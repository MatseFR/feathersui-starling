/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.layout;
import feathers.starling.layout.IVirtualLayout;
import starling.display.DisplayObject;

/**
 * A virtual layout that supports variable item dimensions.
 *
 * @productversion Feathers 1.0.0
 */
interface IVariableVirtualLayout extends IVirtualLayout
{
	/**
	 * When the layout is virtualized, and this value is true, the items may
	 * have variable dimensions. If false, the items will all share the
	 * same dimensions as the typical item. Performance is better for
	 * layouts where all items have the same dimensions.
	 */
	public var hasVariableItemDimensions(get, set):Bool;
	
	/**
	 * Clears the cached dimensions for all virtualized indices.
	 */
	function resetVariableVirtualCache():Void;
	
	/**
	 * Clears the cached dimensions for one specific virtualized index.
	 */
	function resetVariableVirtualCacheAtIndex(index:Int, item:DisplayObject = null):Void;
	
	/**
	 * Inserts an item in to the cache at the specified index, pushing the
	 * old cached value at that index, and all following values, up one
	 * index.
	 */
	function addToVariableVirtualCacheAtIndex(index:Int, item:DisplayObject = null):Void;
	
	/**
	 * Removes an item in to the cache at the specified index, moving the
	 * values at following indexes down by one.
	 */
	function removeFromVariableVirtualCacheAtIndex(index:Int):Void;
}