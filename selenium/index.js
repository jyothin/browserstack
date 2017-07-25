var webdriver = require('selenium-webdriver');

var capabilities = {
//    'browserName': 'firefox',
    'browserName': 'chrome',
    'browserstack.user': 'jyothinmadari2',
    'browserstack.key': 'o1GdnpBqayUfVqWYSpNd'

    'realMobile': 'true',
    'device': 'Samsung Galaxy Tab 4'
}

var driver = new webdriver.Builder().
    usingServer('http://hub-cloud.browserstack.com/wd/hub').
    withCapabilities(capabilities).
    build();

driver.get('http://www.google.com');
driver.findElement(webdriver.By.name('q')).sendKeys('BrowserStack');
driver.findElement(webdriver.By.name('btnG')).click();
sleep(10)
driver.get('http://example.com');
driver.

driver.getTitle().then(function (title) {
    console.log(title);
});

driver.quit();
