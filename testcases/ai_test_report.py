#!/usr/bin/env python3
"""
ai_test_report.py
วิเคราะห์ผล Robot Framework test ทั้งหมดว่ามีกี่ testcases Pass กี่ Testcases และที่ fail ด้วย local vision LLM (ผ่าน KoboldCpp)
แล้วสร้างรายงาน HTML สรุปจำนวนเทสที่รัน/ผ่าน/ไม่ผ่าน สาเหตุที่น่าจะเป็น พร้อม screenshot และคำแนะนำ

ก่อนใช้งาน: เปิด KoboldCpp ค้างไว้ (โหลดโมเดล + mmproj แล้ว, backend Vulkan)
ปกติจะรัน API อยู่ที่ http://localhost:5001

วิธีใช้งาน (รันหลังจากรัน robot test เสร็จ):
    python ai_test_report.py --output-xml output.xml --output-dir results --report ai_report.html

ติดตั้ง dependency ก่อนใช้งาน:
    pip install robotframework requests
"""

import argparse
import base64
import html
import os
import re
import sys
from datetime import datetime
from functools import partial
from pathlib import Path
from urllib.parse import quote

import requests
from robot.api import ExecutionResult, ResultVisitor


SCREENSHOT_PATTERN = re.compile(r'([\w\-./\\\u0E00-\u0E7F]+\.(?:png|jpg|jpeg))', re.IGNORECASE)
 # เปลี่ยนทุกครั้งที่แก้สคริปต์ เพื่อเช็คว่ารันไฟล์ล่าสุดหรือยัง

# อักขระจีน (Han) และเครื่องหมายวรรคตอนจีน/fullwidth ที่โมเดลตระกูล Qwen มักหลุดออกมาเอง
CJK_PATTERN = re.compile(r'[\u3000-\u303f\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff00-\uffef]')

# คำสั่งระดับ system เขียนเป็นภาษาอังกฤษ เพราะโมเดลทำตามได้แม่นกว่าคำสั่งภาษาไทย
SYSTEM_PROMPT = (
    "You are a QA automation assistant analysing failed Robot Framework + Selenium tests. "
    "Always answer in Thai only. Never output Chinese characters or Chinese punctuation, "
    "even if you think you see Chinese in the image. "
    "Keep technical terms, element names and quoted UI text exactly as they appear (English or Thai). "
    "The web UI under test is in Thai and English only. "
    "If text in the screenshot is too small or blurry to read, say that you cannot read it instead of guessing."
)

# ต่อท้าย prompt ตอนถามซ้ำ เมื่อคำตอบรอบก่อนมีอักขระจีนปน
RETRY_SUFFIX = (
    "\n\nIMPORTANT: Your previous answer contained Chinese characters. "
    "Answer again in Thai only. Do not use any Chinese characters."
)

PROMPT_TEMPLATE = """คุณเป็นผู้เชี่ยวชาญด้าน QA Automation กำลังช่วยวิเคราะห์ automated test ที่ fail (Robot Framework + Selenium)

=== ข้อมูล error จริงจาก log (สำคัญที่สุด ต้องอ้างอิงในคำตอบ) ===
Test case: {test_name}
Error message: "{error_message}"
Keyword ที่ fail: {failed_keyword}
===

คำสั่ง: ให้อ่าน error message ข้างบนก่อนเป็นอันดับแรก แล้วดู screenshot ประกอบเพื่อหาหลักฐานสนับสนุน
ห้ามตอบทั่วไปโดยไม่อ้างอิง error message ที่ให้มา
ข้อควรระวัง: UI ของระบบที่ทดสอบมีเฉพาะภาษาไทยและอังกฤษ ไม่มีภาษาจีน ห้ามอ้างว่าเจอภาษาจีนในภาพและห้ามตอบเป็นภาษาจีน ถ้าข้อความในภาพเล็กหรือเบลอจนอ่านไม่ออก ให้บอกตรงๆ ว่าอ่านไม่ออก ห้ามเดา

ตอบเป็นภาษาไทย กระชับ เป็นข้อๆ:
1. คัดลอก error message ข้างบนมาตรงๆ ตามต้นฉบับ (ห้ามแปลหรือเปลี่ยนคำ) แล้วอธิบายความหมายเป็นภาษาไทยสั้นๆ
2. เทียบ error กับภาพจาก screenshot และอธิบายสาเหตุที่error จากที่ดูบนรูป screenshot (เช่น หาข้อความที่คาดว่าจะเจอไม่เจอจริงในภาพ, มี popup บัง, หน้ายังโหลดไม่เสร็จ, หน้าผิดจากที่ควรจะเป็น)
3. ข้อเสนอแนะเบื้องต้นในการแก้ไข
"""


