/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.display;

import feathers.utils.MathUtils;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.display.DisplayObject;
import starling.rendering.Painter;
import starling.utils.MatrixUtil;
import starling.utils.Pool;

/**
 * Passes rendering to another display object, but provides its own separate
 * transformation.
 *
 * <p>Touching the delegate does not pass touches to the target. The
 * delegate is a separate display object. However, interacting with the
 * target may affect the rendering of the delegate.</p>
 *
 * @productversion Feathers 2.2.0
 */
class RenderDelegate extends DisplayObject 
{
	/**
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();
	
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject) 
	{
		super();
		this.target = target;
	}
	
	/**
	 * The displaying object being rendered.
	 */
	public var target(get, set):DisplayObject;
	private var _target:DisplayObject;
	private function get_target():DisplayObject { return this._target; }
	private function set_target(value:DisplayObject):DisplayObject
	{
		if(this._target == value)
		{
			return value;
		}
		this._target = value;
		this.setRequiresRedraw();
		return this._target;
	}
	
	/**
	 * @private
	 */
	override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
	{
		resultRect = this._target.getBounds(this._target, resultRect);
		var matrix:Matrix = Pool.getMatrix();
		this.getTransformationMatrix(targetSpace, matrix);
		var minX:Float = MathUtils.FLOAT_MAX;
		var maxX:Float = MathUtils.FLOAT_MIN;
		var minY:Float = MathUtils.FLOAT_MAX;
		var maxY:Float = MathUtils.FLOAT_MIN;
		for (i in 0...4)
		{
			MatrixUtil.transformCoords(matrix, i % 2 == 0 ? 0 : resultRect.width, i < 2 ? 0 : resultRect.height, HELPER_POINT);
			if (HELPER_POINT.x < minX)
			{
				minX = HELPER_POINT.x;
			}
			if (HELPER_POINT.x > maxX)
			{
				maxX = HELPER_POINT.x;
			}
			if (HELPER_POINT.y < minY)
			{
				minY = HELPER_POINT.y;
			}
			if (HELPER_POINT.y > maxY)
			{
				maxY = HELPER_POINT.y;
			}
		}
		Pool.putMatrix(matrix);
		resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
		return resultRect;
	}
	
	/**
	 * @private
	 */
	override public function render(painter:Painter):Void
	{
		var oldCacheEnabled:Bool = painter.cacheEnabled;
		painter.cacheEnabled = false;
		this._target.render(painter);
		painter.cacheEnabled = oldCacheEnabled;
		painter.excludeFromCache(this);
	}
	
}