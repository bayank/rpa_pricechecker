*** Settings ***
#Library  SeleniumLibrary
Library  RPA.Browser.Selenium
#Library    ../venv/lib/python3.11/site-packages/robot/libraries/XML.py
Library             RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587
Library    RPA.Robocorp.Vault

*** Variables ***
${browser}      firefox
${ENV}    CLOUD    # LOCAL or CLOUD
${CHANGED}    False
${EMAIL_SUBJECT}    Price Checker Ran, No Changes.


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
    ${currentprice}=        Evaluate    int(${currentprice}[1:])
    Set Test Variable    ${currentprice}     ${currentprice}

    IF    ${currentprice} != ${baseprice}
        Log    Price change detected!!!
        PriceChanged
        Set Suite Variable    ${MIRROR_RESULT}    ${item}: PRICE CHANGED!!! Normally priced at $${baseprice} is now $${currentprice}!!! ${url}
    ELSE
        Log    No price change detected.
        Set Suite Variable    ${MIRROR_RESULT}    ${item}: No change. Normally priced at $${baseprice} is still $${currentprice}. ${url}
    END

    Close Browser
    EvalReport


CheckPriceMonitor
    ${item}=    Set Variable    Monitor
    ${url}=           Set Variable    https://www.dell.com/en-us/shop/dell-ultrasharp-40-curved-thunderbolt-hub-monitor-u4025qw/apd/210-bmdp/monitors-monitor-accessories
    ${baseprice}=     Set Variable    1919.99

    Run Keyword If    '${ENV}' == 'LOCAL'      
    ...                Open Browser    ${url}    ${browser}
    ...    ELSE IF    '${ENV}' == 'CLOUD'
    ...                Open Available Browser    ${url}    browser_selection=${browser}    headless=True

    ${currentprice}=        Get Text        //div[@data-testid='sharedPSPDellPrice']   
    ${currentprice}=      Evaluate    float('${currentprice}'.replace("$", "").replace(",", ""))
    
    IF    ${currentprice} != ${baseprice}
        Log    Price change detected!!!
        PriceChanged
        Set Suite Variable    ${MONITOR_RESULT}    ${item}: PRICE CHANGED!!! Normally priced at $${baseprice} is now $${currentprice}!!! ${url}
    ELSE
        Log    No price change detected.
        Set Suite Variable    ${MONITOR_RESULT}    ${item}: No change. Normally priced at $${baseprice} is still $${currentprice}. ${url}
    END

    Close Browser
    EvalReport

SendReport
    SendEmail

*** Keywords ***
MinimizePopup
    Wait Until Element Is Visible    alias:close_popup    timeout=1
    Click Element    alias:close_popup
SelectSize
    Click Element    xpath=//span[normalize-space()='30.5" x 30.5"']
PriceChanged
    Set Suite Variable    ${CHANGED}    True
    Log    PRICE CHANGED!!!
EvalReport
    IF    '${CHANGED}' == 'True'
        Set Suite Variable    ${EMAIL_SUBJECT}    PRICE CHANGED!!! Price Checker Ran, Changes Detected!!!
    END



SendEmail
    ${secret}=    Get Secret        gmail
    Authorize    account=${secret}[USERNAME]    password=${secret}[PASSWORD]
    Send Message    sender=${secret}[USERNAME]
    ...    recipients=${secret}[DESTINATION]
    ...    subject=${EMAIL_SUBJECT}
    ...    body=1. ${MIRROR_RESULT} \n2. ${MONITOR_RESULT}

