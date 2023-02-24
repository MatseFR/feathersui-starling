/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.dragDrop;
import feathers.core.PopUpManager;
import feathers.events.DragDropEvent;
import feathers.utils.type.SafeCast;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Stage;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Handles drag and drop operations based on Starling touch events.
 *
 * @see feathers.dragDrop.IDragSource
 * @see feathers.dragDrop.IDropTarget
 * @see feathers.dragDrop.DragData
 *
 * @productversion Feathers 1.0.0
 */
class DragDropManager 
{
	/**
	 * The ID of the touch that initiated the current drag. Returns <code>-1</code>
	 * if there is not an active drag action. In multi-touch applications,
	 * knowing the touch ID is useful if additional actions need to happen
	 * using the same touch.
	 */
	public static var touchPointID(get, never):Int;
	private static var _touchPointID:Int = -1;
	private static function get_touchPointID():Int { return _touchPointID; }
	
	/**
	 * @private
	 */
	private static var _dragSourceStage:Stage;
	
	/**
	 * The <code>IDragSource</code> that started the current drag.
	 */
	public static var dragSource(get, never):IDragSource;
	private static var _dragSource:IDragSource;
	private static function get_dragSource():IDragSource { return _dragSource; }
	
	/**
	 * The data associated with the current drag. Returns <code>null</code>
	 * if there is not a current drag.
	 */
	public static var dragData(get, never):DragData;
	private static var _dragData:DragData;
	private static function get_dragData():DragData { return _dragData; }
	
	/**
	 * Determines if the drag and drop manager is currently handling a drag.
	 * Only one drag may be active at a time.
	 */
	public static var isDragging(get, never):Bool;
	private static function get_isDragging():Bool { return _dragData != null; }
	
	/**
	 * @private
	 * The current target of the current drag.
	 */
	private static var dropTarget:IDropTarget;

	/**
	 * @private
	 * Indicates if the current drag has been accepted by the dropTarget.
	 */
	private static var isAccepted:Bool = false;

	/**
	 * @private
	 * The avatar for the current drag data.
	 */
	private static var avatar:DisplayObject;

	/**
	 * @private
	 */
	private static var avatarOffsetX:Float;

	/**
	 * @private
	 */
	private static var avatarOffsetY:Float;

	/**
	 * @private
	 */
	private static var dropTargetLocalX:Float;

	/**
	 * @private
	 */
	private static var dropTargetLocalY:Float;
	
	/**
	 * @private
	 */
	private static var avatarOldTouchable:Bool;
	
