/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.renderers;
import feathers.controls.GroupedList;
import feathers.core.IFeathersControl;

/**
 * Interface to implement a renderer for a grouped list footer.
 *
 * @see feathers.controls.GroupedList
 *
 * @productversion Feathers 2.3.0
 */
interface IGroupedListFooterRenderer extends IFeathersControl
{
	/**
	 * Data for a footer renderer from the grouped list's data provider.
	 * A footer renderer should be designed with the assumption that its
	 * <code>data</code> will change as the list scrolls.
	 *
	 * <p>This property is set automatically by the list, and it should not
	 * be set manually.</p>
	 */
	public var data(get, set):Dynamic;
	
	/**
	 * The index of the group within the data provider of the grouped list.
	 *
	 * <p>This property is set automatically by the list, and it should not
	 * be set manually.</p>
	 */
	public var groupIndex(get, set):Int;
	
	/**
	 * The index of this display object within the layout.
	 *
	 * <p>This property is set automatically by the list, and it should not
	 * be set manually.</p>
	 */
	public var layoutIndex(get, set):Int;
	
	/**
	 * The grouped list that contains this footer renderer.
	 *
	 * <p>This property is set automatically by the list, and it should not
	 * be set manually.</p>
	 */
	public var owner(get, set):GroupedList;
	
	/**
	 * The ID of the factory used to create this footer renderer.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var factoryID(get, set):String;
}