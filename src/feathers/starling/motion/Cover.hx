/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion;
import feathers.starling.display.RenderDelegate;
import feathers.starling.motion.effectClasses.IEffectContext;
import feathers.starling.motion.effectClasses.TweenEffectContext;
import feathers.starling.utils.type.Property;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;

/**
 * Creates animated transitions for screen navigators that slide a new
 * display object into view by animating the <code>x</code> and
 * <code>y</code> properties, while covering an existing display object that
 * remains stationary below. The display object may slide up, right,
 * down, or left.
 *
 * @see ../../../help/transitions.html#cover Transitions for Feathers screen navigators: Cover
 *
 * @productversion Feathers 2.1.0
 */
class Cover 
{
	/**
	 * @private
	 */
	private static inline var SCREEN_REQUIRED_ERROR:String = "Cannot transition if both old screen and new screen are null.";

	/**
	 * Creates a transition function for a screen navigator that slides the
	 * new screen into view to the left, animating the <code>x</code>
	 * property, to cover up the old screen, which remains stationary.
	 *
	 * @see ../../../help/transitions.html#cover Transitions for Feathers screen navigators: Cover
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCoverLeftTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			if (newScreen != null)
			{
				newScreen.x = newScreen.width;
				newScreen.y = 0;
			}
			if (oldScreen != null)
			{
				oldScreen.x = 0;
				oldScreen.y = 0;
				var tween:CoverTween = new CoverTween(newScreen, oldScreen, -oldScreen.width, 0, duration, ease, managed ? null : onComplete, tweenProperties);
				if (managed)
				{
					return new TweenEffectContext(null, tween);
				}
				Starling.currentJuggler.add(tween);
				return null;
			}
			//we only have the new screen
			return slideInNewScreen(newScreen, duration, ease, tweenProperties, onComplete, managed);
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that slides the
	 * new screen into view to the right, animating the <code>x</code>
	 * property, to cover up the old screen, which remains stationary.
	 *
	 * @see ../../../help/transitions.html#cover Transitions for Feathers screen navigators: Cover
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCoverRightTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			if (newScreen != null)
			{
				newScreen.x = -newScreen.width;
				newScreen.y = 0;
			}
			if (oldScreen != null)
			{
				oldScreen.x = 0;
				oldScreen.y = 0;
				var tween:CoverTween = new CoverTween(newScreen, oldScreen, oldScreen.width, 0, duration, ease, managed ? null : onComplete, tweenProperties);
				if (managed)
				{
					return new TweenEffectContext(null, tween);
				}
				Starling.currentJuggler.add(tween);
				return null;
			}
			//we only have the new screen
			return slideInNewScreen(newScreen, duration, ease, tweenProperties, onComplete, managed);
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that slides the
	 * new screen up into view, animating the <code>y</code> property, to
	 * cover up the old screen, which remains stationary.
	 *
	 * @see ../../../help/transitions.html#cover Transitions for Feathers screen navigators: Cover
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCoverUpTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			if (newScreen != null)
			{
				newScreen.x = 0;
				newScreen.y = newScreen.height;
			}
			if (oldScreen != null)
			{
				oldScreen.x = 0;
				oldScreen.y = 0;
				var tween:CoverTween = new CoverTween(newScreen, oldScreen, 0, -oldScreen.height, duration, ease, managed ? null : onComplete, tweenProperties);
				if (managed)
				{
					return new TweenEffectContext(null, tween);
				}
				Starling.currentJuggler.add(tween);
				return null;
			}
			//we only have the new screen
			return slideInNewScreen(newScreen, duration, ease, tweenProperties, onComplete, managed);
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that slides the
	 * new screen down into view, animating the <code>y</code> property, to
	 * cover up the old screen, which remains stationary.
	 *
	 * @see ../../../help/transitions.html#cover Transitions for Feathers screen navigators: Cover
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCoverDownTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			if (newScreen != null)
			{
				newScreen.x = 0;
				newScreen.y = -newScreen.height;
			}
			if (oldScreen != null)
			{
				oldScreen.x = 0;
				oldScreen.y = 0;
				var tween:CoverTween = new CoverTween(newScreen, oldScreen, 0, oldScreen.height, duration, ease, managed ? null : onComplete, tweenProperties);
				if (managed)
				{
					return new TweenEffectContext(null, tween);
				}
				Starling.currentJuggler.add(tween);
				return null;
			}
			//we only have the new screen
			return slideInNewScreen(newScreen, duration, ease, tweenProperties, onComplete, managed);
		};
	}
	
	/**
	 * @private
	 */
	private static function slideInNewScreen(newScreen:DisplayObject,
		duration:Float, ease:Dynamic, tweenProperties:Dynamic, onComplete:Function, managed:Bool):IEffectContext
	{
		var tween:Tween = new Tween(newScreen, duration, ease);
		if (newScreen.x != 0)
		{
			tween.animate("x", 0);
		}
		if (newScreen.y != 0)
		{
			tween.animate("y", 0);
		}
		if (tweenProperties != null)
		{
			for (propertyName in Reflect.fields(tweenProperties))
			{
				Property.write(tween, propertyName, Reflect.field(tweenProperties, propertyName));
			}
		}
		tween.onComplete = onComplete;
		if (managed)
		{
			return new TweenEffectContext(null, tween);
		}
		Starling.currentJuggler.add(tween);
		return null;
	}
	
}

