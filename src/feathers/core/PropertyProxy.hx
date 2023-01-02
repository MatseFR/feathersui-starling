/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import haxe.iterators.ArrayIterator;

/**
 * Detects when its own properties have changed and dispatches an event
 * to notify listeners.
 *
 * <p>Supports nested <code>PropertyProxy</code> instances using attribute
 * <code>&#64;</code> notation. Placing an <code>&#64;</code> before a property name
 * is like saying, "If this nested <code>PropertyProxy</code> doesn't exist
 * yet, create one. If it does, use the existing one."</p>
 *
 * @productversion Feathers 1.0.0
 */
abstract PropertyProxy(PropertyProxyReal)
{
	/**
	 * Creates a <code>PropertyProxy</code> from a regular old <code>Object</code>.
	 */
	public static function fromObject(source:Dynamic, onChangeCallback:PropertyProxyReal->String->Void = null):PropertyProxy
	{
		var fields:Array<String>;
		if (Std.isOfType(source, Dynamic))
		{
			fields = Reflect.fields(source);
		}
		else
		{
			fields = Type.getInstanceFields(Type.getClass(source));
		}
		var newValue:PropertyProxy = new PropertyProxy(onChangeCallback);
		
		for (field in fields)
		{
			newValue.setProp(field, Reflect.getProperty(source, field));
		}
		
		return newValue;
	}
	
	/**
	 * Construtor.
	 */
	public inline function new(onChangeCallback:PropertyProxyReal->String->Void = null) 
	{
		this = new PropertyProxyReal(onChangeCallback);
	}
	
	/**
	 * 
	 */
	public function iterator():ArrayIterator<String>
	{
		return this.namesIterator();
	}
	
	@:op([])
	@:op(a.b)
	public function getProp(name:String):Dynamic
	{
		return this.getProperty(name);
	}
	
	@:op([])
	@:op(a.b)
	public function setProp(name:String, value:Dynamic):Void
	{
		this.setProperty(name, value);
	}
	
}