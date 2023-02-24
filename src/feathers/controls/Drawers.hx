/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.controls.supportClasses.BaseScreenNavigator;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IValidating;
import feathers.events.ExclusiveTouch;
import feathers.events.FeathersEventType;
import feathers.layout.Orientation;
import feathers.layout.RelativeDepth;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.utils.display.DisplayUtils;
import feathers.utils.math.MathUtils;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.Lib.getTimer;
import openfl.ui.Keyboard;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.display.Stage;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * A container that displays primary content in the center surrounded by
 * optional "drawers" that can open and close on the edges. Useful for
 * mobile-style app menus that slide open from the side of the screen.
 *
 * <p>Additionally, each drawer may be individually "docked" in an
 * always-open state, making this a useful application-level layout
 * container even if the drawers never need to be hidden. Docking behavior
 * may be limited to either portrait or landscape, or a drawer may be docked
 * in both orientations. By default, a drawer is not docked.</p>
 *
 * <p>The following example creates an app with a slide out menu to the
 * left of the main content:</p>
 *
 * <listing version="3.0">
 * var navigator:StackScreenNavigator = new StackScreenNavigator();
 * var list:List = new List();
 * // the navigator's screens, the list's data provider, and additional
 * // properties should be set here.
 * 
 * var drawers:Drawers = new Drawers();
 * drawers.content = navigator;
 * drawers.leftDrawer = menu;
 * drawers.leftDrawerToggleEventType = Event.OPEN;
 * this.addChild( drawers );</listing>
 *
 * <p>In the example above, a screen in the <code>StackScreenNavigator</code>
 * component dispatches an event of type <code>Event.OPEN</code> when it
 * wants to display the slide out the <code>List</code> that is used as
 * the left drawer.</p>
 *
 * @see ../../../help/drawers.html How to use the Feathers Drawers component
 *
 * @productversion Feathers 1.2.0
 */
