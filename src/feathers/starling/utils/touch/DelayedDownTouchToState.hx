/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.utils.touch;

import feathers.starling.controls.ButtonState;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import starling.display.DisplayObject;

/**
 * Similar to <code>TouchToState</code>, but delays the "down" state by a
 * specified number of seconds. Useful for delayed state changes in
 * scrolling containers.
 *
 * @productversion Feathers 3.2.0
 */
class DelayedDownTouchToState extends TouchToState 
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject = null, callback:String->Void = null) 
	{
		super(target, callback);
	}
	
	/**
	 * @private
	 */
	override function set_target(value:DisplayObject):DisplayObject 
	{
		super.set_target(value);
		if (this._target == null && this._stateDelayTimer != null)
		{
			if (this._stateDelayTimer.running)
			{
				this._stateDelayTimer.stop();
			}
			this._stateDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, stateDelayTimer_timerCompleteHandler);
			this._stateDelayTimer = null;
		}
		return value;
	}
	
	/**
	 * @private
	 */
	private var _delayedCurrentState:String;

	/**
	 * @private
	 */
	private var _stateDelayTimer:Timer;
	
	/**
	 * The time, in seconds, to delay the state.
	 *
	 * @default 0.25
	 */
	public var delay(get, set):Float;
	private var _delay:Float = 0.25;
	private function get_delay():Float { return this._delay; }
	private function set_delay(value:Float):Float
	{
		return this._delay = value;
	}
	
	/**
	 * @private
	 */
	override function changeState(value:String):Void
	{
		if (this._stateDelayTimer != null && this._stateDelayTimer.running)
		{
			this._delayedCurrentState = value;
			return;
		}
		
		if (value == ButtonState.DOWN)
		{
			if (this._currentState == value)
			{
				return;
			}
			this._delayedCurrentState = value;
			if (this._stateDelayTimer != null)
			{
				this._stateDelayTimer.reset();
			}
			else
			{
				this._stateDelayTimer = new Timer(this._delay * 1000, 1);
				this._stateDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stateDelayTimer_timerCompleteHandler);
			}
			this._stateDelayTimer.start();
			return;
		}
		super.changeState(value);
	}
	
	/**
	 * @private
	 */
	private function stateDelayTimer_timerCompleteHandler(event:TimerEvent):Void
	{
		super.changeState(this._delayedCurrentState);
		this._delayedCurrentState = null;
	}
	
}