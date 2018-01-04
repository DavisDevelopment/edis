package edis;

import tannus.io.*;
import tannus.ds.*;
import tannus.math.TMath.*;
import tannus.sys.Path;

import edis.Environment;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.FunctionTools;
using DateTools;

class Console {
/* === Methods === */

    private static function ensureMode():Void {
        if (mode == null) {
            var pt = Environment.platform;
            switch ( pt ) {
                case EdisPlatform.Browser, EdisPlatform.Chrome(_):
                    mode = LMTrace;

                case EdisPlatform.Cordova(_):
                    mode = LMTrace;

                case EdisPlatform.Electron(_):
                    mode = LM
            }
        }
    }

    @:allow( edis.Console.LogEntry )
    private static #if !js inline #end function useNative():Bool {
            #if js
            if (use_native == null) {
                inline function isdef(x) return untyped __js__('(typeof {0} !== "undefined")');
                use_native = (untyped (isdef(JSON) && isdef(atob) && isdef(btoa)));
            }
            return use_native;
        #else
            return false;
        #end
    }

    @:allow( edis.Console.LogEntry )
    private static inline function json_encode(x: Dynamic):String {
        if (useNative()) {
            return (untyped __js__('JSON.stringify({0})', x));
        }
        else {
            return haxe.Json.stringify( x );
        }
    }

    @:allow( edis.Console.LogEntry )
    private static inline function json_decode(x: String):Dynamic {
        if (useNative()) {
            return (untyped __js__('JSON.parse({0})', Std.string(x)));
        }
        else {
            return haxe.Json.parse( x );
        }
    }

    @:allow( edis.Console.LogEntry )
    private static inline function atob(x: String):String {
        if (useNative()) {
            return (untyped __js__('atob({0})', x));
        }
        else {
            return (ByteArray.ofString( x ).toBase64());
        }
    }

    @:allow( edis.Console.LogEntry )
    private static inline function btoa(x: String):String {
        if (useNative()) {
            return (untyped __js__('btoa({0})', x));
        }
        else {
            return (ByteArray.fromBase64( x ).toString());
        }
    }

/* === Fields === */

    private static var mode:Null<LogMode> = null;
    private static var use_native:Null<Bool> = null;
}

private enum LogMode {
    LMTrace;
    LMFile(file: Path);
}

@:access( edis.Console )
private class LogEntry {
    public var type: LogType;
    public var text: String;
    public var time: Date;

    public inline function new(type:LogType, text:String, time:Date) {
        this.type = type;
        this.text = text;
        this.time = time;
    }

    public function clone():LogEntry {
        return new LogEntry(type, text, time);
    }

    public function toString():String {
        return text;
    }

    public inline function encode():String {
        return Console.json_encode(toJson());
    }

    public static inline function decode(data: String):LogEntry {
        return fromJson(Console.json_decode( data ));
    }

    public function toJson():Array<String> {
        return untyped [type, Console.atob(text), time.toString()];
    }

    public static inline function fromJson(array: Array<String>):LogEntry {
        switch ( array ) {
            case [type, text, time]:
                return new LogEntry(type, Console.btoa(text), Date.fromString(time));

            default:
                throw 'TypeError: Invalid data for LogEntry';
        }
    }
}

@:enum
abstract LogType (String) from String {
    var Debug = 'D';
    var Info = 'I';
    var Warning = 'W';
    var Error = 'E';
}

//private enum LogType {
    //Debug;
    //Info;
    //Warning;
    //Error;
//}
