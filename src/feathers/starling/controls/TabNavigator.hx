/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;
import feathers.starling.controls.supportClasses.BaseScreenNavigator;
import feathers.starling.core.IFeathersControl;
import feathers.starling.data.ArrayCollection;
import feathers.starling.data.IListCollection;
import feathers.starling.events.ExclusiveTouch;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.Direction;
import feathers.starling.layout.RelativePosition;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.TabNavigatorItem;
import feathers.starling.system.DeviceCapabilities;
import haxe.Constraints.Function;
import openfl.Lib;
import openfl.geom.Point;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * A tabbed container.
 *
 * <p>The following example creates a tab navigator, adds a couple of tabs
 * and displays the navigator:</p>
 *
 * <listing version="3.0">
 * var navigator:TabNavigator = new TabNavigator();
 * navigator.addScreen( "newsFeed", new TabNavigatorItem( NewsFeedTab, "News" ) );
 * navigator.addScreen( "profile", new TabNavigatorItem( ProfileTab, "Profile" ) );
 * this.addChild( navigator );
 * </listing>
 *
 * @see ../../../help/tab-navigator.html How to use the Feathers TabNavigator component
 * @see feathers.controls.TabNavigatorItem
 *
 * @productversion Feathers 3.1.0
 */
class TabNavigator extends BaseScreenNavigator
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
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_TAB_BAR_FACTORY:String = "tabBarFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the tab
	 * bar.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TAB_BAR:String = "feathers-tab-navigator-tab-bar";

	/**
	 * The default <code>IStyleProvider</code> for all <code>TabNavigator</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * @private
	 */
	private static function defaultTabBarFactory():TabBar
	{
		return new TabBar();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.screenContainer = new LayoutGroup();
		this.screenContainer.addEventListener(TouchEvent.TOUCH, screenContainer_touchHandler);
		this.addChild(this.screenContainer);
	}
	
	override public function dispose():Void 
	{
		if (this._tabBarDataProvider != null)
		{
			this._tabBarDataProvider.dispose(disposeItem);
		}
		super.dispose();
	}
	
	private function disposeItem(item:TabNavigatorItem):Void
	{
		item.dispose();
	}
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return TabNavigator.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var touchPointID:Int = -1;
	
	/**
	 * The index of the currently selected tab. Returns <code>-1</code> if
	 * no tab is selected.
	 *
	 * <p>In the following example, the tab navigator's selected index is changed:</p>
	 *
	 * <listing version="3.0">
	 * navigator.selectedIndex = 2;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected index:</p>
	 *
	 * <listing version="3.0">
	 * function navigator_changeHandler( event:Event ):void
	 * {
	 *     var navigator:TabNavigator = TabNavigator( event.currentTarget );
	 *     var index:int = navigator.selectedIndex;
	 * 
	 * }
	 * navigator.addEventListener( Event.CHANGE, navigator_changeHandler );</listing>
	 *
	 * @default -1
	 */
	public var selectedIndex(get, set):Int;
	private var _selectedIndex:Int = -1;
	private function get_selectedIndex():Int { return this._selectedIndex; }
	private function set_selectedIndex(value:Int):Int
	{
		if (this._selectedIndex == value)
		{
			return value;
		}
		this._selectedIndex = value;
		if (value < 0)
		{
			this.clearScreenInternal();
		}
		else
		{
			var id:String = this._tabBarDataProvider.getItemAt(this._selectedIndex);
			if (this._activeScreenID == id)
			{
				return value;
			}
			this.showScreen(id);
		}
		return this._selectedIndex;
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the tab bar.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the tab bar style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TAB_BAR</code>.
	 *
	 * <p>To customize the tab bar style name without subclassing, see
	 * <code>customTabBarStyleName</code>.</p>
	 *
	 * @see #style:customTabBarStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var tabBarStyleName:String = DEFAULT_CHILD_STYLE_NAME_TAB_BAR;

	//this would be a VectorCollection with a Vector.<String>, but the ASC1
	//compiler doesn't like it!
	/**
	 * @private
	 */
	private var _tabBarDataProvider:IListCollection = new ArrayCollection(new Array<String>());

	/**
	 * @private
	 */
	private var _ignoreTabBarChanges:Bool = false;

	/**
	 * @private
	 */
	private var tabBar:TabBar;
	
	/**
	 * A function used to generate the navigator's tab bar sub-component.
	 * The tab bar must be an instance of <code>TabBar</code> (or a
	 * subclass). This factory can be used to change properties on the tab
	 * bar when it is first created. For instance, if you are skinning
	 * Feathers components without a theme, you might use this factory to
	 * set skins and other styles on the tab bar.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():TabBar</pre>
	 *
	 * <p>In the following example, a custom tab bar factory is passed
	 * to the navigator:</p>
	 *
	 * <listing version="3.0">
	 * navigator.tabBarFactory = function():TabBar
	 * {
	 *     var tabs:TabBar = new TabBar();
	 *     tabs.distributeTabSizes = true;
	 *     return tabs;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.TabBar
	 */
	public var tabBarFactory(get, set):Void->TabBar;
	private var _tabBarFactory:Void->TabBar;
	private function get_tabBarFactory():Void->TabBar { return this._tabBarFactory; }
	private function set_tabBarFactory(value:Void->TabBar):Void->TabBar
	{
		if (this._tabBarFactory == value)
		{
			return value;
		}
		this._tabBarFactory = value;
		this.invalidate(INVALIDATION_FLAG_TAB_BAR_FACTORY);
		return this._tabBarFactory;
	}
	
	/**
	 * @private
	 */
	public var customTabBarStyleName(get, set):String;
	private var _customTabBarStyleName:String;
	private function get_customTabBarStyleName():String { return this._customTabBarStyleName; }
	private function set_customTabBarStyleName(value:String):String
	{
		if (this.processStyleRestriction("customTabBarStyleName"))
		{
			return value;
		}
		if (this._customTabBarStyleName == value)
		{
			return value;
		}
		this._customTabBarStyleName = value;
		this.invalidate(INVALIDATION_FLAG_TAB_BAR_FACTORY);
		return this._customTabBarStyleName;
	}
	
	/**
	 * @private
	 */
	public var tabBarPosition(get, set):String;
	private var _tabBarPosition:String = RelativePosition.BOTTOM;
	private function get_tabBarPosition():String { return this._tabBarPosition; }
	private function set_tabBarPosition(value:String):String
	{
		if (this.processStyleRestriction("tabBarPosition"))
		{
			return value;
		}
		if (this._tabBarPosition == value)
		{
			return value;
		}
		this._tabBarPosition = value;
		this.invalidate(INVALIDATION_FLAG_TAB_BAR_FACTORY);
		return this._tabBarPosition;
	}
	
	/**
	 * @private
	 */
	public var transition(get, set):Function;
	private var _transition:Function;
	private function get_transition():Function { return this._transition; }
	private function set_transition(value:Function):Function
	{
		if (this.processStyleRestriction("transition"))
		{
			return value;
		}
		return this._transition = value;
	}
	
	/**
	 * @private
	 */
	private var _dragCancelled:Bool = false;

	/**
	 * @private
	 */
	private var _isDragging:Bool = false;

	/**
	 * @private
	 */
	private var _isDraggingPrevious:Bool = false;

	/**
	 * @private
	 */
	private var _isDraggingNext:Bool = false;

	/**
	 * @private
	 */
	private var _swipeTween:Tween;
	
	/**
	 * Determines if the swipe gesture to switch between tabs is enabled.
	 *
	 * <p>In the following example, swiping between tabs is enabled:</p>
	 *
	 * <listing version="3.0">
	 * navigator.isSwipeEnabled = true;</listing>
	 *
	 * @default false
	 */
	public var isSwipeEnabled(get, set):Bool;
	private var _isSwipeEnabled:Bool = false;
	private function get_isSwipeEnabled():Bool { return this._isSwipeEnabled; }
	private function set_isSwipeEnabled(value:Bool):Bool
	{
		return this._isSwipeEnabled = value;
	}
	
	/**
	 * @private
	 */
	public var swipeDuration(get, set):Float;
	private var _swipeDuration:Float = 0.25;
	private function get_swipeDuration():Float { return this._swipeDuration; }
	private function set_swipeDuration(value:Float):Float
	{
		if (this.processStyleRestriction("swipeDuration"))
		{
			return value;
		}
		return this._swipeDuration = value;
	}
	
	/**
	 * @private
	 */
	public var swipeEase(get, set):Dynamic;
	private var _swipeEase:Dynamic = Transitions.EASE_OUT;
	private function get_swipeEase():Dynamic { return this._swipeEase; }
	private function set_swipeEase(value:Dynamic):Dynamic
	{
		if (this.processStyleRestriction("swipeEase"))
		{
			return value;
		}
		return this._swipeEase = value;
	}
	
	/**
	 * The minimum physical distance (in inches) that a touch must move
	 * before a drag gesture begins.
	 *
	 * <p>In the following example, the minimum drag distance is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.minimumDragDistance = 0.1;</listing>
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
	 * must move before a swipe is detected. Otherwise, it will settle which
	 * screen to navigate to based on which one is closer when the touch ends.
	 *
	 * <p>In the following example, the minimum swipe velocity is customized:</p>
	 *
	 * <listing version="3.0">
	 * navigator.minimumSwipeVelocity = 2;</listing>
	 *
	 * @default 5
	 */
	public var minimumSwipeVelocity(get, set):Float;
	private var _minimumSwipeVelocity:Float = 5;
	private function get_minimumSwipeVelocity():Float { return this._minimumSwipeVelocity; }
	private function set_minimumSwipeVelocity(value:Float):Float
	{
		return this._minimumSwipeVelocity = value;
	}
	
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
	private var _savedTransitionOnComplete:Function;
	
	/**
	 * Registers a new screen with a string identifier that can be used
	 * to reference the screen in other calls, like <code>removeScreen()</code>
	 * or <code>showScreen()</code>.
	 *
	 * @see #addScreenAt()
	 * @see #removeScreen()
	 * @see #removeScreenAt()
	 */
	public function addScreen(id:String, item:TabNavigatorItem):Void
	{
		this.addScreenAt(id, item, this._tabBarDataProvider.length);
	}
	
	/**
	 * Registers a new screen with a string identifier that can be used
	 * to reference the screen in other calls, like <code>removeScreen()</code>
	 * or <code>showScreen()</code>.
	 *
	 * @see #addScreen()
	 * @see #removeScreen()
	 * @see #removeScreenAt()
	 */
	public function addScreenAt(id:String, item:TabNavigatorItem, index:Int):Void
	{
		this.addScreenInternal(id, item);
		this._tabBarDataProvider.addItemAt(id, index);
		if (this._selectedIndex < 0 && this._tabBarDataProvider.length == 1)
		{
			this.selectedIndex = 0;
		}
	}
	
	/**
	 * Removes an existing screen using the identifier assigned to it in the
	 * call to <code>addScreen()</code> or <code>addScreenAt()</code>.
	 *
	 * @see #removeScreenAt()
	 * @see #removeAllScreens()
	 * @see #addScreen()
	 * @see #addScreenAt()
	 */
	public function removeScreen(id:String):TabNavigatorItem
	{
		this._tabBarDataProvider.removeItem(id);
		return cast this.removeScreenInternal(id);
	}
	
	/**
	 * Removes an existing screen using the identifier assigned to it in the
	 * call to <code>addScreen()</code>.
	 *
	 * @see #removeScreen()
	 * @see #removeAllScreens()
	 * @see #addScreen()
	 * @see #addScreenAt()
	 */
	public function removeScreenAt(index:Int):TabNavigatorItem
	{
		var id:String = this._tabBarDataProvider.removeItemAt(index);
		return cast this.removeScreenInternal(id);
	}
	
	/**
	 * @private
	 */
	override public function removeAllScreens():Void
	{
		this._tabBarDataProvider.removeAll();
		super.removeAllScreens();
	}
	
	/**
	 *
	 * Displays the screen with the specified id. An optional transition may
	 * be passed in. If <code>null</code> the <code>transition</code>
	 * property will be used instead.
	 *
	 * <p>Returns a reference to the new screen, unless a transition is
	 * currently active. In that case, the new screen will be queued until
	 * the transition has completed, and no reference will be returned.</p>
	 *
	 * @see #transition
	 */
	public function showScreen(id:String, transition:Function = null):DisplayObject
	{
		if (this._activeScreenID == id)
		{
			//if we're already showing this id, do nothing
			return this._activeScreen;
		}
		if (transition == null)
		{
			var item:TabNavigatorItem = this.getScreen(id);
			if (item != null && item.transition != null)
			{
				transition = item.transition;
			}
			else
			{
				transition = this.transition;
			}
		}
		//showScreenInternal() dispatches Event.CHANGE, so we want to be
		//sure that the selectedIndex property returns the correct value
		this._selectedIndex = this._tabBarDataProvider.getItemIndex(id);
		var result:DisplayObject = this.showScreenInternal(id, transition);
		//however, we don't want to set the tab bar's selectedIndex before
		//calling setScreenInternal() because it would cause showScreen()
		//to be called again if we did it first
		this.tabBar.selectedIndex = this._selectedIndex;
		return result;
	}
	
	/**
	 * Returns the <code>TabNavigatorItem</code> instance with the
	 * specified identifier.
	 */
	public function getScreen(id:String):TabNavigatorItem
	{
		if (this._screens.exists(id))
		{
			return cast this._screens[id];
		}
		return null;
	}
	
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
				return this.screenContainer;
			}
			return result;
		}
		//we want to register touches in our hitArea as a last resort
		if (!this.visible || !this.touchable)
		{
			return null;
		}
		return this._hitArea.contains(localPoint.x, localPoint.y) ? this.screenContainer : null;
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var tabBarFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_TAB_BAR_FACTORY);
		
		if (tabBarFactoryInvalid)
		{
			this.createTabBar();
		}
		
		super.draw();
	}
	
	/**
	 * Creates and adds the <code>tabBar</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #tabBar
	 * @see #tabBarFactory
	 * @see #style:customTabBarStyleName
	 */
	private function createTabBar():Void
	{
		if (this.tabBar != null)
		{
			this.tabBar.removeFromParent(true);
			this.tabBar = null;
		}
		
		var factory:Void->TabBar = this._tabBarFactory != null ? this._tabBarFactory : defaultTabBarFactory;
		var tabBarStyleName:String = this._customTabBarStyleName != null ? this._customTabBarStyleName : this.tabBarStyleName;
		this.tabBar = factory();
		this.tabBar.styleNameList.add(tabBarStyleName);
		if (this._tabBarPosition == RelativePosition.LEFT ||
			this._tabBarPosition == RelativePosition.RIGHT)
		{
			this.tabBar.direction = Direction.VERTICAL;
		}
		else //top or bottom
		{
			this.tabBar.direction = Direction.HORIZONTAL;
		}
		this.tabBar.addEventListener(Event.CHANGE, tabBar_changeHandler);
		this.tabBar.addEventListener(Event.TRIGGERED, tabBar_triggeredHandler);
		this.tabBar.dataProvider = this._tabBarDataProvider;
		this.tabBar.labelFunction = this.getTabLabel;
		this.tabBar.iconFunction = this.getTabIcon;
		this.addChild(this.tabBar);
	}
	
	/**
	 * @private
	 */
	private function getTabLabel(id:String):String
	{
		var item:TabNavigatorItem = this.getScreen(id);
		return item.label;
	}

	/**
	 * @private
	 */
	private function getTabIcon(id:String):DisplayObject
	{
		var item:TabNavigatorItem = this.getScreen(id);
		return item.icon;
	}
	
	/**
	 * @private
	 */
	override function prepareActiveScreen():Void
	{
		if (Std.isOfType(this._activeScreen, StackScreenNavigator))
		{
			//always show root screen when switching to this tab
			cast(this._activeScreen, StackScreenNavigator).popToRootScreen(BaseScreenNavigator.defaultTransition);
		}
	}
	
	/**
	 * @private
	 */
	override function cleanupActiveScreen():Void
	{
	}
	
	/**
	 * @private
	 */
	override function layoutChildren():Void
	{
		var screenWidth:Float = this.actualWidth;
		var screenHeight:Float = this.actualHeight;
		if (this._tabBarPosition == RelativePosition.LEFT ||
			this._tabBarPosition == RelativePosition.RIGHT)
		{
			this.tabBar.y = 0;
			this.tabBar.height = this.actualHeight;
			this.tabBar.validate();
			if (this._tabBarPosition == RelativePosition.LEFT)
			{
				this.tabBar.x = 0;
			}
			else
			{
				this.tabBar.x = this.actualWidth - this.tabBar.width;
			}
			screenWidth -= this.tabBar.width;
		}
		else //top or bottom
		{
			this.tabBar.x = 0;
			this.tabBar.width = this.actualWidth;
			this.tabBar.validate();
			if (this._tabBarPosition == RelativePosition.TOP)
			{
				this.tabBar.y = 0;
			}
			else
			{
				this.tabBar.y = this.actualHeight - this.tabBar.height;
			}
			screenHeight -= this.tabBar.height;
		}
		
		if (this._tabBarPosition == RelativePosition.LEFT)
		{
			this.screenContainer.x = this.tabBar.width;
		}
		else //top, bottom, or right
		{
			this.screenContainer.x = 0;
		}
		if (this._tabBarPosition == RelativePosition.TOP)
		{
			this.screenContainer.y = this.tabBar.height;
		}
		else //right, left, or bottom
		{
			this.screenContainer.y = 0;
		}
		this.screenContainer.width = screenWidth;
		this.screenContainer.height = screenHeight;
		if (this._activeScreen != null)
		{
			this._activeScreen.x = 0;
			this._activeScreen.y = 0;
			this._activeScreen.width = screenWidth;
			this._activeScreen.height = screenHeight;
		}
	}
	
	/**
	 * @private
	 */
	private function tabBar_triggeredHandler(event:Event, id:String):Void
	{
		this.dispatchEventWith(Event.TRIGGERED, false, this.getScreen(id));
		if (id != this._activeScreenID)
		{
			return;
		}
		if (Std.isOfType(this._activeScreen, StackScreenNavigator))
		{
			var navigator:StackScreenNavigator = cast this._activeScreen;
			navigator.popToRootScreen();
		}
	}
	
	/**
	 * @private
	 */
	private function tabBar_changeHandler(event:Event):Void
	{
		if (this._ignoreTabBarChanges)
		{
			return;
		}
		var id:String = this.tabBar.selectedItem;
		if (this._activeScreenID == id)
		{
			//we're already showing this screen, so no need to do anything
			//this probably isn't a bug because we sometimes update the
			//tab bar's selected index after the activeScreenID is updated
			return;
		}
		var transition:Function = null;
		if (this._activeScreenID == null)
		{
			transition = BaseScreenNavigator.defaultTransition;
		}
		this.showScreen(id, transition);
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
	private function dragTransition(oldScreen:IFeathersControl, newScreen:IFeathersControl, onComplete:Function):Void
	{
		this._savedTransitionOnComplete = onComplete;
		if (this._swipeTween != null)
		{
			//it's possible that TouchPhase.ENDED is dispatched before the
			//transition starts. if that's the case, the tween will already
			//be created, and we simply add it to the juggler.
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			starling.juggler.add(this._swipeTween);
		}
		else
		{
			this.handleDragMove();
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
		
		var point:Point = Pool.getPoint();
		touch.getLocation(this, point);
		var localX:Float = point.x;
		var localY:Float = point.y;
		Pool.putPoint(point);
		
		this.touchPointID = touch.id;
		this._velocityX = 0;
		this._velocityY = 0;
		this._previousVelocityX.resize(0);
		this._previousVelocityY.resize(0);
		this._previousTouchTime = Lib.getTimer();
		this._previousTouchX = this._startTouchX = this._currentTouchX = localX;
		this._previousTouchY = this._startTouchY = this._currentTouchY = localY;
		this._isDraggingPrevious = false;
		this._isDraggingNext = false;
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
		this._currentTouchY = point.y;
		Pool.putPoint(point);
		var now:Int = Lib.getTimer();
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
	private function handleDragMove():Void
	{
		if (this._tabBarPosition == RelativePosition.LEFT ||
			this._tabBarPosition == RelativePosition.RIGHT)
		{
			this._previousScreenInTransition.y = this._currentTouchY - this._startTouchY;
		}
		else //top or bottom
		{
			this._previousScreenInTransition.x = this._currentTouchX - this._startTouchX;
		}
		this.swipeTween_onUpdate();
	}
	
	/**
	 * @private
	 */
	override function transitionComplete(cancelTransition:Bool = false):Void
	{
		if (cancelTransition)
		{
			this._selectedIndex = this._tabBarDataProvider.getItemIndex(this._previousScreenInTransitionID);
			var oldIgnoreTabBarChanges:Bool = this._ignoreTabBarChanges;
			this._ignoreTabBarChanges = true;
			this.tabBar.selectedIndex = this._selectedIndex;
			this._ignoreTabBarChanges = oldIgnoreTabBarChanges;
		}
		super.transitionComplete(cancelTransition);
	}
	
	/**
	 * @private
	 */
	private function swipeTween_onUpdate():Void
	{
		if (this._tabBarPosition == RelativePosition.LEFT ||
			this._tabBarPosition == RelativePosition.RIGHT)
		{
			if (this._isDraggingPrevious)
			{
				this._activeScreen.x = this._previousScreenInTransition.x;
				this._activeScreen.y = this._previousScreenInTransition.y - this._activeScreen.height;
			}
			else if (this._isDraggingNext)
			{
				this._activeScreen.x = this._previousScreenInTransition.x;
				this._activeScreen.y = this._previousScreenInTransition.y + this._previousScreenInTransition.height;
			}
		}
		else //top or bottom
		{
			if (this._isDraggingPrevious)
			{
				this._activeScreen.x = this._previousScreenInTransition.x - this._activeScreen.width;
				this._activeScreen.y = this._previousScreenInTransition.y;
			}
			else if (this._isDraggingNext)
			{
				this._activeScreen.x = this._previousScreenInTransition.x + this._previousScreenInTransition.width;
				this._activeScreen.y = this._previousScreenInTransition.y;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function swipeTween_onComplete():Void
	{
		this._swipeTween = null;
		this._isDragging = false;
		this._isDraggingPrevious = false;
		this._isDraggingNext = false;
		var cancelled:Bool = this._dragCancelled;
		this._dragCancelled = false;
		var onComplete:Function = this._savedTransitionOnComplete;
		this._savedTransitionOnComplete = null;
		onComplete(cancelled);
	}
	
	/**
	 * @private
	 */
	private function handleDragEnd():Void
	{
		this._dragCancelled = false;
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var sum:Float;
		var velocityCount:Int;
		var totalWeight:Float;
		var weight:Float;
		if (this._tabBarPosition == RelativePosition.LEFT ||
			this._tabBarPosition == RelativePosition.RIGHT)
		{
			//take the average for more accuracy
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
			
			if (inchesPerSecondY < -this._minimumSwipeVelocity)
			{
				//force next
				if (this._isDraggingPrevious)
				{
					this._dragCancelled = true;
				}
			}
			else if (inchesPerSecondY > this._minimumSwipeVelocity)
			{
				//force previous
				if (this._isDraggingNext)
				{
					this._dragCancelled = true;
				}
			}
			else if (this._activeScreen.y >= (this.screenContainer.height / 2))
			{
				if (this._isDraggingNext)
				{
					this._dragCancelled = true;
				}
			}
			else if (this._activeScreen.y <= -(this.screenContainer.height / 2))
			{
				if (this._isDraggingPrevious)
				{
					this._dragCancelled = true;
				}
			}
		}
		else //top or bottom
		{
			sum = this._velocityX * CURRENT_VELOCITY_WEIGHT;
			velocityCount = this._previousVelocityX.length;
			totalWeight = CURRENT_VELOCITY_WEIGHT;
			for (i in 0...velocityCount)
			{
				weight = VELOCITY_WEIGHTS[i];
				sum += this._previousVelocityX.shift() * weight;
				totalWeight += weight;
			}
			
			var inchesPerSecondX:Float = 1000 * (sum / totalWeight) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
			
			if (inchesPerSecondX < -this._minimumSwipeVelocity)
			{
				//force next
				if (this._isDraggingPrevious)
				{
					this._dragCancelled = true;
				}
			}
			else if (inchesPerSecondX > this._minimumSwipeVelocity)
			{
				//force previous
				if (this._isDraggingNext)
				{
					this._dragCancelled = true;
				}
			}
			else if (this._activeScreen.x >= (this.screenContainer.width / 2))
			{
				if (this._isDraggingNext)
				{
					this._dragCancelled = true;
				}
			}
			else if (this._activeScreen.x <= -(this.screenContainer.width / 2))
			{
				if (this._isDraggingPrevious)
				{
					this._dragCancelled = true;
				}
			}
		}
		
		this._swipeTween = new Tween(this._previousScreenInTransition, this._swipeDuration, this._swipeEase);
		if (this._tabBarPosition == RelativePosition.LEFT ||
			this._tabBarPosition == RelativePosition.RIGHT)
		{
			if (this._dragCancelled)
			{
				this._swipeTween.animate("y", 0);
			}
			else if (this._isDraggingPrevious)
			{
				this._swipeTween.animate("y", this.screenContainer.height);
			}
			else if (this._isDraggingNext)
			{
				this._swipeTween.animate("y", -this.screenContainer.height);
			}
		}
		else //top or bottom
		{
			if (this._dragCancelled)
			{
				this._swipeTween.animate("x", 0);
			}
			else if (this._isDraggingPrevious)
			{
				this._swipeTween.animate("x", this.screenContainer.width);
			}
			else if (this._isDraggingNext)
			{
				this._swipeTween.animate("x", -this.screenContainer.width);
			}
		}
		this._swipeTween.onUpdate = this.swipeTween_onUpdate;
		this._swipeTween.onComplete = this.swipeTween_onComplete;
		if (this._savedTransitionOnComplete != null)
		{
			//it's possible that we get here before the transition has
			//officially start. if that's the case, we won't add the tween
			//to the juggler now, and we'll do it later.
			starling.juggler.add(this._swipeTween);
		}
	}
	
	/**
	 * @private
	 */
	private function checkForDrag():Void
	{
		var maxIndex:Int = this._tabBarDataProvider.length - 1;
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var horizontalInchesMoved:Float = (this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		var verticalInchesMoved:Float = (this._currentTouchY - this._startTouchY) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		if (this._tabBarPosition == RelativePosition.LEFT ||
			this._tabBarPosition == RelativePosition.RIGHT)
		{
			if (this._selectedIndex > 0 && verticalInchesMoved >= this._minimumDragDistance)
			{
				this._isDraggingPrevious = true;
			}
			else if (this._selectedIndex < maxIndex && verticalInchesMoved <= -this._minimumDragDistance)
			{
				this._isDraggingNext = true;
			}
		}
		else //top or bottom
		{
			if (this._selectedIndex > 0 && horizontalInchesMoved >= this._minimumDragDistance)
			{
				this._isDraggingPrevious = true;
			}
			else if (this._selectedIndex < maxIndex && horizontalInchesMoved <= -this._minimumDragDistance)
			{
				this._isDraggingNext = true;
			}
		}
		
		if (this._isDraggingPrevious)
		{
			var previousIndex:Int = this._selectedIndex - 1;
			this._isDragging = true;
			var previousID:String = this._tabBarDataProvider.getItemAt(previousIndex);
			this.showScreen(previousID, dragTransition);
		}
		if (this._isDraggingNext)
		{
			var nextIndex:Int = this._selectedIndex + 1;
			this._isDragging = true;
			var nextID:String = this._tabBarDataProvider.getItemAt(nextIndex);
			this.showScreen(nextID, dragTransition);
		}
		if (this._isDragging)
		{
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
	private function screenContainer_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled || this._swipeTween != null || !this._isSwipeEnabled)
		{
			this.touchPointID = -1;
			return;
		}
		var touch:Touch;
		if (this.touchPointID >= 0)
		{
			touch = event.getTouch(this.screenContainer, null, this.touchPointID);
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
				this.touchPointID = -1;
				if (this._isDragging)
				{
					this.handleDragEnd();
					this.dispatchEventWith(FeathersEventType.END_INTERACTION);
				}
			}
		}
		else
		{
			touch = event.getTouch(this.screenContainer, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this.handleTouchBegan(touch);
		}
	}
}