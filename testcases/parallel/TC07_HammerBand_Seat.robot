*** Settings ***
Documentation     เลือกโซน / เลือกที่นั่ง / กรอกข้อมูล (ไซส์เสื้อ) ของงาน Hammer Band 50th Hit The World
...               อ้างอิงเคสใน testcases/HammerBand_Seat_Testcases.csv (HB001-HB025 ยกเว้น HB003, HB014, HB020, HB026)
...               ไม่มีเคสไหนจ่ายเงิน เคสที่จองที่นั่งจะยกเลิกคำสั่งซื้อทุกครั้งตอนจบ
...               รัน: cd testcases/parallel แล้ว python -m robot TC07_HammerBand_Seat.robot
...               ต้องเปิด Chrome port 9222 (บัญชี A) และ 9223 (บัญชี B) และ login ไว้ก่อน
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Library           Collections
Resource          ../../keywords/ticket/hammerkeywords.robot

Suite Setup       Register Keyword To Run On Failure    Nothing
Test Teardown     Seat Test Teardown

*** Variables ***
${PORT_A}          9222
${PORT_B}          9223
# ที่นั่งที่จ่ายเงินแล้วใน VIP1 (ใช้กับ HB017)
${PAID_SEAT}       W9
${SUMMARY_JS}      var b=[...document.querySelectorAll('div')].filter(x=>x.innerText.trim().startsWith('ที่นั่งของคุณ')); return b.length? b[0].innerText : '';
${FREE_SEAT_JS}    var s=[...document.querySelectorAll('label.neo-seat')].filter(l=>l.querySelector('img') && l.querySelector('img').src.includes('default-seat')); return s.slice(0, arguments[0]).map(l=>[l.getAttribute('for'), l.innerText.trim()]);

*** Keywords ***
Seat Test Teardown
    [Documentation]    ยกเลิกคำสั่งซื้อที่ค้างในทุก browser ที่เปิด (ทั้งเคสผ่านและเคสพัง) แล้วปิด
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Capture Page Screenshot
    FOR    ${alias}    IN    A    B
        ${open}=    Run Keyword And Return Status    Switch Browser    ${alias}
        IF    ${open}
            Run Keyword And Ignore Error    Unselect Frame
            ${st}    ${msg}=    Run Keyword And Ignore Error    Hammer Clean Up Order
            IF    '${st}' == 'FAIL'    Log    [${alias}] ล้างคำสั่งซื้อไม่สำเร็จ: ${msg}    WARN
        END
    END
    Close All Browsers

Open Account A
    Attach To Specific Chrome    ${PORT_A}    A

Open Account B
    Attach To Specific Chrome    ${PORT_B}    B

Get Seat Summary
    ${text}=    Execute Javascript    ${SUMMARY_JS}
    RETURN    ${text}

Get Free Seats
    [Documentation]    คืนรายการ [for-id, ชื่อที่นั่ง] ของที่นั่งว่าง ${count} ที่แรก
    [Arguments]    ${count}=1
    @{seats}=    Execute Javascript    ${FREE_SEAT_JS}    ARGUMENTS    ${count}
    ${n}=    Get Length    ${seats}
    Should Be True    ${n} >= ${count}    ที่นั่งว่างไม่พอ ต้องการ ${count} มี ${n}
    RETURN    @{seats}

Click Seat
    [Arguments]    ${for_id}
    ${el}=    Get WebElement    css:label.neo-seat[for='${for_id}']
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${el}
    Sleep    1s

Seat Image Should Be
    [Arguments]    ${for_id}    ${kind}
    ${src}=    Get Element Attribute    css:label.neo-seat[for='${for_id}'] img    src
    Should Contain    ${src}    ${kind}    ที่นั่ง ${for_id} ควรเป็น ${kind} แต่เป็น ${src}

Seat Image By Name Should Be
    [Arguments]    ${name}    ${kind}
    ${src}=    Execute Javascript
    ...    var l=[...document.querySelectorAll('label.neo-seat')].find(x=>x.innerText.trim()==arguments[0]);
    ...    if(l) return l.querySelector('img').src;
    ...    return 'not-found';
    ...    ARGUMENTS    ${name}
    IF    '${kind}' == 'unavailable-seat'
        # ที่นั่งเต็มไม่มีตัวหนังสือ จึงหาตามชื่อไม่เจอ = แสดงเป็นเต็ม
        Should Be True    'unavailable-seat' in $src or $src == 'not-found'    ที่นั่ง ${name} ควรเป็นเต็ม แต่เป็น ${src}
    ELSE
        Should Contain    ${src}    ${kind}    ที่นั่ง ${name} ควรเป็น ${kind} แต่เป็น ${src}
    END

