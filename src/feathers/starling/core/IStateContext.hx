/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;

/**
 * An object with multiple states.
 *
 * @productversion Feathers 2.3.0
 */
interface IStateContext extends IFeathersEventDispatcher
{
	/**
	 * The object's current state.
	 *
	 * @see #event:stateChange feathers.events.FeathersEventType.STATE_CHANGE
	 */
	public var currentState(get, never):String;
}