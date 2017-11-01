package edis.storage.kv;

import tannus.ds.*;
import tannus.io.*;
import tannus.async.*;
import tannus.html.JSFunction;

import haxe.extern.EitherType;

import sa.Globals.*;

import Slambda.fn;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.html.JSTools;
using tannus.ds.IteratorTools;

/*
   StorageArea -- object used to store persistant data
*/
class StorageArea {
    /* Constructor Function */
    public function new():Void {
        //
    }

/* === Instance Methods === */

    public function initialize(done : VoidCb):Void {
        //TODO
    }

    public function getValueByKey<T>(key:String, done:Cb<T>):Void {
        //TODO
    }

    public function getValueByPath<T>(key:String, done:Cb<T>):Void {
        var path:ObjectPath = new ObjectPath( key );
        var root = path.root(), rest = path.shift();
        getValueByKey(root.path, function(?error, ?rootData) {
            if (error != null) {
                done(error, null);
            }
            else if (rootData != null) {
                done(null, rest.get( rootData ));
            }
            else {
                done(null, null);
            }
        });
    }

    public function getValue<T>(key:String, done:Cb<T>):Void {
        if ((~/[.\/]/g).match( key )) {
            getValueByPath(key, done);
        }
        else {
            getValueByKey(key, done);
        }
    }

    public function getValuesByPairs(pairs:Iterator<KeyValue>, done:Cb<Dynamic>):Void {
        var result:Object = new Object({});
        var reads:Array<VoidAsync> = new Array();
        
        // path-compatible 'set'
        function opathset(key:String, value:Dynamic) {
            return (new ObjectPath( key )).set(result, value);
        }

        // standard read
        function sread(pair:KeyValue, ?cb:VoidCb):Void {
            reads.push(function(next) {
                if (cb != null) {
                    next = _.wrap(next, function(n:VoidCb, ?error:Dynamic) {
                        defer(() -> cb(error));
                        return n( error );
                    });
                }
                // compute keys
                var rkeys = getReadOpKeys( pair );

                // key-only
                if (pair.value == null) {
                    getValue(rkeys.source, function(?error, ?value) {
                        if (error != null)
                            return next( error );
                        else {
                            opathset(rkeys.destination, value);
                            next();
                        }
                    });
                }
                // key => value
                else {
                    //
                    getValue(rkeys.source, function(?error, ?value) {
                        if (error != null)
                            return next( error );
                        else {
                            //result[pair.key] = value;
                            if (opathset(rkeys.destination, value) == null) {
                                opathset(rkeys.destination, pair.value);
                            }
                            next();
                        }
                    });
                }
            });
        }

        // iterate over all pairs
        for (pair in pairs) {
            // for now, [sread] covers everything
            sread( pair );
        }

        // perform all 'reads' in order
        VoidAsyncs.series(reads, function(?error) {
            if (error != null) {
                done(error, null);
            }
            else {
                done(null, result);
            }
        });
    }

    public function getValuesDefaults(defaults:Map<String, Null<Dynamic>>, done:Cb<Dynamic>):Void {
        var pairs:Iterator<KeyValue> = (defaults.keys().map(key -> new KeyValue(key, defaults[key])));
        getValuesByPairs(pairs, done);
    }

    public function getValuesObject(o:Object, done:Cb<Dynamic>):Void {
        var pairs:Iterator<KeyValue> = (o.keys.iterator().map(key -> new KeyValue(key, o[key])));
        getValuesByPairs(pairs, done);
    }

    /**
      * load an Object containing a subset of [this]'s data, as 
      * specified by [keys]
      */
    public function getValues(keys:Array<String>, done:Cb<Dynamic>):Void {
        return getValuesByPairs(keys.iterator().map(key -> new KeyValue(key, null)), done);
        /*
        var defaults:Map<String, Null<Dynamic>> = new Map();
        for (key in keys) {
            defaults[key] = null;
        }
        return getValuesDefaults(defaults, cb);
        */
    }

    /**
      * load an Object containing all of [this]'s data
      */
    public function getAll(cb : Cb<Dynamic>):Void {
        //TODO
    }

    public function setValueByKey(key:String, value:Dynamic, done:VoidCb):Void {
        //TODO
    }

