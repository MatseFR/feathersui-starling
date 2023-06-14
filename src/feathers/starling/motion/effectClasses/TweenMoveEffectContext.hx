/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion.effectClasses;

import feathers.starling.core.IFeathersControl;
import feathers.starling.motion.effectClasses.TweenEffectContext;
import starling.animation.Tween;
import starling.display.DisplayObject;

/**
 * A move effect context for a <code>starling.animation.Tween</code>.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 * @see http://doc.starling-framework.org/core/starling/animation/Tween.html starling.animation.Tween
 * @see feathers.core.FeathersControl#moveEffect
 *
 * @productversion Feathers 3.5.0
 */
class TweenMoveEffectContext extends TweenEffectContext implements IMoveEffectContext
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject, tween:Tween) 
	{
		super(target, tween);
		this._oldX = this._target.x;
		this._oldY = this._target.y;
		this._newX = this._target.x;
		this._tween.animate("x", this._newX);
		this._newY = this._target.y;
		this._tween.animate("y", this._newY);
	}
	
	/**
	 * @inheritDoc
	 */
	public var oldX(get, set):Float;
	private var _oldX:Float;
	private function get_oldX():Float { return this._oldX; }
	private function set_oldX(value:Float):Float
	{
		return this._oldX = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var oldY(get, set):Float;
	private var _oldY:Float;
	private function get_oldY():Float { return this._oldY; }
	private function set_oldY(value:Float):Float
	{
		return this._oldY = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var newX(get, set):Float;
	private var _newX:Float;
	private function get_newX():Float { return this._newX; }
	private function set_newX(value:Float):Float
	{
		if (this._newX == value)
		{
			return value;
		}
		this._newX = value;
		this._tween.animate("x", value);
		return this._newX;
	}
	
	/**
	 * @inheritDoc
	 */
	public var newY(get, set):Float;
	private var _newY:Float;
	private function get_newY():Float { return this._newY; }
	private function set_newY(value:Float):Float
	{
		if (this._newY == value)
		{
			return value;
		}
		this._newY = value;
		this._tween.animate("y", value);
		return this._newY;
	}
	
	/**
	 * @private
	 */
	override public function play():Void
	{
		if (Std.isOfType(this._target, IFeathersControl))
		{
			cast(this._target, IFeathersControl).suspendEffects();
		}
		this._target.x = this._oldX;
		this._target.y = this._oldY;
		if (Std.isOfType(this._target, IFeathersControl))
		{
			cast(this._target, IFeathersControl).resumeEffects();
		}
		super.play();
	}
	
}