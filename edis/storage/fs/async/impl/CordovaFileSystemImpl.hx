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

    override function exists(path:Path, ?done:Cb<Bool>):Promise<Bool> {
        return derive(path, done, function(path, entry) {
            return (entry != null);
        });
    }

    private function derive<T>(path:Path, ?done:Cb<T>, f:Path->WebFSEntry->PromiseResolution<T>):Promise<T> {
        return wrap(done, Promise.create({
            return resolveEntry( path ).transform(@ignore function(entry) {
                return untyped f(path, entry);
            });
        }));
    }

    private function resolveEntry(path:Path, ?done:Cb<WebFSEntry>):Promise<WebFSEntry> {
        return wrap(done, new Promise(function(yes, no) {
            CordovaFile.resolve(pathToUrl( path ), yes, no);
        }));
    }

    private function urlToPath(url : String):Path {
        if (url.startsWith('file://')) {
            url = url.after('file://');
        }
        return Path.fromString( url );
    }

    private function pathToUrl(path : Path):String {
        return ('file://'+path.toString());
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
