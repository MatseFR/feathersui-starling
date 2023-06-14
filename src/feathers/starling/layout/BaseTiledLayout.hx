/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.layout;

import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import openfl.errors.RangeError;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Abstract base class for <code>TiledRowsLayout</code> and <code>TiledColumnsLayout</code>.
 *
 * @productversion Feathers 3.3.0
 *
 * @see feathers.layout.TiledRowsLayout
 * @see feathers.layout.TiledColumnsLayout
 */
abstract class BaseTiledLayout extends EventDispatcher 
{
	/**
	 * Constructor.
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
	 * Quickly sets both <code>horizontalGap</code> and <code>verticalGap</code>
	 * to the same value. The <code>gap</code> getter always returns the
	 * value of <code>horizontalGap</code>, but the value of
	 * <code>verticalGap</code> may be different.
	 *
	 * @default 0
	 *
	 * @see #horizontalGap
	 * @see #verticalGap
	 */
	public var gap(get, set):Float;
	private function get_gap():Float { return this._horizontalGap; }
	private function set_gap(value:Float):Float
	{
		this.horizontalGap = value;
		return this.verticalGap = value;
	}
	
	/**
	 * The horizontal space, in pixels, between tiles.
	 *
	 * @default 0
	 */
	public var horizontalGap(get, set):Float;
	private var _horizontalGap:Float = 0;
	private function get_horizontalGap():Float { return this._horizontalGap; }
	private function set_horizontalGap(value:Float):Float
	{
		if (this._horizontalGap == value)
		{
			return value;
		}
		this._horizontalGap = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._horizontalGap;
	}
	
