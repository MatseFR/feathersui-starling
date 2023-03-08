/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.utils.ReverseIterator;
import feathers.utils.type.SafeCast;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import feathers.core.IFeathersControl;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * Positions items from left to right in a single row.
 *
 * @see ../../../help/horizontal-layout.html How to use HorizontalLayout with Feathers containers
 *
 * @productversion Feathers 1.0.0
 */
class HorizontalLayout extends BaseLinearLayout implements IVariableVirtualLayout implements ITrimmedVirtualLayout implements IDragDropLayout
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * If the total item width is less than the bounds, the positions of
	 * the items can be aligned horizontally, on the x-axis.
	 *
	 * <p><strong>Note:</strong> The <code>HorizontalAlign.JUSTIFY</code>
	 * constant is not supported.</p>
	 *
	 * @default feathers.layout.HorizontalAlign.LEFT
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 */
	override function get_horizontalAlign():String { return this._horizontalAlign; }
	
	/**
	 * The alignment of the items vertically, on the y-axis.
	 *
	 * <p>If the <code>verticalAlign</code> property is set to
	 * <code>feathers.layout.VerticalAlign.JUSTIFY</code>, the
	 * <code>height</code>, <code>minHeight</code>, and
	 * <code>maxHeight</code> properties of the items may be changed, and
	 * their original values ignored by the layout. In this situation, if
	 * the height needs to be constrained, the <code>height</code>,
	 * <code>minHeight</code>, or <code>maxHeight</code> properties should
	 * instead be set on the parent container that is using this layout.</p>
	 *
	 * @default feathers.layout.VerticalAlign.TOP
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see feathers.layout.VerticalAlign#JUSTIFY
	 */
	override function get_verticalAlign():String
	{
		//this is an override so that this class can have its own documentation.
		return this._verticalAlign;
	}
	
	/**
	 * Distributes the width of the view port equally to each item. If the
	 * view port width needs to be measured, the largest item's width will
	 * be used for all items, subject to any specified minimum and maximum
	 * width values.
	 *
	 * @default false
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
	 * Requests that the layout set the view port dimensions to display a
	 * specific number of columns (plus gaps and padding), if possible. If
	 * the explicit width of the view port is set, then this value will be
	 * ignored. If the view port's minimum and/or maximum width are set,
	 * the actual number of visible columns may be adjusted to meet those
	 * requirements. Set this value to <code>0</code> to display as many
	 * columns as possible.
	 *
	 * @default 0
	 *
	 * @see #maxColumnCount
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
	 * The maximum number of columns to display. If the explicit width of
	 * the view port is set or if the <code>requestedColumnCount</code> is
	 * set, then this value will be ignored. If the view port's minimum
	 * and/or maximum width are set, the actual number of visible columns
	 * may be adjusted to meet those requirements. Set this value to
	 * <code>0</code> to display as many columns as possible.
	 *
	 * @default 0
	 */
	public var maxColumnCount(get, set):Int;
	private var _maxColumnCount:Int = 0;
	private function get_maxColumnCount():Int { return this._maxColumnCount; }
	private function set_maxColumnCount(value:Int):Int
	{
		if (value < 0)
		{
			throw new RangeError("maxColumnCount requires a value >= 0");
		}
		if (this._maxColumnCount == value)
		{
			return value;
		}
		this._maxColumnCount = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._maxColumnCount;
	}
	
	/**
	 * When the scroll position is calculated for an item, an attempt will
	 * be made to align the item to this position.
	 *
	 * @default feathers.layout.HorizontalAlign.CENTER
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 */
	public var scrollPositionHorizontalAlign(get, set):String;
	private var _scrollPositionHorizontalAlign:String = HorizontalAlign.CENTER;
	private function get_scrollPositionHorizontalAlign():String { return this._scrollPositionHorizontalAlign; }
	private function set_scrollPositionHorizontalAlign(value:String):String
	{
		return this._scrollPositionHorizontalAlign = value;
	}
	
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
		var scrollX:Float = viewPortBounds != null ? viewPortBounds.scrollX : 0;
		var scrollY:Float = viewPortBounds != null ? viewPortBounds.scrollY : 0;
		var boundsX:Float = viewPortBounds != null ? viewPortBounds.x : 0;
		var boundsY:Float = viewPortBounds != null ? viewPortBounds.y : 0;
		var minWidth:Float = viewPortBounds != null ? viewPortBounds.minWidth : 0;
		var minHeight:Float = viewPortBounds != null ? viewPortBounds.minHeight : 0;
		var maxWidth:Float = viewPortBounds != null ? viewPortBounds.maxWidth : Math.POSITIVE_INFINITY;
		var maxHeight:Float = viewPortBounds != null ? viewPortBounds.maxHeight : Math.POSITIVE_INFINITY;
		var explicitWidth:Float = viewPortBounds != null ? viewPortBounds.explicitWidth : Math.NaN;
		var explicitHeight:Float = viewPortBounds != null ? viewPortBounds.explicitHeight : Math.NaN;
		
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			this.prepareTypicalItem(explicitHeight - this._paddingTop - this._paddingBottom);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var needsExplicitWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsExplicitHeight:Bool = explicitHeight != explicitHeight; //isNaN
		var distributedWidth:Float = Math.NaN;
		if (!needsExplicitWidth && this._distributeWidths)
		{
			//we need to calculate this before validateItems() because it
			//needs to be passed in there.
			distributedWidth = this.calculateDistributedWidth(items, explicitWidth, minWidth, maxWidth, false);
			if (this._useVirtualLayout)
			{
				calculatedTypicalItemWidth = distributedWidth;
			}
		}
		
		if (!this._useVirtualLayout || this._hasVariableItemDimensions || this._distributeWidths ||
			this._verticalAlign != VerticalAlign.JUSTIFY ||
			needsExplicitHeight) //isNaN
		{
			//in some cases, we may need to validate all of the items so
			//that we can use their dimensions below.
			this.validateItems(items, explicitHeight - this._paddingTop - this._paddingBottom,
				minHeight - this._paddingTop - this._paddingBottom,
				maxHeight - this._paddingTop - this._paddingBottom,
				explicitWidth - this._paddingLeft - this._paddingRight,
				minWidth - this._paddingLeft - this._paddingRight,
				maxWidth - this._paddingLeft - this._paddingRight, distributedWidth);
		}
		
		if (needsExplicitWidth && this._distributeWidths)
		{
			//if we didn't calculate this before, we need to do it now.
			distributedWidth = this.calculateDistributedWidth(items, explicitWidth, minWidth, maxWidth, true);
		}
		var hasDistributedWidth:Bool = distributedWidth == distributedWidth; //!isNaN
		
		if (!this._useVirtualLayout)
		{
			//handle the percentWidth property from HorizontalLayoutData,
			//if available.
			this.applyPercentWidths(items, explicitWidth, minWidth, maxWidth);
		}
		
		//this section prepares some variables needed for the following loop
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var maxItemHeight:Float = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
		var positionX:Float = boundsX + this._paddingLeft;
		var itemCount:Int = items.length;
		var totalItemCount:Int = itemCount;
		var requestedColumnAvailableWidth:Float = 0;
		var maxColumnAvailableWidth:Float = Math.POSITIVE_INFINITY;
		if (this._useVirtualLayout && !this._hasVariableItemDimensions)
		{
			//if the layout is virtualized, and the items all have the same
			//width, we can make our loops smaller by skipping some items
			//at the beginning and end. this improves performance.
			totalItemCount += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
			positionX += (this._beforeVirtualizedItemCount * (calculatedTypicalItemWidth + this._gap));
			if (hasFirstGap && this._beforeVirtualizedItemCount > 0)
			{
				positionX = positionX - this._gap + this._firstGap;
			}
		}
		var secondToLastIndex:Int = totalItemCount - 2;
		//this cache is used to save non-null items in virtual layouts. by
		//using a smaller array, we can improve performance by spending less
		//time in the upcoming loops.
		this._discoveredItemsCache.resize(0);
		var discoveredItemsCacheLastIndex:Int = 0;
		
		//if there are no items in layout, then we don't want to subtract
		//any gap when calculating the total width, so default to 0.
		var gap:Float = 0;
		
		var cachedWidth:Float = Math.NaN;
		var item:DisplayObject;
		var iNormalized:Int;
		var layoutItem:ILayoutDisplayObject;
		var pivotX:Float;
		var itemWidth:Float;
		var itemHeight:Float;
		//this first loop sets the x position of items, and it calculates
		//the total width of all items
		for (i in 0...itemCount)
		{
			if (!this._useVirtualLayout)
			{
				if (this._maxColumnCount > 0 && this._maxColumnCount == i)
				{
					maxColumnAvailableWidth = positionX;
				}
				if (this._requestedColumnCount > 0 && this._requestedColumnCount == i)
				{
					requestedColumnAvailableWidth = positionX;
				}
			}
			item = items[i];
			//if we're trimming some items at the beginning, we need to
			//adjust i to account for the missing items in the array
			iNormalized = i + this._beforeVirtualizedItemCount;
			
			//pick the gap that will follow this item. the first and second
			//to last items may have different gaps.
			gap = this._gap;
			if (hasFirstGap && iNormalized == 0)
			{
				gap = this._firstGap;
			}
			else if (hasLastGap && iNormalized > 0 && iNormalized == secondToLastIndex)
			{
				gap = this._lastGap;
			}
				
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				cachedWidth = iNormalized < this._virtualCache.length ? this._virtualCache[iNormalized] : Math.NaN;
			}
			if (this._useVirtualLayout && item == null)
			{
				//the item is null, and the layout is virtualized, so we
				//need to estimate the width of the item.
				
				if (!this._hasVariableItemDimensions ||
					cachedWidth != cachedWidth) //isNaN
				{
					//if all items must have the same width, we will
					//use the width of the typical item (calculatedTypicalItemWidth).
					
					//if items may have different widths, we first check
					//the cache for a width value. if there isn't one, then
					//we'll use calculatedTypicalItemWidth as a fallback.
					positionX += calculatedTypicalItemWidth + gap;
				}
				else
				{
					//if we have variable item widths, we should use a
					//cached width when there's one available. it will be
					//more accurate than the typical item's width.
					positionX += cachedWidth + gap;
				}
			}
			else
			{
				//we get here if the item isn't null. it is never null if
				//the layout isn't virtualized.
				layoutItem = SafeCast.safe_cast(item, ILayoutDisplayObject);
				if (layoutItem != null && !layoutItem.includeInLayout)
				{
					continue;
				}
				pivotX = item.pivotX;
				if (pivotX != 0)
				{
					pivotX *= item.scaleX;
				}
				item.x = pivotX + positionX;
				
				if (hasDistributedWidth)
				{
					item.width = itemWidth = distributedWidth;
				}
				else
				{
					itemWidth = item.width;
				}
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
							this._virtualCache[iNormalized] = itemWidth;
							
							//attempt to adjust the scroll position so that
							//it looks like we're scrolling smoothly after
							//this item resizes.
							if (positionX < scrollX &&
								cachedWidth != cachedWidth && //isNaN
								itemWidth != calculatedTypicalItemWidth)
							{
								this.dispatchEventWith(Event.SCROLL, false, new Point(itemWidth - calculatedTypicalItemWidth, 0));
							}
							
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else if (calculatedTypicalItemWidth >= 0)
					{
						//if all items must have the same width, we will
						//use the width of the typical item (calculatedTypicalItemWidth).
						itemWidth = calculatedTypicalItemWidth;
						if (item != this._typicalItem || item.width != itemWidth)
						{
							//ensure that the typical item's width is not
							//set explicitly so that it can resize
							item.width = itemWidth;
						}
					}
				}
				positionX += itemWidth + gap;
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
				if (this._useVirtualLayout)
				{
					this._discoveredItemsCache[discoveredItemsCacheLastIndex] = item;
					discoveredItemsCacheLastIndex++;
				}
			}
		}
		if (this._useVirtualLayout && !this._hasVariableItemDimensions)
		{
			//finish the final calculation of the x position so that it can
			//be used for the total width of all items
			positionX += (this._afterVirtualizedItemCount * (calculatedTypicalItemWidth + this._gap));
			if (hasLastGap && this._afterVirtualizedItemCount > 0)
			{
				positionX = positionX - this._gap + this._lastGap;
			}
		}
		if (!this._useVirtualLayout && this._requestedColumnCount > itemCount)
		{
			if (itemCount > 0)
			{
				requestedColumnAvailableWidth = this._requestedColumnCount * positionX / itemCount;
			}
			else
			{
				requestedColumnAvailableWidth = 0;
			}
		}
		
		//this array will contain all items that are not null. see the
		//comment above where the discoveredItemsCache is initialized for
		//details about why this is important.
		var discoveredItems:Array<DisplayObject> = this._useVirtualLayout ? this._discoveredItemsCache : items;
		var discoveredItemCount:Int = discoveredItems.length;
		
		var totalHeight:Float = maxItemHeight + this._paddingTop + this._paddingBottom;
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
		
		//this is the total width of all items
		var totalWidth:Float = positionX - gap + this._paddingRight - boundsX;
		//the available width is the width of the viewport. if the explicit
		//width is NaN, we need to calculate the viewport width ourselves
		//based on the total width of all items.
		var availableWidth:Float = explicitWidth;
		if (availableWidth != availableWidth) //isNaN
		{
			if (this._requestedColumnCount > 0)
			{
				if (this._useVirtualLayout)
				{
					availableWidth = (calculatedTypicalItemWidth + this._gap) * this._requestedColumnCount - this._gap + this._paddingLeft + this._paddingRight;
				}
				else
				{
					availableWidth = requestedColumnAvailableWidth;
				}
			}
			else
			{
				availableWidth = totalWidth;
				if (this._maxColumnCount > 0)
				{
					if (this._useVirtualLayout)
					{
						maxColumnAvailableWidth = (calculatedTypicalItemWidth + this._gap) * this._maxColumnCount - this._gap + this._paddingLeft + this._paddingRight;
					}
					if (maxColumnAvailableWidth < availableWidth)
					{
						availableWidth = maxColumnAvailableWidth;
					}
				}
			}
			if (availableWidth < minWidth)
			{
				availableWidth = minWidth;
			}
			else if (availableWidth > maxWidth)
			{
				availableWidth = maxWidth;
			}
		}
		
		//in this section, we handle horizontal alignment. items will be
		//aligned horizontally if the total width of all items is less than
		//the available width of the view port.
		if (totalWidth < availableWidth)
		{
			var horizontalAlignOffsetX:Float = 0;
			if (this._horizontalAlign == HorizontalAlign.RIGHT)
			{
				horizontalAlignOffsetX = availableWidth - totalWidth;
			}
			else if (this._horizontalAlign == HorizontalAlign.CENTER)
			{
				horizontalAlignOffsetX = Math.fround((availableWidth - totalWidth) / 2);
			}
			if (horizontalAlignOffsetX != 0)
			{
				for (i in 0...discoveredItemCount)
				{
					item = discoveredItems[i];
					if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
					{
						continue;
					}
					item.x += horizontalAlignOffsetX;
				}
			}
		}
		
		var availableHeightMinusPadding:Float = availableHeight - this._paddingTop - this._paddingBottom;
		for (i in 0...discoveredItemCount)
		{
			item = discoveredItems[i];
			layoutItem = SafeCast.safe_cast(item, ILayoutDisplayObject);
			if (layoutItem != null && !layoutItem.includeInLayout)
			{
				continue;
			}
			
			var pivotY:Float = item.pivotY;
			if (pivotY != 0)
			{
				pivotY *= item.scaleY;
			}
			
			//in this section, we handle vertical alignment and percent
			//height from HorizontalLayoutData
			if (this._verticalAlign == VerticalAlign.JUSTIFY)
			{
				//if we justify items vertically, we can skip percent height
				item.y = pivotY + boundsY + this._paddingTop;
				item.height = availableHeightMinusPadding;
			}
			else
			{
				if (layoutItem != null)
				{
					var layoutData:HorizontalLayoutData = cast layoutItem.layoutData;
					if (layoutData != null)
					{
						//in this section, we handle percentage width if
						//VerticalLayoutData is available.
						var percentHeight:Float = layoutData.percentHeight;
						if (percentHeight == percentHeight) //!isNaN
						{
							if (percentHeight < 0)
							{
								percentHeight = 0;
							}
							if (percentHeight > 100)
							{
								percentHeight = 100;
							}
							itemHeight = percentHeight * availableHeightMinusPadding / 100;
							if (Std.isOfType(item, IFeathersControl))
							{
								var feathersItem:IFeathersControl = cast item;
								var itemMinHeight:Float = feathersItem.explicitMinHeight;
								//we try to respect the minWidth, but not
								//when it's larger than 100%
								if (itemMinHeight > availableHeightMinusPadding)
								{
									itemMinHeight = availableHeightMinusPadding;
								}
								if (itemHeight < itemMinHeight)
								{
									itemHeight = itemMinHeight;
								}
								else
								{
									var itemMaxHeight:Float = feathersItem.explicitMaxHeight;
									if (itemHeight > itemMaxHeight)
									{
										itemHeight = itemMaxHeight;
									}
								}
							}
							item.height = itemHeight;
						}
					}
				}
				//handle all other vertical alignment values (we handled
				//justify already). the y position of all items is set here.
				var verticalAlignHeight:Float = availableHeight;
				if (totalHeight > verticalAlignHeight)
				{
					verticalAlignHeight = totalHeight;
				}
				switch (this._verticalAlign)
				{
					case VerticalAlign.BOTTOM:
						item.y = pivotY + boundsY + verticalAlignHeight - this._paddingBottom - item.height;
					
					case VerticalAlign.MIDDLE:
						item.y = pivotY + boundsY + this._paddingTop + Math.fround((verticalAlignHeight - this._paddingTop - this._paddingBottom - item.height) / 2);
					
					default: //top
						item.y = pivotY + boundsY + this._paddingTop;
					
				}
			}
		}
		//we don't want to keep a reference to any of the items, so clear
		//this cache
		this._discoveredItemsCache.resize(0);
		
		//finally, we want to calculate the result so that the container
		//can use it to adjust its viewport and determine the minimum and
		//maximum scroll positions (if needed)
		if (result == null)
		{
			result = new LayoutBoundsResult();
		}
		result.contentX = 0;
		result.contentWidth = totalWidth;
		result.contentY = 0;
		result.contentHeight = this._verticalAlign == VerticalAlign.JUSTIFY ? availableHeight : totalHeight;
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
		
		this.prepareTypicalItem(explicitHeight - this._paddingTop - this._paddingBottom);
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var positionX:Float;
		var maxItemHeight:Float = 0;
		var cachedWidth:Float;
		if (this._distributeWidths)
		{
			positionX = (calculatedTypicalItemWidth + this._gap) * itemCount;
		}
		else
		{
			positionX = 0;
			maxItemHeight = calculatedTypicalItemHeight;
			if (!this._hasVariableItemDimensions)
			{
				positionX += ((calculatedTypicalItemWidth + this._gap) * itemCount);
			}
			else
			{
				for (i in 0...itemCount)
				{
					cachedWidth = i < this._virtualCache.length ? this._virtualCache[i] : Math.NaN;
					if (cachedWidth != cachedWidth) //isNaN
					{
						positionX += calculatedTypicalItemWidth + this._gap;
					}
					else
					{
						positionX += cachedWidth + this._gap;
					}
				}
			}
		}
		positionX -= this._gap;
		if (hasFirstGap && itemCount > 1)
		{
			positionX = positionX - this._gap + this._firstGap;
		}
		if (hasLastGap && itemCount > 2)
		{
			positionX = positionX - this._gap + this._lastGap;
		}
		
		if (needsWidth)
		{
			var resultWidth:Float;
			if (this._requestedColumnCount > 0)
			{
				resultWidth = (calculatedTypicalItemWidth + this._gap) * this._requestedColumnCount - this._gap + this._paddingLeft + this._paddingRight;
			}
			else
			{
				resultWidth = positionX + this._paddingLeft + this._paddingRight;
				if (this._maxColumnCount > 0)
				{
					var maxColumnResultWidth:Float = (calculatedTypicalItemWidth + this._gap) * this._maxColumnCount - this._gap + this._paddingLeft + this._paddingRight;
					if (maxColumnResultWidth < resultWidth)
					{
						resultWidth = maxColumnResultWidth;
					}
				}
			}
			if (resultWidth < minWidth)
			{
				resultWidth = minWidth;
			}
			else if (resultWidth > maxWidth)
			{
				resultWidth = maxWidth;
			}
			result.x = resultWidth;
		}
		else
		{
			result.x = explicitWidth;
		}
		
		if (needsHeight)
		{
			var resultHeight:Float = maxItemHeight + this._paddingTop + this._paddingBottom;
			if (resultHeight < minHeight)
			{
				resultHeight = minHeight;
			}
			else if (resultHeight > maxHeight)
			{
				resultHeight = maxHeight;
			}
			result.y = resultHeight;
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
		
		this.prepareTypicalItem(height - this._paddingTop - this._paddingBottom);
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var resultLastIndex:Int = 0;
		//we add one extra here because the first item renderer in view may
		//be partially obscured, which would reveal an extra item renderer.
		var maxVisibleTypicalItemCount:Int = Math.ceil(width / (calculatedTypicalItemWidth + this._gap)) + 1;
		if (!this._hasVariableItemDimensions)
		{
			//this case can be optimized because we know that every item has
			//the same width
			var totalItemWidth:Float = itemCount * (calculatedTypicalItemWidth + this._gap) - this._gap;
			if (hasFirstGap && itemCount > 1)
			{
				totalItemWidth = totalItemWidth - this._gap + this._firstGap;
			}
			if (hasLastGap && itemCount > 2)
			{
				totalItemWidth = totalItemWidth - this._gap + this._lastGap;
			}
			var indexOffset:Int = 0;
			if (totalItemWidth < width)
			{
				if (this._horizontalAlign == HorizontalAlign.RIGHT)
				{
					indexOffset = Math.ceil((width - totalItemWidth) / (calculatedTypicalItemWidth + this._gap));
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					indexOffset = Math.ceil(((width - totalItemWidth) / (calculatedTypicalItemWidth + this._gap)) / 2);
				}
			}
			var minimum:Int = Std.int((scrollX - this._paddingLeft) / (calculatedTypicalItemWidth + this._gap));
			if (minimum < 0)
			{
				minimum = 0;
			}
			minimum -= indexOffset;
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
			for (i in minimum...maximum+1)
			{
				if (i >= 0 && i < itemCount)
				{
					result[resultLastIndex] = i;
				}
				else if (i < 0)
				{
					result[resultLastIndex] = itemCount + i;
				}
				else if (i >= itemCount)
				{
					result[resultLastIndex] = i - itemCount;
				}
				resultLastIndex++;
			}
			return result;
		}
		var secondToLastIndex:Int = itemCount - 2;
		var maxPositionX:Float = scrollX + width;
		var positionX:Float = this._paddingLeft;
		var gap:Float;
		var cachedWidth:Float;
		var itemWidth:Float;
		var oldPositionX:Float;
		for (i in 0...itemCount)
		{
			gap = this._gap;
			if (hasFirstGap && i == 0)
			{
				gap = this._firstGap;
			}
			else if (hasLastGap && i > 0 && i == secondToLastIndex)
			{
				gap = this._lastGap;
			}
			cachedWidth = i < this._virtualCache.length ? this._virtualCache[i] : Math.NaN;
			if (cachedWidth != cachedWidth) //isNaN
			{
				itemWidth = calculatedTypicalItemWidth;
			}
			else
			{
				itemWidth = cachedWidth;
			}
			oldPositionX = positionX;
			positionX += itemWidth + gap;
			if (positionX > scrollX && oldPositionX < maxPositionX)
			{
				result[resultLastIndex] = i;
				resultLastIndex++;
			}
			
			if (positionX >= maxPositionX)
			{
				break;
			}
		}
		
		//similar to above, in order to avoid costly destruction and
		//creation of item renderers, we're going to fill in some extra
		//indices
		var resultLength:Int = result.length;
		var visibleItemCountDifference:Int = maxVisibleTypicalItemCount - resultLength;
		if (visibleItemCountDifference > 0 && resultLength > 0)
		{
			//add extra items before the first index
			var firstExistingIndex:Int = result[0];
			var lastIndexToAdd:Int = firstExistingIndex - visibleItemCountDifference;
			if (lastIndexToAdd < 0)
			{
				lastIndexToAdd = 0;
			}
			//for (i = firstExistingIndex - 1; i >= lastIndexToAdd; i--)
			for (i in new ReverseIterator(firstExistingIndex - 1, lastIndexToAdd))
			{
				result.insert(0, i);
			}
		}
		resultLength = result.length;
		resultLastIndex = resultLength;
		visibleItemCountDifference = maxVisibleTypicalItemCount - resultLength;
		if (visibleItemCountDifference > 0)
		{
			//add extra items after the last index
			var startIndex:Int = resultLength > 0 ? (result[resultLength - 1] + 1) : 0;
			var endIndex:Int = startIndex + visibleItemCountDifference;
			if (endIndex > itemCount)
			{
				endIndex = itemCount;
			}
			//for (i = startIndex; i < endIndex; i++)
			for (i in startIndex...endIndex)
			{
				result[resultLastIndex] = i;
				resultLastIndex++;
			}
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		var maxScrollX:Float = this.calculateMaxScrollXOfIndex(index, items, x, y, width, height);
		var itemWidth:Float;
		
		if (this._useVirtualLayout)
		{
			if (this._hasVariableItemDimensions)
			{
				itemWidth = index < this._virtualCache.length ? this._virtualCache[index] : Math.NaN;
				if (itemWidth != itemWidth) //isNaN
				{
					itemWidth = this._typicalItem.width;
				}
			}
			else
			{
				itemWidth = this._typicalItem.width;
			}
		}
		else
		{
			itemWidth = items[index].width;
		}
		
		if (result == null)
		{
			result = new Point();
		}
		
		var rightPosition:Float = maxScrollX - (width - itemWidth);
		if (scrollX >= rightPosition && scrollX <= maxScrollX)
		{
			//keep the current scroll position because the item is already
			//fully visible
			result.x = scrollX;
		}
		else
		{
			var leftDifference:Float = Math.abs(maxScrollX - scrollX);
			var rightDifference:Float = Math.abs(rightPosition - scrollX);
			if (rightDifference < leftDifference)
			{
				result.x = rightPosition;
			}
			else
			{
				result.x = maxScrollX;
			}
		}
		result.y = 0;
		
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function calculateNavigationDestination(items:Array<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int
	{
		var calculatedTypicalItemWidth:Float = 0;
		var itemArrayCount:Int = items.length;
		var itemCount:Int = itemArrayCount + this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			this.prepareTypicalItem(bounds.viewPortHeight - this._paddingTop - this._paddingBottom);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
		}
		
		var result:Int = index;
		var xPosition:Float;
		var indexOffset:Int;
		var cachedWidth:Float = Math.NaN;
		var iNormalized:Int;
		var item:DisplayObject;
		if (keyCode == Keyboard.HOME)
		{
			if (itemCount > 0)
			{
				result = 0;
			}
		}
		else if (keyCode == Keyboard.END)
		{
			result = itemCount - 1;
		}
		else if (keyCode == Keyboard.PAGE_UP)
		{
			xPosition = 0;
			indexOffset = 0;
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				indexOffset = -this._beforeVirtualizedItemCount;
			}
			
			//for(var i:int = index; i >= 0; i--)
			for (i in new ReverseIterator(index, 0))
			{
				iNormalized = i + indexOffset;
				if (this._useVirtualLayout && this._hasVariableItemDimensions)
				{
					cachedWidth = i < this._virtualCache.length ? this._virtualCache[i] : Math.NaN;
				}
				if (iNormalized < 0 || iNormalized >= itemArrayCount)
				{
					if (cachedWidth == cachedWidth) //!isNaN
					{
						xPosition += cachedWidth;
					}
					else
					{
						xPosition += calculatedTypicalItemWidth;
					}
				}
				else
				{
					item = items[iNormalized];
					if (item == null)
					{
						if (cachedWidth == cachedWidth) //!isNaN
						{
							xPosition += cachedWidth;
						}
						else
						{
							xPosition += calculatedTypicalItemWidth;
						}
					}
					else
					{
						xPosition += item.width;
					}
				}
				if (xPosition > bounds.viewPortWidth)
				{
					break;
				}
				xPosition += this._gap;
				result = i;
			}
		}
		else if (keyCode == Keyboard.PAGE_DOWN)
		{
			xPosition = 0;
			indexOffset = 0;
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				indexOffset = -this._beforeVirtualizedItemCount;
			}
			for (i in index...itemCount)
			{
				iNormalized = i + indexOffset;
				if (this._useVirtualLayout && this._hasVariableItemDimensions)
				{
					cachedWidth = i < this._virtualCache.length ? this._virtualCache[i] : Math.NaN;
				}
				if (iNormalized < 0 || iNormalized >= itemArrayCount)
				{
					if (cachedWidth == cachedWidth) //!isNaN
					{
						xPosition += cachedWidth;
					}
					else
					{
						xPosition += calculatedTypicalItemWidth;
					}
				}
				else
				{
					item = items[iNormalized];
					if (item == null)
					{
						if (cachedWidth == cachedWidth) //!isNaN
						{
							xPosition += cachedWidth;
						}
						else
						{
							xPosition += calculatedTypicalItemWidth;
						}
					}
					else
					{
						xPosition += item.width;
					}
				}
				if (xPosition > bounds.viewPortWidth)
				{
					break;
				}
				xPosition += this._gap;
				result = i;
			}
		}
		else if (keyCode == Keyboard.LEFT)
		{
			result--;
		}
		else if (keyCode == Keyboard.RIGHT)
		{
			result++;
		}
		if (result < 0)
		{
			return 0;
		}
		if (result >= itemCount)
		{
			return itemCount - 1;
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		var itemWidth:Float;
		var maxScrollX:Float = this.calculateMaxScrollXOfIndex(index, items, x, y, width, height);
		if (this._useVirtualLayout)
		{
			if (this._hasVariableItemDimensions)
			{
				itemWidth = index < this._virtualCache.length ? this._virtualCache[index] : Math.NaN;
				if (itemWidth != itemWidth) //isNaN
				{
					itemWidth = this._typicalItem.width;
				}
			}
			else
			{
				itemWidth = this._typicalItem.width;
			}
		}
		else
		{
			itemWidth = items[index].width;
		}
		if (this._scrollPositionHorizontalAlign == HorizontalAlign.CENTER)
		{
			maxScrollX -= Math.fround((width - itemWidth) / 2);
		}
		else if (this._scrollPositionHorizontalAlign == HorizontalAlign.RIGHT)
		{
			maxScrollX -= (width - itemWidth);
		}
		result.x = maxScrollX;
		result.y = 0;
		
		return result;
	}
	
	/**
	 * @private
	 */
	public function positionDropIndicator(dropIndicator:DisplayObject, index:Int,
		x:Float, y:Float, items:Array<DisplayObject>, width:Float, height:Float):Void
	{
		var indexOffset:Int = 0;
		var itemCount:Int = items.length;
		var totalItemCount:Int = itemCount;
		if (this._useVirtualLayout && !this._hasVariableItemDimensions)
		{
			//if the layout is virtualized, and the items all have the same
			//height, we can make our loops smaller by skipping some items
			//at the beginning and end. this improves performance.
			totalItemCount += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
			indexOffset = this._beforeVirtualizedItemCount;
		}
		var indexMinusOffset:Int = index - indexOffset;
		
		if (Std.isOfType(dropIndicator, IValidating))
		{
			cast(dropIndicator, IValidating).validate();
		}
		
		dropIndicator.y = this._paddingTop;
		var xPosition:Float = 0;
		var item:DisplayObject;
		if (index < totalItemCount)
		{
			item = items[indexMinusOffset];
			xPosition = item.x - dropIndicator.width / 2;
			dropIndicator.y = item.y;
			dropIndicator.height = item.height;
		}
		else //after the last item
		{
			item = items[indexMinusOffset - 1];
			xPosition = item.x + item.width - dropIndicator.width;
			dropIndicator.y = item.y;
			dropIndicator.height = item.height;
		}
		if (xPosition < 0)
		{
			xPosition = 0;
		}
		dropIndicator.x = xPosition;
	}
	
	/**
	 * @private
	 */
	public function getDropIndex(x:Float, y:Float, items:Array<DisplayObject>,
		boundsX:Float, boundsY:Float, width:Float, height:Float):Int
	{
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float;
		if (this._useVirtualLayout)
		{
			this.prepareTypicalItem(height - this._paddingTop - this._paddingBottom);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var positionX:Float = boundsX + this._paddingLeft;
		var lastWidth:Float = 0;
		var gap:Float = this._gap;
		var indexOffset:Int = 0;
		var itemCount:Int = items.length;
		var totalItemCount:Int = itemCount;
		if (this._useVirtualLayout && !this._hasVariableItemDimensions)
		{
			totalItemCount += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
			indexOffset = this._beforeVirtualizedItemCount;
		}
		var secondToLastIndex:Int = totalItemCount - 2;
		var item:DisplayObject;
		var cachedWidth:Float = Math.NaN;
		var itemWidth:Float;
		var indexMinusOffset:Int;
		for (i in 0...totalItemCount+1)
		{
			item = null;
			indexMinusOffset = i - indexOffset;
			if (indexMinusOffset >= 0 && indexMinusOffset < itemCount)
			{
				item = items[indexMinusOffset];
			}
			if (hasFirstGap && i == 0)
			{
				gap = this._firstGap;
			}
			else if (hasLastGap && i > 0 && i == secondToLastIndex)
			{
				gap = this._lastGap;
			}
			else
			{
				gap = this._gap;
			}
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				cachedWidth = i < this._virtualCache.length ? this._virtualCache[i] : Math.NaN;
			}
			if (this._useVirtualLayout && item == null)
			{
				if (!this._hasVariableItemDimensions ||
					cachedWidth != cachedWidth) //isNaN
				{
					lastWidth = calculatedTypicalItemWidth;
				}
				else
				{
					lastWidth = cachedWidth;
				}
			}
			else
			{
				//use the x position of the item to account for horizontal
				//alignment, in case the total width of the items is less
				//than the width of the container
				positionX = item.x;
				itemWidth = item.width;
				if (this._useVirtualLayout)
				{
					if (this._hasVariableItemDimensions)
					{
						if (itemWidth != cachedWidth)
						{
							this._virtualCache[i] = itemWidth;
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else if (calculatedTypicalItemWidth >= 0)
					{
						itemWidth = calculatedTypicalItemWidth;
					}
				}
				lastWidth = itemWidth;
			}
			if (x < (positionX + (lastWidth / 2)))
			{
				return i;
			}
			positionX += lastWidth + gap;
		}
		return totalItemCount;
	}
	
	/**
	 * @private
	 */
	private function validateItems(items:Array<DisplayObject>,
		explicitHeight:Float, minHeight:Float, maxHeight:Float,
		explicitWidth:Float, minWidth:Float, maxWidth:Float, distributedWidth:Float):Void
	{
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		var containerWidth:Float = explicitWidth;
		if (needsWidth)
		{
			containerWidth = minWidth;
		}
		//if the alignment is justified, then we want to set the height of
		//each item before validating because setting one dimension may
		//cause the other dimension to change, and that will invalidate the
		//layout if it happens after validation, causing more invalidation
		var isJustified:Bool = this._verticalAlign == VerticalAlign.JUSTIFY;
		var itemCount:Int = items.length;
		var measureItem:IMeasureDisplayObject;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = items[i];
			if (item == null || (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout))
			{
				continue;
			}
			if (this._distributeWidths)
			{
				item.width = distributedWidth;
			}
			if (isJustified)
			{
				//the alignment is justified, but we don't yet have a width
				//to use, so we need to ensure that we accurately measure
				//the items instead of using an old justified height that
				//may be wrong now!
				item.height = explicitHeight;
				if (Std.isOfType(item, IFeathersControl))
				{
					var feathersItem:IFeathersControl = cast item;
					feathersItem.minHeight = minHeight;
					feathersItem.maxHeight = maxHeight;
				}
			}
			else if (Std.isOfType(item, ILayoutDisplayObject))
			{
				var layoutItem:ILayoutDisplayObject = cast item;
				var layoutData:HorizontalLayoutData = cast layoutItem.layoutData;
				if (layoutData != null)
				{
					var percentWidth:Float = layoutData.percentWidth;
					var percentHeight:Float = layoutData.percentHeight;
					if (percentWidth == percentWidth) //!isNaN
					{
						if (percentWidth < 0)
						{
							percentWidth = 0;
						}
						if (percentWidth > 100)
						{
							percentWidth = 100;
						}
						var itemWidth:Float = containerWidth * percentWidth / 100;
						measureItem = cast item;
						var itemExplicitMinWidth:Float = measureItem.explicitMinWidth;
						if (measureItem.explicitMinWidth == measureItem.explicitMinWidth && //!isNaN
							itemWidth < itemExplicitMinWidth)
						{
							itemWidth = itemExplicitMinWidth;
						}
						//validating this component may be expensive if we
						//don't limit the width! we want to ensure that a
						//component like a horizontal list with many item
						//renderers doesn't completely bypass layout
						//virtualization, so we limit the width to the
						//maximum possible value if it were the only item in
						//the layout.
						//this doesn't need to be perfectly accurate because
						//it's just a maximum
						measureItem.maxWidth = itemWidth;
						//we also need to clear the explicit width because,
						//for many components, it will affect the minWidth
						//which is used in the final calculation
						item.width = Math.NaN;
					}
					if (percentHeight == percentHeight) //!isNaN
					{
						if (percentHeight < 0)
						{
							percentHeight = 0;
						}
						if (percentHeight > 100)
						{
							percentHeight = 100;
						}
						var itemHeight:Float = explicitHeight * percentHeight / 100;
						measureItem = cast item;
						//we use the explicitMinHeight to make an accurate
						//measurement, and we'll use the component's
						//measured minHeight later, after we validate it.
						var itemExplicitMinHeight:Float = measureItem.explicitMinHeight;
						if (measureItem.explicitMinHeight == measureItem.explicitMinHeight && //!isNaN
							itemHeight < itemExplicitMinHeight)
						{
							itemHeight = itemExplicitMinHeight;
						}
						if (itemHeight > maxHeight)
						{
							itemHeight = maxHeight;
						}
						//unlike above, where we set maxWidth, we can set
						//the height explicitly here
						//in fact, it's required because we need to make
						//an accurate measurement of the total view port
						//height
						item.height = itemHeight;
						//if itemWidth is NaN, we need to set a maximum
						//width instead. this is important for items where
						//the height becomes larger when their width becomes
						//smaller (such as word-wrapped text)
						if (measureItem.explicitHeight != measureItem.explicitHeight && //isNaN
							measureItem.maxHeight > maxHeight)
						{
							measureItem.maxHeight = maxHeight;
						}
					}
				}
			}
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function prepareTypicalItem(justifyHeight:Float):Void
	{
		if (this._typicalItem == null)
		{
			return;
		}
		if (this._resetTypicalItemDimensionsOnMeasure)
		{
			this._typicalItem.width = this._typicalItemWidth;
		}
		var hasSetHeight:Bool = false;
		if (this._verticalAlign == VerticalAlign.JUSTIFY &&
			justifyHeight == justifyHeight) //!isNaN
		{
			hasSetHeight = true;
			this._typicalItem.height = justifyHeight;
		}
		else if (Std.isOfType(this._typicalItem, ILayoutDisplayObject))
		{
			var layoutItem:ILayoutDisplayObject = cast this._typicalItem;
			var layoutData:VerticalLayoutData = cast layoutItem.layoutData;
			if (layoutData != null)
			{
				var percentHeight:Float = layoutData.percentHeight;
				if (percentHeight == percentHeight) //!isNaN
				{
					if (percentHeight < 0)
					{
						percentHeight = 0;
					}
					if (percentHeight > 100)
					{
						percentHeight = 100;
					}
					hasSetHeight = true;
					this._typicalItem.height = justifyHeight * percentHeight / 100;
				}
			}
		}
		if (!hasSetHeight && this._resetTypicalItemDimensionsOnMeasure)
		{
			this._typicalItem.height = this._typicalItemHeight;
		}
		if (Std.isOfType(this._typicalItem, IValidating))
		{
			cast(this._typicalItem, IValidating).validate();
		}
	}
	
	/**
	 * @private
	 */
	private function calculateDistributedWidth(items:Array<DisplayObject>, explicitWidth:Float, minWidth:Float, maxWidth:Float, measureItems:Bool):Float
	{
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var maxItemWidth:Float = 0;
		var includedItemCount:Int = 0;
		var itemCount:Int = items.length;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
			}
			includedItemCount++;
			var itemWidth:Float = item.width;
			if (itemWidth > maxItemWidth)
			{
				maxItemWidth = itemWidth;
			}
		}
		if (measureItems && needsWidth)
		{
			explicitWidth = maxItemWidth * includedItemCount + this._paddingLeft + this._paddingRight + this._gap * (includedItemCount - 1);
			var needsRecalculation:Bool = false;
			if (explicitWidth > maxWidth)
			{
				explicitWidth = maxWidth;
				needsRecalculation = true;
			}
			else if (explicitWidth < minWidth)
			{
				explicitWidth = minWidth;
				needsRecalculation = true;
			}
			if (!needsRecalculation)
			{
				return maxItemWidth;
			}
		}
		var availableSpace:Float = explicitWidth;
		if (needsWidth && maxWidth < Math.POSITIVE_INFINITY)
		{
			availableSpace = maxWidth;
		}
		availableSpace = availableSpace - this._paddingLeft - this._paddingRight - this._gap * (includedItemCount - 1);
		if (includedItemCount > 1 && this._firstGap == this._firstGap) //!isNaN
		{
			availableSpace += this._gap - this._firstGap;
		}
		if (includedItemCount > 2 && this._lastGap == this._lastGap) //!isNaN
		{
			availableSpace += this._gap - this._lastGap;
		}
		return availableSpace / includedItemCount;
	}
	
	/**
	 * @private
	 */
	private function applyPercentWidths(items:Array<DisplayObject>, explicitWidth:Float, minWidth:Float, maxWidth:Float):Void
	{
		var remainingWidth:Float = explicitWidth;
		this._discoveredItemsCache.resize(0);
		var totalExplicitWidth:Float = 0;
		var totalMinWidth:Float = 0;
		var totalPercentWidth:Float = 0;
		var item:DisplayObject;
		var itemCount:Int = items.length;
		var feathersItem:IFeathersControl;
		var layoutData:HorizontalLayoutData;
		var layoutItem:ILayoutDisplayObject;
		var percentWidth:Float;
		var pushIndex:Int = 0;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject))
			{
				layoutItem = cast item;
				if (!layoutItem.includeInLayout)
				{
					continue;
				}
				layoutData = cast layoutItem.layoutData;
				if (layoutData != null)
				{
					percentWidth = layoutData.percentWidth;
					if (percentWidth == percentWidth) //!isNaN
					{
						if (percentWidth < 0)
						{
							percentWidth = 0;
						}
						if (Std.isOfType(layoutItem, IFeathersControl))
						{
							feathersItem = cast layoutItem;
							totalMinWidth += feathersItem.minWidth;
						}
						totalPercentWidth += percentWidth;
						totalExplicitWidth += this._gap;
						this._discoveredItemsCache[pushIndex] = item;
						pushIndex++;
						continue;
					}
				}
			}
			totalExplicitWidth += item.width + this._gap;
		}
		totalExplicitWidth -= this._gap;
		if (this._firstGap == this._firstGap && //!isNaN
			itemCount > 1)
		{
			totalExplicitWidth += (this._firstGap - this._gap);
		}
		else if (this._lastGap == this._lastGap //!isNaN
			&& itemCount > 2)
		{
			totalExplicitWidth += (this._lastGap - this._gap);
		}
		totalExplicitWidth += this._paddingLeft + this._paddingRight;
		if (totalPercentWidth < 100)
		{
			totalPercentWidth = 100;
		}
		if (remainingWidth != remainingWidth) //isNaN
		{
			remainingWidth = totalExplicitWidth + totalMinWidth;
			if (remainingWidth < minWidth)
			{
				remainingWidth = minWidth;
			}
			else if (remainingWidth > maxWidth)
			{
				remainingWidth = maxWidth;
			}
		}
		remainingWidth -= totalExplicitWidth;
		if (remainingWidth < 0)
		{
			remainingWidth = 0;
		}
		var needsAnotherPass:Bool;
		var percentToPixels:Float;
		var itemWidth:Float;
		var itemMinWidth:Float;
		do
		{
			needsAnotherPass = false;
			percentToPixels = remainingWidth / totalPercentWidth;
			for (i in 0...pushIndex)
			{
				layoutItem = cast this._discoveredItemsCache[i];
				if (layoutItem == null)
				{
					continue;
				}
				layoutData = cast layoutItem.layoutData;
				percentWidth = layoutData.percentWidth;
				if (percentWidth < 0)
				{
					percentWidth = 0;
				}
				itemWidth = percentToPixels * percentWidth;
				if (Std.isOfType(layoutItem, IFeathersControl))
				{
					feathersItem = cast layoutItem;
					itemMinWidth = feathersItem.explicitMinWidth;
					if (itemMinWidth > remainingWidth)
					{
						//we try to respect the item's minimum width, but if
						//it's larger than the remaining space, we need to
						//force it to fit
						itemMinWidth = remainingWidth;
					}
					if (itemWidth < itemMinWidth)
					{
						itemWidth = itemMinWidth;
						remainingWidth -= itemWidth;
						totalPercentWidth -= percentWidth;
						this._discoveredItemsCache[i] = null;
						needsAnotherPass = true;
					}
					//we don't check maxWidth here because it is used in
					//validateItems() for performance optimization, so it
					//isn't a real maximum
				}
				layoutItem.width = itemWidth;
				if (Std.isOfType(layoutItem, IValidating))
				{
					//changing the width of the item may cause its height
					//to change, so we need to validate. the height is
					//needed for measurement.
					cast(layoutItem, IValidating).validate();
				}
			}
		}
		while(needsAnotherPass);
		this._discoveredItemsCache.resize(0);
	}
	
	/**
	 * @private
	 */
	private function calculateMaxScrollXOfIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float):Float
	{
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			this.prepareTypicalItem(height - this._paddingTop - this._paddingBottom);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var positionX:Float = x + this._paddingLeft;
		var lastWidth:Float = 0;
		var gap:Float = this._gap;
		var startIndexOffset:Int = 0;
		var endIndexOffset:Float = 0;
		var itemCount:Int = items.length;
		var totalItemCount:Int = itemCount;
		if (this._useVirtualLayout && !this._hasVariableItemDimensions)
		{
			totalItemCount += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
			if (index < this._beforeVirtualizedItemCount)
			{
				//this makes it skip the loop below
				startIndexOffset = index + 1;
				lastWidth = calculatedTypicalItemWidth;
				gap = this._gap;
			}
			else
			{
				startIndexOffset = this._beforeVirtualizedItemCount;
				endIndexOffset = index - items.length - this._beforeVirtualizedItemCount + 1;
				if (endIndexOffset < 0)
				{
					endIndexOffset = 0;
				}
				positionX += (endIndexOffset * (calculatedTypicalItemWidth + this._gap));
			}
			positionX += (startIndexOffset * (calculatedTypicalItemWidth + this._gap));
		}
		index -= (startIndexOffset + Std.int(endIndexOffset));
		var secondToLastIndex:Int = totalItemCount - 2;
		var item:DisplayObject;
		var iNormalized:Int;
		var cachedWidth:Float = Math.NaN;
		var itemWidth:Float;
		for (i in 0...index+1)
		{
			item = items[i];
			iNormalized = i + startIndexOffset;
			if (hasFirstGap && iNormalized == 0)
			{
				gap = this._firstGap;
			}
			else if (hasLastGap && iNormalized > 0 && iNormalized == secondToLastIndex)
			{
				gap = this._lastGap;
			}
			else
			{
				gap = this._gap;
			}
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				cachedWidth = iNormalized < this._virtualCache.length ? this._virtualCache[iNormalized] : Math.NaN;
			}
			if (this._useVirtualLayout && item == null)
			{
				if (!this._hasVariableItemDimensions ||
					cachedWidth != cachedWidth) //isNaN
				{
					lastWidth = calculatedTypicalItemWidth;
				}
				else
				{
					lastWidth = cachedWidth;
				}
			}
			else
			{
				itemWidth = item.width;
				if (this._useVirtualLayout)
				{
					if (this._hasVariableItemDimensions)
					{
						if (itemWidth != cachedWidth)
						{
							this._virtualCache[iNormalized] = itemWidth;
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else if (calculatedTypicalItemWidth >= 0)
					{
						item.width = itemWidth = calculatedTypicalItemWidth;
					}
				}
				lastWidth = itemWidth;
			}
			positionX += lastWidth + gap;
		}
		positionX -= (lastWidth + gap);
		return positionX;
	}
	
}