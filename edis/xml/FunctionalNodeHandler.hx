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

class FunctionalNodeHandler extends BaseNodeHandler {
    /* Constructor Function */
    public function new(?spec : FNHSpec):Void {
        super();

        _inits = (spec != null ? (spec.inits != null ? spec.inits : []) : []);
        _reqattrs = new Set();
        _attrs = new Dict();
        _nhr = new Dict();
    }

/* === Instance Methods === */

    override function handle(node: Xml):Void {
        this.node = node;
        for (builder in _inits)
            builder( this );

        _srattrs = new Set();
        _srattrs.pushMany( _reqattrs );
        for (name in node.attributes()) {
            onAttribute(name, node.get(name));
        }
    }

    /**
      * 
      */
    public inline function build(builder: FunctionalNodeHandler->Void):Void {
        _inits.push( builder );
    }

    public function accept<T>(attr:String, required:Bool=false, ?transform:String->T, ?extracted:T->Void):AttrHandler<T> {
        var ah:AttrHandler<T> = new AttrHandler(attr, transform);
        if (extracted != null)
            ah.extracted.on( extracted );
        if ( required )
            _reqattrs.push( attr );
        return (_attrs.set(attr, ah));
    }

    public function acceptString(n:String, ?got:String->Void):AttrHandler<String> {
        return accept(n, null, null, got);
    }

    public function acceptFloat(n:String, ?got:Float->Void):AttrHandler<Float> {
        return accept(n, null, Std.parseFloat, got);
    }

    public function acceptInt(n:String, ?got:Int->Void):AttrHandler<Int> {
        return accept(n, null, Std.parseInt, got);
    }

    public function require<T>(attr:String, ?transform:String->T, ?extracted:T->Void):AttrHandler<T> {
        return accept(attr, true, transform, extracted);
    }
    public function acceptString(n:String, ?got:String->Void):AttrHandler<String> return require(n, null, got);
    public function acceptFloat(n:String, ?got:Float->Void):AttrHandler<Float> return require(n, Std.parseFloat, got);
    public function acceptInt(n:String, ?got:Int->Void):AttrHandler<Int> return require(n, Std.parseInt, got);

    override function onAttribute(name:String, value:String):Void {
        if (_attrs.exists( name )) {
            _attrs.get(name).extract( node );
            if (_srattrs.exists( name ))
                _srattrs.remove( name );
        }
    }

    override function onChild(child: Xml):Void {

    }

/* === Instance Fields === */

    private var _inits: Array<FunctionalNodeHandler -> Void>;
    private var _reqattrs: Set<String>;
    private var _srattrs: Set<String>;
    private var _attrs: Dict<String, AttrHandler<Dynamic>>;
    private var _nhr: Dict<String, Getter<INodeHandler>>;
}

class AttrHandler<TOut:String> {
    public function new(n:String, ?f:String->TOut) {
        name = n;
        if (f == null)
            _map = (untyped (v)->v);
        else
            _map = f;
        extracted = new Signal();
    }

    public function extract(node:Xml):Null<TOut> {
        var sval:Null<String> = node.get( name );
        if (sval == null) {
            return null;
        }
        else {
            return _map( sval );
        }
    }
    
    public var name: String;
    public var extracted: Signal<TOut>;
    private var _map: String->TOut;
}

typedef FNHSpec = {
    ?inits: Array<FunctionalNodeHandler -> Void>
}
