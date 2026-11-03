* Settings *
Library        DateTime
Library        SeleniumLibrary    
Library        String
Library        Collections
Library        OperatingSystem

* Keywords *
waiting for elements 
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Wait Until Keyword Succeeds    25x    1s    Element Should Be Enabled    ${locator}

Wait until element is ready then click element
    [Arguments]    ${locator}
    Wait Until Keyword Succeeds    30x    1s    Click Element    ${locator}

Wait until element is ready then click element with javascript
    [Arguments]    ${locator}
    # สั่งให้รอจนกว่า Element จะปรากฏบนหน้าจอหลัก (DOM) ก่อน
    Wait Until Page Contains Element    ${locator}    timeout=10s
    # ดึงค่า WebElement ออกมาเพื่อให้ JavaScript รู้จักวัตถุชิ้นนี้
    ${element}=    Get WebElement    ${locator}
    # ใช้ JavaScript คลิกทะลุทุกการบดบัง
    Wait Until Keyword Succeeds    10x    1s    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Wait until element is ready then input text
    [Arguments]    ${locator}    ${text}
    Wait Until Keyword Succeeds    10x    1s    Input Text    ${locator}    ${text}

Clear Element Text
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    # Focus element ก่อน
    Execute Javascript    arguments[0].focus();    ARGUMENTS    ${element}
    # Select all content
    Execute Javascript    arguments[0].select();    ARGUMENTS    ${element}
    # ลบข้อความด้วย JavaScript
    Execute Javascript    arguments[0].value = '';    ARGUMENTS    ${element}
    # ส่ง events เพื่อให้ form รู้ว่ามีการเปลี่ยนแปลง
    Execute Javascript    arguments[0].dispatchEvent(new Event('input', { bubbles: true }));    ARGUMENTS    ${element}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change', { bubbles: true }));    ARGUMENTS    ${element}
    Execute Javascript    arguments[0].dispatchEvent(new Event('blur', { bubbles: true }));    ARGUMENTS    ${element}
    Sleep    0.3s



Wait until page contains element then verify text
    [Arguments]    ${expected_text}
    Wait Until Keyword Succeeds    15x    1s    Page Should Contain    ${expected_text}


Verify Total Price Number
    [Documentation]    รอให้ราคารวมแสดงตรงกับค่าที่คาดหวัง โดยเช็คซ้ำจนกว่าจะตรงหรือหมดเวลา
    [Arguments]    ${locator}    ${expected_price}    ${timeout}=20s    ${interval}=2s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Wait Until Keyword Succeeds    ${timeout}    ${interval}
    ...    Check Total Price Once    ${locator}    ${expected_price}

Check Total Price Once
    [Arguments]    ${locator}    ${expected_price}
    ${actual_text}=    Get Text    ${locator}
    ${actual_number}=    Get Regexp Matches    ${actual_text}    [\\d,]+\\.?\\d*
    ${actual_clean}=    Remove String    ${actual_number}[0]    ,
    ${expected_clean}=    Remove String    ${expected_price}    ,
    Should Be Equal As Numbers    ${actual_clean}    ${expected_clean}
    ...    msg=ราคาที่แสดง: ${actual_clean} ไม่เท่ากับ ราคาที่ควรแสดง: ${expected_clean}



get seat
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    ${seat}=    Get Text    ${locator}
    Log To Console    ${seat}
    Append To File    price_log.txt    ${seat}\n



get ticket name 
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    ${text}=    Get Text    ${locator}
    ${parts}=    Split String    ${text}    x
    ${ticket_name}=    Strip String    ${parts}[0]

    Log To Console    TICKET=[${ticket_name}]
    Append To File    price_log.txt    ${ticket_name}\n




get price
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    ${full_text}=    Get Text    ${locator}
    
    # 1. ดึงเฉพาะตัวเลขและจุดทศนิยมออกมา
    ${actual_number}=    Get Regexp Matches    ${full_text}    [\\d,]+\\.?\\d*
    
    # 2. ลบลูกน้ำ (,) ออก (โค้ดเดิมของคุณขาดตัว , ด้านหลัง ผมเติมให้สมบูรณ์ครับ)
    ${actual_clean}=    Remove String    ${actual_number}[0]    ,\n
    

    ${current_datetime}=    Get Current Date
    ${current_time}=        Convert Date    ${current_datetime}    result_format=%H:%M
    ${plus_1_min}=          Add Time To Date
    ...    ${current_datetime}
    ...    1 minute
    ...    result_format=%H:%M

    ${file_exists}=    Run Keyword And Return Status
    ...    File Should Exist
    ...    price_log.txt

    IF    ${file_exists}
        ${file_content}=    Get File    price_log.txt

        ${exists}=    Run Keyword And Return Status
        ...    Should Contain
        ...    ${file_content}
        ...    ${actual_clean}
    ELSE
        ${exists}=    Set Variable    False
    END

    IF    not ${exists}
        Append To File
        ...    price_log.txt
        ...    ${actual_clean}\n${current_time}\n${plus_1_min}\n

        Log To Console    ✅ บันทึกราคาใหม่ ${actual_clean}
    ELSE
        Log To Console    ⚠️ ราคาซ้ำ ไม่บันทึก ${actual_clean}
    END


