/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion;
import feathers.starling.core.IFeathersControl;
import feathers.starling.motion.effectClasses.IEffectContext;
import feathers.starling.motion.effectClasses.IResizeEffectContext;
import feathers.starling.motion.effectClasses.TweenEffectContext;
import feathers.starling.motion.effectClasses.TweenResizeEffectContext;
import haxe.Constraints.Function;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.display.DisplayObject;

/**
 * An effect that animates a component's <code>width</code> and
 * <code>height</code> dimensions.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 *
 * @productversion Feathers 3.5.0
 */
class Resize 
{
	/**
	 * Creates an effect function for the target component that animates
	 * its dimensions when they are changed. Must be used with the
	 * <code>resizeEffect</code> property.
	 *
	 * @see feathers.core.FeathersControl#resizeEffect
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createResizeEffect(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.STOP):Function
	{
		return function(target:DisplayObject):IResizeEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			var context:TweenResizeEffectContext = new TweenResizeEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its dimensions from their current values to new values.
	 *
	 * @productversion Feathers 3.5.0
	 *
	 * @see #createResizeWidthToEffect()
	 * @see #createResizeHeightToEffect()
	 */
	public static function createResizeToEffect(toWidth:Float, toHeight:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("width", toWidth);
			tween.animate("height", toHeight);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its <strong>width</strong> from its current value to a new
	 * value.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createResizeWidthToEffect(toWidth:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("width", toWidth);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its <strong>height</strong> from its current value to a new
	 * value.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createResizeHeightToEffect(toHeight:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("height", toHeight);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its dimensions from specific values to its
	 * current values.
	 *
	 * @productversion Feathers 3.5.0
	 *
	 * @see #createResizeWidthFromEffect()
	 * @see createResizeHeightFromEffect()
	 */
	public static function createResizeFromEffect(fromWidth:Float, fromHeight:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldWidth:Float = target.width;
			var oldHeight:Float = target.height;
			if (Std.isOfType(target, IFeathersControl))
			{
				var oldExplicitWidth:Float = cast(target, IFeathersControl).explicitWidth;
				var oldExplicitHeight:Float = cast(target, IFeathersControl).explicitHeight;
				if (oldExplicitWidth == oldExplicitWidth || //!isNaN
					oldExplicitHeight == oldExplicitHeight) //!isNaN
				{
					tween.onComplete = function():Void
					{
						//restore the original explicit height
						target.width = oldExplicitWidth;
						target.height = oldExplicitHeight;
					};
				}
				cast(target, IFeathersControl).suspendEffects();
			}
			target.width = fromWidth;
			target.height = fromHeight;
			if (Std.isOfType(target, IFeathersControl))
			{
				cast(target, IFeathersControl).resumeEffects();
			}
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("width", oldWidth);
			tween.animate("height", oldHeight);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its <strong>width</strong> from a specific value to its
	 * current value.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createResizeWidthFromEffect(fromWidth:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldWidth:Float = target.width;
			if (Std.isOfType(target, IFeathersControl))
			{
				var oldExplicitWidth:Float = cast(target, IFeathersControl).explicitWidth;
				if (oldExplicitWidth == oldExplicitWidth) //!isNaN
				{
					tween.onComplete = function():Void
					{
						//restore the original explicit width
						target.width = oldExplicitWidth;
					};
				}
				cast(target, IFeathersControl).suspendEffects();
			}
			target.width = fromWidth;
			if (Std.isOfType(target, IFeathersControl))
			{
				cast(target, IFeathersControl).resumeEffects();
			}
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("width", oldWidth);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its <strong>height</strong> from a specific value to its
	 * current value.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createResizeHeightFromEffect(fromHeight:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldHeight:Float = target.height;
			if (Std.isOfType(target, IFeathersControl))
			{
				var oldExplicitHeight:Float = cast(target, IFeathersControl).explicitHeight;
				if (oldExplicitHeight == oldExplicitHeight) //!isNaN
				{
					tween.onComplete = function():Void
					{
						//restore the original explicit height
						target.height = oldExplicitHeight;
					};
				}
				cast(target, IFeathersControl).suspendEffects();
			}
			target.height = fromHeight;
			if (Std.isOfType(target, IFeathersControl))
			{
				cast(target, IFeathersControl).resumeEffects();
			}
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("height", oldHeight);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its dimensions from its current values to new values
	 * calculated by an offset.
	 *
	 * @productversion Feathers 3.5.0
	 *
	 * @see #createResizeWidthByEffect()
	 * @see #createResizeHeightByEffect()
	 */
	public static function createResizeByEffect(widthBy:Float, heightBy:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("width", target.width + widthBy);
			tween.animate("height", target.height + heightBy);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its <strong>width</strong> from its current value to a new
	 * value calculated by an offset.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createResizeWidthByEffect(widthBy:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("width", target.width + widthBy);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
	/**
	 * Creates an effect function for the target component that
	 * animates its <strong>height</strong> from its current value to a new
	 * value calculated by an offset.
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createResizeHeightByEffect(heightBy:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var tween:Tween = new Tween(target, duration, ease);
			tween.animate("height", target.height + heightBy);
			var context:TweenEffectContext = new TweenEffectContext(target, tween);
			context.interruptBehavior = interruptBehavior;
			return context;
		};
	}
	
}