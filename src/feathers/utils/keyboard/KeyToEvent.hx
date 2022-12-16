/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.keyboard;
import feathers.core.DefaultFocusManager;
import feathers.core.IFocusDisplayObject;
import feathers.events.FeathersEventType;
import feathers.system.DeviceCapabilities;
import openfl.ui.Keyboard;
import starling.display.Stage;
import starling.events.Event;
import starling.events.KeyboardEvent;

/**
 * Dispatches an event from the target when a key is pressed and released
 * and the target has focus. Conveniently handles all
 * <code>KeyboardEvent</code> listeners automatically.
 *
 * <p>In the following example, a custom item renderer will be triggered
 * when a key is pressed and released:</p>
 *
 * <listing version="3.0">
 * public class CustomComponent extends FeathersControl implements IFocusDisplayObject
 * {
 *     public function CustomComponent()
 *     {
 *         super();
 *         this._keyToEvent = new KeyToEvent(this, Event.TRIGGERED);
 *         this._keyToEvent.keyCode = Keyboard.SPACE;
 *     }
 * 
 *     private var _keyToEvent:KeyToEvent;
 * // ...</listing>
 *
 * @see feathers.utils.keyboard.KeyToTrigger
 * @see feathers.utils.keyboard.KeyToSelect
 *
 * @productversion Feathers 3.4.0
 */
class KeyToEvent 
{
	/**
	 * Constructor.
	 */
	public function new(target:IFocusDisplayObject = null, keyCode:Int = Keyboard.SPACE, eventType:String = null) 
	{
		this.target = target;
		this.keyCode = keyCode;
		this.eventType = eventType;
	}
	
	/**
	 * @private
	 */
	private var _stage:Stage;
	
	/**
	 * The target component that should be selected when a key is pressed.
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
		if (this._stage != null)
		{
			//if the target changes while the old target has focus, remove
			//the listeners to avoid possible errors
			this._stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			this._stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this._stage = null;
		}
		if(this._target !== null)
		{
			this._target.removeEventListener(FeathersEventType.FOCUS_IN, target_focusInHandler);
			this._target.removeEventListener(FeathersEventType.FOCUS_OUT, target_focusOutHandler);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		}
		this._target = value;
		if(this._target !== null)
		{
			this._target.addEventListener(FeathersEventType.FOCUS_IN, target_focusInHandler);
			this._target.addEventListener(FeathersEventType.FOCUS_OUT, target_focusOutHandler);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		}
		return this._target;
	}
	
	/**
	 * The key that will dispatch the event, when pressed.
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
	 * The key that will cancel the event if the key is down.
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
	 * The location of the key that will dispatch the event, when pressed.
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
	 * The event type that will be dispatched when pressed.
	 */
	public var eventType(get, set):String;
	private var _eventType:String = null;
	private function get_eventType():String { return this._eventType; }
	private function set_eventType(value:String):String
	{
		return this._eventType = value;
	}
	
	/**
	 * May be set to <code>false</code> to disable event dispatching
	 * temporarily until set back to <code>true</code>.
	 */
	public var isEnabled(get, set):Bool;
	private var _isEnabled:Bool = true;
	private function get_isEnabled():Bool { return this._isEnabled; }
	private function set_isEnabled(value:Bool):Bool
	{
		return this._isEnabled = value;
	}
	
	/**
	 * @private
	 */
	private function target_focusInHandler(event:Event):Void
	{
		var focusManager:DefaultFocusManager = cast this._target.focusManager;
		this._stage = this._target.stage;
		this._stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	private function target_focusOutHandler(event:Event):Void
	{
		if (this._stage != null)
		{
			this._stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			this._stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this._stage = null;
		}
	}
	
	/**
	 * @private
	 */
	private function target_removedFromStageHandler(event:Event):Void
	{
		if (this._stage != null)
		{
			this._stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			this._stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this._stage = null;
		}
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
	}
	
	/**
	 * @private
	 */
	private function stage_keyUpHandler(event:KeyboardEvent):Void
	{
		if (!this._isEnabled)
		{
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
		var stage:Stage = cast event.currentTarget;
		stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		if(this._stage != stage)
		{
			return;
		}
		this._target.dispatchEventWith(this._eventType);
	}
	
}