package edis.xml;

import tannus.ds.*;
import tannus.io.*;
import tannus.async.*;

import edis.xml.FunctionalNodeHandler.create as fnh;

import Slambda.fn;
import tannus.math.TMath.*;
import edis.Globals.*;
import Xml;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.FunctionTools;
using edis.xml.XmlTools;

class BaseXmlParser implements INodeHandler {
    public function new() {
        nhr = new Map();
        _complete = new VoidSignal();

        setup();
    }

/* === Instance Methods === */

    /**
      * method where parsing procedures are created
      */
    private function setup():Void {
        //
    }

    public function handleString(xml: String):Void {
        var doc:Xml = Xml.parse( xml );
        handle(doc.firstElement());
    }

    public function handle(node: Xml):Void {
        this.node = node;
        if (node.isDocument() || node.isElement()) {
            if (root == null) {
                root = node;
            }

            for (elem in node.elements()) {
                onChild( elem );
            }
        }
        _complete.fire();
    }

    /**
      * handle an Element node
      */
    public function onChild(element: Xml):Void {
        var getnh:Null<Void->INodeHandler> = cast nhr.get(element.nodeName);
        if (getnh != null) {
            var nh:INodeHandler = getnh();
            nh.handle( element );
        }
        else {
            if (ignoreUnhandled) {
                trace('Warning: unhandled <${element.nodeName}/>');
            }
            else {
                throw 'Error: Unhandled <${element.nodeName}/>';
            }
        }
    }

    /**
      * register a node handler
      */
    public inline function register(nodeName:String, nodeHandlerGetter:Getter<INodeHandler>):Void {
        nhr.set(nodeName, nodeHandlerGetter);
    }

    public function on(nodeName:String, builder:FunctionalNodeHandler->Void):Void {
        register(nodeName, fnh.bind(builder));
    }

    public function then(onComplete: Void->Void):Void {
        _complete.once( onComplete );
    }

    public function onAttribute(k:String,v:String):Void {}
    public function onTextNode(s:String):Void {}
    public function onCommentNode(s:String):Void {}

/* === Instance Fields === */

    public var root : Xml;
    public var node: Xml;

    private var nhr: Map<String, Getter<INodeHandler>>;
    private var ignoreUnhandled: Bool = true;
    private var _complete : VoidSignal;
}
