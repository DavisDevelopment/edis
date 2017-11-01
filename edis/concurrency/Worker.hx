package edis.concurrency;

import tannus.ds.Maybe;
import tannus.ds.Dict;
import tannus.ds.Obj;
import tannus.io.EventDispatcher;

#if node
import tannus.node.Process;
#end

import js.html.WorkerGlobalScope;
import js.html.DedicatedWorkerGlobalScope as Dws;

import edis.concurrency.WorkerPacket;
import edis.concurrency.WorkerPacket as Packet;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using Slambda;
using tannus.ds.ArrayTools;


/**
  * class used to handle various long-running tasks from within a node subprocess
  */
@:autoBuild(edis.concurrency.WorkerMacros.workerBuilder())
class Worker {
	/* Constructor Function */
	public function new():Void {
	    replyListeners = new Dict();
	    _ed = new EventDispatcher();
	    data = new DataDispatcher( this );

	    @:privateAccess _ed.__checkEvents = false;
	}

/* === Instance Methods === */

	/**
	  * entry point for the app
	  */
	private function __start():Void {
		listenForMessages( _onMessage );
	}

	/**
	  * process incoming packets
	  */
	private function onPacket(packet : WorkerIncomingPacket):Void {
	    null;
	}

	/**
	  * process incoming messages into packets
	  */
	private function _onMessage(raw : Dynamic):Void {
	    if (Packet.isPacket( raw )) {
	        var packet:Packet = cast raw;
	        packet = packet.decode();
	        if (packet.type.startsWith( Packet.REPLYPREFIX )) {
	            return _onReply( packet );
	        }

	        var incoming:WorkerIncomingPacket = ipacket( packet );
	        if (_ed.canDispatch( incoming.type )) {
	            _ed.dispatch(incoming.type, incoming);
	        }
	        onPacket( incoming );
	    }
	}

	private function _onReply(packet : Packet):Void {
	    var replyToId:String = packet.type.after( Packet.REPLYPREFIX );
	    if (replyListeners.exists( replyToId )) {
	        var entry = replyListeners[replyToId];
	        entry.listener( packet.data );
	        replyListeners.remove( replyToId );
	    }
	}

	/**
	  * send a packet
	  */
	public function send(type:String, data:Dynamic, ?encoding:WorkerPacketEncoding, ?onResponse:Dynamic->Void):Void {
	    if (onResponse == null) {
            _post(packet(type, data, encoding));
        }
        else {
            var outPacket:Packet = packet(type, data, encoding);
            replyListeners[outPacket.id] = {
                packet: outPacket,
                listener: onResponse
            };
            _post( outPacket );
        }
	}

	public inline function on(n:String, f:WorkerIncomingPacket->Void):Void _ed.on(n, f);
	public inline function once(n:String, f:WorkerIncomingPacket->Void):Void _ed.once(n, f);
	public inline function off(n:String, ?f:WorkerIncomingPacket->Void):Void _ed.off(n, f);
	public inline function when(n:String, check:WorkerIncomingPacket->Bool, f:WorkerIncomingPacket->Void):Void _ed.when(n, check, f);

    /**
      * create a Packet
      */
	private function packet(type:String, data:Dynamic, ?encoding:WorkerPacketEncoding):Packet {
	    return Packet.create(type, data, encoding);
	}

	private function ipacket(packet:Packet):WorkerIncomingPacket {
	    return new WorkerIncomingPacket(this, packet);
	}

    /**
      * send [message] to [this] Process's parent
      */
	private function _post(message : Dynamic):Void {
	    if (isWebWorker()) {
	        self.postMessage( message );
	    }
        else {
            #if node
            process.send( message );
            #end
        }
	}

	/**
	  * listen for messages
	  */
	private function listenForMessages(handler : Dynamic -> Void):Void {
	    if (isWebWorker()) {
	        self.onmessage = (function(event : Dynamic) {
	            handler( event.data );
	        });
	    }
        else {
            #if node
            process.on('message', handler);
            #end
        }
	}

	/**
	  * terminate [this] process
	  */
	private function exit(code : Int):Void {
	    if (isWebWorker()) {
	        self.close();
	    }
        else {
            #if node
            process.exit( code );
            #end
        }
	}

    /**
      * check whether [this] is a WebWorker
      */
	private inline function isWebWorker():Bool {
	    #if !node
	    return true;
	    #else
	    return (
	        (untyped __js__("typeof self !== 'undefined'")) &&
	        Std.is((untyped __js__('self')), Dws)
	    );
	    #end
	}

    //
	private inline function defer(f : Void->Void):Void {
	    #if node
	    (untyped __js__('process.nextTick')( f ));
	    #else
	    self.setTimeout(f, 0);
	    #end
	}

/* === Computed Instance Fields === */

    public var self(get, never):Maybe<Dws>;
    private function get_self():Maybe<Dws> {
        if (isWebWorker()) {
            return cast (untyped __js__('self'));
        }
        else return null;
    }

    #if node
    public var process(get, never):Null<Process>;
    private inline function get_process():Null<Process> {
        if (!isWebWorker()) {
            return untyped __js__('process');
        } else return null;
    }
    #end

    public var oself(get, never):Maybe<Obj>;
    private function get_oself():Maybe<Obj> {
        var s = self;
        return s.ternary(Obj.fromDynamic( s ), null);
    }

/* === Instance Fields === */

    public var data : DataDispatcher;
    private var replyListeners : Dict<String, {packet:Packet,listener:Dynamic->Void}>;
    private var _ed : EventDispatcher;
}
