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

    @:overload(function(docs: Array<Dynamic<Dynamic>>):Void {})
    public function insert(doc: Dynamic<Dynamic>):Void;
    public function remove(doc: Dynamic<Dynamic>):Void;

    @:overload(function(pairs: Array<Dynamic<Dynamic>>):Void {})
    public function update(oldDoc:Dynamic<Dynamic>, newDoc:Dynamic<Dynamic>):Void;

    public function revertUpdate(oldDoc:Dynamic<Dynamic>, newDoc:Dynamic<Dynamic>):Void;
    @:overload(function(values: Array<Dynamic>):Array<Dynamic<Dynamic>> {})
    public function getMatching(value: Dynamic<Dynamic>):Array<Dynamic<Dynamic>>;
    public function getAll():Array<Dynamic<Dynamic>>;
}
