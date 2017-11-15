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
}