class FailureCollector(ResultVisitor):
    """เดินผ่านผลลัพธ์ output.xml นับจำนวน test ทั้งหมด (PASS / FAIL / SKIP)
    และเก็บรายละเอียดเฉพาะ test ที่ fail พร้อม error message,
    keyword ที่ fail และชื่อไฟล์ screenshot ที่ถูกอ้างถึงใน log"""

    def __init__(self):
        self.failures = []
        self.total = 0
        self.passed = 0
        self.failed = 0
        self.skipped = 0

    def stats(self):
        """สรุปตัวเลขสำหรับแสดงผล อัตราผ่านคิดจาก passed / total (รวม skip)"""
        executed = self.passed + self.failed  # ไม่นับ skip
        return {
            "total": self.total,
            "passed": self.passed,
            "failed": self.failed,
            "skipped": self.skipped,
            "pass_rate": (self.passed / self.total * 100) if self.total else 0.0,
            "pass_rate_executed": (self.passed / executed * 100) if executed else 0.0,
        }

    def visit_test(self, test):
        self.total += 1
        if test.status == "PASS":
            self.passed += 1
        elif test.status == "SKIP":
            self.skipped += 1
        elif test.status == "FAIL":
            self.failed += 1

        if test.status != "FAIL":
            return

        failed_keywords = []
        screenshots = []

        def walk(body):
            for item in body:
                is_message = hasattr(item, "message") and not hasattr(item, "body")
                if is_message:
                    text = item.message or ""
                    for m in SCREENSHOT_PATTERN.findall(text):
                        screenshots.append(m)
                    continue

                if hasattr(item, "body"):
                    # นับเฉพาะ keyword จริง (ข้ามบล็อก IF/FOR/TRY ที่การอ่าน .name จะขึ้นคำเตือน deprecated ของ RF)
                    is_keyword = getattr(item, "type", "") in ("KEYWORD", "SETUP", "TEARDOWN")
                    if is_keyword and getattr(item, "status", None) == "FAIL" and getattr(item, "name", None):
                        failed_keywords.append(item.name)
                    walk(item.body)

        walk(test.body)
        for fixture in (test.setup, test.teardown):  # รูปอาจถูกถ่ายใน setup/teardown
            if fixture:
                walk([fixture])

        self.failures.append({
            "name": test.name,
            "long_name": test.longname,
            "message": test.message,
            "failed_keywords": failed_keywords,
            "screenshots": screenshots,
        })


