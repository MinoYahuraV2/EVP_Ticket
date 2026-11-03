*** Settings ***
Documentation     ขั้นตอนที่ใช้ร่วมกันของเทสต์งาน Hammer Band 50th Hit The World (TC06 ซื้อบัตร, TC07 เลือกโซน/ที่นั่ง)
...               กฎสำคัญ: ที่นั่งจะถูกจองตั้งแต่กด "ชำระเงิน" ในหน้าเลือกที่นั่ง และยกเลิกได้ทางเดียว
...               คือกด "ยกเลิกคำสั่งซื้อ" ในหน้าเลือกช่องทางชำระเงินหรือหน้าจ่ายเงิน
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Library           Collections
Resource          buyticketkeywords.robot
Variables         ../../resources/testdata.yaml

*** Variables ***
${HAMMER_TICKET}    https://eventpass-ticket-uat.eventpass.biz/event-detail/UAT-Hammer-Band-50th-Hit-The-World
${SELECTED_IMG}     xpath://label[contains(@class,'neo-seat')]//img[contains(@src,'selected-seat')]
${PAY_BTN}          xpath://button[normalize-space()='ชำระเงิน' or normalize-space()='Check Out']
${SIZE_SELECT}      xpath://label[contains(normalize-space(),'ไซส์เสื้อ')]/following-sibling::select
${FORM_BUY_BTN}     xpath://div[contains(@class,'container-summary')]//button[contains(normalize-space(),'ซื้อบัตร') or contains(normalize-space(),'Buy Ticket')]

*** Keywords ***
Hammer Teardown
    [Documentation]    เคสพัง: ถ่ายรูป แล้วยกเลิกคำสั่งซื้อที่ค้าง (ถ้ามี) ก่อนปิด browser
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error    Capture Page Screenshot
        Run Keyword And Ignore Error    Unselect Frame
        ${st}    ${msg}=    Run Keyword And Ignore Error    Hammer Clean Up Order
        IF    '${st}' == 'FAIL'    Log    ล้างคำสั่งซื้อไม่สำเร็จ: ${msg}    WARN
    END
    Close All Browsers

Attach To Specific Chrome
    [Documentation]    เกาะ Chrome ที่เปิดด้วย --remote-debugging-port และ login ไว้แล้ว
    [Arguments]    ${PORT}    ${alias}=${None}
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_experimental_option    debuggerAddress    127.0.0.1:${PORT}
    Open Browser    about:blank    chrome    alias=${alias}    options=${options}
    # ปิดแท็บอื่นที่ค้างใน Chrome ทดสอบ ให้เหลือแท็บเดียว กันสลับผิดแท็บ
    @{handles}=    Get Window Handles
    ${keep}=    Set Variable    ${handles}[0]
    FOR    ${h}    IN    @{handles}[1:]
        Switch Window    ${h}
        Close Window
    END
    Switch Window    ${keep}
    Maximize Browser Window

Click Zone On Map
    [Documentation]    ผังโซนเป็นรูป + <area> เลือกตามลำดับ area: 0-2 VIP1-3, 3-6 A1-4, 7-12 B1-6, 13-14 RB1-2
    [Arguments]    ${area_index}
    Wait Until Element Is Visible    id=img-map    timeout=30s
    Wait Until Keyword Succeeds    10x    1s
    ...    Execute Javascript    document.querySelectorAll('map[name=zoneMapAreas] area')[${area_index}].click()
    Wait Until Location Contains    select-seat    timeout=20s
    Wait Until Page Contains Element    css:label.neo-seat    timeout=30s
    Sleep    2s

Click Visible Buy Button
    ${clicked}=    Execute Javascript
    ...    var names=['ซื้อบัตร','Buy Ticket','ไปที่บัตร','Go to Tickets'];
    ...    var b=[...document.querySelectorAll('button')].filter(x=>names.includes(x.innerText.trim()) && x.offsetParent!==null);
    ...    if(!b.length) return false; b[b.length-1].click(); return true;
    Should Be True    ${clicked}    ไม่เจอปุ่มซื้อบัตร
    Sleep    2s
    ${url}=    Get Location
    IF    'select-zone' not in $url
        Fail    ยังไม่ไปหน้าเลือกโซน
    END

Accept Cookie If Shown
    Run Keyword And Ignore Error    Click Element    xpath://button[normalize-space()='ยอมรับ'] | //div[normalize-space()='ยอมรับ']

Open Hammer Zone Page
    [Documentation]    เปิดหน้ารายละเอียดงาน แล้วกดซื้อบัตรไปหน้าเลือกโซน
    Go To    ${HAMMER_TICKET}
    Wait Until Keyword Succeeds    30x    1s    Click Visible Buy Button
    Wait Until Location Contains    select-zone    timeout=20s
    Wait Until Element Is Visible    id=img-map    timeout=30s
    Accept Cookie If Shown

Open Hammer Seat Page
    [Documentation]    ไปหน้าเลือกที่นั่งของโซน ถ้าเจอที่นั่งค้าง (สีเขียว) จะยกเลิกคำสั่งซื้อให้ก่อน
    [Arguments]    ${area_index}=0
    Open Hammer Zone Page
    Click Zone On Map    ${area_index}
    ${green}=    Get Element Count    ${SELECTED_IMG}
    IF    ${green} > 0
        Log To Console    🧹 เจอที่นั่งค้าง ${green} ที่ กำลังยกเลิก
        Hammer Clear Held Seats
        Open Hammer Zone Page
        Click Zone On Map    ${area_index}
        ${green}=    Get Element Count    ${SELECTED_IMG}
        Should Be Equal As Integers    ${green}    0    ล้างตะกร้าแล้วยังมีที่นั่งค้าง ${green} ที่ หยุดเทสต์ไว้ก่อน
    END

