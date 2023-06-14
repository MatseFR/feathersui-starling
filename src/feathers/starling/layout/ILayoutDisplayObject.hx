/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.layout;
import feathers.starling.core.IFeathersDisplayObject;

/**
 * A display object that may be associated with extra data for use with
 * advanced layouts.
 *
 * @productversion Feathers 1.1.0
 */
interface ILayoutDisplayObject extends IFeathersDisplayObject
{
	/**
	 * Extra parameters associated with this display object that will be
	 * used by the layout algorithm.
	 */
	public var layoutData(get, set):ILayoutData;
	
	/**
	 * Determines if the ILayout should use this object or ignore it.
	 *
	 * <p>In the following example, the display object is excluded from
	 * the layout:</p>
	 *
	 * <listing version="3.0">
	 * object.includeInLayout = false;</listing>
	 */
	public var includeInLayout(get, set):Bool;
}