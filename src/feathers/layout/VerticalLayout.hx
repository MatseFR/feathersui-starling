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
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import feathers.core.IFeathersControl;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.utils.Pool;

/**
 * Positions items from top to bottom in a single column.
 *
 * @see ../../../help/vertical-layout.html How to use VerticalLayout with Feathers containers
 *
 * @productversion Feathers 1.0.0
 */
class VerticalLayout extends BaseLinearLayout implements IVariableVirtualLayout implements ITrimmedVirtualLayout implements IGroupedLayout implements IDragDropLayout
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * The alignment of the items horizontally, on the x-axis.
	 *
	 * <p>If the <code>horizontalAlign</code> property is set to
	 * <code>feathers.layout.HorizontalAlign.JUSTIFY</code>, the
	 * <code>width</code>, <code>minWidth</code>, and <code>maxWidth</code>
	 * properties of the items may be changed, and their original values
	 * ignored by the layout. In this situation, if the width needs to be
	 * constrained, the <code>width</code>, <code>minWidth</code>, or
	 * <code>maxWidth</code> properties should instead be set on the parent
	 * container using the layout.</p>
	 *
	 * @default feathers.layout.HorizontalAlign.LEFT
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 * @see feathers.layout.HorizontalAlign#JUSTIFY
	 */
	override function get_horizontalAlign():String 
	{
		//this is an override so that this class can have its own documentation.
		return this._horizontalAlign;
	}
	
	/**
	 * If the total item height is less than the bounds, the positions of
	 * the items can be aligned vertically, on the y-axis.
	 *
	 * <p><strong>Note:</strong> The <code>VerticalAlign.JUSTIFY</code>
	 * constant is not supported.</p>
	 *
	 * @default feathers.layout.VerticalAlign.TOP
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 */
	override function get_verticalAlign():String 
	{
		//this is an override so that this class can have its own documentation.
		return this._verticalAlign;
	}
	
	/**
	 * If a non-null value for the <code>headerIndices</code> property is
	 * provided (by a component like <code>GroupedList</code>), and the
	 * <code>stickyHeader</code> property is set to <code>true</code>, a
	 * header will stick to the top of the view port until the current group
	 * completely scrolls out of the view port.
	 *
	 * @default false
	 */
	public var stickyHeader(get, set):Bool;
	private var _stickyHeader:Bool = false;
	private function get_stickyHeader():Bool { return this._stickyHeader; }
	private function set_stickyHeader(value:Bool):Bool
	{
		if (this._stickyHeader == value)
		{
			return value;
		}
		this._stickyHeader = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._stickyHeader;
	}
	
	/**
	 * @inheritDoc
	 */
	public var headerIndices(get, set):Array<Int>;
	private var _headerIndices:Array<Int>;
	private function get_headerIndices():Array<Int> { return this._headerIndices; }
	private function set_headerIndices(value:Array<Int>):Array<Int>
	{
		if (this._headerIndices == value)
		{
			return value;
		}
		this._headerIndices = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._headerIndices;
	}
	
	/**
	 * Distributes the height of the view port equally to each item. If the
	 * view port height needs to be measured, the largest item's height will
	 * be used for all items, subject to any specified minimum and maximum
	 * height values.
	 *
	 * @default false
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
	 * Requests that the layout set the view port dimensions to display a
	 * specific number of rows (plus gaps and padding), if possible. If the
	 * explicit height of the view port is set, then this value will be
	 * ignored. If the view port's minimum and/or maximum height are set,
	 * the actual number of visible rows may be adjusted to meet those
	 * requirements. Set this value to <code>0</code> to display as many
	 * rows as possible.
	 *
	 * @default 0
	 *
	 * @see #maxRowCount
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
	 * The maximum number of rows to display. If the explicit height of the
	 * view port is set or if <code>requestedRowCount</code> is set, then
	 * this value will be ignored. If the view port's minimum and/or maximum
	 * height are set, the actual number of visible rows may be adjusted to
	 * meet those requirements. Set this value to <code>0</code> to display
	 * as many rows as possible.
	 *
	 * @default 0
	 */
	public var maxRowCount(get, set):Int;
	private var _maxRowCount:Int = 0;
	private function get_maxRowCount():Int { return this._maxRowCount; }
	private function set_maxRowCount(value:Int):Int
	{
		if (value < 0)
		{
			throw new RangeError("maxRowCount requires a value >= 0");
		}
		if (this._maxRowCount == value)
		{
			return value;
		}
		this._maxRowCount = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._maxRowCount;
	}
	
	/**
	 * When the scroll position is calculated for an item, an attempt will
	 * be made to align the item to this position.
	 *
	 * @default feathers.layout.VerticalAlign.MIDDLE
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 */
	public var scrollPositionVerticalAlign(get, set):String;
	private var _scrollPositionVerticalAlign:String = VerticalAlign.MIDDLE;
	private function get_scrollPositionVerticalAlign():String { return this._scrollPositionVerticalAlign; }
	private function set_scrollPositionVerticalAlign(value:String):String
	{
		return this._scrollPositionVerticalAlign = value;
	}
	
	/**
	 * When the scroll position is calculated for a header (specified by a
	 * <code>GroupedList</code> or another component with the
	 * <code>headerIndicies</code> property, an attempt will be made to
	 * align the header to this position.
	 *
	 * @default feathers.layout.VerticalAlign.TOP
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see #headerIndices
	 * @see #scrollPositionVerticalAlign
	 */
	public var headerScrollPositionVerticalAlign(get, set):String;
	private var _headerScrollPositionVerticalAlign:String = VerticalAlign.TOP;
	private function get_headerScrollPositionVerticalAlign():String { return this._headerScrollPositionVerticalAlign; }
	private function set_headerScrollPositionVerticalAlign(value:String):String
	{
		return this._headerScrollPositionVerticalAlign = value;
	}
	
	/**
	 * @inheritDoc
	 */
	override function get_requiresLayoutOnScroll():Bool 
	{
		return this._useVirtualLayout ||
				(this._headerIndices != null && this._stickyHeader); //the header needs to stick!
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
		
		var calculatedTypicalItemWidth:Float;
		var calculatedTypicalItemHeight:Float;
		if(this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			this.prepareTypicalItem(explicitWidth - this._paddingLeft - this._paddingRight);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var needsExplicitWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsExplicitHeight:Bool = explicitHeight != explicitHeight; //isNaN
		var distributedHeight:Float;
		if (!needsExplicitHeight && this._distributeHeights)
		{
			//we need to calculate this before validateItems() because it
			//needs to be passed in there.
			distributedHeight = this.calculateDistributedHeight(items, explicitHeight, minHeight, maxHeight, false);
			if (this._useVirtualLayout)
			{
				calculatedTypicalItemHeight = distributedHeight;
			}
		}
		
		if (!this._useVirtualLayout || this._hasVariableItemDimensions || this._distributeHeights ||
			this._horizontalAlign != HorizontalAlign.JUSTIFY ||
			needsExplicitWidth) //isNaN
		{
			//in some cases, we may need to validate all of the items so
			//that we can use their dimensions below.
			this.validateItems(items, explicitWidth - this._paddingLeft - this._paddingRight,
				minWidth - this._paddingLeft - this._paddingRight,
				maxWidth - this._paddingLeft - this._paddingRight,
				explicitHeight - this._paddingTop - this._paddingBottom,
				minHeight - this._paddingTop - this._paddingBottom,
				maxHeight - this._paddingTop - this._paddingBottom, distributedHeight);
		}
		
		if (needsExplicitHeight && this._distributeHeights)
		{
			//if we didn't calculate this before, we need to do it now.
			distributedHeight = this.calculateDistributedHeight(items, explicitHeight, minHeight, maxHeight, true);
		}
		var hasDistributedHeight:Bool = distributedHeight == distributedHeight; //!isNaN
		
		if (!this._useVirtualLayout)
		{
			//handle the percentHeight property from VerticalLayoutData,
			//if available.
			this.applyPercentHeights(items, explicitHeight, minHeight, maxHeight);
		}
		
		//this section prepares some variables needed for the following loop
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var maxItemWidth:Float = this._useVirtualLayout ? calculatedTypicalItemWidth : 0;
		var startPositionY:Float = boundsY + this._paddingTop;
		var positionY:Float = startPositionY;
		var indexOffset:Int = 0;
		var itemCount:Int = items.length;
		var totalItemCount:Int = itemCount;
		var requestedRowAvailableHeight:Float = 0;
		var maxRowAvailableHeight:Float = Math.POSITIVE_INFINITY;
		if (this._useVirtualLayout && !this._hasVariableItemDimensions)
		{
			//if the layout is virtualized, and the items all have the same
			//height, we can make our loops smaller by skipping some items
			//at the beginning and end. this improves performance.
			totalItemCount += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
			indexOffset = this._beforeVirtualizedItemCount;
			positionY += (this._beforeVirtualizedItemCount * (calculatedTypicalItemHeight + this._gap));
			if (hasFirstGap && this._beforeVirtualizedItemCount > 0)
			{
				positionY = positionY - this._gap + this._firstGap;
			}
		}
		var secondToLastIndex:Int = totalItemCount - 2;
		//this cache is used to save non-null items in virtual layouts. by
		//using a smaller array, we can improve performance by spending less
		//time in the upcoming loops.
		this._discoveredItemsCache.resize(0);
		var discoveredItemsCacheLastIndex:Int = 0;
		
		//if there are no items in layout, then we don't want to subtract
		//any gap when calculating the total height, so default to 0.
		var gap:Float = 0;
		
		var headerIndicesIndex:Int = -1;
		var nextHeaderIndex:Int = -1;
		var headerCount:Int = 0;
		var stickyHeaderMaxY:Float = Math.POSITIVE_INFINITY;
		if (this._headerIndices != null && this._stickyHeader)
		{
			headerCount = this._headerIndices.length;
			if (headerCount > 0)
			{
				headerIndicesIndex = 0;
				nextHeaderIndex = this._headerIndices[headerIndicesIndex];
			}
		}
		
		var item:DisplayObject;
		var iNormalized:Int;
		var cachedHeight:Float;
		var layoutItem:ILayoutDisplayObject;
		var pivotY:Float;
		var itemWidth:Float;
		var itemHeight:Float;
		//this first loop sets the y position of items, and it calculates
		//the total height of all items
		for (i in 0...itemCount)
		{
			if (!this._useVirtualLayout)
			{
				if (this._maxRowCount > 0 && this._maxRowCount == i)
				{
					maxRowAvailableHeight = positionY;
				}
				if (this._requestedRowCount > 0 && this._requestedRowCount == i)
				{
					requestedRowAvailableHeight = positionY;
				}
			}
			item = items[i];
			//if we're trimming some items at the beginning, we need to
			//adjust i to account for the missing items in the array
			iNormalized = i + indexOffset;
			
			if (nextHeaderIndex == iNormalized)
			{
				//if the sticky header is enabled, we need to find its index
				//we look for the first header that is visible at the top of
				//the view port. the previous one should be sticky.
				if (positionY < scrollY)
				{
					headerIndicesIndex++;
					if (headerIndicesIndex < headerCount)
					{
						nextHeaderIndex = this._headerIndices[headerIndicesIndex];
					}
				}
				else
				{
					headerIndicesIndex--;
					if(headerIndicesIndex >= 0)
					{
						//this is the index of the "sticky" header, but we
						//need to save it for later.
						nextHeaderIndex = this._headerIndices[headerIndicesIndex];
						stickyHeaderMaxY = positionY;
					}
				}
			}
			
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
				cachedHeight = this._virtualCache[iNormalized];
			}
			if (this._useVirtualLayout && item == null)
			{
				//the item is null, and the layout is virtualized, so we
				//need to estimate the height of the item.
				
				if (!this._hasVariableItemDimensions ||
					cachedHeight != cachedHeight) //isNaN
				{
					//if all items must have the same height, we will
					//use the height of the typical item (calculatedTypicalItemHeight).
					
					//if items may have different heights, we first check
					//the cache for a height value. if there isn't one, then
					//we'll use calculatedTypicalItemHeight as a fallback.
					positionY += calculatedTypicalItemHeight + gap;
				}
				else
				{
					//if we have variable item heights, we should use a
					//cached height when there's one available. it will be
					//more accurate than the typical item's height.
					positionY += cachedHeight + gap;
				}
			}
			else
			{
				//we get here if the item isn't null. it is never null if
				//the layout isn't virtualized.
				layoutItem = cast item;
				if (layoutItem != null && !layoutItem.includeInLayout)
				{
					continue;
				}
				pivotY = item.pivotY;
				if (pivotY != 0)
				{
					pivotY *= item.scaleY;
				}
				item.y = pivotY + positionY;
				itemWidth = item.width;
				if (hasDistributedHeight)
				{
					item.height = itemHeight = distributedHeight;
				}
				else
				{
					itemHeight = item.height;
				}
				if (this._useVirtualLayout)
				{
					if (this._hasVariableItemDimensions)
					{
						if (itemHeight != cachedHeight)
						{
							//update the cache if needed. this will notify
							//the container that the virtualized layout has
							//changed, and it the view port may need to be
							//re-measured.
							this._virtualCache[iNormalized] = itemHeight;
							
							//attempt to adjust the scroll position so that
							//it looks like we're scrolling smoothly after
							//this item resizes.
							if (positionY < scrollY &&
								cachedHeight != cachedHeight && //isNaN
								itemHeight != calculatedTypicalItemHeight)
							{
								this.dispatchEventWith(Event.SCROLL, false, new Point(0, itemHeight - calculatedTypicalItemHeight));
							}
							
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else if (calculatedTypicalItemHeight >= 0)
					{
						//if all items must have the same height, we will
						//use the height of the typical item (calculatedTypicalItemHeight).
						itemHeight = calculatedTypicalItemHeight;
						if (item != this._typicalItem || item.height != itemHeight)
						{
							//ensure that the typical item's height is not
							//set explicitly so that it can resize
							item.height = itemHeight;
						}
					}
				}
				positionY += itemHeight + gap;
				//we compare with > instead of Math.max() because the rest
				//arguments on Math.max() cause extra garbage collection and
				//hurt performance
				if (itemWidth > maxItemWidth)
				{
					//we need to know the maximum width of the items in the
					//case where the width of the view port needs to be
					//calculated by the layout.
					maxItemWidth = itemWidth;
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
			//finish the final calculation of the y position so that it can
			//be used for the total height of all items
			positionY += (this._afterVirtualizedItemCount * (calculatedTypicalItemHeight + this._gap));
			if (hasLastGap && this._afterVirtualizedItemCount > 0)
			{
				positionY = positionY - this._gap + this._lastGap;
			}
		}
		if (nextHeaderIndex >= 0)
		{
			//position the "sticky" header at the top of the view port.
			//it should not cover the following header.
			var header:DisplayObject = items[nextHeaderIndex];
			this.positionStickyHeader(header, scrollY, stickyHeaderMaxY);
		}
		if (!this._useVirtualLayout && this._requestedRowCount > itemCount)
		{
			if (itemCount > 0)
			{
				requestedRowAvailableHeight = this._requestedRowCount * positionY / itemCount;
			}
			else
			{
				requestedRowAvailableHeight = 0;
			}
		}
		
		//this array will contain all items that are not null. see the
		//comment above where the discoveredItemsCache is initialized for
		//details about why this is important.
		var discoveredItems:Array<DisplayObject> = this._useVirtualLayout ? this._discoveredItemsCache : items;
		var discoveredItemCount:Int = discoveredItems.length;
		
		var totalWidth:Float = maxItemWidth + this._paddingLeft + this._paddingRight;
		//the available width is the width of the viewport. if the explicit
		//width is NaN, we need to calculate the viewport width ourselves
		//based on the total width of all items.
		var availableWidth:Float = explicitWidth;
		if (availableWidth != availableWidth) //isNaN
		{
			availableWidth = totalWidth;
			if (availableWidth < minWidth)
			{
				availableWidth = minWidth;
			}
			else if (availableWidth > maxWidth)
			{
				availableWidth = maxWidth;
			}
		}
		
		//this is the total height of all items
		var totalHeight:Float = positionY - gap + this._paddingBottom - boundsY;
		//the available height is the height of the viewport. if the explicit
		//height is NaN, we need to calculate the viewport height ourselves
		//based on the total height of all items.
		var availableHeight:Float = explicitHeight;
		if (availableHeight != availableHeight) //isNaN
		{
			availableHeight = totalHeight;
			if (this._requestedRowCount > 0)
			{
				if (this._useVirtualLayout)
				{
					availableHeight = this._requestedRowCount * (calculatedTypicalItemHeight + this._gap) - this._gap + this._paddingTop + this._paddingBottom;
				}
				else
				{
					availableHeight = requestedRowAvailableHeight;
				}
			}
			else
			{
				availableHeight = totalHeight;
				if (this._maxRowCount > 0)
				{
					if (this._useVirtualLayout)
					{
						maxRowAvailableHeight = this._maxRowCount * (calculatedTypicalItemHeight + this._gap) - this._gap + this._paddingTop + this._paddingBottom;
					}
					if (maxRowAvailableHeight < availableHeight)
					{
						availableHeight = maxRowAvailableHeight;
					}
				}
			}
			if (availableHeight < minHeight)
			{
				availableHeight = minHeight;
			}
			else if (availableHeight > maxHeight)
			{
				availableHeight = maxHeight;
			}
		}
		
		//in this section, we handle vertical alignment. items will be
		//aligned vertically if the total height of all items is less than
		//the available height of the view port.
		if (totalHeight < availableHeight)
		{
			var verticalAlignOffsetY:Float = 0;
			if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				verticalAlignOffsetY = availableHeight - totalHeight;
			}
			else if (this._verticalAlign == VerticalAlign.MIDDLE)
			{
				verticalAlignOffsetY = Math.round((availableHeight - totalHeight) / 2);
			}
			if (verticalAlignOffsetY != 0)
			{
				for (i in 0...discoveredItemCount)
				{
					item = discoveredItems[i];
					if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
					{
						continue;
					}
					item.y += verticalAlignOffsetY;
				}
			}
		}
		
		var availableWidthMinusPadding:Float = availableWidth - this._paddingLeft - this._paddingRight;
		for (i in 0...discoveredItemCount)
		{
			item = discoveredItems[i];
			layoutItem = cast item;
			if (layoutItem != null && !layoutItem.includeInLayout)
			{
				continue;
			}
			
			var pivotX:Float = item.pivotX;
			if (pivotX != 0)
			{
				pivotX *= item.scaleX;
			}
			
			//in this section, we handle horizontal alignment and percent
			//width from VerticalLayoutData
			if (this._horizontalAlign == HorizontalAlign.JUSTIFY)
			{
				//if we justify items horizontally, we can skip percent width
				item.x = pivotX + boundsX + this._paddingLeft;
				item.width = availableWidthMinusPadding;
			}
			else
			{
				if (layoutItem != null)
				{
					var layoutData:VerticalLayoutData = cast layoutItem.layoutData;
					if (layoutData != null)
					{
						//in this section, we handle percentage width if
						//VerticalLayoutData is available.
						var percentWidth:Float = layoutData.percentWidth;
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
							itemWidth = percentWidth * availableWidthMinusPadding / 100;
							if (Std.isOfType(item, IFeathersControl))
							{
								var feathersItem:IFeathersControl = cast item;
								var itemMinWidth:Float = feathersItem.explicitMinWidth;
								//we try to respect the minWidth, but not
								//when it's larger than 100%
								if (itemMinWidth > availableWidthMinusPadding)
								{
									itemMinWidth = availableWidthMinusPadding;
								}
								if (itemWidth < itemMinWidth)
								{
									itemWidth = itemMinWidth;
								}
								else
								{
									var itemMaxWidth:Float = feathersItem.explicitMaxWidth;
									if (itemWidth > itemMaxWidth)
									{
										itemWidth = itemMaxWidth;
									}
								}
							}
							item.width = itemWidth;
						}
					}
				}
				//handle all other horizontal alignment values (we handled
				//justify already). the x position of all items is set.
				var horizontalAlignWidth:Float = availableWidth;
				if (totalWidth > horizontalAlignWidth)
				{
					horizontalAlignWidth = totalWidth;
				}
				switch (this._horizontalAlign)
				{
					case HorizontalAlign.RIGHT:
					{
						item.x = pivotX + boundsX + horizontalAlignWidth - this._paddingRight - item.width;
						break;
					}
					case HorizontalAlign.CENTER:
					{
						//round to the nearest pixel when dividing by 2 to
						//align in the center
						item.x = pivotX + boundsX + this._paddingLeft + Math.round((horizontalAlignWidth - this._paddingLeft - this._paddingRight - item.width) / 2);
						break;
					}
					default: //left
					{
						item.x = pivotX + boundsX + this._paddingLeft;
					}
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
		result.contentWidth = this._horizontalAlign == HorizontalAlign.JUSTIFY ? availableWidth : totalWidth;
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
		
		this.prepareTypicalItem(explicitWidth - this._paddingLeft - this._paddingRight);
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var positionY:Float;
		var maxItemWidth:Float;
		if (this._distributeHeights)
		{
			positionY = (calculatedTypicalItemHeight + this._gap) * itemCount;
		}
		else
		{
			positionY = 0;
			maxItemWidth = calculatedTypicalItemWidth;
			if (!this._hasVariableItemDimensions)
			{
				positionY += ((calculatedTypicalItemHeight + this._gap) * itemCount);
			}
			else
			{
				for (i in 0...itemCount)
				{
					var cachedHeight:Float = this._virtualCache[i];
					if (cachedHeight != cachedHeight) //isNaN
					{
						positionY += calculatedTypicalItemHeight + this._gap;
					}
					else
					{
						positionY += cachedHeight + this._gap;
					}
				}
			}
		}
		positionY -= this._gap;
		if (hasFirstGap && itemCount > 1)
		{
			positionY = positionY - this._gap + this._firstGap;
		}
		if (hasLastGap && itemCount > 2)
		{
			positionY = positionY - this._gap + this._lastGap;
		}
		
		if (needsWidth)
		{
			var resultWidth:Float = maxItemWidth + this._paddingLeft + this._paddingRight;
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
			var resultHeight:Float;
			if (this._requestedRowCount > 0)
			{
				resultHeight = (calculatedTypicalItemHeight + this._gap) * this._requestedRowCount - this._gap;
			}
			else
			{
				resultHeight = positionY;
				if (this._maxRowCount > 0)
				{
					var maxRowResultHeight:Float = (calculatedTypicalItemHeight + this._gap) * this._maxRowCount - this._gap;
					if (maxRowResultHeight < resultHeight)
					{
						resultHeight = maxRowResultHeight;
					}
				}
			}
			resultHeight += this._paddingTop + this._paddingBottom;
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
		
		this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var resultLastIndex:Int = 0;
		//we add one extra here because the first item renderer in view may
		//be partially obscured, which would reveal an extra item renderer.
		var maxVisibleTypicalItemCount:Int = Math.ceil(height / (calculatedTypicalItemHeight + this._gap)) + 1;
		if (!this._hasVariableItemDimensions)
		{
			//this case can be optimized because we know that every item has
			//the same height
			var totalItemHeight:Float = itemCount * (calculatedTypicalItemHeight + this._gap) - this._gap;
			if (hasFirstGap && itemCount > 1)
			{
				totalItemHeight = totalItemHeight - this._gap + this._firstGap;
			}
			if (hasLastGap && itemCount > 2)
			{
				totalItemHeight = totalItemHeight - this._gap + this._lastGap;
			}
			var indexOffset:Int = 0;
			if (totalItemHeight < height)
			{
				if (this._verticalAlign == VerticalAlign.BOTTOM)
				{
					indexOffset = Math.ceil((height - totalItemHeight) / (calculatedTypicalItemHeight + this._gap));
				}
				else if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					indexOffset = Math.ceil(((height - totalItemHeight) / (calculatedTypicalItemHeight + this._gap)) / 2);
				}
			}
			var minimum:Int = Std.int((scrollY - this._paddingTop) / (calculatedTypicalItemHeight + this._gap));
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
		
		var headerIndicesIndex:Int = -1;
		var nextHeaderIndex:Int = -1;
		var headerCount:Int = 0;
		if (this._headerIndices != null && this._stickyHeader)
		{
			headerCount = this._headerIndices.length;
			if (headerCount > 0)
			{
				headerIndicesIndex = 0;
				nextHeaderIndex = this._headerIndices[headerIndicesIndex];
			}
		}
		
		var secondToLastIndex:Int = itemCount - 2;
		var maxPositionY:Float = scrollY + height;
		var startPositionY:Float = this._paddingTop;
		var foundSticky:Bool = false;
		var positionY:Float = startPositionY;
		var gap:Float;
		var itemHeight:Float;
		var cachedHeight:Float;
		var oldPositionY:Float;
		for (i in 0...itemCount)
		{
			if (nextHeaderIndex == i)
			{
				if (positionY < scrollY)
				{
					headerIndicesIndex++;
					if (headerIndicesIndex < headerCount)
					{
						nextHeaderIndex = this._headerIndices[headerIndicesIndex];
					}
				}
				else
				{
					headerIndicesIndex--;
					if (headerIndicesIndex >= 0)
					{
						//this is the index of the "sticky" header
						nextHeaderIndex = this._headerIndices[headerIndicesIndex];
						foundSticky = true;
					}
				}
			}
			
			gap = this._gap;
			if (hasFirstGap && i == 0)
			{
				gap = this._firstGap;
			}
			else if (hasLastGap && i > 0 && i == secondToLastIndex)
			{
				gap = this._lastGap;
			}
			cachedHeight = this._virtualCache[i];
			if (cachedHeight != cachedHeight) //isNaN
			{
				itemHeight = calculatedTypicalItemHeight;
			}
			else
			{
				itemHeight = cachedHeight;
			}
			oldPositionY = positionY;
			positionY += itemHeight + gap;
			if (positionY > scrollY && oldPositionY < maxPositionY)
			{
				result[resultLastIndex] = i;
				resultLastIndex++;
			}
			
			if (positionY >= maxPositionY)
			{
				if (!foundSticky)
				{
					headerIndicesIndex--;
					if (headerIndicesIndex >= 0)
					{
						//this is the index of the "sticky" header
						nextHeaderIndex = this._headerIndices[headerIndicesIndex];
					}
				}
				break;
			}
		}
		if (nextHeaderIndex >= 0 && result.indexOf(nextHeaderIndex) < 0)
		{
			var addedStickyHeader:Bool = false;
			for (i in 0...resultLastIndex)
			{
				if (nextHeaderIndex <= result[i])
				{
					result.insert(i, nextHeaderIndex);
					addedStickyHeader = true;
					break;
				}
			}
			if (!addedStickyHeader)
			{
				result[resultLastIndex] = nextHeaderIndex;
			}
			resultLastIndex++;
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
				if (i == nextHeaderIndex)
				{
					continue;
				}
				result.insert(0, i);
			}
		}
		resultLength = result.length;
		visibleItemCountDifference = maxVisibleTypicalItemCount - resultLength;
		resultLastIndex = resultLength;
		if (visibleItemCountDifference > 0)
		{
			//add extra items after the last index
			var startIndex:Int = (resultLength > 0) ? (result[resultLength - 1] + 1) : 0;
			var endIndex:Int = startIndex + visibleItemCountDifference;
			if (endIndex > itemCount)
			{
				endIndex = itemCount;
			}
			for (i in startIndex...endIndex)
			{
				if (i == nextHeaderIndex)
				{
					continue;
				}
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
		var point:Point = Pool.getPoint();
		this.calculateScrollRangeOfIndex(index, items, x, y, width, height, point);
		var minScrollY:Float = point.x;
		var maxScrollY:Float = point.y;
		var scrollRange:Float = maxScrollY - minScrollY;
		Pool.putPoint(point);
		
		var itemHeight:Float;
		if (this._useVirtualLayout)
		{
			if (this._hasVariableItemDimensions)
			{
				itemHeight = this._virtualCache[index];
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
		
		var bottomPosition:Float = maxScrollY - (scrollRange - itemHeight);
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
		var itemArrayCount:Int = items.length;
		var itemCount:Int = itemArrayCount + this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
		var calculatedTypicalItemHeight:Float;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			this.prepareTypicalItem(bounds.viewPortWidth - this._paddingLeft - this._paddingRight);
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var backwards:Bool = false;
		var result:Int = index;
		var indexOffset:Int;
		var yPosition:Float;
		var iNormalized:Int;
		var cachedHeight:Float;
		var item:DisplayObject;
		if (keyCode == Keyboard.HOME)
		{
			backwards = true;
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
			backwards = true;
			indexOffset = 0;
			if (this._useVirtualLayout && this._hasVariableItemDimensions)
			{
				indexOffset = -this._beforeVirtualizedItemCount;
			}
			yPosition = 0;
			//for(var i:int = index; i >= 0; i--)
			for (i in new ReverseIterator(index, 0))
			{
				iNormalized = i + indexOffset;
				if (this._useVirtualLayout && this._hasVariableItemDimensions)
				{
					cachedHeight = this._virtualCache[i];
				}
				if (iNormalized < 0 || iNormalized >= itemArrayCount)
				{
					if (cachedHeight == cachedHeight) //!isNaN
					{
						yPosition += cachedHeight;
					}
					else
					{
						yPosition += calculatedTypicalItemHeight;
					}
				}
				else
				{
					item = items[iNormalized];
					if (item == null)
					{
						if (cachedHeight == cachedHeight) //!isNaN
						{
							yPosition += cachedHeight;
						}
						else
						{
							yPosition += calculatedTypicalItemHeight;
						}
					}
					else
					{
						yPosition += item.height;
					}
				}
				if (yPosition > bounds.viewPortHeight)
				{
					break;
				}
				yPosition += this._gap;
				result = i;
			}
		}
		else if (keyCode == Keyboard.PAGE_DOWN)
		{
			yPosition = 0;
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
					cachedHeight = this._virtualCache[i];
				}
				if (iNormalized < 0 || iNormalized >= itemArrayCount)
				{
					if (cachedHeight == cachedHeight) //!isNaN
					{
						yPosition += cachedHeight;
					}
					else
					{
						yPosition += calculatedTypicalItemHeight;
					}
				}
				else
				{
					item = items[iNormalized];
					if (item == null)
					{
						if (cachedHeight == cachedHeight) //!isNaN
						{
							yPosition += cachedHeight;
						}
						else
						{
							yPosition += calculatedTypicalItemHeight;
						}
					}
					else
					{
						yPosition += item.height;
					}
				}
				if (yPosition > bounds.viewPortHeight)
				{
					break;
				}
				yPosition += this._gap;
				result = i;
			}
		}
		else if (keyCode == Keyboard.UP)
		{
			backwards = true;
			result--;
		}
		else if (keyCode == Keyboard.DOWN)
		{
			result++;
		}
		if (result < 0)
		{
			result = 0;
		}
		if (result >= itemCount)
		{
			result = itemCount - 1;
		}
		while (this._headerIndices != null && this._headerIndices.indexOf(result) != -1)
		{
			if (backwards)
			{
				if (result == 0)
				{
					backwards = false;
					result++;
				}
				else
				{
					result--;
				}
			}
			else
			{
				result++;
			}
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		var point:Point = Pool.getPoint();
		this.calculateScrollRangeOfIndex(index, items, x, y, width, height, point);
		var minScrollY:Float = point.x;
		var maxScrollY:Float = point.y;
		var scrollRange:Float = maxScrollY - minScrollY;
		Pool.putPoint(point);
		
		var itemHeight:Float;
		if (this._useVirtualLayout)
		{
			if (this._hasVariableItemDimensions)
			{
				itemHeight = this._virtualCache[index];
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
		
		var verticalAlign:String = this._scrollPositionVerticalAlign;
		if (this._headerIndices != null &&
			this._headerIndices.indexOf(index) != -1)
		{
			verticalAlign = this._headerScrollPositionVerticalAlign;
		}
		if (verticalAlign == VerticalAlign.MIDDLE)
		{
			maxScrollY -= Math.round((scrollRange - itemHeight) / 2);
		}
		else if (verticalAlign == VerticalAlign.BOTTOM)
		{
			maxScrollY -= (scrollRange - itemHeight);
		}
		result.y = maxScrollY;
		
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
		
		var yPosition:Float = 0;
		var item:DisplayObject;
		if (index < totalItemCount)
		{
			item = items[indexMinusOffset];
			yPosition = item.y - dropIndicator.height / 2;
			dropIndicator.x = item.x;
			dropIndicator.width = item.width;
		}
		else //after the last item
		{
			item = items[indexMinusOffset - 1];
			yPosition = item.y + item.height - dropIndicator.height;
			dropIndicator.x = item.x;
			dropIndicator.width = item.width;
		}
		if (yPosition < 0)
		{
			yPosition = 0;
		}
		dropIndicator.y = yPosition;
	}
	
	/**
	 * @private
	 */
	public function getDropIndex(x:Float, y:Float, items:Array<DisplayObject>,
		boundsX:Float, boundsY:Float, width:Float, height:Float):Int
	{
		var calculatedTypicalItemWidth:Float;
		var calculatedTypicalItemHeight:Float;
		if (this._useVirtualLayout)
		{
			this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var positionY:Float = boundsY + this._paddingTop;
		var lastHeight:Float = 0;
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
		var indexMinusOffset:Int;
		var cachedHeight:Float;
		var itemHeight:Float;
		for (i in 0...totalItemCount)
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
				cachedHeight = this._virtualCache[i];
			}
			if (this._useVirtualLayout && item == null)
			{
				if (!this._hasVariableItemDimensions ||
					cachedHeight != cachedHeight) //isNaN
				{
					lastHeight = calculatedTypicalItemHeight;
				}
				else
				{
					lastHeight = cachedHeight;
				}
			}
			else
			{
				//use the y position of the item to account for vertical
				//alignment, in case the total height of the items is less
				//than the height of the container
				positionY = item.y;
				itemHeight = item.height;
				if (this._useVirtualLayout)
				{
					if (this._hasVariableItemDimensions)
					{
						if (itemHeight != cachedHeight)
						{
							this._virtualCache[i] = itemHeight;
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else if (calculatedTypicalItemHeight >= 0)
					{
						itemHeight = calculatedTypicalItemHeight;
					}
				}
				lastHeight = itemHeight;
			}
			if (y < (positionY + (lastHeight / 2)))
			{
				return i;
			}
			positionY += lastHeight + gap;
		}
		return totalItemCount;
	}
	
	/**
	 * @private
	 */
	private function validateItems(items:Array<DisplayObject>,
		explicitWidth:Float, minWidth:Float, maxWidth:Float,
		explicitHeight:Float, minHeight:Float, maxHeight:Float,
		distributedHeight:Float):Void
	{
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		var containerHeight:Float = explicitHeight;
		if (needsHeight)
		{
			containerHeight = minHeight;
		}
		//if the alignment is justified, then we want to set the width of
		//each item before validating because setting one dimension may
		//cause the other dimension to change, and that will invalidate the
		//layout if it happens after validation, causing more invalidation
		var isJustified:Bool = this._horizontalAlign == HorizontalAlign.JUSTIFY;
		var itemCount:Int = items.length;
		var item:DisplayObject;
		var feathersItem:IFeathersControl;
		var layoutItem:ILayoutDisplayObject;
		var layoutData:VerticalLayoutData;
		var percentWidth:Float;
		var percentHeight:Float;
		var measureItem:IMeasureDisplayObject;
		var itemWidth:Float;
		var itemExplicitMinWidth:Float;
		var itemHeight:Float;
		var itemExplicitMinHeight:Float;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (item == null || (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout))
			{
				continue;
			}
			if (isJustified)
			{
				//the alignment is justified, but we don't yet have a width
				//to use, so we need to ensure that we accurately measure
				//the items instead of using an old justified width that may
				//be wrong now!
				item.width = explicitWidth;
				if (Std.isOfType(item, IFeathersControl))
				{
					feathersItem = cast(item, IFeathersControl);
					feathersItem.minWidth = minWidth;
					feathersItem.maxWidth = maxWidth;
				}
			}
			else if (Std.isOfType(item, ILayoutDisplayObject))
			{
				layoutItem = cast(item, ILayoutDisplayObject);
				layoutData = cast layoutItem.layoutData;
				if (layoutData != null)
				{
					percentWidth = layoutData.percentWidth;
					percentHeight = layoutData.percentHeight;
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
						itemWidth = explicitWidth * percentWidth / 100;
						measureItem = cast item;
						//we use the explicitMinWidth to make an accurate
						//measurement, and we'll use the component's
						//measured minWidth later, after we validate it.
						itemExplicitMinWidth = measureItem.explicitMinWidth;
						if (measureItem.explicitMinWidth == measureItem.explicitMinWidth && //!isNaN
							itemWidth < itemExplicitMinWidth)
						{
							itemWidth = itemExplicitMinWidth;
						}
						if (itemWidth > maxWidth)
						{
							itemWidth = maxWidth;
						}
						//unlike below, where we set maxHeight, we can set
						//the width explicitly here
						//in fact, it's required because we need to make
						//an accurate measurement of the total view port
						//width
						item.width = itemWidth;
						//if itemWidth is NaN, we need to set a maximum
						//width instead. this is important for items where
						//the height becomes larger when their width becomes
						//smaller (such as word-wrapped text)
						if (measureItem.explicitWidth != measureItem.explicitWidth && //isNaN
							measureItem.maxWidth > maxWidth)
						{
							measureItem.maxWidth = maxWidth;
						}
					}
					if (percentHeight == percentHeight) //!isNaN
					{
						itemHeight = containerHeight * percentHeight / 100;
						measureItem = cast item;
						//we use the explicitMinHeight to make an accurate
						//measurement, and we'll use the component's
						//measured minHeight later, after we validate it.
						itemExplicitMinHeight = measureItem.explicitMinHeight;
						if (measureItem.explicitMinHeight == measureItem.explicitMinHeight && //!isNaN
							itemHeight < itemExplicitMinHeight)
						{
							itemHeight = itemExplicitMinHeight;
						}
						//validating this component may be expensive if we
						//don't limit the height! we want to ensure that a
						//component like a vertical list with many item
						//renderers doesn't completely bypass layout
						//virtualization, so we limit the height to the
						//maximum possible value if it were the only item in
						//the layout.
						//this doesn't need to be perfectly accurate because
						//it's just a maximum
						measureItem.maxHeight = itemHeight;
						//we also need to clear the explicit height because,
						//for many components, it will affect the minHeight
						//which is used in the final calculation
						item.height = Math.NaN;
					}
				}
			}
			if (this._distributeHeights)
			{
				item.height = distributedHeight;
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
	private function prepareTypicalItem(justifyWidth:Float):Void
	{
		if (this._typicalItem == null)
		{
			return;
		}
		var hasSetWidth:Bool = false;
		if (this._horizontalAlign == HorizontalAlign.JUSTIFY &&
			justifyWidth == justifyWidth) //!isNaN
		{
			hasSetWidth = true;
			this._typicalItem.width = justifyWidth;
		}
		else if (Std.isOfType(this._typicalItem, ILayoutDisplayObject))
		{
			var layoutItem:ILayoutDisplayObject = cast this._typicalItem;
			var layoutData:VerticalLayoutData = cast layoutItem.layoutData;
			if (layoutData != null)
			{
				var percentWidth:Float = layoutData.percentWidth;
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
					hasSetWidth = true;
					this._typicalItem.width = justifyWidth * percentWidth / 100;
				}
			}
		}
		if (!hasSetWidth && this._resetTypicalItemDimensionsOnMeasure)
		{
			this._typicalItem.width = this._typicalItemWidth;
		}
		if (this._resetTypicalItemDimensionsOnMeasure)
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
	private function calculateDistributedHeight(items:Array<DisplayObject>, explicitHeight:Float, minHeight:Float, maxHeight:Float, measureItems:Bool):Float
	{
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		var includedItemCount:Int = 0;
		var maxItemHeight:Float = 0;
		var itemCount:Int = items.length;
		var item:DisplayObject;
		var itemHeight:Float;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
			}
			includedItemCount++;
			itemHeight = item.height;
			if (itemHeight > maxItemHeight)
			{
				maxItemHeight = itemHeight;
			}
		}
		if (measureItems && needsHeight)
		{
			explicitHeight = maxItemHeight * includedItemCount + this._paddingTop + this._paddingBottom + this._gap * (includedItemCount - 1);
			var needsRecalculation:Bool = false;
			if (explicitHeight > maxHeight)
			{
				explicitHeight = maxHeight;
				needsRecalculation = true;
			}
			else if (explicitHeight < minHeight)
			{
				explicitHeight = minHeight;
				needsRecalculation = true;
			}
			if (!needsRecalculation)
			{
				return maxItemHeight;
			}
		}
		var availableSpace:Float = explicitHeight;
		if (needsHeight && maxHeight < Math.POSITIVE_INFINITY)
		{
			availableSpace = maxHeight;
		}
		availableSpace = availableSpace - this._paddingTop - this._paddingBottom - this._gap * (includedItemCount - 1);
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
	private function applyPercentHeights(items:Array<DisplayObject>, explicitHeight:Float, minHeight:Float, maxHeight:Float):Void
	{
		var remainingHeight:Float = explicitHeight;
		this._discoveredItemsCache.resize(0);
		var totalExplicitHeight:Float = 0;
		var totalMinHeight:Float = 0;
		var totalPercentHeight:Float = 0;
		var itemCount:Int = items.length;
		var pushIndex:Int = 0;
		var item:DisplayObject;
		var layoutItem:ILayoutDisplayObject;
		var layoutData:VerticalLayoutData;
		var percentHeight:Float;
		var feathersItem:IFeathersControl;
		for(i in 0...itemCount)
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
					percentHeight = layoutData.percentHeight;
					if (percentHeight == percentHeight) //!isNaN
					{
						if (percentHeight < 0)
						{
							percentHeight = 0;
						}
						if (Std.isOfType(layoutItem, IFeathersControl))
						{
							feathersItem = cast layoutItem;
							totalMinHeight += feathersItem.minHeight;
						}
						totalPercentHeight += percentHeight;
						totalExplicitHeight += this._gap;
						this._discoveredItemsCache[pushIndex] = item;
						pushIndex++;
						continue;
					}
				}
			}
			totalExplicitHeight += item.height + this._gap;
		}
		totalExplicitHeight -= this._gap;
		if (this._firstGap == this._firstGap && itemCount > 1)
		{
			totalExplicitHeight += (this._firstGap - this._gap);
		}
		else if (this._lastGap == this._lastGap && itemCount > 2)
		{
			totalExplicitHeight += (this._lastGap - this._gap);
		}
		totalExplicitHeight += this._paddingTop + this._paddingBottom;
		if (totalPercentHeight < 100)
		{
			totalPercentHeight = 100;
		}
		if (remainingHeight != remainingHeight) //isNaN
		{
			remainingHeight = totalExplicitHeight + totalMinHeight;
			if (remainingHeight < minHeight)
			{
				remainingHeight = minHeight;
			}
			else if (remainingHeight > maxHeight)
			{
				remainingHeight = maxHeight;
			}
		}
		remainingHeight -= totalExplicitHeight;
		if (remainingHeight < 0)
		{
			remainingHeight = 0;
		}
		var needsAnotherPass:Bool;
		var percentToPixels:Float;
		var itemHeight:Float;
		do
		{
			needsAnotherPass = false;
			percentToPixels = remainingHeight / totalPercentHeight;
			for(i in 0...pushIndex)
			{
				layoutItem = cast this._discoveredItemsCache[i];
				if (layoutItem == null)
				{
					continue;
				}
				layoutData = cast layoutItem.layoutData;
				percentHeight = layoutData.percentHeight;
				if (percentHeight < 0)
				{
					percentHeight = 0;
				}
				itemHeight = percentToPixels * percentHeight;
				if (Std.isOfType(layoutItem, IFeathersControl))
				{
					feathersItem = cast layoutItem;
					var itemMinHeight:Float = feathersItem.explicitMinHeight;
					if (itemMinHeight > remainingHeight)
					{
						//we try to respect the item's minimum height, but
						//if it's larger than the remaining space, we need
						//to force it to fit
						itemMinHeight = remainingHeight;
					}
					if (itemHeight < itemMinHeight)
					{
						itemHeight = itemMinHeight;
						remainingHeight -= itemHeight;
						totalPercentHeight -= percentHeight;
						this._discoveredItemsCache[i] = null;
						needsAnotherPass = true;
					}
					//we don't check maxHeight here because it is used in
					//validateItems() for performance optimization, so it
					//isn't a real maximum
				}
				layoutItem.height = itemHeight;
				if (Std.isOfType(layoutItem, IValidating))
				{
					//changing the height of the item may cause its width
					//to change, so we need to validate. the width is needed
					//for measurement.
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
	private function calculateScrollRangeOfIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point):Void
	{
		var calculatedTypicalItemWidth:Float;
		var calculatedTypicalItemHeight:Float;
		if (this._useVirtualLayout)
		{
			this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		var headerIndicesIndex:Int = -1;
		var nextHeaderIndex:Int = -1;
		var headerCount:Int = 0;
		var lastHeaderHeight:Float = 0;
		if (this._headerIndices != null && this._stickyHeader)
		{
			headerCount = this._headerIndices.length;
			if (headerCount > 0)
			{
				headerIndicesIndex = 0;
				nextHeaderIndex = this._headerIndices[headerIndicesIndex];
			}
		}
		var hasFirstGap:Bool = this._firstGap == this._firstGap; //!isNaN
		var hasLastGap:Bool = this._lastGap == this._lastGap; //!isNaN
		var positionY:Float = y + this._paddingTop;
		var lastHeight:Float = 0;
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
				lastHeight = calculatedTypicalItemHeight;
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
				positionY += (endIndexOffset * (calculatedTypicalItemHeight + this._gap));
			}
			positionY += (startIndexOffset * (calculatedTypicalItemHeight + this._gap));
		}
		index -= (startIndexOffset + Std.int(endIndexOffset));
		var secondToLastIndex:Int = totalItemCount - 2;
		var item:DisplayObject;
		var iNormalized:Int;
		var cachedHeight:Float;
		var itemHeight:Float;
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
				cachedHeight = this._virtualCache[iNormalized];
			}
			if (this._useVirtualLayout && item == null)
			{
				if (!this._hasVariableItemDimensions ||
					cachedHeight != cachedHeight) //isNaN
				{
					lastHeight = calculatedTypicalItemHeight;
				}
				else
				{
					lastHeight = cachedHeight;
				}
			}
			else
			{
				itemHeight = item.height;
				if (this._useVirtualLayout)
				{
					if (this._hasVariableItemDimensions)
					{
						if (itemHeight != cachedHeight)
						{
							this._virtualCache[iNormalized] = itemHeight;
							this.dispatchEventWith(Event.CHANGE);
						}
					}
					else if (calculatedTypicalItemHeight >= 0)
					{
						item.height = itemHeight = calculatedTypicalItemHeight;
					}
				}
				lastHeight = itemHeight;
			}
			positionY += lastHeight + gap;
			if (nextHeaderIndex == iNormalized)
			{
				lastHeaderHeight = lastHeight;
				//if the sticky header is enabled, we need to find its index
				//we look for the first header that is visible at the top of
				//the view port. the previous one should be sticky.
				headerIndicesIndex++;
				if (headerIndicesIndex < headerCount)
				{
					nextHeaderIndex = this._headerIndices[headerIndicesIndex];
				}
			}
		}
		positionY -= (lastHeight + gap);
		result.x = positionY - height;
		if (this._stickyHeader &&
			this._headerIndices != null &&
			this._headerIndices.indexOf(index) == -1)
		{
			//if the headers are sticky, adjust the scroll range if we're
			//scrolling to an item because the sticky header should not hide
			//the item
			//unlike items, though, headers have a full scroll range
			positionY -= lastHeaderHeight;
		}
		result.y = positionY;
	}
	
	/**
	 * @private
	 */
	private function positionStickyHeader(header:DisplayObject, scrollY:Float, maxY:Float):Void
	{
		if (header == null || header.y >= scrollY)
		{
			return;
		}
		if (Std.isOfType(header, IValidating))
		{
			cast(header, IValidating).validate();
		}
		maxY -= header.height;
		if (maxY > scrollY)
		{
			maxY = scrollY;
		}
		header.y = maxY;
		//ensure that the sticky header is always on top!
		var headerParent:DisplayObjectContainer = header.parent;
		if (headerParent != null)
		{
			headerParent.setChildIndex(header, headerParent.numChildren - 1);
		}
	}
	
}