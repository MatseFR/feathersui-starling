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
import feathers.core.IStateObserver;
import feathers.core.ITextBaselineControl;
import feathers.core.ITextRenderer;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.skins.IStyleProvider;
import feathers.text.FontStylesSet;
import feathers.utils.keyboard.KeyToState;
import feathers.utils.keyboard.KeyToTrigger;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.touch.LongPress;
import feathers.utils.type.SafeCast;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.rendering.Painter;
import starling.text.TextFormat;
import starling.utils.Pool;

/**
 * A push button control that may be triggered when pressed and released.
 *
 * <p>The following example creates a button, gives it a label and listens
 * for when the button is triggered:</p>
 *
 * <listing version="3.0">
 * var button:Button = new Button();
 * button.label = "Click Me";
 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
 * this.addChild( button );</listing>
 *
 * @see ../../../help/button.html How to use the Feathers Button component
 *
 * @productversion Feathers 1.0.0
 */
class Button extends BasicButton implements IFocusDisplayObject implements ITextBaselineControl
{
	/**
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();
	
	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * label text renderer.
	 *
	 * <p>Note: the label text renderer is not a
	 * <code>feathers.controls.Label</code>. It is an instance of one of the
	 * <code>ITextRenderer</code> implementations.</p>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-button-label";
	
	/**
	 * An alternate style name to use with <code>Button</code> to allow a
	 * theme to give it a more prominent, "call-to-action" style. If a theme
	 * does not provide a style for a call-to-action button, the theme will
	 * automatically fall back to using the default button style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the call-to-action style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_STYLE_NAME_CALL_TO_ACTION_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_CALL_TO_ACTION_BUTTON:String = "feathers-call-to-action-button";
	
	/**
	 * An alternate style name to use with <code>Button</code> to allow a
	 * theme to give it a less prominent, "quiet" style. If a theme does not
	 * provide a style for a quiet button, the theme will automatically fall
	 * back to using the default button style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the quiet button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_QUIET_BUTTON:String = "feathers-quiet-button";
	
	/**
	 * An alternate style name to use with <code>Button</code> to allow a
	 * theme to give it a highly prominent, "danger" style. An example would
	 * be a delete button or some other button that has a destructive action
	 * that cannot be undone if the button is triggered. If a theme does not
	 * provide a style for the danger button, the theme will automatically
	 * fall back to using the default button style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the danger button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_STYLE_NAME_DANGER_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_DANGER_BUTTON:String = "feathers-danger-button";
	
	/**
	 * An alternate style name to use with <code>Button</code> to allow a
	 * theme to give it a "back button" style, perhaps with an arrow
	 * pointing backward. If a theme does not provide a style for a back
	 * button, the theme will automatically fall back to using the default
	 * button skin.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the back button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_STYLE_NAME_BACK_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_BACK_BUTTON:String = "feathers-back-button";
	
	/**
	 * An alternate style name to use with <code>Button</code> to allow a
	 * theme to give it a "forward" button style, perhaps with an arrow
	 * pointing forward. If a theme does not provide a style for a forward
	 * button, the theme will automatically fall back to using the default
	 * button style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the forward button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_STYLE_NAME_FORWARD_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_FORWARD_BUTTON:String = "feathers-forward-button";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>Button</code>
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
		if (this._fontStylesSet == null)
		{
			this._fontStylesSet = new FontStylesSet();
			this._fontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the label text
	 * renderer. This variable is <code>protected</code> so that sub-classes
	 * can customize the label text renderer style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_LABEL</code>.
	 *
	 * <p>To customize the label text renderer style name without
	 * subclassing, see <code>customLabelStyleName</code>.</p>
	 *
	 * @see #style:customLabelStyleName
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var labelStyleName:String = DEFAULT_CHILD_STYLE_NAME_LABEL;
	
	/**
	 * The text renderer for the button's label.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #label
	 * @see #labelFactory
	 * @see #createLabel()
	 */
	private var labelTextRenderer:ITextRenderer;
	
	/**
	 * @private
	 */
	private var _explicitLabelWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitLabelHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitLabelMinWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitLabelMinHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitLabelMaxWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitLabelMaxHeight:Float;
	
	/**
	 * The currently visible icon. The value will be <code>null</code> if
	 * there is no currently visible icon.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var currentIcon:DisplayObject;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Button.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var keyToTrigger:KeyToTrigger;
	
	/**
	 * @private
	 */
	private var keyToState:KeyToState;
	
	/**
	 * @private
	 */
	private var longPress:LongPress;
	
	/**
	 * @private
	 */
	private var dpadEnterKeyToTrigger:KeyToTrigger;
	
	/**
	 * @private
	 */
	private var dpadEnterKeyToState:KeyToState;
	
	/**
	 * The text displayed on the button.
	 *
	 * <p>The following example gives the button some label text:</p>
	 *
	 * <listing version="3.0">
	 * button.label = "Click Me";</listing>
	 *
	 * @default null
	 */
	public var label(get, set):String;
	private var _label:String = null;
	private function get_label():String { return this._label; }
	private function set_label(value:String):String
	{
		if (this._label == value)
		{
			return value;
		}
		this._label = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._label;
	}
	
	/**
	 * @private
	 */
	public var hasLabelTextRenderer(get, set):Bool;
	private var _hasLabelTextRenderer:Bool = true;
	private function get_hasLabelTextRenderer():Bool { return this._hasLabelTextRenderer; }
	private function set_hasLabelTextRenderer(value:Bool):Bool
	{
		if (this.processStyleRestriction("hasLabelTextRenderer"))
		{
			return value;
		}
		if (this._hasLabelTextRenderer == value)
		{
			return value;
		}
		this._hasLabelTextRenderer = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._hasLabelTextRenderer;
	}
	
