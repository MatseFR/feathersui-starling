/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;
import starling.display.DisplayObject;

/**
 * Methods for layouts that support drag and drop.
 */
interface IDragDropLayout 
{
	/**
	 * Returns the index of the item if it were dropped at the specified
	 * location.
	 */
	function getDropIndex(x:Float, y:Float, items:Array<DisplayObject>,
		boundsX:Float, boundsY:Float, width:Float, height:Float):Int;
	
	/**
	 * Positions the drop indicator in the layout. Must be called after
	 * <code>layout()</code>.
	 */
	function positionDropIndicator(dropIndicator:DisplayObject, index:Int,
		x:Float, y:Float, items:Array<DisplayObject>, width:Float, height:Float):Void;
}