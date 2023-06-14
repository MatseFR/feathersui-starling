/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.layout;
import openfl.geom.Rectangle;

/**
 * A layout for the <code>SpinnerList</code> component.
 *
 * @see feathers.controls.SpinnerList
 *
 * @productversion Feathers 2.1.0
 */
interface ISpinnerLayout 
{
	/**
	 * The interval, in pixels, between snapping points.
	 */
	public var snapInterval(get, never):Float;
	
	/**
	 * A rectangle indicating the bounds of the selected item. Used by the
	 * <code>SpinnerList</code> to position its selection overlay skin.
	 */
	public var selectionBounds(get, never):Rectangle;
}