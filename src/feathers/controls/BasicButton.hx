/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IValidating;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.touch.TapToTrigger;
import feathers.utils.touch.TouchToState;
import feathers.utils.type.SafeCast;
import openfl.geom.Point;
import feathers.core.IFeathersControl;
import starling.display.DisplayObject;

/**
 * A simple button control with states, but no content, that is useful for
 * purposes like skinning. For a more full-featured button, with a label and
 * icon, see <code>feathers.controls.Button</code> instead.
 *
 * @see feathers.controls.Button
 *
 * @productversion Feathers 3.0.0
 */
class BasicButton extends FeathersControl implements IStateContext
{
	/**
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();

	/**
	 * The default <code>IStyleProvider</code> for all <code>BasicButton</code>
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
		this.isQuickHitAreaEnabled = true;
	}
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return BasicButton.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var touchToState:TouchToState;
	
	/**
	 * @private
	 */
	private var tapToTrigger:TapToTrigger;
	
	/**
	 * The current state of the button.
	 *
	 * @see feathers.controls.ButtonState
	 * @see #event:stateChange feathers.events.FeathersEventType.STATE_CHANGE
	 */
	public var currentState(get, never):String;
	private var _currentState:String = ButtonState.UP;
	private function get_currentState():String { return this._currentState; }
	
	/**
	 * The currently visible skin. The value will be <code>null</code> if
	 * there is no currently visible skin.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var currentSkin:DisplayObject;
	
	
	override function set_isEnabled(value:Bool):Bool 
	{
		if (this._isEnabled == value)
		{
			return value;
		}
		super.isEnabled = value;
		if (this._isEnabled)
		{
			//might be in another state for some reason
			//let's only change to up if needed
			if (this._currentState == ButtonState.DISABLED)
			{
				this.changeState(ButtonState.UP);
			}
		}
		else
		{
			this.changeState(ButtonState.DISABLED);
		}
		return this._isEnabled;
	}
	
	/**
	 * @private
	 */
	public var keepDownStateOnRollOut(get, set):Bool;
	private var _keepDownStateOnRollOut:Bool = false;
	private function get_keepDownStateOnRollOut():Bool { return this._keepDownStateOnRollOut; }
	private function set_keepDownStateOnRollOut(value:Bool):Bool
	{
		if (this.processStyleRestriction("keepDownStateOnRollOut"))
		{
			return value;
		}
		if (this.touchToState != null)
		{
			this.touchToState.keepDownStateOnRollOut = value;
		}
		return this._keepDownStateOnRollOut = value;
	}
	
	
	public var defaultSkin(get, set):DisplayObject;
	private var _defaultSkin:DisplayObject;
	private function get_defaultSkin():DisplayObject { return this._defaultSkin; }
	private function set_defaultSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("defaultSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._defaultSkin == value)
		{
			return value;
		}
		if (this._defaultSkin != null &&
			this.currentSkin == this._defaultSkin)
		{
			//if this skin needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentSkin(this._defaultSkin);
			this.currentSkin = null;
		}
		this._defaultSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._defaultSkin;
	}
	
