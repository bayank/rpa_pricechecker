from RPA.Browser.Selenium import Selenium
from RPA.Email.ImapSmtp import ImapSmtp
from robocorp.tasks import task
from robocorp import vault, log, browser
import time


browser = "firefox"
ENV = "CLOUD" # LOCAL or CLOUD
CHANGED = False
RESULTS = []

window = Selenium()

@task
def CheckPriceMirror():
    global CHANGED, RESULTS, ENV, browser
    item = "Mirror"
    url = "https://www.potterybarn.com/products/markle-antiqued-panel-mirror/"
    base_price = 399

    if ENV == "LOCAL":
        window.open_browser(url=url, browser=browser)
    elif ENV == "CLOUD":
        window.open_available_browser(url=url, browser_selection=browser, headless=True)

    # Close popup
    window.wait_until_element_is_visible(locator="alias:close_popup", timeout=1)
    window.click_element(locator="alias:close_popup")
    time.sleep(1)
    
    # Select 30.5 x 30.5 size
    window.click_element(locator="//span[normalize-space()='30.5\" x 30.5\"']")
    time.sleep(1)
    
    # Read the current price
    current_price = window.get_text(locator="//div[@data-test-id='desktop-product-details']//li[@class='product-price']")
    current_price = int(current_price[1:])
    log.info(f"Current price of {item}: {current_price}")

    if current_price != base_price:
        log.info("Price change detected!!")
        CHANGED = True
        RESULTS.append(f"{item}: PRICE CHANGED!!! Normally priced at ${base_price} is now ${current_price}!!! {url}")
    else:
        log.info("No price change detected")
        RESULTS.append(f"{item}: No change. Normally priced at ${base_price} is still ${current_price}. {url}")
    window.close_browser
    

@task
def CheckPriceMonitor():
    global CHANGED, RESULTS, ENV, browser
    item = "Dell U4025QW Monitor"
    url = "https://www.dell.com/en-us/shop/dell-ultrasharp-40-curved-thunderbolt-hub-monitor-u4025qw/apd/210-bmdp/monitors-monitor-accessories"
    base_price = 1919.99

    if ENV == "LOCAL":
        window.open_browser(url=url, browser=browser)
    elif ENV == "CLOUD":
        window.open_available_browser(url=url, browser_selection=browser, headless=True)

    current_price:str = window.get_text(locator="//div[@data-testid='sharedPSPDellPrice']")
    current_price = float(current_price.replace("$", "").replace(",", ""))
    log.info(f"Current price of {item}: {current_price}")

    if current_price != base_price:
        log.info("Price change detected!!")
        CHANGED = True
        RESULTS.append(f"{item}: PRICE CHANGED!!! Normally priced at ${base_price} is now ${current_price}!!! {url}")
    else:
        log.info("No price change detected")
        RESULTS.append(f"{item}: No change. Normally priced at ${base_price} is still ${current_price}. {url}")
    window.close_browser


@task
def send_mail():
    global RESULTS, CHANGED

    secret = vault.get_secret("gmail")
    GMAIL_ACCOUNT = secret["USERNAME"]
    GMAIL_PW = secret["PASSWORD"]
    DESTINATION = secret["DESTINATION"]

    if CHANGED == True:
        EMAIL_SUBJECT = "PRICE CHANGED!!! Price Checker Ran, Changes Detected!!!"
    else:
        EMAIL_SUBJECT = "Price Checker Ran, No Changes."

    EMAIL_BODY = ""
    for i, line in enumerate(RESULTS, start=1):
        EMAIL_BODY += f"{i}. {line}\n"

    mail = ImapSmtp(smtp_server="smtp.gmail.com", smtp_port=587)
    mail.authorize(account=GMAIL_ACCOUNT, password=GMAIL_PW)
    mail.send_message(
        sender=GMAIL_ACCOUNT,
        recipients=DESTINATION,
        subject=EMAIL_SUBJECT,
        body=EMAIL_BODY,
    )