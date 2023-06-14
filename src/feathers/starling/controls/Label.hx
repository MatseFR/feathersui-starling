/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

import feathers.starling.core.FeathersControl;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IMeasureDisplayObject;
import feathers.starling.core.ITextBaselineControl;
import feathers.starling.core.ITextRenderer;
import feathers.starling.core.IToolTip;
import feathers.starling.core.IValidating;
import feathers.starling.core.PropertyProxy;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.text.FontStylesSet;
import feathers.starling.utils.skins.SkinsUtils;
import feathers.starling.utils.type.Property;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.text.TextFormat;
import starling.utils.Pool;

/**
 * Displays text using a text renderer.
 *
 * @see ../../../help/label.html How to use the Feathers Label component
 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
 *
 * @productversion Feathers 1.0.0
 */
class Label extends FeathersControl implements ITextBaselineControl implements IToolTip
{
	/**
	 * The default value added to the <code>styleNameList</code> of the text
	 * renderer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER:String = "feathers-label-text-renderer";
	
	/**
	 * An alternate style name to use with <code>Label</code> to allow a
	 * theme to give it a larger style meant for headings. If a theme does
	 * not provide a style for a heading label, the theme will automatically
	 * fall back to using the default style for a label.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the heading style is applied to a label:</p>
	 *
	 * <listing version="3.0">
	 * var label:Label = new Label();
	 * label.text = "Very Important Heading";
	 * label.styleNameList.add( Label.ALTERNATE_STYLE_NAME_HEADING );
	 * this.addChild( label );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_HEADING:String = "feathers-heading-label";
	
	/**
	 * An alternate style name to use with <code>Label</code> to allow a
	 * theme to give it a smaller style meant for less-important details. If
	 * a theme does not provide a style for a detail label, the theme will
	 * automatically fall back to using the default style for a label.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the detail style is applied to a label:</p>
	 *
	 * <listing version="3.0">
	 * var label:Label = new Label();
	 * label.text = "Less important, detailed text";
	 * label.styleNameList.add( Label.ALTERNATE_STYLE_NAME_DETAIL );
	 * this.addChild( label );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_DETAIL:String = "feathers-detail-label";
	
	/**
	 * An alternate style name to use with <code>Label</code> to allow a
	 * theme to give it a tool tip style for use with the tool tip manager.
	 * If a theme does not provide a style for a tool tip label, the theme
	 * will automatically fall back to using the default style for a label.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_TOOL_TIP:String = "feathers-tool-tip";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>Label</code>
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
		this.isQuickHitAreaEnabled = true;
		if (this._fontStylesSet == null)
		{
			this._fontStylesSet = new FontStylesSet();
			this._fontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the text
	 * renderer. This variable is <code>protected</code> so that sub-classes
	 * can customize the text renderer style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER</code>.
	 *
	 * <p>To customize the text renderer style name without subclassing, see
	 * <code>customTextRendererStyleName</code>.</p>
	 *
	 * @see #style:customTextRendererStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var textRendererStyleName:String = DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER;
	
	/**
	 * The text renderer.
	 *
	 * @see #createTextRenderer()
	 * @see #textRendererFactory
	 */
	private var textRenderer:ITextRenderer;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Label.globalStyleProvider;
	}
	
	/**
	 * The text displayed by the label.
	 *
	 * <p>In the following example, the label's text is updated:</p>
	 *
	 * <listing version="3.0">
	 * label.text = "Hello World";</listing>
	 *
	 * @default null
	 */
	public var text(get, set):String;
	private var _text:String;
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (this._text == value)
		{
			return value;
		}
		this._text = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._text;
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
		if (this._wordWrap == value)
		{
			return value;
		}
		this._wordWrap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._wordWrap;
	}
	
	/**
	 * The baseline measurement of the text, in pixels.
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.textRenderer == null)
		{
			return this.scaledActualHeight;
		}
		return this.scaleY * (this.textRenderer.y + this.textRenderer.baseline);
	}
	
	/**
	 * The number of text lines displayed by the label. The component may
	 * contain multiple text lines if the text contains line breaks or if
	 * the <code>wordWrap</code> property is enabled.
	 *
	 * @see #wordWrap
	 */
	public var numLines(get, never):Int;
	private function get_numLines():Int
	{
		if (this.textRenderer == null)
		{
			return 0;
		}
		return this.textRenderer.numLines;
	}
	
	/**
	 * A function used to instantiate the label's text renderer
	 * sub-component. By default, the label will use the global text
	 * renderer factory, <code>FeathersControl.defaultTextRendererFactory()</code>,
	 * to create the text renderer. The text renderer must be an instance of
	 * <code>ITextRenderer</code>. This factory can be used to change
	 * properties on the text renderer when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to style the text renderer.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, a custom text renderer factory is passed
	 * to the label:</p>
	 *
	 * <listing version="3.0">
	 * label.textRendererFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var textRendererFactory(get, set):Void->ITextRenderer;
	private var _textRendererFactory:Void->ITextRenderer;
	private function get_textRendererFactory():Void->ITextRenderer { return this._textRendererFactory; }
	private function set_textRendererFactory(value:Void->ITextRenderer):Void->ITextRenderer
	{
		if (this._textRendererFactory == value)
		{
			return value;
		}
		this._textRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._textRendererFactory;
	}
	
	/**
	 * @private
	 */
	public var customTextRendererStyleName(get, set):String;
	private var _customTextRendererStyleName:String;
	private function get_customTextRendererStyleName():String { return this._customTextRendererStyleName; }
	private function set_customTextRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customTextRendererStyleName"))
		{
			return value;
		}
		if (this._customTextRendererStyleName == value)
		{
			return value;
		}
		this._customTextRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customTextRendererStyleName;
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
	 * An object that stores properties for the label's text renderer
	 * sub-component, and the properties will be passed down to the text
	 * renderer when the label validates. The available properties
	 * depend on which <code>ITextRenderer</code> implementation is returned
	 * by <code>textRendererFactory</code>. Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>textRendererFactory</code> function
	 * instead of using <code>textRendererProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the label's text renderer's properties
	 * are updated (this example assumes that the label text renderer is a
	 * <code>TextFieldTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * label.textRendererProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 * label.textRendererProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see #textRendererFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var textRendererProperties(get, set):PropertyProxy;
	private var _textRendererProperties:PropertyProxy;
	private function get_textRendererProperties():PropertyProxy
	{
		if (this._textRendererProperties == null)
		{
			this._textRendererProperties = new PropertyProxy(textRendererProperties_onChange);
		}
		return this._textRendererProperties;
	}
	private function set_textRendererProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._textRendererProperties == value)
		{
			return value;
		}
		if (this._textRendererProperties != null)
		{
			this._textRendererProperties.dispose();
		}
		this._textRendererProperties = value;
		if (this._textRendererProperties != null)
		{
			this._textRendererProperties.addOnChangeCallback(textRendererProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return value;
	}
	
	/**
	 * @private
	 */
	private var _explicitTextRendererWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitTextRendererHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitTextRendererMinWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitTextRendererMinHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitTextRendererMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitTextRendererMaxHeight:Float;
	
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
		if (this.processStyleRestriction("backgroundSkin"))
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
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
		if (this.processStyleRestriction("backgroundDisabledSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._backgroundDisabledSkin != null &&
			this.currentBackgroundSkin == this._backgroundDisabledSkin)
		{
			this.removeCurrentBackgroundSkin(this._backgroundDisabledSkin);
			this.currentBackgroundSkin = null;
		}
		this._backgroundDisabledSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundDisabledSkin;
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
		return  this._paddingLeft;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the label is the parent because it'll
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
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		if (this._textRendererProperties != null)
		{
			this._textRendererProperties.dispose();
			this._textRendererProperties = null;
		}
		super.dispose();
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
		
		if (sizeInvalid || stylesInvalid || stateInvalid)
		{
			this.refreshBackgroundSkin();
		}
		
		if (textRendererInvalid)
		{
			this.createTextRenderer();
		}
		
		if (textRendererInvalid || dataInvalid || stateInvalid)
		{
			this.refreshTextRendererData();
		}
		
		if (textRendererInvalid || stateInvalid)
		{
			this.refreshEnabled();
		}
		
		if (textRendererInvalid || stylesInvalid)
		{
			this.refreshTextRendererStyles();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutChildren();
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
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(cast this.textRenderer,
			this._explicitWidth - this._paddingLeft - this._paddingRight,
			this._explicitHeight - this._paddingTop - this._paddingBottom,
			this._explicitMinWidth - this._paddingLeft - this._paddingRight,
			this._explicitMinHeight - this._paddingTop - this._paddingBottom,
			this._explicitMaxWidth - this._paddingLeft - this._paddingRight,
			this._explicitMaxHeight - this._paddingTop - this._paddingBottom,
			this._explicitTextRendererWidth, this._explicitTextRendererHeight,
			this._explicitTextRendererMinWidth, this._explicitTextRendererMinHeight,
			this._explicitTextRendererMaxWidth, this._explicitTextRendererMaxHeight);
		this.textRenderer.maxWidth = this._explicitMaxWidth - this._paddingLeft - this._paddingRight;
		this.textRenderer.maxHeight = this._explicitMaxHeight - this._paddingTop - this._paddingBottom;
		var point:Point = Pool.getPoint();
		this.textRenderer.measureText(point);
		
		var measureBackground:IMeasureDisplayObject = cast this.currentBackgroundSkin;
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			cast(this.currentBackgroundSkin, IValidating).validate();
		}
		
		//minimum dimensions
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			//if we don't have an explicitWidth, then the minimum width
			//should be small to allow wrapping or truncation
			if (this._text != null && !needsWidth)
			{
				newMinWidth = point.x;
			}
			else
			{
				newMinWidth = 0;
			}
			newMinWidth += this._paddingLeft + this._paddingRight;
			var backgroundMinWidth:Float = 0;
			if (measureBackground != null)
			{
				backgroundMinWidth = measureBackground.minWidth;
			}
			else if (this.currentBackgroundSkin != null)
			{
				backgroundMinWidth = this._explicitBackgroundMinWidth;
			}
			if (backgroundMinWidth > newMinWidth)
			{
				newMinWidth = backgroundMinWidth;
			}
		}
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (this._text != null)
			{
				newMinHeight = point.y;
			}
			else
			{
				newMinHeight = 0;
			}
			newMinHeight += this._paddingTop + this._paddingBottom;
			var backgroundMinHeight:Float = 0;
			if (measureBackground != null)
			{
				backgroundMinHeight = measureBackground.minHeight;
			}
			else if (this.currentBackgroundSkin != null)
			{
				backgroundMinHeight = this._explicitBackgroundMinHeight;
			}
			if (backgroundMinHeight > newMinHeight)
			{
				newMinHeight = backgroundMinHeight;
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (this._text != null)
			{
				newWidth = point.x;
			}
			else
			{
				newWidth = 0;
			}
			newWidth += this._paddingLeft + this._paddingRight;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.width > newWidth)
			{
				newWidth = this.currentBackgroundSkin.width;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (this._text != null)
			{
				newHeight = point.y;
			}
			else
			{
				newHeight = 0;
			}
			newHeight += this._paddingTop + this._paddingBottom;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.height > newHeight) //!isNaN
			{
				newHeight = this.currentBackgroundSkin.height;
			}
		}
		
		Pool.putPoint(point);
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Creates and adds the <code>textRenderer</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #textRenderer
	 * @see #textRendererFactory
	 */
	private function createTextRenderer():Void
	{
		if (this.textRenderer != null)
		{
			this.removeChild(cast this.textRenderer, true);
			this.textRenderer = null;
		}
		
		var factory:Void->ITextRenderer = this._textRendererFactory != null ? this._textRendererFactory : FeathersControl.defaultTextRendererFactory;
		this.textRenderer = factory();
		var textRendererStyleName:String = this._customTextRendererStyleName != null ? this._customTextRendererStyleName : this.textRendererStyleName;
		this.textRenderer.styleNameList.add(textRendererStyleName);
		this.addChild(cast this.textRenderer);
		
		this.textRenderer.initializeNow();
		this._explicitTextRendererWidth = this.textRenderer.explicitWidth;
		this._explicitTextRendererHeight = this.textRenderer.explicitHeight;
		this._explicitTextRendererMinWidth = this.textRenderer.explicitMinWidth;
		this._explicitTextRendererMinHeight = this.textRenderer.explicitMinHeight;
		this._explicitTextRendererMaxWidth = this.textRenderer.explicitMaxWidth;
		this._explicitTextRendererMaxHeight = this.textRenderer.explicitMaxHeight;
	}
	
	/**
	 * Choose the appropriate background skin based on the control's current
	 * state.
	 */
	private function refreshBackgroundSkin():Void
	{
		var newCurrentBackgroundSkin:DisplayObject = this._backgroundSkin;
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			newCurrentBackgroundSkin = this._backgroundDisabledSkin;
		}
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
				this.addChildAt(this.currentBackgroundSkin, 0);
			}
		}
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
			skin.removeFromParent(false);
		}
	}
	
	/**
	 * Positions and sizes children based on the actual width and height
	 * values.
	 */
	private function layoutChildren():Void
	{
		if (this.currentBackgroundSkin != null)
		{
			this.currentBackgroundSkin.x = 0;
			this.currentBackgroundSkin.y = 0;
			this.currentBackgroundSkin.width = this.actualWidth;
			this.currentBackgroundSkin.height = this.actualHeight;
		}
		this.textRenderer.x = this._paddingLeft;
		this.textRenderer.y = this._paddingTop;
		this.textRenderer.width = this.actualWidth - this._paddingLeft - this._paddingRight;
		this.textRenderer.height = this.actualHeight - this._paddingTop - this._paddingBottom;
		this.textRenderer.validate();
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		this.textRenderer.isEnabled = this._isEnabled;
	}
	
	/**
	 * @private
	 */
	private function refreshTextRendererData():Void
	{
		this.textRenderer.text = this._text;
		this.textRenderer.visible = this._text != null && this._text.length != 0;
	}
	
	/**
	 * @private
	 */
	private function refreshTextRendererStyles():Void
	{
		this.textRenderer.fontStyles = this._fontStylesSet;
		this.textRenderer.wordWrap = this._wordWrap;
		if (this._textRendererProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._textRendererProperties)
			{
				propertyValue = this._textRendererProperties[propertyName];
				Property.write(this.textRenderer, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function fontStyles_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function textRendererProperties_onChange(proxy:PropertyProxy, propertyName:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}