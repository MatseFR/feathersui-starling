package feathers.starling.utils.type;

class TypeUtil 
{

	inline static public function isObject(object:Dynamic):Bool
	{
		if (Std.isOfType(object, String)) 
		{
			return false;
		}
		var type:Type.ValueType = Type.typeof(object);
		switch (type)
		{
			case Type.ValueType.TNull, Type.ValueType.TInt, Type.ValueType.TFloat, Type.ValueType.TBool, Type.ValueType.TFunction, Type.ValueType.TUnknown :
				return false;
			
			case Type.ValueType.TObject :
				return true;
			
			default : // ValueType.TClass
				return true;
		}
	}
	
}