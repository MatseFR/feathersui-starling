/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.events;

import feathers.starling.dragDrop.DragData;
import feathers.starling.dragDrop.IDragSource;
import starling.events.Event;

/**
 * Events used by the <code>DragDropManager</code>.
 *
 * @see feathers.dragDrop.DragDropManager
 *
 * @productversion Feathers 1.0.0
 */
class DragDropEvent extends Event 
{
	/**
	 * Dispatched by the <code>IDragSource</code> when a drag starts.
	 *
	 * @see feathers.dragDrop.IDragSource
	 */
	public static inline var DRAG_START:String = "dragStart";

	/**
	 * Dispatched by the <code>IDragSource</code> when a drag completes.
	 * This is always dispatched, even when there wasn't a successful drop.
	 * See the <code>isDropped</code> property to determine if the drop
	 * was successful.
	 *
	 * @see feathers.dragDrop.IDragSource
	 */
	public static inline var DRAG_COMPLETE:String = "dragComplete";

	/**
	 * Dispatched by a <code>IDropTarget</code> when a drag enters its
	 * bounds.
	 *
	 * @see feathers.dragDrop.IDropTarget
	 */
	public static inline var DRAG_ENTER:String = "dragEnter";

	/**
	 * Dispatched by a <code>IDropTarget</code> when a drag moves to a new
	 * location within its bounds.
	 *
	 * @see feathers.dragDrop.IDropTarget
	 */
	public static inline var DRAG_MOVE:String = "dragMove";

	/**
	 * Dispatched by a <code>IDropTarget</code> when a drag exits its
	 * bounds.
	 *
	 * @see feathers.dragDrop.IDropTarget
	 */
	public static inline var DRAG_EXIT:String = "dragExit";

	/**
	 * Dispatched by a <code>IDropTarget</code> when a drop occurs.
	 *
	 * @see feathers.dragDrop.IDropTarget
	 */
	public static inline var DRAG_DROP:String = "dragDrop";
	
	/**
	 * Constructor.
	 */
	public function new(type:String, dragData:DragData, isDropped:Bool, localX:Null<Float> = null, localY:Null<Float> = null, dragSource:IDragSource = null) 
	{
		if (localX == null) localX = Math.NaN;
		if (localY == null) localY = Math.NaN;
		
		super(type, false, dragData);
		this.isDropped = isDropped;
		this.localX = localX;
		this.localY = localY;
		this.dragSource = dragSource;
	}
	
	/**
	 * The <code>DragData</code> associated with the current drag.
	 */
	public var dragData(get, never):DragData;
	private function get_dragData():DragData { return cast this.data; }
	
	/**
	 * Determines if there has been a drop.
	 */
	public var isDropped:Bool;
	
	/**
	 * The x location, in pixels, of the current action, in the local
	 * coordinate system of the <code>IDropTarget</code>.
	 *
	 * <p>Value will always be <code>NaN</code> for <code>DRAG_START</code>
	 * and <code>DRAG_COMPLETE</code> events.</p>
	 *
	 * @see feathers.dragDrop.IDropTarget
	 */
	public var localX:Float;
	
	/**
	 * The y location, in pixels, of the current action, in the local
	 * coordinate system of the <code>IDropTarget</code>.
	 *
	 * <p>Value will always be <code>NaN</code> for <code>DRAG_START</code>
	 * and <code>DRAG_COMPLETE</code> events.</p>
	 *
	 * @see feathers.dragDrop.IDropTarget
	 */
	public var localY:Float;
	
	/**
	 * The source where the drag started.
	 */
	public var dragSource:IDragSource;
	
}