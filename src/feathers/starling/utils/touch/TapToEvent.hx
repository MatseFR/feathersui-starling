/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.utils.touch;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Stage;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Dispatches an event from the target when the target is tapped/clicked.
 * Conveniently handles all <code>TouchEvent</code> listeners
 * automatically.
 *
 * <p>In the following example, a custom item renderer will be triggered
 * when tapped:</p>
 *
 * <listing version="3.0">
 * public class CustomItemRenderer extends LayoutGroupListItemRenderer
 * {
 *     public function CustomItemRenderer()
 *     {
 *         super();
 *         this._tapToEvent = new TapToEvent(this, Event.TRIGGERED);
 *     }
 * 
 *     private var _tapToEvent:TapToEvent;
 * }</listing>
 *
 * @see feathers.utils.touch.TapToTrigger
 * @see feathers.utils.touch.TapToSelect
 * @see feathers.utils.touch.LongPress
 *
 * @productversion Feathers 3.4.0
 */
class TapToEvent 
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject = null, eventType:String = null) 
	{
		this.target = target;
		this.eventType = eventType;
	}
	
	/**
	 * The target component that should dispatch the <code>eventType</code>
	 * when tapped.
	 */
	public var target(get, set):DisplayObject;
	private var _target:DisplayObject;
	private function get_target():DisplayObject { return this._target; }
	private function set_target(value:DisplayObject):DisplayObject
	{
		if (this._target == value)
		{
			return value;
		}
		if (this._target != null)
		{
			this._target.removeEventListener(TouchEvent.TOUCH, target_touchHandler);
		}
		this._target = value;
		if (this._target != null)
		{
			//if we're changing targets, and a touch is active, we want to
			//clear it.
			this._touchPointID = -1;
			this._target.addEventListener(TouchEvent.TOUCH, target_touchHandler);
		}
		return this._target;
	}
	
	/**
	 * The event type that will be dispatched when tapped.
	 */
	public var eventType(get, set):String;
	private var _eventType:String = null;
	private function get_eventType():String { return this._eventType; }
	private function set_eventType(value:String):String
	{
		return this._eventType = value;
	}
	
	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;
	
	/**
	 * May be set to <code>false</code> to disable the event dispatching
	 * temporarily until set back to <code>true</code>.
	 */
	public var isEnabled(get, set):Bool;
	private var _isEnabled:Bool = true;
	private function get_isEnabled():Bool { return this._isEnabled; }
	private function set_isEnabled(value:Bool):Bool
	{
		if (this._isEnabled == value)
		{
			return value;
		}
		if (!value)
		{
			this._touchPointID = -1;
		}
		return this._isEnabled = value;
	}
	
	/**
	 * The number of times a component must be tapped before the event will
	 * be dispatched. If the value of <code>tapCount</code> is <code>-1</code>,
	 * the event will be dispatched for every tap.
	 */
	public var tapCount(get, set):Int;
	private var _tapCount:Int = -1;
	private function get_tapCount():Int { return this._tapCount; }
	private function set_tapCount(value:Int):Int
	{
		return this._tapCount = value;
	}
	
	/**
	 * In addition to a normal call to <code>hitTest()</code>, a custom
	 * function may impose additional rules that determine if the target
	 * should be dispatch an event. Called on <code>TouchPhase.BEGAN</code>.
	 *
	 * <p>The function must have the following signature:</p>
	 *
	 * <pre>function(localPosition:Point):Boolean;</pre>
	 *
	 * <p>The function should return <code>true</code> if the target should
	 * dispatch an event, and <code>false</code> if it should not dispatch.</p>
	 */
	public var customHitTest(get, set):Point->Bool;
	private var _customHitTest:Point->Bool;
	private function get_customHitTest():Point->Bool { return this._customHitTest; }
	private function set_customHitTest(value:Point->Bool):Point->Bool
	{
		return this._customHitTest = value;
	}
	
	/**
	 * @private
	 */
	private function target_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		var point:Point;
		var isInBounds:Bool;
		if (this._touchPointID >= 0)
		{
			//a touch has begun, so we'll ignore all other touches.
			touch = event.getTouch(this._target, null, this._touchPointID);
			if (touch == null)
			{
				//this should not happen.
				return;
			}
			
			if (touch.phase == TouchPhase.ENDED)
			{
				var stage:Stage = this._target.stage;
				if (stage != null)
				{
					point = Pool.getPoint();
					touch.getLocation(stage, point);
					if (Std.isOfType(this._target, DisplayObjectContainer))
					{
						isInBounds = cast(this._target, DisplayObjectContainer).contains(stage.hitTest(point));
					}
					else
					{
						isInBounds = this._target == stage.hitTest(point);
					}
					Pool.putPoint(point);
					if (isInBounds && (this._tapCount == -1 || this._tapCount == touch.tapCount))
					{
						this._target.dispatchEventWith(this._eventType);
					}
				}
				
				//the touch has ended, so now we can start watching for a
				//new one.
				this._touchPointID = -1;
			}
			return;
		}
		else
		{
			//we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(this._target, TouchPhase.BEGAN);
			if (touch == null)
			{
				//we only care about the began phase. ignore all other
				//phases when we don't have a saved touch ID.
				return;
			}
			if (this._customHitTest != null)
			{
				point = Pool.getPoint();
				touch.getLocation(this._target, point);
				isInBounds = this._customHitTest(point);
				Pool.putPoint(point);
				if (!isInBounds)
				{
					return;
				}
			}
			
			//save the touch ID so that we can track this touch's phases.
			this._touchPointID = touch.id;
		}
	}
	
}