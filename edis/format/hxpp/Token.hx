package edis.format.hxpp;

import tannus.io.RegEx;
import tannus.io.PRegEx;
import tannus.io.*;
import tannus.ds.*;

enum Token {
    TLiteral(content: String);
    TInline(code: String);
    TPrint(code: String);
}
