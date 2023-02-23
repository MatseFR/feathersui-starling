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
import feathers.core.PropertyProxyReal;
import feathers.events.FeathersEventType;
import feathers.layout.Direction;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.utils.Timer;
import feathers.core.IFeathersControl;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Select a value between a minimum and a maximum by dragging a thumb over
 * a physical range. This type of scroll bar does not have a visible track,
 * and it does not have increment and decrement buttons. It is ideal for
 * mobile applications where the scroll bar is often simply a visual element
 * to indicate the scroll position. For a more feature-rich scroll bar,
 * see the <code>ScrollBar</code> component.
 *
 * <p>The following example updates a list to use simple scroll bars:</p>
 *
 * <listing version="3.0">
 * list.horizontalScrollBarFactory = function():IScrollBar
 * {
 *     return new SimpleScrollBar();
 * };
 * list.verticalScrollBarFactory = function():IScrollBar
 * {
 *     return new SimpleScrollBar();
 * };</listing>
 *
 * @see ../../../help/simple-scroll-bar.html How to use the Feathers SimpleScrollBar component
 * @see feathers.controls.ScrollBar
 *
 * @productversion Feathers 1.0.0
 */
class SimpleScrollBar extends FeathersControl implements IDirectionalScrollBar
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_THUMB_FACTORY:String = "thumbFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the thumb.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-simple-scroll-bar-thumb";

	/**
	 * The default <code>IStyleProvider</code> for all <code>SimpleScrollBar</code>
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
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	
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
	 * @private
	 */
	private var _thumbExplicitWidth:Float;

	/**
	 * @private
	 */
	private var _thumbExplicitHeight:Float;

	/**
	 * @private
	 */
	private var _thumbExplicitMinWidth:Float;

	/**
	 * @private
	 */
	private var _thumbExplicitMinHeight:Float;

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
	 * @private
	 */
	private var track:Quad;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return SimpleScrollBar.globalStyleProvider;
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
		if (this.processStyleRestriction("fixedThumbSize"))
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
	 * Determines if the value should be clamped to the range between the
	 * minimum and maximum. If <code>false</code> and the value is outside of the range,
	 * the thumb will shrink as if the range were increasing.
	 *
	 * <p>In the following example, the clamping behavior is updated:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.clampToRange = true;</listing>
	 *
	 * @default false
	 */
	public var clampToRange:Bool = false;
	
	/**
	 * @inheritDoc
	 *
	 * @default 0
	 *
	 * @see #maximum
	 * @see #minimum
	 * @see #step
	 * @see #page
	 * @see #event:change
	 */
	public var value(get, set):Float;
	private var _value:Float = 0;
	private function get_value():Float { return this._value; }
	private function set_value(newValue:Float):Float
	{
		if (this.clampToRange)
		{
			newValue = MathUtils.clamp(newValue, this._minimum, this._maximum);
		}
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
		return this._maximum = value;
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
		if (this.processStyleRestriction("paddingTop"))
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
		if (this.processStyleRestriction("paddingRight"))
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
		if (this.processStyleRestriction("paddingBottom"))
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
		if (this.processStyleRestriction("paddingLeft"))
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
	 * A function used to generate the scroll bar's thumb sub-component.
	 * The thumb must be an instance of <code>BasicButton</code>. This
	 * factory can be used to change properties on the thumb when it is
	 * first created. For instance, if you are skinning Feathers components
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
		if (!Std.isOfType(value, PropertyProxyReal))
		{
			var newValue:PropertyProxy = PropertyProxy.fromObject(value);
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			value = newValue;
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
	private var _touchValue:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _pageStartValue:Float;
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		if (this.track == null)
		{
			this.track = new Quad(10, 10, 0xff00ff);
			this.track.alpha = 0;
			this.track.addEventListener(TouchEvent.TOUCH, track_touchHandler);
			this.addChild(this.track);
		}
		if (this._value < this._minimum)
		{
			this.value = this._minimum;
		}
		else if (this._value > this._maximum)
		{
			this.value = this._maximum;
		}
	}
	
	override public function dispose():Void 
	{
		if (this._thumbProperties != null)
		{
			this._thumbProperties.dispose();
			this._thumbProperties = null;
		}
		super.dispose();
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
		var thumbFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_THUMB_FACTORY);
		
		if (thumbFactoryInvalid)
		{
			this.createThumb();
		}
		
		if (thumbFactoryInvalid || stylesInvalid)
		{
			this.refreshThumbStyles();
		}
		
		if (dataInvalid || thumbFactoryInvalid || stateInvalid)
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
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}

		this.thumb.width = this._thumbExplicitWidth;
		this.thumb.height = this._thumbExplicitHeight;
		var measureThumb:IMeasureDisplayObject = null;
		if (Std.isOfType(this.thumb, IMeasureDisplayObject))
		{
			measureThumb = cast this.thumb;
			measureThumb.minWidth = this._thumbExplicitMinWidth;
			measureThumb.minHeight = this._thumbExplicitMinHeight;
		}
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
		}

		var range:Float = this._maximum - this._minimum;
		var adjustedPage:Float = this._page;
		if (adjustedPage == 0)
		{
			//fall back to using step!
			adjustedPage = this._step;
		}
		if (adjustedPage > range)
		{
			adjustedPage = range;
		}
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsWidth)
		{
			newWidth = this.thumb.width;
			if (this._direction != Direction.VERTICAL && adjustedPage != 0)
			{
				newWidth *= range / adjustedPage;
			}
			newWidth += this._paddingLeft + this._paddingRight;
		}
		if (needsHeight)
		{
			newHeight = this.thumb.height;
			if (this._direction == Direction.VERTICAL && adjustedPage != 0)
			{
				newHeight *= range / adjustedPage;
			}
			newHeight += this._paddingTop + this._paddingBottom;
		}
		if (needsMinWidth)
		{
			if (measureThumb != null)
			{
				newMinWidth = measureThumb.minWidth;
			}
			else
			{
				newMinWidth = this.thumb.width;
			}
			if (this._direction != Direction.VERTICAL && adjustedPage != 0)
			{
				newMinWidth *= range / adjustedPage;
			}
			newMinWidth += this._paddingLeft + this._paddingRight;
		}
		if (needsMinHeight)
		{
			if (measureThumb != null)
			{
				newMinHeight = measureThumb.minHeight;
			}
			else
			{
				newMinHeight = this.thumb.height;
			}
			if (this._direction == Direction.VERTICAL && adjustedPage != 0)
			{
				newMinHeight *= range / adjustedPage;
			}
			newMinHeight += this._paddingTop + this._paddingBottom;
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
		if (Std.isOfType(thumb, IFocusDisplayObject))
		{
			thumb.isFocusEnabled = false;
		}
		thumb.keepDownStateOnRollOut = true;
		thumb.addEventListener(TouchEvent.TOUCH, thumb_touchHandler);
		this.addChild(thumb);
		this.thumb = thumb;
		
		if (Std.isOfType(this.thumb, IFeathersControl))
		{
			cast(this.thumb, IFeathersControl).initializeNow();
		}
		if (Std.isOfType(this.thumb, IMeasureDisplayObject))
		{
			var measureThumb:IMeasureDisplayObject = cast this.thumb;
			this._thumbExplicitWidth = measureThumb.explicitWidth;
			this._thumbExplicitHeight = measureThumb.explicitHeight;
			this._thumbExplicitMinWidth = measureThumb.explicitMinWidth;
			this._thumbExplicitMinHeight = measureThumb.explicitMinHeight;
		}
		else
		{
			//this is a regular display object, and we'll treat its
			//measurements as explicit when we auto-size the scroll bar
			this._thumbExplicitWidth = this.thumb.width;
			this._thumbExplicitHeight = this.thumb.height;
			this._thumbExplicitMinWidth = this._thumbExplicitWidth;
			this._thumbExplicitMinHeight = this._thumbExplicitHeight;
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
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		if (Std.isOfType(this.thumb, IFeathersControl))
		{
			cast(this.thumb, IFeathersControl).isEnabled = this._isEnabled && this._maximum > this._minimum;
		}
	}
	
	/**
	 * @private
	 */
	private function layout():Void
	{
		this.track.width = this.actualWidth;
		this.track.height = this.actualHeight;
		
		var range:Float = this._maximum - this._minimum;
		this.thumb.visible = range > 0;
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
		else if (adjustedPage > range)
		{
			adjustedPage = range;
		}
		var valueOffset:Float = 0;
		if (this._value < this._minimum)
		{
			valueOffset = this._minimum - this._value;
		}
		if (this._value > this._maximum)
		{
			valueOffset = this._value - this._maximum;
		}
		if (this._direction == Direction.VERTICAL)
		{
			this.thumb.width = contentWidth;
			var thumbMinHeight:Float = this._thumbExplicitMinHeight;
			if (Std.isOfType(this.thumb, IMeasureDisplayObject))
			{
				thumbMinHeight = cast(this.thumb, IMeasureDisplayObject).minHeight;
			}
			if (this._fixedThumbSize)
			{
				this.thumb.height = this._thumbExplicitHeight;
			}
			else
			{
				var thumbHeight:Float = contentHeight * adjustedPage / range;
				var heightOffset:Float = contentHeight - thumbHeight;
				if (heightOffset > thumbHeight)
				{
					heightOffset = thumbHeight;
				}
				heightOffset *= valueOffset / (range * thumbHeight / contentHeight);
				thumbHeight -= heightOffset;
				if (thumbHeight < thumbMinHeight)
				{
					thumbHeight = thumbMinHeight;
				}
				this.thumb.height = thumbHeight;
			}
			this.thumb.x = this._paddingLeft + (this.actualWidth - this._paddingLeft - this._paddingRight - this.thumb.width) / 2;
			var trackScrollableHeight:Float = contentHeight - this.thumb.height;
			var thumbY:Float = trackScrollableHeight * (this._value - this._minimum) / range;
			if (thumbY > trackScrollableHeight)
			{
				thumbY = trackScrollableHeight;
			}
			else if (thumbY < 0)
			{
				thumbY = 0;
			}
			this.thumb.y = this._paddingTop + thumbY;
		}
		else //horizontal
		{
			var thumbMinWidth:Float = this._thumbExplicitMinWidth;
			if (Std.isOfType(this.thumb, IMeasureDisplayObject))
			{
				thumbMinWidth = cast(this.thumb, IMeasureDisplayObject).minWidth;
			}
			if (this._fixedThumbSize)
			{
				this.thumb.width = this._thumbExplicitWidth;
			}
			else
			{
				var thumbWidth:Float = contentWidth * adjustedPage / range;
				var widthOffset:Float = contentWidth - thumbWidth;
				if (widthOffset > thumbWidth)
				{
					widthOffset = thumbWidth;
				}
				widthOffset *= valueOffset / (range * thumbWidth / contentWidth);
				thumbWidth -= widthOffset;
				if (thumbWidth < thumbMinWidth)
				{
					thumbWidth = thumbMinWidth;
				}
				this.thumb.width = thumbWidth;
			}
			this.thumb.height = contentHeight;
			var trackScrollableWidth:Float = contentWidth - this.thumb.width;
			var thumbX:Float = trackScrollableWidth * (this._value - this._minimum) / range;
			if (thumbX > trackScrollableWidth)
			{
				thumbX = trackScrollableWidth;
			}
			else if (thumbX < 0)
			{
				thumbX = 0;
			}
			this.thumb.x = this._paddingLeft + thumbX;
			this.thumb.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.thumb.height) / 2;
		}
		
		//final validation to avoid juggler next frame issues
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
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
			var trackScrollableHeight:Float = this.actualHeight - this.thumb.height - this._paddingTop - this._paddingBottom;
			if (trackScrollableHeight > 0)
			{
				var yOffset:Float = location.y - this._touchStartY - this._paddingTop;
				var yPosition:Float = Math.min(Math.max(0, this._thumbStartY + yOffset), trackScrollableHeight);
				percentage = yPosition / trackScrollableHeight;
			}
		}
		else //horizontal
		{
			var trackScrollableWidth:Float = this.actualWidth - this.thumb.width - this._paddingLeft - this._paddingRight;
			if (trackScrollableWidth > 0)
			{
				var xOffset:Float = location.x - this._touchStartX - this._paddingLeft;
				var xPosition:Float = Math.min(Math.max(0, this._thumbStartX + xOffset), trackScrollableWidth);
				percentage = xPosition / trackScrollableWidth;
			}
		}
		
		return this._minimum + percentage * (this._maximum - this._minimum);
	}
	
	/**
	 * @private
	 */
	private function adjustPage():Void
	{
		var range:Float = this._maximum - this._minimum;
		var adjustedPage:Float = this._page;
		if (adjustedPage == 0)
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
			newValue = MathUtils.clamp(newValue, this._minimum, this._maximum);
			this.value = newValue;
		}
		else if (this._touchValue > this._pageStartValue)
		{
			newValue = Math.min(this._touchValue, this._value + adjustedPage);
			if (this._step != 0 && newValue != this._maximum && newValue != this._minimum)
			{
				newValue = MathUtils.roundUpToNearest(newValue, this._step);
			}
			newValue = MathUtils.clamp(newValue, this._minimum, this._maximum);
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
	private function thumbProperties_onChange(proxy:PropertyProxyReal, name:String):Void
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
			}
		}
		else
		{
			touch = event.getTouch(this.track, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this._touchPointID = touch.id;
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
	private function repeatTimer_timerHandler(event:TimerEvent):Void
	{
		if (this._repeatTimer.currentCount < 5)
		{
			return;
		}
		this.currentRepeatAction();
	}

}