package edis.dom.components;

import tannus.html.Element;

import edis.Globals.*;

class Div extends Component {
    override function isValidHost(elem: Element):Bool return (super.isValidHost(elem) && elem.is('div'));
    override function _fresh_():Null<Element> return e('<div/>');
}