class Drawers extends FeathersControl 
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>Drawers</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * The field used to access the "content event dispatcher" of a
	 * <code>ScreenNavigator</code> component, which happens to be the
	 * currently active screen.
	 *
	 * @see #contentEventDispatcherField
	 * @see feathers.controls.ScreenNavigator
	 */
	private static inline var SCREEN_NAVIGATOR_CONTENT_EVENT_DISPATCHER_FIELD:String = "activeScreen";
	
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
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();
	
	/**
	 * Constructor
	 */
	public function new(content:IFeathersControl = null) 
	{
		super();
		this.content = content;
		this.addEventListener(Event.ADDED_TO_STAGE, drawers_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, drawers_removedFromStageHandler);
		this.addEventListener(TouchEvent.TOUCH, drawers_touchHandler);
	}
	
	/**
	 * The event dispatcher that controls opening and closing drawers with
	 * events. Often, the event dispatcher is the content itself, but you
	 * may specify a <code>contentEventDispatcherField</code> to access a
	 * property of the content instead, or you may specify a
	 * <code>contentEventDispatcherFunction</code> to run some more complex
	 * code to access the event dispatcher.
	 *
	 * @see #contentEventDispatcherField
	 * @see #contentEventDispatcherFunction
	 */
	private var contentEventDispatcher:EventDispatcher;
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Drawers.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _originalContentWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _originalContentHeight:Float = Math.NaN;
	
	/**
	 * The primary content displayed in the center of the container.
	 *
	 * <p>If the primary content is a container where you'd prefer to listen
	 * to events from its children, you may need to use properties like
	 * <code>contentEventDispatcherField</code>, <code>contentEventDispatcherFunction</code>,
	 * and <code>contentEventDispatcherChangeEventType</code> to ensure that
	 * open and close events for drawers are correctly mapped to the correct
	 * event dispatcher. If the content is dispatching the events, then those
	 * properties should be set to <code>null</code>.</p>
	 *
	 * <p>In the following example, a <code>StackScreenNavigator</code> is added
	 * as the content:</p>
	 *
	 * <listing version="3.0">
	 * var navigator:StackScreenNavigator = new StackScreenNavigator();
	 * // additional code to add the screens can go here
	 * drawers.content = navigator;</listing>
	 *
	 * @default null
	 *
	 * @see #contentEventDispatcherField
	 * @see #contentEventDispatcherFunction
	 * @see #contentEventDispatcherChangeEventType
	 */
	public var content(get, set):IFeathersControl;
	private var _content:IFeathersControl;
	private function get_content():IFeathersControl { return this._content; }
	private function set_content(value:IFeathersControl):IFeathersControl
	{
		if (this._content == value)
		{
			return value;
		}
		if (this._content != null)
		{
			if (this._contentEventDispatcherChangeEventType != null)
			{
				this._content.removeEventListener(this._contentEventDispatcherChangeEventType, content_eventDispatcherChangeHandler);
			}
			this._content.removeEventListener(FeathersEventType.RESIZE, content_resizeHandler);
			if (this._content.parent == this)
			{
				this.removeChild(cast this._content, false);
			}
		}
		this._content = value;
		this._originalContentWidth = Math.NaN;
		this._originalContentHeight = Math.NaN;
		if (this._content != null)
		{
			if (Std.isOfType(this._content, BaseScreenNavigator))
			{
				this.contentEventDispatcherField = SCREEN_NAVIGATOR_CONTENT_EVENT_DISPATCHER_FIELD;
				this.contentEventDispatcherChangeEventType = Event.CHANGE;
			}
			if (this._contentEventDispatcherChangeEventType != null)
			{
				this._content.addEventListener(this._contentEventDispatcherChangeEventType, content_eventDispatcherChangeHandler);
			}
			if (this._autoSizeMode == AutoSizeMode.CONTENT || this.stage == null)
			{
				this._content.addEventListener(FeathersEventType.RESIZE, content_resizeHandler);
			}
			if (this._openMode == RelativeDepth.ABOVE)
			{
				this.addChildAt(cast this._content, 0);
			}
			else //below
			{
				//the content should appear under the overlay skin, if it exists
				if (this._overlaySkin != null)
				{
					this.addChildAt(cast this._content, this.getChildIndex(this._overlaySkin));
				}
				else
				{
					this.addChild(cast this._content);
				}
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._content;
	}
	
	/**
	 * @private
	 */
	private var _overlaySkinOriginalAlpha:Float = 1;
	
	/**
	 * @private
	 */
	public var overlaySkin(get, set):DisplayObject;
	private var _overlaySkin:DisplayObject;
	private function get_overlaySkin():DisplayObject { return this._overlaySkin; }
	private function set_overlaySkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("overlaySkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._overlaySkin == value)
		{
			return value;
		}
		if (this._overlaySkin != null && this._overlaySkin.parent == this)
		{
			this.removeChild(this._overlaySkin, false);
		}
		this._overlaySkin = value;
		if (this._overlaySkin != null)
		{
			this._overlaySkinOriginalAlpha = this._overlaySkin.alpha;
			this._overlaySkin.visible = this.isTopDrawerOpen || this.isRightDrawerOpen || this.isBottomDrawerOpen || this.isLeftDrawerOpen;
			this.addChild(this._overlaySkin);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._overlaySkin;
	}
	
	/**
	 * @private
	 */
	private var _originalTopDrawerWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _originalTopDrawerHeight:Float = Math.NaN;
	
	/**
	 * The drawer that appears above the primary content.
	 *
	 * <p>In the following example, a <code>List</code> is added as the
	 * top drawer:</p>
	 *
	 * <listing version="3.0">
	 * var list:List = new List();
	 * // set data provider and other properties here
	 * drawers.topDrawer = list;</listing>
	 *
	 * @default null
	 *
	 * @see #topDrawerDockMode
	 * @see #topDrawerToggleEventType
	 */
	public var topDrawer(get, set):IFeathersControl;
	private var _topDrawer:IFeathersControl;
	private function get_topDrawer():IFeathersControl { return this._topDrawer; }
	private function set_topDrawer(value:IFeathersControl):IFeathersControl
	{
		if (this._topDrawer == value)
		{
			return value;
		}
		if (this.isTopDrawerOpen && value == null)
		{
			this.isTopDrawerOpen = false;
		}
		if (this._topDrawer != null && this._topDrawer.parent == this)
		{
			this.removeChild(cast this._topDrawer, false);
		}
		this._topDrawer = value;
		this._originalTopDrawerWidth = Math.NaN;
		this._originalTopDrawerHeight = Math.NaN;
		if (this._topDrawer != null)
		{
			this._topDrawer.visible = false;
			this._topDrawer.addEventListener(FeathersEventType.RESIZE, drawer_resizeHandler);
			if (this._openMode == RelativeDepth.ABOVE)
			{
				this.addChild(cast this._topDrawer);
			}
			else //below
			{
				this.addChildAt(cast this._topDrawer, 0);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._topDrawer;
	}
	
	/**
	 * @private
	 */
	public var topDrawerDivider(get, set):DisplayObject;
	private var _topDrawerDivider:DisplayObject;
	private function get_topDrawerDivider():DisplayObject { return this._topDrawerDivider; }
	private function set_topDrawerDivider(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("topDrawerDivider"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._topDrawerDivider == value)
		{
			return value;
		}
		if (this._topDrawerDivider != null && this._topDrawerDivider.parent == this)
		{
			this.removeChild(this._topDrawerDivider, false);
		}
		this._topDrawerDivider = value;
		if (this._topDrawerDivider != null)
		{
			this._topDrawerDivider.visible = false;
			this.addChild(this._topDrawerDivider);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._topDrawerDivider;
	}
	
	/**
	 * Determines if the top drawer is docked in all, some, or no stage
	 * orientations. The current stage orientation is determined by
	 * calculating the aspect ratio of the stage.
	 *
	 * <p>In the following example, the top drawer is docked in the
	 * landscape stage orientation:</p>
	 *
	 * <listing version="3.0">
	 * drawers.topDrawerDockMode = Orientation.LANDSCAPE;</listing>
	 *
	 * @default feathers.layout.Orientation.NONE
	 *
	 * @see feathers.layout.Orientation#PORTRAIT
	 * @see feathers.layout.Orientation#LANDSCAPE
	 * @see feathers.layout.Orientation#NONE
	 * @see feathers.layout.Orientation#BOTH
	 * @see #topDrawer
	 */
	public var topDrawerDockMode(get, set):String;
	private var _topDrawerDockMode:String = Orientation.NONE;
	private function get_topDrawerDockMode():String { return this._topDrawerDockMode; }
	private function set_topDrawerDockMode(value:String):String
	{
		if (this._topDrawerDockMode == value)
		{
			return value;
		}
		this._topDrawerDockMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._topDrawerDockMode;
	}
	
	/**
	 * When this event is dispatched by the content event dispatcher, the
	 * top drawer will toggle open and closed.
	 *
	 * <p>In the following example, the top drawer is toggled when the
	 * content dispatches an event of type <code>Event.OPEN</code>:</p>
	 *
	 * <listing version="3.0">
	 * drawers.topDrawerToggleEventType = Event.OPEN;</listing>
	 *
	 * @default null
	 *
	 * @see #content
	 * @see #topDrawer
	 */
	public var topDrawerToggleEventType(get, set):String;
	private var _topDrawerToggleEventType:String;
	private function get_topDrawerToggleEventType():String { return this._topDrawerToggleEventType; }
	private function set_topDrawerToggleEventType(value:String):String
	{
		if (this._topDrawerToggleEventType == value)
		{
			return value;
		}
		if (this.contentEventDispatcher != null && this._topDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.removeEventListener(this._topDrawerToggleEventType, content_topDrawerToggleEventTypeHandler);
		}
		this._topDrawerToggleEventType = value;
		if (this.contentEventDispatcher != null && this._topDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.addEventListener(this._topDrawerToggleEventType, content_topDrawerToggleEventTypeHandler);
		}
		return this._topDrawerToggleEventType;
	}
	
	/**
	 * Indicates if the top drawer is currently open. If you want to check
	 * if the top drawer is docked, check <code>isTopDrawerDocked</code>
	 * instead.
	 *
	 * <p>To animate the top drawer open or closed, call
	 * <code>toggleTopDrawer()</code>. Setting <code>isTopDrawerOpen</code>
	 * will open or close the top drawer without animation.</p>
	 *
	 * <p>In the following example, we check if the top drawer is open:</p>
	 *
	 * <listing version="3.0">
	 * if( drawers.isTopDrawerOpen )
	 * {
	 *     // do something
	 * }</listing>
	 *
	 * @default false
	 *
	 * @see #isTopDrawerDocked
	 * @see #topDrawer
	 * @see #toggleTopDrawer()
	 */
	public var isTopDrawerOpen(get, set):Bool;
	private var _isTopDrawerOpen:Bool = false;
	private function get_isTopDrawerOpen():Bool { return this._topDrawer != null && this._isTopDrawerOpen; }
	private function set_isTopDrawerOpen(value:Bool):Bool
	{
		if (this.isTopDrawerDocked || this._isTopDrawerOpen == value)
		{
			return value;
		}
		if (value)
		{
			this.isRightDrawerOpen = false;
			this.isBottomDrawerOpen = false;
			this.isLeftDrawerOpen = false;
		}
		this._isTopDrawerOpen = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isTopDrawerOpen;
	}
	
	/**
	 * Indicates if the top drawer is currently docked. Docking behavior of
	 * the top drawer is controlled with the <code>topDrawerDockMode</code>
	 * property. To check if the top drawer is open, but not docked, use
	 * the <code>isTopDrawerOpen</code> property.
	 *
	 * @see #topDrawer
	 * @see #topDrawerDockMode
	 * @see #isTopDrawerOpen
	 */
	public var isTopDrawerDocked(get, never):Bool;
	private function get_isTopDrawerDocked():Bool
	{
		if (this._topDrawer == null)
		{
			return false;
		}
		if (this._topDrawerDockMode == Orientation.BOTH)
		{
			return true;
		}
		if (this._topDrawerDockMode == Orientation.NONE)
		{
			return false;
		}
		var stage:Stage = this.stage;
		if (stage == null)
		{
			//fall back to the current stage, but it may be wrong...
			stage = Starling.current.stage;
		}
		if (stage.stageWidth > stage.stageHeight)
		{
			return this._topDrawerDockMode == Orientation.LANDSCAPE;
		}
		return this._topDrawerDockMode == Orientation.PORTRAIT;
	}
	
	/**
	 * @private
	 */
	private var _originalRightDrawerWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _originalRightDrawerHeight:Float = Math.NaN;
	
	/**
	 * The drawer that appears to the right of the primary content.
	 *
	 * <p>In the following example, a <code>List</code> is added as the
	 * right drawer:</p>
	 *
	 * <listing version="3.0">
	 * var list:List = new List();
	 * // set data provider and other properties here
	 * drawers.rightDrawer = list;</listing>
	 *
	 * @default null
	 *
	 * @see #rightDrawerDockMode
	 * @see #rightDrawerToggleEventType
	 */
	public var rightDrawer(get, set):IFeathersControl;
	private var _rightDrawer:IFeathersControl;
	private function get_rightDrawer():IFeathersControl { return this._rightDrawer; }
	private function set_rightDrawer(value:IFeathersControl):IFeathersControl
	{
		if (this._rightDrawer == value)
		{
			return value;
		}
		if (this.isRightDrawerOpen && value == null)
		{
			this.isRightDrawerOpen = false;
		}
		if (this._rightDrawer != null && this._rightDrawer.parent == this)
		{
			this.removeChild(cast this._rightDrawer, false);
		}
		this._rightDrawer = value;
		this._originalRightDrawerWidth = Math.NaN;
		this._originalRightDrawerHeight = Math.NaN;
		if (this._rightDrawer != null)
		{
			this._rightDrawer.visible = false;
			this._rightDrawer.addEventListener(FeathersEventType.RESIZE, drawer_resizeHandler);
			if (this._openMode == RelativeDepth.ABOVE)
			{
				this.addChild(cast this._rightDrawer);
			}
			else //below
			{
				this.addChildAt(cast this._rightDrawer, 0);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._rightDrawer;
	}
	
	/**
	 * @private
	 */
	public var rightDrawerDivider(get, set):DisplayObject;
	private var _rightDrawerDivider:DisplayObject;
	private function get_rightDrawerDivider():DisplayObject { return this._rightDrawerDivider; }
	private function set_rightDrawerDivider(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("rightDrawerDivider"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._rightDrawerDivider == value)
		{
			return value;
		}
		if (this._rightDrawerDivider != null && this._rightDrawerDivider.parent == this)
		{
			this.removeChild(this._rightDrawerDivider, false);
		}
		this._rightDrawerDivider = value;
		if (this._rightDrawerDivider != null)
		{
			this._rightDrawerDivider.visible = false;
			this.addChild(this._rightDrawerDivider);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._rightDrawerDivider;
	}
	
	/**
	 * Determines if the right drawer is docked in all, some, or no stage
	 * orientations. The current stage orientation is determined by
	 * calculating the aspect ratio of the stage.
	 *
	 * <p>In the following example, the right drawer is docked in the
	 * landscape stage orientation:</p>
	 *
	 * <listing version="3.0">
	 * drawers.rightDrawerDockMode = Orientation.LANDSCAPE;</listing>
	 *
	 * @default feathers.layout.Orientation.NONE
	 *
	 * @see feathers.layout.Orientation#PORTRAIT
	 * @see feathers.layout.Orientation#LANDSCAPE
	 * @see feathers.layout.Orientation#NONE
	 * @see feathers.layout.Orientation#BOTH
	 * @see #rightDrawer
	 */
	public var rightDrawerDockMode(get, set):String;
	private var _rightDrawerDockMode:String = Orientation.NONE;
	private function get_rightDrawerDockMode():String { return this._rightDrawerDockMode; }
	private function set_rightDrawerDockMode(value:String):String
	{
		if (this._rightDrawerDockMode == value)
		{
			return value;
		}
		this._rightDrawerDockMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._rightDrawerDockMode;
	}
	
	/**
	 * When this event is dispatched by the content event dispatcher, the
	 * right drawer will toggle open and closed.
	 *
	 * <p>In the following example, the right drawer is toggled when the
	 * content dispatches an event of type <code>Event.OPEN</code>:</p>
	 *
	 * <listing version="3.0">
	 * drawers.rightDrawerToggleEventType = Event.OPEN;</listing>
	 *
	 * @default null
	 *
	 * @see #content
	 * @see #rightDrawer
	 */
	public var rightDrawerToggleEventType(get, set):String;
	private var _rightDrawerToggleEventType:String;
	private function get_rightDrawerToggleEventType():String { return this._rightDrawerToggleEventType; }
	private function set_rightDrawerToggleEventType(value:String):String
	{
		if (this._rightDrawerToggleEventType == value)
		{
			return value;
		}
		if (this.contentEventDispatcher != null && this._rightDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.removeEventListener(this._rightDrawerToggleEventType, content_rightDrawerToggleEventTypeHandler);
		}
		this._rightDrawerToggleEventType = value;
		if (this.contentEventDispatcher != null && this._rightDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.addEventListener(this._rightDrawerToggleEventType, content_rightDrawerToggleEventTypeHandler);
		}
		return this._rightDrawerToggleEventType;
	}
	
	/**
	 * Indicates if the right drawer is currently open. If you want to check
	 * if the right drawer is docked, check <code>isRightDrawerDocked</code>
	 * instead.
	 *
	 * <p>To animate the right drawer open or closed, call
	 * <code>toggleRightDrawer()</code>. Setting <code>isRightDrawerOpen</code>
	 * will open or close the right drawer without animation.</p>
	 *
	 * <p>In the following example, we check if the right drawer is open:</p>
	 *
	 * <listing version="3.0">
	 * if( drawers.isRightDrawerOpen )
	 * {
	 *     // do something
	 * }</listing>
	 *
	 * @default false
	 *
	 * @see #rightDrawer
	 * @see #rightDrawerDockMode
	 * @see #toggleRightDrawer()
	 */
	public var isRightDrawerOpen(get, set):Bool;
	private var _isRightDrawerOpen:Bool = false;
	private function get_isRightDrawerOpen():Bool { return this._rightDrawer != null && this._isRightDrawerOpen; }
	private function set_isRightDrawerOpen(value:Bool):Bool
	{
		if (this.isRightDrawerDocked || this._isRightDrawerOpen == value)
		{
			return value;
		}
		if (value)
		{
			this.isTopDrawerOpen = false;
			this.isBottomDrawerOpen = false;
			this.isLeftDrawerOpen = false;
		}
		this._isRightDrawerOpen = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isRightDrawerOpen;
	}
	
	/**
	 * Indicates if the right drawer is currently docked. Docking behavior of
	 * the right drawer is controlled with the <code>rightDrawerDockMode</code>
	 * property. To check if the right drawer is open, but not docked, use
	 * the <code>isRightDrawerOpen</code> property.
	 *
	 * @see #rightDrawer
	 * @see #rightDrawerDockMode
	 * @see #isRightDrawerOpen
	 */
	public var isRightDrawerDocked(get, never):Bool;
	private function get_isRightDrawerDocked():Bool
	{
		if (this._rightDrawer == null)
		{
			return false;
		}
		if (this._rightDrawerDockMode == Orientation.BOTH)
		{
			return true;
		}
		if (this._rightDrawerDockMode == Orientation.NONE)
		{
			return false;
		}
		var stage:Stage = this.stage;
		if (stage == null)
		{
			//fall back to the current stage, but it may be wrong...
			stage = Starling.current.stage;
		}
		if (stage.stageWidth > stage.stageHeight)
		{
			return this._rightDrawerDockMode == Orientation.LANDSCAPE;
		}
		return this._rightDrawerDockMode == Orientation.PORTRAIT;
	}
	
	/**
	 * @private
	 */
	private var _originalBottomDrawerWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _originalBottomDrawerHeight:Float = Math.NaN;
	
	/**
	 * The drawer that appears below the primary content.
	 *
	 * <p>In the following example, a <code>List</code> is added as the
	 * bottom drawer:</p>
	 *
	 * <listing version="3.0">
	 * var list:List = new List();
	 * // set data provider and other properties here
	 * drawers.bottomDrawer = list;</listing>
	 *
	 * @default null
	 *
	 * @see #bottomDrawerDockMode
	 * @see #bottomDrawerToggleEventType
	 */
	public var bottomDrawer(get, set):IFeathersControl;
	private var _bottomDrawer:IFeathersControl;
	private function get_bottomDrawer():IFeathersControl { return this._bottomDrawer; }
	private function set_bottomDrawer(value:IFeathersControl):IFeathersControl
	{
		if (this._bottomDrawer == value)
		{
			return value;
		}
		if (this.isBottomDrawerOpen && value == null)
		{
			this.isBottomDrawerOpen = false;
		}
		if (this._bottomDrawer != null && this._bottomDrawer.parent == this)
		{
			this.removeChild(cast this._bottomDrawer, false);
		}
		this._bottomDrawer = value;
		this._originalBottomDrawerWidth = Math.NaN;
		this._originalBottomDrawerHeight = Math.NaN;
		if (this._bottomDrawer != null)
		{
			this._bottomDrawer.visible = false;
			this._bottomDrawer.addEventListener(FeathersEventType.RESIZE, drawer_resizeHandler);
			if (this._openMode == RelativeDepth.ABOVE)
			{
				this.addChild(cast this._bottomDrawer);
			}
			else //below
			{
				this.addChildAt(cast this._bottomDrawer, 0);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._bottomDrawer;
	}
	
	/**
	 * @private
	 */
	public var bottomDrawerDivider(get, set):DisplayObject;
	private var _bottomDrawerDivider:DisplayObject;
	private function get_bottomDrawerDivider():DisplayObject { return this._bottomDrawerDivider; }
	private function set_bottomDrawerDivider(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("bottomDrawerDivider"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._bottomDrawerDivider == value)
		{
			return value;
		}
		if (this._bottomDrawerDivider != null && this._bottomDrawerDivider.parent == this)
		{
			this.removeChild(this._bottomDrawerDivider, false);
		}
		this._bottomDrawerDivider = value;
		if (this._bottomDrawerDivider != null)
		{
			this._bottomDrawerDivider.visible = false;
			this.addChild(this._bottomDrawerDivider);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._bottomDrawerDivider;
	}
	
	/**
	 * Determines if the bottom drawer is docked in all, some, or no stage
	 * orientations. The current stage orientation is determined by
	 * calculating the aspect ratio of the stage.
	 *
	 * <p>In the following example, the bottom drawer is docked in the
	 * landscape stage orientation:</p>
	 *
	 * <listing version="3.0">
	 * drawers.bottomDrawerDockMode = Orientation.LANDSCAPE;</listing>
	 *
	 * @default feathers.layout.Orientation.NONE
	 *
	 * @see feathers.layout.Orientation#PORTRAIT
	 * @see feathers.layout.Orientation#LANDSCAPE
	 * @see feathers.layout.Orientation#NONE
	 * @see feathers.layout.Orientation#BOTH
	 * @see #bottomDrawer
	 */
	public var bottomDrawerDockMode(get, set):String;
	private var _bottomDrawerDockMode:String = Orientation.NONE;
	private function get_bottomDrawerDockMode():String { return this._bottomDrawerDockMode; }
	private function set_bottomDrawerDockMode(value:String):String
	{
		if (this._bottomDrawerDockMode == value)
		{
			return value;
		}
		this._bottomDrawerDockMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._bottomDrawerDockMode;
	}
	
	/**
	 * When this event is dispatched by the content event dispatcher, the
	 * bottom drawer will toggle open and closed.
	 *
	 * <p>In the following example, the bottom drawer is toggled when the
	 * content dispatches an event of type <code>Event.OPEN</code>:</p>
	 *
	 * <listing version="3.0">
	 * drawers.bottomDrawerToggleEventType = Event.OPEN;</listing>
	 *
	 * @default null
	 *
	 * @see #content
	 * @see #bottomDrawer
	 */
	public var bottomDrawerToggleEventType(get, set):String;
	private var _bottomDrawerToggleEventType:String;
	private function get_bottomDrawerToggleEventType():String { return this._bottomDrawerToggleEventType; }
	private function set_bottomDrawerToggleEventType(value:String):String
	{
		if (this._bottomDrawerToggleEventType == value)
		{
			return value;
		}
		if (this.contentEventDispatcher != null && this._bottomDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.removeEventListener(this._bottomDrawerToggleEventType, content_bottomDrawerToggleEventTypeHandler);
		}
		this._bottomDrawerToggleEventType = value;
		if (this.contentEventDispatcher != null && this._bottomDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.addEventListener(this._bottomDrawerToggleEventType, content_bottomDrawerToggleEventTypeHandler);
		}
		return this._bottomDrawerToggleEventType;
	}
	
	/**
	 * Indicates if the bottom drawer is currently open. If you want to check
	 * if the bottom drawer is docked, check <code>isBottomDrawerDocked</code>
	 * instead.
	 *
	 * <p>To animate the bottom drawer open or closed, call
	 * <code>toggleBottomDrawer()</code>. Setting <code>isBottomDrawerOpen</code>
	 * will open or close the bottom drawer without animation.</p>
	 *
	 * <p>In the following example, we check if the bottom drawer is open:</p>
	 *
	 * <listing version="3.0">
	 * if( drawers.isBottomDrawerOpen )
	 * {
	 *     // do something
	 * }</listing>
	 *
	 * @default false
	 *
	 * @see #bottomDrawer
	 * @see #isBottomDrawerOpen
	 * @see #toggleBottomDrawer()
	 */
	public var isBottomDrawerOpen(get, set):Bool;
	private var _isBottomDrawerOpen:Bool = false;
	private function get_isBottomDrawerOpen():Bool { return this._bottomDrawer != null && this._isBottomDrawerOpen; }
	private function set_isBottomDrawerOpen(value:Bool):Bool
	{
		if (this.isBottomDrawerDocked || this._isBottomDrawerOpen == value)
		{
			return value;
		}
		if (value)
		{
			this.isTopDrawerOpen = false;
			this.isRightDrawerOpen = false;
			this.isLeftDrawerOpen = false;
		}
		this._isBottomDrawerOpen = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isBottomDrawerOpen;
	}
	
	/**
	 * Indicates if the bottom drawer is currently docked. Docking behavior of
	 * the bottom drawer is controlled with the <code>bottomDrawerDockMode</code>
	 * property. To check if the bottom drawer is open, but not docked, use
	 * the <code>isBottomDrawerOpen</code> property.
	 *
	 * @see #bottomDrawer
	 * @see #bottomDrawerDockMode
	 * @see #isBottomDrawerOpen
	 */
	public var isBottomDrawerDocked(get, never):Bool;
	private function get_isBottomDrawerDocked():Bool
	{
		if (this._bottomDrawer == null)
		{
			return false;
		}
		if (this._bottomDrawerDockMode == Orientation.BOTH)
		{
			return true;
		}
		if (this._bottomDrawerDockMode == Orientation.NONE)
		{
			return false;
		}
		var stage:Stage = this.stage;
		if (stage == null)
		{
			//fall back to the current stage, but it may be wrong...
			stage = Starling.current.stage;
		}
		if (stage.stageWidth > stage.stageHeight)
		{
			return this._bottomDrawerDockMode == Orientation.LANDSCAPE;
		}
		return this._bottomDrawerDockMode == Orientation.PORTRAIT;
	}
	
	/**
	 * @private
	 */
	private var _originalLeftDrawerWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _originalLeftDrawerHeight:Float = Math.NaN;
	
	/**
	 * The drawer that appears below the primary content.
	 *
	 * <p>In the following example, a <code>List</code> is added as the
	 * left drawer:</p>
	 *
	 * <listing version="3.0">
	 * var list:List = new List();
	 * // set data provider and other properties here
	 * drawers.leftDrawer = list;</listing>
	 *
	 * @default null
	 *
	 * @see #leftDrawerDockMode
	 * @see #leftDrawerToggleEventType
	 */
	public var leftDrawer(get, set):IFeathersControl;
	private var _leftDrawer:IFeathersControl;
	private function get_leftDrawer():IFeathersControl { return this._leftDrawer; }
	private function set_leftDrawer(value:IFeathersControl):IFeathersControl
	{
		if (this._leftDrawer == value)
		{
			return value;
		}
		if (this.isLeftDrawerOpen && value == null)
		{
			this.isLeftDrawerOpen = false;
		}
		if (this._leftDrawer != null && this._leftDrawer.parent == this)
		{
			this.removeChild(cast this._leftDrawer, false);
		}
		this._leftDrawer = value;
		this._originalLeftDrawerWidth = Math.NaN;
		this._originalLeftDrawerHeight = Math.NaN;
		if (this._leftDrawer != null)
		{
			this._leftDrawer.visible = false;
			this._leftDrawer.addEventListener(FeathersEventType.RESIZE, drawer_resizeHandler);
			if (this._openMode == RelativeDepth.ABOVE)
			{
				this.addChild(cast this._leftDrawer);
			}
			else //below
			{
				this.addChildAt(cast this._leftDrawer, 0);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._leftDrawer;
	}
	
	/**
	 * @private
	 */
	public var leftDrawerDivider(get, set):DisplayObject;
	private var _leftDrawerDivider:DisplayObject;
	private function get_leftDrawerDivider():DisplayObject { return this._leftDrawerDivider; }
	private function set_leftDrawerDivider(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("leftDrawerDivider"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._leftDrawerDivider == value)
		{
			return value;
		}
		if (this._leftDrawerDivider != null && this._leftDrawerDivider.parent == this)
		{
			this.removeChild(this._leftDrawerDivider, false);
		}
		this._leftDrawerDivider = value;
		if (this._leftDrawerDivider != null)
		{
			this._leftDrawerDivider.visible = false;
			this.addChild(this._leftDrawerDivider);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._leftDrawerDivider;
	}
	
	/**
	 * Determines if the left drawer is docked in all, some, or no stage
	 * orientations. The current stage orientation is determined by
	 * calculating the aspect ratio of the stage.
	 *
	 * <p>In the following example, the left drawer is docked in the
	 * landscape stage orientation:</p>
	 *
	 * <listing version="3.0">
	 * drawers.leftDrawerDockMode = Orientation.LANDSCAPE;</listing>
	 *
	 * @default feathers.layout.Orientation.NONE
	 *
	 * @see feathers.layout.Orientation#PORTRAIT
	 * @see feathers.layout.Orientation#LANDSCAPE
	 * @see feathers.layout.Orientation#NONE
	 * @see feathers.layout.Orientation#BOTH
	 * @see #leftDrawer
	 */
	public var leftDrawerDockMode(get, set):String;
	private var _leftDrawerDockMode:String = Orientation.NONE;
	private function get_leftDrawerDockMode():String { return this._leftDrawerDockMode; }
	private function set_leftDrawerDockMode(value:String):String
	{
		if (this._leftDrawerDockMode == value)
		{
			return value;
		}
		this._leftDrawerDockMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._leftDrawerDockMode;
	}
	
	/**
	 * When this event is dispatched by the content event dispatcher, the
	 * left drawer will toggle open and closed.
	 *
	 * <p>In the following example, the left drawer is toggled when the
	 * content dispatches and event of type <code>Event.OPEN</code>:</p>
	 *
	 * <listing version="3.0">
	 * drawers.leftDrawerToggleEventType = Event.OPEN;</listing>
	 *
	 * @default null
	 *
	 * @see #content
	 * @see #leftDrawer
	 */
	public var leftDrawerToggleEventType(get, set):String;
	private var _leftDrawerToggleEventType:String;
	private function get_leftDrawerToggleEventType():String { return this._leftDrawerToggleEventType; }
	private function set_leftDrawerToggleEventType(value:String):String
	{
		if (this._leftDrawerToggleEventType == value)
		{
			return value;
		}
		if (this.contentEventDispatcher != null && this._leftDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.removeEventListener(this._leftDrawerToggleEventType, content_leftDrawerToggleEventTypeHandler);
		}
		this._leftDrawerToggleEventType = value;
		if (this.contentEventDispatcher != null && this._leftDrawerToggleEventType != null)
		{
			this.contentEventDispatcher.addEventListener(this._leftDrawerToggleEventType, content_leftDrawerToggleEventTypeHandler);
		}
		return this._leftDrawerToggleEventType;
	}
	
	/**
	 * Indicates if the left drawer is currently open. If you want to check
	 * if the left drawer is docked, check <code>isLeftDrawerDocked</code>
	 * instead.
	 *
	 * <p>To animate the left drawer open or closed, call
	 * <code>toggleLeftDrawer()</code>. Setting <code>isLeftDrawerOpen</code>
	 * will open or close the left drawer without animation.</p>
	 *
	 * <p>In the following example, we check if the left drawer is open:</p>
	 *
	 * <listing version="3.0">
	 * if( drawers.isLeftDrawerOpen )
	 * {
	 *     // do something
	 * }</listing>
	 *
	 * @default false
	 *
	 * @see #leftDrawer
	 * @see #isLeftDrawerDocked
	 * @see #toggleLeftDrawer()
	 */
	public var isLeftDrawerOpen(get, set):Bool;
	private var _isLeftDrawerOpen:Bool = false;
	private function get_isLeftDrawerOpen():Bool { return this._leftDrawer != null && this._isLeftDrawerOpen; }
	private function set_isLeftDrawerOpen(value:Bool):Bool
	{
		if (this.isLeftDrawerDocked || this._isLeftDrawerOpen == value)
		{
			return value;
		}
		if (value)
		{
			this.isTopDrawerOpen = false;
			this.isRightDrawerOpen = false;
			this.isBottomDrawerOpen = false;
		}
		this._isLeftDrawerOpen = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isLeftDrawerOpen;
	}
	
	/**
	 * Indicates if the left drawer is currently docked. Docking behavior of
	 * the left drawer is controlled with the <code>leftDrawerDockMode</code>
	 * property. To check if the left drawer is open, but not docked, use
	 * the <code>isLeftDrawerOpen</code> property.
	 *
	 * @see #leftDrawer
	 * @see #leftDrawerDockMode
	 * @see #isLeftDrawerOpen
	 */
	public var isLeftDrawerDocked(get, never):Bool;
	private function get_isLeftDrawerDocked():Bool
	{
		if (this._leftDrawer == null)
		{
			return false;
		}
		if (this._leftDrawerDockMode == Orientation.BOTH)
		{
			return true;
		}
		if (this._leftDrawerDockMode == Orientation.NONE)
		{
			return false;
		}
		var stage:Stage = this.stage;
		if (stage == null)
		{
			//fall back to the current stage, but it may be wrong...
			stage = Starling.current.stage;
		}
		if (stage.stageWidth > stage.stageHeight)
		{
			return this._leftDrawerDockMode == Orientation.LANDSCAPE;
		}
		return this._leftDrawerDockMode == Orientation.PORTRAIT;
	}
	
	/**
	 * Determines how the drawers container will set its own size when its
	 * dimensions (width and height) aren't set explicitly.
	 *
	 * <p>In the following example, the drawers container will be sized to
	 * match its content:</p>
	 *
	 * <listing version="3.0">
	 * drawers.autoSizeMode = AutoSizeMode.CONTENT;</listing>
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
		if (this._content != null)
		{
			if (this._autoSizeMode == AutoSizeMode.CONTENT)
			{
				this._content.addEventListener(FeathersEventType.RESIZE, content_resizeHandler);
			}
			else
			{
				this._content.removeEventListener(FeathersEventType.RESIZE, content_resizeHandler);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._autoSizeMode;
	}
	
	/**
	 * Determines if the drawers are clipped while opening or closing. If
	 * the content does not have a background, the drawers should
	 * generally be clipped so that the drawer does not show under the
	 * content. If the content has a fully opaque background that will
	 * conceal the drawers, then clipping may be disabled to potentially
	 * improve performance.
	 *
	 * <p>In the following example, clipping will be disabled:</p>
	 *
	 * <listing version="3.0">
	 * navigator.clipDrawers = false;</listing>
	 *
	 * @default true
	 *
	 * @see #topDrawer
	 * @see #rightDrawer
	 * @see #bottomDrawer
	 * @see #leftDrawer
	 */
	public var clipDrawers(get, set):Bool;
	private var _clipDrawers:Bool = true;
	private function get_clipDrawers():Bool { return this._clipDrawers; }
	private function set_clipDrawers(value:Bool):Bool
	{
		if (this._clipDrawers == value)
		{
			return value;
		}
		this._clipDrawers = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._clipDrawers;
	}
	
	/**
	 * @private
	 */
	public var openMode(get, set):String;
	private var _openMode:String = RelativeDepth.BELOW;
	private function get_openMode():String { return this._openMode; }
	private function set_openMode(value:String):String
	{
		//for legacy reasons, OPEN_MODE_ABOVE had a different string value
		if (value == "overlay")
		{
			value = RelativeDepth.ABOVE;
		}
		if (this.processStyleRestriction("openMode"))
		{
			return value;
		}
		if (this._openMode == value)
		{
			return value;
		}
		this._openMode = value;
		if (this._content != null)
		{
			if (this._openMode == RelativeDepth.ABOVE)
			{
				this.setChildIndex(cast this._content, 0);
			}
			else //below
			{
				if (this._overlaySkin != null)
				{
					//the content should below the overlay skin
					this.setChildIndex(cast this._content, this.numChildren - 1);
					this.setChildIndex(this._overlaySkin, this.numChildren - 1);
				}
				else
				{
					this.setChildIndex(cast this._content, this.numChildren - 1);
				}
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._openMode;
	}
	
	/**
	 * An optional touch gesture used to open a drawer.
	 *
	 * <p>In the following example, the drawers are opened by dragging
	 * anywhere inside the content:</p>
	 *
	 * <listing version="3.0">
	 * drawers.openGesture = DragGesture.CONTENT;</listing>
	 *
	 * @default feathers.controls.DragGesture.EDGE
	 *
	 * @see feathers.controls.DragGesture#NONE
	 * @see feathers.controls.DragGesture#CONTENT
	 * @see feathers.controls.DragGesture#EDGE
	 * @see #openGestureEdgeSize
	 */
	public var openGesture(get, set):String;
	private var _openGesture:String = DragGesture.EDGE;
	private function get_openGesture():String { return this._openGesture; }
	private function set_openGesture(value:String):String
	{
		if (value == "dragContent")
		{
			value = DragGesture.CONTENT;
		}
		else if (value == "dragContentEdge")
		{
			value = DragGesture.EDGE;
		}
		return this._openGesture = value;
	}
	
	/**
	 * The minimum physical distance (in inches) that a touch must move
	 * before a drag gesture begins.
	 *
	 * <p>In the following example, the minimum drag distance is customized:</p>
	 *
	 * <listing version="3.0">
	 * drawers.minimumDragDistance = 0.1;</listing>
	 *
	 * @default 0.04
	 */
	public var minimumDragDistance(get, set):Float;
	private var _minimumDragDistance:Float = 0.04;
	private function get_minimumDragDistance():Float { return this._minimumDragDistance; }
	private function set_minimumDragDistance(value:Float):Float
	{
		return this._minimumDragDistance = value;
	}
	
	/**
	 * The minimum physical velocity (in inches per second) that a touch
	 * must move before the a drawern can be "thrown" to open or close it.
	 * Otherwise, it will settle open or closed based on which state is
	 * closer when the touch ends.
	 *
	 * <p>In the following example, the minimum drawer throw velocity is customized:</p>
	 *
	 * <listing version="3.0">
	 * drawers.minimumDrawerThrowVelocity = 2;</listing>
	 *
	 * @default 5
	 */
	public var minimumDrawerThrowVelocity(get, set):Float;
	private var _minimumDrawerThrowVelocity:Float = 5;
	private function get_minimumDrawerThrowVelocity():Float { return this._minimumDrawerThrowVelocity; }
	private function set_minimumDrawerThrowVelocity(value:Float):Float
	{
		return this._minimumDrawerThrowVelocity = value;
	}
	
	/**
	 * The size (in inches) of the region near the edge of the content that
	 * can be dragged when the <code>openGesture</code> property is set to
	 * <code>DragGesture.EDGE</code>.
	 *
	 * <p>In the following example, the open gesture edge size is customized:</p>
	 *
	 * <listing version="3.0">
	 * drawers.openGestureEdgeSize = 0.25;</listing>
	 *
	 * @default 0.1
	 *
	 * @see #openGesture
	 * @see feathers.controls.DragGesture#EDGE
	 */
	public var openGestureEdgeSize(get, set):Float;
	private var _openGestureEdgeSize:Float = 0.1;
	private function get_openGestureEdgeSize():Float { return this._openGestureEdgeSize; }
	private function set_openGestureEdgeSize(value:Float):Float
	{
		return this._openGestureEdgeSize = value;
	}
	
	/**
	 * The event dispatched by the content to indicate that the content
	 * event dispatcher has changed. When this event is dispatched by the
	 * content, the drawers container will listen for the drawer toggle
	 * events from the new dispatcher that discovered using
	 * <code>contentEventDispatcherField</code> or
	 * <code>contentEventDispatcherFunction</code>.
	 *
	 * <p>For <code>StackScreenNavigator</code> and
	 * <code>ScreenNavigator</code> components, this value is automatically
	 * set to <code>Event.CHANGE</code>.</p>
	 *
	 * <p>In the following example, the drawers container will update its
	 * content event dispatcher when the content dispatches an event of type
	 * <code>Event.CHANGE</code>:</p>
	 *
	 * <listing version="3.0">
	 * drawers.contentEventDispatcherChangeEventType = Event.CHANGE;</listing>
	 *
	 * @default null
	 *
	 * @see #contentEventDispatcherField
	 * @see #contentEventDispatcherFunction
	 */
	public var contentEventDispatcherChangeEventType(get, set):String;
	private var _contentEventDispatcherChangeEventType:String;
	private function get_contentEventDispatcherChangeEventType():String { return this._contentEventDispatcherChangeEventType; }
	private function set_contentEventDispatcherChangeEventType(value:String):String
	{
		if (this._contentEventDispatcherChangeEventType == value)
		{
			return value;
		}
		if (this._content != null && this._contentEventDispatcherChangeEventType != null)
		{
			this._content.removeEventListener(this._contentEventDispatcherChangeEventType, content_eventDispatcherChangeHandler);
		}
		this._contentEventDispatcherChangeEventType = value;
		if (this._content != null && this._contentEventDispatcherChangeEventType != null)
		{
			this._content.addEventListener(this._contentEventDispatcherChangeEventType, content_eventDispatcherChangeHandler);
		}
		return this._contentEventDispatcherChangeEventType;
	}
	
	/**
	 * A property of the <code>content</code> that references an event
	 * dispatcher that dispatches events to toggle drawers open and closed.
	 *
	 * <p>For <code>StackScreenNavigator</code> and
	 * <code>ScreenNavigator</code> components, this value is automatically
	 * set to <code>"activeScreen"</code> to listen for events from the
	 * currently active/visible screen.</p>
	 *
	 * <p>In the following example, the content event dispatcher field is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * drawers.contentEventDispatcherField = "selectedChild";</listing>
	 *
	 * @default null
	 *
	 * @see #contentEventDispatcherFunction
	 * @see #contentEventDispatcherChangeEventType
	 * @see #topDrawerToggleEventType
	 * @see #rightDrawerToggleEventType
	 * @see #bottomDrawerToggleEventType
	 * @see #leftDrawerToggleEventType
	 */
	public var contentEventDispatcherField(get, set):String;
	private var _contentEventDispatcherField:String;
	private function get_contentEventDispatcherField():String { return this._contentEventDispatcherField; }
	private function set_contentEventDispatcherField(value:String):String
	{
		if (this._contentEventDispatcherField == value)
		{
			return value;
		}
		this._contentEventDispatcherField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentEventDispatcherField;
	}
	
	/**
	 * A function that returns an event dispatcher that dispatches events to
	 * toggle drawers open and closed.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function( content:DisplayObject ):EventDispatcher</pre>
	 *
	 * <p>In the following example, the content event dispatcher function is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * drawers.contentEventDispatcherField = function( content:CustomView ):void
	 * {
	 *     return content.selectedChild;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #contentEventDispatcherField
	 * @see #contentEventDispatcherChangeEventType
	 * @see #topDrawerToggleEventType
	 * @see #rightDrawerToggleEventType
	 * @see #bottomDrawerToggleEventType
	 * @see #leftDrawerToggleEventType
	 */
	public var contentEventDispatcherFunction(get, set):Function;
	private var _contentEventDispatcherFunction:Function;
	private function get_contentEventDispatcherFunction():Function { return this._contentEventDispatcherFunction; }
	private function set_contentEventDispatcherFunction(value:Function):Function
	{
		if (this._contentEventDispatcherFunction == value)
		{
			return value;
		}
		this._contentEventDispatcherFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentEventDispatcherFunction;
	}
	
	/**
	 * @private
	 */
	private var _openOrCloseTween:Tween;
	
	/**
	 * @private
	 */
	public var openOrCloseDuration(get, set):Float;
	private var _openOrCloseDuration:Float = 0.25;
	private function get_openOrCloseDuration():Float { return this._openOrCloseDuration; }
	private function set_openOrCloseDuration(value:Float):Float
	{
		if (this.processStyleRestriction("openOrCloseDuration"))
		{
			return value;
		}
		return this._openOrCloseDuration = value;
	}
	
	/**
	 * @private
	 */
	public var openOrCloseEase(get, set):String;
	private var _openOrCloseEase:String = Transitions.EASE_OUT;
	private function get_openOrCloseEase():String { return this._openOrCloseEase; }
	private function set_openOrCloseEase(value:String):String
	{
		if (this.processStyleRestriction("openOrCloseEase"))
		{
			return value;
		}
		return this._openOrCloseEase = value;
	}
	
	/**
	 * @private
	 */
	private var isToggleTopDrawerPending:Bool = false;

	/**
	 * @private
	 */
	private var isToggleRightDrawerPending:Bool = false;

	/**
	 * @private
	 */
	private var isToggleBottomDrawerPending:Bool = false;

	/**
	 * @private
	 */
	private var isToggleLeftDrawerPending:Bool = false;

	/**
	 * @private
	 */
	private var pendingToggleDuration:Float;

	/**
	 * @private
	 */
	private var touchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _isDragging:Bool = false;

	/**
	 * @private
	 */
	private var _isDraggingTopDrawer:Bool = false;

	/**
	 * @private
	 */
	private var _isDraggingRightDrawer:Bool = false;

	/**
	 * @private
	 */
	private var _isDraggingBottomDrawer:Bool = false;

	/**
	 * @private
	 */
	private var _isDraggingLeftDrawer:Bool = false;

	/**
	 * @private
	 */
	private var _startTouchX:Float;

	/**
	 * @private
	 */
	private var _startTouchY:Float;

	/**
	 * @private
	 */
	private var _currentTouchX:Float;

	/**
	 * @private
	 */
	private var _currentTouchY:Float;

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
	private var _previousTouchY:Float;

	/**
	 * @private
	 */
	private var _velocityX:Float = 0;

	/**
	 * @private
	 */
	private var _velocityY:Float = 0;

	/**
	 * @private
	 */
	private var _previousVelocityX:Array<Float> = new Array<Float>();

	/**
	 * @private
	 */
	private var _previousVelocityY:Array<Float> = new Array<Float>();
	
	/**
	 * @private
	 */
	override public function hitTest(localPoint:Point):DisplayObject
	{
		var result:DisplayObject = super.hitTest(localPoint);
		if (result != null)
		{
			if (this._isDragging)
			{
				return this;
			}
			if (this.isTopDrawerOpen && result != (cast this._topDrawer) && !(Std.isOfType(this._topDrawer, DisplayObjectContainer) && cast(this._topDrawer, DisplayObjectContainer).contains(result)))
			{
				return this;
			}
			else if (this.isRightDrawerOpen && result != (cast this._rightDrawer) && !(Std.isOfType(this._rightDrawer, DisplayObjectContainer) && cast(this._rightDrawer, DisplayObjectContainer).contains(result)))
			{
				return this;
			}
			else if (this.isBottomDrawerOpen && result != (cast this._bottomDrawer) && !(Std.isOfType(this._bottomDrawer, DisplayObjectContainer) && cast(this._bottomDrawer, DisplayObjectContainer).contains(result)))
			{
				return this;
			}
			else if (this.isLeftDrawerOpen && result != (cast this._leftDrawer) && !(Std.isOfType(this._leftDrawer, DisplayObjectContainer) && cast(this._leftDrawer, DisplayObjectContainer).contains(result)))
			{
				return this;
			}
			return result;
		}
		//we want to register touches in our hitArea as a last resort
		if (!this.visible || !this.touchable)
		{
			return null;
		}
		return this._hitArea.contains(localPoint.x, localPoint.y) ? this : null;
	}
	
	/**
	 * Opens or closes the top drawer. If the <code>duration</code> argument
	 * is <code>NaN</code>, the default <code>openOrCloseDuration</code> is
	 * used. The default value of the <code>duration</code> argument is
	 * <code>NaN</code>. Otherwise, this value is the duration of the
	 * animation, in seconds.
	 *
	 * <p>To open or close the top drawer without animation, set the
	 * <code>isTopDrawerOpen</code> property.</p>
	 *
	 * @see #isTopDrawerOpen
	 * @see #openOrCloseDuration
	 * @see #openOrCloseEase
	 */
	public function toggleTopDrawer(?duration:Float):Void
	{
		if (duration == null) duration = Math.NaN;
		
		if (this._topDrawer == null || this.isTopDrawerDocked)
		{
			return;
		}
		this.pendingToggleDuration = duration;
		if (this.isToggleTopDrawerPending)
		{
			return;
		}
		if (!this.isTopDrawerOpen)
		{
			this.isRightDrawerOpen = false;
			this.isBottomDrawerOpen = false;
			this.isLeftDrawerOpen = false;
		}
		this.isToggleTopDrawerPending = true;
		this.isToggleRightDrawerPending = false;
		this.isToggleBottomDrawerPending = false;
		this.isToggleLeftDrawerPending = false;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
	/**
	 * Opens or closes the right drawer. If the <code>duration</code> argument
	 * is <code>NaN</code>, the default <code>openOrCloseDuration</code> is
	 * used. The default value of the <code>duration</code> argument is
	 * <code>NaN</code>. Otherwise, this value is the duration of the
	 * animation, in seconds.
	 *
	 * <p>To open or close the right drawer without animation, set the
	 * <code>isRightDrawerOpen</code> property.</p>
	 *
	 * @see #isRightDrawerOpen
	 * @see #openOrCloseDuration
	 * @see #openOrCloseEase
	 */
	public function toggleRightDrawer(?duration:Float):Void
	{
		if (duration == null) duration = Math.NaN;
		
		if (this._rightDrawer == null || this.isRightDrawerDocked)
		{
			return;
		}
		this.pendingToggleDuration = duration;
		if (this.isToggleRightDrawerPending)
		{
			return;
		}
		if (!this.isRightDrawerOpen)
		{
			this.isTopDrawerOpen = false;
			this.isBottomDrawerOpen = false;
			this.isLeftDrawerOpen = false;
		}
		this.isToggleTopDrawerPending = false;
		this.isToggleRightDrawerPending = true;
		this.isToggleBottomDrawerPending = false;
		this.isToggleLeftDrawerPending = false;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
	/**
	 * Opens or closes the bottom drawer. If the <code>duration</code> argument
	 * is <code>NaN</code>, the default <code>openOrCloseDuration</code> is
	 * used. The default value of the <code>duration</code> argument is
	 * <code>NaN</code>. Otherwise, this value is the duration of the
	 * animation, in seconds.
	 *
	 * <p>To open or close the bottom drawer without animation, set the
	 * <code>isBottomDrawerOpen</code> property.</p>
	 *
	 * @see #isBottomDrawerOpen
	 * @see #openOrCloseDuration
	 * @see #openOrCloseEase
	 */
	public function toggleBottomDrawer(?duration:Float):Void
	{
		if (duration == null) duration = Math.NaN;
		
		if (this._bottomDrawer == null || this.isBottomDrawerDocked)
		{
			return;
		}
		this.pendingToggleDuration = duration;
		if (this.isToggleBottomDrawerPending)
		{
			return;
		}
		if (!this.isBottomDrawerOpen)
		{
			this.isTopDrawerOpen = false;
			this.isRightDrawerOpen = false;
			this.isLeftDrawerOpen = false;
		}
		this.isToggleTopDrawerPending = false;
		this.isToggleRightDrawerPending = false;
		this.isToggleBottomDrawerPending = true;
		this.isToggleLeftDrawerPending = false;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
	/**
	 * Opens or closes the left drawer. If the <code>duration</code> argument
	 * is <code>NaN</code>, the default <code>openOrCloseDuration</code> is
	 * used. The default value of the <code>duration</code> argument is
	 * <code>NaN</code>. Otherwise, this value is the duration of the
	 * animation, in seconds.
	 *
	 * <p>To open or close the left drawer without animation, set the
	 * <code>isLeftDrawerOpen</code> property.</p>
	 *
	 * @see #isLeftDrawerOpen
	 * @see #openOrCloseDuration
	 * @see #openOrCloseEase
	 */
	public function toggleLeftDrawer(?duration:Float):Void
	{
		if (duration == null) duration = Math.NaN;
		
		if (this._leftDrawer == null || this.isLeftDrawerDocked)
		{
			return;
		}
		this.pendingToggleDuration = duration;
		if (this.isToggleLeftDrawerPending)
		{
			return;
		}
		if (!this.isLeftDrawerOpen)
		{
			this.isTopDrawerOpen = false;
			this.isRightDrawerOpen = false;
			this.isBottomDrawerOpen = false;
		}
		this.isToggleTopDrawerPending = false;
		this.isToggleRightDrawerPending = false;
		this.isToggleBottomDrawerPending = false;
		this.isToggleLeftDrawerPending = true;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var selectedInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		
		if (dataInvalid)
		{
			this.refreshCurrentEventTarget();
		}
		
		if (sizeInvalid || layoutInvalid)
		{
			this.refreshDrawerStates();
		}
		if (sizeInvalid || layoutInvalid || selectedInvalid)
		{
			this.refreshOverlayState();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutChildren();
		
		this.handlePendingActions();
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
		
		var measureContent:Bool = this._autoSizeMode == AutoSizeMode.CONTENT || this.stage == null;
		var isTopDrawerDocked:Bool = this.isTopDrawerDocked;
		var isRightDrawerDocked:Bool = this.isRightDrawerDocked;
		var isBottomDrawerDocked:Bool = this.isBottomDrawerDocked;
		var isLeftDrawerDocked:Bool = this.isLeftDrawerDocked;
		if (measureContent)
		{
			if (this._content != null)
			{
				this._content.validate();
				if (this._originalContentWidth != this._originalContentWidth) //isNaN
				{
					this._originalContentWidth = this._content.width;
				}
				if (this._originalContentHeight != this._originalContentHeight) //isNaN
				{
					this._originalContentHeight = this._content.height;
				}
			}
			if (isTopDrawerDocked)
			{
				this._topDrawer.validate();
				if (this._originalTopDrawerWidth != this._originalTopDrawerWidth) //isNaN
				{
					this._originalTopDrawerWidth = this._topDrawer.width;
				}
				if (this._originalTopDrawerHeight != this._originalTopDrawerHeight) //isNaN
				{
					this._originalTopDrawerHeight = this._topDrawer.height;
				}
			}
			if (isRightDrawerDocked)
			{
				this._rightDrawer.validate();
				if (this._originalRightDrawerWidth != this._originalRightDrawerWidth) //isNaN
				{
					this._originalRightDrawerWidth = this._rightDrawer.width;
				}
				if (this._originalRightDrawerHeight != this._originalRightDrawerHeight) //isNaN
				{
					this._originalRightDrawerHeight = this._rightDrawer.height;
				}
			}
			if (isBottomDrawerDocked)
			{
				this._bottomDrawer.validate();
				if (this._originalBottomDrawerWidth != this._originalBottomDrawerWidth) //isNaN
				{
					this._originalBottomDrawerWidth = this._bottomDrawer.width;
				}
				if (this._originalBottomDrawerHeight != this._originalBottomDrawerHeight) //isNaN
				{
					this._originalBottomDrawerHeight = this._bottomDrawer.height;
				}
			}
			if (isLeftDrawerDocked)
			{
				this._leftDrawer.validate();
				if (this._originalLeftDrawerWidth != this._originalLeftDrawerWidth) //isNaN
				{
					this._originalLeftDrawerWidth = this._leftDrawer.width;
				}
				if (this._originalLeftDrawerHeight != this._originalLeftDrawerHeight) //isNaN
				{
					this._originalLeftDrawerHeight = this._leftDrawer.height;
				}
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (measureContent)
			{
				if (this._content != null)
				{
					newWidth = this._originalContentWidth;
				}
				else
				{
					newWidth = 0;
				}
				if (isLeftDrawerDocked)
				{
					newWidth += this._originalLeftDrawerWidth;
				}
				if (isRightDrawerDocked)
				{
					newWidth += this._originalRightDrawerWidth;
				}
				if (isTopDrawerDocked && this._originalTopDrawerWidth > newWidth)
				{
					newWidth = this._originalTopDrawerWidth;
				}
				if (isBottomDrawerDocked && this._originalBottomDrawerWidth > newWidth)
				{
					newWidth = this._originalBottomDrawerWidth;
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
			if (measureContent)
			{
				if (this._content != null)
				{
					newHeight = this._originalContentHeight;
				}
				else
				{
					newHeight = 0;
				}
				if (isTopDrawerDocked)
				{
					newHeight += this._originalTopDrawerHeight;
				}
				if (isBottomDrawerDocked)
				{
					newHeight += this._originalBottomDrawerHeight;
				}
				if (isLeftDrawerDocked && this._originalLeftDrawerHeight > newHeight)
				{
					newHeight = this._originalLeftDrawerHeight;
				}
				if (isRightDrawerDocked && this._originalRightDrawerHeight > newHeight)
				{
					newHeight = this._originalRightDrawerHeight;
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
			if (measureContent)
			{
				if (this._content != null)
				{
					newMinWidth = this._content.minWidth;
				}
				else
				{
					newMinWidth = 0;
				}
				if (isLeftDrawerDocked)
				{
					newMinWidth += this._leftDrawer.minWidth;
				}
				if (isRightDrawerDocked)
				{
					newMinWidth += this._rightDrawer.minWidth;
				}
				if (isTopDrawerDocked && this._topDrawer.minWidth > newMinWidth)
				{
					newMinWidth = this._topDrawer.minWidth;
				}
				if (isBottomDrawerDocked && this._bottomDrawer.minWidth > newMinWidth)
				{
					newMinWidth = this._bottomDrawer.minWidth;
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
			if (measureContent)
			{
				if (this._content != null)
				{
					newMinHeight = this._content.minHeight;
				}
				else
				{
					newMinHeight = 0;
				}
				if (isTopDrawerDocked)
				{
					newMinHeight += this._topDrawer.minHeight;
				}
				if (isBottomDrawerDocked)
				{
					newMinHeight += this._bottomDrawer.minHeight;
				}
				if (isLeftDrawerDocked && this._leftDrawer.minHeight > newMinHeight)
				{
					newMinHeight = this._leftDrawer.minHeight;
				}
				if (isRightDrawerDocked && this._rightDrawer.minHeight > newMinHeight)
				{
					newMinHeight = this._rightDrawer.minHeight;
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
	 * Positions and sizes the children.
	 */
	private function layoutChildren():Void
	{
		var isTopDrawerOpen:Bool = this.isTopDrawerOpen;
		var isRightDrawerOpen:Bool = this.isRightDrawerOpen;
		var isBottomDrawerOpen:Bool = this.isBottomDrawerOpen;
		var isLeftDrawerOpen:Bool = this.isLeftDrawerOpen;
		var isTopDrawerDocked:Bool = this.isTopDrawerDocked;
		var isRightDrawerDocked:Bool = this.isRightDrawerDocked;
		var isBottomDrawerDocked:Bool = this.isBottomDrawerDocked;
		var isLeftDrawerDocked:Bool = this.isLeftDrawerDocked;
		
		var topDrawerHeight:Float = 0;
		var bottomDrawerHeight:Float = 0;
		if (this._topDrawer != null)
		{
			this._topDrawer.width = this.actualWidth;
			this._topDrawer.validate();
			topDrawerHeight = this._topDrawer.height;
			if (this._topDrawerDivider != null)
			{
				this._topDrawerDivider.width = this._topDrawer.width;
				if (Std.isOfType(this._topDrawerDivider, IValidating))
				{
					cast(this._topDrawerDivider, IValidating).validate();
				}
			}
		}
		if (this._bottomDrawer != null)
		{
			this._bottomDrawer.width = this.actualWidth;
			this._bottomDrawer.validate();
			bottomDrawerHeight = this._bottomDrawer.height;
			if (this._bottomDrawerDivider != null)
			{
				this._bottomDrawerDivider.width = this._bottomDrawer.width;
				if (Std.isOfType(this._bottomDrawerDivider, IValidating))
				{
					cast(this._bottomDrawerDivider, IValidating).validate();
				}
			}
		}
		
		var contentHeight:Float = this.actualHeight;
		if (isTopDrawerDocked)
		{
			contentHeight -= topDrawerHeight;
			if (this._topDrawerDivider != null)
			{
				contentHeight -= this._topDrawerDivider.height;
			}
		}
		if (isBottomDrawerDocked)
		{
			contentHeight -= bottomDrawerHeight;
			if (this._bottomDrawerDivider != null)
			{
				contentHeight -= this._bottomDrawerDivider.height;
			}
		}
		if (contentHeight < 0)
		{
			contentHeight = 0;
		}
		
		var rightDrawerWidth:Float = 0;
		var leftDrawerWidth:Float = 0;
		if (this._rightDrawer != null)
		{
			if (isRightDrawerDocked)
			{
				this._rightDrawer.height = contentHeight;
			}
			else
			{
				this._rightDrawer.height = this.actualHeight;
			}
			this._rightDrawer.validate();
			rightDrawerWidth = this._rightDrawer.width;
			if (this._rightDrawerDivider != null)
			{
				this._rightDrawerDivider.height = this._rightDrawer.height;
				if (Std.isOfType(this._rightDrawerDivider, IValidating))
				{
					cast(this._rightDrawerDivider, IValidating).validate();
				}
			}
		}
		if (this._leftDrawer != null)
		{
			if (isLeftDrawerDocked)
			{
				this._leftDrawer.height = contentHeight;
			}
			else
			{
				this._leftDrawer.height = this.actualHeight;
			}
			this._leftDrawer.validate();
			leftDrawerWidth = this._leftDrawer.width;
			if (this._leftDrawerDivider != null)
			{
				this._leftDrawerDivider.height = this._leftDrawer.height;
				if (Std.isOfType(this._leftDrawerDivider, IValidating))
				{
					cast(this._leftDrawerDivider, IValidating).validate();
				}
			}
		}
		
		var contentWidth:Float = this.actualWidth;
		if (isLeftDrawerDocked)
		{
			contentWidth -= leftDrawerWidth;
			if (this._leftDrawerDivider != null)
			{
				contentWidth -= this._leftDrawerDivider.width;
			}
		}
		if (isRightDrawerDocked)
		{
			contentWidth -= rightDrawerWidth;
			if (this._rightDrawerDivider != null)
			{
				contentWidth -= this._rightDrawerDivider.width;
			}
		}
		if (contentWidth < 0)
		{
			contentWidth = 0;
		}
		
		var contentX:Float = 0;
		if (isRightDrawerOpen && this._openMode == RelativeDepth.BELOW)
		{
			contentX = -rightDrawerWidth;
			if (isLeftDrawerDocked)
			{
				contentX += leftDrawerWidth;
				if (this._leftDrawerDivider != null)
				{
					contentX += this._leftDrawerDivider.width;
				}
			}
		}
		else if ((isLeftDrawerOpen && this._openMode == RelativeDepth.BELOW) || isLeftDrawerDocked)
		{
			contentX = leftDrawerWidth;
			if (this._leftDrawerDivider != null && isLeftDrawerDocked)
			{
				contentX += this._leftDrawerDivider.width;
			}
		}
		var contentY:Float = 0;
		if (isBottomDrawerOpen && this._openMode == RelativeDepth.BELOW)
		{
			contentY = -bottomDrawerHeight;
			if (isTopDrawerDocked)
			{
				contentY += topDrawerHeight;
				if (this._topDrawerDivider != null)
				{
					contentY += this._topDrawerDivider.height;
				}
			}
		}
		else if ((isTopDrawerOpen && this._openMode == RelativeDepth.BELOW) || isTopDrawerDocked)
		{
			contentY = topDrawerHeight;
			if (this._topDrawerDivider != null && isTopDrawerDocked)
			{
				contentY += this._topDrawerDivider.height;
			}
		}
		if (this._content != null)
		{
			this._content.x = contentX;
			this._content.y = contentY;
			if (this._autoSizeMode != AutoSizeMode.CONTENT)
			{
				this._content.width = contentWidth;
				this._content.height = contentHeight;
				
				//final validation to avoid juggler next frame issues
				this._content.validate();
			}
		}

		if (this._topDrawer != null)
		{
			var topDrawerX:Float = 0;
			var topDrawerY:Float = 0;
			if (isTopDrawerDocked)
			{
				if (isBottomDrawerOpen && this._openMode == RelativeDepth.BELOW)
				{
					topDrawerY -= bottomDrawerHeight;
				}
				if (!isLeftDrawerDocked)
				{
					topDrawerX = contentX;
				}
			}
			else if (this._openMode == RelativeDepth.ABOVE &&
				!this._isTopDrawerOpen)
			{
				topDrawerY -= topDrawerHeight;
			}
			this._topDrawer.x = topDrawerX;
			this._topDrawer.y = topDrawerY;
			this._topDrawer.visible = isTopDrawerOpen || isTopDrawerDocked || this._isDraggingTopDrawer;
			if (this._topDrawerDivider != null)
			{
				this._topDrawerDivider.visible = isTopDrawerDocked;
				this._topDrawerDivider.x = topDrawerX;
				this._topDrawerDivider.y = topDrawerY + topDrawerHeight;
			}
			
			//final validation to avoid juggler next frame issues
			this._topDrawer.validate();
		}
		
		if (this._rightDrawer != null)
		{
			var rightDrawerX:Float = this.actualWidth - rightDrawerWidth;
			var rightDrawerY:Float = 0;
			if (isRightDrawerDocked)
			{
				rightDrawerX = contentX + contentWidth;
				if (this._rightDrawerDivider != null)
				{
					rightDrawerX += this._rightDrawerDivider.width;
				}
				rightDrawerY = contentY;
			}
			else if (this._openMode == RelativeDepth.ABOVE &&
				!this._isRightDrawerOpen)
			{
				rightDrawerX += rightDrawerWidth;
			}
			this._rightDrawer.x = rightDrawerX;
			this._rightDrawer.y = rightDrawerY;
			this._rightDrawer.visible = isRightDrawerOpen || isRightDrawerDocked || this._isDraggingRightDrawer;
			if (this._rightDrawerDivider != null)
			{
				this._rightDrawerDivider.visible = isRightDrawerDocked;
				this._rightDrawerDivider.x = rightDrawerX - this._rightDrawerDivider.width;
				this._rightDrawerDivider.y = rightDrawerY;
			}
			
			//final validation to avoid juggler next frame issues
			this._rightDrawer.validate();
		}
		
		if (this._bottomDrawer != null)
		{
			var bottomDrawerX:Float = 0;
			var bottomDrawerY:Float = this.actualHeight - bottomDrawerHeight;
			if (isBottomDrawerDocked)
			{
				if (!isLeftDrawerDocked)
				{
					bottomDrawerX = contentX;
				}
				bottomDrawerY = contentY + contentHeight;
				if (this._bottomDrawerDivider != null)
				{
					bottomDrawerY += this._bottomDrawerDivider.height;
				}
			}
			else if (this._openMode == RelativeDepth.ABOVE &&
				!this._isBottomDrawerOpen)
			{
				bottomDrawerY += bottomDrawerHeight;
			}
			this._bottomDrawer.x = bottomDrawerX;
			this._bottomDrawer.y = bottomDrawerY;
			this._bottomDrawer.visible = isBottomDrawerOpen || isBottomDrawerDocked || this._isDraggingBottomDrawer;
			if (this._bottomDrawerDivider != null)
			{
				this._bottomDrawerDivider.visible = isBottomDrawerDocked;
				this._bottomDrawerDivider.x = bottomDrawerX;
				this._bottomDrawerDivider.y = bottomDrawerY - this._bottomDrawerDivider.height;
			}
			
			//final validation to avoid juggler next frame issues
			this._bottomDrawer.validate();
		}
		
		if (this._leftDrawer != null)
		{
			var leftDrawerX:Float = 0;
			var leftDrawerY:Float = 0;
			if (isLeftDrawerDocked)
			{
				if (isRightDrawerOpen && this._openMode == RelativeDepth.BELOW)
				{
					leftDrawerX -= rightDrawerWidth;
				}
				leftDrawerY = contentY;
			}
			else if (this._openMode == RelativeDepth.ABOVE &&
				!this._isLeftDrawerOpen)
			{
				leftDrawerX -= leftDrawerWidth;
			}
			this._leftDrawer.x = leftDrawerX;
			this._leftDrawer.y = leftDrawerY;
			this._leftDrawer.visible = isLeftDrawerOpen || isLeftDrawerDocked || this._isDraggingLeftDrawer;
			if (this._leftDrawerDivider != null)
			{
				this._leftDrawerDivider.visible = isLeftDrawerDocked;
				this._leftDrawerDivider.x = leftDrawerX + leftDrawerWidth;
				this._leftDrawerDivider.y = leftDrawerY;
			}
			
			//final validation to avoid juggler next frame issues
			this._leftDrawer.validate();
		}
		
		if (this._overlaySkin != null)
		{
			this.positionOverlaySkin();
			this._overlaySkin.width = this.actualWidth;
			this._overlaySkin.height = this.actualHeight;
			
			//final validation to avoid juggler next frame issues
			if (Std.isOfType(this._overlaySkin, IValidating))
			{
				cast(this._overlaySkin, IValidating).validate();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function handlePendingActions():Void
	{
		if (this.isToggleTopDrawerPending)
		{
			this._isTopDrawerOpen = !this._isTopDrawerOpen;
			this.isToggleTopDrawerPending = false;
			this.openOrCloseTopDrawer();
		}
		else if (this.isToggleRightDrawerPending)
		{
			this._isRightDrawerOpen = !this._isRightDrawerOpen;
			this.isToggleRightDrawerPending = false;
			this.openOrCloseRightDrawer();
		}
		else if (this.isToggleBottomDrawerPending)
		{
			this._isBottomDrawerOpen = !this._isBottomDrawerOpen;
			this.isToggleBottomDrawerPending = false;
			this.openOrCloseBottomDrawer();
		}
		else if (this.isToggleLeftDrawerPending)
		{
			this._isLeftDrawerOpen = !this._isLeftDrawerOpen;
			this.isToggleLeftDrawerPending = false;
			this.openOrCloseLeftDrawer();
		}
	}
	
	/**
	 * @private
	 */
	private function openOrCloseTopDrawer():Void
	{
		if (this._topDrawer == null || this.isTopDrawerDocked)
		{
			return;
		}
		if (this._openOrCloseTween != null)
		{
			this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
			Starling.currentJuggler.remove(this._openOrCloseTween);
			this._openOrCloseTween = null;
		}
		this.prepareTopDrawer();
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = true;
			if (this._isTopDrawerOpen)
			{
				this._overlaySkin.alpha = 0;
			}
			else
			{
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
			}
		}
		var targetPosition:Float = this._isTopDrawerOpen ? this._topDrawer.height : 0;
		var duration:Float = this.pendingToggleDuration;
		if (duration != duration) //isNaN
		{
			duration = this._openOrCloseDuration;
		}
		this.pendingToggleDuration = Math.NaN;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			targetPosition = targetPosition == 0 ? -this._topDrawer.height : 0;
			this._openOrCloseTween = new Tween(this._topDrawer, duration, this._openOrCloseEase);
		}
		else //below
		{
			this._openOrCloseTween = new Tween(this._content, duration, this._openOrCloseEase);
		}
		this._openOrCloseTween.animate("y", targetPosition);
		this._openOrCloseTween.onUpdate = topDrawerOpenOrCloseTween_onUpdate;
		this._openOrCloseTween.onComplete = topDrawerOpenOrCloseTween_onComplete;
		Starling.currentJuggler.add(this._openOrCloseTween);
	}
	
	/**
	 * @private
	 */
	private function openOrCloseRightDrawer():Void
	{
		if (this._rightDrawer == null || this.isRightDrawerDocked)
		{
			return;
		}
		if (this._openOrCloseTween != null)
		{
			this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
			Starling.currentJuggler.remove(this._openOrCloseTween);
			this._openOrCloseTween = null;
		}
		this.prepareRightDrawer();
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = true;
			if (this._isRightDrawerOpen)
			{
				this._overlaySkin.alpha = 0;
			}
			else
			{
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
			}
		}
		var targetPosition:Float = 0;
		if (this._isRightDrawerOpen)
		{
			targetPosition = -this._rightDrawer.width;
		}
		if (this.isLeftDrawerDocked && this._openMode == RelativeDepth.BELOW)
		{
			targetPosition += this._leftDrawer.width;
			if (this._leftDrawerDivider != null)
			{
				targetPosition += this._leftDrawerDivider.width;
			}
		}
		var duration:Float = this.pendingToggleDuration;
		if (duration != duration) //isNaN
		{
			duration = this._openOrCloseDuration;
		}
		this.pendingToggleDuration = Math.NaN;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			this._openOrCloseTween = new Tween(this._rightDrawer, duration, this._openOrCloseEase);
			targetPosition += this.actualWidth;
		}
		else //below
		{
			this._openOrCloseTween = new Tween(this._content, duration, this._openOrCloseEase);
		}
		this._openOrCloseTween.animate("x", targetPosition);
		this._openOrCloseTween.onUpdate = rightDrawerOpenOrCloseTween_onUpdate;
		this._openOrCloseTween.onComplete = rightDrawerOpenOrCloseTween_onComplete;
		Starling.currentJuggler.add(this._openOrCloseTween);
	}
	
	/**
	 * @private
	 */
	private function openOrCloseBottomDrawer():Void
	{
		if (this._bottomDrawer == null || this.isBottomDrawerDocked)
		{
			return;
		}
		if (this._openOrCloseTween != null)
		{
			this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
			Starling.currentJuggler.remove(this._openOrCloseTween);
			this._openOrCloseTween = null;
		}
		this.prepareBottomDrawer();
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = true;
			if (this._isBottomDrawerOpen)
			{
				this._overlaySkin.alpha = 0;
			}
			else
			{
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
			}
		}
		var targetPosition:Float = 0;
		if (this._isBottomDrawerOpen)
		{
			targetPosition = -this._bottomDrawer.height;
		}
		if (this.isTopDrawerDocked && this._openMode == RelativeDepth.BELOW)
		{
			targetPosition += this._topDrawer.height;
			if (this._topDrawerDivider != null)
			{
				targetPosition += this._topDrawerDivider.height;
			}
		}
		var duration:Float = this.pendingToggleDuration;
		if (duration != duration) //isNaN
		{
			duration = this._openOrCloseDuration;
		}
		this.pendingToggleDuration = Math.NaN;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			targetPosition += this.actualHeight;
			this._openOrCloseTween = new Tween(this._bottomDrawer, duration, this._openOrCloseEase);
		}
		else //below
		{
			this._openOrCloseTween = new Tween(this._content, duration, this._openOrCloseEase);
		}
		this._openOrCloseTween.animate("y", targetPosition);
		this._openOrCloseTween.onUpdate = bottomDrawerOpenOrCloseTween_onUpdate;
		this._openOrCloseTween.onComplete = bottomDrawerOpenOrCloseTween_onComplete;
		Starling.currentJuggler.add(this._openOrCloseTween);
	}
	
	/**
	 * @private
	 */
	private function openOrCloseLeftDrawer():Void
	{
		if (this._leftDrawer == null || this.isLeftDrawerDocked)
		{
			return;
		}
		if (this._openOrCloseTween != null)
		{
			this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
			Starling.currentJuggler.remove(this._openOrCloseTween);
			this._openOrCloseTween = null;
		}
		this.prepareLeftDrawer();
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = true;
			if (this._isLeftDrawerOpen)
			{
				this._overlaySkin.alpha = 0;
			}
			else
			{
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
			}
		}
		var targetPosition:Float = this._isLeftDrawerOpen ? this._leftDrawer.width : 0;
		var duration:Float = this.pendingToggleDuration;
		if (duration != duration) //isNaN
		{
			duration = this._openOrCloseDuration;
		}
		this.pendingToggleDuration = Math.NaN;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			targetPosition = targetPosition == 0 ? -this._leftDrawer.width : 0;
			this._openOrCloseTween = new Tween(this._leftDrawer, duration, this._openOrCloseEase);
		}
		else //below
		{
			this._openOrCloseTween = new Tween(this._content, duration, this._openOrCloseEase);
		}
		this._openOrCloseTween.animate("x", targetPosition);
		this._openOrCloseTween.onUpdate = leftDrawerOpenOrCloseTween_onUpdate;
		this._openOrCloseTween.onComplete = leftDrawerOpenOrCloseTween_onComplete;
		Starling.currentJuggler.add(this._openOrCloseTween);
	}
	
	/**
	 * @private
	 */
	private function prepareTopDrawer():Void
	{
		this._topDrawer.visible = true;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			if (this._overlaySkin != null)
			{
				this.setChildIndex(this._overlaySkin, this.numChildren - 1);
			}
			this.setChildIndex(cast this._topDrawer, this.numChildren - 1);
		}
		if (!this._clipDrawers || this._openMode != RelativeDepth.BELOW)
		{
			return;
		}
		if (this._topDrawer.mask == null)
		{
			var mask:Quad = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			//and these values might be 0
			mask.width = this.actualWidth;
			mask.height = this._content.y;
			this._topDrawer.mask = mask;
		}
	}
	
	/**
	 * @private
	 */
	private function prepareRightDrawer():Void
	{
		this._rightDrawer.visible = true;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			if (this._overlaySkin != null)
			{
				this.setChildIndex(this._overlaySkin, this.numChildren - 1);
			}
			this.setChildIndex(cast this._rightDrawer, this.numChildren - 1);
		}
		if (!this._clipDrawers || this._openMode != RelativeDepth.BELOW)
		{
			return;
		}
		if (this._rightDrawer.mask == null)
		{
			var mask:Quad = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			//and these values might be 0
			if (this.isLeftDrawerDocked)
			{
				mask.width = -this._leftDrawer.x;
			}
			else
			{
				mask.width = -this._content.x;
			}
			mask.height = this.actualHeight;
			this._rightDrawer.mask = mask;
		}
	}
	
	/**
	 * @private
	 */
	private function prepareBottomDrawer():Void
	{
		this._bottomDrawer.visible = true;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			if (this._overlaySkin != null)
			{
				this.setChildIndex(this._overlaySkin, this.numChildren - 1);
			}
			this.setChildIndex(cast this._bottomDrawer, this.numChildren - 1);
		}
		if (!this._clipDrawers || this._openMode != RelativeDepth.BELOW)
		{
			return;
		}
		if (this._bottomDrawer.mask == null)
		{
			var mask:Quad = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			//and these values might be 0
			mask.width = this.actualWidth;
			if (this.isTopDrawerDocked)
			{
				mask.height = -this._topDrawer.y;
			}
			else
			{
				mask.height = -this._content.y;
			}
			this._bottomDrawer.mask = mask;
		}
	}
	
	/**
	 * @private
	 */
	private function prepareLeftDrawer():Void
	{
		this._leftDrawer.visible = true;
		if (this._openMode == RelativeDepth.ABOVE)
		{
			if (this._overlaySkin != null)
			{
				this.setChildIndex(this._overlaySkin, this.numChildren - 1);
			}
			this.setChildIndex(cast this._leftDrawer, this.numChildren - 1);
		}
		if (!this._clipDrawers || this._openMode != RelativeDepth.BELOW)
		{
			return;
		}
		if (this._leftDrawer.mask == null)
		{
			var mask:Quad = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			//and these values might be 0
			mask.width = this._content.x;
			mask.height = this.actualHeight;
			this._leftDrawer.mask = mask;
		}
	}
	
	/**
	 * Uses the content event dispatcher fields and functions to generate a
	 * content event dispatcher icon for the content.
	 *
	 * <p>All of the content event dispatcher fields and functions, ordered
	 * by priority:</p>
	 * <ol>
	 *     <li><code>contentEventDispatcherFunction</code></li>
	 *     <li><code>contentEventDispatcherField</code></li>
	 * </ol>
	 *
	 * @see #content
	 * @see #contentEventDispatcherField
	 * @see #contentEventDispatcherFunction
	 * @see #contentEventDispatcherChangeEventType
	 */
	private function contentToContentEventDispatcher():EventDispatcher
	{
		if (this._contentEventDispatcherFunction != null)
		{
			return cast this._contentEventDispatcherFunction(this._content);
		}
		else if (this._contentEventDispatcherField != null && this._content != null && Reflect.hasField(this._content, this._contentEventDispatcherField))
		{
			return cast Reflect.getProperty(this._content, this._contentEventDispatcherField);
		}
		//return SafeCast.safe_cast(this._content, EventDispatcher);
		return cast this._content;
	}
	
	/**
	 * @private
	 */
	private function refreshCurrentEventTarget():Void
	{
		if (this.contentEventDispatcher != null)
		{
			if (this._topDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.removeEventListener(this._topDrawerToggleEventType, content_topDrawerToggleEventTypeHandler);
			}
			if (this._rightDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.removeEventListener(this._rightDrawerToggleEventType, content_rightDrawerToggleEventTypeHandler);
			}
			if (this._bottomDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.removeEventListener(this._bottomDrawerToggleEventType, content_bottomDrawerToggleEventTypeHandler);
			}
			if (this._leftDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.removeEventListener(this._leftDrawerToggleEventType, content_leftDrawerToggleEventTypeHandler);
			}
		}
		this.contentEventDispatcher = this.contentToContentEventDispatcher();
		if (this.contentEventDispatcher != null)
		{
			if (this._topDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.addEventListener(this._topDrawerToggleEventType, content_topDrawerToggleEventTypeHandler);
			}
			if (this._rightDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.addEventListener(this._rightDrawerToggleEventType, content_rightDrawerToggleEventTypeHandler);
			}
			if (this._bottomDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.addEventListener(this._bottomDrawerToggleEventType, content_bottomDrawerToggleEventTypeHandler);
			}
			if (this._leftDrawerToggleEventType != null)
			{
				this.contentEventDispatcher.addEventListener(this._leftDrawerToggleEventType, content_leftDrawerToggleEventTypeHandler);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshDrawerStates():Void
	{
		if (this.isTopDrawerDocked && this._isTopDrawerOpen)
		{
			this._isTopDrawerOpen = false;
		}
		if (this.isRightDrawerDocked && this._isRightDrawerOpen)
		{
			this._isRightDrawerOpen = false;
		}
		if (this.isBottomDrawerDocked && this._isBottomDrawerOpen)
		{
			this._isBottomDrawerOpen = false;
		}
		if (this.isLeftDrawerDocked && this._isLeftDrawerOpen)
		{
			this._isLeftDrawerOpen = false;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshOverlayState():Void
	{
		if (this._overlaySkin == null || this._isDragging)
		{
			return;
		}
		var showOverlay:Bool = (this._isTopDrawerOpen && !this.isTopDrawerDocked) ||
			(this._isRightDrawerOpen && !this.isRightDrawerDocked) ||
			(this._isBottomDrawerOpen && !this.isBottomDrawerDocked) ||
			(this._isLeftDrawerOpen && !this.isLeftDrawerDocked);
		if (showOverlay != this._overlaySkin.visible)
		{
			this._overlaySkin.visible = showOverlay;
			this._overlaySkin.alpha = showOverlay ? this._overlaySkinOriginalAlpha : 0;
		}
	}
	
	/**
	 * @private
	 */
	private function handleTapToClose(touch:Touch):Void
	{
		touch.getLocation(this.stage, HELPER_POINT);
		if (this != this.stage.hitTest(HELPER_POINT))
		{
			return;
		}
		
		if (this.isTopDrawerOpen)
		{
			this._isTopDrawerOpen = false;
			this.openOrCloseTopDrawer();
		}
		else if (this.isRightDrawerOpen)
		{
			this._isRightDrawerOpen = false;
			this.openOrCloseRightDrawer();
		}
		else if (this.isBottomDrawerOpen)
		{
			this._isBottomDrawerOpen = false;
			this.openOrCloseBottomDrawer();
		}
		else if (this.isLeftDrawerOpen)
		{
			this._isLeftDrawerOpen = false;
			this.openOrCloseLeftDrawer();
		}
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
		
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		touch.getLocation(this, HELPER_POINT);
		var localX:Float = HELPER_POINT.x;
		var localY:Float = HELPER_POINT.y;
		if (!this.isTopDrawerOpen && !this.isRightDrawerOpen && !this.isBottomDrawerOpen && !this.isLeftDrawerOpen)
		{
			if (this._openGesture == DragGesture.NONE)
			{
				return;
			}
			if (this._openGesture == DragGesture.EDGE)
			{
				var isNearAnyEdge:Bool = false;
				if (this._topDrawer != null && !this.isTopDrawerDocked)
				{
					var topInches:Float = localY / (DeviceCapabilities.dpi / starling.contentScaleFactor);
					if (topInches >= 0 && topInches <= this._openGestureEdgeSize)
					{
						isNearAnyEdge = true;
					}
				}
				if (!isNearAnyEdge)
				{
					if (this._rightDrawer != null && !this.isRightDrawerDocked)
					{
						var rightInches:Float = (this.actualWidth - localX) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
						if (rightInches >= 0 && rightInches <= this._openGestureEdgeSize)
						{
							isNearAnyEdge = true;
						}
					}
					if (!isNearAnyEdge)
					{
						if (this._bottomDrawer != null && !this.isBottomDrawerDocked)
						{
							var bottomInches:Float = (this.actualHeight - localY) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
							if (bottomInches >= 0 && bottomInches <= this._openGestureEdgeSize)
							{
								isNearAnyEdge = true;
							}
						}
						if (!isNearAnyEdge)
						{
							if (this._leftDrawer != null && !this.isLeftDrawerDocked)
							{
								var leftInches:Float = localX / (DeviceCapabilities.dpi / starling.contentScaleFactor);
								if (leftInches >= 0 && leftInches <= this._openGestureEdgeSize)
								{
									isNearAnyEdge = true;
								}
							}
						}
					}
				}
				if (!isNearAnyEdge)
				{
					return;
				}
			}
		}
		else if (this._openMode == RelativeDepth.BELOW && touch.target != this)
		{
			//when the drawer is opened below, it will only close when
			//something outside of the drawer is touched
			return;
		}
		//when the drawer is opened above, anything may be touched
		
		this.touchPointID = touch.id;
		this._velocityX = 0;
		this._velocityY = 0;
		this._previousVelocityX.resize(0);
		this._previousVelocityY.resize(0);
		this._previousTouchTime = getTimer();
		this._previousTouchX = this._startTouchX = this._currentTouchX = localX;
		this._previousTouchY = this._startTouchY = this._currentTouchY = localY;
		this._isDragging = false;
		this._isDraggingTopDrawer = false;
		this._isDraggingRightDrawer = false;
		this._isDraggingBottomDrawer = false;
		this._isDraggingLeftDrawer = false;
		
		exclusiveTouch.addEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
	}
	
	/**
	 * @private
	 */
	private function handleTouchMoved(touch:Touch):Void
	{
		touch.getLocation(this, HELPER_POINT);
		this._currentTouchX = HELPER_POINT.x;
		this._currentTouchY = HELPER_POINT.y;
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
			this._previousVelocityY[this._previousVelocityY.length] = this._velocityY;
			if (this._previousVelocityY.length > MAXIMUM_SAVED_VELOCITY_COUNT)
			{
				this._previousVelocityY.shift();
			}
			this._velocityX = (this._currentTouchX - this._previousTouchX) / timeOffset;
			this._velocityY = (this._currentTouchY - this._previousTouchY) / timeOffset;
			this._previousTouchTime = now;
			this._previousTouchX = this._currentTouchX;
			this._previousTouchY = this._currentTouchY;
		}
	}
	
	/**
	 * @private
	 */
	private function handleDragEnd():Void
	{
		//take the average for more accuracy
		var sum:Float = this._velocityX * CURRENT_VELOCITY_WEIGHT;
		var velocityCount:Int = this._previousVelocityX.length;
		var totalWeight:Float = CURRENT_VELOCITY_WEIGHT;
		var weight:Float;
		for (i in 0...velocityCount)
		{
			weight = VELOCITY_WEIGHTS[i];
			sum += this._previousVelocityX.shift() * weight;
			totalWeight += weight;
		}
		
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var inchesPerSecondX:Float = 1000 * (sum / totalWeight) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		
		sum = this._velocityY * CURRENT_VELOCITY_WEIGHT;
		velocityCount = this._previousVelocityY.length;
		totalWeight = CURRENT_VELOCITY_WEIGHT;
		for (i in 0...velocityCount)
		{
			weight = VELOCITY_WEIGHTS[i];
			sum += this._previousVelocityY.shift() * weight;
			totalWeight += weight;
		}
		var inchesPerSecondY:Float = 1000 * (sum / totalWeight) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		var positionToCheck:Float;
		this._isDragging = false;
		if (this._isDraggingTopDrawer)
		{
			this._isDraggingTopDrawer = false;
			if (!this._isTopDrawerOpen && inchesPerSecondY > this._minimumDrawerThrowVelocity)
			{
				this._isTopDrawerOpen = true;
			}
			else if (this._isTopDrawerOpen && inchesPerSecondY < -this._minimumDrawerThrowVelocity)
			{
				this._isTopDrawerOpen = false;
			}
			else if (this._openMode == RelativeDepth.ABOVE)
			{
				this._isTopDrawerOpen = MathUtils.roundToNearest(this._topDrawer.y, this._topDrawer.height) == 0;
			}
			else //below
			{
				this._isTopDrawerOpen = MathUtils.roundToNearest(this._content.y, this._topDrawer.height) != 0;
			}
			this.openOrCloseTopDrawer();
		}
		else if (this._isDraggingRightDrawer)
		{
			this._isDraggingRightDrawer = false;
			if (!this._isRightDrawerOpen && inchesPerSecondX < -this._minimumDrawerThrowVelocity)
			{
				this._isRightDrawerOpen = true;
			}
			else if (this._isRightDrawerOpen && inchesPerSecondX > this._minimumDrawerThrowVelocity)
			{
				this._isRightDrawerOpen = false;
			}
			else if (this._openMode == RelativeDepth.ABOVE)
			{
				this._isRightDrawerOpen = MathUtils.roundToNearest(this.actualWidth - this._rightDrawer.x, this._rightDrawer.width) != 0;
			}
			else //bottom
			{
				positionToCheck = this._content.x;
				if (this.isLeftDrawerDocked)
				{
					positionToCheck -= this._leftDrawer.width;
				}
				this._isRightDrawerOpen = MathUtils.roundToNearest(positionToCheck, this._rightDrawer.width) != 0;
			}
			this.openOrCloseRightDrawer();
		}
		else if (this._isDraggingBottomDrawer)
		{
			this._isDraggingBottomDrawer = false;
			if (!this._isBottomDrawerOpen && inchesPerSecondY < -this._minimumDrawerThrowVelocity)
			{
				this._isBottomDrawerOpen = true;
			}
			else if (this._isBottomDrawerOpen && inchesPerSecondY > this._minimumDrawerThrowVelocity)
			{
				this._isBottomDrawerOpen = false;
			}
			else if (this._openMode == RelativeDepth.ABOVE)
			{
				this._isBottomDrawerOpen = MathUtils.roundToNearest(this.actualHeight - this._bottomDrawer.y, this._bottomDrawer.height) != 0;
			}
			else //below
			{
				positionToCheck = this._content.y;
				if (this.isTopDrawerDocked)
				{
					positionToCheck -= this._topDrawer.height;
				}
				this._isBottomDrawerOpen = MathUtils.roundToNearest(positionToCheck, this._bottomDrawer.height) != 0;
			}
			this.openOrCloseBottomDrawer();
		}
		else if (this._isDraggingLeftDrawer)
		{
			this._isDraggingLeftDrawer = false;
			if (!this._isLeftDrawerOpen && inchesPerSecondX > this._minimumDrawerThrowVelocity)
			{
				this._isLeftDrawerOpen = true;
			}
			else if (this._isLeftDrawerOpen && inchesPerSecondX < -this._minimumDrawerThrowVelocity)
			{
				this._isLeftDrawerOpen = false;
			}
			else if (this._openMode == RelativeDepth.ABOVE)
			{
				this._isLeftDrawerOpen = MathUtils.roundToNearest(this._leftDrawer.x, this._leftDrawer.width) == 0;
			}
			else //below
			{
				this._isLeftDrawerOpen = MathUtils.roundToNearest(this._content.x, this._leftDrawer.width) != 0;
			}
			this.openOrCloseLeftDrawer();
		}
	}
	
	/**
	 * @private
	 */
	private function handleDragMove():Void
	{
		var contentX:Float = 0;
		var contentY:Float = 0;
		if (this.isLeftDrawerDocked)
		{
			contentX = this._leftDrawer.width;
			if (this._leftDrawerDivider != null)
			{
				contentX += this._leftDrawerDivider.width;
			}
		}
		if (this.isTopDrawerDocked)
		{
			contentY = this._topDrawer.height;
			if (this._topDrawerDivider != null)
			{
				contentY += this._topDrawerDivider.height;
			}
		}
		if (this._isDraggingLeftDrawer)
		{
			var leftDrawerWidth:Float = this._leftDrawer.width;
			if (this.isLeftDrawerOpen)
			{
				contentX = leftDrawerWidth + this._currentTouchX - this._startTouchX;
			}
			else
			{
				contentX = this._currentTouchX - this._startTouchX;
			}
			if (contentX < 0)
			{
				contentX = 0;
			}
			if (contentX > leftDrawerWidth)
			{
				contentX = leftDrawerWidth;
			}
		}
		else if (this._isDraggingRightDrawer)
		{
			var rightDrawerWidth:Float = this._rightDrawer.width;
			if (this.isRightDrawerOpen)
			{
				contentX = -rightDrawerWidth + this._currentTouchX - this._startTouchX;
			}
			else
			{
				contentX = this._currentTouchX - this._startTouchX;
			}
			if (contentX < -rightDrawerWidth)
			{
				contentX = -rightDrawerWidth;
			}
			if (contentX > 0)
			{
				contentX = 0;
			}
			if (this.isLeftDrawerDocked && this._openMode == RelativeDepth.BELOW)
			{
				contentX += this._leftDrawer.width;
				if (this._leftDrawerDivider != null)
				{
					contentX += this._leftDrawerDivider.width;
				}
			}
		}
		else if (this._isDraggingTopDrawer)
		{
			var topDrawerHeight:Float = this._topDrawer.height;
			if (this.isTopDrawerOpen)
			{
				contentY = topDrawerHeight + this._currentTouchY - this._startTouchY;
			}
			else
			{
				contentY = this._currentTouchY - this._startTouchY;
			}
			if (contentY < 0)
			{
				contentY = 0;
			}
			if (contentY > topDrawerHeight)
			{
				contentY = topDrawerHeight;
			}
		}
		else if (this._isDraggingBottomDrawer)
		{
			var bottomDrawerHeight:Float = this._bottomDrawer.height;
			if (this.isBottomDrawerOpen)
			{
				contentY = -bottomDrawerHeight + this._currentTouchY - this._startTouchY;
			}
			else
			{
				contentY = this._currentTouchY - this._startTouchY;
			}
			if (contentY < -bottomDrawerHeight)
			{
				contentY = -bottomDrawerHeight;
			}
			if (contentY > 0)
			{
				contentY = 0;
			}
			if (this.isTopDrawerDocked && this._openMode == RelativeDepth.BELOW)
			{
				contentY += this._topDrawer.height;
				if (this._topDrawerDivider != null)
				{
					contentY += this._topDrawerDivider.height;
				}
			}
		}
		if (this._openMode == RelativeDepth.ABOVE)
		{
			if (this._isDraggingTopDrawer)
			{
				this._topDrawer.y = contentY - this._topDrawer.height;
			}
			else if (this._isDraggingRightDrawer)
			{
				this._rightDrawer.x = this.actualWidth + contentX;
			}
			else if (this._isDraggingBottomDrawer)
			{
				this._bottomDrawer.y = this.actualHeight + contentY;
			}
			else if (this._isDraggingLeftDrawer)
			{
				this._leftDrawer.x = contentX - this._leftDrawer.width;
			}
		}
		else //below
		{
			this._content.x = contentX;
			this._content.y = contentY;
		}
		if (this._isDraggingTopDrawer)
		{
			this.topDrawerOpenOrCloseTween_onUpdate();
		}
		else if (this._isDraggingRightDrawer)
		{
			this.rightDrawerOpenOrCloseTween_onUpdate();
		}
		else if (this._isDraggingBottomDrawer)
		{
			this.bottomDrawerOpenOrCloseTween_onUpdate();
		}
		else if (this._isDraggingLeftDrawer)
		{
			this.leftDrawerOpenOrCloseTween_onUpdate();
		}
	}
	
	/**
	 * @private
	 */
	private function checkForDragToClose():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var horizontalInchesMoved:Float = (this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		var verticalInchesMoved:Float = (this._currentTouchY - this._startTouchY) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		if (this.isLeftDrawerOpen && horizontalInchesMoved <= -this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingLeftDrawer = true;
			this.prepareLeftDrawer();
		}
		else if (this.isRightDrawerOpen && horizontalInchesMoved >= this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingRightDrawer = true;
			this.prepareRightDrawer();
		}
		else if (this.isTopDrawerOpen && verticalInchesMoved <= -this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingTopDrawer = true;
			this.prepareTopDrawer();
		}
		else if (this.isBottomDrawerOpen && verticalInchesMoved >= this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingBottomDrawer = true;
			this.prepareBottomDrawer();
		}
		
		if (this._isDragging)
		{
			if (this._overlaySkin != null)
			{
				this._overlaySkin.visible = true;
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
			}
			this._startTouchX = this._currentTouchX;
			this._startTouchY = this._currentTouchY;
			var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
			exclusiveTouch.claimTouch(this.touchPointID, this);
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
		}
	}
	
	/**
	 * @private
	 */
	private function checkForDragToOpen():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var horizontalInchesMoved:Float = (this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		var verticalInchesMoved:Float = (this._currentTouchY - this._startTouchY) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		if (this._leftDrawer != null && !this.isLeftDrawerDocked && horizontalInchesMoved >= this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingLeftDrawer = true;
			this.prepareLeftDrawer();
		}
		else if (this._rightDrawer != null && !this.isRightDrawerDocked && horizontalInchesMoved <= -this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingRightDrawer = true;
			this.prepareRightDrawer();
		}
		else if (this._topDrawer != null && !this.isTopDrawerDocked && verticalInchesMoved >= this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingTopDrawer = true;
			this.prepareTopDrawer();
		}
		else if (this._bottomDrawer != null && !this.isBottomDrawerDocked && verticalInchesMoved <= -this._minimumDragDistance)
		{
			this._isDragging = true;
			this._isDraggingBottomDrawer = true;
			this.prepareBottomDrawer();
		}
		
		if (this._isDragging)
		{
			if (this._overlaySkin != null)
			{
				this._overlaySkin.visible = true;
				this._overlaySkin.alpha = 0;
			}
			this._startTouchX = this._currentTouchX;
			this._startTouchY = this._currentTouchY;
			var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			exclusiveTouch.claimTouch(this.touchPointID, this);
			exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
		}
	}
	
	/**
	 * @private
	 */
	private function positionOverlaySkin():Void
	{
		if (this._overlaySkin == null)
		{
			return;
		}
		
		if (this.isLeftDrawerDocked)
		{
			this._overlaySkin.x = this._leftDrawer.x;
		}
		else if (this._openMode == RelativeDepth.ABOVE && this._leftDrawer != null)
		{
			this._overlaySkin.x = this._leftDrawer.x + this._leftDrawer.width;
		}
		else //below or no left drawer
		{
			if (this._content != null)
			{
				this._overlaySkin.x = this._content.x;
			}
			else
			{
				this._overlaySkin.x = 0;
			}
		}
		
		if (this.isTopDrawerDocked)
		{
			this._overlaySkin.y = this._topDrawer.y;
		}
		else if (this._openMode == RelativeDepth.ABOVE && this._topDrawer != null)
		{
			this._overlaySkin.y = this._topDrawer.y + this._topDrawer.height;
		}
		else //below or now top drawer
		{
			if (this._content != null)
			{
				this._overlaySkin.y = this._content.y;
			}
			else
			{
				this._overlaySkin.y = 0;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function topDrawerOpenOrCloseTween_onUpdate():Void
	{
		if (this._overlaySkin != null)
		{
			var ratio:Float;
			if (this._openMode == RelativeDepth.ABOVE)
			{
				ratio = 1 + this._topDrawer.y / this._topDrawer.height;
			}
			else //below
			{
				ratio = this._content.y / this._topDrawer.height;
			}
			this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * ratio;
		}
		this.openOrCloseTween_onUpdate();
	}
	
	/**
	 * @private
	 */
	private function rightDrawerOpenOrCloseTween_onUpdate():Void
	{
		if (this._overlaySkin != null)
		{
			var ratio:Float;
			if (this._openMode == RelativeDepth.ABOVE)
			{
				ratio = -(this._rightDrawer.x - this.actualWidth) / this._rightDrawer.width;
			}
			else //below
			{
				ratio = (this.actualWidth - this._content.x - this._content.width) / this._rightDrawer.width;
			}
			this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * ratio;
		}
		this.openOrCloseTween_onUpdate();
	}
	
	/**
	 * @private
	 */
	private function bottomDrawerOpenOrCloseTween_onUpdate():Void
	{
		if (this._overlaySkin != null)
		{
			var ratio:Float;
			if (this._openMode == RelativeDepth.ABOVE)
			{
				ratio = -(this._bottomDrawer.y - this.actualHeight) / this._bottomDrawer.height;
			}
			else //below
			{
				ratio = (this.actualHeight - this._content.y - this._content.height) / this._bottomDrawer.height;
			}
			this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * ratio;
		}
		this.openOrCloseTween_onUpdate();
	}
	
	/**
	 * @private
	 */
	private function leftDrawerOpenOrCloseTween_onUpdate():Void
	{
		if (this._overlaySkin != null)
		{
			var ratio:Float;
			if (this._openMode == RelativeDepth.ABOVE)
			{
				ratio = 1 + this._leftDrawer.x / this._leftDrawer.width;
			}
			else //below
			{
				ratio = this._content.x / this._leftDrawer.width;
			}
			this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * ratio;
		}
		this.openOrCloseTween_onUpdate();
	}
	
	/**
	 * @private
	 */
	private function openOrCloseTween_onUpdate():Void
	{
		if (this._clipDrawers && this._openMode == RelativeDepth.BELOW)
		{
			var isTopDrawerDocked:Bool = this.isTopDrawerDocked;
			var isRightDrawerDocked:Bool = this.isRightDrawerDocked;
			var isBottomDrawerDocked:Bool = this.isBottomDrawerDocked;
			var isLeftDrawerDocked:Bool = this.isLeftDrawerDocked;
			var contentX:Float = this._content.x;
			var contentY:Float = this._content.y;
			var leftDrawerDockedWidth:Float;
			var mask:Quad;
			if (isTopDrawerDocked)
			{
				if (isLeftDrawerDocked)
				{
					leftDrawerDockedWidth = this._leftDrawer.width;
					if (this._leftDrawerDivider != null)
					{
						leftDrawerDockedWidth += this._leftDrawerDivider.width;
					}
					this._topDrawer.x = contentX - leftDrawerDockedWidth;
				}
				else
				{
					this._topDrawer.x = contentX;
				}
				if (this._topDrawerDivider != null)
				{
					this._topDrawerDivider.x = this._topDrawer.x;
					this._topDrawerDivider.y = contentY - this._topDrawerDivider.height;
					this._topDrawer.y = this._topDrawerDivider.y - this._topDrawer.height;
				}
				else
				{
					this._topDrawer.y = contentY - this._topDrawer.height;
				}
			}
			if (isRightDrawerDocked)
			{
				if (this._rightDrawerDivider != null)
				{
					this._rightDrawerDivider.x = contentX + this._content.width;
					this._rightDrawer.x = this._rightDrawerDivider.x + this._rightDrawerDivider.width;
					this._rightDrawerDivider.y = contentY;
				}
				else
				{
					this._rightDrawer.x = contentX + this._content.width;
				}
				this._rightDrawer.y = contentY;
			}
			if (isBottomDrawerDocked)
			{
				if (isLeftDrawerDocked)
				{
					leftDrawerDockedWidth = this._leftDrawer.width;
					if (this._leftDrawerDivider != null)
					{
						leftDrawerDockedWidth += this._leftDrawerDivider.width;
					}
					this._bottomDrawer.x = contentX - leftDrawerDockedWidth;
				}
				else
				{
					this._bottomDrawer.x = contentX;
				}
				if (this._bottomDrawerDivider != null)
				{
					this._bottomDrawerDivider.x = this._bottomDrawer.x;
					this._bottomDrawerDivider.y = contentY + this._content.height;
					this._bottomDrawer.y = this._bottomDrawerDivider.y + this._bottomDrawerDivider.height;
				}
				else
				{
					this._bottomDrawer.y = contentY + this._content.height;
				}
			}
			if (isLeftDrawerDocked)
			{
				if (this._leftDrawerDivider != null)
				{
					this._leftDrawerDivider.x = contentX - this._leftDrawerDivider.width;
					this._leftDrawer.x = this._leftDrawerDivider.x - this._leftDrawer.width;
					this._leftDrawerDivider.y = contentY;
				}
				else
				{
					this._leftDrawer.x = contentX - this._leftDrawer.width;
				}
				this._leftDrawer.y = contentY;
			}
			if (this._topDrawer != null)
			{
				mask = SafeCast.safe_cast(this._topDrawer.mask, Quad);
				if (mask != null)
				{
					mask.height = contentY;
				}
			}
			if (this._rightDrawer != null)
			{
				mask = SafeCast.safe_cast(this._rightDrawer.mask, Quad);
				if (mask != null)
				{
					var rightClipWidth:Float = -contentX;
					if (isLeftDrawerDocked)
					{
						rightClipWidth = -this._leftDrawer.x;
					}
					mask.x = this._rightDrawer.width - rightClipWidth;
					mask.width = rightClipWidth;
				}
			}
			if (this._bottomDrawer != null)
			{
				mask = SafeCast.safe_cast(this._bottomDrawer.mask, Quad);
				if (mask != null)
				{
					var bottomClipHeight:Float = -contentY;
					if (isTopDrawerDocked)
					{
						bottomClipHeight = -this._topDrawer.y;
					}
					mask.y = this._bottomDrawer.height - bottomClipHeight;
					mask.height = bottomClipHeight;
				}
			}
			if (this._leftDrawer != null)
			{
				mask = SafeCast.safe_cast(this._leftDrawer.mask, Quad);
				if (mask != null)
				{
					mask.width = contentX;
				}
			}
		}
		
		if (this._overlaySkin != null)
		{
			this.positionOverlaySkin();
		}
	}
	
	/**
	 * @private
	 */
	private function topDrawerOpenOrCloseTween_onComplete():Void
	{
		if (this._overlaySkin != null)
		{
			this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
		}
		this._openOrCloseTween = null;
		this._topDrawer.mask = null;
		var isTopDrawerOpen:Bool = this.isTopDrawerOpen;
		var isTopDrawerDocked:Bool = this.isTopDrawerDocked;
		this._topDrawer.visible = isTopDrawerOpen || isTopDrawerDocked;
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = isTopDrawerOpen;
		}
		if (isTopDrawerOpen)
		{
			this.dispatchEventWith(Event.OPEN, false, this._topDrawer);
		}
		else
		{
			this.dispatchEventWith(Event.CLOSE, false, this._topDrawer);
		}
	}
	
	/**
	 * @private
	 */
	private function rightDrawerOpenOrCloseTween_onComplete():Void
	{
		this._openOrCloseTween = null;
		this._rightDrawer.mask = null;
		var isRightDrawerOpen:Bool = this.isRightDrawerOpen;
		var isRightDrawerDocked:Bool = this.isRightDrawerDocked;
		this._rightDrawer.visible = isRightDrawerOpen || isRightDrawerDocked;
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = isRightDrawerOpen;
		}
		if (isRightDrawerOpen)
		{
			this.dispatchEventWith(Event.OPEN, false, this._rightDrawer);
		}
		else
		{
			this.dispatchEventWith(Event.CLOSE, false, this._rightDrawer);
		}
	}
	
	/**
	 * @private
	 */
	private function bottomDrawerOpenOrCloseTween_onComplete():Void
	{
		this._openOrCloseTween = null;
		this._bottomDrawer.mask = null;
		var isBottomDrawerOpen:Bool = this.isBottomDrawerOpen;
		var isBottomDrawerDocked:Bool = this.isBottomDrawerDocked;
		this._bottomDrawer.visible = isBottomDrawerOpen || isBottomDrawerDocked;
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = isBottomDrawerOpen;
		}
		if (isBottomDrawerOpen)
		{
			this.dispatchEventWith(Event.OPEN, false, this._bottomDrawer);
		}
		else
		{
			this.dispatchEventWith(Event.CLOSE, false, this._bottomDrawer);
		}
	}
	
	/**
	 * @private
	 */
	private function leftDrawerOpenOrCloseTween_onComplete():Void
	{
		this._openOrCloseTween = null;
		this._leftDrawer.mask = null;
		var isLeftDrawerOpen:Bool = this.isLeftDrawerOpen;
		var isLeftDrawerDocked:Bool = this.isLeftDrawerDocked;
		this._leftDrawer.visible = isLeftDrawerOpen || isLeftDrawerDocked;
		if (this._overlaySkin != null)
		{
			this._overlaySkin.visible = isLeftDrawerOpen;
		}
		if (isLeftDrawerOpen)
		{
			this.dispatchEventWith(Event.OPEN, false, this._leftDrawer);
		}
		else
		{
			this.dispatchEventWith(Event.CLOSE, false, this._leftDrawer);
		}
	}
	
	/**
	 * @private
	 */
	private function content_eventDispatcherChangeHandler(event:Event):Void
	{
		this.refreshCurrentEventTarget();
	}
	
	/**
	 * @private
	 */
	private function drawers_addedToStageHandler(event:Event):Void
	{
		this.stage.addEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		//using priority here is a hack so that objects higher up in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this);
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, drawers_nativeStage_keyDownHandler, false, priority, true);
	}
	
	/**
	 * @private
	 */
	private function drawers_removedFromStageHandler(event:Event):Void
	{
		if (this.touchPointID >= 0)
		{
			var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
		}
		this.touchPointID = -1;
		this._isDragging = false;
		this._isDraggingTopDrawer = false;
		this._isDraggingRightDrawer = false;
		this._isDraggingBottomDrawer = false;
		this._isDraggingLeftDrawer = false;
		this.stage.removeEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, drawers_nativeStage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	private function drawers_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled || this._openOrCloseTween != null)
		{
			this.touchPointID = -1;
			return;
		}
		var touch:Touch;
		if (this.touchPointID >= 0)
		{
			touch = event.getTouch(this, null, this.touchPointID);
			if (touch == null)
			{
				return;
			}
			if (touch.phase == TouchPhase.MOVED)
			{
				this.handleTouchMoved(touch);
				
				if (!this._isDragging)
				{
					if (this.isTopDrawerOpen || this.isRightDrawerOpen || this.isBottomDrawerOpen || this.isLeftDrawerOpen)
					{
						this.checkForDragToClose();
					}
					else
					{
						this.checkForDragToOpen();
					}
				}
				if (this._isDragging)
				{
					this.handleDragMove();
				}
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				this.touchPointID = -1;
				if (this._isDragging)
				{
					this.handleDragEnd();
					this.dispatchEventWith(FeathersEventType.END_INTERACTION);
				}
				else
				{
					ExclusiveTouch.forStage(this.stage).removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
					if (this.isTopDrawerOpen || this.isRightDrawerOpen || this.isBottomDrawerOpen || this.isLeftDrawerOpen)
					{
						//there is no drag, so we may have a tap
						this.handleTapToClose(touch);
					}
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
		if (this.touchPointID < 0 || this.touchPointID != touchID || this._isDragging)
		{
			return;
		}
		
		var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
		if (exclusiveTouch.getClaim(touchID) == this)
		{
			return;
		}
		
		this.touchPointID = -1;
	}
	
	/**
	 * @private
	 */
	private function stage_resizeHandler(event:ResizeEvent):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function drawers_nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			//someone else already handled this one
			return;
		}
		
		// TODO : Keyboard.BACK only available on flash target
		#if flash
		if (event.keyCode == Keyboard.BACK)
		{
			var isAnyDrawerOpen:Bool = false;
			if (this.isTopDrawerOpen)
			{
				this.toggleTopDrawer();
				isAnyDrawerOpen = true;
			}
			else if (this.isRightDrawerOpen)
			{
				this.toggleRightDrawer();
				isAnyDrawerOpen = true;
			}
			else if (this.isBottomDrawerOpen)
			{
				this.toggleBottomDrawer();
				isAnyDrawerOpen = true;
			}
			else if (this.isLeftDrawerOpen)
			{
				this.toggleLeftDrawer();
				isAnyDrawerOpen = true;
			}
			if (isAnyDrawerOpen)
			{
				event.preventDefault();
			}
		}
		#end
	}
	
	/**
	 * @private
	 */
	private function content_topDrawerToggleEventTypeHandler(event:Event):Void
	{
		if (this._topDrawer == null || this.isTopDrawerDocked)
		{
			return;
		}
		this._isTopDrawerOpen = !this._isTopDrawerOpen;
		this.openOrCloseTopDrawer();
	}
	
	/**
	 * @private
	 */
	private function content_rightDrawerToggleEventTypeHandler(event:Event):Void
	{
		if (this._rightDrawer == null || this.isRightDrawerDocked)
		{
			return;
		}
		this._isRightDrawerOpen = !this._isRightDrawerOpen;
		this.openOrCloseRightDrawer();
	}
	
	/**
	 * @private
	 */
	private function content_bottomDrawerToggleEventTypeHandler(event:Event):Void
	{
		if (this._bottomDrawer == null || this.isBottomDrawerDocked)
		{
			return;
		}
		this._isBottomDrawerOpen = !this._isBottomDrawerOpen;
		this.openOrCloseBottomDrawer();
	}
	
	/**
	 * @private
	 */
	private function content_leftDrawerToggleEventTypeHandler(event:Event):Void
	{
		if (this._leftDrawer == null || this.isLeftDrawerDocked)
		{
			return;
		}
		this._isLeftDrawerOpen = !this._isLeftDrawerOpen;
		this.openOrCloseLeftDrawer();
	}
	
	/**
	 * @private
	 */
	private function content_resizeHandler(event:Event):Void
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
	private function drawer_resizeHandler(event:Event):Void
	{
		if (this._isValidating)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
}