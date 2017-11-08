package edis.libs.cordova;

import tannus.io.*;
import tannus.ds.*;
import tannus.html.Win;
import tannus.html.fs.*;
import tannus.html.fs.WebFSEntry;
import tannus.async.*;
import tannus.sys.Path;

@:native('cordova.file')
extern class CordovaFile {
    public static var applicationDirectory:String;
    public static var applicationStorageDirectory:String;
    public static var dataDirectory:String;
    public static var cacheDirectory:String;
    public static var externalApplicationStorageDirectory:String;
    public static var externalDataDirectory:String;
    public static var externalCacheDirectory:String;
    public static var externalRootDirectory:String;
    public static var tempDirectory:String;

    public static inline function resolve(path:String, success:WebFSEntry->Void, failure:Dynamic->Void):Void {
        (untyped __js__('(window.resolveLocalFileSystemURL||window.webkitResolveLocalFileSystemURL)({0}, {1}, {2})', path, success, failure));
    }
}
