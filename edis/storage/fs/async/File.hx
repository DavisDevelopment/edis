package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import Slambda.fn;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.extern.EitherType;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

class File extends EntryWrapper {
/* === Instance Methods === */

    /**
      * delete [this] Directory
      */
    override function delete(?done: VoidCb):VoidPromise {
        return fs.deleteFile(path, done);
    }

    public function read(?offset:Int, ?length:Int, ?done:Cb<ByteArray>):Promise<ByteArray> {
        return fs.read(path, offset, length, done);
    }

    public function write(data:FileWriteData, ?done:VoidCb):VoidPromise {
        return fs.write(path, data, done);
    }

    public function truncate(len:Int, ?done:VoidCb):VoidPromise {
        return fs.truncate(path, len, done);
    }

    public inline function directory():Directory {
        return new Directory(new Entry(path.directory, fs, true, false));
    }

    override function is_valid(entry: Entry):Bool {
        return entry.type.match(ETFile);
    }
}
