/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.ToggleButton;
import openfl.errors.IllegalOperationError;

/**
 * A toggle control that contains a label and a box that may be checked
 * or not to indicate selection.
 *
 * <p>In the following example, a check is created and selected, and a
 * listener for <code>Event.CHANGE</code> is added:</p>
 *
 * <listing version="3.0">
 * var check:Check = new Check();
 * check.label = "Pick Me!";
 * check.isSelected = true;
 * check.addEventListener( Event.CHANGE, check_changeHandler );
 * this.addChild( check );</listing>
 *
 * @see ../../../help/check.html How to use the Feathers Check component
 * @see feathers.controls.ToggleSwitch
 *
 * @productversion Feathers 1.0.0
 */
class Check extends ToggleButton 
{
	/**
	 * The default value added to the <code>styleNameList</code> of the label.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-check-label";

	/**
	 * The default <code>IStyleProvider</code> for all <code>Check</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.labelStyleName = DEFAULT_CHILD_STYLE_NAME_LABEL;
		super.isToggle = true;
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return Check.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override function set_isToggle(value:Bool):Bool
	{
		throw new IllegalOperationError("CheckBox isToggle must always be true.");
	}
	
}