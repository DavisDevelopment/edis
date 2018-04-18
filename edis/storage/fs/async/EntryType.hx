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

enum EntryType {
    ETFile;
    ETDirectory;
}

enum WrappedEntryType {
    ETFile(file: File);
    ETDirectory(folder: Directory);
}