get price withtime
    [Arguments]    ${locator}    ${timeout}=10s

    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    ${full_text}=    Get Text    ${locator}

    ${current_datetime}=    Get Current Date
    ${plus_1_min}=    Add Time To Date
    ...    ${current_datetime}
    ...    1 minute
    ...    result_format=%H:%M

    ${current_time}=    Get Current Date    result_format=%H:%M

    ${file_exists}=    Run Keyword And Return Status
    ...    File Should Exist
    ...    Ticket_name_log.txt

    IF    ${file_exists}
        ${file_content}=    Get File    Ticket_name_log.txt
        @{saved_tickets}=    Split To Lines    ${file_content}

        ${exists}=    Run Keyword And Return Status
        ...    List Should Contain Value
        ...    ${saved_tickets}
        ...    ${full_text}
    ELSE
        ${exists}=    Set Variable    False
    END

    IF    not ${exists}
        Append To File
        ...    Ticket_name_log.txt
        ...    ${full_text}\n${current_time}\n${plus_1_min}\n

        Log To Console    ✅ บันทึกข้อมูลใหม่: ${full_text}
    ELSE
        Log To Console    ⚠️ ข้อมูลซ้ำ ไม่บันทึก: ${full_text}
    END

get name
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    ${full_text}=    Get Text    ${locator}
    
    Log To Console    ${full_text}
    
   # เอาตัวแปรมาต่อกันตรงๆ โดยไม่มีช่องว่างคั่นกลาง
    Append To File    Ticket_name_log.txt    ${full_text}\n

get name price
    [Arguments]    ${locator}    ${timeout}=10s

    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    ${full_text}=    Get Text    ${locator}

    Log To Console    ${full_text}

    # อ่านข้อมูลเดิมในไฟล์
    ${file_exists}=    Run Keyword And Return Status
    ...    File Should Exist    price_log.txt

    IF    ${file_exists}
        ${file_content}=    Get File    price_log.txt

        # เช็คว่ามีข้อมูลนี้อยู่ในไฟล์แล้วหรือไม่
        ${already_exists}=    Run Keyword And Return Status
        ...    Should Contain    \n${file_content}\n    \n${full_text}\n

        IF    ${already_exists}
            Log To Console    ⚠️ มีข้อมูล ${full_text} อยู่แล้ว → ไม่บันทึกซ้ำ
            RETURN
        END
    END

    # ถ้ายังไม่มี ให้บันทึก
    Append To File    price_log.txt    ${full_text}\n
    Log To Console    ✅ บันทึก ${full_text} ลงไฟล์แล้ว


    

click escape key to close modal
    SeleniumLibrary.Press Keys    NONE    ESCAPE
    Sleep    2.5s

click enter key to submit form
    SeleniumLibrary.Press Keys    NONE    ENTER
    Sleep    0.5s

refresh page
    Reload Page
    Sleep    0.5s


Scroll To The Very Bottom
    # สั่งเลื่อนลงไปล่างสุดของหน้าเว็บทันที
    SeleniumLibrary.Execute Javascript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    1s

Scroll To The Very Top
    SeleniumLibrary.Execute Javascript    window.scrollTo(0, 0)
    Sleep    1s

Type Text Slowly
    [Arguments]    ${locator}    ${text}    ${delay}=0s
    
    # 1. เคลียร์ข้อมูลเดิมในช่องออกก่อน
    Clear Element Text    ${locator}
    
    # 2. แปลงข้อความให้เป็น List ของตัวอักษรแต่ละตัว
    @{chars}=    Evaluate    list($text)
    
    # 3. วนลูปพิมพ์ทีละตัวอักษร แล้วหยุดพักตามเวลาที่ตั้งไว้
    FOR    ${char}    IN    @{chars}
        SeleniumLibrary.Press Keys    ${locator}    ${char}
        Sleep    ${delay}
    END


Remove Duplicates Ignore Spaces
    [Arguments]    ${items}
    ${clean}=    Create List
    FOR    ${item}    IN    @{items}
        ${text}=    Convert To String    ${item}
        ${text}=    Replace String Using Regexp    ${text}    [\\u200b-\\u200d\\ufeff]    ${EMPTY}
        ${text}=    Replace String Using Regexp    ${text}    \\s+    ${SPACE}
        ${text}=    Strip String    ${text}
        Append To List    ${clean}    ${text}
    END
    ${unique}=    Remove Duplicates    ${clean}
    RETURN    ${unique}