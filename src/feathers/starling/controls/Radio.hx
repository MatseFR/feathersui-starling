/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;
import feathers.starling.core.ToggleGroup;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.ToggleButton;
import openfl.errors.IllegalOperationError;
import starling.events.Event;

/**
 * A toggleable control that exists in a set that requires a single,
 * exclusive toggled item.
 *
 * <p>In the following example, a set of radios are created, along with a
 * toggle group to group them together:</p>
 *
 * <listing version="3.0">
 * var group:ToggleGroup = new ToggleGroup();
 * group.addEventListener( Event.CHANGE, group_changeHandler );
 * 
 * var radio1:Radio = new Radio();
 * radio1.label = "One";
 * radio1.toggleGroup = group;
 * this.addChild( radio1 );
 * 
 * var radio2:Radio = new Radio();
 * radio2.label = "Two";
 * radio2.toggleGroup = group;
 * this.addChild( radio2 );
 * 
 * var radio3:Radio = new Radio();
 * radio3.label = "Three";
 * radio3.toggleGroup = group;
 * this.addChild( radio3 );</listing>
 *
 * @see ../../../help/radio.html How to use the Feathers Radio component
 * @see feathers.core.ToggleGroup
 *
 * @productversion Feathers 1.0.0
 */
class Radio extends ToggleButton 
{
	/**
	 * The default value added to the <code>styleNameList</code> of the label.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-radio-label";

	/**
	 * If a <code>Radio</code> has not been added to a <code>ToggleGroup</code>,
	 * it will automatically be added to this group. If the Radio's
	 * <code>toggleGroup</code> property is set to a different group, it
	 * will be automatically removed from this group, if required.
	 */
	public static var defaultRadioGroup:ToggleGroup = new ToggleGroup();

	/**
	 * The default <code>IStyleProvider</code> for all <code>Radio</code>
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
		super.isToggle = true;
		this.labelStyleName = DEFAULT_CHILD_STYLE_NAME_LABEL;
		this.addEventListener(Event.ADDED_TO_STAGE, radio_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, radio_removedFromStageHandler);
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Radio.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override function set_isToggle(value:Bool):Bool 
	{
		throw new IllegalOperationError("Radio isToggle must always be true.");
	}
	
	/**
	 * @private
	 */
	override function set_toggleGroup(value:ToggleGroup):ToggleGroup 
	{
		if (this._toggleGroup == value)
		{
			return value;
		}
		//a null toggle group will automatically add it to
		//defaultRadioGroup. however, if toggleGroup is already
		//defaultRadioGroup, then we really want to use null because
		//otherwise we'd remove the radio from defaultRadioGroup and then
		//immediately add it back because ToggleGroup sets the toggleGroup
		//property to null when removing an item.
		if (value == null && this._toggleGroup != defaultRadioGroup && this.stage != null)
		{
			value = defaultRadioGroup;
		}
		return super.set_toggleGroup(value);
	}
	
	/**
	 * @private
	 */
	private function radio_addedToStageHandler(event:Event):Void
	{
		if (this._toggleGroup == null)
		{
			this.toggleGroup = defaultRadioGroup;
		}
	}

	/**
	 * @private
	 */
	private function radio_removedFromStageHandler(event:Event):Void
	{
		if (this._toggleGroup == defaultRadioGroup)
		{
			this._toggleGroup.removeItem(this);
		}
	}
	
}