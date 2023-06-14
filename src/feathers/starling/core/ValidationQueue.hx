/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;
import feathers.starling.utils.ReverseIterator;
import starling.animation.IAnimatable;
import starling.core.Starling;

/**
 * @private
 *
 * @productversion Feathers 1.0.0
 */
class ValidationQueue implements IAnimatable
{
	/**
	   @private
	**/
	private static var STARLING_TO_VALIDATION_QUEUE:Map<Starling, ValidationQueue> = new Map<Starling, ValidationQueue>();
	
	/**
	 * Gets the validation queue for the specified Starling instance. If
	 * a validation queue does not exist for the specified Starling
	 * instance, a new one will be created.
	 */
	public static function forStarling(starling:Starling):ValidationQueue
	{
		if (starling == null)
		{
			return null;
		}
		var queue:ValidationQueue = STARLING_TO_VALIDATION_QUEUE[starling];
		if (queue == null)
		{
			STARLING_TO_VALIDATION_QUEUE[starling] = queue = new ValidationQueue(starling);
		}
		return queue;
	}
	
	/**
	   Constructor.
	**/
	public function new(starling:Starling) 
	{
		this._starling = starling;
	}
	
	private var _starling:Starling;
	
	public var isValidating(get, never):Bool;
	private var _isValidating:Bool = false;
	private function get_isValidating():Bool { return this._isValidating; }
	
	private var _queue:Array<IValidating> = new Array<IValidating>();
	
	/**
	 * Disposes the validation queue.
	 */
	public function dispose():Void
	{
		if (this._starling != null)
		{
			this._starling.juggler.remove(this);
			this._starling = null;
		}
	}
	
	/**
	 * Adds a validating component to the queue.
	 */
	public function addControl(control:IValidating):Void
	{
		//if the juggler was purged, we need to add the queue back in.
		if (!this._starling.juggler.contains(this))
		{
			this._starling.juggler.add(this);
		}
		if (this._queue.indexOf(control) != -1)
		{
			//already queued
			return;
		}
		var queueLength:Int = this._queue.length;
		if (this._isValidating)
		{
			//special case: we need to keep it sorted
			var depth:Int = control.depth;
			
			//we're traversing the queue backwards because it's
			//significantly more likely that we're going to push than that
			//we're going to splice, so there's no point to iterating over
			//the whole queue
			var idx:Int = 0;
			for (i in new ReverseIterator(queueLength -1, 0))
			{
				idx = i;
				var otherControl:IValidating = this._queue[i];
				var otherDepth:Int = otherControl.depth;
				//we can skip the overhead of calling queueSortFunction and
				//of looking up the value we've already stored in the depth
				//local variable.
				if (depth >= otherDepth)
				{
					break;
				}
			}
			//add one because we're going after the last item we checked
			//if we made it through all of them, i will be -1, and we want 0
			idx++;
			this._queue.insert(idx, control);
		}
		else
		{
			//faster than push() because push() creates a temporary rest
			//Array that needs to be garbage collected
			this._queue[queueLength] = control;
		}
	}
	
	/**
	   @private
	**/
	public function advanceTime(time:Float):Void
	{
		if (this._isValidating || !this._starling.contextValid)
		{
			return;
		}
		var queueLength:Int = this._queue.length;
		if (queueLength == 0)
		{
			return;
		}
		this._isValidating = true;
		if (queueLength > 1)
		{
			//only sort if there's more than one item in the queue because
			//it will avoid allocating objects
			//this._queue = this._queue.sort(queueSortFunction);
			this._queue.sort(queueSortFunction);
		}
		//rechecking length every time because addControl() might have added
		//a new item during the last validation.
		//we could use an int and check the length again at the end of the
		//loop, but there is little difference in performance, even with
		//millions of items in queue.
		while (this._queue.length != 0)
		{
			var item:IValidating = this._queue.shift();
			if (item.depth < 0)
			{
				//skip items that are no longer on the display list
				continue;
			}
			item.validate();
		}
		this._isValidating = false;
	}
	
	/**
	   @private
	**/
	private static inline function queueSortFunction(first:IValidating, second:IValidating):Int
	{
		var difference:Int = second.depth - first.depth;
		if (difference > 0)
		{
			return -1;
		}
		else if (difference < 0)
		{
			return 1;
		}
		return 0;
	}
	
}