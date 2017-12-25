package edis.dom.jqm;

import tannus.io.*;
import tannus.ds.*;
import tannus.html.*;

import edis.core.*;
import edis.dom.*;

import haxe.Constraints.Function;
import Std.*;
import Reflect.*;
import tannus.math.TMath.*;
import edis.Globals.*;

import haxe.rtti.Meta;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.math.TMath;
using tannus.html.JSTools;
using tannus.FunctionTools;

class JQueryMobileComponent extends Component {
    /* Constructor Function */
    public function new():Void {
        super();

        _call = makeVarArgs(function(args : Array<Dynamic>) {
            if (args.length >= 1 && el != null) {
                //return callMethod(this.el, getProperty(this.el, Std.string(args.shift())), args);
                return callMethod(this.el, this.el.nativeArrayGet('' + args.shift()), args);
            }
            else return null;
        });

        _ecall = makeVarArgs(function(args : Array<Dynamic>) {
            if (args.length >= 1 && el != null && el.at(0) != null) {
                var node = el.at(0);
                return callMethod(node, node.nativeArrayGet('' + args.shift()), args);
            }
            else return null;
        });

        wm = null;
    }

/* === Instance Methods === */

    /**
      * return a partially bound version of the method [methodName]
      */
    private function _meth<Func:Function>(methodName:String, ?partialArgs:Array<Dynamic>):Func {
        var _args:Array<Dynamic> = (untyped [_call, methodName]);
        if (partialArgs != null)
            _args = _args.concat( partialArgs );
        return callMethod(_, _.partial, _args);
    }

    private function _emethod<Func:Function>(methodName:String, ?partialArgs:Array<Dynamic>):Func {
        var _args:Array<Dynamic> = (untyped [_ecall, methodName]);
        if (partialArgs != null)
            _args = _args.concat( partialArgs );
        return callMethod(_, _.partial, _args);
    }

    /**
      * bind [this] to an Element in dat sweet-ass fancy way
      */
    private function _bindel(?el:Element, markup:String, ?einit:Element->Void):Void {
        if (el != null) {
            this.el = el;
        }
        else {
            this.el = e( markup );
        }
        if (einit != null) {
            einit(e( this.el ));
        }
    }

/* === Computed Instance Fields === */

    public var ebody(get, never):Element;
    private inline function get_ebody() return new Element('body');

    public var app(get, never):Application;
    private inline function get_app():Application return ebody.data('sa.core.application');

    public var id(get, set):Null<String>;
    private inline function get_id() return el['id'];
    private inline function set_id(v) return (el['id'] = v);

/* === Instance Fields === */

    public var _call : Dynamic;
    public var _ecall : Dynamic;
    public var wm : Null<Dynamic>;
}

