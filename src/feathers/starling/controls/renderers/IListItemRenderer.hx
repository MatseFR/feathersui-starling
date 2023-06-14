/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import feathers.starling.controls.List;
import feathers.starling.core.IToggle;

/**
 * Interface to implement a renderer for a list item.
 *
 * @productversion Feathers 1.0.0
 */
interface IListItemRenderer extends IToggle
{
	/**
	 * An item from the list's data provider. The data may change if this
	 * item renderer is reused for a new item because it's no longer needed
	 * for the original item.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var data(get, set):Dynamic;
	
	/**
	 * The index (numeric position, starting from zero) of the item within
	 * the list's data provider. Like the <code>data</code> property, this
	 * value may change if this item renderer is reused by the list for a
	 * different item.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var index(get, set):Int;
	
	/**
	 * The list that contains this item renderer.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var owner(get, set):List;
	
	/**
	 * The ID of the factory used to create this item renderer.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var factoryID(get, set):String;
	
}