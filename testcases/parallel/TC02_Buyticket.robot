*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Resource          ../../keywords/ticket/buyticketkeywords.robot

Suite Setup       Register Keyword To Run On Failure    Nothing
Test Teardown     Teardown Screenshot On Fail And Close Browser
Test Template     Scenario Search And Buy Ticket

*** Variables ***
${URL}                  https://eventpass-ticket-uat.eventpass.biz
${BROWSER}              headlesschrome
${DEBUGGER}             127.0.0.1:9222
${TIMEOUT}              20s
${BASIC_TICKET}            https://eventpass-ticket-uat.eventpass.biz/event-detail/new
${BOOKNOW_TICKET}          https://eventpass-ticket-uat.eventpass.biz/event-detail/booknown
${Choose a round_TICKET}   https://eventpass-ticket-uat.eventpass.biz/event-detail/ChoosearoundN
${Get_Link_TICKET}         https://eventpass-ticket-uat.eventpass.biz/event-detail/Getlink
${bUFFET_TICKET}           https://eventpass-ticket-uat.eventpass.biz/event-detail/BuffetN
${ZoneSeat_TICKET}         https://eventpass-ticket-uat.eventpass.biz/event-detail/ZoneSeat1
${ZoneTable_TICKET}        https://eventpass-ticket-uat.eventpass.biz/event-detail/ZTN
${Flow_travel}             https://eventpass-ticket-uat.eventpass.biz/event-detail/dream-world

*** Keywords ***

Attach To Specific Chrome
    [Arguments]    ${PORT}
    Remove Files    ${OUTPUT DIR}${/}selenium-screenshot-*.png
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_experimental_option    debuggerAddress    127.0.0.1:${PORT}
    Open Browser    about:blank    chrome    options=${options}


Go To Event Detail Page
    [Arguments]    ${Ticket_URL}
    Go To    ${Ticket_URL}
    Sleep    1s
    Switch To Latest Window

Switch To Latest Window
    ${handles}=    Get Window Handles
    ${count}=      Get Length    ${handles}
    IF    ${count} > 1
        Switch Window    ${handles}[-1]
    END

Scenario Search And Buy Ticket
    [Arguments]     ${PORT}    ${Ticket_URL}    ${ticket_type}    ${Payment}    ${TicketCheck} 
    # เปิดโหมดรอให้จ่ายเงินครบ 4 เคสก่อน (ต้องเรียกก่อนสเต็ปอื่น เพื่อให้เคสที่ fail ตอนเปิด browser ก็ถูกนับด้วย)
    Set Barrier Mode    ${ticket_type}
    Attach To Specific Chrome    ${PORT}
    Go To Event Detail Page    ${Ticket_URL}
    Buy Ticket Flow Data Driven    ${ticket_type}     ${Payment}    ${TicketCheck}    
    
  

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

Teardown Screenshot On Fail And Close Browser
    [Documentation]    ถ่าย screenshot เฉพาะเทสเคสที่ fail จริง (ไม่ถ่ายตอน keyword fail ระหว่าง retry) แล้วปิด browser เสมอ
    # ถ้าเคสนี้ fail ก่อนถึงจุดรอ ให้นับเข้า barrier เพื่อไม่ให้เคสอื่นรอค้างจน timeout
    Run Keyword And Ignore Error    Count Failed Test In Barrier
    IF    '${TEST STATUS}' == 'FAIL'
        # ถ้าถ่ายไม่สำเร็จ (เช่น browser ปิดไปแล้ว) แค่เตือน ไม่ให้กระทบ status/ข้อความ error ของเทสเคส
        ${status}    ${msg}=    Run Keyword And Ignore Error    Capture Screenshot With Test Name
        IF    '${status}' == 'FAIL'
            Log    ถ่าย screenshot ไม่สำเร็จ: ${msg}    WARN
        END
    END
    Close Browser 

*** Test Cases ***

####     python -m pabot.pabot --processes 4 --testlevelsplit --command python -m robot --end-command TC02_Buyticket.robot

######################                           ${Port ที่ใช้}         ${URL ของบัตร}                    ${เลือกบัตร}                                ${Payment} 

1. Buy Basic Ticket Flow                             9225           ${BASIC_TICKET}                     Basic1                        Credit card            normal fullscreen
# 1.1 Buy Basic Ticket Flow QR                         9223            ${BASIC_TICKET}                     Basic2                        QR                      normal fullscreen
# 1.2 Buy Basic Ticket Flow Shopee Pay                 9224            ${BASIC_TICKET}                     Basic2                        Shopee Pay            normal fullscreen
# 1.3 Buy Basic Ticket Flow installment                9225            ${BASIC_TICKET}                     Basic2                        installment           normal fullscreen
                                                                                                                                          
    
    
# 2. Buy Booknow Ticket Flow                           9222            ${BOOKNOW_TICKET}                   Booknow1                      Credit card            normal fullscreen
# 2.1 Buy Booknow Ticket Flow QR                       9223            ${BOOKNOW_TICKET}                   Booknow                      QR                     normal fullscreen
# 2.2 Buy Booknow Ticket Flow Shopee Pay               9224            ${BOOKNOW_TICKET}                   Booknow2                      Shopee Pay            normal fullscreen
# 2.3 Buy Booknow Ticket Flow installment              9225            ${BOOKNOW_TICKET}                   Booknow2                      installment           normal fullscreen


