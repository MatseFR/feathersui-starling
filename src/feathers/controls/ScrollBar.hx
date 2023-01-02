/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IFocusDisplayObject;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.events.FeathersEventType;
import feathers.layout.Direction;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.utils.Timer;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Select a value between a minimum and a maximum by dragging a thumb over
 * a physical range or by using step buttons. This is a desktop-centric
 * scroll bar with many skinnable parts. For mobile, the
 * <code>SimpleScrollBar</code> is probably a better choice as it provides
 * only the thumb to indicate position without all the extra chrome.
 *
 * <p>The following example updates a list to use scroll bars:</p>
 *
 * <listing version="3.0">
 * list.horizontalScrollBarFactory = function():IScrollBar
 * {
 *     return new ScrollBar();
 * };
 * list.verticalScrollBarFactory = function():IScrollBar
 * {
 *     return new ScrollBar();
 * };</listing>
 *
 * @see ../../../help/scroll-bar.html How to use the Feathers ScrollBar component
 * @see feathers.controls.SimpleScrollBar
 *
 * @productversion Feathers 1.0.0
 */
class ScrollBar extends FeathersControl implements IDirectionalScrollBar
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_THUMB_FACTORY:String = "thumbFactory";
	
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY:String = "minimumTrackFactory";
	
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY:String = "maximumTrackFactory";
	
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY:String = "decrementButtonFactory";
	
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY:String = "incrementButtonFactory";
	
	/**
	 * The default value added to the <code>styleNameList</code> of the minimum
	 * track.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK:String = "feathers-scroll-bar-minimum-track";
	
	/**
	 * The default value added to the <code>styleNameList</code> of the maximum
	 * track.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK:String = "feathers-scroll-bar-maximum-track";
	
	/**
	 * The default value added to the <code>styleNameList</code> of the thumb.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-scroll-bar-thumb";
	
	/**
	 * The default value added to the <code>styleNameList</code> of the decrement
	 * button.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON:String = "feathers-scroll-bar-decrement-button";
	
	/**
	 * The default value added to the <code>styleNameList</code> of the increment
	 * button.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON:String = "feathers-scroll-bar-increment-button";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>ScrollBar</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * @private
	 */
	private static function defaultThumbFactory():BasicButton
	{
		return new Button();
	}
	
	/**
	 * @private
	 */
	private static function defaultMinimumTrackFactory():BasicButton
	{
		return new Button();
	}
	
	/**
	 * @private
	 */
	private static function defaultMaximumTrackFactory():BasicButton
	{
		return new Button();
	}
	
	/**
	 * @private
	 */
	private static function defaultDecrementButtonFactory():BasicButton
	{
		return new Button();
	}
	
	/**
	 * @private
	 */
	private static function defaultIncrementButtonFactory():BasicButton
	{
		return new Button();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the minimum
	 * track. This variable is <code>protected</code> so that sub-classes
	 * can customize the minimum track style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK</code>.
	 *
	 * <p>To customize the minimum track style name without subclassing, see
	 * <code>customMinimumTrackStyleName</code>.</p>
	 *
	 * @see #style:customMinimumTrackStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var minimumTrackStyleName:String = DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK;
	
	/**
	 * The value added to the <code>styleNameList</code> of the maximum
	 * track. This variable is <code>protected</code> so that sub-classes
	 * can customize the maximum track style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK</code>.
	 *
	 * <p>To customize the maximum track style name without subclassing, see
	 * <code>customMaximumTrackStyleName</code>.</p>
	 *
	 * @see #style:customMaximumTrackStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var maximumTrackStyleName:String = DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK;
	
	/**
	 * The value added to the <code>styleNameList</code> of the thumb. This
	 * variable is <code>protected</code> so that sub-classes can customize
	 * the thumb style name in their constructors instead of using the
	 * default style name defined by <code>DEFAULT_CHILD_STYLE_NAME_THUMB</code>.
	 *
	 * <p>To customize the thumb style name without subclassing, see
	 * <code>customThumbStyleName</code>.</p>
	 *
	 * @see #style:customThumbStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var thumbStyleName:String = DEFAULT_CHILD_STYLE_NAME_THUMB;
	
	/**
	 * The value added to the <code>styleNameList</code> of the decrement
	 * button. This variable is <code>protected</code> so that sub-classes
	 * can customize the decrement button style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON</code>.
	 *
	 * <p>To customize the decrement button style name without subclassing,
	 * see <code>customDecrementButtonStyleName</code>.</p>
	 *
	 * @see #style:customDecrementButtonStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var decrementButtonStyleName:String = DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON;
	
	/**
	 * The value added to the <code>styleNameList</code> of the increment
	 * button. This variable is <code>protected</code> so that sub-classes
	 * can customize the increment button style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON</code>.
	 *
	 * <p>To customize the increment button style name without subclassing,
	 * see <code>customIncrementButtonName</code>.</p>
	 *
	 * @see #style:customIncrementButtonStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var incrementButtonStyleName:String = DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON;
	
	/**
	 * @private
	 */
	private var thumbOriginalWidth:Float = Math.NaN;
	
	/**
	 * @private
	 */
	private var thumbOriginalHeight:Float = Math.NaN;
	
	/**
	 * @private
	 */
	private var minimumTrackOriginalWidth:Float = Math.NaN;
	
	/**
	 * @private
	 */
	private var minimumTrackOriginalHeight:Float = Math.NaN;
	
	/**
	 * @private
	 */
	private var maximumTrackOriginalWidth:Float = Math.NaN;
	
	/**
	 * @private
	 */
	private var maximumTrackOriginalHeight:Float = Math.NaN;
	
	/**
	 * The scroll bar's decrement button sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #decrementButtonFactory
	 * @see #createDecrementButton()
	 */
	private var decrementButton:BasicButton;
	
	/**
	 * The scroll bar's increment button sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #incrementButtonFactory
	 * @see #createIncrementButton()
	 */
	private var incrementButton:BasicButton;
	
	/**
	 * The scroll bar's thumb sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #thumbFactory
	 * @see #createThumb()
	 */
	private var thumb:DisplayObject;
	
	/**
	 * The scroll bar's minimum track sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #minimumTrackFactory
	 * @see #createMinimumTrack()
	 */
	private var minimumTrack:DisplayObject;
	
	/**
	 * The scroll bar's maximum track sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #maximumTrackFactory
	 * @see #createMaximumTrack()
	 */
	private var maximumTrack:DisplayObject;
	
	/**
	 * @private
	 */
	private var _minimumTrackSkinExplicitWidth:Float;
	
	/**
	 * @private
	 */
	private var _minimumTrackSkinExplicitHeight:Float;
	
	/**
	 * @private
	 */
	private var _minimumTrackSkinExplicitMinWidth:Float;
	
	/**
	 * @private
	 */
	private var _minimumTrackSkinExplicitMinHeight:Float;
	
	/**
	 * @private
	 */
	private var _maximumTrackSkinExplicitWidth:Float;
	
	/**
	 * @private
	 */
	private var _maximumTrackSkinExplicitHeight:Float;
	
	/**
	 * @private
	 */
	private var _maximumTrackSkinExplicitMinWidth:Float;
	
	/**
	 * @private
	 */
	private var _maximumTrackSkinExplicitMinHeight:Float;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return ScrollBar.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	public var direction(get, set):String;
	private var _direction:String = Direction.HORIZONTAL;
	private function get_direction():String { return this._direction; }
	private function set_direction(value:String):String
	{
		if (this.processStyleRestriction(this.set_direction))
		{
			return value;
		}
		if (this._direction == value)
		{
			return value;
		}
		this._direction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.invalidate(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		this.invalidate(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		this.invalidate(INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY);
		this.invalidate(INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY);
		this.invalidate(INVALIDATION_FLAG_THUMB_FACTORY);
		return this._direction;
	}
	
	/**
	 * @private
	 */
	public var fixedThumbSize(get, set):Bool;
	private var _fixedThumbSize:Bool = false;
	private function get_fixedThumbSize():Bool { return this._fixedThumbSize; }
	private function set_fixedThumbSize(value:Bool):Bool
	{
		if (this.processStyleRestriction(this.set_fixedThumbSize))
		{
			return value;
		}
		if (this._fixedThumbSize == value)
		{
			return value;
		}
		this._fixedThumbSize = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._fixedThumbSize;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default 0
	 *
	 * @see #minimum
	 * @see #maximum
	 * @see #step
	 * @see #page
	 * @see #event:change
	 */
	public var value(get, set):Float;
	private var _value:Float = 0;
	private function get_value():Float { return this._value; }
	private function set_value(newValue:Float):Float
	{
		newValue = MathUtils.clamp(newValue, this._minimum, this._maximum);
		if (this._value == newValue)
		{
			return newValue;
		}
		this._value = newValue;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		if (this.liveDragging || !this.isDragging)
		{
			this.dispatchEventWith(Event.CHANGE);
		}
		return this._value;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #maximum
	 */
	public var minimum(get, set):Float;
	private var _minimum:Float = 0;
	private function get_minimum():Float { return this._minimum; }
	private function set_minimum(value:Float):Float
	{
		if (this._minimum == value)
		{
			return value;
		}
		this._minimum = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._minimum;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #minimum
	 */
	public var maximum(get, set):Float;
	private var _maximum:Float = 0;
	private function get_maximum():Float { return this._maximum; }
	private function set_maximum(value:Float):Float
	{
		if (this._maximum == value)
		{
			return value;
		}
		this._maximum = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._maximum;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #page
	 */
	public var step(get, set):Float;
	private var _step:Float = 0;
	private function get_step():Float { return this._step; }
	private function set_step(value:Float):Float
	{
		return this._step = value;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #step
	 */
	public var page(get, set):Float;
	private var _page:Float = 0;
	private function get_page():Float { return this._page; }
	private function set_page(value:Float):Float
	{
		if (this._page == value)
		{
			return value;
		}
		this._page = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._page;
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
		if (this.processStyleRestriction(this.set_paddingTop))
		{
			return value;
		}
		if (this._paddingTop == value)
		{
			return value;
		}
		this._paddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingTop;
	}
	
	/**
	 * @private
	 */
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight():Float { return this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if (this.processStyleRestriction(this.set_paddingRight))
		{
			return value;
		}
		if (this._paddingRight == value)
		{
			return value;
		}
		this._paddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
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
		if (this.processStyleRestriction(this.set_paddingBottom))
		{
			return value;
		}
		if (this._paddingBottom == value)
		{
			return value;
		}
		this._paddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
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
		if (this.processStyleRestriction(this.set_paddingLeft))
		{
			return value;
		}
		if (this._paddingLeft == value)
		{
			return value;
		}
		this._paddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingLeft;
	}
	
	/**
	 * @private
	 */
	private var currentRepeatAction:Void->Void;

	/**
	 * @private
	 */
	private var _repeatTimer:Timer;
	
	/**
	 * The time, in seconds, before actions are repeated. The first repeat
	 * happens after a delay that is five times longer than the following
	 * repeats.
	 *
	 * <p>In the following example, the repeat delay is changed to 500 milliseconds:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.repeatDelay = 0.5;</listing>
	 *
	 * @default 0.05
	 */
	public var repeatDelay(get, set):Float;
	private var _repeatDelay:Float = 0.05;
	private function get_repeatDelay():Float { return this._repeatDelay; }
	private function set_repeatDelay(value:Float):Float
	{
		if (this._repeatDelay == value)
		{
			return value;
		}
		this._repeatDelay = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._repeatDelay;
	}
	
	/**
	 * @private
	 */
	private var isDragging:Bool = false;
	
	/**
	 * Determines if the scroll bar dispatches the <code>Event.CHANGE</code>
	 * event every time the thumb moves, or only once it stops moving.
	 *
	 * <p>In the following example, live dragging is disabled:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.liveDragging = false;</listing>
	 *
	 * @default true
	 */
	public var liveDragging:Bool = true;
	
	/**
	 * @private
	 */
	public var trackLayoutMode(get, set):String;
	private var _trackLayoutMode:String = TrackLayoutMode.SINGLE;
	private function get_trackLayoutMode():String { return this._trackLayoutMode; }
	private function set_trackLayoutMode(value:String):String
	{
		if (value == "minMax")
		{
			value = TrackLayoutMode.SPLIT;
		}
		if (this.processStyleRestriction(this.set_trackLayoutMode))
		{
			return value;
		}
		if (this._trackLayoutMode == value)
		{
			return value;
		}
		this._trackLayoutMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._trackLayoutMode;
	}
	
	/**
	 * A function used to generate the scroll bar's minimum track
	 * sub-component. The minimum track must be an instance of
	 * <code>BasicButton</code>. This factory can be used to change
	 * properties on the minimum track when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the
	 * minimum track.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom minimum track factory is passed
	 * to the scroll bar:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.minimumTrackFactory = function():BasicButton
	 * {
	 *     var track:BasicButton = new BasicButton();
	 *     track.defaultSkin = new Image( upTexture );
	 *     track.downSkin = new Image( downTexture );
	 *     return track;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var minimumTrackFactory(get, set):Void->BasicButton;
	private var _minimumTrackFactory:Void->BasicButton;
	private function get_minimumTrackFactory():Void->BasicButton { return this._minimumTrackFactory; }
	private function set_minimumTrackFactory(value:Void->BasicButton):Void->BasicButton
	{
		if (this._minimumTrackFactory == value)
		{
			return value;
		}
		this._minimumTrackFactory = value;
		this.invalidate(INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY);
		return this._minimumTrackFactory;
	}
	
	/**
	 * @private
	 */
	public var customMinimumTrackStyleName(get, set):String;
	private var _customMinimumTrackStyleName:String;
	private function get_customMinimumTrackStyleName():String { return this._customMinimumTrackStyleName; }
	private function set_customMinimumTrackStyleName(value:String):String
	{
		if (this.processStyleRestriction(this.set_customMinimumTrackStyleName))
		{
			return value;
		}
		if (this._customMinimumTrackStyleName == value)
		{
			return value;
		}
		this._customMinimumTrackStyleName = value;
		this.invalidate(INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY);
		return this._customMinimumTrackStyleName;
	}
	
	/**
	 * An object that stores properties for the scroll bar's "minimum"
	 * track, and the properties will be passed down to the "minimum" track when
	 * the scroll bar validates. For a list of available properties, refer to
	 * <a href="Button.html"><code>feathers.controls.BasicButton</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>minimumTrackFactory</code> function
	 * instead of using <code>minimumTrackProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the scroll bar's minimum track properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.minimumTrackProperties.defaultSkin = new Image( upTexture );
	 * scrollBar.minimumTrackProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #minimumTrackFactory
	 * @see feathers.controls.BasicButton
	 */
	public var minimumTrackProperties(get, set):Dynamic;
	private var _minimumTrackProperties:PropertyProxy;
	private function get_minimumTrackProperties():Dynamic
	{
		if (this._minimumTrackProperties == null)
		{
			this._minimumTrackProperties = new PropertyProxy(minimumTrackProperties_onChange);
		}
		return this._minimumTrackProperties;
	}
	
	private function set_minimumTrackProperties(value:Dynamic):Dynamic
	{
		if (this._minimumTrackProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxy))
		{
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			//value = newValue;
			value = PropertyProxy.fromObject(value);
		}
		if (this._minimumTrackProperties != null)
		{
			this._minimumTrackProperties.removeOnChangeCallback(minimumTrackProperties_onChange);
			this._minimumTrackProperties.dispose();
		}
		this._minimumTrackProperties = cast value;
		if (this._minimumTrackProperties != null)
		{
			this._minimumTrackProperties.addOnChangeCallback(minimumTrackProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._minimumTrackProperties;
	}
	
	/**
	 * A function used to generate the scroll bar's maximum track
	 * sub-component. The maximum track must be an instance of
	 * <code>BasicButton</code>. This factory can be used to change
	 * properties on the maximum track when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the
	 * maximum track.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom maximum track factory is passed
	 * to the scroll bar:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.maximumTrackFactory = function():BasicButton
	 * {
	 *     var track:BasicButton = new BasicButton();
	 *     track.defaultSkin = new Image( upTexture );
	 *     track.downSkin = new Image( downTexture );
	 *     return track;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var maximumTrackFactory(get, set):Void->BasicButton;
	private var _maximumTrackFactory:Void->BasicButton;
	private function get_maximumTrackFactory():Void->BasicButton { return this._maximumTrackFactory; }
	private function set_maximumTrackFactory(value:Void->BasicButton):Void->BasicButton
	{
		if (this._maximumTrackFactory == value)
		{
			return value;
		}
		this._maximumTrackFactory = value;
		this.invalidate(INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY);
		return this._maximumTrackFactory;
	}
	
	/**
	 * @private
	 */
	public var customMaximumTrackStyleName(get, set):String;
	private var _customMaximumTrackStyleName:String;
	private function get_customMaximumTrackStyleName():String { return this._customMaximumTrackStyleName; }
	private function set_customMaximumTrackStyleName(value:String):String
	{
		if (this.processStyleRestriction(this.set_customMaximumTrackStyleName))
		{
			return value;
		}
		if (this._customMaximumTrackStyleName == value)
		{
			return value;
		}
		this._customMaximumTrackStyleName = value;
		this.invalidate(INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY);
		return this._customMaximumTrackStyleName;
	}
	
	/**
	 * An object that stores properties for the scroll bar's "maximum"
	 * track, and the properties will be passed down to the "maximum" track when
	 * the scroll bar validates. For a list of available properties, refer to
	 * <a href="Button.html"><code>feathers.controls.BasicButton</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>maximumTrackFactory</code> function
	 * instead of using <code>maximumTrackProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the scroll bar's maximum track properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.maximumTrackProperties.defaultSkin = new Image( upTexture );
	 * scrollBar.maximumTrackProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #maximumTrackFactory
	 * @see feathers.controls.BasicButton
	 */
	public var maximumTrackProperties(get, set):Dynamic;
	private var _maximumTrackProperties:PropertyProxy;
	private function get_maximumTrackProperties():Dynamic
	{
		if (this._maximumTrackProperties == null)
		{
			this._maximumTrackProperties = new PropertyProxy(maximumTrackProperties_onChange);
		}
		return this._maximumTrackProperties;
	}
	
	private function set_maximumTrackProperties(value:Dynamic):Dynamic
	{
		if (this._maximumTrackProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if(!Std.isOfType(value, PropertyProxy))
		{
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			//value = newValue;
			value = PropertyProxy.fromObject(value);
		}
		if (this._maximumTrackProperties != null)
		{
			this._maximumTrackProperties.removeOnChangeCallback(maximumTrackProperties_onChange);
			this._maximumTrackProperties.dispose();
		}
		this._maximumTrackProperties = cast value;
		if (this._maximumTrackProperties != null)
		{
			this._maximumTrackProperties.addOnChangeCallback(maximumTrackProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._maximumTrackProperties;
	}
	
	/**
	 * A function used to generate the scroll bar's thumb sub-component.
	 * The thumb must be an instance of <code>Button</code>. This factory
	 * can be used to change properties on the thumb when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to set skins and other
	 * styles on the thumb.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom thumb factory is passed
	 * to the scroll bar:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.thumbFactory = function():BasicButton
	 * {
	 *     var thumb:BasicButton = new BasicButton();
	 *     thumb.defaultSkin = new Image( upTexture );
	 *     thumb.downSkin = new Image( downTexture );
	 *     return thumb;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var thumbFactory(get, set):Void->BasicButton;
	private var _thumbFactory:Void->BasicButton;
	private function get_thumbFactory():Void->BasicButton { return this._thumbFactory; }
	private function set_thumbFactory(value:Void->BasicButton):Void->BasicButton
	{
		if (this._thumbFactory == value)
		{
			return value;
		}
		this._thumbFactory = value;
		this.invalidate(INVALIDATION_FLAG_THUMB_FACTORY);
		return this._thumbFactory;
	}
	
	/**
	 * @private
	 */
	public var customThumbStyleName(get, set):String;
	private var _customThumbStyleName:String;
	private function get_customThumbStyleName():String { return this._customThumbStyleName; }
	private function set_customThumbStyleName(value:String):String
	{
		if (this.processStyleRestriction(this.set_customThumbStyleName))
		{
			return value;
		}
		if (this._customThumbStyleName == value)
		{
			return value;
		}
		this._customThumbStyleName = value;
		this.invalidate(INVALIDATION_FLAG_THUMB_FACTORY);
		return this._customThumbStyleName;
	}
	
	/**
	 * An object that stores properties for the scroll bar's thumb, and the
	 * properties will be passed down to the thumb when the scroll bar
	 * validates. For a list of available properties, refer to
	 * <a href="Button.html"><code>feathers.controls.BasicButton</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>thumbFactory</code> function instead
	 * of using <code>thumbProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the scroll bar's thumb properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.thumbProperties.defaultSkin = new Image( upTexture );
	 * scrollBar.thumbProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #thumbFactory
	 * @see feathers.controls.BasicButton
	 */
	public var thumbProperties(get, set):Dynamic;
	private var _thumbProperties:PropertyProxy;
	private function get_thumbProperties():Dynamic
	{
		if (this._thumbProperties == null)
		{
			this._thumbProperties = new PropertyProxy(thumbProperties_onChange);
		}
		return this._thumbProperties;
	}
	
	private function set_thumbProperties(value:Dynamic):Dynamic
	{
		if (this._thumbProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxy))
		{
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			//value = newValue;
			value = PropertyProxy.fromObject(value);
		}
		if (this._thumbProperties != null)
		{
			this._thumbProperties.removeOnChangeCallback(thumbProperties_onChange);
			this._thumbProperties.dispose();
		}
		this._thumbProperties = cast value;
		if (this._thumbProperties != null)
		{
			this._thumbProperties.addOnChangeCallback(thumbProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._thumbProperties;
	}
	
	/**
	 * A function used to generate the scroll bar's decrement button
	 * sub-component. The decrement button must be an instance of
	 * <code>BasicButton</code>. This factory can be used to change
	 * properties on the decrement button when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the
	 * decrement button.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom decrement button factory is passed
	 * to the scroll bar:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.decrementButtonFactory = function():BasicButton
	 * {
	 *     var button:BasicButton = new BasicButton();
	 *     button.defaultSkin = new Image( upTexture );
	 *     button.downSkin = new Image( downTexture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var decrementButtonFactory(get, set):Void->BasicButton;
	private var _decrementButtonFactory:Void->BasicButton;
	private function get_decrementButtonFactory():Void->BasicButton { return this._decrementButtonFactory; }
	private function set_decrementButtonFactory(value:Void->BasicButton):Void->BasicButton
	{
		if (this._decrementButtonFactory == value)
		{
			return value;
		}
		this._decrementButtonFactory = value;
		this.invalidate(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		return this._decrementButtonFactory;
	}
	
	/**
	 * @private
	 */
	public var customDecrementButtonStyleName(get, set):String;
	private var _customDecrementButtonStyleName:String;
	private function get_customDecrementButtonStyleName():String { return this._customDecrementButtonStyleName; }
	private function set_customDecrementButtonStyleName(value:String):String
	{
		if (this.processStyleRestriction(this.set_customDecrementButtonStyleName))
		{
			return value;
		}
		if (this._customDecrementButtonStyleName == value)
		{
			return value;
		}
		this._customDecrementButtonStyleName = value;
		this.invalidate(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		return this._customDecrementButtonStyleName;
	}
	
	/**
	 * An object that stores properties for the scroll bar's decrement
	 * button, and the properties will be passed down to the decrement
	 * button when the scroll bar validates. For a list of available
	 * properties, refer to
	 * <a href="Button.html"><code>feathers.controls.BasicButton</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>decrementButtonFactory</code>
	 * function instead of using <code>decrementButtonProperties</code> will
	 * result in better performance.</p>
	 *
	 * <p>In the following example, the scroll bar's decrement button properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.decrementButtonProperties.defaultSkin = new Image( upTexture );
	 * scrollBar.decrementButtonProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #decrementButtonFactory
	 * @see feathers.controls.BasicButton
	 */
	public var decrementButtonProperties(get, set):Dynamic;
	private var _decrementButtonProperties:PropertyProxy;
	private function get_decrementButtonProperties():Dynamic
	{
		if (this._decrementButtonProperties == null)
		{
			this._decrementButtonProperties = new PropertyProxy(decrementButtonProperties_onChange);
		}
		return this._decrementButtonProperties;
	}
	
	private function set_decrementButtonProperties(value:Dynamic):Dynamic
	{
		if (this._decrementButtonProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if(!Std.isOfType(value, PropertyProxy))
		{
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			//value = newValue;
			value = PropertyProxy.fromObject(value);
		}
		if (this._decrementButtonProperties != null)
		{
			this._decrementButtonProperties.removeOnChangeCallback(decrementButtonProperties_onChange);
			this._decrementButtonProperties.dispose();
		}
		this._decrementButtonProperties = cast value;
		if (this._decrementButtonProperties != null)
		{
			this._decrementButtonProperties.addOnChangeCallback(decrementButtonProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._decrementButtonProperties;
	}
	
	/**
	 * A function used to generate the scroll bar's increment button
	 * sub-component. The increment button must be an instance of
	 * <code>BasicButton</code>. This factory can be used to change
	 * properties on the increment button when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the
	 * increment button.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom increment button factory is passed
	 * to the scroll bar:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.incrementButtonFactory = function():BasicButton
	 * {
	 *     var button:BasicButton = new BasicButton();
	 *     button.defaultSkin = new Image( upTexture );
	 *     button.downSkin = new Image( downTexture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var incrementButtonFactory(get, set):Void->BasicButton;
	private var _incrementButtonFactory:Void->BasicButton;
	private function get_incrementButtonFactory():Void->BasicButton { return this._incrementButtonFactory; }
	private function set_incrementButtonFactory(value:Void->BasicButton):Void->BasicButton
	{
		if (this._incrementButtonFactory == value)
		{
			return value;
		}
		this._incrementButtonFactory = value;
		this.invalidate(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		return this._incrementButtonFactory;
	}
	
	/**
	 * @private
	 */
	public var customIncrementButtonStyleName(get, set):String;
	private var _customIncrementButtonStyleName:String;
	private function get_customIncrementButtonStyleName():String { return this._customIncrementButtonStyleName; }
	private function set_customIncrementButtonStyleName(value:String):String
	{
		if (this.processStyleRestriction(this.set_customIncrementButtonStyleName))
		{
			return value;
		}
		if (this._customIncrementButtonStyleName == value)
		{
			return value;
		}
		this._customIncrementButtonStyleName = value;
		this.invalidate(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		return this._customIncrementButtonStyleName;
	}
	
	/**
	 * An object that stores properties for the scroll bar's increment
	 * button, and the properties will be passed down to the increment
	 * button when the scroll bar validates. For a list of available
	 * properties, refer to
	 * <a href="Button.html"><code>feathers.controls.BasicButton</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>incrementButtonFactory</code>
	 * function instead of using <code>incrementButtonProperties</code> will
	 * result in better performance.</p>
	 *
	 * <p>In the following example, the scroll bar's increment button properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.incrementButtonProperties.defaultSkin = new Image( upTexture );
	 * scrollBar.incrementButtonProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #incrementButtonFactory
	 * @see feathers.controls.BasicButton
	 */
	public var incrementButtonProperties(get, set):Dynamic;
	private var _incrementButtonProperties:PropertyProxy;
	private function get_incrementButtonProperties():Dynamic
	{
		if (this._incrementButtonProperties == null)
		{
			this._incrementButtonProperties = new PropertyProxy(incrementButtonProperties_onChange);
		}
		return this._incrementButtonProperties;
	}
	
	private function set_incrementButtonProperties(value:Dynamic):Dynamic
	{
		if (this._incrementButtonProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxy))
		{
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			//value = newValue;
			value = PropertyProxy.fromObject(value);
		}
		if (this._incrementButtonProperties != null)
		{
			this._incrementButtonProperties.removeOnChangeCallback(incrementButtonProperties_onChange);
			this._incrementButtonProperties.dispose();
		}
		this._incrementButtonProperties = cast value;
		if (this._incrementButtonProperties != null)
		{
			this._incrementButtonProperties.addOnChangeCallback(incrementButtonProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._incrementButtonProperties;
	}
	
	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _touchStartX:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _touchStartY:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _thumbStartX:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _thumbStartY:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _pageStartValue:Float;

	/**
	 * @private
	 */
	private var _touchValue:Float;
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		if (this._value < this._minimum)
		{
			this.value = this._minimum;
		}
		else if (this._value > this._maximum)
		{
			this.value = this._maximum;
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var thumbFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_THUMB_FACTORY);
		var minimumTrackFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY);
		var maximumTrackFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY);
		var incrementButtonFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		var decrementButtonFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		
		if (thumbFactoryInvalid)
		{
			this.createThumb();
		}
		if (minimumTrackFactoryInvalid)
		{
			this.createMinimumTrack();
		}
		if (maximumTrackFactoryInvalid || layoutInvalid)
		{
			this.createMaximumTrack();
		}
		if (decrementButtonFactoryInvalid)
		{
			this.createDecrementButton();
		}
		if (incrementButtonFactoryInvalid)
		{
			this.createIncrementButton();
		}
		
		if (thumbFactoryInvalid || stylesInvalid)
		{
			this.refreshThumbStyles();
		}
		if (minimumTrackFactoryInvalid || stylesInvalid)
		{
			this.refreshMinimumTrackStyles();
		}
		if ((maximumTrackFactoryInvalid || stylesInvalid || layoutInvalid) && this.maximumTrack != null)
		{
			this.refreshMaximumTrackStyles();
		}
		if (decrementButtonFactoryInvalid || stylesInvalid)
		{
			this.refreshDecrementButtonStyles();
		}
		if (incrementButtonFactoryInvalid || stylesInvalid)
		{
			this.refreshIncrementButtonStyles();
		}
		
		if (dataInvalid || stateInvalid || thumbFactoryInvalid ||
			minimumTrackFactoryInvalid || maximumTrackFactoryInvalid ||
			decrementButtonFactoryInvalid || incrementButtonFactoryInvalid)
		{
			this.refreshEnabled();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layout();
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
		if (this._direction == Direction.VERTICAL)
		{
			return this.measureVertical();
		}
		return this.measureHorizontal();
	}
	
	/**
	 * @private
	 */
	private function measureHorizontal():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		var isSingle:Bool = this._trackLayoutMode == TrackLayoutMode.SINGLE;
		var measureMinTrack:IMeasureDisplayObject;
		if (needsWidth)
		{
			this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
		}
		else if (isSingle)
		{
			this.minimumTrack.width = this._explicitWidth;
		}
		if (Std.isOfType(this.minimumTrack, IMeasureDisplayObject))
		{
			measureMinTrack = cast this.minimumTrack;
			if (needsMinWidth)
			{
				measureMinTrack.minWidth = this._minimumTrackSkinExplicitMinWidth;
			}
			else if (isSingle)
			{
				var minTrackMinWidth:Float = this._explicitMinWidth;
				if (this._minimumTrackSkinExplicitMinWidth > minTrackMinWidth)
				{
					minTrackMinWidth = this._minimumTrackSkinExplicitMinWidth;
				}
				measureMinTrack.minWidth = minTrackMinWidth;
			}
		}
		var measureMaxTrack:IMeasureDisplayObject;
		if (!isSingle)
		{
			if (needsWidth)
			{
				this.maximumTrack.width = this._maximumTrackSkinExplicitWidth;
			}
			if (Std.isOfType(this.maximumTrack, IMeasureDisplayObject))
			{
				measureMaxTrack = cast this.maximumTrack;
				if (needsMinWidth)
				{
					measureMaxTrack.minWidth = this._maximumTrackSkinExplicitMinWidth;
				}
			}
		}
		if (Std.isOfType(this.minimumTrack, IValidating))
		{
			cast(this.minimumTrack, IValidating).validate();
		}
		if (Std.isOfType(this.maximumTrack, IValidating))
		{
			cast(this.maximumTrack, IValidating).validate();
		}
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
		}
		if (Std.isOfType(this.decrementButton, IValidating))
		{
			cast(this.decrementButton, IValidating).validate();
		}
		if (Std.isOfType(this.incrementButton, IValidating))
		{
			cast(this.incrementButton, IValidating).validate();
		}
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsWidth)
		{
			newWidth = this.minimumTrack.width;
			if (!isSingle) //split
			{
				newWidth += this.maximumTrack.width;
			}
			newWidth += this.decrementButton.width + this.incrementButton.width;
		}
		if (needsHeight)
		{
			newHeight = this.minimumTrack.height;
			if (!isSingle && //split
				this.maximumTrack.height > newHeight)
			{
				newHeight = this.maximumTrack.height;
			}
			if (this.thumb.height > newHeight)
			{
				newHeight = this.thumb.height;
			}
			if (this.decrementButton.height > newHeight)
			{
				newHeight = this.decrementButton.height;
			}
			if (this.incrementButton.height > newHeight)
			{
				newHeight = this.incrementButton.height;
			}
		}
		if (needsMinWidth)
		{
			if (measureMinTrack != null)
			{
				newMinWidth = measureMinTrack.minWidth;
			}
			else
			{
				newMinWidth = this.minimumTrack.width;
			}
			if (!isSingle) //split
			{
				if (measureMaxTrack != null)
				{
					newMinWidth += measureMaxTrack.minWidth;
				}
				else if (this.maximumTrack.width > newMinWidth)
				{
					newMinWidth += this.maximumTrack.width;
				}
			}
			if (Std.isOfType(this.decrementButton, IMeasureDisplayObject))
			{
				newMinWidth += cast(this.decrementButton, IMeasureDisplayObject).minWidth;
			}
			else
			{
				newMinWidth += this.decrementButton.width;
			}
			if (Std.isOfType(this.incrementButton, IMeasureDisplayObject))
			{
				newMinWidth += cast(this.incrementButton, IMeasureDisplayObject).minWidth;
			}
			else
			{
				newMinWidth += this.incrementButton.width;
			}
		}
		if (needsMinHeight)
		{
			if (measureMinTrack != null)
			{
				newMinHeight = measureMinTrack.minHeight;
			}
			else
			{
				newMinHeight = this.minimumTrack.height;
			}
			if (!isSingle) //split
			{
				if (measureMaxTrack != null)
				{
					if (measureMaxTrack.minHeight > newMinHeight)
					{
						newMinHeight = measureMaxTrack.minHeight;
					}
				}
				else if (this.maximumTrack.height > newMinHeight)
				{
					newMinHeight = this.maximumTrack.height;
				}
			}
			if (Std.isOfType(this.thumb, IMeasureDisplayObject))
			{
				var measureThumb:IMeasureDisplayObject = cast this.thumb;
				if (measureThumb.minHeight > newMinHeight)
				{
					newMinHeight = measureThumb.minHeight;
				}
			}
			else if (this.thumb.height > newMinHeight)
			{
				newMinHeight = this.thumb.height;
			}
			if (Std.isOfType(this.decrementButton, IMeasureDisplayObject))
			{
				var measureDecrementButton:IMeasureDisplayObject = cast this.decrementButton;
				if (measureDecrementButton.minHeight > newMinHeight)
				{
					newMinHeight = measureDecrementButton.minHeight;
				}
			}
			else if (this.decrementButton.height > newMinHeight)
			{
				newMinHeight = this.decrementButton.height;
			}
			if (Std.isOfType(this.incrementButton, IMeasureDisplayObject))
			{
				var measureIncrementButton:IMeasureDisplayObject = cast this.incrementButton;
				if (measureIncrementButton.minHeight > newMinHeight)
				{
					newMinHeight = measureIncrementButton.minHeight;
				}
			}
			else if (this.incrementButton.height > newMinHeight)
			{
				newMinHeight = this.incrementButton.height;
			}
		}
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function measureVertical():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		var isSingle:Bool = this._trackLayoutMode == TrackLayoutMode.SINGLE;
		if (needsHeight)
		{
			this.minimumTrack.height = this._minimumTrackSkinExplicitHeight;
		}
		else if (isSingle)
		{
			this.minimumTrack.height = this._explicitHeight;
		}
		var measureMinTrack:IMeasureDisplayObject;
		if (Std.isOfType(this.minimumTrack, IMeasureDisplayObject))
		{
			measureMinTrack = cast this.minimumTrack;
			if (needsMinHeight)
			{
				measureMinTrack.minHeight = this._minimumTrackSkinExplicitMinHeight;
			}
			else if (isSingle)
			{
				var minTrackMinHeight:Float = this._explicitMinHeight;
				if (this._minimumTrackSkinExplicitMinHeight > minTrackMinHeight)
				{
					minTrackMinHeight = this._minimumTrackSkinExplicitMinHeight;
				}
				measureMinTrack.minHeight = minTrackMinHeight;
			}
		}
		var measureMaxTrack:IMeasureDisplayObject;
		if (!isSingle)
		{
			if (needsHeight)
			{
				this.maximumTrack.height = this._maximumTrackSkinExplicitHeight;
			}
			if (Std.isOfType(this.maximumTrack, IMeasureDisplayObject))
			{
				measureMaxTrack = cast this.maximumTrack;
				if (needsMinHeight)
				{
					measureMaxTrack.minHeight = this._maximumTrackSkinExplicitMinHeight;
				}
			}
		}
		if (Std.isOfType(this.minimumTrack, IValidating))
		{
			cast(this.minimumTrack, IValidating).validate();
		}
		if (Std.isOfType(this.maximumTrack, IValidating))
		{
			cast(this.maximumTrack, IValidating).validate();
		}
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
		}
		if (Std.isOfType(this.decrementButton, IValidating))
		{
			cast(this.decrementButton, IValidating).validate();
		}
		if (Std.isOfType(this.incrementButton, IValidating))
		{
			cast(this.incrementButton, IValidating).validate();
		}
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsWidth)
		{
			newWidth = this.minimumTrack.width;
			if (!isSingle && //split
				this.maximumTrack.width > newWidth)
			{
				newWidth = this.maximumTrack.width;
			}
			if (this.thumb.width > newWidth)
			{
				newWidth = this.thumb.width;
			}
			if (this.decrementButton.width > newWidth)
			{
				newWidth = this.decrementButton.width;
			}
			if (this.incrementButton.width > newWidth)
			{
				newWidth = this.incrementButton.width;
			}
		}
		if (needsHeight)
		{
			newHeight = this.minimumTrack.height;
			if (!isSingle) //split
			{
				newHeight += this.maximumTrack.height;
			}
			newHeight += this.decrementButton.height + this.incrementButton.height;
		}
		if (needsMinWidth)
		{
			if (measureMinTrack != null)
			{
				newMinWidth = measureMinTrack.minWidth;
			}
			else
			{
				newMinWidth = this.minimumTrack.width;
			}
			if (!isSingle) //split
			{
				if (measureMaxTrack != null)
				{
					if (measureMaxTrack.minWidth > newMinWidth)
					{
						newMinWidth = measureMaxTrack.minWidth;
					}
				}
				else if (this.maximumTrack.width > newMinWidth)
				{
					newMinWidth = this.maximumTrack.width;
				}
			}
			if (Std.isOfType(this.thumb, IMeasureDisplayObject))
			{
				var measureThumb:IMeasureDisplayObject = cast this.thumb;
				if (measureThumb.minWidth > newMinWidth)
				{
					newMinWidth = measureThumb.minWidth;
				}
			}
			else if (this.thumb.width > newMinWidth)
			{
				newMinWidth = this.thumb.width;
			}
			if (Std.isOfType(this.decrementButton, IMeasureDisplayObject))
			{
				var measureDecrementButton:IMeasureDisplayObject = cast this.decrementButton;
				if (measureDecrementButton.minWidth > newMinWidth)
				{
					newMinWidth = measureDecrementButton.minWidth;
				}
			}
			else if (this.decrementButton.width > newMinWidth)
			{
				newMinWidth = this.decrementButton.width;
			}
			if (Std.isOfType(this.incrementButton, IMeasureDisplayObject))
			{
				var measureIncrementButton:IMeasureDisplayObject = cast this.incrementButton;
				if (measureIncrementButton.minWidth > newMinWidth)
				{
					newMinWidth = measureIncrementButton.minWidth;
				}
			}
			else if (this.incrementButton.width > newMinWidth)
			{
				newMinWidth = this.incrementButton.width;
			}
		}
		if (needsMinHeight)
		{
			if (measureMinTrack != null)
			{
				newMinHeight = measureMinTrack.minHeight;
			}
			else
			{
				newMinHeight = this.minimumTrack.height;
			}
			if (!isSingle) //split
			{
				if (measureMaxTrack != null)
				{
					newMinHeight += measureMaxTrack.minHeight;
				}
				else
				{
					newMinHeight += this.maximumTrack.height;
				}
			}
			if (Std.isOfType(this.decrementButton, IMeasureDisplayObject))
			{
				newMinHeight += cast(this.decrementButton, IMeasureDisplayObject).minHeight;
			}
			else
			{
				newMinHeight += this.decrementButton.height;
			}
			if (Std.isOfType(this.incrementButton, IMeasureDisplayObject))
			{
				newMinHeight += cast(this.incrementButton, IMeasureDisplayObject).minHeight;
			}
			else
			{
				newMinHeight += this.incrementButton.height;
			}
		}
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Creates and adds the <code>thumb</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #thumb
	 * @see #thumbFactory
	 * @see #style:customThumbStyleName
	 */
	private function createThumb():Void
	{
		if (this.thumb != null)
		{
			this.thumb.removeFromParent(true);
			this.thumb = null;
		}
		
		var factory:Void->BasicButton = this._thumbFactory != null ? this._thumbFactory : defaultThumbFactory;
		var thumbStyleName:String = this._customThumbStyleName != null ? this._customThumbStyleName : this.thumbStyleName;
		var thumb:BasicButton = factory();
		thumb.styleNameList.add(thumbStyleName);
		thumb.keepDownStateOnRollOut = true;
		if (Std.isOfType(thumb, IFocusDisplayObject))
		{
			thumb.isFocusEnabled = false;
		}
		thumb.addEventListener(TouchEvent.TOUCH, thumb_touchHandler);
		this.addChild(thumb);
		this.thumb = thumb;
	}
	
	/**
	 * Creates and adds the <code>minimumTrack</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #minimumTrack
	 * @see #minimumTrackFactory
	 * @see #style:customMinimumTrackStyleName
	 */
	private function createMinimumTrack():Void
	{
		if (this.minimumTrack != null)
		{
			this.minimumTrack.removeFromParent(true);
			this.minimumTrack = null;
		}
		
		var factory:Void->BasicButton = this._minimumTrackFactory != null ? this._minimumTrackFactory : defaultMinimumTrackFactory;
		var minimumTrackStyleName:String = this._customMinimumTrackStyleName != null ? this._customMinimumTrackStyleName : this.minimumTrackStyleName;
		var minimumTrack:BasicButton = factory();
		minimumTrack.styleNameList.add(minimumTrackStyleName);
		minimumTrack.keepDownStateOnRollOut = true;
		if (Std.isOfType(minimumTrack, IFocusDisplayObject))
		{
			minimumTrack.isFocusEnabled = false;
		}
		minimumTrack.addEventListener(TouchEvent.TOUCH, track_touchHandler);
		this.addChildAt(minimumTrack, 0);
		this.minimumTrack = minimumTrack;
		
		if (Std.isOfType(this.minimumTrack, IFeathersControl))
		{
			cast(this.minimumTrack, IFeathersControl).initializeNow();
		}
		if (Std.isOfType(this.minimumTrack, IMeasureDisplayObject))
		{
			var measureMinTrack:IMeasureDisplayObject = cast this.minimumTrack;
			this._minimumTrackSkinExplicitWidth = measureMinTrack.explicitWidth;
			this._minimumTrackSkinExplicitHeight = measureMinTrack.explicitHeight;
			this._minimumTrackSkinExplicitMinWidth = measureMinTrack.explicitMinWidth;
			this._minimumTrackSkinExplicitMinHeight = measureMinTrack.explicitMinHeight;
		}
		else
		{
			//this is a regular display object, and we'll treat its
			//measurements as explicit when we auto-size the scroll bar
			this._minimumTrackSkinExplicitWidth = this.minimumTrack.width;
			this._minimumTrackSkinExplicitHeight = this.minimumTrack.height;
			this._minimumTrackSkinExplicitMinWidth = this._minimumTrackSkinExplicitWidth;
			this._minimumTrackSkinExplicitMinHeight = this._minimumTrackSkinExplicitHeight;
		}
	}
	
	/**
	 * Creates and adds the <code>maximumTrack</code> sub-component and
	 * removes the old instance, if one exists. If the maximum track is not
	 * needed, it will not be created.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #maximumTrack
	 * @see #maximumTrackFactory
	 * @see #style:customMaximumTrackStyleName
	 */
	private function createMaximumTrack():Void
	{
		if (this.maximumTrack != null)
		{
			this.maximumTrack.removeFromParent(true);
			this.maximumTrack = null;
		}
		if (this._trackLayoutMode != TrackLayoutMode.SPLIT)
		{
			return;
		}
		var factory:Void->BasicButton = this._maximumTrackFactory != null ? this._maximumTrackFactory : defaultMaximumTrackFactory;
		var maximumTrackStyleName:String = this._customMaximumTrackStyleName != null ? this._customMaximumTrackStyleName : this.maximumTrackStyleName;
		var maximumTrack:BasicButton = factory();
		maximumTrack.styleNameList.add(maximumTrackStyleName);
		maximumTrack.keepDownStateOnRollOut = true;
		if (Std.isOfType(maximumTrack, IFocusDisplayObject))
		{
			maximumTrack.isFocusEnabled = false;
		}
		maximumTrack.addEventListener(TouchEvent.TOUCH, track_touchHandler);
		this.addChildAt(maximumTrack, 1);
		this.maximumTrack = maximumTrack;

		if (Std.isOfType(this.maximumTrack, IFeathersControl))
		{
			cast(this.maximumTrack, IFeathersControl).initializeNow();
		}
		if (Std.isOfType(this.maximumTrack, IMeasureDisplayObject))
		{
			var measureMaxTrack:IMeasureDisplayObject = cast this.maximumTrack;
			this._maximumTrackSkinExplicitWidth = measureMaxTrack.explicitWidth;
			this._maximumTrackSkinExplicitHeight = measureMaxTrack.explicitHeight;
			this._maximumTrackSkinExplicitMinWidth = measureMaxTrack.explicitMinWidth;
			this._maximumTrackSkinExplicitMinHeight = measureMaxTrack.explicitMinHeight;
		}
		else
		{
			//this is a regular display object, and we'll treat its
			//measurements as explicit when we auto-size the scroll bar
			this._maximumTrackSkinExplicitWidth = this.maximumTrack.width;
			this._maximumTrackSkinExplicitHeight = this.maximumTrack.height;
			this._maximumTrackSkinExplicitMinWidth = this._maximumTrackSkinExplicitWidth;
			this._maximumTrackSkinExplicitMinHeight = this._maximumTrackSkinExplicitHeight;
		}
	}
	
	/**
	 * Creates and adds the <code>decrementButton</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #decrementButton
	 * @see #decrementButtonFactory
	 * @see #style:customDecremenButtonStyleName
	 */
	private function createDecrementButton():Void
	{
		if (this.decrementButton != null)
		{
			this.decrementButton.removeFromParent(true);
			this.decrementButton = null;
		}
		
		var factory:Void->BasicButton = this._decrementButtonFactory != null ? this._decrementButtonFactory : defaultDecrementButtonFactory;
		var decrementButtonStyleName:String = this._customDecrementButtonStyleName != null ? this._customDecrementButtonStyleName : this.decrementButtonStyleName;
		this.decrementButton = factory();
		this.decrementButton.styleNameList.add(decrementButtonStyleName);
		this.decrementButton.keepDownStateOnRollOut = true;
		if (Std.isOfType(this.decrementButton, IFocusDisplayObject))
		{
			this.decrementButton.isFocusEnabled = false;
		}
		this.decrementButton.addEventListener(TouchEvent.TOUCH, decrementButton_touchHandler);
		this.addChild(this.decrementButton);
	}
	
	/**
	 * Creates and adds the <code>incrementButton</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #incrementButton
	 * @see #incrementButtonFactory
	 * @see #style:customIncrementButtonStyleName
	 */
	private function createIncrementButton():Void
	{
		if (this.incrementButton != null)
		{
			this.incrementButton.removeFromParent(true);
			this.incrementButton = null;
		}
		
		var factory:Void->BasicButton = this._incrementButtonFactory != null ? this._incrementButtonFactory : defaultIncrementButtonFactory;
		var incrementButtonStyleName:String = this._customIncrementButtonStyleName != null ? this._customIncrementButtonStyleName : this.incrementButtonStyleName;
		this.incrementButton = factory();
		this.incrementButton.styleNameList.add(incrementButtonStyleName);
		this.incrementButton.keepDownStateOnRollOut = true;
		if (Std.isOfType(this.incrementButton, IFocusDisplayObject))
		{
			this.incrementButton.isFocusEnabled = false;
		}
		this.incrementButton.addEventListener(TouchEvent.TOUCH, incrementButton_touchHandler);
		this.addChild(this.incrementButton);
	}
	
	/**
	 * @private
	 */
	private function refreshThumbStyles():Void
	{
		for (propertyName in this._thumbProperties)
		{
			var propertyValue:Dynamic = this._thumbProperties[propertyName];
			//this.thumb[propertyName] = propertyValue;
			Reflect.setProperty(this.thumb, propertyName, propertyValue);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshMinimumTrackStyles():Void
	{
		for (propertyName in this._minimumTrackProperties)
		{
			var propertyValue:Dynamic = this._minimumTrackProperties[propertyName];
			//this.minimumTrack[propertyName] = propertyValue;
			Reflect.setProperty(this.minimumTrack, propertyName, propertyValue);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshMaximumTrackStyles():Void
	{
		if (this.maximumTrack == null)
		{
			return;
		}
		for (propertyName in this._maximumTrackProperties)
		{
			var propertyValue:Dynamic = this._maximumTrackProperties[propertyName];
			//this.maximumTrack[propertyName] = propertyValue;
			Reflect.setProperty(this.maximumTrack, propertyName, propertyValue);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshDecrementButtonStyles():Void
	{
		for (propertyName in this._decrementButtonProperties)
		{
			var propertyValue:Dynamic = this._decrementButtonProperties[propertyName];
			//this.decrementButton[propertyName] = propertyValue;
			Reflect.setProperty(this.decrementButton, propertyName, propertyValue);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshIncrementButtonStyles():Void
	{
		for (propertyName in this._incrementButtonProperties)
		{
			var propertyValue:Dynamic = this._incrementButtonProperties[propertyName];
			//this.incrementButton[propertyName] = propertyValue;
			Reflect.setProperty(this.incrementButton, propertyName, propertyValue);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		var isEnabled:Bool = this._isEnabled && this._maximum > this._minimum;
		if (Std.isOfType(this.thumb, IFeathersControl))
		{
			cast(this.thumb, IFeathersControl).isEnabled = isEnabled;
		}
		if (Std.isOfType(this.minimumTrack, IFeathersControl))
		{
			cast(this.minimumTrack, IFeathersControl).isEnabled = isEnabled;
		}
		if (Std.isOfType(this.maximumTrack, IFeathersControl))
		{
			cast(this.maximumTrack, IFeathersControl).isEnabled = isEnabled;
		}
		this.decrementButton.isEnabled = isEnabled;
		this.incrementButton.isEnabled = isEnabled;
	}
	
	/**
	 * @private
	 */
	private function layout():Void
	{
		this.layoutStepButtons();
		this.layoutThumb();
		
		if (this._trackLayoutMode == TrackLayoutMode.SPLIT)
		{
			this.layoutTrackWithMinMax();
		}
		else //single
		{
			this.layoutTrackWithSingle();
		}
	}
	
	/**
	 * @private
	 */
	private function layoutStepButtons():Void
	{
		if (this._direction == Direction.VERTICAL)
		{
			this.decrementButton.x = (this.actualWidth - this.decrementButton.width) / 2;
			this.decrementButton.y = 0;
			this.incrementButton.x = (this.actualWidth - this.incrementButton.width) / 2;
			this.incrementButton.y = this.actualHeight - this.incrementButton.height;
		}
		else
		{
			this.decrementButton.x = 0;
			this.decrementButton.y = (this.actualHeight - this.decrementButton.height) / 2;
			this.incrementButton.x = this.actualWidth - this.incrementButton.width;
			this.incrementButton.y = (this.actualHeight - this.incrementButton.height) / 2;
		}
		var showButtons:Bool = this._maximum != this._minimum;
		this.decrementButton.visible = showButtons;
		this.incrementButton.visible = showButtons;
	}
	
	/**
	 * @private
	 */
	private function layoutThumb():Void
	{
		var range:Float = this._maximum - this._minimum;
		this.thumb.visible = range > 0 && range < Math.POSITIVE_INFINITY && this._isEnabled;
		if (!this.thumb.visible)
		{
			return;
		}
		
		//this will auto-size the thumb, if needed
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
		}
		
		var contentWidth:Float = this.actualWidth - this._paddingLeft - this._paddingRight;
		var contentHeight:Float = this.actualHeight - this._paddingTop - this._paddingBottom;
		var adjustedPage:Float = this._page;
		if (this._page == 0)
		{
			adjustedPage = this._step;
		}
		if (adjustedPage > range)
		{
			adjustedPage = range;
		}
		if (this._direction == Direction.VERTICAL)
		{
			contentHeight -= (this.decrementButton.height + this.incrementButton.height);
			var thumbMinHeight:Float = this.thumbOriginalHeight;
			if (Std.isOfType(this.thumb, IMeasureDisplayObject))
			{
				thumbMinHeight = cast(this.thumb, IMeasureDisplayObject).minHeight;
			}
			this.thumb.width = this.thumbOriginalWidth;
			if (this._fixedThumbSize)
			{
				this.thumb.height = this.thumbOriginalHeight;
			}
			else
			{
				this.thumb.height = Math.max(thumbMinHeight, contentHeight * adjustedPage / range);
			}
			var trackScrollableHeight:Float = contentHeight - this.thumb.height;
			this.thumb.x = this._paddingLeft + (this.actualWidth - this._paddingLeft - this._paddingRight - this.thumb.width) / 2;
			this.thumb.y = this.decrementButton.height + this._paddingTop + Math.max(0, Math.min(trackScrollableHeight, trackScrollableHeight * (this._value - this._minimum) / range));
		}
		else //horizontal
		{
			contentWidth -= (this.decrementButton.width + this.decrementButton.width);
			var thumbMinWidth:Float = this.thumbOriginalWidth;
			if (Std.isOfType(this.thumb, IMeasureDisplayObject))
			{
				thumbMinWidth = cast(this.thumb, IMeasureDisplayObject).minWidth;
			}
			if (this._fixedThumbSize)
			{
				this.thumb.width = this.thumbOriginalWidth;
			}
			else
			{
				this.thumb.width = Math.max(thumbMinWidth, contentWidth * adjustedPage / range);
			}
			this.thumb.height = this.thumbOriginalHeight;
			var trackScrollableWidth:Float = contentWidth - this.thumb.width;
			this.thumb.x = this.decrementButton.width + this._paddingLeft + Math.max(0, Math.min(trackScrollableWidth, trackScrollableWidth * (this._value - this._minimum) / range));
			this.thumb.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.thumb.height) / 2;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutTrackWithMinMax():Void
	{
		var range:Float = this._maximum - this._minimum;
		this.minimumTrack.touchable = range > 0 && range < Math.POSITIVE_INFINITY;
		if (this.maximumTrack != null)
		{
			this.maximumTrack.touchable = range > 0 && range < Math.POSITIVE_INFINITY;
		}
		
		var showButtons:Bool = this._maximum != this._minimum;
		if (this._direction == Direction.VERTICAL)
		{
			this.minimumTrack.x = 0;
			if (showButtons)
			{
				this.minimumTrack.y = this.decrementButton.height;
			}
			else
			{
				this.minimumTrack.y = 0;
			}
			this.minimumTrack.width = this.actualWidth;
			this.minimumTrack.height = (this.thumb.y + this.thumb.height / 2) - this.minimumTrack.y;
			
			this.maximumTrack.x = 0;
			this.maximumTrack.y = this.minimumTrack.y + this.minimumTrack.height;
			this.maximumTrack.width = this.actualWidth;
			if (showButtons)
			{
				this.maximumTrack.height = this.actualHeight - this.incrementButton.height - this.maximumTrack.y;
			}
			else
			{
				this.maximumTrack.height = this.actualHeight - this.maximumTrack.y;
			}
		}
		else //horizontal
		{
			if (showButtons)
			{
				this.minimumTrack.x = this.decrementButton.width;
			}
			else
			{
				this.minimumTrack.x = 0;
			}
			this.minimumTrack.y = 0;
			this.minimumTrack.width = (this.thumb.x + this.thumb.width / 2) - this.minimumTrack.x;
			this.minimumTrack.height = this.actualHeight;
			
			this.maximumTrack.x = this.minimumTrack.x + this.minimumTrack.width;
			this.maximumTrack.y = 0;
			if (showButtons)
			{
				this.maximumTrack.width = this.actualWidth - this.incrementButton.width - this.maximumTrack.x;
			}
			else
			{
				this.maximumTrack.width = this.actualWidth - this.maximumTrack.x;
			}
			this.maximumTrack.height = this.actualHeight;
		}
		
		//final validation to avoid juggler next frame issues
		if (Std.isOfType(this.minimumTrack, IValidating))
		{
			cast(this.minimumTrack, IValidating).validate();
		}
		if (Std.isOfType(this.maximumTrack, IValidating))
		{
			cast(this.maximumTrack, IValidating).validate();
		}
	}
	
	/**
	 * @private
	 */
	private function layoutTrackWithSingle():Void
	{
		var range:Float = this._maximum - this._minimum;
		this.minimumTrack.touchable = range > 0 && range < Math.POSITIVE_INFINITY;
		
		var showButtons:Bool = this._maximum != this._minimum;
		if (this._direction == Direction.VERTICAL)
		{
			this.minimumTrack.x = 0;
			if (showButtons)
			{
				this.minimumTrack.y = this.decrementButton.height;
			}
			else
			{
				this.minimumTrack.y = 0;
			}
			this.minimumTrack.width = this.actualWidth;
			if (showButtons)
			{
				this.minimumTrack.height = this.actualHeight - this.minimumTrack.y - this.incrementButton.height;
			}
			else
			{
				this.minimumTrack.height = this.actualHeight - this.minimumTrack.y;
			}
		}
		else //horizontal
		{
			if (showButtons)
			{
				this.minimumTrack.x = this.decrementButton.width;
			}
			else
			{
				this.minimumTrack.x = 0;
			}
			this.minimumTrack.y = 0;
			if (showButtons)
			{
				this.minimumTrack.width = this.actualWidth - this.minimumTrack.x - this.incrementButton.width;
			}
			else
			{
				this.minimumTrack.width = this.actualWidth - this.minimumTrack.x;
			}
			this.minimumTrack.height = this.actualHeight;
		}
		
		//final validation to avoid juggler next frame issues
		if (Std.isOfType(this.minimumTrack, IValidating))
		{
			cast(this.minimumTrack, IValidating).validate();
		}
	}
	
	/**
	 * @private
	 */
	private function locationToValue(location:Point):Float
	{
		var percentage:Float = 0;
		if (this._direction == Direction.VERTICAL)
		{
			var trackScrollableHeight:Float = this.actualHeight - this.thumb.height - this.decrementButton.height - this.incrementButton.height - this._paddingTop - this._paddingBottom;
			if (trackScrollableHeight > 0)
			{
				var yOffset:Float = location.y - this._touchStartY - this._paddingTop;
				var yPosition:Float = Math.min(Math.max(0, this._thumbStartY + yOffset - this.decrementButton.height), trackScrollableHeight);
				percentage = yPosition / trackScrollableHeight;
			}
		}
		else //horizontal
		{
			var trackScrollableWidth:Float = this.actualWidth - this.thumb.width - this.decrementButton.width - this.incrementButton.width - this._paddingLeft - this._paddingRight;
			if (trackScrollableWidth > 0)
			{
				var xOffset:Float = location.x - this._touchStartX - this._paddingLeft;
				var xPosition:Float = Math.min(Math.max(0, this._thumbStartX + xOffset - this.decrementButton.width), trackScrollableWidth);
				percentage = xPosition / trackScrollableWidth;
			}
		}
		
		return this._minimum + percentage * (this._maximum - this._minimum);
	}
	
	/**
	 * @private
	 */
	private function decrement():Void
	{
		this.value -= this._step;
	}

	/**
	 * @private
	 */
	private function increment():Void
	{
		this.value += this._step;
	}
	
	/**
	 * @private
	 */
	private function adjustPage():Void
	{
		var range:Float = this._maximum - this._minimum;
		var adjustedPage:Float = this._page;
		if (this._page == 0)
		{
			adjustedPage = this._step;
		}
		if (adjustedPage > range)
		{
			adjustedPage = range;
		}
		var newValue:Float;
		if (this._touchValue < this._pageStartValue)
		{
			newValue = Math.max(this._touchValue, this._value - adjustedPage);
			if (this._step != 0 && newValue != this._maximum && newValue != this._minimum)
			{
				newValue = MathUtils.roundDownToNearest(newValue, this._step);
			}
			this.value = newValue;
		}
		else if(this._touchValue > this._pageStartValue)
		{
			newValue = Math.min(this._touchValue, this._value + adjustedPage);
			if(this._step != 0 && newValue != this._maximum && newValue != this._minimum)
			{
				newValue = MathUtils.roundUpToNearest(newValue, this._step);
			}
			this.value = newValue;
		}
	}
	
	/**
	 * @private
	 */
	private function startRepeatTimer(action:Void->Void):Void
	{
		this.currentRepeatAction = action;
		if (this._repeatDelay > 0)
		{
			if (this._repeatTimer == null)
			{
				this._repeatTimer = new Timer(this._repeatDelay * 1000);
				this._repeatTimer.addEventListener(TimerEvent.TIMER, repeatTimer_timerHandler);
			}
			else
			{
				this._repeatTimer.reset();
				this._repeatTimer.delay = this._repeatDelay * 1000;
			}
			this._repeatTimer.start();
		}
	}
	
	/**
	 * @private
	 */
	private function thumbProperties_onChange(proxy:PropertyProxy, name:Dynamic):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private function minimumTrackProperties_onChange(proxy:PropertyProxy, name:Dynamic):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private function maximumTrackProperties_onChange(proxy:PropertyProxy, name:Dynamic):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private function decrementButtonProperties_onChange(proxy:PropertyProxy, name:Dynamic):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private function incrementButtonProperties_onChange(proxy:PropertyProxy, name:Dynamic):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function removedFromStageHandler(event:Event):Void
	{
		this._touchPointID = -1;
		if (this._repeatTimer != null)
		{
			this._repeatTimer.stop();
		}
	}
	
	/**
	 * @private
	 */
	private function track_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var track:DisplayObject = cast event.currentTarget;
		var touch:Touch;
		var location:Point;
		if (this._touchPointID >= 0)
		{
			touch = event.getTouch(track, null, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			if (touch.phase == TouchPhase.MOVED)
			{
				location = touch.getLocation(this, Pool.getPoint());
				this._touchValue = this.locationToValue(location);
				Pool.putPoint(location);
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				this._touchPointID = -1;
				this._repeatTimer.stop();
				this.dispatchEventWith(FeathersEventType.END_INTERACTION);
			}
		}
		else
		{
			touch = event.getTouch(track, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this._touchPointID = touch.id;
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
			location = touch.getLocation(this, Pool.getPoint());
			this._touchStartX = location.x;
			this._touchStartY = location.y;
			this._thumbStartX = this._touchStartX;
			this._thumbStartY = this._touchStartY;
			this._touchValue = this.locationToValue(location);
			Pool.putPoint(location);
			this._pageStartValue = this._value;
			this.adjustPage();
			this.startRepeatTimer(this.adjustPage);
		}
	}
	
	/**
	 * @private
	 */
	private function thumb_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		var location:Point;
		if (this._touchPointID >= 0)
		{
			touch = event.getTouch(this.thumb, null, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			
			if (touch.phase == TouchPhase.MOVED)
			{
				location = touch.getLocation(this, Pool.getPoint());
				var newValue:Float = this.locationToValue(location);
				Pool.putPoint(location);
				if (this._step != 0 && newValue != this._maximum && newValue != this._minimum)
				{
					newValue = MathUtils.roundToNearest(newValue, this._step);
				}
				this.value = newValue;
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				this._touchPointID = -1;
				this.isDragging = false;
				if (!this.liveDragging)
				{
					this.dispatchEventWith(Event.CHANGE);
				}
				this.dispatchEventWith(FeathersEventType.END_INTERACTION);
			}
		}
		else
		{
			touch = event.getTouch(this.thumb, TouchPhase.BEGAN);
			if(touch == null)
			{
				return;
			}
			location = touch.getLocation(this, Pool.getPoint());
			this._touchPointID = touch.id;
			this._thumbStartX = this.thumb.x;
			this._thumbStartY = this.thumb.y;
			this._touchStartX = location.x;
			this._touchStartY = location.y;
			Pool.putPoint(location);
			this.isDragging = true;
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
		}
	}
	
	/**
	 * @private
	 */
	private function decrementButton_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		if (this._touchPointID >= 0)
		{
			touch = event.getTouch(this.decrementButton, TouchPhase.ENDED, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			this._touchPointID = -1;
			this._repeatTimer.stop();
			this.dispatchEventWith(FeathersEventType.END_INTERACTION);
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this.decrementButton, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this._touchPointID = touch.id;
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
			this.decrement();
			this.startRepeatTimer(this.decrement);
		}
	}
	
	/**
	 * @private
	 */
	private function incrementButton_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		if (this._touchPointID >= 0)
		{
			touch = event.getTouch(this.incrementButton, TouchPhase.ENDED, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			this._touchPointID = -1;
			this._repeatTimer.stop();
			this.dispatchEventWith(FeathersEventType.END_INTERACTION);
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this.incrementButton, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this._touchPointID = touch.id;
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
			this.increment();
			this.startRepeatTimer(this.increment);
		}
	}
	
	/**
	 * @private
	 */
	private function repeatTimer_timerHandler(event:TimerEvent):Void
	{
		if (this._repeatTimer.currentCount < 5)
		{
			return;
		}
		this.currentRepeatAction();
	}
	
}