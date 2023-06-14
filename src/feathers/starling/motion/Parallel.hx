/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion;
import feathers.starling.motion.effectClasses.IEffectContext;
import feathers.starling.motion.effectClasses.ParallelEffectContext;
import haxe.Constraints.Function;
import starling.display.DisplayObject;

/**
 * Combines multiple effects that play at the same time, in parallel.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 *
 * @productversion Feathers 3.5.0
 */
class Parallel 
{
	/**
	 * Creates an effect function that combines multiple effect functions
	 * that will play at the same time, in parallel.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createParallelEffect(effects:Array<Function>):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			return new ParallelEffectContext(target, effects);
		};
	}
	
}