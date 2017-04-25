var webdriver = require('selenium-webdriver');

var capabilities = {
//    'browserName': 'firefox',
    'browserName': 'chrome',
    'browserstack.user': 'jyothinmadari2',
    'browserstack.key': 'o1GdnpBqayUfVqWYSpNd'
}

var driver = new webdriver.Builder().
    usingServer('http://hub-cloud.browserstack.com/wd/hub').
    withCapabilities(capabilities).
    build();

driver.get('http://www.google.com');
driver.findElement(webdriver.By.name('q')).sendKeys('BrowserStack');
driver.findElement(webdriver.By.name('btnG')).click();

driver.getTitle().then(function (title) {
    console.log(title);
});

driver.quit();
