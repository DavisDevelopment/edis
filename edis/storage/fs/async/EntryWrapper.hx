package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import Slambda.fn;
import edis.Globals.*;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.extern.EitherType;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

class EntryWrapper {
    /* Constructor Function */
    public function new(entry: Entry):Void {
        if (!is_valid( entry )) {
            invalid( entry );
        }

        this.entry = entry;
    }

/* === Instance Methods == */

    public function delete(?done:VoidCb):VoidPromise {
        ni();
    }

    public function rename(newPath:Path, ?done:VoidCb):VoidPromise {
        return new VoidPromise(function(resolve, reject) {
            fs.rename(path, newPath).then(function(newPath: Path) {
                fs.get( newPath ).then(function(newEntry: Entry) {
                    this.entry = newEntry;
                    defer( resolve );
                }, reject);
            }, reject);
        }).toAsync( done );
    }

    public function stat(?done:Cb<FileStat>):Promise<FileStat> {
        return fs.stat(path, done);
    }

    /**
      * simply throw a 'Not Implemented' error
      */
    private inline function ni():Void {
        throw 'Not Implemented';
    }

    /**
      * check whether [entry] is valid
      */
    private function is_valid(entry: Entry):Bool {
        return true;
    }

    /**
      * generate invalidity error for [entry]
      */
    private function invalid_error(entry: Entry):Dynamic {
        return null;
    }

    /**
      * throw invalid error
      */
    private function invalid(entry: Entry):Void {
        var error = invalid_error( entry );
        if (error == null) {
            error = new FileError(FileErrorType.CustomError('InvalidError'), 'Entry(${entry.path}) is not valid');
        }
        throw error;
    }

/* === Computed Instance Fields == */

    public var fs(get, never): FileSystem;
    private inline function get_fs() return entry.fs;

    public var path(get, never): Path;
    private inline function get_path() return entry.path;

    public var entryType(get, never): EntryType;
    private inline function get_entryType() return entry.type;

/* === Instance Fields == */

    public var entry(default, null): Entry;
}
