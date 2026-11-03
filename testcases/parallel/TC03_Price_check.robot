*** Settings ***
Library           SeleniumLibrary             
Library           OperatingSystem
Library           String
Resource          ../../keywords/ticket/Pricecheckkeywords.robot

Suite Setup       Register Keyword To Run On Failure    Nothing
Test Teardown     Teardown Screenshot On Fail And Close Browser
Test Template     Scenario Check Ticket Price

*** Variables ***
${URL}                      https://eventpass-ticket-uat.eventpass.biz
${BROWSER}                  headlesschrome
${DEBUGGER}                 127.0.0.1:9222
${TIMEOUT}                  20s    9222    
${BASIC_TICKET}            https://eventpass-ticket-uat.eventpass.biz/event-detail/new
${BOOKNOW_TICKET}          https://eventpass-ticket-uat.eventpass.biz/event-detail/booknown
${Choose a round_TICKET}   https://eventpass-ticket-uat.eventpass.biz/event-detail/ChoosearoundN
${bUFFET_TICKET}           https://eventpass-ticket-uat.eventpass.biz/event-detail/BuffetN
${ZoneSeat_TICKET}         https://eventpass-ticket-uat.eventpass.biz/event-detail/ZoneSeat1
${ZoneTable_TICKET}        https://eventpass-ticket-uat.eventpass.biz/event-detail/ZTN

*** Keywords ***

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

Scenario Check Ticket Price
    [Arguments]    ${PORT}    ${Ticket_URL}    ${ticket_type}    ${Ticket_Format}    ${Payment}    ${ticket_protect}    ${PROMOTION_CODE}    ${TOTAL_PRICE}
    Attach To Specific Chrome    ${PORT}
    Go To Event Detail Page    ${Ticket_URL}   
    Check Price Flow Data Driven    ${ticket_type}    ${Ticket_Format}    ${Payment}    ${ticket_protect}    ${PROMOTION_CODE}    ${TOTAL_PRICE}
    

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
    IF    '${TEST STATUS}' == 'FAIL'
        # ถ้าถ่ายไม่สำเร็จ (เช่น browser ปิดไปแล้ว) แค่เตือน ไม่ให้กระทบ status/ข้อความ error ของเทสเคส
        ${status}    ${msg}=    Run Keyword And Ignore Error    Capture Screenshot With Test Name
        IF    '${status}' == 'FAIL'
            Log    ถ่าย screenshot ไม่สำเร็จ: ${msg}    WARN
        END
    END
    Close Browser

*** Test Cases ***

#  python -m pabot.pabot --processes 4 --testlevelsplit --command python -m robot --end-command TC03_Price_check.robot
                                   ##########     port    ${Ticket_URL}      ${ticket_type}     ${Ticket_Format}        ${Payment}        ${ticket_protect}   ${PROMOTION_CODE}   ${TOTAL_PRICE}

##### Basic Ticket (บัตร 2000 บาท)#####
 
1.Basic(Digital,CreditCard)                       9222    ${BASIC_TICKET}            Basic            Digital Ticket         Creditcard            ${EMPTY}         ${EMPTY}            2,137.15
2.Basic(Pickup,CreditCard)                        9223    ${BASIC_TICKET}            Basic            Pick up at Event       Creditcard            ${EMPTY}         ${EMPTY}            2,190.57
3.Basic(Delivery,CreditCard)                      9224    ${BASIC_TICKET}            Basic2           Ticket delivery        Creditcard            ${EMPTY}         ${EMPTY}            2,201.26
4.Basic(Delivery,CreditCard,ProtectTicket)        9225    ${BASIC_TICKET}            Basic2           Ticket delivery        Creditcard            protect          ${EMPTY}            2,362.48

5.Basic(Digital,CreditCard,ProtectTicket)         9222    ${BASIC_TICKET}            Basic            Digital Ticket         Creditcard            protect         ${EMPTY}            2,298.37
6.Basic(Pickup,CreditCard,ProtectTicket)          9223    ${BASIC_TICKET}            Basic            Pick up at Event       Creditcard            protect         ${EMPTY}            2,351.79
7.Basic(Digital,QR)                               9224    ${BASIC_TICKET}            Basic2            Digital Ticket         QR                   ${EMPTY}        ${EMPTY}            2,093.06
8.Basic(Pickup,QR)                                9225    ${BASIC_TICKET}            Basic2            Pick up at Event       QR                   ${EMPTY}        ${EMPTY}            2,145.39

9.Basic(Delivery,QR)                            9222    ${BASIC_TICKET}            Basic            Ticket delivery         QR            ${EMPTY}         ${EMPTY}            2,155.86
10.Basic(Digital,QR,ProtectTicket)              9223    ${BASIC_TICKET}            Basic            Digital Ticket         QR            protect         ${EMPTY}            2,250.96
11.Basic(Pickup,QR,ProtectTicket)               9224    ${BASIC_TICKET}            Basic2            Pick up at Event         QR            protect         ${EMPTY}            2,303.28
12.Basic(Delivery,QR,ProtectTicket)             9225    ${BASIC_TICKET}            Basic2            Ticket delivery         QR            protect         ${EMPTY}            2,313.75

13.Basic(Digital,ShopeePay)                     9222    ${BASIC_TICKET}            Basic            Digital Ticket         Shopee Pay            ${EMPTY}         ${EMPTY}            2,115.11
14.Basic(Pickup,ShopeePay)                      9223    ${BASIC_TICKET}            Basic            Pick up at Event         Shopee Pay            ${EMPTY}         ${EMPTY}            2,167.99
15.Basic(Delivery,ShopeePay)                    9224    ${BASIC_TICKET}            Basic2            Ticket delivery         Shopee Pay            ${EMPTY}         ${EMPTY}            2,178.56
16.Basic(Delivery,ShopeePay,ProtectTicket)      9225    ${BASIC_TICKET}            Basic2            Ticket delivery         Shopee Pay            protect         ${EMPTY}            2,338.12

