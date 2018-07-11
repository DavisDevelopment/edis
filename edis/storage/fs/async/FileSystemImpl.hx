package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import edis.storage.fs.async.impl.IReadStream;

import tannus.node.ReadableStream;
import tannus.node.WritableStream;
import tannus.node.DuplexStream;
import tannus.node.TransformStream;
import tannus.node.*;

import Slambda.fn;

import haxe.Serializer;
import haxe.Unserializer;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class FileSystemImpl {
    /* Constructor Function */
    public function new():Void {
        root = null;
    }

/* === Instance Methods === */

    public function exists(path:Path, ?callback:Cb<Bool>):BoolPromise {
        throw 'not implemented';
    }

    public function isDirectory(path:Path, ?callback:Cb<Bool>):BoolPromise {
        throw 'not implemented';
    }

    public function createDirectory(path:Path, ?done:VoidCb):VoidPromise {
        throw 'not implemented';
    }

    public function deleteDirectory(path:Path, ?done:VoidCb):VoidPromise {
        throw 'not implemented';
    }

    public function deleteFile(path:Path, ?done:VoidCb):VoidPromise {
        throw 'not implemented';
    }

    public function rename(oldPath:Path, newPath:Path, ?done:Cb<Path>):Promise<Path> {
        throw 'not implemented';
    }

    public function copy(src:Path, target:Path, ?done:Cb<Path>):Promise<Path> {
        throw 'not implemented';
    }

    public function read(path:Path, ?offset:Int, ?length:Int, ?done:Cb<ByteArray>):Promise<ByteArray> {
        throw 'not implemented';
    }

    public function readDirectory(path:Path, ?done:Cb<Array<String>>):ArrayPromise<String> {
        throw 'not implemented';
    }

    public function write(path:Path, data:FileWriteData, ?options:{?mode:Int, ?flags:String}, ?done:VoidCb):VoidPromise {
        throw 'not implemented';
    }

    /**
      modeVals=(mode)=>[mode & 0o6, (mode >> 3) & 0o6, (mode >> 6) & 0o6]
      vals2mode=([a,b,c], res=0)=>(res=a, res=(res << 3)+b, res=(res<<3)+c, res)
     **/
    function _write_options(o:{?mode:Int, ?flags:String}) {
        if (o == null)
            o = {};
        if (o.mode == null)
            o.mode = 438;
        if (o.flags == null)
            o.flags = 'w';
        return o;
    }

    public function stat(path:Path, ?done:Cb<FileStat>):Promise<FileStat> {
        throw 'not implemented';
    }

    public function truncate(path:Path, len:Int, ?done:VoidCb):VoidPromise {
        throw 'not implemented';
    }

    public function createReadStream(path:Path, ?options:CreateFileReadStreamOptions, ?done:Cb<ReadableStream<ByteArray>>):ReadableStream<ByteArray> {
        throw 'not implemented';
    }

    public function createWriteStream(path:Path, ?options:CreateFileWriteStreamOptions, ?done:Cb<WritableStream<ByteArray>>):WritableStream<ByteArray> {
        throw 'not implemented';
    }

/* === Utility Methods === */

    /**
      * wraps a Promise to also accept an optional callback
      */
    private function wrap<T, P:Promise<T>>(callback:Null<Cb<T>>, promise:P):P {
        if (callback != null) {
            promise.then(callback.yield(), callback.raise());
        }
        return promise;
    }

/* === Instance Fields === */

    private var root: Null<Path>;
}