class CoverTween extends Tween
{
	public function new(newScreen:DisplayObject, oldScreen:DisplayObject,
		xOffset:Float, yOffset:Float, duration:Float, ease:Dynamic, onCompleteCallback:Function,
		tweenProperties:Dynamic)
	{
		var mask:Quad = new Quad(1, 1, 0xff00ff);
		//the initial dimensions cannot be 0 or there's a runtime error,
		//and these values might be 0
		mask.width = oldScreen.width;
		mask.height = oldScreen.height;
		this._temporaryParent = new Sprite();
		this._temporaryParent.mask = mask;
		oldScreen.parent.addChild(this._temporaryParent);
		var delegate:RenderDelegate = new RenderDelegate(oldScreen);
		delegate.alpha = oldScreen.alpha;
		delegate.blendMode = oldScreen.blendMode;
		delegate.rotation = oldScreen.rotation;
		delegate.scaleX = oldScreen.scaleX;
		delegate.scaleY = oldScreen.scaleY;
		this._temporaryParent.addChild(delegate);
		oldScreen.visible = false;
		this._savedOldScreen = oldScreen;
		
		super(this._temporaryParent.mask, duration, ease);
		
		if (xOffset < 0)
		{
			this.animate("width", 0);
		}
		else if (xOffset > 0)
		{
			this.animate("x", xOffset);
			this.animate("width", 0);
		}
		if (yOffset < 0)
		{
			this.animate("height", 0);
		}
		else if (yOffset > 0)
		{
			this.animate("y", yOffset);
			this.animate("height", 0);
		}
		if (tweenProperties != null)
		{
			for (propertyName in Reflect.fields(tweenProperties))
			{
				Property.write(this, propertyName, Reflect.field(tweenProperties, propertyName));
			}
		}
		this._onCompleteCallback = onCompleteCallback;
		if (newScreen != null)
		{
			this._savedNewScreen = newScreen;
			this._savedXOffset = xOffset;
			this._savedYOffset = yOffset;
			this.onUpdate = this.updateNewScreen;
		}
		this.onComplete = this.cleanupTween;
	}
	
	private var _savedXOffset:Float;
	private var _savedYOffset:Float;
	private var _savedOldScreen:DisplayObject;
	private var _savedNewScreen:DisplayObject;
	private var _temporaryParent:Sprite;
	private var _onCompleteCallback:Function;

	private function updateNewScreen():Void
	{
		var mask:Quad = cast this.target;
		if (this._savedXOffset < 0)
		{
			this._savedNewScreen.x = mask.width;
		}
		else if (this._savedXOffset > 0)
		{
			this._savedNewScreen.x = -mask.width;
		}
		if (this._savedYOffset < 0)
		{
			this._savedNewScreen.y = mask.height;
		}
		else if (this._savedYOffset > 0)
		{
			this._savedNewScreen.y = -mask.height;
		}
	}
	
	private function cleanupTween():Void
	{
		this._temporaryParent.removeFromParent(true);
		this._temporaryParent = null;
		this._savedOldScreen.visible = true;
		this._savedNewScreen = null;
		this._savedOldScreen = null;
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