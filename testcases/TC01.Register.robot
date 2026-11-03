*** Settings ***
Library           SeleniumLibrary
Library           UcLibrary.py
Resource          ../keywords/register/RegisterALLKeyword.robot
Resource          ../keywords/common/loginkeywords.robot
Variables         ../resources/testdata.yaml

Suite Setup       Login Workflow
Suite Teardown    Close Browser

Test Template     User Register Flow Data Driven

*** Keywords ***
Login Workflow
    Register Keyword To Run On Failure    Capture Screenshot With Test Name
    Open Undetected Browser   ${BaseUrl}
    click escape key to close modal
    Click Login On Navbar
    Click Continue With Google
    user login to website with ${email2} and ${valid_password2}
    # ต้องลบบัญชีของ email ใน cms ก่อน
    click escape key to close modal

Capture Screenshot With Test Name
    [Documentation]    เซฟ screenshot ตอน fail เป็นชื่อ "<ชื่อเทสเคส>.png" ถ้าชื่อซ้ำจะถูกเขียนทับ
    ...    เซฟลงโฟลเดอร์ output หลักโดยตรง (ไม่ผ่านการ copy ของ pabot ที่เติม timestamp-เลขโฟลเดอร์นำหน้าให้)
    ${raw_name}=    Get Variable Value    ${TEST NAME}    ${SUITE NAME}
    ${name}=    Replace String Using Regexp    ${raw_name}    [^\\w\\-\\u0E00-\\u0E7F]+    _
    ${name}=    Set Variable    ${name}[:120]
    # ถ้ารันด้วย pabot ${OUTPUT DIR} จะเป็น <โฟลเดอร์หลัก>/pabot_results/<เลข> ให้ตัดเอาแค่ส่วนหน้า pabot_results
    ${parts}=    Split String    ${OUTPUT DIR}    pabot_results    max_split=1
    ${base_dir}=    Normalize Path    ${parts}[0]
    # ปิด log ชั่วคราว เพื่อไม่ให้ SeleniumLibrary/OperatingSystem ใส่ลิงก์รูปที่ path เพี้ยนใน log.html (เราใส่ลิงก์ที่ถูกต้องเองด้านล่าง)
    ${old_level}=    Set Log Level    NONE
    TRY
        # ลบรูปชื่อเดิมก่อน กันลิงก์ไปชี้รูปเก่าของรอบก่อนในกรณีที่รอบนี้ถ่ายไม่ได้
        Remove File    ${base_dir}${/}${name}.png
        Capture Page Screenshot    ${base_dir}${/}${name}.png
        # เช็คว่าไฟล์ถูกบันทึกจริงไหม (ถ้าไม่มี browser เปิดอยู่ SeleniumLibrary จะข้ามการถ่ายรูปโดยไม่ error)
        ${saved}=    Run Keyword And Return Status    File Should Exist    ${base_dir}${/}${name}.png
    FINALLY
        Set Log Level    ${old_level}
    END
    # ใส่ลิงก์รูปใน log เฉพาะเมื่อไฟล์ถูกบันทึกจริง
    IF    ${saved}
        Log    <a href="${name}.png"><img src="${name}.png" width="800px"></a>    html=True
    ELSE
        Log    ไม่ได้บันทึก screenshot (อาจไม่มี browser เปิดอยู่)
    END


*** Test Cases ***

###  python -m robot TC01.Register.robot

# ชื่อ Test Case                                      Lang     Name        Lastname     Birth    Privacy    Success    CheckContractUs

# # # ==================== ชุดทดสอบภาษาไทย (TH) ====================
TH 1. Register with birth date = null                 TH      NN            LN         NO       YES        โปรดระบุ        ${EMPTY}
TH 2. Register with name = null                       TH      ${EMPTY}      LN         YES      YES        โปรดระบุ        ${EMPTY}
TH 3. Register with lastname = null                   TH      NAME       ${EMPTY}      YES      YES        โปรดระบุ        ${EMPTY}
TH 4. Register with name and lastname = null          TH      ${EMPTY}   ${EMPTY}      YES      YES        โปรดระบุ        ${EMPTY}
TH 5. Register without accepting privacy              TH      NAME       LASTNAME      YES      NO         โปรดระบุ        ${EMPTY}


# # ==================== ชุดทดสอบภาษาอังกฤษ (EN) ====================
EN 1. Register with birth date = null                 EN      NAME       LASTNAME       NO       YES       Please specify    ${EMPTY}
EN 2. Register with name = null                       EN     ${EMPTY}    LASTNAME      YES      YES        Please specify    ${EMPTY}
EN 3. Register with lastname = null                   EN     NAME        ${EMPTY}      YES      YES        Please specify    ${EMPTY}
EN 4. Register with name and lastname = null          EN     ${EMPTY}    ${EMPTY}      YES      YES        Please specify    ${EMPTY}
EN 5. Register without accepting privacy              EN     NAME       LASTNAME      YES      NO          Please specify    ${EMPTY}



######=====================ไทย Login สำเร็จ=============================

EN 11. Register with valid information                 EN      Peet           Peet          YES      YES        Search        checkContactUs