	/**
	 * @private
	 */
	public var iconPosition(get, set):String;
	private var _iconPosition:String = RelativePosition.LEFT;
	private function get_iconPosition():String { return this._iconPosition; }
	private function set_iconPosition(value:String):String
	{
		if (this.processStyleRestriction("iconPosition"))
		{
			return value;
		}
		if (this._iconPosition == value)
		{
			return value;
		}
		this._iconPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._iconPosition;
	}
	
	/**
	 * @private
	 */
	public var gap(get, set):Float;
	private var _gap:Float = 0;
	private function get_gap():Float { return this._gap; }
	private function set_gap(value:Float):Float
	{
		if (this.processStyleRestriction("gap"))
		{
			return value;
		}
		if (this._gap == value)
		{
			return value;
		}
		this._gap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._gap;
	}
	
	/**
	 * @private
	 */
	public var minGap(get, set):Float;
	private var _minGap:Float = 0;
	private function get_minGap():Float { return this._minGap; }
	private function set_minGap(value:Float):Float
	{
		if (this.processStyleRestriction("minGap"))
		{
			return value;
		}
		if (this._minGap == value)
		{
			return value;
		}
		this._minGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._minGap;
	}
	
	/**
	 * @private
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.CENTER;
	private function get_horizontalAlign():String { return this._horizontalAlign; }
	private function set_horizontalAlign(value:String):String
	{
		if (this.processStyleRestriction("horizontalAlign"))
		{
			return value;
		}
		if (this._horizontalAlign == value)
		{
			return value;
		}
		this._horizontalAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._horizontalAlign;
	}
	
	/**
	 * @private
	 */
	public var verticalAlign(get, set):String;
	private var _verticalAlign:String = VerticalAlign.MIDDLE;
	private function get_verticalAlign():String { return this._verticalAlign; }
	private function set_verticalAlign(value:String):String
	{
		if (this.processStyleRestriction("verticalAlign"))
		{
			return value;
		}
		if (this._verticalAlign == value)
		{
			return value;
		}
		this._verticalAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._verticalAlign;
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
	public var labelOffsetX(get, set):Float;
	private var _labelOffsetX:Float = 0;
	private function get_labelOffsetX():Float { return this._labelOffsetX; }
	private function set_labelOffsetX(value:Float):Float
	{
		if (this.processStyleRestriction("labelOffsetX"))
		{
			return value;
		}
		if (this._labelOffsetX == value)
		{
			return value;
		}
		this._labelOffsetX = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._labelOffsetX;
	}
	
	/**
	 * @private
	 */
	public var labelOffsetY(get, set):Float;
	private var _labelOffsetY:Float = 0;
	private function get_labelOffsetY():Float { return this._labelOffsetY; }
	private function set_labelOffsetY(value:Float):Float
	{
		if (this.processStyleRestriction("labelOffsetY"))
		{
			return value;
		}
		if (this._labelOffsetY == value)
		{
			return value;
		}
		this._labelOffsetY = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._labelOffsetY;
	}
	
	/**
	 * @private
	 */
	public var iconOffsetX(get, set):Float;
	private var _iconOffsetX:Float = 0;
	private function get_iconOffsetX():Float { return this._iconOffsetX; }
	private function set_iconOffsetX(value:Float):Float
	{
		if (this.processStyleRestriction("iconOffsetX"))
		{
			return value;
		}
		if (this._iconOffsetX == value)
		{
			return value;
		}
		this._iconOffsetX = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._iconOffsetX;
	}
	
	/**
	 * @private
	 */
	public var iconOffsetY(get, set):Float;
	private var _iconOffsetY:Float = 0;
	private function get_iconOffsetY():Float { return this._iconOffsetY; }
	private function set_iconOffsetY(value:Float):Float
	{
		if (this.processStyleRestriction("iconOffsetY"))
		{
			return value;
		}
		if (this._iconOffsetY == value)
		{
			return value;
		}
		this._iconOffsetY = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._iconOffsetY;
	}
	
	/**
	 * @private
	 */
	private var _fontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var fontStyles(get, set):TextFormat;
	private function get_fontStyles():TextFormat { return this._fontStylesSet.format; }
	private function set_fontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("fontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("fontStyles");
		}
		
		var oldValue:TextFormat = this._fontStylesSet.format;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.format = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var disabledFontStyles(get, set):TextFormat;
	private function get_disabledFontStyles():TextFormat { return this._fontStylesSet.disabledFormat; }
	private function set_disabledFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("disabledFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("disabledFontStyles");
		}
		
		var oldValue:TextFormat = this._fontStylesSet.disabledFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var wordWrap(get, set):Bool;
	private var _wordWrap:Bool = false;
	private function get_wordWrap():Bool { return this._wordWrap; }
	private function set_wordWrap(value:Bool):Bool
	{
		if (this.processStyleRestriction("wordWrap"))
		{
			return value;
		}
		this._wordWrap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._wordWrap;
	}
	
	/**
	 * A function used to instantiate the button's label text renderer
	 * sub-component. By default, the button will use the global text
	 * renderer factory, <code>FeathersControl.defaultTextRendererFactory()</code>,
	 * to create the label text renderer. The label text renderer must be an
	 * instance of <code>ITextRenderer</code>. To change properties on the
	 * label text renderer, see <code>defaultLabelProperties</code> and the
	 * other "<code>LabelProperties</code>" properties for each button
	 * state.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>The following example gives the button a custom factory for the
	 * label text renderer:</p>
	 *
	 * <listing version="3.0">
	 * button.labelFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var labelFactory(get, set):Void->ITextRenderer;
	private var _labelFactory:Void->ITextRenderer;
	private function get_labelFactory():Void->ITextRenderer { return this._labelFactory; }
	private function set_labelFactory(value:Void->ITextRenderer):Void->ITextRenderer
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
	public var customLabelStyleName(get, set):String;
	private var _customLabelStyleName:String;
	private function get_customLabelStyleName():String { return this._customLabelStyleName; }
	private function set_customLabelStyleName(value:String):String
	{
		if (this.processStyleRestriction("customLabelStyleName"))
		{
			return value;
		}
		if (this._customLabelStyleName == value)
		{
			return value;
		}
		this._customLabelStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customLabelStyleName;
	}
	
	/**
	 * An object that stores properties for the button's label text renderer
	 * when no specific properties are defined for the button's current
	 * state, and the properties will be passed down to the label text
	 * renderer when the button validates. The available properties depend
	 * on which <code>ITextRenderer</code> implementation is returned by
	 * <code>labelFactory</code>. Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>The following example gives the button default label properties to
	 * use for all states when no specific label properties are available
	 * (this example assumes that the label text renderer is a
	 * <code>BitmapFontTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * button.defaultLabelProperties.textFormat = new BitmapFontTextFormat( bitmapFont );
	 * button.defaultLabelProperties.wordWrap = true;</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see #fontStyles
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
		//if (!Std.isOfType(value, PropertyProxyReal))
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
	 * @private
	 */
	public var defaultIcon(get, set):DisplayObject;
	private var _defaultIcon:DisplayObject;
	private function get_defaultIcon():DisplayObject { return this._defaultIcon; }
	private function set_defaultIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("defaultIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._defaultIcon == value)
		{
			return value;
		}
		if (this._defaultIcon != null &&
			this.currentIcon == this._defaultIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentIcon(this._defaultIcon);
			this.currentIcon = null;
		}
		this._defaultIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._defaultIcon;
	}
	
	/**
	 * @private
	 */
	private var _stateToIcon:Map<String, DisplayObject> = new Map<String, DisplayObject>();
	
	/**
	 * @private
	 */
	public var upIcon(get, set):DisplayObject;
	private function get_upIcon():DisplayObject { return this.getIconForState(ButtonState.UP); }
	private function set_upIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.UP, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var downIcon(get, set):DisplayObject;
	private function get_downIcon():DisplayObject { return this.getIconForState(ButtonState.DOWN); }
	private function set_downIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.DOWN, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var hoverIcon(get, set):DisplayObject;
	private function get_hoverIcon():DisplayObject { return this.getIconForState(ButtonState.HOVER); }
	private function set_hoverIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.HOVER, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var disabledIcon(get, set):DisplayObject;
	private function get_disabledIcon():DisplayObject { return this.getIconForState(ButtonState.DISABLED); }
	private function set_disabledIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(ButtonState.DISABLED, value);
		return value;
	}
	
