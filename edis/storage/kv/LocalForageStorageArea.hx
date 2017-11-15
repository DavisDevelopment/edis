package edis.storage.kv;

import tannus.ds.*;
import tannus.io.*;
import tannus.sys.Path;
import tannus.async.*;

import haxe.extern.EitherType;

import edis.libs.localforage.LocalForage;
import edis.storage.kv.*;
import edis.storage.db.*;
import edis.Globals.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.async.Asyncs;

class LocalForageStorageArea extends StorageArea {
    public function new(s : LocalForageInstance):Void {
        super();

        this.s = s;

        keys(function(?error, ?keys) {
            trace({error:error, result:keys});
        });
    }

/* === Instance Methods === */

    override function initialize(done : VoidCb):Void {
        //s.ready( done );
        defer(function() {
            done();
        });
    }

    override function getValueByKey<T>(key:String, done:Cb<T>):Void {
        trace( this );
        s.getItem(key, done);
    }

    override function setValueByKey(key:String, value:Dynamic, done:VoidCb):Void {
        s.setItem(key, value, function(?error, ?val) {
            done( error );
        });
    }

    override function removeProperty(key:String, done:VoidCb):Void {
        s.removeItem(key, done);
    }

    override function clear(done : VoidCb):Void {
        s.clear( done );
    }

    override function getAll(done : Cb<Dynamic>):Void {
        s.keys(function(?error, ?keys) {
            if (error != null) {
                done(error, null);
            }
            else if (keys != null) {
                getValues(keys, done);
            }
            else {
                done('Error: No keys retrieved by LocalForage');
            }
        });
    }

    override function length(done : Cb<Int>):Void {
        s.length( done );
    }

    override function keys(done : Cb<Array<String>>):Void {
        s.keys( done );
    }

    override function key(index:Int, done:Cb<Maybe<String>>):Void {
        s.key(index, done);
    }

    override function each(iteratee:Dynamic->String->Int->Void, done:VoidCb):Void {
        s.iterate(iteratee, done);
    }

/* === Instance Fields === */

    private var s : LocalForageInstance;

/* === Statics === */

    public static function create(?options: Dynamic):LocalForageStorageArea {
        return new LocalForageStorageArea(LocalForage.createInstance( options ));
    }
}
