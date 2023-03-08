package feathers.utils.type;

/**
 * ...
 * @author Matse
 */
class Property 
{
	// TODO : inline once tested
	static public function existsRead(object:Dynamic, propertyName:String):Bool
	{
		#if flash
		// TODO : use untyped hasOwnProperty ?
		return Reflect.hasField(object, propertyName) || Reflect.hasField(object, "get_" + propertyName);
		#elseif html5
		if (Reflect.hasField(object, propertyName)) return true;
		return untyped propertyName + " in object";
		#else
		// TODO : find a better way to check that a property exists on cpp target
		if (Reflect.hasField(object, propertyName)) return true;
		return Reflect.getProperty(object, propertyName) != null;
		#end
	}

	// TODO : inline once tested
	static public function existsWrite(object:Dynamic, propertyName:String):Bool
	{
		#if flash
		return Reflect.hasField(object, proppropertyName) || Reflect.hasField(object, "set_" + propertyName);
		#elseif html5
		if (Reflect.hasField(object, propertyName)) return true;
		return untyped propertyName + " in object";
		#else
		if (Reflect.hasField(object, propertyName)) return true;
		#end
	}
	
	// TODO : inline once tested
	static public function setPropertyWithCheck(object:Dynamic, propertyName:String, propertyValue:Dynamic):Bool
	{
		#if flash
		if (Reflect.hasField(object, propertyName) || Reflect.hasField(object, "set_" + propertyName))
		{
			Reflect.setProperty(object, propertyName, propertyValue);
			return true;
		}
		return false;
		#elseif html5
		if (untyped propertyName + " in object")
		{
			Reflect.setProperty(object, propertyName, propertyValue);
			return true;
		}
		return false;
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