package edis.storage.fs;

import tannus.io.*;
import tannus.ds.*;
import tannus.ds.Thunk;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import Slambda.fn;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.extern.EitherType;
import haxe.Constraints.Function;
import haxe.io.Bytes;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

abstract FileWriteData (TFileWriteData) from TFileWriteData to TFileWriteData {
    /* Constructor Function */
    public inline function new(data: TFileWriteData) {
        this = data;
    }

/* === Instance Methods === */

    @:to
    public function toByteArray():ByteArray {
        if ((this is tannus.io.Binary)) {
            return this;
        }
        else if ((this is tannus.io.BinaryData)) {
            return ByteArray.ofData(untyped this);
        }
        else if ((this is String)) {
            return ByteArray.ofString( this );
        }
        else if ((this is Bytes)) {
            return ByteArray.fromBytes( this );
        }
        else if (Reflect.isFunction( this )) {
            return fromDynamic((untyped this)()).toByteArray();
        }
        else {
            throw 'TypeError: Invalid FileWriteData';
        }
        return ByteArray.alloc( 0 );
    }

    @:from
    public static inline function fromString<T:String>(string: T):FileWriteData return new FileWriteData(cast(string, String));

    @:from
    public static inline function fromBytes<T:Bytes>(bytes: T):FileWriteData return new FileWriteData(cast(bytes, Bytes));

    @:from
    public static inline function fromByteArray<T:ByteArray>(bytes: T):FileWriteData return new FileWriteData(cast bytes);

    @:from
    public static inline function fromFunc(f: Function):FileWriteData return new FileWriteData(untyped f);

    @:from
    public static function fromDynamic(x: Dynamic):FileWriteData {
        if ((x is String)) {
            return new FileWriteData(cast(x, String));
        }
        else if ((x is tannus.io.Binary)) {
            return new FileWriteData(cast(x, tannus.io.Binary));
        }
        else if ((x is tannus.io.BinaryData)) {
            return fromByteArray(ByteArray.ofData(cast x));
        }
        else if ((x is Bytes)) {
            return fromBytes(cast x);
        }
        else if (Reflect.isFunction( x )) {
            return fromFunc( x );
        }
        else {
            throw 'TypeError: Invalid FileWriteData';
        }
        return fromString('');
    }

/* === Instance Fields === */
}

typedef TFileWriteData = EitherType<EitherType<String, ByteArray>, EitherType<Bytes, Void->TFileWriteData>>;