    /**
      * assign property value by ObjectPath
      */
    public function setValueByPath(key:String, value:Dynamic, done:VoidCb):Void {
        var path = new ObjectPath( key );
        var dir = path.pop(), file = path.top(), root = path.root(), rest = path.shift();
        getValue((root + ''), function(?error, ?dirData) {
            if (error != null) {
                done( error );
            }
            else if (dirData != null) {
                rest.set(dirData, value);
                setValueByKey((root + ''), dirData, done);
            }
            else {
                var data:Dynamic = {};
                rest.set(data, value);
                trace( data );
                done('Error: Cannot path-set on nonexistent Object');
            }
        });
    }

    /**
      * assign the value of a single property
      */
    public function setValue(key:String, value:Dynamic, done:VoidCb):Void {
        return (if (isObjectPathKey( key )) {
            setValueByPath;
        }
        else {
            setValueByKey;
        })(key, value, done);
    }

    /**
      * batch assign using an Object
      */
    public function setValues(values:Dynamic, done:VoidCb):Void {
        var writes = [];
        for (key in Reflect.fields( values )) {
            writes.push(setValue.bind(key, Reflect.getProperty(values, key), _));
        }
        VoidAsyncs.series(writes, done);
    }

    /**
      * batch-assign using a Map<String, Dynamic>
      */
    public function setValuesMap(values:Map<String, Dynamic>, done:VoidCb):Void {
        var writes = [];
        for (key in values.keys()) {
            writes.push(setValue.bind(key, values[key], _));
        }
        VoidAsyncs.series(writes, done);
    }

    /**
      * remove a property from [this]
      */
    public function removeProperty(key:String, done:VoidCb):Void {
        (if (isObjectPathKey( key )) {
            removePropertyByPath;
        }
        else {
            removePropertyByKey;
        })(key, done);
    }

    /**
      * remove a property from [this]
      */
    public function removePropertyByKey(key:String, done:VoidCb):Void {
        //TODO
    }

    /**
      * remove a property from [this]
      */
    public function removePropertyByPath(key:String, done:VoidCb):Void {
        var path:ObjectPath = new ObjectPath( key );
        var root = path.root(), rest = path.shift();
        getValue((root + ''), function(?error, ?rootData) {
            if (error != null) {
                return done( error );
            }
            else if (rootData != null) {
                rest.remove( rootData );
                done();
            }
            else {
                done();
            }
        });
    }

    /**
      * delete a list of properties
      */
    public function removerProperties(keys:Iterable<String>, done:VoidCb):Void {
        VoidAsyncs.callEach([for (key in keys) {
            removeProperty.bind(key, _);
        }], done);
    }

    /**
      * clear [this] of all its properties
      */
    public function clear(done : VoidCb):Void {
        //TODO
    }

    public function length(done : Cb<Int>):Void {
        //TODO
    }

    public function keys(done : Cb<Array<String>>):Void {
        //TODO
    }

    public function key(index:Int, done:Cb<Maybe<String>>):Void {
        keys(function(?error, ?keyList) {
            if (error != null) {
                done(error, null);
            }
            else if (keyList != null) {
                done(null, keyList[index]);
            }
            else {
                done('Error: No data loaded', null);
            }
        });
    }

    /**
      * iterate over every stored value on [this]
      */
    public function each(iteratee:Dynamic->String->Int->Void, done:VoidCb):Void {
        length(function(?error, ?len:Int) {
            if (error != null) {
                return done( error );
            }
            else {
                var index:Int = 0;
                function step() {
                    key(index, function(?error, ?k) {
                        if (error != null) {
                            return done( error );
                        }
                        else {
                            getValue(k, function(?error, ?value) {
                                if (error != null) {
                                    return done( error );
                                }
                                else {
                                    iteratee(value, k, index++);
                                    if (index < len) {
                                        step();
                                    }
                                    else {
                                        done();
                                    }
                                }
                            });
                        }
                    });
                }
                step();
            }
        });
    }

/* === Generalized Instance Methods === */

