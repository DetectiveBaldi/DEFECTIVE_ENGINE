package tools;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class CompileTime
{
    public macro static function getDefine(key:String):Expr
	{
		var value:String = Context.definedValue(key);

		if (value == null)
			value = "";
		else
			value = value.split("=")[0];

		return macro $v{value};
	}
}