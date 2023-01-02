package feathers.utils.type;

import haxe.macro.Expr;

class SafeCast
{

	macro public static function safe_cast(value:Expr, type:Expr)
	{
		switch (value.expr)
		{
			case EConst(c):
				//trace('$value is a constant');
				return macro Std.isOfType($value, $type) ? cast $value : null;
			
			default:
				//trace('!$value');
				return macro $b { [(macro var e = $value), (macro Std.is(e, $type) ? cast e : null)] };
		}
	}
	
}