    /**
      * perform a batch-read and/or dynamic query of [this]
      */
    public function get(query:Dynamic, callback:Cb<Dynamic>):Void {
        // no query, read all
        if (query == null) {
            return getAll( callback );
        }
        // single key
        else if ((query is String)) {
            return getValues([cast query], callback);
        }
        // array of keys
        else if ((query is Array<String>)) {
            return getValues(cast query, callback);
        }
        // query as a Map<String, Dynamic>
        else if ((query is haxe.ds.StringMap)) {
            return getValuesDefaults(cast query, callback);
        }
        // query as an Object
        else if (Reflect.isObject( query )) {
            var q:Object = new Object( query );
            // if that Object has no properties
            if (q.empty()) {
                // load all data
                return getAll( callback );
            }
            // otherwise proceed normally
            else {
                return getValuesObject(q, callback);
                //var def:Map<String, Null<Dynamic>> = new Map();
                //for (key in q.keys) {
                    //def[key] = q[key];
                //}
                //return getValuesDefaults(def, callback);
            }
        }
        // query as a Function
        else if (Reflect.isFunction( query )) {
            // assume that the function will create and return
            // data that can be used to 'get'
            return get(untyped query(), callback);
        }
        else {
            throw 'Error: Invalid [query] parameter for "get"';
        }
    }

    /**
      * perform batch assignment
      */
    public function set(sets:Dynamic, callback:VoidCb):Void {
        if ((sets is haxe.ds.StringMap)) {
            return setValuesMap(cast sets, callback);
        }
        else if (Reflect.isObject( sets )) {
            return setValues(sets, callback);
        }
        else if ((sets is Array<Dynamic>)) {
            var setsteps:Array<Dynamic> = cast sets;
            return VoidAsyncs.callEach([for (x in setsteps) set.bind(x, _)], callback);
        }
        else {
            throw 'Error: Invalid [sets] parameter for "set"';
        }
    }

    /**
      * perform batch deletion of properties
      */
    public function remove(props:EitherType<String, Iterable<String>>, done:VoidCb):Void {
        if ((props is String))
            props = [cast props];
        return removerProperties(cast props, done);
    }

    private function encode(value : Dynamic):Dynamic return value;

    private function decode(value : Dynamic):Dynamic return value;

    /**
      * functionally build a new Object
      */
    private function compose(func : haxe.Constraints.Function):Object {
        var newObj:Object = new Object({});
        var _tmp = func( newObj );
        if (_tmp != null && Reflect.isObject( _tmp )) {
            newObj = _tmp;
        }
        return newObj;
    }

    /**
      * get the key to which 
      */
    private function getReadOpKeys(pair : KeyValue):ReadOpKeys {
        var keys:ReadOpKeys = new ReadOpKeys(pair.key, pair.key);
        var dat:Maybe<Array<String>> = null;
        if (pair.value == null) {
            if (isSimpleAliasKey( pair.key )) {
                dat = simple_alias_data( pair.key );
                keys.set(dat[2], dat[1]);
            }
            else if (isAliasKey( pair.key )) {
                dat = alias_data( pair.key );
                var op:AliasBinop = dat[2];
                switch ( op ) {
                    case Left:
                        keys.set(dat[1], dat[3]);

                    case Right, Colon:
                        keys.set(dat[3], dat[1]);
                }
            }
            else {
                //TODO
            }
        }
        else if ((pair.value is String)) {
            var val:String = cast pair.value;

            if (isAliasVal( val )) {
                dat = alias_val_data( val );
                keys.set(null, dat[1]);
            }
            else if (isValueMacroString( val )) {
                var vmdat = macro_data( val );
                trace( vmdat );
            }
        }
        return keys;
    }

    /**
      * 
      */
    private function getWriteOpValue(pair : KeyValue):Dynamic {
        if (pair.value != null && (pair.value is String)) {
            var val:String = cast pair.value;
            //TODO perform magic
        }
        return pair.value;
    }

    /**
      * check whether [key] is intended to be an Object field Path
      */
    private function isObjectPathKey(key : String):Bool {
        //return ((~/[.\/]/g).match( key ));
        return patternForObjectPath.match( key );
    }

    /**
      * check whether [key] is intended to map data from one key to another (alias)
      */
    private function isAliasKey(key : String):Bool {
        //return ((~/^([^ ><:]+) +([<>:]) +([^ ><:]+$)/gm).match( key ));
        return patternForAlias.match( key );
    }

    private function isSimpleAliasKey(key : String):Bool {
        return patternForSimpleAlias.match( key );
    }

    /**
      * check whether [key] is intended to denote the filling of a 
      * property in the 'results' Object with a value pulled from 
      * elsewhere in the field hierarchy
      */
    private function isMapperString(key : String):Bool {
        //return ((~/^ *([<>:]]) +(e^ <>:]+$)/gm).match( key ));
        return patternForMapper.match( key );
    }
    private function isAliasVal(val : String):Bool {
        return patternForAliasVal.match( val );
    }

