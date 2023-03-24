/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.controls.supportClasses.BaseScreenNavigator;
import feathers.events.ExclusiveTouch;
import feathers.events.FeathersEventType;
import feathers.motion.effectClasses.IEffectContext;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.utils.ReverseIterator;
import haxe.Constraints.Function;
import haxe.ds.Map;
import openfl.Lib.getTimer;
import openfl.errors.ArgumentError;
import openfl.errors.TypeError;
import openfl.geom.Point;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * A "view stack"-like container that supports navigation between screens
 * (any display object) through events.
 *
 * <p>The following example creates a screen navigator, adds a screen and
 * displays it:</p>
 *
 * <listing version="3.0">
 * var navigator:StackScreenNavigator = new StackScreenNavigator();
 * navigator.addScreen( "mainMenu", new StackScreenNavigatorItem( MainMenuScreen ) );
 * this.addChild( navigator );
 * 
 * navigator.rootScreenID = "mainMenu";</listing>
 *
 * @see ../../../help/stack-screen-navigator.html How to use the Feathers StackScreenNavigator component
 * @see ../../../help/transitions.html Transitions for Feathers screen navigators
 * @see feathers.controls.StackScreenNavigatorItem
 *
 * @productversion Feathers 2.1.0
 */
class StackScreenNavigator extends BaseScreenNavigator 
{
	/**
	 * @private
	 * The current velocity is given high importance.
	 */
	private static inline var CURRENT_VELOCITY_WEIGHT:Float = 2.33;

	/**
	 * @private
	 * Older saved velocities are given less importance.
	 */
	private static var VELOCITY_WEIGHTS:Array<Float> = [1, 1.33, 1.66, 2];

	/**
	 * @private
	 */
	private static inline var MAXIMUM_SAVED_VELOCITY_COUNT:Int = 4;

	/**
	 * The default <code>IStyleProvider</code> for all <code>StackScreenNavigator</code>
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
		this.addEventListener(FeathersEventType.INITIALIZE, stackScreenNavigator_initializeHandler);
		this.addEventListener(TouchEvent.TOUCH, stackScreenNavigator_touchHandler);
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return StackScreenNavigator.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _isDragging:Bool = false;

	/**
	 * @private
	 */
	private var _dragCancelled:Bool = false;

	/**
	 * @private
	 */
	private var _startTouchX:Float;

	/**
	 * @private
	 */
	private var _currentTouchX:Float;

	/**
	 * @private
	 */
	private var _previousTouchTime:Int;

	/**
	 * @private
	 */
	private var _previousTouchX:Float;

	/**
	 * @private
	 */
	private var _velocityX:Float = 0;

	/**
	 * @private
	 */
	private var _previousVelocityX:Array<Float> = new Array<Float>();
	
	/**
	 * @private
	 */
	public var pushTransition(get, set):Function;
	private var _pushTransition:Function;
	private function get_pushTransition():Function { return this._pushTransition; }
	private function set_pushTransition(value:Function):Function
	{
		if (this.processStyleRestriction("pushTransition"))
		{
			return value;
		}
		return this._pushTransition = value;
	}
	
	/**
	 * @private
	 */
	public var popTransition(get, set):Function;
	private var _popTransition:Function;
	private function get_popTransition():Function { return this._popTransition; }
	private function set_popTransition(value:Function):Function
	{
		if (this.processStyleRestriction("popTransition"))
		{
			return value;
		}
		return this._popTransition = value;
	}
	
	/**
	 * @private
	 */
	public var popToRootTransition(get, set):Function;
	private var _popToRootTransition:Function;
	private function get_popToRootTransition():Function { return this._popToRootTransition; }
	private function set_popToRootTransition(value:Function):Function
	{
		if (this.processStyleRestriction("popToRootTransition"))
		{
			return value;
		}
		return this._popToRootTransition = value;
	}
	
	/**
	 * @private
	 */
	private var _poppedStackItem:StackItem = null;

	/**
	 * @private
	 */
	private var _stack:Array<StackItem> = new Array<StackItem>();
	
