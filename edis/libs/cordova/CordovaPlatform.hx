package edis.libs.cordova;

@:enum
abstract CordovaPlatform (String) from String {
    var Android = 'Android';
    var BlackBerry = 'BlackBerry 10';
    var Browser = 'browser';
    var IOS = 'iOS';
    var Tizen = 'Tizen';
    var MacOS = 'Mac OS X';
}
