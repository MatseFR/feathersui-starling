/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;

import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Extra, optional data used by an <code>AnchorLayout</code> instance to
 * position and size a display object.
 *
 * @see AnchorLayout
 * @see ILayoutDisplayObject
 *
 * @productversion Feathers 1.1.0
 */
class AnchorLayoutData extends EventDispatcher implements ILayoutData
{
	/**
	 * Constructor.
	 */
	public function new(?top:Float, ?right:Float, ?bottom:Float, ?left:Float,
		?horizontalCenter:Float, ?verticalCenter:Float) 
	{
		super();
		this.top = top != null ? top : Math.NaN;
		this.right = right != null ? right : Math.NaN;
		this.bottom = bottom != null ? bottom : Math.NaN;
		this.left = left != null ? left : Math.NaN;
		this.horizontalCenter = horizontalCenter != null ? horizontalCenter : Math.NaN;
		this.verticalCenter = verticalCenter != null ? verticalCenter : Math.NaN;
	}
	
	/**
	 * The width of the layout object, as a percentage of the container's
	 * width.
	 *
	 * <p>A percentage may be specified in the range from <code>0</code>
	 * to <code>100</code>. If the value is set to <code>NaN</code>, this
	 * property is ignored.</p>
	 *
	 * @default NaN
	 */
	public var percentWidth(get, set):Float;
	private var _percentWidth:Float = Math.NaN;
	private function get_percentWidth():Float { return this._percentWidth; }
	private function set_percentWidth(value:Float):Float
	{
		if (this._percentWidth == value)
		{
			return value;
		}
		this._percentWidth = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._percentWidth;
	}
	
	/**
	 * The height of the layout object, as a percentage of the container's
	 * height.
	 *
	 * <p>A percentage may be specified in the range from <code>0</code>
	 * to <code>100</code>. If the value is set to <code>NaN</code>, this
	 * property is ignored.</p>
	 *
	 * @default NaN
	 */
	public var percentHeight(get, set):Float;
	private var _percentHeight:Float = Math.NaN;
	private function get_percentHeight():Float { return this._percentHeight; }
	private function set_percentHeight(value:Float):Float
	{
		if (this._percentHeight == value)
		{
			return value;
		}
		this._percentHeight = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._percentHeight;
	}
	
	/**
	 * The top edge of the layout object will be relative to this anchor.
	 * If there is no anchor, the top edge of the parent container will be
	 * the anchor.
	 *
	 * @default null
	 *
	 * @see #top
	 */
	public var topAnchorDisplayObject(get, set):DisplayObject;
	private var _topAnchorDisplayObject:DisplayObject;
	private function get_topAnchorDisplayObject():DisplayObject { return this._topAnchorDisplayObject; }
	private function set_topAnchorDisplayObject(value:DisplayObject):DisplayObject
	{
		if (this._topAnchorDisplayObject == value)
		{
			return value;
		}
		this._topAnchorDisplayObject = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._topAnchorDisplayObject;
	}
	
	/**
	 * The position, in pixels, of the top edge relative to the top
	 * anchor, or, if there is no top anchor, then the position is relative
	 * to the top edge of the parent container. If this value is
	 * <code>NaN</code>, the object's top edge will not be anchored.
	 *
	 * @default NaN
	 *
	 * @see #topAnchorDisplayObject
	 */
	public var top(get, set):Float;
	private var _top:Float = Math.NaN;
	private function get_top():Float { return this._top; }
	private function set_top(value:Float):Float
	{
		if (this._top == value)
		{
			return value;
		}
		this._top = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._top;
	}
	
	/**
	 * The right edge of the layout object will be relative to this anchor.
	 * If there is no anchor, the right edge of the parent container will be
	 * the anchor.
	 *
	 * @default null
	 *
	 * @see #right
	 */
	public var rightAnchorDisplayObject(get, set):DisplayObject;
	private var _rightAnchorDisplayObject:DisplayObject;
	private function get_rightAnchorDisplayObject():DisplayObject { return this._rightAnchorDisplayObject; }
	private function set_rightAnchorDisplayObject(value:DisplayObject):DisplayObject
	{
		if (this._rightAnchorDisplayObject == value)
		{
			return value;
		}
		this._rightAnchorDisplayObject = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._rightAnchorDisplayObject;
	}
	
	/**
	 * The position, in pixels, of the right edge relative to the right
	 * anchor, or, if there is no right anchor, then the position is relative
	 * to the right edge of the parent container. If this value is
	 * <code>NaN</code>, the object's right edge will not be anchored.
	 *
	 * @default NaN
	 *
	 * @see #rightAnchorDisplayObject
	 */
	public var right(get, set):Float;
	private var _right:Float = Math.NaN;
	private function get_right():Float { return this._right; }
	private function set_right(value:Float):Float
	{
		if (this._right == value)
		{
			return value;
		}
		this._right = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._right;
	}
	
	/**
	 * The bottom edge of the layout object will be relative to this anchor.
	 * If there is no anchor, the bottom edge of the parent container will be
	 * the anchor.
	 *
	 * @default null
	 *
	 * @see #bottom
	 */
	public var bottomAnchorDisplayObject(get, set):DisplayObject;
	private var _bottomAnchorDisplayObject:DisplayObject;
	private function get_bottomAnchorDisplayObject():DisplayObject { return this._bottomAnchorDisplayObject; }
	private function set_bottomAnchorDisplayObject(value:DisplayObject):DisplayObject
	{
		if (this._bottomAnchorDisplayObject == value)
		{
			return value;
		}
		this._bottomAnchorDisplayObject = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._bottomAnchorDisplayObject;
	}
	
