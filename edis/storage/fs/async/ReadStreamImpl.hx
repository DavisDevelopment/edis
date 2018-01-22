package edis.storage.fs.async;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;

using Slambda;
using tannus.FunctionTools;
using tannus.async.Asyncs;

class ReadStreamImpl<T> {
    /* Constructor Function */
    public function new():Void {
        __onPacket = new Signal();
    }

/* === Instance Methods === */

    /**
      * initiates the stream
      */
    public function open(?callback : Cb<RSPacket<T>>):Void {
        if (callback != null)
            __listen( callback );
        __start();
    }

    /**
      * close the Stream
      */
    public function destroy():Void {
        __destroy();
    }

    public function onData(f:T->Void, once:Bool=false):Void {
        __listen(function(?error, ?packet) {
            if (error == null && packet != null) {
                switch ( packet ) {
                    case RSPData( data ):
                        f( data );

                    default: null;
                }
            }
        }, once);
    }

    public function onError(f:Dynamic->Void, once:Bool=false):Void {
        __listen(function(?error, ?packet) {
            if (error != null) {
                f( error );
            }
            else if (packet != null) {
                switch ( packet ) {
                    case RSPError( error ):
                        f( error );

                    default: null;
                }
            }
        }, once);
    }

    /**
      * internal method that actually starts the streaming process
      */
    private function __start():Void {
        throw 'not implemented';
    }

    /**
      * attach a callback for incoming 'packet's
      */
    private function __listen(callback:Cb<RSPacket<T>>, once:Bool=false):Void {
        (once?__onPacket.once:__onPacket.on)(function(packet) {
            switch ( packet ) {
                case RSPError(error):
                    callback(error, null);

                case other:
                    callback(null, other);
            }
        });
    }

    // 'send' a packet
    private inline function pkt(packet: RSPacket<T>):Void {
        __onPacket.call()
    }

    // send a 'close' signal
    private function __close():Void {
        pkt( RSPClose );
    }

    // send data
    private unction __send(data : T):Void {
        pkt(RSPData( data ));
    }
    
    // raise an error
    private function __raise(error : Dynamic):Void {
        pkt(RSPError( error ));
    }

/* === Instance Fields === */

    //private var __onPacket:Null<Cb<RSPacket<T>>>;
    private var __onPacket: Signal<RSPacket<T>>;
}

enum RSPacket<T> {
    RSPData(data : T);
    RSPError(error: Dynamic);
    RSPClose;
}

class ReadStreamTransformer<TIn, TOut> extends ReadStream<TOut> {
    private var _src : ReadStreamImpl<TIn>;

    public function new(src : ReadStreamImpl<TIn>):Void {
        super();

        _src = src;
    }

    override function __start():Void {
        _src.open( __mapper );
    }

    private function __mapper(?error:Dynamic, ?packet:RSPacket<TIn>):Void {
        if (error != null) {
            __raise( error );
        }
        else if (packet != null) {
            switch ( packet ) {
                case RSPData( in_data ):
                    __send(__transform( in_data ));

                case RSPClose:
                    __close();
            }
        }
        else {
            throw 'Error: Neither an error nor a packet was provided';
        }
    }

    private function __transform(in_data : TIn):TOut {
        throw 'not implemented';
    }
}
