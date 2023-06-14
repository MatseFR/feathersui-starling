package feathers.starling.examples.gallery.layout;

import feathers.starling.layout.LayoutBoundsResult;
import feathers.starling.layout.ViewPortBounds;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.display.DisplayObject;
import starling.events.EventDispatcher;
import starling.utils.Pool;

class GalleryItemRendererLayout extends EventDispatcher 
{
	public function new() 
	{
		super();
	}
	
	public var requiresLayoutOnScroll(get, never):Bool;
	private function get_requiresLayoutOnScroll():Bool { return false; }
	
	public function layout(items:Array<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult
	{
		var itemCount:Int = items.length;
		if (itemCount > 1)
		{
			throw new IllegalOperationError("GalleryItemLayout may not have more than one item.");
		}
		if (result == null)
		{
			result = new LayoutBoundsResult();
		}
		var minX:Float = Math.POSITIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;
		if (itemCount > 0)
		{
			var item:DisplayObject = items[0];
			var itemBounds:Rectangle = item.getBounds(item.parent, Pool.getRectangle());
			if (itemBounds.x < minX)
			{
				minX = itemBounds.x;
			}
			if (itemBounds.y < minY)
			{
				minY = itemBounds.y;
			}
			var itemMaxX:Float = itemBounds.x + itemBounds.width;
			if (itemMaxX > maxX)
			{
				maxX = itemMaxX;
			}
			var itemMaxY:Float = itemBounds.y + itemBounds.height;
			if (itemMaxY > maxY)
			{
				maxY = itemMaxY;
			}
			Pool.putRectangle(itemBounds);
		}
		if (minX == Math.POSITIVE_INFINITY)
		{
			minX = 0;
		}
		if (minY == Math.POSITIVE_INFINITY)
		{
			minY = 0;
		}
		if (maxX == Math.NEGATIVE_INFINITY)
		{
			maxX = 0;
		}
		if (maxY == Math.NEGATIVE_INFINITY)
		{
			maxY = 0;
		}
		var contentX:Float = minX;
		var contentY:Float = minY;
		var contentWidth:Float = maxX - minX;
		var contentHeight:Float = maxY - minY;
		var viewPortWidth:Float = contentWidth;
		var viewPortHeight:Float = contentHeight;
		if (viewPortBounds && viewPortBounds.explicitWidth == viewPortBounds.explicitWidth)
		{
			viewPortWidth = viewPortBounds.explicitWidth;
		}
		if (viewPortBounds && viewPortBounds.explicitHeight == viewPortBounds.explicitHeight)
		{
			viewPortHeight = viewPortBounds.explicitHeight;
		}
		if (contentWidth <= viewPortWidth)
		{
			contentX -= (viewPortWidth - contentWidth) / 2;
			contentWidth = viewPortWidth;
		}
		if (contentHeight <= viewPortHeight)
		{
			contentY -= (viewPortHeight - contentHeight) / 2;
			contentHeight = viewPortHeight;
		}
		result.contentX = contentX;
		result.contentY = contentY;
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}
	
	public function calculateNavigationDestination(items:Array<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int
	{
		return 0;
	}
	
	public function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		if (result == null)
		{
			return new Point(0, 0);
		}
		result.setTo(0, 0);
		return result;
	}
	
	public function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float,
		items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point
	{
		return getScrollPositionForIndex(index, items, x, y, width, height, result);
	}
}