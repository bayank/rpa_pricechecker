# Robot Framework Automation in the Cloud

This is my attempt at automating Robot Framework RPA test cases on a cloud runner.

This stack uses Selenium Webdriver to control Firefox in headless mode, RobotFramework, Python, and cloud API's provided by Robocorp.

The purpose of this test suite in particular is to scrape webpages for data and send an email notification when a crieteria is met.

In this case, the robot is checking the price of a specific variant of the product, and will send an email notification when the price drops below the regular price.

With this implementation, the robot will execute once a day without any need to self-host the test runner locally. 

The bulk of the effort is contained in the tasks.robot file. The rest of the files pertain to the environment configuration where it will be deployed as a docker image.

## Learning materials

- [Robocorp Developer Training Courses](https://robocorp.com/docs/courses)
- [Documentation links on Robot Framework](https://robocorp.com/docs/languages-and-frameworks/robot-framework)
- [Example bots in Robocorp Portal](https://robocorp.com/portal)
