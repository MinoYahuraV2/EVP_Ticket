*** Settings ***
Documentation     ซื้อบัตรงาน Hammer Band 50th Hit The World (เลือกโซนจากผัง -> เลือกที่นั่ง -> จ่ายบัตรเครดิต -> เช็คบัตรใน My Tickets)
...               รัน: cd testcases/parallel แล้ว python -m robot TC06_HammerBand.robot  (ต้องเปิด Chrome port 9222 และ login ไว้ก่อน)
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Resource          ../../keywords/ticket/hammerkeywords.robot

Suite Setup       Register Keyword To Run On Failure    Nothing
Test Teardown     Hammer Teardown
Test Template     Buy Hammer Band Ticket

*** Keywords ***
Select Hammer Zone Seat
    [Arguments]    ${area_index}
    Maximize Browser Window
    Remove File    price_log.txt
    # จอแคบจะเห็นปุ่ม "ไปที่บัตร" แทน "ซื้อบัตร" จึงคลิกปุ่มที่มองเห็นอยู่ด้วย JavaScript
    Wait Until Keyword Succeeds    30x    1s    Click Visible Buy Button
    Wait Until Location Contains    select-zone    timeout=20s
    Click Zone On Map    ${area_index}
    # ป้ายคุกกี้บังที่นั่งได้ กดยอมรับก่อน (ถ้ามี) แล้วคลิกที่นั่ง/ปุ่มด้วย JavaScript กันโดนบัง
    Run Keyword And Ignore Error    Click Element    xpath://button[normalize-space()='ยอมรับ'] | //div[normalize-space()='ยอมรับ']
    # ล้างตะกร้า: ถ้ามีที่นั่งค้าง (สีเขียว) จากรอบก่อน ต้องไปยกเลิกที่หน้าเลือกช่องทางชำระเงินก่อน
    Sleep    3s
    ${green}=    Get Element Count    xpath://label[contains(@class,'neo-seat')]//img[contains(@src,'selected-seat')]
    IF    ${green} > 0
        Log To Console    🧹 เจอที่นั่งค้าง ${green} ที่ กำลังยกเลิก
        Hammer Clear Held Seats
        Go To    ${HAMMER_TICKET}
        Wait Until Keyword Succeeds    30x    1s    Click Visible Buy Button
        Click Zone On Map    ${area_index}
        Sleep    3s
        ${green}=    Get Element Count    xpath://label[contains(@class,'neo-seat')]//img[contains(@src,'selected-seat')]
        Should Be Equal As Integers    ${green}    0    ล้างตะกร้าแล้วยังมีที่นั่งค้าง ${green} ที่ หยุดเทสต์ไว้ก่อน
    END
    # เลือกที่นั่งว่างตัวแรก (ที่นั่งเต็มใช้รูป unavailable-seat.png)
    ${seat}=    Set Variable    xpath:(//label[contains(@class,'neo-seat')][.//img[contains(@src,'default-seat')]])[1]
    Wait Until Page Contains Element    ${seat}    timeout=20s
    ${seat_el}=    Get WebElement    ${seat}
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${seat_el}
    ${pay}=    Set Variable    xpath://button[normalize-space()='ชำระเงิน' or normalize-space()='Check Out']
    Wait Until Element Is Enabled    ${pay}    timeout=20s
    ${pay_el}=    Get WebElement    ${pay}
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${pay_el}
    # หน้ากรอกข้อมูล: งานนี้บังคับเลือกไซส์เสื้อ
    Wait Until Location Contains    form-information    timeout=20s
    ${forms}=    Hammer Form To Payment Page
    # ถ้ามีที่นั่งค้างแอบรวมมา (ไม่ขึ้นสีเขียว) จะมีมากกว่า 1 ฟอร์ม -> ยกเลิกทั้งคำสั่งซื้อแล้วหยุด
    IF    ${forms} != 1
        Hammer Cancel Order On Payment Page
        Fail    มีที่นั่งค้างรวมมา ${forms} ที่ ยกเลิกคำสั่งซื้อแล้ว รันใหม่อีกครั้ง
    END
    Sleep    1s
    get seat fullscreen

Hammer QR Pay
    [Documentation]    เหมือน QR Pay2 แต่ popup ยืนยันอันที่สองของ GB Prime QR tool บางครั้งไม่ขึ้น (เงินเข้าตั้งแต่ popup แรก) จึงไม่บังคับรอ
    Scroll To PromptPay
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    # มีปุ่ม "ถัดไป" ซ่อนอยู่หลายอัน คลิกอันที่มองเห็นด้วย JavaScript
    Run Keyword And Ignore Error    Click Element    xpath://button[normalize-space()='ยอมรับ']
    ${ok}=    Execute Javascript
    ...    var b=[...document.querySelectorAll('button')].filter(x=>['ถัดไป','Next'].includes(x.innerText.trim()) && x.offsetParent!==null);
    ...    if(!b.length) return false; b[0].scrollIntoView({block:'center'}); b[0].click(); return true;
    Should Be True    ${ok}    ไม่เจอปุ่มถัดไป
    Capture2
    Hammer Upload QR Image
    Check Success
    Check Payment Success

Hammer Xendit QR Pay
    [Documentation]    จ่าย QR ของ Xendit: กดลิงก์ "จำลองว่าชำระเงินแล้ว" -> หน้า Xendit QR Simulate กด Simulate Payment
    ...                -> กลับหน้า QR คลิกที่หน้าเว็บ แล้วรอจนขึ้น "ชำระเงินสำเร็จ"
    Scroll To PromptPay
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Run Keyword And Ignore Error    Click Element    xpath://button[normalize-space()='ยอมรับ']
    ${ok}=    Execute Javascript
    ...    var b=[...document.querySelectorAll('button')].filter(x=>['ถัดไป','Next'].includes(x.innerText.trim()) && x.offsetParent!==null);
    ...    if(!b.length) return false; b[0].scrollIntoView({block:'center'}); b[0].click(); return true;
    Should Be True    ${ok}    ไม่เจอปุ่มถัดไป
    # QR บางครั้งขึ้นช้า รอได้นานกว่า Capture2 (20s)
    Wait Until Element Is Visible    xpath=//*[@class='qr-code-img qr-img']    timeout=45s
    Capture QR Code Screenshot
    ${sim}=    Set Variable    xpath://a[contains(normalize-space(),'จำลองว่าชำระเงินแล้ว')]
    Wait Until Page Contains Element    ${sim}    timeout=20s
    Scroll Element Into View    ${sim}
    Click Element    ${sim}
    # จำแท็บหน้า QR ไว้ เพราะ Chrome อาจมีแท็บอื่นเปิดค้าง (MAIN อาจไม่ใช่แท็บนี้)
    ${qr_tab}=    Switch Window    NEW    timeout=15s
    Wait Until Element Is Visible    xpath://button[normalize-space()='Simulate Payment']    timeout=20s
    Click Element    xpath://button[normalize-space()='Simulate Payment']
    Wait Until Page Contains    Response    timeout=20s
    ${body}=    Get Text    tag:body
    Should Not Contain    ${body}    ERROR    msg=หน้า Xendit Simulate ตอบ error: ${body}
    Close Window
    Switch Window    ${qr_tab}    timeout=10s
    # กลับมาหน้า QR แล้วคลิกที่หน้าเว็บ รอสักพักจะขึ้นชำระเงินสำเร็จ
    Wait Until Keyword Succeeds    24x    5s    Click Page And Check Paid
    Hammer Check Paid In History

Hammer Credit Card Pay
    [Documentation]    HB031 จ่ายบัตรเครดิต Xendit: จำลองสถานการณ์ -> 3DS Challenge (กรอกเลขบัตร mock ให้)
    ...                -> กรอกชื่อ นามสกุล อีเมล เบอร์ -> ชำระเงิน -> กรอก OTP 1234 -> SUBMIT -> ชำระเงินสำเร็จ
    Run Keyword And Ignore Error    Click Element    xpath://button[normalize-space()='ยอมรับ']
    Wait Until Page Contains Element    id=credit-radio    timeout=30s
    ${radio}=    Get WebElement    id=credit-radio
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${radio}
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    ${ok}=    Execute Javascript
    ...    var b=[...document.querySelectorAll('button')].filter(x=>['ถัดไป','Next'].includes(x.innerText.trim()) && x.offsetParent!==null);
    ...    if(!b.length) return false; b[0].scrollIntoView({block:'center'}); b[0].click(); return true;
    Should Be True    ${ok}    ไม่เจอปุ่มถัดไป
    # เมนูจำลองสถานการณ์ของ Xendit
    ${sim}=    Set Variable    xpath://button[normalize-space()='จำลองสถานการณ์']
    Wait Until Element Is Visible    ${sim}    timeout=45s
    Click Element    ${sim}
    ${challenge}=    Set Variable    xpath:(//span[normalize-space()='3DS Challenge'])[1]
    Wait Until Element Is Visible    ${challenge}    timeout=10s
    Click Element    ${challenge}
    Sleep    2s
    Input Text    name=card_details.cardholder_first_name    ${name}
    Input Text    name=card_details.cardholder_last_name    ${lastname}
    Input Text    name=card_details.cardholder_email    ${email2}
    Input Text    xpath://input[@type='tel']    812345678
    ${pay}=    Set Variable    xpath://button[normalize-space()='ชำระเงิน']
    Wait Until Element Is Enabled    ${pay}    timeout=10s
    Click Element    ${pay}
    # หน้า OTP อยู่ใน iframe ซ้อน 3 ชั้น (redirect.xendit.co -> frame -> frame)
    Wait Until Page Contains Element    xpath://iframe[contains(@src,'redirect.xendit.co')]    timeout=45s
    # iframe ข้างในโหลดใหม่ได้ระหว่างรอ จึงเข้า frame ใหม่ทุกรอบจนเจอช่อง OTP
    Wait Until Keyword Succeeds    20x    3s    Enter Xendit OTP Frame
    Input Text    name=challengeDataEntry    1234
    Click Element    xpath://input[@value='SUBMIT']
    Unselect Frame
    Wait Until Keyword Succeeds    24x    5s    Page Should Contain Element
    ...    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']
    Hammer Check Paid In History

Enter Xendit OTP Frame
    Unselect Frame
    Select Frame    xpath://iframe[contains(@src,'redirect.xendit.co')]
    Select Frame    xpath:(//iframe)[1]
    Select Frame    xpath:(//iframe)[1]
    Element Should Be Visible    name=challengeDataEntry

Hammer Check Paid In History
    [Documentation]    เปิดแท็บ "สำเร็จ" ในหน้าประวัติ แล้วเช็คว่ามีชื่องาน ที่นั่ง และยอดรวมของรอบนี้
    ...                (ใช้แทน Check Payment Success เพราะแท็บ [2] ในจอกว้างบางทีไม่ใช่แท็บสำเร็จ)
    ${log}=    Get File    price_log.txt
    @{lines}=    Split To Lines    ${log}
    ${seat}=    Set Variable    ${lines}[1]
    ${total}=    Set Variable    ${lines}[4]
    Go To    https://eventpass-ticket-uat.eventpass.biz/history
    Wait Until Keyword Succeeds    10x    2s    Open Completed Tab
    Wait Until Keyword Succeeds    10x    2s    Completed Order Should Show    ${seat}    ${total}
    Log To Console    ✅ เจอคำสั่งซื้อที่นั่ง ${seat} ยอด ${total} ในแท็บสำเร็จ

Open Completed Tab
    ${ok}=    Execute Javascript
    ...    var t=[...document.querySelectorAll('div')].filter(x=>['สำเร็จ','Completed'].includes(x.innerText.trim()) && x.children.length==0 && x.offsetParent!==null);
    ...    if(!t.length) return false; t[0].click(); return true;
    Should Be True    ${ok}    ไม่เจอแท็บสำเร็จ

Completed Order Should Show
    [Arguments]    ${seat}    ${total}
    ${blocks}=    Execute Javascript    return document.body.innerText.split('วันที่สั่งซื้อ').filter(b=>b.includes('Hammer Band')).slice(0,3)
    ${hit}=    Set Variable    ${False}
    FOR    ${b}    IN    @{blocks}
        IF    $seat in $b and $total in $b and 'สำเร็จเมื่อ' in $b
            ${hit}=    Set Variable    ${True}
        END
    END
    Should Be True    ${hit}    ไม่เจอคำสั่งซื้อที่นั่ง ${seat} ยอด ${total} ในแท็บสำเร็จ

Click Page And Check Paid
    Click Element    xpath=//body
    Page Should Contain Element    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']

Hammer Upload QR Image
    Sleep    1s
    Click Element    xpath=//body
    Sleep    0.5s
    Execute Javascript    window.open('http://qrtool.globalprimepay.com/qr')
    Switch Window    NEW
    click escape key to close modal
    Choose File    xpath=//input[@id='file']    ${IMAGE_PATH}
    Wait until element is ready then click element    xpath=//button[@type='submit']
    Alert Should Be Present    timeout=20s
    Wait Until Element Is Visible    xpath://label[normalize-space()='Amount']
    click escape key to close modal
    Wait until element is ready then click element    xpath://button[normalize-space()='confirm']
    ${second}    ${msg}=    Run Keyword And Ignore Error    Alert Should Be Present    timeout=10s
    Log    popup ที่สอง: ${second}
    Sleep    1s
    Close Window
    Switch Window    MAIN    timeout=10s

Buy Hammer Band Ticket
    [Arguments]    ${PORT}    ${area_index}    ${Payment}
    Attach To Specific Chrome    ${PORT}
    Go To    ${HAMMER_TICKET}
    Sleep    2s
    Select Hammer Zone Seat    ${area_index}
    getname(normal)
    Run Keyword If    '${Payment}' == 'Credit card2'    Process Credit card pay2
    Run Keyword If    '${Payment}' == 'QR2'    Hammer QR Pay
    Run Keyword If    '${Payment}' == 'Xendit QR'    Hammer Xendit QR Pay
    Run Keyword If    '${Payment}' == 'Xendit Card'    Hammer Credit Card Pay
    CheckTicket fullscreen

*** Test Cases ***
#                                                    ${PORT}    ${area}    ${Payment}
HB030 Buy Hammer Band VIP1 Seat Xendit QR           9222       0          Xendit QR
HB031 Buy Hammer Band VIP1 Seat Credit Card         9222       0          Xendit Card
