/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.motion.effectClasses;

import starling.display.DisplayObject;

/**
 * An effect context for running multiple effects one after another, in
 * sequence.
 *
 * @productversion Feathers 3.5.0
 *
 * @see feathers.motion.Sequence
 */
class SequenceEffectContext extends BaseEffectContext implements IEffectContext
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject, functions:Array<DisplayObject->IEffectContext>) 
	{
		var duration:Float = 0;
		var count:Int = functions.length;
		var func:DisplayObject->IEffectContext;
		var context:IEffectContext;
		for (i in 0...count)
		{
			func = functions[i] as Function;
			context = func(target);
			this._contexts[i] = context;
			duration += context.duration;
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
		var totalTime:Float = 0;
		var currentTime:Float = this._position * this._duration;
		var contextCount:Int = this._contexts.length;
		var context:IEffectContext;
		var contextDuration:Float;
		for (i in 0...contextCount)
		{
			context = this._contexts[i] as IEffectContext;
			contextDuration = context.duration;
			if (totalTime > currentTime)
			{
				context.position = 0;
			}
			else
			{
				context.position = (currentTime - totalTime) / contextDuration;
			}
			totalTime += contextDuration;
		}
	}
	
}