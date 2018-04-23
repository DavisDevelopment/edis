package edis.format.bdc;

import tannus.io.*;
import tannus.io.ByteArray;
import tannus.io.ByteArrayBuffer;
import tannus.io.ByteStack;
import tannus.ds.*;
import tannus.async.*;

import Slambda.fn;
import tannus.math.TMath.*;
import haxe.extern.EitherType as Either;
import haxe.Constraints.Function;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.IteratorTools;
using tannus.ds.AnonTools;
using tannus.FunctionTools;

class Data {
    /* Constructor Function */
    public function new(?chunks: Array<DataChunk>):Void {
        this.chunks = (chunks != null ? chunks.copy() : []);
    }

/* === Instance Methods === */

    public function push(chunk: DataChunk):DataChunk {
        chunks.push( chunk );
        return chunk;
    }

    public function append(length:Int, ?offset:Int, ?data:ByteArray):DataChunk {
        return push(new DataChunk(length, offset, data));
    }

    public inline function get(i: Int):Null<DataChunk> {
        return chunks[i];
    }
    public function iterator():Iterator<DataChunk> return chunks.iterator();

    public function totalLength():Int {
        var sum:Int = 0;
        for (x in this)
            sum += x.length;
        return sum;
    }

/* === Computed Instance Fields === */

    public var length(get, never): Int;
    private inline function get_length() return chunks.length;

/* === Instance Fields === */

    @:noCompletion
    public var chunks(default, null): Array<DataChunk>;
}

/*
   a 'Chunk' of binary data
   ...
   that's it. nothing about this abstraction layer dictates how the chunks (as a group or individually) are to be processed
*/
class DataChunk {
    /* Constructor Function */
    public function new(length:Int, offset:Int=0, ?data:ByteArray):Void {
        this.length = length;
        this.offset = offset;
        this.data = data;
    }

/* === Instance Methods === */

    /**
      * assign the value of [this]'s [data] property
      */
    public function setData(d: ByteArray):DataChunk {
        // sanity checks
        if (d.length != length) {
            throw 'Error: Mismatched [length] values between `DataChunk` and provided ByteArray ($length !== ${d.length})';
        }
        this.data = d;
        return this;
    }

    /**
      * provide [this] DataChunk with a reference to the value of its [data] property
      */
    public function setDataPointer(getter: Void->ByteArray):DataChunk {
        if (data_ref == null) {
            data_ref = {
                get: getter
            };
        }
        else {
            throw 'Error: [DataChunk] already has `data_ref` property; cannot be reassigned';
        }
        return this;
    }

    /**
      * check whether [this] DataChunk has data
      */
    public inline function hasData():Bool {
        return (data != null);
    }

    /**
      * check whether [this] DataChunk is readable
      */
    public inline function isReadable():Bool {
        return (data != null || data_ref != null);
    }

    /**
      * get [this] DataChunk's data
      */
    public function read(index:Int=0, ?len:Int):Null<ByteArray> {
        if (len == null) len = length;
        var subset:Bool = (index != 0 || len != length);
        if (data != null) {
            return (subset ? data.slice(index, (index + len)) : data);
        }
        else if (data_ref != null) {
            allocate();
            return read(index, len);
        }
        else {
            return null;
        }
    }

    /**
      * manually assert/ensure that [data] has been loaded, and is accessible in memory
      ---
      this will usually already be done, as the default behavior is to load [data] in as the chunks are parsed, but
      when it is not, a 'pointer' to that data is provided instead
      */
    public function allocate():Void {
        if (!hasData() && data_ref != null) {
            setData(data_ref.get());
            if (hasData()) {
                data_ref = null;
            }
            else {
                throw 'Error: [data_ref] did not return a valid ByteArray';
            }
        }
    }

    /**
      * manually dereference [data] from memory
      */
    public function deallocate():Void {
        data.truncate( 0 );
        data = null;
    }

/* === Computed Instance Fields === */
/* === Instance Fields === */

    // the byte data associated with [this] Chunk
    public var data(default, null): Null<ByteArray>;
    private var data_ref: Null<ChunkDataPtr>;

    // length (in bytes) of [data]
    public var length(default, null): Int;

    // the offset from the start of the input ByteArray
    public var offset(default, null): Int;
}

typedef ChunkDataPtr = {
    get: Void->ByteArray
};
