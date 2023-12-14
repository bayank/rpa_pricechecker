*** Settings ***
#Library  SeleniumLibrary
Library  RPA.Browser.Selenium
#Library    ../venv/lib/python3.11/site-packages/robot/libraries/XML.py
Library             RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587
Library    RPA.Robocorp.Vault

*** Variables ***
${browser}      firefox
${url}      https://www.potterybarn.com/products/markle-antiqued-panel-mirror/
${baseprice}        399
${USERNAME}     0
${PASSWORD}     0
${RECIPIENT}    test@gmail.com


*** Test Cases ***
CheckPrice
    # IF RUNNING CLOUD USE "Open Available Browser"
    Open Available Browser  ${url}  browser_selection=${browser}  headless=True

    # IF RUNNING LOCAL USE "Open Browser" 
    #Open Browser  ${url}  ${browser}

    MinimizePopup
    Sleep    1
    SelectSize
    Sleep    1
    ${currentprice}=        Get Text        //div[@data-test-id='desktop-product-details']//li[@class='product-price']    
    Log    The current price is ${currentprice}
    ${currentprice}=        Evaluate    int(${currentprice}[1:])
    Set Suite Variable    ${currentprice}     ${currentprice}
    Log    The current price as an integer is now ${currentprice}
    IF    ${currentprice} < ${baseprice}
        PriceDropped
        SendEmail
    END
    Close Browser


*** Keywords ***
MinimizePopup
    #Click Element    xpath=//div[@class='email-campaign-wrapper joinEmailList']//a[@title='Minimize']
    Click Element    alias:close_popup
SelectSize
    Click Element    xpath=//span[normalize-space()='30.5" x 30.5"']
PriceDropped
    Log    PRICE DROPPED!!!
SendEmail
    ${secret}=    Get Secret        gmail
    Authorize    account=${secret}[USERNAME]    password=${secret}[PASSWORD]
    Send Message    sender=${USERNAME}
    ...    recipients=${RECIPIENT}
    ...    subject=Price of the mirror dropped to $${currentprice}
    ...    body=The 30.5 X 30.5 mirror at Pottery Barn at ${url} which is normally priced at $${baseprice} is now $${currentprice}!!!

