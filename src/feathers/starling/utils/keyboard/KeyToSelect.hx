/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.utils.keyboard;
import feathers.starling.core.IFocusDisplayObject;
import feathers.starling.core.IToggle;
import feathers.starling.events.FeathersEventType;
import feathers.starling.system.DeviceCapabilities;
import feathers.starling.utils.math.MathUtils;
import openfl.errors.ArgumentError;
import openfl.ui.Keyboard;
import starling.display.Stage;
import starling.events.Event;
import starling.events.KeyboardEvent;

/**
 * Changes the <code>isSelected</code> property of the target when a key is
 * pressed and released while the target has focus. The target will
 * dispatch <code>Event.CHANGE</code>. Conveniently handles all
 * <code>KeyboardEvent</code> listeners automatically.
 *
 * <p>In the following example, a custom component will be selected when a
 * key is pressed and released:</p>
 *
 * <listing version="3.0">
 * public class CustomComponent extends FeathersControl implements IFocusDisplayObject
 * {
 *     public function CustomComponent()
 *     {
 *         super();
 *         this._keyToSelect = new KeyToSelect(this);
 *         this._keyToSelect.keyCode = Keyboard.SPACE;
 *     }
 * 
 *     private var _keyToSelect:KeyToSelect;
 * // ...</listing>
 *
 * <p>Note: When combined with a <code>KeyToTrigger</code> instance, the
 * <code>KeyToSelect</code> instance should be created second because
 * <code>Event.TRIGGERED</code> should be dispatched before
 * <code>Event.CHANGE</code>.</p>
 *
 * @see feathers.utils.keyboard.KeyToTrigger
 * @see feathers.utils.touch.TapToSelect
 *
 * @productversion Feathers 3.0.0
 */
class KeyToSelect 
{
	/**
	 * Constructor.
	 */
	public function new(target:IToggle = null, keyCode:Int = Keyboard.SPACE) 
	{
		this.target = target;
		this.keyCode = keyCode;
	}
	
	/**
	 * @private
	 */
	private var _stage:Stage;
	
	/**
	 * The target component that should be selected when a key is pressed.
	 */
	public var target(get, set):IToggle;
	private var _target:IToggle;
	private function get_target():IToggle { return this._target; }
	private function set_target(value:IToggle):IToggle
	{
		if (this._target == value)
		{
			return value;
		}
		if (value != null && !Std.isOfType(value, IFocusDisplayObject))
		{
			throw new ArgumentError("Target of KeyToSelect must implement IFocusDisplayObject");
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
			this._target.addEventListener(FeathersEventType.FOCUS_IN, target_focusInHandler);
			this._target.addEventListener(FeathersEventType.FOCUS_OUT, target_focusOutHandler);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		}
		return this._target;
	}
	
	/**
	 * The key that will select the target, when pressed.
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
	 * The key that will cancel the selection if the key is down.
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
	 * May be set to <code>true</code> to allow the target to be deselected
	 * when the key is pressed.
	 *
	 * @default false
	 */
	public var keyToDeselect(get, set):Bool;
	private var _keyToDeselect:Bool = false;
	private function get_keyToDeselect():Bool { return this._keyToDeselect; }
	private function set_keyToDeselect(value:Bool):Bool
	{
		return this._keyToDeselect = value;
	}
	
	/**
	 * The location of the key that will select the target, when pressed.
	 * If <code>uint.MAX_VALUE</code>, then any key location is allowed.
	 *
	 * @default uint.MAX_VALUE
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
	 * May be set to <code>false</code> to disable selection temporarily
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
	 * @private
	 */
	private function target_focusInHandler(event:Event):Void
	{
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
		if (Std.int(event.keyCode) == this._cancelKeyCode)
		{
			this._stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			return;
		}
		if (Std.int(event.keyCode) != this._keyCode)
		{
			return;
		}
		if (this._keyLocation != MathUtils.INT_MAX &&
			!((Std.int(event.keyLocation) == this._keyLocation) || (this._keyLocation == 4 && DeviceCapabilities.simulateDPad)))
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
		if (Std.int(event.keyCode) != this._keyCode)
		{
			return;
		}
		if (this._keyLocation != MathUtils.INT_MAX &&
			!((Std.int(event.keyLocation) == this._keyLocation) || (this._keyLocation == 4 && DeviceCapabilities.simulateDPad)))
		{
			return;
		}
		var stage:Stage = cast event.currentTarget;
		stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		if (this._stage != stage)
		{
			return;
		}
		if (this._keyToDeselect)
		{
			this._target.isSelected = !this._target.isSelected;
		}
		else
		{
			this._target.isSelected = true;
		}
	}
	
}