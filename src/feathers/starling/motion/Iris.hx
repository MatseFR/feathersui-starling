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
import openfl.geom.Point;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Canvas;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.utils.Pool;

/**
 * Creates effects for Feathers components and transitions for screen
 * navigators that show or hide a display object masked by a growing or
 * shrinking circle. In a transition, both display objects remain stationary
 * while a stencil mask is animated.
 *
 * <p>Note: This effect is not supported with display objects that have
 * transparent backgrounds due to limitations in stencil masks. Display
 * objects should be fully opaque.</p>
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 * @see ../../../help/transitions.html#iris Transitions for Feathers screen navigators: Iris
 *
 * @productversion Feathers 2.2.0
 */
class Iris 
{
	/**
	 * @private
	 */
	private static inline var IRIS_MASK_NAME:String = "feathers-iris-effect-mask";
	
	/**
	 * @private
	 */
	private static inline var SCREEN_REQUIRED_ERROR:String = "Cannot transition if both old screen and new screen are null.";
	
	/**
	 * Creates an effect function for the target component that shows the
	 * component by masking it with a growing circle in the center.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createIrisOpenEffect(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return createIrisOpenEffectAtRatio(0.5, 0.5, duration, ease, interruptBehavior);
	}
	
	/**
	 * Creates an effect function for the target component that shows the
	 * component by masking it with a growing circle at a specific position
	 * in the range from 0.0 to 1.0.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createIrisOpenEffectAtRatio(ratioX:Float, ratioY:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
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
			return createIrisOpenEffectContextAtXY(target, maskWidth * ratioX, maskHeight * ratioY, duration, ease, interruptBehavior);
		};
	}
	
	/**
	 * Creates an effect function for the target component that shows the
	 * component by masking it with a growing circle at a specific position.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createIrisOpenEffectAtXY(x:Float, y:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			return createIrisOpenEffectContextAtXY(target, x, y, duration, ease, interruptBehavior);
		};
	}
	
	/**
	 * @private
	 */
	private static function createIrisOpenEffectContextAtXY(target:DisplayObject, originX:Float, originY:Float, duration:Float, ease:Dynamic, interruptBehavior:String):IEffectContext
	{
		var mask:Canvas = null;
		var oldMask:DisplayObject = target.mask;
		if (Std.isOfType(oldMask, Canvas) && oldMask.name == IRIS_MASK_NAME)
		{
			mask = cast oldMask;
		}
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
		var halfWidth:Float = maskWidth / 2;
		var halfHeight:Float = maskHeight / 2;
		var p1:Point = Pool.getPoint(halfWidth, halfHeight);
		var p2:Point = Pool.getPoint(originX, originY);
		var radiusFromCenter:Float = p1.length;
		var radius:Float;
		if (p1.equals(p2))
		{
			radius = radiusFromCenter;
		}
		else
		{
			var distanceFromCenterToOrigin:Float = Point.distance(p1, p2);
			radius = radiusFromCenter + distanceFromCenterToOrigin;
		}
		Pool.putPoint(p1);
		Pool.putPoint(p2);
		if (mask == null)
		{
			mask = new Canvas();
			mask.name = IRIS_MASK_NAME;
			mask.x = originX;
			mask.y = originY;
			mask.beginFill(0xff00ff);
			mask.drawCircle(0, 0, radius);
			mask.endFill();
			mask.scale = 0;
			target.mask = mask;
		}
		else
		{
			mask.clear();
			mask.beginFill(0xff00ff);
			//the radius may have changed
			mask.drawCircle(0, 0, radius);
			mask.endFill();
		}
		var tween:Tween = new Tween(mask, duration, ease);
		tween.animate("scale", 1);
		if (mask == oldMask)
		{
			//the x and y position may have changed
			if (mask.x != originX)
			{
				tween.animate("x", originX);
			}
			if (mask.y != originY)
			{
				tween.animate("y", originY);
			}
		}
		var context:TweenEffectContext = new TweenEffectContext(target, tween);
		context.interruptBehavior = interruptBehavior;
		context.addEventListener(Event.COMPLETE, function(event:Event, stopped:Bool):Void
		{
			if (stopped)
			{
				return;
			}
			mask.removeFromParent(true);
			if (mask == oldMask)
			{
				target.mask = null;
			}
			else
			{
				target.mask = oldMask;
			}
		});
		return context;
	}
	
