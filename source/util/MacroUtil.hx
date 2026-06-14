package util;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class MacroUtil
{
    public static macro function getDefine(k:String):Expr
    {
        return macro $v{Context.definedValue(k)};
    }

    public static function sanitizeDefine(v:String):String
    {
        if (v == null)
            return "";

        return v.split("=")[0];
    }
}