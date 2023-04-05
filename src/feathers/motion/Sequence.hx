/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.motion;
import feathers.motion.effectClasses.IEffectContext;
import feathers.motion.effectClasses.SequenceEffectContext;
import haxe.Constraints.Function;
import starling.display.DisplayObject;

/**
 * Combines multiple effects that play one after another in sequence.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 *
 * @productversion Feathers 3.5.0
 */
class Sequence 
{
	/**
	 * Creates an effect function that combines multiple effect functions
	 * that will play one after another, in sequence.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createSequenceEffect(effects:Array<Function>):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			return new SequenceEffectContext(target, effects);
		};
	}
}