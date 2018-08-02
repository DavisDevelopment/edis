package edis.dom;

#if !macro
import tannus.io.*;
import tannus.ds.*;
import tannus.geom.*;
import tannus.html.Element;
import tannus.html.Elementable;
import tannus.html.ElStyles;
import tannus.html.Win;
import tannus.html.JSFunction;
import tannus.async.*;
#end

import haxe.rtti.Meta;
import haxe.Constraints.Function;
import haxe.extern.EitherType as Either;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;

#if !macro
import Std.is as istype;
import tannus.math.TMath.*;
import edis.dom.Styles;
import edis.Globals.*;
#end

#if !macro
using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.FunctionTools;
using tannus.async.Asyncs;
using tannus.ds.AnonTools;
using tannus.ds.MapTools;
using tannus.ds.DictTools;
#end
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

/**
  mixin class for working with JQuery (Element) instances
 **/
class Elements {
#if !macro
    public static function allData(e: Element):Anon<Dynamic> {
        return Anon.of(safely(e, _.data(), {}, false));
    }

    public static function getAll(e: Element):Array<Element> {
        return safely(e, _.toArray(), []);
    }

    public static function getChildren(e: Element):Array<Element> {
        return getAll(e.children());
    }

    public static function getAllChildren(e: Element):Array<Array<Element>> {
        return getAll(e).map(getChildren);
    }
#end

    public static macro function safely<T>(elem:ExprOf<Element>, safeExpr:ExprOf<T>, nullExpr:ExprOf<T>, rest:Array<Expr>):ExprOf<T> {
        var checkExpr:Expr = (macro ($elem != null));
        var testExpr:Expr = macro (untyped {
            js.Syntax.code('console.log({0})', $elem);
        });

        var checkEmptiness:Bool = false;
        switch rest {
            case []:
                null;

            case [{expr:be=EConst(CIdent(sbe='true'|'false'))}]:
                checkEmptiness = (switch sbe {
                    case 'true': true;
                    case 'false', _: false;
                });

            case _:
                Context.error('Invalid restargs: ${rest.map(x->x.expr)}', Context.currentPos());
        }

        // adjust [checkExpr] for new emptiness-check
        if (checkEmptiness)
            checkExpr = macro ($checkExpr && ($elem.length > 0));

        // modify the given expressions
        safeExpr = safeExpr.replace(macro _, elem);
        nullExpr = nullExpr.replace(macro _, elem);

        var resExpr:Expr = (macro if ($checkExpr) $safeExpr else $nullExpr);
        //...

        return resExpr;
    }
}

#if macro
typedef Element = Dynamic;
typedef Anon<T> = Dynamic<T>;
#end