17.Basic(Digital,ShopeePay,ProtectTicket)       9222    ${BASIC_TICKET}            Basic            Digital Ticket         Shopee Pay            protect         ${EMPTY}            2,274.66
18.Basic(Pickup,ShopeePay,ProtectTicket)        9223    ${BASIC_TICKET}            Basic            Pick up at Event         Shopee Pay            protect         ${EMPTY}            2,327.54
19.Basic(Digital,Installment)                   9224    ${BASIC_TICKET}            Basic2            Digital Ticket         installment            ${EMPTY}         ${EMPTY}            2,170.21
20.Basic(Pickup,Installment)                    9225    ${BASIC_TICKET}            Basic2            Pick up at Event         installment            ${EMPTY}         ${EMPTY}            2,224.46

21.Basic(Delivery,Installment)                  9222    ${BASIC_TICKET}            Basic            Ticket delivery         installment            ${EMPTY}         ${EMPTY}            2,235.32
22.Basic(Delivery,Installment,ProtectTicket)    9223    ${BASIC_TICKET}            Basic            Ticket delivery         installment            protect         ${EMPTY}            2,399.03
23.Basic(Digital,Installment,ProtectTicket)     9224    ${BASIC_TICKET}            Basic2            Digital Ticket         installment            protect         ${EMPTY}            2,333.92
24.Basic(Pickup,Installment,ProtectTicket)      9225    ${BASIC_TICKET}            Basic2            Pick up at Event         installment            protect         ${EMPTY}            2,388.17

25.Basic(Digital,UploadSlip)                    9222    ${BASIC_TICKET}            Basic            Digital Ticket         Upload Slip            ${EMPTY}         ${EMPTY}            2,060.00
26.Basic(Pickup,UploadSlip)                     9223    ${BASIC_TICKET}            Basic            Pick up at Event         Upload Slip            ${EMPTY}         ${EMPTY}            2,111.50
27.Basic(Delivery,UploadSlip)                   9224    ${BASIC_TICKET}            Basic2            Ticket delivery         Upload Slip            ${EMPTY}         ${EMPTY}            2,121.80
28.Basic(Delivery,UploadSlip,ProtectTicket)     9225    ${BASIC_TICKET}            Basic2            Ticket delivery         Upload Slip            protect         ${EMPTY}            2,277.20

29.Basic(Digital,UploadSlip,ProtectTicket)                          9222    ${BASIC_TICKET}             Basic             Digital Ticket      Upload Slip    protect     ${EMPTY}          2,215.40
30.Basic(Pickup,UploadSlip,ProtectTicket)                           9223    ${BASIC_TICKET}             Basic             Pick up at Event    Upload Slip    protect     ${EMPTY}          2,266.90
31.Basic(Digital,CreditCard,Discount15%)                            9224    ${BASIC_TICKET}             Basic2            Digital Ticket      Creditcard     ${EMPTY}    15%DISCOUNT       1,816.58
32.Basic(Pickup,CreditCard,Discount15%)                             9225    ${BASIC_TICKET}             Basic2            Pick up at Event    Creditcard     ${EMPTY}    15%DISCOUNT       1,870.01

33.Basic(Delivery,CreditCard,Discount15%)                           9222    ${BASIC_TICKET}             Basic             Ticket delivery     Creditcard     ${EMPTY}    15%DISCOUNT       1,880.69
34.Basic(Digital,CreditCard,ProtectTicket,Discount15%)              9223    ${BASIC_TICKET}             Basic             Digital Ticket      Creditcard     protect     15%DISCOUNT       1,977.79
35.Basic(Pickup,CreditCard,ProtectTicket,Discount15%)               9224    ${BASIC_TICKET}             Basic2            Pick up at Event    Creditcard     protect     15%DISCOUNT       2,031.23
36.Basic(Delivery,CreditCard,ProtectTicket,Discount15%)             9225    ${BASIC_TICKET}             Basic2            Ticket delivery     Creditcard     protect     15%DISCOUNT       2,041.91

37.Basic(Digital,QR,Discount15%)                                    9222    ${BASIC_TICKET}             Basic             Digital Ticket      QR             ${EMPTY}    15%DISCOUNT       1,779.11
38.Basic(Pickup,QR,Discount15%)                                     9223    ${BASIC_TICKET}             Basic             Pick up at Event    QR             ${EMPTY}    15%DISCOUNT       1,831.43
39.Basic(Delivery,QR,Discount15%)                                   9224    ${BASIC_TICKET}             Basic2            Ticket delivery     QR             ${EMPTY}    15%DISCOUNT       1,841.89
40.Basic(Digital,QR,ProtectTicket,Discount15%)                      9225    ${BASIC_TICKET}             Basic2            Digital Ticket      QR             protect     15%DISCOUNT       1,937.00

41.Basic(Pickup,QR,ProtectTicket,Discount15%)                       9222    ${BASIC_TICKET}             Basic             Pick up at Event    QR             protect     15%DISCOUNT       1,989.33
42.Basic(Delivery,QR,ProtectTicket,Discount15%)                     9223    ${BASIC_TICKET}             Basic             Ticket delivery     QR             protect     15%DISCOUNT       1,999.79
43.Basic(Digital,ShopeePay,Discount15%)                             9224    ${BASIC_TICKET}             Basic2            Digital Ticket      Shopee Pay     ${EMPTY}    15%DISCOUNT       1,797.84
44.Basic(Pickup,ShopeePay,Discount15%)                              9225    ${BASIC_TICKET}             Basic2            Pick up at Event    Shopee Pay     ${EMPTY}    15%DISCOUNT       1,850.71