Hold One Seat
    [Documentation]    บน browser ปัจจุบัน: เปิดหน้าเลือกที่นั่ง VIP1 เลือกที่นั่งว่าง 1 ที่ แล้วกดชำระเงิน (จองที่นั่ง) คืน [for-id, ชื่อ]
    Open Hammer Seat Page    0
    @{seats}=    Get Free Seats    1
    Click Seat    ${seats}[0][0]
    Click Pay On Seat Page
    Wait Until Location Contains    form-information    timeout=20s
    Wait Until Element Is Visible    ${SIZE_SELECT}    timeout=30s
    RETURN    ${seats}[0]

Cancel Held Order
    [Documentation]    อยู่หน้ากรอกข้อมูล: เลือกไซส์ -> หน้าเลือกช่องทางชำระเงิน -> ยกเลิกคำสั่งซื้อ
    Hammer Form To Payment Page
    Hammer Cancel Order On Payment Page

Find Seat Name On Page
    [Arguments]    ${for_id}
    ${name}=    Execute Javascript    var l=document.querySelector("label.neo-seat[for='"+arguments[0]+"']"); return l? l.innerText.trim() : '';    ARGUMENTS    ${for_id}
    RETURN    ${name}

*** Test Cases ***
HB001 Not Logged In Click Buy Shows Login Popup
    [Documentation]    ยังไม่ login แล้วกดซื้อบัตร -> popup เข้าสู่ระบบ/สมัครสมาชิก
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --window-size\=1920,1080
    Open Browser    ${HAMMER_TICKET}    headlesschrome    alias=GUEST    options=${options}
    Wait Until Keyword Succeeds    30x    1s    Execute Javascript
    ...    var n=['ซื้อบัตร','Buy Ticket','ไปที่บัตร','Go to Tickets']; var b=[...document.querySelectorAll('button')].filter(x=>n.includes(x.innerText.trim()) && x.offsetParent!==null); if(!b.length) throw 'no buy button'; b[b.length-1].click();
    Wait Until Page Contains    เข้าสู่ระบบ/ สมัครสมาชิก    timeout=15s
    Page Should Contain    ดำเนินการต่อด้วย Google
    Page Should Contain    ดำเนินการต่อด้วย email
    Page Should Contain    ยืนยันด้วย OTP

HB002 Logged In Click Buy Goes To Zone Page
    Open Account A
    Open Hammer Zone Page
    Location Should Contain    select-zone
    Element Should Be Visible    id=img-map
    ${areas}=    Get Element Count    css:map[name=zoneMapAreas] area
    Should Be Equal As Integers    ${areas}    15

HB004 Zone List Shows Prices
    Open Account A
    Open Hammer Zone Page
    FOR    ${text}    IN    ZONE : VIP1    ZONE : VIP3    ZONE : A4    ZONE : B6    ZONE : RB2
    ...    2,500 THB    2,000 THB    1,800 THB    1,500 THB
        Page Should Contain    ${text}
    END

HB005 Zone Page Shows Hint Text
    Open Account A
    Open Hammer Zone Page
    Page Should Contain    คลิกที่โซนใดก็ได้จากแผนผังเพื่อเลือกโซน
    Page Should Contain    เลือกบัตรได้หนึ่งโซนต่อการสั่งซื้อหนึ่งครั้งเท่านั้น

HB006 Click VIP1 Goes To Seat Page
    Open Account A
    Open Hammer Seat Page    0
    Location Should Contain    select-seat
    ${sum}=    Get Seat Summary
    Should Contain    ${sum}    ZONE : VIP1
    Should Contain    ${sum}    2,500 THB

HB007 Click Each Price Zone Shows Name And Price
    Open Account A
    FOR    ${idx}    ${zone}    ${price}    IN
    ...    3     ZONE : A1     2,000 THB
    ...    7     ZONE : B1     1,800 THB
    ...    13    ZONE : RB1    1,500 THB
        Open Hammer Seat Page    ${idx}
        ${sum}=    Get Seat Summary
        Should Contain    ${sum}    ${zone}
        Should Contain    ${sum}    ${price}
    END

