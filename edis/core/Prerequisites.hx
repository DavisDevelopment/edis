package edis.core;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;
import tannus.html.Element;
import tannus.html.Win;

import edis.dom.*;
import edis.storage.kv.*;

import edis.Globals.*;
import Slambda.fn;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Prerequisites {
    /* Constructor Function */
    public function new(?items:Array<Prereq>):Void {
        if (items == null)
            items = new Array();
        this.items = items;
        this.met = new OnceSignal();
    }

/* === Instance Methods === */

    /**
      * listen for when these prerequisites have been met
      */
    public inline function onmet(f : Void->Void):Void {
        met.on( f );
    }
    public inline function empty():Bool return items.empty();

    public inline function add(item: Prereq):Void items.push( item );
    @:native('_void')
    public inline function void(a : Void->Void):Void add(PVoidFunc( a ));
    public inline function vasync(a : VoidAsync):Void add(PVoidAsync( a ));
    public inline function vprom(a : VoidPromise):Void add(PVoidPromise( a ));
    public inline function async<T>(a : Async<T>):Void add(PAsync( a ));
    public inline function prom<T>(a : Promise<T>):Void add(PPromise( a ));
    public inline function task(a : Task1):Void add(PTask( a ));

    public function meet(done: VoidCb):Void {
        var steps = items.map(_vasync);
        VoidAsyncs.series(steps, function(?error) {
            done( error );
            if (error != null)
                defer( met.announce );
        });
    }

    private function _vasync(item : Prereq):VoidAsync {
        switch ( item ) {
            case PVoidFunc( a ):
                return (function(next) {
                    defer(function() {
                        try {
                            a();
                            next();
                        }
                        catch (error: Dynamic) {
                            next( error );
                        }
                    });
                });

            case PVoidAsync( a ):
                return a;

            case PVoidPromise( a ):
                return (function(next:VoidCb) a.then(next.void()).unless(next.raise()));

            case PAsync( a ):
                return (function(next) a((?err,?res)->next(err)));

            case PPromise( a ):
                return (function(next) a.then.fn(res=>next()).unless(fn(next(_))));

            case PTask( a ):
                return (function(next) a.run( next ));
        }
    }

/* === Instance Fields === */

    private var items : Array<Prereq>;
    private var met : OnceSignal;
}

enum Prereq {
    PVoidFunc(a : Void->Void);
    PVoidAsync(a : VoidAsync);
    PVoidPromise(a : VoidPromise);
    PAsync<T>(a : Async<T>);
    PPromise<T>(a : Promise<T>);
    PTask(a : Task1);
}
