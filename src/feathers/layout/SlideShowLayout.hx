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
import starling.events.EventDispatcher;

/**
 * Displays one item per page.
 *
 * @see ../../../help/slide-show-layout.html How to use SlideShowLayout with Feathers containers
 *
 * @productversion Feathers 3.3.0
 */
class SlideShowLayout extends EventDispatcher implements IVirtualLayout implements ITrimmedVirtualLayout
{
	/**
	 * @private
	 */
	private static inline var FUZZY_PAGE_DETECTION:Float = 0.000001;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * Determines if pages are positioned from left-to-right or from top-to-bottom.
	 *
	 * @default feathers.layout.Direction.HORIZONTAL
	 *
	 * @see feathers.layout.Direction#HORIZONTAL
	 * @see feathers.layout.Direction#VERTICAL
	 */
	public var direction(get, set):String;
	private var _direction:String = Direction.HORIZONTAL;
	private function get_direction():String { return this._direction; }
	private function set_direction(value:String):String
	{
		if (this._direction == value)
		{
			return value;
		}
		this._direction = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._direction;
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
	 * The space, in pixels, that appears on top of each item.
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
	 * The minimum space, in pixels, to the right of each item.
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
	 * The space, in pixels, that appears on the bottom of each item.
	 * item.
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
	 * The minimum space, in pixels, to the left of each item.
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
	 * The alignment of each item vertically, on the y-axis.
	 *
	 * @default feathers.layout.VerticalAlign.MIDDLE
	 *
	 * @see feathers.layout.VerticalAlign#TOP
	 * @see feathers.layout.VerticalAlign#MIDDLE
	 * @see feathers.layout.VerticalAlign#BOTTOM
	 * @see feathers.layout.VerticalAlign#JUSTIFY
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
	 * The alignment of each item horizontally, on the x-axis.
	 *
	 * @default feathers.layout.HorizontalAlign.CENTER
	 *
	 * @see feathers.layout.HorizontalAlign#LEFT
	 * @see feathers.layout.HorizontalAlign#CENTER
	 * @see feathers.layout.HorizontalAlign#RIGHT
	 * @see feathers.layout.HorizontalAlign#JUSTIFY
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
	 * If the layout is virtualized, specifies the minimum total number of
	 * items that will be created, even if some are not currently visible
	 * in the view port.
	 *
	 * @default 1
	 *
	 * @see #useVirtualLayout
	 */
	public var minimumItemCount(get, set):Int;
	private var _minimumItemCount:Int = 1;
	private function get_minimumItemCount():Int { return this._minimumItemCount; }
	private function set_minimumItemCount(value:Int):Int
	{
		if (this._minimumItemCount == value)
		{
			return value;
		}
		this._minimumItemCount = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._minimumItemCount;
	}
	
	/**
	 * @inheritDoc
	 */
	public var requiresLayoutOnScroll(get, never):Bool;
	private function get_requiresLayoutOnScroll():Bool { return this._useVirtualLayout; }
	
	/**
	 * @inheritDoc
	 */
	public function layout(items:Array<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult
	{
		//since viewPortBounds can be null, we may need to provide some defaults
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
		var itemCount:Int = items.length;
		
		var calculatedTypicalItemWidth:Float = 0;
		var calculatedTypicalItemHeight:Float = 0;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we'll need the dimensions of the
			//typical item so that we have fallback values when an item is null
			this.prepareTypicalItem(explicitWidth - this._paddingLeft - this._paddingRight,
				explicitHeight - this._paddingTop - this._paddingBottom);
			calculatedTypicalItemWidth = this._typicalItem != null ? this._typicalItem.width : 0;
			calculatedTypicalItemHeight = this._typicalItem != null ? this._typicalItem.height : 0;
		}
		
		var needsExplicitWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsExplicitHeight:Bool = explicitHeight != explicitHeight; //isNaN
		var viewPortWidth:Float = explicitWidth;
		if (needsExplicitWidth)
		{
			viewPortWidth = calculatedTypicalItemWidth;
		}
		var viewPortHeight:Float = explicitHeight;
		if (needsExplicitHeight)
		{
			viewPortHeight = calculatedTypicalItemHeight;
		}
		
		if (!this._useVirtualLayout ||
			this._horizontalAlign != HorizontalAlign.JUSTIFY ||
			this._verticalAlign != VerticalAlign.JUSTIFY ||
			needsExplicitWidth || needsExplicitHeight)
		{
			//in some cases, we may need to validate all of the items so
			//that we can use their dimensions below.
			this.validateItems(items, explicitWidth - this._paddingLeft - this._paddingRight,
				explicitHeight - this._paddingTop - this._paddingBottom);
		}
		
		var item:DisplayObject;
		//if the layout isn't virtual and the view port dimensions aren't
		//explicit, we need to calculate them
		if (!this._useVirtualLayout && (needsExplicitWidth || needsExplicitHeight))
		{
			var maxItemWidth:Float = this._useVirtualLayout ? calculatedTypicalItemWidth : 0;
			var maxItemHeight:Float = this._useVirtualLayout ? calculatedTypicalItemHeight : 0;
			for (i in 0...itemCount)
			{
				item = items[i];
				if (maxItemWidth < item.width)
				{
					maxItemWidth = item.width;
				}
				if (maxItemHeight < item.height)
				{
					maxItemHeight = item.height;
				}
			}
			if (needsExplicitWidth)
			{
				viewPortWidth = maxItemWidth + this._paddingLeft + this._paddingRight;
			}
			if (needsExplicitHeight)
			{
				viewPortHeight = maxItemHeight + this._paddingTop + this._paddingBottom;
			}
		}
		if (needsExplicitWidth)
		{
			if (viewPortWidth < minWidth)
			{
				viewPortWidth = minWidth;
			}
			else if (viewPortWidth > maxWidth)
			{
				viewPortWidth = maxWidth;
			}
		}
		if (needsExplicitHeight)
		{
			if (viewPortHeight < minHeight)
			{
				viewPortHeight = minHeight;
			}
			else if (viewPortHeight > maxHeight)
			{
				viewPortHeight = maxHeight;
			}
		}
		var startPosition:Float;
		if (this._direction == Direction.VERTICAL)
		{
			startPosition = boundsY;
		}
		else
		{
			startPosition = boundsX;
		}
		var position:Float = startPosition;
		if (this._useVirtualLayout)
		{
			//if the layout is virtualized, we can make our loops shorter
			//by skipping some items at the beginning and end. this
			//improves performance.
			if (this._direction == Direction.VERTICAL)
			{
				position += (this._beforeVirtualizedItemCount * viewPortHeight);
			}
			else //horizontal
			{
				position += (this._beforeVirtualizedItemCount * viewPortWidth);
			}
		}
		var contentWidth:Float = viewPortWidth - this._paddingLeft - this._paddingRight;
		var contentHeight:Float = viewPortHeight - this._paddingTop - this._paddingBottom;
		var layoutItem:ILayoutDisplayObject;
		var xPosition:Float;
		var yPosition:Float;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (item != null)
			{
				//we get here if the item isn't null. it is never null if
				//the layout isn't virtualized.
				layoutItem = SafeCast.safe_cast(item, ILayoutDisplayObject);
				if (layoutItem != null && !layoutItem.includeInLayout)
				{
					continue;
				}
				xPosition = this._direction == Direction.VERTICAL ? 0 : position;
				switch (this._horizontalAlign)
				{
					case HorizontalAlign.JUSTIFY:
						xPosition += this._paddingLeft;
						item.width = contentWidth;
					
					case HorizontalAlign.LEFT:
						xPosition += this._paddingLeft;
					
					case HorizontalAlign.RIGHT:
						xPosition += contentWidth - item.width;
					
					case HorizontalAlign.CENTER:
						xPosition += Math.round((contentWidth - item.width) / 2);
				}
				item.x = xPosition;
				yPosition = this._direction == Direction.VERTICAL ? position : 0;
				switch (this._verticalAlign)
				{
					case VerticalAlign.JUSTIFY:
						yPosition += this._paddingTop;
						item.height = contentHeight;
					
					case VerticalAlign.TOP:
						yPosition += this._paddingTop;
					
					case VerticalAlign.BOTTOM:
						yPosition += contentHeight - item.height;
					
					case VerticalAlign.MIDDLE:
						yPosition += Math.round((contentHeight - item.height) / 2);
				}
				item.y = yPosition;
			}
			if (this._direction == Direction.VERTICAL)
			{
				position += viewPortHeight;
			}
			else //horizontal
			{
				position += viewPortWidth;
			}
		}
		if (position == startPosition)
		{
			//require at least one page
			if (this._direction == Direction.VERTICAL)
			{
				position += viewPortHeight;
			}
			else //horizontal
			{
				position += viewPortWidth;
			}
		}
		if (this._useVirtualLayout)
		{
			position += (viewPortWidth * this._afterVirtualizedItemCount);
		}
		
		if (result == null)
		{
			result = new LayoutBoundsResult();
		}
		result.contentX = 0;
		result.contentY = 0;
		if (this._direction == Direction.VERTICAL)
		{
			result.contentWidth = viewPortWidth;
			result.contentHeight = position;
		}
		else //horizontal
		{
			result.contentWidth = position;
			result.contentHeight = viewPortHeight;
		}
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
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
		
		this.prepareTypicalItem(explicitWidth - this._paddingLeft - this._paddingRight,
			explicitHeight - this._paddingTop - this._paddingBottom);
		var calculatedTypicalItemWidth:Float = this._typicalItem != null ? this._typicalItem.width : 0;
		var calculatedTypicalItemHeight:Float = this._typicalItem != null ? this._typicalItem.height : 0;
		
		if (needsWidth)
		{
			var resultWidth:Float = calculatedTypicalItemWidth + this._paddingLeft + this._paddingRight;
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
			var resultHeight:Float = calculatedTypicalItemHeight + this._paddingTop + this._paddingBottom;
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
		var baseIndex:Int;
		var isBetweenPages:Bool;
		if (this._direction == Direction.VERTICAL)
		{
			baseIndex = Std.int(scrollY / height);
			isBetweenPages = ((scrollY / height) - baseIndex) > FUZZY_PAGE_DETECTION;
		}
		else //horizontal
		{
			baseIndex = Std.int(scrollX / width);
			isBetweenPages = ((scrollX / width) - baseIndex) > FUZZY_PAGE_DETECTION;
		}
		var extraBeforeCount:Int = Std.int(this._minimumItemCount / 2);
		var startIndex:Int = baseIndex - extraBeforeCount;
		if (startIndex < 0)
		{
			extraBeforeCount += startIndex;
			startIndex = 0;
		}
		var extraAfterCount:Int = this._minimumItemCount - extraBeforeCount;
		if (!isBetweenPages || this._minimumItemCount > 2)
		{
			extraAfterCount--;
		}
		var endIndex:Int = baseIndex + extraAfterCount;
		var maxIndex:Int = itemCount - 1;
		if (endIndex > maxIndex)
		{
			endIndex = maxIndex;
		}
		var pushIndex:Int = 0;
		for (i in startIndex...endIndex+1)
		{
			result[pushIndex] = i;
			pushIndex++;
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		return this.getScrollPositionForIndex(index, items, x, y, width, height, result);
	}
	
	/**
	 * @inheritDoc
	 */
	public function calculateNavigationDestination(items:Array<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int
	{
		var itemArrayCount:Int = items.length;
		var itemCount:Int = itemArrayCount + this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
		
		var result:Int = index;
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
		else if (keyCode == Keyboard.PAGE_UP ||
			(this._direction == Direction.VERTICAL && keyCode == Keyboard.UP) ||
			(this._direction == Direction.HORIZONTAL && keyCode == Keyboard.LEFT))
		{
			result--;
		}
		else if (keyCode == Keyboard.PAGE_DOWN ||
			(this._direction == Direction.VERTICAL && keyCode == Keyboard.DOWN) ||
			(this._direction == Direction.HORIZONTAL && keyCode == Keyboard.RIGHT))
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
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		if (this._direction == Direction.VERTICAL)
		{
			result.x = 0;
			result.y = height * index;
		}
		else //horizontal
		{
			result.x = width * index;
			result.y = 0;
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function validateItems(items:Array<DisplayObject>,
		explicitWidth:Float, explicitHeight:Float):Void
	{
		//if the alignment is justified, then we want to set the width of
		//each item before validating because setting one dimension may
		//cause the other dimension to change, and that will invalidate the
		//layout if it happens after validation, causing more invalidation
		var itemCount:Int = items.length;
		var item:DisplayObject;
		for (i in 0...itemCount)
		{
			item = items[i];
			if (item == null || (Std.isOfType(item, ILayoutDisplayObject) && !cast(item, ILayoutDisplayObject).includeInLayout))
			{
				continue;
			}
			if (this._horizontalAlign == HorizontalAlign.JUSTIFY)
			{
				//the alignment is justified, but we don't yet have a width
				//to use, so we need to ensure that we accurately measure
				//the items instead of using an old justified width that may
				//be wrong now!
				item.width = explicitWidth;
			}
			if (this._verticalAlign == VerticalAlign.JUSTIFY)
			{
				item.height = explicitHeight;
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
	private function prepareTypicalItem(justifyWidth:Float, justifyHeight:Float):Void
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
		if (this._verticalAlign == VerticalAlign.JUSTIFY &&
			justifyHeight == justifyHeight) //!isNaN
		{
			this._typicalItem.height = justifyHeight;
		}
		if (Std.isOfType(this._typicalItem, IValidating))
		{
			cast(this._typicalItem, IValidating).validate();
		}
	}
	
}