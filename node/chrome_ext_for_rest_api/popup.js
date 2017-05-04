var _options;
var _data = {};
var _type;
var _desktop;
var _mobile;

function onOsInput(event) {
  if (!event.target.value) {console.error("Please select a OS");}
  else {
    var browsers_devices = _type[event.target.value];
    var options = "";
    var browser_device = document.querySelector('select[name="browser-device"]');
    for (var i in browsers_devices) {
      if ( !("os" in browsers_devices[i]) ) {
        options += "<option value=\""+
          browsers_devices[i].display_name+"\">"+
          browsers_devices[i].display_name+
          "</option>"+
          "<br>";
      }
    }
    browser_device.innerHTML = options;
  }
}

function onTypeInput(event) {
  var type;
  if (!event.target.value) {console.err("Please select a Type");}
  else {
    if (event.target.value === 'Desktop') {
      type = _desktop;
      _type = _data.desktop;
      document.getElementById("browser-device").innerHTML = "Browser:";
    }
    else if (event.target.value === 'Mobile') {
      type = _mobile;
      _type = _data.mobile;
      document.getElementById("browser-device").innerHTML = "Device:";
    }
    var options = "";
    var os = document.querySelector('select[name="os"]');
    for (var i=0; i<type.length; i++) {
      options += "<option value=\""+
        type[i].os_display_name+"\">"+
        type[i].os_display_name+
        "</option>"+
        "<br>";
    }
    os.innerHTML = options;
  }
  onOsInput({target: {value: type[0].os_display_name}});
}

function getOsBrowserList() {
  document.getElementById("loading").style.visibility = "visible";
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState === 4 && this.status === 200) {
      var params = JSON.parse(this.responseText);
      _data.desktop = {};
      params.desktop.forEach(function (currentOs, index) {
        _data.desktop[currentOs.os_display_name] = {"os": currentOs};
        params.desktop[index].browsers.forEach(function (currentBrowser, browserIndex) {
          _data.desktop[currentOs.os_display_name][currentBrowser.display_name] = currentBrowser;
        });
      });
      _data.mobile = {};
      params.mobile.forEach(function (currentOs, index) {
        _data.mobile[currentOs.os_display_name] = {"os": currentOs};
        params.mobile[index].devices.forEach(function (currentDevice, deviceIndex) {
          _data.mobile[currentOs.os_display_name][currentDevice.display_name] = currentDevice;
        });
      });
      _desktop = params.desktop;
      _mobile = params.mobile;
      onTypeInput({target: {value: "Desktop"}});
      onOsInput({target: {value: _desktop[0].os_display_name}});
      document.getElementById("loading").style.visibility = "hidden";
    }
  };
  xhttp.open(
      "GET",
      "https://www.browserstack.com/list-of-browsers-and-platforms.json?product=live",
      true
  );
  xhttp.setRequestHeader("Accept", "application/json");
  xhttp.onerror = function () {
    console.error("Network error");
  };
  xhttp.send();
}

function onSubmit(event) {
  var form = event.target;
  var type = form.type.value;
  var os = form.os.value;
  var browser_device = form["browser-device"].value;
  var providedUrl = form.url.value;
  
  if (!type) {alert("Invalid Type!"); return false;}
  else if (!os) {alert("Invalid OS!"); return false;}
  else if (!browser_device) {
    if (type === "Desktop") {alert("Invalid Browser!");}
    else {alert("Invalid Device!");}
    return false;
  } else if (!providedUrl) {alert("Please provide a URL!"); return false;}
  
  console.log(_type);
  var integrationUrl = "https://www.browserstack.com/start#"+
    "os="+_type[os]["os"].os+"&"+
    "os_version="+_type[os]["os"].os_version+"&";
  if (type === "Desktop") {
    integrationUrl += "browser="+_type[os][browser_device].browser+"&"+
      "browser_version="+_type[os][browser_device].browser_version;
  } else {
    integrationUrl += "device="+_type[os][browser_device].device+"&";
  }
  integrationUrl += "url="+providedUrl;
  integrationUrl = encodeURI(integrationUrl);
  console.log(integrationUrl);
  chrome.tabs.create({url: integrationUrl});
}

document.addEventListener('DOMContentLoaded', function() {
  document.querySelector('select[name="type"]').onchange = onTypeInput;
  document.querySelector('select[name="os"]').onchange = onOsInput;
  //document.querySelector('input[name="submit"]').onclick = onSubmit;
  document.querySelector('form[name="view_site"]').onsubmit = onSubmit;

  getOsBrowserList(function(url) {
    getImageUrl(url, function(imageUrl, width, height) {
    }, function(errorMessage) {
    });
  });
});
