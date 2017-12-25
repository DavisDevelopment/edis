package pt.views;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;
import tannus.async.*;

import edis.dom.*;

import haxe.extern.EitherType;

import edis.Globals.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class Popup extends JQueryMobileComponent {
    /* Constructor Function */
    public function new(?el : Element):Void {
        super();

        if (el == null) {
            this.el = e('<div data-role="popup"></div>');
        }
        else {
            this.el = el;
        }

        el.plugin('popup');
    }

/* === Instance Methods === */

    public function open(?options:{?x:Float,?y:Float,?transition:String,?positionTo:String}):Void {
        appendTo('body');
        call([]);
        call(['open', options]);
    }

    public function close():Void {
        call(['close']);
    }

    public function disable():Void {
        call(['disable']);
    }

    public function enable():Void {
        call(['enable']);
    }

    public function option(?name:Dynamic, ?value:Dynamic):Dynamic {
        var params:Array<Dynamic> = ['option'];
        if (name != null && Reflect.isObject( name )) {
            params.push( name );
        }
        else {
            if (name != null)
                params.push( name );
            if (value != null)
                params.push( value );
        }
        return call( params );
    }

    public function reposition(pos : {x:Float, y:Float, positionTo:String}):Void {
        return call(untyped ['reposition', pos]);
    }

    private inline function call<T>(params : Array<Dynamic>):T {
        return el.plugin('popup', params);
    }
}
