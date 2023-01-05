/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;

import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import feathers.core.IFeathersControl;
import starling.display.DisplayObject;
import starling.events.EventDispatcher;
import starling.utils.Pool;

/**
 * Positions and sizes items by anchoring their edges (or center points)
 * to their parent container or to other items.
 *
 * @see ../../../help/anchor-layout.html How to use AnchorLayout with Feathers containers
 * @see AnchorLayoutData
 *
 * @productversion Feathers 1.1.0
 */
class AnchorLayout extends EventDispatcher implements ILayout
{
	/**
	 * @private
	 */
	private static inline var CIRCULAR_REFERENCE_ERROR:String = "It is impossible to create this layout due to a circular reference in the AnchorLayoutData.";
	
	/**
	 * @private
	 */
	private var _helperVector1:Array<DisplayObject> = new Array<DisplayObject>;

	/**
	 * @private
	 */
	private var _helperVector2:Array<DisplayObject> = new Array<DisplayObject>;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		
	}
	
	/**
	 * @inheritDoc
	 */
	public var requiresLayoutOnScroll(get, never):Bool;
	private function get_requiresLayoutOnScroll():Bool { return false; }
	
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
		
		var viewPortWidth:Float = explicitWidth;
		var viewPortHeight:Float = explicitHeight;
		
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		if (needsWidth || needsHeight)
		{
			this.validateItems(items, explicitWidth, explicitHeight,
				maxWidth, maxHeight, true);
			var point:Point = Pool.getPoint();
			this.measureViewPort(items, viewPortWidth, viewPortHeight, point);
			if (needsWidth)
			{
				viewPortWidth = point.x;
				if (viewPortWidth < minWidth)
				{
					viewPortWidth = minWidth;
				}
				else if (viewPortWidth > maxWidth)
				{
					viewPortWidth = maxWidth;
				}
			}
			if (needsHeight)
			{
				viewPortHeight = point.y;
				if (viewPortHeight < minHeight)
				{
					viewPortHeight = minHeight;
				}
				else if (viewPortHeight > maxHeight)
				{
					viewPortHeight = maxHeight;
				}
			}
			Pool.putPoint(point);
		}
		else
		{
			this.validateItems(items, explicitWidth, explicitHeight,
				maxWidth, maxHeight, false);
		}
		
		this.layoutWithBounds(items, boundsX, boundsY, viewPortWidth, viewPortHeight);
		
		point = Pool.getPoint();
		this.measureContent(items, viewPortWidth, viewPortHeight, point);
		
		if (!result)
		{
			result = new LayoutBoundsResult();
		}
		result.contentWidth = point.x;
		result.contentHeight = point.y;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		Pool.putPoint(point);
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function calculateNavigationDestination(items:Array.<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int
	{
		return index;
	}

	/**
	 * @inheritDoc
	 */
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float, items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		return this.getScrollPositionForIndex(index, items, x, y, width, height, result);
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
		result.x = 0;
		result.y = 0;
		return result;
	}
	
	/**
	 * @private
	 */
	private function measureViewPort(items:Array<DisplayObject>,
		viewPortWidth:Float, viewPortHeight:Float, result:Point):Point
	{
		this._helperVector1.resize(0);
		this._helperVector2.resize(0);
		result.setTo(0, 0);
		var mainVector:Array<DisplayObject> = items;
		var otherVector:Array<DisplayObject> = this._helperVector1;
		this.measureVector(items, otherVector, result);
		var currentLength:Float = otherVector.length;
		while (currentLength > 0)
		{
			if (otherVector == this._helperVector1)
			{
				mainVector = this._helperVector1;
				otherVector = this._helperVector2;
			}
			else
			{
				mainVector = this._helperVector2;
				otherVector = this._helperVector1;
			}
			this.measureVector(mainVector, otherVector, result);
			var oldLength:Float = currentLength;
			currentLength = otherVector.length;
			if (oldLength == currentLength)
			{
				this._helperVector1.resize(0);
				this._helperVector2.resize(0);
				throw new IllegalOperationError(CIRCULAR_REFERENCE_ERROR);
			}
		}
		this._helperVector1.resize(0);
		this._helperVector2.resize(0);
		return result;
	}
	
	/**
	 * @private
	 */
	private function measureVector(items:Array<DisplayObject>, unpositionedItems:Array<DisplayObject>, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		unpositionedItems.resize(0);
		var itemCount:Int = items.length;
		var pushIndex:Int = 0;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = items[i];
			var layoutData:AnchorLayoutData;
			if (Std.isOfType(item, ILayoutDisplayObject))
			{
				var layoutItem:ILayoutDisplayObject = cast item;
				if (!layoutItem.includeInLayout)
				{
					continue;
				}
				layoutData = cast layoutItem.layoutData;
			}
			var isReadyForLayout:Bool = layoutData == null || this.isReadyForLayout(layoutData, i, items, unpositionedItems);
			if (!isReadyForLayout)
			{
				unpositionedItems[pushIndex] = item;
				pushIndex++;
				continue;
			}
			
			this.measureItem(item, result);
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function measureItem(item:DisplayObject, result:Point):Void
	{
		var maxX:Float = result.x;
		var maxY:Float = result.y;
		var isAnchored:Bool = false;
		if (Std.isOfType(item, ILayoutDisplayObject))
		{
			var layoutItem:ILayoutDisplayObject = cast item;
			var layoutData:AnchorLayoutData = cast layoutItem.layoutData;
			if (layoutData != null)
			{
				var measurement:Float = this.measureItemHorizontally(layoutItem, layoutData);
				if (measurement > maxX)
				{
					maxX = measurement;
				}
				measurement = this.measureItemVertically(layoutItem, layoutData);
				if (measurement > maxY)
				{
					maxY = measurement;
				}
				isAnchored = true;
			}
		}
		if (!isAnchored)
		{
			measurement = item.x - item.pivotX + item.width;
			if (measurement > maxX)
			{
				maxX = measurement;
			}
			measurement = item.y - item.pivotY + item.height;
			if (measurement > maxY)
			{
				maxY = measurement;
			}
		}
		
		result.x = maxX;
		result.y = maxY;
	}
	
	/**
	 * @private
	 */
	private function measureItemHorizontally(item:ILayoutDisplayObject, layoutData:AnchorLayoutData):Float
	{
		var itemWidth:Float = item.width;
		var displayItem:DisplayObject = cast item;
		var left:Float = this.getLeftOffset(displayItem);
		var right:Float = this.getRightOffset(displayItem);
		return itemWidth + left + right;
	}
	
	/**
	 * @private
	 */
	private function measureItemVertically(item:ILayoutDisplayObject, layoutData:AnchorLayoutData):Float
	{
		var itemHeight:Float = item.height;
		if (layoutData != null && Std.isOfType(item, IFeathersControl))
		{
			var percentHeight:Float = layoutData.percentHeight;
			//for some reason, if we don't call a function right here,
			//compiling with the flex 4.6 SDK will throw a VerifyError
			//for a stack overflow.
			//we could change the == check back to !isNaN() instead, but
			//isNaN() can allocate an object, so we should call a different
			//function without allocation.
			this.doNothing();
			if (percentHeight == percentHeight) //!isNaN
			{
				itemHeight = cast(item, IFeathersControl).minHeight;
			}
		}
		var displayItem:DisplayObject = cast item;
		var top:Float = this.getTopOffset(displayItem);
		var bottom:Float = this.getBottomOffset(displayItem);
		return itemHeight + top + bottom;
	}
	
	/**
	 * @private
	 * This function is here to work around a bug in the Flex 4.6 SDK
	 * compiler. For explanation, see the places where it gets called.
	 */
	private function doNothing():Void {}
	
	/**
	 * @private
	 */
	private function getTopOffset(item:DisplayObject):Float
	{
		if (Std.isOfType(item, ILayoutDisplayObject))
		{
			var layoutItem:ILayoutDisplayObject = cast item;
			var layoutData:AnchorLayoutData = cast layoutItem.layoutData;
			if (layoutData != null)
			{
				var top:Float = layoutData.top;
				var hasTopPosition:Bool = top == top; //!isNaN
				var bottom:Float = layoutData.bottom;
				var hasBottomPosition:Bool = bottom == bottom; //!isNaN
				var verticalCenter:Float = layoutData.verticalCenter;
				var hasVerticalCenterPosition:Bool = verticalCenter == verticalCenter; //!isNaN
				if (hasTopPosition)
				{
					var topAnchorDisplayObject:DisplayObject = layoutData.topAnchorDisplayObject;
					if (topAnchorDisplayObject != null)
					{
						top += topAnchorDisplayObject.height + this.getTopOffset(topAnchorDisplayObject);
					}
					else
					{
						return top;
					}
				}
				else if (!hasBottomPosition && !hasVerticalCenterPosition)
				{
					top = item.y;
				}
				else
				{
					top = 0;
				}
				if (hasBottomPosition)
				{
					var bottomAnchorDisplayObject:DisplayObject = layoutData.bottomAnchorDisplayObject;
					if (bottomAnchorDisplayObject != null)
					{
						top = Math.max(top, -bottomAnchorDisplayObject.height - bottom + this.getTopOffset(bottomAnchorDisplayObject));
					}
				}
				if (hasVerticalCenterPosition)
				{
					var verticalCenterAnchorDisplayObject:DisplayObject = layoutData.verticalCenterAnchorDisplayObject;
					if (verticalCenterAnchorDisplayObject != null)
					{
						var verticalOffset:Float = verticalCenter - Math.fround((item.height - verticalCenterAnchorDisplayObject.height) / 2);
						top = Math.max(top, verticalOffset + this.getTopOffset(verticalCenterAnchorDisplayObject));
					}
					else if (verticalCenter > 0)
					{
						return verticalCenter * 2;
					}
				}
				return top;
			}
		}
		return item.y;
	}
	
	/**
	 * @private
	 */
	private function getRightOffset(item:DisplayObject):Float
	{
		if (Std.isOfType(item, ILayoutDisplayObject))
		{
			var layoutItem:ILayoutDisplayObject = cast item;
			var layoutData:AnchorLayoutData = cast layoutItem.layoutData;
			if (layoutData != null)
			{
				var right:Float = layoutData.right;
				var hasRightPosition:Bool = right == right; //!isNaN
				if (hasRightPosition)
				{
					var rightAnchorDisplayObject:DisplayObject = layoutData.rightAnchorDisplayObject;
					if (rightAnchorDisplayObject != null)
					{
						right += rightAnchorDisplayObject.width + this.getRightOffset(rightAnchorDisplayObject);
					}
					else
					{
						return right;
					}
				}
				else
				{
					right = 0;
				}
				var left:Float = layoutData.left;
				var hasLeftPosition:Bool = left == left; //!isNaN
				if (hasLeftPosition)
				{
					var leftAnchorDisplayObject:DisplayObject = layoutData.leftAnchorDisplayObject;
					if (leftAnchorDisplayObject != null)
					{
						right = Math.max(right, -leftAnchorDisplayObject.width - left + this.getRightOffset(leftAnchorDisplayObject));
					}
				}
				var horizontalCenter:Float = layoutData.horizontalCenter;
				var hasHorizontalCenterPosition:Bool = horizontalCenter == horizontalCenter; //!isNaN
				if (hasHorizontalCenterPosition)
				{
					var horizontalCenterAnchorDisplayObject:DisplayObject = layoutData.horizontalCenterAnchorDisplayObject;
					if (horizontalCenterAnchorDisplayObject != null)
					{
						var horizontalOffset:Float = -horizontalCenter - Math.fround((item.width - horizontalCenterAnchorDisplayObject.width) / 2);
						right = Math.max(right, horizontalOffset + this.getRightOffset(horizontalCenterAnchorDisplayObject));
					}
					else if (horizontalCenter < 0)
					{
						return -horizontalCenter * 2;
					}
				}
				return right;
			}
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	private function getBottomOffset(item:DisplayObject):Float
	{
		if (Std.isOfType(item, ILayoutDisplayObject))
		{
			var layoutItem:ILayoutDisplayObject = cast item;
			var layoutData:AnchorLayoutData = cast layoutItem.layoutData;
			if (layoutData != null)
			{
				var bottom:Float = layoutData.bottom;
				var hasBottomPosition:Bool = bottom == bottom; //!isNaN
				if (hasBottomPosition)
				{
					var bottomAnchorDisplayObject:DisplayObject = layoutData.bottomAnchorDisplayObject;
					if (bottomAnchorDisplayObject != null)
					{
						bottom += bottomAnchorDisplayObject.height + this.getBottomOffset(bottomAnchorDisplayObject);
					}
					else
					{
						return bottom;
					}
				}
				else
				{
					bottom = 0;
				}
				var top:Float = layoutData.top;
				var hasTopPosition:Bool = top == top; //!isNaN
				if (hasTopPosition)
				{
					var topAnchorDisplayObject:DisplayObject = layoutData.topAnchorDisplayObject;
					if (topAnchorDisplayObject != null)
					{
						bottom = Math.max(bottom, -topAnchorDisplayObject.height - top + this.getBottomOffset(topAnchorDisplayObject));
					}
				}
				var verticalCenter:Float = layoutData.verticalCenter;
				var hasVerticalCenterPosition:Bool = verticalCenter == verticalCenter; //!isNaN
				if (hasVerticalCenterPosition)
				{
					var verticalCenterAnchorDisplayObject:DisplayObject = layoutData.verticalCenterAnchorDisplayObject;
					if (verticalCenterAnchorDisplayObject != null)
					{
						var verticalOffset:Float = -verticalCenter - Math.fround((item.height - verticalCenterAnchorDisplayObject.height) / 2);
						bottom = Math.max(bottom, verticalOffset + this.getBottomOffset(verticalCenterAnchorDisplayObject));
					}
					else if (verticalCenter < 0)
					{
						return -verticalCenter * 2;
					}
				}
				return bottom;
			}
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	private function getLeftOffset(item:DisplayObject):Float
	{
		if (Std.isOfType(item, ILayoutDisplayObject))
		{
			var layoutItem:ILayoutDisplayObject = cast item;
			var layoutData:AnchorLayoutData = cast layoutItem.layoutData;
			if (layoutData != null)
			{
				var left:Float = layoutData.left;
				var hasLeftPosition:Bool = left == left; //!isNaN
				var right:Float = layoutData.right;
				var hasRightPosition:Bool = right == right; //!isNaN;
				var horizontalCenter:Float = layoutData.horizontalCenter;
				var hasHorizontalCenterPosition:Bool = horizontalCenter == horizontalCenter; //!isNaN
				if (hasLeftPosition)
				{
					var leftAnchorDisplayObject:DisplayObject = layoutData.leftAnchorDisplayObject;
					if (leftAnchorDisplayObject != null)
					{
						left += leftAnchorDisplayObject.width + this.getLeftOffset(leftAnchorDisplayObject);
					}
					else
					{
						return left;
					}
				}
				else if (!hasRightPosition && !hasHorizontalCenterPosition)
				{
					left = item.x;
				}
				else
				{
					left = 0;
				}
				if (hasRightPosition)
				{
					var rightAnchorDisplayObject:DisplayObject = layoutData.rightAnchorDisplayObject;
					if (rightAnchorDisplayObject != null)
					{
						left = Math.max(left, -rightAnchorDisplayObject.width - right + this.getLeftOffset(rightAnchorDisplayObject));
					}
				}
				if (hasHorizontalCenterPosition)
				{
					var horizontalCenterAnchorDisplayObject:DisplayObject = layoutData.horizontalCenterAnchorDisplayObject;
					if (horizontalCenterAnchorDisplayObject != null)
					{
						var horizontalOffset:Float = horizontalCenter - Math.fround((item.width - horizontalCenterAnchorDisplayObject.width) / 2);
						left = Math.max(left, horizontalOffset + this.getLeftOffset(horizontalCenterAnchorDisplayObject));
					}
					else if (horizontalCenter > 0)
					{
						return horizontalCenter * 2;
					}
				}
				return left;
			}
		}
		return item.x;
	}
	
	/**
	 * @private
	 */
	private function layoutWithBounds(items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float):Void
	{
		this._helperVector1.length = 0;
		this._helperVector2.length = 0;
		var mainVector:Array<DisplayObject> = items;
		var otherVector:Array<DisplayObject> = this._helperVector1;
		this.layoutVector(items, otherVector, x, y, width, height);
		var currentLength:Float = otherVector.length;
		while (currentLength > 0)
		{
			if (otherVector == this._helperVector1)
			{
				mainVector = this._helperVector1;
				otherVector = this._helperVector2;
			}
			else
			{
				mainVector = this._helperVector2;
				otherVector = this._helperVector1;
			}
			this.layoutVector(mainVector, otherVector, x, y, width, height);
			var oldLength:Float = currentLength;
			currentLength = otherVector.length;
			if (oldLength == currentLength)
			{
				this._helperVector1.length = 0;
				this._helperVector2.length = 0;
				throw new IllegalOperationError(CIRCULAR_REFERENCE_ERROR);
			}
		}
		this._helperVector1.length = 0;
		this._helperVector2.length = 0;
	}
	
	/**
	 * @private
	 */
	private function layoutVector(items:Array<DisplayObject>, unpositionedItems:Array<DisplayObject>, boundsX:Float, boundsY:Float, viewPortWidth:Float, viewPortHeight:Float):Void
	{
		unpositionedItems.length = 0;
		var itemCount:Int = items.length;
		var pushIndex:Int = 0;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = items[i];
			var layoutItem:ILayoutDisplayObject = cast item;
			if (layoutItem == null || !layoutItem.includeInLayout)
			{
				continue;
			}
			var layoutData:AnchorLayoutData = layoutItem.layoutData as AnchorLayoutData;
			if (layoutData == null)
			{
				continue;
			}
			
			var isReadyForLayout:Bool = this.isReadyForLayout(layoutData, i, items, unpositionedItems);
			if (!isReadyForLayout)
			{
				unpositionedItems[pushIndex] = item;
				pushIndex++;
				continue;
			}
			this.positionHorizontally(layoutItem, layoutData, boundsX, boundsY, viewPortWidth, viewPortHeight);
			this.positionVertically(layoutItem, layoutData, boundsX, boundsY, viewPortWidth, viewPortHeight);
		}
	}
	
	/**
	 * @private
	 */
	private function positionHorizontally(item:ILayoutDisplayObject, layoutData:AnchorLayoutData, boundsX:Float, boundsY:Float, viewPortWidth:Float, viewPortHeight:Float):Void
	{
		var uiItem:IMeasureDisplayObject = cast item;
		var percentWidth:Float = layoutData.percentWidth;
		if (percentWidth == percentWidth) //!isNaN
		{
			if (percentWidth < 0)
			{
				percentWidth = 0;
			}
			else if (percentWidth > 100)
			{
				percentWidth = 100;
			}
			var itemWidth:Float = percentWidth * 0.01 * viewPortWidth;
			if (uiItem != null)
			{
				var minWidth:Float = uiItem.explicitMinWidth;
				var maxWidth:Float = uiItem.explicitMaxWidth;
				if (itemWidth < minWidth)
				{
					itemWidth = minWidth;
				}
				else if (itemWidth > maxWidth)
				{
					itemWidth = maxWidth;
				}
			}
			if (itemWidth > viewPortWidth)
			{
				itemWidth = viewPortWidth;
			}
			if (uiItem.explicitMaxWidth == uiItem.explicitMaxWidth &&
				uiItem.explicitMaxWidth < itemWidth)
			{
				itemWidth = uiItem.explicitMaxWidth;
			}
			item.width = itemWidth;
		}
		var left:Float = layoutData.left;
		var hasLeftPosition:Bool = left == left; //!isNaN
		if (hasLeftPosition)
		{
			var leftAnchorDisplayObject:DisplayObject = layoutData.leftAnchorDisplayObject;
			if (leftAnchorDisplayObject != null)
			{
				item.x = item.pivotX + leftAnchorDisplayObject.x - leftAnchorDisplayObject.pivotX + leftAnchorDisplayObject.width + left;
			}
			else
			{
				item.x = item.pivotX + boundsX + left;
			}
		}
		var horizontalCenter:Float = layoutData.horizontalCenter;
		var hasHorizontalCenterPosition:Bool = horizontalCenter == horizontalCenter; //!isNaN
		var right:Float = layoutData.right;
		var hasRightPosition:Bool = right == right; //!isNaN
		if (hasRightPosition)
		{
			var rightAnchorDisplayObject:DisplayObject = layoutData.rightAnchorDisplayObject;
			if (hasLeftPosition)
			{
				var leftRightWidth:Float = viewPortWidth;
				if (rightAnchorDisplayObject != null)
				{
					leftRightWidth = rightAnchorDisplayObject.x - rightAnchorDisplayObject.pivotX;
				}
				if (leftAnchorDisplayObject != null)
				{
					leftRightWidth -= (leftAnchorDisplayObject.x - leftAnchorDisplayObject.pivotX + leftAnchorDisplayObject.width);
				}
				itemWidth = leftRightWidth - right - left;
				if (uiItem.explicitMaxWidth == uiItem.explicitMaxWidth && //!isNaN
					uiItem.explicitMaxWidth < itemWidth)
				{
					itemWidth = uiItem.explicitMaxWidth;
				}
				item.width = itemWidth;
			}
			else if (hasHorizontalCenterPosition)
			{
				var horizontalCenterAnchorDisplayObject:DisplayObject = layoutData.horizontalCenterAnchorDisplayObject;
				var xPositionOfCenter:Float;
				if (horizontalCenterAnchorDisplayObject != null)
				{
					xPositionOfCenter = horizontalCenterAnchorDisplayObject.x - horizontalCenterAnchorDisplayObject.pivotX + Math.fround(horizontalCenterAnchorDisplayObject.width / 2) + horizontalCenter;
				}
				else
				{
					xPositionOfCenter = Math.fround(viewPortWidth / 2) + horizontalCenter;
				}
				var xPositionOfRight:Float;
				if (rightAnchorDisplayObject != null)
				{
					xPositionOfRight = rightAnchorDisplayObject.x - rightAnchorDisplayObject.pivotX - right;
				}
				else
				{
					xPositionOfRight = viewPortWidth - right;
				}
				itemWidth = 2 * (xPositionOfRight - xPositionOfCenter);
				if (uiItem.explicitMaxWidth == uiItem.explicitMaxWidth && //!isNaN
					uiItem.explicitMaxWidth < itemWidth)
				{
					itemWidth = uiItem.explicitMaxWidth;
				}
				item.width = itemWidth;
				item.x = item.pivotX + viewPortWidth - right - item.width;
			}
			else
			{
				if (rightAnchorDisplayObject != null)
				{
					item.x = item.pivotX + rightAnchorDisplayObject.x - rightAnchorDisplayObject.pivotX - item.width - right;
				}
				else
				{
					item.x = item.pivotX + boundsX + viewPortWidth - right - item.width;
				}
			}
		}
		else if (hasHorizontalCenterPosition)
		{
			horizontalCenterAnchorDisplayObject = layoutData.horizontalCenterAnchorDisplayObject;
			if (horizontalCenterAnchorDisplayObject != null)
			{
				xPositionOfCenter = horizontalCenterAnchorDisplayObject.x - horizontalCenterAnchorDisplayObject.pivotX + Math.round(horizontalCenterAnchorDisplayObject.width / 2) + horizontalCenter;
			}
			else
			{
				xPositionOfCenter = Math.fround(viewPortWidth / 2) + horizontalCenter;
			}
			
			if (hasLeftPosition)
			{
				itemWidth = 2 * (xPositionOfCenter - item.x + item.pivotX);
				if (uiItem.explicitMaxWidth == uiItem.explicitMaxWidth && //!isNaN
					uiItem.explicitMaxWidth < itemWidth)
				{
					itemWidth = uiItem.explicitMaxWidth;
				}
				item.width = itemWidth;
			}
			else
			{
				item.x = item.pivotX + xPositionOfCenter - Math.fround(item.width / 2);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function positionVertically(item:ILayoutDisplayObject, layoutData:AnchorLayoutData, boundsX:Float, boundsY:Float, viewPortWidth:Float, viewPortHeight:Float):Void
	{
		var uiItem:IMeasureDisplayObject = item as IMeasureDisplayObject;
		var percentHeight:Float = layoutData.percentHeight;
		if (percentHeight == percentHeight) //!isNaN
		{
			if (percentHeight < 0)
			{
				percentHeight = 0;
			}
			else if (percentHeight > 100)
			{
				percentHeight = 100;
			}
			var itemHeight:Float = percentHeight * 0.01 * viewPortHeight;
			if (uiItem != null)
			{
				var minHeight:Float = uiItem.explicitMinHeight;
				var maxHeight:Float = uiItem.explicitMaxHeight;
				if (itemHeight < minHeight)
				{
					itemHeight = minHeight;
				}
				else if (itemHeight > maxHeight)
				{
					itemHeight = maxHeight;
				}
			}
			if (itemHeight > viewPortHeight)
			{
				itemHeight = viewPortHeight;
			}
			if (uiItem.explicitMaxHeight == uiItem.explicitMaxHeight && //!isNaN
				uiItem.explicitMaxHeight < itemHeight)
			{
				itemHeight = uiItem.explicitMaxHeight;
			}
			item.height = itemHeight;
		}
		var top:Float = layoutData.top;
		var hasTopPosition:Bool = top == top; //!isNaN
		if (hasTopPosition)
		{
			var topAnchorDisplayObject:DisplayObject = layoutData.topAnchorDisplayObject;
			if (topAnchorDisplayObject != null)
			{
				item.y = item.pivotY + topAnchorDisplayObject.y - topAnchorDisplayObject.pivotY + topAnchorDisplayObject.height + top;
			}
			else
			{
				item.y = item.pivotY + boundsY + top;
			}
		}
		var verticalCenter:Float = layoutData.verticalCenter;
		var hasVerticalCenterPosition:Bool = verticalCenter == verticalCenter; //!isNaN
		var bottom:Float = layoutData.bottom;
		var hasBottomPosition:Bool = bottom == bottom; //!isNaN
		if (hasBottomPosition)
		{
			var bottomAnchorDisplayObject:DisplayObject = layoutData.bottomAnchorDisplayObject;
			if (hasTopPosition)
			{
				var topBottomHeight:Float = viewPortHeight;
				if (bottomAnchorDisplayObject != null)
				{
					topBottomHeight = bottomAnchorDisplayObject.y - bottomAnchorDisplayObject.pivotY;
				}
				if (topAnchorDisplayObject != null)
				{
					topBottomHeight -= (topAnchorDisplayObject.y - topAnchorDisplayObject.pivotY + topAnchorDisplayObject.height);
				}
				itemHeight = topBottomHeight - bottom - top;
				if (uiItem.explicitMaxHeight == uiItem.explicitMaxHeight && //!isNaN
					uiItem.explicitMaxHeight < itemHeight)
				{
					itemHeight = uiItem.explicitMaxHeight;
				}
				item.height = itemHeight;
			}
			else if (hasVerticalCenterPosition)
			{
				var verticalCenterAnchorDisplayObject:DisplayObject = layoutData.verticalCenterAnchorDisplayObject;
				var yPositionOfCenter:Float;
				if (verticalCenterAnchorDisplayObject != null)
				{
					yPositionOfCenter = verticalCenterAnchorDisplayObject.y - verticalCenterAnchorDisplayObject.pivotY + Math.fround(verticalCenterAnchorDisplayObject.height / 2) + verticalCenter;
				}
				else
				{
					yPositionOfCenter = Math.fround(viewPortHeight / 2) + verticalCenter;
				}
				var yPositionOfBottom:Float;
				if (bottomAnchorDisplayObject != null)
				{
					yPositionOfBottom = bottomAnchorDisplayObject.y - bottomAnchorDisplayObject.pivotY - bottom;
				}
				else
				{
					yPositionOfBottom = viewPortHeight - bottom;
				}
				itemHeight = 2 * (yPositionOfBottom - yPositionOfCenter);
				if (uiItem.explicitMaxHeight == uiItem.explicitMaxHeight && //!isNaN
					uiItem.explicitMaxHeight < itemHeight)
				{
					itemHeight = uiItem.explicitMaxHeight;
				}
				item.height = itemHeight;
				item.y = item.pivotY + viewPortHeight - bottom - item.height;
			}
			else
			{
				if (bottomAnchorDisplayObject != null)
				{
					item.y = item.pivotY + bottomAnchorDisplayObject.y - bottomAnchorDisplayObject.pivotY - item.height - bottom;
				}
				else
				{
					item.y = item.pivotY + boundsY + viewPortHeight - bottom - item.height;
				}
			}
		}
		else if (hasVerticalCenterPosition)
		{
			verticalCenterAnchorDisplayObject = layoutData.verticalCenterAnchorDisplayObject;
			if (verticalCenterAnchorDisplayObject != null)
			{
				yPositionOfCenter = verticalCenterAnchorDisplayObject.y - verticalCenterAnchorDisplayObject.pivotY + Math.fround(verticalCenterAnchorDisplayObject.height / 2) + verticalCenter;
			}
			else
			{
				yPositionOfCenter = Math.fround(viewPortHeight / 2) + verticalCenter;
			}
			
			if (hasTopPosition)
			{
				itemHeight = 2 * (yPositionOfCenter - item.y + item.pivotY);
				if (uiItem.explicitMaxHeight == uiItem.explicitMaxHeight && //!isNaN
					uiItem.explicitMaxHeight < itemHeight)
				{
					itemHeight = uiItem.explicitMaxHeight;
				}
				item.height = itemHeight;
			}
			else
			{
				item.y = item.pivotY + yPositionOfCenter - Math.fround(item.height / 2);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function measureContent(items:Array<DisplayObject>, viewPortWidth:Float, viewPortHeight:Float, result:Point = null):Point
	{
		var maxX:Float = viewPortWidth;
		var maxY:Float = viewPortHeight;
		var itemCount:Int = items.length;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = items[i];
			var itemMaxX:Float = item.x - item.pivotX + item.width;
			var itemMaxY:Float = item.y - item.pivotY + item.height;
			if (itemMaxX == itemMaxX && //!isNaN
				itemMaxX > maxX)
			{
				maxX = itemMaxX;
			}
			if (itemMaxY == itemMaxY && //!isNaN
				itemMaxY > maxY)
			{
				maxY = itemMaxY;
			}
		}
		result.x = maxX;
		result.y = maxY;
		return result;
	}
	
	/**
	 * @private
	 */
	private function isReadyForLayout(layoutData:AnchorLayoutData, index:Int, items:Array<DisplayObject>, unpositionedItems:Array<DisplayObject>):Bool
	{
		var nextIndex:Int = index + 1;
		var leftAnchorDisplayObject:DisplayObject = layoutData.leftAnchorDisplayObject;
		if (leftAnchorDisplayObject != null && (items.indexOf(leftAnchorDisplayObject, nextIndex) >= nextIndex || unpositionedItems.indexOf(leftAnchorDisplayObject) >= 0))
		{
			return false;
		}
		var rightAnchorDisplayObject:DisplayObject = layoutData.rightAnchorDisplayObject;
		if (rightAnchorDisplayObject != null && (items.indexOf(rightAnchorDisplayObject, nextIndex) >= nextIndex || unpositionedItems.indexOf(rightAnchorDisplayObject) >= 0))
		{
			return false;
		}
		var topAnchorDisplayObject:DisplayObject = layoutData.topAnchorDisplayObject;
		if (topAnchorDisplayObject != null && (items.indexOf(topAnchorDisplayObject, nextIndex) >= nextIndex || unpositionedItems.indexOf(topAnchorDisplayObject) >= 0))
		{
			return false;
		}
		var bottomAnchorDisplayObject:DisplayObject = layoutData.bottomAnchorDisplayObject;
		if (bottomAnchorDisplayObject != null && (items.indexOf(bottomAnchorDisplayObject, nextIndex) >= nextIndex || unpositionedItems.indexOf(bottomAnchorDisplayObject) >= 0))
		{
			return false;
		}
		var horizontalCenterAnchorDisplayObject:DisplayObject = layoutData.horizontalCenterAnchorDisplayObject;
		if (horizontalCenterAnchorDisplayObject != null && (items.indexOf(horizontalCenterAnchorDisplayObject, nextIndex) >= nextIndex || unpositionedItems.indexOf(horizontalCenterAnchorDisplayObject) >= 0))
		{
			return false;
		}
		var verticalCenterAnchorDisplayObject:DisplayObject = layoutData.verticalCenterAnchorDisplayObject;
		if (verticalCenterAnchorDisplayObject != null && (items.indexOf(verticalCenterAnchorDisplayObject, nextIndex) >= nextIndex || unpositionedItems.indexOf(verticalCenterAnchorDisplayObject) >= 0))
		{
			return false;
		}
		return true;
	}
	
	/**
	 * @private
	 */
	private function isReferenced(item:DisplayObject, items:Array<DisplayObject>):Bool
	{
		var itemCount:Int = items.length;
		for (i in 0...itemCount)
		{
			var otherItem:ILayoutDisplayObject = cast items[i];
			if (otherItem == null || otherItem == item)
			{
				continue;
			}
			var layoutData:AnchorLayoutData = cast otherItem.layoutData;
			if (layoutData == null)
			{
				continue;
			}
			if (layoutData.leftAnchorDisplayObject == item || layoutData.horizontalCenterAnchorDisplayObject == item ||
				layoutData.rightAnchorDisplayObject == item || layoutData.topAnchorDisplayObject == item ||
				layoutData.verticalCenterAnchorDisplayObject == item || layoutData.bottomAnchorDisplayObject == item)
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * @private
	 */
	private function validateItems(items:Array<DisplayObject>,
		explicitWidth:Float, explicitHeight:Float,
		maxWidth:Float, maxHeight:Float, force:Bool):Void
	{
		var needsWidth:Bool = explicitWidth != explicitWidth; //isNaN
		var needsHeight:Bool = explicitHeight != explicitHeight; //isNaN
		var containerWidth:Float = explicitWidth;
		if (needsWidth && maxWidth < Math.POSITIVE_INFINITY)
		{
			containerWidth = maxWidth;
		}
		var containerHeight:Float = explicitHeight;
		if (needsHeight && maxHeight < Math.POSITIVE_INFINITY)
		{
			containerHeight = maxHeight;
		}
		var itemCount:Int = items.length;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = items[i];
			if (Std.isOfType(item, ILayoutDisplayObject))
			{
				var layoutItem:ILayoutDisplayObject = cast item;
				if (!layoutItem.includeInLayout)
				{
					continue;
				}
				var layoutData:AnchorLayoutData = cast layoutItem.layoutData;
				if (layoutData != null)
				{
					var left:Float = layoutData.left;
					var hasLeftPosition:Bool = left == left; //!isNaN
					var leftAnchor:DisplayObject = layoutData.leftAnchorDisplayObject;
					var right:Float = layoutData.right;
					var rightAnchor:DisplayObject = layoutData.rightAnchorDisplayObject;
					var hasRightPosition:Bool = right == right; //!isNaN
					var percentWidth:Float = layoutData.percentWidth;
					var hasPercentWidth:Bool = percentWidth == percentWidth; //!isNaN
					var measureItem:IMeasureDisplayObject = cast item;
					if (needsWidth)
					{
						if (hasLeftPosition && leftAnchor == null &&
							hasRightPosition && rightAnchor == null)
						{
							measureItem.width = Math.NaN;
							measureItem.maxWidth = maxWidth - left - right;
						}
						else if (hasPercentWidth)
						{
							if (percentWidth < 0)
							{
								percentWidth = 0;
							}
							else if (percentWidth > 100)
							{
								percentWidth = 100;
							}
							measureItem.width = Math.NaN;
							measureItem.maxWidth = percentWidth * 0.01 * maxWidth;
						}
					}
					else
					{
						//optimization: set the child width before
						//validation if the container width is explicit
						//or has a maximum
						if (hasLeftPosition && leftAnchor == null &&
							hasRightPosition && rightAnchor == null)
						{
							var itemWidth:Float = containerWidth - left - right;
							if (measureItem.explicitMaxWidth == measureItem.explicitMaxWidth && //!isNaN
								measureItem.explicitMaxWidth < itemWidth)
							{
								itemWidth = measureItem.explicitMaxWidth;
							}
							item.width = itemWidth;
						}
						else if (hasPercentWidth)
						{
							if (percentWidth < 0)
							{
								percentWidth = 0;
							}
							else if (percentWidth > 100)
							{
								percentWidth = 100;
							}
							itemWidth = percentWidth * 0.01 * containerWidth;
							if (measureItem.explicitMaxWidth == measureItem.explicitMaxWidth && //!isNaN
								measureItem.explicitMaxWidth < itemWidth)
							{
								itemWidth = measureItem.explicitMaxWidth;
							}
							item.width = itemWidth;
						}
					}
					var horizontalCenter:Float = layoutData.horizontalCenter;
					var hasHorizontalCenterPosition:Bool = horizontalCenter == horizontalCenter; //!isNaN
					
					var top:Float = layoutData.top;
					var hasTopPosition:Bool = top == top; //!isNaN
					var topAnchor:DisplayObject = layoutData.topAnchorDisplayObject;
					var bottom:Float = layoutData.bottom;
					var hasBottomPosition:Bool = bottom == bottom; //!isNaN
					var bottomAnchor:DisplayObject = layoutData.bottomAnchorDisplayObject;
					var percentHeight:Float = layoutData.percentHeight;
					var hasPercentHeight:Bool = percentHeight == percentHeight; //!isNaN
					if (!needsHeight)
					{
						//optimization: set the child height before
						//validation if the container height is explicit
						//or has a maximum.
						if (hasTopPosition && topAnchor == null &&
							hasBottomPosition && bottomAnchor == null)
						{
							var itemHeight:Float = containerHeight - top - bottom;
							if (measureItem.explicitMaxHeight == measureItem.explicitMaxHeight && //!isNaN
								measureItem.explicitMaxHeight < itemHeight)
							{
								itemHeight = measureItem.explicitMaxHeight;
							}
							item.height = itemHeight;
						}
						else if (hasPercentHeight)
						{
							if (percentHeight < 0)
							{
								percentHeight = 0;
							}
							else if (percentHeight > 100)
							{
								percentHeight = 100;
							}
							itemHeight = percentHeight * 0.01 * containerHeight;
							if (measureItem.explicitMaxHeight == measureItem.explicitMaxHeight && //!isNaN
								measureItem.explicitMaxHeight < itemHeight)
							{
								itemHeight = measureItem.explicitMaxHeight;
							}
							item.height = itemHeight;
						}
					}
					var verticalCenter:Float = layoutData.verticalCenter;
					var hasVerticalCenterPosition:Bool = verticalCenter == verticalCenter; //!isNaN
					
					if ((hasRightPosition && !hasLeftPosition && !hasHorizontalCenterPosition) ||
						hasHorizontalCenterPosition)
					{
						if (Std.isOfType(item, IValidating))
						{
							cast(item, IValidating).validate();
						}
						continue;
					}
					else if ((hasBottomPosition && !hasTopPosition && !hasVerticalCenterPosition) ||
						hasVerticalCenterPosition)
					{
						if (Std.isOfType(item, IValidating))
						{
							cast(item, IValidating).validate();
						}
						continue;
					}
				}
			}
			if (force || this.isReferenced(item, items))
			{
				if (Std.isOfType(item, IValidating))
				{
					cast(item, IValidating).validate();
				}
			}
		}
	}
	
}