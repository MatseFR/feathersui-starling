/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import feathers.starling.controls.GroupedList;
import feathers.starling.core.IToggle;

/**
 * Interface to implement a renderer for a grouped list item.
 *
 * @productversion Feathers 1.0.0
 */
interface IGroupedListItemRenderer extends IToggle
{
	/**
	 * An item from the grouped list's data provider. The data may change if
	 * this item renderer is reused for a new item because it's no longer
	 * needed for the original item.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var data(get, set):Dynamic;
	
	/**
	 * The index of the item's parent group within the data provider of the
	 * grouped list.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var groupIndex(get, set):Int;
	
	/**
	 * The index of the item within its parent group.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var itemIndex(get, set):Int;
	
	/**
	 * The index of the item within the layout.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var layoutIndex(get, set):Int;
	
	/**
	 * The grouped list that contains this item renderer.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var owner(get, set):GroupedList;
	
	/**
	 * The ID of the factory used to create this item renderer.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var factoryID(get, set):String;
}