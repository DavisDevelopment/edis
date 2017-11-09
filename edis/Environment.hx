package edis;

import tannus.io.*;
import tannus.ds.*;
import tannus.html.*;
import tannus.math.TMath.*;

import edis.libs.cordova.CordovaPlatform;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Environment {
    private static inline function testWindow():Bool return (untyped __js__('(typeof window !== "undefined")'));
    private static inline function testCordova():Bool return testWindow() && (untyped __js__('!!window.cordova'));
    private static inline function testChromeExtension():Bool return testWindow() && (untyped __js__('(window.chrome && chrome.runtime && !!chrome.runtime.id)'));
    private static inline function testChromeApp():Bool return testWindow() && (untyped __js__('(window.chrome && chrome.app && chrome.app.runtime && !!chrome.app.runtime.id)'));
    private static inline function testElectron():Bool return testWindow() && (untyped __js__('(window.process && window.process.type)'));

    public static var platformType(get, never):EdisPlatformType;
    private static var _pt:Null<EdisPlatformType> = null;
    private static function get_platformType() {
        if (_pt == null) {
            if (testCordova()) {
                _pt = EPTCordova;
            }
            else if (testChromeExtension() || testChromeApp()) {
                _pt = EPTChrome;
            }
            else if (testElectron()) {
                _pt = EPTElectron;
            }
            else {
                _pt = EPTBrowser;
            }
        }
        return _pt;
    }

    public static var platform(get, never):EdisPlatform;
    private static var _p:Null<EdisPlatform> = null;
    private static function get_platform() {
        if (_p == null) {
            var pt = platformType;
            switch ( pt ) {
                case EPTBrowser:
                    _p = Browser;

                case EPTCordova:
                    var cpt:CordovaPlatform = (untyped __js__('device.platform'));
                    var ecpt:Null<EdisCordovaPlatform> = null;
                    switch ( cpt ) {
                        case Android:
                            ecpt = EdisCordovaPlatform.Android;
                        case BlackBerry:
                            ecpt = BlackBerry;
                        case Browser:
                            ecpt = Browser;
                        case IOS:
                            ecpt = IOS;
                        case Tizen:
                            ecpt = Tizen;
                        case MacOS:
                            ecpt = MacOS;
                        case _:
                            ecpt = null;
                    }
                    _p = Cordova( ecpt );

                case EPTChrome:
                    _p = Chrome({
                        if (testChromeApp())
                            PackagedApp;
                        else if (testChromeExtension())
                            Extension;
                        else
                            throw 'BettyWhatTheFuck';
                    });

                case EPTElectron:
                    _p = Electron(testWindow() ? Content : Background);

                case _:
                    throw 'BettyWhatTheFuck';
            }
        }
        return _p;
    }
}

enum EdisPlatformType {
    EPTBrowser;
    EPTCordova;
    EPTChrome;
    EPTElectron;
}

enum EdisPlatform {
    Browser;
    Cordova(platform : EdisCordovaPlatform);
    Chrome(platform : EdisChromePlatform);
    Electron(platform : EdisElectronPlatform);
}

enum EdisCordovaPlatform {
    Android;
    BlackBerry;
    Browser;
    IOS;
    Tizen;
    MacOS;
}

enum EdisChromePlatform {
    PackagedApp;//(context : EdisChromeScriptType);
    Extension;//(context : EdisChromeScriptType);
}

enum EdisChromeScriptType {
    Background;
    Content;
}

enum EdisElectronPlatform {
    Background;
    Content;
}
