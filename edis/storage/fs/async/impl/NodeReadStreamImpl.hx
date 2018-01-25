package edis.storage.fs.async.impl;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import tannus.node.Buffer;
import tannus.node.Fs;
import tannus.node.ReadableStream;
import tannus.node.Error;

import Slambda.fn;

import haxe.Serializer;
import haxe.Unserializer;

import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

class NodeReadStreamImpl<Stream:ReadableStream> extends ByteArrayReadStreamImpl {
    /* Constructor Function */
    public function new(rstream: Stream):Void {
        super();

        s = rstream;
    }

    override function __start():Void {
        super.__start();

        s.onData(function(chunk: Buffer) {
            __send(ByteArray.ofData( chunk ));
        });
        s.onError(err -> __raise( err ));
        s.onClose(function() {
            __close();
        });
        s.onEnd(function() {
            __end();
        });
    }

    override function __pause():Void s.pause();
    override function __resume():Void s.resume();
    override function __isPaused():Bool return s.isPaused();
    override function __destroy():Void {
        super.__destroy();
        s.destroy();
        s = null;
    }

    private var s: Stream;
}
