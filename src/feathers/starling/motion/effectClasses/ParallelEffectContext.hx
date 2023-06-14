/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion.effectClasses;

import haxe.Constraints.Function;
import starling.display.DisplayObject;

/**
 * An effect context for running multiple effects in parallel.
 *
 * @productversion Feathers 3.5.0
 *
 * @see feathers.motion.Parallel
 */
class ParallelEffectContext extends BaseEffectContext implements IEffectContext
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject, functions:Array<Function>) 
	{
		var duration:Float = 0;
		var count:Int = functions.length;
		var func:Function;
		var context:IEffectContext;
		for (i in 0...count)
		{
			func = functions[i];
			context = cast func(target);
			this._contexts[i] = context;
			var contextDuration:Float = context.duration;
			if (contextDuration > duration)
			{
				duration = contextDuration;
			}
		}
		super(target, duration);
	}
	
	/**
	 * @private
	 */
	private var _contexts:Array<IEffectContext> = new Array<IEffectContext>();

	/**
	 * @private
	 */
	override function updateEffect():Void
	{
		var ratio:Float = this._position * this._duration;
		var contextCount:Int = this._contexts.length;
		var context:IEffectContext;
		for (i in 0...contextCount)
		{
			context = this._contexts[i];
			context.position = ratio / context.duration;
		}
	}
	
}