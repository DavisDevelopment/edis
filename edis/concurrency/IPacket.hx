package edis.concurrency;

import tannus.ds.Uuid;
import tannus.ds.Dict;

import haxe.Json as JSON;
import haxe.Serializer;
import haxe.Unserializer;

#if !worker
import edis.concurrency.Boss;
#end
import edis.concurrency.WorkerPacket;

using StringTools;
using tannus.ds.StringUtils;

@:access(#if worker edis.concurrency.Worker #else edis.concurrency.Boss #end)
class IPacket {
    /* Constructor Function */
    public function new(owner:Owner, packet:WorkerPacket):Void {
        this.owner = owner;
        this.packet = packet;

        id = packet.id;
        type = packet.type;
        data = packet.data;
    }

    public function reply(responseData:Dynamic, ?enc:WorkerPacketEncoding):Void {
        var resPacket:WorkerPacket = new WorkerPacket({
            id: id,
            type: (WorkerPacket.REPLYPREFIX + id),
            data: responseData,
            encoding: None
        });
        resPacket = resPacket.encode((enc != null) ? enc : packet.encoding);

        owner._post( resPacket );
    }

    public var id(default, null):String;
    public var type(default, null):String;
    public var data(default, null):Dynamic;

    private var owner : Owner;
    private var packet : WorkerPacket;
}

typedef Owner = #if worker edis.concurrency.Worker #else edis.concurrency.Boss #end;
