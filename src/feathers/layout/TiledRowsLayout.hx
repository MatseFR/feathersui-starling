/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;
import feathers.core.IValidating;
import feathers.utils.math.MathUtils;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;

/**
 * Positions items as tiles (equal width and height) from left to right
 * in multiple rows. Constrained to the suggested width, the tiled rows
 * layout will change in height as the number of items increases or
 * decreases.
 *
 * @see ../../../help/tiled-rows-layout.html How to use TiledRowsLayout with Feathers containers
 *
 * @productversion Feathers 1.0.0
 */
class TiledRowsLayout extends BaseTiledLayout implements IVirtualLayout implements IDragDropLayout
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
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
	override function get_requestedColumnCount():Int
	{
		//this is an override so that this class can have its own documentation.
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
	override function get_requestedRowCount():Int
	{
		//this is an override so that this class can have its own documentation.
		return this._requestedRowCount;
	}
	
	/**
	 * If the total combined height of the rows is larger than the height
	 * of the view port, the layout will be split into pages where each
	 * page is filled with the maximum number of rows that may be displayed
	 * without cutting off any items.
	 *
	 * @default feathers.layout.Direction.NONE
	 *
	 * @see feathers.layout.Direction#NONE
	 * @see feathers.layout.Direction#HORIZONTAL
	 * @see feathers.layout.Direction#VERTICAL
	 */
	override function get_paging():String
	{
		//this is an override so that this class can have its own documentation.
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
	override function get_distributeWidths():Bool
	{
		//this is an override so that this class can have its own documentation.
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
	 * <p>Note: If the <code>distributeHeights</code> property is set to
	 * <code>true</code>, the <code>useSquareTiles</code> property will be
	 * automatically changed to <code>false</code>.</p>
	 *
	 * @default false
	 *
	 * @see #requestedRowCount
	 * @see #useSquareTiles
	 */
	override function get_distributeHeights():Bool
	{
		return this._distributeHeights;
	}
	
	override function set_distributeHeights(value:Bool):Bool
	{
		super.distributeHeights = value;
		if (value)
		{
			this.useSquareTiles = false;
		}
		return value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function layout(items:Array<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult
	{
		if (result == null)
		{
			result = new LayoutBoundsResult();
		}
		if (items.length == 0)
		{
			result.contentX = 0;
			result.contentY = 0;
			result.contentWidth = this._paddingLeft + this._paddingRight;
			result.contentHeight = this._paddingTop + this._paddingBottom;
			result.viewPortWidth = result.contentWidth;
			result.viewPortHeight = result.contentHeight;
			return result;
		}
		
		//var scrollX:Float = viewPortBounds != null ? viewPortBounds.scrollX : 0;
		//var scrollY:Float = viewPortBounds != null ? viewPortBounds.scrollY : 0;
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
			this.prepareTypicalItem();
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		this.validateItems(items);
		
		this._discoveredItemsCache.resize(0);
		var itemCount:Int = items.length;
		var tileWidth:Float = 0;
		var tileHeight:Float = 0;
		var item:DisplayObject;
		if (this._useVirtualLayout)
		{
			//a virtual layout assumes that all items are the same size as
			//the typical item, so we don't need to measure every item in
			//that case
			tileWidth = calculatedTypicalItemWidth;
			tileHeight = calculatedTypicalItemHeight;
		}
		else
		{
			var itemWidth:Float;
			var itemHeight:Float;
			for (i in 0...itemCount)
			{
				item = items[i];
				if (item == null)
				{
					continue;
				}
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				itemWidth = item.width;
				itemHeight = item.height;
				if (itemWidth > tileWidth)
				{
					tileWidth = itemWidth;
				}
				if (itemHeight > tileHeight)
				{
					tileHeight = itemHeight;
				}
			}
		}
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		
		var horizontalTileCount:Int = this.calculateHorizontalTileCount(tileWidth,
			explicitWidth, maxWidth, this._paddingLeft + this._paddingRight,
			this._horizontalGap, this._requestedColumnCount, itemCount);
		var availableWidth:Float;
		if (explicitWidth == explicitWidth) //!isNaN
		{
			availableWidth = explicitWidth;
		}
		else
		{
			availableWidth = this._paddingLeft + this._paddingRight + ((tileWidth + this._horizontalGap) * horizontalTileCount) - this._horizontalGap;
			if (availableWidth < minWidth)
			{
				availableWidth = minWidth;
			}
			else if (availableWidth > maxWidth)
			{
				availableWidth = maxWidth;
			}
		}
		if (this._distributeWidths)
		{
			//distribute remaining space
			tileWidth = (availableWidth - this._paddingLeft - this._paddingRight - (horizontalTileCount * this._horizontalGap) + this._horizontalGap) / horizontalTileCount;
			if (this._useSquareTiles)
			{
				tileHeight = tileWidth;
			}
		}
		var verticalTileCount:Int = this.calculateVerticalTileCount(tileHeight,
			explicitHeight, maxHeight, this._paddingTop + this._paddingBottom,
			this._verticalGap, this._requestedRowCount, itemCount,
			horizontalTileCount, this._distributeHeights && !this._useSquareTiles);
		var availableHeight:Float;
		if (explicitHeight == explicitHeight) //!isNaN
		{
			availableHeight = explicitHeight;
		}
		else
		{
			availableHeight = this._paddingTop + this._paddingBottom + ((tileHeight + this._verticalGap) * verticalTileCount) - this._verticalGap;
			if (availableHeight < minHeight)
			{
				availableHeight = minHeight;
			}
			else if (availableHeight > maxHeight)
			{
				availableHeight = maxHeight;
			}
		}
		if (this._distributeHeights && !this._useSquareTiles)
		{
			//distribute remaining space
			tileHeight = (availableHeight - this._paddingTop - this._paddingBottom - (verticalTileCount * this._verticalGap) + this._verticalGap) / verticalTileCount;
		}
		
		var totalPageContentWidth:Float = horizontalTileCount * (tileWidth + this._horizontalGap) - this._horizontalGap + this._paddingLeft + this._paddingRight;
		var totalPageContentHeight:Float = verticalTileCount * (tileHeight + this._verticalGap) - this._verticalGap + this._paddingTop + this._paddingBottom;
		
		var startX:Float = boundsX + this._paddingLeft;
		var startY:Float = boundsY + this._paddingTop;
		
		var perPage:Int = horizontalTileCount * verticalTileCount;
		var pageIndex:Int = 0;
		var nextPageStartIndex:Int = perPage;
		var pageStartX:Float = startX;
		var positionX:Float = startX;
		var positionY:Float = startY;
		var itemIndex:Int = 0;
		var discoveredItemsCachePushIndex:Int = 0;
		var discoveredItems:Array<DisplayObject>;
		var discoveredItemsFirstIndex:Int;
		var discoveredItemsLastIndex:Int;
		var index:Int = -1;
		for (i in 0...itemCount)
		{
			index++;
			item = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
			}
			if (itemIndex != 0 && itemIndex % horizontalTileCount == 0)
			{
				positionX = pageStartX;
				positionY += tileHeight + this._verticalGap;
			}
			if (itemIndex == nextPageStartIndex)
			{
				//we're starting a new page, so handle alignment of the
				//items on the current page and update the positions
				if (this._paging != Direction.NONE)
				{
					discoveredItems = this._useVirtualLayout ? this._discoveredItemsCache : items;
					discoveredItemsFirstIndex = this._useVirtualLayout ? 0 : (itemIndex - perPage);
					discoveredItemsLastIndex = this._useVirtualLayout ? (this._discoveredItemsCache.length - 1) : (itemIndex - 1);
					this.applyHorizontalAlign(discoveredItems, discoveredItemsFirstIndex, discoveredItemsLastIndex, totalPageContentWidth, availableWidth);
					this.applyVerticalAlign(discoveredItems, discoveredItemsFirstIndex, discoveredItemsLastIndex, totalPageContentHeight, availableHeight);
					this._discoveredItemsCache.resize(0);
					discoveredItemsCachePushIndex = 0;
				}
				pageIndex++;
				nextPageStartIndex += perPage;
				
				//we can use availableWidth and availableHeight here without
				//checking if they're NaN because we will never reach a
				//new page without them already being calculated.
				if (this._paging == Direction.HORIZONTAL)
				{
					positionX = pageStartX = startX + availableWidth * pageIndex;
					positionY = startY;
				}
				else if (this._paging == Direction.VERTICAL)
				{
					positionY = startY + availableHeight * pageIndex;
				}
			}
			if (item != null)
			{
				switch (this._tileHorizontalAlign)
				{
					case HorizontalAlign.JUSTIFY:
						item.x = item.pivotX + positionX;
						item.width = tileWidth;
					
					case HorizontalAlign.LEFT:
						item.x = item.pivotX + positionX;
					
					case HorizontalAlign.RIGHT:
						item.x = item.pivotX + positionX + tileWidth - item.width;
					
					default: //center or unknown
						item.x = item.pivotX + positionX + Math.round((tileWidth - item.width) / 2);
				}
				switch (this._tileVerticalAlign)
				{
					case VerticalAlign.JUSTIFY:
						item.y = item.pivotY + positionY;
						item.height = tileHeight;
					
					case VerticalAlign.TOP:
						item.y = item.pivotY + positionY;
					
					case VerticalAlign.BOTTOM:
						item.y = item.pivotY + positionY + tileHeight - item.height;
					
					default: //middle or unknown
						item.y = item.pivotY + positionY + Math.round((tileHeight - item.height) / 2);
				}
				if (this._useVirtualLayout)
				{
					this._discoveredItemsCache[discoveredItemsCachePushIndex] = item;
					discoveredItemsCachePushIndex++;
				}
			}
			positionX += tileWidth + this._horizontalGap;
			itemIndex++;
		}
		//align the last page
		if (this._paging != Direction.NONE)
		{
			discoveredItems = this._useVirtualLayout ? this._discoveredItemsCache : items;
			discoveredItemsFirstIndex = this._useVirtualLayout ? 0 : (nextPageStartIndex - perPage);
			discoveredItemsLastIndex = this._useVirtualLayout ? (discoveredItems.length - 1) : (index - 1);
			this.applyHorizontalAlign(discoveredItems, discoveredItemsFirstIndex, discoveredItemsLastIndex, totalPageContentWidth, availableWidth);
			this.applyVerticalAlign(discoveredItems, discoveredItemsFirstIndex, discoveredItemsLastIndex, totalPageContentHeight, availableHeight);
		}
		
		var totalWidth:Float;
		if (this._paging == Direction.HORIZONTAL)
		{
			totalWidth = Math.fceil(itemCount / perPage) * availableWidth;
		}
		else //vertical or none
		{
			totalWidth = totalPageContentWidth;
		}
		var totalHeight:Float;
		if (this._paging == Direction.HORIZONTAL)
		{
			totalHeight = availableHeight;
		}
		else if (this._paging == Direction.VERTICAL)
		{
			totalHeight = Math.fceil(itemCount / perPage) * availableHeight;
		}
		else //none
		{
			totalHeight = positionY + tileHeight + this._paddingBottom;
			if (totalHeight < totalPageContentHeight)
			{
				totalHeight = totalPageContentHeight;
			}
		}
		
		if (this._paging == Direction.NONE)
		{
			discoveredItems = this._useVirtualLayout ? this._discoveredItemsCache : items;
			discoveredItemsLastIndex = discoveredItems.length - 1;
			this.applyHorizontalAlign(discoveredItems, 0, discoveredItemsLastIndex, totalWidth, availableWidth);
			this.applyVerticalAlign(discoveredItems, 0, discoveredItemsLastIndex, totalHeight, availableHeight);
		}
		this._discoveredItemsCache.resize(0);
		
		result.contentX = 0;
		result.contentY = 0;
		result.contentWidth = totalWidth;
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
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN;
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		if (!needsWidth && !needsHeight)
		{
			result.x = explicitWidth;
			result.y = explicitHeight;
			return result;
		}
		var boundsX:Float = viewPortBounds != null ? viewPortBounds.x : 0;
		var boundsY:Float = viewPortBounds != null ? viewPortBounds.y : 0;
		var minWidth:Float = viewPortBounds != null ? viewPortBounds.minWidth : 0;
		var minHeight:Float = viewPortBounds != null ? viewPortBounds.minHeight : 0;
		var maxWidth:Float = viewPortBounds != null ? viewPortBounds.maxWidth : Math.POSITIVE_INFINITY;
		var maxHeight:Float = viewPortBounds != null ? viewPortBounds.maxHeight : Math.POSITIVE_INFINITY;
		
		this.prepareTypicalItem();
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var tileWidth:Float = calculatedTypicalItemWidth;
		var tileHeight:Float = calculatedTypicalItemHeight;
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		
		var horizontalTileCount:Int = this.calculateHorizontalTileCount(tileWidth,
			explicitWidth, maxWidth, this._paddingLeft + this._paddingRight,
			this._horizontalGap, this._requestedColumnCount, itemCount);
		var verticalTileCount:Int = this.calculateVerticalTileCount(tileHeight,
			explicitHeight, maxHeight, this._paddingTop + this._paddingBottom,
			this._verticalGap, this._requestedRowCount, itemCount,
			horizontalTileCount, this._distributeHeights && !this._useSquareTiles);
		var availableWidth:Float;
		if (explicitWidth == explicitWidth) //!isNaN
		{
			availableWidth = explicitWidth;
		}
		else
		{
			availableWidth = this._paddingLeft + this._paddingRight + ((tileWidth + this._horizontalGap) * horizontalTileCount) - this._horizontalGap;
			if (availableWidth < minWidth)
			{
				availableWidth = minWidth;
			}
			else if (availableWidth > maxWidth)
			{
				availableWidth = maxWidth;
			}
		}
		var availableHeight:Float;
		if (explicitHeight == explicitHeight) //!isNaN
		{
			availableHeight = explicitHeight;
		}
		else
		{
			availableHeight = this._paddingTop + this._paddingBottom + ((tileHeight + this._verticalGap) * verticalTileCount) - this._verticalGap;
			if (availableHeight < minHeight)
			{
				availableHeight = minHeight;
			}
			else if (availableHeight > maxHeight)
			{
				availableHeight = maxHeight;
			}
		}
		
		var totalPageContentWidth:Float = horizontalTileCount * (tileWidth + this._horizontalGap) - this._horizontalGap + this._paddingLeft + this._paddingRight;
		var totalPageContentHeight:Float = verticalTileCount * (tileHeight + this._verticalGap) - this._verticalGap + this._paddingTop + this._paddingBottom;
		
		var startX:Float = boundsX + this._paddingLeft;
		var startY:Float = boundsY + this._paddingTop;
		
		var perPage:Int = horizontalTileCount * verticalTileCount;
		var pageIndex:Int = 0;
		var nextPageStartIndex:Int = perPage;
		var pageStartX:Float = startX;
		var positionX:Float = startX;
		var positionY:Float = startY;
		for (i in 0...itemCount)
		{
			if (i != 0 && i % horizontalTileCount == 0)
			{
				positionX = pageStartX;
				positionY += tileHeight + this._verticalGap;
			}
			if (i == nextPageStartIndex)
			{
				pageIndex++;
				nextPageStartIndex += perPage;
				
				//we can use availableWidth and availableHeight here without
				//checking if they're NaN because we will never reach a
				//new page without them already being calculated.
				if (this._paging == Direction.HORIZONTAL)
				{
					positionX = pageStartX = startX + availableWidth * pageIndex;
					positionY = startY;
				}
				else if (this._paging == Direction.VERTICAL)
				{
					positionY = startY + availableHeight * pageIndex;
				}
			}
		}
		
		var totalWidth:Float;
		if (this._paging == Direction.HORIZONTAL)
		{
			totalWidth = Math.fceil(itemCount / perPage) * availableWidth;
		}
		else
		{
			totalWidth = totalPageContentWidth;
		}
		var totalHeight:Float;
		if (this._paging == Direction.HORIZONTAL)
		{
			totalHeight = availableHeight;
		}
		else if (this._paging == Direction.VERTICAL)
		{
			totalHeight = Math.fceil(itemCount / perPage) * availableHeight;
		}
		else
		{
			totalHeight = positionY + tileHeight + this._paddingBottom;
			if (totalHeight < totalPageContentHeight)
			{
				totalHeight = totalPageContentHeight;
			}
		}
		
		var resultX:Float;
		if (needsWidth)
		{
			resultX = totalWidth;
			if (resultX < minWidth)
			{
				resultX = minWidth;
			}
			else if (resultX > maxWidth)
			{
				resultX = maxWidth;
			}
			result.x = resultX;
		}
		else
		{
			result.x = explicitWidth;
		}
		var resultY:Float;
		if (needsHeight)
		{
			resultY = totalHeight;
			if (resultY < minHeight)
			{
				resultY = minHeight;
			}
			else if (resultY > maxHeight)
			{
				resultY = maxHeight;
			}
			result.y = resultY;
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
		
		if (this._paging == Direction.HORIZONTAL)
		{
			this.getVisibleIndicesAtScrollPositionWithHorizontalPaging(scrollX, scrollY, width, height, itemCount, result);
		}
		else if (this._paging == Direction.VERTICAL)
		{
			this.getVisibleIndicesAtScrollPositionWithVerticalPaging(scrollX, scrollY, width, height, itemCount, result);
		}
		else //none
		{
			this.getVisibleIndicesAtScrollPositionWithoutPaging(scrollX, scrollY, width, height, itemCount, result);
		}
		
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function calculateNavigationDestination(items:Array<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int
	{
		var itemCount:Int = items.length;
		if (keyCode == Keyboard.HOME)
		{
			return 0;
		}
		else if (keyCode == Keyboard.END)
		{
			return itemCount - 1;
		}
		
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			this.prepareTypicalItem();
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		this.validateItems(items);
		
		this._discoveredItemsCache.resize(0);
		var tileWidth:Float = 0;
		var tileHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			//a virtual layout assumes that all items are the same size as
			//the typical item, so we don't need to measure every item in
			//that case
			tileWidth = calculatedTypicalItemWidth;
			tileHeight = calculatedTypicalItemHeight;
		}
		else
		{
			var item:DisplayObject;
			var itemWidth:Float;
			var itemHeight:Float;
			for (i in 0...itemCount)
			{
				item = items[i];
				if (item == null)
				{
					continue;
				}
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				itemWidth = item.width;
				itemHeight = item.height;
				if (itemWidth > tileWidth)
				{
					tileWidth = itemWidth;
				}
				if (itemHeight > tileHeight)
				{
					tileHeight = itemHeight;
				}
			}
		}
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		
		var availableWidth:Float = bounds.viewPortWidth;
		var horizontalTileCount:Int = this.calculateHorizontalTileCount(tileWidth,
			availableWidth, Math.POSITIVE_INFINITY, this._paddingLeft + this._paddingRight,
			this._horizontalGap, this._requestedColumnCount, itemCount);
		var pageHorizontalTileCount:Int = horizontalTileCount;
		var pageVerticalTileCount:Int = this.calculateVerticalTileCount(tileHeight,
			bounds.viewPortHeight, Math.POSITIVE_INFINITY, this._paddingTop + this._paddingBottom,
			this._verticalGap, this._requestedRowCount, itemCount,
			pageHorizontalTileCount, this._distributeHeights && !this._useSquareTiles);
		var verticalTileCount:Int = Math.ceil(itemCount / horizontalTileCount);
		var rowIndex:Int = Std.int(index / pageHorizontalTileCount);
		var columnIndex:Int = index % pageHorizontalTileCount;
		if (this._paging == Direction.HORIZONTAL)
		{
			verticalTileCount = pageVerticalTileCount;
			var perPage:Float = pageHorizontalTileCount * pageVerticalTileCount;
			var pageCount:Int = Math.ceil(itemCount / perPage);
			horizontalTileCount *= pageCount;
			while (rowIndex >= verticalTileCount)
			{
				rowIndex -= verticalTileCount;
				columnIndex += pageHorizontalTileCount;
			}
		}
		
		if (keyCode == Keyboard.PAGE_UP)
		{
			if (this._paging == Direction.HORIZONTAL)
			{
				columnIndex -= pageHorizontalTileCount;
			}
			else
			{
				rowIndex -= pageVerticalTileCount;
			}
		}
		else if (keyCode == Keyboard.PAGE_DOWN)
		{
			if (this._paging == Direction.HORIZONTAL)
			{
				columnIndex += pageHorizontalTileCount;
			}
			else
			{
				rowIndex += pageVerticalTileCount;
			}
		}
		else if (keyCode == Keyboard.UP)
		{
			rowIndex--;
		}
		else if (keyCode == Keyboard.DOWN)
		{
			rowIndex++;
		}
		else if (keyCode == Keyboard.LEFT)
		{
			columnIndex--;
		}
		else if (keyCode == Keyboard.RIGHT)
		{
			columnIndex++;
		}
		if (rowIndex < 0)
		{
			rowIndex = 0;
		}
		else if (rowIndex >= verticalTileCount)
		{
			rowIndex = verticalTileCount - 1;
		}
		if (columnIndex < 0)
		{
			columnIndex = 0;
		}
		else if (columnIndex >= horizontalTileCount)
		{
			columnIndex = horizontalTileCount - 1;
		}
		if (this._paging == Direction.HORIZONTAL)
		{
			while (columnIndex >= pageHorizontalTileCount)
			{
				columnIndex -= pageHorizontalTileCount;
				rowIndex += verticalTileCount;
			}
		}
		var result:Int = rowIndex * pageHorizontalTileCount + columnIndex;
		if (result >= itemCount)
		{
			//nothing at this column on the next row
			result = itemCount - 1;
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		return this.calculateScrollPositionForIndex(index, items, x, y, width, height, result, true, scrollX, scrollY);
	}

	/**
	 * @inheritDoc
	 */
	public function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		return this.calculateScrollPositionForIndex(index, items, x, y, width, height, result, false);
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
			this.prepareTypicalItem();
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var itemCount:Int = items.length;
		var tileWidth:Float = this._useVirtualLayout ? calculatedTypicalItemWidth : 0;
		var tileHeight:Float = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
		//a virtual layout assumes that all items are the same size as
		//the typical item, so we don't need to measure every item in
		//that case
		var item:DisplayObject;
		if (!this._useVirtualLayout)
		{
			var itemWidth:Float;
			var itemHeight:Float;
			for (i in 0...itemCount)
			{
				item = items[i];
				if (item == null)
				{
					continue;
				}
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				itemWidth = item.width;
				itemHeight = item.height;
				if (itemWidth > tileWidth)
				{
					tileWidth = itemWidth;
				}
				if (itemHeight > tileHeight)
				{
					tileHeight = itemHeight;
				}
			}
		}
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		var horizontalTileCount:Int = Std.int((width - this._paddingLeft - this._paddingRight + this._horizontalGap) / (tileWidth + this._horizontalGap));
		if (horizontalTileCount < 1)
		{
			horizontalTileCount = 1;
		}
		else if (this._requestedColumnCount > 0 && horizontalTileCount > this._requestedColumnCount)
		{
			horizontalTileCount = this._requestedColumnCount;
		}
		var verticalTileCount:Int = Std.int((height - this._paddingTop - this._paddingBottom + this._verticalGap) / (tileHeight + this._verticalGap));
		if (verticalTileCount < 1)
		{
			verticalTileCount = 1;
		}
		else if (this._requestedRowCount > 0 && verticalTileCount > this._requestedRowCount)
		{
			verticalTileCount = this._requestedRowCount;
		}
		var perPage:Int = horizontalTileCount * verticalTileCount;
		var startX:Float = boundsX + this._paddingLeft;
		var actualHorizontalTileCount:Int = horizontalTileCount;
		if (actualHorizontalTileCount > itemCount)
		{
			actualHorizontalTileCount = itemCount;
		}
		if (this._horizontalAlign == HorizontalAlign.RIGHT)
		{
			startX = boundsX + this._paddingLeft + (width - this._paddingLeft - this._paddingRight) -
				((actualHorizontalTileCount * (tileWidth + this._horizontalGap)) - this._horizontalGap);
		}
		else if (this._horizontalAlign == HorizontalAlign.CENTER)
		{
			startX = boundsX + this._paddingLeft + ((width - this._paddingLeft - this._paddingRight) -
				((actualHorizontalTileCount * (tileWidth + this._horizontalGap)) - this._horizontalGap)) / 2;
		}
		var startY:Float = boundsY + this._paddingTop;
		if (this._paging != Direction.NONE || itemCount <= perPage)
		{
			var actualVerticalTileCount:Int = verticalTileCount;
			if (itemCount <= perPage)
			{
				actualVerticalTileCount = Math.ceil(itemCount / actualHorizontalTileCount);
			}
			if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				startY = boundsY + this._paddingTop + (height - this._paddingTop - this._paddingBottom) -
					((actualVerticalTileCount * (tileHeight + this._verticalGap)) - this._verticalGap);
			}
			else if (this._verticalAlign == VerticalAlign.MIDDLE)
			{
				startY = boundsY + this._paddingTop + ((height - this._paddingTop - this._paddingBottom) -
					((actualVerticalTileCount * (tileHeight + this._verticalGap)) - this._verticalGap)) / 2;
			}
		}
		var pageIndex:Int = 0;
		var rowIndex:Int = 0;
		var lastRowIndex:Int = Std.int((itemCount - 1) / horizontalTileCount);
		var nextPageStartIndex:Int = perPage;
		var pageStartX:Float = startX;
		var positionX:Float = startX;
		var positionY:Float = startY;
		var index:Int = -1;
		for (i in 0...itemCount)
		{
			index++;
			item = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
			}
			if (i != 0 && i % horizontalTileCount == 0)
			{
				if ((x < (pageStartX + width)) &&
					(y < (positionY + tileHeight + (this._verticalGap / 2))))
				{
					//we're at the end of the previous row (but we also make
					//sure that we're not on the next page)
					return i;
				}
				positionX = pageStartX;
				positionY += tileHeight + this._verticalGap;
				rowIndex++;
			}
			if (i == nextPageStartIndex)
			{
				pageIndex++;
				nextPageStartIndex += perPage;
				
				//we can use availableWidth and availableHeight here without
				//checking if they're NaN because we will never reach a
				//new page without them already being calculated.
				if (this._paging == Direction.HORIZONTAL)
				{
					positionX = pageStartX = startX + width * pageIndex;
					positionY = startY;
				}
				else if (this._paging == Direction.VERTICAL)
				{
					positionY = startY + height * pageIndex;
				}
			}
			if ((x < (positionX + (tileWidth / 2))) &&
				((y < (positionY + tileHeight + (this._verticalGap / 2))) || (rowIndex == lastRowIndex)))
			{
				return i;
			}
			positionX += tileWidth + this._horizontalGap;
		}
		return index;
	}
	
	/**
	 * @inheritDoc
	 */
	public function positionDropIndicator(dropIndicator:DisplayObject, index:Int,
		x:Float, y:Float, items:Array<DisplayObject>, width:Float, height:Float):Void
	{
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			this.prepareTypicalItem();
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var itemCount:Int = items.length;
		var tileWidth:Float = this._useVirtualLayout ? calculatedTypicalItemWidth : 0;
		var tileHeight:Float = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
		//a virtual layout assumes that all items are the same size as
		//the typical item, so we don't need to measure every item in
		//that case
		var item:DisplayObject;
		if (!this._useVirtualLayout)
		{
			var itemWidth:Float;
			var itemHeight:Float;
			for (i in 0...itemCount)
			{
				item = items[i];
				if (item == null)
				{
					continue;
				}
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				itemWidth = item.width;
				itemHeight = item.height;
				if (itemWidth > tileWidth)
				{
					tileWidth = itemWidth;
				}
				if (itemHeight > tileHeight)
				{
					tileHeight = itemHeight;
				}
			}
		}
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		var horizontalTileCount:Int = Std.int((width - this._paddingLeft - this._paddingRight + this._horizontalGap) / (tileWidth + this._horizontalGap));
		if (horizontalTileCount < 1)
		{
			horizontalTileCount = 1;
		}
		else if (this._requestedColumnCount > 0 && horizontalTileCount > this._requestedColumnCount)
		{
			horizontalTileCount = this._requestedColumnCount;
		}
		var verticalTileCount:Int = Std.int((height - this._paddingTop - this._paddingBottom + this._verticalGap) / (tileHeight + this._verticalGap));
		if (verticalTileCount < 1)
		{
			verticalTileCount = 1;
		}
		else if (this._requestedRowCount > 0 && verticalTileCount > this._requestedRowCount)
		{
			verticalTileCount = this._requestedRowCount;
		}
		var perPage:Int = horizontalTileCount * verticalTileCount;
		var startX:Float = this._paddingLeft;
		var actualHorizontalTileCount:Int = horizontalTileCount;
		if (actualHorizontalTileCount > itemCount)
		{
			actualHorizontalTileCount = itemCount;
		}
		if (this._horizontalAlign == HorizontalAlign.RIGHT)
		{
			startX = this._paddingLeft + (width - this._paddingLeft - this._paddingRight) -
				((actualHorizontalTileCount * (tileWidth + this._horizontalGap)) - this._horizontalGap);
		}
		else if (this._horizontalAlign == HorizontalAlign.CENTER)
		{
			startX = this._paddingLeft + ((width - this._paddingLeft - this._paddingRight) -
				((actualHorizontalTileCount * (tileWidth + this._horizontalGap)) - this._horizontalGap)) / 2;
		}
		var startY:Float = this._paddingTop;
		if (this._paging != Direction.NONE || itemCount <= perPage)
		{
			var actualVerticalTileCount:Int = verticalTileCount;
			if (itemCount <= perPage)
			{
				actualVerticalTileCount = Math.ceil(itemCount / actualHorizontalTileCount);
			}
			if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				startY = this._paddingTop + (height - this._paddingTop - this._paddingBottom) -
					((actualVerticalTileCount * (tileHeight + this._verticalGap)) - this._verticalGap);
			}
			else if (this._verticalAlign == VerticalAlign.MIDDLE)
			{
				startY = this._paddingTop + ((height - this._paddingTop - this._paddingBottom) -
					((actualVerticalTileCount * (tileHeight + this._verticalGap)) - this._verticalGap)) / 2;
			}
		}
		var pageIndex:Int = 0;
		var rowIndex:Int = 0;
		var lastRowIndex:Int = Std.int((itemCount - 1) / horizontalTileCount);
		var nextPageStartIndex:Int = perPage;
		var pageStartX:Float = startX;
		var positionX:Float = startX;
		var positionY:Float = startY;
		var rowItemCount:Int = 0;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
			}
			if (i != 0 && i % horizontalTileCount == 0)
			{
				//start of a new row
				positionX = pageStartX;
				positionY += tileHeight + this._verticalGap;
				rowItemCount = 0;
				rowIndex++;
			}
			if (i == nextPageStartIndex)
			{
				//start of a new page
				pageIndex++;
				nextPageStartIndex += perPage;
				if (this._paging == Direction.HORIZONTAL)
				{
					positionX = pageStartX = startX + width * pageIndex;
					positionY = startY;
				}
				else if (this._paging == Direction.VERTICAL)
				{
					positionY = startY + height * pageIndex;
				}
			}
			if ((x < (positionX + (tileWidth / 2))) &&
				((y < (positionY + tileHeight + (this._verticalGap / 2))) || (rowIndex == lastRowIndex)))
			{
				dropIndicator.x = positionX - dropIndicator.width / 2;
				dropIndicator.y = positionY;
				dropIndicator.height = tileHeight;
				return;
			}
			positionX += tileWidth + this._horizontalGap;
			
			if (rowItemCount > 0 &&
				(x < (positionX + (tileWidth / 2))) &&
				(x < (pageStartX + width)) && //not on next page
				(positionX + tileWidth) > (width - this._paddingRight) &&
				(y < (positionY + tileHeight + (this._verticalGap / 2))))
			{
				//index on next row, but position drop indicator at the end
				//of the current row
				dropIndicator.x = positionX - this._horizontalGap - dropIndicator.width / 2;
				dropIndicator.y = positionY;
				dropIndicator.height = tileHeight;
				return;
			}
			rowItemCount++;
		}
		dropIndicator.x = positionX - dropIndicator.width / 2;
		dropIndicator.y = positionY;
		dropIndicator.height = tileHeight;
	}
	
	/**
	 * @private
	 */
	private function applyHorizontalAlign(items:Array<DisplayObject>, startIndex:Int, endIndex:Int, totalItemWidth:Float, availableWidth:Float):Void
	{
		if (totalItemWidth >= availableWidth)
		{
			return;
		}
		var horizontalAlignOffsetX:Float = 0;
		if (this._horizontalAlign == HorizontalAlign.RIGHT)
		{
			horizontalAlignOffsetX = availableWidth - totalItemWidth;
		}
		else if (this._horizontalAlign != HorizontalAlign.LEFT)
		{
			//we're going to default to center if we encounter an
			//unknown value
			horizontalAlignOffsetX = Math.fround((availableWidth - totalItemWidth) / 2);
		}
		if (horizontalAlignOffsetX != 0)
		{
			var item:DisplayObject;
			for (i in startIndex...endIndex+1)
			{
				item = items[i];
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				item.x += horizontalAlignOffsetX;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function applyVerticalAlign(items:Array<DisplayObject>, startIndex:Int, endIndex:Int, totalItemHeight:Float, availableHeight:Float):Void
	{
		if (totalItemHeight >= availableHeight)
		{
			return;
		}
		var verticalAlignOffsetY:Float = 0;
		if (this._verticalAlign == VerticalAlign.BOTTOM)
		{
			verticalAlignOffsetY = availableHeight - totalItemHeight;
		}
		else if (this._verticalAlign == VerticalAlign.MIDDLE)
		{
			verticalAlignOffsetY = Math.round((availableHeight - totalItemHeight) / 2);
		}
		if (verticalAlignOffsetY != 0)
		{
			var item:DisplayObject;
			for (i in startIndex...endIndex+1)
			{
				item = items[i];
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				item.y += verticalAlignOffsetY;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function getVisibleIndicesAtScrollPositionWithHorizontalPaging(scrollX:Float, scrollY:Float, width:Float, height:Float, itemCount:Int, result:Array<Int>):Void
	{
		this.prepareTypicalItem();
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var tileWidth:Float = calculatedTypicalItemWidth;
		var tileHeight:Float = calculatedTypicalItemHeight;
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		var horizontalTileCount:Int = this.calculateHorizontalTileCount(tileWidth,
			width, width, this._paddingLeft + this._paddingRight,
			this._horizontalGap, this._requestedColumnCount, itemCount);
		if (this._distributeWidths)
		{
			tileWidth = (width - this._paddingLeft - this._paddingRight - (horizontalTileCount * this._horizontalGap) + this._horizontalGap) / horizontalTileCount;
			if (this._useSquareTiles)
			{
				tileHeight = tileWidth;
			}
		}
		var verticalTileCount:Int = this.calculateVerticalTileCount(tileHeight,
			height, height, this._paddingTop + this._paddingBottom,
			this._verticalGap, this._requestedRowCount, itemCount,
			horizontalTileCount, this._distributeHeights && !this._useSquareTiles);
		if (this._distributeHeights && !this._useSquareTiles)
		{
			tileHeight = (height - this._paddingTop - this._paddingBottom - (verticalTileCount * this._verticalGap) + this._verticalGap) / verticalTileCount;
		}
		var perPage:Int = horizontalTileCount * verticalTileCount;
		var minimumItemCount:Int = perPage + 2 * verticalTileCount;
		if (minimumItemCount > itemCount)
		{
			minimumItemCount = itemCount;
		}
		
		var startPageIndex:Int = Math.round(scrollX / width);
		var minimum:Int = startPageIndex * perPage;
		var totalRowWidth:Float = horizontalTileCount * (tileWidth + this._horizontalGap) - this._horizontalGap;
		var leftSideOffset:Float = 0;
		var rightSideOffset:Float = 0;
		if (totalRowWidth < width)
		{
			if (this._horizontalAlign == HorizontalAlign.RIGHT)
			{
				leftSideOffset = width - this._paddingLeft - this._paddingRight - totalRowWidth;
				rightSideOffset = 0;
			}
			else if (this._horizontalAlign == HorizontalAlign.CENTER)
			{
				leftSideOffset = rightSideOffset = Math.round((width - this._paddingLeft - this._paddingRight - totalRowWidth) / 2);
			}
			else //left
			{
				leftSideOffset = 0;
				rightSideOffset = width - this._paddingLeft - this._paddingRight - totalRowWidth;
			}
		}
		var columnOffset:Int = 0;
		var pageStartPosition:Float = startPageIndex * width;
		var partialPageSize:Float = scrollX - pageStartPosition;
		if (partialPageSize < 0)
		{
			partialPageSize = -partialPageSize - this._paddingRight - rightSideOffset;
			if (partialPageSize < 0)
			{
				partialPageSize = 0;
			}
			columnOffset = -Math.floor(partialPageSize / (tileWidth + this._horizontalGap)) - 1;
			minimum += -perPage + horizontalTileCount + columnOffset;
		}
		else if (partialPageSize > 0)
		{
			partialPageSize = partialPageSize - this._paddingLeft - leftSideOffset;
			if (partialPageSize < 0)
			{
				partialPageSize = 0;
			}
			columnOffset = Math.floor(partialPageSize / (tileWidth + this._horizontalGap));
			minimum += columnOffset;
		}
		if (minimum < 0)
		{
			minimum = 0;
			columnOffset = 0;
		}
		if (minimum + minimumItemCount >= itemCount)
		{
			var resultPushIndex:Int = result.length;
			//an optimized path when we're on or near the last page
			minimum = itemCount - minimumItemCount;
			for (i in minimum...itemCount)
			{
				result[resultPushIndex] = i;
				resultPushIndex++;
			}
		}
		else
		{
			var rowIndex:Int = 0;
			var columnIndex:Int = (horizontalTileCount + columnOffset) % horizontalTileCount;
			var pageStart:Int = Std.int(minimum / perPage) * perPage;
			var i:Int = minimum;
			var resultLength:Int = 0;
			do
			{
				if (i < itemCount)
				{
					result[resultLength] = i;
					resultLength++;
				}
				rowIndex++;
				if (rowIndex == verticalTileCount)
				{
					rowIndex = 0;
					columnIndex++;
					if (columnIndex == horizontalTileCount)
					{
						columnIndex = 0;
						pageStart += perPage;
					}
					i = pageStart + columnIndex - horizontalTileCount;
				}
				i += horizontalTileCount;
			}
			while (resultLength < minimumItemCount && pageStart < itemCount);
		}
	}
	
	/**
	 * @private
	 */
	private function getVisibleIndicesAtScrollPositionWithVerticalPaging(scrollX:Float, scrollY:Float, width:Float, height:Float, itemCount:Int, result:Array<Int>):Void
	{
		this.prepareTypicalItem();
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var tileWidth:Float = calculatedTypicalItemWidth;
		var tileHeight:Float = calculatedTypicalItemHeight;
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		var horizontalTileCount:Int = this.calculateHorizontalTileCount(tileWidth,
			width, width, this._paddingLeft + this._paddingRight,
			this._horizontalGap, this._requestedColumnCount, itemCount);
		if (this._distributeWidths)
		{
			tileWidth = (width - this._paddingLeft - this._paddingRight - (horizontalTileCount * this._horizontalGap) + this._horizontalGap) / horizontalTileCount;
			if (this._useSquareTiles)
			{
				tileHeight = tileWidth;
			}
		}
		var verticalTileCount:Int = this.calculateVerticalTileCount(tileHeight,
			height, height, this._paddingTop + this._paddingBottom,
			this._verticalGap, this._requestedRowCount, itemCount,
			horizontalTileCount, this._distributeHeights && !this._useSquareTiles);
		if (this._distributeHeights && !this._useSquareTiles)
		{
			tileHeight = (height - this._paddingTop - this._paddingBottom - (verticalTileCount * this._verticalGap) + this._verticalGap) / verticalTileCount;
		}
		var perPage:Int = horizontalTileCount * verticalTileCount;
		var minimumItemCount:Int = perPage + 2 * horizontalTileCount;
		if (minimumItemCount > itemCount)
		{
			minimumItemCount = itemCount;
		}
		
		var startPageIndex:Int = Math.round(scrollY / height);
		var minimum:Int = startPageIndex * perPage;
		var totalColumnHeight:Float = verticalTileCount * (tileHeight + this._verticalGap) - this._verticalGap;
		var topSideOffset:Float = 0;
		var bottomSideOffset:Float = 0;
		if (totalColumnHeight < height)
		{
			if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				topSideOffset = height - this._paddingTop - this._paddingBottom - totalColumnHeight;
				bottomSideOffset = 0;
			}
			else if (this._verticalAlign == VerticalAlign.MIDDLE)
			{
				topSideOffset = bottomSideOffset = Math.round((height - this._paddingTop - this._paddingBottom - totalColumnHeight) / 2);
			}
			else //top
			{
				topSideOffset = 0;
				bottomSideOffset = height - this._paddingTop - this._paddingBottom - totalColumnHeight;
			}
		}
		var rowOffset:Int = 0;
		var pageStartPosition:Float = startPageIndex * height;
		var partialPageSize:Float = scrollY - pageStartPosition;
		if (partialPageSize < 0)
		{
			partialPageSize = -partialPageSize - this._paddingBottom - bottomSideOffset;
			if (partialPageSize < 0)
			{
				partialPageSize = 0;
			}
			rowOffset = -Math.floor(partialPageSize / (tileHeight + this._verticalGap)) - 1;
			minimum += horizontalTileCount * rowOffset;
		}
		else if (partialPageSize > 0)
		{
			partialPageSize = partialPageSize - this._paddingTop - topSideOffset;
			if (partialPageSize < 0)
			{
				partialPageSize = 0;
			}
			rowOffset = Math.floor(partialPageSize / (tileHeight + this._verticalGap));
			minimum += horizontalTileCount * rowOffset;
		}
		if (minimum < 0)
		{
			minimum = 0;
			rowOffset = 0;
		}
		
		var maximum:Int = minimum + minimumItemCount;
		if (maximum > itemCount)
		{
			maximum = itemCount;
		}
		minimum = maximum - minimumItemCount;
		var resultPushIndex:Int = result.length;
		for (i in minimum...maximum)
		{
			result[resultPushIndex] = i;
			resultPushIndex++;
		}
	}
	
	/**
	 * @private
	 */
	private function getVisibleIndicesAtScrollPositionWithoutPaging(scrollX:Float, scrollY:Float, width:Float, height:Float, itemCount:Int, result:Array<Int>):Void
	{
		this.prepareTypicalItem();
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		var tileWidth:Float = calculatedTypicalItemWidth;
		var tileHeight:Float = calculatedTypicalItemHeight;
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		var horizontalTileCount:Int = this.calculateHorizontalTileCount(tileWidth,
			width, width, this._paddingLeft + this._paddingRight,
			this._horizontalGap, this._requestedColumnCount, itemCount);
		if (this._distributeWidths)
		{
			tileWidth = (width - this._paddingLeft - this._paddingRight - (horizontalTileCount * this._horizontalGap) + this._horizontalGap) / horizontalTileCount;
			if (this._useSquareTiles)
			{
				tileHeight = tileWidth;
			}
		}
		var verticalTileCount:Int;
		if (this._distributeHeights && !this._useSquareTiles)
		{
			verticalTileCount = this.calculateVerticalTileCount(tileHeight,
				height, height, this._paddingTop + this._paddingBottom,
				this._verticalGap, this._requestedRowCount, itemCount,
				horizontalTileCount, this._distributeHeights && !this._useSquareTiles);
			tileHeight = (height - this._paddingTop - this._paddingBottom - (verticalTileCount * this._verticalGap) + this._verticalGap) / verticalTileCount;
		}
		verticalTileCount = Math.ceil((height + this._verticalGap) / (tileHeight + this._verticalGap)) + 1;
		var minimumItemCount:Int = verticalTileCount * horizontalTileCount;
		if (minimumItemCount > itemCount)
		{
			minimumItemCount = itemCount;
		}
		var rowIndexOffset:Int = 0;
		var totalRowHeight:Float = Math.fceil(itemCount / horizontalTileCount) * (tileHeight + this._verticalGap) - this._verticalGap;
		if (totalRowHeight < height)
		{
			if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				rowIndexOffset = Math.ceil((height - totalRowHeight) / (tileHeight + this._verticalGap));
			}
			else if (this._verticalAlign == VerticalAlign.MIDDLE)
			{
				rowIndexOffset = Math.ceil((height - totalRowHeight) / (tileHeight + this._verticalGap) / 2);
			}
		}
		var rowIndex:Int = -rowIndexOffset + Math.floor((scrollY - this._paddingTop + this._verticalGap) / (tileHeight + this._verticalGap));
		var minimum:Int = rowIndex * horizontalTileCount;
		if (minimum < 0)
		{
			minimum = 0;
		}
		var maximum:Int = minimum + minimumItemCount;
		if (maximum > itemCount)
		{
			maximum = itemCount;
		}
		minimum = maximum - minimumItemCount;
		var resultPushIndex:Int = result.length;
		for (i in minimum...maximum)
		{
			result[resultPushIndex] = i;
			resultPushIndex++;
		}
	}
	
	/**
	 * @private
	 */
	private function validateItems(items:Array<DisplayObject>):Void
	{
		var itemCount:Int = items.length;
		var item:DisplayObject;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
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
	private function prepareTypicalItem():Void
	{
		if (this._typicalItem == null)
		{
			return;
		}
		if (this._resetTypicalItemDimensionsOnMeasure)
		{
			this._typicalItem.width = this._typicalItemWidth;
			this._typicalItem.height = this._typicalItemHeight;
		}
		if (Std.isOfType(this._typicalItem, IValidating))
		{
			cast(this._typicalItem, IValidating).validate();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function calculateScrollPositionForIndex(index:Int, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null,
		nearest:Bool = false, scrollX:Float = 0, scrollY:Float = 0):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			this.prepareTypicalItem();
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var itemCount:Int = items.length;
		var tileWidth:Float = this._useVirtualLayout ? calculatedTypicalItemWidth : 0;
		var tileHeight:Float = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
		//a virtual layout assumes that all items are the same size as
		//the typical item, so we don't need to measure every item in
		//that case
		if (!this._useVirtualLayout)
		{
			var item:DisplayObject;
			var itemWidth:Float;
			var itemHeight:Float;
			for (i in 0...itemCount)
			{
				item = items[i];
				if (item == null)
				{
					continue;
				}
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				itemWidth = item.width;
				itemHeight = item.height;
				if (itemWidth > tileWidth)
				{
					tileWidth = itemWidth;
				}
				if (itemHeight > tileHeight)
				{
					tileHeight = itemHeight;
				}
			}
		}
		if (tileWidth < 0)
		{
			tileWidth = 0;
		}
		if (tileHeight < 0)
		{
			tileHeight = 0;
		}
		if (this._useSquareTiles)
		{
			if (tileWidth > tileHeight)
			{
				tileHeight = tileWidth;
			}
			else if (tileHeight > tileWidth)
			{
				tileWidth = tileHeight;
			}
		}
		var horizontalTileCount:Int = Std.int((width - this._paddingLeft - this._paddingRight + this._horizontalGap) / (tileWidth + this._horizontalGap));
		if (horizontalTileCount < 1)
		{
			horizontalTileCount = 1;
		}
		else if (this._requestedColumnCount > 0 && horizontalTileCount > this._requestedColumnCount)
		{
			horizontalTileCount = this._requestedColumnCount;
		}
		if (this._paging != Direction.NONE)
		{
			var verticalTileCount:Int = Std.int((height - this._paddingTop - this._paddingBottom + this._verticalGap) / (tileHeight + this._verticalGap));
			if (verticalTileCount < 1)
			{
				verticalTileCount = 1;
			}
			var perPage:Float = horizontalTileCount * verticalTileCount;
			var pageIndex:Int = Std.int(index / perPage);
			if (this._paging == Direction.HORIZONTAL)
			{
				result.x = pageIndex * width;
				result.y = 0;
			}
			else
			{
				result.x = 0;
				result.y = pageIndex * height;
			}
		}
		else
		{
			var resultY:Float = this._paddingTop + ((tileHeight + this._verticalGap) * Std.int(index / horizontalTileCount));
			if (nearest)
			{
				var bottomPosition:Float = resultY - (height - tileHeight);
				if (scrollY >= bottomPosition && scrollY <= resultY)
				{
					//keep the current scroll position because the item is already
					//fully visible
					resultY = scrollY;
				}
				else
				{
					var topDifference:Float = Math.abs(resultY - scrollY);
					var bottomDifference:Float = Math.abs(bottomPosition - scrollY);
					if (bottomDifference < topDifference)
					{
						resultY = bottomPosition;
					}
				}
			}
			else
			{
				resultY -= Math.fround((height - tileHeight) / 2);
			}
			result.x = 0;
			result.y = resultY;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function calculateHorizontalTileCount(tileWidth:Float,
		explicitWidth:Float, maxWidth:Float, paddingLeftAndRight:Float,
		horizontalGap:Float, requestedColumnCount:Int, totalItemCount:Int):Int
	{
		if (requestedColumnCount > 0 && this._distributeWidths)
		{
			return requestedColumnCount;
		}
		var tileCount:Int;
		if (explicitWidth == explicitWidth) //!isNaN
		{
			//in this case, the exact width is known
			tileCount = Std.int((explicitWidth - paddingLeftAndRight + horizontalGap) / (tileWidth + horizontalGap));
			if (requestedColumnCount > 0 && tileCount > requestedColumnCount)
			{
				return requestedColumnCount;
			}
			if (tileCount > totalItemCount)
			{
				tileCount = totalItemCount;
			}
			if (tileCount < 1)
			{
				//we must have at least one tile per row
				tileCount = 1;
			}
			return tileCount;
		}
		
		//in this case, the width is not known, but it may have a maximum
		if (requestedColumnCount > 0)
		{
			tileCount = requestedColumnCount;
		}
		else
		{
			tileCount = totalItemCount;
		}
		
		var maxTileCount:Int = MathUtils.INT_MAX;
		if (maxWidth == maxWidth && //!isNaN
			maxWidth < Math.POSITIVE_INFINITY)
		{
			maxTileCount = Std.int((maxWidth - paddingLeftAndRight + horizontalGap) / (tileWidth + horizontalGap));
			if (maxTileCount < 1)
			{
				//we must have at least one tile per row
				maxTileCount = 1;
			}
		}
		if (tileCount > maxTileCount)
		{
			tileCount = maxTileCount;
		}
		if (tileCount < 1)
		{
			//we must have at least one tile per row
			tileCount = 1;
		}
		return tileCount;
	}
	
	/**
	 * @private
	 */
	private function calculateVerticalTileCount(tileHeight:Float,
		explicitHeight:Float, maxHeight:Float, paddingTopAndBottom:Float,
		verticalGap:Float, requestedRowCount:Int, totalItemCount:Int,
		horizontalTileCount:Int, distributeHeights:Bool):Int
	{
		//using the horizontal tile count, calculate how many rows would be
		//required for the total number of items if there were no restrictions.
		var defaultVerticalTileCount:Int = Math.ceil(totalItemCount / horizontalTileCount);
		if (distributeHeights)
		{
			if (requestedRowCount > 0 && defaultVerticalTileCount > requestedRowCount)
			{
				return requestedRowCount;
			}
			return defaultVerticalTileCount;
		}
		
		var verticalTileCount:Int;
		if (explicitHeight == explicitHeight) //!isNaN
		{
			//in this case, the exact height is known
			verticalTileCount = Std.int((explicitHeight - paddingTopAndBottom + verticalGap) / (tileHeight + verticalGap));
			if (requestedRowCount > 0 && verticalTileCount > requestedRowCount)
			{
				return requestedRowCount;
			}
			if (verticalTileCount > defaultVerticalTileCount)
			{
				verticalTileCount = defaultVerticalTileCount;
			}
			if (verticalTileCount < 1)
			{
				//we must have at least one tile per row
				verticalTileCount = 1;
			}
			return verticalTileCount;
		}
		
		//in this case, the height is not known, but it may have a maximum
		if (requestedRowCount > 0)
		{
			verticalTileCount = requestedRowCount;
		}
		else
		{
			verticalTileCount = defaultVerticalTileCount;
		}
		
		var maxVerticalTileCount:Int = MathUtils.INT_MAX;
		if (maxHeight == maxHeight && //!isNaN
			maxHeight < Math.POSITIVE_INFINITY)
		{
			maxVerticalTileCount = Std.int((maxHeight - paddingTopAndBottom + verticalGap) / (tileHeight + verticalGap));
			if (maxVerticalTileCount < 1)
			{
				//we must have at least one tile per row
				maxVerticalTileCount = 1;
			}
		}
		if (verticalTileCount > maxVerticalTileCount)
		{
			verticalTileCount = maxVerticalTileCount;
		}
		if (verticalTileCount < 1)
		{
			//we must have at least one tile per row
			verticalTileCount = 1;
		}
		return verticalTileCount;
	}
	
}