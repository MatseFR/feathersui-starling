package feathers.utils.type;

/**
 * ...
 * @author Matse
 */
class Property 
{
	inline static public function existsRead(object:Dynamic, propertyName:String):Bool
	{
		#if flash
		// TODO : use untyped hasOwnProperty ?
		return Reflect.hasField(object, propertyName) || Reflect.hasField(object, "get_" + propertyName);
		#elseif html5
		if (Std.isOfType(object, String))
		{
			// trace("string");
			return false;
		}
		var type = Type.typeof(object);
		switch (type)
		{
			case Type.ValueType.TNull, Type.ValueType.TInt, Type.ValueType.TFloat, Type.ValueType.TBool, Type.ValueType.TFunction, Type.ValueType.TUnknown :
				// trace("trash");
				return false;
			
			case Type.ValueType.TObject :
				// trace("object");
				return Reflect.hasField(object, propertyName);
			
			default :
				// trace("default");
				if (Reflect.hasField(object, propertyName))
				{
					return true;
				}
				return Reflect.getProperty(object, propertyName) != null;
		}
		#else
		// TODO : find a better way to check that a property exists on cpp target
		if (Reflect.hasField(object, propertyName)) return true;
		return Reflect.getProperty(object, propertyName) != null;
		#end
	}

	inline static public function existsWrite(object:Dynamic, propertyName:String):Bool
	{
		#if flash
		return Reflect.hasField(object, propertyName) || Reflect.hasField(object, "set_" + propertyName);
		#elseif html5
		if (Reflect.hasField(object, propertyName)) return true;
		return untyped propertyName + " in object";
		#else
		if (Reflect.hasField(object, propertyName)) return true;
		return Reflect.getProperty(object, propertyName) != null;
		#end
	}
	
	inline static public function read(object:Dynamic, propertyName:String):Dynamic
	{
		return Reflect.getProperty(object, propertyName);
	}
	
	inline static public function write(object:Dynamic, propertyName:String, propertyValue:Dynamic):Void
	{
		Reflect.setProperty(object, propertyName, propertyValue);
	}
	
	static public function writeWithCheck(object:Dynamic, propertyName:String, propertyValue:Dynamic):Bool
	{
		#if flash
		if (Reflect.hasField(object, propertyName) || Reflect.hasField(object, "set_" + propertyName))
		{
			Reflect.setProperty(object, propertyName, propertyValue);
			return true;
		}
		return false;
		//#elseif html5
		//if (untyped propertyName + " in object")
		//{
			//Reflect.setProperty(object, propertyName, propertyValue);
			//return true;
		//}
		//return false;
		#else
		try
		{
			Reflect.setProperty(object, propertyName, propertyValue);
		}
		catch (e)
		{
			return false;
		}
		return true;
		//Reflect.setProperty(object, propertyName, propertyValue);
		//return Reflect.getProperty(object, propertyName) == propertyValue;
		#end
	}
	
}