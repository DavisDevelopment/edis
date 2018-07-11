package edis.libs.nedb;

import tannus.node.*;
import tannus.async.*;

@:jsRequire('nedb', 'Cursor')
extern class Cursor<T> {
    public function skip(n: Int):Cursor<T>;
    public function limit(n: Int):Cursor<T>;
    public function sort(sortSpec: Dynamic<Dynamic>):Cursor<T>;
    public function projection(project: Dynamic<Dynamic>):Cursor<T>;
    public function exec(callback: Cb<T>):Void;
}
