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
        _complete = new VoidSignal();
        _begin = new VoidSignal();
        _text = new Signal();
        _child = new Signal();
        _attr = new Signal2();
        _allattrs = new Signal();
        _attrflags = new Signal();

        _buffrs = new Dict();
    }

/* === Instance Methods === */

    override function handle(node: Xml):Void {
        this.node = node;
        for (builder in _inits)
            builder( this );
        _begin.fire();

        _srattrs = new Set();
        _srattrs.pushMany( _reqattrs );
        var all:Map<String,String> = new Map();
        var flags:Set<String> = new Set();
        for (name in node.attributes()) {
            var val = node.get( name );
            onAttribute(name, val);
            all[name] = val;
            if (val.trim().empty()) {
                flags.push( name );
            }
        }
        _allattrs.call( all );
        _attrflags.call( flags );

        var missing = _reqattrs.difference(_srattrs);
        if (missing.length > 0) {
            var errorMessage:String = [for (x in missing) 'Error: Missing required attribute "$x"'].join('\n');
            throw errorMessage;
        }

        var text:String = '';
        for (e in node) {
            if (e.isElement()) {
                onChild( e );
            }
            else {
                switch ( e.nodeType ) {
                    case CData, PCData:
                        text += e.nodeValue;

                    case Comment:
                        onCommentNode( e.nodeValue );

                    case _:
                        //
                }
            }
        }
        onTextNode( text );

        _complete.fire();
    }

    /**
      * 
      */
    public inline function build(builder: FunctionalNodeHandler->Void):Void {
        _inits.push( builder );
    }

    public inline function then(onComplete: Void->Void):Void {
        _complete.once( onComplete );
    }

    public inline function onNodeObtained(f: Xml->Void):Void {
        _begin.once(function() f( node ));
    }

    public function accept<T>(attr:String, required:Bool=false, ?transform:String->T, ?extracted:T->Void):AttrHandler<T> {
        var ah:AttrHandler<T> = new AttrHandler(attr, transform);
        if (extracted != null)
            ah.extracted.on( extracted );
        if ( required )
            _reqattrs.push( attr );
        return untyped (_attrs.set(attr, ah));
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

    public function acceptBool(n:String, got:Bool->Void) {
        return hasFlag(n, got);
    }

    public function require<T>(attr:String, ?transform:String->T, ?extracted:T->Void):AttrHandler<T> {
        return accept(attr, true, transform, extracted);
    }
    public function requireString(n:String, ?got:String->Void):AttrHandler<String> return untyped require(n, null, got);
    public function requireFloat(n:String, ?got:Float->Void):AttrHandler<Float> return untyped require(n, Std.parseFloat, got);
    public function requireInt(n:String, ?got:Int->Void):AttrHandler<Int> return untyped require(n, untyped Std.parseInt, got);

    public inline function register(nodeName:String, nodeHandlerGetter:Getter<INodeHandler>):Void {
        _nhr[nodeName] = nodeHandlerGetter;
    }

    public function on(nodeName:String, builder:FunctionalNodeHandler->Void):FunctionalNodeHandler {
        register(nodeName, create.bind(builder));
        return this;
    }

    public function onm(nodeNames:Iterable<String>, builders:Iterable<FunctionalNodeHandler->Void>):FunctionalNodeHandler {
        var getter:Getter<INodeHandler> = cast createm.bind(builders);
        for (nodeName in nodeNames) {
            register(nodeName, getter);
        }
        return this;
    }

    public function onAny(builder: FunctionalNodeHandler->Void):Void {
        _child.on(function(child) {
            var sub = create( builder );
            sub.handle( child );
        });
    }

    /**
      * get the whole of [this] node's textual content
      */
    public function getText(f: String->Void):Void {
        //_text.once( f );
        //buffer('txt', '');
        var result:String = '';
        _text.on(function(chunk) {
            //buffer('txt', chunk);
            result += chunk;
            trace('text-chunk! "$result"');
        });
        then(function() {
            //var full = closebuffer('txt').join('');
            //f( full );
            return result;
        });
    }

    public function getTextAs<T>(f:T->Void, m:String->T):Void {
        getText(function(txt) {
            f(m( txt ));
        });
    }

    public function getTextAsBool(f:Bool->Void):Void {
        getTextAs(f, s->(switch (s.toLowerCase()){
            case 'true', 'yes', 'on': true;
            case 'false', 'no', 'off': false;
            case _: throw 'TypeError: Expected Boolean value, got "$s"';
        }));
    }

    public function getTextAsFloat(f:Float->Void):Void {
        getTextAs(f, Std.parseFloat);
    }
    public function getTextAsInt(f:Int->Void):Void getTextAs(f, Std.parseInt);
    
    public inline function anyattr(f:String->String->Void):Void _attr.on( f );

    public inline function attrs(f:Map<String,String>->Void):Void _allattrs.on( f );
    public inline function flags(f:Set<String>->Void):Void _attrflags.on( f );
    public inline function hasFlag(name:String, f:Bool->Void) { flags(s->f(s.exists(name))); }

    public function childGetText(name:String, f:String->Void):Void {
        on(name, function(n) {
            n.getText( f );
        });
    }

    public function childGetTextAs<T>(name:String, f:T->Void, m:String->T):Void {
        on(name, function(n) {
            n.getTextAs(f, m);
        });
    }

    public function childGetTextAsBool(name:String, f:Bool->Void):Void {
        on(name, function(n) {
            n.getTextAsBool( f );
        });
    }
    public function childGetTextAsFloat(name:String, f:Float->Void):Void {
        on(name, function(n) {
            n.getTextAsFloat( f );
        });
    }
    public function childGetTextAsInt(name:String, f:Int->Void):Void {
        on(name, function(n) {
            n.getTextAsInt( f );
        });
    }

    override function onAttribute(name:String, value:String):Void {
        if (_attrs.exists( name )) {
            _attrs.get(name).extract( node );
            if (_srattrs.exists( name ))
                _srattrs.remove( name );
        }
        _attr.call(name, value);
    }

    /**
      * called each time a child-node is encountered
      */
    override function onChild(child: Xml):Void {
        var gnh = _nhr.get(child.nodeName);
        if (gnh != null) {
            var nh = gnh();
            nh.handle( child );
        }
        _child.call( child );
    }

    /**
      * called each time a text node is encountered
      */
    override function onTextNode(text:String):Void {
        _text.call( text );
    }

    /**
      * [create and] return a 'buffer' array
      */
    private function getbuffer<T>(buffer_id:String):Array<T> {
        if (!_buffrs.exists(buffer_id)) {
            return untyped (_buffrs[buffer_id] = untyped new Array());
        }
        return untyped _buffrs.get( buffer_id );
    }

    private inline function rmbuffer(buffer_id: String):Bool {
        return _buffrs.remove( buffer_id );
    }

    private inline function buffer<T>(buffer_id:String, buffer_entry:T):Void {
        getbuffer( buffer_id ).push( buffer_entry );
    }

    private function closebuffer<T>(buffer_id:String, ?last_entry:T):Array<T> {
        var res:Array<T> = untyped getbuffer( buffer_id );
        if (last_entry != null) {
            res.push( last_entry );
        }
        rmbuffer( buffer_id );
        return res;
    }

/* === Instance Fields === */

    private var _inits: Array<FunctionalNodeHandler -> Void>;
    private var _reqattrs: Set<String>;
    private var _srattrs: Set<String>;
    private var _attrs: Dict<String, AttrHandler<Dynamic>>;
    private var _nhr: Dict<String, Getter<INodeHandler>>;
    private var _begin: VoidSignal;
    private var _complete: VoidSignal;
    private var _text: Signal<String>;
    private var _child: Signal<Xml>;
    private var _attr: Signal2<String, String>;
    private var _allattrs: Signal<Map<String, String>>;
    private var _attrflags: Signal<Set<String>>;

    // dict used for buffering data
    private var _buffrs: Dict<String, Array<Dynamic>>;

/* === Static Methods === */

    public static function createm(builders:Iterable<FunctionalNodeHandler->Void>):FunctionalNodeHandler {
        var handler = new FunctionalNodeHandler();
        var ba = builders.array();
        if (!ba.empty()) {
            var builder = ba.shift();
            if (!ba.empty()) {
                for (f in builders) {
                    builder = builder.join(f);
                }
            }
            handler.build( builder );
        }
        return handler;
    }

    public static function create(builder: FunctionalNodeHandler->Void):FunctionalNodeHandler {
        var handler = new FunctionalNodeHandler();
        handler.build( builder );
        return handler;
    }
}

class AttrHandler<TOut> {
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
            var outval:TOut = _map( sval );
            extracted.call( outval );
            return outval;
        }
    }
    
    public var name: String;
    public var extracted: Signal<TOut>;
    private var _map: String->TOut;
}

typedef FNHSpec = {
    ?inits: Array<FunctionalNodeHandler -> Void>
}
