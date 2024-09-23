*** Settings ***
#Library  SeleniumLibrary
Library  RPA.Browser.Selenium
#Library    ../venv/lib/python3.11/site-packages/robot/libraries/XML.py
Library             RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587
Library    Collections
Library    RPA.Robocorp.Vault

*** Variables ***
${browser}      firefox
${ENV}    CLOUD    # LOCAL or CLOUD


*** Test Cases ***
CheckPriceMirror
    ${item}=    Set Variable    Mirror
    ${url}=           Set Variable    https://www.potterybarn.com/products/markle-antiqued-panel-mirror/
    ${baseprice}=     Set Variable    399

    Run Keyword If    '${ENV}' == 'LOCAL'      
    ...                Open Browser    ${url}    ${browser}
    ...    ELSE IF    '${ENV}' == 'CLOUD'
    ...                Open Available Browser    ${url}    browser_selection=${browser}    headless=True
    
    MinimizePopup
    Sleep    1
    SelectSize
    Sleep    1
    ${currentprice}=        Get Text        //div[@data-test-id='desktop-product-details']//li[@class='product-price']    
    Log    The current price is ${currentprice}
    ${currentprice}=        Evaluate    int(${currentprice}[1:])
    Set Test Variable    ${currentprice}     ${currentprice}
    Log    The current price as an integer is now ${currentprice}
    IF    ${currentprice} <= ${baseprice}
        PriceDropped
        SendEmail     ${item}    ${url}    ${baseprice}    ${currentprice}
    END
    Close Browser

CheckPriceMonitor
    ${item}=    Set Variable    Monitor
    ${url}=           Set Variable    https://www.dell.com/en-us/shop/dell-ultrasharp-40-curved-thunderbolt-hub-monitor-u4025qw/apd/210-bmdp/monitors-monitor-accessories
    ${baseprice}=     Set Variable    1919.99

    Run Keyword If    '${ENV}' == 'LOCAL'      
    ...                Open Browser    ${url}    ${browser}
    ...    ELSE IF    '${ENV}' == 'CLOUD'
    ...                Open Available Browser    ${url}    browser_selection=${browser}    headless=True

    ${currentprice}=        Get Text        //div[@data-testid='sharedPSPDellPrice']   
    ${float_price}=      Evaluate    float('${currentprice}'.replace("$", "").replace(",", ""))
    
    IF    ${float_price} <= ${baseprice}
        PriceDropped
        SendEmail     ${item}    ${url}    ${baseprice}    ${currentprice}
    END
    Close Browser

*** Keywords ***
MinimizePopup
    #Click Element    xpath=//div[@class='email-campaign-wrapper joinEmailList']//a[@title='Minimize']
    Wait Until Element Is Visible    alias:close_popup    timeout=1
    Click Element    alias:close_popup
SelectSize
    Click Element    xpath=//span[normalize-space()='30.5" x 30.5"']
PriceDropped
    Log    PRICE DROPPED!!!
SendEmail
    [Arguments]    ${item}    ${url}    ${baseprice}    ${currentprice}
    ${secret}=    Get Secret        gmail
    Authorize    account=${secret}[USERNAME]    password=${secret}[PASSWORD]
    Send Message    sender=${secret}[USERNAME]
    ...    recipients=${secret}[DESTINATION]
    ...    subject=Update: Price of the ${item} is $${currentprice}
    ...    body=The ${item} at ${url} which is normally priced at $${baseprice} is currently $${currentprice}!!!