HB008 Seat Legend Shows Free Selected Full
    Open Account A
    Open Hammer Seat Page    0
    ${legend}=    Execute Javascript    return document.body.innerText
    FOR    ${word}    IN    ว่าง    เลือก    เต็ม
        Should Contain    ${legend}    ${word}
    END

HB009 No Seat Selected Pay Disabled
    Open Account A
    Open Hammer Seat Page    0
    ${sum}=    Get Seat Summary
    Should Match Regexp    ${sum}    Seat\\s*\\n?\\s*-
    Element Should Be Disabled    ${PAY_BTN}

HB010 Click Free Seat Selects It
    Open Account A
    Open Hammer Seat Page    0
    @{seats}=    Get Free Seats    1
    ${id}    ${name}=    Set Variable    ${seats}[0][0]    ${seats}[0][1]
    Click Seat    ${id}
    Seat Image Should Be    ${id}    selected-seat
    ${sum}=    Get Seat Summary
    Should Contain    ${sum}    ${name}
    Element Should Be Enabled    ${PAY_BTN}

HB011 Click Selected Seat Again Unselects It
    Open Account A
    Open Hammer Seat Page    0
    @{seats}=    Get Free Seats    1
    ${id}    ${name}=    Set Variable    ${seats}[0][0]    ${seats}[0][1]
    Click Seat    ${id}
    Seat Image Should Be    ${id}    selected-seat
    Click Seat    ${id}
    Seat Image Should Be    ${id}    default-seat
    ${sum}=    Get Seat Summary
    Should Not Contain    ${sum}    ${name}
    Element Should Be Disabled    ${PAY_BTN}

HB012 Click Full Seat Does Nothing
    Open Account A
    Open Hammer Seat Page    0
    ${id}=    Execute Javascript
    ...    var l=[...document.querySelectorAll('label.neo-seat')].find(x=>x.querySelector('img') && x.querySelector('img').src.includes('unavailable-seat'));
    ...    return l? l.getAttribute('for') : '';
    Should Not Be Empty    ${id}    ไม่มีที่นั่งเต็มในโซนนี้ให้ทดสอบ
    Click Seat    ${id}
    Seat Image Should Be    ${id}    unavailable-seat
    Element Should Be Disabled    ${PAY_BTN}

HB013 Select Many Seats Total Matches
    [Documentation]    เลือก 3 ที่ใน VIP1 -> กล่องสรุปมีครบ 3 ที่ -> หน้ากรอกข้อมูลยอดรวม 7,500 (ยกเลิกคำสั่งซื้อตอนจบ)
    Open Account A
    Open Hammer Seat Page    0
    @{seats}=    Get Free Seats    3
    FOR    ${s}    IN    @{seats}
        Click Seat    ${s}[0]
    END
    ${sum}=    Get Seat Summary
    FOR    ${s}    IN    @{seats}
        Should Contain    ${sum}    ${s}[1]
    END
    Click Pay On Seat Page
    Wait Until Location Contains    form-information    timeout=20s
    Wait Until Page Contains    7,500/THB    timeout=15s
    ${forms}=    Get Element Count    ${SIZE_SELECT}
    Should Be Equal As Integers    ${forms}    3

