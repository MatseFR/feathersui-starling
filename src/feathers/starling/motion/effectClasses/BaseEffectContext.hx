/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion.effectClasses;

import feathers.starling.motion.effectClasses.IEffectContext;
import starling.animation.Juggler;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * An abstract base class for <code>IEffectContext</code> implementations.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 */
abstract class BaseEffectContext extends EventDispatcher implements IEffectContext
{
	/**
	 * @private
	 */
	private static inline var MAX_POSITION:Float = 0.99999;
	
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject, duration:Float, transition:Dynamic = null) 
	{
		super();
		
		this._target = target;
		this._duration = duration;
		if (transition == null)
		{
			transition = Transitions.LINEAR;
		}
		this._transition = transition;
		this.prepareEffect();
	}
	
	/**
	 * The target of the effect.
	 */
	public var target(get, never):DisplayObject;
	private var _target:DisplayObject;
	private function get_target():DisplayObject { return this._target; }
	
	/**
	 * @private
	 */
	private var _playTween:Tween = null;
	
	/**
	 * The duration of the effect, in seconds.
	 */
	public var duration(get, never):Float;
	private var _duration:Float;
	private function get_duration():Float { return this._duration; }
	
	/**
	 * The transition, or easing function, used for the effect.
	 *
	 * @see http://doc.starling-framework.org/core/starling/animation/Transitions.html starling.animation.Transitions
	 */
	public var transition(get, never):Dynamic;
	private var _transition:Dynamic;
	private function get_transition():Dynamic { return this._transition; }
	
	/**
	 * @private
	 */
	private var _position:Float = 0;

	/**
	 * @private
	 */
	private var _playing:Bool = false;

	/**
	 * @private
	 */
	private var _reversed:Bool = false;
	
	/**
	 * The <code>Juggler</code> used to update the effect when it is
	 * playing. If <code>null</code>, uses <code>Starling.juggler</code>.
	 *
	 * @see http://doc.starling-framework.org/core/starling/animation/Juggler.html starling.animation.Juggler
	 */
	public var juggler(get, set):Juggler;
	private var _juggler:Juggler;
	private function get_juggler():Juggler { return this._juggler; }
	private function set_juggler(value:Juggler):Juggler
	{
		if (this._juggler == value)
		{
			return value;
		}
		var oldJuggler:Juggler = this._juggler;
		if (oldJuggler == null)
		{
			oldJuggler = Starling.currentJuggler;
		}
		this._juggler = value;
		if (this._playing && this._juggler != oldJuggler)
		{
			oldJuggler.remove(this._playTween);
			if (this._juggler != null)
			{
				this._juggler.add(this._playTween);
			}
			else
			{
				this._playing = false;
			}
		}
		return this._juggler;
	}
	
	/**
	 * Sets the position of the effect using a value between <code>0</code>
	 * and <code>1</code>.
	 *
	 * @see #duration
	 */
	public var position(get, set):Float;
	private function get_position():Float { return this._position; }
	private function set_position(value:Float):Float
	{
		if (value > MAX_POSITION)
		{
			value = MAX_POSITION;
		}
		this._position = value;
		this.updateEffect();
		return this._position;
	}
	
	/**
	 * @inheritDoc
	 */
	public function play():Void
	{
		if (this._playing && !this._reversed)
		{
			//already playing in the correct direction
			return;
		}
		if (this._playTween != null)
		{
			this._playTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
			this._playTween = null;
		}
		this._playing = true;
		this._reversed = false;
		
		var duration:Float = this._duration * (1 - this._position);
		this._playTween = new Tween(this, duration, this._transition);
		this._playTween.animate("position", 1);
		this._playTween.onComplete = this.playTween_onComplete;
		
		var juggler:Juggler = this._juggler;
		if (juggler == null)
		{
			juggler = Starling.currentJuggler;
		}
		juggler.add(this._playTween);
	}
	
	/**
	 * @inheritDoc
	 */
	public function playReverse():Void
	{
		if (this._playing && this._reversed)
		{
			//already playing in the correct direction
			return;
		}
		if (this._playTween != null)
		{
			this._playTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
			this._playTween = null;
		}
		this._playing = true;
		this._reversed = true;
		
		var duration:Float = this._duration * this._position;
		this._playTween = new Tween(this, duration, this._transition);
		this._playTween.animate("position", 0);
		this._playTween.onComplete = this.playTween_onComplete;
		
		var juggler:Juggler = this._juggler;
		if (juggler == null)
		{
			juggler = Starling.currentJuggler;
		}
		juggler.add(this._playTween);
	}
	
	/**
	 * @inheritDoc
	 */
	public function pause():Void
	{
		if (!this._playing)
		{
			return;
		}
		if (this._playTween != null)
		{
			this._playTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
			this._playTween = null;
		}
		this._playing = false;
	}
	
	/**
	 * @inheritDoc
	 */
	public function stop():Void
	{
		this.pause();
		this.cleanupEffect();
		this.dispatchEventWith(Event.COMPLETE, false, true);
	}
	
	/**
	 * @inheritDoc
	 */
	public function toEnd():Void
	{
		if (this._playing)
		{
			this._position = 1;
			this._playTween.advanceTime(this._playTween.totalTime);
			return;
		}
		this.position = 1;
		this.cleanupEffect();
		this.dispatchEventWith(Event.COMPLETE, false, false);
	}
	
	/**
	 * @inheritDoc
	 */
	public function interrupt():Void
	{
		//by default, go to the end. subclasses may override this method
		//to customize the behavior, if needed.
		this.toEnd();
	}
	
	/**
	 * Called when the effect is initialized. Subclasses may
	 * override this method to customize the effect's behavior.
	 */
	private function prepareEffect():Void
	{
		
	}
	
	/**
	 * Called when the effect's position is updated. Subclasses may
	 * override this method to customize the effect's behavior.
	 */
	private function updateEffect():Void
	{
		
	}

	/**
	 * Called when the effect completes or is interrupted. Subclasses may
	 * override this method to customize the effect's behavior.
	 */
	private function cleanupEffect():Void
	{
		
	}

	/**
	 * @private
	 */
	private function playTween_onComplete():Void
	{
		this._playTween = null;
		this.cleanupEffect();
		this.dispatchEventWith(Event.COMPLETE, false, false);
	}
	
}