package edis.dom.jqm;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;
import tannus.async.*;

import js.jquery.Event;

import edis.dom.*;

import Slambda.fn;
import tannus.math.TMath.*;
import edis.Globals.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.math.TMath;

class Loader {
    /* Constructor Function */
    public function new(?text:String, ?html:String):Void {
        this.l = (untyped __js__('jQuery.mobile.loading'));
        this.text = text;
        this.html = html;
    }

/* === Methods === */

    public inline function open():Void {
        l('show', {
            text: text,
            textVisible: (text != null),
            theme: 'a',
            textonly: false,
            html: html
        });
    }

    public inline function close():Void {
        l('hide');
    }

/* === Fields === */

    public var text : Null<String> = null;
    public var html : Null<String> = null;

    private var l : String->?Dynamic->Void;
}
