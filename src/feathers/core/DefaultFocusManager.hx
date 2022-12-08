/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;

import feathers.events.FeathersEventType;
import openfl.display.InteractiveObject;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.FocusEvent;
import openfl.events.IEventDispatcher;
import openfl.events.KeyboardEvent;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.TouchEvent;

/**
 * The default <code>IFocusManager</code> implementation. This focus
 * manager is designed to work on both desktop and mobile. Focus may be
 * controlled by <code>Keyboard.TAB</code> (including going
 * backwards when holding the shift key) or with the arrow keys on a d-pad
 * (such as those that appear on a smart TV remote control and some game
 * controllers).
 *
 * <p>To simulate <code>KeyLocation.D_PAD</code> in the AIR Debug
 * Launcher on desktop for debugging purposes, set
 * <code>DeviceCapabilities.simulateDPad</code> to <code>true</code>.</p>
 *
 * @see ../../../help/focus.html Keyboard focus management in Feathers
 * @see feathers.core.FocusManager
 *
 * @productversion Feathers 2.0.0
 */
class DefaultFocusManager extends EventDispatcher implements IFocusManager
{
	/**
	   @private
	**/
	private static var NATIVE_STAGE_TO_FOCUS_TARGET:Map<Stage, NativeFocusTarget> = new Map<Stage, NativeFocusTarget>();

	/**
	   Constructor.
	**/
	public function new(root:DisplayObjectContainer)
	{
		super();
		if (root.stage == null)
		{
			throw new ArgumentError("Focus manager root must be added to the stage.");
		}
		this._root = root;
		this._starling = root.stage.starling;
	}

	/**
	   @private
	**/
	private var _starling:Starling;

	/**
	   @private
	**/
	private var _nativeFocusTarget:NativeFocusTarget;

	/**
	 * @inheritDoc
	 */
	public var root(get, never):DisplayObjectContainer;
	private var _root:DisplayObjectContainer;
	private function get_root():DisplayObjectContainer { return this._root; }

