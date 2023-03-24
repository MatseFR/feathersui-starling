/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.motion;
import feathers.display.RenderDelegate;
import feathers.motion.effectClasses.IEffectContext;
import feathers.motion.effectClasses.TweenEffectContext;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;

/**
 * Creates effects for Feathers components and transitions for screen
 * navigators that wipe a display object out of view, revealing another
 * display object under the first. Both display objects remain stationary
 * while the effect animates clipping rectangles. The clipping rectangles
 * may be animated up, right, down, or left.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 * @see ../../../help/transitions.html#wipe Transitions for Feathers screen navigators: Wipe
 *
 * @productversion Feathers 2.2.0
 */
class Wipe 
{
	/**
	 * @private
	 */
	private static inline var SCREEN_REQUIRED_ERROR:String = "Cannot transition if both old screen and new screen are null.";
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component into view from right to left, animating the
	 * <code>width</code> and <code>x</code> properties of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeInLeftEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			mask.width = 0;
			mask.x = maskWidth;
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("width", maskWidth);
			tween.animate("x", 0);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.removeFromParent(true);
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component into view from left to right, animating the
	 * <code>width</code> property of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeInRightEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			mask.width = 0;
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("width", maskWidth);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.dispose();
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component into view from bottom to top, animating the
	 * <code>height</code> and <code>y</code> properties of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeInUpEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			mask.height = 0;
			mask.y = maskHeight;
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("height", maskHeight);
			tween.animate("y", 0);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.dispose();
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component into view from top to bottom, animating the
	 * <code>height</code> property of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeInDownEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			mask.height = 0;
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("height", maskHeight);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.removeFromParent(true);
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component out of view from right to left, animating the
	 * <code>width</code> property of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeOutLeftEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("width", 0);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.dispose();
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component out of view from left to right, animating the
	 * <code>width</code> and <code>x</code> properties of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeOutRightEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("width", 0);
			tween.animate("x", maskWidth);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.removeFromParent(true);
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component out of view from bottom to top, animating the
	 * <code>height</code> property of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeOutUpEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("height", 0);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.dispose();
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates an effect function for the target component that wipes the
	 * target component out of view from top to bottom, animating the
	 * <code>height</code> and <code>y</code> properties of a temporary mask.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 */
	public static function createWipeOutDownEffect(duration:Float = 0.25, ease:Dynamic = Transitions.EASE_OUT):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			var oldMask:DisplayObject = target.mask;
			var maskWidth:Float = target.width;
			var maskHeight:Float = target.height;
			if (maskWidth < 0)
			{
				maskWidth = 1;
			}
			if (maskHeight < 0)
			{
				maskHeight = 1;
			}
			var mask:Quad = new Quad(maskWidth, maskHeight, 0xff00ff);
			target.mask = mask;
			var tween:Tween = new Tween(mask, duration, ease);
			tween.animate("height", 0);
			tween.animate("y", maskHeight);
			tween.onComplete = function():Void
			{
				target.mask = oldMask;
				mask.removeFromParent(true);
			};
			return new TweenEffectContext(target, tween);
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that wipes the
	 * old screen out of view to the left, animating the <code>width</code>
	 * property of a <code>clipRect</code>, to reveal the new screen under
	 * it. The new screen remains stationary.
	 *
	 * @see ../../../help/transitions.html#wipe Transitions for Feathers screen navigators: Wipe
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createWipeLeftTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var xOffset:Float = oldScreen != null ? -oldScreen.width : -newScreen.width;
			var tween:WipeTween = new WipeTween(newScreen, oldScreen, xOffset, 0, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that wipes the
	 * old screen out of view to the right, animating the <code>x</code>
	 * and <code>width</code> properties of a <code>clipRect</code>, to
	 * reveal the new screen under it. The new screen remains stationary.
	 *
	 * @see ../../../help/transitions.html#wipe Transitions for Feathers screen navigators: Wipe
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createWipeRightTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var xOffset:Float = oldScreen != null ? oldScreen.width : newScreen.width;
			var tween:WipeTween = new WipeTween(newScreen, oldScreen, xOffset, 0, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that wipes the
	 * old screen up, animating the <code>height</code> property of a
	 * <code>clipRect</code>, to reveal the new screen under it. The new
	 * screen remains stationary.
	 *
	 * @see ../../../help/transitions.html#wipe Transitions for Feathers screen navigators: Wipe
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createWipeUpTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var yOffset:Float = oldScreen != null ? -oldScreen.height : -newScreen.height;
			var tween:WipeTween = new WipeTween(newScreen, oldScreen, 0, yOffset, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that wipes the
	 * old screen down, animating the <code>y</code> and <code>height</code>
	 * properties of a <code>clipRect</code>, to reveal the new screen under
	 * it. The new screen remains stationary.
	 *
	 * @see ../../../help/transitions.html#wipe Transitions for Feathers screen navigators: Wipe
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createWipeDownTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var yOffset:Float = oldScreen != null ? oldScreen.height : newScreen.height;
			var tween:WipeTween = new WipeTween(newScreen, oldScreen, 0, yOffset, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
}

class WipeTween extends Tween
{
	public function new(newScreen:DisplayObject, oldScreen:DisplayObject,
		xOffset:Float, yOffset:Float, duration:Float, ease:Dynamic, onCompleteCallback:Function,
		tweenProperties:Dynamic)
	{
		var mask:Quad = null;
		if (newScreen != null)
		{
			mask = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			mask.width = 0;
			mask.height = 0;
			if (xOffset != 0)
			{
				if (xOffset < 0)
				{
					mask.x = newScreen.width;
				}
				mask.height = newScreen.height;
			}
			if (yOffset != 0)
			{
				if (yOffset < 0)
				{
					mask.y = newScreen.height;
				}
				mask.width = newScreen.width;
			}
			this._newScreenDelegate = new RenderDelegate(newScreen);
			this._newScreenDelegate.alpha = newScreen.alpha;
			this._newScreenDelegate.blendMode = newScreen.blendMode;
			this._newScreenDelegate.rotation = newScreen.rotation;
			this._newScreenDelegate.scaleX = newScreen.scaleX;
			this._newScreenDelegate.scaleY = newScreen.scaleY;
			this._newScreenDelegate.mask = mask;
			this._newScreenClipRect = mask;
			newScreen.parent.addChild(this._newScreenDelegate);
			newScreen.parent.addChild(mask);
			newScreen.visible = false;
			this._savedNewScreen = newScreen;
		}
		if (oldScreen != null)
		{
			mask = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			//and these values might be 0
			mask.width = oldScreen.width;
			mask.height = oldScreen.height;
			this._oldScreenDelegate = new RenderDelegate(oldScreen);
			this._oldScreenDelegate.alpha = oldScreen.alpha;
			this._oldScreenDelegate.blendMode = oldScreen.blendMode;
			this._oldScreenDelegate.rotation = oldScreen.rotation;
			this._oldScreenDelegate.scaleX = oldScreen.scaleX;
			this._oldScreenDelegate.scaleY = oldScreen.scaleY;
			this._oldScreenDelegate.mask = mask;
			oldScreen.parent.addChild(this._oldScreenDelegate);
			oldScreen.parent.addChild(mask);
			oldScreen.visible = false;
			this._savedOldScreen = oldScreen;
		}
		
		super(mask, duration, ease);
		
		if (oldScreen != null)
		{
			if (xOffset < 0)
			{
				this.animate("width", oldScreen.width + xOffset);
			}
			else if (xOffset > 0)
			{
				this.animate("x", xOffset);
				this.animate("width", oldScreen.width - xOffset);
			}
			if (yOffset < 0)
			{
				this.animate("height", oldScreen.height + yOffset);
			}
			else if (yOffset > 0)
			{
				this.animate("y", yOffset);
				this.animate("height", oldScreen.height - yOffset);
			}
			if (this._newScreenDelegate != null)
			{
				this.onUpdate = this.updateNewScreen;
			}
		}
		else //new screen only
		{
			if (xOffset < 0)
			{
				this.animate("x", newScreen.width + xOffset);
				this.animate("width", -xOffset);
			}
			else if (xOffset > 0)
			{
				this.animate("width", xOffset);
			}
			if (yOffset < 0)
			{
				this.animate("y", newScreen.height + yOffset);
				this.animate("height", -yOffset);
			}
			else if (yOffset > 0)
			{
				this.animate("height", yOffset);
			}
		}
		if (tweenProperties != null)
		{
			for (propertyName in Reflect.fields(tweenProperties))
			{
				Reflect.setProperty(this, propertyName, Reflect.field(tweenProperties, propertyName));
			}
		}
		this._savedXOffset = xOffset;
		this._savedYOffset = yOffset;
		this._onCompleteCallback = onCompleteCallback;
		this.onComplete = this.cleanupTween;
	}
	
	private var _oldScreenDelegate:RenderDelegate;
	private var _newScreenDelegate:RenderDelegate;
	private var _newScreenClipRect:Quad;
	private var _savedOldScreen:DisplayObject;
	private var _savedNewScreen:DisplayObject;
	private var _savedXOffset:Float;
	private var _savedYOffset:Float;
	private var _onCompleteCallback:Function;
	
	private function updateNewScreen():Void
	{
		var oldScreenClipRect:Quad = cast this.target;
		if (this._savedXOffset < 0)
		{
			this._newScreenClipRect.x = oldScreenClipRect.width;
			this._newScreenClipRect.width = this._savedNewScreen.width - this._newScreenClipRect.x;
		}
		else if (this._savedXOffset > 0)
		{
			this._newScreenClipRect.width = oldScreenClipRect.x;
		}
		if (this._savedYOffset < 0)
		{
			this._newScreenClipRect.y = oldScreenClipRect.height;
			this._newScreenClipRect.height = this._savedNewScreen.height - this._newScreenClipRect.y;
		}
		else if (this._savedYOffset > 0)
		{
			this._newScreenClipRect.height = oldScreenClipRect.y;
		}
	}
	
	private function cleanupTween():Void
	{
		if (this._oldScreenDelegate != null)
		{
			cast(this.target, Quad).removeFromParent(true);
			this._oldScreenDelegate.removeFromParent(true);
			this._oldScreenDelegate = null;
		}
		if (this._newScreenDelegate != null)
		{
			this._newScreenClipRect.removeFromParent(true);
			this._newScreenClipRect = null;
			this._newScreenDelegate.removeFromParent(true);
			this._newScreenDelegate = null;
		}
		if (this._savedOldScreen != null)
		{
			this._savedOldScreen.visible = true;
			this._savedOldScreen = null;
		}
		if (this._savedNewScreen != null)
		{
			this._savedNewScreen.visible = true;
			this._savedNewScreen = null;
		}
		if (this._onCompleteCallback != null)
		{
			this._onCompleteCallback();
		}
	}
}