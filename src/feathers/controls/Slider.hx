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
import feathers.events.ExclusiveTouch;
import feathers.events.FeathersEventType;
import feathers.layout.Direction;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import openfl.utils.Timer;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Select a value between a minimum and a maximum by dragging a thumb over
 * the bounds of a track. The slider's track is divided into two parts split
 * by the thumb.
 *
 * <p>The following example sets the slider's range and listens for when the
 * value changes:</p>
 *
 * <listing version="3.0">
 * var slider:Slider = new Slider();
 * slider.minimum = 0;
 * slider.maximum = 100;
 * slider.step = 1;
 * slider.page = 10;
 * slider.value = 12;
 * slider.addEventListener( Event.CHANGE, slider_changeHandler );
 * this.addChild( slider );</listing>
 *
 * @see ../../../help/slider.html How to use the Feathers Slider component
 *
 * @productversion Feathers 1.0.0
 */
class Slider extends FeathersControl implements IDirectionalScrollBar implements IFocusDisplayObject
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
	 * The default value added to the <code>styleNameList</code> of the
	 * minimum track.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK:String = "feathers-slider-minimum-track";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * maximum track.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK:String = "feathers-slider-maximum-track";

	/**
	 * The default value added to the <code>styleNameList</code> of the thumb.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-slider-thumb";

	/**
	 * The default <code>IStyleProvider</code> for all <code>Slider</code>
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
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.addEventListener(Event.REMOVED_FROM_STAGE, slider_removedFromStageHandler);
	}
	
	override public function dispose():Void 
	{
		if (this._maximumTrackProperties != null)
		{
			this._maximumTrackProperties.dispose();
			this._maximumTrackProperties = null;
		}
		if (this._minimumTrackProperties != null)
		{
			this._minimumTrackProperties.dispose();
			this._minimumTrackProperties = null;
		}
		if (this._thumbProperties != null)
		{
			this._thumbProperties.dispose();
			this._thumbProperties = null;
		}
		super.dispose();
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
	 * The thumb sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #thumbFactory
	 * @see #createThumb()
	 */
	private var thumb:DisplayObject;

	/**
	 * The minimum track sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #minimumTrackFactory
	 * @see #createMinimumTrack()
	 */
	private var minimumTrack:DisplayObject;

	/**
	 * The maximum track sub-component.
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
		return Slider.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	public var direction(get, set):String;
	private var _direction:String = Direction.HORIZONTAL;
	private function get_direction():String { return this._direction; }
	private function set_direction(value:String):String
	{
		if (this.processStyleRestriction("direction"))
		{
			return value;
		}
		if (this._direction == value)
		{
			return value;
		}
		this._direction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.invalidate(INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY);
		this.invalidate(INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY);
		this.invalidate(INVALIDATION_FLAG_THUMB_FACTORY);
		return this._direction;
	}
	
	/**
	 * The value of the slider, between the minimum and maximum.
	 *
	 * <p>In the following example, the value is changed to 12:</p>
	 *
	 * <listing version="3.0">
	 * slider.minimum = 0;
	 * slider.maximum = 100;
	 * slider.step = 1;
	 * slider.page = 10
	 * slider.value = 12;</listing>
	 *
	 * @default 0
	 *
	 * @see #minimum
	 * @see #maximum
	 * @see #step
	 * @see #page
	 */
	public var value(get, set):Float;
	private var _value:Float = 0;
	private function get_value():Float { return this._value; }
	private function set_value(newValue:Float):Float
	{
		if (this._step != 0 && newValue != this._maximum && newValue != this._minimum)
		{
			newValue = MathUtils.roundToNearest(newValue - this._minimum, this._step) + this._minimum;
		}
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
	 * The slider's value will not go lower than the minimum.
	 *
	 * <p>In the following example, the minimum is set to 0:</p>
	 *
	 * <listing version="3.0">
	 * slider.minimum = 0;
	 * slider.maximum = 100;
	 * slider.step = 1;
	 * slider.page = 10
	 * slider.value = 12;</listing>
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
	 * The slider's value will not go higher than the maximum. The maximum
	 * is zero (<code>0</code>), by default, and it should almost always be
	 * changed to something more appropriate.
	 *
	 * <p>In the following example, the maximum is set to 100:</p>
	 *
	 * <listing version="3.0">
	 * slider.minimum = 0;
	 * slider.maximum = 100;
	 * slider.step = 1;
	 * slider.page = 10
	 * slider.value = 12;</listing>
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
	 * As the slider's thumb is dragged, the value is snapped to a multiple
	 * of the step. Paging using the slider's track will use the <code>step</code>
	 * value if the <code>page</code> value is <code>NaN</code>. If the
	 * <code>step</code> is zero (<code>0</code>), paging with the track will not be possible.
	 *
	 * <p>In the following example, the step is changed to 1:</p>
	 *
	 * <listing version="3.0">
	 * slider.minimum = 0;
	 * slider.maximum = 100;
	 * slider.step = 1;
	 * slider.page = 10;
	 * slider.value = 10;</listing>
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
		if (this._step == value)
		{
			return value;
		}
		return this._step = value;
	}
	
	/**
	 * If the <code>trackInteractionMode</code> property is set to
	 * <code>TrackInteractionMode.BY_PAGE</code>, and the slider's
	 * track is touched, and the thumb is shown, the slider value will be
	 * incremented or decremented by the page value. If the
	 * <code>trackInteractionMode</code> property is set to
	 * <code>TrackInteractionMode.TO_VALUE</code>, this property will be
	 * ignored.
	 *
	 * <p>If this value is <code>NaN</code>, the <code>step</code> value
	 * will be used instead. If the <code>step</code> value is zero, paging
	 * with the track is not possible.</p>
	 *
	 * <p>In the following example, the page is changed to 10:</p>
	 *
	 * <listing version="3.0">
	 * slider.minimum = 0;
	 * slider.maximum = 100;
	 * slider.step = 1;
	 * slider.page = 10
	 * slider.value = 12;</listing>
	 *
	 * @default NaN
	 *
	 * @see #value
	 * @see #page
	 * @see #style:trackInteractionMode
	 */
	public var page(get, set):Float;
	private var _page:Float = Math.NaN;
	private function get_page():Float { return this._page; }
	private function set_page(value:Float):Float
	{
		if (this._page == value)
		{
			return value;
		}
		return this._page = value;
	}
	
	/**
	 * @private
	 */
	private var isDragging:Bool = false;
	
	/**
	 * Determines if the slider dispatches the <code>Event.CHANGE</code>
	 * event every time the thumb moves, or only once it stops moving.
	 *
	 * <p>In the following example, live dragging is disabled:</p>
	 *
	 * <listing version="3.0">
	 * slider.liveDragging = false;</listing>
	 *
	 * @default true
	 */
	public var liveDragging:Bool = true;
	
	/**
	 * @private
	 */
	public var showThumb(get, set):Bool;
	private var _showThumb:Bool = true;
	private function get_showThumb():Bool { return this._showThumb; }
	private function set_showThumb(value:Bool):Bool
	{
		if (this.processStyleRestriction("showThumb"))
		{
			return value;
		}
		if (this._showThumb == value)
		{
			return value;
		}
		this._showThumb = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._showThumb;
	}
	
	/**
	 * @private
	 */
	public var thumbOffset(get, set):Float;
	private var _thumbOffset:Float = 0;
	private function get_thumbOffset():Float { return this._thumbOffset; }
	private function set_thumbOffset(value:Float):Float
	{
		if (this.processStyleRestriction("thumbOffset"))
		{
			return value;
		}
		if (this._thumbOffset == value)
		{
			return value;
		}
		this._thumbOffset = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._thumbOffset;
	}
	
	/**
	 * @private
	 */
	public var minimumPadding(get, set):Float;
	private var _minimumPadding:Float = 0;
	private function get_minimumPadding():Float { return this._minimumPadding; }
	private function set_minimumPadding(value:Float):Float
	{
		if (this.processStyleRestriction("minimumPadding"))
		{
			return value;
		}
		if (this._minimumPadding == value)
		{
			return value;
		}
		this._minimumPadding = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._minimumPadding;
	}
	
	/**
	 * @private
	 */
	public var maximumPadding(get, set):Float;
	private var _maximumPadding:Float = 0;
	private function get_maximumPadding():Float { return this._maximumPadding; }
	private function set_maximumPadding(value:Float):Float
	{
		if (this.processStyleRestriction("maximumPadding"))
		{
			return value;
		}
		if (this._maximumPadding == value)
		{
			return value;
		}
		this._maximumPadding = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this.maximumPadding;
	}
	
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
		if (this.processStyleRestriction("trackLayoutMode"))
		{
			return value;
		}
		if (this._trackLayoutMode == value)
		{
			return value;
		}
		this._trackLayoutMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._trackLayoutMode;
	}
	
	/**
	 * @private
	 */
	public var trackScaleMode(get, set):String;
	private var _trackScaleMode:String = TrackScaleMode.DIRECTIONAL;
	private function get_trackScaleMode():String { return this._trackScaleMode; }
	private function set_trackScaleMode(value:String):String
	{
		if (this.processStyleRestriction("trackScaleMode"))
		{
			return value;
		}
		if (this._trackScaleMode == value)
		{
			return value;
		}
		this._trackScaleMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._trackScaleMode;
	}
	
	/**
	 * @private
	 */
	public var trackInteractionMode(get, set):String;
	private var _trackInteractionMode:String = TrackInteractionMode.TO_VALUE;
	private function get_trackInteractionMode():String { return this._trackInteractionMode; }
	private function set_trackInteractionMode(value:String):String
	{
		if (this.processStyleRestriction("trackInteractionMode"))
		{
			return value;
		}
		return this._trackInteractionMode = value;
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
	 * <p>In the following example, the slider's repeat delay is set to
	 * 500 milliseconds:</p>
	 *
	 * <listing version="3.0">
	 * slider.repeatDelay = 0.5;</listing>
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
	 * A function used to generate the slider's minimum track sub-component.
	 * The minimum track must be an instance of <code>BasicButton</code> (or
	 * a subclass). This factory can be used to change properties on the
	 * minimum track when it is first created. For instance, if you are
	 * skinning Feathers components without a theme, you might use this
	 * factory to set skins and other styles on the minimum track.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom minimum track factory is passed
	 * to the slider:</p>
	 *
	 * <listing version="3.0">
	 * slider.minimumTrackFactory = function():BasicButton
	 * {
	 *     var track:BasicButton = new BasicButton();
	 *     var skin:ImageSkin = new ImageSkin( upTexture );
	 *     skin.setTextureForState( ButtonState.DOWN, downTexture );
	 *     track.defaultSkin = skin;
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
		if (this.processStyleRestriction("customMinimumTrackStyleName"))
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
	 * An object that stores properties for the slider's "minimum" track,
	 * and the properties will be passed down to the "minimum" track when
	 * the slider validates. For a list of available properties, refer to
	 * <a href="BasicButton.html"><code>feathers.controls.BasicButton</code></a>.
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
	 * <p>In the following example, the slider's minimum track properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * slider.minimumTrackProperties.defaultSkin = new Image( upTexture );
	 * slider.minimumTrackProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #minimumTrackFactory
	 * @see feathers.controls.BasicButton
	 */
	public var minimumTrackProperties(get, set):PropertyProxy;
	private var _minimumTrackProperties:PropertyProxy;
	private function get_minimumTrackProperties():PropertyProxy
	{
		if (this._minimumTrackProperties == null)
		{
			this._minimumTrackProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._minimumTrackProperties;
	}
	
	private function set_minimumTrackProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._minimumTrackProperties == value)
		{
			return value;
		}
		//if (value == null)
		//{
			//value = new PropertyProxy();
		//}
		//if (!Std.isOfType(value, PropertyProxyReal))
		//{
			////var newValue:PropertyProxy = new PropertyProxy();
			////for(var propertyName:String in value)
			////{
				////newValue[propertyName] = value[propertyName];
			////}
			////value = newValue;
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._minimumTrackProperties != null)
		{
			//this._minimumTrackProperties.removeOnChangeCallback(childProperties_onChange);
			this._minimumTrackProperties.dispose();
		}
		this._minimumTrackProperties = value;
		if (this._minimumTrackProperties != null)
		{
			this._minimumTrackProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._minimumTrackProperties;
	}
	
	/**
	 * A function used to generate the slider's maximum track sub-component.
	 * The maximum track must be an instance of <code>BasicButton</code> (or
	 * a subclass). This factory can be used to change properties on the
	 * maximum track when it is first created. For instance, if you are
	 * skinning Feathers components without a theme, you might use this
	 * factory to set skins and other styles on the maximum track.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom maximum track factory is passed
	 * to the slider:</p>
	 *
	 * <listing version="3.0">
	 * slider.maximumTrackFactory = function():BasicButton
	 * {
	 *     var track:BasicButton = new BasicButton();
	 *     var skin:ImageSkin = new ImageSkin( upTexture );
	 *     skin.setTextureForState( ButtonState.DOWN, downTexture );
	 *     track.defaultSkin = skin;
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
		if (this.processStyleRestriction("customMaximumTrackStyleName"))
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
	 * An object that stores properties for the slider's "maximum" track,
	 * and the properties will be passed down to the "maximum" track when
	 * the slider validates. For a list of available properties, refer to
	 * <a href="BasicButton.html"><code>feathers.controls.BasicButton</code></a>.
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
	 * <p>In the following example, the slider's maximum track properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * slider.maximumTrackProperties.defaultSkin = new Image( upTexture );
	 * slider.maximumTrackProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #maximumTrackFactory
	 * @see feathers.controls.BasicButton
	 */
	public var maximumTrackProperties(get, set):PropertyProxy;
	private var _maximumTrackProperties:PropertyProxy;
	private function get_maximumTrackProperties():PropertyProxy
	{
		if (this._maximumTrackProperties == null)
		{
			this._maximumTrackProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._maximumTrackProperties;
	}
	
	private function set_maximumTrackProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._maximumTrackProperties == value)
		{
			return value;
		}
		//if (value == null)
		//{
			//value = new PropertyProxy();
		//}
		//if (!Std.isOfType(value, PropertyProxyReal))
		//{
			////var newValue:PropertyProxy = new PropertyProxy();
			////for(var propertyName:String in value)
			////{
				////newValue[propertyName] = value[propertyName];
			////}
			////value = newValue;
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._maximumTrackProperties != null)
		{
			//this._maximumTrackProperties.removeOnChangeCallback(childProperties_onChange);
			this._maximumTrackProperties.dispose();
		}
		this._maximumTrackProperties = value;
		if (this._maximumTrackProperties != null)
		{
			this._maximumTrackProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._maximumTrackProperties;
	}
	
	/**
	 * A function used to generate the slider's thumb sub-component.
	 * The thumb must be an instance of <code>BasicButton</code> (or a
	 * subclass). This factory can be used to change properties on the thumb
	 * when it is first created. For instance, if you are skinning Feathers
	 * components without a theme, you might use this factory to set skins
	 * and other styles on the thumb.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom thumb factory is passed
	 * to the slider:</p>
	 *
	 * <listing version="3.0">
	 * slider.thumbFactory = function():BasicButton
	 * {
	 *     var thumb:BasicButton = new BasicButton();
	 *     var skin:ImageSkin = new ImageSkin( upTexture );
	 *     skin.setTextureForState( ButtonState.DOWN, downTexture );
	 *     thumb.defaultSkin = skin;
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
		if (this.processStyleRestriction("customThumbStyleName"))
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
	 * An object that stores properties for the slider's thumb, and the
	 * properties will be passed down to the thumb when the slider
	 * validates. For a list of available properties, refer to
	 * <a href="BasicButton.html"><code>feathers.controls.BasicButton</code></a>.
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
	 * <p>In the following example, the slider's thumb properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * slider.thumbProperties.defaultSkin = new Image( upTexture );
	 * slider.thumbProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 * @see #thumbFactory
	 */
	public var thumbProperties(get, set):PropertyProxy;
	private var _thumbProperties:PropertyProxy;
	private function get_thumbProperties():PropertyProxy
	{
		if (this._thumbProperties == null)
		{
			this._thumbProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._thumbProperties;
	}
	
	private function set_thumbProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._thumbProperties == value)
		{
			return value;
		}
		//if (!value)
		//{
			//value = new PropertyProxy();
		//}
		//if (!Std.isOfType(value, PropertyProxyReal))
		//{
			////var newValue:PropertyProxy = new PropertyProxy();
			////for(var propertyName:String in value)
			////{
				////newValue[propertyName] = value[propertyName];
			////}
			////value = newValue;
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._thumbProperties != null)
		{
			//this._thumbProperties.removeOnChangeCallback(childProperties_onChange);
			this._thumbProperties.dispose();
		}
		this._thumbProperties = value;
		if (this._thumbProperties != null)
		{
			this._thumbProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._thumbProperties;
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
	private var _touchValue:Float;

	/**
	 * @private
	 */
	private var _pageStartValue:Float;
	
	/**
	 * @private
	 */
	override public function hitTest(local:Point):DisplayObject
	{
		var result:DisplayObject = super.hitTest(local);
		if (result != null && this._trackInteractionMode == TrackInteractionMode.TO_VALUE)
		{
			return this.thumb;
		}
		return result;
	}
	
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
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var focusInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_FOCUS);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var thumbFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_THUMB_FACTORY);
		var minimumTrackFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY);
		var maximumTrackFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY);
		
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
		
		if (thumbFactoryInvalid || stylesInvalid)
		{
			this.refreshThumbStyles();
		}
		if (minimumTrackFactoryInvalid || stylesInvalid)
		{
			this.refreshMinimumTrackStyles();
		}
		if ((maximumTrackFactoryInvalid || layoutInvalid || stylesInvalid) && this.maximumTrack != null)
		{
			this.refreshMaximumTrackStyles();
		}
		
		if (stateInvalid || thumbFactoryInvalid || minimumTrackFactoryInvalid ||
			maximumTrackFactoryInvalid)
		{
			this.refreshEnabled();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutChildren();
		
		if (sizeInvalid || focusInvalid)
		{
			this.refreshFocusIndicator();
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
		if (this._direction == Direction.VERTICAL)
		{
			return this.measureVertical();
		}
		return this.measureHorizontal();
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
		var measureMinTrack:IMeasureDisplayObject = null;
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
		var measureMaxTrack:IMeasureDisplayObject = null;
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
		}
		if (needsHeight)
		{
			newHeight = this.minimumTrack.height;
			if (!isSingle) //split
			{
				if (this.maximumTrack.height > newHeight)
				{
					newHeight = this.maximumTrack.height;
				}
				newHeight += this.thumb.height / 2;
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
				else
				{
					newMinHeight = this.maximumTrack.height;
				}
				if (Std.isOfType(this.thumb, IMeasureDisplayObject))
				{
					newMinHeight += cast(this.thumb, IMeasureDisplayObject).minHeight / 2;
				}
				else
				{
					newMinHeight += this.thumb.height / 2;
				}
			}
		}
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
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
		if (needsWidth)
		{
			this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
		}
		else if (isSingle)
		{
			this.minimumTrack.width = this._explicitWidth;
		}
		var measureMinTrack:IMeasureDisplayObject = null;
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
		var measureMaxTrack:IMeasureDisplayObject = null;
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
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsWidth)
		{
			newWidth = this.minimumTrack.width;
			if (!isSingle) //split
			{
				if (this.maximumTrack.width > newWidth)
				{
					newWidth = this.maximumTrack.width;
				}
				newWidth += this.thumb.width / 2;
			}
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
				if (Std.isOfType(this.thumb, IMeasureDisplayObject))
				{
					newMinWidth += cast(this.thumb, IMeasureDisplayObject).minWidth / 2;
				}
				else
				{
					newMinWidth += this.thumb.width / 2;
				}
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
			//measurements as explicit when we auto-size the slider
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
		if (this._trackLayoutMode == TrackLayoutMode.SINGLE)
		{
			return;
		}
		
		var factory:Void->BasicButton = this._maximumTrackFactory != null ? this._maximumTrackFactory : defaultMaximumTrackFactory;
		var maximumTrackStyleName:String = this._customMaximumTrackStyleName != null ? this._customMaximumTrackStyleName : this.maximumTrackStyleName;
		var maximumTrack:BasicButton = factory();
		maximumTrack.styleNameList.add(maximumTrackStyleName);
		maximumTrack.keepDownStateOnRollOut = true;
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
			//measurements as explicit when we auto-size the slider
			this._maximumTrackSkinExplicitWidth = this.maximumTrack.width;
			this._maximumTrackSkinExplicitHeight = this.maximumTrack.height;
			this._maximumTrackSkinExplicitMinWidth = this._maximumTrackSkinExplicitWidth;
			this._maximumTrackSkinExplicitMinHeight = this._maximumTrackSkinExplicitHeight;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshThumbStyles():Void
	{
		if (this._thumbProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._thumbProperties)
			{
				propertyValue = this._thumbProperties[propertyName];
				//this.thumb[propertyName] = propertyValue;
				Reflect.setProperty(this.thumb, propertyName, propertyValue);
			}
		}
		this.thumb.visible = this._showThumb;
	}
	
	/**
	 * @private
	 */
	private function refreshMinimumTrackStyles():Void
	{
		if (this._minimumTrackProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._minimumTrackProperties)
			{
				propertyValue = this._minimumTrackProperties[propertyName];
				//this.minimumTrack[propertyName] = propertyValue;
				Reflect.setProperty(minimumTrack, propertyName, propertyValue);
			}
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
		if (this._maximumTrackProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._maximumTrackProperties)
			{
				propertyValue = this._maximumTrackProperties[propertyName];
				//this.maximumTrack[propertyName] = propertyValue;
				Reflect.setProperty(maximumTrack, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		if (Std.isOfType(this.thumb, IFeathersControl))
		{
			cast(this.thumb, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (Std.isOfType(this.minimumTrack, IFeathersControl))
		{
			cast(this.minimumTrack, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (Std.isOfType(this.maximumTrack, IFeathersControl))
		{
			cast(this.maximumTrack, IFeathersControl).isEnabled = this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
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
	private function layoutThumb():Void
	{
		//this will auto-size the thumb, if needed
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
		}
		
		var percentage:Float;
		if (this._minimum == this._maximum)
		{
			percentage = 1;
		}
		else
		{
			percentage = (this._value - this._minimum) / (this._maximum - this._minimum);
			if (percentage < 0)
			{
				percentage = 0;
			}
			else if (percentage > 1)
			{
				percentage = 1;
			}
		}
		if (this._direction == Direction.VERTICAL)
		{
			var trackScrollableHeight:Float = this.actualHeight - this.thumb.height - this._minimumPadding - this._maximumPadding;
			this.thumb.x = Math.fround((this.actualWidth - this.thumb.width) / 2) + this._thumbOffset;
			//maximum is at the top, so we need to start the y position of
			//the thumb from the maximum padding
			this.thumb.y = Math.fround(this._maximumPadding + trackScrollableHeight * (1 - percentage));
		}
		else //horizontal
		{
			var trackScrollableWidth:Float = this.actualWidth - this.thumb.width - this._minimumPadding - this._maximumPadding;
			//minimum is at the left, so we need to start the x position of
			//the thumb from the minimum padding
			this.thumb.x = Math.fround(this._minimumPadding + (trackScrollableWidth * percentage));
			this.thumb.y = Math.fround((this.actualHeight - this.thumb.height) / 2) + this._thumbOffset;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutTrackWithMinMax():Void
	{
		if (this._direction == Direction.VERTICAL)
		{
			var maximumTrackHeight:Float = Math.fround(this.thumb.y + (this.thumb.height / 2));
			this.maximumTrack.y = 0;
			this.maximumTrack.height = maximumTrackHeight;
			this.minimumTrack.y = maximumTrackHeight;
			this.minimumTrack.height = this.actualHeight - maximumTrackHeight;
			if (this._trackScaleMode == TrackScaleMode.EXACT_FIT)
			{
				this.maximumTrack.x = 0;
				this.maximumTrack.width = this.actualWidth;
				this.minimumTrack.x = 0;
				this.minimumTrack.width = this.actualWidth;
			}
			else //directional
			{
				this.maximumTrack.width = this._maximumTrackSkinExplicitWidth;
				this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
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
			
			if (this._trackScaleMode == TrackScaleMode.DIRECTIONAL)
			{
				this.maximumTrack.x = Math.fround((this.actualWidth - this.maximumTrack.width) / 2);
				this.minimumTrack.x = Math.fround((this.actualWidth - this.minimumTrack.width) / 2);
			}
		}
		else //horizontal
		{
			var minimumTrackWidth:Float = Math.fround(this.thumb.x + (this.thumb.width / 2));
			this.minimumTrack.x = 0;
			this.minimumTrack.width = minimumTrackWidth;
			this.maximumTrack.x = minimumTrackWidth;
			this.maximumTrack.width = this.actualWidth - minimumTrackWidth;
			
			if (this._trackScaleMode == TrackScaleMode.EXACT_FIT)
			{
				this.minimumTrack.y = 0;
				this.minimumTrack.height = this.actualHeight;
				this.maximumTrack.y = 0;
				this.maximumTrack.height = this.actualHeight;
			}
			else //directional
			{
				this.minimumTrack.height = this._minimumTrackSkinExplicitHeight;
				this.maximumTrack.height = this._maximumTrackSkinExplicitHeight;
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
			
			if (this._trackScaleMode == TrackScaleMode.DIRECTIONAL)
			{
				this.minimumTrack.y = Math.fround((this.actualHeight - this.minimumTrack.height) / 2);
				this.maximumTrack.y = Math.fround((this.actualHeight - this.maximumTrack.height) / 2);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function layoutTrackWithSingle():Void
	{
		if (this._direction == Direction.VERTICAL)
		{
			this.minimumTrack.y = 0;
			this.minimumTrack.height = this.actualHeight;
			if (this._trackScaleMode == TrackScaleMode.EXACT_FIT)
			{
				this.minimumTrack.x = 0;
				this.minimumTrack.width = this.actualWidth;
			}
			else //directional
			{
				//we'll calculate x after validation in case the track needs
				//to auto-size
				this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
			}
			
			//final validation to avoid juggler next frame issues
			if (Std.isOfType(this.minimumTrack, IValidating))
			{
				cast(this.minimumTrack, IValidating).validate();
			}
			
			if (this._trackScaleMode == TrackScaleMode.DIRECTIONAL)
			{
				this.minimumTrack.x = Math.fround((this.actualWidth - this.minimumTrack.width) / 2);
			}
		}
		else //horizontal
		{
			this.minimumTrack.x = 0;
			this.minimumTrack.width = this.actualWidth;
			if (this._trackScaleMode == TrackScaleMode.EXACT_FIT)
			{
				this.minimumTrack.y = 0;
				this.minimumTrack.height = this.actualHeight;
			}
			else //directional
			{
				//we'll calculate y after validation in case the track needs
				//to auto-size
				this.minimumTrack.height = this._minimumTrackSkinExplicitHeight;
			}
			
			//final validation to avoid juggler next frame issues
			if (Std.isOfType(this.minimumTrack, IValidating))
			{
				cast(this.minimumTrack, IValidating).validate();
			}
			
			if (this._trackScaleMode == TrackScaleMode.DIRECTIONAL)
			{
				this.minimumTrack.y = Math.fround((this.actualHeight - this.minimumTrack.height) / 2);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function locationToValue(location:Point):Float
	{
		var percentage:Float;
		if (this._direction == Direction.VERTICAL)
		{
			var trackScrollableHeight:Float = this.actualHeight - this.thumb.height - this._minimumPadding - this._maximumPadding;
			var yOffset:Float = location.y - this._touchStartY - this._maximumPadding;
			var yPosition:Float = Math.min(Math.max(0, this._thumbStartY + yOffset), trackScrollableHeight);
			percentage = 1 - (yPosition / trackScrollableHeight);
		}
		else //horizontal
		{
			var trackScrollableWidth:Float = this.actualWidth - this.thumb.width - this._minimumPadding - this._maximumPadding;
			var xOffset:Float = location.x - this._touchStartX - this._minimumPadding;
			var xPosition:Float = Math.min(Math.max(0, this._thumbStartX + xOffset), trackScrollableWidth);
			percentage = xPosition / trackScrollableWidth;
		}
		
		return this._minimum + percentage * (this._maximum - this._minimum);
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
	private function adjustPage():Void
	{
		var page:Float = this._page;
		if (page != page) //isNaN
		{
			page = this._step;
		}
		var newValue:Float;
		if (this._touchValue < this._pageStartValue)
		{
			newValue = Math.max(this._touchValue, this._value - page);
			if (this._step != 0 && newValue != this._maximum && newValue != this._minimum)
			{
				newValue = MathUtils.roundDownToNearest(newValue, this._step);
			}
			this.value = newValue;
		}
		else if (this._touchValue > this._pageStartValue)
		{
			newValue = Math.min(this._touchValue, this._value + page);
			if (this._step != 0 && newValue != this._maximum && newValue != this._minimum)
			{
				newValue = MathUtils.roundUpToNearest(newValue, this._step);
			}
			this.value = newValue;
		}
	}
	
	/**
	 * @private
	 */
	private function childProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function slider_removedFromStageHandler(event:Event):Void
	{
		this._touchPointID = -1;
		var wasDragging:Bool = this.isDragging;
		this.isDragging = false;
		if (wasDragging && !this.liveDragging)
		{
			this.dispatchEventWith(Event.CHANGE);
		}
	}
	
	/**
	 * @private
	 */
	override function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		super.focusOutHandler(event);
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
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
				if (!this._showThumb || this._trackInteractionMode != TrackInteractionMode.BY_PAGE)
				{
					this.value = this._touchValue;
				}
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				if (this._repeatTimer != null)
				{
					this._repeatTimer.stop();
				}
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
			touch = event.getTouch(track, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			location = touch.getLocation(this, Pool.getPoint());
			this._touchPointID = touch.id;
			if (this._direction == Direction.VERTICAL)
			{
				this._thumbStartX = location.x;
				this._thumbStartY = Math.min(this.actualHeight - this.thumb.height - this._maximumPadding, Math.max(this._minimumPadding, location.y - this.thumb.height / 2));
			}
			else //horizontal
			{
				this._thumbStartX = Math.min(this.actualWidth - this.thumb.width - this._maximumPadding, Math.max(this._minimumPadding, location.x - this.thumb.width / 2));
				this._thumbStartY = location.y;
			}
			this._touchStartX = location.x;
			this._touchStartY = location.y;
			this._touchValue = this.locationToValue(location);
			Pool.putPoint(location);
			this._pageStartValue = this._value;
			this.isDragging = true;
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
			if (this._showThumb && this._trackInteractionMode == TrackInteractionMode.BY_PAGE)
			{
				this.adjustPage();
				this.startRepeatTimer(this.adjustPage);
			}
			else
			{
				this.value = this._touchValue;
			}
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
		if (this._trackInteractionMode == TrackInteractionMode.TO_VALUE)
		{
			touch = event.getTouch(this.thumb, null, this._touchPointID);
			if (touch != null)
			{
				location = touch.getLocation(this.thumb, Pool.getPoint());
				if (this.thumb.hitTest(location) == null)
				{
					//the touch is not actually on the thumb, so behave as
					//if the track were touched
					Pool.putPoint(location);
					this.track_touchHandler(event);
					return;
				}
				//the touch is on the thumb
				Pool.putPoint(location);
			}
		}
		
		if (this._touchPointID >= 0)
		{
			touch = event.getTouch(this.thumb, null, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			if (touch.phase == TouchPhase.MOVED)
			{
				var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
				var claim:DisplayObject = exclusiveTouch.getClaim(this._touchPointID);
				if (claim != this)
				{
					if (claim != null)
					{
						//already claimed by another display object
						return;
					}
					else
					{
						exclusiveTouch.claimTouch(this._touchPointID, this);
					}
				}
				location = touch.getLocation(this, Pool.getPoint());
				this.value = this.locationToValue(location);
				Pool.putPoint(location);
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
			if (touch == null)
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
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.keyCode == Keyboard.HOME)
		{
			event.preventDefault();
			this.value = this._minimum;
			return;
		}
		if (event.keyCode == Keyboard.END)
		{
			event.preventDefault();
			this.value = this._maximum;
			return;
		}
		var page:Float = this._page;
		if (page != page) //isNaN
		{
			page = this._step;
		}
		if (this._direction == Direction.VERTICAL)
		{
			if (event.keyCode == Keyboard.UP)
			{
				event.preventDefault();
				if (event.shiftKey)
				{
					this.value += page;
				}
				else
				{
					this.value += this._step;
				}
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				event.preventDefault();
				if (event.shiftKey)
				{
					this.value -= page;
				}
				else
				{
					this.value -= this._step;
				}
			}
		}
		else
		{
			if (event.keyCode == Keyboard.LEFT)
			{
				event.preventDefault();
				if (event.shiftKey)
				{
					this.value -= page;
				}
				else
				{
					this.value -= this._step;
				}
			}
			else if (event.keyCode == Keyboard.RIGHT)
			{
				event.preventDefault();
				if (event.shiftKey)
				{
					this.value += page;
				}
				else
				{
					this.value += this._step;
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function repeatTimer_timerHandler(event:TimerEvent):Void
	{
		var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
		var claim:DisplayObject = exclusiveTouch.getClaim(this._touchPointID);
		if (claim != null && claim != this)
		{
			return;
		}
		if (this._repeatTimer.currentCount < 5)
		{
			return;
		}
		this.currentRepeatAction();
	}
	
}