45.Basic(Delivery,ShopeePay,Discount15%)                            9222    ${BASIC_TICKET}             Basic             Ticket delivery     Shopee Pay     ${EMPTY}    15%DISCOUNT       1,861.29
46.Basic(Digital,ShopeePay,ProtectTicket,Discount15%)               9223    ${BASIC_TICKET}             Basic             Digital Ticket      Shopee Pay     protect     15%DISCOUNT       1,957.40
47.Basic(Pickup,ShopeePay,ProtectTicket,Discount15%)                9224    ${BASIC_TICKET}             Basic2            Pick up at Event    Shopee Pay     protect     15%DISCOUNT       2,010.28
48.Basic(Delivery,ShopeePay,ProtectTicket,Discount15%)              9225    ${BASIC_TICKET}             Basic2            Ticket delivery     Shopee Pay     protect     15%DISCOUNT       2,020.84

49.Basic(Digital,Installment,Discount15%)                           9222    ${BASIC_TICKET}             Basic             Digital Ticket      installment    ${EMPTY}    15%DISCOUNT       1,844.68
50.Basic(Pickup,Installment,Discount15%)                            9223    ${BASIC_TICKET}             Basic             Pick up at Event    installment    ${EMPTY}    15%DISCOUNT       1,898.94
51.Basic(Delivery,Installment,Discount15%)                          9224    ${BASIC_TICKET}             Basic2            Ticket delivery     installment    ${EMPTY}    15%DISCOUNT       1,909.78
52.Basic(Digital,Installment,ProtectTicket,Discount15%)             9225    ${BASIC_TICKET}             Basic2            Digital Ticket      installment    protect     15%DISCOUNT       2,008.39

53.Basic(Pickup,Installment,ProtectTicket,Discount15%)              9222    ${BASIC_TICKET}             Basic             Pick up at Event    installment    protect     15%DISCOUNT       2,062.64
54.Basic(Delivery,Installment,ProtectTicket,Discount15%)            9223    ${BASIC_TICKET}             Basic             Ticket delivery     installment    protect     15%DISCOUNT       2,073.50
55.Basic(Digital,UploadSlip,Discount15%)                            9224    ${BASIC_TICKET}             Basic2            Digital Ticket      Upload Slip    ${EMPTY}    15%DISCOUNT       1,751.00
56.Basic(Pickup,UploadSlip,Discount15%)                             9225    ${BASIC_TICKET}             Basic2            Pick up at Event    Upload Slip    ${EMPTY}    15%DISCOUNT       1,802.50

57.Basic(Delivery,UploadSlip,Discount15%)                           9222    ${BASIC_TICKET}             Basic             Ticket delivery     Upload Slip    ${EMPTY}    15%DISCOUNT       1,812.80
58.Basic(Digital,UploadSlip,ProtectTicket,Discount15%)              9223    ${BASIC_TICKET}             Basic             Digital Ticket      Upload Slip    protect     15%DISCOUNT       1,906.40
59.Basic(Pickup,UploadSlip,ProtectTicket,Discount15%)               9224    ${BASIC_TICKET}             Basic2            Pick up at Event    Upload Slip    protect     15%DISCOUNT       1,957.90
60.Basic(Delivery,UploadSlip,ProtectTicket,Discount15%)             9225    ${BASIC_TICKET}             Basic2            Ticket delivery     Upload Slip    protect     15%DISCOUNT       1,968.20







    
######### Booknow บัตร 1690 บาท #######

61.BookNow(Digital,CreditCard)                                      9222    ${BOOKNOW_TICKET}           Booknow           Digital Ticket      Creditcard     ${EMPTY}    ${EMPTY}          1,780.25
62.BookNow(Pickup,CreditCard)                                       9223    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    Creditcard     ${EMPTY}    ${EMPTY}          1,885.03
63.BookNow(Delivery,CreditCard)                                     9224    ${BOOKNOW_TICKET}           Booknow2          Ticket delivery     Creditcard     ${EMPTY}    ${EMPTY}          1,937.43
64.BookNow(Digital,CreditCard,ProtectTicket)                        9225    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      Creditcard     protect     ${EMPTY}          1,914.72

65.BookNow(Pickup,CreditCard,ProtectTicket)                         9222    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    Creditcard     protect     ${EMPTY}          2,019.50
66.BookNow(Delivery,CreditCard,ProtectTicket)                       9223    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     Creditcard     protect     ${EMPTY}          2,071.89
67.BookNow(Digital,CreditCard,ProtectTicket,Discount10%)            9224    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      Creditcard     protect     10%DISCOUNT       1,736.69
68.BookNow(Pickup,CreditCard,ProtectTicket,Discount10%)             9225    ${BOOKNOW_TICKET}           Booknow2          Pick up at Event    Creditcard     protect     10%DISCOUNT       1,841.47

69.BookNow(Delivery,CreditCard,ProtectTicket,Discount10%)           9222    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     Creditcard     protect     10%DISCOUNT       1,893.86
70.BookNow(Digital,QR)                                              9223    ${BOOKNOW_TICKET}           Booknow           Digital Ticket      QR             ${EMPTY}    ${EMPTY}          1,743.53
71.BookNow(Pickup,QR)                                               9224    ${BOOKNOW_TICKET}           Booknow2          Pick up at Event    QR             ${EMPTY}    ${EMPTY}          1,846.15
72.BookNow(Delivery,QR)                                             9225    ${BOOKNOW_TICKET}           Booknow2          Ticket delivery     QR             ${EMPTY}    ${EMPTY}          1,897.46

73.BookNow(Digital,QR,ProtectTicket)                                9222    ${BOOKNOW_TICKET}           Booknow           Digital Ticket      QR             protect     ${EMPTY}          1,875.22
74.BookNow(Pickup,QR,ProtectTicket)                                 9223    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    QR             protect     ${EMPTY}          1,977.84
75.BookNow(Delivery,QR,ProtectTicket)                               9224    ${BOOKNOW_TICKET}           Booknow2          Ticket delivery     QR             protect     ${EMPTY}          2,029.16
76.BookNow(Digital,QR,ProtectTicket,Discount10%)                    9225    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      QR             protect     10%DISCOUNT       1,700.87

