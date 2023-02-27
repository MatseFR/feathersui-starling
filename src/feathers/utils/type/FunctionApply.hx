package feathers.utils.type;
import haxe.Constraints.Function;

/**
 * Meant as a replacement for as3's Function.apply. Based on Starling's Execute class.
 */
class FunctionApply 
{
	/** Executes a function with the specified arguments and returns result. If the argument count does not match
     *  the function, the argument list is cropped / filled up with <code>null</code> values. */
	public static function apply(func:Function, args:Array<Dynamic> = null):Dynamic
    {
        if (func != null)
        {
            if (args == null) args = [];
            
            #if flash
            var maxNumArgs:Int = untyped func.length;
            #elseif neko
            var maxNumArgs:Int = untyped ($nargs)(func);
            #elseif cpp
            var maxNumArgs:Int = untyped func.__ArgCount();
			#elseif html5
			var maxNumArgs:Int = untyped func.length;
            #else
            var maxNumArgs:Int = -1;
            #end
			
            for (i in args.length...maxNumArgs)
                args[i] = null;
			
            // In theory, the 'default' case would always work,
            // but we want to avoid the 'slice' allocations.
			
            switch (maxNumArgs)
            {
                case 0:  return func();
                case 1:  return func(args[0]);
                case 2:  return func(args[0], args[1]);
                case 3:  return func(args[0], args[1], args[2]);
                case 4:  return func(args[0], args[1], args[2], args[3]);
                case 5:  return func(args[0], args[1], args[2], args[3], args[4]);
                case 6:  return func(args[0], args[1], args[2], args[3], args[4], args[5]);
                case 7:  return func(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
                case -1: return Reflect.callMethod(func, func, args);
                default: return Reflect.callMethod(func, func, args.slice(0, maxNumArgs));
            }
        }
		return null;
    }
	
}