	/**
	 * Starts a new drag. If another drag is currently active, it is
	 * immediately cancelled. Includes an optional "avatar", a visual
	 * representation of the data that is being dragged.
	 */
	public static function startDrag(source:IDragSource, touch:Touch, data:DragData, dragAvatar:DisplayObject = null, dragAvatarOffsetX:Float = 0, dragAvatarOffsetY:Float = 0):Void
	{
		if (isDragging)
		{
			cancelDrag();
		}
		if (source == null)
		{
			throw new ArgumentError("Drag source cannot be null.");
		}
		if (data == null)
		{
			throw new ArgumentError("Drag data cannot be null.");
		}
		_dragSource = source;
		_dragData = data;
		_touchPointID = touch.id;
		avatar = dragAvatar;
		avatarOffsetX = dragAvatarOffsetX;
		avatarOffsetY = dragAvatarOffsetY;
		_dragSourceStage = cast(source, DisplayObject).stage;
		var point:Point = Pool.getPoint();
		touch.getLocation(_dragSourceStage, point);
		if (avatar != null)
		{
			avatarOldTouchable = avatar.touchable;
			avatar.touchable = false;
			avatar.x = point.x + avatarOffsetX;
			avatar.y = point.y + avatarOffsetY;
			PopUpManager.addPopUp(avatar, false, false);
		}
		_dragSourceStage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		var starling:Starling = _dragSourceStage.starling;
		starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler, false, 0, true);
		_dragSource.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_START, data, false, Math.NaN, Math.NaN, _dragSource));
		
		updateDropTarget(point);
		Pool.putPoint(point);
	}
	
	/**
	 * Tells the drag and drop manager if the target will accept the current
	 * drop. Meant to be called in a listener for the target's
	 * <code>DragDropEvent.DRAG_ENTER</code> event.
	 */
	public static function acceptDrag(target:IDropTarget):Void
	{
		if (dropTarget != target)
		{
			throw new ArgumentError("Drop target cannot accept a drag at this time. Acceptance may only happen after the DragDropEvent.DRAG_ENTER event is dispatched and before the DragDropEvent.DRAG_EXIT event is dispatched.");
		}
		isAccepted = true;
	}
	
	/**
	 * Immediately cancels the current drag.
	 */
	public static function cancelDrag():Void
	{
		if (!isDragging)
		{
			return;
		}
		completeDrag(false);
	}
	
	/**
	 * @private
	 */
	private static function completeDrag(isDropped:Bool):Void
	{
		if (!isDragging)
		{
			throw new IllegalOperationError("Drag cannot be completed because none is currently active.");
		}
		if (dropTarget != null)
		{
			dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_EXIT, _dragData, false, dropTargetLocalX, dropTargetLocalY, _dragSource));
			dropTarget = null;
		}
		var source:IDragSource = _dragSource;
		var data:DragData = _dragData;
		cleanup();
		source.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_COMPLETE, data, isDropped, Math.NaN, Math.NaN, source));
	}
	
	/**
	 * @private
	 */
	private static function cleanup():Void
	{
		if (avatar != null)
		{
			//may have been removed from parent already in the drop listener
			if (PopUpManager.isPopUp(avatar))
			{
				PopUpManager.removePopUp(avatar);
			}
			avatar.touchable = avatarOldTouchable;
			avatar = null;
		}
		var starling:Starling = _dragSourceStage.starling;
		_dragSourceStage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler);
		_dragSource = null;
		_dragData = null;
		_dragSourceStage = null;
	}
	
	/**
	 * @private
	 */
	private static function updateDropTarget(location:Point):Void
	{
		var target:DisplayObject = _dragSourceStage.hitTest(location);
		while (target != null && !Std.isOfType(target, IDropTarget))
		{
			target = target.parent;
		}
		if (target != null)
		{
			target.globalToLocal(location, location);
		}
		if (target != SafeCast.safe_cast(dropTarget, DisplayObject))
		{
			if (dropTarget != null)
			{
				//notice that we can reuse the previously saved location
				dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_EXIT, _dragData, false, dropTargetLocalX, dropTargetLocalY, _dragSource));
			}
			dropTarget = cast target;
			isAccepted = false;
			if (dropTarget != null)
			{
				dropTargetLocalX = location.x;
				dropTargetLocalY = location.y;
				dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_ENTER, _dragData, false, dropTargetLocalX, dropTargetLocalY, _dragSource));
			}
		}
		else if (dropTarget != null)
		{
			dropTargetLocalX = location.x;
			dropTargetLocalY = location.y;
			dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_MOVE, _dragData, false, dropTargetLocalX, dropTargetLocalY, _dragSource));
		}
	}
	
	/**
	 * @private
	 */
	private static function nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		// TODO : Keyboard.BACK only available on flash target
		if (event.keyCode == Keyboard.ESCAPE #if flash || event.keyCode == Keyboard.BACK #end)
		{
			event.preventDefault();
			cancelDrag();
		}
	}
	
	/**
	 * @private
	 */
	private static function stage_touchHandler(event:TouchEvent):Void
	{
		var stage:Stage = cast event.currentTarget;
		var touch:Touch = event.getTouch(stage, null, _touchPointID);
		if (touch == null)
		{
			return;
		}
		if (touch.phase == TouchPhase.MOVED)
		{
			var point:Point = Pool.getPoint();
			touch.getLocation(stage, point);
			if (avatar != null)
			{
				avatar.x = point.x + avatarOffsetX;
				avatar.y = point.y + avatarOffsetY;
			}
			updateDropTarget(point);
			Pool.putPoint(point);
		}
		else if (touch.phase == TouchPhase.ENDED)
		{
			_touchPointID = -1;
			var isDropped:Bool = false;
			if (dropTarget != null && isAccepted)
			{
				dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_DROP, _dragData, true, dropTargetLocalX, dropTargetLocalY, _dragSource));
				isDropped = true;
			}
			dropTarget = null;
			completeDrag(isDropped);
		}
	}
	
}