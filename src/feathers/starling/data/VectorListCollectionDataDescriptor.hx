/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.data;
import openfl.Vector;
import openfl.errors.IllegalOperationError;

/**
 * An <code>IListCollectionDataDescriptor</code> implementation for Vectors.
 *
 * @see ListCollection
 * @see IListCollectionDataDescriptor
 *
 * @productversion Feathers 1.0.0
 */
class VectorListCollectionDataDescriptor implements IListCollectionDataDescriptor
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
		return cast(data, Vector<Dynamic>).length;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemAt(data:Dynamic, index:Int):Dynamic
	{
		this.checkForCorrectDataType(data);
		return cast(data, Vector<Dynamic>)[index];
	}
	
	/**
	 * @inheritDoc
	 */
	public function setItemAt(data:Dynamic, item:Dynamic, index:Int):Void
	{
		this.checkForCorrectDataType(data);
		cast(data, Vector<Dynamic>)[index] = item;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addItemAt(data:Dynamic, item:Dynamic, index:Int):Void
	{
		this.checkForCorrectDataType(data);
		cast(data, Vector<Dynamic>).insertAt(index, item);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeItemAt(data:Dynamic, index:Int):Dynamic
	{
		this.checkForCorrectDataType(data);
		return cast(data, Vector<Dynamic>).removeAt(index);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeAll(data:Dynamic):Void
	{
		this.checkForCorrectDataType(data);
		cast(data, Vector<Dynamic>).length = 0;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemIndex(data:Dynamic, item:Dynamic):Int
	{
		this.checkForCorrectDataType(data);
		return cast(data, Vector<Dynamic>).indexOf(item);
	}
	
	/**
	 * @private
	 */
	private function checkForCorrectDataType(data:Dynamic):Void
	{
		if (!Std.isOfType(data, Vector))
		{
			throw new IllegalOperationError("Expected Vector. Received " + Type.getClassName(Type.getClass(data)) + " instead.");
		}
	}
	
}