	/**
	 * @private
	 */
	public var stackCount(get, never):Int;
	private function get_stackCount():Int
	{
		if (this._stack.length != 0)
		{
			return this._stack.length + 1;
		}
		if (this._activeScreen != null)
		{
			return 1;
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	private var _pushScreenEvents:Map<String, Map<String, Dynamic>> = new Map();

	/**
	 * @private
	 */
	private var _replaceScreenEvents:Map<String, Map<String, Dynamic>>;

	/**
	 * @private
	 */
	private var _popScreenEvents:Array<String>;

	/**
	 * @private
	 */
	private var _popToRootScreenEvents:Array<String>;

	/**
	 * @private
	 */
	private var _tempRootScreenID:String;
	
	/**
	 * Sets the first screen at the bottom of the stack, or the root screen.
	 * When this screen is shown, there will be no transition.
	 *
	 * <p>If the stack contains screens when you set this property, they
	 * will be removed from the stack. In other words, setting this property
	 * will clear the stack, erasing the current history.</p>
	 *
	 * <p>In the following example, the root screen is set:</p>
	 *
	 * <listing version="3.0">
	 * navigator.rootScreenID = "someScreen";</listing>
	 *
	 * @see #popToRootScreen()
	 */
	public var rootScreenID(get, set):String;
	private function get_rootScreenID():String
	{
		if (this._tempRootScreenID != null)
		{
			return this._tempRootScreenID;
		}
		else if (this._stack.length == 0)
		{
			return this._activeScreenID;
		}
		return this._stack[0].id;
	}
	
	private function set_rootScreenID(value:String):String
	{
		if (this._isInitialized)
		{
			//we may have delayed showing the root screen until after
			//initialization, but this property could be set between when
			//_isInitialized is set to true and when the screen is actually
			//shown, so we need to clear this variable, just in case.
			this._tempRootScreenID = null;
			
			//this clears the whole stack and starts fresh
			this._stack.resize(0);
			if (value != null)
			{
				//show without a transition because we're not navigating.
				//we're forcibly replacing the root screen.
				this.showScreenInternal(value, null);
			}
			else
			{
				this.clearScreenInternal(null);
			}
		}
		else
		{
			this._tempRootScreenID = value;
		}
		return value;
	}
	
	/**
	 * The minimum physical distance (in inches) that a touch must move
	 * before a drag gesture begins when <code>isSwipeToPopEnabled</code>
	 * is <code>true</code>.
	 *
	 * <p>In the following example, the minimum drag distance is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.minimumDragDistance = 0.1;</listing>
	 *
	 * @default 0.04
	 *
	 * @see #isSwipeToPopEnabled
	 */
	public var minimumDragDistance(get, set):Float;
	private var _minimumDragDistance:Float = 0.04;
	private function get_minimumDragDistance():Float { return this._minimumDragDistance; }
	private function set_minimumDragDistance(value:Float):Float
	{
		return this._minimumDragDistance;
	}
	
	/**
	 * The minimum physical velocity (in inches per second) that a touch
	 * must move before a swipe is detected. Otherwise, it will settle which
	 * screen to navigate to based on which one is closer when the touch ends.
	 *
	 * <p>In the following example, the minimum swipe velocity is customized:</p>
	 *
	 * <listing version="3.0">
	 * navigator.minimumSwipeVelocity = 2;</listing>
	 *
	 * @default 5
	 *
	 * @see #isSwipeToPopEnabled
	 */
	public var minimumSwipeVelocity(get, set):Float;
	private var _minimumSwipeVelocity:Float = 5;
	private function get_minimumSwipeVelocity():Float { return this._minimumSwipeVelocity; }
	private function set_minimumSwipeVelocity(value:Float):Float
	{
		return this._minimumSwipeVelocity = value;
	}
	
	/**
	 * Determines if the swipe gesture to pop the current screen is enabled.
	 *
	 * <p>In the following example, swiping to go back is enabled:</p>
	 *
	 * <listing version="3.0">
	 * navigator.isSwipeToPopEnabled = true;</listing>
	 *
	 * @default false
	 */
	public var isSwipeToPopEnabled(get, set):Bool;
	private var _isSwipeToPopEnabled:Bool = false;
	private function get_isSwipeToPopEnabled():Bool { return this._isSwipeToPopEnabled; }
	private function set_isSwipeToPopEnabled(value:Bool):Bool
	{
		return this._isSwipeToPopEnabled = value;
	}
	
	/**
	 * The size (in inches) of the region near the left edge of the content
	 * that can be dragged when <code>isSwipeToPopEnabled</code> is
	 * <code>true</code>.
	 *
	 * <p>In the following example, the swipe-to-pop gesture edge size is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * drawers.swipeToPopGestureEdgeSize = 0.25;</listing>
	 *
	 * @default 0.1
	 *
	 * @see #isSwipeToPopEnabled
	 */
	public var swipeToPopGestureEdgeSize(get, set):Float;
	private var _swipeToPopGestureEdgeSize:Float = 0.1;
	private function get_swipeToPopGestureEdgeSize():Float { return this._swipeToPopGestureEdgeSize; }
	private function set_swipeToPopGestureEdgeSize(value:Float):Float
	{
		return this._swipeToPopGestureEdgeSize = value;
	}
	
	/**
	 * @private
	 */
	private var _savedTransitionOnComplete:Function = null;

	/**
	 * @private
	 */
	private var _dragEffectContext:IEffectContext = null;

	/**
	 * @private
	 */
	private var _dragEffectTransition:Function = null;
	
	/**
	 * Registers a new screen with a string identifier that can be used
	 * to reference the screen in other calls, like <code>removeScreen()</code>
	 * or <code>pushScreen()</code>.
	 *
	 * @see #removeScreen()
	 */
	public function addScreen(id:String, item:StackScreenNavigatorItem):Void
	{
		this.addScreenInternal(id, item);
	}
	
	/**
	 * Removes an existing screen using the identifier assigned to it in the
	 * call to <code>addScreen()</code>.
	 *
	 * @see #removeAllScreens()
	 * @see #addScreen()
	 */
	public function removeScreen(id:String):StackScreenNavigatorItem
	{
		var item:StackItem;
		for (i in new ReverseIterator(this._stack.length - 1, 0))
		{
			item = this._stack[i];
			if (item.id == id)
			{
				item.dispose();
				this._stack.splice(i, 1);
				//don't break here because there might be multiple screens
				//with this ID in the stack
			}
		}
		return cast this.removeScreenInternal(id);
	}
	
	/**
	 * @private
	 */
	override public function removeAllScreens():Void
	{
		for (item in this._stack)
		{
			item.dispose();
		}
		this._stack.resize(0);
		super.removeAllScreens();
	}
	/**
	 * Returns the <code>StackScreenNavigatorItem</code> instance with the
	 * specified identifier.
	 */
	public function getScreen(id:String):StackScreenNavigatorItem
	{
		if (this._screens.exists(id))
		{
			return cast this._screens[id];
		}
		return null;
	}
	
	/**
	 * Pushes a screen onto the top of the stack.
	 *
	 * <p>A set of key-value pairs representing properties on the previous
	 * screen may be passed in. If the new screen is popped, these values
	 * may be used to restore the previous screen's state.</p>
	 *
	 * <p>An optional transition may be specified. If <code>null</code> the
	 * <code>pushTransition</code> property will be used instead.</p>
	 *
	 * <p>Returns a reference to the new screen, unless a transition is
	 * currently active. In that case, the new screen will be queued until
	 * the transition has completed, and no reference will be returned.</p>
	 *
	 * @see #pushTransition
	 */
	public function pushScreen(id:String, savedPreviousScreenProperties:Dynamic = null, transition:Function = null):DisplayObject
	{
		if (transition == null)
		{
			var item:StackScreenNavigatorItem = this.getScreen(id);
			if (item != null && item.pushTransition != null)
			{
				transition = item.pushTransition;
			}
			else
			{
				transition = this.pushTransition;
			}
		}
		if (this._activeScreenID != null)
		{
			this._stack[this._stack.length] = new StackItem(this._activeScreenID, savedPreviousScreenProperties);
		}
		else if (savedPreviousScreenProperties != null)
		{
			throw new ArgumentError("Cannot save properties for the previous screen because there is no previous screen.");
		}
		return this.showScreenInternal(id, transition);
	}
	
	/**
	 * Pops the current screen from the top of the stack, returning to the
	 * previous screen.
	 *
	 * <p>An optional transition may be specified. If <code>null</code> the
	 * <code>popTransition</code> property will be used instead.</p>
	 *
	 * <p>Returns a reference to the new screen, unless a transition is
	 * currently active. In that case, the new screen will be queued until
	 * the transition has completed, and no reference will be returned.</p>
	 *
	 * @see #popTransition
	 */
	public function popScreen(transition:Function = null):DisplayObject
	{
		if (this._stack.length == 0)
		{
			return this._activeScreen;
		}
		if (transition == null)
		{
			var screenItem:StackScreenNavigatorItem = this.getScreen(this._activeScreenID);
			if (screenItem != null && screenItem.popTransition != null)
			{
				transition = screenItem.popTransition;
			}
			else
			{
				transition = this.popTransition;
			}
		}
		this._poppedStackItem = this._stack.pop();
		return this.showScreenInternal(this._poppedStackItem.id, transition, this._poppedStackItem.properties);
	}
	
	/**
	 * Returns to the root screen, at the bottom of the stack.
	 *
	 * <p>An optional transition may be specified. If <code>null</code>, the
	 * <code>popToRootTransition</code> or <code>popTransition</code>
	 * property will be used instead.</p>
	 *
	 * <p>Returns a reference to the new screen, unless a transition is
	 * currently active. In that case, the new screen will be queued until
	 * the transition has completed, and no reference will be returned.</p>
	 *
	 * @see #popToRootTransition
	 * @see #popTransition
	 */
	public function popToRootScreen(transition:Function = null):DisplayObject
	{
		if (this._stack.length == 0)
		{
			return this._activeScreen;
		}
		if (transition == null)
		{
			transition = this.popToRootTransition;
			if (transition == null)
			{
				transition = this.popTransition;
			}
		}
		var item:StackItem = this._stack.shift();
		for (item in this._stack)
		{
			item.dispose();
		}
		this._stack.resize(0);
		return this.showScreenInternal(item.id, transition, item.properties);
	}
	
	/**
	 * Pops all screens from the stack, leaving the
	 * <code>StackScreenNavigator</code> empty.
	 *
	 * <p>An optional transition may be specified. If <code>null</code>, the
	 * <code>popTransition</code> property will be used instead.</p>
	 *
	 * @see #popTransition
	 */
	public function popAll(transition:Function = null):Void
	{
		if (this._activeScreen == null)
		{
			return;
		}
		if (transition == null)
		{
			transition = this.popTransition;
		}
		for (item in this._stack)
		{
			item.dispose();
		}
		this._stack.resize(0);
		this.clearScreenInternal(transition);
	}
	
	/**
	 * Returns to the root screen, at the bottom of the stack, but replaces
	 * it with a new root screen.
	 *
	 * <p>An optional transition may be specified. If <code>null</code>, the
	 * <code>popToRootTransition</code> or <code>popTransition</code>
	 * property will be used instead.</p>
	 *
	 * <p>Returns a reference to the new screen, unless a transition is
	 * currently active. In that case, the new screen will be queued until
	 * the transition has completed, and no reference will be returned.</p>
	 *
	 * @see #popToRootTransition
	 * @see #popTransition
	 */
	public function popToRootScreenAndReplace(id:String, transition:Function = null):DisplayObject
	{
		if (transition == null)
		{
			transition = this.popToRootTransition;
			if (transition == null)
			{
				transition = this.popTransition;
			}
		}
		for (item in this._stack)
		{
			item.dispose();
		}
		this._stack.resize(0);
		return this.showScreenInternal(id, transition);
	}
	
	/**
	 * Replaces the current screen on the top of the stack with a new
	 * screen. May be used in the case where you want to navigate from
	 * screen A to screen B and then to screen C, but when popping screen C,
	 * you want to skip screen B and return to screen A.
	 *
	 * <p>Returns a reference to the new screen, unless a transition is
	 * currently active. In that case, the new screen will be queued until
	 * the transition has completed, and no reference will be returned.</p>
	 *
	 * <p>An optional transition may be specified. If <code>null</code> the
	 * <code>pushTransition</code> property will be used instead.</p>
	 *
	 * @see #pushTransition
	 */
	public function replaceScreen(id:String, transition:Function = null):DisplayObject
	{
		if (transition == null)
		{
			var item:StackScreenNavigatorItem = this.getScreen(id);
			if (item != null && item.pushTransition != null)
			{
				transition = item.pushTransition;
			}
			else
			{
				transition = this.pushTransition;
			}
		}
		return this.showScreenInternal(id, transition);
	}
	
	/**
	 * @private
	 */
	override function hitTest(local:Point):DisplayObject
	{
		var result:DisplayObject = super.hitTest(local);
		if (this._isDragging && result != null)
		{
			//don't allow touches to reach children while dragging
			return this;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	override function prepareActiveScreen():Void
	{
		var item:StackScreenNavigatorItem = cast this._screens[this._activeScreenID];
		this.addPushEventsToActiveScreen(item);
		this.addReplaceEventsToActiveScreen(item);
		this.addPopEventsToActiveScreen(item);
		this.addPopToRootEventsToActiveScreen(item);
	}
	
	/**
	 * @private
	 */
	override function cleanupActiveScreen():Void
	{
		var item:StackScreenNavigatorItem = cast this._screens[this._activeScreenID];
		this.removePushEventsFromActiveScreen(item);
		this.removeReplaceEventsFromActiveScreen(item);
		this.removePopEventsFromActiveScreen(item);
		this.removePopToRootEventsFromActiveScreen(item);
	}
	
	/**
	 * @private
	 */
	private function addPushEventsToActiveScreen(item:StackScreenNavigatorItem):Void
	{
		var events:Map<String, Dynamic> = item.pushEvents;
		var savedScreenEvents:Map<String, Dynamic> = new Map();
		var signal:Dynamic;
		var eventAction:Dynamic;
		var eventListener:Dynamic;
		for (eventName in events.keys())
		{
			//signal = null;
			//if (BaseScreenNavigator.SIGNAL_TYPE !== null &&
				//this._activeScreen.hasOwnProperty(eventName))
			//{
				//signal = this._activeScreen[eventName] as BaseScreenNavigator.SIGNAL_TYPE;
			//}
			signal = Reflect.getProperty(this._activeScreen, eventName);
			eventAction = events[eventName];
			if (Reflect.isFunction(eventAction))
			{
				if (signal != null)
				{
					signal.add(eventAction);
				}
				else
				{
					this._activeScreen.addEventListener(eventName, eventAction);
				}
			}
			else if (Std.isOfType(eventAction, String))
			{
				if (signal != null)
				{
					eventListener = this.createPushScreenSignalListener(cast eventAction, signal);
					signal.add(eventListener);
				}
				else
				{
					eventListener = this.createPushScreenEventListener(cast eventAction);
					this._activeScreen.addEventListener(eventName, eventListener);
				}
				savedScreenEvents[eventName] = eventListener;
			}
			else
			{
				throw new TypeError("Unknown push event action defined for screen: " + eventAction.toString());
			}
		}
		this._pushScreenEvents[this._activeScreenID] = savedScreenEvents;
	}
	
	/**
	 * @private
	 */
	private function removePushEventsFromActiveScreen(item:StackScreenNavigatorItem):Void
	{
		var pushEvents:Map<String, Dynamic> = item.pushEvents;
		var savedScreenEvents:Map<String, Dynamic> = this._pushScreenEvents[this._activeScreenID];
		var signal:Dynamic;
		var eventAction:Dynamic;
		var eventListener:Dynamic;
		for (eventName in pushEvents.keys())
		{
			//signal = null;
			//if(BaseScreenNavigator.SIGNAL_TYPE !== null &&
				//this._activeScreen.hasOwnProperty(eventName))
			//{
				//signal = this._activeScreen[eventName] as BaseScreenNavigator.SIGNAL_TYPE;
			//}
			signal = Reflect.getProperty(this._activeScreen, eventName);
			eventAction = pushEvents[eventName];
			if (Reflect.isFunction(eventAction))
			{
				if (signal != null)
				{
					signal.remove(eventAction);
				}
				else
				{
					this._activeScreen.removeEventListener(eventName, eventAction);
				}
			}
			else if (Std.isOfType(eventAction, String))
			{
				eventListener = savedScreenEvents[eventName];
				if (signal != null)
				{
					signal.remove(eventListener);
				}
				else
				{
					this._activeScreen.removeEventListener(eventName, eventListener);
				}
			}
		}
		//this._pushScreenEvents[this._activeScreenID] = null;
		savedScreenEvents.clear();
		this._pushScreenEvents.remove(this._activeScreenID);
	}
	
	/**
	 * @private
	 */
	private function addReplaceEventsToActiveScreen(item:StackScreenNavigatorItem):Void
	{
		var events:Map<String, String> = item.replaceEvents;
		if (events == null)
		{
			return;
		}
		var savedScreenEvents:Map<String, Dynamic> = new Map();
		var signal:Dynamic;
		var eventAction:String;
		var eventListener:Function;
		for (eventName in events.keys())
		{
			//signal = null;
			//if(BaseScreenNavigator.SIGNAL_TYPE !== null &&
				//this._activeScreen.hasOwnProperty(eventName))
			//{
				//signal = this._activeScreen[eventName] as BaseScreenNavigator.SIGNAL_TYPE;
			//}
			signal = Reflect.getProperty(this._activeScreen, eventName);
			eventAction = events[eventName];
			//if(eventAction is String)
			//{
				if (signal != null)
				{
					eventListener = this.createReplaceScreenSignalListener(eventAction, signal);
					signal.add(eventListener);
				}
				else
				{
					eventListener = this.createReplaceScreenEventListener(eventAction);
					this._activeScreen.addEventListener(eventName, eventListener);
				}
				savedScreenEvents[eventName] = eventListener;
			//}
			//else
			//{
				//throw new TypeError("Unknown replace event action defined for screen:", eventAction.toString());
			//}
		}
		if (this._replaceScreenEvents == null)
		{
			this._replaceScreenEvents = new Map();
		}
		this._replaceScreenEvents[this._activeScreenID] = savedScreenEvents;
	}
	
	/**
	 * @private
	 */
	private function removeReplaceEventsFromActiveScreen(item:StackScreenNavigatorItem):Void
	{
		var replaceEvents:Map<String, String> = item.replaceEvents;
		if (replaceEvents == null)
		{
			return;
		}
		var savedScreenEvents:Map<String, Dynamic> = this._replaceScreenEvents[this._activeScreenID];
		var signal:Dynamic;
		var eventAction:String;
		var eventListener:Dynamic->Void;
		for (eventName in replaceEvents)
		{
			//signal:Dynamic;
			//if(BaseScreenNavigator.SIGNAL_TYPE !== null &&
				//this._activeScreen.hasOwnProperty(eventName))
			//{
				//signal = this._activeScreen[eventName] as BaseScreenNavigator.SIGNAL_TYPE;
			//}
			signal = Reflect.getProperty(this._activeScreen, eventName);
			eventAction = replaceEvents[eventName];
			//if (eventAction is String)
			//{
				eventListener = savedScreenEvents[eventName];
				if (signal != null)
				{
					signal.remove(eventListener);
				}
				else
				{
					this._activeScreen.removeEventListener(eventName, eventListener);
				}
			//}
		}
		//this._replaceScreenEvents[this._activeScreenID] = null;
		savedScreenEvents.clear();
		this._replaceScreenEvents.remove(this._activeScreenID);
	}
	
	/**
	 * @private
	 */
	private function addPopEventsToActiveScreen(item:StackScreenNavigatorItem):Void
	{
		if (item.popEvents == null)
		{
			return;
		}
		//creating a copy because this array could change before the screen
		//is removed.
		var popEvents:Array<String> = item.popEvents.copy();
		var signal:Dynamic;
		for (eventName in popEvents)
		{
			signal = Reflect.getProperty(this._activeScreen, eventName);
			if (signal != null)
			{
				signal.add(popSignalListener);
			}
			else
			{
				this._activeScreen.addEventListener(eventName, popEventListener);
			}
		}
		this._popScreenEvents = popEvents;
	}
	
	/**
	 * @private
	 */
	private function removePopEventsFromActiveScreen(item:StackScreenNavigatorItem):Void
	{
		if (this._popScreenEvents == null)
		{
			return;
		}
		var signal:Dynamic;
		for (eventName in this._popScreenEvents)
		{
			signal = Reflect.getProperty(this._activeScreen, eventName);
			if (signal)
			{
				signal.remove(popSignalListener);
			}
			else
			{
				this._activeScreen.removeEventListener(eventName, popEventListener);
			}
		}
		this._popScreenEvents = null;
	}
	
	/**
	 * @private
	 */
	private function removePopToRootEventsFromActiveScreen(item:StackScreenNavigatorItem):Void
	{
		if (this._popToRootScreenEvents == null)
		{
			return;
		}
		
		var signal:Dynamic;
		for (eventName in this._popToRootScreenEvents)
		{
			signal = Reflect.getProperty(this._activeScreen, eventName);
			if (signal != null)
			{
				signal.remove(popToRootSignalListener);
			}
			else
			{
				this._activeScreen.removeEventListener(eventName, popToRootEventListener);
			}
		}
		this._popToRootScreenEvents = null;
	}
	
	/**
	 * @private
	 */
	private function addPopToRootEventsToActiveScreen(item:StackScreenNavigatorItem):Void
	{
		if (item.popToRootEvents == null)
		{
			return;
		}
		//creating a copy because this array could change before the screen
		//is removed.
		var popToRootEvents:Array<String> = item.popToRootEvents.copy();
		//var eventCount:int = popToRootEvents.length;
		var signal:Dynamic;
		for (eventName in popToRootEvents)
		{
			//var eventName:String = popToRootEvents[i];
			//signal = null;
			//if(BaseScreenNavigator.SIGNAL_TYPE !== null &&
				//this._activeScreen.hasOwnProperty(eventName))
			//{
				//signal = this._activeScreen[eventName] as BaseScreenNavigator.SIGNAL_TYPE;
			//}
			signal = Reflect.getProperty(this._activeScreen, eventName);
			if (signal != null)
			{
				signal.add(popToRootSignalListener);
			}
			else
			{
				this._activeScreen.addEventListener(eventName, popToRootEventListener);
			}
		}
		this._popToRootScreenEvents = popToRootEvents;
	}
	
	/**
	 * @private
	 */
	private function createPushScreenEventListener(screenID:String):Function
	{
		var self:StackScreenNavigator = this;
		var eventListener:Function = function(event:Event, data:Dynamic):Void
		{
			self.pushScreen(screenID, data);
		};
		
		return eventListener;
	}
	
	/**
	 * @private
	 */
	private function createPushScreenSignalListener(screenID:String, signal:Dynamic):Function
	{
		var self:StackScreenNavigator = this;
		var signalListener:Function;
		if (signal.valueClasses.length == 1)
		{
			//shortcut to avoid the allocation of the rest array
			signalListener = function(arg0:Dynamic):Void
			{
				self.pushScreen(screenID, arg0);
			};
		}
		else
		{
			signalListener = function(...rest:Array<Dynamic>):Void
			{
				var data:Dynamic = null;
				if (rest.length != 0)
				{
					data = rest[0];
				}
				self.pushScreen(screenID, data);
			};
		}
		
		return signalListener;
	}
	
	/**
	 * @private
	 */
	private function createReplaceScreenEventListener(screenID:String):Function
	{
		var self:StackScreenNavigator = this;
		var eventListener:Function = function(event:Event):Void
		{
			self.replaceScreen(screenID);
		};
		
		return eventListener;
	}
	
	/**
	 * @private
	 */
	private function createReplaceScreenSignalListener(screenID:String, signal:Dynamic):Function
	{
		var self:StackScreenNavigator = this;
		var signalListener:Function;
		if (signal.valueClasses.length == 0)
		{
			//shortcut to avoid the allocation of the rest array
			signalListener = function():Void
			{
				self.replaceScreen(screenID);
			};
		}
		else
		{
			signalListener = function(...rest:Dynamic):Void
			{
				self.replaceScreen(screenID);
			};
		}
		
		return signalListener;
	}
	
	/**
	 * @private
	 */
	private function handleTouchBegan(touch:Touch):Void
	{
		var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
		if (exclusiveTouch.getClaim(touch.id) != null)
		{
			//already claimed
			return;
		}
		
		var point:Point = Pool.getPoint();
		touch.getLocation(this, point);
		var localX:Float = point.x;
		Pool.putPoint(point);
		
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var leftInches:Float = localX / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		if (leftInches < 0 || leftInches > this._swipeToPopGestureEdgeSize)
		{
			//we're not close enough to the edge
			return;
		}
		
		this._touchPointID = touch.id;
		this._velocityX = 0;
		this._previousVelocityX.resize(0);
		this._previousTouchTime = getTimer();
		this._previousTouchX = this._startTouchX = this._currentTouchX = localX;
		this._isDragging = false;
		this._dragCancelled = false;
		
		exclusiveTouch.addEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
	}
	
	/**
	 * @private
	 */
	private function handleTouchMoved(touch:Touch):Void
	{
		var point:Point = Pool.getPoint();
		touch.getLocation(this, point);
		this._currentTouchX = point.x;
		Pool.putPoint(point);
		var now:Int = getTimer();
		var timeOffset:Int = now - this._previousTouchTime;
		if (timeOffset > 0)
		{
			//we're keeping previous velocity updates to improve accuracy
			this._previousVelocityX[this._previousVelocityX.length] = this._velocityX;
			if (this._previousVelocityX.length > MAXIMUM_SAVED_VELOCITY_COUNT)
			{
				this._previousVelocityX.shift();
			}
			this._velocityX = (this._currentTouchX - this._previousTouchX) / timeOffset;
			this._previousTouchTime = now;
			this._previousTouchX = this._currentTouchX;
		}
	}
	
	/**
	 * @private
	 */
	private function dragTransition(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Function):Void
	{
		this._savedTransitionOnComplete = onComplete;
		this._dragEffectContext = this._dragEffectTransition(this._previousScreenInTransition, this._activeScreen, null, true);
		this._dragEffectTransition = null;
		this.handleDragMove();
	}
	
	/**
	 * @private
	 */
	private function handleDragMove():Void
	{
		if (this._dragEffectContext == null)
		{
			//the transition may not have started yet
			return;
		}
		var offsetX:Float = this._currentTouchX - this._startTouchX;
		this._dragEffectContext.position = offsetX / this.screenContainer.width;
	}
	
	/**
	 * @private
	 */
	private function handleDragEnd():Void
	{
		if (this._dragEffectContext == null)
		{
			//if we're waiting to start the transition for performance
			//reasons, force it to start immediately
			if (this._waitingTransition != null)
			{
				this.startWaitingTransition();
			}
		}
		
		this._dragCancelled = false;
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		
		var sum:Float = this._velocityX * CURRENT_VELOCITY_WEIGHT;
		var velocityCount:Int = this._previousVelocityX.length;
		var totalWeight:Float = CURRENT_VELOCITY_WEIGHT;
		for (i in 0...velocityCount)
		{
			var weight:Float = VELOCITY_WEIGHTS[i];
			sum += this._previousVelocityX.shift() * weight;
			totalWeight += weight;
		}
		
		var inchesPerSecondX:Float = 1000 * (sum / totalWeight) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		if (inchesPerSecondX < -this._minimumSwipeVelocity)
		{
			//force back to current screen
			if (this._isDragging)
			{
				this._dragCancelled = true;
			}
		}
		else
		{
			var offsetX:Float = this._currentTouchX - this._startTouchX;
			var ratio:Float = offsetX / this.screenContainer.width;
			if (ratio <= 0.5)
			{
				if (this._isDragging)
				{
					this._dragCancelled = true;
				}
			}
		}
		
		this._dragEffectContext.addEventListener(Event.COMPLETE, dragEffectContext_completeHandler);
		if (this._dragCancelled)
		{
			this._dragEffectContext.playReverse();
		}
		else
		{
			this._dragEffectContext.play();
		}
	}
	
	/**
	 * @private
	 */
	private function checkForDrag():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var horizontalInchesMoved:Float = (this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		if (horizontalInchesMoved < this._minimumDragDistance)
		{
			return;
		}
		
		this._dragEffectTransition = null;
		var screenItem:StackScreenNavigatorItem = this.getScreen(this._activeScreenID);
		if (screenItem != null && screenItem.popTransition != null)
		{
			this._dragEffectTransition = screenItem.popTransition;
		}
		else
		{
			this._dragEffectTransition = this.popTransition;
		}
		
		//if no transition has been specified, use the default
		if (this._dragEffectTransition == null)
		{
			this._dragEffectTransition = BaseScreenNavigator.defaultTransition;
		}
		
		//if this is an old transition that doesn't support being managed,
		//simply start it without management.
		// TODO : handle old transitions ? (what's an old transition ?)
		//if (this._dragEffectTransition.length < 4)
		//{
			//this._dragEffectTransition = null;
			//this.popScreen();
			//return;
		//}
		
		this._isDragging = true;
		this.popScreen(dragTransition);
		this._startTouchX = this._currentTouchX;
		var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
		exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
		exclusiveTouch.claimTouch(this._touchPointID, this);
		this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
	}
	
	/**
	 * @private
	 */
	override function transitionComplete(cancelTransition:Bool = false):Void
	{
		this._poppedStackItem = null;
		super.transitionComplete(cancelTransition);
	}
	
	/**
	 * @private
	 */
	private function popEventListener(event:Event):Void
	{
		this.popScreen();
	}
	
	/**
	 * @private
	 */
	private function popSignalListener(...rest:Dynamic):Void
	{
		this.popScreen();
	}
	
	/**
	 * @private
	 */
	private function popToRootEventListener(event:Event):Void
	{
		this.popToRootScreen();
	}
	
	/**
	 * @private
	 */
	private function popToRootSignalListener(...rest:Dynamic):Void
	{
		this.popToRootScreen();
	}
	
	/**
	 * @private
	 */
	private function stackScreenNavigator_initializeHandler(event:Event):Void
	{
		if (this._tempRootScreenID != null)
		{
			var screenID:String = this._tempRootScreenID;
			this._tempRootScreenID = null;
			this.showScreenInternal(screenID, null);
		}
	}
	
	/**
	 * @private
	 */
	private function stackScreenNavigator_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled || !this._isSwipeToPopEnabled || (this._stack.length == 0 && !this._isDragging))
		{
			this._touchPointID = -1;
			return;
		}
		var touch:Touch;
		if (this._touchPointID != -1)
		{
			touch = event.getTouch(this, null, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			if (touch.phase == TouchPhase.MOVED)
			{
				this.handleTouchMoved(touch);
				
				if (!this._isDragging)
				{
					this.checkForDrag();
				}
				if (this._isDragging)
				{
					this.handleDragMove();
				}
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				this._touchPointID = -1;
				if (this._isDragging)
				{
					this.handleDragEnd();
					this.dispatchEventWith(FeathersEventType.END_INTERACTION);
				}
			}
		}
		else
		{
			touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this.handleTouchBegan(touch);
		}
	}
	
	/**
	 * @private
	 */
	private function exclusiveTouch_changeHandler(event:Event, touchID:Int):Void
	{
		if (this._touchPointID == -1 || this._touchPointID != touchID || this._isDragging)
		{
			return;
		}
		
		var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
		if (exclusiveTouch.getClaim(touchID) == this)
		{
			return;
		}
		
		this._touchPointID = -1;
	}
	
	/**
	 * @private
	 */
	private function dragEffectContext_completeHandler(event:Event):Void
	{
		this._dragEffectContext.removeEventListeners();
		this._dragEffectContext = null;
		this._isDragging = false;
		var cancelled:Bool = this._dragCancelled;
		this._dragCancelled = false;
		var onComplete:Function = this._savedTransitionOnComplete;
		this._savedTransitionOnComplete = null;
		if (cancelled)
		{
			this._stack[this._stack.length] = this._poppedStackItem;
		}
		onComplete(cancelled);
	}
	
}

@:final class StackItem
{
	public function new(id:String, properties:Dynamic)
	{
		this.id = id;
		this.properties = properties;
	}
	
	public function dispose():Void
	{
		if (this.properties != null)
		{
			this.properties.clear();
			this.properties = null;
		}
	}

	public var id:String;
	public var properties:Dynamic;
}