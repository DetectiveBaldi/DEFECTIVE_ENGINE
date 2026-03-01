package util;

import haxe.macro.Context;
import haxe.macro.Expr;

class MacroUtil
{
    /**
     * Gets a macro value as a string.
     * @param key Value to parse.
     * @return `Expr`
     */
    public static macro function getDefine(key:String):Expr
    {
        return macro $v{Context.definedValue(key)};
    }
}