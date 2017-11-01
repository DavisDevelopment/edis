package edis;

import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Globals {
    public static function defer(action:Void->Void):Void {
        #if node
            untyped __js__('process.nextTick({0})', action);
        #else
            untyped __js__('setTimeout({0}, 0)', action);
        #end
    }
#if underscore
    public static var us(get, never):Dynamic;
    private static inline function get_us() return _;
    public static var _:Dynamic = {js.Lib.require('underscore');};
#end
}
