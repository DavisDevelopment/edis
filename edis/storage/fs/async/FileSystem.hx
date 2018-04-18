package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import tannus.node.ReadableStream;
import tannus.node.WritableStream;
import tannus.node.DuplexStream;
import tannus.node.TransformStream;
import tannus.node.*;

import edis.storage.fs.async.impl.*;
import edis.storage.fs.async.impl.IReadStream;
import edis.streams.*;

import Slambda.fn;

import haxe.Serializer;
import haxe.Unserializer;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

@:keep
@:expose
@:expose('EdisFileSystem')
class FileSystem {
    /* Constructor Function */
    private function new(impl: FileSystemImpl):Void {
        this.i = impl;
    }

/* === Instance Methods === */

    public function exists(path:Path, ?callback:Cb<Bool>):BoolPromise return i.exists(path, callback);

    public function isDirectory(path:Path, ?callback:Cb<Bool>):BoolPromise return i.isDirectory(path, callback);

    public function createDirectory(path:Path, ?done:VoidCb):VoidPromise return i.createDirectory(path, done);

    public function deleteDirectory(path:Path, ?done:VoidCb):VoidPromise return i.deleteDirectory(path, done);

    public function deleteFile(path:Path, ?done:VoidCb):VoidPromise return i.deleteFile(path, done);

    public function rename(oldPath:Path, newPath:Path, ?done:Cb<Path>):Promise<Path> return i.rename(oldPath, newPath, done);

    public function copy(src:Path, target:Path, ?done:Cb<Path>):Promise<Path> return i.copy(src, target, done);

    public function read(path:Path, ?offset:Int, ?length:Int, ?done:Cb<ByteArray>):Promise<ByteArray> return i.read(path, offset, length, done);

    public function readDirectory(path:Path, ?done:Cb<Array<String>>):ArrayPromise<String> return i.readDirectory(path, done);

    public function write(path:Path, data:FileWriteData, ?done:VoidCb):VoidPromise return i.write(path, data, done);

    public function stat(path:Path, ?done:Cb<FileStat>):Promise<FileStat> return i.stat(path, done);

    public function truncate(path:Path, len:Int, ?done:VoidCb):VoidPromise return i.truncate(path, len, done);

    public function createReadStream(path:Path, ?options:CreateFileReadStreamOptions, ?callback:Cb<ReadableStream<ByteArray>>):ReadableStream<ByteArray> {
        return i.createReadStream(path, options, callback);
    }

    /**
      * get an Entry for the given Path
      */
    public function get(path:Path, ?cb:Cb<Entry>):Promise<Entry> {
        return new Promise<Entry>(function(yes, no) {
            exists( path ).then(function(doesExist) {
                if ( doesExist ) {
                    isDirectory( path ).then(function(isDir) {
                        var entry:Entry = new Entry(path, this, isDir, !isDir);
                        yes( entry );
                    }).unless(cast no);
                }
                else {
                    no(new FileError(NotFoundError, 'File not found: "$path"'));
                }
            }).unless(cast no);
        }).toAsync( cb );
    }

    private function ew<T:EntryWrapper>(path:Path, make:Entry->T, ?done:Cb<T>):Promise<T> {
        return get( path ).transform( make ).toAsync( done );
    }

    public function directory(path:Path, ?cb:Cb<Directory>):Promise<Directory> {
        return ew(path, fn(new Directory(_)), cb);
    }

    public function file(path:Path, ?cb:Cb<File>):Promise<File> {
        return ew(path, fn(new File(_)), cb);
    }

/* === Instance Fields === */

    private var i: FileSystemImpl;

/* === Factory Methods === */

    public static function node():FileSystem return new FileSystem(new NodeFileSystemImpl());
}
