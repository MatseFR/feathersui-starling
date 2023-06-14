/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.dragDrop;

/**
 * Stores data associated with a drag and drop operation.
 *
 * @see feathers.dragDrop.DragDropManager
 *
 * @productversion Feathers 1.0.0
 */
class DragData 
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		
	}
	
	private var _data:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	/**
	 * Determines if the specified data format is available.
	 */
	public function hasDataForFormat(format:String):Bool
	{
		return this._data.exists(format);
	}
	
	/**
	 * Returns data for the specified format.
	 */
	public function getDataForFormat(format:String):Dynamic
	{
		if (this._data.exists(format))
		{
			return this._data[format];
		}
		return null;
	}
	
	/**
	 * Saves data for the specified format.
	 */
	public function setDataForFormat(format:String, data:Dynamic):Void
	{
		this._data[format] = data;
	}
	
	/**
	 * Removes all data for the specified format.
	 */
	public function clearDataForFormat(format:String):Dynamic
	{
		var data:Dynamic = null;
		if (this._data.exists(format))
		{
			data = this._data[format];
			this._data.remove(format);
		}
		return data;
	}
	
}