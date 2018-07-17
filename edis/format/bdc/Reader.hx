package edis.format.bdc;

import tannus.io.*;
import tannus.io.ByteArray;
import tannus.io.ByteArrayBuffer;
import tannus.io.ByteStack;
import tannus.ds.*;
import tannus.async.*;
import tannus.math.TMath;

import edis.format.bdc.Data;

import Slambda.fn;
import tannus.math.TMath.*;
import haxe.extern.EitherType as Either;
import haxe.Constraints.Function;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.IteratorTools;
using tannus.ds.AnonTools;
using tannus.FunctionTools;

class Reader {
    /* Constructor Function */
    public function new(opts: ReaderOpts):Void {
        this.opts = _fill_opts( opts );
        this.output = new Data();
    }

/* === Instance Methods === */

    /**
      * read through [b], parsing it into DataChunks
      */
    public function read(b: ByteArray):Data {
        this.input = b;
        input_offset = 0;

        _consume_all();
        return output;
    }

    private function _consume_all():Void {
        while ((input.length - input_offset) > 0) {
            _consume_chunk();
        }
        trace('[== `consume_all` did not recur infinitely :D ==]');
    }

    /**
      * read a [DataChunk] from [input], moving the 'cursor' forward as we go
      */
    private function _consume_chunk():Void {
        if ((input.length - input_offset) > 0) {
            if (input.get(bi()) == opts.tokens.chunk) {
                var stbl:Int = opts.sizeTokenByteLength;
                if (stbl != 4) {
                    throw 'FormatError: Unsupported size-token byte-length (${stbl})';
                }
                else {
                    adv();
                    var size:Int = input.getUInt32(bi());
                    adv(opts.sizeTokenByteLength);
                    trace('chunk size:', size);
                    var chunk = output.append(size, input_offset);
                    if ( opts.autoLoadChunkData ) {
                        var chunkBytes = input.slice(input_offset, bi( size ));
                        trace('slice range: $input_offset-${bi(size)}');
                        chunk.setData( chunkBytes );
                    }
                    else {
                        var tmp_offset:Int = input_offset, tmp_input = input;
                        chunk.setDataPointer(fn(tmp_input.slice(tmp_offset, (tmp_offset + size))));
                        trace('chunk has been given a Pointer');
                    }
                    adv( size );
                    trace('chunk parsed/consumed');
                    return ;
                }
            }
            else {
                throw 'FormatError: Invalid `bdc` format';
            }
        }
    }

    private inline function bi(index: Int = 0):Int return (input_offset + index);
    private inline function adv(n:Int = 1):Int return (input_offset += n);

    private static function _fill_opts(o: ReaderOpts):ReaderOpts {
        if (o.tokens == null) {
            var tk = o.tokens = {};
            if ((tk.chunk : Int) == null) {
                tk.chunk = 123;
            }
        }

        if (o.sizeTokenByteLength == null) {
            o.sizeTokenByteLength = 4;
        }

        if (o.maximumChunkByteLength == null) {
            o.maximumChunkByteLength = -1;
        }

        if (o.autoLoadChunkData == null) {
            o.autoLoadChunkData = true;
        }

        return o;
    }

/* === Static Methods === */

    public static function run(o:ReaderOpts, b:ByteArray):Data {
        return (new Reader( o ).read( b ));
    }

/* === Computed Instance Fields === */
/* === Instance Fields === */

    private var opts: ReaderOpts;
    private var output: Data;
    private var input : ByteArray;
    private var input_offset: Int = 0;
}

typedef ReaderOpts = {
    // options regarding the format's tokens
    ?tokens: ReaderTokenOpts,

    // length of the [size] token in bytes, which is 4 by default (unsigned 32bit integer)
    ?sizeTokenByteLength: Int,

    // maximum allowed length of a chunk in bytes, defaults to -1 (no enforced limit)
    ?maximumChunkByteLength: Int,

    // whether to read the chunks' ByteArray data into memory as we go (defaults to true)
    ?autoLoadChunkData: Bool
};

typedef ReaderTokenOpts = {
    // byte that marks start of a 'chunk' item (defaults to 123)
    ?chunk: Byte
};
