package edis.core;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;
import tannus.html.Element;
import tannus.html.Win;

import edis.dom.*;
import edis.storage.kv.*;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

@:access( edis.core.Application )
class ApplicationStorage {
    public function new(a : Application):Void {
        var la = a.localStorageArea();
        var ta = a.tempStorageArea();
        local = new Storage( la );
        temp = new Storage( ta );
        a.require(function(req) {
            //req.vasync( la.initialize );
            //req.vasync( ta.initialize );
            req.vasync(untyped local.initialize);
            req.vasync(untyped temp.initialize);
        });
    }

    public var local : Storage;
    public var temp : Storage;
}
