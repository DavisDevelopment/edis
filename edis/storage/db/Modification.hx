package edis.storage.db;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;

import Slambda.fn;
import tannus.math.TMath.*;
import haxe.extern.EitherType;
import haxe.Constraints.Function;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using Slambda;
using tannus.async.Asyncs;
using tannus.async.VoidAsyncs;
using tannus.html.JSTools;

class Modification {
    /* Constructor Function */
    public function new(?o : Object):Void {
        this.o = (o != null ? o : {});
    }

/* === Operators === */

    public function set(index:String, value:Dynamic):Modification {
        return _set(_bokv(index, value));
    }

    public function inc(index:String, value:Int):Modification {
        return _increment(_bokv(index, value));
    }

    public function unset(index: String):Modification {
        return _unset(_bokiv(pluralize(index), true));
        //return _unset(_bokv(index, value));
    }

    public function push(index:String, value:Dynamic):Modification {
        return _push(_bokv(index, value));
    }

    public function pushMany(index:String, values:Array<Dynamic>):Modification {
        return push(index, _each( values ));
    }

    public function pop(index:String, value:Dynamic):Modification {
        return _pop(_bokv(index, value));
    }

    public function addToSet(index:String, value:Dynamic):Modification {
        return _addToSet(_bokv(index, value));
    }

    public function addAllToSet(index:String, values:Array<Dynamic>):Modification {
        return _addToSet(_bokv(index, _bopv('each', values)));
    }

    public function pull(index:String, what:Dynamic):Modification {
        //return _pull(_bokv(index, value));
        return _pull(_bokv(index, sanitize( what )));
    }

    public function min(index:String, value:Dynamic):Modification {
        return _min(_bokv(index, value));
    }

    public function max(index:String, value:Dynamic):Modification {
        return _max(_bokv(index, value));
    }

/* === Internal Methods === */

    public function _each(data: Array<Dynamic>):Dynamic {
        return _bokv(opname('each'), data);
    }

    public function _set(data: Dynamic):Modification {
        return op('set', data);
    }

    public function _increment(data: Dynamic):Modification {
        return op('inc', data);
    }

    public function _unset(data: Dynamic):Modification {
        return op('unset', data);
    }

    public function _push(d: Dynamic):Modification {
        return op('push', d);
    }

    public function _pop(d: Dynamic):Modification {
        return op('pop', d);
    }

    public function _addToSet(d: Dynamic):Modification {
        return op('addToSet', d);
    }

    public function _pull(d: Dynamic):Modification {
        return op('pull', d);
    }

    public function _min(d: Dynamic):Modification {
        return op('min', d);
    }

    public function _max(d: Dynamic):Modification {
        return op('max', d);
    }

/* === Instance Methods === */

    /**
      * convert [this] to a raw Object
      */
    public inline function toObject():Object {
        return o;
    }

    /**
      * add an operator
      */
    private inline function op(name:String, operand:Dynamic):Modification {
        //o[opname(name)] = sanitize( operand );
        o.nativeArraySet(opname(name), sanitize( operand ));
        return this;
    }

    /**
      * build and return an operator-expression
      */
    public function opv(spec: EitherType<Function, {op:String, ?operand:Dynamic}>):Dynamic {
        if (Reflect.isFunction( spec )) {
            return Operators.expr(untyped spec);
        }
        else {
            var spec:{op:String, ?operand:Dynamic} = cast spec;
            return _bokv(opname(spec.op), spec.operand);
        }
    }

    /**
      * sanitize an Object
      */
    private static function sanitize(v : Dynamic):Dynamic {
        if ((v is Modification)) {
            return cast(v, Modification).toObject();
        }
        else if ((v is Query)) {
            return cast(v, Query).toObject();
        }
        else {
            return v;
        }
    }

    /**
      * convert a comma-separated string-list of indices into an Array of indices
      */
    private static function pluralize(i: String):Array<String> {
        return (i.split(',').filter.fn(_.hasContent()).map.fn(_.trim()));
    }

    /**
      * compute the key for an operator
      */
    private static inline function opname(name: String):String {
        return '$$$name';
    }

    /**
      * utility method to construct an Object
      */
    private static inline function _buildObject(f : Object->Void):Object {
        var o:Object = {};
        f( o );
        return o;
    }
    private static inline function _bo(f : Object->Void):Object return _buildObject( f );

    private static function _bokv(k:String, v:Dynamic):Object {
        return _buildObject(function(o) {
            o.nas(k, v);
        });
    }
    private static function _bopv(op:String, args:Dynamic):Object {
        return _bokv(opname(op), sanitize(args));
    }

    /**
      * magically build out multi-property object functionally
      */
    private static function _bokiv(keys:Iterable<String>, value:Dynamic):Object {
        var vit:Null<Iterator<Dynamic>> = null;

        function val(key: String):Dynamic {
            if (Reflect.isFunction( value )) {
                return value( key );
            }
            else if (vit != null) {
                if (vit.hasNext()) {
                    return vit.next();
                }
                else return null;
            }
            else if (vit == null && (Reflect.isObject(value) && Reflect.hasField(value, 'iterator') && Reflect.isFunction(Reflect.field(value, 'iterator')))) {
                vit = cast value.iterator();
                return val( key );
            }
            else {
                return value;
            }
        }

        return _bo(function(o: Object) {
            var it = keys.iterator(), k:String;
            while (it.hasNext()) {
                k = it.next();
                o.nas(k, val( k ));
            }
        });
    }
 

/* === Instance Fields === */

    private var o : Object;

/* === Statics === */

    public static function mb(m : EitherType<Modification, Function>):Modification {
        if (Reflect.isFunction( m )) {
            var mod:Modification = new Modification();
            var result:Null<Dynamic> = untyped m(mod);
            if ((result is Modification)) {
                return cast result;
            }
            else return mod;
        }
        else return cast m;
    }

    private static var ops:Operators = {new Operators();};
}

abstract Mod (EitherType<Modification, Function>) from EitherType<Modification, Function> {
    public inline function new(m : EitherType<Modification, Function>) {
        this = m;
    }

    @:to
    public inline function toMod():Modification return Modification.mb( this );

    @:to
    public inline function toObject():Object return toMod().toObject();

    @:to
    public inline function toDynamic():Dynamic return toObject();

    @:from
    public static inline function fromFunction(f : Function):Mod return new Mod( f );
}
