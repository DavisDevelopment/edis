package edis.storage.db;

import tannus.io.*;
import tannus.ds.*;
import tannus.ds.promises.*;
import tannus.async.*;
import tannus.sys.*;

import edis.storage.db.Query;
import edis.storage.db.Modification;
import edis.storage.db.Query.*;

import edis.libs.nedb.DataStore;
import edis.Globals.*;

import Slambda.fn;
import tannus.math.TMath.*;
import haxe.extern.EitherType;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using Slambda;
using tannus.async.Asyncs;
using tannus.async.VoidAsyncs;
using tannus.html.JSTools;

class TableWrapper {
    /* Constructor Function */
    public function new(store : DataStore):Void {
        this.store = store;
    }

/* === Instance Methods === */

    /**
      * initialize [this]
      */
    public function init(done : VoidCb):Void {
        store.loadDatabase( done );
    }

    /**
      * run a Query
      */
    public function query<T>(query:QueryDecl, ?done:Cb<Array<T>>):ArrayPromise<T> {
        return wrap(find(query.toDynamic()).array(), done);
    }
    //public function _query<T>(query:QueryDecl, done:Cb<Array<T>>) {
        //this.query(query).toAsync( done );
    //}

    /**
      * run a Query
      */
    public function queryOne<T>(query:QueryDecl, ?done:Cb<T>):Promise<T> {
        return wrap(findOne(query.toDynamic()), done);
    }
    //public function _queryOne<T>(query:QueryDecl, done:Cb<T>):Void {
        //queryOne(query).toAsync( done );
    //}

    /**
      * get the single item that matches [query]
      */
    public function findOne<T>(query:Dynamic, ?done:Cb<Maybe<T>>):Promise<Maybe<T>> {
        return wrap(store.findOne.bind(query, _).toPromise(), done);
    }
    //public function _findOne<T>(q:Dynamic, f:Cb<Maybe<T>>):Void {
        //findOne(q).toAsync( f );
    //}

    /**
      * get all items taht match [query]
      */
    public function find<T>(query:Dynamic, ?done:Cb<Array<T>>):Promise<Array<T>> {
        return untyped wrap(untyped store.find.bind(query, _).toPromise(), done);
    }
    //public function _find<T>(q:Dynamic, f:Cb<T>):Void {
        //find(q).toAsync(untyped f);
    //}

    public function count(query:QueryDecl, ?done:Cb<Int>):Promise<Int> {
        return wrap(store.count.bind(query.toDynamic(), _).toPromise(), done);
    }
    //public function _count(query:QueryDecl, done:Cb<Int>) count( query ).toAsync( done );

    public function length(?done:Cb<Int>):Promise<Int> {
        return wrap(count(new Query()), done);
    }
    //public function _length(done : Cb<Int>) length().toAsync( done );

    /**
      * get all items in [this] table
      */
    public function all<T>(?done:Cb<Array<T>>):ArrayPromise<T> {
        return wrap(find({}).array(), done);
    }
    //public function _all<T>(done : Cb<Array<T>>):Void {
        //all().toAsync( done );
    //}

    /**
      * get all by a single field
      */
    public function getAllBy<T>(index:String, value:Dynamic, ?done:Cb<Array<T>>):ArrayPromise<T> {
        return wrap(find(_bo(function(o : Object) {
            o[index] = value;
        })).array(), done);
    }
    //public function _getAllBy<T>(index:String, value:Dynamic, done:Cb<Array<T>>):Void {
        //getAllBy(index, value).toAsync( done );
    //}

    /**
      * get a single row by a single field
      */
    public function getBy<T>(index:String, value:Dynamic, ?done:Cb<T>):Promise<T> {
        return wrap(findOne(_bo(function(o : Object) {
            o[index] = value;
        })), done);
    }
    //public function _getBy<T>(index:String, value:Dynamic, done:Cb<T>):Void {
        //return getBy(index, value).toAsync( done );
    //}

    /**
      * get an item by id
      */
    public function getById<T>(id:Dynamic, ?done:Cb<T>):Promise<T> {
        return wrap(getBy('_id', id), done);
    }

    /**
      * update an item
      */
    public function update<T>(query:Dynamic, update:Dynamic, ?options:{?multi:Bool,?insert:Bool}, ?done:Cb<T>):Promise<T> {
        return wrap(Promise.create({
            store.update(query, update, buildUpdateOptions(options), function(err:Null<Dynamic>, numAffected:Int, affectedDocuments:T, upsert:Bool) {
                if (err != null) {
                    throw err;
                }
                else {
                    return affectedDocuments;
                }
            });
        }), done);
    }
    //public function _update<T>(query:Dynamic, update:Dynamic, ?options:{?multi:Bool, ?insert:Bool}, done:Cb<T>):Void {
        //this.update(query, update, options).toAsync( done );
    //}

    /**
      * modify an item
      */
    public function mutate<T>(query:QueryDecl, mod:Mod, ?options:{?multi:Bool, ?insert:Bool}, ?done:Cb<T>):Promise<T> {
        return wrap(Promise.create({
            var p = update(query.toObject(), mod.toObject(), options);
            p.then(function(o : Object) {
                return getById(o['_id']);
            });
            p.unless(function(error) {
                throw error;
            });
        }), done);
    }
    //public function _mutate<T>(query:QueryDecl, mod:Mod, ?options:{?multi:Bool,?insert:Bool}, done:Cb<T>):Void {
        //mutate(query, mod, options).toAsync( done );
    //}

