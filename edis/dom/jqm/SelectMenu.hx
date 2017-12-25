package pt.views;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;
import tannus.async.*;

import edis.dom.*;

import js.html.SelectElement;
import js.html.OptionElement;

import edis.Globals.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.IteratorTools;

class SelectMenu extends JQueryMobileComponent {
    /* Constructor Function */
    public function new(?e : Element):Void {
        super();

        _bindel(e, '<select></select>', function(e:Element) {
            _call( 'selectmenu' );
        });

        wm = _method('selectmenu');

        forwardEvents(['click', 'change', 'focus', 'focusin', 'blur']);
    }

/* === Methods === */

    public function selectedOption():Maybe<OptionElement> {
        return _ecall('item', sel.selectedIndex);
    }

    /**
      * get or set the value of [this] SelectMenu
      */
    public function value(?newValue : String):String {
        if (newValue == null) {
            return selectedOption().value.value;
        }
        else {
            var opt = selectedOption();
            if (opt != null) {
                opt.selected = false;
            }
            var options = sel.options;
            for (index in 0...options.length) {
                var option:OptionElement = cast options.item( index );
                if (option.value == newValue) {
                    option.selected = true;
                }
            }
            return value();
        }
    }

    public function addOption(text:String, value:String):OptionElement {
        var o = document.createOptionElement();
        o.text = text;
        o.value = value;
        sel.add( o );
        wm( 'refresh' );
        return o;
    }

/* === Computed Fields === */

    public var sel(get, never):SelectElement;
    private inline function get_sel() return cast (el.at( 0 ));

/* === Fields === */

    //private var values:Dict<String, T>;
}