	/**
	 * The duration, in seconds, of a long press.
	 *
	 * <p>The following example changes the long press duration to one full second:</p>
	 *
	 * <listing version="3.0">
	 * button.longPressDuration = 1.0;</listing>
	 *
	 * @default 0.5
	 *
	 * @see #event:longPress
	 * @see #isLongPressEnabled
	 */
	public var longPressDuration(get, set):Float;
	private var _longPressDuration:Float = 0.5;
	private function get_longPressDuration():Float { return this._longPressDuration; }
	private function set_longPressDuration(value:Float):Float
	{
		if (this._longPressDuration == value)
		{
			return value;
		}
		this._longPressDuration = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._longPressDuration;
	}
	
	/**
	 * Determines if <code>FeathersEventType.LONG_PRESS</code> will be
	 * dispatched.
	 *
	 * <p>The following example enables long presses:</p>
	 *
	 * <listing version="3.0">
	 * button.isLongPressEnabled = true;
	 * button.addEventListener( FeathersEventType.LONG_PRESS, function( event:Event ):void
	 * {
	 *     // long press
	 * });</listing>
	 *
	 * @default false
	 *
	 * @see #event:longPress
	 * @see #longPressDuration
	 */
	public var isLongPressEnabled(get, set):Bool;
	private var _isLongPressEnabled:Bool = false;
	private function get_isLongPressEnabled():Bool { return this._isLongPressEnabled; }
	private function set_isLongPressEnabled(value:Bool):Bool
	{
		if (this._isLongPressEnabled == value)
		{
			return value;
		}
		this._isLongPressEnabled = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._isLongPressEnabled;
	}
	
	/**
	 * @private
	 */
	private var _stateToScale:Map<String, Float> = new Map<String, Float>();
	
