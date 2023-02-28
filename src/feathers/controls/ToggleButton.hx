/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.core.FeathersControl;
import feathers.core.IGroupedToggle;
import feathers.core.ToggleGroup;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.keyboard.KeyToSelect;
import feathers.utils.touch.TapToSelect;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.text.TextFormat;

/**
 * A button that may be selected and deselected when triggered.
 *
 * <p>The following example creates a toggle button, and listens for when
 * its selection changes:</p>
 *
 * <listing version="3.0">
 * var button:ToggleButton = new ToggleButton();
 * button.label = "Click Me";
 * button.addEventListener( Event.CHANGE, button_changeHandler );
 * this.addChild( button );</listing>
 *
 * @see ../../../help/toggle-button.html How to use the Feathers ToggleButton component
 *
 * @productversion Feathers 2.0.0
 */
class ToggleButton extends Button implements IGroupedToggle
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>ToggleButton</code>
	 * components. If <code>null</code>, falls back to using
	 * <code>Button.globalStyleProvider</code> instead.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 * @see feathers.controls.Button#globalStyleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		if (ToggleButton.globalStyleProvider != null)
		{
			return ToggleButton.globalStyleProvider;
		}
		return Button.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override function get_currentState():String 
	{
		if (this._isSelected)
		{
			return super.currentState + "AndSelected";
		}
		return super.get_currentState();
	}
	
	/**
	 * @private
	 */
	private var tapToSelect:TapToSelect;

	/**
	 * @private
	 */
	private var keyToSelect:KeyToSelect;

	/**
	 * @private
	 */
	private var dpadEnterKeyToSelect:KeyToSelect;
	
	/**
	 * Determines if the button may be selected or deselected as a result of
	 * user interaction. If <code>true</code>, the value of the
	 * <code>isSelected</code> property will be toggled when the button is
	 * triggered.
	 *
	 * <p>The following example disables the ability to toggle:</p>
	 *
	 * <listing version="3.0">
	 * button.isToggle = false;</listing>
	 *
	 * @default true
	 *
	 * @see #isSelected
	 * @see #event:triggered Event.TRIGGERED
	 */
	public var isToggle(get, set):Bool;
	private var _isToggle:Bool = true;
	private function get_isToggle():Bool { return this._isToggle; }
	private function set_isToggle(value:Bool):Bool
	{
		if (this._isToggle == value)
		{
			return value;
		}
		this._isToggle = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._isToggle;
	}
	
	/**
	 * Indicates if the button is selected or not. The button may be
	 * selected programmatically, even if <code>isToggle</code> is <code>false</code>,
	 * but generally, <code>isToggle</code> should be set to <code>true</code>
	 * to allow the user to select and deselect it by triggering the button
	 * with a click or tap. If focus management is enabled, a button may
	 * also be triggered with the spacebar when the button has focus.
	 *
	 * <p>The following example enables the button to toggle and selects it
	 * automatically:</p>
	 *
	 * <listing version="3.0">
	 * button.isToggle = true;
	 * button.isSelected = true;</listing>
	 *
	 * <p><strong>Warning:</strong> Do not listen to
	 * <code>Event.TRIGGERED</code> to be notified when the
	 * <code>isSelected</code> property changes. You must listen to
	 * <code>Event.CHANGE</code>.</p>
	 *
	 * @default false
	 *
	 * @see #event:change Event.CHANGE
	 * @see #isToggle
	 */
	public var isSelected(get, set):Bool;
	private var _isSelected:Bool = false;
	private function get_isSelected():Bool { return this._isSelected; }
	private function set_isSelected(value:Bool):Bool
	{
		if (this._isSelected == value)
		{
			return value;
		}
		this._isSelected = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(FeathersEventType.STATE_CHANGE);
		return this._isSelected;
	}
	
	/**
	 * @inheritDoc
	 */
	public var toggleGroup(get, set):ToggleGroup;
	private var _toggleGroup:ToggleGroup;
	private function get_toggleGroup():ToggleGroup { return this._toggleGroup; }
	private function set_toggleGroup(value:ToggleGroup):ToggleGroup
	{
		if (this._toggleGroup == value)
		{
			return value;
		}
		if (this._toggleGroup != null && this._toggleGroup.hasItem(this))
		{
			this._toggleGroup.removeItem(this);
		}
		this._toggleGroup = value;
		if (this._toggleGroup != null && !this._toggleGroup.hasItem(this))
		{
			this._toggleGroup.addItem(this);
		}
		return this._toggleGroup;
	}
	
	/**
	 * @private
	 */
	public var defaultSelectedSkin(get, set):DisplayObject;
	private var _defaultSelectedSkin:DisplayObject;
	private function get_defaultSelectedSkin():DisplayObject { return this._defaultSelectedSkin; }
	private function set_defaultSelectedSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("defaultSelectedSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._defaultSelectedSkin == value)
		{
			return value;
		}
		if (this._defaultSelectedSkin != null &&
			this.currentSkin == this._defaultSelectedSkin)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentSkin(this._defaultSelectedSkin);
			this.currentSkin = null;
		}
		this._defaultSelectedSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._defaultSelectedSkin;
	}
	
	/**
	 * @private
	 */
	public var selectedUpSkin(get, set):DisplayObject;
	private function get_selectedUpSkin():DisplayObject { return this.getSkinForState(ButtonState.UP_AND_SELECTED); }
	private function set_selectedUpSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.UP_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var selectedDownSkin(get, set):DisplayObject;
	private function get_selectedDownSkin():DisplayObject { return this.getSkinForState(ButtonState.DOWN_AND_SELECTED); }
	private function set_selectedDownSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.DOWN_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var selectedHoverSkin(get, set):DisplayObject;
	private function get_selectedHoverSkin():DisplayObject { return this.getSkinForState(ButtonState.HOVER_AND_SELECTED); }
	private function set_selectedHoverSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.HOVER_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * 
	 */
	public var selectedDisabledSkin(get, set):DisplayObject;
	private function get_selectedDisabledSkin():DisplayObject { return this.getSkinForState(ButtonState.DISABLED_AND_SELECTED); }
	private function set_selectedDisabledSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.DISABLED_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var selectedFontStyles(get, set):TextFormat;
	private function get_selectedFontStyles():TextFormat { return this._fontStylesSet.selectedFormat; }
	private function set_selectedFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("selectedFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("selectedFontStyles");
		}
		
		var oldValue:TextFormat = this._fontStylesSet.selectedFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.selectedFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var defaultSelectedIcon(get, set):DisplayObject;
	private var _defaultSelectedIcon:DisplayObject;
	private function get_defaultSelectedIcon():DisplayObject { return this._defaultSelectedIcon; }
	private function set_defaultSelectedIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("defaultSelectedIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._defaultSelectedIcon == value)
		{
			return value;
		}
		if (this._defaultSelectedIcon != null &&
			this.currentIcon == this._defaultSelectedIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentIcon(this._defaultSelectedIcon);
			this.currentIcon = null;
		}
		this._defaultSelectedIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._defaultSelectedIcon;
	}
	
	/**
	 * @private
	 */
	public var selectedUpIcon(get, set):DisplayObject;
	private function get_selectedUpIcon():DisplayObject { return this.getIconForState(ButtonState.UP_AND_SELECTED); }
	private function set_selectedUpIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.UP_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var selectedDownIcon(get, set):DisplayObject;
	private function get_selectedDownIcon():DisplayObject { return this.getIconForState(ButtonState.DOWN_AND_SELECTED); }
	private function set_selectedDownIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.DOWN_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var selectedHoverIcon(get, set):DisplayObject;
	private function get_selectedHoverIcon():DisplayObject { return this.getIconForState(ButtonState.HOVER_AND_SELECTED); }
	private function set_selectedHoverIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.HOVER_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var selectedDisabledIcon(get, set):DisplayObject;
	private function get_selectedDisabledIcon():DisplayObject { return this.getIconForState(ButtonState.DISABLED_AND_SELECTED); }
	private function set_selectedDisabledIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.DISABLED_AND_SELECTED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var scaleWhenSelected(get, set):Float;
	private var _scaleWhenSelected:Float = 1;
	private function get_scaleWhenSelected():Float { return this._scaleWhenSelected; }
	private function set_scaleWhenSelected(value:Float):Float
	{
		if (this.processStyleRestriction("scaleWhenSelected"))
		{
			return value;
		}
		if (this._scaleWhenSelected == value)
		{
			return value;
		}
		return this._scaleWhenSelected = value;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._defaultSelectedSkin != null && this._defaultSelectedSkin.parent != this)
		{
			this._defaultSelectedSkin.dispose();
		}
		if (this._defaultSelectedIcon != null && this._defaultSelectedIcon.parent != this)
		{
			this._defaultSelectedIcon.dispose();
		}
		if (this.keyToSelect != null)
		{
			//setting the target to null will remove listeners and do any
			//other clean up that is needed
			this.keyToSelect.target = null;
		}
		if (this.dpadEnterKeyToSelect != null)
		{
			this.dpadEnterKeyToSelect.target = null;
		}
		if (this.tapToSelect != null)
		{
			this.tapToSelect.target = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		super.initialize();
		if (this.tapToSelect == null)
		{
			this.tapToSelect = new TapToSelect(this);
			this.longPress.tapToSelect = this.tapToSelect;
		}
		if (this.keyToSelect == null)
		{
			this.keyToSelect = new KeyToSelect(this);
		}
		if (this.dpadEnterKeyToSelect == null)
		{
			this.dpadEnterKeyToSelect = new KeyToSelect(this, Keyboard.ENTER);
			this.dpadEnterKeyToState.keyLocation = 4; //KeyLocation.D_PAD is only in AIR
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshSelectionEvents();
		}
		
		super.draw();
	}
	
	/**
	 * @private
	 */
	override function getCurrentSkin():DisplayObject
	{
		//we use the currentState getter here instead of the variable
		//because the variable does not keep track of the selection
		var result:DisplayObject = this._stateToSkin[this.currentState];
		if (result != null)
		{
			return result;
		}
		if (this._isSelected && this._defaultSelectedSkin != null)
		{
			return this._defaultSelectedSkin;
		}
		return this._defaultSkin;
	}
	
	/**
	 * @private
	 */
	override function getCurrentIcon():DisplayObject
	{
		//we use the currentState getter here instead of the variable
		//because the variable does not keep track of the selection
		var result:DisplayObject = this._stateToIcon[this.currentState];
		if (result != null)
		{
			return result;
		}
		if (this._isSelected && this._defaultSelectedIcon != null)
		{
			return this._defaultSelectedIcon;
		}
		return this._defaultIcon;
	}
	
	/**
	 * @private
	 */
	override function getScaleForCurrentState(state:String = null):Float
	{
		if (state == null)
		{
			state = this.currentState;
		}
		if (this._stateToScale.exists(state))
		{
			return this._stateToScale[state];
		}
		else if (this._isSelected)
		{
			return this._scaleWhenSelected;
		}
		return 1;
	}
	
	/**
	 * @private
	 */
	private function refreshSelectionEvents():Void
	{
		this.tapToSelect.isEnabled = this._isEnabled && this._isToggle;
		this.tapToSelect.tapToDeselect = this._isToggle;
		this.keyToSelect.isEnabled = this._isEnabled && this._isToggle;
		this.keyToSelect.keyToDeselect = this._isToggle;
		this.dpadEnterKeyToSelect.isEnabled = this._isEnabled && this._isToggle;
		this.dpadEnterKeyToSelect.keyToDeselect = this._isToggle;
	}
	
}