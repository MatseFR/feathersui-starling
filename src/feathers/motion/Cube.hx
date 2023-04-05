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
import feathers.utils.type.Property;
import haxe.Constraints.Function;
import openfl.display3D.Context3DTriangleFace;
import openfl.errors.ArgumentError;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite3D;
import starling.rendering.Painter;

/**
 * Creates animated transitions for screen navigators that position a
 * display object in 3D space as if it is on a side of a cube, and the cube
 * may rotate up or down around the x-axis, or it may rotate left or right
 * around the y-axis.
 *
 * <p>Warning: <code>Cube</code> and other transitions with 3D effects may
 * not be compatible with masks.</p>
 *
 * @see ../../../help/transitions.html#cube Transitions for Feathers screen navigators: Cube
 *
 * @productversion Feathers 2.1.0
 */
class Cube 
{
	/**
	 * @private
	 */
	private static inline var SCREEN_REQUIRED_ERROR:String = "Cannot transition if both old screen and new screen are null.";
	
	/**
	 * Creates a transition function for a screen navigator that positions
	 * the screens in 3D space as if they are on two adjacent sides of a
	 * cube, and the cube rotates left around the y-axis.
	 *
	 * @see ../../../help/transitions.html#cube Transitions for Feathers screen navigators: Cube
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCubeLeftTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:CubeTween = new CubeTween(newScreen, oldScreen, Math.PI / 2, 0, duration, ease, managed ? null : onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that positions
	 * the screens in 3D space as if they are on two adjacent sides of a
	 * cube, and the cube rotates right around the y-axis.
	 *
	 * @see ../../../help/transitions.html#cube Transitions for Feathers screen navigators: Cube
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCubeRightTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:CubeTween = new CubeTween(newScreen, oldScreen, -Math.PI / 2, 0, duration, ease, managed ? null : onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that positions
	 * the screens in 3D space as if they are on two adjacent sides of a
	 * cube, and the cube rotates up around the x-axis.
	 *
	 * @see ../../../help/transitions.html#cube Transitions for Feathers screen navigators: Cube
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCubeUpTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:CubeTween = new CubeTween(newScreen, oldScreen, 0, -Math.PI / 2, duration, ease, managed ? null : onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
	/**
	 * Creates a transition function for a screen navigator that positions
	 * the screens in 3D space as if they are on two adjacent sides of a
	 * cube, and the cube rotates down around the y-axis.
	 *
	 * @see ../../../help/transitions.html#cube Transitions for Feathers screen navigators: Cube
	 * @see feathers.controls.StackScreenNavigator#pushTransition
	 * @see feathers.controls.StackScreenNavigator#popTransition
	 * @see feathers.controls.ScreenNavigator#transition
	 */
	public static function createCubeDownTransition(duration:Float = 0.5, ease:Dynamic = Transitions.EASE_OUT, tweenProperties:Dynamic = null):Function
	{
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function, managed:Bool = false):IEffectContext
		{
			if (oldScreen == null && newScreen == null)
			{
				throw new ArgumentError(SCREEN_REQUIRED_ERROR);
			}
			var tween:CubeTween = new CubeTween(newScreen, oldScreen, 0, Math.PI / 2, duration, ease, managed ? null : onComplete, tweenProperties);
			if (managed)
			{
				return new TweenEffectContext(null, tween);
			}
			Starling.currentJuggler.add(tween);
			return null;
		};
	}
	
}

class CubeTween extends Tween
{
	public function new(newScreen:DisplayObject, oldScreen:DisplayObject,
		rotationYOffset:Float, rotationXOffset:Float,
		duration:Float, ease:Dynamic, onCompleteCallback:Function,
		tweenProperties:Dynamic)
	{
		var cube:CulledSprite3D = new CulledSprite3D();
		var delegate:RenderDelegate;
		if (newScreen != null)
		{
			this._navigator = newScreen.parent;
			this._newScreenParent = new Sprite3D();
			if (rotationYOffset < 0)
			{
				this._newScreenParent.z = this._navigator.width;
				this._newScreenParent.rotationY = rotationYOffset + Math.PI;
			}
			else if (rotationYOffset > 0)
			{
				this._newScreenParent.x = this._navigator.width;
				this._newScreenParent.rotationY = -rotationYOffset;
			}
			if (rotationXOffset < 0)
			{
				this._newScreenParent.y = this._navigator.height;
				this._newScreenParent.rotationX = rotationXOffset + Math.PI;
			}
			else if (rotationXOffset > 0)
			{
				this._newScreenParent.z = this._navigator.height;
				this._newScreenParent.rotationX = -rotationXOffset;
			}
			delegate = new RenderDelegate(newScreen);
			delegate.alpha = newScreen.alpha;
			delegate.blendMode = newScreen.blendMode;
			delegate.rotation = newScreen.rotation;
			delegate.scaleX = newScreen.scaleX;
			delegate.scaleY = newScreen.scaleY;
			this._newScreenParent.addChild(delegate);
			newScreen.visible = false;
			this._savedNewScreen = newScreen;
			cube.addChild(this._newScreenParent);
		}
		if (oldScreen != null)
		{
			if (this._navigator == null)
			{
				this._navigator = oldScreen.parent;
			}
			delegate = new RenderDelegate(oldScreen);
			delegate.alpha = oldScreen.alpha;
			delegate.blendMode = oldScreen.blendMode;
			delegate.rotation = oldScreen.rotation;
			delegate.scaleX = oldScreen.scaleX;
			delegate.scaleY = oldScreen.scaleY;
			cube.addChildAt(delegate, 0);
			oldScreen.visible = false;
			this._savedOldScreen = oldScreen;
		}
		this._navigator.addChild(cube);
		
		super(cube, duration, ease);
		
		if (rotationYOffset < 0)
		{
			this.animate("x", this._navigator.width);
			this.animate("rotationY", rotationYOffset);
		}
		else if (rotationYOffset > 0)
		{
			this.animate("z", this._navigator.width);
			this.animate("rotationY", rotationYOffset);
		}
		if (rotationXOffset < 0)
		{
			this.animate("z", this._navigator.height);
			this.animate("rotationX", rotationXOffset);
		}
		else if (rotationXOffset > 0)
		{
			this.animate("y", this._navigator.height);
			this.animate("rotationX", rotationXOffset);
		}
		if (tweenProperties != null)
		{
			for (propertyName in Reflect.fields(tweenProperties))
			{
				Property.write(this, propertyName, Reflect.field(tweenProperties, propertyName));
			}
		}
		
		this._onCompleteCallback = onCompleteCallback;
		this.onComplete = this.cleanupTween;
	}
	
	private var _navigator:DisplayObjectContainer;
	private var _newScreenParent:Sprite3D;
	private var _onCompleteCallback:Function;
	private var _savedNewScreen:DisplayObject;
	private var _savedOldScreen:DisplayObject;

	private function cleanupTween():Void
	{
		var cube:Sprite3D = cast this.target;
		cube.removeFromParent(true);
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

class CulledSprite3D extends Sprite3D
{
	override public function render(painter:Painter):Void
	{
		//this will be cleared later when the state is popped
		painter.state.culling = Context3DTriangleFace.BACK;
		super.render(painter);
	}
}

