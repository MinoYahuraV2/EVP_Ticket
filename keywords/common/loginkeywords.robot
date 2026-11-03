*** Settings ***
# Library    SeleniumLibrary
Resource    ../common/commonkeywords.robot
Variables    ../../resources/config.yaml    

*** Keywords ***
Click Login On Navbar
    Wait until element is ready then click element with javascript    xpath=//span[text()='เข้าสู่ระบบ']


Click Continue With Google
    Wait until element is ready then click element with javascript    xpath=//button[contains(@class, 'model__card') and .//span[text()='ดำเนินการต่อด้วย Google']]

user login to website with ${username} and ${password}
    Wait until element is ready then input text    id=identifierId    ${username}
    Wait until element is ready then click element    xpath=//span[text()='ถัดไป' or text()='Next']
    Wait until element is ready then input text    name=Passwd    ${password}
    Wait until element is ready then click element    xpath=//span[text()='ถัดไป' or text()='Next']
    Wait Until Location Contains    ${BaseUrl}
    # ยอมรับคุกกี้
    Wait until element is ready then click element    xpath://div[normalize-space()='ยอมรับ']

