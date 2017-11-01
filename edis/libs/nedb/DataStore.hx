package edis.libs.nedb;

import tannus.node.*;
import tannus.async.*;

@:jsRequire( 'nedb' )
extern class DataStore {
    /* Constructor Function */
    public function new(options : Dynamic):Void;

/* === Instance Methods === */

    public function loadDatabase(?callback : VoidCb):Void;
    public function insert(doc:Dynamic, callback:Cb<Dynamic>):Void;
    public function find(query:Dynamic, callback:Cb<Array<Dynamic>>):Void;
    public function findOne(query:Dynamic, callback:Cb<Dynamic>):Void;
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
}

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