def find_screenshot_path(filename, output_dir):
    """screenshot ใน log มักถูกอ้างเป็น relative path ลองหาในโฟลเดอร์ output ให้
    ถ้าไม่เจอ จะค้นต่อในโฟลเดอร์ย่อยทั้งหมด (เช่น pabot_results\\N) ด้วยชื่อไฟล์"""
    candidates = [
        os.path.join(output_dir, filename),
        os.path.join(output_dir, os.path.basename(filename)),
        filename,
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c

    target = os.path.basename(filename.replace("\\", "/"))
    for root, _dirs, files in os.walk(output_dir):
        if target in files:
            return os.path.join(root, target)
    return None


def _extract_chat_content(response_json):
    try:
        return response_json["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError):
        return "[รูปแบบผลลัพธ์ไม่ตรงกับที่คาด — ตรวจสอบว่า KoboldCpp เปิด API อยู่และโหลดโมเดลแล้ว]"


def _chat(messages, api_url, timeout, max_tokens, temperature):
    """ส่งข้อความไป KoboldCpp (OpenAI-compatible) คืนคำตอบของโมเดล
    หรือข้อความ error ที่ขึ้นต้นด้วย [ ถ้าเรียกไม่สำเร็จ"""
    try:
        resp = requests.post(
            f"{api_url}/v1/chat/completions",
            json={
                "messages": messages,
                "max_tokens": max_tokens,
                "temperature": temperature,
            },
            timeout=timeout,
        )
        resp.raise_for_status()
        return _extract_chat_content(resp.json())
    except requests.Timeout:
        return (f"[KoboldCpp ตอบช้าเกิน {timeout} วินาที — เช็คว่าโหลดโมเดลลง GPU (Vulkan) จริงไหม "
                f"หรือเพิ่ม --timeout ให้มากขึ้น]")
    except requests.RequestException as e:
        return f"[เรียก KoboldCpp ไม่สำเร็จ: {e} — เช็คว่าเปิด KoboldCpp ค้างไว้และโหลดโมเดล+mmproj แล้วหรือยัง]"


def analyze_with_kobold(image_path, prompt, api_url, timeout=300, max_tokens=600, temperature=0.2):
    try:
        with open(image_path, "rb") as f:
            img_b64 = base64.b64encode(f.read()).decode("utf-8")
    except OSError as e:
        return f"[ไม่สามารถเปิดไฟล์รูปได้: {e}]"

    ext = os.path.splitext(image_path)[1].lstrip(".").lower() or "png"
    data_url = f"data:image/{ext};base64,{img_b64}"

    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {
            "role": "user",
            "content": [
                {"type": "text", "text": prompt},
                {"type": "image_url", "image_url": {"url": data_url}},
            ],
        },
    ]
    return _chat(messages, api_url, timeout, max_tokens, temperature)


def analyze_text_only(prompt, api_url, timeout=300, max_tokens=600, temperature=0.2):
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": prompt},
    ]
    return _chat(messages, api_url, timeout, max_tokens, temperature)


def contains_cjk(text):
    return bool(CJK_PATTERN.search(text or ""))


def analyze_with_language_guard(analyze_fn, prompt, retries):
    """เรียกโมเดล ถ้าคำตอบมีอักขระจีนปนจะถามซ้ำ (สูงสุด retries ครั้ง)
    พร้อมย้ำให้ตอบเป็นภาษาไทย ถ้าถามซ้ำแล้วยังมีอยู่จะใส่คำเตือนไว้หัวคำตอบ"""
    result = analyze_fn(prompt)
    if retries <= 0:
        return result  # ปิดการตรวจอักขระจีน (เช่น ระบบที่ทดสอบมี UI ภาษาจีนจริง)
    attempts = 0
    while contains_cjk(result) and attempts < retries:
        attempts += 1
        print(f"พบอักขระจีนในคำตอบ ถามซ้ำครั้งที่ {attempts}/{retries} ... ", end="", flush=True)
        result = analyze_fn(prompt + RETRY_SUFFIX)
    if contains_cjk(result):
        result = ("[คำเตือน: คำตอบของโมเดลยังมีอักขระภาษาจีนปนอยู่แม้ถามซ้ำแล้ว "
                  "ควรตรวจสอบกับ error message และรูปจริงอีกครั้ง]\n\n" + result)
    return result


def print_summary(stats):
    """พิมพ์สรุปจำนวนเทสลง console"""
    print("=" * 50)
    print(f"รันทั้งหมด : {stats['total']} testcases")
    print(f"ผ่าน (PASS): {stats['passed']}")
    print(f"ไม่ผ่าน (FAIL): {stats['failed']}")
    if stats["skipped"]:
        print(f"ข้าม (SKIP): {stats['skipped']}")
    print(f"อัตราผ่าน  : {stats['pass_rate']:.1f}%")
    print("=" * 50)


