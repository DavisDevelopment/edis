package edis.dom.components;

import tannus.io.*;
import tannus.ds.*;
import tannus.html.Element;
import tannus.events.KeyboardEvent;

import js.html.InputElement;

import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

class NativeInput<T> extends Component implements IInput<T> {
/* === Instance Methods === */

    public function getValue():T {
        if (iel == null)
            return null;
        else untyped {
            return iel.value;
        }
    }

    public function setValue(v: T) {
        if (iel == null)
            return ;
        untyped {
            iel.value = ('' + v);
        }
    }

    public function getPlaceholder():String {
        return iel!=null?iel.placeholder:'';
    }
    public function setPlaceholder(v: String) {
        if (iel != null)
            iel.placeholder = v;
    }

    override function isValidHost(elem: Element):Bool return (super.isValidHost(elem) && elem.is('input'));
    override function _fresh_():Element return e('<input type="$_defaultInputType"></input>');
    override function _possess_(elem: Element) {
        var evts = [
            'input',
            'keypress',
            'keydown',
            'keyup',
            'change',
            'focus',
            'blur'
        ];

        forwardEvents(evts, cel, tannus.events.KeyboardEvent.fromJqEvent);
    }

/* === Computed Instance Fields === */

    public var iel(get, never):Null<InputElement>;
    private inline function get_iel() return (cel != null ? cast(cel.at(0), InputElement) : null);

/* === Instance Fields === */

    var _defaultInputType:String = 'text';
}
