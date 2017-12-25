package edis.dom.jqm;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;
import tannus.async.*;

import edis.dom.*;
import edis.dom.Component;

import edis.Globals.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.IteratorTools;

class List extends JQueryMobileComponent {
    /* Constructor Function */
    public function new(?el : Element):Void {
        super();

        if (el == null) {
            this.el = e('<ul></ul>');
            this.el.attr({
                'data-role': 'listview'
            });
        }
        else {
            this.el = el;
        }

        //this.call = this.el.method('listview');
        this.call = _.partial(_call, 'listview');

        this.el.data('_model', this);
        this.el.plugin('listview');
    }

/* === Instance Methods === */

    override function _attach(child:Dynamic, attacher:Attacher):Void {
        var childEl = _resolveElement( child );
        if (!childEl.is('li')) {
            var listItem = new ListItem();
            listItem.append( child );
            super._attach(listItem, attacher);
        }
        else super._attach(child, attacher);
    }

    public function option(?name:Dynamic, ?value:Dynamic):Dynamic {
        return call('option', name, value);
    }

    public function allOpts():Dynamic {
        return option();
    }

    public function getOpt<T>(name : String):T {
        return option(name);
    }

    public function setOpt<T>(name:String, value:T):T {
        option(name, value);
        return value;
    }

    public function setOpts(opts : Dynamic):Void {
        option( opts );
    }

    public function refresh():Void {
        call('refresh');
    }

    public function dispose():Void {
        call('destroy');
    }

    /**
      * iterate over all <li/> elements in [this] List
      */
    public function itemElements():Iterator<Element> {
        var items:Element = el.find('li');
        return (0...items.length).map.fn(e(items.at(_)));
    }

    /**
      * iterate over all listItem models
      */
    public function items():Iterator<ListItem> {
        return itemElements().map(function(e) {
            var modl = e.data('_model');
            if (modl != null && (modl is ListItem)) {
                return cast modl;
            }
            else {
                return new ListItem( e );
            }
        });
    }

/* === Computed Instance Fields === */

/* === Instance Fields === */

    private var call : Dynamic;
}