77.BookNow(Pickup,QR,ProtectTicket,Discount10%)                     9222    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    QR             protect     10%DISCOUNT       1,803.48
78.BookNow(Delivery,QR,ProtectTicket,Discount10%)                   9223    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     QR             protect     10%DISCOUNT       1,854.80
79.BookNow(Digital,ShopeePay)                                       9224    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      Shopee Pay     ${EMPTY}    ${EMPTY}          1,743.53
80.BookNow(Pickup,ShopeePay)                                        9225    ${BOOKNOW_TICKET}           Booknow2          Pick up at Event    Shopee Pay     ${EMPTY}    ${EMPTY}          1,846.15

81.BookNow(Delivery,ShopeePay)                                      9222    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     Shopee Pay     ${EMPTY}    ${EMPTY}          1,897.46
82.BookNow(Digital,ShopeePay,ProtectTicket)                         9223    ${BOOKNOW_TICKET}           Booknow           Digital Ticket      Shopee Pay     protect     ${EMPTY}          1,875.22
83.BookNow(Pickup,ShopeePay,ProtectTicket)                          9224    ${BOOKNOW_TICKET}           Booknow2          Pick up at Event    Shopee Pay     protect     ${EMPTY}          1,977.84
84.BookNow(Delivery,ShopeePay,ProtectTicket)                        9225    ${BOOKNOW_TICKET}           Booknow2          Ticket delivery     Shopee Pay     protect     ${EMPTY}          2,029.16

85.BookNow(Digital,ShopeePay,ProtectTicket,Discount10%)             9222    ${BOOKNOW_TICKET}           Booknow           Digital Ticket      Shopee Pay     protect     10%DISCOUNT       1,700.87
86.BookNow(Pickup,ShopeePay,ProtectTicket,Discount10%)              9223    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    Shopee Pay     protect     10%DISCOUNT       1,803.48
87.BookNow(Delivery,ShopeePay,ProtectTicket,Discount10%)            9224    ${BOOKNOW_TICKET}           Booknow2          Ticket delivery     Shopee Pay     protect     10%DISCOUNT       1,854.80
88.BookNow(Digital,Installment)                                     9225    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      installment    ${EMPTY}    ${EMPTY}          1,807.80

89.BookNow(Pickup,Installment)                                      9222    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    installment    ${EMPTY}    ${EMPTY}          1,914.20
90.BookNow(Delivery,Installment)                                    9223    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     installment    ${EMPTY}    ${EMPTY}          1,967.40
91.BookNow(Digital,Installment,ProtectTicket)                       9224    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      installment    protect     ${EMPTY}          1,944.34
92.BookNow(Pickup,Installment,ProtectTicket)                        9225    ${BOOKNOW_TICKET}           Booknow2          Pick up at Event    installment    protect     ${EMPTY}          2,050.74

93.BookNow(Delivery,Installment,ProtectTicket)                      9222    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     installment    protect     ${EMPTY}          2,103.95
94.BookNow(Digital,Installment,ProtectTicket,Discount10%)           9223    ${BOOKNOW_TICKET}           Booknow           Digital Ticket      installment    protect     10%DISCOUNT       1,763.56
95.BookNow(Pickup,Installment,ProtectTicket,Discount10%)            9224    ${BOOKNOW_TICKET}           Booknow2          Pick up at Event    installment    protect     10%DISCOUNT       1,869.96
96.BookNow(Delivery,Installment,ProtectTicket,Discount10%)          9225    ${BOOKNOW_TICKET}           Booknow2          Ticket delivery     installment    protect     10%DISCOUNT       1,923.16

97.BookNow(Digital,UploadSlip)                                      9222    ${BOOKNOW_TICKET}           Booknow           Digital Ticket      Upload Slip    ${EMPTY}    ${EMPTY}          1,715.99
98.BookNow(Pickup,UploadSlip)                                       9223    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    Upload Slip    ${EMPTY}    ${EMPTY}          1,816.99
99.BookNow(Delivery,UploadSlip)                                     9224    ${BOOKNOW_TICKET}           Booknow2          Ticket delivery     Upload Slip    ${EMPTY}    ${EMPTY}          1,867.49
100.BookNow(Digital,UploadSlip,ProtectTicket)                       9225    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      Upload Slip    protect     ${EMPTY}          1,845.60

101.BookNow(Pickup,UploadSlip,ProtectTicket)                        9222    ${BOOKNOW_TICKET}           Booknow           Pick up at Event    Upload Slip    protect     ${EMPTY}          1,946.60
102.BookNow(Delivery,UploadSlip,ProtectTicket)                      9223    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     Upload Slip    protect     ${EMPTY}          1,997.10
103.BookNow(Digital,UploadSlip,ProtectTicket,Discount10%)           9224    ${BOOKNOW_TICKET}           Booknow2          Digital Ticket      Upload Slip    protect     10%DISCOUNT       1,674.00
104.BookNow(Pickup,UploadSlip,ProtectTicket,Discount10%)            9225    ${BOOKNOW_TICKET}           Booknow2          Pick up at Event    Upload Slip    protect     10%DISCOUNT       1,775.00

105.BookNow(Delivery,UploadSlip,ProtectTicket,Discount10%)          9222    ${BOOKNOW_TICKET}           Booknow           Ticket delivery     Upload Slip    protect     10%DISCOUNT       1,825.50



########## Buffet บัตร ... บาท #######

106.Buffet(Digital,CreditCard)                                      9222    ${bUFFET_TICKET}            Buffet            Digital Ticket      Creditcard     ${EMPTY}    ${EMPTY}          1,815.51
107.Buffet(Pickup,CreditCard)                                       9223    ${bUFFET_TICKET}            Buffet            Pick up at Event    Creditcard     ${EMPTY}    ${EMPTY}          1,868.93
108.Buffet(Delivery,CreditCard)                                     9224    ${bUFFET_TICKET}            Buffet            Ticket delivery     Creditcard     ${EMPTY}    ${EMPTY}          1,922.36
109.Buffet(Digital,CreditCard,ProtectTicket)                        9225    ${bUFFET_TICKET}            Buffet            Digital Ticket      Creditcard     protect     ${EMPTY}          2,010.91

