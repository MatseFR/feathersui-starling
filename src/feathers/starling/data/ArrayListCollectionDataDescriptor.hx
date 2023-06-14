/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.data;
import feathers.starling.data.IListCollectionDataDescriptor;
import openfl.errors.IllegalOperationError;

/**
 * An <code>IListCollectionDataDescriptor</code> implementation for Arrays.
 *
 * @see ListCollection
 * @see IListCollectionDataDescriptor
 *
 * @productversion Feathers 1.0.0
 */
class ArrayListCollectionDataDescriptor implements IListCollectionDataDescriptor
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		
	}
	
	/**
	 * @inheritDoc
	 */
	public function getLength(data:Dynamic):Int
	{
		this.checkForCorrectDataType(data);
		return cast(data, Array<Dynamic>).length;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemAt(data:Dynamic, index:Int):Dynamic
	{
		this.checkForCorrectDataType(data);
		return cast(data, Array<Dynamic>)[index];
	}
	
	/**
	 * @inheritDoc
	 */
	public function setItemAt(data:Dynamic, item:Dynamic, index:Int):Void
	{
		this.checkForCorrectDataType(data);
		cast(data, Array<Dynamic>)[index] = item;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addItemAt(data:Dynamic, item:Dynamic, index:Int):Void
	{
		this.checkForCorrectDataType(data);
		cast(data, Array<Dynamic>).insert(index, item);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeItemAt(data:Dynamic, index:Int):Dynamic
	{
		this.checkForCorrectDataType(data);
		return cast(data, Array<Dynamic>).splice(index, 1)[0];
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeAll(data:Dynamic):Void
	{
		this.checkForCorrectDataType(data);
		cast(data, Array<Dynamic>).resize(0);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemIndex(data:Dynamic, item:Dynamic):Int
	{
		this.checkForCorrectDataType(data);
		return cast(data, Array<Dynamic>).indexOf(item);
	}
	
	/**
	 * @private
	 */
	private function checkForCorrectDataType(data:Dynamic):Void
	{
		if (!Std.isOfType(data, Array))
		{
			throw new IllegalOperationError("Expected Array. Received " + Type.getClassName(Type.getClass(data)) + " instead.");
		}
	}
	
}