    /**
      * check whether [s] is a 'macro' of any kind
      */
    private function isValueMacroString(s : String):Bool {
        if (isMapperString( s )) {
            return true;
        }
        else {
            for (re in patternsForMacroString) {
                if (re.match( s )) {
                    return true;
                }
            }
            return false;
        }
    }

    /**
      * check whether [key] is a non-literal key of any kind
      */
    private function isNonLiteralKey(key : String):Bool {
        return (isObjectPathKey( key ) || isAliasKey( key ));
    }

    private function alias_data(key : String):Maybe<Array<String>> return redat(patternForAlias, key);
    private function alias_val_data(val : String):Maybe<Array<String>> return redat(patternForAliasVal, val);
    private function simple_alias_data(key : String):Maybe<Array<String>> return redat(patternForSimpleAlias, key);
    private function mapper_data(key : String):Maybe<Array<String>> return redat(patternForMapper, key);
    private function macro_data(s : String):Maybe<ValueMacroType> {
        if (!isValueMacroString( s )) {
            return null;
        }
        else {
            var macroCode:Int = 0;
            for (index in 0...patternsForMacroString.length) {
                var re = patternsForMacroString[index];
                if (re.match( s )) {
                    macroCode = index;
                }
            }
            var re:RegEx = patternsForMacroString[macroCode];
            var data = redat(re, s);
            if (data == null) {
                return null;
            }
            else {
                var type:Null<ValueMacroType> = null;
                switch ( macroCode ) {
                    case 0:
                        type = VMReification(data[1]);

                    case 1:
                        type = VMInlineTag(data[1]);

                    case 2, 3:
                        type = VMMetaMethod(data[1], data[2]);

                    default:
                        null;
                }
                return type;
            }
        }
    }

    /**
      * extract data from [s] via [re]
      */
    private function redat(re:RegEx, s:String):Maybe<Array<String>> {
        if (!re.match( s )) {
            return null;
        }
        else {
            return (re.search( s )[0]);
        }
    }

    private static var patternForObjectPath : RegEx = {new RegEx(~/.\//gm);};
    private static var patternForSimpleAlias : RegEx = {new RegEx(~/^([A-Za-z0-9_]+): *(.+)$/gm);};
    private static var patternForAlias : RegEx = {new RegEx(~/^([^ ><:]+) +([<>:]) +([^ ><:]+$)/gm);};
    private static var patternForAliasVal : RegEx = {new RegEx(~/^ *< *([A-Za-z0-9_]+)$/gm);};
    private static var patternForMapper : RegEx = {new RegEx(~/^ *([<>:]]) +([^ <>:]+$)/gm);};
    private static var patternsForMacroString:Array<RegEx> = {[
        // standard self-referencing reification
        new RegEx(~/@\{([^@{}]+)\}/gm),
        // full tag-line expression interpolation
        new RegEx(~/@\{%(.+)%\}/gm),
        //[-- metamethods --]
        // non-call and/or no-arguments
        new RegEx(~/@:([A-Za-z0-9_$]+)\(? *\) *?$/gm),
        // with arguments
        new RegEx(~/@:([A-Za-z0-9_$]+)\( *(.+) *\) *$/gm)
    ];};

    // all acceptible 'alias' binary-operator chars
    private static var aliasBinops:String = '<>:';
}

enum ValueMacroType {
    VMReification(block : String);
    VMInlineTag(block : String);
    VMMetaMethod(name:String, ?paren:String);
}

//@:structInit
class KeyValue {
    public function new(k:String, ?v:Dynamic) {
        this.key = k;
        this.value = v;
    }

    public var key : String;
    public var value : Null<Dynamic>;
}

class ReadOpKeys {
    public inline function new(src:String, dest:String) {
        this.source = src;
        this.destination = dest;
    }

    public function set(?a:String, ?b:String):Void {
        if (a != null)
            source = a;
        if (b != null)
            destination = b;
    }

    public var source : String;
    public var destination : String;
}

@:enum
@:access( edis.storage.kv.StorageArea )
abstract AliasBinop (String) from String to String {
    var Left = '<';
    var Right = '>';
    var Colon = ':';

    @:from
    public static inline function fromString(s : String):AliasBinop {
        if (!StorageArea.aliasBinops.has( s )) {
            throw 'Error: Invalid AliasBinop "$s"';
        }
        return s;
    }
}