110.Buffet(Pickup,CreditCard,ProtectTicket)                         9222    ${bUFFET_TICKET}            Buffet            Pick up at Event    Creditcard     protect     ${EMPTY}          2,064.33
111.Buffet(Delivery,CreditCard,ProtectTicket)                       9223    ${bUFFET_TICKET}            Buffet            Ticket delivery     Creditcard     protect     ${EMPTY}          2,117.77
112.Buffet(Digital,CreditCard,ProtectTicket,Discount10%)            9224    ${bUFFET_TICKET}            Buffet            Digital Ticket      Creditcard     protect     10%DISCOUNT       1,829.36
113.Buffet(Pickup,CreditCard,ProtectTicket,Discount10%)             9225    ${bUFFET_TICKET}            Buffet            Pick up at Event    Creditcard     protect     10%DISCOUNT       1,882.79

114.Buffet(Delivery,CreditCard,ProtectTicket,Discount10%)           9222    ${bUFFET_TICKET}            Buffet            Ticket delivery     Creditcard     protect     10%DISCOUNT       1,936.21
115.Buffet(Digital,QR)                                              9223    ${bUFFET_TICKET}            Buffet            Digital Ticket      QR             ${EMPTY}    ${EMPTY}          1,778.06
116.Buffet(Pickup,QR)                                               9224    ${bUFFET_TICKET}            Buffet            Pick up at Event    QR             ${EMPTY}    ${EMPTY}          1,830.38
117.Buffet(Delivery,QR)                                             9225    ${bUFFET_TICKET}            Buffet            Ticket delivery     QR             ${EMPTY}    ${EMPTY}          1,882.71

118.Buffet(Digital,QR,ProtectTicket)                                9222    ${bUFFET_TICKET}            Buffet            Digital Ticket      QR             protect     ${EMPTY}          1,969.42
119.Buffet(Pickup,QR,ProtectTicket)                                 9223    ${bUFFET_TICKET}            Buffet            Pick up at Event    QR             protect     ${EMPTY}          2,021.76
120.Buffet(Delivery,QR,ProtectTicket)                               9224    ${bUFFET_TICKET}            Buffet            Ticket delivery     QR             protect     ${EMPTY}          2,074.08
121.Buffet(Digital,QR,ProtectTicket,Discount10%)                    9225    ${bUFFET_TICKET}            Buffet            Digital Ticket      QR             protect     10%DISCOUNT       1,791.62

122.Buffet(Pickup,QR,ProtectTicket,Discount10%)                     9222    ${bUFFET_TICKET}            Buffet            Pick up at Event    QR             protect     10%DISCOUNT       1,843.95
123.Buffet(Delivery,QR,ProtectTicket,Discount10%)                   9223    ${bUFFET_TICKET}            Buffet            Ticket delivery     QR             protect     10%DISCOUNT       1,896.27
124.Buffet(Digital,ShopeePay)                                       9224    ${bUFFET_TICKET}            Buffet            Digital Ticket      Shopee Pay     ${EMPTY}    ${EMPTY}          1,796.78
125.Buffet(Pickup,ShopeePay)                                        9225    ${bUFFET_TICKET}            Buffet            Pick up at Event    Shopee Pay     ${EMPTY}    ${EMPTY}          1,849.66

126.Buffet(Delivery,ShopeePay)                                      9222    ${bUFFET_TICKET}            Buffet            Ticket delivery     Shopee Pay     ${EMPTY}    ${EMPTY}          1,902.53
127.Buffet(Digital,ShopeePay,ProtectTicket)                         9223    ${bUFFET_TICKET}            Buffet            Digital Ticket      Shopee Pay     protect     ${EMPTY}          1,990.17
128.Buffet(Pickup,ShopeePay,ProtectTicket)                          9224    ${bUFFET_TICKET}            Buffet            Pick up at Event    Shopee Pay     protect     ${EMPTY}          2,043.05
129.Buffet(Delivery,ShopeePay,ProtectTicket)                        9225    ${bUFFET_TICKET}            Buffet            Ticket delivery     Shopee Pay     protect     ${EMPTY}          2,095.92

130.Buffet(Digital,ShopeePay,ProtectTicket,Discount10%)             9222    ${bUFFET_TICKET}            Buffet            Digital Ticket      Shopee Pay     protect     10%DISCOUNT       1,810.49
131.Buffet(Pickup,ShopeePay,ProtectTicket,Discount10%)              9223    ${bUFFET_TICKET}            Buffet            Pick up at Event    Shopee Pay     protect     10%DISCOUNT       1,863.37
132.Buffet(Delivery,ShopeePay,ProtectTicket,Discount10%)            9224    ${bUFFET_TICKET}            Buffet            Ticket delivery     Shopee Pay     protect     10%DISCOUNT       1,916.25
133.Buffet(Digital,Installment)                                     9225    ${bUFFET_TICKET}            Buffet            Digital Ticket      installment    ${EMPTY}    ${EMPTY}          1,843.60

134.Buffet(Pickup,Installment)                                      9222    ${bUFFET_TICKET}            Buffet            Pick up at Event    installment    ${EMPTY}    ${EMPTY}          1,897.84
135.Buffet(Delivery,Installment)                                    9223    ${bUFFET_TICKET}            Buffet            Ticket delivery     installment    ${EMPTY}    ${EMPTY}          1,952.11
136.Buffet(Digital,Installment,ProtectTicket)                       9224    ${bUFFET_TICKET}            Buffet            Digital Ticket      installment    protect     ${EMPTY}          2,042.02
137.Buffet(Pickup,Installment,ProtectTicket)                        9225    ${bUFFET_TICKET}            Buffet            Pick up at Event    installment    protect     ${EMPTY}          2,096.27

