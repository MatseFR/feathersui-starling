/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;

import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Extra, optional data used by an <code>VerticalLayout</code> instance to
 * position and size a display object.
 *
 * @see VerticalLayout
 * @see ILayoutDisplayObject
 *
 * @productversion Feathers 1.3.0
 */
class VerticalLayoutData extends EventDispatcher implements ILayoutData
{
	/**
	 * Constructor.
	 */
	public function new(?percentWidth:Float, ?percentHeight:Float) 
	{
		super();
		this._percentWidth = percentWidth != null ? percentWidth : Math.NaN;
		this._percentHeight = percentHeight != null ? percentHeight : Math.NaN;
	}
	
	/**
	 * The width of the layout object, as a percentage of the container's
	 * width.
	 *
	 * <p>A percentage may be specified in the range from <code>0</code>
	 * to <code>100</code>. If the value is set to <code>NaN</code>, this
	 * property is ignored.</p>
	 *
	 * <p>Performance tip: If all items in your layout will have 100% width,
	 * it's better to set the <code>horizontalAlign</code> property of the
	 * <code>VerticalLayout</code> to
	 * <code>HorizontalAlign.JUSTIFY</code>.</p>
	 *
	 * @default NaN
	 *
	 * @see feathers.layout.VerticalLayout#horizontalAlign
	 */
	public var percentWidth(get, set):Float;
	private var _percentWidth:Float;
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
	 * height. The container will calculate the sum of all of its children
	 * with explicit pixel heights, and then the remaining space will be
	 * distributed to children with percent heights.
	 *
	 * <p>A percentage may be specified in the range from <code>0</code>
	 * to <code>100</code>. If the value is set to <code>NaN</code>, this
	 * property is ignored. It will also be ignored when the
	 * <code>useVirtualLayout</code> property of the
	 * <code>VerticalLayout</code> is set to <code>false</code>.</p>
	 *
	 * @default NaN
	 */
	public var percentHeight(get, set):Float;
	private var _percentHeight:Float;
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
	
}