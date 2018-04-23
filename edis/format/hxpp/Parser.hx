package edis.format.hxpp;

import tannus.io.RegEx;
import tannus.io.PRegEx;
import tannus.io.*;
import tannus.ds.*;

import edis.format.hxpp.Token;

import Slambda.fn;
import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

class Lexer {
    /**
      *
      */
    public static function tokenize(s: String):Array<Token> {
        var tree = new Array();
        inline function add(tk: Token) tree.push( tk );
        var tag = tagre(), li:Int = null;
        tag.iter(s, function(m) {
            li = m.matchedPos().len;
            add(TLiteral(m.matchedLeft().trim()));
            var g = m.groups();
            trace(g[0]);
            add((switch (g[1]) {
                case 'hxpp': Token.TInline;
                case '=': Token.TPrint;
                case other: throw 'DafuqError';
            })(g[0].trim()));
        });
        if (li == null) {
            add(TLiteral( s ));
        }
        else {
            add(TLiteral(s.slice(li)));
        }
        return tree;
    }

    static function tagre():RegEx return re(pre( _tag ));
    static function ptagre():RegEx return re(pre( _printTag ));

    static function _tag(r: PRegEx):PRegEx {
        return 
        r.add('<?', true)
        .group(function(_: PRegEx) {
            _.add('hxpp', false).or('=', true);
        }, true)
        .anything(true, true)
        .add('?>', true);
    }

    static function _printTag(r: PRegEx):PRegEx {
        return r.add('<?=', true).anything(true, true).add('?>', true);
    }

    inline static function pre(f: PRegEx->PRegEx):PRegEx {
        //var re = new PRegEx();
        //return f( re );
        return f(new PRegEx());
    }
    inline static function re(x: PRegEx):RegEx {
        trace(x.generate());
        return x.toRegEx();
    }
}
