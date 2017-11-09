package edis.storage.fs.async.impl;

import tannus.io.*;
import tannus.ds.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.Promise;
import tannus.async.VoidPromise;
import tannus.async.promises.*;
import tannus.html.fs.*;

import Slambda.fn;
import edis.libs.cordova.CordovaFile;

import haxe.Serializer;
import haxe.Unserializer;

import edis.Globals.*;

import js.html.Exception;
import js.html.DOMException;
import js.html.DOMException.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class CordovaFileSystemImpl extends FileSystemImpl {
    /* Constructor Function */
    public function new():Void {
        super();

        roots = new Dict();
        entries = new Dict();
        etc = new Dict();
        paths = new Set();
    }

/* === Instance Methods === */

    /**
      *
      */
    override function exists(path:Path, ?done:Cb<Bool>):Promise<Bool> {
        return derive(path, null, done, function(dir, path) {
            return dir.exists( path );
        });
    }

    override function isDirectory(path:Path, ?done:Cb<Bool>):Promise<Bool> {
        return derive(path, null, done, function(dir, path) {
            var prom = dir.getDirectory( path ).transform(@ignore function(d) {
                if (d == null) {
                    return false;
                }
                else {
                    return true;
                }
            }).bool();
            //prom.unless()
            return prom;
        });
    }

    override function createDirectory(path:Path, ?done:VoidCb):VoidPromise {
        return vderive(path, null, done, function(dir, path, next) {
            dir.createDirectory( path ).then((wde)->next(), next.raise());
        });
    }

    override function deleteDirectory(path:Path, ?done:VoidCb):VoidPromise {
        return vderive(path, null, done, function(dir, path, next) {
            _getDirectory(path, dir).then(function(entry) {
                entry.remove(next.void(), next.raise());
            });
        });
    }

    override function deleteFile(path:Path, ?done:VoidCb):VoidPromise {
        return vderive(path, null, done, function(dir, path, next) {
            _getFile(path, dir).then(function(entry) {
                entry.remove(next.void());
            });
        });
    }

    override function read(path:Path, ?offset:Int, ?length:Int, ?done:Cb<ByteArray>):Promise<ByteArray> {
        return derive(path, null, done, function(dir, path) {
            return _getFile(path, dir).transform(entry->entry.file().read(offset, length));
            //_getFile(path, dir).then(function(entry) {
                //return entry.file().read(offset, length);
            //})
        });
    }

    override function write(path:Path, data:ByteArray, ?done:VoidCb):VoidPromise {
        return vderive(path, null, done, function(dir, path, next) {
            _getFile(path, dir).then(function(entry) {
                entry.writer().then(function(writer) {
                    writer.seek( 0 );
                    writer.truncate( data.length );
                    writer.write(data, function(error:Null<Dynamic>) {
                        next( error );
                    });
                }, next.raise());
            }, next.raise());
        });
    }

    /**
      * meh, betty
      */
    private function dres<T>(path:Path, ?done:Cb<T>, f:WebDirectoryEntry->Path->PromiseResolution<T>):Promise<T> {
        //oh poo yie
    }

    /**
      * derive one promise from another
      */
    private function derive<T>(path:Path, ?resolution:PathResolution, ?done:Cb<T>, f:WebDirectoryEntry->Path->PromiseResolution<T>):Promise<T> {
        if (resolution == null) {
            resolution = PathResolution.Absolute;
        }

        return wrap(done, Promise.create({
            switch ( resolution ) {
                case Absolute:
                    //return untyped pair( path ).transform(pair -> f(pair.left, pair.right));
                    return (untyped pair( path ).transform(@ignore function(par) {
                        return f(par.left, par.right);
                    }));

                case From( dir ):
                    return f(dir, path);
            }
        }));
    }

    private function vderive(path:Path, ?resolution:PathResolution, ?done:VoidCb, f:WebDirectoryEntry->Path->VoidCb->Void):VoidPromise {
        if (resolution == null) {
            resolution = PathResolution.Absolute;
        }
        var prom = new VoidPromise(function(accept, reject) {
            switch ( resolution ) {
                case Absolute:
                    pair( path ).then(function(lr) {
                        //accept(f(lr.left, lr.right));
                        f(lr.left, lr.right, function(?error) {
                            if (error != null) {
                                reject( error );
                            }
                            else accept();
                        });
                    }, reject);

                case From( dir ):
                    f(dir, path, function(?error) {
                        if (error != null)
                            reject( error );
                        else
                            accept();
                    });
            }
        });
        if (done != null) {
            prom.then(done.void(), done.raise());
        }
        return prom;
    }

    /**
      * derive relative to a pre-obtained directory
      */
    private function deriveFrom<T>(path:Path, dir:WebDirectoryEntry, ?done:Cb<T>, f:WebDirectoryEntry->Path->PromiseResolution<T>):Promise<T> {
        return derive(path, From( dir ), done, f);
    }
    private function vderiveFrom(path:Path, dir:WebDirectoryEntry, ?done:VoidCb, f:WebDirectoryEntry->Path->VoidCb->Void):VoidPromise {
        return vderive(path, From( dir ), done, f);
    }

    /**
      * resolve a Path to a FileSystem entry
      */
    public function resolve(path:Path, ?done:Cb<WebFSEntry>):Promise<WebFSEntry> {
        if (isRootSimulated( path )) {
            //return derive(path, null, null, function(dir, path) {

            //})
            return _getFSEntry(path, done);
        }
        else {
            return new Promise(function(yes, no) {
                CordovaFile.resolve(('file://'+path.toString()), yes, no);
            });
        }
    }

    /**
      * resolve a root Directory from the given Path
      */
    private function resolveRoot(path : Path):Promise<WebDirectoryEntry> {
        var bits:Array<String> = path.normalize().pieces;
        var rootBit:String = bits[0];
        return resolveRootFromName(rootName(path.normalize().pieces[0]));
    }

    /**
      * get the pieces of [path]
      */
    private function bits(path : Path):Array<String> return path.normalize().pieces;

    /**
      * apply functional transformation to [pair]
      */
    private inline function mappair<LIn,RIn,LOut,ROut,LRes:PromiseResolution<LOut>,RRes:PromiseResolution<ROut>>(pair:Pair<LIn, RIn>, left:LIn->LRes, right:RIn->RRes):Pair<LRes, RRes> {
        return new Pair(left( pair.left ), right( pair.right ));
    }

    /**
      * get a pair of the root-name and the rest of the path
      */
    private function rrpair(path:Path):Pair<String, Array<String>> {
        var a:Array<String> = bits( path );
        return new Pair((a.splice(0, 1)[0]), a);
    }

    /**
      * get a Pair of the root directory and the sub-path of it 
      */
    private function pair(path:Path):Promise<Pair<WebDirectoryEntry, Path>> {
        return Promise.pair(untyped mappair(untyped rrpair(path), untyped fn(resolveRootFromName(rootName(_))), untyped fn(Path.fromPieces(_))));
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
      * check whether the root of [path] is a simulated reference to an important Directory
      */
    private function isRootSimulated(path : Path):Bool {
        return ([
            'app', 'application',
            'appstorage', 'applicationstorage',
            'data', 'cache', 'temp', 'external',
            'external-storage', 'externaldata',
            'external-data', 'externalroot',
            'external-root', 'externalcache',
            'external-cache'
        ].has(path.pieces[0]));
    }

    /**
      * resolve root Directory from its name
      */
    private function resolveRootFromName(name : String):Promise<WebDirectoryEntry> {
        return new Promise(function(yes, no) {
            if (roots.exists( name )) {
                defer(yes.bind(roots[name]));
            }
            else {
                CordovaFile.resolve(name, function(entry) {
                    yes(roots[name] = new WebDirectoryEntry(cast entry));
                }, no);
            }
        });
    }

    /**
      * get a File 
      */
    private function _getFile(path:Path, ?dir:WebDirectoryEntry, ?done:Cb<WebFileEntry>):Promise<WebFileEntry> {
        var f = (dir != null ? deriveFrom.bind(_, dir, _) : derive.bind(_, null, _));
        return f(path, done, function(dir:WebDirectoryEntry, path:Path) {
            return dir.getFile( path );
        });
    }

    /**
      * get a Directory
      */
    private function _getDirectory(path:Path, ?dir:WebDirectoryEntry, ?done:Cb<WebDirectoryEntry>):Promise<WebDirectoryEntry> {
        var f = (dir != null ? deriveFrom.bind(_, dir, _) : derive.bind(_, null, _));
        return f(path, done, function(dir:WebDirectoryEntry, path:Path) {
            return dir.getDirectory( path );
        });
    }

    private function _getEntry(path:Path, ?done:Cb<Entry>):Promise<Entry> {
        return wrap(done, _getFSEntry( path ).transform.fn(new Entry(path, path.name, _.isFile, _.isDirectory)));
    }

    /**
      * get an Entry by Path
      */
    private function _getFSEntry(path:Path, ?done:Cb<WebFSEntry>):Promise<WebFSEntry> {
        path = path.normalize();
        return derive(path, done, function(dir, path) {
            if (entries.exists( path )) {
                return entries[path];
            }
            else {
                // guess ? ETFile : ETDirectory
                var guess:Bool = true;
                for (p in paths) {
                    if (p.startsWith( path ) && !p.endsWith( path )) {
                        guess = false;
                        break;
                    }
                }
                if (!path.name.has('.')) {
                    guess = false;
                }

                var nep:Promise<WebFSEntry> = _guessedEntry(dir, path, guess);
                nep.then(function(entry) {
                    entries[path] = entry;
                });
                //var ep:Promise<Entry> = nep.transform.fn(new Entry(path, path.name, _.isFile, _.isDirectory));
                return nep;
            }
        });
    }

    /**
      * obtain a WebFSEntry, regardless of whether it's a File or a Directory, sped up by educated guessing
      */
    private function _guessedEntry(dir:WebDirectoryEntry, path:Path, guess:Bool):Promise<WebFSEntry> {
        var first:Bool = true;
        var result:Null<WebFSEntry> = null;
        var doit = new VoidPromise(function(yes, no) {
            inline function gpf():Path->?WebDirectoryEntry->Promise<WebFSEntry> {
                return (untyped (guess ? _getFile.bind(_, _, null) : _getDirectory.bind(_, _, null)));
            }
            function attempt() {
                var promise = (gpf()(path, dir));
                promise.unless(function(error : DOMException) {
                    switch ( error.code ) {
                        case TYPE_MISMATCH_ERR:
                            if ( first ) {
                                first = false;
                                guess = !guess;
                                attempt();
                            }
                            else {
                                no(new FileError(NotFoundError, 'No such file or directory "$path"'));
                            }

                        case _:
                            no(domExceptionToFileError( error ));
                    }
                }, fn((_ is DOMException)));

                promise.then(function(entry : WebFSEntry) {
                    paths.add( path );
                    result = entry;
                    yes();
                }, no);
            }
            attempt();
        });
        return doit.promise(fn(result));
    }

    /**
      * wrap a Promise in an error-transforming Promise
      */
    private function fwdErrs<T,P:Promise<T>>(promise : P):Promise<T> {
        return promise.derive(function(promise, accept, reject) {
            promise.then( accept );

            inline function fe<I,O>(m:I->O, ?c:I->Bool) {
                promise.unless(function(in_err:I) {
                    reject(m( in_err ));
                }, c);
            }

            fe(domExceptionToFileError, fn((_ is DOMException)));
            fe(fn(_));
        });
    }

    /**
      * create a FileError from a DOMException
      */
    private function domExceptionToFileError(e : DOMException):FileError {
        return new FileError(translateDomExceptionType( e ), e.message);
    }

    /**
      * determine FileErrorType from the error code of a DOMException
      */
    private function translateDomExceptionType(e : DOMException):FileErrorType {
        return (switch ( e.code ) {
            case DATA_CLONE_ERR: DataCloneError;
            case NOT_FOUND_ERR: NotFoundError;
            case NOT_SUPPORTED_ERR: NotSupportedError;
            case NO_DATA_ALLOWED_ERR: NoDataAllowedError;
            case NO_MODIFICATION_ALLOWED_ERR: NoModificationAllowedError;
            case QUOTA_EXCEEDED_ERR: QuotaExceededError;
            case SECURITY_ERR: SecurityError;
            case TYPE_MISMATCH_ERR: TypeMismatchError;
            case URL_MISMATCH_ERR: UrlMismatchError;
            case VALIDATION_ERR: ValidationError;
            case WRONG_DOCUMENT_ERR: WrongDocumentError;
            case _: CustomError( e.name );
        });
    }

/* === Instance Fields === */

    private var roots : Dict<String, WebDirectoryEntry>;
    private var entries : Dict<Path, WebFSEntry>;
    private var etc : Dict<Path, EntryType>;
    private var paths : Set<Path>;
}

enum PathResolution {
    Absolute;
    From(dir : WebDirectoryEntry);
}
