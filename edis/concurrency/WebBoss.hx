package edis.concurrency;

import edis.concurrency.WorkerPacket;

import js.html.Worker as NWorker;

class WebBoss extends Boss {
    private var w : NWorker;
    public function new(ww : NWorker):Void {
        super();

        w = ww;
        init();
    }
    override function _post(data : Dynamic):Void w.postMessage( data );
    //override function send(type:String, data:Dynamic, encoding:WorkerPacketEncoding=None):Void {
        //w.postMessage(packet(type, data, encoding));
    //}
    override function kill():Void w.terminate();
    override function _onMessage(f : Dynamic->Void):Void {
        w.addEventListener('message', function(event) {
            f( event.data );
        });
    }
}