	/**
	 * @private
	 */
	public var upSkin(get, set):DisplayObject;
	private function get_upSkin():DisplayObject { return this.getSkinForState(ButtonState.UP); }
	private function set_upSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.UP, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var downSkin(get, set):DisplayObject;
	private function get_downSkin():DisplayObject { return this.getSkinForState(ButtonState.DOWN); }
	private function set_downSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.DOWN, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var hoverSkin(get, set):DisplayObject;
	private function get_hoverSkin():DisplayObject { return this.getSkinForState(ButtonState.HOVER); }
	private function set_hoverSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.HOVER, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var disabledSkin(get, set):DisplayObject;
	private function get_disabledSkin():DisplayObject { return this.getSkinForState(ButtonState.DISABLED); }
	private function set_disabledSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(ButtonState.DISABLED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	private var _stateToSkin:Map<String, DisplayObject> = new Map<String, DisplayObject>();
	
	/**
	 * @private
	 */
	private var _explicitSkinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitSkinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitSkinMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitSkinMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitSkinMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitSkinMaxHeight:Float;
	
	/**
	 * Gets the skin to be used by the button when its
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a skin is not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see #setSkinForState()
	 */
	public function getSkinForState(state:String):DisplayObject
	{
		return this._stateToSkin[state];
	}
	
	/**
	 * Sets the skin to be used by the button when its
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a skin is not defined for a specific state, the value of the
	 * <code>defaultSkin</code> property will be used instead.</p>
	 *
	 * @see #style:defaultSkin
	 * @see #getSkinForState()
	 * @see feathers.controls.ButtonState
	 */
	public function setSkinForState(state:String, skin:DisplayObject):Void
	{
		var key:String = "setSkinForState--" + state;
		if (this.processStyleRestriction(key))
		{
			if (skin != null)
			{
				skin.dispose();
			}
			return;
		}
		var oldSkin:DisplayObject = this._stateToSkin[state];
		if (oldSkin != null &&
			this.currentSkin == oldSkin)
		{
			//if this skin needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentSkin(oldSkin);
			this.currentSkin = null;
		}
		if (skin != null)
		{
			this._stateToSkin[state] = skin;
		}
		else
		{
			this._stateToSkin.remove(state);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void 
	{
		//we don't dispose it if the button is the parent because it'll
		//already get disposed in super.dispose()
		if (this._defaultSkin != null && this._defaultSkin.parent != this)
		{
			this._defaultSkin.dispose();
		}
		for (skin in this._stateToSkin)
		{
			if (skin != null && skin.parent != this)
			{
				skin.dispose();
			}
		}
		this._stateToSkin.clear();
		if (this.touchToState != null)
		{
			//setting the target to null will remove listeners and do any
			//other clean up that is needed
			this.touchToState.target = null;
		}
		if (this.tapToTrigger != null)
		{
			this.tapToTrigger.target = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void 
	{
		super.initialize();
		if (this.touchToState == null)
		{
			this.touchToState = new TouchToState(this, this.changeState);
		}
		this.touchToState.keepDownStateOnRollOut = this._keepDownStateOnRollOut;
		if (this.tapToTrigger == null)
		{
			this.tapToTrigger = new TapToTrigger(this);
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshTriggeredEvents();
			this.refreshSkin();
		}
		
		this.autoSizeIfNeeded();
		this.scaleSkin();
	}
	
	/**
	 * If the component's dimensions have not been set explicitly, it will
	 * measure its content and determine an ideal size for itself. If the
	 * <code>explicitWidth</code> or <code>explicitHeight</code> member
	 * variables are set, those value will be used without additional
	 * measurement. If one is set, but not the other, the dimension with the
	 * explicit value will not be measured, but the other non-explicit
	 * dimension will still need measurement.
	 *
	 * <p>Calls <code>saveMeasurements()</code> to set up the
	 * <code>actualWidth</code> and <code>actualHeight</code> member
	 * variables used for layout.</p>
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 */
	private function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitSkinWidth, this._explicitSkinHeight,
			this._explicitSkinMinWidth, this._explicitSkinMinHeight,
			this._explicitSkinMaxWidth, this._explicitSkinMaxHeight);
		var measureSkin:IMeasureDisplayObject = SafeCast.safe_cast(this.currentSkin, IMeasureDisplayObject);
		
		if (Std.isOfType(this.currentSkin, IValidating))
		{
			cast(this.currentSkin, IValidating).validate();
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (measureSkin != null)
			{
				newMinWidth = measureSkin.minWidth;
			}
			else if (this.currentSkin != null)
			{
				newMinWidth = this._explicitSkinMinWidth;
			}
			else
			{
				newMinWidth = 0;
			}
		}
		
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (measureSkin != null)
			{
				newMinHeight = measureSkin.minHeight;
			}
			else if (this.currentSkin != null)
			{
				newMinHeight = this._explicitSkinMinHeight;
			}
			else
			{
				newMinHeight = 0;
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (this.currentSkin != null)
			{
				newWidth = this.currentSkin.width;
			}
			else
			{
				newWidth = 0;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (this.currentSkin != null)
			{
				newHeight = this.currentSkin.height;
			}
			else
			{
				newHeight = 0;
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Sets the <code>currentSkin</code> property.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function refreshSkin():Void
	{
		var oldSkin:DisplayObject = this.currentSkin;
		this.currentSkin = this.getCurrentSkin();
		if (this.currentSkin != oldSkin)
		{
			this.removeCurrentSkin(oldSkin);
			if (this.currentSkin != null)
			{
				if (Std.isOfType(this.currentSkin, IFeathersControl))
				{
					cast(this.currentSkin, IFeathersControl).initializeNow();
				}
				if (Std.isOfType(this.currentSkin, IMeasureDisplayObject))
				{
					var measureSkin:IMeasureDisplayObject = cast this.currentSkin;
					this._explicitSkinWidth = measureSkin.explicitWidth;
					this._explicitSkinHeight = measureSkin.explicitHeight;
					this._explicitSkinMinWidth = measureSkin.explicitMinWidth;
					this._explicitSkinMinHeight = measureSkin.explicitMinHeight;
					this._explicitSkinMaxWidth = measureSkin.explicitMaxWidth;
					this._explicitSkinMaxHeight = measureSkin.explicitMaxHeight;
				}
				else
				{
					this._explicitSkinWidth = this.currentSkin.width;
					this._explicitSkinHeight = this.currentSkin.height;
					this._explicitSkinMinWidth = this._explicitSkinWidth;
					this._explicitSkinMinHeight = this._explicitSkinHeight;
					this._explicitSkinMaxWidth = this._explicitSkinWidth;
					this._explicitSkinMaxHeight = this._explicitSkinHeight;
				}
				if (Std.isOfType(this.currentSkin, IStateObserver))
				{
					cast(this.currentSkin, IStateObserver).stateContext = this;
				}
				this.addChildAt(this.currentSkin, 0);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function getCurrentSkin():DisplayObject
	{
		var result:DisplayObject = this._stateToSkin[this._currentState];
		if (result != null)
		{
			return result;
		}
		return this._defaultSkin;
	}
	
	/**
	 * @private
	 */
	private function scaleSkin():Void
	{
		if (this.currentSkin == null)
		{
			return;
		}
		this.currentSkin.x = 0;
		this.currentSkin.y = 0;
		if (this.currentSkin.width != this.actualWidth)
		{
			this.currentSkin.width = this.actualWidth;
		}
		if (this.currentSkin.height != this.actualHeight)
		{
			this.currentSkin.height = this.actualHeight;
		}
		if (Std.isOfType(this.currentSkin, IValidating))
		{
			cast(this.currentSkin, IValidating).validate();
		}
	}
	
	/**
	 * @private
	 */
	private function removeCurrentSkin(skin:DisplayObject):Void
	{
		if (skin == null)
		{
			return;
		}
		if (Std.isOfType(skin, IStateObserver))
		{
			cast(skin, IStateObserver).stateContext = null;
		}
		if (skin.parent == this)
		{
			//we need to restore these values so that they won't be lost the
			//next time that this skin is used for measurement
			skin.width = this._explicitSkinWidth;
			skin.height = this._explicitSkinHeight;
			if (Std.isOfType(skin, IMeasureDisplayObject))
			{
				var measureSkin:IMeasureDisplayObject = cast skin;
				measureSkin.minWidth = this._explicitSkinMinWidth;
				measureSkin.minHeight = this._explicitSkinMinHeight;
				measureSkin.maxWidth = this._explicitSkinMaxWidth;
				measureSkin.maxHeight = this._explicitSkinMaxHeight;
			}
			this.removeChild(skin, false);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTriggeredEvents():Void
	{
		this.tapToTrigger.isEnabled = this._isEnabled;
	}
	
	/**
	 * @private
	 */
	private function changeState(state:String):Void
	{
		if (!this._isEnabled)
		{
			state = ButtonState.DISABLED;
		}
		if (this._currentState == state)
		{
			return;
		}
		this._currentState = state;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		this.dispatchEventWith(FeathersEventType.STATE_CHANGE);
	}
	
}