	/**
	 * @inheritDoc
	 *
	 * @default false
	 */
	public var isEnabled(get, set):Bool;
	private var _isEnabled:Bool = false;
	private function get_isEnabled():Bool { return this._isEnabled; }
	private function set_isEnabled(value:Bool):Bool
	{
		if (this._isEnabled == value)
		{
			return value;
		}
		this._isEnabled = value;
		if (this._isEnabled)
		{
			this._nativeFocusTarget = NATIVE_STAGE_TO_FOCUS_TARGET[this._starling.nativeStage];
			if (this._nativeFocusTarget == null)
			{
				this._nativeFocusTarget = new NativeFocusTarget();
				//we must add it directly to the nativeStage because
				//otherwise, the skipUnchangedFrames property won't work
				this._starling.nativeStage.addChild(_nativeFocusTarget);
			}
			else
			{
				this._nativeFocusTarget.referenceCount++;
			}
			//since we weren't listening for objects being added while the
			//focus manager was disabled, we need to do it now in case there
			//are new ones.
			this.setFocusManager(this._root);
			this._root.addEventListener(Event.ADDED, topLevelContainer_addedHandler);
			this._root.addEventListener(Event.REMOVED, topLevelContainer_removedHandler);
			this._root.addEventListener(TouchEvent.TOUCH, topLevelContainer_touchHandler);
			this._starling.nativeStage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, stage_keyFocusChangeHandler, false, 0, true);
			this._starling.nativeStage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, stage_mouseFocusChangeHandler, false, 0, true);
			this._starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler, false, 0, true);
			//TransformGestureEvent.GESTURE_DIRECTIONAL_TAP requires
			//AIR 24, but we want to support older versions too
			this._starling.nativeStage.addEventListener("gestureDirectionalTap", stage_gestureDirectionalTapHandler, false, 0, true);
			if (this._savedFocus && !this._savedFocus.stage)
			{
				this._savedFocus = null;
			}
			this.focus = this._savedFocus;
			this._savedFocus = null;
		}
		else
		{
			this._nativeFocusTarget.referenceCount--;
			if (this._nativeFocusTarget.referenceCount <= 0)
			{
				this._nativeFocusTarget.parent.removeChild(this._nativeFocusTarget);
				NATIVE_STAGE_TO_FOCUS_TARGET.remove(this._starling.nativeStage];
			}
			this._nativeFocusTarget = null;
			this._root.removeEventListener(Event.ADDED, topLevelContainer_addedHandler);
			this._root.removeEventListener(Event.REMOVED, topLevelContainer_removedHandler);
			this._root.removeEventListener(TouchEvent.TOUCH, topLevelContainer_touchHandler);
			this._starling.nativeStage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, stage_keyFocusChangeHandler);
			this._starling.nativeStage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, stage_mouseFocusChangeHandler);
			this._starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			this._starling.nativeStage.removeEventListener("gestureDirectionalTap", stage_gestureDirectionalTapHandler);
			var focusToSave:IFocusDisplayObject = this.focus;
			this.focus = null;
			this._savedFocus = focusToSave;
		}
	}
	
	/**
	   @private
	**/
	private var _savedFocus:IFocusDisplayObject;
	
	/**
	 * @inheritDoc
	 *
	 * @default null
	 */
	public var focus(get, set):IFocusDisplayObject;
	private var _focus:IFocusDisplayObject;
	private function get_focus():IFocusDisplayObject { return this._focus; }
	private function set_focus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (this._focus == value)
		{
			return value;
		}
		var shouldHaveFocus:Bool = false;
		var oldFocus:IFeathersDisplayObject = this._focus;
		if (this._isEnabled && value != null && value.isFocusEnabled && value.focusManager == this)
		{
			this._focus = value;
			shouldHaveFocus = true;
		}
		else
		{
			this._focus = null;
		}
		var nativeStage:Stage = this._starling.nativeStage;
		if (Std.isOfType(oldFocus, INativeFocusOwner))
		{
			var nativeFocus:Dynamic = cast(oldFocus, INativeFocusOwner).nativeFocus;
			if (nativeFocus == null && nativeStage != null)
			{
				nativeFocus = nativeStage.focus;
			}
			if (Std.isOfType(nativeFocus, IEventDispatcher))
			{
				//this listener restores focus, if it is lost in a way that
				//is out of our control. since we may be manually removing
				//focus in a listener for FeathersEventType.FOCUS_OUT, we
				//don't want it to restore focus.
				cast(nativeFocus, IEventDispatcher).removeEventListener(FocusEvent.FOCUS_OUT, nativeFocus_focusOutHandler);
			}
		}
		if (oldFocus != null)
		{
			//this event should be dispatched after setting the new value of
			//_focus because we want to be able to access the value of the
			//focus property in the event listener.
			oldFocus.dispatchEventWith(FeathersEventType.FOCUS_OUT);
		}
		if (shouldHaveFocus && this._focus != value)
		{
			//this shouldn't happen, but if it does, let's not break the
			//current state even more by referencing an old focused object.
			return;
		}
		if (this._isEnabled)
		{
			if (this._focus != null)
			{
				nativeFocus = null;
				if (Std.isOfType(this._focus, INativeFocusOwner)
				{
					nativeFocus = cast(this._focus, INativeFocusOwner).nativeFocus;
					if (Std.isOfType(nativeFocus, InteractiveObject))
					{
						nativeStage.focus = cast nativeFocus;
					}
					else if (nativeFocus != null)
					{
						if (Std.isOfType(this._focus, IAdvancedNativeFocusOwner))
						{
							var advancedFocus:IAdvancedNativeFocusOwner = cast this._focus;
							if (!advancedFocus.hasFocus)
							{
								//let the focused component handle giving focus to
								//its nativeFocus because it may have a custom API
								advancedFocus.setFocus();
							}
						}
						else
						{
							throw new IllegalOperationError("If nativeFocus does not return an InteractiveObject, class must implement IAdvancedNativeFocusOwner interface");
						}
					}
				}
				//an INativeFocusOwner may return null for its
				//nativeFocus property, so we still need to double-check
				//that the native stage has something in focus. that's
				//why there isn't an else here
				if (nativeFocus == null)
				{
					nativeFocus = this._nativeFocusTarget;
					nativeStage.focus = this._nativeFocusTarget;
				}
				if (Std.isOfType(nativeFocus, IEventDispatcher))
				{
					cast(nativeFocus, IEventDispatcher).addEventListener(FocusEvent.FOCUS_OUT, nativeFocus_focusOutHandler, false, 0, true);
				}
				this._focus.dispatchEventWith(FeathersEventType.FOCUS_IN);
			}
			else
			{
				nativeStage.focus = null;
			}
		}
		else
		{
			this._savedFocus = value;
		}
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	   @private
	**/
	private function setFocusManager(target:DisplayObject):Void
	{
		if (Std.isOfType(target, IFocusDisplayObject)
		{
			var targetWithFocus:IFocusDisplayObject = cast target;
			targetWithFocus.focusManager = this;
		}
		if ((Std.isOfType(target, DisplayObjectContainer) && !Std.isOfType(target, IFocusDisplayObject)) ||
			(Std.isOfType(target, IFocusContainer) && cast(target, IFocusContainer).isChildFocusEnabled))
		{
			var container:DisplayObjectContainer = cast target;
			var childCount:Int = container.numChildren;
			for (i in 0...childCount)
			{
				var child:DisplayObject = container.getChildAt(i);
				this.setFocusManager(child);
			}
			if (Std.isOfType(container, IFocusExtras))
			{
				var containerWithExtras:IFocusExtras = cast container;
				var extras:Array<DisplayObject> = containerWithExtras.focusExtrasBefore;
				if (extras != null)
				{
					childCount = extras.length;
					for (i in 0...childCount)
					{
						child = extras[i];
						this.setFocusManager(child);
					}
				}
				extras = containerWithExtras.focusExtrasAfter;
				if (extras != null)
				{
					childCount = extras.length;
					for (i in 0...childCount)
					{
						child = extras[i];
						this.setFocusManager(child);
					}
				}
			}
		}
	}
	
	/**
	   @private
	**/
	private function clearFocusManager(target:DisplayObject):Void
	{
		if (Std.isOfType(target, IFocusDisplayObject))
		{
			var targetWithFocus:IFocusDisplayObject = cast target;
			if (targetWithFocus.focusManager == this)
			{
				if (this._focus == targetWithFocus)
				{
					//change to focus owner, which falls back to null
					this.focus = targetWithFocus.focusOwner;
				}
				targetWithFocus.focusManager = null;
			}
		}
		if (Std.isOfType(target, DisplayObjectContainer))
		{
			var container:DisplayObjectContainer = cast target;
			var childCount:Int = container.numChildren;
			for (i in 0...childCount)
			{
				var child:DisplayObject = container.getChildAt(i);
				this.clearFocusManager(child);
			}
			if (Std.isOfType(container, IFocusExtras)
			{
				var containerWithExtras:IFocusExtras = cast container;
				var extras:Array<DisplayObject> = containerWithExtras.focusExtrasBefore;
				if (extras != null)
				{
					childCount = extras.length;
					for (i in 0...childCount)
					{
						child = extras[i];
						this.clearFocusManager(child);
					}
				}
				extras = containerWithExtras.focusExtrasAfter;
				if (extras != null)
				{
					childCount = extras.length;
					for (i in 0...childCount)
					{
						child = extras[i];
						this.clearFocusManager(child);
					}
				}
			}
		}
	}
	
	/**
	   @private
	**/
	private function findPreviousContainerFocus(container:DisplayObjectContainer, beforeChild:DisplayObject, fallbackToGlobal:Bool):IFocusDisplayObject
	{
		if (Std.isOfType(container, 
	}

}

import openfl.display.Sprite;

class NativeFocusTarget extends Sprite
{
	public function new()
	{
		super();
		this.tabEnabled = true;
		this.mouseEnabled = false;
		this.mouseChildren = false;
		this.alpha = 0;
	}

	public var referenceCount:Int = 1;
}