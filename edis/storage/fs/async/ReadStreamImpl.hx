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
        __chunkBuffer = new Array();
        __allowBuffering = true;
        __status = SSUnbound;
    }

/* === Instance Methods === */

    /**
      * initiates the stream
      */
    public function open():Void {
        onData(function(chunk: T) {
            if ( __allowBuffering ) {
                //__chunkBuffer.push( chunk );
                __buffer( chunk );
            }
        });
        __start();
    }

    /**
      * pause [this] Stream
      */
    public function pause():Void {
        __pause();
    }

    public function isPaused():Bool {
        return __isPaused();
    }

    public function resume():Void {
        __resume();
    }

    public function setBuffering(status: Bool):Void {
        __allowBuffering = status;
    }

    public function flush():Void {
        __flush();
    }

    /**
      * close the Stream
      */
    public function destroy():Void {
        __destroy();
    }

    public function getStatus():RStreamStatus {
        return __getStatus();
    }

    public function onData(f:T->Void, ?once:Bool=false):Void {
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

    public function onError(f:Dynamic->Void, ?once:Bool=false):Void {
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

    public function onEnd(f: Void->Void):Void {
        __listen(function(?error, ?packet) {
            if (error == null && packet != null) {
                switch ( packet ) {
                    case RSPEnd:
                        f();

                    default: null;
                }
            }
        });
    }

    public function onClose(f: Void->Void):Void {
        __listen(function(?error, ?packet) {
            if (error == null && packet != null) {
                switch ( packet ) {
                    case RSPClose:
                        f();

                    default: null;
                }
            }
        });
    }

    /**
      * internal method that actually starts the streaming process
      */
    private function __start():Void {
        //throw 'not implemented';
    }

    private function __pause():Void throw 'not implemented';
    private function __isPaused():Bool throw 'not implemented';
    private function __resume():Void throw 'not implemented';

    private function __flush():Void {
        var chunk: T;

        while (__chunkBuffer.length > 0) {
            chunk = __chunkBuffer.shift();
            __send( chunk );
        }
    }

    private function __buffer(chunk: T):Void {
        __chunkBuffer.push( chunk );
    }

    private function __destroy():Void {
        throw 'not implemented';
    }

    private function __getStatus():RStreamStatus {
        switch ( __status ) {
            case SSUnbound, SSBuffered:
                return __status;

            case SSOpen:
                if (isPaused()) {
                    if (__allowBuffering && __chunkBuffer.length > 0) {
                        return SSBuffered;
                    }
                    else {
                        return SSPaused;
                    }
                } else return SSOpen;

            case SSEnded, SSClosed:
                if (__allowBuffering && __chunkBuffer.length > 0) {
                    return SSBuffered;
                }
                else {
                    return __status;
                }

            case _:
                throw 'betty';
        }
    }

    /**
      * attach a callback for incoming 'packet's
      */
    private function __listen(callback:Cb<RSPacket<T>>, once:Bool=false):Void {
        __onPacket.on(function(packet) {
            switch ( packet ) {
                case RSPError(error):
                    callback(error, null);

                case other:
                    callback(null, other);
            }
        }, once);
    }

    // 'send' a packet
    private function pkt(packet: RSPacket<T>):Void {
        __onPacket.call( packet );
    }

    // send a 'close' signal
    private function __close():Void {
        pkt( RSPClose );
        __status = SSClosed;
    }

    private function __end():Void {
        pkt( RSPEnd );
        __status = SSEnded;
    }

    // send data
    private function __send(data : T):Void {
        __status = SSOpen;
        pkt(RSPData(__itransform( data )));
    }
    
    // raise an error
    private function __raise(error : Dynamic):Void {
        pkt(RSPError( error ));
    }

    // we might perform data transformation here
    private function __itransform(data: T):T {
        return data;
    }

/* === Instance Fields === */

    //private var __onPacket:Null<Cb<RSPacket<T>>>;
    private var __onPacket: Signal<RSPacket<T>>;
    private var __chunkBuffer: Array<T>;
    private var __allowBuffering: Bool;

    private var __status: RStreamStatus;
}

enum RSPacket<T> {
    RSPData(data : T);
    RSPError(error: Dynamic);
    RSPClose;
    RSPEnd;
}

enum RStreamStatus {
    SSUnbound;
    SSOpen;
    SSPaused;
    SSBuffered;
    SSClosed;
    SSEnded;
}