138.Buffet(Delivery,Installment,ProtectTicket)                      9222    ${bUFFET_TICKET}            Buffet            Ticket delivery     installment    protect     ${EMPTY}          2,150.53
139.Buffet(Digital,Installment,ProtectTicket,Discount10%)           9223    ${bUFFET_TICKET}            Buffet            Digital Ticket      installment    protect     10%DISCOUNT       1,857.66
140.Buffet(Pickup,Installment,ProtectTicket,Discount10%)            9224    ${bUFFET_TICKET}            Buffet            Pick up at Event    installment    protect     10%DISCOUNT       1,911.91
141.Buffet(Delivery,Installment,ProtectTicket,Discount10%)          9225    ${bUFFET_TICKET}            Buffet            Ticket delivery     installment    protect     10%DISCOUNT       1,966.17

142.Buffet(Digital,UploadSlip)                                      9222    ${bUFFET_TICKET}            Buffet            Digital Ticket      Upload Slip    ${EMPTY}    ${EMPTY}          1,749.97
143.Buffet(Pickup,UploadSlip)                                       9223    ${bUFFET_TICKET}            Buffet            Pick up at Event    Upload Slip    ${EMPTY}    ${EMPTY}          1,801.47
144.Buffet(Delivery,UploadSlip)                                     9224    ${bUFFET_TICKET}            Buffet            Ticket delivery     Upload Slip    ${EMPTY}    ${EMPTY}          1,852.97
145.Buffet(Digital,UploadSlip,ProtectTicket)                        9225    ${bUFFET_TICKET}            Buffet            Digital Ticket      Upload Slip    protect     ${EMPTY}          1,938.32

146.Buffet(Pickup,UploadSlip,ProtectTicket)                         9222    ${bUFFET_TICKET}            Buffet            Pick up at Event    Upload Slip    protect     ${EMPTY}          1,989.82
147.Buffet(Delivery,UploadSlip,ProtectTicket)                       9223    ${bUFFET_TICKET}            Buffet            Ticket delivery     Upload Slip    protect     ${EMPTY}          2,041.32
148.Buffet(Digital,UploadSlip,ProtectTicket,Discount10%)            9224    ${bUFFET_TICKET}            Buffet            Digital Ticket      Upload Slip    protect     10%DISCOUNT       1,763.32
149.Buffet(Pickup,UploadSlip,ProtectTicket,Discount10%)             9225    ${bUFFET_TICKET}            Buffet            Pick up at Event    Upload Slip    protect     10%DISCOUNT       1,814.82

150.Buffet(Delivery,UploadSlip,ProtectTicket,Discount10%)           9222    ${bUFFET_TICKET}            Buffet            Ticket delivery     Upload Slip    protect     10%DISCOUNT       1,866.32




##### Choose a round ราคา 699 ####


151.ChooseARound(Digital,CreditCard)                                9222    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Creditcard     ${EMPTY}    ${EMPTY}          746.93
152.ChooseARound(Pickup,CreditCard)                                 9223    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Creditcard     ${EMPTY}    ${EMPTY}          853.79
153.ChooseARound(Delivery,CreditCard)                               9224    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Creditcard     ${EMPTY}    ${EMPTY}          960.65
154.ChooseARound(Digital,CreditCard,ProtectTicket)                  9225    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Creditcard     protect     ${EMPTY}          804.03

155.ChooseARound(Pickup,CreditCard,ProtectTicket)                   9222    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Creditcard     protect     ${EMPTY}          910.88
156.ChooseARound(Delivery,CreditCard,ProtectTicket)                 9223    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Creditcard     protect     ${EMPTY}          1,017.74
157.ChooseARound(Digital,CreditCard,ProtectTicket,Discount100)      9224    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Creditcard     protect     100.- DISCOUNT    697.17
158.ChooseARound(Pickup,CreditCard,ProtectTicket,Discount100)       9225    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Creditcard     protect     100.- DISCOUNT    804.03

159.ChooseARound(Delivery,CreditCard,ProtectTicket,Discount100)     9222    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Creditcard     protect     100.- DISCOUNT    910.88
160.ChooseARound(Digital,QR)                                        9223    ${Choose a round_TICKET}    Choose a round    Digital Ticket      QR             ${EMPTY}    ${EMPTY}          735.38
161.ChooseARound(Pickup,QR)                                         9224    ${Choose a round_TICKET}    Choose a round    Pick up at Event    QR             ${EMPTY}    ${EMPTY}          840.58
162.ChooseARound(Delivery,QR)                                       9225    ${Choose a round_TICKET}    Choose a round    Ticket delivery     QR             ${EMPTY}    ${EMPTY}          945.79

163.ChooseARound(Digital,QR,ProtectTicket)                          9222    ${Choose a round_TICKET}    Choose a round    Digital Ticket      QR             protect     ${EMPTY}          791.59
164.ChooseARound(Pickup,QR,ProtectTicket)                           9223    ${Choose a round_TICKET}    Choose a round    Pick up at Event    QR             protect     ${EMPTY}          896.79
165.ChooseARound(Delivery,QR,ProtectTicket)                         9224    ${Choose a round_TICKET}    Choose a round    Ticket delivery     QR             protect     ${EMPTY}          1,001.99
166.ChooseARound(Digital,QR,ProtectTicket,Discount100)              9225    ${Choose a round_TICKET}    Choose a round    Digital Ticket      QR             protect     100.- DISCOUNT    686.38

