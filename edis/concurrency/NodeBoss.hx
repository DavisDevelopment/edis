package edis.concurrency;

import tannus.node.ChildProcess;
import edis.concurrency.WorkerPacket;

class NodeBoss extends Boss {
    private var p : ChildProcess;
    public function new(cp : ChildProcess):Void {
        super();
        p = cp;
        init();
    }

    override function _post(data: Dynamic) p.send( data );
    //override function send(type:String, data:Dynamic, encoding:WorkerPacketEncoding=None):Void {
        //p.send(packet(type, data, encoding));
    //}

    override function kill():Void p.kill();

    override function _onMessage(f : Dynamic->Void):Void {
        p.on('message', f);
    }
}
