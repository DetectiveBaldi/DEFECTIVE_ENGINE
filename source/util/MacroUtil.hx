package util;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class MacroUtil
{
    public static macro function getDefine(key:String):Expr
    {
        return macro $v{Context.definedValue(key)};
    }

    public static function sanitizeDefine(value:String):String
    {
        return value?.split("=")[0] ?? "";
    }
}