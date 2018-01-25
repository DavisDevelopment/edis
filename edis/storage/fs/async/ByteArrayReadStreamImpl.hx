package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;

import edis.Globals.*;

//import haxe.ds.Option;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.Asyncs;
using tannus.math.TMath;

class ByteArrayReadStreamImpl extends ReadStreamImpl<ByteArray> {
    /* Constructor Function */
    public function new():Void {
        super();

        setBuffering( true );

        __onReadable = new VoidSignal();
        chunkSize = null;
        forceAsync = false;
    }

/* === Instance Methods === */

    /**
      * get the total length of all buffered data
      */
    public function readableLength():Int {
        if (bfr.hasContent()) {
            return bfr.sumf.fn( _.length ).i();
        }
        else return 0;
    }

    /**
      * check whether there is 
      */

    /**
      * read directly from data buffer
      * when [size] is provided, up to [size] bytes are read from buffer, otherwise all buffered data is read
      * when [exact] is 'true' and [size] is provided, exactly [size] bytes are read from buffer.
      * when [exact] is 'true' and there is not at least [size] bytes buffered, no data is removed from the buffer, and 'null' is returned
      */
    public function read(?size:Int, ?exact:Bool=false):Null<ByteArray> {
        if (bfr.empty()) {
            return null;
        }
        else {
            if (size == null) {
                var tmp = bfr;
                bfr = [];
                return _join( tmp );
            }
            else {
                var chunks:Array<ByteArray> = new Array();
                var resLength:Int = 0;
                while (!bfr.empty() && resLength < size) {
                    var ch:ByteArray = bfr[0];
                    if ((size - resLength) >= ch.length) {
                        chunks.push(bfr.shift());
                        resLength += ch.length;
                    }
                    else {
                        var chs:ByteArray;
                        chunks.push(chs = ch.splice(0, (size - resLength)));
                        resLength += chs.length;
                    }
                }
                if (exact && resLength < size) {
                    bfr = chunks.concat( bfr );
                    return null;
                }

                var res = _join( chunks );
                return res;
            }
        }
    }

    /**
      * set handler for when new data becomes available on [this] stream
      */
    public function onReadable(f:Void->Void, ?once:Bool=false):Void {
        (once ? __onReadable.once : __onReadable.on)( f );
    }

    override function __flush():Void {
        bfr = [];
    }

    override function __start():Void {
        super.__start();
        onData(function(chunk: ByteArray) {
            if ( __allowBuffering ) {
                defer(function() {
                    if (readableLength() > 0) {
                        __onReadable.fire();
                    }
                });
            }
        });
    }

    override function __destroy():Void {
        bfr = [];
    }

    override function __buffer(chunk: ByteArray):Void {
        if (chunkSize == null) {
            super.__buffer( chunk );
        }
        else {
            while (chunk.length > chunkSize) {
                __chunkBuffer.push(chunk.splice(0, chunkSize));
            }
            if (chunk.length > 0)
                __chunkBuffer.push( chunk );
        }
    }

    override function __send(chunk: ByteArray):Void {
        if (chunkSize == null) {
            super.__send( chunk );
        }
        else {
            // break [chunk] into slices of [chunkSize]
            while (chunk.length > chunkSize) {
                super.__send(chunk.splice(0, chunkSize));
            }
            if (chunk.length > 0) {
                super.__send( chunk );
            }
        }
    }

    /**
      * join a list of ByteArrays
      */
    private static function _join(i: Iterable<ByteArray>):ByteArray {
        var res:ByteArrayBuffer = new ByteArrayBuffer();
        for (b in i) {
            res.add( b );
        }
        return res.getByteArray();
    }

/* === Computed Instance Fields === */

    private var bfr(get, set):Array<ByteArray>;
    private inline function get_bfr() return __chunkBuffer;
    private inline function set_bfr(v) return (__chunkBuffer = v);

/* === Instance Fields === */

    private var __onReadable: VoidSignal;

    private var chunkSize: Null<Int>;
    private var forceAsync: Bool;
}