Click Pay On Seat Page
    [Documentation]    กด "ชำระเงิน" ในหน้าเลือกที่นั่ง (ขั้นนี้ระบบเริ่มจองที่นั่ง)
    Wait Until Element Is Enabled    ${PAY_BTN}    timeout=20s
    ${pay_el}=    Get WebElement    ${PAY_BTN}
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${pay_el}

Hammer Clear Held Seats
    [Documentation]    อยู่หน้าเลือกที่นั่งที่มีที่นั่งค้าง: กดชำระเงิน -> เลือกไซส์ -> หน้าเลือกช่องทางชำระเงิน -> ยกเลิกคำสั่งซื้อ
    Click Pay On Seat Page
    Wait Until Location Contains    form-information    timeout=20s
    Hammer Form To Payment Page
    Hammer Cancel Order On Payment Page

Hammer Cancel Order On Payment Page
    [Documentation]    ยกเลิกคำสั่งซื้อ (วิธีเดียวที่ปล่อยที่นั่งได้) ต้องอยู่หน้าเลือกช่องทางชำระเงินหรือหน้าจ่ายเงิน
    # หน้านี้มีปุ่มยกเลิกคำสั่งซื้อซ่อนอยู่ด้วย (layout มือถือ) จึงคลิกเฉพาะปุ่มที่มองเห็น แล้วรอ popup ยืนยัน
    Wait Until Keyword Succeeds    10x    3s    Open Cancel Order Popup
    Wait Until Keyword Succeeds    5x    1s    Click Visible Confirm Cancel
    Sleep    3s
    Log To Console    🧹 ยกเลิกคำสั่งซื้อแล้ว

Open Cancel Order Popup
    ${ok}=    Execute Javascript
    ...    var b=[...document.querySelectorAll('button')].filter(x=>['ยกเลิกคำสั่งซื้อ','Cancel Order'].includes(x.innerText.trim()) && x.offsetParent!==null);
    ...    if(!b.length) return false; b[0].scrollIntoView({block:'center'}); b[0].click(); return true;
    Should Be True    ${ok}    ไม่เจอปุ่มยกเลิกคำสั่งซื้อที่มองเห็น
    Wait Until Keyword Succeeds    5x    1s    Confirm Cancel Button Should Be Visible

Confirm Cancel Button Should Be Visible
    ${n}=    Execute Javascript
    ...    return [...document.querySelectorAll('button')].filter(x=>['ยกเลิก','Cancel'].includes(x.innerText.trim()) && x.offsetParent!==null).length;
    Should Be True    ${n} > 0    popup ยืนยันการยกเลิกยังไม่ขึ้น

Click Visible Confirm Cancel
    ${ok}=    Execute Javascript
    ...    var b=[...document.querySelectorAll('button')].filter(x=>['ยกเลิก','Cancel'].includes(x.innerText.trim()) && x.offsetParent!==null);
    ...    if(!b.length) return false; b[b.length-1].click(); return true;
    Should Be True    ${ok}    ไม่เจอปุ่มยืนยันยกเลิก

Select All Shirt Sizes
    [Documentation]    เลือกไซส์เสื้อให้ทุกฟอร์มในหน้ากรอกข้อมูล แล้วคืนจำนวนฟอร์ม
    [Arguments]    ${size}=ไซส์ M
    Wait Until Element Is Visible    ${SIZE_SELECT}    timeout=20s
    ${forms}=    Get Element Count    ${SIZE_SELECT}
    FOR    ${i}    IN RANGE    1    ${forms} + 1
        ${s}=    Get WebElement    xpath:(//label[contains(normalize-space(),'ไซส์เสื้อ')]/following-sibling::select)[${i}]
        Execute Javascript    arguments[0].scrollIntoView({block:'center'});    ARGUMENTS    ${s}
        Select From List By Value    ${s}    ${size}
    END
    RETURN    ${forms}

Hammer Form To Payment Page
    [Documentation]    อยู่หน้ากรอกข้อมูล: เลือกไซส์เสื้อให้ครบทุกใบ แล้วกดซื้อบัตรไปหน้าเลือกช่องทางชำระเงิน
    ${forms}=    Select All Shirt Sizes
    Wait Until Element Is Enabled    ${FORM_BUY_BTN}    timeout=20s
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    css:.swal2-container    timeout=10s
    ${next_el}=    Get WebElement    ${FORM_BUY_BTN}
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${next_el}
    Wait Until Location Contains    ticket-payment    timeout=30s
    RETURN    ${forms}

Hammer Clean Up Order
    [Documentation]    ถ้าค้างอยู่หน้ากรอกข้อมูลหรือหน้าจ่ายเงิน ให้ยกเลิกคำสั่งซื้อ กันที่นั่งค้าง
    ${url}=    Get Location
    IF    'form-information' in $url
        Hammer Form To Payment Page
        ${url}=    Get Location
    END
    IF    'ticket-payment' in $url
        # หน้านี้มีข้อความ "ชำระเงินสำเร็จ" ซ่อนอยู่ จึงเช็คเฉพาะที่มองเห็นจริง
        ${paid}=    Run Keyword And Return Status    Element Should Be Visible
        ...    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']
        IF    not ${paid}    Hammer Cancel Order On Payment Page
    END
