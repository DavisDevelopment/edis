package edis.core;

import edis.dom.*;
import tannus.html.Element;
import tannus.html.Win;
import tannus.ds.*;
import tannus.io.*;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

class Page extends Component {
	/* Constructor Function */
	public function new(?el : Element):Void {
		super( el );

        if (el == null) {
            this.el = new Element('<div></div>');
        }
        
		body = null;
		title = '';
		attachments = new Array();
	}

/* === Instance Methods === */

	/**
	  * Open [this] Page
	  */
	public function open(body : Body):Void {
		if ( !opened ) {
			opened = true;
		}
		this.body = body;
		active = true;
	}

	/**
	  * Re-open [this] Page
	  */
	public function reopen(body : Body):Void {
		this.body = body;
		active = true;
	}

	/**
	  * Close [this] Page
	  */
	public function close():Void {
		destroy();
		active = false;
	}

	/**
	  * Navigate back to the previous Page
	  */
	public function back():Void {
		if (previousPage != null) {
			body.open( previousPage );
		}
	}

	/**
	  * attach a Controller to [this]
	  */
	public function attachController(c : PageController<Page>):Void {
		attachments.push( c );
		c.attach( this );
	}

	/**
	  * detach a Controller from [this]
	  */
	public function detachController(c : PageController<Page>):Void {
		attachments.remove( c );
		c.detach( this );
	}

	/**
	  * 'disable' all attached controllers
	  */
	public function disableAllControllers():Void {
		for (c in attachments) {
			if (!c.isDisabled()) {
				c.disable();
			}
		}
	}

	/**
	  * 'enable' all attached controllers
	  */
	public function enableAllControllers():Void {
		for (c in attachments) {
			if (c.isDisabled()) {
				c.enable();
			}
		}
	}

	public function onOpened(body: Body):Void {
	    //TODO
	}

	public function onReopened(body: Body):Void {
	    //TODO
	}

	public function onClosed(body: Body):Void {
	    //TODO
	}

/* === Computed Instance Fields === */

	public var active(get, set):Bool;
	private inline function get_active():Bool return is('.active');
	private function set_active(v : Bool):Bool {
		(v?addClass:removeClass)( 'active' );
		return active;
	}

	public var title(default, set):String;
	private function set_title(v : String):String {
		var r = (title = v);
		if (body != null) {
			body.title = title;
		}
		return r;
	}

/* === Instance Fields === */

	public var body : Null<Body>;
	public var previousPage : Null<Page> = null;

	@:allow( edis.core.Body )
	@:allow( edis.core.Application )
	private var opened : Bool = false;

	private var attachments : Array<PageController<Page>>;
}
