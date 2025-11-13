package util;

import haxe.macro.Context;
import haxe.macro.Expr;

class MacroUtil
{
    public static macro function getDefine(key:String):Expr
    {
        return macro $v{Context.definedValue(key)};
    }
}