# 3. Buy Buffet Ticket Flow                            9222            ${bUFFET_TICKET}                    Buffet1                       Credit card              normal fullscreen      
# 3.1 Buy Buffet Ticket Flow QR                        9223            ${bUFFET_TICKET}                    Buffet                       QR                       normal fullscreen
# 3.2 Buy Buffet Ticket Flow Shopee Pay                9224            ${bUFFET_TICKET}                    Buffet                       Shopee Pay               normal fullscreen     
# 3.3 Buy Buffet Ticket Flow installment               9225            ${bUFFET_TICKET}                    Buffet                       installment              normal fullscreen   



# 4. Buy Choose a round Ticket Flow                    9222            ${Choose a round_TICKET}             Choose a round1              Credit card            normal fullscreen
# 4.1 Buy Choose a round Ticket Flow QR                9223            ${Choose a round_TICKET}             Choose a round              QR                     normal fullscreen
# 4.2 Buy Choose a round Ticket Flow Shopee Pay        9224            ${Choose a round_TICKET}             Choose a round              Shopee Pay             normal fullscreen
# 4.3 Buy Choose a round Ticket Flow installment       9225            ${Choose a round_TICKET}             Choose a round2              installment            normal fullscreen



# 5. Buy Get Link Ticket Flow                          9222            ${Get_Link_TICKET}                      Get Link1                    Credit card         normal fullscreen
# 5.1 Buy Get Link Ticket Flow QR                      9223            ${Get_Link_TICKET}                      Get Link                    QR                  normal fullscreen
# 5.2 Buy Get Link Ticket Flow Shopee Pay              9224            ${Get_Link_TICKET}                      Get Link2                    Shopee Pay         normal fullscreen
# 5.3 Buy Get Link Ticket Flow installment             9225            ${Get_Link_TICKET}                      Get Link2                   installment         normal fullscreen



#############         python -m robot TC02_Buyticket.robot     #############  ใช้ จอ 9225

# 6. Buy Zone Seat Ticket                              9225            ${ZoneSeat_TICKET}                      Zone seat                   Credit card2                 normal fullscreen 
# 6.1 Buy Zone Seat Ticket Flow QR                     9225            ${ZoneSeat_TICKET}                      Zone seat                   QR2                          normal fullscreen
# 6.2 Buy Zone Seat Ticket Flow Shopee Pay             9225            ${ZoneSeat_TICKET}                      Zone seat                   Shopee Pay2                  normal fullscreen
# 6.3 Buy Zone Seat Ticket Flow installment            9225            ${ZoneSeat_TICKET}                      Zone seat                   installment2                 normal fullscreen

# 7. Buy Zone table Ticket                             9225            ${ZoneTable_TICKET}                     Zone table                  Credit card2                  normal fullscreen
# 7.1 Buy Zone table Ticket Flow QR                    9225            ${ZoneTable_TICKET}                     Zone table                   QR2                          normal fullscreen
# 7.2 Buy Zone table Ticket Flow Shopee Pay            9225            ${ZoneTable_TICKET}                     Zone table                   Shopee Pay2                  normal fullscreen
# 7.3 Buy Zone table Ticket Flow installment           9225            ${ZoneTable_TICKET}                     Zone table                  installment2                  normal fullscreen




########    flow travel    ########

# flow travel check Email ลูกค้าและ partner
# form type-single จะดักข้อมูลให้กรอกข้อมูลให้ครบทั้ง ชื่อ อีเมล เบอร์ 
# แต่ถ้า type-multiple จะต้องกรอกข้อมูลทั้งหมดใหม่

# Startflow >>  go to detail >> ใส่เบอร์ >> กดซื้อบัตรด้วยเงื่อนไขต่างๆ >> รอสถานะขึ้นว่าจ่ายสำเร็จ >> ไปเปิด Emailดูเช็คว่าได้บัตรไหม >> เปิดดูหน้า dashboard ว่าข้อมูลลูกค้าที่ซื้อตรงกันมั้ย >> จบflow

# # รันที่ละ 2 Browser / tab 9223 login cms admin ไว้

# 10. Buy flow travel ticket                            9222            ${Flow_travel}                    flowtravel1                  Credit card           flowtravel
# 10.1 Buy flow travel ticket                           9223            ${Flow_travel}                    flowtravel                   QR                    flowtravel
# 10.2 Buy Zone table Ticket Flow Shopee Pay            9222            ${Flow_travel}                    flowtravel                   Shopee Pay            flowtravel
# 10.3 Buy Zone table Ticket Flow installment           9223            ${Flow_travel}                    flowtravel4                  installment           flowtravel4

#  python -m pabot.pabot --processes 2 --testlevelsplit --command python -m robot --end-command TC02_Buyticket.robot








#1. เปิดChrome ใน cmd

# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\RobotChromeprofile_0"


# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9223 --user-data-dir="C:\RobotChromeprofile_1"


# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9224 --user-data-dir="C:\RobotChromeprofile_2"


# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9225 --user-data-dir="C:\RobotChromeprofile_3"



#2. รันโค้ด

# cd testcases/parallel
# python -m pabot.pabot --processes 4 --testlevelsplit --command python -m robot --end-command TC02_Buyticket.robot



















































