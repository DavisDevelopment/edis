package edis.libs.nedb;

import tannus.node.*;
import tannus.async.*;

@:jsRequire( 'nedb' )
extern class DataStore {
    /* Constructor Function */
    public function new(options: CreateOptions):Void;

/* === Instance Methods === */

    public function loadDatabase(?callback : VoidCb):Void;
    public function insert(doc:Dynamic, callback:Cb<Dynamic>):Void;

    @:overload(function(query:Dynamic<Dynamic>, projection:Dynamic<Dynamic>, callback:Cb<Array<Dynamic>>):Void {})
    @:overload(function(query: Dynamic<Dynamic>):Cursor<Array<Dynamic>> {})
    public function find(query:Dynamic, callback:Cb<Array<Dynamic>>):Void;

    @:overload(function(query:Dynamic<Dynamic>, projection:Dynamic<Dynamic>, callback:Cb<Dynamic>):Void {})
    @:overload(function(query: Dynamic<Dynamic>):Cursor<Dynamic> {})
    public function findOne(query:Dynamic, callback:Cb<Dynamic>):Void;

    @:overload(function(query:Dynamic<Dynamic>, callback:Cb<Int>):Void {})
    @:overload(function(query: Dynamic<Dynamic>):Cursor<Int> {})
    public function count(query:Dynamic, callback:Cb<Int>):Void;

    public function update(query:Dynamic, update:Dynamic, options:UpdateOptions, ?callback:Null<Dynamic>->Null<Int>->Null<Dynamic>->Null<Dynamic>->Void):Void;
    public function remove(query:Dynamic, options:{multi:Bool}, ?callback:Cb<Int>):Void;

    public function ensureIndex(options:IndexOptions, ?callback:VoidCb):Void;
    public function removeIndex(fieldName:String, ?callback:VoidCb):Void;

    inline public function compact():Void {
        this.persistence.compactDatafile();
    }

/* === Instance Fields === */

    public var persistence : Persistence;
    public var indexes : Dynamic<Index>;
}

typedef CreateOptions = {
    ?filename: String,
    ?inMemoryOnly: Bool,
    ?timestampData: Bool,
    ?autoload: Bool,
    ?onload: ?Dynamic->Void,
    ?afterSerialization: String->String,
    ?beforeDeserialization: String->String,
    ?compareStrings: String->String->Int
};

typedef IndexOptions = {
    fieldName: String,
    ?unique: Bool,
    ?sparse: Bool,
    ?expireAfterSeconds: Float
};

typedef UpdateOptions = {
    ?multi: Bool,
    ?upsert: Bool,
    ?returnUpdatedDocs: Bool
};