REPORT_CSS = """
  body { font-family: 'Segoe UI', Tahoma, sans-serif; margin: 40px; background:#f7f7f9; color:#222; }
  h1 { color:#c0392b; }
  .case { background:#fff; padding:20px; border-radius:8px; margin-bottom:20px; box-shadow:0 1px 3px rgba(0,0,0,0.1); }
  .grid { display:flex; gap:20px; flex-wrap:wrap; align-items:flex-start; }
  .analysis { flex:1; min-width:300px; }
  pre { white-space:pre-wrap; background:#f0f0f0; padding:10px; border-radius:6px; }
  .meta { color:#666; font-size:0.9em; }
  .shot { max-width:500px; }
  .thumb { display:block; max-width:100%; border:1px solid #ccc; border-radius:6px; cursor:zoom-in; }
  .thumb:hover { box-shadow:0 0 0 3px rgba(52,152,219,0.4); }
  .hint { color:#888; font-size:0.8em; margin:4px 0 0; }

  .summary { display:flex; gap:16px; flex-wrap:wrap; margin:16px 0 12px; }
  .stat { flex:1; min-width:140px; background:#fff; border-radius:8px; padding:16px 20px;
          box-shadow:0 1px 3px rgba(0,0,0,0.1); border-top:4px solid #95a5a6; }
  .stat .num { display:block; font-size:2.2em; font-weight:700; line-height:1.1; }
  .stat .label { color:#666; font-size:0.95em; }
  .stat.total { border-top-color:#34495e; }
  .stat.pass  { border-top-color:#27ae60; } .stat.pass .num { color:#27ae60; }
  .stat.fail  { border-top-color:#c0392b; } .stat.fail .num { color:#c0392b; }
  .stat.skip  { border-top-color:#f39c12; } .stat.skip .num { color:#d68910; }
  .stat.rate  { border-top-color:#2980b9; } .stat.rate .num { color:#2980b9; }
  .bar { display:flex; height:14px; border-radius:7px; overflow:hidden; background:#e5e5e5; margin-bottom:8px; }
  .bar span { display:block; height:100%; }
  .bar .b-pass { background:#27ae60; } .bar .b-fail { background:#c0392b; } .bar .b-skip { background:#f39c12; }

  #lightbox { display:none; position:fixed; top:0; right:0; bottom:0; left:0; z-index:1000;
              background:rgba(0,0,0,0.88); overflow:auto; padding:24px; box-sizing:border-box; }
  #lightbox.open { display:flex; }
  #lightbox-img { margin:auto; max-width:calc(100vw - 48px); max-height:calc(100vh - 48px); cursor:zoom-in; background:#fff; }
  #lightbox-img.full { max-width:none; max-height:none; cursor:zoom-out; }
  #lightbox-close { position:fixed; top:12px; right:16px; z-index:1001; border:0; border-radius:50%;
                    width:36px; height:36px; font-size:18px; cursor:pointer; background:#fff; color:#222; }
  #lightbox-hint { position:fixed; bottom:10px; left:0; right:0; text-align:center; color:#ddd;
                   font-size:0.85em; pointer-events:none; }
"""

REPORT_JS = """
(function () {
  var box = document.getElementById('lightbox');
  var big = document.getElementById('lightbox-img');

  function openBox(src, alt) {
    big.src = src;
    big.alt = alt || '';
    big.classList.remove('full');
    box.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeBox() {
    box.classList.remove('open');
    big.removeAttribute('src');
    document.body.style.overflow = '';
  }

  document.addEventListener('click', function (e) {
    var t = e.target;
    if (t.classList && t.classList.contains('thumb')) { openBox(t.getAttribute('src'), t.alt); return; }
    if (t === big) { big.classList.toggle('full'); return; }
    if (box.classList.contains('open')) { closeBox(); }
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && box.classList.contains('open')) { closeBox(); }
  });
})();
"""


def _image_src(image_path, report_path):
    """สร้างค่า src ของ <img> เป็น path เทียบกับที่ตั้งของ report (ใช้ / และ encode อักขระพิเศษ)"""
    report_dir = os.path.dirname(os.path.abspath(report_path))
    try:
        rel = os.path.relpath(image_path, report_dir).replace(os.sep, "/")
        return quote(rel)
    except ValueError:
        # คนละไดรฟ์ (เช่น report อยู่ C: รูปอยู่ D:) เทียบ path ไม่ได้ ใช้ file:// แทน
        return Path(os.path.abspath(image_path)).as_uri()


