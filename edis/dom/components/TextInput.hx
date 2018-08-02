package edis.dom.components;

import tannus.io.*;
import tannus.ds.*;
import tannus.html.Element;

import js.html.InputElement;

import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

class TextInput extends NativeInput<String> {
    /* Constructor Function */
    public function new(?el: Element) {
        super(el);
    }
}
