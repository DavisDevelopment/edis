package edis.storage.kv;

import tannus.ds.*;
import tannus.io.*;
import tannus.async.*;
import tannus.async.promises.*;

import haxe.extern.EitherType as Either;

//import sa.Globals.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class Storage {
    /* Constructor Function */
    public function new(area : StorageArea):Void {
        this.area = area;
    }

/* === Instance Methods === */

    public function initialize(?done : VoidCb):Promise<Storage> {
        return ppv(area.initialize, done);
    }

    public function getValueByKey<T>(key:String, ?done:Cb<T>):Promise<T> return pp(area.getValueByKey.bind(key, _), done);
    public function getValueByPath<T>(key:String, ?done:Cb<T>):Promise<T> return pp(area.getValueByPath.bind(key, _), done);
    public function getValue<T>(key:String, ?done:Cb<T>):Promise<T> return pp(area.getValue.bind(key, _), done);
    public function getValuesDefaults(defaults:Map<String, Null<Dynamic>>, ?done:Cb<Dynamic>):Promise<Dynamic> return pp(area.getValuesDefaults.bind(defaults, _), done);
    public function getValuesObject(o:Object, ?done:Cb<Dynamic>):Promise<Dynamic> return pp(area.getValuesObject.bind(o, _), done);
    public function getValues(keys:Array<String>, ?done:Cb<Dynamic>):Promise<Dynamic> return pp(area.getValues.bind(keys, _), done);
    public function getAll(?done : Cb<Dynamic>):Promise<Dynamic> return pp(area.getAll, done);
    public function setValue(key:String, value:Dynamic, ?done:VoidCb):Promise<Storage> return ppv(area.setValue.bind(key, value, _), done);
    public function setValues(values:Dynamic, ?done:VoidCb):Promise<Storage> return ppv(area.setValues.bind(values, _), done);
    public function setValuesMap(values:Map<String, Dynamic>, ?done:VoidCb):Promise<Storage> return ppv(area.setValuesMap.bind(values, _), done);
    public function removeProperty(key:String, ?done:VoidCb):Promise<Storage> return ppv(area.removeProperty.bind(key, _), done);
    public function removeProperties(keys:Iterable<String>, ?done:VoidCb):Promise<Storage> return ppv(area.removeProperties.bind(keys, _), done);
    public function clear(?done : VoidCb):Promise<Storage> return ppv(area.clear, done);
    public function length(?done : Cb<Int>):Promise<Int> return pp(area.length, done);
    public function keys(?done : Cb<Array<String>>):ArrayPromise<String> return pp(area.keys, done).array();
    public function key(index:Int, ?done:Cb<Maybe<String>>):Promise<Maybe<String>> return pp(area.key.bind(index, _), done);
    public function each(iteratee:Dynamic->String->Int->Void, ?done:VoidCb):Promise<Storage> return ppv(area.each.bind(iteratee, _), done);
    public function get(query:Dynamic, ?done:Cb<Dynamic>):Promise<Dynamic> return pp(area.get.bind(query, _), done);
    public function set(sets:Dynamic, ?done:VoidCb):Promise<Storage> return ppv(area.set.bind(sets, _), done);
    public function remove(props:Either<String, Iterable<String>>, ?done:VoidCb):Promise<Storage> return ppv(area.remove.bind(props, _), done);


    /**
      * convert [f] into a Promise, and optionally provide a callback
      */
    private function pp<T>(f:Async<T>, ?cb:Cb<T>):Promise<T> {
        inline function callback(?err, ?res) {
            if (cb != null) {
                cb(err, res);
            }
        }

        return Promise.create({
            f(function(?error, ?result) {
                if (error != null) {
                    callback(error, null);
                    throw error;
                }
                else {
                    callback(null, result);
                    return result;
                }
            });
        });
    }

    /**
      * convert [f] into a Promise<Storage> and provide a callback
      */
    private function ppv(f:VoidAsync, ?cb:VoidCb):Promise<Storage> {
        inline function done(?error) {
            if (cb != null) {
                cb( error );
            }
        }

        return Promise.create({
            f(function(?error) {
                if (error != null) {
                    done( error );
                    throw error;
                }
                else {
                    done();
                    return this;
                }
            });
        });
    }

/* === Instance Fields === */

    private var area : StorageArea;
}
