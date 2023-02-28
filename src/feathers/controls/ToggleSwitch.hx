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
import feathers.core.IStateContext;
import feathers.core.ITextBaselineControl;
import feathers.core.ITextRenderer;
import feathers.core.IToggle;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.events.ExclusiveTouch;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.text.FontStylesSet;
import feathers.utils.math.MathUtils;
import haxe.Constraints.Function;
import openfl.geom.Point;
import openfl.ui.KeyLocation;
import openfl.ui.Keyboard;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextFormat;
import starling.utils.SystemUtil;

/**
 * Similar to a light switch with on and off states. Generally considered an
 * alternative to a check box.
 *
 * <p>The following example programmatically selects a toggle switch and
 * listens for when the selection changes:</p>
 *
 * <listing version="3.0">
 * var toggle:ToggleSwitch = new ToggleSwitch();
 * toggle.isSelected = true;
 * toggle.addEventListener( Event.CHANGE, toggle_changeHandler );
 * this.addChild( toggle );</listing>
 *
 * @see ../../../help/toggle-switch.html How to use the Feathers ToggleSwitch component
 * @see feathers.controls.Check
 *
 * @productversion Feathers 1.0.0
 */
class ToggleSwitch extends FeathersControl implements IToggle implements IFocusDisplayObject implements ITextBaselineControl implements IStateContext
{
	/**
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();

	/**
	 * @private
	 * The minimum physical distance (in inches) that a touch must move
	 * before the scroller starts scrolling.
	 */
	private static inline var MINIMUM_DRAG_DISTANCE:Float = 0.04;

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_THUMB_FACTORY:String = "thumbFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_ON_TRACK_FACTORY:String = "onTrackFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_OFF_TRACK_FACTORY:String = "offTrackFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the "off
	 * label" text renderer.
	 *
	 * <p>Note: the "off label" text renderer is not a
	 * <code>feathers.controls.Label</code>. It is an instance of one of the
	 * <code>ITextRenderer</code> implementations.</p>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_OFF_LABEL:String = "feathers-toggle-switch-off-label";

