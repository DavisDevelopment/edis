package edis.libs.nedb;

import tannus.node.*;
import tannus.async.*;

#if (js && node)
@:require('nedb', 'persistence')
#end
extern class Persistence {
/* === Instance Methods === */

    public function compactDatafile():Void;

/* === Instance Fields === */
    
    public var filename : Null<String>;
}
