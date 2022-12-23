/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.texture;
import openfl.geom.Point;
import starling.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class TextureUtils 
{

	/**
	 * Calculates the dimensions of the texture needed to display an item with
	 * the specified width and height, accepting a maximum where the snapshot
	 * must be split into multiple textures. If Starling's profile is
	 * <code>Context3DProfile.BASELINE_CONSTRAINED</code>, will calculate
	 * power-of-two dimensions for the texture.
	 *
	 * @productversion Feathers 3.1.0
	 */
	public function calculateSnapshotTextureDimensions(width:Float, height:Float, maximum:Float, supportsRectangleTexture:Bool, result:Point = null):Point
	{
		var snapshotWidth:Float = width;
		var snapshotHeight:Float = height;
		if (!supportsRectangleTexture)
		{
			if (snapshotWidth > maximum)
			{
				snapshotWidth = Std.int(snapshotWidth / maximum) * maximum + MathUtil.getNextPowerOfTwo(snapshotWidth % maximum);
			}
			else
			{
				snapshotWidth = MathUtil.getNextPowerOfTwo(snapshotWidth);
			}
		}
		else if (snapshotWidth > maximum)
		{
			snapshotWidth = Std.int(snapshotWidth / maximum) * maximum + (snapshotWidth % maximum);
		}
		if (!supportsRectangleTexture)
		{
			if (snapshotHeight > maximum)
			{
				snapshotHeight = Std.int(snapshotHeight / maximum) * maximum + MathUtil.getNextPowerOfTwo(snapshotHeight % maximum);
			}
			else
			{
				snapshotHeight = MathUtil.getNextPowerOfTwo(snapshotHeight);
			}
		}
		else if (snapshotHeight > maximum)
		{
			snapshotHeight = Std.int(snapshotHeight / maximum) * maximum + (snapshotHeight % maximum);
		}
		if (result == null)
		{
			result = new Point(snapshotWidth, snapshotHeight);
		}
		else
		{
			result.setTo(snapshotWidth, snapshotHeight);
		}
		return result;
	}
	
}