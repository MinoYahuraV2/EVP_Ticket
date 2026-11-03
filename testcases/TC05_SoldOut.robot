*** Settings ***
Library          SeleniumLibrary
Library           UcLibrary.py
Resource        ../keywords/common/commonkeywords.robot
Resource          ../keywords/common/loginkeywords.robot
Variables         ../resources/testdata.yaml

Suite Setup       Register Keyword To Run On Failure    Capture Screenshot With Test Name

*** Variables ***
${LASTTICKET_URL}    https://eventpass-ticket-uat.eventpass.biz/event-detail/LastTicket
${IMAGE_PATH}        ../keywords/ticket/QRpic/captured_QR.png
 
*** Keywords ***

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


Login as user1
    Open Undetected Browser   ${BaseUrl}   alias=Browser1
    # Maximize Browser Window
    click escape key to close modal
    Click Login On Navbar
    Click Continue With Google
    user login to website with ${email2} and ${valid_password2}
    click escape key to close modal

Login as user2
    Open Undetected Browser   ${BaseUrl}    alias=Browser2
    # Maximize Browser Window
    click escape key to close modal
    Click Login On Navbar
    Click Continue With Google
    user login to website with ${email} and ${valid_password}
    click escape key to close modal

Select Last Ticket And Go To Payment
    Go To    ${LASTTICKET_URL}
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[1]
    

Verify Ticket Is Sold Out Or Locked
    click escape key to close modal    
    Go To    ${LASTTICKET_URL}

    #=========================
    Wait Until Page Contains Element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]    timeout=10s
      #=========================
    # พอหาเจอแล้ว ค่อยทำการเช็คสถานะ Disabled
    ${BUY_BTN}=    Set Variable    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Element Should Be Disabled    ${BUY_BTN}

Cancel order
    Wait until element is ready then click element    xpath=//button[normalize-space()='Cancel Order' or normalize-space()='ยกเลิกคำสั่งซื้อ']
    Wait until element is ready then click element    xpath=(//button[normalize-space()='Cancel' or normalize-space()='ยกเลิก'])[1]  


Complete Payment Successfully
    Go To    ${LASTTICKET_URL}
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Wait until element is ready then click element    xpath=//button[@id="credit-radio"]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[1]
    Wait Until Element Is Visible    id=gbprimepay-iframe    timeout=20s
    Select Frame    id=gbprimepay-iframe

    Wait Until Element Is Visible    id=number_card
    Type Text Slowly    id=number_card    4535017710535741

    Wait Until Element Is Visible    xpath=//*[@id="payment-customer"]/div/div[4]/div[1]/div/div[1]/select    timeout=20s
    Select From List By Value        xpath=//*[@id="payment-customer"]/div/div[4]/div[1]/div/div[1]/select    05

    Wait Until Element Is Visible    xpath=//*[@id="payment-customer"]/div/div[4]/div[1]/div/div[2]/select    timeout=20s
    Select From List By Label        xpath=//*[@id="payment-customer"]/div/div[4]/div[1]/div/div[2]/select    2028
    Wait Until Element Is Visible    id=cvc    timeout=20s
    Input Text                 id=cvc    184
    Wait Until Element Is Visible    xpath=/html/body/form/div/div[6]/button[1]    timeout=30s
    # Sleep    3s
    # Scroll To The Very Bottom
    Wait until element is ready then click element         xpath=/html/body/form/div/div[6]/button[1]
    Unselect Frame
    Sleep    1s
    Wait Until Element Is Visible    xpath:/html/body/div/form/div/div[3]/div[2]/label/span    timeout=30s
    ${extracted_otp}=    Get Text    xpath:/html/body/div/form/div/div[3]/div[2]/label/span

    # 2. นำค่าที่ดึงได้ ส่งเข้าไปใน Keyword เพื่อกรอก
    Validate OTP    ${extracted_otp}
    Wait Until Element Is Visible    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=50s

Validate OTP
    [Arguments]    ${OTP}
    Wait Until Element Is Visible    xpath:/html/body/div/form/div/div[4]/div[2]/input    timeout=30s
    Input Text    xpath:/html/body/div/form/div/div[4]/div[2]/input    ${OTP}
    Click Element    class:btn-primary
    #หาข้อความ success
    Wait Until Element Is Visible    xpath=//p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=30s



    
*** Test Cases ***

TC_01.test status last ticket

    Login as user1
    Select Last Ticket And Go To Payment
    
    Login as user2
    Verify Ticket Is Sold Out Or Locked

    Switch To Browser    Browser1
    Reload Page
    Cancel order

    Switch To Browser    Browser2
    Sleep    2s
    Reload Page
    Complete Payment Successfully
    
    [Teardown]    Close All Browsers
