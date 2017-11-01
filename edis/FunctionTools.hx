package edis;

import tannus.io.*;
import tannus.ds.*;
import tannus.math.TMath.*;

import js.Lib.global;
import js.Lib.nativeThis as _this;
import js.Lib.eval;

import haxe.Constraints.Function;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.html.JSTools;

class FunctionTools {
    //
    public static function varArgs<T:Function>(f : Function):T {
        return (function(args : Array<Dynamic>) {
            return f.apply(_this, args);
        });
    }

    public static function compose(o:Dynamic, ops:Iterable<Function>):Dynamic {
        for (op in ops) {
            o = op( o );
        }
        return o;
    }

    public static function composer(ops : Iterable<Function>):Dynamic->Dynamic {
        return compose.bind(_, ops);
    }

/* === Fields === */

    private static var arguments
}
