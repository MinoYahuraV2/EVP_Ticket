*** Settings ***
# Library         SeleniumLibrary
Resource        ../common/commonkeywords.robot

*** Keywords ***


Click EN Language
    # commonkeywords.Wait until element is ready then click element with java script    xpath=//span[text()='TH' or text()='EN']
    commonkeywords.Wait until element is ready then click element with java script    class:lang-switch
    commonkeywords.Wait until element is ready then click element with java script    xpath=//span[text()='English']

user click login button on navbar
    commonkeywords.Wait until element is ready then click element     xpath=//span[text()='เข้าสู่ระบบ' or text()='Login']
    commonkeywords.Wait until element is ready then click element     xpath=//span[text()='ดำเนินการต่อด้วย Google' or text()='Continue with Google']

    
Select Birth Date
    commonkeywords.Wait until element is ready then click element    xpath=//span[text()='DD/MM/YYYY']
    commonkeywords.Wait until element is ready then click element    class:react-calendar__navigation__label__labelText
    commonkeywords.Wait until element is ready then click element    xpath=(//*[contains(@class,'react-calendar__tile')])[1]
    commonkeywords.Wait until element is ready then click element    xpath=(//*[contains(@class,'react-calendar__tile')])[1]


check profile ${input_name} ${input_lastname}
    Sleep    5s
    Go To    https://eventpass-ticket-uat.eventpass.biz/profile
    Wait until page contains element then verify text    ${input_name}
    Wait until page contains element then verify text    ${input_lastname}
    Wait Until Page Contains Element     xpath://span[normalize-space()='No Specific' or normalize-space()='ไม่ระบุ']
    Wait Until Page Contains Element     xpath://span[normalize-space()='Phone Number' or normalize-space()='เบอร์โทรศัพท์']
    Wait Until Page Contains Element     xpath=//span[text()='อัฟกานิสถาน' or text()='AFGHAN']

confirm policy
    commonkeywords.Wait until element is ready then click element    id=verify_status3   



CheckContactUs
    Go To    https://eventpass-ticket-uat.eventpass.biz/

    # Wait until element is ready then click element    class:img-logo
    Wait until element is ready then click element    xpath=//button[@data-testid='main-button']
    Sleep    1s
    Wait until element is ready then click element    xpath=//a[text()='ติดตามเพจ Facebook' or text()='Follow Facebook Page']
    Sleep    2s

#verify new tab URL is FACEBOOK PAGE
    switch window    NEW
    sleep    1s
    ${current_url}=    Get Location
    Should Be True    '${current_url}' in ['https://www.facebook.com/eventpassticket', 'facebook.com/eventpassticket', 'chrome://signin-dice-web-intercept.top-chrome/chrome-signin']

#click Line Button
    Switch Window    MAIN
    Sleep    2s
    Wait until element is ready then click element    xpath=//button[@data-testid='main-button']
    Wait until element is ready then click element    xpath=//a[text()='บัตรและการสนับสนุน' or text()='Tickets & Support']
    Sleep    2s

# verify new tab URL is LINE
    switch window    NEW
    ${current_url}=    Get Location
    Should Contain    ${current_url}    https://page.line.me
    Switch Window    MAIN
    


# =================================================================
# 🌟 Master Keyword (รองรับทั้ง TH และ EN)
# =================================================================
User Register Flow Data Driven
    [Arguments]    ${language}    ${input_name}    ${input_lastname}    ${fill_birthdate}    ${accept_privacy}    ${success}    ${CheckContact}
    
    # 1. ถ้าเป็น EN ให้เปลี่ยนภาษาในฟอร์มก่อนกรอกข้อมูล
    Run Keyword If    '${language}'.strip().upper() == 'EN'    Click EN Language
    
    # 2. รีเฟรชและรอให้เว็บโหลดเสร็จสมบูรณ์
    commonkeywords.refresh page
    Sleep    2s

    # 3. รอช่องกรอกชื่อ
    commonkeywords.waiting for elements    name=name    15s
    
    # 4. กรอกข้อมูล (ใช้เงื่อนไข != '${EMPTY}' ปลอดภัยที่สุดใน Robot)
    Run Keyword If    '${input_name}' != '${EMPTY}'        commonkeywords.Wait until element is ready then input text     name=name    ${input_name}
    Run Keyword If    '${input_lastname}' != '${EMPTY}'    commonkeywords.Wait until element is ready then input text     name=last_name    ${input_lastname}
    
    # 5. เลือกประเทศ
    commonkeywords.Wait until element is ready then click element    css=.search-select__control
    commonkeywords.Wait until element is ready then click element    xpath=//div[text()='อัฟกานิสถาน' or text()='AFGHAN']
    
    # 6. ยอมรับเงื่อนไข
    IF    '${accept_privacy}' == 'YES'
        confirm policy
    END


    # 7. เลือกวันเกิด 
    Run Keyword If    '${fill_birthdate}' == 'YES'    Select Birth Date
    
    # 8. กดส่ง
    commonkeywords.Wait until element is ready then click element    xpath=//button[text()='ส่ง' or text()='Submit']
    
    # 9. ตรวจสอบผลลัพธ์
    # Run Keyword If    '${success}' == 'ค้นหา' or '${success}' == 'Search'    commonkeywords.waiting for elements    xpath=//button[text()='ค้นหา' or text()='Search']
    Run Keyword If    '${success}' != '${EMPTY}'   Page Should Contain     ${success}       

    Run Keyword If    '${success}' == 'Search'   check profile ${input_name} ${input_lastname}




    Run Keyword If    '${CheckContact}' != '${EMPTY}'   CheckContactUs


    
    
