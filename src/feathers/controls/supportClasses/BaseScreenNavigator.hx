package feathers.controls.supportClasses;
/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
import feathers.controls.AutoSizeMode;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.events.FeathersEventType;
import feathers.utils.skins.SkinsUtils;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.errors.AbstractMethodError;
import starling.events.Event;

/**
 * A base class for screen navigator components that isn't meant to be
 * instantiated directly. It should only be subclassed.
 *
 * @see feathers.controls.StackScreenNavigator
 * @see feathers.controls.ScreenNavigator
 *
 * @productversion Feathers 2.1.0
 */
abstract class BaseScreenNavigator extends FeathersControl
{
	private static var SIGNAL_TYPE:Class<Dynamic>;
	
	/**
	 * The default transition function.
	 */
	private static function defaultTransition(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:?Bool->Void):Void
	{
		//in short, do nothing
		completeCallback();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		
		if (SIGNAL_TYPE == null)
		{
			
		}
		
		this.screenContainer = this;
		this.addEventListener(Event.ADDED_TO_STAGE, screenNavigator_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, screenNavigator_removedFromStageHandler);
	}
	
	/**
	 * The string identifier for the currently active screen.
	 */
	public var activeScreenID(get, never):String;
	private var _activeScreenID:String;
	private function get_activeScreenID():String { return this._activeScreenID; }
	
	/**
	 * A reference to the currently active screen.
	 */
	public var activeScreen(get, never):DisplayObject;
	private var _activeScreen:DisplayObject;
	private function get_activeScreen():DisplayObject { return this._activeScreen; }
	
	/**
	 * @private
	 */
	private var screenContainer:DisplayObjectContainer;

	/**
	 * @private
	 */
	private var _activeScreenExplicitWidth:Float;

	/**
	 * @private
	 */
	private var _activeScreenExplicitHeight:Float;

	/**
	 * @private
	 */
	private var _activeScreenExplicitMinWidth:Float;

	/**
	 * @private
	 */
	private var _activeScreenExplicitMinHeight:Float;

	/**
	 * @private
	 */
	private var _activeScreenExplicitMaxWidth:Float;

	/**
	 * @private
	 */
	private var _activeScreenExplicitMaxHeight:Float;
	
	/**
	 * @private
	 */
	private var _screens:Map<String, IScreenNavigatorItem> = new Map<String, IScreenNavigatorItem>();
	
	/**
	 * @private
	 */
	private var _previousScreenInTransitionID:String;

	/**
	 * @private
	 */
	private var _previousScreenInTransition:DisplayObject;

	/**
	 * @private
	 */
	private var _nextScreenID:String = null;

	/**
	 * @private
	 */
	private var _nextScreenTransition:DisplayObject->DisplayObject->(?Bool->Void)->Void = null;

	/**
	 * @private
	 */
	private var _clearAfterTransition:Bool = false;
	
	/**
	 * @private
	 */
	private var _delayedTransition:DisplayObject->DisplayObject->(?Bool->Void)->Void = null;

	/**
	 * @private
	 */
	private var _waitingForDelayedTransition:Bool = false;
	
