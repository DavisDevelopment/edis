package edis.libs.nedb;

import tannus.node.*;
import tannus.async.*;

@:jsRequire( 'nedb.Index' )
extern class Index {
    public var fieldName : String;
    public var unique : Bool;
    public var sparse : Bool;
    public var tree : Dynamic;
    
/* === Instance Methods === */
}
