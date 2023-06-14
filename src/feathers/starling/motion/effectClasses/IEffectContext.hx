/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion.effectClasses;
import feathers.starling.core.IFeathersEventDispatcher;
import starling.display.DisplayObject;

/**
 * Gives a component the ability to control an effect.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 *
 * @productversion Feathers 3.5.0
 */
interface IEffectContext extends IFeathersEventDispatcher
{
	/**
	   The target of the effect
	**/
	public var target(get, never):DisplayObject;
	
	/**
	 * The duration of the effect, in seconds.
	 */
	public var duration(get, never):Float;
	
	/**
	 * The position of the effect, from <code>0</code> to <code>1</code>.
	 *
	 * @see #duration
	 */
	public var position(get, set):Float;
	
	/**
	 * Starts playing the effect from its current position to the end.
	 *
	 * @see #pause()
	 */
	function play():Void;
	
	/**
	 * Starts playing the effect from its current position back to the
	 * beginning (completing at a position of <code>0</code>).
	 */
	function playReverse():Void;
	
	/**
	 * Pauses an effect that is currently playing.
	 */
	function pause():Void;
	
	/**
	 * Stops the effect at its current position and forces
	 * <code>Event.COMPLETE</code> to dispatch. The <code>data</code>
	 * property of the event will be <code>true</code>.
	 *
	 * @see #toEnd()
	 * @see #event:complete starling.events.Event.COMPLETE
	 */
	function stop():Void;
	
	/**
	 * Advances the effect to the end and forces
	 * <code>Event.COMPLETE</code> to dispatch. The <code>data</code>
	 * property of the event will be <code>false</code>.
	 *
	 * @see #stop()
	 * @see #event:complete starling.events.Event.COMPLETE
	 */
	function toEnd():Void;
	
	/**
	 * Interrupts the playing effect, but the effect context will be allowed
	 * to determine on its own if it should call <code>stop()</code> or
	 * <code>toEnd()</code>.
	 *
	 * @see #toEnd()
	 * @see #stop()
	 */
	function interrupt():Void;
	
}