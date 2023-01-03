/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.touch;
import feathers.controls.ButtonState;
import feathers.core.IStateContext;
import haxe.Constraints.Function;
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
 * Changes a target's state based on the <code>TouchPhase</code> when the
 * target is touched. Conveniently handles all <code>TouchEvent</code> listeners
 * automatically. Useful for custom item renderers that should be change
 * state based on touch.
 *
 * @see feathers.utils.keyboard.KeyToState
 *
 * @productversion Feathers 3.2.0
 */
class TouchToState 
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject = null, callback:String->Void = null) 
	{
		this.target = target;
		this.callback = callback;
	}
	
	/**
	 * The target component that should change state based on touch phases.
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
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		}
		this._target = value;
		if (this._target != null)
		{
			//if we're changing targets, and a touch is active, we want to
			//clear it.
			this._touchPointID = -1;
			//then restore to the default state
			this._currentState = this._upState;
			this._target.addEventListener(TouchEvent.TOUCH, target_touchHandler);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		}
		return this._target;
	}
	
	/**
	 * The function to call when the state is changed.
	 *
	 * <p>The callback is expected to have the following signature:</p>
	 * <pre>function(currentState:String):void</pre>
	 */
	public var callback(get, set):String->Void;
	private var _callback:String->Void;
	private function get_callback():String->Void { return this._callback; }
	private function set_callback(value:String->Void):String->Void
	{
		if (this._callback == value)
		{
			return value;
		}
		this._callback = value;
		if (this._callback != null)
		{
			this._callback(this._currentState);
		}
		return this._callback;
	}
	
	/**
	 * The current state of the utility. May be different than the state
	 * of the target.
	 */
	public var currentState(get, never):String;
	private var _currentState:String = ButtonState.UP;
	private function get_currentState():String { return this._currentState; }
	
	/**
	 * The value for the "up" state.
	 *
	 * @default feathers.controls.ButtonState.UP
	 */
	public var upState(get, set):String;
	private var _upState:String = ButtonState.UP;
	private function get_upState():String { return this._upState; }
	private function set_upState(value:String):String
	{
		return this._upState = value;
	}
	
	/**
	 * The value for the "down" state.
	 *
	 * @default feathers.controls.ButtonState.DOWN
	 */
	public var downState(get, set):String;
	private var _downState:String = ButtonState.DOWN;
	private function get_downState():String { return this._downState; }
	private function set_downState(value:String):String
	{
		return this._downState = value;
	}
	
	/**
	 * The value for the "hover" state.
	 *
	 * @default feathers.controls.ButtonState.HOVER
	 */
	public var hoverState(get, set):String;
	private var _hoverState:String = ButtonState.HOVER;
	private function get_hoverState():String { return this._hoverState; }
	private function set_hoverState(value:String):String
	{
		return this._hoverState = value;
	}
	
	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;
	
	/**
	 * May be set to <code>false</code> to disable the state changes
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
	 * In addition to a normal call to <code>hitTest()</code>, a custom
	 * function may impose additional rules that determine if the target
	 * should change state. Called on <code>TouchPhase.BEGAN</code>.
	 *
	 * <p>The function must have the following signature:</p>
	 *
	 * <pre>function(localPosition:Point):Boolean;</pre>
	 *
	 * <p>The function should return <code>true</code> if the target should
	 * be triggered, and <code>false</code> if it should not be
	 * triggered.</p>
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
	private var _hoverBeforeBegan:Bool = false;
	
	/**
	 * If <code>true</code>, the button state will remain as
	 * <code>downState</code> until <code>TouchPhase.ENDED</code>. If
	 * <code>false</code>, and the touch leaves the bounds of the button
	 * after <code>TouchPhase.BEGAN</code>, the button state will change to
	 * <code>upState</code>.
	 *
	 * @default false
	 */
	public var keepDownStateOnRollOut(get, set):Bool;
	private var _keepDownStateOnRollOut:Bool = false;
	private function get_keepDownStateOnRollOut():Bool { return this._keepDownStateOnRollOut; }
	private function set_keepDownStateOnRollOut(value:Bool):Bool
	{
		return this._keepDownStateOnRollOut = value;
	}
	
	/**
	 * @private
	 */
	private function handleCustomHitTest(touch:Touch):Bool
	{
		if (this._customHitTest == null)
		{
			return true;
		}
		var point:Point = Pool.getPoint();
		touch.getLocation(this._target, point);
		var isInBounds:Bool = this._customHitTest(point);
		Pool.putPoint(point);
		return isInBounds;
	}
	
	/**
	 * @private
	 */
	private function changeState(value:String):Void
	{
		var oldState:String = this._currentState;
		if (Std.isOfType(this._target, IStateContext))
		{
			oldState = cast(this._target, IStateContext).currentState;
		}
		this._currentState = value;
		if (oldState == value)
		{
			return;
		}
		if (this._callback != null)
		{
			this._callback(value);
		}
	}
	
	/**
	 * @private
	 */
	private function resetTouchState():Void
	{
		this._hoverBeforeBegan = false;
		this._touchPointID = -1;
		this.changeState(this._upState);
	}

	/**
	 * @private
	 */
	private function target_removedFromStageHandler(event:Event):Void
	{
		this.resetTouchState();
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
				return;
			}
			
			var stage:Stage = this._target.stage;
			if (stage != null)
			{
				var point:Point = Pool.getPoint();
				touch.getLocation(stage, point);
				var isInBounds:Bool;
				if (Std.isOfType(this._target, DisplayObjectContainer))
				{
					isInBounds = cast(this._target, DisplayObjectContainer).contains(stage.hitTest(point));
				}
				else
				{
					isInBounds = this._target == stage.hitTest(point);
				}
				isInBounds = isInBounds && this.handleCustomHitTest(touch);
				Pool.putPoint(point);
				if (touch.phase == TouchPhase.MOVED)
				{
					if (this._keepDownStateOnRollOut)
					{
						//nothing to change!
						return;
					}
					if (isInBounds)
					{
						this.changeState(this._downState);
						return;
					}
					else
					{
						this.changeState(this._upState);
						return;
					}
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					if (isInBounds && this._hoverBeforeBegan)
					{
						//if the mouse is over the target on ended, return
						//to the hover state, but only if there was a hover
						//state before began.
						//this ensures that the hover state is not
						//unexpectedly entered on a touch screen.
						this._touchPointID = -1;
						this.changeState(this._hoverState);
					}
					else
					{
						this.resetTouchState();
					}
					return;
				}
			}
		}
		else
		{
			//we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(this._target, TouchPhase.BEGAN);
			if (touch != null && this.handleCustomHitTest(touch))
			{
				this.changeState(this._downState);
				this._touchPointID = touch.id;
				return;
			}
			touch = event.getTouch(this._target, TouchPhase.HOVER);
			if (touch != null && this.handleCustomHitTest(touch))
			{
				this._hoverBeforeBegan = true;
				this.changeState(this._hoverState);
				return;
			}
			
			//end of hover
			this.changeState(this._upState);
		}
	}
	
}