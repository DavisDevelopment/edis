package edis.format.bdc;

import tannus.io.*;
import tannus.io.ByteArray;
import tannus.io.ByteArrayBuffer;
import tannus.ds.*;
import tannus.async.*;
import tannus.math.TMath;

import edis.format.bdc.Data;

import haxe.io.Output;
import haxe.io.BytesOutput;
import haxe.io.BytesBuffer;
import haxe.io.Error as IOError;

import Slambda.fn;
import tannus.math.TMath.*;
import haxe.extern.EitherType as Either;
import haxe.Constraints.Function;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.IteratorTools;
using tannus.ds.AnonTools;
using tannus.FunctionTools;
using tannus.math.TMath;

class Writer {
    /* Constructor Function */
    public function new(o: WriterOps) {
        options = o;
        if (o.delimiter == null)
            o.delimiter = 123;
        if (o.sizeByteLength == null)
            o.sizeByteLength = 4;
        if (o.maxChunkByteLength == null)
            o.maxChunkByteLength = -1;

        piping = false;
    }

/* === Instance Methods === */

    public function write(data:Data, ?output:Output):Null<ByteArray> {
        this.data = data;
        this.b = new BytesBuffer();
        if (output != null) {
            this.output = output;
            piping = true;
        }
        else {
            this.output = null;
            piping = false;
        }

        for (chunk in data) {
            
        }
    }

    function writeChunk(chunk: DataChunk) {
        if (!chunk.isReadable())
            throw 'Error: Cannot write NULL DataChunk. DataChunk could not be read';
        var cb:ByteArray = chunk.read();

    }

    function writeChunkSize(len: Int) {
        switch options.sizeByteLength {
            case 1: b.length
            case 2: output.writeInt8()
        }
    }

/* === Instance Fields === */

    var options: WriterOpts;
    var data: Data;

    var output: Null<Output>;
    var b: BytesBuffer;
    var piping:Bool;
}

typedef WriterOpts = {
    ?delimiter: Byte,
    ?sizeByteLength: Int,
    ?maxChunkByteLength: Int
};
