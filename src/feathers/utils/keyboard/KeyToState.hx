/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.keyboard;
import feathers.controls.ButtonState;
import feathers.core.IFocusDisplayObject;
import feathers.core.IStateContext;
import feathers.events.FeathersEventType;
import feathers.system.DeviceCapabilities;
import feathers.utils.math.MathUtils;
import openfl.errors.ArgumentError;
import openfl.ui.Keyboard;
import starling.display.Stage;
import starling.events.Event;
import starling.events.KeyboardEvent;

/**
 * Changes a target's state when a key is pressed or released on the
 * keyboard. Conveniently handles all <code>KeyboardEvent</code> listeners
 * automatically.
 *
 * @see feathers.utils.touch.TouchToState
 *
 * @productversion Feathers 3.2.0
 */
class KeyToState 
{
	/**
	 * Constructor.
	 */
	public function new(target:IFocusDisplayObject = null, callback:String->Void) 
	{
		this.target = target;
		this.callback = callback;
	}
	
	/**
	 * @private
	 */
	private var _stage:Stage;
	
	/**
	 * @private
	 */
	private var _hasFocus:Bool = false;
	
	/**
	 * The target component that should change state when a key is pressed
	 * or released.
	 */
	public var target(get, set):IFocusDisplayObject;
	private var _target:IFocusDisplayObject;
	private function get_target():IFocusDisplayObject { return this._target; }
	private function set_target(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (this._target == value)
		{
			return value;
		}
		if (value != null && !Std.isOfType(value, IFocusDisplayObject))
		{
			throw new ArgumentError("Target of KeyToState must implement IFocusDisplayObject");
		}
		if (this._stage != null)
		{
			//if the target changes while the old target has focus, remove
			//the listeners to avoid possible errors
			this._stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			this._stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this._stage = null;
		}
		if (this._target != null)
		{
			this._target.removeEventListener(FeathersEventType.FOCUS_IN, target_focusInHandler);
			this._target.removeEventListener(FeathersEventType.FOCUS_OUT, target_focusOutHandler);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		}
		this._target = value;
		if (this._target != null)
		{
			this._currentState = this._upState;
			this._target.addEventListener(FeathersEventType.FOCUS_IN, target_focusInHandler);
			this._target.addEventListener(FeathersEventType.FOCUS_OUT, target_focusOutHandler);
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
	 * The key that will change the state of the target, when pressed.
	 *
	 * @default flash.ui.Keyboard.SPACE
	 */
	public var keyCode(get, set):Int;
	private var _keyCode:Int = Keyboard.SPACE;
	private function get_keyCode():Int { return this._keyCode; }
	private function set_keyCode(value:Int):Int
	{
		return this._keyCode = value;
	}
	
	/**
	 * The key that will cancel the state change if the key is down.
	 *
	 * @default flash.ui.Keyboard.ESCAPE
	 */
	public var cancelKeyCode(get, set):Int;
	private var _cancelKeyCode:Int = Keyboard.ESCAPE;
	private function get_cancelKeyCode():Int { return this._cancelKeyCode; }
	private function set_cancelKeyCode(value:Int):Int
	{
		return this._cancelKeyCode = value;
	}
	
	/**
	 * The location of the key that will change the state, when pressed.
	 * If <code>feathers.utils.MathUtils.INT_MAX</code>, then any key location is allowed.
	 *
	 * @default feathers.utils.MathUtils.INT_MAX
	 *
	 * @see flash.ui.KeyLocation
	 */
	public var keyLocation(get, set):Int;
	private var _keyLocation:Int = MathUtils.INT_MAX;
	private function get_keyLocation():Int { return this._keyLocation; }
	private function set_keyLocation(value:Int):Int
	{
		return this._keyLocation = value;
	}
	
	/**
	 * May be set to <code>false</code> to disable state changes temporarily
	 * until set back to <code>true</code>.
	 */
	public var isEnabled(get, set):Bool;
	private var _isEnabled:Bool = true;
	private function get_isEnabled():Bool { return this._isEnabled; }
	private function set_isEnabled(value:Bool):Bool
	{
		return this._isEnabled = value;
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
	private function focusOut():Void
	{
		this._hasFocus = false;
		if (this._stage != null)
		{
			this._stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			this._stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this._stage = null;
		}
		this.changeState(this._upState);
	}
	
	/**
	 * @private
	 */
	private function target_focusInHandler(event:Event):Void
	{
		this._hasFocus = true;
		this._stage = this._target.stage;
		this._stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		
		//don't change the state on focus in because the state may be
		//managed by another utility
	}
	
	/**
	 * @private
	 */
	private function target_focusOutHandler(event:Event):Void
	{
		this.focusOut();
	}
	
	/**
	 * @private
	 */
	private function target_removedFromStageHandler(event:Event):Void
	{
		this.focusOut();
	}
	
	/**
	 * @private
	 */
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (!this._isEnabled)
		{
			return;
		}
		if (event.currentTarget != this._stage)
		{
			//Github issue #1762: the stage may have been set to null in a
			//previous KeyboardEvent.KEY_DOWN listener
			return;
		}
		if (event.keyCode == this._cancelKeyCode)
		{
			this._stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this.changeState(this._upState);
			return;
		}
		if (event.keyCode != this._keyCode)
		{
			return;
		}
		if (this._keyLocation != MathUtils.INT_MAX &&
			!((event.keyLocation == this._keyLocation) || (this._keyLocation == 4 && DeviceCapabilities.simulateDPad)))
		{
			return;
		}
		this._stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		this.changeState(this._downState);
	}
	
	/**
	 * @private
	 */
	private function stage_keyUpHandler(event:KeyboardEvent):Void
	{
		if(!this._isEnabled)
		{
			return;
		}
		if(event.keyCode != this._keyCode)
		{
			return;
		}
		if(this._keyLocation != MathUtils.INT_MAX &&
			!((event.keyLocation == this._keyLocation) || (this._keyLocation == 4 && DeviceCapabilities.simulateDPad)))
		{
			return;
		}
		var stage:Stage = cast event.currentTarget;
		stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		if(this._stage != stage)
		{
			return;
		}
		this.changeState(this._upState);
	}
	
}