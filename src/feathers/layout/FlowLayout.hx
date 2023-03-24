/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;
import feathers.core.IValidating;
import feathers.utils.type.SafeCast;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * Positions items of different dimensions from left to right in multiple
 * rows. When the width of a row reaches the width of the container, a new
 * row will be started. Constrained to the suggested width, the flow layout
 * will change in height as the number of items increases or decreases.
 *
 * @see ../../../help/flow-layout.html How to use FlowLayout with Feathers containers
 *
 * @productversion Feathers 2.2.0
 */
class FlowLayout extends BaseVariableVirtualLayout implements IVariableVirtualLayout implements IDragDropLayout
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this._hasVariableItemDimensions = true;
	}
	
	/**
	 * @private
	 */
	private var _rowItems:Array<DisplayObject> = new Array<DisplayObject>();
	
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
	 * The horizontal space, in pixels, between items.
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
	 * The vertical space, in pixels, between items.
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
	 * The space, in pixels, between the first and second items. If the
	 * value of <code>firstHorizontalGap</code> is <code>NaN</code>, the
	 * value of the <code>horizontalGap</code> property will be used
	 * instead.
	 *
	 * @default NaN
	 *
	 * @see #gap
	 */
	public var firstHorizontalGap(get, set):Float;
	private var _firstHorizontalGap:Float = Math.NaN;
	private function get_firstHorizontalGap():Float { return this._firstHorizontalGap; }
	private function set_firstHorizontalGap(value:Float):Float
	{
		if (this._firstHorizontalGap == value)
		{
			return value;
		}
		this._firstHorizontalGap = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._firstHorizontalGap;
	}
	
	/**
	 * The space, in pixels, between the last and second to last items. If
	 * the value of <code>lastHorizontalGap</code> is <code>NaN</code>, the
	 * value of the <code>horizontalGap</code> property will be used instead.
	 *
	 * @default NaN
	 *
	 * @see #gap
	 */
	public var lastHorizontalGap(get, set):Float;
	private var _lastHorizontalGap:Float = Math.NaN;
	private function get_lastHorizontalGap():Float { return this._lastHorizontalGap; }
	private function set_lastHorizontalGap(value:Float):Float
	{
		if (this._lastHorizontalGap == value)
		{
			return value;
		}
		this._lastHorizontalGap = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._lastHorizontalGap;
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
	 * If the total row width is less than the bounds, the items in the row
	 * can be aligned horizontally.
	 *
	 * <p><strong>Note:</strong> The <code>HorizontalAlign.JUSTIFY</code>
	 * constant is not supported.</p>
	 *
	 * @default feathers.layout.HorizontalAlign.LEFT
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 * @see #verticalAlign
	 * @see #rowVerticalAlign
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
	 * If the total height of the content is less than the bounds, the
	 * content may be aligned vertically.
	 *
	 * <p><strong>Note:</strong> The <code>VerticalAlign.JUSTIFY</code>
	 * constant is not supported.</p>
	 *
	 * @default feathers.layout.VerticalAlign.TOP
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see #horizontalAlign
	 * @see #rowVerticalAlign
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
	 * If the height of an item is less than the height of a row, it can be
	 * aligned vertically.
	 *
	 * @default feathers.layout.VerticalAlign.TOP
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see #horizontalAlign
	 * @see #verticalAlign
	 */
	public var rowVerticalAlign(get, set):String;
	private var _rowVerticalAlign:String = VerticalAlign.TOP;
	private function get_rowVerticalAlign():String { return this._rowVerticalAlign; }
	private function set_rowVerticalAlign(value:String):String
	{
		if (this._rowVerticalAlign == value)
		{
			return value;
		}
		this._rowVerticalAlign = value;
		return this._rowVerticalAlign;
	}
	
	/**
	 * @private
	 */
	private var _widthCache:Array<Null<Float>> = [];

	/**
	 * @private
	 */
	private var _heightCache:Array<Null<Float>> = [];
	
	/**
	 * @inheritDoc
	 */
	public function layout(items:Array<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult
	{
		//this function is very long because it may be called every frame,
		//in some situations. testing revealed that splitting this function
		//into separate, smaller functions affected performance.
		//since the SWC compiler cannot inline functions, we can't use that
		//feature either.
		
		//since viewPortBounds can be null, we may need to provide some defaults
		var boundsX:Float = viewPortBounds != null ? viewPortBounds.x : 0;
		var boundsY:Float = viewPortBounds != null ? viewPortBounds.y : 0;
		var minWidth:Float = viewPortBounds != null ? viewPortBounds.minWidth : 0;
		var minHeight:Float = viewPortBounds != null ? viewPortBounds.minHeight : 0;
		var maxWidth:Float = viewPortBounds != null ? viewPortBounds.maxWidth : Math.POSITIVE_INFINITY;
		var maxHeight:Float = viewPortBounds != null ? viewPortBounds.maxHeight : Math.POSITIVE_INFINITY;
		var explicitWidth:Float = viewPortBounds != null ? viewPortBounds.explicitWidth : Math.NaN;
		var explicitHeight:Float = viewPortBounds != null ? viewPortBounds.explicitHeight : Math.NaN;
		
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN
		//let's figure out if we can show multiple rows
		var supportsMultipleRows:Bool = true;
		var availableRowWidth:Float = explicitWidth;
		if (needsWidth)
		{
			availableRowWidth = maxWidth;
			if (availableRowWidth == Math.POSITIVE_INFINITY)
			{
				supportsMultipleRows = false;
			}
		}
		
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			if (Std.isOfType(this._typicalItem, IValidating))
			{
				cast(this._typicalItem, IValidating).validate();
			}
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var i:Int = 0;
		var itemCount:Int = items.length;
		var positionY:Float = boundsY + this._paddingTop;
		var maxRowWidth:Float = 0;
		var maxItemHeight:Float = 0;
		var verticalGap:Float = this._verticalGap;
		var hasFirstHorizontalGap:Bool = this._firstHorizontalGap == this._firstHorizontalGap; //!isNaN
		var hasLastHorizontalGap:Bool = this._lastHorizontalGap == this._lastHorizontalGap; //!isNaN
		var secondToLastIndex:Int = itemCount - 2;
		var positionX:Float;
		var rowItemCount:Int;
		var horizontalGap:Float;
		var item:DisplayObject;
		var cachedWidth:Float = Math.NaN;
		var cachedHeight:Float = Math.NaN;
		var itemWidth:Float;
		var itemHeight:Float;
		var previousIndex:Int;
		var totalRowWidth:Float;
		var horizontalAlignOffsetX:Float;
		var layoutItem:ILayoutDisplayObject;
		do
		{
			if (i != 0)
			{
				positionY += maxItemHeight + verticalGap;
			}
			//this section prepares some variables needed for the following loop
			maxItemHeight = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
			positionX = boundsX + this._paddingLeft;
			//we save the items in this row to align them later.
			this._rowItems.resize(0);
			rowItemCount = 0;
			
			//if there are no items in the row (such as when there are no
			//items in the container!), then we don't want to subtract the
			//gap when calculating the row width, so default to 0.
			horizontalGap = 0;
			
			//this first loop sets the x position of items, and it calculates
			//the total width of all items
			while (i < itemCount)
			{
				item = items[i];
				horizontalGap = this._horizontalGap;
				if (hasFirstHorizontalGap && i == 0)
				{
					horizontalGap = this._firstHorizontalGap;
				}
				else if (hasLastHorizontalGap && i != 0 && i == secondToLastIndex)
				{
					horizontalGap = this._lastHorizontalGap;
				}
				
				if (this._useVirtualLayout && this._hasVariableItemDimensions)
				{
					cachedWidth = this._widthCache[i];
					cachedHeight = this._heightCache[i];
				}
				if (this._useVirtualLayout && item == null)
				{
					//the item is null, and the layout is virtualized, so we
					//need to estimate the width of the item.
					
					if (this._hasVariableItemDimensions)
					{
						if (cachedWidth != cachedWidth) //isNaN
						{
							itemWidth = calculatedTypicalItemWidth;
						}
						else
						{
							itemWidth = cachedWidth;
						}
						if (cachedHeight != cachedHeight) //isNaN
						{
							itemHeight = calculatedTypicalItemHeight;
						}
						else
						{
							itemHeight = cachedHeight;
						}
					}
					else
					{
						itemWidth = calculatedTypicalItemWidth;
						itemHeight = calculatedTypicalItemHeight;
					}
				}
				else
				{
					//we get here if the item isn't null. it is never null if
					//the layout isn't virtualized.
					if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
					{
						continue;
					}
					if (Std.isOfType(item, IValidating))
					{
						cast(item, IValidating).validate();
					}
					itemWidth = item.width;
					itemHeight = item.height;
					if (this._useVirtualLayout)
					{
						if (this._hasVariableItemDimensions)
						{
							if (itemWidth != cachedWidth)
							{
								//update the cache if needed. this will notify
								//the container that the virtualized layout has
								//changed, and it the view port may need to be
								//re-measured.
								this._widthCache[i] = itemWidth;
								this.dispatchEventWith(Event.CHANGE);
							}
							if (itemHeight != cachedHeight)
							{
								this._heightCache[i] = itemHeight;
								this.dispatchEventWith(Event.CHANGE);
							}
						}
						else
						{
							if (calculatedTypicalItemWidth >= 0)
							{
								item.width = itemWidth = calculatedTypicalItemWidth;
							}
							if (calculatedTypicalItemHeight >= 0)
							{
								item.height = itemHeight = calculatedTypicalItemHeight;
							}
						}
					}
				}
				if (supportsMultipleRows && rowItemCount != 0 && (positionX + itemWidth) > (availableRowWidth - this._paddingRight))
				{
					//we need to restore the previous gap because it will be
					//subtracted from the x position to get the row width.
					previousIndex = i - 1;
					horizontalGap = this._horizontalGap;
					if (hasFirstHorizontalGap && previousIndex == 0)
					{
						horizontalGap = this._firstHorizontalGap;
					}
					else if (hasLastHorizontalGap && previousIndex > 0 && previousIndex == secondToLastIndex)
					{
						horizontalGap = this._lastHorizontalGap;
					}
					//we've reached the end of the row, so go to next
					break;
				}
				if (item != null)
				{
					this._rowItems[this._rowItems.length] = item;
					item.x = item.pivotX + positionX;
				}
				positionX += itemWidth + horizontalGap;
				//we compare with > instead of Math.max() because the rest
				//arguments on Math.max() cause extra garbage collection and
				//hurt performance
				if (itemHeight > maxItemHeight)
				{
					//we need to know the maximum height of the items in the
					//case where the height of the view port needs to be
					//calculated by the layout.
					maxItemHeight = itemHeight;
				}
				rowItemCount++;
				i++;
			}
			
			//this is the total width of all items in the row
			totalRowWidth = positionX - horizontalGap + this._paddingRight - boundsX;
			if (totalRowWidth > maxRowWidth)
			{
				maxRowWidth = totalRowWidth;
			}
			rowItemCount = this._rowItems.length;
			
			if (supportsMultipleRows)
			{
				//in this section, we handle horizontal alignment for the
				//current row. however, we may need to adjust it later if
				//the maxRowWidth is smaller than the availableRowWidth.
				horizontalAlignOffsetX = 0;
				if (this._horizontalAlign == HorizontalAlign.RIGHT)
				{
					horizontalAlignOffsetX = availableRowWidth - totalRowWidth;
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					horizontalAlignOffsetX = Math.fround((availableRowWidth - totalRowWidth) / 2);
				}
				if (horizontalAlignOffsetX != 0)
				{
					for (j in 0...rowItemCount)
					{
						item = this._rowItems[j];
						if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
						{
							continue;
						}
						item.x += horizontalAlignOffsetX;
					}
				}
			}
			
			for (j in 0...rowItemCount)
			{
				item = this._rowItems[j];
				layoutItem = SafeCast.safe_cast(item, ILayoutDisplayObject);
				if (layoutItem != null && !layoutItem.includeInLayout)
				{
					continue;
				}
				//handle all other vertical alignment values. the y position
				//of all items is set here.
				switch (this._rowVerticalAlign)
				{
					case VerticalAlign.BOTTOM:
						item.y = item.pivotY + positionY + maxItemHeight - item.height;
					
					case VerticalAlign.MIDDLE:
						//round to the nearest pixel when dividing by 2 to
						//align in the middle
						item.y = item.pivotY + positionY + Math.round((maxItemHeight - item.height) / 2);
					
					default: //top
						item.y = item.pivotY + positionY;
				}
			}
		}
		while (i < itemCount);
		//we don't want to keep a reference to any of the items, so clear
		//this cache
		this._rowItems.resize(0);
		
		var contentRowWidth:Float;
		if (supportsMultipleRows && (needsWidth || explicitWidth < maxRowWidth))
		{
			//if the maxRowWidth has changed since any row was aligned, the
			//items in those rows may need to be shifted a bit
			contentRowWidth = maxRowWidth;
			if (contentRowWidth < minWidth)
			{
				contentRowWidth = minWidth;
			}
			else if (contentRowWidth > maxWidth)
			{
				contentRowWidth = maxWidth;
			}
			horizontalAlignOffsetX = 0;
			if (this._horizontalAlign == HorizontalAlign.RIGHT)
			{
				horizontalAlignOffsetX = availableRowWidth - contentRowWidth;
			}
			else if (this._horizontalAlign == HorizontalAlign.CENTER)
			{
				horizontalAlignOffsetX = Math.round((availableRowWidth - contentRowWidth) / 2);
			}
			if (horizontalAlignOffsetX != 0)
			{
				for (j in 0...itemCount)
				{
					item = items[j];
					layoutItem = SafeCast.safe_cast(item, ILayoutDisplayObject);
					if (item == null || (layoutItem != null && !layoutItem.includeInLayout))
					{
						continue;
					}
					//previously, we used the maxWidth for alignment,
					//but the max row width may be smaller, so we need
					//to account for the difference
					item.x -= horizontalAlignOffsetX;
				}
			}
		}
		else
		{
			contentRowWidth = maxRowWidth;
		}
		if (needsWidth)
		{
			availableRowWidth = contentRowWidth;
		}
		
		var totalHeight:Float = positionY + maxItemHeight + this._paddingBottom;
		//the available height is the height of the viewport. if the explicit
		//height is NaN, we need to calculate the viewport height ourselves
		//based on the total height of all items.
		var availableHeight:Float = explicitHeight;
		if (availableHeight != availableHeight) //isNaN
		{
			availableHeight = totalHeight;
			if (availableHeight < minHeight)
			{
				availableHeight = minHeight;
			}
			else if (availableHeight > maxHeight)
			{
				availableHeight = maxHeight;
			}
		}
		
		if (totalHeight < availableHeight &&
			this._verticalAlign != VerticalAlign.TOP)
		{
			var verticalAlignOffset:Float = availableHeight - totalHeight;
			if (this._verticalAlign == VerticalAlign.MIDDLE)
			{
				verticalAlignOffset /= 2;
			}
			for (j in 0...itemCount)
			{
				item = items[i];
				layoutItem = SafeCast.safe_cast(item, ILayoutDisplayObject);
				if (item == null || (layoutItem != null && !layoutItem.includeInLayout))
				{
					continue;
				}
				item.y += verticalAlignOffset;
			}
		}
		
		//finally, we want to calculate the result so that the container
		//can use it to adjust its viewport and determine the minimum and
		//maximum scroll positions (if needed)
		if (result == null)
		{
			result = new LayoutBoundsResult();
		}
		result.contentX = 0;
		result.contentWidth = maxRowWidth;
		result.contentY = 0;
		result.contentHeight = totalHeight;
		result.viewPortWidth = availableRowWidth;
		result.viewPortHeight = availableHeight;
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function measureViewPort(itemCount:Int, viewPortBounds:ViewPortBounds = null, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		if (!this._useVirtualLayout)
		{
			throw new IllegalOperationError("measureViewPort() may be called only if useVirtualLayout is true.");
		}
		//this function is very long because it may be called every frame,
		//in some situations. testing revealed that splitting this function
		//into separate, smaller functions affected performance.
		//since the SWC compiler cannot inline functions, we can't use that
		//feature either.
		
		//since viewPortBounds can be null, we may need to provide some defaults
		var boundsX:Float = viewPortBounds != null ? viewPortBounds.x : 0;
		var boundsY:Float = viewPortBounds != null ? viewPortBounds.y : 0;
		var minWidth:Float = viewPortBounds != null ? viewPortBounds.minWidth : 0;
		var minHeight:Float = viewPortBounds != null ? viewPortBounds.minHeight : 0;
		var maxWidth:Float = viewPortBounds != null ? viewPortBounds.maxWidth : Math.POSITIVE_INFINITY;
		var maxHeight:Float = viewPortBounds != null ? viewPortBounds.maxHeight : Math.POSITIVE_INFINITY;
		var explicitWidth:Float = viewPortBounds != null ? viewPortBounds.explicitWidth : Math.NaN;
		var explicitHeight:Float = viewPortBounds != null ? viewPortBounds.explicitHeight : Math.NaN;
		
		//let's figure out if we can show multiple rows
		var supportsMultipleRows:Bool = true;
		var availableRowWidth:Float = explicitWidth;
		if (availableRowWidth != availableRowWidth) //isNaN
		{
			availableRowWidth = maxWidth;
			if (availableRowWidth == Math.POSITIVE_INFINITY)
			{
				supportsMultipleRows = false;
			}
		}
		
		if (Std.isOfType(this._typicalItem, IValidating))
		{
			cast(this._typicalItem, IValidating).validate();
		}
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var i:Int = 0;
		var positionY:Float = boundsY + this._paddingTop;
		var maxRowWidth:Float = 0;
		var maxItemHeight:Float = 0;
		var verticalGap:Float = this._verticalGap;
		var hasFirstHorizontalGap:Bool = this._firstHorizontalGap == this._firstHorizontalGap; //!isNaN
		var hasLastHorizontalGap:Bool = this._lastHorizontalGap == this._lastHorizontalGap; //!isNaN
		var secondToLastIndex:Int = itemCount - 2;
		var positionX:Float;
		var rowItemCount:Int;
		var horizontalGap:Float;
		var cachedWidth:Float;
		var cachedHeight:Float;
		var itemWidth:Float;
		var itemHeight:Float;
		var totalRowWidth:Float;
		do
		{
			if (i != 0)
			{
				positionY += maxItemHeight + verticalGap;
			}
			//this section prepares some variables needed for the following loop
			maxItemHeight = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
			positionX = boundsX + this._paddingLeft;
			rowItemCount = 0;
			
			//if there are no items in the row (such as when there are no
			//items in the container!), then we don't want to subtract the
			//gap when calculating the row width, so default to 0.
			horizontalGap = 0;
			
			//this first loop sets the x position of items, and it calculates
			//the total width of all items
			while (i < itemCount)
			{
				horizontalGap = this._horizontalGap;
				if (hasFirstHorizontalGap && i == 0)
				{
					horizontalGap = this._firstHorizontalGap;
				}
				else if (hasLastHorizontalGap && i != 0 && i == secondToLastIndex)
				{
					horizontalGap = this._lastHorizontalGap;
				}
				if (this._hasVariableItemDimensions)
				{
					cachedWidth = this._widthCache[i];
					cachedHeight = this._heightCache[i];
					if (cachedWidth != cachedWidth) //isNaN
					{
						itemWidth = calculatedTypicalItemWidth;
					}
					else
					{
						itemWidth = cachedWidth;
					}
					if (cachedHeight != cachedHeight) //isNaN
					{
						itemHeight = calculatedTypicalItemHeight;
					}
					else
					{
						itemHeight = cachedHeight;
					}
				}
				else
				{
					itemWidth = calculatedTypicalItemWidth;
					itemHeight = calculatedTypicalItemHeight;
				}
				if (supportsMultipleRows && rowItemCount != 0 && (positionX + itemWidth) > (availableRowWidth - this._paddingRight))
				{
					//we've reached the end of the row, so go to next
					break;
				}
				positionX += itemWidth + horizontalGap;
				//we compare with > instead of Math.max() because the rest
				//arguments on Math.max() cause extra garbage collection and
				//hurt performance
				if (itemHeight > maxItemHeight)
				{
					//we need to know the maximum height of the items in the
					//case where the height of the view port needs to be
					//calculated by the layout.
					maxItemHeight = itemHeight;
				}
				rowItemCount++;
				i++;
			}
			
			//this is the total width of all items in the row
			totalRowWidth = positionX - horizontalGap + this._paddingRight - boundsX;
			if (totalRowWidth > maxRowWidth)
			{
				maxRowWidth = totalRowWidth;
			}
		}
		while (i < itemCount);
		
		if (supportsMultipleRows)
		{
			if (explicitWidth != explicitWidth) //isNaN
			{
				availableRowWidth = maxRowWidth;
				if (availableRowWidth < minWidth)
				{
					availableRowWidth = minWidth;
				}
				else if (availableRowWidth > maxWidth)
				{
					availableRowWidth = maxWidth;
				}
			}
		}
		else
		{
			availableRowWidth = maxRowWidth;
		}
		
		var totalHeight:Float = positionY + maxItemHeight + this._paddingBottom;
		//the available height is the height of the viewport. if the explicit
		//height is NaN, we need to calculate the viewport height ourselves
		//based on the total height of all items.
		var availableHeight:Float = explicitHeight;
		if (availableHeight != availableHeight) //isNaN
		{
			availableHeight = totalHeight;
			if (availableHeight < minHeight)
			{
				availableHeight = minHeight;
			}
			else if (availableHeight > maxHeight)
			{
				availableHeight = maxHeight;
			}
		}
		
		result.x = availableRowWidth;
		result.y = availableHeight;
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		result = this.calculateMaxScrollYAndRowHeightOfIndex(index, items, x, y, width, height, result);
		var maxScrollY:Float = result.x;
		var rowHeight:Float = result.y;
		
		result.x = 0;
		
		var bottomPosition:Float = maxScrollY - (height - rowHeight);
		if (scrollY >= bottomPosition && scrollY <= maxScrollY)
		{
			//keep the current scroll position because the item is already
			//fully visible
			result.y = scrollY;
		}
		else
		{
			var topDifference:Float = Math.abs(maxScrollY - scrollY);
			var bottomDifference:Float = Math.abs(bottomPosition - scrollY);
			if (bottomDifference < topDifference)
			{
				result.y = bottomPosition;
			}
			else
			{
				result.y = maxScrollY;
			}
		}
		
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function calculateNavigationDestination(items:Array<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int
	{
		var result:Int = index;
		if (keyCode == Keyboard.HOME)
		{
			if (items.length != 0)
			{
				result = 0;
			}
		}
		else if (keyCode == Keyboard.END)
		{
			result = items.length - 1;
		}
		else if (keyCode == Keyboard.UP)
		{
			result--;
		}
		else if (keyCode == Keyboard.DOWN)
		{
			result++;
		}
		if (result < 0)
		{
			return 0;
		}
		if (result >= items.length)
		{
			return items.length - 1;
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		result = this.calculateMaxScrollYAndRowHeightOfIndex(index, items, x, y, width, height, result);
		var maxScrollY:Float = result.x;
		//var rowHeight:Float = result.y;
		
		var itemHeight:Float;
		if (this._useVirtualLayout)
		{
			if (this._hasVariableItemDimensions)
			{
				itemHeight = this._heightCache[index];
				if (itemHeight != itemHeight) //isNaN
				{
					itemHeight = this._typicalItem.height;
				}
			}
			else
			{
				itemHeight = this._typicalItem.height;
			}
		}
		else
		{
			itemHeight = items[index].height;
		}
		
		if (result == null)
		{
			result = new Point();
		}
		result.x = 0;
		result.y = maxScrollY - Math.fround((height - itemHeight) / 2);
		
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getDropIndex(x:Float, y:Float, items:Array<DisplayObject>,
		boundsX:Float, boundsY:Float, width:Float, height:Float):Int
	{
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			if (Std.isOfType(this._typicalItem, IValidating))
			{
				cast(this._typicalItem, IValidating).validate();
			}
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var horizontalGap:Float = this._horizontalGap;
		var verticalGap:Float = this._verticalGap;
		var maxItemHeight:Float = 0;
		var positionY:Float = this._paddingTop;
		var i:Int = 0;
		var itemCount:Int = items.length;
		var positionX:Float;
		var rowItemCount:Int;
		var item:DisplayObject;
		var cachedWidth:Float = Math.NaN;
		var cachedHeight:Float = Math.NaN;
		var itemWidth:Float;
		var itemHeight:Float;
		var endOfRow:Bool;
		do
		{
			if (i != 0)
			{
				positionY += maxItemHeight + verticalGap;
			}
			//this section prepares some variables needed for the following loop
			maxItemHeight = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
			positionX = this._paddingLeft;
			rowItemCount = 0;
			while (i < itemCount)
			{
				item = items[i];
				
				if (this._useVirtualLayout && this._hasVariableItemDimensions)
				{
					cachedWidth = this._widthCache[i];
					cachedHeight = this._heightCache[i];
				}
				if (this._useVirtualLayout && item == null)
				{
					//the item is null, and the layout is virtualized, so we
					//need to estimate the width of the item.
					
					if (this._hasVariableItemDimensions)
					{
						if (cachedWidth != cachedWidth) //isNaN
						{
							itemWidth = calculatedTypicalItemWidth;
						}
						else
						{
							itemWidth = cachedWidth;
						}
						if (cachedHeight != cachedHeight) //isNaN
						{
							itemHeight = calculatedTypicalItemHeight;
						}
						else
						{
							itemHeight = cachedHeight;
						}
					}
					else
					{
						itemWidth = calculatedTypicalItemWidth;
						itemHeight = calculatedTypicalItemHeight;
					}
				}
				else
				{
					//we get here if the item isn't null. it is never null if
					//the layout isn't virtualized.
					if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
					{
						continue;
					}
					if (Std.isOfType(item, IValidating))
					{
						cast(item, IValidating).validate();
					}
					itemWidth = item.width;
					itemHeight = item.height;
					if (this._useVirtualLayout && this._hasVariableItemDimensions)
					{
						if (this._hasVariableItemDimensions)
						{
							if (itemWidth != cachedWidth)
							{
								this._widthCache[i] = itemWidth;
								this.dispatchEventWith(Event.CHANGE);
							}
							if (itemHeight != cachedHeight)
							{
								this._heightCache[i] = itemHeight;
								this.dispatchEventWith(Event.CHANGE);
							}
						}
						else
						{
							if (calculatedTypicalItemWidth >= 0)
							{
								itemWidth = calculatedTypicalItemWidth;
							}
							if (calculatedTypicalItemHeight >= 0)
							{
								itemHeight = calculatedTypicalItemHeight;
							}
						}
					}
				}
				endOfRow = rowItemCount != 0 && (positionX + itemWidth) > (width - this._paddingRight);
				if ((endOfRow || x < (positionX + (itemWidth / 2))) && y < (positionY + itemHeight + (gap / 2)))
				{
					return i;
				}
				if (endOfRow)
				{
					//we've reached the end of the row, so go to next
					break;
				}
				//we compare with > instead of Math.max() because the rest
				//arguments on Math.max() cause extra garbage collection and
				//hurt performance
				if (itemHeight > maxItemHeight)
				{
					//we need to know the maximum height of the items in the
					//case where the height of the view port needs to be
					//calculated by the layout.
					maxItemHeight = itemHeight;
				}
				positionX += itemWidth + horizontalGap;
				rowItemCount++;
				i++;
			}
		}
		while (i < itemCount);
		return itemCount;
	}
	
	/**
	 * @inheritDoc
	 */
	public function positionDropIndicator(dropIndicator:DisplayObject, index:Int,
		x:Float, y:Float, items:Array<DisplayObject>, width:Float, height:Float):Void
	{
		if (Std.isOfType(dropIndicator, IValidating))
		{
			cast(dropIndicator, IValidating).validate();
		}
		
		var horizontalGap:Float = this._horizontalGap;
		var verticalGap:Float = this._verticalGap;
		var maxItemHeight:Float = 0;
		var positionY:Float = this._paddingTop;
		var i:Int = 0;
		var itemCount:Int = items.length;
		var item:DisplayObject;
		var positionX:Float;
		var rowItemCount:Int;
		var itemWidth:Float;
		var itemHeight:Float = 0;
		do
		{
			if (i != 0)
			{
				if (y < (positionY + itemHeight + (verticalGap / 2)))
				{
					//if the x/y position is closer to the previous row,
					//then display the drop indicator at the end of that row
					item = items[i - 1];
					dropIndicator.x = item.x + item.width - dropIndicator.width / 2;
					dropIndicator.y = item.y;
					dropIndicator.height = item.height;
					return;
				}
				positionY += maxItemHeight + verticalGap;
			}
			//this section prepares some variables needed for the following loop
			maxItemHeight = 0;
			positionX = this._paddingLeft;
			rowItemCount = 0;
			while (i < itemCount)
			{
				item = items[i];
				itemWidth = item.width;
				itemHeight = item.height;
				if (rowItemCount > 0 && (positionX + itemWidth) > (width - this._paddingRight))
				{
					//we've reached the end of the row, so go to next
					break;
				}
				//we compare with > instead of Math.max() because the rest
				//arguments on Math.max() cause extra garbage collection and
				//hurt performance
				if (itemHeight > maxItemHeight)
				{
					//we need to know the maximum height of the items in the
					//case where the height of the view port needs to be
					//calculated by the layout.
					maxItemHeight = itemHeight;
				}
				if (i == index)
				{
					dropIndicator.x = item.x - dropIndicator.width / 2;
					dropIndicator.y = item.y;
					dropIndicator.height = item.height;
					return;
				}
				positionX += itemWidth + horizontalGap;
				rowItemCount++;
				i++;
			}
		}
		while (i < itemCount);
		var lastItem:DisplayObject = items[itemCount - 1];
		dropIndicator.x = lastItem.x + lastItem.width - dropIndicator.width / 2;
		dropIndicator.y = lastItem.y;
		dropIndicator.height = lastItem.height;
	}
	
	/**
	 * @inheritDoc
	 */
	override function resetVariableVirtualCache():Void
	{
		this._widthCache.resize(0);
		this._heightCache.resize(0);
	}
	
	/**
	 * @inheritDoc
	 */
	override function resetVariableVirtualCacheAtIndex(index:Int, item:DisplayObject = null):Void
	{
		this._widthCache.splice(index, 1);
		this._heightCache.splice(index, 1);
		if (item != null)
		{
			this._widthCache[index] = item.width;
			this._heightCache[index] = item.height;
			this.dispatchEventWith(Event.CHANGE);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override function addToVariableVirtualCacheAtIndex(index:Int, item:DisplayObject = null):Void
	{
		var widthValue:Null<Float> = (item != null) ? item.width : null;
		var heightValue:Null<Float> = (item != null) ? item.height : null;
		this._widthCache.insert(index, widthValue);
		this._heightCache.insert(index, heightValue);
	}
	
	/**
	 * @inheritDoc
	 */
	override function removeFromVariableVirtualCacheAtIndex(index:Int):Void
	{
		this._widthCache.splice(index, 1);
		this._heightCache.splice(index, 1);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getVisibleIndicesAtScrollPosition(scrollX:Float, scrollY:Float, width:Float, height:Float, itemCount:Int, result:Array<Int> = null):Array<Int>
	{
		if (result != null)
		{
			result.resize(0);
		}
		else
		{
			result = new Array<Int>();
		}
		if (!this._useVirtualLayout)
		{
			throw new IllegalOperationError("getVisibleIndicesAtScrollPosition() may be called only if useVirtualLayout is true.");
		}
		
		if (Std.isOfType(this._typicalItem, IValidating))
		{
			cast(this._typicalItem, IValidating).validate();
		}
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var resultLastIndex:Int = 0;
		
		var i:Int = 0;
		var positionY:Float = this._paddingTop;
		var maxItemHeight:Float = 0;
		var verticalGap:Float = this._verticalGap;
		var maxPositionY:Float = scrollY + height;
		var hasFirstHorizontalGap:Bool = this._firstHorizontalGap == this._firstHorizontalGap; //!isNaN
		var hasLastHorizontalGap:Bool = this._lastHorizontalGap == this._lastHorizontalGap; //!isNaN
		var secondToLastIndex:Int = itemCount - 2;
		var positionX:Float;
		var rowItemCount:Int;
		var horizontalGap:Float;
		var cachedWidth:Float = Math.NaN;
		var cachedHeight:Float = Math.NaN;
		var itemWidth:Float;
		var itemHeight:Float;
		do
		{
			if (i != 0)
			{
				positionY += maxItemHeight + verticalGap;
				if (positionY >= maxPositionY)
				{
					//the following rows will not be visible, so we can stop
					break;
				}
			}
			//this section prepares some variables needed for the following loop
			maxItemHeight = calculatedTypicalItemHeight;
			positionX = this._paddingLeft;
			rowItemCount = 0;
			
			//this first loop sets the x position of items, and it calculates
			//the total width of all items
			while (i < itemCount)
			{
				horizontalGap = this._horizontalGap;
				if (hasFirstHorizontalGap && i == 0)
				{
					horizontalGap = this._firstHorizontalGap;
				}
				else if (hasLastHorizontalGap && i != 0 && i == secondToLastIndex)
				{
					horizontalGap = this._lastHorizontalGap;
				}
				if (this._hasVariableItemDimensions)
				{
					cachedWidth = this._widthCache[i];
					cachedHeight = this._heightCache[i];
				}
				if (this._hasVariableItemDimensions)
				{
					if (cachedWidth != cachedWidth) //isNaN
					{
						itemWidth = calculatedTypicalItemWidth;
					}
					else
					{
						itemWidth = cachedWidth;
					}
					if (cachedHeight != cachedHeight) //isNaN
					{
						itemHeight = calculatedTypicalItemHeight;
					}
					else
					{
						itemHeight = cachedHeight;
					}
				}
				else
				{
					itemWidth = calculatedTypicalItemWidth;
					itemHeight = calculatedTypicalItemHeight;
				}
				if (rowItemCount > 0 && (positionX + itemWidth) > (width - this._paddingRight))
				{
					//we've reached the end of the row, so go to next
					break;
				}
				if ((positionY + itemHeight) > scrollY)
				{
					result[resultLastIndex] = i;
					resultLastIndex++;
				}
				positionX += itemWidth + horizontalGap;
				//we compare with > instead of Math.max() because the rest
				//arguments on Math.max() cause extra garbage collection and
				//hurt performance
				if (itemHeight > maxItemHeight)
				{
					//we need to know the maximum height of the items in the
					//case where the height of the view port needs to be
					//calculated by the layout.
					maxItemHeight = itemHeight;
				}
				rowItemCount++;
				i++;
			}
		}
		while (i < itemCount);
		return result;
	}
	
	/**
	 * @private
	 */
	private function calculateMaxScrollYAndRowHeightOfIndex(index:Int, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			if (Std.isOfType(this._typicalItem, IValidating))
			{
				cast(this._typicalItem, IValidating).validate();
			}
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var horizontalGap:Float = this._horizontalGap;
		var verticalGap:Float = this._verticalGap;
		var maxItemHeight:Float = 0;
		var positionY:Float = y + this._paddingTop;
		var i:Int = 0;
		var itemCount:Int = items.length;
		var isLastRow:Bool = false;
		var positionX:Float;
		var rowItemCount:Int;
		var item:DisplayObject;
		var cachedWidth:Float = Math.NaN;
		var cachedHeight:Float = Math.NaN;
		var itemWidth:Float;
		var itemHeight:Float;
		do
		{
			if (isLastRow)
			{
				break;
			}
			if (i != 0)
			{
				positionY += maxItemHeight + verticalGap;
			}
			//this section prepares some variables needed for the following loop
			maxItemHeight = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
			positionX = x + this._paddingLeft;
			rowItemCount = 0;
			while (i < itemCount)
			{
				item = items[i];
				
				if (this._useVirtualLayout && this._hasVariableItemDimensions)
				{
					cachedWidth = this._widthCache[i];
					cachedHeight = this._heightCache[i];
				}
				if (this._useVirtualLayout && item == null)
				{
					//the item is null, and the layout is virtualized, so we
					//need to estimate the width of the item.
					
					if (this._hasVariableItemDimensions)
					{
						if (cachedWidth != cachedWidth) //isNaN
						{
							itemWidth = calculatedTypicalItemWidth;
						}
						else
						{
							itemWidth = cachedWidth;
						}
						if (cachedHeight != cachedHeight) //isNaN
						{
							itemHeight = calculatedTypicalItemHeight;
						}
						else
						{
							itemHeight = cachedHeight;
						}
					}
					else
					{
						itemWidth = calculatedTypicalItemWidth;
						itemHeight = calculatedTypicalItemHeight;
					}
				}
				else
				{
					//we get here if the item isn't null. it is never null if
					//the layout isn't virtualized.
					if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
					{
						continue;
					}
					if (Std.isOfType(item, IValidating))
					{
						cast(item, IValidating).validate();
					}
					itemWidth = item.width;
					itemHeight = item.height;
					if (this._useVirtualLayout && this._hasVariableItemDimensions)
					{
						if (this._hasVariableItemDimensions)
						{
							if (itemWidth != cachedWidth)
							{
								this._widthCache[i] = itemWidth;
								this.dispatchEventWith(Event.CHANGE);
							}
							if (itemHeight != cachedHeight)
							{
								this._heightCache[i] = itemHeight;
								this.dispatchEventWith(Event.CHANGE);
							}
						}
						else
						{
							if (calculatedTypicalItemWidth >= 0)
							{
								itemWidth = calculatedTypicalItemWidth;
							}
							if (calculatedTypicalItemHeight >= 0)
							{
								itemHeight = calculatedTypicalItemHeight;
							}
						}
					}
				}
				if (rowItemCount > 0 && (positionX + itemWidth) > (width - this._paddingRight))
				{
					//we've reached the end of the row, so go to next
					break;
				}
				//we don't check this at the beginning of the loop because
				//it may break to start a new row and then redo this item
				if (i == index)
				{
					isLastRow = true;
				}
				//we compare with > instead of Math.max() because the rest
				//arguments on Math.max() cause extra garbage collection and
				//hurt performance
				if (itemHeight > maxItemHeight)
				{
					//we need to know the maximum height of the items in the
					//case where the height of the view port needs to be
					//calculated by the layout.
					maxItemHeight = itemHeight;
				}
				positionX += itemWidth + horizontalGap;
				rowItemCount++;
				i++;
			}
		}
		while (i < itemCount);
		result.setTo(positionY, maxItemHeight);
		return result;
	}
	
}