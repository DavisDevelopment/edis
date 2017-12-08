package edis.core;

import tannus.ds.*;
import tannus.io.*;
import tannus.html.*;

import edis.Globals.*;

import haxe.extern.EitherType;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.Json;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

@:forward
abstract HistoryState (CHistoryState) from CHistoryState to CHistoryState {
    /* Constructor Function */
    public inline function new(page:String, data:Dynamic):Void {
        this = {
            page: page,
            data: data
        };
    }

/* === Instance Methods === */

    /**
      * convert to an EncodedHistoryState object
      */
    public function encode():EncodedHistoryState {
        return {
            page: this.page,
            data: Serializer.run( this.data )
        };
    }

    /**
      * create a HistoryState object from an EncodedHistoryState
      */
    @:from
    public static inline function decode(encoded : EncodedHistoryState):HistoryState {
        return new HistoryState(encoded.page, Unserializer.run( encoded.data ));
    }

    /**
      * check that the provided object seems to be compatible with the EncodedHistoryState type
      */
    public static inline function isEncodedHistoryState(x : Dynamic):Bool {
        return (
            (x.page != null && (x.page is String)) &&
            (x.data != null && (x.data is String))
        );
    }
}

typedef CHistoryState = {
    var page : String;
    var data : Dynamic;
};

typedef EncodedHistoryState = {
    var page : String;
    var data : String;
};
