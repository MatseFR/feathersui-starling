/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.motion.effectClasses;

/**
 * Gives a component the ability to control a move effect.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 */
interface IMoveEffectContext extends IEffectContext
{
	/**
	 * The old x position of the target.
	 */
	public var oldX(get, set):Float;
	
	/**
	 * The old y position of the target.
	 */
	public var oldY(get, set):Float;
	
	/**
	 * The new x position of the target.
	 */
	public var newX(get, set):Float;
	
	/**
	 * The new y position of the target.
	 */
	public var newY(get, set):Float;
}