package feathers.utils.type;
import haxe.Constraints.Function;
//import haxe.macro.Context;
//import haxe.macro.Expr;
import openfl.errors.Error;

/**
 * ...
 * @author Matse
 */
class ArgumentsCount 
{
	
	inline public static function count_args(func:Function):Int
	{
		#if flash
		return untyped func.length;
		#elseif neko
		return untyped ($nargs)(func);
		#elseif cpp
		return untyped func.__ArgCount();
		#elseif html5
		return untyped func.length;
		#else
		throw new Error("ArgumentsCount.count_args ::: unsupported platform");
		#end
	}

	//macro public static function count_args(func:Expr)
	//{
		//if (Context.defined("flash"))
		//{
			//return macro untyped $func.length;
		//}
		//else if (Context.defined("neko"))
		//{
			////return macro untyped ($nargs)($func);
			//var f = "untyped ($nargs)";
			//return macro $i{f}($func);
		//}
		//else if (Context.defined("cpp"))
		//{
			//return macro untyped $func.__ArgCount();
		//}
		//else if (Context.defined("html5"))
		//{
			//return macro untyped $func.length;
		//}
		//return macro 123;
	//}
	
}