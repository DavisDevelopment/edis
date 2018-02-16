package edis.streams;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;
import tannus.node.*;
import tannus.node.ReadableStream;
import tannus.node.WritableStream;

import Slambda.fn;
import edis.Globals.*;

using tannus.FunctionTools;
using tannus.html.JSTools;

class WritableByteArrayStream extends WritableStream<ByteArray> {
    /* Constructor Function */
    public function new(?o: WritableStreamOptions):Void {
        super(_.defaults({
            objectMode: true,
            highWaterMark: 16
        }, o));
    }

/* === Instance Methods === */

    /**
      * create a WritableStream<Buffer> from [this]
      */
    public function toBufferStream():WritableStream<Buffer> {
        function bwrite(self:WritableStream<Buffer>, chunk:Buffer, encoding:String, next:VoidCb) {
            write(ByteArray.ofData( chunk ), next);
        }

        function bdestroy(self:WritableStream<Buffer>, error:Null<Dynamic>, next:VoidCb) {
            destroy( error );
            defer(next.void());
        }

        var res:WritableStream<Buffer> = new WritableStream({
            objectMode: false,
            encoding: 'buffer',
            write: bwrite.fthis(),
            destroy: bdestroy.fthis()
        });

        inline function fwd(evt: String):Void {
            addListener(evt, res.emit.bind(evt, _));
        }

        fwd( 'error' );
        fwd( 'close' );
        fwd( 'drain' );
        fwd( 'finish' );

        return res;
    }
}

class WrappedWritableByteArrayStream extends WritableByteArrayStream {
    private var dest: WritableStream<Buffer>;
    public function new(stream: WritableStream<Buffer>):Void {
        super();

        dest = stream;

        inline function fwd(evt: String)
            dest.on(evt, emit.bind( evt ));
        for (evt in ['close', 'drain', 'error'])
            fwd( evt );
    }

    override function _write(chunk:ByteArray, encoding:String, next:VoidCb):Void {
        dest.write(buf( chunk ), encoding, next);
    }

    override function _destroy(error:Null<Dynamic>, next:VoidCb):Void {
        next( error );
    }

    override function _final(next: VoidCb):Void {
        dest.onceFinish(next.void());
        dest.destroy();
    }

    private static inline function buf(d: ByteArray):Buffer return untyped d.getData();
}
