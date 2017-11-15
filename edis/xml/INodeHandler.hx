package edis.xml;

import tannus.ds.*;
import tannus.io.*;
import tannus.async.*;

import Slambda.fn;
import tannus.math.TMath.*;
import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.FunctionTools;

interface INodeHandler {
    function handle(node: Xml):Void;
    function onChild(child: Xml):Void;
    function onAttribute(name:String, value:String):Void;
    function onTextNode(text: String):Void;
    function onCommentNode(text: String):Void;

    var node: Xml;
}
