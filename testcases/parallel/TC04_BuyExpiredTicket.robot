


*** Settings ***
Library           SeleniumLibrary   
Library           OperatingSystem
Resource          ../../keywords/ticket/buyticketkeywords.robot

Suite Setup       Register Keyword To Run On Failure    Nothing
Test Teardown     Close Browser 
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
${Zone seat_Ticket}         https://eventpass-ticket-uat.eventpass.biz/event-detail/ZoneSeat1
${Zone seat_K-bank}         https://eventpass-ticket-uat.eventpass.biz/event-detail/ZoneSeat1_copy_1786616084077
${ZoneTable_TICKET}        https://eventpass-ticket-uat.eventpass.biz/event-detail/ZTN



*** Keywords ***
# 2. แก้ Keyword ให้รับค่า ${PORT} เข้ามาตรงๆ แทนการสุ่มด้วย Pool ID
Attach To Specific Chrome
    [Arguments]    ${PORT}
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

# 3. เพิ่ม ${PORT} เข้ามาเป็น Argument ตัวแรกใน Template
Scenario Search And Buy Ticket
    [Arguments]    ${PORT}    ${Ticket_URL}    ${ticket_type}    ${Payment}    ${TicketCheck}

    # สั่งเชื่อมต่อ Browser ตาม Port ที่ส่งมาก่อน
    Remove File    price_log.txt
    Attach To Specific Chrome    ${PORT}
    Go To Event Detail Page    ${Ticket_URL}
    Buy Ticket Flow Data Driven    ${ticket_type}     ${Payment}    ${TicketCheck} 
    

*** Test Cases ***

#                                         ${PORT}    ${Ticket_URL}                ${ticket_type}       ${Payment} 

# ############             expired GB Pay : เทสกรณี จ่าย QR xendit หลังจาก 10 นาทีแบบที่นั่งยังไม่เกิน Limit

1. Buy Basic Ticket Flow                  9222       ${BASIC_TICKET}              Basic                GB Pay Expired            normal fullscreen 
     
2. Buy Booknow Ticket Flow                9223       ${BOOKNOW_TICKET}            Booknow              GB Pay Expired            normal fullscreen 

3. Buy Buffet Ticket Flow                 9224       ${bUFFET_TICKET}             Buffet               GB Pay Expired            normal fullscreen         

4. Buy Choose a round Ticket Flow         9225       ${Choose a round_TICKET}     Choose a round       GB Pay Expired            normal fullscreen 





#############           cancel orders แต่จ่ายด้วย QR

# 7. cancel Basic Ticket Flow                  9222       ${BASIC_TICKET}              Basic                Cancel order            ${EMPTY} 
     
# 8. cancel Booknow Ticket Flow                9223       ${BOOKNOW_TICKET}            Booknow              Cancel order            ${EMPTY} 

# 9. cancel Buffet Ticket Flow                 9224       ${bUFFET_TICKET}             Buffet               Cancel order            ${EMPTY}         

# 10. cancel Choose a round Ticket Flow         9225       ${Choose a round_TICKET}     Choose a round       Cancel order            ${EMPTY} 


# 11. Buy Zone seat Ticket Flow             9225       ${Zone seat_Ticket}             Zone seat               Cancel order Zone        ${EMPTY}
# 12. Buy Zone table Ticket Flow            9225       ${ZoneTable_TICKET}             Zone table              Cancel order Zone        ${EMPTY}









#1. เปิดChrome ใน cmd

# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\RobotChromeprofile_0"


# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9223 --user-data-dir="C:\RobotChromeprofile_1"


# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9224 --user-data-dir="C:\RobotChromeprofile_2"


# & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9225 --user-data-dir="C:\RobotChromeprofile_3"


#2. รันโค้ด

# cd testcases/parallel

# python -m pabot.pabot --processes 2 --testlevelsplit TC04_BuyExpiredTicket.robot

# python -m pabot.pabot --command python -m robot --end-command --processes 4 --testlevelsplit TC04_BuyExpiredTicket.robot