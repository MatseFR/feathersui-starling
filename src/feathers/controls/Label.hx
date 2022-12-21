/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.ITextBaselineControl;
import feathers.core.ITextRenderer;
import feathers.core.IToolTip;
import feathers.core.PropertyProxy;
import feathers.skins.IStyleProvider;
import feathers.text.FontStylesSet;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.text.TextFormat;

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
		this.invalidate(INVALIDATION_FLAG_DATA);
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
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._wordWrap == value)
		{
			return value;
		}
		this._wordWrap = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._wordWrap;
	}
	
	/**
	 * The baseline measurement of the text, in pixels.
	 */
	public var baseLine(get, never):Float;
	private function get_baseLine():Float
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
	public var textRendererFactory(get, set):Void->ITextRenderer
	private var _textRendererFactory:Void->ITextRenderer;
	private function get_textRendererFactory():Void->ITextRenderer { return this._textRendererFactory; }
	private function set_textRendererFactory(value:Void->ITextRenderer):Void->ITextRenderer
	{
		if (this._textRendererFactory == value)
		{
			return;
		}
		this._textRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
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
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._customTextRendererStyleName == value)
		{
			return value;
		}
		this._customTextRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
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
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		var savedCallee:Function = arguments.callee;
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(savedCallee);
		}
		if (value != null)
		{
			value.removeEventListener(Event.CHANGE, changeHandler);
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
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		var savedCallee:Function = arguments.callee;
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(savedCallee);
		}
		if (value != null)
		{
			value.removeEventListener(Event.CHANGE, changeHandler);
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
	public var textRendererProperties(get, set):Dynamic;
	private var _textRendererProperties:PropertyProxy;
	private function get_textRendererProperties():Dynamic
	{
		if (this._textRendererProperties == null)
		{
			this._textRendererProperties = new PropertyProxy(textRendererProperties_onChange);
		}
		return this._textRendererProperties;
	}
	private function set_textRendererProperties(value:Dynamic):Dynamic
	{
		if (this._textRendererProperties == value)
		{
			return value;
		}
		if (value != null && !Std.isOfType(value, PropertyProxy))
		{
			value = PropertyProxy.fromObject(value);
		}
		if (this._textRendererProperties)
		{
			this._textRendererProperties.removeOnChangeCallback(textRendererProperties_onChange);
		}
		this._textRendererProperties = cast value;
		if (this._textRendererProperties != null)
		{
			this._textRendererProperties.addOnChangeCallback(textRendererProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
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
			if(value != null)
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
		this.invalidate(INVALIDATION_FLAG_STYLES);
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
		return this._paddingTop;
	}
	
	/**
	 * @private
	 */
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingTop():Float { return this._paddingRight; }
	private function set_paddingTop(value:Float):Float
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._paddingRight == value)
		{
			return;
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
		return  this._paddingLeft;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the label is the parent because it'll
		//already get disposed in super.dispose()
		if(this._backgroundSkin != null &&
			this._backgroundSkin.parent != this)
		{
			this._backgroundSkin.dispose();
		}
		if(this._backgroundDisabledSkin != null &&
			this._backgroundDisabledSkin.parent != this)
		{
			this._backgroundDisabledSkin.dispose();
		}
		if(this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		super.dispose();
	}
	
}