package edis.core;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;
import tannus.html.Element;
import tannus.html.Win;

import edis.dom.*;
import edis.storage.kv.*;
import edis.Globals.*;

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

        window.document.addEventListener('deviceready', onReady, false);
	}

/* === Instance Methods === */

	/**
	  * Start [this] Application
	  */
	public function run():Void {
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
        var eb = new Element( 'body' );
        eb.data('sa.core.application', this);
        eb.plugin('pagecontainer');

        // assign [this]'s useful fields
        _pageContainer = eb.data('mobile-pagecontainer');
        _pageContainer._e = eb;
        navigator = new ApplicationNavigator( this );

        __plugins();
        __jqevents();
	}

    /**
      * when the mobile device is ready
      */
    public function onReady():Void {
        window.document.addEventListener('pause', onPause, false);
        window.document.addEventListener('resume', onResume, false);

        trace('device ready');
        defer( run );
    }

	/**
	  * require some shit
	  */
	public inline function require(builder : Prerequisites->Void):Void {
	    builder( reqs );
	}

	public function initialize(done : VoidCb):Void {
	    trace( reqs );
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

    /**
      * get the currently active page
      */
    public function getActivePageElement():Maybe<Element> {
        return _pageContainer.getActivePage();
    }

    /**
      * get the currently active page model
      */
    public function getActivePage():Maybe<Page> {
        return navigator.getActivePage();
    }

    /**
      * bind handlers to jquery events
      */
    private function __jqevents():Void {
        e(_pageContainer._e).on('pagecontainerhide', function(event, ui:Dynamic) {
            if (ui != null && Reflect.isObject( ui )) { 
                if (ui.prevPage != null) {
                    var pel:Element = e(ui.prevPage);
                    var prevPage:Null<Page> = pel.data('edis.core.page');
                    if (prevPage != null && (prevPage is Page)) {
                        prevPage.onClosed( body );
                    }
                }
            }
        });

        e(_pageContainer._e).on('pagecontainershow', function(event, ui:Dynamic) {
            if (ui != null && Reflect.isObject( ui )) {
                if (ui.toPage != null) {
                    var tel:Element = e( ui.toPage );
                    var toPage:Null<Page> = tel.data('edis.core.page');
                    if (toPage != null && (toPage is Page)) {
                        if ( !toPage.opened ) {
                            toPage.onOpened( body );
                            toPage.opened = true;
                        }
                        else {
                            toPage.onReopened( body );
                        }
                    }
                }
            }
        });
    }

    /**
      * perform plugin-specific tasks
      */
    private function __plugins():Void {
        Reflect.deleteField(window, 'open');
        window.expose('open', window.get('originalOpen'));
    }

    

    /**
      * when the app has been moved to the background
      */
    public function onPause():Void {
        //TODO
    }

    /**
      * when the app has been moved back to the foreground
      */
    public function onResume():Void {
        //TODO
    }

    public inline function ensureIsReady(done : Void->Void):Void {
        reqs.onmet( done );
    }

/* === Instance Fields === */

	public var title : String;
	public var win : Win;
	public var self : Obj;
	public var body : Body;

    public var storage : ApplicationStorage;
    public var navigator : ApplicationNavigator;
	public var reqs : Prerequisites;
    public var _pageContainer : Dynamic;
}
