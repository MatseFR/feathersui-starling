/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;

import feathers.starling.core.IAdvancedNativeFocusOwner;
import feathers.starling.core.IFeathersDisplayObject;
import feathers.starling.core.IFocusContainer;
import feathers.starling.core.IFocusDisplayObject;
import feathers.starling.core.IFocusExtras;
import feathers.starling.core.IFocusManager;
import feathers.starling.core.INativeFocusOwner;
import openfl.Lib;
import feathers.starling.controls.supportClasses.LayoutViewPort;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.RelativePosition;
import feathers.starling.system.DeviceCapabilities;
import feathers.starling.utils.ReverseIterator;
import feathers.starling.utils.focus.FocusUtils;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.FocusEvent;
import openfl.events.IEventDispatcher;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.system.Capabilities;
import openfl.ui.KeyLocation;
import openfl.ui.Keyboard;
import feathers.starling.core.IFeathersControl;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

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
			// TODO : openfl has no TransformGestureEvent
			//this._starling.nativeStage.addEventListener("gestureDirectionalTap", stage_gestureDirectionalTapHandler, false, 0, true);
			if (this._savedFocus != null && this._savedFocus.stage == null)
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
				NATIVE_STAGE_TO_FOCUS_TARGET.remove(this._starling.nativeStage);
			}
			this._nativeFocusTarget = null;
			this._root.removeEventListener(Event.ADDED, topLevelContainer_addedHandler);
			this._root.removeEventListener(Event.REMOVED, topLevelContainer_removedHandler);
			this._root.removeEventListener(TouchEvent.TOUCH, topLevelContainer_touchHandler);
			this._starling.nativeStage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, stage_keyFocusChangeHandler);
			this._starling.nativeStage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, stage_mouseFocusChangeHandler);
			this._starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			// TODO : openfl has no TransformGestureEvent
			//this._starling.nativeStage.removeEventListener("gestureDirectionalTap", stage_gestureDirectionalTapHandler);
			var focusToSave:IFocusDisplayObject = this.focus;
			this.focus = null;
			this._savedFocus = focusToSave;
		}
		return this._isEnabled;
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
		var nativeFocus:Dynamic;
		if (Std.isOfType(oldFocus, INativeFocusOwner))
		{
			nativeFocus = cast(oldFocus, INativeFocusOwner).nativeFocus;
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
			return value;
		}
		if (this._isEnabled)
		{
			if (this._focus != null)
			{
				nativeFocus = null;
				if (Std.isOfType(this._focus, INativeFocusOwner))
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
		
		// DEBUG
		//trace("Focus change for " + this._root + " from " + oldFocus + " to " + this._focus);
		//\DEBUG
		
		return this._focus;
	}
	
	/**
	   @private
	**/
	private function setFocusManager(target:DisplayObject):Void
	{
		if (Std.isOfType(target, IFocusDisplayObject))
		{
			var targetWithFocus:IFocusDisplayObject = cast target;
			targetWithFocus.focusManager = this;
		}
		if ((Std.isOfType(target, DisplayObjectContainer) && !Std.isOfType(target, IFocusDisplayObject)) ||
			(Std.isOfType(target, IFocusContainer) && cast(target, IFocusContainer).isChildFocusEnabled))
		{
			var container:DisplayObjectContainer = cast target;
			var child:DisplayObject;
			var childCount:Int = container.numChildren;
			for (i in 0...childCount)
			{
				child = container.getChildAt(i);
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
			var child:DisplayObject;
			for (i in 0...childCount)
			{
				child = container.getChildAt(i);
				this.clearFocusManager(child);
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
		if (Std.isOfType(container, LayoutViewPort))
		{
			container = container.parent;
		}
		var hasProcessedBeforeChild:Bool = beforeChild == null;
		var startIndex:Int;
		var child:DisplayObject;
		var foundChild:IFocusDisplayObject;
		var extras:Array<DisplayObject>;
		var focusWithExtras:IFocusExtras = null;
		var skip:Bool = false;
		if (Std.isOfType(container, IFocusExtras))
		{
			focusWithExtras = cast container;
			extras = focusWithExtras.focusExtrasAfter;
			if (extras != null)
			{
				if (beforeChild != null)
				{
					startIndex = extras.indexOf(beforeChild) - 1;
					hasProcessedBeforeChild = startIndex >= -1;
					skip = !hasProcessedBeforeChild;
				}
				else
				{
					startIndex = extras.length - 1;
				}
				if (!skip)
				{
					for (i in new ReverseIterator(startIndex, 0))
					{
						child = extras[i];
						foundChild = this.findPreviousChildFocus(child);
						if (this.isValidFocus(foundChild))
						{
							return foundChild;
						}
					}
				}
			}
		}
		if (beforeChild != null && !hasProcessedBeforeChild)
		{
			startIndex = container.getChildIndex(beforeChild) - 1;
			hasProcessedBeforeChild = startIndex >= -1;
		}
		else
		{
			startIndex = container.numChildren - 1;
		}
		for (i in new ReverseIterator(startIndex, 0))
		{
			child = container.getChildAt(i);
			foundChild = this.findPreviousChildFocus(child);
			if (this.isValidFocus(foundChild))
			{
				return foundChild;
			}
		}
		if (Std.isOfType(container, IFocusExtras))
		{
			extras = focusWithExtras.focusExtrasBefore;
			if (extras != null)
			{
				skip = false;
				if (beforeChild != null && !hasProcessedBeforeChild)
				{
					startIndex = extras.indexOf(beforeChild) - 1;
					hasProcessedBeforeChild = startIndex >= -1;
					skip = !hasProcessedBeforeChild;
				}
				else
				{
					startIndex = extras.length - 1;
				}
				if (!skip)
				{
					for (i in new ReverseIterator(startIndex, 0))
					{
						child = extras[i];
						foundChild = this.findPreviousChildFocus(child);
						if (this.isValidFocus(foundChild))
						{
							return foundChild;
						}
					}
				}
			}
		}
		
		if (fallbackToGlobal && container != this._root)
		{
			//try the container itself before moving backwards
			if (Std.isOfType(container, IFocusDisplayObject))
			{
				var focusContainer:IFocusDisplayObject = cast container;
				if (this.isValidFocus(focusContainer))
				{
					return focusContainer;
				}
			}
			return this.findPreviousContainerFocus(container.parent, container, true);
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private function findNextContainerFocus(container:DisplayObjectContainer, afterChild:DisplayObject, fallbackToGlobal:Bool):IFocusDisplayObject
	{
		if (Std.isOfType(container, LayoutViewPort))
		{
			container = container.parent;
		}
		var hasProcessedAfterChild:Bool = afterChild == null;
		var startIndex:Int;
		var childCount:Int;
		var child:DisplayObject;
		var foundChild:IFocusDisplayObject;
		var focusWithExtras:IFocusExtras = null;
		var extras:Array<DisplayObject>;
		var skip:Bool;
		if (Std.isOfType(container, IFocusExtras))
		{
			focusWithExtras = cast container;
			extras = focusWithExtras.focusExtrasBefore;
			if (extras != null)
			{
				skip = false;
				if (afterChild != null)
				{
					startIndex = extras.indexOf(afterChild) + 1;
					hasProcessedAfterChild = startIndex > 0;
					skip = !hasProcessedAfterChild;
				}
				else
				{
					startIndex = 0;
				}
				if (!skip)
				{
					childCount = extras.length;
					for (i in startIndex...childCount)
					{
						child = extras[i];
						foundChild = this.findNextChildFocus(child);
						if (this.isValidFocus(foundChild))
						{
							return foundChild;
						}
					}
				}
			}
		}
		if (afterChild != null && !hasProcessedAfterChild)
		{
			startIndex = container.getChildIndex(afterChild) + 1;
			hasProcessedAfterChild = startIndex > 0;
		}
		else
		{
			startIndex = 0;
		}
		childCount = container.numChildren;
		for (i in startIndex...childCount)
		{
			child = container.getChildAt(i);
			foundChild = this.findNextChildFocus(child);
			if (this.isValidFocus(foundChild))
			{
				return foundChild;
			}
		}
		if (Std.isOfType(container, IFocusExtras))
		{
			extras = focusWithExtras.focusExtrasAfter;
			if (extras != null)
			{
				skip = false;
				if (afterChild != null && !hasProcessedAfterChild)
				{
					startIndex = extras.indexOf(afterChild) + 1;
					hasProcessedAfterChild = startIndex > 0;
					skip = !hasProcessedAfterChild;
				}
				else
				{
					startIndex = 0;
				}
				if (!skip)
				{
					childCount = extras.length;
					for (i in startIndex...childCount)
					{
						child = extras[i];
						foundChild = this.findNextChildFocus(child);
						if (this.isValidFocus(foundChild))
						{
							return foundChild;
						}
					}
				}
			}
		}
		
		if (fallbackToGlobal && container != this._root)
		{
			return this.findNextContainerFocus(container.parent, container, true);
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private function findPreviousChildFocus(child:DisplayObject):IFocusDisplayObject
	{
		if ((Std.isOfType(child, DisplayObjectContainer) && !Std.isOfType(child, IFocusDisplayObject)) ||
			(Std.isOfType(child, IFocusContainer) && cast(child, IFocusContainer).isChildFocusEnabled))
		{
			var childContainer:DisplayObjectContainer = cast child;
			var foundChild:IFocusDisplayObject = this.findPreviousContainerFocus(childContainer, null, false);
			if (foundChild != null)
			{
				return foundChild;
			}
		}
		if (Std.isOfType(child, IFocusDisplayObject))
		{
			var childWithFocus:IFocusDisplayObject = cast child;
			if (this.isValidFocus(childWithFocus))
			{
				return childWithFocus;
			}
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private function findNextChildFocus(child:DisplayObject):IFocusDisplayObject
	{
		if (Std.isOfType(child, IFocusDisplayObject))
		{
			var childWithFocus:IFocusDisplayObject = cast child;
			if (this.isValidFocus(childWithFocus))
			{
				return childWithFocus;
			}
		}
		if ((Std.isOfType(child, DisplayObjectContainer) && !Std.isOfType(child, IFocusDisplayObject)) ||
			(Std.isOfType(child, IFocusContainer) && cast(child, IFocusContainer).isChildFocusEnabled))
		{
			var childContainer:DisplayObjectContainer = cast child;
			var foundChild:IFocusDisplayObject = this.findNextContainerFocus(childContainer, null, false);
			if (foundChild != null)
			{
				return foundChild;
			}
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private function findFocusAtRelativePosition(container:DisplayObjectContainer, position:String):IFocusDisplayObject
	{
		var focusableObjects:Array<IFocusDisplayObject> = new Array<IFocusDisplayObject>();
		findAllFocusableObjects(container, focusableObjects);
		if (this._focus == null)
		{
			if (focusableObjects.length != 0)
			{
				return focusableObjects[0];
			}
			return null;
		}
		var focusedRect:Rectangle = this._focus.getBounds(this._focus.stage, Pool.getRectangle());
		var result:IFocusDisplayObject = null;
		var count:Int = focusableObjects.length;
		for (i in 0...count)
		{
			var focusableObject:IFocusDisplayObject = focusableObjects[i];
			if (focusableObject == this._focus)
			{
				continue;
			}
			if (FocusUtils.isBetterFocusForRelativePosition(focusableObject, result, focusedRect, position))
			{
				result = focusableObject;
			}
		}
		Pool.putRectangle(focusedRect);
		
		if (result == null)
		{
			//default to keeping the current focus
			return this._focus;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function findAllFocusableObjects(child:DisplayObject, result:Array<IFocusDisplayObject>):Void
	{
		if (Std.isOfType(child, IFocusDisplayObject))
		{
			var focusableObject:IFocusDisplayObject = cast child;
			if (isValidFocus(focusableObject))
			{
				result[result.length] = focusableObject;
			}
		}
		var count:Int;
		var childOfChild:DisplayObject;
		var extras:Array<DisplayObject>;
		var focusExtras:IFocusExtras = null;
		if (Std.isOfType(child, IFocusExtras))
		{
			focusExtras = cast child;
			extras = focusExtras.focusExtrasBefore;
			count = extras.length;
			for (i in 0...count)
			{
				childOfChild = extras[i];
				findAllFocusableObjects(childOfChild, result);
			}
		}
		var otherContainer:DisplayObjectContainer;
		if (Std.isOfType(child, IFocusDisplayObject))
		{
			if (Std.isOfType(child, IFocusContainer) && cast(child, IFocusContainer).isChildFocusEnabled)
			{
				otherContainer = cast child;
				count = otherContainer.numChildren;
				for (i in 0...count)
				{
					childOfChild = otherContainer.getChildAt(i);
					findAllFocusableObjects(childOfChild, result);
				}
			}
		}
		else if (Std.isOfType(child, DisplayObjectContainer))
		{
			otherContainer = cast child;
			count = otherContainer.numChildren;
			for (i in 0...count)
			{
				childOfChild = otherContainer.getChildAt(i);
				findAllFocusableObjects(childOfChild, result);
			}
		}
		if (Std.isOfType(child, IFocusExtras))
		{
			extras = focusExtras.focusExtrasAfter;
			count = extras.length;
			for (i in 0...count)
			{
				childOfChild = extras[i];
				findAllFocusableObjects(childOfChild, result);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function isValidFocus(child:IFocusDisplayObject):Bool
	{
		if (child == null || child.focusManager != this)
		{
			return false;
		}
		if (!child.isFocusEnabled)
		{
			if (child.focusOwner == null || !isValidFocus(child.focusOwner))
			{
				return false;
			}
		}
		var uiChild:IFeathersControl = cast child;
		if (uiChild != null && !uiChild.isEnabled)
		{
			return false;
		}
		return true;
	}
	
	/**
	 * @private
	 */
	private function stage_mouseFocusChangeHandler(event:FocusEvent):Void
	{
		if (event.relatedObject != null #if !flash && event.relatedObject != Lib.current.stage#end)
		{
			//we need to allow mouse focus to be passed to native display
			//objects. for instance, hyperlinks in TextField won't work
			//unless the TextField can be focused.
			this.focus = null;
			return;
		}
		event.preventDefault();
	}

	/**
	 * @private
	 */
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		// TODO : openfl.ui.KeyLocation has no D_PAD property
		//if (event.keyLocation != KeyLocation.D_PAD && !DeviceCapabilities.simulateDPad)
		//{
			//focus is controlled only with a d-pad and not the regular
			//keyboard arrow keys
			return;
		//}
		if (event.keyCode != Keyboard.UP && event.keyCode != Keyboard.DOWN &&
			event.keyCode != Keyboard.LEFT && event.keyCode != Keyboard.RIGHT)
		{
			return;
		}
		if (event.isDefaultPrevented())
		{
			//something else has already handled this keyboard event
			return;
		}
		var newFocus:IFocusDisplayObject = null;
		var currentFocus:IFocusDisplayObject = this._focus;
		if (currentFocus != null && currentFocus.focusOwner != null)
		{
			newFocus = currentFocus.focusOwner;
		}
		else
		{
			var position:String = RelativePosition.RIGHT;
			switch (event.keyCode)
			{
				case Keyboard.UP :
					position = RelativePosition.TOP;
					if (currentFocus != null && currentFocus.nextUpFocus != null)
					{
						newFocus = currentFocus.nextUpFocus;
					}
				case Keyboard.RIGHT :
					position = RelativePosition.RIGHT;
					if (currentFocus != null && currentFocus.nextRightFocus != null)
					{
						newFocus = currentFocus.nextRightFocus;
					}
				case Keyboard.DOWN :
					position = RelativePosition.BOTTOM;
					if (currentFocus != null && currentFocus.nextDownFocus != null)
					{
						newFocus = currentFocus.nextDownFocus;
					}
				case Keyboard.LEFT :
					position = RelativePosition.LEFT;
					if (currentFocus != null && currentFocus.nextLeftFocus != null)
					{
						newFocus = currentFocus.nextLeftFocus;
					}
			}
			if (newFocus == null)
			{
				newFocus = findFocusAtRelativePosition(this._root, position);
			}
		}
		if (newFocus != this._focus)
		{
			event.preventDefault();
			this.focus = newFocus;
		}
		if (this._focus != null)
		{
			this._focus.showFocus();
		}
	}
	
	/**
	 * @private
	 */
	// TODO : openfl has no TransformGestureEvent
	//private function stage_gestureDirectionalTapHandler(event:TransformGestureEvent):Void
	//{
		//if (event.isDefaultPrevented())
		//{
			////something else has already handled this event
			//return;
		//}
		//var position:String = null;
		//if (event.offsetY < 0)
		//{
			//position = RelativePosition.TOP;
		//}
		//else if (event.offsetY > 0)
		//{
			//position = RelativePosition.BOTTOM;
		//}
		//else if (event.offsetX > 0)
		//{
			//position = RelativePosition.RIGHT;
		//}
		//else if (event.offsetX < 0)
		//{
			//position = RelativePosition.LEFT;
		//}
		//if (position == null)
		//{
			//return;
		//}
		//var newFocus:IFocusDisplayObject = findFocusAtRelativePosition(this._root, position);
		//if (newFocus != this._focus)
		//{
			//event.preventDefault();
			//this.focus = newFocus;
		//}
		//if (this._focus)
		//{
			//this._focus.showFocus();
		//}
	//}
	
	/**
	 * @private
	 */
	private function stage_keyFocusChangeHandler(event:FocusEvent):Void
	{
		//keyCode 0 is sent by IE, for some reason
		if (event.keyCode != Keyboard.TAB && event.keyCode != 0)
		{
			return;
		}
		
		var newFocus:IFocusDisplayObject = null;
		var currentFocus:IFocusDisplayObject = this._focus;
		if (currentFocus != null && currentFocus.focusOwner != null)
		{
			newFocus = currentFocus.focusOwner;
		}
		else if (event.shiftKey)
		{
			if (currentFocus != null)
			{
				if (currentFocus.previousTabFocus != null)
				{
					newFocus = currentFocus.previousTabFocus;
				}
				else
				{
					newFocus = this.findPreviousContainerFocus(currentFocus.parent, cast currentFocus, true);
				}
			}
			if (newFocus == null)
			{
				newFocus = this.findPreviousContainerFocus(this._root, null, false);
			}
		}
		else
		{
			if (currentFocus != null)
			{
				if (currentFocus.nextTabFocus != null)
				{
					newFocus = currentFocus.nextTabFocus;
				}
				else if (Std.isOfType(currentFocus, IFocusContainer) && cast(currentFocus, IFocusContainer).isChildFocusEnabled)
				{
					newFocus = this.findNextContainerFocus(cast currentFocus, null, true);
				}
				else
				{
					newFocus = this.findNextContainerFocus(currentFocus.parent, cast currentFocus, true);
				}
			}
			if (newFocus == null)
			{
				newFocus = this.findNextContainerFocus(this._root, null, false);
			}
		}
		if (newFocus != null)
		{
			event.preventDefault();
		}
		this.focus = newFocus;
		if (this._focus != null)
		{
			this._focus.showFocus();
		}
	}
	
	/**
	 * @private
	 */
	private function topLevelContainer_addedHandler(event:Event):Void
	{
		this.setFocusManager(cast event.target);
	}
	
	/**
	 * @private
	 */
	private function topLevelContainer_removedHandler(event:Event):Void
	{
		this.clearFocusManager(cast event.target);
	}
	
	/**
	 * @private
	 */
	private function topLevelContainer_touchHandler(event:TouchEvent):Void
	{
		if (Capabilities.os.indexOf("tvOS") != -1)
		{
			return;
		}
		var touch:Touch = event.getTouch(this._root, TouchPhase.BEGAN);
		if (touch == null)
		{
			return;
		}
		if (this._focus != null && this._focus.maintainTouchFocus)
		{
			return;
		}
		var focusTarget:IFocusDisplayObject = null;
		var target:DisplayObject = touch.target;
		do
		{
			if (Std.isOfType(target, IFocusDisplayObject))
			{
				var tempFocusTarget:IFocusDisplayObject = cast target;
				if (this.isValidFocus(tempFocusTarget))
				{
					if (focusTarget == null || !Std.isOfType(tempFocusTarget, IFocusContainer) || !cast(tempFocusTarget, IFocusContainer).isChildFocusEnabled)
					{
						focusTarget = tempFocusTarget;
					}
				}
			}
			target = target.parent;
		}
		while (target != null);
		if (this._focus != null && focusTarget != null)
		{
			//ignore touches on focusOwner because we consider the
			//focusOwner to indirectly have focus already
			var focusOwner:IFocusDisplayObject = this._focus.focusOwner;
			if (focusOwner == focusTarget)
			{
				return;
			}
			//similarly, ignore touches on display objects that have a
			//focusOwner and that owner is the currently focused object
			var result:DisplayObject = cast focusTarget;
			while (result != null)
			{
				var focusResult:IFocusDisplayObject = cast result;
				if (focusResult != null)
				{
					focusOwner = focusResult.focusOwner;
					if (focusOwner != null)
					{
						if (focusOwner == this._focus)
						{
							//the current focus is the touch target's owner,
							//so we don't need to clear focus
							focusTarget = focusOwner;
						}
						//if we've found a display object with a focus owner,
						//then we've gone far enough up the display list
						break;
					}
					else if (focusResult.isFocusEnabled)
					{
						//if focus in enabled, then we've gone far enough up
						//the display list
						break;
					}
				}
				result = result.parent;
			}
		}
		this.focus = focusTarget;
	}
	
	/**
	 * @private
	 */
	private function nativeFocus_focusOutHandler(event:FocusEvent):Void
	{
		var nativeFocus:Dynamic = event.currentTarget;
		var nativeStage:Stage = this._starling.nativeStage;
		if (nativeStage.focus != null && nativeStage.focus != nativeFocus)
		{
			//we should stop listening for this event because something else
			//has focus now
			if (Std.isOfType(nativeFocus, IEventDispatcher))
			{
				cast(nativeFocus, IEventDispatcher).removeEventListener(FocusEvent.FOCUS_OUT, nativeFocus_focusOutHandler);
			}
		}
		else if (this._focus != null)
		{
			if (Std.isOfType(this._focus, INativeFocusOwner) &&
				cast(this._focus, INativeFocusOwner).nativeFocus != nativeFocus)
			{
				return;
			}
			//if there's still a feathers focus, but the native stage object has
			//lost focus for some reason, and there's no focus at all, force it
			//back into focus.
			//this can happen on app deactivate!
			if (Std.isOfType(nativeFocus, InteractiveObject))
			{
				nativeStage.focus = cast nativeFocus;
			}
			else //nativeFocus is IAdvancedNativeFocusOwner
			{
				//let the focused component handle giving focus to its
				//nativeFocus because it may have a custom API
				cast(this._focus, IAdvancedNativeFocusOwner).setFocus();
			}
		}
	}

}

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