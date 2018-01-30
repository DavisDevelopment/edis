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

class XmlTools {
    public static function isElement(xml:Xml):Bool return (xml.nodeType == Element);
    public static function isDocument(xml:Xml):Bool return (xml.nodeType == Document);
    public static function isTextual(xml:Xml):Bool return (xml.nodeType == PCData || xml.nodeType == CData || xml.nodeType == Comment);

    public static function childElement(xml:Xml, nodeName:String, ?attrs:Map<String,String>, ?insertAt:Int):Xml {
        var el:Xml = Xml.createElement( nodeName );
        if (attrs != null) {
            for (key in attrs.keys())
                el.set(key, attrs[key]);
        }
        if (insertAt != null) {
            xml.insertChild(el, insertAt);
        }
        else {
            xml.addChild( el );
        }
        return el;
    }

    public static function text(xml:Xml, ?newText:String):String {
        var setting:Bool = (newText != null);
        switch ( xml.nodeType ) {
            case Document, Element:
                if ( setting ) {
                    // empty [xml]
                    for (node in xml) {
                        xml.removeChild( node );
                    }
                    xml.addChild(Xml.createPCData( newText ));
                    return newText;
                }
                else {
                    var res:String = '';
                    for (node in xml) {
                        res += text( node );
                    }
                    return res;
                }

            case PCData:
                if ( setting ) {
                    throw 'Error: what are you doing?';
                }
                else {
                    return xml.nodeValue;
                }

            default:
                return '';
        }
    }
}
