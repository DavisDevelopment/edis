package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import Slambda.fn;

import edis.storage.fs.async.EntryType;

import haxe.Serializer;
import haxe.Unserializer;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

/**
  *
  */
class Entry {
    /* Constructor Function */
    public function new(path:Path, fs:FileSystem, isDirectory:Bool, isFile:Bool):Void {
        this.path = path;
        this.fs = fs;
        this.isDirectory = isDirectory;
        this.isFile = isFile;
        this.type = (switch ([isFile, isDirectory]) {
            case [true, false]: EntryType.ETFile;
            case [false, true]: EntryType.ETDirectory;
            case _: throw 'Betty: What the fuck?';
        });

        js.Object.preventExtensions( this );
    }

/* === Instance Methods === */

    private inline function ew<T:EntryWrapper>(make:Entry->T, check:Entry->Bool):Null<T> {
        if (check( this )) {
            return make( this );
        }
        else {
            return null;
        }
    }

    /**
      * convert [this] Entry to a Directory object
      */
    public function directory():Null<Directory> {
        var dir = ew(fn(new Directory(_)), fn(_.type.match(ETDirectory)));
        if (dir == null) {
            throw new FileError(TypeMismatchError, '${this} is not a directory');
        }
        return dir;
    }

    /**
      * convert [this] Entry to a File object
      */
    public function file():Null<File> {
        var f:Null<File> = ew(fn(new File(_)), fn(_.type.match(ETFile)));
        if (f == null) {
            throw new FileError(TypeMismatchError, '${this} is not a valid file');
        }
        return f;
    }

    /**
      * convert [this] to its 'wrapped' type
      */
    public function wrapped():WrappedEntryType {
        return (switch ( type ) {
            case ETFile: ETFile(file());
            case ETDirectory: ETDirectory(directory());
        });
    }

    /**
      * display [this] as a String
      */
    public function toString():String {
        return 'Entry("$path")';
    }

/* === Instance Fields === */

    public var path : Path;
    public var fs : FileSystem;
    public var isDirectory : Bool;
    public var isFile : Bool;
    public var type : EntryType;
}