    /**
      * put an item
      */
    public function put<T>(query:QueryDecl, update:Dynamic, ?done:Cb<T>):Promise<T> {
        if (update.nag('_id') == null) {
            update.nad('_id');
        }

        return wrap(this.update(query.toObject(), update, {
            multi: false,
            insert: true
        }), done);
    }
    //public function _put<T>(query:QueryDecl, update:Dynamic, done:Cb<T>):Void {
        //put(query, update).toAsync( done );
    //}

    /**
      * insert an item
      */
    public function insert<T>(doc:Dynamic, ?done:Cb<T>):Promise<T> {
        if (doc.nag('_id') == null) {
            doc.nad('_id');
        }
        return wrap(store.insert.bind(doc, _).toPromise(), done);
    }
    //public function _insert<T>(doc:Dynamic, done:Cb<T>) insert(doc).toAsync( done );

    /**
      * create a new Index
      */
    public function createIndex(fieldName:String, unique:Bool=false, sparse:Bool=false, ?done:VoidCb):Void {
        store.ensureIndex({
            fieldName: fieldName,
            unique: unique,
            sparse: sparse
        }, done);
    }

    /**
      * delete an Index
      */
    public function deleteIndex(fieldName:String, ?done:VoidCb):Void {
        store.removeIndex(fieldName, done);
    }

    /**
      * create a new Row
      */
    public function create<T>(row:T, ?done:Cb<T>):Promise<T> {
        return insert(row, done);
    }
    //public function _create<T>(row:T, done:Cb<T>) create( row ).toAsync( done );

    /**
      * fetch, or create, a row
      */
    /*
    public function _cog<T>(query:QueryDecl, fresh:Void->T, ?test:T->Bool, done:Cb<T>):Void {
        queryOne(query, function(?error, ?row:Maybe<T>) {
            if (error != null) {
                return done(error, null);
            }
            else if (row != null && (test == null || test( row ))) {
                return done(null, row);
            }
            else {
                _create(fresh(), done);
            }
        });
    }
    */

    /**
      * fetch, or create, a row
      */
    public function cog<T>(query:QueryDecl, fresh:Void->T, ?test:T->Bool, ?done:Cb<T>):Promise<T> {
        return wrap(queryOne( query ).transform(function(row : Maybe<T>) {
            if (row != null && (test == null || test( row ))) {
                return untyped row;
            }
            else {
                return untyped create(untyped fresh());
                //return untyped put(query, fresh());
            }
        }), done);
    }

    /**
      * delete one or more documents
      */
    public function remove<T>(query:QueryDecl, done:EitherType<VoidCb, Cb<Int>>, multiple:Bool=false):Void {
        store.remove(query.toDynamic(), {multi:multiple}, function(?error, ?numRemoved) {
            untyped done(error, numRemoved);
        });
    }

    /**
      * delete all Documents that match [query]
      */
    public function removeMultiple<T>(query:QueryDecl, done:EitherType<VoidCb, Cb<Int>>):Void {
        remove(query, done, true);
    }

    /**
      * delete all Documents
      */
    public function removeAll(done : EitherType<VoidCb, Cb<Int>>):Void {
        store.remove({}, {multi: true}, function(?error, ?numRemoved) {
            untyped done(error, numRemoved);
        });
    }

    /**
      * compact [this] Table's data file
      */
    public function compact():Void {
        store.compact();
    }

    /**
      * call method [action] on every document in [this] Table
      */
    public function each<T>(action:T->Void, done:VoidCb):Void {
        var index = store.indexes._id;
        try {
            index.tree.executeOnEveryNode(function(node:Dynamic) {
                var i:Int = 0;
                while (i < node.data.length) {
                    action(untyped node.data[i++]);
                }
            });
            done();
        }
        catch (error : Dynamic) {
            done( error );
        }
    }

/* === Utility Methods === */

    /**
      * create and return a new Modification
      */
    public inline function createModification():Modification return new Modification();

    /**
      * create and return a new Query
      */
    public inline function createQuery():Query return new Query();

    /**
      * build out the update options
      */
    private function buildUpdateOptions(?o : {?multi:Bool, ?insert:Bool}):UpdateOptions {
        o = _.defaults((o != null ? o : {}), {
            multi: false,
            insert: true
        });
        return {
            multi: o.multi,
            upsert: o.insert,
            returnUpdatedDocs: true
        };
    }

    /**
      * utility method to construct an Object
      */
    private function _buildObject(f : Object->Void):Object {
        var o:Object = {};
        f( o );
        return o;
    }
    private inline function _bo(f : Object->Void):Object return _buildObject( f );

    /**
      * callback Betty
      */
    private inline function wrap<T, P:Promise<T>>(promise:P, ?callback:Cb<T>):P {
        if (callback != null) {
            promise.then(callback.yield(), callback.raise());
        }
        return promise;
    }

    /**
      * convert a QueryDecl to a Query
      */
    private inline function qd(decl: QueryDecl):Query {
        return decl.toQuery();
    }

/* === Instance Fields === */

    public var store : DataStore;
}