167.ChooseARound(Pickup,QR,ProtectTicket,Discount100)               9222    ${Choose a round_TICKET}    Choose a round    Pick up at Event    QR             protect     100.- DISCOUNT    791.59
168.ChooseARound(Delivery,QR,ProtectTicket,Discount100)             9223    ${Choose a round_TICKET}    Choose a round    Ticket delivery     QR             protect     100.- DISCOUNT    896.79
169.ChooseARound(Digital,ShopeePay)                                 9224    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Shopee Pay     ${EMPTY}    ${EMPTY}          743.08
170.ChooseARound(Pickup,ShopeePay)                                  9225    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Shopee Pay     ${EMPTY}    ${EMPTY}          849.39

171.ChooseARound(Delivery,ShopeePay)                                9222    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Shopee Pay     ${EMPTY}    ${EMPTY}          955.69
172.ChooseARound(Digital,ShopeePay,ProtectTicket)                   9223    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Shopee Pay     protect     ${EMPTY}          799.88
173.ChooseARound(Pickup,ShopeePay,ProtectTicket)                    9224    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Shopee Pay     protect     ${EMPTY}          906.18
174.ChooseARound(Delivery,ShopeePay,ProtectTicket)                  9225    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Shopee Pay     protect     ${EMPTY}          1,012.49

175.ChooseARound(Digital,ShopeePay,ProtectTicket,Discount100)       9222    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Shopee Pay     protect     100.- DISCOUNT    693.57
176.ChooseARound(Pickup,ShopeePay,ProtectTicket,Discount100)        9223    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Shopee Pay     protect     100.- DISCOUNT    799.88
177.ChooseARound(Delivery,ShopeePay,ProtectTicket,Discount100)      9224    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Shopee Pay     protect     100.- DISCOUNT    906.18
178.ChooseARound(Digital,Installment)                               9225    ${Choose a round_TICKET}    Choose a round    Digital Ticket      installment    ${EMPTY}    ${EMPTY}          758.49

179.ChooseARound(Pickup,Installment)                                9222    ${Choose a round_TICKET}    Choose a round    Pick up at Event    installment    ${EMPTY}    ${EMPTY}          867.00
180.ChooseARound(Delivery,Installment)                              9223    ${Choose a round_TICKET}    Choose a round    Ticket delivery     installment    ${EMPTY}    ${EMPTY}          975.51
181.ChooseARound(Digital,Installment,ProtectTicket)                 9224    ${Choose a round_TICKET}    Choose a round    Digital Ticket      installment    protect     ${EMPTY}          816.46
182.ChooseARound(Pickup,Installment,ProtectTicket)                  9225    ${Choose a round_TICKET}    Choose a round    Pick up at Event    installment    protect     ${EMPTY}          924.97

183.ChooseARound(Delivery,Installment,ProtectTicket)                9222    ${Choose a round_TICKET}    Choose a round    Ticket delivery     installment    protect     ${EMPTY}          1,033.48
184.ChooseARound(Digital,Installment,ProtectTicket,Discount100)     9223    ${Choose a round_TICKET}    Choose a round    Digital Ticket      installment    protect     100.- DISCOUNT    707.95
185.ChooseARound(Pickup,Installment,ProtectTicket,Discount100)      9224    ${Choose a round_TICKET}    Choose a round    Pick up at Event    installment    protect     100.- DISCOUNT    816.46
186.ChooseARound(Delivery,Installment,ProtectTicket,Discount100)    9225    ${Choose a round_TICKET}    Choose a round    Ticket delivery     installment    protect     100.- DISCOUNT    924.97


187.ChooseARound(Digital,UploadSlip)                                9222    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Upload Slip    ${EMPTY}    ${EMPTY}          719.97
188.ChooseARound(Pickup,UploadSlip)                                 9223    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Upload Slip    ${EMPTY}    ${EMPTY}          822.97
189.ChooseARound(Delivery,UploadSlip)                               9224    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Upload Slip    ${EMPTY}    ${EMPTY}          925.97
190.ChooseARound(Digital,UploadSlip,ProtectTicket)                  9225    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Upload Slip    protect     ${EMPTY}          775.00

191.ChooseARound(Pickup,UploadSlip,ProtectTicket)                   9222    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Upload Slip    protect     ${EMPTY}          878.00
192.ChooseARound(Delivery,UploadSlip,ProtectTicket)                 9223    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Upload Slip    protect     ${EMPTY}          981.00
193.ChooseARound(Digital,UploadSlip,ProtectTicket,Discount100)      9224    ${Choose a round_TICKET}    Choose a round    Digital Ticket      Upload Slip    protect     100.- DISCOUNT    672.00
194.ChooseARound(Pickup,UploadSlip,ProtectTicket,Discount100)       9225    ${Choose a round_TICKET}    Choose a round    Pick up at Event    Upload Slip    protect     100.- DISCOUNT    775.00

195.ChooseARound(Delivery,UploadSlip,ProtectTicket,Discount100)     9222    ${Choose a round_TICKET}    Choose a round    Ticket delivery     Upload Slip    protect     100.- DISCOUNT    878.00





#######      แบ่งรันเพราะบัตร (Zoneseat-Run ได้แค่ 1 Browser)
#######      python -m robot TC03_Price_check.robot

# #zone seat    ใส่โค้ดลด อัตโนมัติเมื่อซื้อสองใบ

# 196.ZoneSeat(Pickup,CreditCard,AutoPromo)                           9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    Creditcard     ${EMPTY}    AUTO PROMO        4,787.21
# 197.ZoneSeat(Delivery,CreditCard,AutoPromo)                         9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     Creditcard     ${EMPTY}    AUTO PROMO        4,894.07
# 198.ZoneSeat(Pickup,CreditCard,ProtectTicket,AutoPromo)             9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    Creditcard     protect     AUTO PROMO        5156.07
# 199.ZoneSeat(Delivery,CreditCard,ProtectTicket,AutoPromo)           9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     Creditcard     protect     AUTO PROMO        5262.92


