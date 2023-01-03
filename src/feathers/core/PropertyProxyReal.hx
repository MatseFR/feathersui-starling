/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import haxe.iterators.ArrayIterator;

/**
 * ...
 * @author Matse
 */
class PropertyProxyReal 
{
	/**
	 * Constructor.
	 */
	public function new(onChangeCallback:PropertyProxyReal->String->Void = null) 
	{
		if (onChangeCallback != null)
		{
			this._onChangeCallbacks[this._onChangeCallbacks.length] = onChangeCallback;
		}
	}
	
	/**
	 * @private
	 */
	private var _subProxyName:String;
	
	/**
	 * @private
	 */
	private var _onChangeCallbacks:Array<PropertyProxyReal->String->Void> = new Array<PropertyProxyReal->String->Void>();
	
	/**
	 * @private
	 */
	private var _names:Array<String> = new Array<String>();
	
	/**
	 * @private
	 */
	private var _storage:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	/**
	 * @private
	 */
	public function hasProperty(name:String):Bool
	{
		return this._storage.exists(name);
	}
	
	/**
	 * 
	 */
	public function iterator():ArrayIterator<String>
	{
		return this._names.iterator();
	}
	
	public function namesIterator():ArrayIterator<String>
	{
		return this._names.iterator();
	}
	
	/**
	 * @private
	 */
	public function getProperty(name:String):Dynamic
	{
		if (!this._storage.exists(name))
		{
			var subProxy:PropertyProxy = new PropertyProxy(subProxy_onChange);
			subProxy._subProxyName = name;
			this._storage[name] = subProxy;
			this._names[this._names.length] = name;
			this.fireOnChangeCallback(name);
		}
		return this._storage[name];
	}
	
	/**
	 * @private
	 */
	public function setProperty(name:String, value:Dynamic):Void
	{
		this._storage[name] = value;
		if (this._names.indexOf(name) == -1)
		{
			this._names[this._names.length] = name;
		}
		this.fireOnChangeCallback(name);
	}
	
	/**
	 * @private
	 */
	public function deleteProperty(name:String):Bool
	{
		var index:Int = this._names.indexOf(name);
		if (index != -1)
		{
			this._names.splice(index, 1);
		}
		var result:Bool = this._storage.remove(name);
		if (result)
		{
			this.fireOnChangeCallback(name);
		}
		return result;
	}
	
	/**
	 * @private
	 */
	public function nextNameIndex(index:Int):Int
	{
		if (index < this._names.length)
		{
			return index + 1;
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	public function nextName(index:Int):String
	{
		return this._names[index -1];
	}
	
	/**
	 * @private
	 */
	public function nextValue(index:Int):Dynamic
	{
		var name:String = this._names[index - 1];
		return this._storage[name];
	}
	
	/**
	 * Adds a callback to react to property changes.
	 */
	public function addOnChangeCallback(callback:PropertyProxyReal->String->Void):Void
	{
		this._onChangeCallbacks[this._onChangeCallbacks.length] = callback;
	}
	
	/**
	 * Removes a callback.
	 */
	public function removeOnChangeCallback(callback:PropertyProxyReal->String->Void):Void
	{
		var index:Int = this._onChangeCallbacks.indexOf(callback);
		if (index == -1)
		{
			return;
		}
		if (index == 0)
		{
			this._onChangeCallbacks.shift();
			return;
		}
		if (index == this._onChangeCallbacks.length -1)
		{
			this._onChangeCallbacks.pop();
			return;
		}
		this._onChangeCallbacks.splice(index, 1);
	}
	
	/**
	 * @private
	 */
	public function toString():String
	{
		var result:String = "[object PropertyProxy";
		for (name in this._names)
		{
			result += " " + name;
		}
		return result + "]";
	}
	
	/**
	 * @private
	 */
	private function fireOnChangeCallback(forName:String):Void
	{
		var callbackCount:Int = this._onChangeCallbacks.length;
		for (i in 0...callbackCount)
		{
			this._onChangeCallbacks[i](this, forName);
		}
	}
	
	/**
	 * @private
	 */
	private function subProxy_onChange(proxy:PropertyProxyReal, name:String):Void
	{
		this.fireOnChangeCallback(proxy._subProxyName);
	}
	
	/**
	 * 
	 */
	public function dispose():Void
	{
		this._storage.clear();
	}
	
}