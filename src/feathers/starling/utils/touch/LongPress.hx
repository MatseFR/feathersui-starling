/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.utils.touch;
import feathers.starling.events.FeathersEventType;
import haxe.Timer;
import openfl.Lib.getTimer;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Stage;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Dispatches <code>FeathersEventType.LONG_PRESS</code> from the target when
 * the target is long-pressed. Conveniently handles all
 * <code>TouchEvent</code> listeners automatically. Useful for custom item
 * renderers that should dispatch a long press event.
 *
 * <p>In the following example, a custom item renderer will dispatch
 * a long press event when tapped:</p>
 *
 * <listing version="3.0">
 * public class CustomItemRenderer extends LayoutGroupListItemRenderer
 * {
 *     public function CustomItemRenderer()
 *     {
 *         super();
 *         this._longPress = new LongPress(this);
 *     }
 * 
 *     private var _longPress:LongPress;
 * }</listing>
 *
 * <p>Note: When combined with <code>TapToSelect</code> or
 * <code>TapToTrigger</code>, the <code>LongPress</code> instance should be
 * created first because it needs a higher priority for the
 * <code>TouchEvent.TOUCH</code> event so that it can disable the other
 * events.</p>
 *
 * @see feathers.events.FeathersEventType.LONG_PRESS
 * @see feathers.utils.touch.TapToTrigger
 * @see feathers.utils.touch.TapToSelect
 *
 * @productversion Feathers 2.3.0
 */
class LongPress 
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject = null) 
	{
		this.target = target;
	}
	
	/**
	 * The target component that should dispatch
	 * <code>FeathersEventType.LONG_PRESS</code> when tapped.
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
			this._target.removeEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
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
	 * The duration, in seconds, of a long press.
	 *
	 * <p>The following example changes the long press duration to one full second:</p>
	 *
	 * <listing version="3.0">
	 * longPress.longPressDuration = 1.0;</listing>
	 *
	 * @default 0.5
	 */
	public var longPressDuration(get, set):Float;
	private var _longPressDuration:Float = 0.5;
	private function get_longPressDuration():Float { return this._longPressDuration; }
	private function set_longPressDuration(value:Float):Float
	{
		return this._longPressDuration = value;
	}
	
	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;
	
	/**
	 * @private
	 */
	private var _touchLastGlobalPosition:Point = new Point();
	
	/**
	 * @private
	 */
	private var _touchBeginTime:Int;
	
	/**
	 * May be set to <code>false</code> to disable the triggered event
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
	 * If the target can be triggered by tapping, the
	 * <code>TapToTrigger</code> instance should be passed in so that it can
	 * be temporarily disabled when a long press is detected.
	 */
	public var tapToTrigger(get, set):TapToTrigger;
	private var _tapToTrigger:TapToTrigger;
	private function get_tapToTrigger():TapToTrigger { return this._tapToTrigger; }
	private function set_tapToTrigger(value:TapToTrigger):TapToTrigger
	{
		return this._tapToTrigger;
	}
	
	/**
	 * If the target can be selected by tapping, the
	 * <code>TapToSelect</code> instance should be passed in so that it can
	 * be temporarily disabled when a long press is detected.
	 */
	public var tapToSelect(get, set):TapToSelect;
	private var _tapToSelect:TapToSelect;
	private function get_tapToSelect():TapToSelect { return this._tapToSelect; }
	private function set_tapToSelect(value:TapToSelect):TapToSelect
	{
		return this._tapToSelect = value;
	}
	
	/**
	 * In addition to a normal call to <code>hitTest()</code>, a custom
	 * function may impose additional rules that determine if the target
	 * should be long pressed. Called on <code>TouchPhase.BEGAN</code>.
	 *
	 * <p>The function must have the following signature:</p>
	 *
	 * <pre>function(localPosition:Point):Boolean;</pre>
	 *
	 * <p>The function should return <code>true</code> if the target should
	 * be long pressed, and <code>false</code> if it should not be
	 * long pressed.</p>
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
		if (this._touchPointID >= 0)
		{
			//a touch has begun, so we'll ignore all other touches.
			touch = event.getTouch(this._target, null, this._touchPointID);
			if (touch == null)
			{
				//this should not happen.
				return;
			}
			
			if (touch.phase == TouchPhase.MOVED)
			{
				this._touchLastGlobalPosition.x = touch.globalX;
				this._touchLastGlobalPosition.y = touch.globalY;
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				this._target.removeEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
				
				//re-enable the other events
				if (this._tapToTrigger != null)
				{
					this._tapToTrigger.isEnabled = true;
				}
				if (this._tapToSelect != null)
				{
					this._tapToSelect.isEnabled = true;
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
			touch = event.getTouch(cast this._target, TouchPhase.BEGAN);
			if (touch == null)
			{
				//we only care about the began phase. ignore all other
				//phases when we don't have a saved touch ID.
				return;
			}
			if (this._customHitTest != null)
			{
				var point:Point = Pool.getPoint();
				touch.getLocation(cast this._target, point);
				var isInBounds:Bool = this._customHitTest(point);
				Pool.putPoint(point);
				if (!isInBounds)
				{
					return;
				}
			}
			
			//save the touch ID so that we can track this touch's phases.
			this._touchPointID = touch.id;
			
			//save the position so that we can do a final hit test
			this._touchLastGlobalPosition.x = touch.globalX;
			this._touchLastGlobalPosition.y = touch.globalY;
			
			this._touchBeginTime = getTimer();
			this._target.addEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function target_enterFrameHandler(event:Event):Void
	{
		var accumulatedTime:Float = (Timer.stamp() - this._touchBeginTime);// / 1000;
		if (accumulatedTime >= this._longPressDuration)
		{
			this._target.removeEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
			
			var isInBounds:Bool;
			var stage:Stage = this._target.stage;
			if (Std.isOfType(this._target, DisplayObjectContainer))
			{
				isInBounds = cast(this._target, DisplayObjectContainer).contains(stage.hitTest(this._touchLastGlobalPosition));
			}
			else
			{
				isInBounds = this._target == stage.hitTest(this._touchLastGlobalPosition);
			}
			if (isInBounds)
			{
				//disable the other events
				if (this._tapToTrigger != null)
				{
					this._tapToTrigger.isEnabled = false;
				}
				if (this._tapToSelect != null)
				{
					this._tapToSelect.isEnabled = false;
				}
				
				this._target.dispatchEventWith(FeathersEventType.LONG_PRESS);
			}
		}
	}
	
}