	/**
	 * The default value added to the <code>styleNameList</code> of the "on
	 * label" text renderer.
	 *
	 * <p>Note: the "on label" text renderer is not a
	 * <code>feathers.controls.Label</code>. It is an instance of one of the
	 * <code>ITextRenderer</code> implementations.</p>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ON_LABEL:String = "feathers-toggle-switch-on-label";

	/**
	 * The default value added to the <code>styleNameList</code> of the off track.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_OFF_TRACK:String = "feathers-toggle-switch-off-track";

	/**
	 * The default value added to the <code>styleNameList</code> of the on track.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ON_TRACK:String = "feathers-toggle-switch-on-track";

	/**
	 * The default value added to the <code>styleNameList</code> of the thumb.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-toggle-switch-thumb";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>ToggleSwitch</code>
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
	private static function defaultOnTrackFactory():BasicButton
	{
		return new Button();
	}

	/**
	 * @private
	 */
	private static function defaultOffTrackFactory():BasicButton
	{
		return new Button();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		if (this._onLabelFontStylesSet == null)
		{
			this._onLabelFontStylesSet = new FontStylesSet();
			this._onLabelFontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
		if (this._offLabelFontStylesSet == null)
		{
			this._offLabelFontStylesSet = new FontStylesSet();
			this._offLabelFontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
		this.addEventListener(TouchEvent.TOUCH, toggleSwitch_touchHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, toggleSwitch_removedFromStageHandler);
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the off label
	 * text renderer. This variable is <code>protected</code> so that
	 * sub-classes can customize the on label text renderer style name in
	 * their constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ON_LABEL</code>.
	 *
	 * <p>To customize the "on" label text renderer style name without
	 * subclassing, see <code>customOnLabelStyleName</code>.</p>
	 *
	 * @see #style:customOnLabelStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var onLabelStyleName:String = DEFAULT_CHILD_STYLE_NAME_ON_LABEL;

	/**
	 * The value added to the <code>styleNameList</code> of the off label
	 * text renderer. This variable is <code>protected</code> so that
	 * sub-classes can customize the off label text renderer style name in
	 * their constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_OFF_LABEL</code>.
	 *
	 * <p>To customize the "off" label text renderer style name without
	 * subclassing, see <code>customOffLabelStyleName</code>.</p>
	 *
	 * @see #style:customOffLabelStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var offLabelStyleName:String = DEFAULT_CHILD_STYLE_NAME_OFF_LABEL;

	/**
	 * The value added to the <code>styleNameList</code> of the on track.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the on track style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ON_TRACK</code>.
	 *
	 * <p>To customize the on track style name without subclassing, see
	 * <code>customOnTrackStyleName</code>.</p>
	 *
	 * @see #style:customOnTrackStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var onTrackStyleName:String = DEFAULT_CHILD_STYLE_NAME_ON_TRACK;

	/**
	 * The value added to the <code>styleNameList</code> of the off track.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the off track style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_OFF_TRACK</code>.
	 *
	 * <p>To customize the off track style name without subclassing, see
	 * <code>customOffTrackStyleName</code>.</p>
	 *
	 * @see #style:customOffTrackStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var offTrackStyleName:String = DEFAULT_CHILD_STYLE_NAME_OFF_TRACK;

	/**
	 * The value added to the <code>styleNameList</code> of the thumb. This
	 * variable is <code>protected</code> so that sub-classes can customize
	 * the thumb style name in their constructors instead of using the
	 * default stylename defined by <code>DEFAULT_CHILD_STYLE_NAME_THUMB</code>.
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
	 * The "on" text renderer sub-component.
	 *
	 * @see #labelFactory
	 */
	private var onTextRenderer:ITextRenderer;

	/**
	 * The "off" text renderer sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #labelFactory
	 */
	private var offTextRenderer:ITextRenderer;

	/**
	 * The "on" track sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #onTrackFactory
	 * @see #createOnTrack()
	 */
	private var onTrack:DisplayObject;

	/**
	 * The "off" track sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #offTrackFactory
	 * @see #createOffTrack()
	 */
	private var offTrack:DisplayObject;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return ToggleSwitch.globalStyleProvider;
	}
	
	/**
	 * The current state of the toggle switch.
	 *
	 * @see feathers.controls.ToggleState
	 * @see #event:stateChange feathers.events.FeathersEventType.STATE_CHANGE
	 */
	public var currentState(get, never):String;
	private var _currentState:String = ToggleState.NOT_SELECTED;
	private function get_currentState():String { return this._currentState; }
	
	/**
	 * @private
	 */
	override function set_isEnabled(value:Bool):Bool 
	{
		if (this._isEnabled == value)
		{
			return value;
		}
		super.set_isEnabled(value);
		this.resetState();
		return this._isEnabled;
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
	public var showLabels(get, set):Bool;
	private var _showLabels:Bool = true;
	private function get_showLabels():Bool { return this._showLabels; }
	private function set_showLabels(value:Bool):Bool
	{
		if (this.processStyleRestriction("showLabels"))
		{
			return value;
		}
		if (this._showLabels == value)
		{
			return value;
		}
		this._showLabels = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._showLabels;
	}
	
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
	public var trackLayoutMode(get, set):String;
	private var _trackLayoutMode:String = TrackLayoutMode.SINGLE;
	private function get_trackLayoutMode():String { return this._trackLayoutMode; }
	private function set_trackLayoutMode(value:String):String
	{
		if (value == "onOff")
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
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
	 * An object that stores properties for the toggle switch's label text
	 * renderers when the toggle switch is enabled, and the properties will
	 * be passed down to the text renderers when the toggle switch
	 * validates. The available properties depend on which
	 * <code>ITextRenderer</code> implementation is returned by
	 * <code>labelFactory</code> (possibly <code>onLabelFactory</code> or
	 * <code>offLabelFactory</code> instead). Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>In the following example, the toggle switch's default label
	 * properties are updated (this example assumes that the label text
	 * renderers are of type <code>TextFieldTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * toggle.defaultLabelProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 * toggle.defaultLabelProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see #labelFactory
	 * @see #onLabelFactory
	 * @see #offLabelFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var defaultLabelProperties(get, set):PropertyProxy;
	private var _defaultLabelProperties:PropertyProxy;
	private function get_defaultLabelProperties():PropertyProxy
	{
		if (this._defaultLabelProperties == null)
		{
			this._defaultLabelProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._defaultLabelProperties;
	}
	
	private function set_defaultLabelProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._defaultLabelProperties == value)
		{
			return value;
		}
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._defaultLabelProperties != null)
		{
			//this._defaultLabelProperties.removeOnChangeCallback(childProperties_onChange);
			this._defaultLabelProperties.dispose();
		}
		this._defaultLabelProperties = value;
		if (this._defaultLabelProperties != null)
		{
			this._defaultLabelProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._defaultLabelProperties;
	}
	
	/**
	 * An object that stores properties for the toggle switch's label text
	 * renderers when the toggle switch is disabled, and the properties will
	 * be passed down to the text renderers when the toggle switch
	 * validates. The available properties depend on which
	 * <code>ITextRenderer</code> implementation is returned by
	 * <code>labelFactory</code> (possibly <code>onLabelFactory</code> or
	 * <code>offLabelFactory</code> instead). Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>In the following example, the toggle switch's disabled label
	 * properties are updated (this example assumes that the label text
	 * renderers are of type <code>TextFieldTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * toggle.disabledLabelProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 * toggle.disabledLabelProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see #labelFactory
	 * @see #onLabelFactory
	 * @see #offLabelFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var disabledLabelProperties(get, set):PropertyProxy;
	private var _disabledLabelProperties:PropertyProxy;
	private function get_disabledLabelProperties():PropertyProxy
	{
		if (this._disabledLabelProperties == null)
		{
			this._disabledLabelProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._disabledLabelProperties;
	}
	
	private function set_disabledLabelProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._disabledLabelProperties == value)
		{
			return value;
		}
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._disabledLabelProperties != null)
		{
			//this._disabledLabelProperties.removeOnChangeCallback(childProperties_onChange);
			this._disabledLabelProperties.dispose();
		}
		this._disabledLabelProperties = value;
		if (this._disabledLabelProperties != null)
		{
			this._disabledLabelProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._disabledLabelProperties;
	}
	
	/**
	 * An object that stores properties for the toggle switch's "on" label
	 * text renderer, and the properties will be passed down to the text
	 * renderer when the toggle switch validates. If <code>null</code>, then
	 * <code>defaultLabelProperties</code> is used instead.
	 *
	 * <p>The available properties depend on which
	 * <code>ITextRenderer</code> implementation is returned by
	 * <code>labelFactory</code> (possibly <code>onLabelFactory</code>
	 * instead). Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.</p>
	 *
	 * <p>In the following example, the toggle switch's on label properties
	 * are updated (this example assumes that the on label text renderer is a
	 * <code>TextFieldTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * toggle.onLabelProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 * toggle.onLabelProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see #labelFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var onLabelProperties(get, set):PropertyProxy;
	private var _onLabelProperties:PropertyProxy;
	private function get_onLabelProperties():PropertyProxy
	{
		if (this._onLabelProperties == null)
		{
			this._onLabelProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._onLabelProperties;
	}
	
	private function set_onLabelProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._onLabelProperties == value)
		{
			return value;
		}
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._onLabelProperties != null)
		{
			//this._onLabelProperties.removeOnChangeCallback(childProperties_onChange);
			this._onLabelProperties.dispose();
		}
		this._onLabelProperties = value;
		if (this._onLabelProperties != null)
		{
			this._onLabelProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._onLabelProperties;
	}
	
	/**
	 * An object that stores properties for the toggle switch's "off" label
	 * text renderer, and the properties will be passed down to the text
	 * renderer when the toggle switch validates. If <code>null</code>, then
	 * <code>defaultLabelProperties</code> is used instead.
	 *
	 * <p>The available properties depend on which
	 * <code>ITextRenderer</code> implementation is returned by
	 * <code>labelFactory</code> (possibly <code>offLabelFactory</code>
	 * instead). Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.</p>
	 *
	 * <p>In the following example, the toggle switch's off label properties
	 * are updated (this example assumes that the off label text renderer is a
	 * <code>TextFieldTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * toggle.offLabelProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 * toggle.offLabelProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see #labelFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var offLabelProperties(get, set):PropertyProxy;
	private var _offLabelProperties:PropertyProxy;
	private function get_offLabelProperties():PropertyProxy
	{
		if (this._offLabelProperties == null)
		{
			this._offLabelProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._onLabelProperties;
	}
	
	private function set_offLabelProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._offLabelProperties == value)
		{
			return value;
		}
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._offLabelProperties != null)
		{
			//this._offLabelProperties.removeOnChangeCallback(childProperties_onChange);
			this._offLabelProperties.dispose();
		}
		this._offLabelProperties = value;
		if (this._offLabelProperties != null)
		{
			this._offLabelProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._offLabelProperties;
	}
	
	/**
	 * A function used to instantiate the toggle switch's label text
	 * renderer sub-components, if specific factories for those label text
	 * renderers are not provided. The label text renderers must be
	 * instances of <code>ITextRenderer</code>. This factory can be used to
	 * change properties of the label text renderers when they are first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to style the label text
	 * renderers.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, the toggle switch uses a custom label
	 * factory:</p>
	 *
	 * <listing version="3.0">
	 * toggle.labelFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see #onLabelFactory
	 * @see #offLabelFactory
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var labelFactory(get, set):Function;
	private var _labelFactory:Function;
	private function get_labelFactory():Function { return this._labelFactory; }
	private function set_labelFactory(value:Function):Function
	{
		if (this._labelFactory == value)
		{
			return value;
		}
		this._labelFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._labelFactory;
	}
	
	/**
	 * @private
	 */
	private var _onLabelFontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var onLabelFontStyles(get, set):TextFormat;
	private function get_onLabelFontStyles():TextFormat { return this._onLabelFontStylesSet.format; }
	private function set_onLabelFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("onLabelFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("onLabelFontStyles");
		}
		
		var oldValue:TextFormat = this._onLabelFontStylesSet.format;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._onLabelFontStylesSet.format = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var onLabelDisabledFontStyles(get, set):TextFormat;
	private function get_onLabelDisabledFontStyles():TextFormat { return this._onLabelFontStylesSet.disabledFormat; }
	private function set_onLabelDisabledFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("onLabelDisabledFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("onLabelDisabledFontStyles");
		}
		
		var oldValue:TextFormat = this._onLabelFontStylesSet.disabledFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._onLabelFontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var onLabelSelectedFontStyles(get, set):TextFormat;
	private function get_onLabelSelectedFontStyles():TextFormat { return this._onLabelFontStylesSet.selectedFormat; }
	private function set_onLabelSelectedFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("onLabelSelectedFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("onLabelSelectedFontStyles");
		}
		
		var oldValue:TextFormat = this._onLabelFontStylesSet.selectedFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._onLabelFontStylesSet.selectedFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * A function used to instantiate the toggle switch's on label text
	 * renderer sub-component. The on label text renderer must be an
	 * instance of <code>ITextRenderer</code>. This factory can be used to
	 * change properties of the on label text renderer when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to style the on label
	 * text renderer.
	 *
	 * <p>If an <code>onLabelFactory</code> is not provided, the default
	 * <code>labelFactory</code> will be used.</p>
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, the toggle switch uses a custom on label
	 * factory:</p>
	 *
	 * <listing version="3.0">
	 * toggle.onLabelFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see #labelFactory
	 * @see #offLabelFactory
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var onLabelFactory(get, set):Function;
	private var _onLabelFactory:Function;
	private function get_onLabelFactory():Function { return this._onLabelFactory; }
	private function set_onLabelFactory(value:Function):Function
	{
		if (this._onLabelFactory == value)
		{
			return value;
		}
		this._onLabelFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._onLabelFactory;
	}
	
	/**
	 * @private
	 */
	public var customOnLabelStyleName(get, set):String;
	private var _customOnLabelStyleName:String;
	private function get_customOnLabelStyleName():String { return this._customOnLabelStyleName; }
	private function set_customOnLabelStyleName(value:String):String
	{
		if (this.processStyleRestriction("customOnLabelStyleName"))
		{
			return value;
		}
		if (this._customOnLabelStyleName == value)
		{
			return value;
		}
		this._customOnLabelStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customOnLabelStyleName;
	}
	
	/**
	 * @private
	 */
	private var _offLabelFontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var offLabelFontStyles(get, set):TextFormat;
	private function get_offLabelFontStyles():TextFormat { return this._offLabelFontStylesSet.format; }
	private function set_offLabelFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("offLabelFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("offLabelFontStyles");
		}
		
		var oldValue:TextFormat = this._offLabelFontStylesSet.format;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._offLabelFontStylesSet.format = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var offLabelDisabledFontStyles(get, set):TextFormat;
	private function get_offLabelDisabledFontStyles():TextFormat { return this._offLabelFontStylesSet.disabledFormat; }
	private function set_offLabelDisabledFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("offLabelDisabledFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("offLabelDisabledFontStyles");
		}
		
		var oldValue:TextFormat = this._offLabelFontStylesSet.disabledFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._offLabelFontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var offLabelSelectedFontStyles(get, set):TextFormat;
	private function get_offLabelSelectedFontStyles():TextFormat { return this._offLabelFontStylesSet.selectedFormat; }
	private function set_offLabelSelectedFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("offLabelSelectedFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("offLabelSelectedFontStyles");
		}
		
		var oldValue:TextFormat = this._offLabelFontStylesSet.selectedFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._offLabelFontStylesSet.selectedFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * A function used to instantiate the toggle switch's off label text
	 * renderer sub-component. The off label text renderer must be an
	 * instance of <code>ITextRenderer</code>. This factory can be used to
	 * change properties of the off label text renderer when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to style the off label
	 * text renderer.
	 *
	 * <p>If an <code>offLabelFactory</code> is not provided, the default
	 * <code>labelFactory</code> will be used.</p>
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, the toggle switch uses a custom on label
	 * factory:</p>
	 *
	 * <listing version="3.0">
	 * toggle.offLabelFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see #labelFactory
	 * @see #onLabelFactory
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var offLabelFactory(get, set):Function;
	private var _offLabelFactory:Function;
	private function get_offLabelFactory():Function { return this._offLabelFactory; }
	private function set_offLabelFactory(value:Function):Function
	{
		if (this._offLabelFactory == value)
		{
			return value;
		}
		this._offLabelFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._offLabelFactory;
	}
	
	/**
	 * @private
	 */
	public var customOffLabelStyleName(get, set):String;
	private var _customOffLabelStyleName:String;
	private function get_customOffLabelStyleName():String { return this._customOffLabelStyleName; }
	private function set_customOffLabelStyleName(value:String):String
	{
		if (this.processStyleRestriction("customOffLabelStyleName"))
		{
			return value;
		}
		if (this._customOffLabelStyleName == value)
		{
			return value;
		}
		this._customOffLabelStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customOffLabelStyleName;
	}
	
	/**
	 * @private
	 */
	private var _onTrackSkinExplicitWidth:Float;

	/**
	 * @private
	 */
	private var _onTrackSkinExplicitHeight:Float;

	/**
	 * @private
	 */
	private var _onTrackSkinExplicitMinWidth:Float;

	/**
	 * @private
	 */
	private var _onTrackSkinExplicitMinHeight:Float;

	/**
	 * @private
	 */
	private var _offTrackSkinExplicitWidth:Float;

	/**
	 * @private
	 */
	private var _offTrackSkinExplicitHeight:Float;

	/**
	 * @private
	 */
	private var _offTrackSkinExplicitMinWidth:Float;

	/**
	 * @private
	 */
	private var _offTrackSkinExplicitMinHeight:Float;
	
	/**
	 * Indicates if the toggle switch is selected (ON) or not (OFF).
	 *
	 * <p>In the following example, the toggle switch is selected:</p>
	 *
	 * <listing version="3.0">
	 * toggle.isSelected = true;</listing>
	 *
	 * @default false
	 *
	 * @see #setSelectionWithAnimation()
	 */
	public var isSelected(get, set):Bool;
	private var _isSelected:Bool = false;
	private function get_isSelected():Bool { return this._isSelected; }
	private function set_isSelected(value:Bool):Bool
	{
		this._animateSelectionChange = false;
		if (this._isSelected == value)
		{
			return value;
		}
		this._isSelected = value;
		this.resetState();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
		return this._isSelected;
	}
	
	/**
	 * @private
	 */
	public var toggleThumbSelection(get, set):Bool;
	private var _toggleThumbSelection:Bool = false;
	private function get_toggleThumbSelection():Bool { return this._toggleThumbSelection; }
	private function set_toggleThumbSelection(value:Bool):Bool
	{
		if (this.processStyleRestriction("toggleThumbSelection"))
		{
			return value;
		}
		if (this._toggleThumbSelection == value)
		{
			return value;
		}
		this._toggleThumbSelection = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._toggleThumbSelection;
	}
	
	/**
	 * @private
	 */
	public var toggleDuration(get, set):Float;
	private var _toggleDuration:Float = 0.15;
	private function get_toggleDuration():Float { return this._toggleDuration; }
	private function set_toggleDuration(value:Float):Float
	{
		if (this.processStyleRestriction("toggleDuration"))
		{
			return value;
		}
		return this._toggleDuration = value;
	}
	
	/**
	 * @private
	 */
	public var toggleEase(get, set):Dynamic;
	private var _toggleEase:Dynamic = Transitions.EASE_OUT;
	private function get_toggleEase():Dynamic { return this._toggleEase; }
	private function set_toggleEase(value:Dynamic):Dynamic
	{
		if (this.processStyleRestriction("toggleEase"))
		{
			return value;
		}
		return this._toggleEase = value;
	}
	
	/**
	 * @private
	 */
	public var onText(get, set):String;
	private var _onText:String = "ON";
	private function get_onText():String { return this._onText; }
	private function set_onText(value:String):String
	{
		if (value == null)
		{
			value = "";
		}
		if (this.processStyleRestriction("onText"))
		{
			return value;
		}
		if (this._onText == value)
		{
			return value;
		}
		this._onText = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._onText;
	}
	
	/**
	 * @private
	 */
	public var offText(get, set):String;
	private var _offText:String = "OFF";
	private function get_offText():String { return this._offText; }
	private function set_offText(value:String):String
	{
		if (value == null)
		{
			value = "";
		}
		if (this.processStyleRestriction("offText"))
		{
			return value;
		}
		if (this._offText == value)
		{
			return value;
		}
		this._offText = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._offText;
	}
	
	/**
	 * @private
	 */
	private var _toggleTween:Tween;

	/**
	 * @private
	 */
	private var _ignoreTapHandler:Bool = false;

	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _thumbStartX:Float;

	/**
	 * @private
	 */
	private var _touchStartX:Float;

	/**
	 * @private
	 */
	private var _animateSelectionChange:Bool = false;
	
	/**
	 * A function used to generate the toggle switch's "on" track
	 * sub-component. The "on" track must be an instance of
	 * <code>BasicButton</code> (or a subclass). This factory can be used to
	 * change properties on the "on" track when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the "on"
	 * track.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom on track factory is passed to
	 * the toggle switch:</p>
	 *
	 * <listing version="3.0">
	 * toggle.onTrackFactory = function():BasicButton
	 * {
	 *     var onTrack:BasicButton = new BasicButton();
	 *     onTrack.defaultSkin = new Image( texture );
	 *     return onTrack;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var onTrackFactory(get, set):Function;
	private var _onTrackFactory:Function;
	private function get_onTrackFactory():Function { return this._onTrackFactory; }
	private function set_onTrackFactory(value:Function):Function
	{
		if (this._onTrackFactory == value)
		{
			return value;
		}
		this._onTrackFactory = value;
		this.invalidate(INVALIDATION_FLAG_ON_TRACK_FACTORY);
		return this._onTrackFactory;
	}
	
	/**
	 * @private
	 */
	public var customOnTrackStyleName(get, set):String;
	private var _customOnTrackStyleName:String;
	private function get_customOnTrackStyleName():String { return this._customOnTrackStyleName; }
	private function set_customOnTrackStyleName(value:String):String
	{
		if (this.processStyleRestriction("customOnTrackStyleName"))
		{
			return value;
		}
		if (this._customOnTrackStyleName == value)
		{
			return value;
		}
		this._customOnTrackStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ON_TRACK_FACTORY);
		return this._customOnTrackStyleName;
	}
	
	/**
	 * An object that stores properties for the toggle switch's "on" track,
	 * and the properties will be passed down to the "on" track when the
	 * toggle switch validates. For a list of available properties,
	 * refer to <a href="BasicButton.html"><code>feathers.controls.BasicButton</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>onTrackFactory</code> function
	 * instead of using <code>onTrackProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the toggle switch's on track properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * toggle.onTrackProperties.defaultSkin = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 * @see #onTrackFactory
	 */
	public var onTrackProperties(get, set):PropertyProxy;
	private var _onTrackProperties:PropertyProxy;
	private function get_onTrackProperties():PropertyProxy
	{
		if (this._onTrackProperties == null)
		{
			this._onTrackProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._onTrackProperties;
	}
	
	private function set_onTrackProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._onTrackProperties == value)
		{
			return value;
		}
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._onTrackProperties != null)
		{
			//this._onTrackProperties.removeOnChangeCallback(childProperties_onChange);
			this._onTrackProperties.dispose();
		}
		this._onTrackProperties = value;
		if (this._onTrackProperties != null)
		{
			this._onTrackProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._onTrackProperties;
	}
	
	/**
	 * A function used to generate the toggle switch's "off" track
	 * sub-component. The "off" track must be an instance of
	 * <code>BasicButton</code> (or a subclass). This factory can be used to
	 * change properties on the "off" track when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the "off"
	 * track.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom off track factory is passed to
	 * the toggle switch:</p>
	 *
	 * <listing version="3.0">
	 * toggle.offTrackFactory = function():BasicButton
	 * {
	 *     var offTrack:BasicButton = new BasicButton();
	 *     offTrack.defaultSkin = new Image( texture );
	 *     return offTrack;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var offTrackFactory(get, set):Function;
	private var _offTrackFactory:Function;
	private function get_offTrackFactory():Function { return this._offTrackFactory; }
	private function set_offTrackFactory(value:Function):Function
	{
		if (this._offTrackFactory == value)
		{
			return value;
		}
		this._offTrackFactory = value;
		this.invalidate(INVALIDATION_FLAG_OFF_TRACK_FACTORY);
		return this._offTrackFactory;
	}
	
	/**
	 * @private
	 */
	public var customOffTrackStyleName(get, set):String;
	private var _customOffTrackStyleName:String;
	private function get_customOffTrackStyleName():String { return this._customOffTrackStyleName; }
	private function set_customOffTrackStyleName(value:String):String
	{
		if (this.processStyleRestriction("customOffTrackStyleName"))
		{
			return value;
		}
		if (this._customOffTrackStyleName == value)
		{
			return value;
		}
		this._customOffTrackStyleName = value;
		this.invalidate(INVALIDATION_FLAG_OFF_TRACK_FACTORY);
		return this._customOffTrackStyleName;
	}
	
	/**
	 * An object that stores properties for the toggle switch's "off" track,
	 * and the properties will be passed down to the "off" track when the
	 * toggle switch validates. For a list of available properties,
	 * refer to <a href="BasicButton.html"><code>feathers.controls.BasicButton</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>offTrackFactory</code> function
	 * instead of using <code>offTrackProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the toggle switch's off track properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * toggle.offTrackProperties.defaultSkin = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 * @see #offTrackFactory
	 */
	public var offTrackProperties(get, set):PropertyProxy;
	private var _offTrackProperties:PropertyProxy;
	private function get_offTrackProperties():PropertyProxy
	{
		if (this._offTrackProperties == null)
		{
			this._offTrackProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._offTrackProperties;
	}
	
	private function set_offTrackProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._offTrackProperties == value)
		{
			return value;
		}
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._offTrackProperties != null)
		{
			//this._offTrackProperties.removeOnChangeCallback(childProperties_onChange);
			this._offTrackProperties.dispose();
		}
		this._offTrackProperties = value;
		if (this._offTrackProperties != null)
		{
			this._offTrackProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._offTrackProperties;
	}
	
	/**
	 * A function used to generate the toggle switch's thumb sub-component.
	 * The thumb must be an instance of <code>BasicButton</code> (or a
	 * subclass). This factory can be used to change properties on the thumb
	 * when it is first created. For instance, if you are skinning Feathers
	 * components without a theme, you might use <code>thumbFactory</code>
	 * to set skins and other styles on the thumb.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():BasicButton</pre>
	 *
	 * <p>In the following example, a custom thumb factory is passed to the
	 * toggle switch:</p>
	 *
	 * <listing version="3.0">
	 * toggle.thumbFactory = function():BasicButton
	 * {
	 *     var button:BasicButton = new BasicButton();
	 *     button.defaultSkin = new Image( texture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.BasicButton
	 */
	public var thumbFactory(get, set):Function;
	private var _thumbFactory:Function;
	private function get_thumbFactory():Function { return this._thumbFactory; }
	private function set_thumbFactory(value:Function):Function
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
	 * An object that stores properties for the toggle switch's thumb
	 * sub-component, and the properties will be passed down to the thumb
	 * when the toggle switch validates. For a list of available properties,
	 * refer to <a href="BasicButton.html"><code>feathers.controls.BasicButton</code></a>.
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
	 * <p>In the following example, the toggle switch's thumb properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * toggle.thumbProperties.defaultSkin = new Image( texture );</listing>
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
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
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
	 * @inheritDoc
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.onTextRenderer == null)
		{
			return this.scaledActualHeight;
		}
		return this.scaleY * (this.onTextRenderer.y + this.onTextRenderer.baseline);
	}
	
	/**
	 * Changes the <code>isSelected</code> property, but animates the thumb
	 * to the new position, as if the user tapped the toggle switch.
	 *
	 * @see #isSelected
	 */
	public function setSelectionWithAnimation(isSelected:Bool):Void
	{
		if (this._isSelected == isSelected)
		{
			return;
		}
		this.isSelected = isSelected;
		this._animateSelectionChange = true;
	}
	
	/**
	 * Gets the font styles to be used to display the toggle switch's on
	 * label text when the toggle switch's <code>currentState</code>
	 * property matches the specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #setOnLabelFontStylesForState()
	 * @see #onLabelFontStyles
	 */
	public function getOnLabelFontStylesForState(state:String):TextFormat
	{
		if (this._onLabelFontStylesSet == null)
		{
			return null;
		}
		return this._onLabelFontStylesSet.getFormatForState(state);
	}
	
	/**
	 * Sets the font styles to be used to display the toggle switch's on
	 * label text when the toggle switch's <code>currentState</code>
	 * property matches the specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, the value of
	 * the <code>onLabelFontStyles</code> property will be used instead.</p>
	 *
	 * <p>Note: if the text renderer has been customized with advanced font
	 * formatting, it may override the values specified with
	 * <code>setOnLabelFontStylesForState()</code> and properties like
	 * <code>onLabelFontStyles</code> and <code>onLabelDisabledFontStyles</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #onLabelFontStyles
	 */
	public function setOnLabelFontStylesForState(state:String, format:TextFormat):Void
	{
		var key:String = "setOnLabelFontStylesForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(key);
		}
		
		var oldValue:TextFormat = this._onLabelFontStylesSet.getFormatForState(state);
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._onLabelFontStylesSet.setFormatForState(state, format);
		if (format != null)
		{
			format.addEventListener(Event.CHANGE, changeHandler);
		}
	}
	
	/**
	 * Gets the font styles to be used to display the toggle switch's off
	 * label text when the toggle switch's <code>currentState</code>
	 * property matches the specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #setOffLabelFontStylesForState()
	 * @see #offLabelFontStyles
	 */
	public function getOffLabelFontStylesForState(state:String):TextFormat
	{
		if (this._offLabelFontStylesSet == null)
		{
			return null;
		}
		return this._offLabelFontStylesSet.getFormatForState(state);
	}
	
	/**
	 * Sets the font styles to be used to display the toggle switch's off
	 * label text when the toggle switch's <code>currentState</code>
	 * property matches the specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, the value of
	 * the <code>offLabelFontStyles</code> property will be used instead.</p>
	 *
	 * <p>Note: if the text renderer has been customized with advanced font
	 * formatting, it may override the values specified with
	 * <code>setOffLabelFontStylesForState()</code> and properties like
	 * <code>offLabelFontStyles</code> and <code>offLabelDisabledFontStyles</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #offLabelFontStyles
	 */
	public function setOffLabelFontStylesForState(state:String, format:TextFormat):Void
	{
		var key:String = "setOffLabelFontStylesForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(key);
		}
		
		var oldValue:TextFormat = this._offLabelFontStylesSet.getFormatForState(state);
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._offLabelFontStylesSet.setFormatForState(state, format);
		if (format != null)
		{
			format.addEventListener(Event.CHANGE, changeHandler);
		}
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._onLabelFontStylesSet != null)
		{
			this._onLabelFontStylesSet.dispose();
			this._onLabelFontStylesSet = null;
		}
		if (this._offLabelFontStylesSet != null)
		{
			this._offLabelFontStylesSet.dispose();
			this._offLabelFontStylesSet = null;
		}
		if (this._defaultLabelProperties != null)
		{
			this._defaultLabelProperties.dispose();
			this._defaultLabelProperties = null;
		}
		if (this._disabledLabelProperties != null)
		{
			this._disabledLabelProperties.dispose();
			this._disabledLabelProperties = null;
		}
		if (this._offLabelProperties != null)
		{
			this._offLabelProperties.dispose();
			this._offLabelProperties = null;
		}
		if (this._offTrackProperties != null)
		{
			this._offTrackProperties.dispose();
			this._offTrackProperties = null;
		}
		if (this._onLabelProperties != null)
		{
			this._onLabelProperties.dispose();
			this._onLabelProperties = null;
		}
		if (this._onTrackProperties != null)
		{
			this._onTrackProperties.dispose();
			this._onTrackProperties = null;
		}
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
		var selectionInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var focusInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_FOCUS);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var textRendererInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		var thumbFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_THUMB_FACTORY);
		var onTrackFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_ON_TRACK_FACTORY);
		var offTrackFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_OFF_TRACK_FACTORY);
		
		if (thumbFactoryInvalid)
		{
			this.createThumb();
		}
		
		if (onTrackFactoryInvalid)
		{
			this.createOnTrack();
		}
		
		if (offTrackFactoryInvalid || layoutInvalid)
		{
			this.createOffTrack();
		}
		
		if (textRendererInvalid)
		{
			this.createLabels();
		}
		
		if (textRendererInvalid || stylesInvalid || stateInvalid)
		{
			this.refreshOnLabelStyles();
			this.refreshOffLabelStyles();
		}
		
		if (thumbFactoryInvalid || stylesInvalid)
		{
			this.refreshThumbStyles();
		}
		if (onTrackFactoryInvalid || stylesInvalid)
		{
			this.refreshOnTrackStyles();
		}
		if ((offTrackFactoryInvalid || layoutInvalid || stylesInvalid) && this.offTrack != null)
		{
			this.refreshOffTrackStyles();
		}
		
		if (stateInvalid || layoutInvalid || thumbFactoryInvalid || onTrackFactoryInvalid ||
			onTrackFactoryInvalid || textRendererInvalid)
		{
			this.refreshEnabled();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		if (sizeInvalid || stylesInvalid || selectionInvalid)
		{
			this.updateSelection();
		}
		
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
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if(!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		var isSingle:Bool = this._trackLayoutMode == TrackLayoutMode.SINGLE;
		if (needsWidth)
		{
			this.onTrack.width = this._onTrackSkinExplicitWidth;
		}
		else if (isSingle)
		{
			this.onTrack.width = this._explicitWidth;
		}
		var measureOnTrack:IMeasureDisplayObject = null;
		if (Std.isOfType(this.onTrack, IMeasureDisplayObject))
		{
			measureOnTrack = cast this.onTrack;
			if (needsMinWidth)
			{
				measureOnTrack.minWidth = this._onTrackSkinExplicitMinWidth;
			}
			else if (isSingle)
			{
				var minTrackMinWidth:Float = this._explicitMinWidth;
				if (this._onTrackSkinExplicitMinWidth > minTrackMinWidth)
				{
					minTrackMinWidth = this._onTrackSkinExplicitMinWidth;
				}
				measureOnTrack.minWidth = minTrackMinWidth;
			}
		}
		var measureOffTrack:IMeasureDisplayObject = null;
		if (!isSingle)
		{
			if (needsWidth)
			{
				this.offTrack.width = this._offTrackSkinExplicitWidth;
			}
			if (Std.isOfType(this.offTrack, IMeasureDisplayObject))
			{
				measureOffTrack = cast this.offTrack;
				if (needsMinWidth)
				{
					measureOffTrack.minWidth = this._offTrackSkinExplicitMinWidth;
				}
			}
		}
		if (Std.isOfType(this.onTrack, IValidating))
		{
			cast(this.onTrack, IValidating).validate();
		}
		if (Std.isOfType(this.offTrack, IValidating))
		{
			cast(this.offTrack, IValidating).validate();
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
			newWidth = this.onTrack.width;
			if (!isSingle) //split
			{
				if (this.offTrack.width > newWidth)
				{
					newWidth = this.offTrack.width;
				}
				newWidth += this.thumb.width / 2;
			}
		}
		if (needsHeight)
		{
			newHeight = this.onTrack.height;
			if (!isSingle && //split
				this.offTrack.height > newHeight)
			{
				newHeight = this.offTrack.height;
			}
			if (this.thumb.height > newHeight)
			{
				newHeight = this.thumb.height;
			}
		}
		if (needsMinWidth)
		{
			if (measureOnTrack != null)
			{
				newMinWidth = measureOnTrack.minWidth;
			}
			else
			{
				newMinWidth = this.onTrack.width;
			}
			if (!isSingle) //split
			{
				if (measureOffTrack != null)
				{
					if (measureOffTrack.minWidth > newMinWidth)
					{
						newMinWidth = measureOffTrack.minWidth;
					}
				}
				else if (this.offTrack.width > newMinWidth)
				{
					newMinWidth = this.offTrack.width;
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
			if (measureOnTrack != null)
			{
				newMinHeight = measureOnTrack.minHeight;
			}
			else
			{
				newMinHeight = this.onTrack.height;
			}
			if (!isSingle) //split
			{
				if (measureOffTrack != null)
				{
					if (measureOffTrack.minHeight > newMinHeight)
					{
						newMinHeight = measureOffTrack.minHeight;
					}
				}
				else if (this.offTrack.height > newMinHeight)
				{
					newMinHeight = this.offTrack.height;
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
		
		var factory:Function = this._thumbFactory != null ? this._thumbFactory : defaultThumbFactory;
		var thumbStyleName:String = this._customThumbStyleName != null ? this._customThumbStyleName : this.thumbStyleName;
		var thumb:BasicButton = cast factory();
		thumb.styleNameList.add(thumbStyleName);
		thumb.keepDownStateOnRollOut = true;
		thumb.addEventListener(TouchEvent.TOUCH, thumb_touchHandler);
		this.addChild(thumb);
		this.thumb = thumb;
	}
	
	/**
	 * Creates and adds the <code>onTrack</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #onTrack
	 * @see #onTrackFactory
	 * @see #style:customOnTrackStyleName
	 */
	private function createOnTrack():Void
	{
		if (this.onTrack != null)
		{
			this.onTrack.removeFromParent(true);
			this.onTrack = null;
		}
		
		var factory:Function = this._onTrackFactory != null ? this._onTrackFactory : defaultOnTrackFactory;
		var onTrackStyleName:String = this._customOnTrackStyleName != null ? this._customOnTrackStyleName : this.onTrackStyleName;
		var onTrack:BasicButton = cast factory();
		onTrack.styleNameList.add(onTrackStyleName);
		onTrack.keepDownStateOnRollOut = true;
		this.addChildAt(onTrack, 0);
		this.onTrack = onTrack;
		
		if (Std.isOfType(this.onTrack, IFeathersControl))
		{
			cast(this.onTrack, IFeathersControl).initializeNow();
		}
		if (Std.isOfType(this.onTrack, IMeasureDisplayObject))
		{
			var measureOnTrack:IMeasureDisplayObject = cast this.onTrack;
			this._onTrackSkinExplicitWidth = measureOnTrack.explicitWidth;
			this._onTrackSkinExplicitHeight = measureOnTrack.explicitHeight;
			this._onTrackSkinExplicitMinWidth = measureOnTrack.explicitMinWidth;
			this._onTrackSkinExplicitMinHeight = measureOnTrack.explicitMinHeight;
		}
		else
		{
			//this is a regular display object, and we'll treat its
			//measurements as explicit when we auto-size the toggle switch
			this._onTrackSkinExplicitWidth = this.onTrack.width;
			this._onTrackSkinExplicitHeight = this.onTrack.height;
			this._onTrackSkinExplicitMinWidth = this._onTrackSkinExplicitWidth;
			this._onTrackSkinExplicitMinHeight = this._onTrackSkinExplicitHeight;
		}
	}
	
	/**
	 * Creates and adds the <code>offTrack</code> sub-component and
	 * removes the old instance, if one exists. If the off track is not
	 * needed, it will not be created.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #offTrack
	 * @see #offTrackFactory
	 * @see #style:customOffTrackStyleName
	 */
	private function createOffTrack():Void
	{
		if (this.offTrack != null)
		{
			this.offTrack.removeFromParent(true);
			this.offTrack = null;
		}
		if (this._trackLayoutMode == TrackLayoutMode.SINGLE)
		{
			return;
		}
		var factory:Function = this._offTrackFactory != null ? this._offTrackFactory : defaultOffTrackFactory;
		var offTrackStyleName:String = this._customOffTrackStyleName != null ? this._customOffTrackStyleName : this.offTrackStyleName;
		var offTrack:BasicButton = cast factory();
		offTrack.styleNameList.add(offTrackStyleName);
		offTrack.keepDownStateOnRollOut = true;
		this.addChildAt(offTrack, 1);
		this.offTrack = offTrack;
		
		if (Std.isOfType(this.offTrack, IFeathersControl))
		{
			cast(this.offTrack, IFeathersControl).initializeNow();
		}
		if (Std.isOfType(this.offTrack, IMeasureDisplayObject))
		{
			var measureOffTrack:IMeasureDisplayObject = cast this.offTrack;
			this._offTrackSkinExplicitWidth = measureOffTrack.explicitWidth;
			this._offTrackSkinExplicitHeight = measureOffTrack.explicitHeight;
			this._offTrackSkinExplicitMinWidth = measureOffTrack.explicitMinWidth;
			this._offTrackSkinExplicitMinHeight = measureOffTrack.explicitMinHeight;
		}
		else
		{
			//this is a regular display object, and we'll treat its
			//measurements as explicit when we auto-size the toggle switch
			this._offTrackSkinExplicitWidth = this.offTrack.width;
			this._offTrackSkinExplicitHeight = this.offTrack.height;
			this._offTrackSkinExplicitMinWidth = this._offTrackSkinExplicitWidth;
			this._offTrackSkinExplicitMinHeight = this._offTrackSkinExplicitHeight;
		}
	}
	
	/**
	 * @private
	 */
	private function createLabels():Void
	{
		if (this.offTextRenderer != null)
		{
			this.removeChild(cast this.offTextRenderer, true);
			this.offTextRenderer = null;
		}
		if (this.onTextRenderer != null)
		{
			this.removeChild(cast this.onTextRenderer, true);
			this.onTextRenderer = null;
		}
		
		var index:Int = this.getChildIndex(this.thumb);
		var offLabelFactory:Function = this._offLabelFactory;
		if (offLabelFactory == null)
		{
			offLabelFactory = this._labelFactory;
		}
		if (offLabelFactory == null)
		{
			offLabelFactory = FeathersControl.defaultTextRendererFactory;
		}
		this.offTextRenderer = cast offLabelFactory();
		this.offTextRenderer.stateContext = this;
		var offLabelStyleName:String = this._customOffLabelStyleName != null ? this._customOffLabelStyleName : this.offLabelStyleName;
		this.offTextRenderer.styleNameList.add(offLabelStyleName);
		var mask:Quad = new Quad(1, 1, 0xff00ff);
		//the initial dimensions cannot be 0 or there's a runtime error
		mask.width = 0;
		mask.height = 0;
		this.offTextRenderer.mask = mask;
		this.addChildAt(cast this.offTextRenderer, index);
		
		var onLabelFactory:Function = this._onLabelFactory;
		if (onLabelFactory == null)
		{
			onLabelFactory = this._labelFactory;
		}
		if (onLabelFactory == null)
		{
			onLabelFactory = FeathersControl.defaultTextRendererFactory;
		}
		this.onTextRenderer = cast onLabelFactory();
		this.onTextRenderer.stateContext = this;
		var onLabelStyleName:String = this._customOnLabelStyleName != null ? this._customOnLabelStyleName : this.onLabelStyleName;
		this.onTextRenderer.styleNameList.add(onLabelStyleName);
		mask = new Quad(1, 1, 0xff00ff);
		//the initial dimensions cannot be 0 or there's a runtime error
		mask.width = 0;
		mask.height = 0;
		this.onTextRenderer.mask = mask;
		this.addChildAt(cast this.onTextRenderer, index);
	}
	
	/**
	 * @private
	 */
	private function changeState(state:String):Void
	{
		if (this._currentState == state)
		{
			return;
		}
		this._currentState = state;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		this.dispatchEventWith(FeathersEventType.STATE_CHANGE);
	}
	
	/**
	 * @private
	 */
	private function resetState():Void
	{
		if (this._isEnabled)
		{
			if (this._isSelected)
			{
				this.changeState(ToggleState.SELECTED);
			}
			else
			{
				this.changeState(ToggleState.NOT_SELECTED);
			}
		}
		else
		{
			if (this._isSelected)
			{
				this.changeState(ToggleState.SELECTED_AND_DISABLED);
			}
			else
			{
				this.changeState(ToggleState.DISABLED);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
		}
		this.thumb.y = (this.actualHeight - this.thumb.height) / 2;
		
		var maxLabelWidth:Float = Math.max(0, this.actualWidth - this.thumb.width - this._paddingLeft - this._paddingRight);
		var totalLabelHeight:Float = Math.max(this.onTextRenderer.height, this.offTextRenderer.height);
		
		var mask:DisplayObject = this.onTextRenderer.mask;
		mask.width = maxLabelWidth;
		mask.height = totalLabelHeight;
		
		this.onTextRenderer.y = (this.actualHeight - totalLabelHeight) / 2;
		
		mask = this.offTextRenderer.mask;
		mask.width = maxLabelWidth;
		mask.height = totalLabelHeight;
		
		this.offTextRenderer.y = (this.actualHeight - totalLabelHeight) / 2;
		
		this.layoutTracks();
	}
	
	/**
	 * @private
	 */
	private function layoutTracks():Void
	{
		var maxLabelWidth:Float = Math.max(0, this.actualWidth - this.thumb.width - this._paddingLeft - this._paddingRight);
		var thumbOffset:Float = this.thumb.x - this._paddingLeft;
		
		var onScrollOffset:Float = maxLabelWidth - thumbOffset - (maxLabelWidth - this.onTextRenderer.width) / 2;
		var currentMask:DisplayObject = this.onTextRenderer.mask;
		currentMask.x = onScrollOffset;
		this.onTextRenderer.x = this._paddingLeft - onScrollOffset;
		
		var offScrollOffset:Float = -thumbOffset - (maxLabelWidth - this.offTextRenderer.width) / 2;
		currentMask = this.offTextRenderer.mask;
		currentMask.x = offScrollOffset;
		this.offTextRenderer.x = this.actualWidth - this._paddingRight - maxLabelWidth - offScrollOffset;
		
		if (this._trackLayoutMode == TrackLayoutMode.SPLIT)
		{
			this.layoutTrackWithOnOff();
		}
		else
		{
			this.layoutTrackWithSingle();
		}
	}
	
	/**
	 * @private
	 */
	private function updateSelection():Void
	{
		if (Std.isOfType(this.thumb, IToggle))
		{
			var toggleThumb:IToggle = cast this.thumb;
			if (this._toggleThumbSelection)
			{
				toggleThumb.isSelected = this._isSelected;
			}
			else
			{
				toggleThumb.isSelected = false;
			}
		}
		if (Std.isOfType(this.thumb, IValidating))
		{
			cast(this.thumb, IValidating).validate();
		}
		
		var xPosition:Float = this._paddingLeft;
		if (this._isSelected)
		{
			xPosition = this.actualWidth - this.thumb.width - this._paddingRight;
		}
		
		//stop the tween, no matter what
		if (this._toggleTween != null)
		{
			Starling.currentJuggler.remove(this._toggleTween);
			this._toggleTween = null;
		}
		
		if (this._animateSelectionChange)
		{
			this._toggleTween = new Tween(this.thumb, this._toggleDuration, this._toggleEase);
			this._toggleTween.animate("x", xPosition);
			this._toggleTween.onUpdate = selectionTween_onUpdate;
			this._toggleTween.onComplete = selectionTween_onComplete;
			Starling.currentJuggler.add(this._toggleTween);
		}
		else
		{
			this.thumb.x = xPosition;
		}
		this._animateSelectionChange = false;
	}
	
	/**
	 * @private
	 */
	private function refreshOnLabelStyles():Void
	{
		//no need to style the label field if there's no text to display
		if (!this._showLabels || !this._showThumb)
		{
			this.onTextRenderer.visible = false;
			return;
		}
		
		this.onTextRenderer.fontStyles = this._onLabelFontStylesSet;
		var properties:PropertyProxy = null;
		if (!this._isEnabled)
		{
			properties = this._disabledLabelProperties;
		}
		if (properties == null && this._onLabelProperties != null)
		{
			properties = this._onLabelProperties;
		}
		if (properties == null)
		{
			properties = this._defaultLabelProperties;
		}
		
		this.onTextRenderer.text = this._onText;
		if (properties != null)
		{
			//var displayRenderer:DisplayObject = cast this.onTextRenderer;
			var propertyValue:Dynamic;
			for (propertyName in properties)
			{
				propertyValue = properties[propertyName];
				Reflect.setProperty(this.onTextRenderer, propertyName, propertyValue);
			}
		}
		this.onTextRenderer.validate();
		this.onTextRenderer.visible = true;
	}
	
	/**
	 * @private
	 */
	private function refreshOffLabelStyles():Void
	{
		//no need to style the label field if there's no text to display
		if (!this._showLabels || !this._showThumb)
		{
			this.offTextRenderer.visible = false;
			return;
		}
		
		this.offTextRenderer.fontStyles = this._offLabelFontStylesSet;
		var properties:PropertyProxy = null;
		if (!this._isEnabled)
		{
			properties = this._disabledLabelProperties;
		}
		if (properties == null && this._offLabelProperties != null)
		{
			properties = this._offLabelProperties;
		}
		if (properties == null)
		{
			properties = this._defaultLabelProperties;
		}
		
		this.offTextRenderer.text = this._offText;
		if (properties != null)
		{
			//var displayRenderer:DisplayObject = DisplayObject(this.offTextRenderer);
			//for(var propertyName:String in properties)
			//{
				//var propertyValue:Object = properties[propertyName];
				//displayRenderer[propertyName] = propertyValue;
			//}
			var propertyValue:Dynamic;
			for (propertyName in properties)
			{
				propertyValue = properties[propertyName];
				Reflect.setProperty(this.offTextRenderer, propertyName, propertyValue);
			}
		}
		this.offTextRenderer.validate();
		this.offTextRenderer.visible = true;
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
				Reflect.setProperty(this.thumb, propertyName, propertyValue);
			}
		}
		this.thumb.visible = this._showThumb;
	}
	
	/**
	 * @private
	 */
	private function refreshOnTrackStyles():Void
	{
		if (this._onTrackProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._onTrackProperties)
			{
				propertyValue = this._onTrackProperties[propertyName];
				Reflect.setProperty(this.onTrack, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshOffTrackStyles():Void
	{
		if (this.offTrack == null)
		{
			return;
		}
		if (this._offTrackProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._offTrackProperties)
			{
				propertyValue = this._offTrackProperties[propertyName];
				Reflect.setProperty(this.offTrack, propertyName, propertyValue);
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
		if (Std.isOfType(this.onTrack, IFeathersControl))
		{
			cast(this.onTrack, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (Std.isOfType(this.offTrack, IFeathersControl))
		{
			cast(this.offTrack, IFeathersControl).isEnabled = this._isEnabled;
		}
		this.onTextRenderer.isEnabled = this._isEnabled;
		this.offTextRenderer.isEnabled = this._isEnabled;
	}
	
	/**
	 * @private
	 */
	private function layoutTrackWithOnOff():Void
	{
		var onTrackWidth:Float = Math.fround(this.thumb.x + (this.thumb.width / 2));
		this.onTrack.x = 0;
		this.onTrack.width = onTrackWidth;
		this.offTrack.x = onTrackWidth;
		this.offTrack.width = this.actualWidth - onTrackWidth;
		if (this._trackScaleMode == TrackScaleMode.EXACT_FIT)
		{
			this.onTrack.y = 0;
			this.onTrack.height = this.actualHeight;
			
			this.offTrack.y = 0;
			this.offTrack.height = this.actualHeight;
		}
		
		//final validation to avoid juggler next frame issues
		if (Std.isOfType(this.onTrack, IValidating))
		{
			cast(this.onTrack, IValidating).validate();
		}
		if (Std.isOfType(this.offTrack, IValidating))
		{
			cast(this.offTrack, IValidating).validate();
		}
		
		if (this._trackScaleMode == TrackScaleMode.DIRECTIONAL)
		{
			this.onTrack.y = Math.fround((this.actualHeight - this.onTrack.height) / 2);
			this.offTrack.y = Math.fround((this.actualHeight - this.offTrack.height) / 2);
		}
	}
	
	/**
	 * @private
	 */
	private function layoutTrackWithSingle():Void
	{
		this.onTrack.x = 0;
		this.onTrack.width = this.actualWidth;
		if (this._trackScaleMode == TrackScaleMode.EXACT_FIT)
		{
			this.onTrack.y = 0;
			this.onTrack.height = this.actualHeight;
		}
		else
		{
			//we'll calculate y after validation in case the track needs
			//to auto-size
			this.onTrack.height = this._onTrackSkinExplicitHeight;
		}
		
		//final validation to avoid juggler next frame issues
		if (Std.isOfType(this.onTrack, IValidating))
		{
			cast(this.onTrack, IValidating).validate();
		}
		
		if (this._trackScaleMode == TrackScaleMode.DIRECTIONAL)
		{
			this.onTrack.y = Math.fround((this.actualHeight - this.onTrack.height) / 2);
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
	private function toggleSwitch_removedFromStageHandler(event:Event):Void
	{
		this._touchPointID = -1;
	}

	/**
	 * @private
	 */
	override function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
	}

	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		super.focusOutHandler(event);
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		this.stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
	}
	
	/**
	 * @private
	 */
	private function toggleSwitch_touchHandler(event:TouchEvent):Void
	{
		if (this._ignoreTapHandler)
		{
			this._ignoreTapHandler = false;
			return;
		}
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
		if (touch == null)
		{
			return;
		}
		this._touchPointID = -1;
		touch.getLocation(this.stage, HELPER_POINT);
		var isInBounds:Bool = this.contains(this.stage.hitTest(HELPER_POINT));
		if (isInBounds)
		{
			this.setSelectionWithAnimation(!this._isSelected);
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
		if (this._touchPointID >= 0)
		{
			touch = event.getTouch(this.thumb, null, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			touch.getLocation(this, HELPER_POINT);
			var trackScrollableWidth:Float = this.actualWidth - this._paddingLeft - this._paddingRight - this.thumb.width;
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
				var xOffset:Float = HELPER_POINT.x - this._touchStartX;
				var xPosition:Float = Math.min(Math.max(this._paddingLeft, this._thumbStartX + xOffset), this._paddingLeft + trackScrollableWidth);
				this.thumb.x = xPosition;
				this.layoutTracks();
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				var pixelsMoved:Float = Math.abs(HELPER_POINT.x - this._touchStartX);
				var inchesMoved:Float = pixelsMoved / DeviceCapabilities.dpi;
				if (inchesMoved > MINIMUM_DRAG_DISTANCE || (SystemUtil.isDesktop && pixelsMoved >= 1))
				{
					this._touchPointID = -1;
					this._ignoreTapHandler = true;
					this.setSelectionWithAnimation(this.thumb.x > (this._paddingLeft + trackScrollableWidth / 2));
					//we still need to invalidate, even if there's no change
					//because the thumb may be in the middle!
					this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
				}
			}
		}
		else
		{
			touch = event.getTouch(this.thumb, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			touch.getLocation(this, HELPER_POINT);
			this._touchPointID = touch.id;
			this._thumbStartX = this.thumb.x;
			this._touchStartX = HELPER_POINT.x;
		}
	}
	
	/**
	 * @private
	 */
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.keyCode == Keyboard.ESCAPE)
		{
			this._touchPointID = -1;
		}
		if (this._touchPointID != -1 || !(event.keyCode == Keyboard.SPACE || (event.keyCode == Keyboard.ENTER && (event.keyLocation == KeyLocation.D_PAD || DeviceCapabilities.simulateDPad))))
		{
			return;
		}
		this._touchPointID = MathUtils.INT_MAX;
	}

	/**
	 * @private
	 */
	private function stage_keyUpHandler(event:KeyboardEvent):Void
	{
		if (this._touchPointID != MathUtils.INT_MAX || !(event.keyCode == Keyboard.SPACE || (event.keyCode == Keyboard.ENTER && (event.keyLocation == KeyLocation.D_PAD || DeviceCapabilities.simulateDPad))))
		{
			return;
		}
		this._touchPointID = -1;
		this.setSelectionWithAnimation(!this._isSelected);
	}
	
	/**
	 * @private
	 */
	private function selectionTween_onUpdate():Void
	{
		this.layoutTracks();
	}

	/**
	 * @private
	 */
	private function selectionTween_onComplete():Void
	{
		this._toggleTween = null;
	}

	/**
	 * @private
	 */
	private function fontStyles_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}