HB015 Back To Zone Clears Selection
    Open Account A
    Open Hammer Seat Page    0
    @{seats}=    Get Free Seats    1
    ${id}=    Set Variable    ${seats}[0][0]
    Click Seat    ${id}
    Seat Image Should Be    ${id}    selected-seat
    # popup (swal2) ที่กำลังปิดบังลิงก์ได้ จึงคลิกด้วย JavaScript
    ${back}=    Get WebElement    xpath:(//*[normalize-space()='กลับไปเลือกโซน'])[last()]
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${back}
    Wait Until Location Contains    select-zone    timeout=15s
    Click Zone On Map    0
    Seat Image Should Be    ${id}    default-seat

HB016 Seat Held By Other Account Shows Full
    [Documentation]    บัญชี B จองที่นั่ง (กดชำระเงินแล้ว ยังไม่จ่าย) -> บัญชี A เห็นที่นั่งนั้นเป็นเต็ม
    Open Account B
    ${held}=    Hold One Seat
    Open Account A
    Open Hammer Seat Page    0
    Seat Image Should Be    ${held}[0]    unavailable-seat

HB017 Paid Seat Shows Full
    Open Account A
    Open Hammer Seat Page    0
    Seat Image By Name Should Be    ${PAID_SEAT}    unavailable-seat

HB018 Seat From Cancelled Order Becomes Free
    [Documentation]    บัญชี B จองที่นั่งแล้วยกเลิกคำสั่งซื้อ -> บัญชี A เห็นที่นั่งนั้นว่าง
    Open Account B
    ${held}=    Hold One Seat
    Cancel Held Order
    Open Account A
    Open Hammer Seat Page    0
    Seat Image Should Be    ${held}[0]    default-seat

HB019 Two Accounts Same Seat Only One Wins
    [Documentation]    บัญชี A และ B เลือกที่นั่งเดียวกัน แล้วกดชำระเงินแทบพร้อมกัน -> ได้ที่นั่งคนเดียว อีกคนขึ้นแจ้งเตือน
    Open Account A
    Open Hammer Seat Page    0
    @{seats}=    Get Free Seats    1
    ${id}=    Set Variable    ${seats}[0][0]
    Click Seat    ${id}
    Open Account B
    Open Hammer Seat Page    0
    Click Seat    ${id}
    Seat Image Should Be    ${id}    selected-seat
    # กดชำระเงินทั้งสองฝั่งให้ห่างกันน้อยที่สุด
    Switch Browser    A
    ${a_el}=    Get WebElement    ${PAY_BTN}
    Switch Browser    B
    ${b_el}=    Get WebElement    ${PAY_BTN}
    Switch Browser    A
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${a_el}
    Switch Browser    B
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${b_el}
    Sleep    8s
    ${winners}=    Create List
    ${losers}=    Create List
    FOR    ${alias}    IN    A    B
        Switch Browser    ${alias}
        ${url}=    Get Location
        ${pop}=    Execute Javascript    var p=document.querySelector('.swal2-popup'); return p? p.innerText : '';
        IF    'form-information' in $url
            Append To List    ${winners}    ${alias}
        ELSE
            Should Contain    ${pop}    already taken or locked    [${alias}] ไม่ได้ที่นั่ง แต่ไม่ขึ้นแจ้งเตือน: ${pop}
            Append To List    ${losers}    ${alias}
        END
    END
    Log To Console    ได้ที่นั่ง: ${winners} / ไม่ได้: ${losers}
    Length Should Be    ${winners}    1    ควรได้ที่นั่งคนเดียว แต่ได้ ${winners}

HB021 Pay Goes To Form Page With Seat And Timer
    Open Account A
    ${held}=    Hold One Seat
    Page Should Contain    Seat : ${held}[1]
    Page Should Contain    กรุณากรอกข้อมูลให้เสร็จภายใน

HB022 Shirt Size Options And Required
    Open Account A
    Hold One Seat
    @{opts}=    Get List Items    ${SIZE_SELECT}
    List Should Contain Value    ${opts}    ไซส์ S
    List Should Contain Value    ${opts}    ไซส์ M
    List Should Contain Value    ${opts}    ไซส์ L
    Page Should Contain Element    xpath://label[contains(normalize-space(),'ไซส์เสื้อ')]/span[normalize-space()='*']

HB023 No Shirt Size Buy Disabled
    Open Account A
    Hold One Seat
    Element Should Be Disabled    ${FORM_BUY_BTN}

HB024 Many Seats Partial Sizes Buy Disabled
    Open Account A
    Open Hammer Seat Page    0
    @{seats}=    Get Free Seats    2
    FOR    ${s}    IN    @{seats}
        Click Seat    ${s}[0]
    END
    Click Pay On Seat Page
    Wait Until Location Contains    form-information    timeout=20s
    Wait Until Element Is Visible    ${SIZE_SELECT}    timeout=20s
    Select From List By Value    xpath:(//label[contains(normalize-space(),'ไซส์เสื้อ')]/following-sibling::select)[1]    ไซส์ M
    Element Should Be Disabled    ${FORM_BUY_BTN}
    Select From List By Value    xpath:(//label[contains(normalize-space(),'ไซส์เสื้อ')]/following-sibling::select)[2]    ไซส์ L
    Wait Until Element Is Enabled    ${FORM_BUY_BTN}    timeout=10s

HB025 All Sizes Selected Goes To Payment Page
    Open Account A
    Hold One Seat
    ${forms}=    Hammer Form To Payment Page
    Should Be Equal As Integers    ${forms}    1
    Location Should Contain    ticket-payment
    Wait Until Page Contains Element    id=credit-radio    timeout=30s
    Page Should Contain Element    id=prompt-pay-radio