	/**
	 * Determines if the navigator's content should be clipped to the width
	 * and height.
	 *
	 * <p>In the following example, clipping is enabled:</p>
	 *
	 * <listing version="3.0">
	 * navigator.clipContent = true;</listing>
	 *
	 * @default false
	 */
	public var clipContent(get, set):Bool;
	private var _clipContent:Bool = false;
	private function get_clipContent():Bool { return this._clipContent; }
	private function set_clipContent(value:Bool):Bool
	{
		if (this._clipContent == value)
		{
			return value;
		}
		this._clipContent = value;
		if (!value)
		{
			this.mask = null;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._clipContent;
	}
	
	/**
	 * Determines how the screen navigator will set its own size when its
	 * dimensions (width and height) aren't set explicitly.
	 *
	 * <p>In the following example, the screen navigator will be sized to
	 * match its content:</p>
	 *
	 * <listing version="3.0">
	 * navigator.autoSizeMode = AutoSizeMode.CONTENT;</listing>
	 *
	 * @default feathers.controls.AutoSizeMode.STAGE
	 *
	 * @see feathers.controls.AutoSizeMode#STAGE
	 * @see feathers.controls.AutoSizeMode#CONTENT
	 */
	public var autoSizeMode(get, set):String;
	private var _autoSizeMode:String = AutoSizeMode.STAGE;
	private function get_autoSizeMode():String { return this._autoSizeMode; }
	private function set_autoSizeMode(value:String):String
	{
		if (this._autoSizeMode == value)
		{
			return value;
		}
		this._autoSizeMode = value;
		if (this._activeScreen != null)
		{
			if(this._autoSizeMode == AutoSizeMode.CONTENT)
			{
				this._activeScreen.addEventListener(Event.RESIZE, activeScreen_resizeHandler);
			}
			else
			{
				this._activeScreen.removeEventListener(Event.RESIZE, activeScreen_resizeHandler);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._autoSizeMode;
	}
	
	/**
	 * @private
	 */
	private var _waitingTransition:DisplayObject->DisplayObject->(?Bool->Void)->Void;

	/**
	 * @private
	 */
	private var _waitingForTransitionFrameCount:Int = 1;
	
	/**
	 * Indicates whether the screen navigator is currently transitioning
	 * between screens.
	 */
	public var isTransitionActive(get, never):Bool;
	private var _isTransitionActive:Bool = false;
	private function get_isTransitionActive():Bool { return this._isTransitionActive; }
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._activeScreen != null)
		{
			this.cleanupActiveScreen();
			this._activeScreen = null;
			this._activeScreenID = null;
		}
		this._screens.clear();
		super.dispose();
	}
	
	/**
	 * Removes all screens that were added with <code>addScreen()</code>.
	 *
	 * @see #addScreen()
	 */
	public function removeAllScreens():Void
	{
		if (this._isTransitionActive)
		{
			throw new IllegalOperationError("Cannot remove all screens while a transition is active.");
		}
		if (this._activeScreen != null)
		{
			//if someone meant to have a transition, they would have called
			//clearScreen()
			this.clearScreenInternal(null);
			this.dispatchEventWith(FeathersEventType.CLEAR);
		}
		this._screens.clear();
	}
	
	/**
	 * Determines if the specified screen identifier has been added with
	 * <code>addScreen()</code>.
	 *
	 * @see #addScreen()
	 */
	public function hasScreen(id:String):Bool
	{
		return this._screens.exists(id);
	}
	
	/**
	 * Returns a list of the screen identifiers that have been added.
	 */
	public function getScreenIDs(result:Array<String> = null):Array<String>
	{
		if (result != null)
		{
			result.resize(0);
		}
		else
		{
			result = new Array<String>();
		}
		var pushIndex:Int = 0;
		for (id in this._screens.keys())
		{
			result[pushIndex] = id;
			pushIndex++;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var selectionInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutChildren();
		
		if (stylesInvalid || sizeInvalid)
		{
			this.refreshMask();
		}
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
		
		var needsToMeasureContent:Bool = this._autoSizeMode == AutoSizeMode.CONTENT || this.stage == null;
		var measureScreen:IMeasureDisplayObject = cast this._activeScreen;
		if (needsToMeasureContent)
		{
			if (this._activeScreen != null)
			{
				SkinsUtils.resetFluidChildDimensionsForMeasurement(this._activeScreen,
					this._explicitWidth, this._explicitHeight,
					this._explicitMinWidth, this._explicitMinHeight,
					this._explicitMaxWidth, this._explicitMaxHeight,
					this._activeScreenExplicitWidth, this._activeScreenExplicitHeight,
					this._activeScreenExplicitMinWidth, this._activeScreenExplicitMinHeight,
					this._activeScreenExplicitMaxWidth, this._activeScreenExplicitMaxHeight);
				if (Std.isOfType(this._activeScreen, IValidating))
				{
					cast(this._activeScreen, IValidating).validate();
				}
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (needsToMeasureContent)
			{
				if (this._activeScreen != null)
				{
					newWidth = this._activeScreen.width;
				}
				else
				{
					newWidth = 0;
				}
			}
			else
			{
				newWidth = this.stage.stageWidth;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (needsToMeasureContent)
			{
				if (this._activeScreen != null)
				{
					newHeight = this._activeScreen.height;
				}
				else
				{
					newHeight = 0;
				}
			}
			else
			{
				newHeight = this.stage.stageHeight;
			}
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (needsToMeasureContent)
			{
				if (measureScreen != null)
				{
					newMinWidth = measureScreen.minWidth;
				}
				else if (this._activeScreen != null)
				{
					newMinWidth = this._activeScreen.width;
				}
				else
				{
					newMinWidth = 0;
				}
			}
			else
			{
				newMinWidth = this.stage.stageWidth;
			}
		}
		
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (needsToMeasureContent)
			{
				if (measureScreen != null)
				{
					newMinHeight = measureScreen.minHeight;
				}
				else if (this._activeScreen != null)
				{
					newMinHeight = this._activeScreen.height;
				}
				else
				{
					newMinHeight = 0;
				}
			}
			else
			{
				newMinHeight = this.stage.stageHeight;
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function addScreenInternal(id:String, item:IScreenNavigatorItem):Void
	{
		if (this._screens.exists(id))
		{
			throw new ArgumentError("Screen with id '" + id + "' already defined. Cannot add two screens with the same id.");
		}
		this._screens[id] = item;
	}
	
	/**
	 * @private
	 */
	private function refreshMask():Void
	{
		if (!this._clipContent)
		{
			return;
		}
		var mask:DisplayObject = this.mask;
		if (mask != null)
		{
			mask.width = this.actualWidth;
			mask.height = this.actualHeight;
		}
		else
		{
			mask = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			//and these values might be 0
			mask.width = this.actualWidth;
			mask.height = this.actualHeight;
			this.mask = mask;
		}
	}
	
	/**
	 * @private
	 */
	private function removeScreenInternal(id:String):IScreenNavigatorItem
	{
		if (!this._screens.exists(id))
		{
			throw new ArgumentError("Screen '" + id + "' cannot be removed because it has not been added.");
		}
		if (this._isTransitionActive && (id == this._previousScreenInTransitionID || id == this._activeScreenID))
		{
			throw new IllegalOperationError("Cannot remove a screen while it is transitioning in or out.");
		}
		if (this._activeScreenID == id)
		{
			//if someone meant to have a transition, they would have called
			//clearScreen()
			this.clearScreenInternal(null);
			this.dispatchEventWith(FeathersEventType.CLEAR);
		}
		var item:IScreenNavigatorItem = this._screens[id];
		this._screens.remove(id);
		return item;
	}
	
	/**
	 * @private
	 */
	private function showScreenInternal(id:String, transition:DisplayObject->DisplayObject->(?Bool->Void)->Void, properties:Map<String, Dynamic> = null):DisplayObject
	{
		if (!this.hasScreen(id))
		{
			throw new ArgumentError("Screen with id '" + id + "' cannot be shown because it has not been defined.");
		}
		
		if (this._isTransitionActive)
		{
			this._nextScreenID = id;
			this._nextScreenTransition = transition;
			this._clearAfterTransition = false;
			return null;
		}
		
		this._previousScreenInTransition = this._activeScreen;
		this._previousScreenInTransitionID = this._activeScreenID;
		if (this._activeScreen != null)
		{
			this.cleanupActiveScreen();
		}
		
		this._isTransitionActive = true;
		
		var item:IScreenNavigatorItem = this._screens[id];
		this._activeScreen = item.getScreen();
		this._activeScreenID = id;
		if (item.transitionDelayEvent != null)
		{
			this._waitingForDelayedTransition = true;
			this._activeScreen.addEventListener(item.transitionDelayEvent, screen_transitionDelayHandler);
		}
		else
		{
			this._waitingForDelayedTransition = false;
		}
		if (properties != null)
		{
			//var fields:Array<String> = Reflect.fields(properties);
			//for (propertyName in fields)
			//{
				////this._activeScreen[propertyName] = properties[propertyName];
				//Reflect.setProperty(this._activeScreen, propertyName, Reflect.field(properties, propertyName));
			//}
			for (propertyName in properties.keys())
			{
				Reflect.setProperty(this._activeScreen, propertyName, properties[propertyName]);
			}
		}
		if (Std.isOfType(this._activeScreen, IScreen))
		{
			var screen:IScreen = cast this._activeScreen;
			screen.screenID = this._activeScreenID;
			screen.owner = this; //subclasses will implement the interface
		}
		if (this._autoSizeMode == AutoSizeMode.CONTENT || this.stage == null)
		{
			this._activeScreen.addEventListener(Event.RESIZE, activeScreen_resizeHandler);
		}
		this.prepareActiveScreen();
		var isSameInstance:Bool = this._previousScreenInTransition == this._activeScreen;
		this.screenContainer.addChild(this._activeScreen);
		if (Std.isOfType(this._activeScreen, IFeathersControl))
		{
			cast(this._activeScreen, IFeathersControl).initializeNow();
		}
		var measureScreen:IMeasureDisplayObject = cast this._activeScreen;
		if (measureScreen != null)
		{
			this._activeScreenExplicitWidth = measureScreen.explicitWidth;
			this._activeScreenExplicitHeight = measureScreen.explicitHeight;
			this._activeScreenExplicitMinWidth = measureScreen.explicitMinWidth;
			this._activeScreenExplicitMinHeight = measureScreen.explicitMinHeight;
			this._activeScreenExplicitMaxWidth = measureScreen.explicitMaxWidth;
			this._activeScreenExplicitMaxHeight = measureScreen.explicitMaxHeight;
		}
		else
		{
			this._activeScreenExplicitWidth = this._activeScreen.width;
			this._activeScreenExplicitHeight = this._activeScreen.height;
			this._activeScreenExplicitMinWidth = this._activeScreenExplicitWidth;
			this._activeScreenExplicitMinHeight = this._activeScreenExplicitHeight;
			this._activeScreenExplicitMaxWidth = this._activeScreenExplicitWidth;
			this._activeScreenExplicitMaxHeight = this._activeScreenExplicitHeight;
		}
		
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		if (this._validationQueue != null && !this._validationQueue.isValidating)
		{
			//force a COMPLETE validation of everything
			//but only if we're not already doing that...
			this._validationQueue.advanceTime(0);
		}
		else if (!this._isValidating)
		{
			this.validate();
		}
		
		if (isSameInstance)
		{
			//we can't transition if both screens are the same display
			//object, so skip the transition!
			this._previousScreenInTransition = null;
			this._previousScreenInTransitionID = null;
			this._isTransitionActive = false;
		}
		else if (item.transitionDelayEvent != null && this._waitingForDelayedTransition)
		{
			this._waitingForDelayedTransition = false;
			this._activeScreen.visible = false;
			this._delayedTransition = transition;
		}
		else
		{
			if (item.transitionDelayEvent != null)
			{
				//if we skipped the delay because the event was already
				//dispatched, then don't forget to remove the listener
				this._activeScreen.removeEventListener(item.transitionDelayEvent, screen_transitionDelayHandler);
			}
			this.startTransition(transition);
		}
		
		this.dispatchEventWith(Event.CHANGE);
		return this._activeScreen;
	}
	
	/**
	 * @private
	 */
	private function clearScreenInternal(transition:DisplayObject->DisplayObject->(?Bool->Void)->Void = null):Void
	{
		if (this._activeScreen == null)
		{
			//no screen visible.
			return;
		}
		
		if (this._isTransitionActive)
		{
			this._nextScreenID = null;
			this._clearAfterTransition = true;
			this._nextScreenTransition = transition;
			return;
		}
		
		this.cleanupActiveScreen();
		
		this._isTransitionActive = true;
		this._previousScreenInTransition = this._activeScreen;
		this._previousScreenInTransitionID = this._activeScreenID;
		this._activeScreen = null;
		this._activeScreenID = null;
		
		this.dispatchEventWith(FeathersEventType.TRANSITION_START);
		this._previousScreenInTransition.dispatchEventWith(FeathersEventType.TRANSITION_OUT_START);
		if (transition != null)
		{
			this._waitingForTransitionFrameCount = 0;
			this._waitingTransition = transition;
			//this is a workaround for an issue with transition performance.
			//see the comment in the listener for details.
			this.addEventListener(Event.ENTER_FRAME, waitingForTransition_enterFrameHandler);
		}
		else
		{
			defaultTransition(this._previousScreenInTransition, this._activeScreen, transitionComplete);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
	/**
	 * @private
	 */
	private function prepareActiveScreen():Void
	{
		throw new AbstractMethodError();
	}
	
	/**
	 * @private
	 */
	private function cleanupActiveScreen():Void
	{
		throw new AbstractMethodError();
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		if (this._activeScreen != null)
		{
			if (this._activeScreen.width != this.actualWidth)
			{
				this._activeScreen.width = this.actualWidth;
			}
			if (this._activeScreen.height != this.actualHeight)
			{
				this._activeScreen.height = this.actualHeight;
			}
			if (Std.isOfType(this._activeScreen, IValidating))
			{
				cast(this._activeScreen, IValidating).validate();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function startTransition(transition:DisplayObject->DisplayObject->(?Bool->Void)->Void):Void
	{
		this.dispatchEventWith(FeathersEventType.TRANSITION_START);
		this._activeScreen.dispatchEventWith(FeathersEventType.TRANSITION_IN_START);
		if (this._previousScreenInTransition != null)
		{
			this._previousScreenInTransition.dispatchEventWith(FeathersEventType.TRANSITION_OUT_START);
		}
		if (transition != null && transition != defaultTransition)
		{
			//temporarily make the active screen invisible because the
			//transition doesn't start right away.
			this._activeScreen.visible = false;
			this._waitingForTransitionFrameCount = 0;
			this._waitingTransition = transition;
			//this is a workaround for an issue with transition performance.
			//see the comment in the listener for details.
			this.addEventListener(Event.ENTER_FRAME, waitingForTransition_enterFrameHandler);
		}
		else
		{
			//the screen may have been hidden if the transition was delayed
			this._activeScreen.visible = true;
			defaultTransition(this._previousScreenInTransition, this._activeScreen, transitionComplete);
		}
	}
	
	/**
	 * @private
	 */
	private function startWaitingTransition():Void
	{
		this.removeEventListener(Event.ENTER_FRAME, waitingForTransition_enterFrameHandler);
		if (this._activeScreen != null)
		{
			this._activeScreen.visible = true;
		}
		
		var transition:DisplayObject->DisplayObject->(?Bool->Void)->Void = this._waitingTransition;
		this._waitingTransition = null;
		transition(this._previousScreenInTransition, this._activeScreen, transitionComplete);
	}
	
	/**
	 * @private
	 */
	private function transitionComplete(cancelTransition:Bool = false):Void
	{
		//consider the transition still active if something is already
		//queued up to happen next. if an event listener asks to show a new
		//screen, it needs to replace what is queued up.
		this._isTransitionActive = this._clearAfterTransition || this._nextScreenID != null;
		var item:IScreenNavigatorItem;
		if (cancelTransition)
		{
			if (this._activeScreen != null)
			{
				item = cast(this._screens[this._activeScreenID]);
				this.cleanupActiveScreen();
				this.screenContainer.removeChild(this._activeScreen, item.canDispose);
				if (!item.canDispose)
				{
					this._activeScreen.width = this._activeScreenExplicitWidth;
					this._activeScreen.height = this._activeScreenExplicitHeight;
					var measureScreen:IMeasureDisplayObject = cast this._activeScreen;
					if (measureScreen != null)
					{
						measureScreen.minWidth = this._activeScreenExplicitMinWidth;
						measureScreen.minHeight = this._activeScreenExplicitMinHeight;
					}
				}
			}
			this._activeScreen = this._previousScreenInTransition;
			this._activeScreenID = this._previousScreenInTransitionID;
			this._previousScreenInTransition = null;
			this._previousScreenInTransitionID = null;
			this.prepareActiveScreen();
			this.dispatchEventWith(FeathersEventType.TRANSITION_CANCEL);
			this.dispatchEventWith(Event.CHANGE);
		}
		else
		{
			//we need to save these in local variables because a new
			//transition may be started in the listeners for the transition
			//complete events, and that will overwrite them.
			var activeScreen:DisplayObject = this._activeScreen;
			var previousScreen:DisplayObject = this._previousScreenInTransition;
			var previousScreenID:String = this._previousScreenInTransitionID;
			item = cast this._screens[previousScreenID];
			this._previousScreenInTransition = null;
			this._previousScreenInTransitionID = null;
			if (previousScreen != null)
			{
				previousScreen.dispatchEventWith(FeathersEventType.TRANSITION_OUT_COMPLETE);
			}
			if (activeScreen != null)
			{
				activeScreen.dispatchEventWith(FeathersEventType.TRANSITION_IN_COMPLETE);
			}
			//we need to dispatch this event before the previous screen's
			//owner property is set to null because legacy code that was
			//written before TRANSITION_OUT_COMPLETE existed may be using
			//this event for the same purpose.
			this.dispatchEventWith(FeathersEventType.TRANSITION_COMPLETE);
			if (previousScreen != null)
			{
				if (Std.isOfType(previousScreen, IScreen))
				{
					var screen:IScreen = cast previousScreen;
					screen.screenID = null;
					screen.owner = null;
				}
				previousScreen.removeEventListener(Event.RESIZE, activeScreen_resizeHandler);
				this.screenContainer.removeChild(previousScreen, item.canDispose);
			}
		}
		
		this._isTransitionActive = false;
		var nextTransition:DisplayObject->DisplayObject->(?Bool->Void)->Void = this._nextScreenTransition;
		this._nextScreenTransition = null;
		if (this._clearAfterTransition)
		{
			this._clearAfterTransition = false;
			this.clearScreenInternal(nextTransition);
		}
		else if (this._nextScreenID != null)
		{
			var nextScreenID:String = this._nextScreenID;
			this._nextScreenID = null;
			this.showScreenInternal(nextScreenID, nextTransition);
		}
	}
	
	/**
	 * @private
	 */
	private function screenNavigator_addedToStageHandler(event:Event):Void
	{
		if (this._autoSizeMode == AutoSizeMode.STAGE)
		{
			//if we validated before being added to the stage, or if we've
			//been removed from stage and added again, we need to be sure
			//that the new stage dimensions are accounted for.
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		this.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
	}
	
	/**
	 * @private
	 */
	private function screenNavigator_removedFromStageHandler(event:Event):Void
	{
		this.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
	}
	
	/**
	 * @private
	 */
	private function activeScreen_resizeHandler(event:Event):Void
	{
		if (this._isValidating || this._autoSizeMode != AutoSizeMode.CONTENT)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function stage_resizeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function screen_transitionDelayHandler(event:Event):Void
	{
		this._activeScreen.removeEventListener(event.type, screen_transitionDelayHandler);
		var wasWaiting:Bool = this._waitingForDelayedTransition;
		this._waitingForDelayedTransition = false;
		if (wasWaiting)
		{
			return;
		}
		var transition:DisplayObject->DisplayObject->(?Bool->Void)->Void = this._delayedTransition;
		this._delayedTransition = null;
		this.startTransition(transition);
	}
	
	/**
	 * @private
	 */
	private function waitingForTransition_enterFrameHandler(event:Event):Void
	{
		//we need to wait a couple of frames before we can start the
		//transition to make it as smooth as possible. this feels a little
		//hacky, to be honest, but I can't figure out why waiting only one
		//frame won't do the trick. the delay is so small though that it's
		//virtually impossible to notice.
		if (this._waitingForTransitionFrameCount < 2)
		{
			this._waitingForTransitionFrameCount++;
			return;
		}
		this.startWaitingTransition();
	}
	
}