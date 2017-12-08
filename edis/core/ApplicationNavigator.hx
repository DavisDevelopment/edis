package edis.core;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;

import edis.Globals.*;

import haxe.extern.EitherType;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.Json;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class ApplicationNavigator {
    /* Constructor Function */
    public function new(app : Application):Void {
        this.app = app;
        this.navigateEvent = new Signal2();

        __listen();
    }

/* === Instance Methods === */

    /**
      * handle events and shit
      */
    private function __listen():Void {
        e(window).on('navigate', function(event, data) {
            navigateEvent.call(event, data);
        });
    }

    /**
      * get the currently active page
      */
    public function getActivePage():Maybe<Page> {
        var activePageEl = app.getActivePageElement();
        if (activePageEl == null) {
            return null;
        }
        else {
            var activePageModel:Maybe<Page> = activePageEl.data('edis.core.page');
            if (activePageModel != null) {
                return activePageModel;
            }
            else {
                return new Page( activePageEl );
            }
        }
    }

    public function changePage(to:EitherType<String, Page>, ?options:Dynamic):Void {
        var target:Dynamic = to;
        if ((to is Page)) {
            target = cast(to, Page).el;
        }
        app._pageContainer.change( target );
    }

    /**
      * push a history entry
      */
    public function pushState(page:String, data:Dynamic, title:String='', ?address:String):Void {
        var state:HistoryState = new HistoryState(page, data);
        window.history.pushState(state.encode(), title, address);
    }

    /**
      * replace current history entry
      */
    public function replaceState(page:String, data:Dynamic, title:String='', ?address:String):Void {
        var state:HistoryState = new HistoryState(page, data);
        window.history.replaceState(state.encode(), title, address);
    }

    /**
      * get the current history entry
      */
    public function getCurrentState():Dynamic {
        return window.history.state;
    }

    public function back():Void {
        window.history.back();
    }

/* === Instance Fields === */

    public var app : Application;

    public var navigateEvent : Signal2<js.jquery.Event, Dynamic>;
}
