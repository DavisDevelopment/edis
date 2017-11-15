package edis.core;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;
import tannus.html.Element;
import tannus.html.Win;

import edis.dom.*;
import edis.storage.kv.*;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

class Application {
	/* Constrcutor Function */
	public function new():Void {
		win = Win.current;
		self = Obj.fromDynamic( this );
		self.defineProperty('title', Ptr.create(win.document.title));
		body = new Body( this );
		reqs = new Prerequisites();
		storage = new ApplicationStorage( this );
	}

/* === Instance Methods === */

	/**
	  * Start [this] Application
	  */
	public function run():Void {
	    trace('initializing app...');
	    trace( reqs );
		initialize(function(?error) {
		    if (error != null) {
		        throw error;
		    }
            else {
                start();
            }
		});
	}

    /**
      * entry point
      */
	public function start():Void {
	    //TODO
	}

	/**
	  * require some shit
	  */
	public inline function require(builder : Prerequisites->Void):Void {
	    builder( reqs );
	}

	public function initialize(done : VoidCb):Void {
	    reqs.meet( done );
	}

	private function defaultStorageArea():StorageArea {
	    return cast new StorageArea();
	}

	private function localStorageArea():StorageArea {
	    return defaultStorageArea();
	}

	private function tempStorageArea():StorageArea {
	    return defaultStorageArea();
	}

/* === Instance Fields === */

	public var title : String;
	public var win : Win;
	public var self : Obj;
	public var body : Body;

    public var storage : ApplicationStorage;
	public var reqs : Prerequisites;
}
