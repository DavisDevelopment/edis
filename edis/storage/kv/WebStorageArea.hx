package edis.storage.kv;

import tannus.ds.*;
import tannus.io.*;
import tannus.async.*;

import haxe.extern.EitherType;

import sa.Globals.*;

import js.html.Storage;
import Reflect.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class WebStorageArea extends StorageArea {
    /* Constructor Function */
    public function new(s : Storage):Void {
        super();

        this.s = s;
    }

/* === Instance Methods === */

    override function initialize(done : VoidCb):Void {
        done();
    }

    override function getValueByKey(key:String, cb:Cb<Dynamic>):Void {
        defer(function() {
            //var o = {};
            //setProperty(o, key, decode(s.getItem(key)));
            //cb(null, o);
            cb(null, decode(s.getItem( key )));
        });
    }

    override function getValuesDefaults(defaults:Map<String, Null<Dynamic>>, cb:Cb<Dynamic>):Void {
        var me = this;
        function defget(key:String):Dynamic {
            var val = s.getItem( key );
            if (val == null)
                val = defaults[key];
            if (val != null)
                val = decode( val );
            return val;
        }
        defer(function() {
            var o:Dynamic = {};
            for (key in defaults.keys()) {
                setProperty(o, key, defget( key ));
            }
            cb(null, o);
        });
    }

    override function getAll(cb : Cb<Dynamic>):Void {
        var keys = [for (i in 0...s.length) s.key(i)];
        return getValues(keys, cb);
    }

    override function setValueByKey(key:String, value:Dynamic, cb:VoidCb):Void {
        defer(function() {
            s.setItem(key, encode( value ));
            cb();
        });
    }

    override function setValues(values:Dynamic, cb:VoidCb):Void {
        defer(function() {
            for (key in fields( values ))
                s.setItem(key, encode(getProperty(values, key)));
            cb();
        });
    }

    override function removeProperty(key:String, cb:VoidCb):Void {
        vasync(()->s.removeItem(key), cb);
    }

    override function removerProperties(keys:Iterable<String>, cb:VoidCb):Void {
        vasync(()->{
            for (key in keys)
                s.removeItem( key );
        }, cb);
    }

    override function clear(cb : VoidCb):Void {
        vasync(s.clear, cb);
    }

    override function length(done : Cb<Int>) {
        async(()-> s.length, done);
    }

    private function async<T>(task:Void->T, callback:Cb<T>):Void {
        defer(function() {
            try {
                var result = task();
                callback(null, result);
            }
            catch (error : Dynamic) {
                callback(error, null);
            }
        });
    }
    private function vasync(task:Void->Void, callback:VoidCb):Void {
        defer(function() {
            try {
                task();
                callback();
            }
            catch (error : Dynamic) {
                callback( error );
            }
        });
    }

    override function encode(value : Dynamic):Dynamic return haxe.Json.stringify( value );
    override function decode(value : Dynamic):Dynamic return haxe.Json.parse( value );

/* === Instance Fields === */

    private var s : Storage;
}
