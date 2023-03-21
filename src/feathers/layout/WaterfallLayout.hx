/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;
import feathers.core.IValidating;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * A layout with multiple columns of equal width where items may have
 * variable heights. Items are added to the layout in order, but they may be
 * added to any of the available columns. The layout selects the column
 * where the column's height plus the item's height will result in the
 * smallest possible total height.
 *
 * @see ../../../help/waterfall-layout.html How to use WaterfallLayout with Feathers containers
 *
 * @productversion Feathers 2.2.0
 */
class WaterfallLayout extends BaseVariableVirtualLayout implements IVariableVirtualLayout
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
	 * The horizontal space, in pixels, between columns.
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
	 * The vertical space, in pixels, between items in a column.
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
	 * The space, in pixels, that appears on top, above the items.
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
	 * The space, in pixels, that appears on the bottom, below the items.
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
	 * The alignment of the items horizontally, on the x-axis.
	 *
	 * <p><strong>Note:</strong> The <code>HorizontalAlign.JUSTIFY</code>
	 * constant is not supported.</p>
	 *
	 * @default feathers.layout.HorizontalAlign.CENTER
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
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
	 * Requests that the layout uses a specific number of columns, if
	 * possible. Set to <code>0</code> to calculate the maximum of columns
	 * that will fit in the available space.
	 *
	 * <p>If the view port's explicit or maximum width is not large enough
	 * to fit the requested number of columns, it will use fewer. If the
	 * view port doesn't have an explicit width and the maximum width is
	 * equal to <code>Number.POSITIVE_INFINITY</code>, the width will be
	 * calculated automatically to fit the exact number of requested
	 * columns.</p>
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
	 * @private
	 */
	private var _heightCache:Array<Float> = new Array<Float>();
	
	/**
	 * @inheritDoc
	 */
	public function layout(items:Array<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult
	{
		var boundsX:Float = viewPortBounds != null ? viewPortBounds.x : 0;
		var boundsY:Float = viewPortBounds != null ? viewPortBounds.y : 0;
		var minWidth:Float = viewPortBounds != null ? viewPortBounds.minWidth : 0;
		var minHeight:Float = viewPortBounds != null ? viewPortBounds.minHeight : 0;
		var maxWidth:Float = viewPortBounds != null ? viewPortBounds.maxWidth : Math.POSITIVE_INFINITY;
		var maxHeight:Float = viewPortBounds != null ? viewPortBounds.maxHeight : Math.POSITIVE_INFINITY;
		var explicitWidth:Float = viewPortBounds != null ? viewPortBounds.explicitWidth : Math.NaN;
		var explicitHeight:Float = viewPortBounds != null ? viewPortBounds.explicitHeight : Math.NaN;
		
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		
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
		
		var columnWidth:Float = 0;
		var item:DisplayObject;
		if (this._useVirtualLayout)
		{
			columnWidth = calculatedTypicalItemWidth;
		}
		else if (items.length != 0)
		{
			item = items[0];
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
			columnWidth = item.width;
		}
		var availableWidth:Float = explicitWidth;
		if (needsWidth)
		{
			if (maxWidth < Math.POSITIVE_INFINITY)
			{
				availableWidth = maxWidth;
			}
			else if (this._requestedColumnCount > 0)
			{
				availableWidth = ((columnWidth + this._horizontalGap) * this._requestedColumnCount) - this._horizontalGap;
			}
			else
			{
				availableWidth = columnWidth;
			}
			availableWidth += this._paddingLeft + this._paddingRight;
			if (availableWidth < minWidth)
			{
				availableWidth = minWidth;
			}
			else if (availableWidth > maxWidth)
			{
				availableWidth = maxWidth;
			}
		}
		var columnCount:Int = Std.int((availableWidth + this._horizontalGap - this._paddingLeft - this._paddingRight) / (columnWidth + this._horizontalGap));
		if (this._requestedColumnCount > 0 && columnCount > this._requestedColumnCount)
		{
			columnCount = this._requestedColumnCount;
		}
		else if (columnCount < 1)
		{
			columnCount = 1;
		}
		var columnHeights:Array<Float> = new Array<Float>();
		for (i in 0...columnCount)
		{
			columnHeights[i] = this._paddingTop;
		}
		//columnHeights.fixed = true;
		
		var horizontalAlignOffset:Float = 0;
		if (this._horizontalAlign == HorizontalAlign.RIGHT)
		{
			horizontalAlignOffset = (availableWidth - this._paddingLeft - this._paddingRight) - ((columnCount * (columnWidth + this._horizontalGap)) - this._horizontalGap);
		}
		else if (this._horizontalAlign == HorizontalAlign.CENTER)
		{
			horizontalAlignOffset = Math.round(((availableWidth - this._paddingLeft - this._paddingRight) - ((columnCount * (columnWidth + this._horizontalGap)) - this._horizontalGap)) / 2);
		}
		
		var itemCount:Int = items.length;
		var targetColumnIndex:Int = 0;
		var targetColumnHeight:Float = columnHeights[targetColumnIndex];
		var cachedHeight:Float = Math.NaN;
		var itemHeight:Float;
		var layoutItem:ILayoutDisplayObject;
		var scaleFactor:Float;
		var columnHeight:Float;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				cachedHeight = this._heightCache[i];
			}
			if (this._useVirtualLayout && item == null)
			{
				if (!this._hasVariableItemDimensions ||
					cachedHeight != cachedHeight) //isNaN
				{
					//if all items must have the same height, we will
					//use the height of the typical item (calculatedTypicalItemHeight).
					
					//if items may have different heights, we first check
					//the cache for a height value. if there isn't one, then
					//we'll use calculatedTypicalItemHeight as a fallback.
					itemHeight = calculatedTypicalItemHeight;
				}
				else
				{
					itemHeight = cachedHeight;
				}
			}
			else
			{
				if (Std.isOfType(item, ILayoutDisplayObject))
				{
					layoutItem = cast item;
					if (!layoutItem.includeInLayout)
					{
						continue;
					}
				}
				if (Std.isOfType(item, IValidating))
				{
					cast(item, IValidating).validate();
				}
				//first, scale the items to fit into the column width
				scaleFactor = columnWidth / item.width;
				item.width *= scaleFactor;
				if (Std.isOfType(item, IValidating))
				{
					//if we changed the width, we need to recalculate the
					//height.
					cast(item, IValidating).validate();
				}
				if (this._useVirtualLayout)
				{
					if (this._hasVariableItemDimensions)
					{
						itemHeight = item.height;
						if (itemHeight != cachedHeight)
						{
							//update the cache if needed. this will notify
							//the container that the virtualized layout has
							//changed, and it the view port may need to be
							//re-measured.
							this._heightCache[i] = itemHeight;
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else
					{
						item.height = itemHeight = calculatedTypicalItemHeight;
					}
				}
				else
				{
					itemHeight = item.height;
				}
			}
			targetColumnHeight += itemHeight;
			for (j in 0...columnCount)
			{
				if (j == targetColumnIndex)
				{
					continue;
				}
				columnHeight = columnHeights[j] + itemHeight;
				if (columnHeight < targetColumnHeight)
				{
					targetColumnIndex = j;
					targetColumnHeight = columnHeight;
				}
			}
			if (item != null)
			{
				item.x = item.pivotX + boundsX + horizontalAlignOffset + this._paddingLeft + targetColumnIndex * (columnWidth + this._horizontalGap);
				item.y = item.pivotY + boundsY + targetColumnHeight - itemHeight;
			}
			targetColumnHeight += this._verticalGap;
			columnHeights[targetColumnIndex] = targetColumnHeight;
		}
		var totalHeight:Float = columnHeights[0];
		for (i in 1...columnCount)
		{
			columnHeight = columnHeights[i];
			if (columnHeight > totalHeight)
			{
				totalHeight = columnHeight;
			}
		}
		totalHeight -= this._verticalGap;
		totalHeight += this._paddingBottom;
		if (totalHeight < 0)
		{
			totalHeight = 0;
		}
		
		var availableHeight:Float = explicitHeight;
		if (needsHeight)
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
		
		//finally, we want to calculate the result so that the container
		//can use it to adjust its viewport and determine the minimum and
		//maximum scroll positions (if needed)
		if (result == null)
		{
			result = new LayoutBoundsResult();
		}
		result.contentX = 0;
		result.contentWidth = availableWidth;
		result.contentY = 0;
		result.contentHeight = totalHeight;
		result.viewPortWidth = availableWidth;
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
		
		var explicitWidth:Float = viewPortBounds != null ? viewPortBounds.explicitWidth : Math.NaN;
		var explicitHeight:Float = viewPortBounds != null ? viewPortBounds.explicitHeight : Math.NaN;
		
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		if (!needsWidth && !needsHeight)
		{
			result.x = explicitWidth;
			result.y = explicitHeight;
			return result;
		}
		
		var minWidth:Float = viewPortBounds != null ? viewPortBounds.minWidth : 0;
		var minHeight:Float = viewPortBounds != null ? viewPortBounds.minHeight : 0;
		var maxWidth:Float = viewPortBounds != null ? viewPortBounds.maxWidth : Math.POSITIVE_INFINITY;
		var maxHeight:Float = viewPortBounds != null ? viewPortBounds.maxHeight : Math.POSITIVE_INFINITY;
		
		if (Std.isOfType(this._typicalItem, IValidating))
		{
			cast(this._typicalItem, IValidating).validate();
		}
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var columnWidth:Float = calculatedTypicalItemWidth;
		var availableWidth:Float = explicitWidth;
		if (needsWidth)
		{
			if (maxWidth < Math.POSITIVE_INFINITY)
			{
				availableWidth = maxWidth;
			}
			else if (this._requestedColumnCount > 0)
			{
				availableWidth = ((columnWidth + this._horizontalGap) * this._requestedColumnCount) - this._horizontalGap;
			}
			else
			{
				availableWidth = columnWidth;
			}
			availableWidth += this._paddingLeft + this._paddingRight;
			if (availableWidth < minWidth)
			{
				availableWidth = minWidth;
			}
			else if (availableWidth > maxWidth)
			{
				availableWidth = maxWidth;
			}
		}
		var columnCount:Int = Std.int((availableWidth + this._horizontalGap - this._paddingLeft - this._paddingRight) / (columnWidth + this._horizontalGap));
		if (this._requestedColumnCount > 0 && columnCount > this._requestedColumnCount)
		{
			columnCount = this._requestedColumnCount;
		}
		else if (columnCount < 1)
		{
			columnCount = 1;
		}
		
		if (needsWidth)
		{
			result.x = this._paddingLeft + this._paddingRight + (columnCount * (columnWidth + this._horizontalGap)) - this._horizontalGap;
		}
		else
		{
			result.x = explicitWidth;
		}
		
		if (needsHeight)
		{
			if (this._hasVariableItemDimensions)
			{
				var columnHeights:Array<Float> = new Array<Float>();
				for (i in 0...columnCount)
				{
					columnHeights[i] = this._paddingTop;
				}
				//columnHeights.fixed = true;
				
				var targetColumnIndex:Int = 0;
				var targetColumnHeight:Float = columnHeights[targetColumnIndex];
				var itemHeight:Float;
				var columnHeight:Float;
				for (i in 0...itemCount)
				{
					if (this._hasVariableItemDimensions)
					{
						itemHeight = this._heightCache[i];
						if (itemHeight != itemHeight) //isNaN
						{
							itemHeight = calculatedTypicalItemHeight;
						}
					}
					else
					{
						itemHeight = calculatedTypicalItemHeight;
					}
					targetColumnHeight += itemHeight;
					for (j in 0...columnCount)
					{
						if (j == targetColumnIndex)
						{
							continue;
						}
						columnHeight = columnHeights[j] + itemHeight;
						if (columnHeight < targetColumnHeight)
						{
							targetColumnIndex = j;
							targetColumnHeight = columnHeight;
						}
					}
					targetColumnHeight += this._verticalGap;
					columnHeights[targetColumnIndex] = targetColumnHeight;
				}
				var totalHeight:Float = columnHeights[0];
				for (i in 1...columnCount)
				{
					columnHeight = columnHeights[i];
					if (columnHeight > totalHeight)
					{
						totalHeight = columnHeight;
					}
				}
				totalHeight -= this._verticalGap;
				totalHeight += this._paddingBottom;
				if (totalHeight < 0)
				{
					totalHeight = 0;
				}
				if (totalHeight < minHeight)
				{
					totalHeight = minHeight;
				}
				else if (totalHeight > maxHeight)
				{
					totalHeight = maxHeight;
				}
				result.y = totalHeight;
			}
			else
			{
				result.y = this._paddingTop + this._paddingBottom + (Math.fceil(itemCount / columnCount) * (calculatedTypicalItemHeight + this._verticalGap)) - this._verticalGap;
			}
		}
		else
		{
			result.y = explicitHeight;
		}
		return result;
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
		
		var columnWidth:Float = calculatedTypicalItemWidth;
		var columnCount:Int = Std.int((width + this._horizontalGap - this._paddingLeft - this._paddingRight) / (columnWidth + this._horizontalGap));
		if (this._requestedColumnCount > 0 && columnCount > this._requestedColumnCount)
		{
			columnCount = this._requestedColumnCount;
		}
		else if (columnCount < 1)
		{
			columnCount = 1;
		}
		var resultLastIndex:Int = 0;
		if (this._hasVariableItemDimensions)
		{
			var columnHeights:Array<Float> = new Array<Float>();
			for (i in 0...columnCount)
			{
				columnHeights[i] = this._paddingTop;
			}
			//columnHeights.fixed = true;
			
			var maxPositionY:Float = scrollY + height;
			var targetColumnIndex:Int = 0;
			var targetColumnHeight:Float = columnHeights[targetColumnIndex];
			var itemHeight:Float;
			var columnHeight:Float;
			for (i in 0...itemCount)
			{
				if (this._hasVariableItemDimensions)
				{
					itemHeight = this._heightCache[i];
					if (itemHeight != itemHeight) //isNaN
					{
						itemHeight = calculatedTypicalItemHeight;
					}
				}
				else
				{
					itemHeight = calculatedTypicalItemHeight;
				}
				targetColumnHeight += itemHeight;
				for (j in 0...columnCount)
				{
					if (j == targetColumnIndex)
					{
						continue;
					}
					columnHeight = columnHeights[j] + itemHeight;
					if (columnHeight < targetColumnHeight)
					{
						targetColumnIndex = j;
						targetColumnHeight = columnHeight;
					}
				}
				if (targetColumnHeight > scrollY && (targetColumnHeight - itemHeight) < maxPositionY)
				{
					result[resultLastIndex] = i;
					resultLastIndex++;
				}
				targetColumnHeight += this._verticalGap;
				columnHeights[targetColumnIndex] = targetColumnHeight;
			}
			return result;
		}
		//this case can be optimized because we know that every item has
		//the same height
		
		//we add one extra here because the first item renderer in view may
		//be partially obscured, which would reveal an extra item renderer.
		var maxVisibleTypicalItemCount:Int = Math.ceil(height / (calculatedTypicalItemHeight + this._verticalGap)) + 1;
		//we're calculating the minimum and maximum rows
		var minimum:Int = Std.int((scrollY - this._paddingTop) / (calculatedTypicalItemHeight + this._verticalGap));
		if (minimum < 0)
		{
			minimum = 0;
		}
		//if we're scrolling beyond the final item, we should keep the
		//indices consistent so that items aren't destroyed and
		//recreated unnecessarily
		var maximum:Int = minimum + maxVisibleTypicalItemCount;
		if (maximum >= itemCount)
		{
			maximum = itemCount - 1;
		}
		minimum = maximum - maxVisibleTypicalItemCount;
		if (minimum < 0)
		{
			minimum = 0;
		}
		var index:Int;
		for (i in minimum...maximum+1)
		{
			for (j in 0...columnCount)
			{
				index = (i * columnCount) + j;
				if (index >= 0 && i < itemCount)
				{
					result[resultLastIndex] = index;
				}
				else if (index < 0)
				{
					result[resultLastIndex] = itemCount + index;
				}
				else if (index >= itemCount)
				{
					result[resultLastIndex] = index - itemCount;
				}
				resultLastIndex++;
			}
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		var maxScrollY:Float = this.calculateMaxScrollYOfIndex(index, items, x, y, width, height);
		
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
		
		var bottomPosition:Float = maxScrollY - (height - itemHeight);
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
		var maxScrollY:Float = this.calculateMaxScrollYOfIndex(index, items, x, y, width, height);
		
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
	 * @private
	 */
	private function calculateMaxScrollYOfIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float):Float
	{
		if (items.length == 0)
		{
			return 0;
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
		
		var columnWidth:Float = 0;
		var item:DisplayObject;
		if (this._useVirtualLayout)
		{
			columnWidth = calculatedTypicalItemWidth;
		}
		else if (items.length != 0)
		{
			item = items[0];
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
			columnWidth = item.width;
		}
		
		var columnCount:Int = Std.int((width + this._horizontalGap - this._paddingLeft - this._paddingRight) / (columnWidth + this._horizontalGap));
		if (this._requestedColumnCount > 0 && columnCount > this._requestedColumnCount)
		{
			columnCount = this._requestedColumnCount;
		}
		else if (columnCount < 1)
		{
			columnCount = 1;
		}
		var columnHeights:Array<Float> = new Array<Float>();
		for (i in 0...columnCount)
		{
			columnHeights[i] = this._paddingTop;
		}
		//columnHeights.fixed = true;
		
		var itemCount:Int = items.length;
		var targetColumnIndex:Int = 0;
		var targetColumnHeight:Float = columnHeights[targetColumnIndex];
		var cachedHeight:Float = Math.NaN;
		var itemHeight:Float;
		var layoutItem:ILayoutDisplayObject;
		var scaleFactor:Float;
		var columnHeight:Float;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				cachedHeight = this._heightCache[i];
			}
			if (this._useVirtualLayout && item == null)
			{
				if (!this._hasVariableItemDimensions ||
					cachedHeight != cachedHeight) //isNaN
				{
					//if all items must have the same height, we will
					//use the height of the typical item (calculatedTypicalItemHeight).
					
					//if items may have different heights, we first check
					//the cache for a height value. if there isn't one, then
					//we'll use calculatedTypicalItemHeight as a fallback.
					itemHeight = calculatedTypicalItemHeight;
				}
				else
				{
					itemHeight = cachedHeight;
				}
			}
			else
			{
				if (Std.isOfType(item, ILayoutDisplayObject))
				{
					layoutItem = cast item;
					if (!layoutItem.includeInLayout)
					{
						continue;
					}
				}
				if (Std.isOfType(item, IValidating))
				{
					cast(item, IValidating).validate();
				}
				//first, scale the items to fit into the column width
				scaleFactor = columnWidth / item.width;
				item.width *= scaleFactor;
				if (Std.isOfType(item, IValidating))
				{
					cast(item, IValidating).validate();
				}
				if (this._useVirtualLayout)
				{
					if (this._hasVariableItemDimensions)
					{
						itemHeight = item.height;
						if (itemHeight != cachedHeight)
						{
							this._heightCache[i] = itemHeight;
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else
					{
						item.height = itemHeight = calculatedTypicalItemHeight;
					}
				}
				else
				{
					itemHeight = item.height;
				}
			}
			targetColumnHeight += itemHeight;
			for (j in 0...columnCount)
			{
				if (j == targetColumnIndex)
				{
					continue;
				}
				columnHeight = columnHeights[j] + itemHeight;
				if (columnHeight < targetColumnHeight)
				{
					targetColumnIndex = j;
					targetColumnHeight = columnHeight;
				}
			}
			if (i == index)
			{
				return targetColumnHeight - itemHeight;
			}
			targetColumnHeight += this._verticalGap;
			columnHeights[targetColumnIndex] = targetColumnHeight;
		}
		var totalHeight:Float = columnHeights[0];
		for (i in 1...columnCount)
		{
			columnHeight = columnHeights[i];
			if (columnHeight > totalHeight)
			{
				totalHeight = columnHeight;
			}
		}
		totalHeight -= this._verticalGap;
		totalHeight += this._paddingBottom;
		//subtracting the height gives us the maximum scroll position
		totalHeight -= height;
		if (totalHeight < 0)
		{
			totalHeight = 0;
		}
		return totalHeight;
	}
	
}