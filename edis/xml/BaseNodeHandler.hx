package edis.xml;

import tannus.ds.*;
import tannus.io.*;
import tannus.async.*;

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

class BaseNodeHandler implements INodeHandler {
    /* Constructor Function */
    public function new():Void {
        //this.node = node;
    }

    public function onChild(child: Xml):Void {
        //TODO
    }

    public function onAttribute(name:String, value:String):Void {
        #if debug trace('$name = "$value"'); #end
    }

    public function onTextNode(text: String):Void {
        #if debug trace('text("$text")'); #end
    }
    
    public function onCommentNode(text: String):Void {
        #if debug trace('comment("$text")'); #end
    }

    public function handle(node: Xml):Void {
        this.node = node;

        if (node.isElement()) {
            for (name in node.attributes()) {
                onAttribute(name, node.get(name));
            }
        }
        for (x in node.iterator()) {
            if (x.isElement()) {
                onChild( x );
            }
            else if (x.nodeType == PCData) {
                onTextNode( x.nodeValue );
            }
            else if (x.nodeType == CData) {
                onTextNode( x.nodeValue );
            }
            else if (x.nodeType == Comment) {
                onCommentNode( x.nodeValue );
            }
            else {
                trace( x.nodeType );
                trace( x );
            }
        }
    }

    public var node: Xml;
}
