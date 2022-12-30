/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusDisplayObject;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.events.ExclusiveTouch;
import feathers.events.FeathersEventType;
import feathers.layout.Direction;
import feathers.layout.RelativePosition;
import feathers.system.DeviceCapabilities;
import feathers.utils.math.MathUtils;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import feathers.controls.supportClasses.IViewPort;
import feathers.core.IFeathersControl;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.MathUtil;
import starling.utils.Pool;

/**
 * Allows horizontal and vertical scrolling of a <em>view port</em>. Not
 * meant to be used as a standalone container or component. Generally meant
 * to be the super class of another component that needs to support
 * scrolling. To put components in a generic scrollable container (with
 * optional layout), see <code>ScrollContainer</code>. To scroll long
 * passages of text, see <code>ScrollText</code>.
 *
 * <p>This component is generally not instantiated directly. Instead it is
 * typically used as a super class for other scrolling components like lists
 * and containers. With that in mind, no code example is included here.</p>
 *
 * @see feathers.controls.ScrollContainer
 *
 * @productversion Feathers 1.1.0
 */
class Scroller extends FeathersControl implements IFocusDisplayObject
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_SCROLL_BAR_RENDERER:String = "scrollBarRenderer";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_PENDING_SCROLL:String = "pendingScroll";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_PENDING_REVEAL_SCROLL_BARS:String = "pendingRevealScrollBars";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_PENDING_PULL_VIEW:String = "pendingPullView";

	/**
	 * Flag to indicate that the clipping has changed.
	 */
	private static inline var INVALIDATION_FLAG_CLIPPING:String = "clipping";
	
	/**
	 * @private
	 * The point where we stop calculating velocity changes because floating
	 * point issues can start to appear.
	 */
	private static inline var MINIMUM_VELOCITY:Float = 0.02;
	
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
	 * The default value added to the <code>styleNameList</code> of the
	 * horizontal scroll bar.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_HORIZONTAL_SCROLL_BAR:String = "feathers-scroller-horizontal-scroll-bar";

	/**
	 * The default value added to the <code>styleNameList</code> of the vertical
	 * scroll bar.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_VERTICAL_SCROLL_BAR:String = "feathers-scroller-vertical-scroll-bar";
	
	/**
	 * @private
	 */
	private static inline var PAGE_INDEX_EPSILON:Float = 0.01;
	
	/**
	 * @private
	 */
	private static function defaultScrollBarFactory():IScrollBar
	{
		return new SimpleScrollBar();
	}

	/**
	 * @private
	 */
	private static function defaultThrowEase(ratio:Float):Float
	{
		ratio -= 1;
		return 1 - ratio * ratio * ratio * ratio;
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		
		this.addEventListener(Event.ADDED_TO_STAGE, scroller_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, scroller_removedFromStageHandler);
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the horizontal
	 * scroll bar. This variable is <code>protected</code> so that
	 * sub-classes can customize the horizontal scroll bar style name in
	 * their constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_HORIZONTAL_SCROLL_BAR</code>.
	 *
	 * <p>To customize the horizontal scroll bar style name without
	 * subclassing, see <code>customHorizontalScrollBarStyleName</code>.</p>
	 *
	 * @see #style:customHorizontalScrollBarStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var horizontalScrollBarStyleName:String = DEFAULT_CHILD_STYLE_NAME_HORIZONTAL_SCROLL_BAR;
	
	/**
	 * The value added to the <code>styleNameList</code> of the vertical
	 * scroll bar. This variable is <code>protected</code> so that
	 * sub-classes can customize the vertical scroll bar style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_VERTICAL_SCROLL_BAR</code>.
	 *
	 * <p>To customize the vertical scroll bar style name without
	 * subclassing, see <code>customVerticalScrollBarStyleName</code>.</p>
	 *
	 * @see #style:customVerticalScrollBarStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var verticalScrollBarStyleName:String = DEFAULT_CHILD_STYLE_NAME_VERTICAL_SCROLL_BAR;
	
	/**
	 * The horizontal scrollbar instance. May be null.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #horizontalScrollBarFactory
	 * @see #createScrollBars()
	 */
	private var horizontalScrollBar:IScrollBar;
	
	/**
	 * The vertical scrollbar instance. May be null.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #verticalScrollBarFactory
	 * @see #createScrollBars()
	 */
	private var verticalScrollBar:IScrollBar;
	
	/**
	 * @private
	 */
	override function get_isFocusEnabled():Bool
	{
		return (this._maxVerticalScrollPosition != this._minVerticalScrollPosition ||
			this._maxHorizontalScrollPosition != this._minHorizontalScrollPosition) &&
			super.isFocusEnabled;
	}
	
	/**
	 * @private
	 */
	private var _topViewPortOffset:Float;

	/**
	 * @private
	 */
	private var _rightViewPortOffset:Float;

	/**
	 * @private
	 */
	private var _bottomViewPortOffset:Float;

	/**
	 * @private
	 */
	private var _leftViewPortOffset:Float;

	/**
	 * @private
	 */
	private var _hasHorizontalScrollBar:Bool = false;

	/**
	 * @private
	 */
	private var _hasVerticalScrollBar:Bool = false;

	/**
	 * @private
	 */
	private var _horizontalScrollBarTouchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _verticalScrollBarTouchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;

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
	private var _startHorizontalScrollPosition:Float;
	
	/**
	 * @private
	 */
	private var _startVerticalScrollPosition:Float;
	
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
	private var _pendingVelocityChange:Bool = false;

	/**
	 * @private
	 */
	private var _lastViewPortWidth:Float = 0;

	/**
	 * @private
	 */
	private var _lastViewPortHeight:Float = 0;

	/**
	 * @private
	 */
	private var _hasViewPortBoundsChanged:Bool = false;

	/**
	 * @private
	 */
	private var _horizontalAutoScrollTween:Tween;

	/**
	 * @private
	 */
	private var _verticalAutoScrollTween:Tween;

	/**
	 * @private
	 */
	private var _topPullTween:Tween;

	/**
	 * @private
	 */
	private var _rightPullTween:Tween;

	/**
	 * @private
	 */
	private var _bottomPullTween:Tween;

	/**
	 * @private
	 */
	private var _leftPullTween:Tween;
	
	/**
	 * @private
	 */
	private var _isDraggingHorizontally:Bool = false;

	/**
	 * @private
	 */
	private var _isDraggingVertically:Bool = false;

	/**
	 * @private
	 */
	private var ignoreViewPortResizing:Bool = false;
	
	/**
	 * The display object displayed and scrolled within the Scroller.
	 *
	 * @default null
	 */
	public var viewPort(get, set):IViewPort;
	private var _viewPort:IViewPort;
	private function get_viewPort():IViewPort { return this._viewPort; }
	private function set_viewPort(value:IViewPort):IViewPort
	{
		if (this._viewPort == value)
		{
			return value;
		}
		if (this._viewPort != null)
		{
			this._viewPort.removeEventListener(FeathersEventType.RESIZE, viewPort_resizeHandler);
			this.removeRawChildInternal(cast this._viewPort);
		}
		this._viewPort = value;
		if (this._viewPort != null)
		{
			this._viewPort.addEventListener(FeathersEventType.RESIZE, viewPort_resizeHandler);
			this.addRawChildAtInternal(cast this._viewPort, 0);
			if (Std.isOfType(this._viewPort, IFeathersControl))
			{
				cast(this._viewPort, IFeathersControl).initializeNow();
			}
			this._explicitViewPortWidth = this._viewPort.explicitWidth;
			this._explicitViewPortHeight = this._viewPort.explicitHeight;
			this._explicitViewPortMinWidth = this._viewPort.explicitMinWidth;
			this._explicitViewPortMinHeight = this._viewPort.explicitMinHeight;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._viewPort;
	}
	
	/**
	 * @private
	 */
	private var _explicitViewPortWidth:Float;

	/**
	 * @private
	 */
	private var _explicitViewPortHeight:Float;

	/**
	 * @private
	 */
	private var _explicitViewPortMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitViewPortMinHeight:Float;
	
	/**
	 * Determines if the dimensions of the view port are used when measuring
	 * the scroller. If disabled, only children other than the view port
	 * (such as the background skin) are used for measurement.
	 *
	 * <p>In the following example, the view port measurement is disabled:</p>
	 *
	 * <listing version="3.0">
	 * scroller.measureViewPort = false;</listing>
	 *
	 * @default true
	 */
	public var measureViewPort(get, set):Bool;
	private var _measureViewPort:Bool = true;
	private function get_measureViewPort():Bool { return this._measureViewPort; }
	private function set_measureViewPort(value:Bool):Bool
	{
		if (this._measureViewPort == value)
		{
			return value;
		}
		this._measureViewPort = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._measureViewPort;
	}
	
	/**
	 * @private
	 */
	public var snapToPages(get, set):Bool;
	private var _snapToPages:Bool = false;
	private function get_snapToPages():Bool { return this._snapToPages; }
	private function set_snapToPages(value:Bool):Bool
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._snapToPages == value)
		{
			return value;
		}
		this._snapToPages = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		return this._snapToPages;
	}
	
	/**
	 * @private
	 */
	private var _snapOnComplete:Bool = false;
	
	/**
	 * Creates the horizontal scroll bar. The horizontal scroll bar must be
	 * an instance of <code>IScrollBar</code>. This factory can be used to
	 * change properties on the horizontal scroll bar when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to set skins and other
	 * styles on the horizontal scroll bar.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():IScrollBar</pre>
	 *
	 * <p>In the following example, a custom horizontal scroll bar factory
	 * is passed to the scroller:</p>
	 *
	 * <listing version="3.0">
	 * scroller.horizontalScrollBarFactory = function():IScrollBar
	 * {
	 *     return new ScrollBar();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.IScrollBar
	 */
	public var horizontalScrollBarFactory(get, set):Void->IScrollBar;
	private var _horizontalScrollBarFactory = defaultScrollBarFactory;
	private function get_horizontalScrollBarFactory():Void->IScrollBar { return this._horizontalScrollBarFactory; }
	private function set_horizontalScrollBarFactory(value:Void->IScrollBar):Void->IScrollBar
	{
		if (this._horizontalScrollBarFactory == value)
		{
			return value;
		}
		this._horizontalScrollBarFactory = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		return this._horizontalScrollBarFactory;
	}
	
	/**
	 * @private
	 */
	public var customHorizontalScrollBarStyleName(get, set):String;
	private var _customHorizontalScrollBarStyleName:String;
	private function get_customHorizontalScrollBarStyleName():String { return this._customHorizontalScrollBarStyleName; }
	private function set_customHorizontalScrollBarStyleName(value:String):String
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._customHorizontalScrollBarStyleName == value)
		{
			return value;
		}
		this._customHorizontalScrollBarStyleName = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		return this._customHorizontalScrollBarStyleName;
	}
	
	/**
	 * An object that stores properties for the container's horizontal
	 * scroll bar, and the properties will be passed down to the horizontal
	 * scroll bar when the container validates. The available properties
	 * depend on which <code>IScrollBar</code> implementation is returned
	 * by <code>horizontalScrollBarFactory</code>. Refer to
	 * <a href="IScrollBar.html"><code>feathers.controls.IScrollBar</code></a>
	 * for a list of available scroll bar implementations.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>horizontalScrollBarFactory</code>
	 * function instead of using <code>horizontalScrollBarProperties</code>
	 * will result in better performance.</p>
	 *
	 * <p>In the following example, properties for the horizontal scroll bar
	 * are passed to the scroller:</p>
	 *
	 * <listing version="3.0">
	 * scroller.horizontalScrollBarProperties.liveDragging = false;</listing>
	 *
	 * @default null
	 *
	 * @see #horizontalScrollBarFactory
	 * @see feathers.controls.IScrollBar
	 * @see feathers.controls.SimpleScrollBar
	 * @see feathers.controls.ScrollBar
	 */
	public var horizontalScrollBarProperties(get, set):Dynamic;
	private var _horizontalScrollBarProperties:PropertyProxy;
	private function get_horizontalScrollBarProperties():Dynamic
	{
		if (this._horizontalScrollBarProperties == null)
		{
			this._horizontalScrollBarProperties = new PropertyProxy(childProperties_change);
		}
		return this._horizontalScrollBarProperties;
	}
	
	private function set_horizontalScrollBarProperties(value:Dynamic):Dynamic
	{
		if (this._horizontalScrollBarProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxy))
		{
			var newValue:PropertyProxy = PropertyProxy.fromObject(value);
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			value = newValue;
		}
		if (this._horizontalScrollBarProperties != null)
		{
			this._horizontalScrollBarProperties.removeOnChangeCallback(childProperties_onChange);
			this._horizontalScrollBarProperties.dispose();
		}
		this._horizontalScrollBarProperties = cast value;
		if (this._horizontalScrollBarProperties != null)
		{
			this._horizontalScrollBarProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._horizontalScrollBarProperties;
	}
	
	/**
	 * @private
	 */
	public var verticalScrollBarPosition(get, set):String;
	private var _verticalScrollBarPosition:String = RelativePosition.RIGHT;
	private function get_verticalScrollBarPosition():String { return this._verticalScrollBarPosition; }
	private function set_verticalScrollBarPosition(value:String):String
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._verticalScrollBarPosition == value)
		{
			return value;
		}
		this._verticalScrollBarPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._verticalScrollBarPosition;
	}
	
	/**
	 * @private
	 */
	public var horizontalScrollBarPosition(get, set):String;
	private var _horizontalScrollBarPosition:String = RelativePosition.BOTTOM;
	private function get_horizontalScrollBarPosition():String { return this._horizontalScrollBarPosition; }
	private function set_horizontalScrollBarPosition(value:String):String
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._horizontalScrollBarPosition == value)
		{
			return value;
		}
		this._horizontalScrollBarPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._horizontalScrollBarPosition;
	}
	
	/**
	 * Creates the vertical scroll bar. The vertical scroll bar must be an
	 * instance of <code>Button</code>. This factory can be used to change
	 * properties on the vertical scroll bar when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the
	 * vertical scroll bar.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():IScrollBar</pre>
	 *
	 * <p>In the following example, a custom vertical scroll bar factory
	 * is passed to the scroller:</p>
	 *
	 * <listing version="3.0">
	 * scroller.verticalScrollBarFactory = function():IScrollBar
	 * {
	 *     return new ScrollBar();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.IScrollBar
	 */
	public var verticalScrollBarFactory(get, set):Void->IScrollBar;
	private var _verticalScrollBarFactory:Void->IScrollBar;
	private function get_verticalScrollBarFactory():Void->IScrollBar { return this._verticalScrollBarFactory; }
	private function set_verticalScrollBarFactory(value:Void->IScrollBar):Void->IScrollBar
	{
		if (this._verticalScrollBarFactory == value)
		{
			return value;
		}
		this._verticalScrollBarFactory = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		return this._verticalScrollBarFactory;
	}
	
	/**
	 * @private
	 */
	public var customVerticalScrollBarStyleName(get, set):String;
	private var _customVerticalScrollBarStyleName:String;
	private function get_customVerticalScrollBarStyleName():String { return this._customVerticalScrollBarStyleName; }
	private function set_customVerticalScrollBarStyleName(value:String):String
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._customVerticalScrollBarStyleName == value)
		{
			return value;
		}
		this._customVerticalScrollBarStyleName = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		return this._customVerticalScrollBarStyleName;
	}
	
	/**
	 * An object that stores properties for the container's vertical scroll
	 * bar, and the properties will be passed down to the vertical scroll
	 * bar when the container validates. The available properties depend on
	 * which <code>IScrollBar</code> implementation is returned by
	 * <code>verticalScrollBarFactory</code>. Refer to
	 * <a href="IScrollBar.html"><code>feathers.controls.IScrollBar</code></a>
	 * for a list of available scroll bar implementations.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>verticalScrollBarFactory</code>
	 * function instead of using <code>verticalScrollBarProperties</code>
	 * will result in better performance.</p>
	 *
	 * <p>In the following example, properties for the vertical scroll bar
	 * are passed to the container:</p>
	 *
	 * <listing version="3.0">
	 * scroller.verticalScrollBarProperties.liveDragging = false;</listing>
	 *
	 * @default null
	 *
	 * @see #verticalScrollBarFactory
	 * @see feathers.controls.IScrollBar
	 * @see feathers.controls.SimpleScrollBar
	 * @see feathers.controls.ScrollBar
	 */
	public var verticalScrollBarProperties(get, set):Dynamic;
	private var _verticalScrollBarProperties:PropertyProxy;
	private function get_verticalScrollBarProperties():Dynamic
	{
		if (this._verticalScrollBarProperties == null)
		{
			this._verticalScrollBarProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._verticalScrollBarProperties;
	}
	
	private function set_verticalScrollBarProperties(value:Dynamic):Dynamic
	{
		if (this._horizontalScrollBarProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxy))
		{
			var newValue:PropertyProxy = PropertyProxy.fromObject(value);
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			value = newValue;
		}
		if (this._verticalScrollBarProperties != null)
		{
			this._verticalScrollBarProperties.removeOnChangeCallback(childProperties_onChange);
			this._verticalScrollBarProperties.dispose();
		}
		this._verticalScrollBarProperties = cast value;
		if (this._verticalScrollBarProperties != null)
		{
			this._verticalScrollBarProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._verticalScrollBarProperties;
	}
	
	/**
	 * @private
	 */
	private var actualHorizontalScrollStep:Float = 1;
	
	/**
	 * @private
	 */
	private var explicitHorizontalScrollStep:Float = Math.NaN;
	
	/**
	 * The number of pixels the horizontal scroll position can be adjusted
	 * by a "step". Passed to the horizontal scroll bar, if one exists.
	 * Touch scrolling is not affected by the step value.
	 *
	 * <p>In the following example, the horizontal scroll step is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.horizontalScrollStep = 0;</listing>
	 *
	 * @default NaN
	 */
	public var horizontalScrollStep(get, set):Float;
	private function get_horizontalScrollStep():Float { return this.actualHorizontalScrollStep; }
	private function set_horizontalScrollStep(value:Float):Float
	{
		if (this.explicitHorizontalScrollStep == value)
		{
			return value;
		}
		this.explicitHorizontalScrollStep = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return this.explicitHorizontalScrollStep;
	}
	
	/**
	 * @private
	 */
	private var _targetHorizontalScrollPosition:Float;
	
	/**
	 * The number of pixels the container has been scrolled horizontally (on
	 * the x-axis).
	 *
	 * <p>In the following example, the horizontal scroll position is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.horizontalScrollPosition = scroller.maxHorizontalScrollPosition;</listing>
	 *
	 * @see #minHorizontalScrollPosition
	 * @see #maxHorizontalScrollPosition
	 */
	public var horizontalScrollPosition(get, set):Float;
	private var _horizontalScrollPosition:Float = 0;
	private function get_horizontalScrollPosition():Float { return this._horizontalScrollPosition; }
	private function set_horizontalScrollPosition(value:Float):Float
	{
		if (this._horizontalScrollPosition == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			//there isn't any recovery from this, so stop it early
			throw new ArgumentError("horizontalScrollPosition cannot be NaN.");
		}
		this._horizontalScrollPosition = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return this._horizontalScrollPosition;
	}
	
	/**
	 * The number of pixels the scroller may be scrolled horizontally to the
	 * left. This value is automatically calculated based on the bounds of
	 * the viewport. The <code>horizontalScrollPosition</code> property may
	 * have a lower value than the minimum due to elastic edges. However,
	 * once the user stops interacting with the scroller, it will
	 * automatically animate back to the maximum or minimum position.
	 *
	 * @see #horizontalScrollPosition
	 * @see #maxHorizontalScrollPosition
	 */
	public var minHorizontalScrollPosition(get, never):Float;
	private var _minHorizontalScrollPosition:Float = 0;
	private function get_minHorizontalScrollPosition():Float { return this._minHorizontalScrollPosition; }
	
	/**
	 * The number of pixels the scroller may be scrolled horizontally to the
	 * right. This value is automatically calculated based on the bounds of
	 * the viewport. The <code>horizontalScrollPosition</code> property may
	 * have a higher value than the maximum due to elastic edges. However,
	 * once the user stops interacting with the scroller, it will
	 * automatically animate back to the maximum or minimum position.
	 *
	 * @see #horizontalScrollPosition
	 * @see #minHorizontalScrollPosition
	 */
	public var maxHorizontalScrollPosition(get, never):Float;
	private var _maxHorizontalScrollPosition:Float = 0;
	private function get_maxHorizontalScrollPosition():Float { return this._maxHorizontalScrollPosition; }
	
	/**
	 * The index of the horizontal page, if snapping is enabled. If snapping
	 * is disabled, the index will always be <code>0</code>.
	 * 
	 * @see #horizontalPageCount
	 * @see #minHorizontalPageIndex
	 * @see #maxHorizontalPageIndex
	 */
	public var horizontalPageIndex(get, set):Int;
	private var _horizontalPageIndex:Int = 0;
	private function get_horizontalPageIndex():Int
	{
		if (this.hasPendingHorizontalPageIndex)
		{
			return this.pendingHorizontalPageIndex;
		}
		return this._horizontalPageIndex;
	}
	
	private function set_horizontalPageIndex(value:Int):Int
	{
		if (!this._snapToPages)
		{
			throw new IllegalOperationError("The horizontalPageIndex may not be set if snapToPages is false.");
		}
		this.hasPendingHorizontalPageIndex = false;
		this.pendingHorizontalScrollPosition = Math.NaN;
		if (this._horizontalPageIndex == value)
		{
			return value;
		}
		if (!this.isInvalid())
		{
			if (value < this._minHorizontalPageIndex)
			{
				value = this._minHorizontalPageIndex;
			}
			else if (value > this._maxHorizontalPageIndex)
			{
				value = this._maxHorizontalPageIndex;
			}
			this._horizontalScrollPosition = this.actualPageWidth * value;
		}
		else
		{
			//minimum and maximum values haven't been calculated yet, so we
			//need to wait for validation to change the scroll position
			this.hasPendingHorizontalPageIndex = true;
			this.pendingHorizontalPageIndex = value;
			this.pendingScrollDuration = 0;
		}
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return value;
	}
	
	/**
	 * The minimum horizontal page index that may be displayed by this
	 * container, if page snapping is enabled.
	 *
	 * @see #snapToPages
	 * @see #horizontalPageCount
	 * @see #maxHorizontalPageIndex
	 */
	public var minHorizontalPageIndex(get, never):Int;
	private var _minHorizontalPageIndex:Int = 0;
	private function get_minHorizontalPageIndex():Int { return this._minHorizontalPageIndex; }
	
	/**
	 * The maximum horizontal page index that may be displayed by this
	 * container, if page snapping is enabled.
	 *
	 * @see #snapToPages
	 * @see #horizontalPageCount
	 * @see #minHorizontalPageIndex
	 */
	public var maxHorizontalPageIndex(get, never):Int;
	private var _maxHorizontalPageIndex:Int = 0;
	private function get_maxHorizontalPageIndex():Int { return this._maxHorizontalPageIndex; }
	
	/**
	 * The number of horizontal pages, if snapping is enabled. If snapping
	 * is disabled, the page count will always be <code>1</code>.
	 *
	 * <p>If the scroller's view port supports infinite scrolling, this
	 * property will return <code>int.MAX_VALUE</code>, since an
	 * <code>int</code> cannot hold the value <code>Number.POSITIVE_INFINITY</code>.</p>
	 *
	 * @see #snapToPages
	 * @see #horizontalPageIndex
	 * @see #minHorizontalPageIndex
	 * @see #maxHorizontalPageIndex
	 */
	public var horizontalPageCount(get, never):Int;
	private function get_horizontalPageCount():Int
	{
		if(this._maxHorizontalPageIndex == MathUtils.INT_MAX ||
			this._minHorizontalPageIndex == MathUtils.INT_MIN)
		{
			return MathUtils.INT_MAX;
		}
		return this._maxHorizontalPageIndex - this._minHorizontalPageIndex + 1;
	}
	
	/**
	 * Determines whether the scroller may scroll horizontally (on the
	 * x-axis) or not.
	 *
	 * <p>In the following example, horizontal scrolling is disabled:</p>
	 *
	 * <listing version="3.0">
	 * scroller.horizontalScrollPolicy = ScrollPolicy.OFF;</listing>
	 *
	 * @default feathers.controls.ScrollPolicy.AUTO
	 *
	 * @see feathers.controls.ScrollPolicy#AUTO
	 * @see feathers.controls.ScrollPolicy#ON
	 * @see feathers.controls.ScrollPolicy#OFF
	 */
	public var horizontalScrollPolicy(get, set):String;
	private var _horizontalScrollPolicy:String = ScrollPolicy.AUTO;
	private function get_horizontalScrollPolicy():String { return this._horizontalScrollPolicy; }
	private function set_horizontalScrollPolicy(value:String):String
	{
		if (this._horizontalScrollPolicy == value)
		{
			return value;
		}
		this._horizontalScrollPolicy = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		this.invalidate(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		return this._horizontalScrollPolicy;
	}
	
	/**
	 * @private
	 */
	private var actualVerticalScrollStep:Float = 1;
	
	/**
	 * @private
	 */
	private var explicitVerticalScrollStep:Float = Math.NaN;
	
	/**
	 * The number of pixels the vertical scroll position can be adjusted
	 * by a "step". Passed to the vertical scroll bar, if one exists.
	 * Touch scrolling is not affected by the step value.
	 *
	 * <p>In the following example, the vertical scroll step is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.verticalScrollStep = 0;</listing>
	 *
	 * @default NaN
	 */
	public var verticalScrollStep(get, set):Float;
	private function get_verticalScrollStep():Float { return this.actualVerticalScrollStep; }
	private function set_verticalScrollStep(value:Float):Float
	{
		if (this.explicitVerticalScrollStep == value)
		{
			return value;
		}
		this.explicitVerticalScrollStep = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return this.explicitVerticalScrollStep;
	}
	
	/**
	 * The number of pixels the vertical scroll position can be adjusted by
	 * a "step" when using the mouse wheel. If this value is
	 * <code>NaN</code>, the mouse wheel will use the same scroll step as the scroll bars.
	 *
	 * <p>In the following example, the vertical mouse wheel scroll step is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.verticalMouseWheelScrollStep = 10;</listing>
	 *
	 * @default NaN
	 */
	public var verticalMouseWheelScrollStep(get, set):Float;
	private var _verticalMouseWheelScrollStep:Float = Math.NaN;
	private function get_verticalMouseWheelScrollStep():Float { return this._verticalMouseWheelScrollStep; }
	private function set_verticalMouseWheelScrollStep(value:Float):Float
	{
		if(this._verticalMouseWheelScrollStep == value)
		{
			return value;
		}
		this._verticalMouseWheelScrollStep = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return this._verticalMouseWheelScrollStep;
	}
	
	/**
	 * @private
	 */
	private var _targetVerticalScrollPosition:Float;
	
	/**
	 * The number of pixels the container has been scrolled vertically (on
	 * the y-axis).
	 *
	 * <p>In the following example, the vertical scroll position is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.verticalScrollPosition = scroller.maxVerticalScrollPosition;</listing>
	 * 
	 * @see #minVerticalScrollPosition
	 * @see #maxVerticalScrollPosition
	 */
	public var verticalScrollPosition(get, set):Float;
	private var _verticalScrollPosition:Float = 0;
	private function get_verticalScrollPosition():Float { return this._verticalScrollPosition; }
	private function set_verticalScrollPosition(value:Float):Float
	{
		if (this._verticalScrollPosition == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			//there isn't any recovery from this, so stop it early
			throw new ArgumentError("verticalScrollPosition cannot be NaN.");
		}
		this._verticalScrollPosition = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return this._verticalScrollPosition;
	}
	
	/**
	 * The number of pixels the scroller may be scrolled vertically beyond
	 * the top edge. This value is automatically calculated based on the
	 * bounds of the viewport. The <code>verticalScrollPosition</code>
	 * property may have a lower value than the minimum due to elastic
	 * edges. However, once the user stops interacting with the scroller, it
	 * will automatically animate back to the maximum or minimum position.
	 *
	 * @see #verticalScrollPosition
	 * @see #maxVerticalScrollPosition
	 */
	public var minVerticalScrollPosition(get, never):Float;
	private var _minVerticalScrollPosition:Float = 0;
	private function get_minVerticalScrollPosition():Float { return this._minVerticalScrollPosition; }
	
	/**
	 * The number of pixels the scroller may be scrolled vertically beyond
	 * the bottom edge. This value is automatically calculated based on the
	 * bounds of the viewport. The <code>verticalScrollPosition</code>
	 * property may have a lower value than the minimum due to elastic
	 * edges. However, once the user stops interacting with the scroller, it
	 * will automatically animate back to the maximum or minimum position.
	 *
	 * @see #verticalScrollPosition
	 * @see #minVerticalScrollPosition
	 */
	public var maxVerticalScrollPosition(get, never):Float;
	private var _maxVerticalScrollPosition:Float = 0;
	private function get_maxVerticalScrollPosition():Float { return this._maxVerticalScrollPosition; }
	
	/**
	 * The index of the vertical page, if snapping is enabled. If snapping
	 * is disabled, the index will always be <code>0</code>.
	 *
	 * @see #verticalPageCount
	 * @see #minVerticalPageIndex
	 * @see #maxVerticalPageIndex
	 */
	public var verticalPageIndex(get, set):Int;
	private var _verticalPageIndex:Int = 0;
	private function get_verticalPageIndex():Int
	{
		if (this.hasPendingVerticalPageIndex)
		{
			return this.pendingVerticalPageIndex;
		}
		return this._verticalPageIndex;
	}
	
	private function set_verticalPageIndex(value:Int):Int
	{
		if (!this._snapToPages)
		{
			throw new IllegalOperationError("The verticalPageIndex may not be set if snapToPages is false.");
		}
		this.hasPendingVerticalPageIndex = false;
		this.pendingVerticalScrollPosition = Math.NaN;
		if (this._verticalPageIndex == value)
		{
			return value;
		}
		if (!this.isInvalid())
		{
			if(value < this._minVerticalPageIndex)
			{
				value = this._minVerticalPageIndex;
			}
			else if(value > this._maxVerticalPageIndex)
			{
				value = this._maxVerticalPageIndex;
			}
			this._verticalScrollPosition = this.actualPageHeight * value;
		}
		else
		{
			//minimum and maximum values haven't been calculated yet, so we
			//need to wait for validation to change the scroll position
			this.hasPendingVerticalPageIndex = true;
			this.pendingVerticalPageIndex = value;
			this.pendingScrollDuration = 0;
		}
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return value;
	}
	
	/**
	 * The minimum vertical page index that may be displayed by this
	 * container, if page snapping is enabled.
	 *
	 * @see #snapToPages
	 * @see #verticalPageCount
	 * @see #maxVerticalPageIndex
	 */
	public var minVerticalPageIndex(get, never):Int;
	private var _minVerticalPageIndex:Int = 0;
	private function get_minVerticalPageIndex():Int { return this._minVerticalPageIndex; }
	
	/**
	 * The maximum vertical page index that may be displayed by this
	 * container, if page snapping is enabled.
	 *
	 * @see #snapToPages
	 * @see #verticalPageCount
	 * @see #minVerticalPageIndex
	 */
	public var maxVerticalPageIndex(get, never):Int;
	private var _maxVerticalPageIndex:Int = 0;
	private function get_maxVerticalPageIndex():Int { return this._maxVerticalPageIndex; }
	
	/**
	 * The number of vertical pages, if snapping is enabled. If snapping
	 * is disabled, the page count will always be <code>1</code>.
	 *
	 * <p>If the scroller's view port supports infinite scrolling, this
	 * property will return <code>int.MAX_VALUE</code>, since an
	 * <code>int</code> cannot hold the value <code>Number.POSITIVE_INFINITY</code>.</p>
	 *
	 * @see #snapToPages
	 * @see #verticalPageIndex
	 * @see #minVerticalPageIndex
	 * @see #maxVerticalPageIndex
	 */
	public var verticalPageCount(get, never):Int;
	private function get_verticalPageCount():Int
	{
		if (this._maxVerticalPageIndex == MathUtils.INT_MAX ||
			this._minVerticalPageIndex == MathUtils.INT_MIN)
		{
			return MathUtils.INT_MAX;
		}
		return this._maxVerticalPageIndex - this._minVerticalPageIndex + 1;
	}
	
	/**
	 * Determines whether the scroller may scroll vertically (on the
	 * y-axis) or not.
	 *
	 * <p>In the following example, vertical scrolling is disabled:</p>
	 *
	 * <listing version="3.0">
	 * scroller.verticalScrollPolicy = ScrollPolicy.OFF;</listing>
	 *
	 * @default feathers.controls.ScrollPolicy.AUTO
	 *
	 * @see feathers.controls.ScrollPolicy#AUTO
	 * @see feathers.controls.ScrollPolicy#ON
	 * @see feathers.controls.ScrollPolicy#OFF
	 */
	public var verticalScrollPolicy(get, set):String;
	private var _verticalScrollPolicy:String = ScrollPolicy.AUTO;
	private function get_verticalScrollPolicy():String { return this._verticalScrollPolicy; }
	private function set_verticalScrollPolicy(value:String):String
	{
		if (this._verticalScrollPolicy == value)
		{
			return value;
		}
		this._verticalScrollPolicy = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		this.invalidate(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		return this._verticalScrollPolicy;
	}
	
	/**
	 * @private
	 */
	public var clipContent(get, set):Bool;
	private var _clipContent:Bool = true;
	private function get_clipContent():Bool { return this._clipContent; }
	private function set_clipContent(value:Bool):Bool
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._clipContent == value)
		{
			return value;
		}
		this._clipContent = value;
		if (!value && this._viewPort)
		{
			this._viewPort.mask = null;
		}
		this.invalidate(INVALIDATION_FLAG_CLIPPING);
		return this._clipContent;
	}
	
	/**
	 * @private
	 */
	private var actualPageWidth:Float = 0;

	/**
	 * @private
	 */
	private var explicitPageWidth:Float = Math.NaN;
	
	/**
	 * When set, the horizontal pages snap to this width value instead of
	 * the width of the scroller.
	 *
	 * <p>In the following example, the page width is set to 200 pixels:</p>
	 *
	 * <listing version="3.0">
	 * scroller.pageWidth = 200;</listing>
	 *
	 * @see #snapToPages
	 */
	public var pageWidth(get, set):Float;
	private function get_pageWidth():Float { return this.actualPageWidth; }
	private function set_pageWidth(value:Float):Float
	{
		if (this.explicitPageWidth == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN && this.explicitPageWidth != this.explicitPageWidth) //isNaN
		{
			return value;
		}
		this.explicitPageWidth = value;
		if (valueIsNaN)
		{
			//we need to calculate this value during validation
			this.actualPageWidth = 0;
		}
		else
		{
			this.actualPageWidth = this.explicitPageWidth;
		}
		return this.explicitPageWidth;
	}
	
	/**
	 * @private
	 */
	private var actualPageHeight:Float = 0;

	/**
	 * @private
	 */
	private var explicitPageHeight:Float = Math.NaN;
	
	/**
	 * When set, the vertical pages snap to this height value instead of
	 * the height of the scroller.
	 *
	 * <p>In the following example, the page height is set to 200 pixels:</p>
	 *
	 * <listing version="3.0">
	 * scroller.pageHeight = 200;</listing>
	 *
	 * @see #snapToPages
	 */
	public var pageHeight(get, set):Float;
	private function get_pageHeight():Float { return this.actualPageHeight; }
	private function set_pageHeight(value:Float):Float
	{
		if (this.explicitPageHeight == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN && this.explicitPageHeight != this.explicitPageHeight) //isNaN
		{
			return value;
		}
		this.explicitPageHeight = value;
		if (valueIsNaN)
		{
			//we need to calculate this value during validation
			this.actualPageHeight = 0;
		}
		else
		{
			this.actualPageHeight = this.explicitPageHeight;
		}
		return this.explicitPageHeight;
	}
	
	/**
	 * @private
	 */
	public var hasElasticEdges(get, set):Bool;
	private var _hasElasticEdges:Bool = true;
	private function get_hasElasticEdges():Bool { return this._hasElasticEdges; }
	private function set_hasElasticEdges(value:Bool):Bool
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._hasElasticEdges = value;
	}
	
	/**
	 * @private
	 */
	public var elasticity(get, set):Float;
	private var _elasticity:Float = 0.33;
	private function get_elasticity():Float { return this._elasticity; }
	private function set_elasticity(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._elasticity = value;
	}
	
	/**
	 * @private
	 */
	public var throwElasticity(get, set):Float;
	private var _throwElasticity:Float = 0.05;
	private function get_throwElasticity():Float { return this._throwElasticity; }
	private function set_throwElasticity(value:Float):Float
	{
		if( this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._throwElasticity = value;
	}
	
	/**
	 * @private
	 */
	public var scrollBarDisplayMode(get, set):String;
	private var _scrollBarDisplayMode:String = ScrollBarDisplayMode.FLOAT;
	private function get_scrollBarDisplayMode():String { return this._scrollBarDisplayMode; }
	private function set_scrollBarDisplayMode(value:String):String
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._scrollBarDisplayMode == value)
		{
			return value;
		}
		this._scrollBarDisplayMode = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._scrollBarDisplayMode;
	}
	
	/**
	 * @private
	 */
	public var interactionMode(get, set):String;
	private var _interactionMode:String = ScrollInteractionMode.TOUCH;
	private function get_interactionMode():String { return this._interactionMode; }
	private function set_interactionMode(value:String):String
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._interactionMode == value)
		{
			return value;
		}
		this._interactionMode = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._interactionMode;
	}
	
	/**
	 * @private
	 */
	private var _explicitBackgroundWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMinWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMinHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMaxWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMaxHeight:Float;
	
	/**
	 * @private
	 */
	private var currentBackgroundSkin:DisplayObject;
	
	/**
	 * @private
	 */
	public var backgroundSkin(get, set):DisplayObject;
	private var _backgroundSkin:DisplayObject;
	private function get_backgroundSkin():DisplayObject { return this._backgroundSkin; }
	private function set_backgroundSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._backgroundSkin == value)
		{
			return value;
		}
		if (this._backgroundSkin != null &&
			this.currentBackgroundSkin == this._backgroundSkin)
		{
			this.removeCurrentBackgroundSkin(this._backgroundSkin);
			this.currentBackgroundSkin = null;
		}
		this._backgroundSkin = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._backgroundSkin;
	}
	
	/**
	 * @private
	 */
	public var backgroundDisabledSkin(get, set):DisplayObject;
	private var _backgroundDisabledSkin:DisplayObject;
	private function get_backgroundDisabledSkin():DisplayObject { return this._backgroundDisabledSkin; }
	private function set_backgroundDisabledSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._backgroundDisabledSkin == value)
		{
			return value;
		}
		if (this._backgroundDisabledSkin != null &&
			this.currentBackgroundSkin == this._backgroundDisabledSkin)
		{
			this.removeCurrentBackgroundSkin(this._backgroundDisabledSkin);
			this.currentBackgroundSkin = null;
		}
		this._backgroundDisabledSkin = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._backgroundDisabledSkin;
	}
	
	/**
	 * @private
	 */
	public var autoHideBackground(get, set):Bool;
	private var _autoHideBackground:Bool = false;
	private function get_autoHideBackground():Bool { return this._autoHideBackground; }
	private function set_autoHideBackground(value:Bool):Bool
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._autoHideBackground == value)
		{
			return value;
		}
		this._autoHideBackground = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._autoHideBackground;
	}
	
	/**
	 * The minimum physical distance (in inches) that a touch must move
	 * before the scroller starts scrolling.
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
	 * must move before the scroller will "throw" to the next page.
	 * Otherwise, it will settle to the nearest page.
	 *
	 * <p>In the following example, the minimum page throw velocity is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.minimumPageThrowVelocity = 2;</listing>
	 *
	 * @default 5
	 */
	public var minimumPageThrowVelocity(get, set):Float;
	private var _minimumPageThrowVelocity:Float = 5;
	private function get_minimumPageThrowVelocity():Float { return _minimumPageThrowVelocity; }
	private function set_minimumPageThrowVelocity(value:Float):Float
	{
		return this._minimumPageThrowVelocity = value;
	}
	
	/**
	 * @private
	 */
	public var padding(get, set):Float;
	private function get_padding():Float { return this._paddingTop; }
	private function set_padding(value:Float):Float
	{
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		return this.paddingLeft = value;
	}
	
	/**
	 * @private
	 */
	public var paddingTop(get, set):Float;
	private var _paddingTop:Float = 0;
	private function get_paddingTop():Float { return this._paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._paddingTop == value)
		{
			return value;
		}
		this._paddingTop = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._paddingTop = value;
	}
	
	/**
	 * @private
	 */
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight():Float { return this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._paddingRight == value)
		{
			return value;
		}
		this._paddingRight = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._paddingRight;
	}
	
	/**
	 * @private
	 */
	public var paddingBottom(get, set):Float;
	private var _paddingBottom:Float = 0;
	private function get_paddingBottom():Float { return this._paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._paddingBottom == value)
		{
			return value;
		}
		this._paddingBottom = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._paddingBottom;
	}
	
	/**
	 * @private
	 */
	public var paddingLeft(get, set):Float;
	private var _paddingLeft:Float = 0;
	private function get_paddingLeft():Float { return this._paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._paddingLeft == value)
		{
			return value;
		}
		this._paddingLeft = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._paddingLeft;
	}
	
	/**
	 * @private
	 */
	private var _horizontalScrollBarHideTween:Tween;

	/**
	 * @private
	 */
	private var _verticalScrollBarHideTween:Tween;
	
	/**
	 * @private
	 */
	public var hideScrollBarAnimationDuration(get, set):Float;
	private var _hideScrollBarAnimationDuration:Float = 0.2;
	private function get_hideScrollBarAnimationDuration():Float { return this._hideScrollBarAnimationDuration; }
	private function set_hideScrollBarAnimationDuration(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._hideScrollBarAnimationDuration = value;
	}
	
	/**
	 * @private
	 */
	public var hideScrollBarAnimationEase(get, set):String;
	private var _hideScrollBarAnimationEase:String = Transitions.EASE_OUT;
	private function get_hideScrollBarAnimationEase():String { return this._hideScrollBarAnimationEase; }
	private function set_hideScrollBarAnimationEase(value:String):String
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._hideScrollBarAnimationEase = value;
	}
	
	/**
	 * 
	 */
	public var elasticSnapDuration(get, set):Float;
	private var _elasticSnapDuration:Float = 0.5;
	private function get_elasticSnapDuration():Float { return this._elasticSnapDuration; }
	private function set_elasticSnapDuration(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._elasticSnapDuration = value;
	}
	
	/**
	 * @private
	 * This value is precalculated. See the <code>decelerationRate</code>
	 * setter for the dynamic calculation.
	 */
	private var _logDecelerationRate:Float = -0.0020020026706730793;
	
	/**
	 * @private
	 */
	public var decelerationRate(get, set):Float;
	private var _decelerationRate:Float = DecelerationRate.NORMAL;
	private function get_decelerationRate():Float { return this._decelerationRate; }
	private function set_decelerationRate(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._decelerationRate == value)
		{
			return value;
		}
		this._decelerationRate = value;
		this._logDecelerationRate = Math.log(this._decelerationRate);
		this._fixedThrowDuration = -0.1 / Math.log(Math.pow(this._decelerationRate, 1000 / 60));
		return this._decelerationRate;
	}
	
	/**
	 * @private
	 * This value is precalculated. See the <code>decelerationRate</code>
	 * setter for the dynamic calculation.
	 */
	private var _fixedThrowDuration:Float = 2.996998998998728;
	
	/**
	 * @private
	 */
	public var useFixedThrowDuration(get, set):Bool;
	private var _useFixedThrowDuration:Bool = true;
	private function get_useFixedThrowDuration():Bool { return this._useFixedThrowDuration; }
	private function set_useFixedThrowDuration(value:Bool):Bool
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._useFixedThrowDuration = value;
	}
	
	/**
	 * @private
	 */
	public var pageThrowDuration(get, set):Float;
	private var _pageThrowDuration:Float = 0.5;
	private function get_pageThrowDuration():Float { return this._pageThrowDuration; }
	private function set_pageThrowDuration(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._pageThrowDuration = value;
	}
	
	/**
	 * @private
	 */
	public var mouseWheelScrollDuration(get, set):Float;
	private var _mouseWheelScrollDuration:Float = 0.35;
	private function get_mouseWheelScrollDuration():Float { return this._mouseWheelScrollDuration; }
	private function set_mouseWheelScrollDuration(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._mouseWheelScrollDuration = value;
	}
	
	/**
	 * The direction of scrolling when the user scrolls the mouse wheel
	 * vertically. In some cases, it is common for a container that only
	 * scrolls horizontally to scroll even when the mouse wheel is scrolled
	 * vertically.
	 *
	 * <p>In the following example, the direction of scrolling when using
	 * the mouse wheel is changed:</p>
	 *
	 * <listing version="3.0">
	 * scroller.verticalMouseWheelScrollDirection = Direction.HORIZONTAL;</listing>
	 *
	 * @default feathers.layout.Direction.VERTICAL
	 *
	 * @see feathers.layout.Direction#HORIZONTAL
	 * @see feathers.layout.Direction#VERTICAL
	 */
	public var verticalMouseWheelScrollDirection(get, set):String;
	private var _verticalMouseWheelScrollDirection:String = Direction.VERTICAL;
	private function get_verticalMouseWheelScrollDirection():String { return this._verticalMouseWheelScrollDirection; }
	private function set_verticalMouseWheelScrollDirection(value:String):String
	{
		return this._verticalMouseWheelScrollDirection = value;
	}
	
	/**
	 * @private
	 */
	public var throwEase(get, set):Float;
	private var _throwEase:Float = defaultThrowEase;
	private function get_throwEase():Float { return this._throwEase; }
	private function set_throwEase(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (value == null)
		{
			value = defaultThrowEase;
		}
		return this._throwEase = value;
	}
	
	/**
	 * @private
	 */
	public var snapScrollPositionsToPixels(get, set):Bool;
	private var _snapScrollPositionsToPixels:Bool = true;
	private function get_snapScrollPositionsToPixels():Bool { return this._snapScrollPositionsToPixels; }
	private function set_snapScrollPositionsToPixels(value:Bool):Bool
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._snapScrollPositionsToPixels == value)
		{
			return value;
		}
		this._snapScrollPositionsToPixels = value;
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		return this._snapScrollPositionsToPixels;
	}
	
	/**
	 * @private
	 */
	private var _horizontalScrollBarIsScrolling:Bool = false;

	/**
	 * @private
	 */
	private var _verticalScrollBarIsScrolling:Bool = false;
	
	/**
	 * Determines if the scroller is currently scrolling with user
	 * interaction or with animation.
	 */
	public var isScrolling(get, never):Bool;
	private var _isScrolling:Bool = false;
	private function get_isScrolling():Bool { return this._isScrolling; }
	
	/**
	 * @private
	 */
	private var _isScrollingStopped:Bool = false;

	/**
	 * The pending horizontal scroll position to scroll to after validating.
	 * A value of <code>NaN</code> means that the scroller won't scroll to a
	 * horizontal position after validating.
	 */
	private var pendingHorizontalScrollPosition:Float = Math.NaN;

	/**
	 * The pending vertical scroll position to scroll to after validating.
	 * A value of <code>NaN</code> means that the scroller won't scroll to a
	 * vertical position after validating.
	 */
	private var pendingVerticalScrollPosition:Float = Math.NaN;

	/**
	 * A flag that indicates if the scroller should scroll to a new page
	 * when it validates. If <code>true</code>, it will use the value of
	 * <code>pendingHorizontalPageIndex</code> as the target page index.
	 * 
	 * @see #pendingHorizontalPageIndex
	 */
	private var hasPendingHorizontalPageIndex:Bool = false;

	/**
	 * A flag that indicates if the scroller should scroll to a new page
	 * when it validates. If <code>true</code>, it will use the value of
	 * <code>pendingVerticalPageIndex</code> as the target page index.
	 *
	 * @see #pendingVerticalPageIndex
	 */
	private var hasPendingVerticalPageIndex:Bool = false;

	/**
	 * The pending horizontal page index to scroll to after validating. The
	 * flag <code>hasPendingHorizontalPageIndex</code> must be set to true
	 * if there is a pending page index to scroll to.
	 * 
	 * @see #hasPendingHorizontalPageIndex
	 */
	private var pendingHorizontalPageIndex:Int;

	/**
	 * The pending vertical page index to scroll to after validating. The
	 * flag <code>hasPendingVerticalPageIndex</code> must be set to true
	 * if there is a pending page index to scroll to.
	 *
	 * @see #hasPendingVerticalPageIndex
	 */
	private var pendingVerticalPageIndex:Int;

	/**
	 * The duration of the pending scroll action.
	 */
	private var pendingScrollDuration:Float;
	
	/**
	 * @private
	 */
	private var isScrollBarRevealPending:Bool = false;
	
	/**
	 * @private
	 */
	public var revealScrollBarDuration(get, set):Float;
	private var _revealScrollBarDuration:Float = 1.0;
	private function get_revealScrollBarDuration():Float { return this._revealScrollBarDuration; }
	private function set_revealScrollBarDuration(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		return this._revealScrollBarsDuration = value;
	}
	
	/**
	 * @private
	 */
	private var _isTopPullViewPending:Bool = false;
	
	/**
	 * Indicates if the <code>topPullView</code> has been activated. Set to
	 * <code>false</code> to close the <code>topPullView</code>.
	 * 
	 * <p>Note: Manually setting <code>isTopPullViewActive</code> to
	 * <code>true</code> will not result in <code>Event.UPDATE</code> being
	 * dispatched.</p>
	 * 
	 * @see #topPullView
	 */
	public var isTopPullViewActive(get, set):Bool;
	private var _isTopPullViewActive:Bool = false;
	private function get_isTopPullViewActive():Bool { return this._isTopPullViewActive; }
	private function set_isTopPullViewActive(value:Bool):Bool
	{
		if (this._isTopPullViewActive == value)
		{
			return value;
		}
		if (this._topPullView == null)
		{
			return value;
		}
		this._isTopPullViewActive = value;
		this._isTopPullViewPending = true;
		this.invalidate(INVALIDATION_FLAG_PENDING_PULL_VIEW);
	}
	
	/**
	 * A view that is displayed at the top of the scroller's view port when
	 * dragging down.
	 *
	 * <strong>Events</strong>
	 * 
	 * <p>The scroller will dispatch <code>FeathersEventType.PULLING</code>
	 * on the pull view as it is dragged into view. The event's
	 * <code>data</code> property will be a value between <code>0</code> and
	 * <code>1</code> to indicate how far the pull view has been dragged so
	 * far. A value of <code>1</code> does not necessarily indicate that
	 * the pull view has been activated yet. A value greater than
	 * <code>1</code> is possible if <code>hasElasticEdges</code> is
	 * <code>true</code>.</p>
	 * 
	 * <p>When the pull view is activated by the user, the scroller will
	 * dispatch <code>Event.UPDATE</code>. When the pull view should
	 * be deactivated, set the <code>isTopPullViewActive</code> property
	 * to <code>false</code>.</p>
	 * 
	 * @default null
	 *
	 * @see #isTopPullViewActive
	 * @see #topPullViewDisplayMode
	 * @see #event:update starling.events.Event.UPDATE
	 */
	public var topPullView(get, set):DisplayObject;
	private var _topPullView:DisplayObject;
	private function get_topPullView():DisplayObject { return this._topPullView; }
	private function set_topPullView(value:DisplayObject):DisplayObject
	{
		if (this._topPullView != null)
		{
			this._topPullView.mask.dispose();
			this._topPullView.mask = null;
			if(this._topPullView.parent == this)
			{
				this.removeRawChildInternal(this._topPullView, false);
			}
		}
		this._topPullView = value;
		if (this._topPullView != null)
		{
			this._topPullView.mask = new Quad(1, 1, 0xff00ff);
			this._topPullView.visible = false;
			this.addRawChildInternal(this._topPullView);
		}
		else
		{
			this.isTopPullViewActive = false;
		}
		return this._topPullView;
	}
	
	/**
	 * Indicates whether the top pull view may be dragged with the content,
	 * or if its position is fixed to the edge of the scroller.
	 *
	 * @default feathers.controls.PullViewDisplayMode.DRAG
	 *
	 * @see feathers.controls.PullViewDisplayMode#DRAG
	 * @see feathers.controls.PullViewDisplayMode#FIXED
	 * @see #topPullView
	 */
	public var topPullViewDisplayMode(get, set):String;
	private var _topPullViewDisplayMode:String = PullViewDisplayMode.DRAG;
	private function get_topPullViewDisplayMode():String { return this._topPullViewDisplayMode; }
	private function set_topPullViewDisplayMode(value:String):String
	{
		if (this._topPullViewDisplayMode == value)
		{
			return value;
		}
		this._topPullViewDisplayMode = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._topPullViewDisplayMode;
	}
	
	/**
	 * @private
	 */
	public var topPullViewRatio(get, set):Float;
	private var _topPullViewRatio:Float = 0;
	private function get_topPullViewRatio():Float { return this._topPullViewRatio; }
	private function set_topPullViewRatio(value:Float):Float
	{
		if (this._topPullViewRatio == value)
		{
			return value;
		}
		this._topPullViewRatio = value;
		if (!this._isTopPullViewActive && this._topPullView != null)
		{
			this._topPullView.dispatchEventWith(FeathersEventType.PULLING, false, value);
		}
		return this._topPullViewRatio;
	}
	
	/**
	 * @private
	 */
	private var _isRightPullViewPending:Bool = false;
	
	/**
	 * @private
	 */
	public var isRightPullViewActive(get, set):Bool;
	private var _isRightPullViewActive:Bool = false;
	private function get_isRightPullViewActive():Bool { return this._isRightPullViewActive; }
	private function set_isRightPullViewActive(value:Bool):Bool
	{
		if (this._isRightPullViewActive == value)
		{
			return value;
		}
		if (this._rightPullView == null)
		{
			return value;
		}
		this._isRightPullViewActive = value;
		this._isRightPullViewPending = true;
		this.invalidate(INVALIDATION_FLAG_PENDING_PULL_VIEW);
		return this._isRightPullViewActive;
	}
	
	/**
	 * A view that is displayed to the right of the scroller's view port
	 * when dragging to the left.
	 *
	 * <strong>Events</strong>
	 *
	 * <p>The scroller will dispatch <code>FeathersEventType.PULLING</code>
	 * on the pull view as it is dragged into view. The event's
	 * <code>data</code> property will be a value between <code>0</code> and
	 * <code>1</code> to indicate how far the pull view has been dragged so
	 * far. A value of <code>1</code> does not necessarily indicate that
	 * the pull view has been activated yet. A value greater than
	 * <code>1</code> is possible if <code>hasElasticEdges</code> is
	 * <code>true</code>.</p>
	 *
	 * <p>When the pull view is activated by the user, the scroller will
	 * dispatch <code>Event.UPDATE</code>. When the pull view should
	 * be deactivated, set the <code>isRightPullViewActive</code> property
	 * to <code>false</code>.</p>
	 *
	 * @default null
	 *
	 * @see #isRightPullViewActive
	 * @see #rightPullViewDisplayMode
	 * @see #event:update starling.events.Event.UPDATE
	 */
	public var rightPullView(get, set):DisplayObject;
	private var _rightPullView:DisplayObject;
	private function get_rightPullView():DisplayObject { return this._rightPullView; }
	private function set_rightPullView(value:DisplayObject):DisplayObject
	{
		if (this._rightPullView != null)
		{
			this._rightPullView.mask.dispose();
			this._rightPullView.mask = null;
			if (this._rightPullView.parent == this)
			{
				this.removeRawChildInternal(this._rightPullView, false);
			}
		}
		this._rightPullView = value;
		if (this._rightPullView != null)
		{
			this._rightPullView.mask = new Quad(1, 1, 0xff00ff);
			this._rightPullView.visible = false;
			this.addRawChildInternal(this._rightPullView);
		}
		else
		{
			this.isRightPullViewActive = false;
		}
		return this._rightPullView;
	}
	
	/**
	 * Indicates whether the right pull view may be dragged with the
	 * content, or if its position is fixed to the edge of the scroller.
	 *
	 * @default feathers.controls.PullViewDisplayMode.DRAG
	 *
	 * @see feathers.controls.PullViewDisplayMode#DRAG
	 * @see feathers.controls.PullViewDisplayMode#FIXED
	 * @see #rightPullView
	 */
	public var rightPullViewDisplayMode(get, set):String;
	private var _rightPullViewDisplayMode:String = PullViewDisplayMode.DRAG;
	private function get_rightPullViewDisplayMode():String { return this._rightPullViewDisplayMode; }
	private function set_rightPullViewDisplayMode(value:String):String
	{
		if (this._rightPullViewDisplayMode == value)
		{
			return;
		}
		this._rightPullViewDisplayMode = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._rightPullViewDisplayMode;
	}
	
	/**
	 * @private
	 */
	public var rightPullViewRatio(get, set):Float;
	private var _rightPullViewRatio:Float = 0;
	private function get_rightPullViewRatio():Float { return this._rightPullViewRatio; }
	private function set_rightPullViewRatio(value:Float):Float
	{
		if (this._rightPullViewRatio == value)
		{
			return value;
		}
		this._rightPullViewRatio = value;
		if (!this._isRightPullViewActive && this._rightPullView != null)
		{
			this._rightPullView.dispatchEventWith(FeathersEventType.PULLING, false, value);
		}
		return this._rightPullViewRatio;
	}
	
	/**
	 * @private
	 */
	private var _isBottomPullViewPending:Bool = false;
	
	/**
	 * Indicates if the <code>bottomPullView</code> has been activated. Set
	 * to <code>false</code> to close the <code>bottomPullView</code>.
	 *
	 * <p>Note: Manually setting <code>isBottomPullViewActive</code> to
	 * <code>true</code> will not result in <code>Event.UPDATE</code> being
	 * dispatched.</p>
	 *
	 * @see #bottomPullView
	 */
	public var isBottomPullViewActive(get, set):Bool;
	private var _isBottomPullViewActive:Bool = false;
	private function get_isBottomPullViewActive():Bool { return this._isBottomPullViewActive; }
	private function set_isBottomPullViewActive(value:Bool):Bool
	{
		if (this._isBottomPullViewActive == value)
		{
			return value;
		}
		if (this._bottomPullView == null)
		{
			return value;
		}
		this._isBottomPullViewActive = value;
		this._isBottomPullViewPending = true;
		this.invalidate(INVALIDATION_FLAG_PENDING_PULL_VIEW);
		return this._isBottomPullViewActive;
	}
	
	/**
	 * A view that is displayed at the bottom of the scroller's view port
	 * when dragging up.
	 *
	 * <strong>Events</strong>
	 *
	 * <p>The scroller will dispatch <code>FeathersEventType.PULLING</code>
	 * on the pull view as it is dragged into view. The event's
	 * <code>data</code> property will be a value between <code>0</code> and
	 * <code>1</code> to indicate how far the pull view has been dragged so
	 * far. A value of <code>1</code> does not necessarily indicate that
	 * the pull view has been activated yet. A value greater than
	 * <code>1</code> is possible if <code>hasElasticEdges</code> is
	 * <code>true</code>.</p>
	 *
	 * <p>When the pull view is activated by the user, the scroller will
	 * dispatch <code>Event.UPDATE</code>. When the pull view should
	 * be deactivated, set the <code>isBottomPullViewActive</code> property
	 * to <code>false</code>.</p>
	 *
	 * @default null
	 *
	 * @see #isBottomPullViewActive
	 * @see #bottomPullViewDisplayMode
	 * @see #event:update starling.events.Event.UPDATE
	 */
	public var bottomPullView(get, set):DisplayObject;
	private var _bottomPullView:DisplayObject = null;
	private function get_bottomPullView():DisplayObject { return this._bottomPullView; }
	private function set_bottomPullView(value:DisplayObject):DisplayObject
	{
		if (this._bottomPullView != null)
		{
			this._bottomPullView.mask.dispose();
			this._bottomPullView.mask = null;
			if (this._bottomPullView.parent == this)
			{
				this.removeRawChildInternal(this._bottomPullView, false);
			}
		}
		this._bottomPullView = value;
		if (this._bottomPullView != null)
		{
			this._bottomPullView.mask = new Quad(1, 1, 0xff00ff);
			this._bottomPullView.visible = false;
			this.addRawChildInternal(this._bottomPullView);
		}
		else
		{
			this.isBottomPullViewActive = false;
		}
		return this._bottomPullView;
	}
	
	/**
	 * Indicates whether the bottom pull view may be dragged with the
	 * content, or if its position is fixed to the edge of the scroller.
	 *
	 * @default feathers.controls.PullViewDisplayMode.DRAG
	 *
	 * @see feathers.controls.PullViewDisplayMode#DRAG
	 * @see feathers.controls.PullViewDisplayMode#FIXED
	 * @see #bottomPullView
	 */
	public var bottomPullviewDisplayMode(get, set):String;
	private var _bottomPullViewDisplayMode:String = PullViewDisplayMode.DRAG;
	private function get_bottomPullViewDisplayMode():String { return this._bottomPullViewDisplayMode; }
	private function set_bottomPullViewDisplayMode(value:String):String
	{
		if (this._bottomPullViewDisplayMode == value)
		{
			return value;
		}
		this._bottomPullViewDisplayMode = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._bottomPullViewDisplayMode;
	}
	
	/**
	 * @private
	 */
	public var bottomPullViewRatio(get, set):Float;
	private var _bottomPullViewRatio:Float = 0;
	private function get_bottomPullViewRatio():Float { return this._bottomPullViewRatio; }
	private function set_bottomPullViewRatio(value:Float):Float
	{
		if (this._bottomPullViewRatio == value)
		{
			return value;
		}
		this._bottomPullViewRatio = value;
		if (!this._isBottomPullViewActive && this._bottomPullView != null)
		{
			this._bottomPullView.dispatchEventWith(FeathersEventType.PULLING, false, value);
		}
		return this._bottomPullViewRatio;
	}
	
	/**
	 * @private
	 */
	private var _isLeftPullViewPending:Bool = false;
	
	/**
	 * Indicates if the <code>leftPullView</code> has been activated. Set to
	 * <code>false</code> to close the <code>leftPullView</code>.
	 *
	 * <p>Note: Manually setting <code>isLeftpPullViewActive</code> to
	 * <code>true</code> will not result in <code>Event.UPDATE</code> being
	 * dispatched.</p>
	 *
	 * @see #leftPullView
	 */
	public var isLeftPullViewActive(get, set):Bool;
	private var _isLeftPullViewActive:Bool = false;
	private function get_isLeftPullViewActive():Bool { return this._isLeftPullViewActive; }
	private function set_isLeftPullViewActive(value:Bool):Bool
	{
		if (this._isLeftPullViewActive == value)
		{
			return value;
		}
		if(this._leftPullView == null)
		{
			return value;
		}
		this._isLeftPullViewActive = value;
		this._isLeftPullViewPending = true;
		this.invalidate(INVALIDATION_FLAG_PENDING_PULL_VIEW);
		return this._isLeftPullViewActive;
	}
	
	/**
	 * A view that is displayed to the left of the scroller's view port
	 * when dragging to the right.
	 *
	 * <strong>Events</strong>
	 *
	 * <p>The scroller will dispatch <code>FeathersEventType.PULLING</code>
	 * on the pull view as it is dragged into view. The event's
	 * <code>data</code> property will be a value between <code>0</code> and
	 * <code>1</code> to indicate how far the pull view has been dragged so
	 * far. A value of <code>1</code> does not necessarily indicate that
	 * the pull view has been activated yet. A value greater than
	 * <code>1</code> is possible if <code>hasElasticEdges</code> is
	 * <code>true</code>.</p>
	 *
	 * <p>When the pull view is activated by the user, the scroller will
	 * dispatch <code>Event.UPDATE</code>. When the pull view should
	 * be deactivated, set the <code>isLeftPullViewActive</code> property
	 * to <code>false</code>.</p>
	 *
	 * @default null
	 *
	 * @see #isLeftPullViewActive
	 * @see #leftPullViewDisplayMode
	 * @see #event:update starling.events.Event.UPDATE
	 */
	public var leftPullView(get, set):DisplayObject;
	private var _leftPullView:DisplayObject = null;
	private function get_leftPullView():DisplayObject { return this._leftPullView; }
	private function set_leftPullView(value:DisplayObject):DisplayObject
	{
		if (this._leftPullView != null)
		{
			this._leftPullView.mask.dispose();
			this._leftPullView.mask = null;
			if (this._leftPullView.parent == this)
			{
				this.removeRawChildInternal(this._leftPullView, false);
			}
		}
		this._leftPullView = value;
		if (this._leftPullView != null)
		{
			this._leftPullView.mask = new Quad(1, 1, 0xff00ff);
			this._leftPullView.visible = false;
			this.addRawChildInternal(this._leftPullView);
		}
		else
		{
			this.isLeftPullViewActive = false;
		}
		return this._leftPullView;
	}
	
	/**
	 * @private
	 */
	public var leftPullViewRatio(get, set):Float;
	private var _leftPullViewRatio:Float = 0;
	private function get_leftPullViewRatio():Float { return this._leftPullViewRatio; }
	private function set_leftPullViewRatio(value:Float):Float
	{
		if (this._leftPullViewRatio == value)
		{
			return value;
		}
		this._leftPullViewRatio = value;
		if (!this._isLeftPullViewActive && this._leftPullView != null)
		{
			this._leftPullView.dispatchEventWith(FeathersEventType.PULLING, false, value);
		}
		return this._leftPullViewRatio;
	}
	
	/**
	 * Indicates whether the left pull view may be dragged with the content,
	 * or if its position is fixed to the edge of the scroller.
	 *
	 * @default feathers.controls.PullViewDisplayMode.DRAG
	 *
	 * @see feathers.controls.PullViewDisplayMode#DRAG
	 * @see feathers.controls.PullViewDisplayMode#FIXED
	 * @see #leftPullView
	 */
	public var leftPullViewDisplayMode(get, set):String;
	private var _leftPullViewDisplayMode:String = PullViewDisplayMode.DRAG;
	private function get_leftPullViewDisplayMode():String { return this._leftPullViewDisplayMode; }
	private function set_leftPullViewDisplayMode(value:String):String
	{
		if (this._leftPullViewDisplayMode == value)
		{
			return value;
		}
		this._leftPullViewDisplayMode = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._leftPullViewDisplayMode;
	}
	
	/**
	 * @private
	 */
	private var _horizontalAutoScrollTweenEndRatio:Float = 1;

	/**
	 * @private
	 */
	private var _verticalAutoScrollTweenEndRatio:Float = 1;
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, nativeStage_mouseWheelHandler);
		starling.nativeStage.removeEventListener("orientationChange", nativeStage_orientationChangeHandler);
		
		//we don't dispose it if the scroller is the parent because it'll
		//already get disposed in super.dispose()
		if (this._backgroundSkin != null &&
			this._backgroundSkin.parent != this)
		{
			this._backgroundSkin.dispose();
		}
		if (this._backgroundDisabledSkin != null &&
			this._backgroundDisabledSkin.parent != this)
		{
			this._backgroundDisabledSkin.dispose();
		}
		super.dispose();
	}
	
	/**
	 * If the user is scrolling with touch or if the scrolling is animated,
	 * calling stopScrolling() will cause the scroller to ignore the drag
	 * and stop animations. This function may only be called during scrolling,
	 * so if you need to stop scrolling on a <code>TouchEvent</code> with
	 * <code>TouchPhase.BEGAN</code>, you may need to wait for the scroller
	 * to start scrolling before you can call this function.
	 *
	 * <p>In the following example, we listen for <code>FeathersEventType.SCROLL_START</code>
	 * to stop scrolling:</p>
	 *
	 * <listing version="3.0">
	 * scroller.addEventListener( FeathersEventType.SCROLL_START, function( event:Event ):void
	 * {
	 *     scroller.stopScrolling();
	 * });</listing>
	 */
	public function stopScrolling():Void
	{
		if (this._horizontalAutoScrollTween != null)
		{
			Starling.juggler.remove(this._horizontalAutoScrollTween);
			this._horizontalAutoScrollTween = null;
		}
		if (this._verticalAutoScrollTween != null)
		{
			Starling.juggler.remove(this._verticalAutoScrollTween);
			this._verticalAutoScrollTween = null;
		}
		this._isScrollingStopped = true;
		this._velocityX = 0;
		this._velocityY = 0;
		this._previousVelocityX.length = 0;
		this._previousVelocityY.length = 0;
		this.hideHorizontalScrollBar();
		this.hideVerticalScrollBar();
	}
	
	/**
	 * After the next validation, animates the scroll positions to a
	 * specific location. May scroll in only one direction by passing in a
	 * value of <code>NaN</code> for either scroll position. If the
	 * <code>animationDuration</code> argument is <code>NaN</code> (the
	 * default value), the duration of a standard throw is used. The
	 * duration is in seconds.
	 *
	 * <p>Because this function is primarily designed for animation, using a
	 * duration of <code>0</code> may require a frame or two before the
	 * scroll position updates.</p>
	 *
	 * <p>In the following example, we scroll to the maximum vertical scroll
	 * position:</p>
	 *
	 * <listing version="3.0">
	 * scroller.scrollToPosition( scroller.horizontalScrollPosition, scroller.maxVerticalScrollPosition );</listing>
	 *
	 * @see #horizontalScrollPosition
	 * @see #verticalScrollPosition
	 * @see #throwEase
	 */
	public function scrollToPosition(horizontalScrollPosition:Float, verticalScrollPosition:Float, animationDuration:Float = Math.NaN):Void
	{
		if (animationDuration != animationDuration) //isNaN
		{
			if (this._useFixedThrowDuration)
			{
				animationDuration = this._fixedThrowDuration;
			}
			else
			{
				var point:Point = Pool.getPoint(horizontalScrollPosition - this._horizontalScrollPosition, verticalScrollPosition - this._verticalScrollPosition);
				animationDuration = this.calculateDynamicThrowDuration(point.length * this._logDecelerationRate + MINIMUM_VELOCITY);
				Pool.putPoint(point);
			}
		}
		//cancel any pending scroll to a different page. we can have only
		//one type of pending scroll at a time.
		this.hasPendingHorizontalPageIndex = false;
		this.hasPendingVerticalPageIndex = false;
		if (this.pendingHorizontalScrollPosition == horizontalScrollPosition &&
			this.pendingVerticalScrollPosition == verticalScrollPosition &&
			this.pendingScrollDuration == animationDuration)
		{
			return;
		}
		this.pendingHorizontalScrollPosition = horizontalScrollPosition;
		this.pendingVerticalScrollPosition = verticalScrollPosition;
		this.pendingScrollDuration = animationDuration;
		this.invalidate(INVALIDATION_FLAG_PENDING_SCROLL);
	}
	
	/**
	 * After the next validation, animates the scroll position to a specific
	 * page index. To scroll in only one direction, pass in the value of the
	 * <code>horizontalPageIndex</code> or the
	 * <code>verticalPageIndex</code> property to the appropriate parameter.
	 * If the <code>animationDuration</code> argument is <code>NaN</code>
	 * (the default value) the value of the <code>pageThrowDuration</code>
	 * property is used for the duration. The duration is in seconds.
	 *
	 * <p>You can only scroll to a page if the <code>snapToPages</code>
	 * property is <code>true</code>.</p>
	 *
	 * <p>In the following example, we scroll to the last horizontal page:</p>
	 *
	 * <listing version="3.0">
	 * scroller.scrollToPageIndex( scroller.horizontalPageCount - 1, scroller.verticalPageIndex );</listing>
	 *
	 * @see #snapToPages
	 * @see #pageThrowDuration
	 * @see #throwEase
	 * @see #horizontalPageIndex
	 * @see #verticalPageIndex
	 */
	public function scrollToPageIndex(horizontalPageIndex:Int, verticalPageIndex:Int, animationDuration:Float = Math.NaN):Void
	{
		if (animationDuration != animationDuration) //isNaN
		{
			animationDuration = this._pageThrowDuration;
		}
		//cancel any pending scroll to a specific scroll position. we can
		//have only one type of pending scroll at a time.
		this.pendingHorizontalScrollPosition = Math.NaN;
		this.pendingVerticalScrollPosition = Math.NaN;
		this.hasPendingHorizontalPageIndex = this._horizontalPageIndex != horizontalPageIndex;
		this.hasPendingVerticalPageIndex = this._verticalPageIndex != verticalPageIndex;
		if (!this.hasPendingHorizontalPageIndex && !this.hasPendingVerticalPageIndex)
		{
			return;
		}
		this.pendingHorizontalPageIndex = horizontalPageIndex;
		this.pendingVerticalPageIndex = verticalPageIndex;
		this.pendingScrollDuration = animationDuration;
		this.invalidate(INVALIDATION_FLAG_PENDING_SCROLL);
	}
	
	/**
	 * If the scroll bars are floating, briefly show them as a hint to the
	 * user. Useful when first navigating to a screen to give the user
	 * context about both the ability to scroll and the current scroll
	 * position.
	 *
	 * @see #revealScrollBarsDuration
	 */
	public function revealScrollBars():Void
	{
		this.isScrollBarRevealPending = true;
		this.invalidate(INVALIDATION_FLAG_PENDING_REVEAL_SCROLL_BARS);
	}
	
	/**
	 * @private
	 */
	override public function hitTest(localPoint:Point):DisplayObject
	{
		//save localX and localY because localPoint could change after the
		//call to super.hitTest().
		var localX:Float = localPoint.x;
		var localY:Float = localPoint.y;
		//first check the children for touches
		var result:DisplayObject = super.hitTest(localPoint);
		if ((this._isDraggingHorizontally || this._isDraggingVertically) &&
			Std.isOfType(this.viewPort, DisplayObjectContainer) &&
			cast(this.viewPort, DisplayObjectContainer).contains(result))
		{
			result = cast this.viewPort;
		}
		if (result == null)
		{
			//we want to register touches in our hitArea as a last resort
			if (!this.visible || !this.touchable)
			{
				return null;
			}
			return this._hitArea.contains(localX, localY) ? this : null;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var sizeInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_SIZE);
		//we don't use this flag in this class, but subclasses will use it,
		//and it's better to handle it here instead of having them
		//invalidate unrelated flags
		var dataInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_DATA);
		//similarly, this flag may be set in subclasses
		var layoutInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_LAYOUT);
		var scrollInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_SCROLL);
		var clippingInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_CLIPPING);
		var stylesInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_STATE);
		var scrollBarInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_SCROLL_BAR_RENDERER);
		var pendingScrollInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_PENDING_SCROLL);
		var pendingRevealScrollBarsInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_PENDING_REVEAL_SCROLL_BARS);
		var pendingPullViewInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_PENDING_PULL_VIEW);
		
		if (scrollBarInvalid)
		{
			this.createScrollBars();
		}
		
		if (sizeInvalid || stylesInvalid || stateInvalid)
		{
			this.refreshBackgroundSkin();
		}
		
		if (scrollBarInvalid || stylesInvalid)
		{
			this.refreshScrollBarStyles();
			this.refreshInteractionModeEvents();
		}
		
		if (scrollBarInvalid || stateInvalid)
		{
			this.refreshEnabled();
		}
		
		if (this.horizontalScrollBar)
		{
			this.horizontalScrollBar.validate();
		}
		if (this.verticalScrollBar)
		{
			this.verticalScrollBar.validate();
		}
		
		var oldMaxHorizontalScrollPosition:Float = this._maxHorizontalScrollPosition;
		var oldMaxVerticalScrollPosition:Float = this._maxVerticalScrollPosition;
		var needsMeasurement:Bool = (scrollInvalid && this._viewPort.requiresMeasurementOnScroll) ||
			dataInvalid || sizeInvalid || stylesInvalid || scrollBarInvalid || stateInvalid || layoutInvalid;
		this.refreshViewPort(needsMeasurement);
		if (oldMaxHorizontalScrollPosition != this._maxHorizontalScrollPosition)
		{
			this.refreshHorizontalAutoScrollTweenEndRatio();
			scrollInvalid = true;
		}
		if (oldMaxVerticalScrollPosition != this._maxVerticalScrollPosition)
		{
			this.refreshVerticalAutoScrollTweenEndRatio();
			scrollInvalid = true;
		}
		if (scrollInvalid)
		{
			this.dispatchEventWith(Event.SCROLL);
		}
		
		this.showOrHideChildren();
		this.layoutChildren();
		
		if (scrollInvalid || sizeInvalid || stylesInvalid || scrollBarInvalid)
		{
			this.refreshScrollBarValues();
		}
		
		if (needsMeasurement || scrollInvalid || clippingInvalid)
		{
			this.refreshMask();
		}
		this.refreshFocusIndicator();
		
		if (pendingScrollInvalid)
		{
			this.handlePendingScroll();
		}
		
		if (pendingRevealScrollBarsInvalid)
		{
			this.handlePendingRevealScrollBars();
		}
		
		if (pendingPullViewInvalid)
		{
			this.handlePendingPullView();
		}
	}
	
	/**
	 * @private
	 */
	private function refreshViewPort(measure:Bool):Void
	{
		if (this._snapScrollPositionsToPixels)
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			var pixelSize:Float = 1 / starling.contentScaleFactor;
			this._viewPort.horizontalScrollPosition = Math.fround(this._horizontalScrollPosition / pixelSize) * pixelSize;
			this._viewPort.verticalScrollPosition = Math.fround(this._verticalScrollPosition / pixelSize) * pixelSize;
		}
		else
		{
			this._viewPort.horizontalScrollPosition = this._horizontalScrollPosition;
			this._viewPort.verticalScrollPosition = this._verticalScrollPosition;
		}
		if (!measure)
		{
			this._viewPort.validate();
			this.refreshScrollValues();
			return;
		}
		var loopCount:Int = 0;
		do
		{
			this._hasViewPortBoundsChanged = false;
			//if we don't need to do any measurement, we can skip
			//this stuff and improve performance
			if (this._measureViewPort)
			{
				this.calculateViewPortOffsets(true, false);
				this.refreshViewPortBoundsForMeasurement();
			}
			this.calculateViewPortOffsets(false, false);
			
			this.autoSizeIfNeeded();
			
			//just in case autoSizeIfNeeded() is overridden, we need to call
			//this again and use actualWidth/Height instead of
			//explicitWidth/Height.
			this.calculateViewPortOffsets(false, true);
			
			this.refreshViewPortBoundsForLayout();
			this.refreshScrollValues();
			loopCount++;
			if (loopCount >= 10)
			{
				//if it still fails after ten tries, we've probably entered
				//an infinite loop. it could be things like rounding errors,
				//layout issues, or custom item renderers that don't measure
				//correctly
				throw new Error(Type.getClassName(Type.getClass(this)) + " stuck in an infinite loop during measurement and validation. This may be an issue with the layout or children, such as custom item renderers.");
			}
		}
		while (this._hasViewPortBoundsChanged);
		this._lastViewPortWidth = this._viewPort.width;
		this._lastViewPortHeight = this._viewPort.height;
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
		
		resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		var measureBackground:IMeasureDisplayObject = cast this.currentBackgroundSkin;
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			cast(this.currentBackgroundSkin, IValidating).validate();
		}

		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsWidth)
		{
			if (this._measureViewPort)
			{
				newWidth = this._viewPort.visibleWidth;
			}
			else
			{
				newWidth = 0;
			}
			newWidth += this._rightViewPortOffset + this._leftViewPortOffset;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.width > newWidth)
			{
				newWidth = this.currentBackgroundSkin.width;
			}
		}
		if (needsHeight)
		{
			if (this._measureViewPort)
			{
				newHeight = this._viewPort.visibleHeight;
			}
			else
			{
				newHeight = 0;
			}
			newHeight += this._bottomViewPortOffset + this._topViewPortOffset;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.height > newHeight)
			{
				newHeight = this.currentBackgroundSkin.height;
			}
		}
		if (needsMinWidth)
		{
			if (this._measureViewPort)
			{
				newMinWidth = this._viewPort.minVisibleWidth;
			}
			else
			{
				newMinWidth = 0;
			}
			newMinWidth += this._rightViewPortOffset + this._leftViewPortOffset;
			if (this.currentBackgroundSkin != null)
			{
				if (measureBackground != null)
				{
					if (measureBackground.minWidth > newMinWidth)
					{
						newMinWidth = measureBackground.minWidth;
					}
				}
				else if (this._explicitBackgroundMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitBackgroundMinWidth;
				}
			}
		}
		if (needsMinHeight)
		{
			if (this._measureViewPort)
			{
				newMinHeight = this._viewPort.minVisibleHeight;
			}
			else
			{
				newMinHeight = 0;
			}
			newMinHeight += this._bottomViewPortOffset + this._topViewPortOffset;
			if (this.currentBackgroundSkin != null)
			{
				if (measureBackground != null)
				{
					if (measureBackground.minHeight > newMinHeight)
					{
						newMinHeight = measureBackground.minHeight;
					}
				}
				else if (this._explicitBackgroundMinHeight > newMinHeight)
				{
					newMinHeight = this._explicitBackgroundMinHeight;
				}
			}
		}
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Creates and adds the <code>horizontalScrollBar</code> and
	 * <code>verticalScrollBar</code> sub-components and removes the old
	 * instances, if they exist.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #horizontalScrollBar
	 * @see #verticalScrollBar
	 * @see #horizontalScrollBarFactory
	 * @see #verticalScrollBarFactory
	 */
	private function createScrollBars():Void
	{
		if (this.horizontalScrollBar != null)
		{
			this.horizontalScrollBar.removeEventListener(FeathersEventType.BEGIN_INTERACTION, horizontalScrollBar_beginInteractionHandler);
			this.horizontalScrollBar.removeEventListener(FeathersEventType.END_INTERACTION, horizontalScrollBar_endInteractionHandler);
			this.horizontalScrollBar.removeEventListener(Event.CHANGE, horizontalScrollBar_changeHandler);
			this.removeRawChildInternal(cast this.horizontalScrollBar, true);
			this.horizontalScrollBar = null;
		}
		if (this.verticalScrollBar != null)
		{
			this.verticalScrollBar.removeEventListener(FeathersEventType.BEGIN_INTERACTION, verticalScrollBar_beginInteractionHandler);
			this.verticalScrollBar.removeEventListener(FeathersEventType.END_INTERACTION, verticalScrollBar_endInteractionHandler);
			this.verticalScrollBar.removeEventListener(Event.CHANGE, verticalScrollBar_changeHandler);
			this.removeRawChildInternal(cast this.verticalScrollBar, true);
			this.verticalScrollBar = null;
		}

		if (this._scrollBarDisplayMode != ScrollBarDisplayMode.NONE &&
			this._horizontalScrollPolicy != ScrollPolicy.OFF && this._horizontalScrollBarFactory != null)
		{
			this.horizontalScrollBar = this._horizontalScrollBarFactory();
			if (Std.isOfType(this.horizontalScrollBar, IDirectionalScrollBar))
			{
				cast(this.horizontalScrollBar, IDirectionalScrollBar).direction = Direction.HORIZONTAL;
			}
			var horizontalScrollBarStyleName:String = this._customHorizontalScrollBarStyleName != null ? this._customHorizontalScrollBarStyleName : this.horizontalScrollBarStyleName;
			this.horizontalScrollBar.styleNameList.add(horizontalScrollBarStyleName);
			this.horizontalScrollBar.addEventListener(Event.CHANGE, horizontalScrollBar_changeHandler);
			this.horizontalScrollBar.addEventListener(FeathersEventType.BEGIN_INTERACTION, horizontalScrollBar_beginInteractionHandler);
			this.horizontalScrollBar.addEventListener(FeathersEventType.END_INTERACTION, horizontalScrollBar_endInteractionHandler);
			this.addRawChildInternal(cast this.horizontalScrollBar);
		}
		if (this._scrollBarDisplayMode != ScrollBarDisplayMode.NONE &&
			this._verticalScrollPolicy != ScrollPolicy.OFF && this._verticalScrollBarFactory != null)
		{
			this.verticalScrollBar = this._verticalScrollBarFactory();
			if (Std.isOfType(this.verticalScrollBar, IDirectionalScrollBar))
			{
				cast(this.verticalScrollBar, IDirectionalScrollBar).direction = Direction.VERTICAL;
			}
			var verticalScrollBarStyleName:String = this._customVerticalScrollBarStyleName != null ? this._customVerticalScrollBarStyleName : this.verticalScrollBarStyleName;
			this.verticalScrollBar.styleNameList.add(verticalScrollBarStyleName);
			this.verticalScrollBar.addEventListener(Event.CHANGE, verticalScrollBar_changeHandler);
			this.verticalScrollBar.addEventListener(FeathersEventType.BEGIN_INTERACTION, verticalScrollBar_beginInteractionHandler);
			this.verticalScrollBar.addEventListener(FeathersEventType.END_INTERACTION, verticalScrollBar_endInteractionHandler);
			this.addRawChildInternal(cast this.verticalScrollBar);
		}
	}
	
	/**
	 * Choose the appropriate background skin based on the control's current
	 * state.
	 */
	private function refreshBackgroundSkin():Void
	{
		var newCurrentBackgroundSkin:DisplayObject = this.getCurrentBackgroundSkin();
		if (this.currentBackgroundSkin != newCurrentBackgroundSkin)
		{
			this.removeCurrentBackgroundSkin(this.currentBackgroundSkin);
			this.currentBackgroundSkin = newCurrentBackgroundSkin;
			if (this.currentBackgroundSkin != null)
			{
				if (Std.isOfType(this.currentBackgroundSkin, IFeathersControl))
				{
					cast(this.currentBackgroundSkin, IFeathersControl).initializeNow();
				}
				if (Std.isOfType(this.currentBackgroundSkin, IMeasureDisplayObject))
				{
					var measureSkin:IMeasureDisplayObject = cast this.currentBackgroundSkin;
					this._explicitBackgroundWidth = measureSkin.explicitWidth;
					this._explicitBackgroundHeight = measureSkin.explicitHeight;
					this._explicitBackgroundMinWidth = measureSkin.explicitMinWidth;
					this._explicitBackgroundMinHeight = measureSkin.explicitMinHeight;
					this._explicitBackgroundMaxWidth = measureSkin.explicitMaxWidth;
					this._explicitBackgroundMaxHeight = measureSkin.explicitMaxHeight;
				}
				else
				{
					this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
					this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
					this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
					this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
				}
				this.addRawChildAtInternal(this.currentBackgroundSkin, 0);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function getCurrentBackgroundSkin():DisplayObject
	{
		var newCurrentBackgroundSkin:DisplayObject = this._backgroundSkin;
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			newCurrentBackgroundSkin = this._backgroundDisabledSkin;
		}
		return newCurrentBackgroundSkin;
	}
	
	/**
	 * @private
	 */
	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void
	{
		if (skin == null)
		{
			return;
		}
		if (skin.parent == this)
		{
			//we need to restore these values so that they won't be lost the
			//next time that this skin is used for measurement
			skin.width = this._explicitBackgroundWidth;
			skin.height = this._explicitBackgroundHeight;
			if (Std.isOfType(skin, IMeasureDisplayObject))
			{
				var measureSkin:IMeasureDisplayObject = cast skin;
				measureSkin.minWidth = this._explicitBackgroundMinWidth;
				measureSkin.minHeight = this._explicitBackgroundMinHeight;
				measureSkin.maxWidth = this._explicitBackgroundMaxWidth;
				measureSkin.maxHeight = this._explicitBackgroundMaxHeight;
			}
			this.removeRawChildInternal(skin);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshScrollBarStyles():Void
	{
		if (this.horizontalScrollBar != null)
		{
			for (propertyName in this._horizontalScrollBarProperties)
			{
				var propertyValue:Dynamic = this._horizontalScrollBarProperties[propertyName];
				this.horizontalScrollBar[propertyName] = propertyValue;
			}
			if (this._horizontalScrollBarHideTween != null)
			{
				Starling.juggler.remove(this._horizontalScrollBarHideTween);
				this._horizontalScrollBarHideTween = null;
			}
			this.horizontalScrollBar.alpha = this._scrollBarDisplayMode == ScrollBarDisplayMode.FLOAT ? 0 : 1;
		}
		if (this.verticalScrollBar != null)
		{
			for (propertyName in this._verticalScrollBarProperties)
			{
				propertyValue = this._verticalScrollBarProperties[propertyName];
				this.verticalScrollBar[propertyName] = propertyValue;
			}
			if (this._verticalScrollBarHideTween != null)
			{
				Starling.juggler.remove(this._verticalScrollBarHideTween);
				this._verticalScrollBarHideTween = null;
			}
			this.verticalScrollBar.alpha = this._scrollBarDisplayMode == ScrollBarDisplayMode.FLOAT ? 0 : 1;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		if (this._viewPort)
		{
			this._viewPort.isEnabled = this._isEnabled;
		}
		if (this.horizontalScrollBar != null)
		{
			this.horizontalScrollBar.isEnabled = this._isEnabled;
		}
		if (this.verticalScrollBar != null)
		{
			this.verticalScrollBar.isEnabled = this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	override function refreshFocusIndicator():Void
	{
		if (this._focusIndicatorSkin != null)
		{
			if (this._hasFocus && this._showFocus)
			{
				if (this._focusIndicatorSkin.parent != this)
				{
					this.addRawChildInternal(this._focusIndicatorSkin);
				}
				else
				{
					this.setRawChildIndexInternal(this._focusIndicatorSkin, this.numRawChildrenInternal - 1);
				}
			}
			else if (this._focusIndicatorSkin.parent == this)
			{
				this.removeRawChildInternal(this._focusIndicatorSkin, false);
			}
			this._focusIndicatorSkin.x = this._focusPaddingLeft;
			this._focusIndicatorSkin.y = this._focusPaddingTop;
			this._focusIndicatorSkin.width = this.actualWidth - this._focusPaddingLeft - this._focusPaddingRight;
			this._focusIndicatorSkin.height = this.actualHeight - this._focusPaddingTop - this._focusPaddingBottom;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshViewPortBoundsForMeasurement():Void
	{
		var horizontalWidthOffset:Float = this._leftViewPortOffset + this._rightViewPortOffset;
		var verticalHeightOffset:Float = this._topViewPortOffset + this._bottomViewPortOffset;
		
		resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		var measureBackground:IMeasureDisplayObject = cast this.currentBackgroundSkin;
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			cast(this.currentBackgroundSkin, IValidating).validate();
		}
		
		//we account for the explicit minimum dimensions of the view port
		//and the minimum dimensions of the background skin because it helps
		//the final measurements stabilize faster.
		var viewPortMinWidth:Float = this._explicitMinWidth;
		if (viewPortMinWidth != viewPortMinWidth || //isNaN
			this._explicitViewPortMinWidth > viewPortMinWidth)
		{
			viewPortMinWidth = this._explicitViewPortMinWidth;
		}
		if (viewPortMinWidth != viewPortMinWidth || //isNaN
			this._explicitWidth > viewPortMinWidth)
		{
			viewPortMinWidth = this._explicitWidth;
		}
		if (this.currentBackgroundSkin != null)
		{
			var backgroundMinWidth:Float = this.currentBackgroundSkin.width;
			if (measureBackground != null)
			{
				backgroundMinWidth = measureBackground.minWidth;
			}
			if (viewPortMinWidth != viewPortMinWidth || //isNaN
				backgroundMinWidth > viewPortMinWidth)
			{
				viewPortMinWidth = backgroundMinWidth;
			}
		}
		viewPortMinWidth -= horizontalWidthOffset;
		
		var viewPortMinHeight:Float = this._explicitMinHeight;
		if (viewPortMinHeight != viewPortMinHeight || //isNaN
			this._explicitViewPortMinHeight > viewPortMinHeight)
		{
			viewPortMinHeight = this._explicitViewPortMinHeight;
		}
		if (viewPortMinHeight != viewPortMinHeight || //isNaN
			this._explicitHeight > viewPortMinHeight)
		{
			viewPortMinHeight = this._explicitHeight;
		}
		if (this.currentBackgroundSkin != null)
		{
			var backgroundMinHeight:Float = this.currentBackgroundSkin.height;
			if (measureBackground != null)
			{
				backgroundMinHeight = measureBackground.minHeight;
			}
			if (viewPortMinHeight != viewPortMinHeight || //isNaN
				backgroundMinHeight > viewPortMinHeight)
			{
				viewPortMinHeight = backgroundMinHeight;
			}
		}
		viewPortMinHeight -= verticalHeightOffset;

		var oldIgnoreViewPortResizing:Bool = this.ignoreViewPortResizing;
		//setting some of the properties below may result in a resize
		//event, which forces another layout pass for the view port and
		//hurts performance (because it needs to break out of an
		//infinite loop)
		this.ignoreViewPortResizing = true;

		//if scroll bars are fixed, we're going to include the offsets even
		//if they may not be needed in the final pass. if not fixed, the
		//view port fills the entire bounds.
		this._viewPort.visibleWidth = this._explicitWidth - horizontalWidthOffset;
		this._viewPort.minVisibleWidth = this._explicitMinWidth - horizontalWidthOffset;
		this._viewPort.maxVisibleWidth = this._explicitMaxWidth - horizontalWidthOffset;
		this._viewPort.minWidth = viewPortMinWidth;

		this._viewPort.visibleHeight = this._explicitHeight - verticalHeightOffset;
		this._viewPort.minVisibleHeight = this._explicitMinHeight - verticalHeightOffset;
		this._viewPort.maxVisibleHeight = this._explicitMaxHeight - verticalHeightOffset;
		this._viewPort.minHeight = viewPortMinHeight;
		this._viewPort.validate();
		//we don't want to listen for a resize event from the view port
		//while it is validating this time. during the next validation is
		//where it matters if the view port resizes. 
		this.ignoreViewPortResizing = oldIgnoreViewPortResizing;
	}
	
	/**
	 * @private
	 */
	private function refreshViewPortBoundsForLayout():Void
	{
		var horizontalWidthOffset:Float = this._leftViewPortOffset + this._rightViewPortOffset;
		var verticalHeightOffset:Float = this._topViewPortOffset + this._bottomViewPortOffset;
		
		var oldIgnoreViewPortResizing:Bool = this.ignoreViewPortResizing;
		//setting some of the properties below may result in a resize
		//event, which forces another layout pass for the view port and
		//hurts performance (because it needs to break out of an
		//infinite loop)
		this.ignoreViewPortResizing = true;
		
		var visibleWidth:Float = this.actualWidth - horizontalWidthOffset;
		//we'll only set the view port's visibleWidth and visibleHeight if
		//our dimensions are explicit. this allows the view port to know
		//whether it needs to re-measure on scroll.
		if (this._viewPort.visibleWidth != visibleWidth)
		{
			this._viewPort.visibleWidth = visibleWidth;
		}
		this._viewPort.minVisibleWidth = this.actualMinWidth - horizontalWidthOffset;
		this._viewPort.maxVisibleWidth = this._explicitMaxWidth - horizontalWidthOffset;
		this._viewPort.minWidth = visibleWidth;
		
		var visibleHeight:Float = this.actualHeight - verticalHeightOffset;
		if (this._viewPort.visibleHeight != visibleHeight)
		{
			this._viewPort.visibleHeight = visibleHeight;
		}
		this._viewPort.minVisibleHeight = this.actualMinHeight - verticalHeightOffset;
		this._viewPort.maxVisibleHeight = this._explicitMaxHeight - verticalHeightOffset;
		this._viewPort.minHeight = visibleHeight;
		
		//this time, we care whether a resize event is dispatched while the
		//view port is validating because it means we'll need to try another
		//measurement pass. we restore the flag before calling validate().
		this.ignoreViewPortResizing = oldIgnoreViewPortResizing;
		
		this._viewPort.validate();
	}
	
	/**
	 * @private
	 */
	private function refreshScrollValues():Void
	{
		this.refreshScrollSteps();
		
		var oldMaxHSP:Float = this._maxHorizontalScrollPosition;
		var oldMaxVSP:Float = this._maxVerticalScrollPosition;
		this.refreshMinAndMaxScrollPositions();
		var maximumPositionsChanged:Bool = this._maxHorizontalScrollPosition != oldMaxHSP || this._maxVerticalScrollPosition != oldMaxVSP;
		if (maximumPositionsChanged && this._touchPointID < 0)
		{
			this.clampScrollPositions();
		}
		
		this.refreshPageCount();
		this.refreshPageIndices();
	}
	
	/**
	 * @private
	 */
	private function clampScrollPositions():Void
	{
		if (this._horizontalAutoScrollTween == null)
		{
			if (this._snapToPages)
			{
				this._horizontalScrollPosition = MathUtils.roundToNearest(this._horizontalScrollPosition, this.actualPageWidth);
			}
			var targetHorizontalScrollPosition:Float = this._horizontalScrollPosition;
			if (targetHorizontalScrollPosition < this._minHorizontalScrollPosition)
			{
				targetHorizontalScrollPosition = this._minHorizontalScrollPosition;
			}
			else if (targetHorizontalScrollPosition > this._maxHorizontalScrollPosition)
			{
				targetHorizontalScrollPosition = this._maxHorizontalScrollPosition;
			}
			this.horizontalScrollPosition = targetHorizontalScrollPosition;
		}
		if (this._verticalAutoScrollTween == null)
		{
			if (this._snapToPages)
			{
				this._verticalScrollPosition = roundToNearest(this._verticalScrollPosition, this.actualPageHeight);
			}
			var targetVerticalScrollPosition:Float = this._verticalScrollPosition;
			if (targetVerticalScrollPosition < this._minVerticalScrollPosition)
			{
				targetVerticalScrollPosition = this._minVerticalScrollPosition;
			}
			else if (targetVerticalScrollPosition > this._maxVerticalScrollPosition)
			{
				targetVerticalScrollPosition = this._maxVerticalScrollPosition;
			}
			this.verticalScrollPosition = targetVerticalScrollPosition;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshScrollSteps():Void
	{
		if (this.explicitHorizontalScrollStep != this.explicitHorizontalScrollStep) //isNaN
		{
			if (this._viewPort != null)
			{
				this.actualHorizontalScrollStep = this._viewPort.horizontalScrollStep;
			}
			else
			{
				this.actualHorizontalScrollStep = 1;
			}
		}
		else
		{
			this.actualHorizontalScrollStep = this.explicitHorizontalScrollStep;
		}
		if (this.explicitVerticalScrollStep != this.explicitVerticalScrollStep) //isNaN
		{
			if (this._viewPort != null)
			{
				this.actualVerticalScrollStep = this._viewPort.verticalScrollStep;
			}
			else
			{
				this.actualVerticalScrollStep = 1;
			}
		}
		else
		{
			this.actualVerticalScrollStep = this.explicitVerticalScrollStep;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshMinAndMaxScrollPositions():Void
	{
		var visibleViewPortWidth:Float = this.actualWidth - (this._leftViewPortOffset + this._rightViewPortOffset);
		var visibleViewPortHeight:Float = this.actualHeight - (this._topViewPortOffset + this._bottomViewPortOffset);
		if (this.explicitPageWidth != this.explicitPageWidth) //isNaN
		{
			this.actualPageWidth = visibleViewPortWidth;
		}
		if (this.explicitPageHeight != this.explicitPageHeight) //isNaN
		{
			this.actualPageHeight = visibleViewPortHeight;
		}
		if (this._viewPort != null)
		{
			this._minHorizontalScrollPosition = this._viewPort.contentX;
			if (this._viewPort.width == Math.POSITIVE_INFINITY)
			{
				//we don't want to risk the possibility of negative infinity
				//being added to positive infinity. the result is NaN.
				this._maxHorizontalScrollPosition = Math.POSITIVE_INFINITY;
			}
			else
			{
				this._maxHorizontalScrollPosition = this._minHorizontalScrollPosition + this._viewPort.width - visibleViewPortWidth;
			}
			if (this._maxHorizontalScrollPosition < this._minHorizontalScrollPosition)
			{
				this._maxHorizontalScrollPosition = this._minHorizontalScrollPosition;
			}
			this._minVerticalScrollPosition = this._viewPort.contentY;
			if (this._viewPort.height == Math.POSITIVE_INFINITY)
			{
				//we don't want to risk the possibility of negative infinity
				//being added to positive infinity. the result is NaN.
				this._maxVerticalScrollPosition = Math.POSITIVE_INFINITY;
			}
			else
			{
				this._maxVerticalScrollPosition = this._minVerticalScrollPosition + this._viewPort.height - visibleViewPortHeight;
			}
			if (this._maxVerticalScrollPosition < this._minVerticalScrollPosition)
			{
				this._maxVerticalScrollPosition =  this._minVerticalScrollPosition;
			}
		}
		else
		{
			this._minHorizontalScrollPosition = 0;
			this._minVerticalScrollPosition = 0;
			this._maxHorizontalScrollPosition = 0;
			this._maxVerticalScrollPosition = 0;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshPageCount():Void
	{
		if (this._snapToPages)
		{
			var horizontalScrollRange:Float = this._maxHorizontalScrollPosition - this._minHorizontalScrollPosition;
			if (horizontalScrollRange == Math.POSITIVE_INFINITY)
			{
				//trying to put positive infinity into an int results in 0
				//so we need a special case to provide a large int value.
				if (this._minHorizontalScrollPosition == Math.NEGATIVE_INFINITY)
				{
					this._minHorizontalPageIndex = MathUtils.INT_MIN;
				}
				else
				{
					this._minHorizontalPageIndex = 0;
				}
				this._maxHorizontalPageIndex = MathUtils.INT_MAX;
			}
			else
			{
				this._minHorizontalPageIndex = 0;
				var unroundedPageIndex:Float = horizontalScrollRange / this.actualPageWidth;
				var nearestPageIndex:Int = Math.round(unroundedPageIndex);
				if (MathUtil.isEquivalent(unroundedPageIndex, nearestPageIndex, PAGE_INDEX_EPSILON))
				{
					//we almost always want to round up, but a
					//floating point math error, or a page width that
					//isn't an integer (when snapping to pixels) could
					//cause the page index to be off by one
					this._maxHorizontalPageIndex = nearestPageIndex;
				}
				else
				{
					this._maxHorizontalPageIndex = Math.ceil(unroundedPageIndex);
				}
			}
			
			var verticalScrollRange:Float = this._maxVerticalScrollPosition - this._minVerticalScrollPosition;
			if (verticalScrollRange == Math.POSITIVE_INFINITY)
			{
				//trying to put positive infinity into an int results in 0
				//so we need a special case to provide a large int value.
				if (this._minVerticalScrollPosition == Math.NEGATIVE_INFINITY)
				{
					this._minVerticalPageIndex = MathUtils.INT_MIN;
				}
				else
				{
					this._minVerticalPageIndex = 0;
				}
				this._maxVerticalPageIndex = MathUtils.INT_MAX;
			}
			else
			{
				this._minVerticalPageIndex = 0;
				unroundedPageIndex = verticalScrollRange / this.actualPageHeight;
				nearestPageIndex = Math.round(unroundedPageIndex);
				if (MathUtil.isEquivalent(unroundedPageIndex, nearestPageIndex, PAGE_INDEX_EPSILON))
				{
					//we almost always want to round up, but a
					//floating point math error, or a page height that
					//isn't an integer (when snapping to pixels) could
					//cause the page index to be off by one
					this._maxVerticalPageIndex = nearestPageIndex;
				}
				else
				{
					this._maxVerticalPageIndex = Math.ceil(unroundedPageIndex);
				}
			}
		}
		else
		{
			this._maxHorizontalPageIndex = 0;
			this._maxHorizontalPageIndex = 0;
			this._minVerticalPageIndex = 0;
			this._maxVerticalPageIndex = 0;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshPageIndices():Void
	{
		if (this._horizontalAutoScrollTween == null && !this.hasPendingHorizontalPageIndex)
		{
			if (this._snapToPages)
			{
				if (this._horizontalScrollPosition == this._maxHorizontalScrollPosition)
				{
					this._horizontalPageIndex = this._maxHorizontalPageIndex;
				}
				else if (this._horizontalScrollPosition == this._minHorizontalScrollPosition)
				{
					this._horizontalPageIndex = this._minHorizontalPageIndex;
				}
				else
				{
					if (this._minHorizontalScrollPosition == Math.NEGATIVE_INFINITY && this._horizontalScrollPosition < 0)
					{
						var unroundedPageIndex:Float = this._horizontalScrollPosition / this.actualPageWidth;
					}
					else if (this._maxHorizontalScrollPosition == Math.POSITIVE_INFINITY && this._horizontalScrollPosition >= 0)
					{
						unroundedPageIndex = this._horizontalScrollPosition / this.actualPageWidth;
					}
					else
					{
						var adjustedHorizontalScrollPosition:Float = this._horizontalScrollPosition - this._minHorizontalScrollPosition;
						unroundedPageIndex = adjustedHorizontalScrollPosition / this.actualPageWidth;
					}
					var nearestPageIndex:Int = Math.round(unroundedPageIndex);
					if (unroundedPageIndex != nearestPageIndex &&
						MathUtil.isEquivalent(unroundedPageIndex, nearestPageIndex, PAGE_INDEX_EPSILON))
					{
						//we almost always want to round down, but a
						//floating point math error, or a page width that
						//isn't an integer (when snapping to pixels) could
						//cause the page index to be off by one
						this._horizontalPageIndex = nearestPageIndex;
					}
					else
					{
						this._horizontalPageIndex = Math.floor(unroundedPageIndex);
					}
				}
			}
			else
			{
				this._horizontalPageIndex = this._minHorizontalPageIndex;
			}
			if (this._horizontalPageIndex < this._minHorizontalPageIndex)
			{
				this._horizontalPageIndex = this._minHorizontalPageIndex;
			}
			if (this._horizontalPageIndex > this._maxHorizontalPageIndex)
			{
				this._horizontalPageIndex = this._maxHorizontalPageIndex;
			}
		}
		if (this._verticalAutoScrollTween == null && !this.hasPendingVerticalPageIndex)
		{
			if (this._snapToPages)
			{
				if (this._verticalScrollPosition == this._maxVerticalScrollPosition)
				{
					this._verticalPageIndex = this._maxVerticalPageIndex;
				}
				else if (this._verticalScrollPosition == this._minVerticalScrollPosition)
				{
					this._verticalPageIndex = this._minVerticalPageIndex;
				}
				else
				{
					if (this._minVerticalScrollPosition == Math.NEGATIVE_INFINITY && this._verticalScrollPosition < 0)
					{
						unroundedPageIndex = this._verticalScrollPosition / this.actualPageHeight;
					}
					else if (this._maxVerticalScrollPosition == Math.POSITIVE_INFINITY && this._verticalScrollPosition >= 0)
					{
						unroundedPageIndex = this._verticalScrollPosition / this.actualPageHeight;
					}
					else
					{
						var adjustedVerticalScrollPosition:Float = this._verticalScrollPosition - this._minVerticalScrollPosition;
						unroundedPageIndex = adjustedVerticalScrollPosition / this.actualPageHeight;
					}
					nearestPageIndex = Math.round(unroundedPageIndex);
					if (unroundedPageIndex != nearestPageIndex &&
						MathUtil.isEquivalent(unroundedPageIndex, nearestPageIndex, PAGE_INDEX_EPSILON))
					{
						//we almost always want to round down, but a
						//floating point math error, or a page height that
						//isn't an integer (when snapping to pixels) could
						//cause the page index to be off by one
						this._verticalPageIndex = nearestPageIndex;
					}
					else
					{
						this._verticalPageIndex = Math.floor(unroundedPageIndex);
					}
				}
			}
			else
			{
				this._verticalPageIndex = this._minVerticalScrollPosition;
			}
			if (this._verticalPageIndex < this._minVerticalScrollPosition)
			{
				this._verticalPageIndex = this._minVerticalScrollPosition;
			}
			if (this._verticalPageIndex > this._maxVerticalPageIndex)
			{
				this._verticalPageIndex = this._maxVerticalPageIndex;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshScrollBarValues():Void
	{
		if (this.horizontalScrollBar != null)
		{
			this.horizontalScrollBar.minimum = this._minHorizontalScrollPosition;
			this.horizontalScrollBar.maximum = this._maxHorizontalScrollPosition;
			this.horizontalScrollBar.value = this._horizontalScrollPosition;
			this.horizontalScrollBar.page = (this._maxHorizontalScrollPosition - this._minHorizontalScrollPosition) * this.actualPageWidth / this._viewPort.width;
			this.horizontalScrollBar.step = this.actualHorizontalScrollStep;
		}
		
		if (this.verticalScrollBar != null)
		{
			this.verticalScrollBar.minimum = this._minVerticalScrollPosition;
			this.verticalScrollBar.maximum = this._maxVerticalScrollPosition;
			this.verticalScrollBar.value = this._verticalScrollPosition;
			this.verticalScrollBar.page = (this._maxVerticalScrollPosition - this._minVerticalScrollPosition) * this.actualPageHeight / this._viewPort.height;
			this.verticalScrollBar.step = this.actualVerticalScrollStep;
		}
	}
	
	/**
	 * @private
	 */
	private function showOrHideChildren():Void
	{
		var childCount:Int = this.numRawChildrenInternal;
		if (this.verticalScrollBar != null)
		{
			this.verticalScrollBar.visible = this._hasVerticalScrollBar;
			this.verticalScrollBar.touchable = this._hasVerticalScrollBar && this._interactionMode != ScrollInteractionMode.TOUCH;
			this.setRawChildIndexInternal(cast this.verticalScrollBar, childCount - 1);
		}
		if (this.horizontalScrollBar != null)
		{
			this.horizontalScrollBar.visible = this._hasHorizontalScrollBar;
			this.horizontalScrollBar.touchable = this._hasHorizontalScrollBar && this._interactionMode != ScrollInteractionMode.TOUCH;
			if (this.verticalScrollBar != null)
			{
				this.setRawChildIndexInternal(cast this.horizontalScrollBar, childCount - 2);
			}
			else
			{
				this.setRawChildIndexInternal(cast this.horizontalScrollBar, childCount - 1);
			}
		}
		if (this.currentBackgroundSkin != null)
		{
			if (this._autoHideBackground)
			{
				this.currentBackgroundSkin.visible = this._viewPort.width <= this.actualWidth ||
					this._viewPort.height <= this.actualHeight ||
					this._horizontalScrollPosition < 0 ||
					this._horizontalScrollPosition > this._maxHorizontalScrollPosition ||
					this._verticalScrollPosition < 0 ||
					this._verticalScrollPosition > this._maxVerticalScrollPosition;
			}
			else
			{
				this.currentBackgroundSkin.visible = true;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function calculateViewPortOffsetsForFixedHorizontalScrollBar(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void
	{
		if (this.horizontalScrollBar != null && (this._measureViewPort || useActualBounds))
		{
			var scrollerWidth:Float = useActualBounds ? this.actualWidth : this._explicitWidth;
			if (!useActualBounds && !forceScrollBars &&
				scrollerWidth != scrollerWidth) //isNaN
			{
				//even if explicitWidth is NaN, the view port might measure
				//a view port width smaller than its content width
				scrollerWidth = this._viewPort.visibleWidth + this._leftViewPortOffset + this._rightViewPortOffset;
			}
			var totalWidth:Float = this._viewPort.width + this._leftViewPortOffset + this._rightViewPortOffset;
			if (forceScrollBars || this._horizontalScrollPolicy == ScrollPolicy.ON ||
				((totalWidth > scrollerWidth || totalWidth > this._explicitMaxWidth) &&
					this._horizontalScrollPolicy != ScrollPolicy.OFF))
			{
				this._hasHorizontalScrollBar = true;
				if (this._scrollBarDisplayMode == ScrollBarDisplayMode.FIXED)
				{
					if (this._horizontalScrollBarPosition == RelativePosition.TOP)
					{
						this._topViewPortOffset += this.horizontalScrollBar.height;
					}
					else
					{
						this._bottomViewPortOffset += this.horizontalScrollBar.height;
					}
				}
			}
			else
			{
				this._hasHorizontalScrollBar = false;
			}
		}
		else
		{
			this._hasHorizontalScrollBar = false;
		}
	}
	
	/**
	 * @private
	 */
	private function calculateViewPortOffsetsForFixedVerticalScrollBar(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void
	{
		if (this.verticalScrollBar != null && (this._measureViewPort || useActualBounds))
		{
			var scrollerHeight:Float = useActualBounds ? this.actualHeight : this._explicitHeight;
			if (!useActualBounds && !forceScrollBars &&
				scrollerHeight != scrollerHeight) //isNaN
			{
				//even if explicitHeight is NaN, the view port might measure
				//a view port height smaller than its content height
				scrollerHeight = this._viewPort.visibleHeight + this._topViewPortOffset + this._bottomViewPortOffset;
			}
			var totalHeight:Float = this._viewPort.height + this._topViewPortOffset + this._bottomViewPortOffset;
			if (forceScrollBars || this._verticalScrollPolicy == ScrollPolicy.ON ||
				((totalHeight > scrollerHeight || totalHeight > this._explicitMaxHeight) &&
					this._verticalScrollPolicy != ScrollPolicy.OFF))
			{
				this._hasVerticalScrollBar = true;
				if (this._scrollBarDisplayMode == ScrollBarDisplayMode.FIXED)
				{
					if (this._verticalScrollBarPosition == RelativePosition.LEFT)
					{
						this._leftViewPortOffset += this.verticalScrollBar.width;
					}
					else
					{
						this._rightViewPortOffset += this.verticalScrollBar.width;
					}
				}
			}
			else
			{
				this._hasVerticalScrollBar = false;
			}
		}
		else
		{
			this._hasVerticalScrollBar = false;
		}
	}
	
	/**
	 * @private
	 */
	private function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void
	{
		//in fixed mode, if we determine that scrolling is required, we
		//remember the offsets for later. if scrolling is not needed, then
		//we will ignore the offsets from here forward
		this._topViewPortOffset = this._paddingTop;
		this._rightViewPortOffset = this._paddingRight;
		this._bottomViewPortOffset = this._paddingBottom;
		this._leftViewPortOffset = this._paddingLeft;
		this.calculateViewPortOffsetsForFixedHorizontalScrollBar(forceScrollBars, useActualBounds);
		this.calculateViewPortOffsetsForFixedVerticalScrollBar(forceScrollBars, useActualBounds);
		//we need to double check the horizontal scroll bar if the scroll
		//bars are fixed because adding a vertical scroll bar may require a
		//horizontal one too.
		if (this._scrollBarDisplayMode == ScrollBarDisplayMode.FIXED &&
			this._hasVerticalScrollBar && !this._hasHorizontalScrollBar)
		{
			this.calculateViewPortOffsetsForFixedHorizontalScrollBar(forceScrollBars, useActualBounds);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshInteractionModeEvents():Void
	{
		if (this._interactionMode == ScrollInteractionMode.TOUCH || this._interactionMode == ScrollInteractionMode.TOUCH_AND_SCROLL_BARS)
		{
			this.addEventListener(TouchEvent.TOUCH, scroller_touchHandler);
		}
		else
		{
			this.removeEventListener(TouchEvent.TOUCH, scroller_touchHandler);
		}

		if ((this._interactionMode == ScrollInteractionMode.MOUSE || this._interactionMode == ScrollInteractionMode.TOUCH_AND_SCROLL_BARS) &&
			this._scrollBarDisplayMode == ScrollBarDisplayMode.FLOAT)
		{
			if (this.horizontalScrollBar != null)
			{
				this.horizontalScrollBar.addEventListener(TouchEvent.TOUCH, horizontalScrollBar_touchHandler);
			}
			if (this.verticalScrollBar != null)
			{
				this.verticalScrollBar.addEventListener(TouchEvent.TOUCH, verticalScrollBar_touchHandler);
			}
		}
		else
		{
			if (this.horizontalScrollBar != null)
			{
				this.horizontalScrollBar.removeEventListener(TouchEvent.TOUCH, horizontalScrollBar_touchHandler);
			}
			if (this.verticalScrollBar != null)
			{
				this.verticalScrollBar.removeEventListener(TouchEvent.TOUCH, verticalScrollBar_touchHandler);
			}
		}
	}
	
	/**
	 * Positions and sizes children based on the actual width and height
	 * values.
	 */
	private function layoutChildren():Void
	{
		var visibleWidth:Float = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset;
		var visibleHeight:Float = this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset;
		
		if (this.currentBackgroundSkin != null)
		{
			this.currentBackgroundSkin.width = this.actualWidth;
			this.currentBackgroundSkin.height = this.actualHeight;
		}
		
		if (this._snapScrollPositionsToPixels)
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			var pixelSize:Float = 1 / starling.contentScaleFactor;
			this._viewPort.x = Math.fround((this._leftViewPortOffset - this._horizontalScrollPosition) / pixelSize) * pixelSize;
			this._viewPort.y = Math.fround((this._topViewPortOffset - this._verticalScrollPosition) / pixelSize) * pixelSize;
		}
		else
		{
			this._viewPort.x = this._leftViewPortOffset - this._horizontalScrollPosition;
			this._viewPort.y = this._topViewPortOffset - this._verticalScrollPosition;
		}
		
		this.layoutPullViews();
		this.layoutScrollBars();
	}
	
	/**
	 * @private
	 */
	private function layoutScrollBars():Void
	{
		var visibleWidth:Float = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset;
		var visibleHeight:Float = this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset;
		if (this.horizontalScrollBar != null)
		{
			this.horizontalScrollBar.validate();
		}
		if (this.verticalScrollBar != null)
		{
			this.verticalScrollBar.validate();
		}
		if (this.horizontalScrollBar != null)
		{
			if (this._horizontalScrollBarPosition == RelativePosition.TOP)
			{
				this.horizontalScrollBar.y = this._paddingTop;
			}
			else
			{
				this.horizontalScrollBar.y = this._topViewPortOffset + visibleHeight;
			}
			this.horizontalScrollBar.x = this._leftViewPortOffset;
			if (this._scrollBarDisplayMode != ScrollBarDisplayMode.FIXED)
			{
				this.horizontalScrollBar.y -= this.horizontalScrollBar.height;
				if ((this._hasVerticalScrollBar || this._verticalScrollBarHideTween != null) && this.verticalScrollBar != null)
				{
					this.horizontalScrollBar.width = visibleWidth - this.verticalScrollBar.width;
				}
				else
				{
					this.horizontalScrollBar.width = visibleWidth;
				}
			}
			else
			{
				this.horizontalScrollBar.width = visibleWidth;
			}
		}
		
		if (this.verticalScrollBar != null)
		{
			if (this._verticalScrollBarPosition == RelativePosition.LEFT)
			{
				this.verticalScrollBar.x = this._paddingLeft;
			}
			else
			{
				this.verticalScrollBar.x = this._leftViewPortOffset + visibleWidth;
			}
			this.verticalScrollBar.y = this._topViewPortOffset;
			if (this._scrollBarDisplayMode != ScrollBarDisplayMode.FIXED)
			{
				this.verticalScrollBar.x -= this.verticalScrollBar.width;
				if ((this._hasHorizontalScrollBar || this._horizontalScrollBarHideTween != null) && this.horizontalScrollBar != null)
				{
					this.verticalScrollBar.height = visibleHeight - this.horizontalScrollBar.height;
				}
				else
				{
					this.verticalScrollBar.height = visibleHeight;
				}
			}
			else
			{
				this.verticalScrollBar.height = visibleHeight;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function layoutPullViews():Void
	{
		var viewPortIndex:Int = this.getRawChildIndexInternal(cast this._viewPort);
		if (this._topPullView != null)
		{
			if (Std.isOfType(this._topPullView, IValidating))
			{
				cast(this._topPullView, IValidating).validate();
			}
			this._topPullView.x = this._topPullView.pivotX * this._topPullView.scaleX +
				(this.actualWidth - this._topPullView.width) / 2;
			//if the animation is active, we don't want to interrupt it.
			//if the user starts dragging, the animation will be stopped.
			if (this._topPullTween == null)
			{
				var pullViewSize:Float = this._topPullView.height;
				var finalRatio:Float = this._topPullViewRatio;
				if (this._verticalScrollPosition < this._minVerticalScrollPosition)
				{
					var scrollRatio:Float = (this._minVerticalScrollPosition - this._verticalScrollPosition) / pullViewSize;
					if (scrollRatio > finalRatio)
					{
						finalRatio = scrollRatio;
					}
				}
				if (this._isTopPullViewActive && finalRatio < 1)
				{
					finalRatio = 1;
				}
				if (finalRatio > 0)
				{
					if (this._topPullViewDisplayMode == PullViewDisplayMode.FIXED)
					{
						this._topPullView.y = this._topViewPortOffset +
							this._topPullView.pivotY * this._topPullView.scaleY;
					}
					else
					{
						this._topPullView.y = this._topViewPortOffset +
							this._topPullView.pivotY * this._topPullView.scaleY +
							(finalRatio * pullViewSize) - pullViewSize;
					}
					this._topPullView.visible = true;
					this.refreshTopPullViewMask();
				}
				else
				{
					this._topPullView.visible = false;
				}
			}
			var pullViewIndex:Int = this.getRawChildIndexInternal(this._topPullView);
			if (this._topPullViewDisplayMode == PullViewDisplayMode.FIXED &&
				this._hasElasticEdges)
			{
				//if fixed and elastic, the pull view should appear below
				//the view port
				if (viewPortIndex < pullViewIndex)
				{
					this.setRawChildIndexInternal(this._topPullView, viewPortIndex);
					viewPortIndex++;
				}
			}
			else
			{
				//otherwise, it should appear above
				if (viewPortIndex > pullViewIndex)
				{
					this.removeRawChildInternal(this._topPullView);
					this.addRawChildAtInternal(this._topPullView, viewPortIndex);
					viewPortIndex--;
				}
			}
		}
		if (this._rightPullView != null)
		{
			if (Std.isOfType(this._rightPullView, IValidating))
			{
				cast(this._rightPullView, IValidating).validate();
			}
			this._rightPullView.y = this._rightPullView.pivotY * this._rightPullView.scaleY +
				(this.actualHeight - this._rightPullView.height) / 2;
			//if the animation is active, we don't want to interrupt it.
			//if the user starts dragging, the animation will be stopped.
			if (this._rightPullTween == null)
			{
				pullViewSize = this._rightPullView.width;
				finalRatio = this._rightPullViewRatio;
				if (this._horizontalScrollPosition > this._maxHorizontalScrollPosition)
				{
					scrollRatio = (this._horizontalScrollPosition - this._maxHorizontalScrollPosition) / pullViewSize;
					if (scrollRatio > finalRatio)
					{
						finalRatio = scrollRatio;
					}
				}
				if (this._isRightPullViewActive && finalRatio < 1)
				{
					finalRatio = 1;
				}
				if (finalRatio > 0)
				{
					if (this._rightPullViewDisplayMode == PullViewDisplayMode.FIXED)
					{
						this._rightPullView.x = this._rightPullView.pivotX * this._rightPullView.scaleX +
							this.actualWidth - this._rightViewPortOffset - pullViewSize;
					}
					else
					{
						this._rightPullView.x = this._rightPullView.pivotX * this._rightPullView.scaleX +
							this.actualWidth - this._rightViewPortOffset - (finalRatio * pullViewSize);
					}
					this._rightPullView.visible = true;
					this.refreshRightPullViewMask();
				}
				else
				{
					this._rightPullView.visible = false;
				}
			}
			pullViewIndex = this.getRawChildIndexInternal(this._rightPullView);
			if (this._rightPullViewDisplayMode == PullViewDisplayMode.FIXED &&
				this._hasElasticEdges)
			{
				//if fixed and elastic, the pull view should appear below
				//the view port
				if (viewPortIndex < pullViewIndex)
				{
					this.setRawChildIndexInternal(this._rightPullView, viewPortIndex);
					viewPortIndex++;
				}
			}
			else
			{
				//otherwise, it should appear above
				if (viewPortIndex > pullViewIndex)
				{
					this.removeRawChildInternal(this._rightPullView);
					this.addRawChildAtInternal(this._rightPullView, viewPortIndex);
					viewPortIndex--;
				}
			}
		}
		if (this._bottomPullView != null)
		{
			if (Std.isOfType(this._bottomPullView, IValidating))
			{
				cast(this._bottomPullView, IValidating).validate();
			}
			this._bottomPullView.x = this._bottomPullView.pivotX * this._bottomPullView.scaleX +
				(this.actualWidth - this._bottomPullView.width) / 2;
			//if the animation is active, we don't want to interrupt it.
			//if the user starts dragging, the animation will be stopped.
			if (this._bottomPullTween == null)
			{
				pullViewSize = this._bottomPullView.height;
				finalRatio = this._bottomPullViewRatio;
				if (this._verticalScrollPosition > this._maxVerticalScrollPosition)
				{
					//if the scroll position is greater than the pull
					//position, then prefer the scroll position
					scrollRatio = (this._verticalScrollPosition - this._maxVerticalScrollPosition) / pullViewSize;
					if (scrollRatio > finalRatio)
					{
						finalRatio = scrollRatio;
					}
				}
				if (this._isBottomPullViewActive && finalRatio < 1)
				{
					finalRatio = 1;
				}
				if (finalRatio > 0)
				{
					if (this._bottomPullViewDisplayMode == PullViewDisplayMode.FIXED)
					{
						this._bottomPullView.y = this._bottomPullView.pivotY * this._bottomPullView.scaleY +
							this.actualHeight - this._bottomViewPortOffset - pullViewSize;
					}
					else
					{
						this._bottomPullView.y = this._bottomPullView.pivotY * this._bottomPullView.scaleY +
							this.actualHeight - this._bottomViewPortOffset - (finalRatio * pullViewSize);
					}
					this._bottomPullView.visible = true;
					this.refreshBottomPullViewMask();
				}
				else
				{
					this._bottomPullView.visible = false;
				}
			}
			pullViewIndex = this.getRawChildIndexInternal(this._bottomPullView);
			if (this._bottomPullViewDisplayMode == PullViewDisplayMode.FIXED &&
				this._hasElasticEdges)
			{
				//if fixed and elastic, the pull view should appear below
				//the view port
				if (viewPortIndex < pullViewIndex)
				{
					this.setRawChildIndexInternal(this._bottomPullView, viewPortIndex);
					viewPortIndex++;
				}
			}
			else
			{
				//otherwise, it should appear above
				if (viewPortIndex > pullViewIndex)
				{
					this.removeRawChildInternal(this._bottomPullView);
					this.addRawChildAtInternal(this._bottomPullView, viewPortIndex);
					viewPortIndex--;
				}
			}
		}
		if (this._leftPullView != null)
		{
			if (Std.isOfType(this._leftPullView, IValidating))
			{
				cast(this._leftPullView, IValidating).validate();
			}
			this._leftPullView.y = this._leftPullView.pivotY * this._leftPullView.scaleY +
				(this.actualHeight - this._leftPullView.height) / 2;
			//if the animation is active, we don't want to interrupt it.
			//if the user starts dragging, the animation will be stopped.
			if (this._leftPullTween == null)
			{
				pullViewSize = this._leftPullView.width;
				finalRatio = this._leftPullViewRatio;
				if (this._horizontalScrollPosition < this._minHorizontalScrollPosition)
				{
					//if the scroll position is less than the pull position,
					//then prefer the scroll position
					scrollRatio = (this._minHorizontalScrollPosition - this._horizontalScrollPosition) / pullViewSize;
					if (scrollRatio > finalRatio)
					{
						finalRatio = scrollRatio;
					}
				}
				if (this._isLeftPullViewActive && finalRatio < 1)
				{
					finalRatio = 1;
				}
				if (finalRatio > 0)
				{
					if (this._leftPullViewDisplayMode == PullViewDisplayMode.FIXED)
					{
						this._leftPullView.x = this._leftViewPortOffset +
							this._leftPullView.pivotX * this._leftPullView.scaleX;
					}
					else
					{
						this._leftPullView.x = this._leftViewPortOffset +
							this._leftPullView.pivotX * this._leftPullView.scaleX +
							 (finalRatio * pullViewSize) - pullViewSize;
					}
					this._leftPullView.visible = true;
					this.refreshLeftPullViewMask();
				}
				else
				{
					this._leftPullView.visible = false;
				}
			}
			pullViewIndex = this.getRawChildIndexInternal(this._leftPullView);
			if (this._leftPullViewDisplayMode == PullViewDisplayMode.FIXED &&
				this._hasElasticEdges)
			{
				//if fixed and elastic, the pull view should appear below
				//the view port
				if (viewPortIndex < pullViewIndex)
				{
					this.setRawChildIndexInternal(this._leftPullView, viewPortIndex);
				}
			}
			else
			{
				//otherwise, it should appear above
				if (viewPortIndex > pullViewIndex)
				{
					this.removeRawChildInternal(this._leftPullView);
					this.addRawChildAtInternal(this._leftPullView, viewPortIndex);
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTopPullViewMask():Void
	{
		var pullViewHeight:Float = this._topPullView.height / this._topPullView.scaleY;
		var mask:DisplayObject = this._topPullView.mask;
		var maskHeight:Float = pullViewHeight + ((this._topPullView.y - this._topPullView.pivotY * this._topPullView.scaleY - this._paddingTop) / this._topPullView.scaleY);
		if (maskHeight < 0)
		{
			maskHeight = 0;
		}
		else if (maskHeight > pullViewHeight)
		{
			maskHeight = pullViewHeight;
		}
		mask.width = this._topPullView.width / this._topPullView.scaleX;
		mask.height = maskHeight;
		mask.x = 0;
		mask.y = pullViewHeight - maskHeight;
	}
	
	/**
	 * @private
	 */
	private function refreshRightPullViewMask():Void
	{
		var pullViewWidth:Float = this._rightPullView.width / this._rightPullView.scaleX;
		var mask:DisplayObject = this._rightPullView.mask;
		var maskWidth:Float = this.actualWidth - this._rightViewPortOffset - ((this._rightPullView.x - this._rightPullView.pivotX / this._rightPullView.scaleX) / this._rightPullView.scaleX);
		if (maskWidth < 0)
		{
			maskWidth = 0;
		}
		else if (maskWidth > pullViewWidth)
		{
			maskWidth = pullViewWidth;
		}
		mask.width = maskWidth;
		mask.height = this._rightPullView.height / this._rightPullView.scaleY;
		mask.x = 0;
		mask.y = 0;
	}
	
	/**
	 * @private
	 */
	private function refreshBottomPullViewMask():Void
	{
		var pullViewHeight:Float = this._bottomPullView.height / this._bottomPullView.scaleY;
		var mask:DisplayObject = this._bottomPullView.mask;
		var maskHeight:Float = this.actualHeight - this._bottomViewPortOffset - ((this._bottomPullView.y - this._bottomPullView.pivotY / this._bottomPullView.scaleY) / this._bottomPullView.scaleY);
		if (maskHeight < 0)
		{
			maskHeight = 0;
		}
		else if (maskHeight > pullViewHeight)
		{
			maskHeight = pullViewHeight;
		}
		mask.width = this._bottomPullView.width / this._bottomPullView.scaleX;
		mask.height = maskHeight;
		mask.x = 0;
		mask.y = 0;
	}
	
	/**
	 * @private
	 */
	private function refreshLeftPullViewMask():Void
	{
		var pullViewWidth:Float = this._leftPullView.width / this._leftPullView.scaleX;
		var mask:DisplayObject = this._leftPullView.mask;
		var maskWidth:Float = pullViewWidth + ((this._leftPullView.x - this._leftPullView.pivotX * this._leftPullView.scaleX - this._paddingLeft) / this._leftPullView.scaleX);
		if (maskWidth < 0)
		{
			maskWidth = 0;
		}
		else if (maskWidth > pullViewWidth)
		{
			maskWidth = pullViewWidth;
		}
		mask.width = maskWidth;
		mask.height = this._leftPullView.height / this._leftPullView.scaleY;
		mask.x = pullViewWidth - maskWidth;
		mask.y = 0;
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
		var clipWidth:Float = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset;
		if (clipWidth < 0)
		{
			clipWidth = 0;
		}
		var clipHeight:Float = this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset;
		if (clipHeight < 0)
		{
			clipHeight = 0;
		}
		var mask:Quad = cast this._viewPort.mask;
		if (mask == null)
		{
			mask = new Quad(1, 1, 0xff0ff);
			this._viewPort.mask = mask;
		}
		mask.x = this._horizontalScrollPosition;
		mask.y = this._verticalScrollPosition;
		mask.width = clipWidth;
		mask.height = clipHeight;
	}
	
	public var numRawChildren(get, never):Int;
	private function get_numRawChildrenInternal():Int
	{
		if (Std.isOfType(this, IScrollContainer))
		{
			return cast(this, IScrollContainer).numRawChildren;
		}
		return this.numChildren;
	}
	
	/**
	 * @private
	 */
	private function addRawChildInternal(child:DisplayObject):DisplayObject
	{
		if (Std.isOfType(this, IScrollContainer))
		{
			return cast(this, IScrollContainer).addRawChild(child);
		}
		return this.addChild(child);
	}
	
	/**
	 * @private
	 */
	private function addRawChildAtInternal(child:DisplayObject, index:Int):DisplayObject
	{
		if (Std.isOfType(this, IScrollContainer))
		{
			return cast(this, IScrollContainer).addRawChildAt(child, index);
		}
		return this.addChildAt(child, index);
	}
	
	/**
	 * @private
	 */
	private function removeRawChildInternal(child:DisplayObject, dispose:Bool = false):DisplayObject
	{
		if (Std.isOfType(this, IScrollContainer))
		{
			return cast(this, IScrollContainer).removeRawChild(child, dispose);
		}
		return this.removeChild(child, dispose);
	}
	
	/**
	 * @private
	 */
	private function removeRawChildAtInternal(index:Int, dispose:Bool = false):DisplayObject
	{
		if(Std.isOfType(this, IScrollContainer))
		{
			return cast(this, IScrollContainer).removeRawChildAt(index, dispose);
		}
		return this.removeChildAt(index, dispose);
	}
	
	/**
	 * @private
	 */
	private function getRawChildIndexInternal(child:DisplayObject):Int
	{
		if (Std.isOfType(this, IScrollContainer))
		{
			return cast(this, IScrollContainer).getRawChildIndex(child);
		}
		return this.getChildIndex(child);
	}
	
	/**
	 * @private
	 */
	private function setRawChildIndexInternal(child:DisplayObject, index:Int):Void
	{
		if (Std.isOfType(this, IScrollContainer))
		{
			cast(this, IScrollContainer).setRawChildIndex(child, index);
			return;
		}
		this.setChildIndex(child, index);
	}
	
	/**
	 * @private
	 */
	private function updateHorizontalScrollFromTouchPosition(touchX:Float):Void
	{
		var offset:Float = this._startTouchX - touchX;
		var position:Float = this._startHorizontalScrollPosition + offset;
		var adjustedMinScrollPosition:Float = this._minHorizontalScrollPosition;
		if (this._isLeftPullViewActive && this._hasElasticEdges)
		{
			adjustedMinScrollPosition -= this._leftPullView.width;
		}
		var adjustedMaxScrollPosition:Float = this._maxHorizontalScrollPosition;
		if (this._isRightPullViewActive && this._hasElasticEdges)
		{
			adjustedMaxScrollPosition += this._rightPullView.width;
		}
		if (position < adjustedMinScrollPosition)
		{
			//first, calculate the position as if elastic edges were enabled
			position = position - (position - adjustedMinScrollPosition) * (1 - this._elasticity);
			if (this._leftPullView != null && position < adjustedMinScrollPosition)
			{
				if (this._isLeftPullViewActive)
				{
					this.leftPullViewRatio = 1;
				}
				else
				{
					//save the difference between that position and the minimum
					//to use for the position of the pull view
					this.leftPullViewRatio = (adjustedMinScrollPosition - position) / this._leftPullView.width;
				}
			}
			if (this._rightPullView != null && !this._isRightPullViewActive)
			{
				this.rightPullViewRatio = 0;
			}
			if (!this._hasElasticEdges ||
				(this._isRightPullViewActive && this._minHorizontalScrollPosition == this._maxHorizontalScrollPosition))
			{
				//if elastic edges aren't enabled, use the minimum
				position = adjustedMinScrollPosition;
			}
		}
		else if (position > adjustedMaxScrollPosition)
		{
			position = position - (position - adjustedMaxScrollPosition) * (1 - this._elasticity);
			if (this._rightPullView != null && position > adjustedMaxScrollPosition)
			{
				if (this._isRightPullViewActive)
				{
					this.rightPullViewRatio = 1;
				}
				else
				{
					this.rightPullViewRatio = (position - adjustedMaxScrollPosition) / this._rightPullView.width;
				}
			}
			if (this._leftPullView != null && !this._isLeftPullViewActive)
			{
				this.leftPullViewRatio = 0;
			}
			if (!this._hasElasticEdges ||
				(this._isLeftPullViewActive && this._minHorizontalScrollPosition == this._maxHorizontalScrollPosition))
			{
				position = adjustedMaxScrollPosition;
			}
		}
		else
		{
			if (this._leftPullView != null && !this._isLeftPullViewActive)
			{
				this.leftPullViewRatio = 0;
			}
			if (this._rightPullView != null && !this._isRightPullViewActive)
			{
				this.rightPullViewRatio = 0;
			}
		}
		if (this._leftPullViewRatio > 0)
		{
			if (this._leftPullTween != null)
			{
				this._leftPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._leftPullTween = null;
			}
			//ensure that the component invalidates, even if the
			//horizontalScrollPosition does not change
			this.invalidate(INVALIDATION_FLAG_SCROLL);
		}
		if (this._rightPullViewRatio > 0)
		{
			if (this._rightPullTween != null)
			{
				this._rightPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._rightPullTween = null;
			}
			//see note above with previous call to invalidate()
			this.invalidate(INVALIDATION_FLAG_SCROLL);
		}
		this.horizontalScrollPosition = position;
	}
	
	/**
	 * @private
	 */
	private function updateVerticalScrollFromTouchPosition(touchY:Float):Void
	{
		var offset:Float = this._startTouchY - touchY;
		var position:Float = this._startVerticalScrollPosition + offset;
		var adjustedMinScrollPosition:Float = this._minVerticalScrollPosition;
		if (this._isTopPullViewActive && this._hasElasticEdges)
		{
			adjustedMinScrollPosition -= this._topPullView.height;
		}
		var adjustedMaxScrollPosition:Float = this._maxVerticalScrollPosition;
		if (this._isBottomPullViewActive && this._hasElasticEdges)
		{
			adjustedMaxScrollPosition += this._bottomPullView.height;
		}
		if (position < adjustedMinScrollPosition)
		{
			//first, calculate the position as if elastic edges were enabled
			position = position - (position - adjustedMinScrollPosition) * (1 - this._elasticity);
			if (this._topPullView != null && position < adjustedMinScrollPosition)
			{
				if (this._isTopPullViewActive)
				{
					this.topPullViewRatio = 1;
				}
				else
				{
					this.topPullViewRatio = (adjustedMinScrollPosition - position) / this._topPullView.height;
				}
			}
			if(this._bottomPullView != null && !this._isBottomPullViewActive)
			{
				this.bottomPullViewRatio = 0;
			}
			if(!this._hasElasticEdges ||
				(this._isBottomPullViewActive && this._minVerticalScrollPosition == this._maxVerticalScrollPosition))
			{
				//if elastic edges aren't enabled, use the minimum
				position = adjustedMinScrollPosition;
			}
		}
		else if (position > adjustedMaxScrollPosition)
		{
			position = position - (position - adjustedMaxScrollPosition) * (1 - this._elasticity);
			if (this._bottomPullView != null && position > adjustedMaxScrollPosition)
			{
				if (this._isBottomPullViewActive)
				{
					this.bottomPullViewRatio = 1;
				}
				else
				{
					this.bottomPullViewRatio = (position - adjustedMaxScrollPosition) / this._bottomPullView.height;
				}
			}
			if (this._topPullView != null && !this._isTopPullViewActive)
			{
				this.topPullViewRatio = 0;
			}
			if (!this._hasElasticEdges ||
				(this._isTopPullViewActive && this._minVerticalScrollPosition == this._maxVerticalScrollPosition))
			{
				position = adjustedMaxScrollPosition;
			}
		}
		else
		{
			if (this._topPullView != null && !this._isTopPullViewActive)
			{
				this.topPullViewRatio = 0;
			}
			if (this._bottomPullView != null && !this._isBottomPullViewActive)
			{
				this.bottomPullViewRatio = 0;
			}
		}
		if (this._topPullViewRatio > 0)
		{
			if (this._topPullTween != null)
			{
				this._topPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._topPullTween = null;
			}
			//ensure that the component invalidates, even if the
			//verticalScrollPosition does not change
			this.invalidate(INVALIDATION_FLAG_SCROLL);
		}
		if (this._bottomPullViewRatio > 0)
		{
			if (this._bottomPullTween != null)
			{
				this._bottomPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._bottomPullTween = null;
			}
			//see note above with previous call to invalidate()
			this.invalidate(INVALIDATION_FLAG_SCROLL);
		}
		this.verticalScrollPosition = position;
	}
	
	/**
	 * Immediately throws the scroller to the specified position, with
	 * optional animation. If you want to throw in only one direction, pass
	 * in <code>NaN</code> for the value that you do not want to change. The
	 * scroller should be validated before throwing.
	 *
	 * @see #scrollToPosition()
	 */
	private function throwTo(targetHorizontalScrollPosition:Float = Math.NaN,
		targetVerticalScrollPosition:Float = Math.NaN, duration:Float = 0.5):Void
	{
		var changedPosition:Bool = false;
		if (targetHorizontalScrollPosition == targetHorizontalScrollPosition) //!isNaN
		{
			if (this._snapToPages && targetHorizontalScrollPosition > this._minHorizontalScrollPosition &&
				targetHorizontalScrollPosition < this._maxHorizontalScrollPosition)
			{
				targetHorizontalScrollPosition = MathUtils.roundToNearest(targetHorizontalScrollPosition, this.actualPageWidth);
			}
			if (this._horizontalAutoScrollTween)
			{
				Starling.juggler.remove(this._horizontalAutoScrollTween);
				this._horizontalAutoScrollTween = null;
			}
			if (this._horizontalScrollPosition != targetHorizontalScrollPosition)
			{
				changedPosition = true;
				this.revealHorizontalScrollBar();
				this.startScroll();
				if (duration == 0)
				{
					this.horizontalScrollPosition = targetHorizontalScrollPosition;
				}
				else
				{
					this._startHorizontalScrollPosition = this._horizontalScrollPosition;
					this._targetHorizontalScrollPosition = targetHorizontalScrollPosition;
					this._horizontalAutoScrollTween = new Tween(this, duration, this._throwEase);
					this._horizontalAutoScrollTween.animate("horizontalScrollPosition", targetHorizontalScrollPosition);
					if (this._snapScrollPositionsToPixels)
					{
						this._horizontalAutoScrollTween.onUpdate = this.horizontalAutoScrollTween_onUpdate;
					}
					this._horizontalAutoScrollTween.onComplete = this.horizontalAutoScrollTween_onComplete;
					Starling.juggler.add(this._horizontalAutoScrollTween);
					this.refreshHorizontalAutoScrollTweenEndRatio();
				}
			}
			else
			{
				this.finishScrollingHorizontally();
			}
		}
		
		if (targetVerticalScrollPosition == targetVerticalScrollPosition) //!isNaN
		{
			if (this._snapToPages && targetVerticalScrollPosition > this._minVerticalScrollPosition &&
				targetVerticalScrollPosition < this._maxVerticalScrollPosition)
			{
				targetVerticalScrollPosition = roundToNearest(targetVerticalScrollPosition, this.actualPageHeight);
			}
			if (this._verticalAutoScrollTween)
			{
				Starling.juggler.remove(this._verticalAutoScrollTween);
				this._verticalAutoScrollTween = null;
			}
			if (this._verticalScrollPosition != targetVerticalScrollPosition)
			{
				changedPosition = true;
				this.revealVerticalScrollBar();
				this.startScroll();
				if (duration == 0)
				{
					this.verticalScrollPosition = targetVerticalScrollPosition;
				}
				else
				{
					this._startVerticalScrollPosition = this._verticalScrollPosition;
					this._targetVerticalScrollPosition = targetVerticalScrollPosition;
					this._verticalAutoScrollTween = new Tween(this, duration, this._throwEase);
					this._verticalAutoScrollTween.animate("verticalScrollPosition", targetVerticalScrollPosition);
					if (this._snapScrollPositionsToPixels)
					{
						this._verticalAutoScrollTween.onUpdate = this.verticalAutoScrollTween_onUpdate;
					}
					this._verticalAutoScrollTween.onComplete = this.verticalAutoScrollTween_onComplete;
					Starling.juggler.add(this._verticalAutoScrollTween);
					this.refreshVerticalAutoScrollTweenEndRatio();
				}
			}
			else
			{
				this.finishScrollingVertically();
			}
		}
		
		if (changedPosition && duration == 0)
		{
			this.completeScroll();
		}
	}
	
	/**
	 * Immediately throws the scroller to the specified page index, with
	 * optional animation. If you want to throw in only one direction, pass
	 * in the value from the <code>horizontalPageIndex</code> or
	 * <code>verticalPageIndex</code> property to the appropriate parameter.
	 * The scroller must be validated before throwing, to ensure that the
	 * minimum and maximum scroll positions are accurate.
	 *
	 * @see #scrollToPageIndex()
	 */
	private function throwToPage(targetHorizontalPageIndex:Int, targetVerticalPageIndex:Int, duration:Float = 0.5):Void
	{
		var targetHorizontalScrollPosition:Float = this._horizontalScrollPosition;
		if (targetHorizontalPageIndex >= this._minHorizontalPageIndex)
		{
			targetHorizontalScrollPosition = this.actualPageWidth * targetHorizontalPageIndex;
		}
		if (targetHorizontalScrollPosition < this._minHorizontalScrollPosition)
		{
			targetHorizontalScrollPosition = this._minHorizontalScrollPosition;
		}
		if (targetHorizontalScrollPosition > this._maxHorizontalScrollPosition)
		{
			targetHorizontalScrollPosition = this._maxHorizontalScrollPosition;
		}
		var targetVerticalScrollPosition:Float = this._verticalScrollPosition;
		if (targetVerticalPageIndex >= this._minVerticalPageIndex)
		{
			targetVerticalScrollPosition = this.actualPageHeight * targetVerticalPageIndex;
		}
		if (targetVerticalScrollPosition < this._minVerticalScrollPosition)
		{
			targetVerticalScrollPosition = this._minVerticalScrollPosition;
		}
		if (targetVerticalScrollPosition > this._maxVerticalScrollPosition)
		{
			targetVerticalScrollPosition = this._maxVerticalScrollPosition;
		}
		if (targetHorizontalPageIndex >= this._minHorizontalPageIndex)
		{
			this._horizontalPageIndex = targetHorizontalPageIndex;
		}
		if (targetVerticalPageIndex >= this._minVerticalPageIndex)
		{
			this._verticalPageIndex = targetVerticalPageIndex;
		}
		this.throwTo(targetHorizontalScrollPosition, targetVerticalScrollPosition, duration);
	}
	
	/**
	 * @private
	 */
	private function calculateDynamicThrowDuration(pixelsPerMS:Float):Float
	{
		return (Math.log(MINIMUM_VELOCITY / Math.abs(pixelsPerMS)) / this._logDecelerationRate) / 1000;
	}

	/**
	 * @private
	 */
	private function calculateThrowDistance(pixelsPerMS:Float):Float
	{
		return (pixelsPerMS - MINIMUM_VELOCITY) / this._logDecelerationRate;
	}
	
	/**
	 * @private
	 */
	private function finishScrollingHorizontally():Void
	{
		var adjustedMinScrollPosition:Float = this._minHorizontalScrollPosition;
		if (this._isLeftPullViewActive && this._hasElasticEdges)
		{
			adjustedMinScrollPosition -= this._leftPullView.width;
		}
		var adjustedMaxScrollPosition:Float = this._maxHorizontalScrollPosition;
		if (this._isRightPullViewActive && this._hasElasticEdges)
		{
			adjustedMaxScrollPosition += this._rightPullView.width;
		}
		var targetHorizontalScrollPosition:Float = Math.NaN;
		if (this._horizontalScrollPosition < adjustedMinScrollPosition)
		{
			targetHorizontalScrollPosition = adjustedMinScrollPosition;
		}
		else if (this._horizontalScrollPosition > adjustedMaxScrollPosition)
		{
			targetHorizontalScrollPosition = adjustedMaxScrollPosition;
		}
		
		this._isDraggingHorizontally = false;
		if (targetHorizontalScrollPosition != targetHorizontalScrollPosition) //isNaN
		{
			this.completeScroll();
		}
		else if (Math.abs(targetHorizontalScrollPosition - this._horizontalScrollPosition) < 1)
		{
			//this distance is too small to animate. just finish now.
			this.horizontalScrollPosition = targetHorizontalScrollPosition;
			this.completeScroll();
		}
		else
		{
			this.throwTo(targetHorizontalScrollPosition, Math.NaN, this._elasticSnapDuration);
		}
		this.restoreHorizontalPullViews();
	}
	
	/**
	 * @private
	 */
	private function finishScrollingVertically():Void
	{
		var adjustedMinScrollPosition:Float = this._minVerticalScrollPosition;
		if (this._isTopPullViewActive && this._hasElasticEdges)
		{
			adjustedMinScrollPosition -= this._topPullView.height;
		}
		var adjustedMaxScrollPosition:Float = this._maxVerticalScrollPosition;
		if (this._isBottomPullViewActive && this._hasElasticEdges)
		{
			adjustedMaxScrollPosition += this._bottomPullView.height;
		}
		var targetVerticalScrollPosition:Float = Math.NaN;
		if (this._verticalScrollPosition < adjustedMinScrollPosition)
		{
			targetVerticalScrollPosition = adjustedMinScrollPosition;
		}
		else if (this._verticalScrollPosition > adjustedMaxScrollPosition)
		{
			targetVerticalScrollPosition = adjustedMaxScrollPosition;
		}
		
		this._isDraggingVertically = false;
		if (targetVerticalScrollPosition != targetVerticalScrollPosition) //isNaN
		{
			this.completeScroll();
		}
		else if (Math.abs(targetVerticalScrollPosition - this._verticalScrollPosition) < 1)
		{
			//this distance is too small to animate. just finish now.
			this.verticalScrollPosition = targetVerticalScrollPosition;
			this.completeScroll();
		}
		else
		{
			this.throwTo(Math.NaN, targetVerticalScrollPosition, this._elasticSnapDuration);
		}
		this.restoreVerticalPullViews();
	}
	
	/**
	 * @private
	 */
	private function restoreVerticalPullViews():Void
	{
		if (this._topPullView != null &&
			this._topPullViewRatio > 0)
		{
			if (this._topPullTween != null)
			{
				this._topPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._topPullTween = null;
			}
			if (this._topPullViewDisplayMode == PullViewDisplayMode.DRAG)
			{
				var yPosition:Float = this._topViewPortOffset + 
					this._topPullView.pivotY * this._topPullView.scaleY;
				if (!this._isTopPullViewActive)
				{
					yPosition -= this._topPullView.height;
				}
				if (this._topPullView.y != yPosition)
				{
					this._topPullTween = new Tween(this._topPullView, this._elasticSnapDuration, this._throwEase);
					this._topPullTween.animate("y", yPosition);
					this._topPullTween.onUpdate = this.refreshTopPullViewMask;
					this._topPullTween.onComplete = this.topPullTween_onComplete;
					Starling.juggler.add(this._topPullTween);
				}
			}
			else
			{
				this.topPullTween_onComplete();
			}
		}
		if (this._bottomPullView != null &&
			this._bottomPullViewRatio > 0)
		{
			if (this._bottomPullTween != null)
			{
				this._bottomPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._bottomPullTween = null;
			}
			if (this._bottomPullViewDisplayMode == PullViewDisplayMode.DRAG)
			{
				yPosition = this.actualHeight - this._bottomViewPortOffset +
					this._bottomPullView.pivotY * this._bottomPullView.scaleY;
				if (this._isBottomPullViewActive)
				{
					yPosition -= this._bottomPullView.height;
				}
				if (this._bottomPullView.y != yPosition)
				{
					this._bottomPullTween = new Tween(this._bottomPullView, this._elasticSnapDuration, this._throwEase);
					this._bottomPullTween.animate("y", yPosition);
					this._bottomPullTween.onUpdate = this.refreshBottomPullViewMask;
					this._bottomPullTween.onComplete = this.bottomPullTween_onComplete;
					Starling.juggler.add(this._bottomPullTween);
				}
			}
			else
			{
				this.bottomPullTween_onComplete();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function restoreHorizontalPullViews():Void
	{
		if (this._leftPullView != null &&
			this._leftPullViewRatio > 0)
		{
			if (this._leftPullTween != null)
			{
				this._leftPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._leftPullTween = null;
			}
			if (this._leftPullViewDisplayMode == PullViewDisplayMode.DRAG)
			{
				var xPosition:Float = this._leftViewPortOffset +
					this._leftPullView.pivotX * this._leftPullView.scaleX;
				if (!this._isLeftPullViewActive)
				{
					xPosition -= this._leftPullView.width;
				}
				if (this._leftPullView.x != xPosition)
				{
					this._leftPullTween = new Tween(this._leftPullView, this._elasticSnapDuration, this._throwEase);
					this._leftPullTween.animate("x", xPosition);
					this._leftPullTween.onUpdate = this.refreshLeftPullViewMask;
					this._leftPullTween.onComplete = this.leftPullTween_onComplete;
					Starling.juggler.add(this._leftPullTween);
				}
			}
			else
			{
				this.leftPullTween_onComplete();
			}
		}
		if (this._rightPullView != null &&
			this._rightPullViewRatio > 0)
		{
			if (this._rightPullTween != null)
			{
				this._rightPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				this._rightPullTween = null;
			}
			if (this._rightPullViewDisplayMode == PullViewDisplayMode.DRAG)
			{
				xPosition = this.actualWidth - this._rightViewPortOffset +
					this._rightPullView.pivotX * this._rightPullView.scaleX;
				if (this._isRightPullViewActive)
				{
					xPosition -= this._rightPullView.width;
				}
				if (this._rightPullView.x != xPosition)
				{
					this._rightPullTween = new Tween(this._rightPullView, this._elasticSnapDuration, this._throwEase);
					this._rightPullTween.animate("x", xPosition);
					this._rightPullTween.onUpdate = this.refreshRightPullViewMask;
					this._rightPullTween.onComplete = this.rightPullTween_onComplete;
					Starling.juggler.add(this._rightPullTween);
				}
			}
			else
			{
				this.rightPullTween_onComplete();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function throwHorizontally(pixelsPerMS:Float):Void
	{
		if (this._snapToPages && !this._snapOnComplete)
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			var inchesPerSecond:Float = 1000 * pixelsPerMS / (DeviceCapabilities.dpi / starling.contentScaleFactor);
			if (inchesPerSecond > this._minimumPageThrowVelocity)
			{
				var snappedPageHorizontalScrollPosition:Float = MathUtils.roundDownToNearest(this._horizontalScrollPosition, this.actualPageWidth);
			}
			else if (inchesPerSecond < -this._minimumPageThrowVelocity)
			{
				snappedPageHorizontalScrollPosition = MathUtils.roundUpToNearest(this._horizontalScrollPosition, this.actualPageWidth);
			}
			else
			{
				var lastPageWidth:Float = this._maxHorizontalScrollPosition % this.actualPageWidth;
				var startOfLastPage:Float = this._maxHorizontalScrollPosition - lastPageWidth;
				if (lastPageWidth < this.actualPageWidth && this._horizontalScrollPosition >= startOfLastPage)
				{
					var lastPagePosition:Float = this._horizontalScrollPosition - startOfLastPage;
					if (inchesPerSecond > this._minimumPageThrowVelocity)
					{
						snappedPageHorizontalScrollPosition = startOfLastPage + MathUtils.roundDownToNearest(lastPagePosition, lastPageWidth);
					}
					else if (inchesPerSecond < -this._minimumPageThrowVelocity)
					{
						snappedPageHorizontalScrollPosition = startOfLastPage + MathUtils.roundUpToNearest(lastPagePosition, lastPageWidth);
					}
					else
					{
						snappedPageHorizontalScrollPosition = startOfLastPage + MathUtils.roundToNearest(lastPagePosition, lastPageWidth);
					}
				}
				else
				{
					snappedPageHorizontalScrollPosition = MathUtils.roundToNearest(this._horizontalScrollPosition, this.actualPageWidth);
				}
			}
			if (snappedPageHorizontalScrollPosition < this._minHorizontalScrollPosition)
			{
				snappedPageHorizontalScrollPosition = this._minHorizontalScrollPosition;
			}
			else if (snappedPageHorizontalScrollPosition > this._maxHorizontalScrollPosition)
			{
				snappedPageHorizontalScrollPosition = this._maxHorizontalScrollPosition;
			}
			if (snappedPageHorizontalScrollPosition == this._maxHorizontalScrollPosition)
			{
				var targetHorizontalPageIndex:Int = this._maxHorizontalPageIndex;
			}
			else
			{
				//we need to use Math.round() on these values to avoid
				//floating-point errors that could result in the values
				//being rounded down too far.
				if (this._minHorizontalScrollPosition == Math.NEGATIVE_INFINITY)
				{
					targetHorizontalPageIndex = Math.round(snappedPageHorizontalScrollPosition / this.actualPageWidth);
				}
				else
				{
					targetHorizontalPageIndex = Math.round((snappedPageHorizontalScrollPosition - this._minHorizontalScrollPosition) / this.actualPageWidth);
				}
			}
			this.throwToPage(targetHorizontalPageIndex, -1, this._pageThrowDuration);
			return;
		}
		
		var absPixelsPerMS:Float = Math.abs(pixelsPerMS);
		if(!this._snapToPages && absPixelsPerMS <= MINIMUM_VELOCITY)
		{
			this.finishScrollingHorizontally();
			return;
		}
		
		var duration:Float = this._fixedThrowDuration;
		if (!this._useFixedThrowDuration)
		{
			duration = this.calculateDynamicThrowDuration(pixelsPerMS);
		}
		this.throwTo(this._horizontalScrollPosition + this.calculateThrowDistance(pixelsPerMS), Math.NaN, duration);
	}
	
	/**
	 * @private
	 */
	private function throwVertically(pixelsPerMS:Float):Void
	{
		if (this._snapToPages && !this._snapOnComplete)
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			var inchesPerSecond:Float = 1000 * pixelsPerMS / (DeviceCapabilities.dpi / starling.contentScaleFactor);
			if (inchesPerSecond > this._minimumPageThrowVelocity)
			{
				var snappedPageVerticalScrollPosition:Float = MathUtils.roundDownToNearest(this._verticalScrollPosition, this.actualPageHeight);
			}
			else if (inchesPerSecond < -this._minimumPageThrowVelocity)
			{
				snappedPageVerticalScrollPosition = MathUtils.roundUpToNearest(this._verticalScrollPosition, this.actualPageHeight);
			}
			else
			{
				var lastPageHeight:Float = this._maxVerticalScrollPosition % this.actualPageHeight;
				var startOfLastPage:Float = this._maxVerticalScrollPosition - lastPageHeight;
				if (lastPageHeight < this.actualPageHeight && this._verticalScrollPosition >= startOfLastPage)
				{
					var lastPagePosition:Float = this._verticalScrollPosition - startOfLastPage;
					if (inchesPerSecond > this._minimumPageThrowVelocity)
					{
						snappedPageVerticalScrollPosition = startOfLastPage + MathUtils.roundDownToNearest(lastPagePosition, lastPageHeight);
					}
					else if (inchesPerSecond < -this._minimumPageThrowVelocity)
					{
						snappedPageVerticalScrollPosition = startOfLastPage + MathUtils.roundUpToNearest(lastPagePosition, lastPageHeight);
					}
					else
					{
						snappedPageVerticalScrollPosition = startOfLastPage + MathUtils.roundToNearest(lastPagePosition, lastPageHeight);
					}
				}
				else
				{
					snappedPageVerticalScrollPosition = MathUtils.roundToNearest(this._verticalScrollPosition, this.actualPageHeight);
				}
			}
			if (snappedPageVerticalScrollPosition < this._minVerticalScrollPosition)
			{
				snappedPageVerticalScrollPosition = this._minVerticalScrollPosition;
			}
			else if (snappedPageVerticalScrollPosition > this._maxVerticalScrollPosition)
			{
				snappedPageVerticalScrollPosition = this._maxVerticalScrollPosition;
			}
			if (snappedPageVerticalScrollPosition == this._maxVerticalScrollPosition)
			{
				var targetVerticalPageIndex:Int = this._maxVerticalPageIndex;
			}
			else
			{
				//we need to use Math.round() on these values to avoid
				//floating-point errors that could result in the values
				//being rounded down too far.
				if (this._minVerticalScrollPosition == Math.NEGATIVE_INFINITY)
				{
					targetVerticalPageIndex = Math.round(snappedPageVerticalScrollPosition / this.actualPageHeight);
				}
				else
				{
					targetVerticalPageIndex = Math.round((snappedPageVerticalScrollPosition - this._minVerticalScrollPosition) / this.actualPageHeight);
				}
			}
			this.throwToPage(-1, targetVerticalPageIndex, this._pageThrowDuration);
			return;
		}
		
		var absPixelsPerMS:Number = Math.abs(pixelsPerMS);
		if(!this._snapToPages && absPixelsPerMS <= MINIMUM_VELOCITY)
		{
			this.finishScrollingVertically();
			return;
		}
		
		var duration:Number = this._fixedThrowDuration;
		if(!this._useFixedThrowDuration)
		{
			duration = this.calculateDynamicThrowDuration(pixelsPerMS);
		}
		this.throwTo(NaN, this._verticalScrollPosition + this.calculateThrowDistance(pixelsPerMS), duration);
	}
	
	/**
	 * @private
	 */
	private function horizontalAutoScrollTween_onUpdateWithEndRatio():Void
	{
		var ratio:Float = this._horizontalAutoScrollTween.transitionFunc(this._horizontalAutoScrollTween.currentTime / this._horizontalAutoScrollTween.totalTime);
		if (ratio >= this._horizontalAutoScrollTweenEndRatio &&
			this._horizontalAutoScrollTween.currentTime < this._horizontalAutoScrollTween.totalTime)
		{
			//check that the currentTime is less than totalTime because if
			//the tween is complete, we don't want it set to null before
			//the onComplete callback
			if (!this._hasElasticEdges)
			{
				if (this._horizontalScrollPosition < this._minHorizontalScrollPosition)
				{
					this._horizontalScrollPosition = this._minHorizontalScrollPosition;
				}
				else if (this._horizontalScrollPosition > this._maxHorizontalScrollPosition)
				{
					this._horizontalScrollPosition = this._maxHorizontalScrollPosition;
				}
			}
			Starling.juggler.remove(this._horizontalAutoScrollTween);
			this._horizontalAutoScrollTween = null;
			this.finishScrollingHorizontally();
			return;
		}
		if (this._snapScrollPositionsToPixels)
		{
			this.horizontalAutoScrollTween_onUpdate();
		}
	}
	
	/**
	 * @private
	 */
	private function verticalAutoScrollTween_onUpdateWithEndRatio():Void
	{
		var ratio:Float = this._verticalAutoScrollTween.transitionFunc(this._verticalAutoScrollTween.currentTime / this._verticalAutoScrollTween.totalTime);
		if (ratio >= this._verticalAutoScrollTweenEndRatio &&
			this._verticalAutoScrollTween.currentTime < this._verticalAutoScrollTween.totalTime)
		{
			//check that the currentTime is less than totalTime because if
			//the tween is complete, we don't want it set to null before
			//the onComplete callback
			if (!this._hasElasticEdges)
			{
				if (this._verticalScrollPosition < this._minVerticalScrollPosition)
				{
					this._verticalScrollPosition = this._minVerticalScrollPosition;
				}
				else if (this._verticalScrollPosition > this._maxVerticalScrollPosition)
				{
					this._verticalScrollPosition = this._maxVerticalScrollPosition;
				}
			}
			Starling.juggler.remove(this._verticalAutoScrollTween);
			this._verticalAutoScrollTween = null;
			this.finishScrollingVertically();
			return;
		}
		if (this._snapScrollPositionsToPixels)
		{
			this.verticalAutoScrollTween_onUpdate();
		}
	}
	
	/**
	 * @private
	 */
	private function refreshHorizontalAutoScrollTweenEndRatio():Void
	{
		var adjustedMinVerticalScrollPosition:Float = this._minHorizontalScrollPosition;
		if (this._isLeftPullViewActive && this._hasElasticEdges)
		{
			adjustedMinVerticalScrollPosition -= this._leftPullView.width;
		}
		var adjustedMaxScrollPosition:Float = this._maxHorizontalScrollPosition;
		if (this._isRightPullViewActive && this._hasElasticEdges)
		{
			adjustedMaxScrollPosition += this._rightPullView.width;
		}
		var distance:Float = Math.abs(this._targetHorizontalScrollPosition - this._startHorizontalScrollPosition);
		var ratioOutOfBounds:Float = 0;
		if (this._targetHorizontalScrollPosition > adjustedMaxScrollPosition)
		{
			ratioOutOfBounds = (this._targetHorizontalScrollPosition - adjustedMaxScrollPosition) / distance;
		}
		else if (this._targetHorizontalScrollPosition < adjustedMinVerticalScrollPosition)
		{
			ratioOutOfBounds = (adjustedMinVerticalScrollPosition - this._targetHorizontalScrollPosition) / distance;
		}
		if (ratioOutOfBounds > 0)
		{
			if (this._hasElasticEdges)
			{
				this._horizontalAutoScrollTweenEndRatio = (1 - ratioOutOfBounds) + (ratioOutOfBounds * this._throwElasticity);
			}
			else
			{
				this._horizontalAutoScrollTweenEndRatio = 1 - ratioOutOfBounds;
			}
		}
		else
		{
			this._horizontalAutoScrollTweenEndRatio = 1;
		}
		if (this._horizontalAutoScrollTween)
		{
			if (this._horizontalAutoScrollTweenEndRatio < 1)
			{
				this._horizontalAutoScrollTween.onUpdate = this.horizontalAutoScrollTween_onUpdateWithEndRatio;
			}
			else if (this._snapScrollPositionsToPixels)
			{
				this._horizontalAutoScrollTween.onUpdate = this.horizontalAutoScrollTween_onUpdate;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshVerticalAutoScrollTweenEndRatio():Void
	{
		var adjustedMinVerticalScrollPosition:Float = this._minVerticalScrollPosition;
		if (this._isTopPullViewActive && this._hasElasticEdges)
		{
			adjustedMinVerticalScrollPosition -= this._topPullView.height;
		}
		var adjustedMaxScrollPosition:Float = this._maxVerticalScrollPosition;
		if (this._isBottomPullViewActive && this._hasElasticEdges)
		{
			adjustedMaxScrollPosition += this._bottomPullView.height;
		}
		var distance:Float = Math.abs(this._targetVerticalScrollPosition - this._startVerticalScrollPosition);
		var ratioOutOfBounds:Float = 0;
		if (this._targetVerticalScrollPosition > adjustedMaxScrollPosition)
		{
			ratioOutOfBounds = (this._targetVerticalScrollPosition - adjustedMaxScrollPosition) / distance;
		}
		else if (this._targetVerticalScrollPosition < adjustedMinVerticalScrollPosition)
		{
			ratioOutOfBounds = (adjustedMinVerticalScrollPosition - this._targetVerticalScrollPosition) / distance;
		}
		if (ratioOutOfBounds > 0)
		{
			if (this._hasElasticEdges)
			{
				this._verticalAutoScrollTweenEndRatio = (1 - ratioOutOfBounds) + (ratioOutOfBounds * this._throwElasticity);
			}
			else
			{
				this._verticalAutoScrollTweenEndRatio = 1 - ratioOutOfBounds;
			}
		}
		else
		{
			this._verticalAutoScrollTweenEndRatio = 1;
		}
		if (this._verticalAutoScrollTween)
		{
			if (this._verticalAutoScrollTweenEndRatio < 1)
			{
				this._verticalAutoScrollTween.onUpdate = this.verticalAutoScrollTween_onUpdateWithEndRatio;
			}
			else if (this._snapScrollPositionsToPixels)
			{
				this._verticalAutoScrollTween.onUpdate = this.verticalAutoScrollTween_onUpdate;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function hideHorizontalScrollBar(delay:Float = 0):Void
	{
		if (this.horizontalScrollBar == null || this._scrollBarDisplayMode != ScrollBarDisplayMode.FLOAT || this._horizontalScrollBarHideTween != null)
		{
			return;
		}
		if (this.horizontalScrollBar.alpha == 0)
		{
			return;
		}
		if (this._hideScrollBarAnimationDuration == 0 && delay == 0)
		{
			this.horizontalScrollBar.alpha = 0;
		}
		else
		{
			this._horizontalScrollBarHideTween = new Tween(this.horizontalScrollBar, this._hideScrollBarAnimationDuration, this._hideScrollBarAnimationEase);
			this._horizontalScrollBarHideTween.fadeTo(0);
			this._horizontalScrollBarHideTween.delay = delay;
			this._horizontalScrollBarHideTween.onComplete = horizontalScrollBarHideTween_onComplete;
			Starling.juggler.add(this._horizontalScrollBarHideTween);
		}
	}
	
	/**
	 * @private
	 */
	private function hideVerticalScrollBar(delay:Float = 0):Void
	{
		if (this.verticalScrollBar == null || this._scrollBarDisplayMode != ScrollBarDisplayMode.FLOAT || this._verticalScrollBarHideTween != null)
		{
			return;
		}
		if (this.verticalScrollBar.alpha == 0)
		{
			return;
		}
		if (this._hideScrollBarAnimationDuration == 0 && delay == 0)
		{
			this.verticalScrollBar.alpha = 0;
		}
		else
		{
			this._verticalScrollBarHideTween = new Tween(this.verticalScrollBar, this._hideScrollBarAnimationDuration, this._hideScrollBarAnimationEase);
			this._verticalScrollBarHideTween.fadeTo(0);
			this._verticalScrollBarHideTween.delay = delay;
			this._verticalScrollBarHideTween.onComplete = verticalScrollBarHideTween_onComplete;
			Starling.juggler.add(this._verticalScrollBarHideTween);
		}
	}
	
	/**
	 * @private
	 */
	private function revealHorizontalScrollBar():Void
	{
		if (this.horizontalScrollBar == null || this._scrollBarDisplayMode != ScrollBarDisplayMode.FLOAT)
		{
			return;
		}
		if (this._horizontalScrollBarHideTween != null)
		{
			Starling.juggler.remove(this._horizontalScrollBarHideTween);
			this._horizontalScrollBarHideTween = null;
		}
		this.horizontalScrollBar.alpha = 1;
	}
	
	/**
	 * @private
	 */
	private function revealVerticalScrollBar():Void
	{
		if (this.verticalScrollBar == null || this._scrollBarDisplayMode != ScrollBarDisplayMode.FLOAT)
		{
			return;
		}
		if (this._verticalScrollBarHideTween != null)
		{
			Starling.juggler.remove(this._verticalScrollBarHideTween);
			this._verticalScrollBarHideTween = null;
		}
		this.verticalScrollBar.alpha = 1;
	}
	
	/**
	 * If scrolling hasn't already started, prepares the scroller to scroll
	 * and dispatches <code>FeathersEventType.SCROLL_START</code>.
	 */
	private function startScroll():Void
	{
		if (this._isScrolling)
		{
			return;
		}
		this._isScrolling = true;
		this.dispatchEventWith(FeathersEventType.SCROLL_START);
	}
	
	/**
	 * Prepares the scroller for normal interaction and dispatches
	 * <code>FeathersEventType.SCROLL_COMPLETE</code>.
	 */
	private function completeScroll():Void
	{
		if (!this._isScrolling || this._verticalAutoScrollTween != null || this._horizontalAutoScrollTween != null ||
			this._isDraggingHorizontally || this._isDraggingVertically ||
			this._horizontalScrollBarIsScrolling || this._verticalScrollBarIsScrolling)
		{
			return;
		}
		this._isScrolling = false;
		this.hideHorizontalScrollBar();
		this.hideVerticalScrollBar();
		//we validate to ensure that the final Event.SCROLL
		//dispatched before FeathersEventType.SCROLL_COMPLETE
		this.validate();
		this.dispatchEventWith(FeathersEventType.SCROLL_COMPLETE);
	}
	
	/**
	 * Scrolls to a pending scroll position, if required.
	 */
	private function handlePendingScroll():Void
	{
		if (this.pendingHorizontalScrollPosition == this.pendingHorizontalScrollPosition ||
			this.pendingVerticalScrollPosition == this.pendingVerticalScrollPosition) //!isNaN
		{
			this.throwTo(this.pendingHorizontalScrollPosition, this.pendingVerticalScrollPosition, this.pendingScrollDuration);
			this.pendingHorizontalScrollPosition = Math.NaN;
			this.pendingVerticalScrollPosition = Math.NaN;
		}
		if (this.hasPendingHorizontalPageIndex && this.hasPendingVerticalPageIndex)
		{
			//both
			this.throwToPage(this.pendingHorizontalPageIndex, this.pendingVerticalPageIndex, this.pendingScrollDuration);
		}
		else if (this.hasPendingHorizontalPageIndex)
		{
			//horizontal only
			this.throwToPage(this.pendingHorizontalPageIndex, this._verticalPageIndex, this.pendingScrollDuration);
		}
		else if (this.hasPendingVerticalPageIndex)
		{
			//vertical only
			this.throwToPage(this._horizontalPageIndex, this.pendingVerticalPageIndex, this.pendingScrollDuration);
		}
		this.hasPendingHorizontalPageIndex = false;
		this.hasPendingVerticalPageIndex = false;
	}
	
	/**
	 * @private
	 */
	private function handlePendingRevealScrollBars():Void
	{
		if (!this.isScrollBarRevealPending)
		{
			return;
		}
		this.isScrollBarRevealPending = false;
		if (this._scrollBarDisplayMode != ScrollBarDisplayMode.FLOAT)
		{
			return;
		}
		this.revealHorizontalScrollBar();
		this.revealVerticalScrollBar();
		this.hideHorizontalScrollBar(this._revealScrollBarsDuration);
		this.hideVerticalScrollBar(this._revealScrollBarsDuration);
	}
	
	/**
	 * @private
	 */
	private function handlePendingPullView():Void
	{
		if (this._isTopPullViewPending)
		{
			this._isTopPullViewPending = false;
			if (this._isTopPullViewActive)
			{
				if (this._topPullTween != null)
				{
					this._topPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
					this._topPullTween = null;
				}
				if (Std.isOfType(this._topPullView, IValidating))
				{
					cast(this._topPullView, IValidating).validate();
				}
				this._topPullView.visible = true;
				this._topPullViewRatio = 1;
				if (this._topPullViewDisplayMode == PullViewDisplayMode.DRAG)
				{
					var targetY:Float = this._topViewPortOffset +
						this._topPullView.pivotY * this._topPullView.scaleY;
					if (this.isCreated)
					{
						this._topPullView.y = targetY - this._topPullView.height;
						this._topPullTween = new Tween(this._topPullView, this._elasticSnapDuration, this._throwEase);
						this._topPullTween.animate("y", targetY);
						this._topPullTween.onUpdate = this.refreshTopPullViewMask;
						this._topPullTween.onComplete = this.topPullTween_onComplete;
						Starling.juggler.add(this._topPullTween);
					}
					else
					{
						//if this is the first time the component validates,
						//we don't need animation
						this._topPullView.y = targetY;
					}
				}
			}
			else
			{
				if (this._isScrolling)
				{
					this.restoreVerticalPullViews();
				}
				else
				{
					this.finishScrollingVertically();
				}
			}
		}
		if (this._isRightPullViewPending)
		{
			this._isRightPullViewPending = false;
			if (this._isRightPullViewActive)
			{
				if (this._rightPullTween != null)
				{
					this._rightPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
					this._rightPullTween = null;
				}
				if (Std.isOfType(this._rightPullView, IValidating))
				{
					cast(this._rightPullView, IValidating).validate();
				}
				this._rightPullView.visible = true;
				this._rightPullViewRatio = 1;
				if (this._rightPullViewDisplayMode == PullViewDisplayMode.DRAG)
				{
					var targetX:Float = this.actualWidth - this._rightViewPortOffset +
						this._rightPullView.pivotX * this._rightPullView.scaleX -
						this._rightPullView.width;
					if (this.isCreated)
					{
						this._rightPullView.x = targetX + this._rightPullView.width;
						this._rightPullTween = new Tween(this._rightPullView, this._elasticSnapDuration, this._throwEase);
						this._rightPullTween.animate("x", targetX);
						this._rightPullTween.onUpdate = this.refreshRightPullViewMask;
						this._rightPullTween.onComplete = this.rightPullTween_onComplete;
						Starling.juggler.add(this._rightPullTween);
					}
					else
					{
						//if this is the first time the component validates,
						//we don't need animation
						this._rightPullView.x = targetX;
					}
				}
			}
			else
			{
				if (this._isScrolling)
				{
					this.restoreHorizontalPullViews();
				}
				else
				{
					this.finishScrollingHorizontally();
				}
			}
		}
		if (this._isBottomPullViewPending)
		{
			this._isBottomPullViewPending = false;
			if (this._isBottomPullViewActive)
			{
				if (this._bottomPullTween != null)
				{
					this._bottomPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
					this._bottomPullTween = null;
				}
				if (Std.isOfType(this._bottomPullView, IValidating))
				{
					cast(this._bottomPullView, IValidating).validate();
				}
				this._bottomPullView.visible = true;
				this._bottomPullViewRatio = 1;
				if (this._bottomPullViewDisplayMode == PullViewDisplayMode.DRAG)
				{
					targetY = this.actualHeight - this._bottomViewPortOffset +
						this._bottomPullView.pivotY * this._bottomPullView.scaleY -
						this._bottomPullView.height;
					if (this.isCreated)
					{
						this._bottomPullView.y = targetY + this._bottomPullView.height;
						this._bottomPullTween = new Tween(this._bottomPullView, this._elasticSnapDuration, this._throwEase);
						this._bottomPullTween.animate("y", targetY);
						this._bottomPullTween.onUpdate = this.refreshBottomPullViewMask;
						this._bottomPullTween.onComplete = this.bottomPullTween_onComplete;
						Starling.juggler.add(this._bottomPullTween);
					}
					else
					{
						this._bottomPullView.y = targetY;
					}
				}
			}
			else
			{
				if (this._isScrolling)
				{
					this.restoreVerticalPullViews();
				}
				else
				{
					this.finishScrollingVertically();
				}
			}
		}
		if (this._isLeftPullViewPending)
		{
			this._isLeftPullViewPending = false;
			if (this._isLeftPullViewActive)
			{
				if (this._leftPullTween != null)
				{
					this._leftPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
					this._leftPullTween = null;
				}
				if (Std.isOfType(this._leftPullView, IValidating))
				{
					cast(this._leftPullView, IValidating).validate();
				}
				this._leftPullView.visible = true;
				this._leftPullViewRatio = 1;
				if (this._leftPullViewDisplayMode == PullViewDisplayMode.DRAG)
				{
					targetX = this._leftViewPortOffset +
						this._leftPullView.pivotX * this._leftPullView.scaleX;
					if (this.isCreated)
					{
						this._leftPullView.x = targetX - this._leftPullView.width;
						this._leftPullTween = new Tween(this._leftPullView, this._elasticSnapDuration, this._throwEase);
						this._leftPullTween.animate("x", targetX);
						this._leftPullTween.onUpdate = this.refreshLeftPullViewMask;
						this._leftPullTween.onComplete = this.leftPullTween_onComplete;
						Starling.juggler.add(this._leftPullTween);
					}
					else
					{
						//if this is the first time the component validates,
						//we don't need animation
						this._leftPullView.x = targetX;
					}
				}
			}
			else
			{
				if (this._isScrolling)
				{
					this.restoreHorizontalPullViews();
				}
				else
				{
					this.finishScrollingHorizontally();
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function checkForDrag():Void
	{
		if (this._isScrollingStopped)
		{
			return;
		}
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var horizontalInchesMoved:Float = (this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		var verticalInchesMoved:Float = (this._currentTouchY - this._startTouchY) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
		if (!this._isDraggingHorizontally &&
			(
				this._horizontalScrollPolicy == ScrollPolicy.ON ||
				(this._horizontalScrollPolicy == ScrollPolicy.AUTO && this._minHorizontalScrollPosition != this._maxHorizontalScrollPosition) ||
				(this._leftPullView != null && (this._currentTouchX > this._startTouchX || this._horizontalScrollPosition < this._minHorizontalScrollPosition)) ||
				(this._rightPullView != null && (this._currentTouchX < this._startTouchX || this._horizontalScrollPosition > this._minHorizontalScrollPosition))
			) &&
			(
				((horizontalInchesMoved <= -this._minimumDragDistance) && (this._hasElasticEdges || this._horizontalScrollPosition < this._maxHorizontalScrollPosition || this._rightPullView != null)) ||
				((horizontalInchesMoved >= this._minimumDragDistance) && (this._hasElasticEdges || this._horizontalScrollPosition > this._minHorizontalScrollPosition || this._leftPullView != null))
			))
		{
			if (this.horizontalScrollBar != null)
			{
				this.revealHorizontalScrollBar();
			}
			this._startTouchX = this._currentTouchX;
			this._startHorizontalScrollPosition = this._horizontalScrollPosition;
			this._isDraggingHorizontally = true;
			//if we haven't already started dragging in the other direction,
			//we need to dispatch the event that says we're starting.
			if (!this._isDraggingVertically)
			{
				this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
				var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
				exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
				exclusiveTouch.claimTouch(this._touchPointID, this);
				this.startScroll();
			}
		}
		if (!this._isDraggingVertically &&
			(
				this._verticalScrollPolicy == ScrollPolicy.ON ||
				(this._verticalScrollPolicy == ScrollPolicy.AUTO && this._minVerticalScrollPosition != this._maxVerticalScrollPosition) ||
				(this._topPullView != null && (this._currentTouchY > this._startTouchY || this._verticalScrollPosition < this._minVerticalScrollPosition)) ||
				(this._bottomPullView != null && (this._currentTouchY < this._startTouchY || this._verticalScrollPosition > this._minVerticalScrollPosition))
			) &&
			(
				((verticalInchesMoved <= -this._minimumDragDistance) && (this._hasElasticEdges || this._verticalScrollPosition < this._maxVerticalScrollPosition || this._bottomPullView != null)) ||
				((verticalInchesMoved >= this._minimumDragDistance) && (this._hasElasticEdges || this._verticalScrollPosition > this._minVerticalScrollPosition || this._topPullView != null))
			))
		{
			if (this.verticalScrollBar != null)
			{
				this.revealVerticalScrollBar();
			}
			this._startTouchY = this._currentTouchY;
			this._startVerticalScrollPosition = this._verticalScrollPosition;
			this._isDraggingVertically = true;
			if(!this._isDraggingHorizontally)
			{
				exclusiveTouch = ExclusiveTouch.forStage(this.stage);
				exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
				exclusiveTouch.claimTouch(this._touchPointID, this);
				this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
				this.startScroll();
			}
		}
		if(this._isDraggingHorizontally && !this._horizontalAutoScrollTween)
		{
			this.updateHorizontalScrollFromTouchPosition(this._currentTouchX);
		}
		if(this._isDraggingVertically && !this._verticalAutoScrollTween)
		{
			this.updateVerticalScrollFromTouchPosition(this._currentTouchY);
		}
	}
	
	/**
	 * @private
	 */
	private function saveVelocity():Void
	{
		this._pendingVelocityChange = false;
		if (this._isScrollingStopped)
		{
			return;
		}
		var now:Int = getTimer();
		var timeOffset:Int = now - this._previousTouchTime;
		if (timeOffset > 0)
		{
			//we're keeping previous velocity updates to improve accuracy
			this._previousVelocityX[this._previousVelocityX.length] = this._velocityX;
			if(this._previousVelocityX.length > MAXIMUM_SAVED_VELOCITY_COUNT)
			{
				this._previousVelocityX.shift();
			}
			this._previousVelocityY[this._previousVelocityY.length] = this._velocityY;
			if(this._previousVelocityY.length > MAXIMUM_SAVED_VELOCITY_COUNT)
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
	private function viewPort_resizeHandler(event:Event):Void
	{
		if (this.ignoreViewPortResizing ||
			(this._viewPort.width == this._lastViewPortWidth && this._viewPort.height == this._lastViewPortHeight))
		{
			return;
		}
		this._lastViewPortWidth = this._viewPort.width;
		this._lastViewPortHeight = this._viewPort.height;
		if (this._isValidating)
		{
			this._hasViewPortBoundsChanged = true;
		}
		else
		{
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
	}
	
	/**
	 * @private
	 */
	private function childProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private function verticalScrollBar_changeHandler(event:Event):Void
	{
		this.verticalScrollPosition = this.verticalScrollBar.value;
	}

	/**
	 * @private
	 */
	private function horizontalScrollBar_changeHandler(event:Event):Void
	{
		this.horizontalScrollPosition = this.horizontalScrollBar.value;
	}
	
	/**
	 * @private
	 */
	private function horizontalScrollBar_beginInteractionHandler(event:Event):Void
	{
		if (this._horizontalAutoScrollTween != null)
		{
			Starling.juggler.remove(this._horizontalAutoScrollTween);
			this._horizontalAutoScrollTween = null;
		}
		this._isDraggingHorizontally = false;
		this._horizontalScrollBarIsScrolling = true;
		this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
		if (!this._isScrolling)
		{
			this.startScroll();
		}
	}
	
	/**
	 * @private
	 */
	private function horizontalScrollBar_endInteractionHandler(event:Event):Void
	{
		this._horizontalScrollBarIsScrolling = false;
		this.dispatchEventWith(FeathersEventType.END_INTERACTION);
		this.completeScroll();
	}
	
	/**
	 * @private
	 */
	private function verticalScrollBar_beginInteractionHandler(event:Event):Void
	{
		if (this._verticalAutoScrollTween != null)
		{
			Starling.juggler.remove(this._verticalAutoScrollTween);
			this._verticalAutoScrollTween = null;
		}
		this._isDraggingVertically = false;
		this._verticalScrollBarIsScrolling = true;
		this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
		if (!this._isScrolling)
		{
			this.startScroll();
		}
	}
	
	/**
	 * @private
	 */
	private function verticalScrollBar_endInteractionHandler(event:Event):Void
	{
		this._verticalScrollBarIsScrolling = false;
		this.dispatchEventWith(FeathersEventType.END_INTERACTION);
		this.completeScroll();
	}
	
	/**
	 * @private
	 */
	private function horizontalAutoScrollTween_onUpdate():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var pixelSize:Float = 1 / starling.contentScaleFactor;
		var viewPortX:Float = Math.round((this._leftViewPortOffset - this._horizontalScrollPosition) / pixelSize) * pixelSize;
		var targetViewPortX:Float = Math.round((this._leftViewPortOffset - this._targetHorizontalScrollPosition) / pixelSize) * pixelSize;
		if (viewPortX == targetViewPortX)
		{
			//we've reached the snapped position, but the tween may not
			//have ended yet. since the user won't see any further changes,
			//force the tween to the end.
			this._horizontalAutoScrollTween.advanceTime(this._horizontalAutoScrollTween.totalTime);
		}
	}
	
	/**
	 * @private
	 */
	private function horizontalAutoScrollTween_onComplete():Void
	{
		//because the onUpdate callback may call advanceTime(), remove
		//the callbacks to be sure that they aren't called too many times.
		if (this._horizontalAutoScrollTween != null)
		{
			this._horizontalAutoScrollTween.onUpdate = null;
			this._horizontalAutoScrollTween.onComplete = null;
			this._horizontalAutoScrollTween = null;
		}
		//the page index will not have updated during the animation, so we
		//need to ensure that it is updated now.
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		this.finishScrollingHorizontally();
	}
	
	/**
	 * @private
	 */
	private function verticalAutoScrollTween_onUpdate():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var pixelSize:Float = 1 / starling.contentScaleFactor;
		var viewPortY:Float = Math.round((this._topViewPortOffset - this._verticalScrollPosition) / pixelSize) * pixelSize;
		var targetViewPortY:Float = Math.round((this._topViewPortOffset - this._targetVerticalScrollPosition) / pixelSize) * pixelSize;
		if (viewPortY == targetViewPortY)
		{
			//we've reached the snapped position, but the tween may not
			//have ended yet. since the user won't see any further changes,
			//force the tween to the end.
			this._verticalAutoScrollTween.advanceTime(this._verticalAutoScrollTween.totalTime);
		}
	}
	
	/**
	 * @private
	 */
	private function verticalAutoScrollTween_onComplete():Void
	{
		//because the onUpdate callback may call advanceTime(), remove
		//the callbacks to be sure that they aren't called too many times.
		if (this._verticalAutoScrollTween != null)
		{
			this._verticalAutoScrollTween.onUpdate = null;
			this._verticalAutoScrollTween.onComplete = null;
			this._verticalAutoScrollTween = null;
		}
		//the page index will not have updated during the animation, so we
		//need to ensure that it is updated now.
		this.invalidate(INVALIDATION_FLAG_SCROLL);
		this.finishScrollingVertically();
	}
	
	/**
	 * @private
	 */
	private function topPullTween_onComplete():Void
	{
		this._topPullTween = null;
		if (this._isTopPullViewActive)
		{
			this._topPullViewRatio = 1;
		}
		else
		{
			this._topPullViewRatio = 0;
		}
		this.invalidate(INVALIDATION_FLAG_SCROLL);
	}
	
	/**
	 * @private
	 */
	private function rightPullTween_onComplete():Void
	{
		this._rightPullTween = null;
		if (this._isRightPullViewActive)
		{
			this._rightPullViewRatio = 1;
		}
		else
		{
			this._rightPullViewRatio = 0;
		}
		this.invalidate(INVALIDATION_FLAG_SCROLL);
	}
	
	/**
	 * @private
	 */
	private function bottomPullTween_onComplete():Void
	{
		this._bottomPullTween = null;
		if (this._isBottomPullViewActive)
		{
			this._bottomPullViewRatio = 1;
		}
		else
		{
			this._bottomPullViewRatio = 0;
		}
		this.invalidate(INVALIDATION_FLAG_SCROLL);
	}
	
	/**
	 * @private
	 */
	private function leftPullTween_onComplete():Void
	{
		this._leftPullTween = null;
		if (this._isLeftPullViewActive)
		{
			this._leftPullViewRatio = 1;
		}
		else
		{
			this._leftPullViewRatio = 0;
		}
		this.invalidate(INVALIDATION_FLAG_SCROLL);
	}
	
	/**
	 * @private
	 */
	private function horizontalScrollBarHideTween_onComplete():Void
	{
		this._horizontalScrollBarHideTween = null;
	}
	
	/**
	 * @private
	 */
	private function verticalScrollBarHideTween_onComplete():Void
	{
		this._verticalScrollBarHideTween = null;
	}
	
	/**
	 * @private
	 */
	private function scroller_touchHandler(event:TouchEvent):Void
	{
		//it's rare, but the stage could be null if the scroller is removed
		//in a listener for the same event.
		if (!this._isEnabled || this.stage == null)
		{
			this._touchPointID = -1;
			return;
		}
		if (this._touchPointID != -1)
		{
			return;
		}
		
		//any began touch is okay here. we don't need to check all touches.
		var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
		if (touch == null)
		{
			return;
		}
		
		if (this._interactionMode == ScrollInteractionMode.TOUCH_AND_SCROLL_BARS &&
			(event.interactsWith(cast this.horizontalScrollBar) || event.interactsWith(cast this.verticalScrollBar)))
		{
			return;
		}
		
		var touchPosition:Point = touch.getLocation(this, Pool.getPoint());
		var touchX:Float = touchPosition.x;
		var touchY:Float = touchPosition.y;
		Pool.putPoint(touchPosition);
		if (touchX < this._leftViewPortOffset || touchY < this._topViewPortOffset ||
			touchX >= (this.actualWidth - this._rightViewPortOffset) ||
			touchY >= (this.actualHeight - this._bottomViewPortOffset))
		{
			return;
		}
		
		var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
		if (exclusiveTouch.getClaim(touch.id))
		{
			//already claimed
			return;
		}
		
		//if the scroll policy is off, we shouldn't stop this animation
		if (this._horizontalAutoScrollTween != null && this._horizontalScrollPolicy != ScrollPolicy.OFF)
		{
			Starling.juggler.remove(this._horizontalAutoScrollTween);
			this._horizontalAutoScrollTween = null;
		}
		if (this._verticalAutoScrollTween != null && this._verticalScrollPolicy != ScrollPolicy.OFF)
		{
			Starling.juggler.remove(this._verticalAutoScrollTween);
			this._verticalAutoScrollTween = null;
		}
		
		this._touchPointID = touch.id;
		this._velocityX = 0;
		this._velocityY = 0;
		this._previousVelocityX.length = 0;
		this._previousVelocityY.length = 0;
		this._previousTouchTime = getTimer();
		this._previousTouchX = this._startTouchX = this._currentTouchX = touchX;
		this._previousTouchY = this._startTouchY = this._currentTouchY = touchY;
		this._startHorizontalScrollPosition = this._horizontalScrollPosition;
		this._startVerticalScrollPosition = this._verticalScrollPosition;
		this._isScrollingStopped = false;
		if (!this._isScrolling || !this._snapToPages)
		{
			//if snapToPages is enabled, we need it to snap to the nearest
			//page on TouchPhase.ENDED, even if we don't drag again
			//BowlerHatLLC/feathersui-starling#1771
			this._isDraggingVertically = false;
			this._isDraggingHorizontally = false;
		}
		if (this._isScrolling)
		{
			//if it was scrolling, stop it immediately
			this.completeScroll();
		}
		
		this.addEventListener(Event.ENTER_FRAME, scroller_enterFrameHandler);
		
		//we need to listen on the stage because if we scroll the bottom or
		//right edge past the top of the scroller, it gets stuck and we stop
		//receiving touch events for "this".
		this.stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		
		exclusiveTouch.addEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
	}
	
	/**
	 * @private
	 */
	private function scroller_enterFrameHandler(event:Event):Void
	{
		this.saveVelocity();
	}
	
	/**
	 * @private
	 */
	private function stage_touchHandler(event:TouchEvent):Void
	{
		if (this._touchPointID < 0)
		{
			//if the touch is claimed with ExclusiveTouch by a child, the
			//listener is removed, but the current event will keep bubbling
			return;
		}
		var touch:Touch = event.getTouch(this.stage, null, this._touchPointID);
		if (touch == null)
		{
			return;
		}
		
		if (touch.phase == TouchPhase.MOVED)
		{
			var touchPosition:Point = touch.getLocation(this, Pool.getPoint());
			this._currentTouchX = touchPosition.x;
			this._currentTouchY = touchPosition.y;
			Pool.putPoint(touchPosition);
			this.checkForDrag();
			//we don't call saveVelocity() on TouchPhase.MOVED because the
			//time interval may be very short, which could lead to
			//inaccurate results. instead, we wait for the next frame.
			this._pendingVelocityChange = true;
		}
		else if (touch.phase == TouchPhase.ENDED)
		{
			if (this._pendingVelocityChange)
			{
				//we may need to do this one last time because the enter
				//frame listener may not have been called since the last
				//TouchPhase.MOVED
				this.saveVelocity();
			}
			if (!this._isDraggingHorizontally && !this._isDraggingVertically)
			{
				ExclusiveTouch.forStage(this.stage).removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
			}
			this.removeEventListener(Event.ENTER_FRAME, scroller_enterFrameHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
			this._touchPointID = -1;
			this.dispatchEventWith(FeathersEventType.END_INTERACTION);
			
			if (!this._isTopPullViewActive && this._isDraggingVertically &&
				this._topPullView != null &&
				this._topPullViewRatio >= 1)
			{
				this._isTopPullViewActive = true;
				this._topPullView.dispatchEventWith(Event.UPDATE);
				this.dispatchEventWith(Event.UPDATE, false, this._topPullView);
			}
			if (!this._isRightPullViewActive && this._isDraggingHorizontally &&
				this._rightPullView != null &&
				this._rightPullViewRatio >= 1)
			{
				this._isRightPullViewActive = true;
				this._rightPullView.dispatchEventWith(Event.UPDATE);
				this.dispatchEventWith(Event.UPDATE, false, this._rightPullView);
			}
			if (!this._isBottomPullViewActive && this._isDraggingVertically &&
				this._bottomPullView != null &&
				this._bottomPullViewRatio >= 1)
			{
				this._isBottomPullViewActive = true;
				this._bottomPullView.dispatchEventWith(Event.UPDATE);
				this.dispatchEventWith(Event.UPDATE, false, this._bottomPullView);
			}
			if (!this._isLeftPullViewActive && this._isDraggingHorizontally && 
				this._leftPullView != null &&
				this._leftPullViewRatio >= 1)
			{
				this._isLeftPullViewActive = true;
				this._leftPullView.dispatchEventWith(Event.UPDATE);
				this.dispatchEventWith(Event.UPDATE, false, this._leftPullView);
			}
			
			var isFinishingHorizontally:Bool = false;
			var adjustedMinHorizontalScrollPosition:Float = this._minHorizontalScrollPosition;
			if (this._isLeftPullViewActive && this._hasElasticEdges)
			{
				adjustedMinHorizontalScrollPosition -= this._leftPullView.width;
			}
			var adjustedMaxHorizontalScrollPosition:Float = this._maxHorizontalScrollPosition;
			if (this._isRightPullViewActive && this._hasElasticEdges)
			{
				adjustedMaxHorizontalScrollPosition += this._rightPullView.width;
			}
			if (this._horizontalScrollPosition < adjustedMinHorizontalScrollPosition ||
				this._horizontalScrollPosition > adjustedMaxHorizontalScrollPosition)
			{
				isFinishingHorizontally = true;
				this.finishScrollingHorizontally();
			}
			var isFinishingVertically:Bool = false;
			var adjustedMinVerticalScrollPosition:Float = this._minVerticalScrollPosition;
			if (this._isTopPullViewActive && this._hasElasticEdges)
			{
				adjustedMinVerticalScrollPosition -= this._topPullView.height;
			}
			var adjustedMaxVerticalScrollPosition:Float = this._maxVerticalScrollPosition;
			if (this._isBottomPullViewActive && this._hasElasticEdges)
			{
				adjustedMaxVerticalScrollPosition += this._bottomPullView.height;
			}
			if (this._verticalScrollPosition < adjustedMinVerticalScrollPosition ||
				this._verticalScrollPosition > adjustedMaxVerticalScrollPosition)
			{
				isFinishingVertically = true;
				this.finishScrollingVertically();
			}
			
			if (isFinishingHorizontally && isFinishingVertically)
			{
				return;
			}
			
			if (!isFinishingHorizontally)
			{
				if (this._isDraggingHorizontally)
				{
					//take the average for more accuracy
					var sum:Float = this._velocityX * CURRENT_VELOCITY_WEIGHT;
					var velocityCount:Int = this._previousVelocityX.length;
					var totalWeight:Float = CURRENT_VELOCITY_WEIGHT;
					for (i in 0...velocityCount)
					{
						var weight:Float = VELOCITY_WEIGHTS[i];
						sum += this._previousVelocityX.shift() * weight;
						totalWeight += weight;
					}
					this.throwHorizontally(sum / totalWeight);
				}
				else
				{
					this.hideHorizontalScrollBar();
				}
			}
			
			if (!isFinishingVertically)
			{
				if (this._isDraggingVertically)
				{
					sum = this._velocityY * CURRENT_VELOCITY_WEIGHT;
					velocityCount = this._previousVelocityY.length;
					totalWeight = CURRENT_VELOCITY_WEIGHT;
					for (i in 0...velocityCount)
					{
						weight = VELOCITY_WEIGHTS[i];
						sum += this._previousVelocityY.shift() * weight;
						totalWeight += weight;
					}
					this.throwVertically(sum / totalWeight);
				}
				else
				{
					this.hideVerticalScrollBar();
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function exclusiveTouch_changeHandler(event:Event, touchID:Int):Void
	{
		if (this._touchPointID < 0 || this._touchPointID != touchID || this._isDraggingHorizontally || this._isDraggingVertically)
		{
			return;
		}
		var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
		if (exclusiveTouch.getClaim(touchID) == this)
		{
			return;
		}
		
		this._touchPointID = -1;
		this.removeEventListener(Event.ENTER_FRAME, scroller_enterFrameHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
		this.dispatchEventWith(FeathersEventType.END_INTERACTION);
	}
	
	/**
	 * @private
	 */
	private function nativeStage_mouseWheelHandler(event:MouseEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		if ((this._verticalMouseWheelScrollDirection == Direction.VERTICAL && (this._maxVerticalScrollPosition == this._minVerticalScrollPosition || this._verticalScrollPolicy == ScrollPolicy.OFF)) ||
			(this._verticalMouseWheelScrollDirection == Direction.HORIZONTAL && (this._maxHorizontalScrollPosition == this._minHorizontalScrollPosition || this._horizontalScrollPolicy == ScrollPolicy.OFF)))
		{
			return;
		}
		
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var nativeScaleFactor:Float = 1;
		if (starling.supportHighResolutions)
		{
			nativeScaleFactor = starling.nativeStage.contentsScaleFactor;
		}
		var starlingViewPort:Rectangle = starling.viewPort;
		var scaleFactor:Float = nativeScaleFactor / starling.contentScaleFactor;
		var point:Point = Pool.getPoint(
			(event.stageX - starlingViewPort.x) * scaleFactor,
			(event.stageY - starlingViewPort.y) * scaleFactor);
		var isContained:Bool = this.stage != null && this.contains(this.stage.hitTest(point));
		if (!isContained)
		{
			Pool.putPoint(point);
		}
		else
		{
			this.globalToLocal(point, point);
			var localMouseX:Float = point.x;
			var localMouseY:Float = point.y;
			Pool.putPoint(point);
			if (localMouseX < this._leftViewPortOffset || localMouseY < this._topViewPortOffset ||
				localMouseX >= this.actualWidth - this._rightViewPortOffset ||
				localMouseY >= this.actualHeight - this._bottomViewPortOffset)
			{
				return;
			}
			var targetHorizontalScrollPosition:Float = this._horizontalScrollPosition;
			var targetVerticalScrollPosition:Float = this._verticalScrollPosition;
			var scrollStep:Float = this._verticalMouseWheelScrollStep;
			if (this._verticalMouseWheelScrollDirection == Direction.HORIZONTAL)
			{
				if (scrollStep != scrollStep) //isNaN
				{
					scrollStep = this.actualHorizontalScrollStep;
				}
				targetHorizontalScrollPosition -= event.delta * scrollStep;
				if (targetHorizontalScrollPosition < this._minHorizontalScrollPosition)
				{
					targetHorizontalScrollPosition = this._minHorizontalScrollPosition;
				}
				else if (targetHorizontalScrollPosition > this._maxHorizontalScrollPosition)
				{
					targetHorizontalScrollPosition = this._maxHorizontalScrollPosition;
				}
			}
			else //vertical
			{
				if (scrollStep != scrollStep) //isNaN
				{
					scrollStep = this.actualVerticalScrollStep;
				}
				targetVerticalScrollPosition -= event.delta * scrollStep;
				if (targetVerticalScrollPosition < this._minVerticalScrollPosition)
				{
					targetVerticalScrollPosition = this._minVerticalScrollPosition;
				}
				else if (targetVerticalScrollPosition > this._maxVerticalScrollPosition)
				{
					targetVerticalScrollPosition = this._maxVerticalScrollPosition;
				}
			}
			this.throwTo(targetHorizontalScrollPosition, targetVerticalScrollPosition, this._mouseWheelScrollDuration);
		}
	}
	
	/**
	 * @private
	 */
	private function nativeStage_orientationChangeHandler(event:flash.events.Event):Void
	{
		if (this._touchPointID < 0)
		{
			return;
		}
		this._startTouchX = this._previousTouchX = this._currentTouchX;
		this._startTouchY = this._previousTouchY = this._currentTouchY;
		this._startHorizontalScrollPosition = this._horizontalScrollPosition;
		this._startVerticalScrollPosition = this._verticalScrollPosition;
	}
	
	/**
	 * @private
	 */
	private function horizontalScrollBar_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._horizontalScrollBarTouchPointID = -1;
			return;
		}
		
		var displayHorizontalScrollBar:DisplayObject = cast event.currentTarget;
		if (this._horizontalScrollBarTouchPointID >= 0)
		{
			var touch:Touch = event.getTouch(displayHorizontalScrollBar, TouchPhase.ENDED, this._horizontalScrollBarTouchPointID);
			if (touch == null)
			{
				return;
			}
			
			this._horizontalScrollBarTouchPointID = -1;
			var touchPosition:Point = touch.getLocation(displayHorizontalScrollBar, Pool.getPoint());
			var isInBounds:Bool = this.horizontalScrollBar.hitTest(touchPosition) != null;
			Pool.putPoint(touchPosition);
			if (!isInBounds)
			{
				this.hideHorizontalScrollBar();
			}
		}
		else
		{
			touch = event.getTouch(displayHorizontalScrollBar, TouchPhase.BEGAN);
			if (touch != null)
			{
				this._horizontalScrollBarTouchPointID = touch.id;
				return;
			}
			if (this._isScrolling)
			{
				return;
			}
			touch = event.getTouch(displayHorizontalScrollBar, TouchPhase.HOVER);
			if (touch)
			{
				this.revealHorizontalScrollBar();
				return;
			}
			
			//end hover
			this.hideHorizontalScrollBar();
		}
	}
	
	/**
	 * @private
	 */
	private function verticalScrollBar_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._verticalScrollBarTouchPointID = -1;
			return;
		}
		
		var displayVerticalScrollBar:DisplayObject = cast event.currentTarget;
		if (this._verticalScrollBarTouchPointID >= 0)
		{
			var touch:Touch = event.getTouch(displayVerticalScrollBar, TouchPhase.ENDED, this._verticalScrollBarTouchPointID);
			if (touch == null)
			{
				return;
			}
			
			this._verticalScrollBarTouchPointID = -1;
			var touchPosition:Point = touch.getLocation(displayVerticalScrollBar, Pool.getPoint());
			var isInBounds:Bool = this.verticalScrollBar.hitTest(touchPosition) != null;
			Pool.putPoint(touchPosition);
			if (!isInBounds)
			{
				this.hideVerticalScrollBar();
			}
		}
		else
		{
			touch = event.getTouch(displayVerticalScrollBar, TouchPhase.BEGAN);
			if (touch != null)
			{
				this._verticalScrollBarTouchPointID = touch.id;
				return;
			}
			if (this._isScrolling)
			{
				return;
			}
			touch = event.getTouch(displayVerticalScrollBar, TouchPhase.HOVER);
			if (touch != null)
			{
				this.revealVerticalScrollBar();
				return;
			}
			
			//end hover
			this.hideVerticalScrollBar();
		}
	}
	
	/**
	 * @private
	 */
	private function scroller_addedToStageHandler(event:Event):Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, nativeStage_mouseWheelHandler, false, 0, true);
		starling.nativeStage.addEventListener("orientationChange", nativeStage_orientationChangeHandler, false, 0, true);
	}
	
	/**
	 * @private
	 */
	private function scroller_removedFromStageHandler(event:Event):Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, nativeStage_mouseWheelHandler);
		starling.nativeStage.removeEventListener("orientationChange", nativeStage_orientationChangeHandler);
		if (this._touchPointID >= 0)
		{
			var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			exclusiveTouch.removeEventListener(Event.CHANGE, exclusiveTouch_changeHandler);
		}
		this._touchPointID = -1;
		this._horizontalScrollBarTouchPointID = -1;
		this._verticalScrollBarTouchPointID = -1;
		this._isDraggingHorizontally = false;
		this._isDraggingVertically = false;
		this._velocityX = 0;
		this._velocityY = 0;
		this._previousVelocityX.length = 0;
		this._previousVelocityY.length = 0;
		this._horizontalScrollBarIsScrolling = false;
		this._verticalScrollBarIsScrolling = false;
		this.removeEventListener(Event.ENTER_FRAME, scroller_enterFrameHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		if (this._verticalAutoScrollTween != null)
		{
			Starling.juggler.remove(this._verticalAutoScrollTween);
			this._verticalAutoScrollTween = null;
		}
		if (this._horizontalAutoScrollTween != null)
		{
			Starling.juggler.remove(this._horizontalAutoScrollTween);
			this._horizontalAutoScrollTween = null;
		}
		if (this._topPullTween != null)
		{
			this._topPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
			this._topPullTween = null;
		}
		if (this._rightPullTween != null)
		{
			this._rightPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
			this._rightPullTween = null;
		}
		if (this._bottomPullTween != null)
		{
			this._bottomPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
			this._bottomPullTween = null;
		}
		if (this._leftPullTween != null)
		{
			this._leftPullTween.dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
			this._leftPullTween = null;
		}
		
		//if we stopped the animation while the list was outside the scroll
		//bounds, then let's account for that
		var oldHorizontalScrollPosition:Float = this._horizontalScrollPosition;
		var oldVerticalScrollPosition:Float = this._verticalScrollPosition;
		if (this._horizontalScrollPosition < this._minHorizontalScrollPosition)
		{
			this._horizontalScrollPosition = this._minHorizontalScrollPosition;
		}
		else if (this._horizontalScrollPosition > this._maxHorizontalScrollPosition)
		{
			this._horizontalScrollPosition = this._maxHorizontalScrollPosition;
		}
		if (this._verticalScrollPosition < this._minVerticalScrollPosition)
		{
			this._verticalScrollPosition = this._minVerticalScrollPosition;
		}
		else if (this._verticalScrollPosition > this._maxVerticalScrollPosition)
		{
			this._verticalScrollPosition = this._maxVerticalScrollPosition;
		}
		if (oldHorizontalScrollPosition != this._horizontalScrollPosition ||
			oldVerticalScrollPosition != this._verticalScrollPosition)
		{
			this.dispatchEventWith(Event.SCROLL);
		}
		this.completeScroll();
	}
	
	/**
	 * @private
	 */
	override function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		//using priority here is a hack so that objects deeper in the
		//display list have a chance to cancel the event first.
		var priority:Int = -getDisplayObjectDepthFromStage(this);
		this.stage.starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler, false, priority, true);
		this.stage.starling.nativeStage.addEventListener("gestureDirectionalTap", stage_gestureDirectionalTapHandler, false, priority, true);
	}
	
	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		super.focusOutHandler(event);
		this.stage.starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler);
		this.stage.starling.nativeStage.removeEventListener("gestureDirectionalTap", stage_gestureDirectionalTapHandler);
	}
	
	/**
	 * @private
	 */
	private function nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			return;
		}
		var newHorizontalScrollPosition:Float = this._horizontalScrollPosition;
		var newVerticalScrollPosition:Float = this._verticalScrollPosition;
		if (event.keyCode == Keyboard.HOME)
		{
			newVerticalScrollPosition = this._minVerticalScrollPosition;
		}
		else if (event.keyCode == Keyboard.END)
		{
			newVerticalScrollPosition = this._maxVerticalScrollPosition;
		}
		else if (event.keyCode == Keyboard.PAGE_UP)
		{
			newVerticalScrollPosition = Math.max(this._minVerticalScrollPosition, this._verticalScrollPosition - this.viewPort.visibleHeight);
		}
		else if (event.keyCode == Keyboard.PAGE_DOWN)
		{
			newVerticalScrollPosition = Math.min(this._maxVerticalScrollPosition, this._verticalScrollPosition + this.viewPort.visibleHeight);
		}
		else if (event.keyCode == Keyboard.UP)
		{
			newVerticalScrollPosition = Math.max(this._minVerticalScrollPosition, this._verticalScrollPosition - this.verticalScrollStep);
		}
		else if (event.keyCode == Keyboard.DOWN)
		{
			newVerticalScrollPosition = Math.min(this._maxVerticalScrollPosition, this._verticalScrollPosition + this.verticalScrollStep);
		}
		else if (event.keyCode == Keyboard.LEFT)
		{
			newHorizontalScrollPosition = Math.max(this._minHorizontalScrollPosition, this._horizontalScrollPosition - this.horizontalScrollStep);
		}
		else if (event.keyCode == Keyboard.RIGHT)
		{
			newHorizontalScrollPosition = Math.min(this._maxHorizontalScrollPosition, this._horizontalScrollPosition + this.horizontalScrollStep);
		}
		if (this._horizontalScrollPosition != newHorizontalScrollPosition &&
			this._horizontalScrollPolicy != ScrollPolicy.OFF)
		{
			event.preventDefault();
			this.horizontalScrollPosition = newHorizontalScrollPosition;
		}
		if (this._verticalScrollPosition != newVerticalScrollPosition &&
			this._verticalScrollPolicy != ScrollPolicy.OFF)
		{
			event.preventDefault();
			this.verticalScrollPosition = newVerticalScrollPosition;
		}
	}
	
	/**
	 * @private
	 */
	private function stage_gestureDirectionalTapHandler(event:TransformGestureEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			return;
		}
		var newHorizontalScrollPosition:Float = this._horizontalScrollPosition;
		var newVerticalScrollPosition:Float = this._verticalScrollPosition;
		if (event.offsetY < 0)
		{
			newVerticalScrollPosition = Math.max(this._minVerticalScrollPosition, this._verticalScrollPosition - this.verticalScrollStep);
		}
		else if (event.offsetY > 0)
		{
			newVerticalScrollPosition = Math.min(this._maxVerticalScrollPosition, this._verticalScrollPosition + this.verticalScrollStep);
		}
		else if (event.offsetX < 0)
		{
			newHorizontalScrollPosition = Math.max(this._maxHorizontalScrollPosition, this._horizontalScrollPosition - this.horizontalScrollStep);
		}
		else if (event.offsetX > 0)
		{
			newHorizontalScrollPosition = Math.min(this._maxHorizontalScrollPosition, this._horizontalScrollPosition + this.horizontalScrollStep);
		}
		if (this._horizontalScrollPosition != newHorizontalScrollPosition)
		{
			event.stopImmediatePropagation();
			//event.preventDefault();
			this.horizontalScrollPosition = newHorizontalScrollPosition;
		}
		if (this._verticalScrollPosition != newVerticalScrollPosition)
		{
			event.stopImmediatePropagation();
			//event.preventDefault();
			this.verticalScrollPosition = newVerticalScrollPosition;
		}
	}
	
}