	/**
	 * @private
	 */
	public var scaleWhenDown(get, set):Float;
	private function get_scaleWhenDown():Float { return this.getScaleForState(ButtonState.DOWN); }
	private function set_scaleWhenDown(value:Float):Float
	{
		this.setScaleForState(ButtonState.DOWN, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var scaleWhenHovering(get, set):Float;
	private function get_scaleWhenHovering():Float { return this.getScaleForState(ButtonState.HOVER); }
	private function set_scaleWhenHovering(value:Float):Float
	{
		this.setScaleForState(ButtonState.HOVER, value);
		return value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.labelTextRenderer == null)
		{
			return this.scaledActualHeight;
		}
		return this.scaleY * (this.labelTextRenderer.y + this.labelTextRenderer.baseline);
	}
	
	/**
	 * The number of text lines displayed by the button. The component may
	 * contain multiple text lines if the text contains line breaks or if
	 * the <code>wordWrap</code> property is enabled.
	 *
	 * @see #wordWrap
	 */
	public var numLines(get, never):Int;
	private function get_numLines():Int
	{
		if (this.labelTextRenderer == null)
		{
			return 0;
		}
		return this.labelTextRenderer.numLines;
	}
	
	/**
	 * @private
	 */
	private var _ignoreIconResizes:Bool = false;
	
	/**
	 * @private
	 */
	override public function render(painter:Painter):Void 
	{
		var scale:Float = this.getScaleForCurrentState();
		if (scale != 1)
		{
			var matrix:Matrix = Pool.getMatrix();
			//scale first, then translate... issue #1455
			matrix.scale(scale, scale);
			matrix.translate(Math.fround((1 - scale) / 2 * this.actualWidth),
				Math.fround((1 - scale) / 2 * this.actualHeight));
			painter.state.transformModelviewMatrix(matrix);
			Pool.putMatrix(matrix);
		}
		super.render(painter);
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the button is the parent because it'll
		//already get disposed in super.dispose()
		if (this._defaultIcon != null && this._defaultIcon.parent != this)
		{
			this._defaultIcon.dispose();
		}
		for (icon in this._stateToIcon)
		{
			if (icon != null && icon.parent != this)
			{
				icon.dispose();
			}
		}
		this._stateToIcon.clear();
		this._stateToScale.clear();
		this._stateToSkin.clear();
		if (this.keyToState != null)
		{
			//setting the target to null will remove listeners and do any
			//other clean up that is needed
			this.keyToState.target = null;
		}
		if (this.keyToTrigger != null)
		{
			this.keyToTrigger.target = null;
		}
		if (this.dpadEnterKeyToState != null)
		{
			this.dpadEnterKeyToState.target = null;
		}
		if (this.dpadEnterKeyToTrigger != null)
		{
			this.dpadEnterKeyToTrigger.target = null;
		}
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		if (this._defaultLabelProperties != null)
		{
			this._defaultLabelProperties.dispose();
			this._defaultLabelProperties = null;
		}
		super.dispose();
	}
	
	/**
	 * Gets the font styles to be used to display the button's text when the
	 * button's <code>currentState</code> property matches the specified
	 * state value.
	 *
	 * <p>If font styles are not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #setFontStylesForState()
	 * @see #style:fontStyles
	 */
	public function getFontStylesForState(state:String):TextFormat
	{
		if (this._fontStylesSet == null)
		{
			return null;
		}
		return this._fontStylesSet.getFormatForState(state);
	}
	
	/**
	 * Sets the font styles to be used to display the button's text when the
	 * button's <code>currentState</code> property matches the specified
	 * state value.
	 *
	 * <p>If font styles are not defined for a specific state, the value of
	 * the <code>fontStyles</code> property will be used instead.</p>
	 *
	 * <p>Note: if the text renderer has been customized with advanced font
	 * formatting, it may override the values specified with
	 * <code>setFontStylesForState()</code> and properties like
	 * <code>fontStyles</code> and <code>disabledFontStyles</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #style:fontStyles
	 */
	public function setFontStylesForState(state:String, format:TextFormat):Void
	{
		var key:String = "setFontStylesForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(key);
		}
		
		var oldFormat:TextFormat = this._fontStylesSet.getFormatForState(state);
		if (oldFormat != null)
		{
			oldFormat.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.setFormatForState(state, format);
		if (format != null)
		{
			format.addEventListener(Event.CHANGE, changeHandler);
		}
	}
	
	/**
	 * Gets the icon to be used by the button when the button's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a icon is not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see #setIconForState()
	 */
	public function getIconForState(state:String):DisplayObject
	{
		return this._stateToIcon[state];
	}
	
	/**
	 * Sets the icon to be used by the button when the button's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If an icon is not defined for a specific state, the value of the
	 * <code>defaultIcon</code> property will be used instead.</p>
	 *
	 * @see #style:defaultIcon
	 * @see #getIconForState()
	 * @see feathers.controls.ButtonState
	 */
	public function setIconForState(state:String, icon:DisplayObject):Void
	{
		var key:String = "setIconForState--" + state;
		if (this.processStyleRestriction(key))
		{
			if (icon != null)
			{
				icon.dispose();
			}
			return;
		}
		var oldIcon:DisplayObject = this._stateToIcon[state];
		if (oldIcon != null &&
			this.currentIcon == oldIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentIcon(oldIcon);
			this.currentIcon = null;
		}
		if (icon != null)
		{
			this._stateToIcon[state] = icon;
		}
		else
		{
			this._stateToIcon.remove(state);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * Gets the scale to be used by the button when the button's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a scale is not defined for a specific state, returns
	 * <code>NaN</code>.</p>
	 *
	 * @see #setScaleForState()
	 */
	public function getScaleForState(state:String):Float
	{
		if (this._stateToScale.exists(state))
		{
			return this._stateToScale[state];
		}
		return Math.NaN;
	}
	
	/**
	 * Sets the scale to be used by the button when the button's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If an icon is not defined for a specific state, the value of the
	 * <code>defaultIcon</code> property will be used instead.</p>
	 *
	 * @see #getScaleForState()
	 * @see feathers.controls.ButtonState
	 */
	public function setScaleForState(state:String, scale:Float):Void
	{
		var key:String = "setScaleForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		if (scale == scale) //!isNaN
		{
			this._stateToScale[state] = scale;
		}
		else
		{
			this._stateToScale.remove(state);
		}
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		super.initialize();
		if (this.keyToState == null)
		{
			this.keyToState = new KeyToState(this, this.changeState);
		}
		if (this.keyToTrigger == null)
		{
			this.keyToTrigger = new KeyToTrigger(this);
		}
		if (this.longPress == null)
		{
			this.longPress = new LongPress(this);
		}
		if (this.dpadEnterKeyToState == null)
		{
			this.dpadEnterKeyToState = new KeyToState(this, this.changeState);
			this.dpadEnterKeyToState.keyCode = Keyboard.ENTER;
			this.dpadEnterKeyToState.keyLocation = 4; //KeyLocation.D_PAD is only in AIR
		}
		if (this.dpadEnterKeyToTrigger == null)
		{
			this.dpadEnterKeyToTrigger = new KeyToTrigger(this, Keyboard.ENTER);
			this.dpadEnterKeyToTrigger.keyLocation = 4; //KeyLocation.D_PAD is only in AIR
		}
		this.longPress.tapToTrigger = this.tapToTrigger;
	}
	
	/**
	 * @private
	 */
	override private function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var textRendererInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		var focusInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_FOCUS);
		
		if (textRendererInvalid)
		{
			this.createLabel();
		}
		
		if (textRendererInvalid || stateInvalid || dataInvalid)
		{
			this.refreshLabel();
		}
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshLongPressEvents();
			this.refreshIcon();
		}
		
		//most components don't need to check the state before passing
		//properties to a child component, but button is an exception
		if (textRendererInvalid || stylesInvalid || stateInvalid)
		{
			this.refreshLabelStyles();
		}
		
		super.draw();
		
		if (textRendererInvalid || stylesInvalid || stateInvalid || dataInvalid || sizeInvalid)
		{
			this.layoutContent();
		}
		
		if (sizeInvalid || focusInvalid)
		{
			this.refreshFocusIndicator();
		}
	}
	