	/**
	 * Creates an effect function for the target component that hides the
	 * component by masking it with a shrinking circle in the center.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createIrisCloseEffect(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return createIrisCloseEffectAtRatio(0.5, 0.5, duration, ease, interruptBehavior);
	}
	
	/**
	 * Creates an effect function for the target component that hides the
	 * component by masking it with a shrinking circle at a specific position
	 * in the range 0.0 to 1.0.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createIrisCloseEffectAtRatio(ratioX:Float, ratioY:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
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
			return createIrisCloseEffectContextAtXY(target, maskWidth * ratioX, maskHeight * ratioY, duration, ease, interruptBehavior);
		};
	}
	
	/**
	 * Creates an effect function for the target component that hides the
	 * component by masking it with a shrinking circle at a specific position.
	 *
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 *
	 * @productversion Feathers 3.5.0
	 */
	public static function createIrisCloseEffectAtXY(x:Float, y:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, interruptBehavior:String = EffectInterruptBehavior.END):Function
	{
		return function(target:DisplayObject):IEffectContext
		{
			return createIrisCloseEffectContextAtXY(target, x, y, duration, ease, interruptBehavior);
		};
	}
	
	/**
	 * @private
	 */
	private static function createIrisCloseEffectContextAtXY(target:DisplayObject, originX:Float, originY:Float, duration:Float, ease:Dynamic, interruptBehavior:String):IEffectContext
	{
		var mask:Canvas = null;
		var oldMask:DisplayObject = target.mask;
		if (Std.isOfType(oldMask, Canvas) && oldMask.name == IRIS_MASK_NAME)
		{
			mask = cast oldMask;
		}
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
		var halfWidth:Float = maskWidth / 2;
		var halfHeight:Float = maskHeight / 2;
		var p1:Point = Pool.getPoint(halfWidth, halfHeight);
		var p2:Point = Pool.getPoint(originX, originY);
		var radiusFromCenter:Float = p1.length;
		var radius:Float;
		if (p1.equals(p2))
		{
			radius = radiusFromCenter;
		}
		else
		{
			var distanceFromCenterToOrigin:Float = Point.distance(p1, p2);
			radius = radiusFromCenter + distanceFromCenterToOrigin;
		}
		Pool.putPoint(p1);
		Pool.putPoint(p2);
		if (mask == null)
		{
			mask = new Canvas();
			mask.name = IRIS_MASK_NAME;
			mask.x = originX;
			mask.y = originY;
			mask.beginFill(0xff00ff);
			mask.drawCircle(0, 0, radius);
			mask.endFill();
			target.mask = mask;
		}
		else
		{
			mask.clear();
			mask.beginFill(0xff00ff);
			//the radius may have changed
			mask.drawCircle(0, 0, radius);
			mask.endFill();
		}
		var tween:Tween = new Tween(mask, duration, ease);
		tween.animate("scale", 0);
		if (mask == oldMask)
		{
			//the x and y position may have changed
			if (mask.x != originX)
			{
				tween.animate("x", originX);
			}
			if (mask.y != originY)
			{
				tween.animate("y", originY);
			}
		}
		var context:TweenEffectContext = new TweenEffectContext(target, tween);
		context.interruptBehavior = interruptBehavior;
		context.addEventListener(Event.COMPLETE, function(event:Event, stopped:Bool):Void
		{
			if (stopped)
			{
				return;
			}
			mask.removeFromParent(true);
			if (mask == oldMask)
			{
				target.mask = null;
			}
			else
			{
				target.mask = oldMask;
			}
		});
		return context;
	}
	
