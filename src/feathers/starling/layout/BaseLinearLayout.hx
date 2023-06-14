/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.layout;
import feathers.starling.layout.BaseVariableVirtualLayout;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * Abstract base class for <code>HorizontalLayout</code> and <code>VerticalLayout</code>.
 *
 * @productversion Feathers 3.3.0
 *
 * @see feathers.layout.HorizontalLayout
 * @see feathers.layout.VerticalLayout
 */
abstract class BaseLinearLayout extends BaseVariableVirtualLayout 
{
	/**
	 * 
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * @private
	 */
	private var _discoveredItemsCache:Array<DisplayObject> = new Array<DisplayObject>();
	
	/**
	 * The space, in pixels, between items.
	 *
	 * @default 0
	 */
	public var gap(get, set):Float;
	private var _gap:Float = 0;
	private function get_gap():Float { return this._gap; }
	private function set_gap(value:Float):Float
	{
		if (this._gap == value)
		{
			return value;
		}
		this._gap = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._gap;
	}
	
	/**
	 * The space, in pixels, between the first and second items. If the
	 * value of <code>firstGap</code> is <code>NaN</code>, the value of the
	 * <code>gap</code> property will be used instead.
	 *
	 * @default NaN
	 */
	public var firstGap(get, set):Float;
	private var _firstGap:Float = Math.NaN;
	private function get_firstGap():Float { return this._firstGap; }
	private function set_firstGap(value:Float):Float
	{
		if (this._firstGap == value)
		{
			return value;
		}
		this._firstGap = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._firstGap;
	}
	
	/**
	 * The space, in pixels, between the last and second to last items. If
	 * the value of <code>lastGap</code> is <code>NaN</code>, the value of
	 * the <code>gap</code> property will be used instead.
	 *
	 * @default NaN
	 */
	public var lastGap(get, set):Float;
	private var _lastGap:Float = Math.NaN;
	private function get_lastGap():Float { return this._lastGap; }
	private function set_lastGap(value:Float):Float
	{
		if (this._lastGap == value)
		{
			return value;
		}
		this._lastGap = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._lastGap;
	}
	
	/**
	 * Quickly sets all padding properties to the same value. The
	 * <code>padding</code> getter always returns the value of
	 * <code>paddingTop</code>, but the other padding values may be
	 * different.
	 *
	 * @default 0
	 *
	 * @see #paddingTop
	 * @see #paddingRight
	 * @see #paddingBottom
	 * @see #paddingLeft
	 */
	public var padding(get, set):Float;
	private function get_padding():Float { return this._paddingTop; }
	private function set_padding(value:Float):Float
	{
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		return this.paddingLeft = value;
	}
	
	/**
	 * The space, in pixels, that appears on top.
	 *
	 * @default 0
	 */
	public var paddingTop(get, set):Float;
	private var _paddingTop:Float = 0;
	private function get_paddingTop():Float { return this._paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		if (this._paddingTop == value)
		{
			return value;
		}
		this._paddingTop = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._paddingTop;
	}
	
	/**
	 * The minimum space, in pixels, to the right of the items.
	 *
	 * @default 0
	 */
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight():Float { return this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if (this._paddingRight == value)
		{
			return value;
		}
		this._paddingRight = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._paddingRight;
	}
	
	/**
	 * The space, in pixels, that appears on the bottom.
	 *
	 * @default 0
	 */
	public var paddingBottom(get, set):Float;
	private var _paddingBottom:Float = 0;
	private function get_paddingBottom():Float { return this._paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		if (this._paddingBottom == value)
		{
			return value;
		}
		this._paddingBottom = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._paddingBottom;
	}
	
	/**
	 * The minimum space, in pixels, to the left of the items.
	 *
	 * @default 0
	 */
	public var paddingLeft(get, set):Float;
	private var _paddingLeft:Float = 0;
	private function get_paddingLeft():Float { return this._paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		if (this._paddingLeft == value)
		{
			return value;
		}
		this._paddingLeft = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._paddingLeft;
	}
	
	/**
	 * The alignment of the items vertically, on the x-axis.
	 *
	 * <p><strong>Note:</strong> The <code>VerticalAlign.JUSTIFY</code>
	 * constant is not supported by <code>VerticalLayout</code>. It may be
	 * used with <code>HorizontalLayout</code> only.</p>
	 *
	 * @default feathers.layout.VerticalAlign.TOP
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see feathers.layout.VerticalAlign#JUSTIFY
	 */
	public var verticalAlign(get, set):String;
	private var _verticalAlign:String = VerticalAlign.TOP;
	private function get_verticalAlign():String { return this._verticalAlign; }
	private function set_verticalAlign(value:String):String
	{
		if (this._verticalAlign == value)
		{
			return value;
		}
		this._verticalAlign = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._verticalAlign;
	}
	
