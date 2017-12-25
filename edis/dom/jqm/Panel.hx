package edis.dom.jqm;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;
import tannus.async.*;

import edis.Globals.*;
import edis.core.*;
import edis.dom.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.IteratorTools;

class Panel extends JQueryMobileComponent {
    public function new(page:Page, ?elem:Element):Void {
        super();

        if (elem == null) {
            el = e('<div data-role="panel"></div>');
        }
        else {
            el = elem;
        }
        if (!childOf( page )) {
            page.prepend( this );
        }

        el.plugin('panel', []);
    }

    public function open():Void {
        call(['open']);
    }

    public function close():Void {
        call(['close']);
    }

    public function toggle():Void {
        call(['toggle']);
    }

    private function call(args : Array<Dynamic>):Dynamic {
        return el.plugin('panel', args);
    }

    public var page : Page;
}
