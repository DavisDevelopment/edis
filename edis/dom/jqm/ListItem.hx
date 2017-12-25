package edis.dom.jqm;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;
import tannus.async.*;

import edis.dom.*;

import edis.Globals.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.IteratorTools;

class ListItem extends JQueryMobileComponent {
    /* Constructor Function */
    public function new(?elem : Element):Void {
        super();

        if (elem == null) {
            el = e('<li></li>');
        }
        else {
            if (elem.is('li')) {
                el = elem;
            }
            else {
                el = e('<li/>');
                el.append( elem );
            }
        }

        el.data('_model', this);
    }

    public function getList():Maybe<List> {
        return untyped (parentElement != null ? parentElement.data('_model') : null);
    }
}