def _summary_html(stats):
    """กล่องสรุปจำนวนเทส + แถบสัดส่วน pass/fail/skip"""
    total = stats["total"]

    def pct(n):
        return (n / total * 100) if total else 0

    skip_card = ""
    if stats["skipped"]:
        skip_card = (f'<div class="stat skip"><span class="num">{stats["skipped"]}</span>'
                     f'<span class="label">ข้าม (SKIP)</span></div>')

    return f"""
<div class="summary">
  <div class="stat total"><span class="num">{total}</span><span class="label">รันทั้งหมด (testcases)</span></div>
  <div class="stat pass"><span class="num">{stats['passed']}</span><span class="label">ผ่าน (PASS)</span></div>
  <div class="stat fail"><span class="num">{stats['failed']}</span><span class="label">ไม่ผ่าน (FAIL)</span></div>
  {skip_card}
  <div class="stat rate"><span class="num">{stats['pass_rate']:.1f}%</span><span class="label">อัตราผ่าน</span></div>
</div>
<div class="bar" title="PASS {stats['passed']} / FAIL {stats['failed']} / SKIP {stats['skipped']}">
  <span class="b-pass" style="width:{pct(stats['passed']):.2f}%"></span>
  <span class="b-fail" style="width:{pct(stats['failed']):.2f}%"></span>
  <span class="b-skip" style="width:{pct(stats['skipped']):.2f}%"></span>
</div>
"""


def build_html_report(failures_analyzed, report_path, stats):
    rows = []
    for f in failures_analyzed:
        if f["screenshot_path"]:
            src = html.escape(_image_src(f["screenshot_path"], report_path), quote=True)
            name_attr = html.escape(f["name"], quote=True)
            shot_html = (
                '<div class="shot">'
                f'<img class="thumb" src="{src}" alt="screenshot: {name_attr}" title="คลิกเพื่อขยาย">'
                '<p class="hint">คลิกที่รูปเพื่อขยาย</p>'
                '</div>'
            )
        else:
            note = html.escape(f.get("screenshot_note") or "")
            shot_html = f'<em>(ไม่พบ screenshot)</em><p class="hint">{note}</p>'

        rows.append(f"""
        <div class="case">
          <h2>{html.escape(f['name'])}</h2>
          <p><b>Error:</b> {html.escape(str(f['message']))}</p>
          <p><b>Failed keyword:</b> {html.escape(', '.join(f['failed_keywords']) or '-')}</p>
          <div class="grid">
            <div>{shot_html}</div>
            <div class="analysis"><b>AI วิเคราะห์:</b><pre>{html.escape(f['analysis'])}</pre></div>
          </div>
        </div>
        <hr>
        """)

    if rows:
        failures_section = f"<h2>รายละเอียดเทสที่ไม่ผ่าน ({len(rows)} เคส)</h2>\n" + "".join(rows)
    elif stats["total"]:
        failures_section = "<p>ไม่มี test fail 🎉</p>"
    else:
        failures_section = "<p>ไม่พบ testcase ใน output.xml</p>"

    html_doc = f"""<!DOCTYPE html>
<html lang="th">
<head>
<meta charset="utf-8">
<title>AI Test Summary Report</title>
<style>{REPORT_CSS}</style>
</head>
<body>
<h1>AI Test Summary Report</h1>
<p class="meta">สร้างเมื่อ: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
{_summary_html(stats)}
<hr>
{failures_section}

<div id="lightbox" role="dialog" aria-modal="true" aria-label="ดูรูปขยาย">
  <button id="lightbox-close" type="button" aria-label="ปิด">&#10005;</button>
  <img id="lightbox-img" alt="">
  <div id="lightbox-hint">คลิกรูปเพื่อสลับขนาดจริง · คลิกพื้นหลังหรือกด Esc เพื่อปิด</div>
</div>
<script>{REPORT_JS}</script>
</body>
</html>"""

    with open(report_path, "w", encoding="utf-8") as f:
        f.write(html_doc)


