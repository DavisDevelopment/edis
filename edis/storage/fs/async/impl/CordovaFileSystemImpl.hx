package edis.storage.fs.async.impl;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;
import tannus.html.fs.*;

import Slambda.fn;
import edis.libs.cordova.CordovaFile;

import haxe.Serializer;
import haxe.Unserializer;

import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class CordovaFileSystemImpl extends FileSystemImpl {
    /* Constructor Function */
    public function new():Void {
        super();

        dirs = new Dict();
    }

/* === Instance Methods === */

    /**
      *
      */
    override function exists(path:Path, ?done:Cb<Bool>):Promise<Bool> {
        return derive(path, done, function(dir) {
            return dir.exists( path );
        });
    }

    override function isDirectory(path:Path, ?done:Cb<Bool>):Promise<Bool> {
        return derive(path, done, function(dir) {
            return dir.getDirectory( path ).transform(@ignore function(d) {
                if (d == null) {
                    return false;
                }
                else {
                    return true;
                }
            });
        });
    }

    /**
      * derive one promise from another
      */
    private function derive<T, P:Promise<T>>(path:Path, ?done:Cb<T>, f:WebDirectoryEntry->P):P {
        return wrap(Promise.create({
            resolveRoot(path).then(function(dir) {
                return @forward f( dir );
            }, error->throw error);
        }), done);
    }

    /**
      * resolve a root Directory from the given Path
      */
    private function resolveRoot(path : Path):Promise<WebDirectoryEntry> {
        return resolveRootFromName(rootName(path.normalize().pieces[0]));
    }

    /**
      * get the Path to a root
      */
    private function rootName(name : String):String {
        switch (name) {
            case 'app', 'application':
                return CordovaFile.applicationDirectory;
            case 'appstorage', 'applicationstorage':
                return CordovaFile.applicationStorageDirectory;
            case 'data':
                return CordovaFile.dataDirectory;
            case 'cache':
                return CordovaFile.cacheDirectory;
            case 'temp':
                return CordovaFile.tempDirectory;
            case 'external', 'external-storage':
                return CordovaFile.externalApplicationStorageDirectory;
            case 'externaldata', 'external-data':
                return CordovaFile.externalDataDirectory;
            case 'externalroot', 'external-root':
                return CordovaFile.externalRootDirectory;
            case 'externalcache', 'external-cache':
                return CordovaFile.externalCacheDirectory;
            case _:
                throw 'WhatTheFuck';
        }
    }

    /**
      * resolve root Directory from its name
      */
    private function resolveRootFromName(name : String):Promise<WebDirectoryEntry> {
        return new Promise(function(yes, no) {
            if (dirs.exists(name)) {
                defer(yes.bind(dirs[name]));
            }
            else {
                CordovaFile.resolve(name, function(dir:js.html.Directory) {
                    yes(dirs[name] = new WebDirectoryEntry(cast dir));
                }, no);
            }
        });
    }

/* === Instance Fields === */

    private var dirs : Dict<String, WebDirectoryEntry>;
}
