package edis.core;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;

import edis.dom.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class JQMobilePageFooter extends Component {
    /* Constructor Function */
    public function new(page:JQMobilePage, ?e:Element):Void {
        super();

        this.page = page;

        if (e == null) {
            e = page.el.find( 'div[data-role="footer"]' );
            if (e.length == 0) {
                e = '<div data-role="footer"></div>';
                page.el.append( e );
            }
        }

        this.el = e;
    }

/* === Instance Methods === */

/* === Instance Fields === */

    public var page : JQMobilePage;
}
