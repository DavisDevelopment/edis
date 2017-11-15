package edis;

import tannus.io.*;
import tannus.ds.*;
import tannus.ds.tuples.*;
import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.FunctionTools;

class Globals {
    public static function defer(action:Void->Void):Void {
        #if node
            untyped __js__('process.nextTick({0})', action);
        #else
            untyped __js__('setTimeout({0}, 0)', action);
        #end
    }

    public static function now():Float {
        #if window
            return window.performance.now();
        #else
            var hrtime:Array<Int> = process.hrtime();
            return (switch ( hrtime ) {
                case [seconds, nanoseconds]: ((seconds * 1e3) + (nanoseconds / 1e6));
                case _: throw 'TypeError: Invalid result from `process.hrtime()`';
            });
        #end
    }

#if underscore
    public static var us(get, never):Dynamic;
    private static inline function get_us() return _;
    public static var _:Dynamic = {js.Lib.require('underscore');};
#end
}
