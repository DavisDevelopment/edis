package edis.storage.fs.async.impl;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import tannus.node.Buffer;
import tannus.node.Fs;
import tannus.node.Fs.FileReadStream;
import tannus.node.ReadableStream;
import tannus.node.Error;

import edis.storage.fs.async.impl.IReadStream;

import haxe.Serializer;
import haxe.Unserializer;

import edis.Globals.*;
import Slambda.fn;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

class NodeFileReadStreamImpl extends NodeReadStreamImpl<FileReadStream> implements edis.storage.fs.async.impl.IReadStream.IFileReadStream {
    /* Constructor Function */
    public function new(s: FileReadStream):Void {
        super( s );

        _path = null;
    }

/* === Instance Methods === */

    public inline function setOptions(o : FileReadStreamOptions):Void {
        options = o;
        chunkSize = options.chunkSize;
        forceAsync = options.forceAsync;
    }

/* === Computed Instance Fields === */

    public var path(get, never):Path;
    private function get_path() {
        if (_path == null) {
            var spath: String;
            if ((s.path is String))
                spath = cast s.path;
            else if ((s.path is Buffer))
                spath = cast(s.path, Buffer).toString('utf8');
            else
                spath = Std.string( s.path );
            _path = Path.fromString( spath );
        }
        return _path;
    }

    public var bytesRead(get, never):Int;
    private inline function get_bytesRead() return s.bytesRead;

/* === Instance Fields === */

    public var options: FileReadStreamOptions;
    private var _path: Null<Path>;
}
