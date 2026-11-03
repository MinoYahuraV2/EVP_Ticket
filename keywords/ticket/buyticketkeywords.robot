*** Settings ***
# Library         SeleniumLibrary
Library         pabot.PabotLib
Library         RPA.Desktop
Resource        ../common/commonkeywords.robot
Variables       ../../resources/config.yaml   

*** Variables ***
${IMAGE_PATH}
${PABOTNUMBEROFPROCESSES}    0
${BARRIER_ENABLED}           ${False}
${BARRIER_ARRIVED}           ${False}
${BARRIER_COUNT}             0

*** Keywords ***
Capture QR Code Screenshot
    # เปลี่ยนจาก Set Variable มาใช้ Set Test Variable
    Set Test Variable    ${IMAGE_PATH}    ${CURDIR}/QRpic/${TEST NAME}_QR.png
    
    # ${QR_LOCATOR}=    Set Variable    xpath=//*[@class='qr-code-img qr-img']/..
    ${QR_LOCATOR}=    Set Variable    xpath=//*[@class='qr-code-img qr-img']/..

    Wait Until Element Is Visible    ${QR_LOCATOR}    timeout=10s
    Capture Element Screenshot    ${QR_LOCATOR}    filename=${IMAGE_PATH}
    

getname(flowtravel)
    commonkeywords.get name price        class:payment-summary-header__event-name
    commonkeywords.get price withtime     class:payment-summary-header__event-name

getname(normal)
    commonkeywords.get name price        class:payment-summary-header__event-name
    # commonkeywords.get price        xpath://div[1]/div[6]/div[2]
    
    
# ==========================================
# ส่วนที่ 1: ขั้นตอนการเลือกบัตร (แยกตามประเภท)
# ==========================================
Select Basic Ticket
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket
    


