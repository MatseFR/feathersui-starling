/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;

import feathers.core.IFeathersControl;
import feathers.core.IValidating;
import feathers.utils.ReverseIterator;
import feathers.utils.type.SafeCast;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * For use with the <code>SpinnerList</code> component, positions items from
 * top to bottom in a single column and repeats infinitely.
 *
 * @see ../../../help/vertical-spinner-layout.html How to use VerticalSpinnerLayout with the Feathers SpinnerList component
 *
 * @productversion Feathers 2.1.0
 */
class VerticalSpinnerLayout extends EventDispatcher implements ISpinnerLayout implements ITrimmedVirtualLayout
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
	 * Quickly sets all padding properties to the same value. The
	 * <code>padding</code> getter always returns the value of
	 * <code>paddingLeft</code>, but the other padding values may be
	 * different.
	 *
	 * @default 0
	 *
	 * @see #paddingRight
	 * @see #paddingLeft
	 */
	public var padding(get, set):Float;
	private function get_padding():Float { return this._paddingLeft; }
	private function set_padding(value:Float):Float
	{
		this.paddingRight = value;
		return this.paddingLeft = value;
	}
	
	/**
	 * The minimum space, in pixels, above the items, if they
	 * do not repeat. If items repeat, <code>paddingTop</code> will
	 * only be used if <code>verticalAlign</code> is set to
	 * <code>VerticalAlign.TOP</code>. In this case, the first item,
	 * starting from the top, will be offset by the value of
	 * <code>paddingTop</code>.
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
	 * The minimum space, in pixels, below the items, if they
	 * do not repeat. If items repeat, <code>paddingBottom</code> will
	 * only be used if <code>verticalAlign</code> is set to
	 * <code>VerticalAlign.BOTTOM</code>. In this case, the first item,
	 * starting from the bottom, will be offset by the value of
	 * <code>paddingBottom</code>.
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
	 * @default feathers.layout.HorizontalAlign.JUSTIFY
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 * @see feathers.layout.HorizontalAlign#JUSTIFY
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.JUSTIFY;
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
	 * The alignment of the items vertically, on the y-axis.
	 *
	 * <p><strong>Note:</strong> The <code>VerticalAlign.JUSTIFY</code>
	 * constant is not supported.</p>
	 *
	 * @default feathers.layout.VerticalAlign.MIDDLE
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 */
	public var verticalAlign(get, set):String;
	private var _verticalAlign:String = VerticalAlign.MIDDLE;
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
	 * @inheritDoc
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
	 * Requests that the layout set the view port dimensions to display a
	 * specific number of rows (plus gaps and padding), if possible. If the
	 * explicit height of the view port is set, then this value will be
	 * ignored. If the view port's minimum and/or maximum height are set,
	 * the actual number of visible rows may be adjusted to meet those
	 * requirements. Set this value to <code>0</code> to display as many
	 * rows as possible.
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
	 * @inheritDoc
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
	 * @inheritDoc
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
	 * @inheritDoc
	 *
	 * @see #resetTypicalItemDimensionsOnMeasure
	 * @see #typicalItemWidth
	 * @see #typicalItemHeight
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
	 * If set to <code>true</code>, the layout will repeat the items
	 * infinitely, if there are enough items to allow this behavior. If the
	 * total height of the items is smaller than the height of the view
	 * port, the items cannot repeat.
	 *
	 * @default true
	 */
	public var repeatItems(get, set):Bool;
	private var _repeatItems:Bool = true;
	private function get_repeatItems():Bool { return this._repeatItems; }
	private function set_repeatItems(value:Bool):Bool
	{
		if (this._repeatItems == value)
		{
			return value;
		}
		this._repeatItems = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._repeatItems;
	}
	
	/**
	 * @copy feathers.layout.ISpinnerLayout#snapInterval
	 */
	public var snapInterval(get, never):Float;
	private function get_snapInterval():Float
	{
		if (this._typicalItem == null)
		{
			return 0;
		}
		return this._typicalItem.height + this._gap;
	}
	
	/**
	 * @inheritDoc
	 */
	public var requiresLayoutOnScroll(get, never):Bool;
	private function get_requiresLayoutOnScroll():Bool { return true; }
	
	/**
	 * @inheritDoc
	 */
	public var selectionBounds(get, never):Rectangle;
	private var _selectionBounds:Rectangle = new Rectangle();
	private function get_selectionBounds():Rectangle { return this._selectionBounds; }
	
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
		//var scrollX:Float = viewPortBounds != null ? viewPortBounds.scrollX : 0;
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
			this.prepareTypicalItem(explicitWidth - this._paddingLeft - this._paddingRight);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		if (!this._useVirtualLayout || this._horizontalAlign != HorizontalAlign.JUSTIFY ||
			explicitWidth != explicitWidth) //isNaN
		{
			//in some cases, we may need to validate all of the items so
			//that we can use their dimensions below.
			this.validateItems(items, explicitWidth - this._paddingLeft - this._paddingRight, explicitHeight);
		}
		
		//this section prepares some variables needed for the following loop
		var maxItemWidth:Float = this._useVirtualLayout ? calculatedTypicalItemWidth : 0;
		var positionY:Float = boundsY;
		var gap:Float = this._gap;
		var itemCount:Int = items.length;
		var totalItemCount:Int = itemCount;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, and the items all have the same
			//height, we can make our loops smaller by skipping some items
			//at the beginning and end. this improves performance.
			
			if (this._beforeVirtualizedItemCount > 0)
			{
				//this value may be negative, which means that we're
				//repeating items. we don't want to include this value in
				//the total count, but we'll use it elsewhere.
				totalItemCount += this._beforeVirtualizedItemCount;
			}
			totalItemCount += this._afterVirtualizedItemCount;
			positionY += (this._beforeVirtualizedItemCount * (calculatedTypicalItemHeight + gap));
		}
		//this cache is used to save non-null items in virtual layouts. by
		//using a smaller array, we can improve performance by spending less
		//time in the upcoming loops.
		this._discoveredItemsCache.resize(0);
		var discoveredItemsCacheLastIndex:Int = 0;
		
		//this first loop sets the y position of items, and it calculates
		//the total height of all items
		var item:DisplayObject;
		var itemWidth:Float;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (item != null)
			{
				//we get here if the item isn't null. it is never null if
				//the layout isn't virtualized.
				if (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout)
				{
					continue;
				}
				item.y = item.pivotY + positionY;
				item.height = calculatedTypicalItemHeight;
				itemWidth = item.width;
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
			positionY += calculatedTypicalItemHeight + gap;
		}
		if (this._useVirtualLayout)
		{
			//finish the final calculation of the y position so that it can
			//be used for the total height of all items
			positionY += (this._afterVirtualizedItemCount * (calculatedTypicalItemHeight + gap));
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
		var totalHeight:Float = positionY - gap - boundsY;
		if (this._useVirtualLayout && this._beforeVirtualizedItemCount < 0)
		{
			totalHeight -= (this._beforeVirtualizedItemCount * (calculatedTypicalItemHeight + gap));
		}
		//the available height is the height of the viewport. if the explicit
		//height is NaN, we need to calculate the viewport height ourselves
		//based on the total height of all items.
		var availableHeight:Float = explicitHeight;
		if (availableHeight != availableHeight) //isNaN
		{
			if (this._requestedRowCount > 0)
			{
				availableHeight = this._requestedRowCount * (calculatedTypicalItemHeight + gap) - gap;
			}
			else
			{
				availableHeight = totalHeight;
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
		
		//we add one extra here because the first item renderer in view may
		//be partially obscured, which would reveal an extra item renderer.
		var maxVisibleTypicalItemCount:Int = Math.ceil(availableHeight / (calculatedTypicalItemHeight + gap)) + 1;
		var minTotalHeightForRepeat:Float = maxVisibleTypicalItemCount * (calculatedTypicalItemHeight + gap) - gap;
		var canRepeatItems:Bool = this._repeatItems && totalHeight >= minTotalHeightForRepeat;
		if (canRepeatItems)
		{
			totalHeight += gap;
		}
		
		//in this section, we handle vertical alignment
		var verticalAlignOffsetY:Float = this._paddingTop;
		if (this._verticalAlign == VerticalAlign.BOTTOM)
		{
			verticalAlignOffsetY = availableHeight - this._paddingBottom - calculatedTypicalItemHeight;
		}
		else if (this._verticalAlign == VerticalAlign.MIDDLE)
		{
			verticalAlignOffsetY = this._paddingTop + Math.fround((availableHeight - this._paddingTop - this._paddingBottom - calculatedTypicalItemHeight) / 2);
		}
		if (!canRepeatItems)
		{
			totalHeight += verticalAlignOffsetY + (availableHeight - calculatedTypicalItemHeight - verticalAlignOffsetY);
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
		
		var layoutItem:ILayoutDisplayObject;
		var adjustedScrollY:Float;
		var multiplier:Int;
		var horizontalAlignWidth:Float;
		for (i in 0...discoveredItemCount)
		{
			item = discoveredItems[i];
			layoutItem = SafeCast.safe_cast(item, ILayoutDisplayObject);
			if (layoutItem != null && !layoutItem.includeInLayout)
			{
				continue;
			}
			
			//if we're repeating items, then we may need to adjust the y
			//position of some items so that they appear inside the viewport
			if (canRepeatItems)
			{
				adjustedScrollY = scrollY - verticalAlignOffsetY;
				if (adjustedScrollY > 0)
				{
					multiplier = Std.int((adjustedScrollY + availableHeight) / totalHeight);
					if (useVirtualLayout && this._beforeVirtualizedItemCount < 0)
					{
						multiplier++;
					}
					item.y += totalHeight * multiplier;
					if (item.y >= (scrollY + availableHeight))
					{
						item.y -= totalHeight;
					}
				}
				else if (adjustedScrollY < 0)
				{
					item.y += totalHeight * (Std.int(adjustedScrollY / totalHeight) - 1);
					if ((item.y + item.height) < scrollY)
					{
						item.y += totalHeight;
					}
				}
			}
			
			//in this section, we handle horizontal alignment
			if (this._horizontalAlign == HorizontalAlign.JUSTIFY)
			{
				//if we justify items horizontally, we can skip percent width
				item.x = item.pivotX + boundsX + this._paddingLeft;
				item.width = availableWidth - this._paddingLeft - this._paddingRight;
			}
			else
			{
				//handle all other horizontal alignment values (we handled
				//justify already). the x position of all items is set.
				horizontalAlignWidth = availableWidth;
				if (totalWidth > horizontalAlignWidth)
				{
					horizontalAlignWidth = totalWidth;
				}
				switch (this._horizontalAlign)
				{
					case HorizontalAlign.RIGHT:
						item.x = item.pivotX + boundsX + horizontalAlignWidth - this._paddingRight - item.width;
					
					case HorizontalAlign.CENTER:
						//round to the nearest pixel when dividing by 2 to
						//align in the center
						item.x = item.pivotX + boundsX + this._paddingLeft + Math.fround((horizontalAlignWidth - this._paddingLeft - this._paddingRight - item.width) / 2);
					
					default: //left
						item.x = item.pivotX + boundsX + this._paddingLeft;
				}
			}
		}
		//we don't want to keep a reference to any of the items, so clear
		//this cache
		this._discoveredItemsCache.resize(0);
		
		//calculate the bounds of the selection rectangle
		this._selectionBounds.x = 0;
		this._selectionBounds.y = verticalAlignOffsetY;
		this._selectionBounds.width = availableWidth;
		this._selectionBounds.height = calculatedTypicalItemHeight;
		
		//finally, we want to calculate the result so that the container
		//can use it to adjust its viewport and determine the minimum and
		//maximum scroll positions (if needed)
		if (result == null)
		{
			result = new LayoutBoundsResult();
		}
		result.contentX = 0;
		result.contentWidth = this._horizontalAlign == HorizontalAlign.JUSTIFY ? availableWidth : totalWidth;
		if (canRepeatItems)
		{
			result.contentY = Math.NEGATIVE_INFINITY;
			result.contentHeight = Math.POSITIVE_INFINITY;
		}
		else
		{
			result.contentY = 0;
			result.contentHeight = totalHeight;
		}
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
		
		var gap:Float = this._gap;
		var positionY:Float = 0;
		
		var maxItemWidth:Float = calculatedTypicalItemWidth;
		positionY += ((calculatedTypicalItemHeight + gap) * itemCount);
		positionY -= gap;
		
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
				resultHeight = (calculatedTypicalItemHeight + gap) * this._requestedRowCount - gap;
			}
			else
			{
				resultHeight = positionY;
			}
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
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		var gap:Float = this._gap;
		
		var resultLastIndex:Int = 0;
		
		var totalItemHeight:Float = itemCount * (calculatedTypicalItemHeight + gap) - gap;
		
		//the actual code that figures out which items are visible assumes
		//that alignment is top. to make it work with other alignments, we
		//can simply adjust the scroll position!
		if (this._verticalAlign == VerticalAlign.MIDDLE)
		{
			scrollY -= Math.fround(this._paddingTop + (height - calculatedTypicalItemHeight) / 2);
		}
		else if (this._verticalAlign == VerticalAlign.BOTTOM)
		{
			scrollY -= (height - calculatedTypicalItemHeight - this._paddingBottom);
		}
		else //top
		{
			scrollY -= this._paddingTop;
		}
		
		//we add one extra here because the first item renderer in view may
		//be partially obscured, which would reveal an extra item renderer.
		var maxVisibleTypicalItemCount:Int = Math.ceil(height / (calculatedTypicalItemHeight + gap)) + 1;
		var minTotalHeightForRepeat:Float = maxVisibleTypicalItemCount * (calculatedTypicalItemHeight + gap) - gap;
		var canRepeatItems:Bool = this._repeatItems && totalItemHeight >= minTotalHeightForRepeat;
		var minimum:Int;
		var maximum:Int;
		if (canRepeatItems)
		{
			//if we're repeating, then there's an extra gap
			totalItemHeight += gap;
			scrollY %= totalItemHeight;
			if (scrollY < 0)
			{
				scrollY += totalItemHeight;
			}
			minimum = Std.int(scrollY / (calculatedTypicalItemHeight + gap));
			maximum = minimum + maxVisibleTypicalItemCount;
		}
		else
		{
			minimum = Std.int(scrollY / (calculatedTypicalItemHeight + gap));
			if (minimum < 0)
			{
				minimum = 0;
			}
			//if we're scrolling beyond the final item, we should keep the
			//indices consistent so that items aren't destroyed and
			//recreated unnecessarily
			maximum = minimum + maxVisibleTypicalItemCount;
			if (maximum >= itemCount)
			{
				maximum = itemCount - 1;
			}
			minimum = maximum - maxVisibleTypicalItemCount;
			if (minimum < 0)
			{
				minimum = 0;
			}
		}
		var loopedI:Int;
		for (i in minimum...maximum+1)
		{
			if (!canRepeatItems || (i >= 0 && i < itemCount))
			{
				result[resultLastIndex] = i;
			}
			else if (i < 0)
			{
				result[resultLastIndex] = itemCount + i;
			}
			else if (i >= itemCount)
			{
				loopedI = i - itemCount;
				if (loopedI == minimum)
				{
					//we don't want to repeat items!
					break;
				}
				result[resultLastIndex] = loopedI;
			}
			resultLastIndex++;
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function calculateNavigationDestination(items:Array<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int
	{
		var itemArrayCount:Int = items.length;
		var itemCount:Int = itemArrayCount + this._afterVirtualizedItemCount;
		if (this._beforeVirtualizedItemCount > 0)
		{
			itemCount += this._beforeVirtualizedItemCount;
		}
		var result:Int = index;
		var yPosition:Float;
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
			yPosition = 0;
			//for (var i:int = index; i >= 0; i--)
			for (i in new ReverseIterator(index, 0))
			{
				yPosition += this.snapInterval;
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
			for (i in index...itemCount)
			{
				yPosition += this.snapInterval;
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
			result--;
		}
		else if (keyCode == Keyboard.DOWN)
		{
			result++;
		}
		var canRepeatItems:Bool = this._repeatItems && bounds.contentHeight == Math.POSITIVE_INFINITY;
		if (canRepeatItems)
		{
			while (result < 0)
			{
				result += itemCount;
			}
			while (result >= itemCount)
			{
				result -= itemCount;
			}
		}
		else if (result < 0)
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
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		//normally, this isn't acceptable, but because the selection is
		//based on the scroll position, it must work this way.
		return this.getScrollPositionForIndex(index, items, x, y, width, height, result);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		if (result == null)
		{
			result = new Point();
		}
		result.x = 0;
		result.y = calculatedTypicalItemHeight * index;
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function validateItems(items:Array<DisplayObject>, justifyWidth:Float, distributedHeight:Float):Void
	{
		//if the alignment is justified, then we want to set the width of
		//each item before validating because setting one dimension may
		//cause the other dimension to change, and that will invalidate the
		//layout if it happens after validation, causing more invalidation
		var isJustified:Bool = this._horizontalAlign == HorizontalAlign.JUSTIFY;
		var mustSetJustifyWidth:Bool = isJustified && justifyWidth == justifyWidth; //!isNaN
		var itemCount:Int = items.length;
		var item:DisplayObject;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (item == null || (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout))
			{
				continue;
			}
			if (mustSetJustifyWidth)
			{
				item.width = justifyWidth;
			}
			else if (isJustified && Std.isOfType(item, IFeathersControl))
			{
				//the alignment is justified, but we don't yet have a width
				//to use, so we need to ensure that we accurately measure
				//the items instead of using an old justified width that may
				//be wrong now!
				item.width = Math.NaN;
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
		if (this._horizontalAlign == HorizontalAlign.JUSTIFY &&
			justifyWidth == justifyWidth) //!isNaN
		{
			this._typicalItem.width = justifyWidth;
		}
		else if (this._resetTypicalItemDimensionsOnMeasure)
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
	
}