# 200.ZoneSeat(Pickup,QR,AutoPromo)                                   9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    QR             ${EMPTY}    AUTO PROMO        4,713.15
# 201.ZoneSeat(Delivery,QR,AutoPromo)                                 9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     QR             ${EMPTY}    AUTO PROMO        4,818.35
# 202.ZoneSeat(Pickup,QR,ProtectTicket,AutoPromo)                     9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    QR             protect     AUTO PROMO        5076.3
# 203.ZoneSeat(Delivery,QR,ProtectTicket,AutoPromo)                   9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     QR             protect     AUTO PROMO        5181.5


# 204.ZoneSeat(Pickup,ShopeePay,AutoPromo)                            9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    Shopee Pay     ${EMPTY}    AUTO PROMO        4,737.84
# 205.ZoneSeat(Delivery,ShopeePay,AutoPromo)                          9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     Shopee Pay     ${EMPTY}    AUTO PROMO        4,843.60
# 206.ZoneSeat(Pickup,ShopeePay,ProtectTicket,AutoPromo)              9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    Shopee Pay     protect     AUTO PROMO        5102.89
# 207.ZoneSeat(Delivery,ShopeePay,ProtectTicket,AutoPromo)            9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     Shopee Pay     protect     AUTO PROMO        5208.64


# 208.ZoneSeat(Pickup,Installment,AutoPromo)                          9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    installment    ${EMPTY}    AUTO PROMO        4,861.27
# 209.ZoneSeat(Delivery,Installment,AutoPromo)                        9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     installment    ${EMPTY}    AUTO PROMO        4,969.78
# 210.ZoneSeat(Pickup,Installment,ProtectTicket,AutoPromo)            9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    installment    protect     AUTO PROMO        5235.84
# 211.ZoneSeat(Delivery,Installment,ProtectTicket,AutoPromo)          9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     installment    protect     AUTO PROMO        5344.35


# 212.ZoneSeat(Pickup,UploadSlip,AutoPromo)                           9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    Upload Slip    ${EMPTY}    AUTO PROMO        4,614.40
# 213.ZoneSeat(Delivery,UploadSlip,AutoPromo)                         9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     Upload Slip    ${EMPTY}    AUTO PROMO        4,717.40
# 214.ZoneSeat(Pickup,UploadSlip,ProtectTicket,AutoPromo)             9225    ${ZoneSeat_TICKET}          Zone seat2        Pick up at Event    Upload Slip    protect     AUTO PROMO        4969.94
# 215.ZoneSeat(Delivery,UploadSlip,ProtectTicket,AutoPromo)           9225    ${ZoneSeat_TICKET}          Zone seat2        Ticket delivery     Upload Slip    protect     AUTO PROMO        5,072.94

# ######## Zone seat 1 ใบ
# 216.ZoneSeat(Pickup,CreditCard,Discount200)                         9225    ${ZoneSeat_TICKET}          Zone seat         Pick up at Event    Creditcard     ${EMPTY}    200Discount       2,286.75




##############zone table
# 217.ZoneTable(Digital,CreditCard,Promo-100)                         9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      Creditcard     ${EMPTY}    -100PROMO         1,496.00
# 218.ZoneTable(Pickup,CreditCard,Promo-100)                          9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    Creditcard     ${EMPTY}    -100PROMO         1,549.43
# 219.ZoneTable(Digital,CreditCard,ProtectTicket,Promo-100)           9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      Creditcard     protect     -100PROMO         1,618.35
# 220.ZoneTable(Pickup,CreditCard,ProtectTicket,Promo-100)            9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    Creditcard     protect     -100PROMO         1,671.78

# 221.ZoneTable(Digital,QR,Promo-100)                                 9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      QR             ${EMPTY}    -100PROMO         1,472.86
# 222.ZoneTable(Pickup,QR,Promo-100)                                  9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    QR             ${EMPTY}    -100PROMO         1,525.46
# 223.ZoneTable(Digital,QR,ProtectTicket,Promo-100)                   9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      QR             protect     -100PROMO         1,593.31
# 224.ZoneTable(Pickup,QR,ProtectTicket,Promo-100)                    9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    QR             protect     -100PROMO         1,645.92


# 225.ZoneTable(Digital,ShopeePay,Promo-100)                          9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      Shopee Pay     ${EMPTY}    -100PROMO         1,480.57
# 226.ZoneTable(Pickup,ShopeePay,Promo-100)                           9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    Shopee Pay     ${EMPTY}    -100PROMO         1,533.45
# 227.ZoneTable(Digital,ShopeePay,ProtectTicket,Promo-100)            9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      Shopee Pay     protect     -100PROMO         1,601.66
# 228.ZoneTable(Pickup,ShopeePay,ProtectTicket,Promo-100)             9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    Shopee Pay     protect     -100PROMO         1,654.54


# 229.ZoneTable(Digital,Installment,Promo-100)                        9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      installment    ${EMPTY}    -100PROMO         1,519.15
# 230.ZoneTable(Pickup,Installment,Promo-100)                         9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    installment    ${EMPTY}    -100PROMO         1,573.40
# 231.ZoneTable(Digital,Installment,ProtectTicket,Promo-100)          9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      installment    protect     -100PROMO         1,643.39
# 232.ZoneTable(Pickup,Installment,ProtectTicket,Promo-100)           9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    installment    protect     -100PROMO         1,697.64


# 233.ZoneTable(Digital,UploadSlip,Promo-100)                         9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      Upload Slip    ${EMPTY}    -100PROMO         1,442.00
# 234.ZoneTable(Pickup,UploadSlip,Promo-100)                          9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    Upload Slip    ${EMPTY}    -100PROMO         1,493.50
# 235.ZoneTable(Digital,UploadSlip,ProtectTicket,Promo-100)           9225    ${ZoneTable_TICKET}         Zone table        Digital Ticket      Upload Slip    protect     -100PROMO         1,559.93
# 236.ZoneTable(Pickup,UploadSlip,ProtectTicket,Promo-100)            9225    ${ZoneTable_TICKET}         Zone table        Pick up at Event    Upload Slip    protect     -100PROMO         1,611.43