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
        nhr = new Dict();
        _complete = new VoidSignal();
        _element = new Signal();

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
        if (!doc.isDocument())
            throw 'WTFError: Xml-tree root is not a document node';

        handle( doc );
    }

    public function handle(node: Xml):Void {
        this.node = node;
        trace( node );
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
        _element.call( element );

        var nhgl:Null<Array<Void->INodeHandler>> = cast nhr.get(element.nodeName.toLowerCase());
        if (nhgl != null) {
            var nh:INodeHandler;
            for (getnh in nhgl) {
                nh = getnh();
                nh.handle( element );
            }
        }
        //var getnh:Null<Void->INodeHandler> = cast nhr.get(element.nodeName.toLowerCase());
        //if (getnh != null) {
            //var nh:INodeHandler = getnh();
            //nh.handle( element );
        //}
        //else {
            //if (ignoreUnhandled) {
                //trace('Warning: unhandled <${element.nodeName}/>');
            //}
            //else {
                //throw 'Error: Unhandled <${element.nodeName}/>';
            //}
        //}
    }

    public inline function onElement(f: Xml->Void):Void {
        _element.on( f );
    }

    public inline function nextElement(f: Xml->Void):Void _element.once( f );

    /**
      * register a node handler
      */
    public inline function register(nodeName:String, nodeHandlerGetter:Getter<INodeHandler>):Void {
        handlerArray(nodeName.toLowerCase()).push( nodeHandlerGetter );
    }

    /**
      * get the list of handler-getters for a given nodeName
      */
    private inline function handlerArray(nodeName: String):Array<Getter<INodeHandler>> {
        return (nhr.exists(nodeName)?nhr[nodeName]:nhr.set(nodeName, new Array()));
    }

    /**
      * register multiple handlers at once
      */
    public inline function registers(nodeNames:Iterable<String>, nodeHandlerGetter:Getter<INodeHandler>):Void {
        for (n in nodeNames) {
            register(n, nodeHandlerGetter);
        }
    }

    /**
      * register a FunctionalNodeHandler
      */
    public function on(nodeName:String, builder:FunctionalNodeHandler->Void):Void {
        if (nodeName.has(',')) {
            var nodeNames = nodeName.split(',').map(s->s.nullEmpty()).compact().unique();
            registers(nodeNames, fnh.bind(builder));
        }
        else {
            register(nodeName, fnh.bind(builder));
        }
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

    private var nhr: Dict<String, Array<Getter<INodeHandler>>>;
    private var ignoreUnhandled: Bool = true;
    private var _element: Signal<Xml>;
    private var _complete : VoidSignal;
}
