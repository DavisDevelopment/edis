package edis.concurrency;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using tannus.macro.MacroTools;

class WorkerMacros {
    /**
      * add 'main' method to all subclasses of worker
      */
    public static macro function workerBuilder():Array<Field> {
        // get the current class
        var lc = Context.getLocalClass().get();
        // get the TypePath to that class
        var ctp:TypePath = lc.fullName().toTypePath();
        // get the list of Fields for the class
        var fields = Context.getBuildFields();
        // add a new Field (public static main)
        fields.push({
            name: 'main',
            access: [Access.APublic, Access.AStatic],
            pos: Context.currentPos(),
            kind: FieldType.FFun({
                args: [],
                params: null,
                ret: null,
                expr: macro {
                    new $ctp().__start();
                }
            })
        });
        return fields;
    }

#if macro

    public static function resolve_script_path(path : TypePath):String {
        return '';
    }

#end
}
