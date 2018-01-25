package edis.storage.fs.async.impl;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import Slambda.fn;
import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

interface IReadStream<T> {
    function open():Void;
    function pause():Void;
    function resume():Void;
    function isPaused():Bool;
    function setBuffering(v: Bool):Void;
    function flush():Void;
    function destroy():Void;
    function onData(f:T->Void, ?once:Bool):Void;
    function onError(f:Dynamic->Void, ?once:Bool):Void;
    function onEnd(f:Void->Void):Void;
    function onClose(f:Void->Void):Void;
}

interface IByteArrayReadStream extends IReadStream<ByteArray> {
    function onReadable(f:Void->Void, ?once:Bool):Void;
    function read(?size:Int, ?exact:Bool):Null<ByteArray>;
    function readableLength():Int;
}

interface IFileReadStream extends IByteArrayReadStream {
    var path(get, never): Path;
    var options: FileReadStreamOptions;
}

typedef FileReadStreamOptions = {
    ?start: Int,
    ?end: Int,
    ?chunkSize: Int,
    autoClose: Bool,
    forceAsync: Bool
};

typedef CreateFileReadStreamOptions = {
    ?start: Int,
    ?end: Int,
    ?encoding: String,
    ?autoClose: Bool,
    ?chunkSize: Int,
    ?forceAsync: Bool
};
