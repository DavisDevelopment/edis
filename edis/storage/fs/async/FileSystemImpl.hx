package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

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
        //
    }

/* === Instance Methods === */

    public function exists(path:Path, ?callback:Cb<Bool>):Promise<Bool> {
        throw 'not implemented';
    }

    public function isDirectory(path:Path, ?callback:Cb<Bool>):Promise<Bool> {
        throw 'not implemented';
    }

    public function createDirectory(path:Path, ?done:Cb<Path>):Promise<Path> {
        throw 'not implemented';
    }

    public function deleteDirectory(path:Path, ?done:Cb<Path>):Promise<Path> {
        throw 'not implemented';
    }

    public function deleteFile(path:Path, ?done:Cb<Path>):Promise<Path> {
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

    public function readDirectory(path:Path, recursive:Bool=false, ?done:Cb<Array<Path>>):ArrayPromise<Path> {
        throw 'not implemented';
    }

    public function write(path:Path, data:ByteArray, ?done:Cb<Path>):Promise<Path> {
        throw 'not implemented';
    }

    public function stat(path:Path, ?done:Cb<FileStat>):Promise<FileStat> {
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
}
