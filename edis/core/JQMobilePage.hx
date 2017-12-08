package edis.core;

import tannus.html.Element;
import tannus.html.Win;
import tannus.ds.*;
import tannus.io.*;

import edis.dom.*;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

class JQMobilePage extends Page {
    /* Constructor Function */
    public function new(?e : Element):Void {
        super( e );

        id = Uuid.create();

        __create();
    }

/* === Instance Methods === */

    /**
      * initialize [this] Page
      */
    private function __create():Void {
        el.plugin('page', [untyped {

        }]);

        el.plugin('pagecontainer');

        el.data('edis.core.page', this);

        if (id == null) {
            id = Uuid.create();
        }

        header = new JQMobilePageHeader( this );
        footer = new JQMobilePageFooter( this );

        activate();
    }

    override function open(body: Body):Void {
        if (!childOf('body')) {
            appendTo( body );
        }

        body.application.navigator.changePage( this );
    }

/* === Computed Instance Fields === */

    public var id(get, set):String;
    private function get_id() return el.get('id');
    private function set_id(v) return el.set('id', v);

/* === Instance Fields === */

    public var header : JQMobilePageHeader;
    public var footer : JQMobilePageFooter;
    private var openedYet : Bool = false;
}
