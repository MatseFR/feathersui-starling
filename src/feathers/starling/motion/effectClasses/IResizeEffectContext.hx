/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion.effectClasses;

/**
 * Gives a component the ability to control a resize effect.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 */
interface IResizeEffectContext extends IEffectContext
{
	/**
	 * The old width of the target.
	 */
	public var oldWidth(get, set):Float;
	
	/**
	 * The old height of the target.
	 */
	public var oldHeight(get, set):Float;
	
	/**
	 * The new width of the target.
	 */
	public var newWidth(get, set):Float;
	
	/**
	 * The new height of the target.
	 */
	public var newHeight(get, set):Float;
}