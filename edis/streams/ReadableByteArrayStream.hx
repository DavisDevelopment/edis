package edis.streams;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;
import tannus.node.*;
import tannus.node.ReadableStream;

import Slambda.fn;
import edis.Globals.*;

using tannus.FunctionTools;
using tannus.html.JSTools;

class ReadableByteArrayStream extends ReadableStream<ByteArray> {
    /* Constructor Function */
    public function new(?o: ReadableStreamOptions):Void {
        super(_.defaults({
            highWaterMark: 16,
            objectMode: true
        }, o));
    }

/* === Instance Methods === */

    public function toBufferStream():ReadableStream<Buffer> {
        function bread(self:ReadableStream<Buffer>, ?size:Int) {
            function da(chunk: ByteArray) {
                if (!self.push(chunk.getData())) {
                    this.removeListener('data', da);
                }
            }
            onData( da );
            read();
        }

        var bufferStream = new ReadableStream({
            objectMode: false,
            encoding: 'buffer',
            read: bread.fthis()
        });

        inline function fwd(evt:String) {
            addListener(evt, bufferStream.emit.bind(evt, _));
        }
        fwd('error');
        fwd('readable');
        fwd('close');
        fwd('end');

        return bufferStream;
    }
}

class WrappedReadableByteArrayStream extends ReadableByteArrayStream {
    private var src: ReadableStream<Buffer>;
    public function new(stream: ReadableStream<Buffer>) {
        super();

        src = stream;
        inline function fwd(e:String)
            src.on(e, emit.bind( e ));
        for (evt in ['error', 'end', 'close', 'readable'])
            fwd( evt );
        src.onData(function(chunk: Buffer) {
            if (!push(ByteArray.ofData(cast chunk))) {
                src.pause();
            }
        });
    }

    override function _read(?size: Int):Void {
        if (src.isPaused()) {
            src.resume();
        }
        src.read( size );
    }
}
