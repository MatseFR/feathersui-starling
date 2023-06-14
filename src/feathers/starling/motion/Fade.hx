/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion;
import feathers.starling.core.IFeathersControl;
import feathers.starling.motion.effectClasses.IEffectContext;
import feathers.starling.motion.effectClasses.TweenEffectContext;
import feathers.starling.utils.type.Property;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

/**
 * Creates effects for Feathers components and transitions for screen
 * navigators, that animate the <code>alpha</code> property of a display
 * object to make it fade in or out.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 * @see ../../../help/transitions.html#fade Transitions for Feathers screen navigators: Fade
 *
 * @productversion Feathers 2.1.0
 */
class Fade 
{
	/**
	 * @private
	 */
	private static inline var SCREEN_REQUIRED_ERROR:String = "Cannot transition if both old screen and new screen are null.";

	/**
	 * Creates an effect function that fades in the target component by
	 * animating the <code>alpha</code> property from <code>0.0</code> to
	 * <code>1.0</code>.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see #createFadeOutEffect()
	 * @see #createFadeBetweenEffect()
	 */
	public static function createFadeInEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return createFadeBetweenEffect(0.0, 1.0, duration, ease, interruptBehavior);
	}
	
	/**
	 * Creates an effect function that fades out the target component by
	 * animating the <code>alpha</code> property from <code>1.0</code> to
	 * <code>0.0</code>.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see #createFadeInEffect()
	 * @see #createFadeBetweenEffect()
	 */
	public static function createFadeOutEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return createFadeBetweenEffect(1.0, 0.0, duration, ease, interruptBehavior);
	}
	
	/**
	 * Creates an effect function that fades the target component by
	 * animating the <code>alpha</code> property from its current value to a
	 * new value.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see #createFadeFromEffect()
	 * @see #createFadeBetweenEffect()
	 */
	public static function createFadeToEffect(endAlpha:Float, duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			tween.fadeTo(endAlpha);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function that fades the target component by
	 * animating the <code>alpha</code> property from a start value to its
	 * current value.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see #createFadeToEffect()
	 * @see #createFadeBetweenEffect()
	 */
	public static function createFadeFromEffect(startAlpha:Float, duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var endAlpha:Float = target.alpha;
			if (Std.isOfType(target, IFeathersControl))
			{
				cast(target, IFeathersControl).suspendEffects();
			}
			target.alpha = startAlpha;
			if (Std.isOfType(target, IFeathersControl))
			{
				cast(target, IFeathersControl).resumeEffects();
			}
			var tween:Tween = new Tween(target, duration, ease);
			tween.fadeTo(endAlpha);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function that fades the target component by
	 * animating the <code>alpha</code> property between a start value and
	 * an ending value.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createFadeBetweenEffect(startAlpha:Float, endAlpha:Float, duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			if (Std.isOfType(target, IFeathersControl))
			{
				cast(target, IFeathersControl).suspendEffects();
			}
			target.alpha = startAlpha;
			if (Std.isOfType(target, IFeathersControl))
			{
				cast(target, IFeathersControl).resumeEffects();
			}
			var tween:Tween = new Tween(target, duration, ease);
			tween.fadeTo(endAlpha);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that fades in
	 * the new screen by animating the <code>alpha</code> property from
	 * <code>0.0</code> to <code>1.0</code>, while the old screen remains
	 * fully opaque at a lower depth.
	 *
	 * @see ../../../help/transitions.html#fade Transitions for Feathers screen navigators: Fade
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createFadeInTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:FadeTween;
			if (newScreen != null)
			{
				newScreen.alpha = 0;
				//make sure the new screen is on top
				var parent:DisplayObjectContainer = newScreen.parent;
				parent.setChildIndex(newScreen, parent.numChildren - 1);
				if (oldScreen != null) //oldScreen can be null, that's okay
				{
					oldScreen.alpha = 1;
				}
				tween = new FadeTween(newScreen, null, duration, ease, onComplete, tweenProperties);
			}
			else
			{
				//there's no new screen to fade in, but we still want some
				//kind of animation, so we'll just fade out the old screen
				//in order to have some animation, we're going to fade out
				oldScreen.alpha = 1;
				tween = new FadeTween(oldScreen, null, duration, ease, onComplete, tweenProperties);
			}
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that fades out
	 * the old screen by animating the <code>alpha</code> property from
	 * <code>1.0</code> to <code>0.0</code>, while the new screen remains
	 * fully opaque at a lower depth.
	 *
	 * @see ../../../help/transitions.html#fade Transitions for Feathers screen navigators: Fade
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createFadeOutTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:FadeTween;
			if (oldScreen != null)
			{
				//make sure the old screen is on top
				var parent:DisplayObjectContainer = oldScreen.parent;
				parent.setChildIndex(oldScreen, parent.numChildren - 1);
				oldScreen.alpha = 1;
				if (newScreen != null) //newScreen can be null, that's okay
				{
					newScreen.alpha = 1;
				}
				tween = new FadeTween(oldScreen, null, duration, ease, onComplete, tweenProperties);
			}
			else
			{
				//there's no old screen to fade out, but we still want some
				//kind of animation, so we'll just fade in the new screen
				//in order to have some animation, we're going to fade out
				newScreen.alpha = 0;
				tween = new FadeTween(newScreen, null, duration, ease, onComplete, tweenProperties);
			}
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that crossfades
	 * the screens. In other words, the old screen fades out, animating the
	 * <code>alpha</code> property from <code>1.0</code> to
	 * <code>0.0</code>. Simultaneously, the new screen fades in, animating
	 * its <code>alpha</code> property from <code>0.0</code> to <code>1.0</code>.
	 *
	 * @see ../../../help/transitions.html#fade Transitions for Feathers screen navigators: Fade
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCrossfadeTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:FadeTween;
			if (newScreen != null)
			{
				newScreen.alpha = 0;
				if (oldScreen != null) //oldScreen can be null, that's okay
				{
					oldScreen.alpha = 1;
				}
				tween = new FadeTween(newScreen, oldScreen, duration, ease, onComplete, tweenProperties);
			}
			else //we only have the old screen
			{
				oldScreen.alpha = 1;
				tween = new FadeTween(oldScreen, null, duration, ease, onComplete, tweenProperties);
			}
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
}

class FadeTween extends Tween
{
	public function new(target:DisplayObject, otherTarget:DisplayObject,
		duration:Float, ease:Dynamic, onCompleteCallback:Function,
		tweenProperties:Dynamic)
	{
		super(target, duration, ease);
		if (target.alpha == 0)
		{
			this.fadeTo(1);
		}
		else
		{
			this.fadeTo(0);
		}
		if (tweenProperties != null)
		{
			for (propertyName in Reflect.fields(tweenProperties))
			{
				Property.write(this, propertyName, Reflect.field(tweenProperties, propertyName));
			}
		}
		if (otherTarget != null)
		{
			this._otherTarget = otherTarget;
			this.onUpdate = this.updateOtherTarget;
		}
		this._onCompleteCallback = onCompleteCallback;
		this.onComplete = this.cleanupTween;
	}
	
	private var _otherTarget:DisplayObject;
	private var _onCompleteCallback:Function;

	private function updateOtherTarget():Void
	{
		var newScreen:DisplayObject = cast this.target;
		this._otherTarget.alpha = 1 - newScreen.alpha;
	}

	private function cleanupTween():Void
	{
		var displayTarget:DisplayObject = cast this.target;
		displayTarget.alpha = 1;
		if (this._otherTarget != null)
		{
			this._otherTarget.alpha = 1;
		}
		if (this._onCompleteCallback != null)
		{
			#if neko
			Reflect.callMethod(this._onCompleteCallback, this._onCompleteCallback, []);
			#else
			this._onCompleteCallback();
			#end
		}
	}
}