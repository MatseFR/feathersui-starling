/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.display;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Stage;

/**
 * ...
 * @author Matse
 */
class DisplayUtils 
{
	/**
	 * Calculates a scale value to maintain aspect ratio and fill the required
	 * bounds (with the possibility of cutting of the edges a bit).
	 *
	 * @productversion Feathers 1.0.0
	 */
	static public inline function calculateScaleRatioToFill(originalWidth:Float, originalHeight:Float, targetWidth:Float, targetHeight:Float):Float
	{
		var widthRatio:Float = targetWidth / originalWidth;
		var heightRatio:Float = targetHeight / originalHeight;
		if (widthRatio > heightRatio)
		{
			return widthRatio;
		}
		return heightRatio;
	}
	
	/**
	 * Calculates a scale value to maintain aspect ratio and fit inside the
	 * required bounds (with the possibility of a bit of empty space on the
	 * edges).
	 *
	 * @productversion Feathers 1.0.0
	 */
	static public inline function calculateScaleRatioToFit(originalWidth:Float, originalHeight:Float, targetWidth:Float, targetHeight:Float):Float
	{
		var widthRatio:Float = targetWidth / originalWidth;
		var heightRatio:Float = targetHeight / originalHeight;
		if (widthRatio < heightRatio)
		{
			return widthRatio;
		}
		return heightRatio;
	}
	
	/**
	 * Calculates how many levels deep the target object is on the display list,
	 * starting from the Starling stage. If the target object is the stage, the
	 * depth will be <code>0</code>. A direct child of the stage will have a
	 * depth of <code>1</code>, and it increases with each new level. If the
	 * object does not have a reference to the stage, the depth will always be
	 * <code>-1</code>, even if the object has a parent.
	 *
	 * @productversion Feathers 1.0.0
	 */
	static public inline function getDisplayObjectDepthFromStage(target:DisplayObject):Int
	{
		if (target.stage == null)
		{
			return -1;
		}
		var count:Int = 0;
		while (target.parent != null)
		{
			target = target.parent;
			count++;
		}
		return count;
	}
	
	/**
	 * Converts from native coordinates to Starling global coordinates.
	 *
	 * @productversion Feathers 3.5.0
	 */
	static public inline function nativeToGlobal(nativePosition:Point, starling:Starling = null, result:Point = null):Point
	{
		if (starling == null)
		{
			starling = Starling.current;
		}
		
		var nativeScaleFactor:Float = 1;
		if (starling.supportHighResolutions)
		{
			nativeScaleFactor = starling.nativeStage.contentsScaleFactor;
		}
		var scaleFactor:Float = starling.contentScaleFactor / nativeScaleFactor;
		
		var viewPort:Rectangle = starling.viewPort;
		var resultX:Float = (nativePosition.x - viewPort.x) / scaleFactor;
		var resultY:Float = (nativePosition.y - viewPort.y) / scaleFactor;
		
		if (result == null)
		{
			result = new Point(resultX, resultY);
		}
		else
		{
			result.setTo(resultX, resultY);
		}
		return result;
	}
	
	/**
	 * Finds the Starling instance that controls a particular
	 * <code>starling.display.Stage</code>.
	 *
	 * @productversion Feathers 2.2.0
	 */
	static public inline function stageToSttarling(stage:Stage):Starling
	{
		for (starling in Starling.all)
		{
			if (starling.stage == stage)
			{
				return starling;
			}
		}
		return null;
	}
	
}