*** Settings ***
Library         SeleniumLibrary               
Library         RPA.Desktop
Resource        ../common/commonkeywords.robot
Variables       ../../resources/config.yaml   

*** Keywords ***

# ==========================================
# ส่วนที่ 1: ขั้นตอนการเลือกบัตร (แยกตามประเภท)
# ==========================================
Select Basic Ticket
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep    1s

Select Basic Ticket2
    Scroll To The Very Bottom
    Sleep    1s
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    waiting for elements    xpath=(//div[text()='1'])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s


Select Booknow Ticket
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//button[text()='Book Now'])[3]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[4]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    1s
    
Select Booknow Ticket2
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=(//button[text()='Book Now'])[1]
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[1]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep    1s
    

Select Buffet Ticket
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s

Select Choose a round Ticket
    Scroll To The Very Bottom
    Scroll To The Very Bottom
    Wait until element is ready then click element    xpath=//i[contains(@class, 'fa fa-plus')]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[1]
    Sleep    1s

#ตั๋ว get link
Select GetLink Ticket
    Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div[2]/div[1]/div/div[2]/div[2]/button
    sleep    2s
    Wait until element is ready then click element    xpath=(//i[contains(@class, 'fa fa-plus')])[2]
    waiting for elements    xpath=(//div[text()='1'])[3]
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[3]
    Sleep    1s

# Select zone table choose a round
#     Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div/div[2]/div[2]/div/div[2]/button
#     Sleep    3s 
#     # 4. สั่งหารูป B1 Zone บนหน้าจอ แล้วคลิกตรงกลางรูปนั้นทันที!
#     RPA.Desktop.Click    image:../images/B1Zone.png
#     Wait until element is ready then click element    xpath:(//label/div/div)[1]
#     Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[3]/div/div[2]/div/div/div[2]/div[3]/button
#     Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div[2]/div[2]/div[2]/div[1]/button

# Select zone seat choose a round
#     Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[2]/div/div/div/div[2]/div[2]/div/div[2]/button
#     Sleep    3s 
#     # 4. สั่งหารูป B1 Zone บนหน้าจอ แล้วคลิกตรงกลางรูปนั้นทันที!
#     RPA.Desktop.Click    image:../images/B1Zone.png
#     Wait until element is ready then click element    xpath:(//label/div/div)[1]
#     Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[3]/div/div[2]/div/div/div[2]/div[3]/button
#     Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div[2]/div[2]/div[2]/div[1]/button

Select Zone Seat
    Maximize Browser Window
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    3s
    RPA.Desktop.Wait For Element    image:../../images/B1.png    timeout=30
    RPA.Desktop.Click    image:../../images/B1.png
    Wait until element is ready then click element    xpath:(//label/div/div)[1]
    # Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[3]/div/div[2]/div/div/div[2]/div[3]/button
    Wait until element is ready then click element    xpath:(//button[text()='ชำระเงิน' or text()='Check Out'])
    Sleep    1s

Select Zone Seat2
    Maximize Browser Window
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    3s
    RPA.Desktop.Wait For Element    image:../../images/B1.png    timeout=30
    RPA.Desktop.Click    image:../../images/B1.png
    Wait until element is ready then click element    xpath:(//label/div/div)[1]
    Wait until element is ready then click element    xpath:(//label/div/div)[1]
    # Wait until element is ready then click element    xpath:/html/body/div[2]/div/div[3]/div/div/div[3]/div/div[2]/div/div/div[2]/div[3]/button
    Wait until element is ready then click element    xpath:(//button[text()='ชำระเงิน' or text()='Check Out'])
    Sleep    1s


Select Zone table 
    Maximize Browser Window
    Wait until element is ready then click element    xpath=(//button[text()='ซื้อบัตร' or text()='Buy Ticket'])[2]
    Sleep    3s
    RPA.Desktop.Wait For Element    image:../../images/B1.png    timeout=30
    RPA.Desktop.Click    image:../../images/B1.png
    Wait until element is ready then click element    xpath:(//label/div/div)[1]
    Wait until element is ready then click element    xpath:(//button[text()='ชำระเงิน' or text()='Check Out'])
    Sleep    1s




# ==========================================
# ส่วนที่ 2: เลือกรูปแบบบัตร
# ==========================================
#ส่วนรูปแบบบัตร
Select Digital Ticket
    Wait until element is ready then click element    css=[value='online']

Pick up at Event
    Wait until element is ready then click element    css=[value='onsite']

Ticket delivery
    Wait until element is ready then click element    css=[value='transport']
    Wait Until Element Is Visible                     css=[name='fullName']
    Input Text    css=[name='fullName']    Test name
    Wait Until Element Is Visible     css=[name='addressInfo']
    Input Text    css=[name='addressInfo']    Test Adress
    Input Text    xpath=(//input[@type='text'])[5]    10510  
    Sleep    1.5s
    click enter key to submit form

    Input Text    id=phoneNo-id    0633681842
    Scroll Element Into View    xpath=//button[@id='prompt-pay-radio']

# ==========================================
# ส่วนที่ 3: ขั้นตอนจ่ายเงิน (ใช้โค้ดชุดเดียวกันทั้งหมด)
# ==========================================
Process Credit card pay
    Scroll Element Into View    xpath=//button[@id='prompt-pay-radio']
    Wait until element is ready then click element    xpath=//button[@id="credit-radio"]

QR Pay
    Scroll Element Into View    xpath=//button[@id='shopeepay-radio']
    Wait until element is ready then click element    xpath=//button[@id='prompt-pay-radio']




Shopee Pay
    Scroll Element Into View    xpath:(//div[normalize-space()='แนะนำ' or normalize-space()='Advised'])[2]
    Wait until element is ready then click element    xpath=//button[@id='shopeepay-radio']
    
    ${element}=    Get WebElement    xpath=(//button[normalize-space()='ถัดไป' or normalize-space()='Next'])[1]
    Execute Javascript    arguments[0].scrollIntoView({block: 'center'})    ARGUMENTS    ${element}


Installment
    Scroll Element Into View    xpath:(//div[normalize-space()='แนะนำ' or normalize-space()='Advised'])[2]
    Wait until element is ready then click element    xpath=//button[@id='installments-radio']

Upload Slip
    Scroll Element Into View    xpath:(//div[normalize-space()='แนะนำ' or normalize-space()='Advised'])[2]
    Wait until element is ready then click element    xpath=//button[@id='upload-slip-radio']


Ticket Protect
    # Wait Until Element Is Visible    xpath://div[normalize-space()='Included Ticket Protect' or normalize-space()='เพิ่มประกันบัตร']
    # Scroll Element Into View    xpath://div[normalize-space()='Included Ticket Protect' or normalize-space()='เพิ่มประกันบัตร']
    # Wait until element is ready then click element    xpath://div[normalize-space()='Included Ticket Protect' or normalize-space()='เพิ่มประกันบัตร']
    Scroll Element Into View    xpath://div[normalize-space()='หมายเหตุ: เงื่อนไขการเคลมประกัน' or normalize-space()='Note: Insurance Claim Conditions']
    Wait until element is ready then click element      xpath:(//div[normalize-space()='แนะนำ' or normalize-space()='Advised'])[2]


    # ${element}=    Get WebElement    xpath=(//button[normalize-space()='ถัดไป' or normalize-space()='Next'])[1]
    # Execute Javascript    arguments[0].scrollIntoView({block: 'center'})    ARGUMENTS    ${element}

AUTO PROMO
    Wait Until Element Is Visible    xpath://div[normalize-space()='รหัสส่วนลด' or normalize-space()='Promotion Code']


Check final price ${TOTAL_PRICE}       
    Scroll Element Into View    xpath=//div[contains(@class, 'payment-summary-total')]
    Wait Until Element Is Visible     xpath=//div[contains(@class, 'payment-summary-total')]               timeout=20s
    # Scroll To The Very Bottom
    Sleep    1.5s
    commonkeywords.Verify Total Price Number    xpath=//div[contains(@class, 'payment-summary-total')]    ${TOTAL_PRICE} 
    Scroll Element Into View    xpath://button[normalize-space()='Cancel Order' or normalize-space()='ยกเลิกคำสั่งซื้อ']
    Wait Until Element Is Visible   xpath://button[normalize-space()='Cancel Order' or normalize-space()='ยกเลิกคำสั่งซื้อ']
    Wait until element is ready then click element with javascript   xpath://button[normalize-space()='Cancel Order' or normalize-space()='ยกเลิกคำสั่งซื้อ'] 
    # Click Element    xpath://button[normalize-space()='Cancel Order' or normalize-space()='ยกเลิกคำสั่งซื้อ'] x
    Wait Until Element Is Visible     xpath:(//button[normalize-space()='Cancel' or normalize-space()='ยกเลิก'])[1]
    Click Element    xpath:(//button[normalize-space()='Cancel' or normalize-space()='ยกเลิก'])[1]  
    sleep    1s


fill promo code ${PROMOTION_CODE}
     Wait Until Element Is Visible    id=input-promotion
     Wait until element is ready then input text    id=input-promotion    ${PROMOTION_CODE}
     ${element}=    Get WebElement    class:submit__promo
     Execute Javascript    arguments[0].scrollIntoView({block: 'center'})    ARGUMENTS    ${element}
     Wait until element is ready then click element    class:submit__promo 
     Wait Until Element Is Visible     xpath://div[normalize-space()='รหัสส่วนลด' or normalize-space()='Promotion Code' or normalize-space()='Discount Code']



Check Price Flow Data Driven    
    [Arguments]    ${ticket_type}    ${Ticket_Format}    ${Payment}    ${ticket_protect}    ${PROMOTION_CODE}    ${TOTAL_PRICE}
    
    # 1. เช็คว่าเทสต์เคสส่งคำว่าอะไรมา แล้วให้ไปเรียกใช้สเต็ปกดบัตรนั้นๆ
    Run Keyword If    '${ticket_type}' == 'Basic'      Select Basic Ticket
    Run Keyword If    '${ticket_type}' == 'Basic2'      Select Basic Ticket2
    Run Keyword If    '${ticket_type}' == 'Booknow'    Select Booknow Ticket
    Run Keyword If    '${ticket_type}' == 'Booknow2'    Select Booknow Ticket2
    Run Keyword If    '${ticket_type}' == 'Buffet'     Select Buffet Ticket
    Run Keyword If    '${ticket_type}' == 'Choose a round'   Select Choose a round Ticket 
    Run Keyword If    '${ticket_type}' == 'Get Link'   Select GetLink Ticket
    Run Keyword If    '${ticket_type}' == 'Zone seat'    Select Zone Seat
    Run Keyword If    '${ticket_type}' == 'Zone seat2'    Select Zone Seat2
    Run Keyword If    '${ticket_type}' == 'Zone table'    Select Zone table 


    # 2. เลือกเงื่อนไขการรับบัตร
    Run Keyword If    '${Ticket_Format}' == 'Digital Ticket'    Select Digital Ticket   
    Run Keyword If    '${Ticket_Format}' == 'Pick up at Event'    Pick up at Event   
    Run Keyword If    '${Ticket_Format}' == 'Ticket delivery'    Ticket delivery


    # 3. หลังจากกดบัตรเสร็จ ให้วิ่งเข้าสู่กระบวนการจ่ายเงิน
    Run Keyword If    '${Payment}' == 'Creditcard'    Process Credit card pay
    Run Keyword If    '${Payment}' == 'QR'            QR Pay 
    Run Keyword If    '${Payment}' == 'Shopee Pay'    Shopee Pay 
    Run Keyword If    '${Payment}' == 'installment'    Installment
    Run Keyword If    '${Payment}' == 'Upload Slip'    Upload Slip


    #ส่วนประกันบัตร
    Run Keyword If    "${ticket_protect}" != "${EMPTY}"    Ticket Protect 
    
    Run Keyword If    "${PROMOTION_CODE}" == "AUTO PROMO"    AUTO PROMO

    Run Keyword If    "${PROMOTION_CODE}" != "" and '${PROMOTION_CODE}' != 'AUTO PROMO'      fill promo code ${PROMOTION_CODE}

    Run Keyword If   '${TOTAL_PRICE}' != '${EMPTY}'     Check final price ${TOTAL_PRICE}
   
   
   
   