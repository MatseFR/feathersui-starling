/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.supportClasses;

import feathers.controls.LayoutGroup;
import feathers.core.FeathersControl;
import feathers.core.IValidating;
import feathers.layout.ILayoutDisplayObject;
import openfl.errors.ArgumentError;
import feathers.controls.supportClasses.IViewPort;
import starling.display.DisplayObject;

/**
 * @private
 * Used internally by ScrollContainer. Not meant to be used on its own.
 *
 * @productversion Feathers 1.0.0
 */
class LayoutViewPort extends LayoutGroup implements IViewPort
{
	public function new() 
	{
		super();
	}
	
	private var _actualMinVisibleWidth:Float = 0;
	
	private var _explicitMinVisibleWidth:Float;
	
	public var minVisibleWidth(get, set):Float;
	private function get_minVisibleWidth():Float
	{
		if (this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return this._actualMinVisibleWidth;
		}
		return this._explicitMinVisibleWidth;
	}
	
	private function set_minVisibleWidth(value:Float):Float
	{
		if (this._explicitMinVisibleWidth == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return value;
		}
		var oldValue:Float = this._explicitMinVisibleWidth;
		this._explicitMinVisibleWidth = value;
		if (valueIsNaN)
		{
			this._actualMinVisibleWidth = 0;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleWidth = value;
			if (this._explicitMinVisibleWidth != this._explicitWidth && //isNaN
				(this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue))
			{
				//only invalidate if this change might affect the visibleWidth
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
		return value;
	}
	
	
	public var maxVisibleWidth(get, set):Float;
	private var _maxVisibleWidth:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleWidth():Float { return this._maxVisibleWidth; }
	private function set_maxVisibleWidth(value:Float):Float
	{
		if (this._maxVisibleWidth == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleWidth cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleWidth;
		this._maxVisibleWidth = value;
		if (this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
			(this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue))
		{
			//only invalidate if this change might affect the visibleWidth
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._maxVisibleWidth;
	}
	
	private var _actualVisibleWidth:Float = 0;
	
	private var _explicitVisibleWidth:Float;
	
	public var visibleWidth(get, set):Float;
	private function get_visibleWidth():Float
	{
		if (this._explicitVisibleWidth != this._explicitVisibleWidth) //isNaN
		{
			return this._actualVisibleWidth;
		}
		return this._explicitVisibleWidth;
	}
	
	private function set_visibleWidth(value:Float):Float
	{
		if (this._explicitVisibleWidth == value ||
			(value != value && this._explicitVisibleWidth != this._explicitVisibleWidth)) //isNaN
		{
			return value;
		}
		this._explicitVisibleWidth = value;
		if (this._actualVisibleWidth != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._explicitVisibleWidth;
	}
	
	private var _actualMinVisibleHeight:Float = 0;
	
	private var _explicitMinVisibleHeight:Float;
	
	public var minVisibleHeight(get, set):Float;
	private function get_minVisibleHeight():Float
	{
		if (this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) // isNaN
		{
			return this._actualMinVisibleHeight;
		}
		return this._explicitMinVisibleHeight;
	}
	
	private function set_minVisibleHeight(value:Float):Float
	{
		if (this._explicitMinVisibleHeight == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) //isNaN
		{
			return value;
		}
		var oldValue:Float = this._explicitMinVisibleHeight;
		this._explicitMinVisibleHeight = value;
		if (valueIsNaN)
		{
			this._actualMinVisibleHeight = 0;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight != this._explicitVisibleHeight && //isNaN
				(this._actualVisibleWidth < value || this._actualVisibleHeight == oldValue))
			{
				//only invalidate if this change might affect the visibleHeight
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
		return this._actualMinVisibleHeight;
	}
	
	
	public var maxVisibleHeight(get, set):Float;
	private var _maxVisibleHeight:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleHeight():Float { return this._maxVisibleHeight; }
	private function set_maxVisibleHeight(value:Float):Float
	{
		if (this._maxVisibleHeight == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleHeight cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleHeight;
		this._maxVisibleHeight = value;
		if (this._explicitVisibleHeight != this._explicitVisibleHeight && //isNaN
			(this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue))
		{
			//only invalidate if this change might affect the visibleHeight
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._maxVisibleHeight;
	}
	
	private var _actualVisibleHeight:Float = 0;
	
	private var _explicitVisibleHeight:Float;
	
	public var visibleHeight(get, set):Float;
	private function get_visibleHeight():Float
	{
		if (this._explicitVisibleHeight != this._explicitVisibleHeight) //isNaN
		{
			return this._actualVisibleHeight;
		}
		return this._explicitVisibleHeight;
	}
	
	private function set_visibleHeight(value:Float):Float
	{
		if (this._explicitVisibleHeight == value ||
			(value != value && this._explicitVisibleHeight != this._explicitVisibleHeight)) //isNaN
		{
			return value;
		}
		this._explicitVisibleHeight = value;
		if (this._actualVisibleHeight != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._explicitVisibleHeight;
	}
	
	public var contentX(get, never):Float;
	private var _contentX:Float = 0;
	private function get_contentX():Float { return this._contentX; }
	
	public var contentY(get, never):Float;
	private var _contentY:Float = 0;
	private function get_contentY():Float { return this._contentY; }
	
	public var horizontalScrollStep(get, never):Float;
	private function get_horizontalScrollStep():Float
	{
		if (this.actualWidth < this.actualHeight)
		{
			return this.actualWidth / 10;
		}
		return this.actualHeight / 10;
	}
	
	public var verticalScrollStep(get, never):Float;
	private function get_verticalScrollStep():Float
	{
		if (this.actualWidth < this.actualHeight)
		{
			return this.actualWidth / 10;
		}
		return this.actualHeight / 10;
	}
	
	public var horizontalScrollPosition(get, set):Float;
	private var _horizontalScrollPosition:Float = 0;
	private function get_horizontalScrollPosition():Float { return this._horizontalScrollPosition; }
	private function set_horizontalScrollPosition(value:Float):Float
	{
		if (this._horizontalScrollPosition == value)
		{
			return value;
		}
		this._horizontalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		return this._horizontalScrollPosition;
	}
	
	public var verticalScrollPosition(get, set):Float;
	private var _verticalScrollPosition:Float = 0;
	private function get_verticalScrollPosition():Float { return this._verticalScrollPosition; }
	private function set_verticalScrollPosition(value:Float):Float
	{
		if (this._verticalScrollPosition == value)
		{
			return value;
		}
		this._verticalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		return this._verticalScrollPosition;
	}
	
	public var requiresMeasurementOnScroll(get, never):Bool;
	private function get_requiresMeasurementOnScroll():Bool
	{
		return this._layout != null && this._layout.requiresLayoutOnScroll &&
		(this._explicitVisibleWidth != this._explicitVisibleWidth || //isNaN
		this._explicitVisibleHeight != this._explicitVisibleHeight); //isNaN
	}
	
	override public function dispose():Void 
	{
		this.layout = null;
		super.dispose();
	}
	
	override function refreshViewPortBounds():Void 
	{
		var needsWidth:Bool = this._explicitVisibleWidth != this._explicitVisibleWidth; //isNaN
		var needsHeight:Bool = this._explicitVisibleHeight != this._explicitVisibleHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinVisibleWidth != this._explicitMinVisibleWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinVisibleHeight != this._explicitMinVisibleHeight; //isNaN
		
		this.viewPortBounds.x = 0;
		this.viewPortBounds.y = 0;
		this.viewPortBounds.scrollX = this._horizontalScrollPosition;
		this.viewPortBounds.scrollY = this._verticalScrollPosition;
		if (this.autoSizeMode == AutoSizeMode.STAGE && needsWidth)
		{
			this.viewPortBounds.explicitWidth = this.stage.stageWidth;
		}
		else
		{
			//layouts can handle NaN for explicit dimensions
			this.viewPortBounds.explicitWidth = this._explicitVisibleWidth;
		}
		if (this._autoSizeMode == AutoSizeMode.STAGE && needsHeight)
		{
			this.viewPortBounds.explicitHeight = this.stage.stageHeight;
		}
		else
		{
			//layouts can handle NaN for explicit dimensions
			this.viewPortBounds.explicitHeight = this._explicitVisibleHeight;
		}
		if (needsMinWidth)
		{
			//layouts don't expect NaN for minimum dimensions
			this.viewPortBounds.minWidth = 0;
		}
		else
		{
			this.viewPortBounds.minWidth = this._explicitMinVisibleWidth;
		}
		if (needsMinHeight)
		{
			//layouts don't expect NaN for minimum dimensions
			this.viewPortBounds.minHeight = 0;
		}
		else
		{
			this.viewPortBounds.minHeight = this._explicitMinVisibleHeight;
		}
		this.viewPortBounds.maxWidth = this._maxVisibleWidth;
		this.viewPortBounds.maxHeight = this._maxVisibleHeight;
	}
	
	override function handleLayoutResult():Void 
	{
		var contentWidth:Float = this._layoutResult.contentWidth;
		var contentHeight:Float = this._layoutResult.contentHeight;
		this.saveMeasurements(contentWidth, contentHeight,
			contentWidth, contentHeight);
		this._contentX = this._layoutResult.contentX;
		this._contentY = this._layoutResult.contentY;
		var viewPortWidth:Float = this._layoutResult.viewPortWidth;
		var viewPortHeight:Float = this._layoutResult.viewPortHeight;
		this._actualVisibleWidth = viewPortWidth;
		this._actualVisibleHeight = viewPortHeight;
		this._actualMinVisibleWidth = viewPortWidth;
		this._actualMinVisibleHeight = viewPortHeight;
	}
	
	override function handleManualLayout():Void 
	{
		var minX:Float = 0;
		var minY:Float = 0;
		var explicitViewPortWidth:Float = this.viewPortBounds.explicitWidth;
		var maxX:Float = explicitViewPortWidth;
		//for some reason, if we don't call a function right here,
		//compiling with the flex 4.6 SDK will throw a VerifyError
		//for a stack overflow.
		//we could change the != check back to isNaN() instead, but
		//isNaN() can allocate an object, so we should call a different
		//function without allocation.
		this.doNothing();
		if (maxX != maxX) //isNaN
		{
			maxX = 0;
		}
		var explicitViewPortHeight:Float = this.viewPortBounds.explicitHeight;
		var maxY:Float = explicitViewPortHeight;
		//see explanation above the previous call to this function.
		this.doNothing();
		if (maxY != maxY) //isNaN
		{
			maxY = 0;
		}
		this._ignoreChildChanges = true;
		var itemCount:Int = this.items.length;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = this.items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
			}
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
			var itemX:Float = item.x - item.pivotX * item.scaleX;
			var itemY:Float = item.y - item.pivotY * item.scaleY;
			var itemMaxX:Float = itemX + item.width;
			var itemMaxY:Float = itemY + item.height;
			if (itemX == itemX && //!isNaN
				itemX < minX)
			{
				minX = itemX;
			}
			if (itemY == itemY && //!isNan
				itemY < minY)
			{
				minY = itemY;
			}
			if (itemMaxX == itemMaxX && //!isNaN
				itemMaxX > maxX)
			{
				maxX = itemMaxX;
			}
			if (itemMaxY == itemMaxY && //isNaN
				itemMaxY > maxY)
			{
				maxY = itemMaxY;
			}
		}
		var minWidth:Float = this.viewPortBounds.minWidth;
		var maxWidth:Float = this.viewPortBounds.maxWidth;
		var minHeight:Float = this.viewPortBounds.minHeight;
		var maxHeight:Float = this.viewPortBounds.maxHeight;
		var calculatedWidth:Float = maxX - minX;
		if (calculatedWidth < minWidth)
		{
			calculatedWidth = minWidth;
		}
		else if (calculatedWidth > maxWidth)
		{
			calculatedWidth = maxWidth;
		}
		var calculatedHeight:Float = maxY - minY;
		if (calculatedHeight < minHeight)
		{
			calculatedHeight = minHeight;
		}
		else if (calculatedHeight > maxHeight)
		{
			calculatedHeight = maxHeight;
		}
		this._ignoreChildChanges = false;
		if (explicitViewPortWidth != explicitViewPortWidth) //isNaN
		{
			this._actualVisibleWidth = calculatedWidth;
		}
		else
		{
			this._actualVisibleWidth = explicitViewPortWidth;
		}
		if (explicitViewPortHeight != explicitViewPortHeight) //isNaN
		{
			this._actualVisibleHeight = calculatedHeight;
		}
		else
		{
			this._actualVisibleHeight = explicitViewPortHeight;
		}
		this._layoutResult.contentX = minX;
		this._layoutResult.contentY = minY;
		this._layoutResult.contentWidth = calculatedWidth;
		this._layoutResult.contentHeight = calculatedHeight;
		this._layoutResult.viewPortWidth = calculatedWidth;
		this._layoutResult.viewPortHeight = calculatedHeight;
	}
	
	/**
	 * @private
	 * This function is here to work around a bug in the Flex 4.6 SDK
	 * compiler. For explanation, see the places where it gets called.
	 */
	private function doNothing():Void {}
	
}