	/**
	 * The position, in pixels, of the bottom edge relative to the bottom
	 * anchor, or, if there is no bottom anchor, then the position is relative
	 * to the bottom edge of the parent container. If this value is
	 * <code>NaN</code>, the object's bottom edge will not be anchored.
	 *
	 * @default NaN
	 *
	 * @see #bottomAnchorDisplayObject
	 */
	public var bottom(get, set):Float;
	private var _bottom:Float = Math.NaN;
	private function get_bottom():Float { return this._bottom; }
	private function set_bottom(value:Float):Float
	{
		if (this._bottom == value)
		{
			return value;
		}
		this._bottom = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._bottom;
	}
	
	/**
	 * The left edge of the layout object will be relative to this anchor.
	 * If there is no anchor, the left edge of the parent container will be
	 * the anchor.
	 *
	 * @default null
	 *
	 * @see #left
	 */
	public var leftAnchorDisplayObject(get, set):DisplayObject;
	private var _leftAnchorDisplayObject:DisplayObject;
	private function get_leftAnchorDisplayObject():DisplayObject { return this._leftAnchorDisplayObject; }
	private function set_leftAnchorDisplayObject(value:DisplayObject):DisplayObject
	{
		if (this._leftAnchorDisplayObject == value)
		{
			return value;
		}
		this._leftAnchorDisplayObject = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._leftAnchorDisplayObject;
	}
	
	/**
	 * The position, in pixels, of the left edge relative to the left
	 * anchor, or, if there is no left anchor, then the position is relative
	 * to the left edge of the parent container. If this value is
	 * <code>NaN</code>, the object's left edge will not be anchored.
	 *
	 * @default NaN
	 *
	 * @see #leftAnchorDisplayObject
	 */
	public var left(get, set):Float;
	private var _left:Float = Math.NaN;
	private function get_left():Float { return this._left; }
	private function set_left(value:Float):Float
	{
		if (this._left == value)
		{
			return value;
		}
		this._left = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._left;
	}
	
	/**
	 * The horizontal center of the layout object will be relative to this
	 * anchor. If there is no anchor, the horizontal center of the parent
	 * container will be the anchor.
	 *
	 * @default null
	 *
	 * @see #horizontalCenter
	 */
	public var horizontalCenterAnchorDisplayObject(get, set):DisplayObject;
	private var _horizontalCenterAnchorDisplayObject:DisplayObject;
	private function get_horizontalCenterAnchorDisplayObject():DisplayObject { return this._horizontalCenterAnchorDisplayObject; }
	private function set_horizontalCenterAnchorDisplayObject(value:DisplayObject):DisplayObject
	{
		if (this._horizontalCenterAnchorDisplayObject == value)
		{
			return value;
		}
		this._horizontalCenterAnchorDisplayObject = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._horizontalCenterAnchorDisplayObject;
	}
	
	/**
	 * The position, in pixels, of the horizontal center relative to the
	 * horizontal center anchor, or, if there is no horizontal center
	 * anchor, then the position is relative to the horizontal center of the
	 * parent container. If this value is <code>NaN</code>, the object's
	 * horizontal center will not be anchored.
	 *
	 * @default NaN
	 *
	 * @see #horizontalCenterAnchorDisplayObject
	 */
	public var horizontalCenter(get, set):Float;
	private var _horizontalCenter:Float = Math.NaN;
	private function get_horizontalCenter():Float { return this._horizontalCenter; }
	private function set_horizontalCenter(value:Float):Float
	{
		if (this._horizontalCenter == value)
		{
			return value;
		}
		this._horizontalCenter = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._horizontalCenter;
	}
	
	/**
	 * The vertical center of the layout object will be relative to this
	 * anchor. If there is no anchor, the vertical center of the parent
	 * container will be the anchor.
	 *
	 * @default null
	 *
	 * @see #verticalCenter
	 */
	public var verticalCenterAnchorDisplayObject(get, set):DisplayObject;
	private var _verticalCenterAnchorDisplayObject:DisplayObject;
	private function get_verticalCenterAnchorDisplayObject():DisplayObject { return this._verticalCenterAnchorDisplayObject; }
	private function set_verticalCenterAnchorDisplayObject(value:DisplayObject):DisplayObject
	{
		if (this._verticalCenterAnchorDisplayObject == value)
		{
			return value;
		}
		this._verticalCenterAnchorDisplayObject = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._verticalCenterAnchorDisplayObject;
	}
	
	/**
	 * The position, in pixels, of the vertical center relative to the
	 * vertical center anchor, or, if there is no vertical center anchor,
	 * then the position is relative to the vertical center of the parent
	 * container. If this value is <code>NaN</code>, the object's vertical
	 * center will not be anchored.
	 *
	 * @default NaN
	 *
	 * @see #verticalCenterAnchorDisplayObject
	 */
	public var verticalCenter(get, set):Float;
	private var _verticalCenter:Float = Math.NaN;
	private function get_verticalCenter():Float { return this._verticalCenter; }
	private function set_verticalCenter(value:Float):Float
	{
		if (this._verticalCenter == value)
		{
			return value;
		}
		this._verticalCenter = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._verticalCenter;
	}
	
}