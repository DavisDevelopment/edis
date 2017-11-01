package edis.concurrency;

import tannus.ds.Maybe;
import tannus.ds.Dict;
import tannus.ds.Obj;
import tannus.io.EventDispatcher;

import edis.concurrency.WorkerPacket;
import edis.concurrency.WorkerPacket as Packet;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using Slambda;
using tannus.ds.ArrayTools;

class DataDispatcher {
    private var o : Owner;
    public function new(o : Owner):Void {
        this.o = o;
    }

    public function on(name:String, handler:Dynamic->Void):Void {
        o.on(name, wrap(handler));
    }

    public function once(name:String, handler:Dynamic->Void):Void {
        o.once(name, wrap(handler));
    }
    
    public function when(name:String, check:Dynamic->Bool, handler:Dynamic->Void):Void {
        o.when(name, wrapb(check), wrap(handler));
    }
    
    private function wrap(f : Dynamic->Void):IPacket->Void {
        return (x : IPacket) -> f( x.data );
    }
    private inline function wrapb(f : Dynamic->Bool):IPacket->Bool {
        return untyped wrap( f );
    }
}
private typedef Owner = #if worker edis.concurrency.Worker #else edis.concurrency.Boss #end;
