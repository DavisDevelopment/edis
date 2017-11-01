package edis.concurrency;

import tannus.io.*;
import tannus.ds.*;

import edis.concurrency.WorkerPacket;
import edis.concurrency.WorkerPacket as Packet;

import Slambda.fn;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using Slambda;
using tannus.ds.ArrayTools;

class Processor extends Worker {
    /* Constructor Function */
    private function new() {
        super();

        ps = new EventDispatcher();
        @:privateAccess ps.__checkEvents = false;
    }

/* === Instance Methods === */
    /**
      * initialize handlers
      */
    private function __listen__():Void {
        null;
    }

    // start the process
    override function __start():Void {
        __listen__();

        super.__start();
    }

    /**
      * handle incoming packets
      */
    override function onPacket(packet : Packet):Void {
        // broadcast [packet] on [ps]
        ps.dispatch(packet.type, packet.data);
    }

    private inline function on<T>(t:String, f:T->Void):Void ps.on(t, f);
    private inline function once<T>(t:String, f:T->Void):Void ps.once(t, f);
    private inline function when<T>(t:String, c:T->Bool, f:T->Void):Void ps.when(t, c, f);

    private var ps:EventDispatcher;
}
