/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.motion.effectClasses;

import feathers.starling.core.IFeathersControl;
import starling.animation.Tween;
import starling.display.DisplayObject;

/**
 * A resize effect context for a <code>starling.animation.Tween</code>.
 *
 * @see ../../../help/effects.html Effects and animation for Feathers components
 * @see http://doc.starling-framework.org/core/starling/animation/Tween.html starling.animation.Tween
 * @see feathers.core.FeathersControl#resizeEffect
 *
 * @productversion Feathers 3.5.0
 */
class TweenResizeEffectContext extends TweenEffectContext implements IResizeEffectContext
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject, tween:Tween) 
	{
		super(target, tween, interruptBehavior);
		
	}
	
	/**
	 * @inheritDoc
	 */
	public var oldWidth(get, set):Float;
	private var _oldWidth:Float;
	private function get_oldWidth():Float { return this._oldWidth; }
	private function set_oldWidth(value:Float):Float
	{
		return this._oldWidth = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var oldHeight(get, set):Float;
	private var _oldHeight:Float;
	private function get_oldHeight():Float { return this._oldHeight; }
	private function set_oldHeight(value:Float):Float
	{
		return this._oldHeight = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var newWidth(get, set):Float;
	private var _newWidth:Float;
	private function get_newWidth():Float { return this._newWidth; }
	private function set_newWidth(value:Float):Float
	{
		if (this._newWidth == value)
		{
			return value;
		}
		this._newWidth = value;
		this._tween.animate("width", value);
		return this._newWidth;
	}
	
	/**
	 * @inheritDoc
	 */
	public var newHeight(get, set):Float;
	private var _newHeight:Float;
	private function get_newHeight():Float { return this._newHeight; }
	private function set_newHeight(value:Float):Float
	{
		if (this._newHeight == value)
		{
			return value;
		}
		this._newHeight = value;
		this._tween.animate("height", value);
		return this._newHeight;
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
		this._target.width = this._oldWidth;
		this._target.height = this._oldHeight;
		if (Std.isOfType(this._target, IFeathersControl))
		{
			cast(this._target, IFeathersControl).resumeEffects();
		}
		super.play();
	}
	
}