	/**
	 * The vertical space, in pixels, between tiles.
	 *
	 * @default 0
	 */
	public var verticalGap(get, set):Float;
	private var _verticalGap:Float = 0;
	private function get_verticalGap():Float { return this._verticalGap; }
	private function set_verticalGap(value:Float):Float
	{
		if (this._verticalGap == value)
		{
			return value;
		}
		this._verticalGap = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._verticalGap;
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
	 * The space, in pixels, above of items.
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
	 * The space, in pixels, to the right of the items.
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
	 * The space, in pixels, below the items.
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
	 * The space, in pixels, to the left of the items.
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
	 * Requests that the layout uses a specific number of columns in a row,
	 * if possible. Set to <code>0</code> to calculate the maximum of
	 * columns that will fit in the available space.
	 *
	 * <p>If the view port's explicit or maximum width is not large enough
	 * to fit the requested number of columns, it will use fewer. If the
	 * view port doesn't have an explicit width and the maximum width is
	 * equal to <code>Number.POSITIVE_INFINITY</code>, the width will be
	 * calculated automatically to fit the exact number of requested
	 * columns.</p>
	 *
	 * <p>If paging is enabled, this value will be used to calculate the
	 * number of columns in a page. If paging isn't enabled, this value will
	 * be used to calculate a minimum number of columns, even if there
	 * aren't enough items to fill each column.</p>
	 *
	 * @default 0
	 */
	public var requestedColumnCount(get, set):Int;
	private var _requestedColumnCount:Int = 0;
	private function get_requestedColumnCount():Int { return this._requestedColumnCount; }
	private function set_requestedColumnCount(value:Int):Int
	{
		if (value < 0)
		{
			throw new RangeError("requestedColumnCount requires a value >= 0");
		}
		if (this._requestedColumnCount == value)
		{
			return value;
		}
		this._requestedColumnCount = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._requestedColumnCount;
	}
	
	/**
	 * Requests that the layout uses a specific number of rows, if possible.
	 * If the view port's explicit or maximum height is not large enough to
	 * fit the requested number of rows, it will use fewer. Set to <code>0</code>
	 * to calculate the number of rows automatically based on width and
	 * height.
	 *
	 * <p>If paging is enabled, this value will be used to calculate the
	 * number of rows in a page. If paging isn't enabled, this value will
	 * be used to calculate a minimum number of rows, even if there aren't
	 * enough items to fill each row.</p>
	 *
	 * @default 0
	 */
	public var requestedRowCount(get, set):Int;
	private var _requestedRowCount:Int = 0;
	private function get_requestedRowCount():Int { return this._requestedRowCount; }
	private function set_requestedRowCount(value:Int):Int
	{
		if (value < 0)
		{
			throw new RangeError("requestedRowCount requires a value >= 0");
		}
		if (this._requestedRowCount == value)
		{
			return value;
		}
		this._requestedRowCount = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._requestedRowCount;
	}
	
	/**
	 * If the total column height is less than the bounds, the items in the
	 * column can be aligned vertically.
	 *
	 * <p><strong>Note:</strong> VerticalAlign.JUSTIFY is not supported.
	 * The <code>distributeHeights</code> property may be used to fill the
	 * available space when the content is not large enough.</p>
	 *
	 * @default feathers.layout.VerticalAlign.TOP
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see #distributeHeights
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
	 * If the total row width is less than the bounds, the items in the row
	 * can be aligned horizontally.
	 *
	 * <p><strong>Note:</strong> HorizontalAlign.JUSTIFY is not supported.
	 * The <code>distributeWidths</code> property may be used to fill the
	 * available space when the content is not large enough.</p>
	 *
	 * @default feathers.layout.HorizontalAlign.CENTER
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 * @see #distributeWidths
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.CENTER;
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
	 * If an item's height is less than the tile bounds, the position of the
	 * item can be aligned vertically.
	 *
	 * @default feathers.layout.VerticalAlign.MIDDLE
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see feathers.layout.VerticalAlign#JUSTIFY
	 */
	public var tileVerticalAlign(get, set):String;
	private var _tileVerticalAlign:String = VerticalAlign.MIDDLE;
	private function get_tileVerticalAlign():String { return this._tileVerticalAlign; }
	private function set_tileVerticalAlign(value:String):String
	{
		if (this._tileVerticalAlign == value)
		{
			return value;
		}
		this._tileVerticalAlign = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._tileVerticalAlign;
	}
	
	/**
	 * If the item's width is less than the tile bounds, the position of the
	 * item can be aligned horizontally.
	 *
	 * @default feathers.layout.HorizontalAlign.CENTER
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 * @see feathers.layout.HorizontalAlign#JUSTIFY
	 */
	public var tileHorizontalAlign(get, set):String;
	private var _tileHorizontalAlign:String = HorizontalAlign.CENTER;
	private function get_tileHorizontalAlign():String { return this._tileHorizontalAlign; }
	private function set_tileHorizontalAlign(value:String):String
	{
		if (this._tileHorizontalAlign == value)
		{
			return value;
		}
		this._tileHorizontalAlign = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._tileHorizontalAlign;
	}
	
	/**
	 * Indicates if tiles are divided into pages vertically or
	 * horizontally, or if paging is disabled.
	 *
	 * @default feathers.layout.Direction.NONE
	 *
	 * @see feathers.layout.Direction#NONE
	 * @see feathers.layout.Direction#HORIZONTAL
	 * @see feathers.layout.Direction#VERTICAL
	 */
	public var paging(get, set):String;
	private var _paging:String = Direction.NONE;
	private function get_paging():String { return this._paging; }
	private function set_paging(value:String):String
	{
		if (this._paging == value)
		{
			return value;
		}
		this._paging = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._paging;
	}
	
	/**
	 * If the total width of the tiles in a row (minus padding and gap)
	 * does not fill the entire row, the remaining space will be distributed
	 * to each tile equally.
	 *
	 * <p>If the container using the layout might resize, setting
	 * <code>requestedColumnCount</code> is recommended because the tiles
	 * will resize too, and their dimensions may not be reset.</p>
	 *
	 * @default false
	 *
	 * @see #requestedColumnCount
	 */
	public var distributeWidths(get, set):Bool;
	private var _distributeWidths:Bool = false;
	private function get_distributeWidths():Bool { return this._distributeWidths; }
	private function set_distributeWidths(value:Bool):Bool
	{
		if (this._distributeWidths == value)
		{
			return value;
		}
		this._distributeWidths = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._distributeWidths;
	}
	
	/**
	 * If the total height of the tiles in a column (minus padding and gap)
	 * does not fill the entire column, the remaining space will be
	 * distributed to each tile equally.
	 *
	 * <p>If the container using the layout might resize, setting
	 * <code>requestedRowCount</code> is recommended because the tiles
	 * will resize too, and their dimensions may not be reset.</p>
	 *
	 * @default false
	 *
	 * @see #requestedRowCount
	 * @see #useSquareTiles
	 */
	public var distributeHeights(get, set):Bool;
	private var _distributeHeights:Bool = false;
	private function get_distributeHeights():Bool { return this._distributeHeights; }
	private function set_distributeHeights(value:Bool):Bool
	{
		if (this._distributeHeights == value)
		{
			return value;
		}
		this._distributeHeights = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._distributeHeights;
	}
	
	/**
	 * Determines if the tiles must be square or if their width and height
	 * may have different values.
	 *
	 * @default true
	 */
	public var useSquareTiles(get, set):Bool;
	private var _useSquareTiles:Bool = true;
	private function get_useSquareTiles():Bool { return this._useSquareTiles; }
	private function set_useSquareTiles(value:Bool):Bool
	{
		if (this._useSquareTiles == value)
		{
			return value;
		}
		this._useSquareTiles = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._useSquareTiles;
	}
	
	/**
	 * @copy feathers.layout.IVirtualLayout#useVirtualLayout
	 *
	 * @default true
	 */
	public var useVirtualLayout(get, set):Bool;
	private var _useVirtualLayout:Bool = true;
	private function get_useVirtualLayout():Bool { return this._useVirtualLayout; }
	private function set_useVirtualLayout(value:Bool):Bool
	{
		if (this._useVirtualLayout == value)
		{
			return value;
		}
		this._useVirtualLayout = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._useVirtualLayout;
	}
	
	/**
	 * @copy feathers.layout.IVirtualLayout#typicalItem
	 */
	public var typicalItem(get, set):DisplayObject;
	private var _typicalItem:DisplayObject;
	private function get_typicalItem():DisplayObject { return this._typicalItem; }
	private function set_typicalItem(value:DisplayObject):DisplayObject
	{
		if (this._typicalItem == value)
		{
			return value;
		}
		this._typicalItem = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._typicalItem;
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
	private var _typicalItemWidth:Float;
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
	private var _typicalItemHeight:Float;
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
	
	/**
	 * @copy feathers.layout.ILayout#requiresLayoutOnScroll
	 */
	public var requiresLayoutOnScroll(get, never):Bool;
	private function get_requiresLayoutOnScroll():Bool
	{
		return this._useVirtualLayout;
	}
	
}