package edis.concurrency;

import tannus.ds.Dict;
import tannus.io.Signal;
import tannus.io.EventDispatcher;

import edis.concurrency.WorkerPacket;

#if node
import tannus.node.ChildProcess;
#end

import js.html.Worker as NWorker;

import Slambda.fn;

using StringTools;
using tannus.ds.StringUtils;

class Boss {
    /* Constructor Function */
    public function new():Void {
        replyListeners = new Dict();
        packetEvent = new Signal();
        _pb = new EventDispatcher();
        @:privateAccess _pb.__checkEvents = false;
    }

/* === Instance Methods === */

    /**
      * initialize [this]
      */
    public function init():Boss {
        _listen();
        return this;
    }

    public function send(type:String, data:Dynamic, ?encoding:WorkerPacketEncoding, ?onResponse:Dynamic->Void):Void {
        var pack = packet(type, data, encoding);
        if (onResponse != null) {
            //trace('awaiting response from ${pack.id}');
            replyListeners[pack.id] = {
                packet: pack,
                listener: onResponse
            };
        }
        else {
            //trace('no response');
        }
        _post( pack );
    }

    private function _post(data : Dynamic):Void {}

    public function kill():Void {
        return ;
    }

    /**
      * listen for messages
      */
    private function _onMessage(handler : Dynamic -> Void):Void {
        return ;
    }

    // handle incoming 'reply' packet
    private function _onReply(packet : WorkerPacket):Void {
        var replyToId:String = packet.type.after( WorkerPacket.REPLYPREFIX );
        //trace('processing response from $replyToId');
        if (replyListeners.exists( replyToId )) {
            var entry = replyListeners[replyToId];
            entry.listener( packet.data );
            replyListeners.remove( replyToId );
        }
        else {
            //trace('unhandled REPLY:');
            //trace( packet );
        }
    }

    /**
      * register a packet event handler
      */
    public inline function onPacket(handler:BossIncomingPacket->Void, once:Bool=false):Void {
        packetEvent.on(handler, once);
    }

    /**
      * register an event handler for the given type
      */
    public inline function on(type:String, handler:BossIncomingPacket->Void):Void {
        _pb.on(type, handler);
    }

    public inline function once(type:String, handler:BossIncomingPacket->Void):Void {
        _pb.once(type, handler);
    }

    public inline function when(type:String, check:BossIncomingPacket->Bool, handler:BossIncomingPacket->Void):Void {
        _pb.when(type, check, handler);
    }

    public inline function off(type:String, handler:BossIncomingPacket->Void):Void {
        _pb.off(type, handler);
    }

    /**
      * start listening for packets
      */
    private function _listen():Void {
        _onMessage(function(o : Dynamic) {
            if (isPacket( o )) {
                //packetEvent.call(cast o);
                var pack:WorkerPacket = cast o;
                pack = pack.decode();
                if (pack.type.startsWith(WorkerPacket.REPLYPREFIX))
                    return _onReply( pack );
                
                var i = new BossIncomingPacket(this, pack);

                packetEvent.call( i );
                _pb.dispatch(i.type, i);
            }
        });
    }

    /**
      * create a packet
      */
    private function packet(type:String, data:Dynamic, ?encoding:WorkerPacketEncoding):WorkerPacket {
        return WorkerPacket.create(type, data, encoding);
    }

    /**
      * determine whether the given anonymous object is a packet
      */
    private function isPacket(o : Dynamic):Bool {
        return (
            (o.type != null && (o.type is String)) &&
            (o.encoding != null && WorkerPacketEncoding.isWorkerPacketEncoding( o.encoding ))
        );
    }

/* === Instance Fields === */

    public var packetEvent : Signal<BossIncomingPacket>;
    // packet broadcaster
    public var _pb : EventDispatcher;
    public var data : DataDispatcher;

    private var replyListeners : Dict<String, {packet:WorkerPacket,listener:Dynamic->Void}>;

/* === Static Methods === */

    // 'hire' a ChildProcess
#if node
    public static function hire_cp(name : String):Boss {
        var cp:ChildProcess;
        #if release
            cp = ChildProcess.fork('./resources/app/scripts/$name');
        #else
            cp = ChildProcess.fork( './scripts/$name' );
        #end
        return new NodeBoss( cp );
    }
#end

    /**
      * 'hire' a WebWorker
      */
    public static function hire_ww(name : String):Boss {
        var nativeWorkerObject:NWorker = new NWorker(
            #if cordova
            '../js/${name}.js'
            #else
            '../scripts/${name}.js'
            #end
        );
        return new WebBoss( nativeWorkerObject );
    }
}