Select Basic Ticket1
    Remove File    price_log.txt
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    waiting for elements    xpath=(//div[text()='1'])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket
    
Basic2
    Scroll To The Very Bottom
    Sleep    1s
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    waiting for elements    xpath=(//div[text()='1'])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select 2 Basic Ticket
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div[2]/div[1]/button
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div[2]/div[3]/button/i
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='2'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep     1s 
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

# ใช้
1 Basic last
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div[2]/div[1]/button
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div[2]/div[4]/button/i
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep     1s 
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket
Basic 2 left
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div[2]/div[1]/button
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div[2]/div[3]/button/i
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep     1s 
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket


### บัตร Booknow ### 

Select Booknow Ticket
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//button[text()='Book Now'])[3]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[4]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Booknow Ticket1
    Remove File    price_log.txt
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//button[text()='Book Now'])[3]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[4]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Booknow Ticket2
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//button[text()='Book Now'])[1]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket
    
Booknow last
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//button[text()='Book Now'])[3]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[7]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Booknow 2 left
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//button[text()='Book Now'])[3]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[6]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket



### บัตร Buffet ### 

Select Buffet Ticket
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Buffet Ticket1
    Remove File    price_log.txt
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Buffet Ticket last
    # ถ้าจะเปลี่ยนวันที่ซื้อใช้อันนี้
    # Wait until element is ready then click element    xpath://img[@class='img_sorting']
    # Wait until element is ready then click element    xpath://button[normalize-space()='3']
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath://span[normalize-space()='10:00-12:00']
    Wait until element is ready then click element    xpath://div[normalize-space()='14:00-16:00']
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket
 
Select Buffet 2 left 
    # ถ้าจะเปลี่ยนวันที่ซื้อใช้อันนี้
    # Wait until element is ready then click element    xpath://img[@class='img_sorting']
    # Wait until element is ready then click element    xpath://button[normalize-space()='3']
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath://span[normalize-space()='10:00-12:00']
    Wait until element is ready then click element    xpath://div[normalize-space()='12:00-14:00']
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket


### บัตร Choose a round ### 

Select Choose a round Ticket
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Choose a round Ticket1
    Remove File    price_log.txt
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Choose a round Ticket2
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Choose a round 2 left
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div/div/div/div/div[2]/section/div[2]/div/div[3]/div/div/div
    Wait until element is ready then click element    xpath://div[normalize-space()='12:00 - 14:00']
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select Choose a round Ticket last
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div/div/div/div/div[2]/section/div[2]/div/div[3]/div/div/div
    Wait until element is ready then click element    xpath://div[normalize-space()='14:00 - 16:00']
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket



### บัตร Getlink ### 

Select GetLink Ticket
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select GetLink Ticket1
    Remove File    price_log.txt
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select GetLink Ticket2
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath:(//button[normalize-space()='Buy Ticket' or normalize-space()='ซื้อบัตร'])[1]
    Sleep    2s
    Click Element    xpath=//body
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    waiting for elements    xpath=(//div[text()='1'])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket

Select GetLink Ticket last
    Wait until element is ready then click element    xpath:(//button[normalize-space()='Buy Ticket' or normalize-space()='ซื้อบัตร'])[1]
    Sleep    2s
    Click Element    xpath=//body
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    waiting for elements    xpath=(//div[text()='1'])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    commonkeywords.get ticket name    class:payment-summary-ticket-list__ticket


### บัตร Zone Seat ### 

Select Zone Seat
    Maximize Browser Window
    Remove File    price_log.txt
    # Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/button
    # Remove File    price_log.txt
    Wait until element is ready then click element    xpath:(//button[normalize-space()='ซื้อบัตร' or normalize-space()='Buy Ticket'])[2]
    # Wait until element is ready then click element    xpath:(//button[normalize-space()='ไปที่บัตร' or normalize-space()='Go to Tickets'])[2]
    # Wait until element is ready then click element    xpath=(//button[contains(@class, 'buy-ticket-button')])[2]
    Sleep    3s
    RPA.Desktop.Wait For Element    image:../../images/B1.png    timeout=30
    RPA.Desktop.Click    image:../../images/B1.png        
    Wait until element is ready then click element    xpath:(//label/div/div)[1]
    Wait until element is ready then click element    xpath://button[normalize-space()='ชำระเงิน' or normalize-space()='Check Out']
    # Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[3]/div/div[2]/div/div/div[2]/div[3]/button
    Sleep    1s
    get seat fullscreen

Select Zone Seat(2)
    Maximize Browser Window
    Wait until element is ready then click element    xpath:(//button[normalize-space()='ซื้อบัตร' or normalize-space()='Buy Ticket'])[2]
    Sleep    10s
    # RPA.Desktop.Wait For Element    image:../../images/B1.png    timeout=30
    # RPA.Desktop.Click    image:../../images/B1.png        
    Wait until element is ready then click element    xpath:(//label/div/div)[1]
    Wait until element is ready then click element    xpath://button[normalize-space()='ชำระเงิน' or normalize-space()='Check Out']
    Sleep    1s
    get seat fullscreen



### บัตร Zone Table ### 

Select Zone table 
    Maximize Browser Window
    Remove File    price_log.txt    
    Wait until element is ready then click element    xpath:(//button[normalize-space()='ซื้อบัตร' or normalize-space()='Buy Ticket'])[2]
    #  Wait until element is ready then click element    xpath:(//button[normalize-space()='ไปที่บัตร' or normalize-space()='Go to Tickets'])[2]
    # Wait until element is ready then click element    xpath=(//button[contains(@class, 'buy-ticket-button')])[2]
    # Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/button
    Sleep    3s
    RPA.Desktop.Wait For Element    image:../../images/B1.png    timeout=30
    RPA.Desktop.Click    image:../../images/B1.png
    Wait until element is ready then click element    xpath:(//label/div/div)[1]
    Wait until element is ready then click element    xpath://button[normalize-space()='ชำระเงิน' or normalize-space()='Check Out']
    Sleep    1s
    get seat fullscreen


### บัตร FlowTravel ### 

Select flowtravel1
    Remove File    price_log.txt
    Remove File    Ticket_name_log.txt
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Wait until element is ready then input text    css:[placeholder="+66 123456789"]    122121212
    click enter key to submit form
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]

Select flowtravel
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Wait until element is ready then input text    css:[placeholder="+66 123456789"]    122121212
    click enter key to submit form
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]

Select flowtravel4
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[3]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Wait until element is ready then input text    css:[placeholder="+66 123456789"]    122121212
    click enter key to submit form
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]






### บัตร Buffet Form ### 




get seat fullscreen
    commonkeywords.get seat    class:payment-summary-ticket-list__ticket
  

# ==========================================
# ส่วนที่ 2: ขั้นตอนจ่ายเงิน (ใช้โค้ดชุดเดียวกันทั้งหมด)
# ==========================================

Process Credit card pay
    Wait until element is ready then click element    xpath=//button[@id="credit-radio"]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]
    # commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        class:payment-summary-total
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
    Check Payment Success


Process Credit card pay2
    # Remove File    price_log.txt
    # flow travel
    Wait until element is ready then click element    xpath=//button[@id="credit-radio"]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[1]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
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
    Check Payment Success

Validate OTP
    [Arguments]    ${OTP}
    Wait Until Element Is Visible    xpath:/html/body/div/form/div/div[4]/div[2]/input    timeout=30s
    Input Text    xpath:/html/body/div/form/div/div[4]/div[2]/input    ${OTP}
    # Click Element    xpath:/html/body/div/form/div/div[5]/div/button[1]
    Click Element    class:btn-primary
    #หาข้อความ success
    Wait Until Element Is Visible    xpath=//p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=30s


QR Pay
    # Wait until element is ready then click element    page.locator(`//button[@id='prompt-pay-radio']`)
    Scroll To PromptPay
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    # Remove File    price_log.txt
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]
    Sleep    3s
    Scroll Element Into View    class:payment-summary-header__title
    Capture 
    Upload Image
    Check Success
    Check Payment Success
    
QR Pay02
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]
    Capture 
    Upload Image
    Check Success
    Check Payment Success
    
QR Pay2
    # Wait until element is ready then click element    page.locator(`//button[@id='prompt-pay-radio']`)
    Scroll To PromptPay
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    # Remove File    price_log.txt
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[1]
    # Scroll To The Very Bottom
    Capture2
    Upload Image
    Check Success
    Check Payment Success
    

Capture
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[@class='qr-code-img qr-img']    timeout=20s
    Capture QR Code Screenshot  

Capture2
    Scroll To The Very Bottom
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[@class='qr-code-img qr-img']    timeout=20s
    Capture QR Code Screenshot  



 

Upload Image
    Sleep    1s
    Click Element    xpath=//body
    Sleep    0.5s
    SeleniumLibrary.Execute Javascript    window.open('http://qrtool.globalprimepay.com/qr')
    SeleniumLibrary.Switch Window    NEW

    click escape key to close modal
    SeleniumLibrary.Choose File    xpath=//input[@id='file']    ${IMAGE_PATH}

    Wait until element is ready then click element   xpath=//button[@type='submit']
    # click escape key to close modal
    # Sleep    1.5s
    Alert Should Be Present    timeout=20s
    # SeleniumLibrary.Handle Alert    ACCEPT     
    #  Alert Should Be Present มัน Accept ให้เลย ไม่ต้องไปใช้คำสั่ง Accept เพิ่ม
    Log To Console    message=First Alert pass
    Wait Until Element Is Visible    xpath://label[normalize-space()='Amount']

    click escape key to close modal
    Wait until element is ready then click element    xpath://button[normalize-space()='confirm']
    # Sleep    1.5s
    Alert Should Be Present    timeout=20s
    # SeleniumLibrary.Handle Alert    ACCEPT
     Log To Console    message=Secound Alert pass
    
    sleep    1s
    Close Window
    SeleniumLibrary.Switch Window    MAIN    timeout=10s
    # Check Success


Check Success
    Wait Until Element Is Visible    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=50s
    # Go To    ${BaseUrl}

	
Shopee Pay
    Scroll To Shopee
    Wait until element is ready then click element    xpath=//button[@id='shopeepay-radio']
    # Remove File    price_log.txt
    Scroll Element Into View        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]
    Sleep    2s
    Scroll To The Very Top
    Scroll Element Into View    class:payment-summary-header__title
    Capture
    Upload Image
    Check Success
    sleep    1s
    Check Payment Success

Shopee Pay02
    Wait until element is ready then click element    xpath=//button[@id='shopeepay-radio']
    Scroll Element Into View        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]
    Sleep    2s
    Scroll To The Very Top
    Capture
    Upload Image
    Check Success
    sleep    1s
    Check Payment Success

Shopee Pay2
    # Scroll Element Into View    xpath=//button[@id='shopeepay-radio']
    Scroll To Shopee
    Wait until element is ready then click element    xpath=//button[@id='shopeepay-radio']
    # Remove File    price_log.txt

    Scroll Element Into View        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]     
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[1]
    Sleep    2s
    Scroll To The Very Top
    Capture2
    Upload Image
    Check Success
    sleep    1s
    Check Payment Success

# installment    ขั้นต่ำ1000 ใช้ กสิกร
installment
    # Scroll Element Into View    xpath=//button[@id='installments-radio']
    Scroll To Installment
    Wait until element is ready then click element    xpath=//button[@id='installments-radio']
    # Remove File    price_log.txt
    Scroll Element Into View        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]


    ##
    Wait Until Element Is Visible    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    timeout=10s
    SeleniumLibrary.Select From List By Label    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    Kasikornbank Public Company Limited

    Wait until element is ready then click element    class:radio-but-name
    Wait until element is ready then click element    xpath=(//button[text()='ดำเนินการต่อ' or text()='Continue'])[2]

    Wait Until Element Is Visible    name=card_number    timeout=20s
    Input Text    name=card_number        4535017710535741

    Wait Until Element Is Visible    name=card_cvv    timeout=20s
    Input Text    name=card_cvv    184

    Wait Until Element Is Visible    css:select[name="card_month"]    timeout=20s
    Select From List By Label        css:select[name="card_month"]    05

    Wait Until Element Is Visible    name:card_year    timeout=20s
    Select From List By Label        name:card_year    2028

    Wait Until Element Is Visible    css:button[type="submit"]    timeout=30s
    Wait until element is ready then click element         css:button[type="submit"]

    Wait Until Element Is Visible    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=50s
    Check Payment Success

installment2
    Scroll To Installment
    Wait until element is ready then click element    xpath=//button[@id='installments-radio']
    Scroll Element Into View        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[1]
    ##
    Wait Until Element Is Visible    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    timeout=10s
    SeleniumLibrary.Select From List By Label    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    Kasikornbank Public Company Limited

    Wait until element is ready then click element    class:radio-but-name
    Wait until element is ready then click element    xpath=(//button[text()='ดำเนินการต่อ' or text()='Continue'])[1]
    Wait Until Element Is Visible    name=card_number    timeout=20s
    Input Text    name=card_number        4535017710535741

    Wait Until Element Is Visible    name=card_cvv    timeout=20s
    Input Text    name=card_cvv    184

    Wait Until Element Is Visible    css:select[name="card_month"]    timeout=20s
    Select From List By Label        css:select[name="card_month"]    05

    Wait Until Element Is Visible    name:card_year    timeout=20s
    Select From List By Label        name:card_year    2028

    Wait Until Element Is Visible    css:button[type="submit"]    timeout=30s
    Wait until element is ready then click element         css:button[type="submit"]

    Wait Until Element Is Visible    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=50s
    Check Payment Success

installment02
    Wait until element is ready then click element    xpath=//button[@id='installments-radio']
    # Remove File    price_log.txt
    Scroll Element Into View        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]
    ##
    Wait Until Element Is Visible    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    timeout=10s
    SeleniumLibrary.Select From List By Label    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    Kasikornbank Public Company Limited

    Wait until element is ready then click element    class:radio-but-name
    Wait until element is ready then click element    xpath=(//button[text()='ดำเนินการต่อ' or text()='Continue'])[2]

    Wait Until Element Is Visible    name=card_number    timeout=20s
    Input Text    name=card_number        4535017710535741

    Wait Until Element Is Visible    name=card_cvv    timeout=20s
    Input Text    name=card_cvv    184

    Wait Until Element Is Visible    css:select[name="card_month"]    timeout=20s
    Select From List By Label        css:select[name="card_month"]    05

    Wait Until Element Is Visible    name:card_year    timeout=20s
    Select From List By Label        name:card_year    2028

    Wait Until Element Is Visible    css:button[type="submit"]    timeout=30s
    Wait until element is ready then click element         css:button[type="submit"]

    Wait Until Element Is Visible    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=50s
    Check Payment Success

    # Scroll Element Into View    xpath=//button[@id='installments-radio']
    Scroll To Installment
    Wait until element is ready then click element    xpath=//button[@id='installments-radio']
    Scroll Element Into View        xpath=//div[contains(@class, 'payment-summary-total')]
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[1]


    ##
    Wait Until Element Is Visible    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    timeout=10s
    SeleniumLibrary.Select From List By Label    css:div > div.sc-94c577d4-0 > select.sc-94c577d4-1    Kasikornbank Public Company Limited

    Wait until element is ready then click element    class:radio-but-name
    Wait until element is ready then click element    xpath=(//button[text()='ดำเนินการต่อ' or text()='Continue'])[1]
    Wait Until Element Is Visible    name=card_number    timeout=20s
    Input Text    name=card_number        4535017710535741

    Wait Until Element Is Visible    name=card_cvv    timeout=20s
    Input Text    name=card_cvv    184

    Wait Until Element Is Visible    css:select[name="card_month"]    timeout=20s
    Select From List By Label        css:select[name="card_month"]    05

    Wait Until Element Is Visible    name:card_year    timeout=20s
    Select From List By Label        name:card_year    2028

    Wait Until Element Is Visible    css:button[type="submit"]    timeout=30s
    Wait until element is ready then click element         css:button[type="submit"]

    Wait Until Element Is Visible    xpath://p[normalize-space()='ชำระเงินสำเร็จ' or normalize-space()='Payment Successful']    timeout=50s
    Check Payment Success
#
# ==========================================
#######  ส่วน Keyword Buyexpired Ticket  ####
# ==========================================



Scroll To PromptPay
    ${xpath}=    Set Variable    //button[@id='prompt-pay-radio']
    
    # ใช้ JavaScript เลื่อนให้อยู่ตรงกลางจอ (block: "center")
    Execute Javascript    document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView({block: "center", inline: "nearest"});
    
    # 💡 ทริค: ควรให้หุ่นยนต์หยุดรออนิเมชันการเลื่อนจอแป๊บนึง ก่อนสั่งคลิก
    Sleep    1s
    Click Element    ${xpath}

Scroll To Shopee
    ${xpath}=    Set Variable    //button[@id='shopeepay-radio']
    
    # ใช้ JavaScript เลื่อนให้อยู่ตรงกลางจอ (block: "center")
    Execute Javascript    document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView({block: "center", inline: "nearest"});
    
    # 💡 ทริค: ควรให้หุ่นยนต์หยุดรออนิเมชันการเลื่อนจอแป๊บนึง ก่อนสั่งคลิก
    Sleep    1s 
    Click Element    ${xpath}

Scroll To Installment
    ${xpath}=    Set Variable    //button[@id='installments-radio']
    
    # ใช้ JavaScript เลื่อนให้อยู่ตรงกลางจอ (block: "center")
    Execute Javascript    document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView({block: "center", inline: "nearest"});
    
    # 💡 ทริค: ควรให้หุ่นยนต์หยุดรออนิเมชันการเลื่อนจอแป๊บนึง ก่อนสั่งคลิก
    Sleep    1s
    Click Element    ${xpath}



GB Pay Expired
    Scroll To PromptPay
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]

    Click Visible Next Button
    Capture 
    Sleep    10m
    Wait Until Element Is Visible    xpath://p[normalize-space()='Payment failed' or normalize-space()='การชำระเงินไม่สำเร็จ']           timeout=30s
    Upload Image
    Go To    https://eventpass-ticket-uat.eventpass.biz/history
    sleep     5s
    refresh page
    Wait until element is ready then click element    xpath=(//div[normalize-space()='Completed' or normalize-space()='สำเร็จ'])[2]
    ${file_content}=    Get File    price_log.txt
    
    # 2. แตกข้อความที่อ่านมาได้แยกเป็นบรรทัดๆ แล้วนำไปใส่ใน List
    @{ALL_EXPECTED_PRICES}=    Split To Lines    ${file_content}
    ${found_count}=    Set Variable    0

    FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
        Continue For Loop If    '${price}' == '${EMPTY}'
        
        # 2. ค้นหาราคาบนหน้าเว็บ (timeout 2s เพื่อความรวดเร็ว)
        ${status}=    Run Keyword And Return Status    Wait Until Page Contains    ${price}    timeout=2s
        
        # 3. ถ้าเจอราคานี้บนหน้าจอ ให้บวกแต้มสะสมเพิ่ม 1
        IF    ${status}
            ${found_count}=    Evaluate    ${found_count} + 1
            Log To Console    ✅ ตรวจพบตัวที่ ${found_count}: ${price}
            
            # 4. เช็คว่าถ้าหาเจอครบ 2 ตัวแล้ว ให้กระโดดออกจาก Loop ทันที (ไม่ต้องเสียเวลาหาตัวที่เหลือ)
            IF    ${found_count} >= 2
                Log To Console    ตรวจพบครบทั้ง ราคาและวันที่
                Exit For Loop
            END
        END
    END
    # 5. สรุปผลนอกลูป: เช็คว่าคะแนนสะสมที่ได้ มีค่ามากกว่าหรือเท่ากับ 2 จริงหรือไม่
    ${is_passed}=    Evaluate    ${found_count} >= 2
    Should Be True    ${is_passed}    msg=❌ พัง! พบราคาบนหน้าเว็บเพียง ${found_count} รายการ (ต้องการอย่างน้อย 2 รายการ)
    # 5. สรุปผลตอนจบ: เช็คว่าคะแนนที่นับได้ มีค่ามากกว่าหรือเท่ากับ 2 หรือไม่ (ถ้าไม่ถึง 2 ให้แจ้ง Error)
    Should Be True    ${found_count} >= 2    msg=❌ พัง! ตรวจพบข้อความบนหน้าเว็บเพียง ${found_count} รายการ (ต้องการอย่างน้อย 2 รายการ)


Cancel order Zone
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    # Remove File    price_log.txt
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Click Visible Next Button
    Capture2
    # Sleep    1s
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath://button[normalize-space()='Cancel Order' or normalize-space()='ยกเลิกคำสั่งซื้อ']
    Wait until element is ready then click element    xpath://button[normalize-space()='Cancel' or normalize-space()='ยกเลิก']
    
    Upload Image
    Go To    https://eventpass-ticket-uat.eventpass.biz/history
    sleep     10s
    refresh page
    Wait until element is ready then click element    xpath=(//div[normalize-space()='Cancelled' or normalize-space()='ยกเลิกแล้ว'])[2]
    # commonkeywords.Verify Total Price Number    xpath://div[@class='d-flex flex-column gap-4']    ${TOTAL_PRICE}
    ${file_content}=    Get File    price_log.txt
    
    # 2. แตกข้อความที่อ่านมาได้แยกเป็นบรรทัดๆ แล้วนำไปใส่ใน List
    @{ALL_EXPECTED_PRICES}=    Split To Lines    ${file_content}
    
    # 3. วนลูปตรวจสอบข้อมูลบนหน้าเว็บ
    # FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
    #     # ดักไว้เผื่อไฟล์มีบรรทัดว่างตอนท้าย จะได้ไม่ Error
    #     Continue For Loop If    '${price}' == '${EMPTY}'
        
    #     # หุ่นยนต์จะค้นหาข้อความนี้ทั้งหน้าเว็บ ถ้าภายใน 5 วินาทีหาไม่เจอจะแจ้ง Error
    #     Run Keyword And Continue On Failure    Wait Until Page Contains    ${price}    timeout=10s
    # END

# 1. สร้างตัวแปรธง (Flag) ตั้งค่าเริ่มต้นว่า "ยังหาไม่เจอ" (False)
   # 1. สร้างตัวแปรเก็บคะแนน (จำนวนที่หาเจอ) เริ่มต้นที่ 0
    ${found_count}=    Set Variable    0

    FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
        Continue For Loop If    '${price}' == '${EMPTY}'
        
        # 2. ค้นหาราคาบนหน้าเว็บ (timeout 2s เพื่อความรวดเร็ว)
        ${status}=    Run Keyword And Return Status    Wait Until Page Contains    ${price}    timeout=2s
        
        # 3. ถ้าเจอราคานี้บนหน้าจอ ให้บวกแต้มสะสมเพิ่ม 1
        IF    ${status}
            ${found_count}=    Evaluate    ${found_count} + 1
            Log To Console    ✅ ตรวจพบตัวที่ ${found_count}: ${price}
            
            # 4. เช็คว่าถ้าหาเจอครบ 2 ตัวแล้ว ให้กระโดดออกจาก Loop ทันที (ไม่ต้องเสียเวลาหาตัวที่เหลือ)
            IF    ${found_count} >= 2
                Log To Console    ตรวจพบครบทั้ง ราคาและวันที่
                Exit For Loop
            END
        END
    END
    
    # 5. สรุปผลนอกลูป: เช็คว่าคะแนนสะสมที่ได้ มีค่ามากกว่าหรือเท่ากับ 2 จริงหรือไม่
    ${is_passed}=    Evaluate    ${found_count} >= 2
    Should Be True    ${is_passed}    msg=❌ พัง! พบราคาบนหน้าเว็บเพียง ${found_count} รายการ (ต้องการอย่างน้อย 2 รายการ)




Cancel order
    Scroll To PromptPay
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Click Visible Next Button
    Capture 
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath://button[normalize-space()='Cancel Order' or normalize-space()='ยกเลิกคำสั่งซื้อ']
    Wait until element is ready then click element    xpath://button[normalize-space()='Cancel' or normalize-space()='ยกเลิก']
    Upload Image
    Go To    https://eventpass-ticket-uat.eventpass.biz/history
    sleep     10s
    refresh page
    Wait until element is ready then click element    xpath=(//div[normalize-space()='Cancelled' or normalize-space()='ยกเลิกแล้ว'])[2]

    ${file_content}=    Get File    price_log.txt
    
    # 2. แตกข้อความที่อ่านมาได้แยกเป็นบรรทัดๆ แล้วนำไปใส่ใน List
    @{ALL_EXPECTED_PRICES}=    Split To Lines    ${file_content}

    @{ALL_EXPECTED_PRICES}=    Remove Duplicates Ignore Spaces    ${ALL_EXPECTED_PRICES}

    ${found_count}=    Set Variable    0

    FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
        Continue For Loop If    '${price}' == '${EMPTY}'
        
        # 2. ค้นหาราคาบนหน้าเว็บ (timeout 2s เพื่อความรวดเร็ว)
        ${status}=    Run Keyword And Return Status    Wait Until Page Contains    ${price}    timeout=2s
        
        # 3. ถ้าเจอราคานี้บนหน้าจอ ให้บวกแต้มสะสมเพิ่ม 1
        IF    ${status}
            ${found_count}=    Evaluate    ${found_count} + 1
            Log To Console    ✅ ตรวจพบตัวที่ ${found_count}: ${price}
            
            # 4. เช็คว่าถ้าหาเจอครบ 2 ตัวแล้ว ให้กระโดดออกจาก Loop ทันที (ไม่ต้องเสียเวลาหาตัวที่เหลือ)
            IF    ${found_count} >= 4
                Log To Console    ตรวจพบครบทั้ง ราคาและวันที่
                Exit For Loop
            END
        END
    END
    
    # 5. สรุปผลนอกลูป: เช็คว่าคะแนนสะสมที่ได้ มีค่ามากกว่าหรือเท่ากับ 2 จริงหรือไม่
    ${is_passed}=    Evaluate    ${found_count} >= 4
    Should Be True    ${is_passed}    msg=❌ พัง! พบราคาบนหน้าเว็บเพียง ${found_count} รายการ (ต้องการอย่างน้อย 4 รายการ)


GB buy 2 sold 1 
    Scroll To PromptPay
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']
    # Remove File    price_log.txt
    commonkeywords.get price        xpath=//div[contains(@class, 'payment-summary-total')]
    Click Visible Next Button
    # Wait until element is ready then click element    xpath=(//button[text()='ถัดไป' or text()='Next'])[2]
    Capture 
    Sleep    10m
    Wait Until Element Is Visible    xpath://p[normalize-space()='Payment failed' or normalize-space()='การชำระเงินไม่สำเร็จ']           timeout=30s
    Sleep    1m
    Sleep    20s
    Upload Image
    Go To    https://eventpass-ticket-uat.eventpass.biz/history
    sleep     5s
    refresh page
    Wait until element is ready then click element    xpath=(//div[normalize-space()='สำเร็จ' or normalize-space()='Completed'])[2]
    # Wait until element is ready then click element    xpath=(//div[normalize-space()='Expired' or normalize-space()='หมดอายุ'])[2]
    # commonkeywords.Verify Total Price Number    xpath://div[@class='d-flex flex-column gap-4']    ${TOTAL_PRICE}
    ${file_content}=    Get File    price_log.txt
    
    # 2. แตกข้อความที่อ่านมาได้แยกเป็นบรรทัดๆ แล้วนำไปใส่ใน List
    @{ALL_EXPECTED_PRICES}=    Split To Lines    ${file_content}
    
    # 3. วนลูปตรวจสอบข้อมูลบนหน้าเว็บ
    FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
        # ดักไว้เผื่อไฟล์มีบรรทัดว่างตอนท้าย จะได้ไม่ Error
        Continue For Loop If    '${price}' == '${EMPTY}'
        
        # หุ่นยนต์จะค้นหาข้อความนี้ทั้งหน้าเว็บ ถ้าภายใน 5 วินาทีหาไม่เจอจะแจ้ง Error
        Run Keyword And Continue On Failure    Page Should Not Contain    ${price}
    END

# # 
# # 
# # 
# # 


Check Payment Success 
    Go To    https://eventpass-ticket-uat.eventpass.biz/history
    sleep     1s
    refresh page
    Wait until element is ready then click element    xpath=(//div[normalize-space()='สำเร็จ' or normalize-space()='Completed'])[2]
    Wait Until Element Is Visible        xpath=(//div[normalize-space()='สำเร็จ' or normalize-space()='Completed'])[2]
    # commonkeywords.Verify Total Price Number    xpath://div[@class='d-flex flex-column gap-4']    ${TOTAL_PRICE}


    ${file_content}=    Get File    price_log.txt
    
    # 2. แตกข้อความที่อ่านมาได้แยกเป็นบรรทัดๆ แล้วนำไปใส่ใน List
    @{ALL_EXPECTED_PRICES}=    Split To Lines    ${file_content}

    @{ALL_EXPECTED_PRICES}=    Remove Duplicates Ignore Spaces    ${ALL_EXPECTED_PRICES}

    # Remove Duplicates    ${ALL_EXPECTED_PRICES}


    ${found_count}=    Set Variable    0

    FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
        Continue For Loop If    '${price}' == '${EMPTY}'
        
        # 2. ค้นหาราคาบนหน้าเว็บ (timeout 2s เพื่อความรวดเร็ว)
        ${status}=    Run Keyword And Return Status    Wait Until Page Contains    ${price}    timeout=2s
        
        # 3. ถ้าเจอราคานี้บนหน้าจอ ให้บวกแต้มสะสมเพิ่ม 1
        IF    ${status}
            ${found_count}=    Evaluate    ${found_count} + 1
            Log To Console    ✅ ตรวจพบตัวที่ ${found_count}: ${price}
            
            # 4. เช็คว่าถ้าหาเจอครบ 2 ตัวแล้ว ให้กระโดดออกจาก Loop ทันที (ไม่ต้องเสียเวลาหาตัวที่เหลือ)
            IF    ${found_count} >= 4
                Log To Console    🎉 ตรวจพบครบ 4 รายการตามเงื่อนไขแล้ว! ข้ามการค้นหาที่เหลือ
                Exit For Loop
            END
        END
    END    
    
    # 5. สรุปผลนอกลูป: เช็คว่าคะแนนสะสมที่ได้ มีค่ามากกว่าหรือเท่ากับ 3 จริงหรือไม่
    ${is_passed}=    Evaluate    ${found_count} >= 4
    Should Be True    ${is_passed}    msg=❌ พัง! พบราคาบนหน้าเว็บเพียง ${found_count} รายการ (ต้องการอย่างน้อย 4 รายการ) เกิดจากราคาในหน้าการจอง/ชำระเงินแสดงไม่ตรงกับหน้า ชำระเงิน


flowtravelCheckTicket
    commonkeywords.get name    xpath=(//span[contains(@class,'invoice-no-underline')])[1]
    check Email
    # Wait until element is ready then click element    css:[id=":2d"]
    SeleniumLibrary.Wait Until Element Is Visible    xpath=(//div[@role='main']//tr[contains(@class, 'zA') and contains(., 'Eventpass Ticket')])[1]    timeout=40s
    refresh page
    # SeleniumLibrary.Click Element   css:[id=":2d"]
    SeleniumLibrary.Wait Until Element Is Visible    xpath=(//div[@role='main']//tr[contains(@class, 'zA') and contains(., 'Eventpass Ticket')])[1]    timeout=40s
    SeleniumLibrary.click element    xpath=(//div[@role='main']//tr[contains(@class, 'zA') and contains(., 'Eventpass Ticket')])[1]
    ${file_content}=    Get File    Ticket_name_log.txt

    @{EmailCheck}=    Split To Lines    ${file_content}

    # ลบข้อมูลซ้ำ
    Remove Duplicates Ignore Spaces    ${EmailCheck}
    # Remove Duplicates    ${EmailCheck}

    ${found_count}=    Set Variable    0

    # ดึงข้อความทั้งหมดจากหน้าเว็บ
    ${page_text}=    Get Text    xpath=//body

    # แปลงข้อความบนหน้าเว็บเป็นตัวเล็ก
    ${page_text_lower}=    Convert To Lower Case    ${page_text}

    FOR    ${TicketID}    IN    @{EmailCheck}

        Continue For Loop If    '${TicketID}' == '${EMPTY}'

        # แปลง TicketID ที่ต้องการหาเป็นตัวเล็ก
        ${ticket_lower}=    Convert To Lower Case    ${TicketID}

        # ค้นหาโดยไม่สนตัวเล็ก/ตัวใหญ่
        ${status}=    Run Keyword And Return Status
        ...    Should Contain
        ...    ${page_text_lower}
        ...    ${ticket_lower}

        IF    ${status}
            ${found_count}=    Evaluate    ${found_count} + 1
            Log To Console    ✅ ตรวจพบตัวที่ ${found_count}: ${TicketID}

            IF    ${found_count} >= 4
                Log To Console    🎉 ตรวจพบครบ 4 รายการตามเงื่อนไขแล้ว!
                Exit For Loop
            END
        END
    END


flowtravelCheckTicket(checkTRAVEL FORM)
    commonkeywords.get name    xpath=(//span[contains(@class,'invoice-no-underline')])[1]
    check Email
    # Wait until element is ready then click element    css:[id=":2d"]
    SeleniumLibrary.Wait Until Element Is Visible    xpath=(//div[@role='main']//tr[contains(@class, 'zA') and contains(., 'Eventpass Ticket')])[1]    timeout=40s
    refresh page
    # SeleniumLibrary.Click Element   css:[id=":2d"]
    SeleniumLibrary.Wait Until Element Is Visible    xpath=(//div[@role='main']//tr[contains(@class, 'zA') and contains(., 'Eventpass Ticket')])[1]    timeout=40s
    SeleniumLibrary.click element    xpath=(//div[@role='main']//tr[contains(@class, 'zA') and contains(., 'Eventpass Ticket')])[1]
    ${file_content}=    Get File    Ticket_name_log.txt

    @{ALL_EXPECTED_PRICES}=    Split To Lines    ${file_content}
        ${found_count}=    Set Variable    0
        FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
            Continue For Loop If    '${price}' == '${EMPTY}'
            ${status}=    Run Keyword And Return Status    Wait Until Page Contains    ${price}    timeout=2s
            IF    ${status}
                ${found_count}=    Evaluate    ${found_count} + 1
                Log To Console    ✅ ตรวจพบตัวที่ ${found_count}: ${price}
                IF    ${found_count} >= 2
                    Log To Console    🎉 ตรวจพบครบ 2 รายการตามเงื่อนไขแล้ว! ข้ามการค้นหาที่เหลือ
                    Exit For Loop
                END
            END
        END   

    Go To     https://eventpass-ticket-cms-uat.eventpass.biz/travel
    ${file_content}=    Get File    Ticket_name_log.txt

    @{ticket_names}=    Split To Lines    ${file_content}

    # ลบค่าซ้ำ
    Remove Duplicates Ignore Spaces    ${ticket_names}
    # Remove Duplicates    ${ticket_names}

    ${found_count}=    Set Variable    0

    FOR    ${ticket_name}    IN    @{ticket_names}

        Continue For Loop If    '${ticket_name}' == '${EMPTY}'

        # ตรวจสอบ Ticket Name บนหน้าเว็บ
        ${status}=    Run Keyword And Return Status
        ...    Wait Until Page Contains    ${ticket_name}    timeout=5s

        IF    ${status}
            ${found_count}=    Evaluate    ${found_count} + 1
            Log To Console    ✅ พบ ${found_count}: ${ticket_name}

            IF    ${found_count} >= 7
                Log To Console    🎉 พบ Ticket Name ครบ 7 รายการ
                Exit For Loop
            END
        ELSE
            Log To Console    ❌ ไม่พบ: ${ticket_name}
        END

    END

    Should Be True
    ...    ${found_count} >= 7
    ...    ไม่พบ Ticket Name ครบ 7 รายการ พบเพียง ${found_count} รายการ

check Email
    #เปิด Email
    Go To    https://mail.google.com
    # 2. รอให้ส่วนกล่องข้อความหลัก (Inbox) โหลดขึ้นมาจนเสร็จ
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//div[@role='main']    timeout=15s
   

CheckTicket
    Sleep    2s
    


CheckTicket fullscreen
    Go To    https://eventpass-ticket-uat.eventpass.biz/mytickets
    sleep     2s
    refresh page
    ${file_content}=    Get File    price_log.txt
    
    # 2. แตกข้อความที่อ่านมาได้แยกเป็นบรรทัดๆ แล้วนำไปใส่ใน List
    @{ALL_EXPECTED_PRICES}=    Split To Lines    ${file_content}
    ${found_count}=    Set Variable    0

    FOR    ${price}    IN    @{ALL_EXPECTED_PRICES}
        Continue For Loop If    '${price}' == '${EMPTY}'

        ${status}=    Run Keyword And Return Status
        ...    Wait Until Page Contains
        ...    ${price}
        ...    timeout=2s

        IF    ${status}
            Log To Console    ✅ พบบัตรแล้ว: ${price}
            RETURN
        END
    END
    Fail    ไม่พบบัตรใด ๆ จากรายการในไฟล์
# ตรวจที่เป็นชื่อ seat เช่่น  H20 ที่เก็บจอนจ่ายเงืน






Click Visible Next Button
    # 1. ดึงปุ่มทั้งหมดที่เข้าเงื่อนไขมาเก็บไว้
    @{buttons}=    Get WebElements    xpath=//button[text()='ถัดไป' or text()='Next']
    
    # 2. วนลูปเช็คทีละปุ่ม
    FOR    ${btn}    IN    @{buttons}
        # เช็คว่าปุ่มนี้มองเห็นได้บนหน้าจอหรือไม่ (ไม่ถูกซ่อนไว้)
        ${is_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${btn}
        
        # 3. ถ้าเจอปุ่มที่มองเห็นได้ ให้กด แล้วหยุดลูปทันที
        IF    ${is_visible}
            Click Element    ${btn}
            Exit For Loop
        END
    END

# ==========================================
# 🌟 ส่วนที่ 3: Master Keyword สำหรับ Data-Driven
# ==========================================
Set Barrier Mode
    [Documentation]    เปิดการรอ (barrier) เฉพาะตอนรันด้วย pabot ครบ 4 processes และไม่ใช่เคส Zone (Zone ใช้ port เดียวกันทั้งหมด จึงห้ามรอกัน)
    [Arguments]    ${ticket_type}
    ${procs}=    Get Variable Value    ${PABOTNUMBEROFPROCESSES}    0
    ${is_zone}=    Evaluate    str($ticket_type).strip().lower().startswith('zone')
    ${enabled}=    Evaluate    int($procs) == 4 and not $is_zone
    Set Test Variable    ${BARRIER_ENABLED}    ${enabled}

Wait For All Parallel Tests
    [Documentation]    รอให้จ่ายเงินเสร็จครบทีละ 4 เคส (4, 8, 12, ...) แล้วค่อยไปต่อ (กันค้างตลอดไปด้วย timeout)
    [Arguments]    ${group_size}=4    ${timeout}=10 min
    ${enabled}=    Get Variable Value    ${BARRIER_ENABLED}    ${False}
    IF    not ${enabled}    RETURN
    ${count}=    Register Barrier Arrival
    # เคสลำดับที่ 1-4 รอให้ครบ 4, ลำดับที่ 5-8 รอให้ครบ 8, ... (รอเป็นรอบละ ${group_size} เคส)
    ${target}=    Evaluate    ((${count} - 1) // int(${group_size}) + 1) * int(${group_size})
    Log To Console    paid ${count} - waiting until ${target} tests have paid
    Wait Until Keyword Succeeds    ${timeout}    2s    All Parallel Tests Paid    ${target}

Register Barrier Arrival
    [Documentation]    นับเคสนี้เข้า barrier 1 ครั้ง (ครั้งเดียวต่อเทสเคส) แล้วคืนลำดับของเคส
    ${arrived}=    Get Variable Value    ${BARRIER_ARRIVED}    ${False}
    IF    ${arrived}    RETURN    ${BARRIER_COUNT}
    Acquire Lock    paid_barrier
    ${st}    ${count}=    Run Keyword And Ignore Error    Get Parallel Value For Key    paid_count
    ${count}=    Set Variable If    '${st}' == 'FAIL' or '${count}' == '${EMPTY}'    0    ${count}
    ${count}=    Evaluate    int(${count}) + 1
    Set Parallel Value For Key    paid_count    ${count}
    Release Lock    paid_barrier
    Set Test Variable    ${BARRIER_ARRIVED}    ${True}
    Set Test Variable    ${BARRIER_COUNT}    ${count}
    RETURN    ${count}

Count Failed Test In Barrier
    [Documentation]    เรียกใน Test Teardown: ถ้าเคสนี้ fail ก่อนถึงจุดรอ ให้นับเข้า barrier เพื่อไม่ให้เคสอื่นรอค้าง
    ${enabled}=    Get Variable Value    ${BARRIER_ENABLED}    ${False}
    ${arrived}=    Get Variable Value    ${BARRIER_ARRIVED}    ${False}
    IF    ${enabled} and not ${arrived}
        Run Keyword And Ignore Error    Register Barrier Arrival
    END

All Parallel Tests Paid

    [Arguments]    ${target}
    ${count}=    Get Parallel Value For Key    paid_count
    Should Be True    int(${count}) >= int(${target})


Buy Ticket Flow Data Driven    
    [Arguments]    ${ticket_type}    ${Payment}    ${TicketCheck}     
    
    # 1. เช็คว่าเทสต์เคสส่งคำว่าอะไรมา แล้วให้ไปเรียกใช้สเต็ปกดบัตรนั้นๆ
    Run Keyword If    '${ticket_type}' == 'Basic'      Select Basic Ticket
    Run Keyword If    '${ticket_type}' == 'Basic1'      Select Basic Ticket1
    Run Keyword If    '${ticket_type}' == 'Basic 2ticket'    Select 2 Basic Ticket
    Run Keyword If    '${ticket_type}' == '1 Basic last'    1 Basic last
    Run Keyword If    '${ticket_type}' == 'Basic 2 left'   Basic 2 left
    Run Keyword If    '${ticket_type}' == 'Basic2'   Basic2


    Run Keyword If    '${ticket_type}' == 'Booknow'    Select Booknow Ticket
    Run Keyword If    '${ticket_type}' == 'Booknow1'    Select Booknow Ticket1
    Run Keyword If    '${ticket_type}' == 'Booknow2'    Select Booknow Ticket2
    Run Keyword If    '${ticket_type}' == 'Booknow last'    Booknow last
    Run Keyword If    '${ticket_type}' == 'Booknow 2 left'   Booknow 2 left


    Run Keyword If    '${ticket_type}' == 'Buffet'     Select Buffet Ticket
    Run Keyword If    '${ticket_type}' == 'Buffet1'     Select Buffet Ticket1
    Run Keyword If    '${ticket_type}' == 'Buffet last'     Select Buffet Ticket last
    Run Keyword If    '${ticket_type}' == 'Buffet 2 left'     Select Buffet 2 left



    Run Keyword If    '${ticket_type}' == 'Choose a round'   Select Choose a round Ticket 
    Run Keyword If    '${ticket_type}' == 'Choose a round1'   Select Choose a round Ticket1
    Run Keyword If    '${ticket_type}' == 'Choose a round2'   Select Choose a round Ticket2 
    Run Keyword If    '${ticket_type}' == 'Choose a round last'   Select Choose a round Ticket last 
    Run Keyword If    '${ticket_type}' == 'Choose a round 2 left'   Select Choose a round 2 left
    
    


    Run Keyword If    '${ticket_type}' == 'Get Link'   Select GetLink Ticket
    Run Keyword If    '${ticket_type}' == 'Get Link1'   Select GetLink Ticket1
    Run Keyword If    '${ticket_type}' == 'Get Link2'   Select GetLink Ticket2
    Run Keyword If    '${ticket_type}' == 'Get Link last'   Select GetLink Ticket last


    Run Keyword If    '${ticket_type}' == 'Zone seat'    Select Zone Seat
    Run Keyword If    '${ticket_type}' == 'Zone seat(2)'    Select Zone Seat(2)
    Run Keyword If    '${ticket_type}' == 'Zone table'    Select Zone table 


    IF    '${ticket_type}' == 'flowtravel'
        Select flowtravel
        getname(flowtravel)
    END

    IF    '${ticket_type}' == 'flowtravel1'
        Select flowtravel1
        getname(flowtravel)
    END


    IF    '${ticket_type}' == 'flowtravel4'
        Select flowtravel4
        getname(flowtravel)
    END

    Run Keyword If    '${ticket_type}' != 'flowtravel'      getname(normal)


    # 2. หลังจากกดบัตรเสร็จ ให้วิ่งเข้าสู่กระบวนการจ่ายเงิน

    Run Keyword If    '${Payment}' =='Credit card'    Process Credit card pay
    Run Keyword If    '${Payment}' =='Credit card2'    Process Credit card pay2
    
    Run Keyword If    '${Payment}' =='QR'    QR Pay
    Run Keyword If    '${Payment}' =='QR02'    QR Pay02
    Run Keyword If    '${Payment}' =='QR2'    QR Pay2

    Run Keyword If    '${Payment}' =='Shopee Pay'    Shopee Pay
    Run Keyword If    '${Payment}' =='Shopee Pay02'    Shopee Pay02 
    Run Keyword If    '${Payment}' =='Shopee Pay2'    Shopee Pay2 

    Run Keyword If    '${Payment}' =='installment'    Installment
    Run Keyword If    '${Payment}' =='installment2'    Installment2
    Run Keyword If    '${Payment}' =='installment02'    Installment02

    Run Keyword If    '${Payment}' =='GB Pay Expired'    GB Pay Expired

    Run Keyword If    '${Payment}' =='Cancel order'    Cancel order

    Run Keyword If    '${Payment}' == 'Cancel order Zone'    Cancel order Zone   


    # รอให้จ่ายเงินเสร็จครบทีละ 4 เคสก่อน ค่อยไปเช็คบัตร
    Wait For All Parallel Tests    4

#####  ส่วนเช็คบัตร ####
    Run Keyword If    '${TicketCheck}' == 'flowtravel'    flowtravelCheckTicket
    Run Keyword If    '${TicketCheck}' == 'flowtravel4'    flowtravelCheckTicket(checkTRAVEL FORM)
    Run Keyword If    '${TicketCheck}' == 'normal'    CheckTicket
    Run Keyword If    '${TicketCheck}' == 'normal fullscreen'    CheckTicket fullscreen
    





