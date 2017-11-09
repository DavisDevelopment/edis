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

class Entry {
    /* Constructor Function */
    public function new(path:Path, name:String, isDirectory:Bool, isFile:Bool):Void {
        this.path = path;
        this.name = name;
        this.isDirectory = isDirectory;
        this.isFile = isFile;
        this.type = (switch ([isFile, isDirectory]) {
            case [true, false]: EntryType.ETFile;
            case [false, true]: EntryType.ETDirectory;
            case _: throw 'Betty: What the fuck?';
        });

        js.Object.freeze( this );
    }

/* === Instance Methods === */

/* === Instance Fields === */

    public var path : Path;
    public var name : String;
    public var isDirectory : Bool;
    public var isFile : Bool;
    public var type : EntryType;
}