def main():
    parser = argparse.ArgumentParser(description="วิเคราะห์ RF test failure ด้วย local vision LLM (KoboldCpp)")
    parser.add_argument("--output-xml", default="output.xml", help="path ไปยัง output.xml ของ Robot Framework")
    parser.add_argument("--output-dir", default=".", help="โฟลเดอร์ที่เก็บ screenshot (ปกติคือโฟลเดอร์เดียวกับ output.xml)")
    parser.add_argument("--api-url", default="http://localhost:5001", help="URL ของ KoboldCpp API (ค่าเริ่มต้นตรงกับที่ KoboldCpp เปิดเอง)")
    parser.add_argument("--report", default="ai_report.html", help="path ของไฟล์รายงานที่จะสร้าง")
    parser.add_argument("--timeout", type=int, default=300, help="เวลารอคำตอบจาก KoboldCpp ต่อ 1 test (วินาที) ค่าเริ่มต้น 300")
    parser.add_argument("--max-tokens", type=int, default=600, help="ความยาวคำตอบสูงสุดที่ให้โมเดลตอบต่อ 1 test")
    parser.add_argument("--temperature", type=float, default=0.2, help="ความสุ่มของคำตอบ ยิ่งต่ำยิ่งนิ่ง (ค่าเริ่มต้น 0.2)")
    parser.add_argument("--cjk-retries", type=int, default=2, help="ถ้าคำตอบมีอักขระจีนปน ให้ถามซ้ำกี่ครั้ง (0 = ไม่ตรวจ/ไม่ถามซ้ำ)")
    args = parser.parse_args()

    if not os.path.isfile(args.output_xml):
        print(f"ไม่พบไฟล์ {args.output_xml}", file=sys.stderr)
        sys.exit(1)

    result = ExecutionResult(args.output_xml)
    collector = FailureCollector()
    result.visit(collector)
    stats = collector.stats()
    print_summary(stats)

    if not collector.failures:
        print("ไม่มี test fail — ไม่ต้องวิเคราะห์อะไรเพิ่ม")
        build_html_report([], args.report, stats)
        print(f"\nสร้างรายงานเสร็จแล้ว: {args.report}")
        return

    print(f"พบ test fail {len(collector.failures)} รายการ กำลังวิเคราะห์...")

    analyzed = []
    for f in collector.failures:
        screenshot_path = None
        refs = list(dict.fromkeys(f["screenshots"]))  # ชื่อไฟล์ที่ log อ้างถึง (ตัดรายการซ้ำ)
        for shot in refs:
            p = find_screenshot_path(shot, args.output_dir)
            if p:
                screenshot_path = p
                break

        if screenshot_path:
            screenshot_note = None
        elif refs:
            screenshot_note = (f"log อ้างถึงรูป {', '.join(refs)} แต่ไม่พบไฟล์ใน {os.path.abspath(args.output_dir)} "
                               f"(รวมโฟลเดอร์ย่อย) ให้เช็คว่า --output-dir ชี้ไปโฟลเดอร์ที่มีไฟล์ .png")
        else:
            screenshot_note = "ไม่พบการอ้างถึงไฟล์รูปในผลของเทสเคสนี้ใน output.xml (เทสเคสนี้อาจไม่ได้ถ่าย screenshot)"

        prompt = PROMPT_TEMPLATE.format(
            test_name=f["name"],
            error_message=f["message"] or "-",
            failed_keyword=", ".join(f["failed_keywords"]) or "-",
        )

        print(f"  - {f['name']} ... ", end="", flush=True)
        if screenshot_path:
            analyze_fn = partial(analyze_with_kobold, screenshot_path, api_url=args.api_url,
                                 timeout=args.timeout, max_tokens=args.max_tokens,
                                 temperature=args.temperature)
        else:
            prompt += "\n(หมายเหตุ: ไม่พบ screenshot ให้วิเคราะห์จาก log เท่านั้น)"
            analyze_fn = partial(analyze_text_only, api_url=args.api_url,
                                 timeout=args.timeout, max_tokens=args.max_tokens,
                                 temperature=args.temperature)
        analysis = analyze_with_language_guard(analyze_fn, prompt, args.cjk_retries)
        print("เสร็จ")
        print(f"      รูป: {screenshot_path}" if screenshot_path else f"      ไม่พบรูป: {screenshot_note}")

        analyzed.append({**f, "screenshot_path": screenshot_path, "screenshot_note": screenshot_note,
                         "analysis": analysis})

    build_html_report(analyzed, args.report, stats)
    print(f"\nสร้างรายงานเสร็จแล้ว: {args.report}")


if __name__ == "__main__":
    main()