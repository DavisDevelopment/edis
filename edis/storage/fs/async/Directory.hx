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

class Directory extends EntryWrapper {
    /* Constructor Function */
    public function new(entry: Entry):Void {
        super( entry );
    }

/* === Instance Methods == */

    /**
      * delete [this] Directory
      */
    override function delete(?done: VoidCb):VoidPromise {
        return fs.deleteDirectory(path, done);
    }

    /**
      * read the paths in [this] Directory
      */
    public function read(?done: Cb<Array<String>>):ArrayPromise<String> {
        return fs.readDirectory(path, done);
    }

    /**
      * get all subpaths of [this] one
      */
    public function ls(?done: Cb<Array<Path>>):ArrayPromise<Path> {
        return read().map(name -> path.plusString( name ));
    }

    /**
      * get all sub-entries of [this]
      */
    public function entries(?done: Cb<Array<Entry>>):ArrayPromise<Entry> {
        return (ls().map(path -> fs.get( path )).transform(cast Promise.all).array());
    }

    /**
      * get a sub-entry of [this]
      */
    public function get(sub:Path, ?done:Cb<Entry>):Promise<Entry> {
        return fs.get(path.plusPath(sub), done);
    }

    /**
      * get a file in [this] directory
      */
    public function file(filePath:Path, ?done:Cb<File>):Promise<File> {
        return ew(filePath, fn(new File(_)), done);
    }

    public function directory(dirPath:Path, ?done:Cb<Directory>):Promise<Directory> {
        return ew(dirPath, fn(new Directory(_)), done);
    }

    private function ew<T:EntryWrapper>(sub:Path, make:Entry->T, ?cb:Cb<T>):Promise<T> {
        return get(sub).transform( make ).toAsync( cb );
    }

    /**
      * check that [entry] is valid
      */
    override function is_valid(entry: Entry):Bool {
        return entry.type.match(ETDirectory);
    }
}
