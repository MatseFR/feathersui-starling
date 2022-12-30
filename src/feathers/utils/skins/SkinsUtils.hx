/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.skins;
import feathers.core.IMeasureDisplayObject;
import starling.display.DisplayObject;

/**
 * ...
 * @author Matse
 */
class SkinsUtils 
{

	/**
	 * Updates the dimensions of a component's for measurement if the child
	 * should fill the entire width and height of its parent.
	 *
	 * @productversion Feathers 3.0.0
	 */
	static public function resetFluidChildDimensionsForMeasurement(child:DisplayObject,
		parentExplicitWidth:Float, parentExplicitHeight:Float,
		parentExplicitMinWidth:Float, parentExplicitMinHeight:Float,
		parentExplicitMaxWidth:Float, parentExplicitMaxHeight:Float,
		childExplicitWidth:Float, childExplicitHeight:Float,
		childExplicitMinWidth:Float, childExplicitMinHeight:Float,
		childExplicitMaxWidth:Float, childExplicitMaxHeight:Float):Void
	{
		if (child == null)
		{
			return;
		}
		var needsWidth:Bool = parentExplicitWidth != parentExplicitWidth; //isNaN
		var needsHeight:Bool = parentExplicitHeight != parentExplicitHeight; //isNaN
		if (needsWidth)
		{
			child.width = childExplicitWidth;
		}
		else
		{
			child.width = parentExplicitWidth;
		}
		if (needsHeight)
		{
			child.height = childExplicitHeight;
		}
		else
		{
			child.height = parentExplicitHeight;
		}
		var measureChild:IMeasureDisplayObject = child as IMeasureDisplayObject;
		if (measureChild != null)
		{
			var childMinWidth:Float = parentExplicitMinWidth;
			//for some reason, if we do the != check on a local variable right
			//here, compiling with the flex 4.6 SDK will throw a VerifyError
			//for a stack overflow.
			//we could change the != check back to isNaN() instead, but
			//isNaN() can allocate an object that needs garbage collection.
			//compilerWorkaround = childMinWidth;
			if (childMinWidth != childMinWidth || //isNaN
				childExplicitMinWidth > childMinWidth)
			{
				childMinWidth = childExplicitMinWidth;
			}
			measureChild.minWidth = childMinWidth;
			var childMinHeight:Float = parentExplicitMinHeight;
			//compilerWorkaround = childMinHeight;
			if (childMinHeight != childMinHeight || //isNaN
				childExplicitMinHeight > childMinHeight)
			{
				childMinHeight = childExplicitMinHeight;
			}
			measureChild.minHeight = childMinHeight;
			
			var childMaxWidth:Float = parentExplicitMaxWidth;
			//compilerWorkaround = childMaxWidth;
			if (childMaxWidth != childMaxWidth || //isNaN
				childExplicitMaxWidth < childMaxWidth)
			{
				childMaxWidth = childExplicitMaxWidth;
			}
			measureChild.maxWidth = childMaxWidth;
			var childMaxHeight:Float = parentExplicitMaxHeight;
			//compilerWorkaround = childMaxHeight;
			if (childMaxHeight != childMaxHeight || //isNaN
				childExplicitMaxHeight < childMaxHeight)
			{
				childMaxHeight = childExplicitMaxHeight;
			}
			measureChild.maxHeight = childMaxHeight;
		}
	}
	
}