package edis.concurrency;

import tannus.ds.Uuid;
import tannus.encoding.StructuredCloneEncoder as Sce;
import tannus.encoding.StructuredCloneDecoder as Scd;

import haxe.Json as JSON;
import haxe.Serializer;
import haxe.Unserializer;

using StringTools;
using tannus.ds.StringUtils;

@:forward
abstract WorkerPacket (TWorkerPacket) from TWorkerPacket to TWorkerPacket {
    /* Constructor Function */
    public inline function new(wp : TWorkerPacket):Void {
        this = wp;
    }

/* === Methods === */

    /**
      * check whether [this] packet is encoded
      */
    public function isEncoded(?t : WorkerPacketEncoding):Bool {
        return ((t != null ? t : this.encoding) != None);
    }

    /**
      * create a clone of [this] packet
      */
    public function clone():WorkerPacket {
        return new WorkerPacket({
            id: this.id,
            type: this.type,
            encoding: this.encoding,
            data: this.data
        });
    }

    /**
      * encode an unencoded packet
      */
    public function encode(etype : WorkerPacketEncoding):WorkerPacket {
        var copy:WorkerPacket = clone();
        //var etype:WorkerPacketEncoding = (type == null ? this.encoding : type);
        if (!isEncoded()) {
            switch ( etype ) {
                case Json:
                    copy.encoding = Json;
                    copy.data = JSON.stringify( this.data );

                case Haxe:
                    copy.encoding = Haxe;
                    copy.data = Serializer.run( this.data );

                case Clone:
                    copy.encoding = Clone;
                    copy.data = Sce.run( this.data );

                default:
                    null;
            }
        }
        else {
            throw 'Error: Packet is already encoded';
        }
        return copy;
    }

    /**
      * convert (if necessary) into a unencoded packet
      */
    public function decode():WorkerPacket {
        switch ( this.encoding ) {
            case Json:
                return {
                    id: this.id,
                    type: this.type,
                    encoding: None,
                    data: JSON.parse(untyped this.data)
                };

            case Haxe:
                return {
                    id: this.id,
                    type: this.type,
                    encoding: None,
                    data: Unserializer.run(untyped this.data)
                };

            case Clone:
                return {
                    id: this.id,
                    type: this.type,
                    encoding: None,
                    data: Scd.run(untyped this.data)
                };

            case None:
                return this;
        }
    }

    /**
      * check whether the given anonymous object is a packet
      */
    public static inline function isPacket(o : Dynamic):Bool {
        return (
            (o.id != null && (o.id is String)) &&
            (o.type != null && (o.type is String)) &&
            (o.encoding != null && WorkerPacketEncoding.isWorkerPacketEncoding( o.encoding ))
        );
    }

    /**
      * create a new Packet
      */
    public static inline function create(type:String, data:Dynamic, encoding:WorkerPacketEncoding=Clone) {
        return fromTWorkerPacket({
            type: type,
            data: data,
            encoding: None
        }).encode( encoding );
    }

    @:from
    public static function fromTWorkerPacket(o : TWorkerPacket):WorkerPacket {
        if (o.id == null)
            o.id = Uuid.create();
        return new WorkerPacket( o );
    }

    public static inline var REPLYPREFIX:String = '[[REPLYTO]]:';
}

typedef TWorkerPacket = {
    ?id: String,
    type: String,
    encoding: WorkerPacketEncoding,
    data: Dynamic
};

@:enum
abstract WorkerPacketEncoding (String) from String to String {
    var None = 'none';
    var Json = 'json';
    var Haxe = 'haxe';
    var Clone = 'sc';

    /**
      * check that the given String refers to a valid WorkerPacketEncoding
      */
    public static inline function isWorkerPacketEncoding(s : String):Bool {
        return (
            (s == None) ||
            (s == Json) ||
            (s == Haxe) ||
            (s == Clone)
        );
    }
}
