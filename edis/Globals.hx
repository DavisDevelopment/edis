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

    public static inline function wait(time:Int, action:Void->Void):Void {
        untyped __js__('setTimeout({0}, {1})', action, time);
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

    public static inline function report(error: Dynamic):Void {
        untyped __js__('console.error({0})', error);
    }

#if window

    public static inline function e(x:Dynamic):tannus.html.Element {
        return new tannus.html.Element( x );
    }

#end

/* === Global Variables === */

#if underscore
    public static var us(get, never):Dynamic;
    private static inline function get_us() return _;
    public static var _:Dynamic = {js.Lib.require('underscore');};
#end

#if window
    public static var window(get, never):tannus.html.Win;
    private static inline function get_window() return tannus.html.Win.current;
#end

#if node
    public static var process(get, never):tannus.node.Process;
    private static inline function get_process() return (untyped __js__('process'));
#end
}
