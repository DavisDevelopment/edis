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

enum FileErrorType {
    CustomError(typeName : String);
    DataCloneError;
    NotFoundError;
    NotSupportedError;
    NoDataAllowedError;
    NoModificationAllowedError;
    QuotaExceededError;
    SecurityError;
    TypeMismatchError;
    UrlMismatchError;
    ValidationError;
    WrongDocumentError;
}