	/**
	 * @private
	 */
	override private function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		var labelRenderer:ITextRenderer = null;
		if (this._label != null && this.labelTextRenderer != null)
		{
			labelRenderer = this.labelTextRenderer;
			this.refreshLabelTextRendererDimensions(true);
			this.labelTextRenderer.measureText(HELPER_POINT);
		}
		
		var adjustedGap:Float = this._gap;
		if (adjustedGap == Math.POSITIVE_INFINITY)
		{
			adjustedGap = this._minGap;
		}
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitSkinWidth, this._explicitSkinHeight,
			this._explicitSkinMinWidth, this._explicitSkinMinHeight,
			this._explicitSkinMaxWidth, this._explicitSkinMaxHeight);
		var measureSkin:IMeasureDisplayObject = SafeCast.safe_cast(this.currentSkin, IMeasureDisplayObject);
		
		if (Std.isOfType(this.currentIcon, IValidating))
		{
			cast(this.currentIcon, IValidating).validate();
		}
		if (Std.isOfType(this.currentSkin, IValidating))
		{
			cast(this.currentSkin, IValidating).validate();
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (labelRenderer != null)
			{
				newMinWidth = HELPER_POINT.x;
			}
			else
			{
				newMinWidth = 0;
			}
			if (this.currentIcon != null)
			{
				if (labelRenderer != null) //both label and icon
				{
					if (this._iconPosition != RelativePosition.TOP &&
						this._iconPosition != RelativePosition.BOTTOM &&
						this._iconPosition != RelativePosition.MANUAL)
					{
						newMinWidth += adjustedGap;
						if (Std.isOfType(this.currentIcon, IFeathersControl))
						{
							newMinWidth += cast(this.currentIcon, IFeathersControl).minWidth;
						}
						else
						{
							newMinWidth += this.currentIcon.width;
						}
					}
					else //top, bottom, or manual
					{
						if (Std.isOfType(this.currentIcon, IFeathersControl))
						{
							var iconMinWidth:Float = cast(this.currentIcon, IFeathersControl).minWidth;
							if (iconMinWidth > newMinWidth)
							{
								newMinWidth = iconMinWidth;
							}
						}
						else if (this.currentIcon.width > newMinWidth)
						{
							newMinWidth = this.currentIcon.width;
						}
					}
				}
				else //no label
				{
					if (Std.isOfType(this.currentIcon, IFeathersControl))
					{
						newMinWidth = cast(this.currentIcon, IFeathersControl).minWidth;
					}
					else
					{
						newMinWidth = this.currentIcon.width;
					}
				}
			}
			newMinWidth += this._paddingLeft + this._paddingRight;
			if (this.currentSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minWidth > newMinWidth)
					{
						newMinWidth = measureSkin.minWidth;
					}
				}
				else if (this._explicitSkinMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitSkinMinWidth;
				}
			}
		}
		
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (labelRenderer != null)
			{
				newMinHeight = HELPER_POINT.y;
			}
			else
			{
				newMinHeight = 0;
			}
			if (this.currentIcon != null)
			{
				if (labelRenderer != null) //both label and icon
				{
					if (this._iconPosition == RelativePosition.TOP || this._iconPosition == RelativePosition.BOTTOM)
					{
						newMinHeight += adjustedGap;
						if (Std.isOfType(this.currentIcon, IFeathersControl))
						{
							newMinHeight += cast(this.currentIcon, IFeathersControl).minHeight;
						}
						else
						{
							newMinHeight += this.currentIcon.height;
						}
					}
					else //left, right, manual
					{
						if (Std.isOfType(this.currentIcon, IFeathersControl))
						{
							var iconMinHeight:Float = cast(this.currentIcon, IFeathersControl).minHeight;
							if (iconMinHeight > newMinHeight)
							{
								newMinHeight = iconMinHeight;
							}
						}
						else if (this.currentIcon.height > newMinHeight)
						{
							newMinHeight = this.currentIcon.height;
						}
					}
				}
				else //no label
				{
					if (Std.isOfType(this.currentIcon, IFeathersControl))
					{
						newMinHeight = cast(this.currentIcon, IFeathersControl).minHeight;
					}
					else
					{
						newMinHeight = this.currentIcon.height;
					}
				}
			}
			newMinHeight += this._paddingTop + this._paddingBottom;
			if (this.currentSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minHeight > newMinHeight)
					{
						newMinHeight = measureSkin.minHeight;
					}
				}
				else if (this._explicitSkinMinHeight > newMinHeight)
				{
					newMinHeight = this._explicitSkinMinHeight;
				}
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (labelRenderer != null)
			{
				newWidth = HELPER_POINT.x;
			}
			else
			{
				newWidth = 0;
			}
			if (this.currentIcon != null)
			{
				if (labelRenderer != null) //both label and icon
				{
					if (this._iconPosition != RelativePosition.TOP &&
						this._iconPosition != RelativePosition.BOTTOM &&
						this._iconPosition != RelativePosition.MANUAL)
					{
						newWidth += adjustedGap + this.currentIcon.width;
					}
					else if (this.currentIcon.width > newWidth) //top, bottom, or manual
					{
						newWidth = this.currentIcon.width;
					}
				}
				else //no label
				{
					newWidth = this.currentIcon.width;
				}
			}
			newWidth += this._paddingLeft + this._paddingRight;
			if (this.currentSkin != null &&
				this.currentSkin.width > newWidth)
			{
				newWidth = this.currentSkin.width;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (labelRenderer != null)
			{
				newHeight = HELPER_POINT.y;
			}
			else
			{
				newHeight = 0;
			}
			if (this.currentIcon != null)
			{
				if (labelRenderer != null) //both label and icon
				{
					if (this._iconPosition == RelativePosition.TOP || this._iconPosition == RelativePosition.BOTTOM)
					{
						newHeight += adjustedGap + this.currentIcon.height;
					}
					else if (this.currentIcon.height > newHeight) //left, right, manual
					{
						newHeight = this.currentIcon.height;
					}
				}
				else //no label
				{
					newHeight = this.currentIcon.height;
				}
			}
			newHeight += this._paddingTop + this._paddingBottom;
			if (this.currentSkin != null &&
				this.currentSkin.height > newHeight)
			{
				newHeight = this.currentSkin.height;
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	override private function changeState(state:String):Void
	{
		var oldState:String = this._currentState;
		if (oldState == state)
		{
			return;
		}
		super.changeState(state);
		if (this.getScaleForCurrentState() != this.getScaleForCurrentState(oldState))
		{
			this.setRequiresRedraw();
		}
	}
	
	/**
	 * Creates the label text renderer sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #labelTextRenderer
	 * @see #labelFactory
	 */
	private function createLabel():Void
	{
		if (this.labelTextRenderer != null)
		{
			this.removeChild(cast this.labelTextRenderer, true);
			this.labelTextRenderer = null;
		}
		
		if (this._hasLabelTextRenderer)
		{
			var factory:Void->ITextRenderer = this._labelFactory != null ? this._labelFactory : FeathersControl.defaultTextRendererFactory;
			this.labelTextRenderer = factory();
			var labelStyleName:String = this._customLabelStyleName != null ? this._customLabelStyleName : this.labelStyleName;
			this.labelTextRenderer.styleNameList.add(labelStyleName);
			if (Std.isOfType(this.labelTextRenderer, IStateObserver))
			{
				cast(this.labelTextRenderer, IStateObserver).stateContext = this;
			}
			this.addChild(cast this.labelTextRenderer);
			this._explicitLabelWidth = this.labelTextRenderer.explicitWidth;
			this._explicitLabelHeight = this.labelTextRenderer.explicitHeight;
			this._explicitLabelMinWidth = this.labelTextRenderer.explicitMinWidth;
			this._explicitLabelMinHeight = this.labelTextRenderer.explicitMinHeight;
			this._explicitLabelMaxWidth = this.labelTextRenderer.explicitMaxWidth;
			this._explicitLabelMaxHeight = this.labelTextRenderer.explicitMaxHeight;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshLabel():Void
	{
		if (this.labelTextRenderer == null)
		{
			return;
		}
		this.labelTextRenderer.text = this._label;
		this.labelTextRenderer.visible = this._label != null && this._label.length > 0;
		this.labelTextRenderer.isEnabled = this._isEnabled;
	}
	
	/**
	 * Sets the <code>currentIcon</code> property.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function refreshIcon():Void
	{
		var oldIcon:DisplayObject = this.currentIcon;
		this.currentIcon = this.getCurrentIcon();
		if (Std.isOfType(this.currentIcon, IFeathersControl))
		{
			cast(this.currentIcon, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (this.currentIcon != oldIcon)
		{
			if (oldIcon != null)
			{
				this.removeCurrentIcon(oldIcon);
			}
			if (this.currentIcon != null)
			{
				if (Std.isOfType(this.currentIcon, IStateObserver))
				{
					cast(this.currentIcon, IStateObserver).stateContext = this;
				}
				//we want the icon to appear below the label text renderer
				var index:Int = this.numChildren;
				if (this.labelTextRenderer != null)
				{
					index = this.getChildIndex(cast this.labelTextRenderer);
				}
				this.addChildAt(this.currentIcon, index);
				if (Std.isOfType(this.currentIcon, IFeathersControl))
				{
					this.currentIcon.addEventListener(FeathersEventType.RESIZE, currentIcon_resizeHandler);
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function removeCurrentIcon(icon:DisplayObject):Void
	{
		if (icon == null)
		{
			return;
		}
		if (Std.isOfType(icon, IFeathersControl))
		{
			icon.removeEventListener(FeathersEventType.RESIZE, currentIcon_resizeHandler);
		}
		if (Std.isOfType(icon, IStateObserver))
		{
			cast(icon, IStateObserver).stateContext = null;
		}
		if (icon.parent == this)
		{
			this.removeChild(icon, false);
		}
	}
	
	/**
	 * @private
	 */
	private function getCurrentIcon():DisplayObject
	{
		var result:DisplayObject = this._stateToIcon[this._currentState];
		if (result != null)
		{
			return result;
		}
		return this._defaultIcon;
	}
	
	/**
	 * @private
	 */
	private function getScaleForCurrentState(state:String = null):Float
	{
		if (state == null)
		{
			state = this._currentState;
		}
		if (this._stateToScale.exists(state))
		{
			return this._stateToScale[state];
		}
		return 1;
	}
	
	/**
	 * @private
	 */
	private function refreshLabelStyles():Void
	{
		if (this.labelTextRenderer == null)
		{
			return;
		}
		this.labelTextRenderer.fontStyles = this._fontStylesSet;
		this.labelTextRenderer.wordWrap = this._wordWrap;
		if (this._defaultLabelProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._defaultLabelProperties)
			{
				propertyValue = this._defaultLabelProperties[propertyName];
				//this.labelTextRenderer[propertyName] = propertyValue;
				Reflect.setProperty(this.labelTextRenderer, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	override function refreshTriggeredEvents():Void
	{
		super.refreshTriggeredEvents();
		this.keyToTrigger.isEnabled = this._isEnabled;
		this.dpadEnterKeyToTrigger.isEnabled = this._isEnabled;
	}
	
	/**
	 * @private
	 */
	private function refreshLongPressEvents():Void
	{
		this.longPress.isEnabled = this._isEnabled && this._isLongPressEnabled;
		this.longPress.longPressDuration = this._longPressDuration;
	}
	
	/**
	 * Positions and sizes the button's content.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function layoutContent():Void
	{
		this.refreshLabelTextRendererDimensions(false);
		var labelRenderer:DisplayObject = null;
		if (this._label != null && this.labelTextRenderer != null)
		{
			labelRenderer = cast this.labelTextRenderer;
		}
		var iconIsInLayout:Bool = this.currentIcon != null && this._iconPosition != RelativePosition.MANUAL;
		if (labelRenderer != null && iconIsInLayout)
		{
			this.positionSingleChild(labelRenderer);
			this.positionLabelAndIcon();
		}
		else if (labelRenderer != null)
		{
			this.positionSingleChild(labelRenderer);
		}
		else if (iconIsInLayout)
		{
			this.positionSingleChild(this.currentIcon);
		}
		
		if (this.currentIcon != null)
		{
			if (this._iconPosition == RelativePosition.MANUAL)
			{
				this.currentIcon.x = this._paddingLeft;
				this.currentIcon.y = this._paddingTop;
			}
			this.currentIcon.x += this._iconOffsetX;
			this.currentIcon.y += this._iconOffsetY;
		}
		if (labelRenderer != null)
		{
			this.labelTextRenderer.x += this._labelOffsetX;
			this.labelTextRenderer.y += this._labelOffsetY;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshLabelTextRendererDimensions(forMeasurement:Bool):Void
	{
		var oldIgnoreIconResizes:Bool = this._ignoreIconResizes;
		this._ignoreIconResizes = true;
		if (Std.isOfType(this.currentIcon, IValidating))
		{
			cast(this.currentIcon, IValidating).validate();
		}
		this._ignoreIconResizes = oldIgnoreIconResizes;
		if (this._label == null || this.labelTextRenderer == null)
		{
			return;
		}
		var calculatedWidth:Float = this.actualWidth;
		var calculatedHeight:Float = this.actualHeight;
		if (forMeasurement)
		{
			calculatedWidth = this._explicitWidth;
			if (calculatedWidth != calculatedWidth) //isNaN
			{
				calculatedWidth = this._explicitMaxWidth;
			}
			calculatedHeight = this._explicitHeight;
			if (calculatedHeight != calculatedHeight) //isNaN
			{
				calculatedHeight = this._explicitMaxHeight;
			}
		}
		calculatedWidth -= (this._paddingLeft + this._paddingRight);
		calculatedHeight -= (this._paddingTop + this._paddingBottom);
		if (this.currentIcon != null)
		{
			var adjustedGap:Float = this._gap;
			if (adjustedGap == Math.POSITIVE_INFINITY)
			{
				adjustedGap = this._minGap;
			}
			if (this._iconPosition == RelativePosition.LEFT || this._iconPosition == RelativePosition.LEFT_BASELINE ||
				this._iconPosition == RelativePosition.RIGHT || this._iconPosition == RelativePosition.RIGHT_BASELINE)
			{
				calculatedWidth -= (this.currentIcon.width + adjustedGap);
			}
			if (this._iconPosition == RelativePosition.TOP || this._iconPosition == RelativePosition.BOTTOM)
			{
				calculatedHeight -= (this.currentIcon.height + adjustedGap);
			}
		}
		if (calculatedWidth < 0)
		{
			calculatedWidth = 0;
		}
		if (calculatedHeight < 0)
		{
			calculatedHeight = 0;
		}
		if (calculatedWidth > this._explicitLabelMaxWidth)
		{
			calculatedWidth = this._explicitLabelMaxWidth;
		}
		if (calculatedHeight > this._explicitLabelMaxHeight)
		{
			calculatedHeight = this._explicitLabelMaxHeight;
		}
		this.labelTextRenderer.width = this._explicitLabelWidth;
		this.labelTextRenderer.height = this._explicitLabelHeight;
		this.labelTextRenderer.minWidth = this._explicitLabelMinWidth;
		this.labelTextRenderer.minHeight = this._explicitLabelMinHeight;
		this.labelTextRenderer.maxWidth = calculatedWidth;
		this.labelTextRenderer.maxHeight = calculatedHeight;
		this.labelTextRenderer.validate();
		if (!forMeasurement)
		{
			calculatedWidth = this.labelTextRenderer.width;
			calculatedHeight = this.labelTextRenderer.height;
			//setting all of these dimensions explicitly means that the text
			//renderer won't measure itself again when it validates, which
			//helps performance. we'll reset them when the button needs to
			//measure itself.
			this.labelTextRenderer.width = calculatedWidth;
			this.labelTextRenderer.height = calculatedHeight;
			this.labelTextRenderer.minWidth = calculatedWidth;
			this.labelTextRenderer.minHeight = calculatedHeight;
		}
	}
	
	/**
	 * @private
	 */
	private function positionSingleChild(displayObject:DisplayObject):Void
	{
		if (this._horizontalAlign == HorizontalAlign.LEFT)
		{
			displayObject.x = this._paddingLeft;
		}
		else if (this._horizontalAlign == HorizontalAlign.RIGHT)
		{
			displayObject.x = this.actualWidth - this._paddingRight - displayObject.width;
		}
		else //center
		{
			displayObject.x = this._paddingLeft + Math.fround((this.actualWidth - this._paddingLeft - this._paddingRight - displayObject.width) / 2);
		}
		if (this._verticalAlign == VerticalAlign.TOP)
		{
			displayObject.y = this._paddingTop;
		}
		else if (this._verticalAlign == VerticalAlign.BOTTOM)
		{
			displayObject.y = this.actualHeight - this._paddingBottom - displayObject.height;
		}
		else //middle
		{
			displayObject.y = this._paddingTop + Math.fround((this.actualHeight - this._paddingTop - this._paddingBottom - displayObject.height) / 2);
		}
	}
	
	/**
	 * @private
	 */
	private function positionLabelAndIcon():Void
	{
		if (this._iconPosition == RelativePosition.TOP)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.currentIcon.y = this._paddingTop;
				this.labelTextRenderer.y = this.actualHeight - this._paddingBottom - this.labelTextRenderer.height;
			}
			else
			{
				if (this._verticalAlign == VerticalAlign.TOP)
				{
					this.labelTextRenderer.y += this.currentIcon.height + this._gap;
				}
				else if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					this.labelTextRenderer.y += Math.fround((this.currentIcon.height + this._gap) / 2);
				}
				this.currentIcon.y = this.labelTextRenderer.y - this.currentIcon.height - this._gap;
			}
		}
		else if (this._iconPosition == RelativePosition.RIGHT || this._iconPosition == RelativePosition.RIGHT_BASELINE)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.labelTextRenderer.x = this._paddingLeft;
				this.currentIcon.x = this.actualWidth - this._paddingRight - this.currentIcon.width;
			}
			else
			{
				if (this._horizontalAlign == HorizontalAlign.RIGHT)
				{
					this.labelTextRenderer.x -= this.currentIcon.width + this._gap;
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					this.labelTextRenderer.x -= Math.fround((this.currentIcon.width + this._gap) / 2);
				}
				this.currentIcon.x = this.labelTextRenderer.x + this.labelTextRenderer.width + this._gap;
			}
		}
		else if (this._iconPosition == RelativePosition.BOTTOM)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.labelTextRenderer.y = this._paddingTop;
				this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
			}
			else
			{
				if (this._verticalAlign == VerticalAlign.BOTTOM)
				{
					this.labelTextRenderer.y -= this.currentIcon.height + this._gap;
				}
				else if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					this.labelTextRenderer.y -= Math.fround((this.currentIcon.height + this._gap) / 2);
				}
				this.currentIcon.y = this.labelTextRenderer.y + this.labelTextRenderer.height + this._gap;
			}
		}
		else if (this._iconPosition == RelativePosition.LEFT || this._iconPosition == RelativePosition.LEFT_BASELINE)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.currentIcon.x = this._paddingLeft;
				this.labelTextRenderer.x = this.actualWidth - this._paddingRight - this.labelTextRenderer.width;
			}
			else
			{
				if (this._horizontalAlign == HorizontalAlign.LEFT)
				{
					this.labelTextRenderer.x += this._gap + this.currentIcon.width;
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					this.labelTextRenderer.x += Math.fround((this._gap + this.currentIcon.width) / 2);
				}
				this.currentIcon.x = this.labelTextRenderer.x - this._gap - this.currentIcon.width;
			}
		}
		
		if (this._iconPosition == RelativePosition.LEFT || this._iconPosition == RelativePosition.RIGHT)
		{
			if (this._verticalAlign == VerticalAlign.TOP)
			{
				this.currentIcon.y = this._paddingTop;
			}
			else if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
			}
			else
			{
				this.currentIcon.y = this._paddingTop + Math.fround((this.actualHeight - this._paddingTop - this._paddingBottom - this.currentIcon.height) / 2);
			}
		}
		else if (this._iconPosition == RelativePosition.LEFT_BASELINE || this._iconPosition == RelativePosition.RIGHT_BASELINE)
		{
			this.currentIcon.y = this.labelTextRenderer.y + (this.labelTextRenderer.baseline) - this.currentIcon.height;
		}
		else //top or bottom
		{
			if (this._horizontalAlign == HorizontalAlign.LEFT)
			{
				this.currentIcon.x = this._paddingLeft;
			}
			else if (this._horizontalAlign == HorizontalAlign.RIGHT)
			{
				this.currentIcon.x = this.actualWidth - this._paddingRight - this.currentIcon.width;
			}
			else
			{
				this.currentIcon.x = this._paddingLeft + Math.fround((this.actualWidth - this._paddingLeft - this._paddingRight - this.currentIcon.width) / 2);
			}
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
	private function currentIcon_resizeHandler():Void
	{
		if (this._ignoreIconResizes)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function fontStyles_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}