	/**
	 * The alignment of the items horizontally, on the x-axis.
	 *
	 * <p><strong>Note:</strong> The <code>HorizontalAlign.JUSTIFY</code>
	 * constant is not supported by <code>HorizontalLayout</code>. It may be
	 * used with <code>VerticalLayout</code> only.</p>
	 *
	 * @default feathers.layout.HorizontalAlign.LEFT
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 * @see feathers.layout.HorizontalAlign#JUSTIFY
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.LEFT;
	private function get_horizontalAlign():String { return this._horizontalAlign; }
	private function set_horizontalAlign(value:String):String
	{
		if (this._horizontalAlign == value)
		{
			return value;
		}
		this._horizontalAlign = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._horizontalAlign;
	}
	
	/**
	 * @copy feathers.layout.ITrimmedLayout#beforeVirtualizedItemCount
	 */
	public var beforeVirtualizedItemCount(get, set):Int;
	private var _beforeVirtualizedItemCount:Int = 0;
	private function get_beforeVirtualizedItemCount():Int { return this._beforeVirtualizedItemCount; }
	private function set_beforeVirtualizedItemCount(value:Int):Int
	{
		if (this._beforeVirtualizedItemCount == value)
		{
			return value;
		}
		this._beforeVirtualizedItemCount = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._beforeVirtualizedItemCount;
	}
	
	/**
	 * @copy feathers.layout.ITrimmedLayout#afterVirtualizedItemCount
	 */
	public var afterVirtualizedItemCount(get, set):Int;
	private var _afterVirtualizedItemCount:Int = 0;
	private function get_afterVirtualizedItemCount():Int { return this._afterVirtualizedItemCount; }
	private function set_afterVirtualizedItemCount(value:Int):Int
	{
		if (this._afterVirtualizedItemCount == value)
		{
			return value;
		}
		this._afterVirtualizedItemCount = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._afterVirtualizedItemCount;
	}
	
	/**
	 * If set to <code>true</code>, the width and height of the
	 * <code>typicalItem</code> will be reset to <code>typicalItemWidth</code>
	 * and <code>typicalItemHeight</code>, respectively, whenever the
	 * typical item needs to be measured. The measured dimensions of the
	 * typical item are used to fill in the blanks of a virtualized layout
	 * for virtual items that don't have their own display objects to
	 * measure yet.
	 *
	 * @default false
	 *
	 * @see #typicalItemWidth
	 * @see #typicalItemHeight
	 * @see #typicalItem
	 */
	public var resetTypicalItemDimensionsOnMeasure(get, set):Bool;
	private var _resetTypicalItemDimensionsOnMeasure:Bool = false;
	private function get_resetTypicalItemDimensionsOnMeasure():Bool { return this._resetTypicalItemDimensionsOnMeasure; }
	private function set_resetTypicalItemDimensionsOnMeasure(value:Bool):Bool
	{
		if (this._resetTypicalItemDimensionsOnMeasure == value)
		{
			return value;
		}
		this._resetTypicalItemDimensionsOnMeasure = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._resetTypicalItemDimensionsOnMeasure;
	}
	
	/**
	 * Used to reset the width, in pixels, of the <code>typicalItem</code>
	 * for measurement. The measured dimensions of the typical item are used
	 * to fill in the blanks of a virtualized layout for virtual items that
	 * don't have their own display objects to measure yet.
	 *
	 * <p>This value is only used when <code>resetTypicalItemDimensionsOnMeasure</code>
	 * is set to <code>true</code>. If <code>resetTypicalItemDimensionsOnMeasure</code>
	 * is set to <code>false</code>, this value will be ignored and the
	 * <code>typicalItem</code> dimensions will not be reset before
	 * measurement.</p>
	 *
	 * <p>If <code>typicalItemWidth</code> is set to <code>NaN</code>, the
	 * typical item will auto-size itself to its preferred width. If you
	 * pass a valid <code>Number</code> value, the typical item's width will
	 * be set to a fixed size. May be used in combination with
	 * <code>typicalItemHeight</code>.</p>
	 *
	 * @default NaN
	 *
	 * @see #resetTypicalItemDimensionsOnMeasure
	 * @see #typicalItemHeight
	 * @see #typicalItem
	 */
	public var typicalItemWidth(get, set):Float;
	private var _typicalItemWidth:Float = Math.NaN;
	private function get_typicalItemWidth():Float { return this._typicalItemWidth; }
	private function set_typicalItemWidth(value:Float):Float
	{
		if (this._typicalItemWidth == value)
		{
			return value;
		}
		this._typicalItemWidth = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._typicalItemWidth;
	}
	
	/**
	 * Used to reset the height, in pixels, of the <code>typicalItem</code>
	 * for measurement. The measured dimensions of the typical item are used
	 * to fill in the blanks of a virtualized layout for virtual items that
	 * don't have their own display objects to measure yet.
	 *
	 * <p>This value is only used when <code>resetTypicalItemDimensionsOnMeasure</code>
	 * is set to <code>true</code>. If <code>resetTypicalItemDimensionsOnMeasure</code>
	 * is set to <code>false</code>, this value will be ignored and the
	 * <code>typicalItem</code> dimensions will not be reset before
	 * measurement.</p>
	 *
	 * <p>If <code>typicalItemHeight</code> is set to <code>NaN</code>, the
	 * typical item will auto-size itself to its preferred height. If you
	 * pass a valid <code>Number</code> value, the typical item's height will
	 * be set to a fixed size. May be used in combination with
	 * <code>typicalItemWidth</code>.</p>
	 *
	 * @default NaN
	 *
	 * @see #resetTypicalItemDimensionsOnMeasure
	 * @see #typicalItemWidth
	 * @see #typicalItem
	 */
	public var typicalItemHeight(get, set):Float;
	private var _typicalItemHeight:Float = Math.NaN;
	private function get_typicalItemHeight():Float { return this._typicalItemHeight; }
	private function set_typicalItemHeight(value:Float):Float
	{
		if (this._typicalItemHeight == value)
		{
			return value;
		}
		this._typicalItemHeight = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._typicalItemHeight;
	}
	
}