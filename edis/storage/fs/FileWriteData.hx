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
            return cast this;
        }
        else if ((this is tannus.io.BinaryData)) {
            return ByteArray.ofData( this );
        }
        else if ((this is String)) {
            return ByteArray.ofString(cast this);
        }
        else if ((this is Bytes)) {
            return ByteArray.fromBytes(cast this);
        }
        else if (Reflect.isFunction( this )) {
            var thunk:Thunk<FileWriteData> = new Thunk(untyped this);
            return thunk.resolve().toByteArray();
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
    public static inline function fromThunk<T:TFileWriteData>(thunk: Thunk<T>):FileWriteData {
        return new FileWriteData(thunk.resolve());
    }

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
            return fromThunk(cast x);
        }
        else {
            throw 'TypeError: Invalid FileWriteData';
        }
        return fromString('');
    }

/* === Instance Fields === */
}

typedef TFileWriteData = EitherType<EitherType<String, ByteArray>, EitherType<Bytes, Thunk<TFileWriteData>>>;
