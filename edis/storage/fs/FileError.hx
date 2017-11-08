package edis.storage.fs;

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

class FileError {
    /* Constructor Function */
    public function new(type:FileErrorType, message:String):Void {
        this.type = type;
        this.message = message;
    }

/* === Instance Fields === */

    public var type(default, null):FileErrorType;
    public var message(default, null):String;
}