	/**
	 * Creates a transition function for a screen navigator that shows a
	 * screen by masking it with a growing circle in the center.
	 *
	 * @see ../../../help/transitions.html#iris Transitions for Feathers screen navigators: Iris
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createIrisOpenTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var originX:Float;
			var originY:Float;
			if (oldScreen != null)
			{
				originX = oldScreen.width / 2;
				originY = oldScreen.height / 2;
			}
			else
			{
				originX = newScreen.width / 2;
				originY = newScreen.height / 2;
			}
			var tween:IrisTween = new IrisTween(newScreen, oldScreen, originX, originY, true, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that shows a
	 * screen by masking it with a growing circle at a specific position.
	 *
	 * @see ../../../help/transitions.html#iris Transitions for Feathers screen navigators: Iris
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createIrisOpenTransitionAt(x:Float, y:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:IrisTween = new IrisTween(newScreen, oldScreen, x, y, true, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that hides a
	 * screen by masking it with a shrinking circle in the center.
	 *
	 * @see ../../../help/transitions.html#iris Transitions for Feathers screen navigators: Iris
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createIrisCloseTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var originX:Float;
			var originY:Float;
			if (oldScreen != null)
			{
				originX = oldScreen.width / 2;
				originY = oldScreen.height / 2;
			}
			else
			{
				originX = newScreen.width / 2;
				originY = newScreen.height / 2;
			}
			var tween:IrisTween = new IrisTween(newScreen, oldScreen, originX, originY, false, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that hides a
	 * screen by masking it with a shrinking circle at a specific position.
	 *
	 * @see ../../../help/transitions.html#iris Transitions for Feathers screen navigators: Iris
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createIrisCloseTransitionAt(x:Float, y:Float, duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:IrisTween = new IrisTween(newScreen, oldScreen, x, y, false, duration, ease, onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
}

class IrisTween extends Tween
{
	public function new(newScreen:DisplayObject, oldScreen:DisplayObject,
		originX:Float, originY:Float, openIris:Bool, duration:Float, ease:Dynamic,
		onCompleteCallback:Function, tweenProperties:Dynamic)
	{
		var width:Float;
		var height:Float;
		if (newScreen != null)
		{
			width = newScreen.width;
			height = newScreen.height;
		}
		else
		{
			width = oldScreen.width;
			height = oldScreen.height;
		}
		var halfWidth:Float = width / 2;
		var halfHeight:Float = height / 2;
		var p1:Point = Pool.getPoint(halfWidth, halfHeight);
		var p2:Point = Pool.getPoint(originX, originY);
		var radiusFromCenter:Float = p1.length;
		var radius:Float;
		if (p1.equals(p2))
		{
			radius = radiusFromCenter;
		}
		else
		{
			var distanceFromCenterToOrigin:Float = Point.distance(p1, p2);
			radius = radiusFromCenter + distanceFromCenterToOrigin;
		}
		Pool.putPoint(p1);
		Pool.putPoint(p2);
		var maskTarget:Canvas = null;
		var mask:Canvas;
		if (newScreen != null && openIris)
		{
			this._newScreenDelegate = new RenderDelegate(newScreen);
			this._newScreenDelegate.alpha = newScreen.alpha;
			this._newScreenDelegate.blendMode = newScreen.blendMode;
			this._newScreenDelegate.rotation = newScreen.rotation;
			this._newScreenDelegate.scaleX = newScreen.scaleX;
			this._newScreenDelegate.scaleY = newScreen.scaleY;
			newScreen.parent.addChild(this._newScreenDelegate);
			newScreen.visible = false;
			this._savedNewScreen = newScreen;
			
			mask = new Canvas();
			mask.x = originX;
			mask.y = originY;
			mask.beginFill(0xff00ff);
			mask.drawCircle(0, 0, radius);
			mask.endFill();
			if (openIris)
			{
				mask.scaleX = 0;
				mask.scaleY = 0;
				this._newScreenDelegate.mask = mask;
			}
			newScreen.parent.addChild(mask);
			maskTarget = mask;
		}
		if (oldScreen != null && !openIris)
		{
			this._oldScreenDelegate = new RenderDelegate(oldScreen);
			this._oldScreenDelegate.alpha = oldScreen.alpha;
			this._oldScreenDelegate.blendMode = oldScreen.blendMode;
			this._oldScreenDelegate.rotation = oldScreen.rotation;
			this._oldScreenDelegate.scaleX = oldScreen.scaleX;
			this._oldScreenDelegate.scaleY = oldScreen.scaleY;
			oldScreen.parent.addChild(this._oldScreenDelegate);
			oldScreen.visible = false;
			this._savedOldScreen = oldScreen;
			
			mask = new Canvas();
			mask.x = originX;
			mask.y = originY;
			mask.beginFill(0xff00ff);
			mask.drawCircle(0, 0, radius);
			mask.endFill();
			if (!openIris)
			{
				this._oldScreenDelegate.mask = mask;
			}
			oldScreen.parent.addChild(mask);
			maskTarget = mask;
		}
		
		super(maskTarget, duration, ease);
		
		if (openIris)
		{
			this.animate("scaleX", 1);
			this.animate("scaleY", 1);
		}
		else
		{
			this.animate("scaleX", 0);
			this.animate("scaleY", 0);
		}
		
		if (tweenProperties != null)
		{
			for (propertyName in Reflect.fields(tweenProperties))
			{
				Property.write(this, propertyName, Reflect.field(tweenProperties, propertyName));
			}
		}
		this._savedWidth = width;
		this._savedHeight = height;
		this._onCompleteCallback = onCompleteCallback;
		this.onComplete = this.cleanupTween;
	}
	
	private var _newScreenDelegate:RenderDelegate;
	private var _oldScreenDelegate:RenderDelegate;
	private var _savedOldScreen:DisplayObject;
	private var _savedNewScreen:DisplayObject;
	private var _onCompleteCallback:Function;
	private var _savedWidth:Float;
	private var _savedHeight:Float;
	
	private function cleanupTween():Void
	{
		if (this._newScreenDelegate != null)
		{
			this._newScreenDelegate.mask.removeFromParent(true);
			this._newScreenDelegate.removeFromParent(true);
			this._newScreenDelegate = null;
		}
		if (this._oldScreenDelegate != null)
		{
			this._oldScreenDelegate.mask.removeFromParent(true);
			this._oldScreenDelegate.removeFromParent(true);
			this._oldScreenDelegate = null;
		}
		if (this._savedNewScreen != null)
		{
			this._savedNewScreen.visible = true;
			this._savedNewScreen = null;
		}
		if (this._savedOldScreen != null)
		{
			this._savedOldScreen.visible = true;
			this._savedOldScreen = null;
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