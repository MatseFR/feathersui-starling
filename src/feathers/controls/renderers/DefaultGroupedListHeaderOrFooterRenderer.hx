/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.renderers;

import feathers.controls.GroupedList;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.ITextRenderer;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.core.PropertyProxyReal;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.skins.IStyleProvider;
import feathers.text.FontStylesSet;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.text.TextFormat;

/**
 * The default renderer used for headers and footers in a GroupedList
 * control.
 *
 * @see feathers.controls.GroupedList
 *
 * @productversion Feathers 1.0.0
 */
class DefaultGroupedListHeaderOrFooterRenderer extends FeathersControl implements IGroupedListHeaderRenderer implements IGroupedListFooterRenderer
{
	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * content label.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_CONTENT_LABEL:String = "feathers-header-footer-renderer-content-label";

	/**
	 * The default <code>IStyleProvider</code> for all <code>DefaultGroupedListHeaderOrFooterRenderer</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();
	
	/**
	 * @private
	 */
	private static function defaultImageLoaderFactory():ImageLoader
	{
		return new ImageLoader();
	}
	
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
	 * The value added to the <code>styleNameList</code> of the content
	 * label text renderer. This variable is <code>protected</code> so that
	 * sub-classes can customize the label text renderer style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_CONTENT_LABEL</code>.
	 *
	 * <p>To customize the content label text renderer style name without
	 * subclassing, see <code>customContentLabelStyleName</code>.</p>
	 *
	 * @see #style:customContentLabelStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var contentLabelStyleName:String = DEFAULT_CHILD_STYLE_NAME_CONTENT_LABEL;

	/**
	 * @private
	 */
	private var contentImage:ImageLoader;

	/**
	 * @private
	 */
	private var contentLabel:ITextRenderer;

	/**
	 * @private
	 */
	private var content:DisplayObject;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return DefaultGroupedListHeaderOrFooterRenderer.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var data(get, set):Dynamic;
	private var _data:Dynamic;
	private function get_data():Dynamic { return this._data; }
	private function set_data(value:Dynamic):Dynamic
	{
		if (this._data == value)
		{
			return value;
		}
		this._data = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._data;
	}
	
	/**
	 * @inheritDoc
	 */
	public var groupIndex(get, set):Int;
	private var _groupIndex:Int = -1;
	private function get_groupIndex():Int { return this._groupIndex; }
	private function set_groupIndex(value:Int):Int
	{
		return this._groupIndex = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var layoutIndex(get, set):Int;
	private var _layoutIndex:Int = -1;
	private function get_layoutIndex():Int { return this._layoutIndex; }
	private function set_layoutIndex(value:Int):Int
	{
		return this._layoutIndex = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):GroupedList;
	private var _owner:GroupedList;
	private function get_owner():GroupedList { return this._owner; }
	private function set_owner(value:GroupedList):GroupedList
	{
		if (this._owner == value)
		{
			return value;
		}
		this._owner = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._owner;
	}
	
	/**
	 * @inheritDoc
	 */
	public var factoryID(get, set):String;
	private var _factoryID:String;
	private function get_factoryID():String { return this._factoryID; }
	private function set_factoryID(value:String):String
	{
		return this._factoryID = value;
	}
	
	/**
	 * @private
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.LEFT;
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
	 * The field in the item that contains a display object to be positioned
	 * in the content position of the renderer. If you wish to display a
	 * texture in the content position, it's better for performance to use
	 * <code>contentSourceField</code> instead.
	 *
	 * <p>All of the content fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>contentSourceFunction</code></li>
	 *     <li><code>contentSourceField</code></li>
	 *     <li><code>contentLabelFunction</code></li>
	 *     <li><code>contentLabelField</code></li>
	 *     <li><code>contentFunction</code></li>
	 *     <li><code>contentField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the content field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentField = "header";</listing>
	 *
	 * @default "content"
	 *
	 * @see #contentSourceField
	 * @see #contentFunction
	 * @see #contentSourceFunction
	 * @see #contentLabelField
	 * @see #contentLabelFunction
	 */
	public var contentField(get, set):String;
	private var _contentField:String = "content";
	private function get_contentField():String { return this._contentField; }
	private function set_contentField(value:String):String
	{
		if (this._contentField == value)
		{
			return value;
		}
		this._contentField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentField;
	}
	
	/**
	 * A function that returns a display object to be positioned in the
	 * content position of the renderer. If you wish to display a texture in
	 * the content position, it's better for performance to use
	 * <code>contentSourceFunction</code> instead.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):DisplayObject</pre>
	 *
	 * <p>All of the content fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>contentSourceFunction</code></li>
	 *     <li><code>contentSourceField</code></li>
	 *     <li><code>contentLabelFunction</code></li>
	 *     <li><code>contentLabelField</code></li>
	 *     <li><code>contentFunction</code></li>
	 *     <li><code>contentField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the content function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentFunction = function( item:Object ):DisplayObject
	 * {
	 *    if(item in cachedContent)
	 *    {
	 *        return cachedContent[item];
	 *    }
	 *    var content:DisplayObject = createContentForHeader( item );
	 *    cachedContent[item] = content;
	 *    return content;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #contentField
	 * @see #contentSourceField
	 * @see #contentSourceFunction
	 * @see #contentLabelField
	 * @see #contentLabelFunction
	 */
	public var contentFunction(get, set):Function;
	private var _contentFunction:Function;
	private function get_contentFunction():Function { return this._contentFunction; }
	private function set_contentFunction(value:Function):Function
	{
		if (this._contentFunction == value)
		{
			return value;
		}
		this._contentFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentFunction;
	}
	
	/**
	 * The field in the data that contains a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the renderer's
	 * content. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>contentLoaderFactory</code>.
	 *
	 * <p>Using an content source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * <code>contentField</code> or <code>contentFunction</code> because the
	 * renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>All of the content fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>contentSourceFunction</code></li>
	 *     <li><code>contentSourceField</code></li>
	 *     <li><code>contentLabelFunction</code></li>
	 *     <li><code>contentLabelField</code></li>
	 *     <li><code>contentFunction</code></li>
	 *     <li><code>contentField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the content source field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentSourceField = "texture";</listing>
	 *
	 * @default "source"
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #contentLoaderFactory
	 * @see #contentSourceFunction
	 * @see #contentField
	 * @see #contentFunction
	 * @see #contentLabelField
	 * @see #contentLabelFunction
	 */
	public var contentSourceField(get, set):String;
	private var _contentSourceField:String = "source";
	private function get_contentSourceField():String { return this._contentSourceField; }
	private function set_contentSourceField(value:String):String
	{
		if (this._contentSourceField == value)
		{
			return value;
		}
		this._contentSourceField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentSourceField;
	}
	
	/**
	 * A function used to generate a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the renderer's
	 * content. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>contentLoaderFactory</code>.
	 *
	 * <p>Using an content source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * <code>contentField</code> or <code>contentFunction</code> because the
	 * renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Object</pre>
	 *
	 * <p>The return value is a valid value for the <code>source</code>
	 * property of an <code>ImageLoader</code> component.</p>
	 *
	 * <p>All of the content fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>contentSourceFunction</code></li>
	 *     <li><code>contentSourceField</code></li>
	 *     <li><code>contentLabelFunction</code></li>
	 *     <li><code>contentLabelField</code></li>
	 *     <li><code>contentFunction</code></li>
	 *     <li><code>contentField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the content source function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentSourceFunction = function( item:Object ):Object
	 * {
	 *    return "http://www.example.com/thumbs/" + item.name + "-thumb.png";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #contentLoaderFactory
	 * @see #contentSourceField
	 * @see #contentField
	 * @see #contentFunction
	 * @see #contentLabelField
	 * @see #contentLabelFunction
	 */
	public var contentSourceFunction(get, set):Function;
	private var _contentSourceFunction:Function;
	private function get_contentSourceFunction():Function { return this._contentSourceFunction; }
	private function set_contentSourceFunction(value:Function):Function
	{
		if (this.contentSourceFunction == value)
		{
			return value;
		}
		this._contentSourceFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentSourceFunction;
	}
	
	/**
	 * The field in the item that contains a string to be displayed in a
	 * renderer-managed <code>Label</code> in the content position of the
	 * renderer. The renderer will automatically reuse an internal
	 * <code>Label</code> and swap the text when the data changes. This
	 * <code>Label</code> may be skinned by changing the
	 * <code>contentLabelFactory</code>.
	 *
	 * <p>Using an content label will result in better performance than
	 * passing in a <code>Label</code> through a <code>contentField</code>
	 * or <code>contentFunction</code> because the renderer can avoid
	 * costly display list manipulation.</p>
	 *
	 * <p>All of the content fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>contentTextureFunction</code></li>
	 *     <li><code>contentTextureField</code></li>
	 *     <li><code>contentLabelFunction</code></li>
	 *     <li><code>contentLabelField</code></li>
	 *     <li><code>contentFunction</code></li>
	 *     <li><code>contentField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the content label field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentLabelField = "text";</listing>
	 *
	 * @default "label"
	 *
	 * @see #contentLabelFactory
	 * @see #contentLabelFunction
	 * @see #contentField
	 * @see #contentFunction
	 * @see #contentSourceField
	 * @see #contentSourceFunction
	 */
	public var contentLabelField(get, set):String;
	private var _contentLabelField:String = "label";
	private function get_contentLabelField():String { return this._contentLabelField; }
	private function set_contentLabelField(value:String):String
	{
		if (this._contentLabelField == value)
		{
			return value;
		}
		this._contentLabelField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentLabelField;
	}
	
	/**
	 * A function that returns a string to be displayed in a
	 * renderer-managed <code>Label</code> in the content position of the
	 * renderer. The renderer will automatically reuse an internal
	 * <code>Label</code> and swap the text when the data changes. This
	 * <code>Label</code> may be skinned by changing the
	 * <code>contentLabelFactory</code>.
	 *
	 * <p>Using an content label will result in better performance than
	 * passing in a <code>Label</code> through a <code>contentField</code>
	 * or <code>contentFunction</code> because the renderer can avoid
	 * costly display list manipulation.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):String</pre>
	 *
	 * <p>All of the content fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>contentTextureFunction</code></li>
	 *     <li><code>contentTextureField</code></li>
	 *     <li><code>contentLabelFunction</code></li>
	 *     <li><code>contentLabelField</code></li>
	 *     <li><code>contentFunction</code></li>
	 *     <li><code>contentField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the content label function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentLabelFunction = function( item:Object ):String
	 * {
	 *    return item.category + " > " + item.subCategory;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #contentLabelFactory
	 * @see #contentLabelField
	 * @see #contentField
	 * @see #contentFunction
	 * @see #contentSourceField
	 * @see #contentSourceFunction
	 */
	public var contentLabelFunction(get, set):Function;
	private var _contentLabelFunction:Function;
	private function get_contentLabelFunction():Function { return this._contentLabelFunction; }
	private function set_contentLabelFunction(value:Function):Function
	{
		if (this._contentLabelFunction == value)
		{
			return value;
		}
		this._contentLabelFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._contentLabelFunction;
	}
	
	/**
	 * A function that generates an <code>ImageLoader</code> that uses the result
	 * of <code>contentSourceField</code> or <code>contentSourceFunction</code>.
	 * Useful for transforming the <code>ImageLoader</code> in some way. For
	 * example, you might want to scale it for current screen density or
	 * apply pixel snapping.
	 *
	 * <p>In the following example, a custom content loader factory is passed
	 * to the renderer:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentLoaderFactory = function():ImageLoader
	 * {
	 *     var loader:ImageLoader = new ImageLoader();
	 *     loader.scaleFactor = 2;
	 *     return loader;
	 * };</listing>
	 *
	 * @default function():ImageLoader { return new ImageLoader(); }
	 *
	 * @see feathers.controls.ImageLoader
	 * @see #contentSourceField
	 * @see #contentSourceFunction
	 */
	public var contentLoaderFactory(get, set):Function;
	private var _contentLoaderFactory:Function = defaultImageLoaderFactory;
	private function get_contentLoaderFactory():Function { return this._contentLoaderFactory; }
	private function set_contentLoaderFactory(value:Function):Function
	{
		if (this._contentLoaderFactory == value)
		{
			return value;
		}
		this._contentLoaderFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._contentLoaderFactory;
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
	 * A function that generates an <code>ITextRenderer</code> that uses the result
	 * of <code>contentLabelField</code> or <code>contentLabelFunction</code>.
	 * Can be used to set properties on the <code>ITextRenderer</code>.
	 *
	 * <p>In the following example, a custom content label factory is passed
	 * to the renderer:</p>
	 *
	 * <listing version="3.0">
	 * renderer.contentLabelFactory = function():ITextRenderer
	 * {
	 *     var renderer:TextFieldTextRenderer = new TextFieldTextRenderer();
	 *     renderer.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 *     renderer.embedFonts = true;
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 * @see #contentLabelField
	 * @see #contentLabelFunction
	 */
	public var contentLabelFactory(get, set):Function;
	private var _contentLabelFactory:Function;
	private function get_contentLabelFactory():Function { return this._contentLabelFactory; }
	private function set_contentLabelFactory(value:Function):Function
	{
		if (this._contentLabelFactory == value)
		{
			return value;
		}
		this._contentLabelFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._contentLabelFactory;
	}
	
	/**
	 * @private
	 */
	public var customContentLabelStyleName(get, set):String;
	private var _customContentLabelStyleName:String;
	private function get_customContentLabelStyleName():String { return this._customContentLabelStyleName; }
	private function set_customContentLabelStyleName(value:String):String
	{
		if (this.processStyleRestriction("customContentLabelStyleName"))
		{
			return value;
		}
		if (this._customContentLabelStyleName == value)
		{
			return value;
		}
		this._customContentLabelStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customContentLabelStyleName;
	}
	
	
	public var contentLabelProperties(get, set):Dynamic;
	private var _contentLabelProperties:PropertyProxy;
	private function get_contentLabelProperties():Dynamic
	{
		if (this._contentLabelProperties == null)
		{
			this._contentLabelProperties = new PropertyProxy(contentLabelProperties_onChange);
		}
		return this._contentLabelProperties;
	}
	
	private function set_contentLabelProperties(value:Dynamic):Dynamic
	{
		if (this._contentLabelProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxyReal))
		{
			value = PropertyProxy.fromObject(value);
		}
		if (this._contentLabelProperties != null)
		{
			this._contentLabelProperties.removeOnChangeCallback(contentLabelProperties_onChange);
			this._contentLabelProperties.dispose();
		}
		this._contentLabelProperties = cast value;
		if (this._contentLabelProperties != null)
		{
			this._contentLabelProperties.addOnChangeCallback(contentLabelProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._contentLabelProperties;
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
	private var _explicitContentWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentHeight:Float;

	/**
	 * @private
	 */
	private var _explicitContentMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitContentMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentMaxHeight:Float;

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
		return this._paddingLeft;
	}
	
	/**
	 * The number of text lines displayed by the renderer. The component may
	 * contain multiple text lines if the text contains line breaks or if
	 * the <code>wordWrap</code> property is enabled.
	 *
	 * @see #wordWrap
	 */
	public var numLines(get, never):Int;
	private function get_numLines():Int
	{
		if (this.contentLabel == null)
		{
			return 0;
		}
		return this.contentLabel.numLines;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the renderer is the parent because it'll
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
		
		//the content may have come from outside of this class. it's up
		//to that code to dispose of the content. in fact, if we disposed
		//of it here, we might screw something up!
		if (this.content != null)
		{
			this.content.removeFromParent();
		}
		
		//however, we need to dispose these, if they exist, since we made
		//them here.
		if (this.contentImage != null)
		{
			this.contentImage.dispose();
			this.contentImage = null;
		}
		if (this.contentLabel != null)
		{
			this.contentLabel.dispose();
			this.contentLabel = null;
		}
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		if (this._contentLabelProperties != null)
		{
			this._contentLabelProperties.dispose();
			this._contentLabelProperties = null;
		}
		super.dispose();
	}
	
	/**
	 * Uses the content fields and functions to generate content for a
	 * specific group header or footer.
	 *
	 * <p>All of the content fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>contentTextureFunction</code></li>
	 *     <li><code>contentTextureField</code></li>
	 *     <li><code>contentLabelFunction</code></li>
	 *     <li><code>contentLabelField</code></li>
	 *     <li><code>contentFunction</code></li>
	 *     <li><code>contentField</code></li>
	 * </ol>
	 */
	private function itemToContent(item:Dynamic):DisplayObject
	{
		var source:Dynamic;
		var labelResult:Dynamic;
		if (this._contentSourceFunction != null)
		{
			source = this._contentSourceFunction(item);
			this.refreshContentSource(source);
			return this.contentImage;
		}
		else if (this._contentSourceField != null && item != null && Reflect.hasField(item, this._contentSourceField))
		{
			source = Reflect.getProperty(item, this._contentSourceField);
			this.refreshContentSource(source);
			return this.contentImage;
		}
		else if (this._contentLabelFunction != null)
		{
			labelResult = this._contentLabelFunction(item);
			if (Std.isOfType(labelResult, String))
			{
				this.refreshContentLabel(cast labelResult);
			}
			else if (labelResult != null)
			{
				this.refreshContentLabel(labelResult.toString());
			}
			else
			{
				this.refreshContentLabel(null);
			}
			return cast this.contentLabel;
		}
		else if (this._contentLabelField != null && item && Reflect.hasField(item, this._contentLabelField))
		{
			labelResult = Reflect.getProperty(item, this._contentLabelField);
			if (Std.isOfType(labelResult, String))
			{
				this.refreshContentLabel(cast labelResult);
			}
			else if (labelResult != null)
			{
				this.refreshContentLabel(labelResult.toString());
			}
			else
			{
				this.refreshContentLabel(null);
			}
			return cast this.contentLabel;
		}
		else if (this._contentFunction != null)
		{
			return cast this._contentFunction(item);
		}
		else if (this._contentField != null && item != null && Reflect.hasField(item, this._contentField))
		{
			return cast Reflect.getProperty(item, this._contentField);
		}
		else if (Std.isOfType(item, String))
		{
			this.refreshContentLabel(cast item);
			return cast this.contentLabel;
		}
		else if (item != null)
		{
			this.refreshContentLabel(item.toString());
			return cast this.contentLabel;
		}
		else
		{
			this.refreshContentLabel(null);
		}
		
		return null;
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshBackgroundSkin();
		}
		
		if (dataInvalid)
		{
			this.commitData();
		}
		
		if (dataInvalid || stylesInvalid)
		{
			this.refreshContentLabelStyles();
		}
		
		if (dataInvalid || stateInvalid)
		{
			this.refreshEnabled();
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
		var measureContent:IMeasureDisplayObject = SafeCast.safe_cast(this.content, IMeasureDisplayObject);
		if (this.contentLabel != null)
		{
			//special case for label to allow word wrap
			var labelMaxWidth:Float = this._explicitWidth;
			if (needsWidth)
			{
				labelMaxWidth = this._explicitMaxWidth;
			}
			this.contentLabel.maxWidth = labelMaxWidth - this._paddingLeft - this._paddingRight;
			this.contentLabel.measureText(HELPER_POINT);
		}
		else if (this.content != null)
		{
			if (this._horizontalAlign == HorizontalAlign.JUSTIFY && this._verticalAlign == VerticalAlign.JUSTIFY)
			{
				SkinsUtils.resetFluidChildDimensionsForMeasurement(this.content,
					this._explicitWidth - this._paddingLeft - this._paddingRight,
					this._explicitHeight - this._paddingTop - this._paddingBottom,
					this._explicitMinWidth - this._paddingLeft - this._paddingRight,
					this._explicitMinHeight - this._paddingTop - this._paddingBottom,
					this._explicitMaxWidth - this._paddingLeft - this._paddingRight,
					this._explicitMaxHeight - this._paddingTop - this._paddingBottom,
					this._explicitContentWidth, this._explicitContentHeight,
					this._explicitContentMinWidth, this._explicitContentMinHeight,
					this._explicitContentMaxWidth, this._explicitContentMaxHeight);
			}
			else
			{
				this.content.width = this._explicitContentWidth;
				this.content.height = this._explicitContentHeight;
				if (measureContent != null)
				{
					measureContent.minWidth = this._explicitContentMinWidth;
					measureContent.minHeight = this._explicitContentMinHeight;
				}
			}
			if (Std.isOfType(this.content, IValidating))
			{
				cast(this.content, IValidating).validate();
			}
		}
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		var measureSkin:IMeasureDisplayObject = SafeCast.safe_cast(this.currentBackgroundSkin, IMeasureDisplayObject);
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (this.contentLabel != null)
			{
				newWidth = HELPER_POINT.x;
			}
			else if (this.content != null)
			{
				newWidth = this.content.width;
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
			if (this.contentLabel != null)
			{
				newHeight = HELPER_POINT.y;
			}
			else if (this.content != null)
			{
				newHeight = this.content.height;
			}
			else
			{
				newHeight = 0;
			}
			newHeight += this._paddingTop + this._paddingBottom;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.height > newHeight)
			{
				newHeight = this.currentBackgroundSkin.height;
			}
		}
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (this.contentLabel != null)
			{
				newMinWidth = HELPER_POINT.x;
			}
			else if (measureContent != null)
			{
				newMinWidth = measureContent.minWidth;
			}
			else if (this.content != null)
			{
				newMinWidth = this.content.width;
			}
			else
			{
				newMinWidth = 0;
			}
			newMinWidth += this._paddingLeft + this._paddingRight;
			if (this.currentBackgroundSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minWidth > newMinWidth)
					{
						newMinWidth = measureSkin.minWidth;
					}
				}
				else if (this._explicitBackgroundMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitBackgroundMinWidth;
				}
			}
		}
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (this.contentLabel != null)
			{
				newMinHeight = HELPER_POINT.y;
			}
			else if (measureContent != null)
			{
				newMinHeight = measureContent.minHeight;
			}
			else if (this.content != null)
			{
				newMinHeight = this.content.height;
			}
			else
			{
				newMinHeight = 0;
			}
			newMinHeight += this._paddingTop + this._paddingBottom;
			if (this.currentBackgroundSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minHeight > newMinHeight)
					{
						newMinHeight = measureSkin.minHeight;
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
	 * @private
	 */
	private function refreshBackgroundSkin():Void
	{
		var oldBackgroundSkin:DisplayObject = this.currentBackgroundSkin;
		this.currentBackgroundSkin = this._backgroundSkin;
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			this.currentBackgroundSkin = this._backgroundDisabledSkin;
		}
		if (oldBackgroundSkin != this.currentBackgroundSkin)
		{
			this.removeCurrentBackgroundSkin(oldBackgroundSkin);
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
	 * @private
	 */
	private function commitData():Void
	{
		if (this._owner != null)
		{
			var newContent:DisplayObject = this.itemToContent(this._data);
			if (newContent != this.content)
			{
				if (this.content != null)
				{
					this.content.removeFromParent();
				}
				this.content = newContent;
				if (this.content != null)
				{
					this.addChild(this.content);
					if (Std.isOfType(this.content, IFeathersControl))
					{
						cast(this.content, IFeathersControl).initializeNow();
					}
					if (Std.isOfType(this.content, IMeasureDisplayObject))
					{
						var measureSkin:IMeasureDisplayObject = cast this.content;
						this._explicitContentWidth = measureSkin.explicitWidth;
						this._explicitContentHeight = measureSkin.explicitHeight;
						this._explicitContentMinWidth = measureSkin.explicitMinWidth;
						this._explicitContentMinHeight = measureSkin.explicitMinHeight;
						this._explicitContentMaxWidth = measureSkin.explicitMaxWidth;
						this._explicitContentMaxHeight = measureSkin.explicitMaxHeight;
					}
					else
					{
						this._explicitContentWidth = this.content.width;
						this._explicitContentHeight = this.content.height;
						this._explicitContentMinWidth = this._explicitContentWidth;
						this._explicitContentMinHeight = this._explicitContentHeight;
						this._explicitContentMaxWidth = this._explicitContentWidth;
						this._explicitContentMaxHeight = this._explicitContentHeight;
					}
				}
			}
		}
		else
		{
			if (this.content != null)
			{
				this.content.removeFromParent();
				this.content = null;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshContentSource(source:Dynamic):Void
	{
		if (this.contentImage == null)
		{
			this.contentImage = this._contentLoaderFactory();
		}
		this.contentImage.source = source;
	}
	
	/**
	 * @private
	 */
	private function refreshContentLabel(label:String):Void
	{
		if (label != null)
		{
			if (this.contentLabel == null)
			{
				var factory:Function = this._contentLabelFactory != null ? this._contentLabelFactory : FeathersControl.defaultTextRendererFactory;
				this.contentLabel = cast factory();
				var contentLabelStyleName:String = this._customContentLabelStyleName != null ? this._customContentLabelStyleName : this.contentLabelStyleName;
				cast(this.contentLabel, FeathersControl).styleNameList.add(contentLabelStyleName);
			}
			this.contentLabel.text = label;
		}
		else if (this.contentLabel != null)
		{
			cast(this.contentLabel, DisplayObject).removeFromParent(true);
			this.contentLabel = null;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		if (Std.isOfType(this.content, IFeathersControl))
		{
			cast(this.content, IFeathersControl).isEnabled = this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshContentLabelStyles():Void
	{
		if (this.contentLabel == null)
		{
			return;
		}
		this.contentLabel.fontStyles = this._fontStylesSet;
		this.contentLabel.wordWrap = this._wordWrap;
		
		var propertyValue:Dynamic;
		for (propertyName in this._contentLabelProperties)
		{
			propertyValue = this._contentLabelProperties[propertyName];
			Reflect.setProperty(this.contentLabel, propertyName, propertyValue);
		}
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		if (this.currentBackgroundSkin != null)
		{
			this.currentBackgroundSkin.width = this.actualWidth;
			this.currentBackgroundSkin.height = this.actualHeight;
		}
		
		if (this.content == null)
		{
			return;
		}
		
		if (this.contentLabel != null)
		{
			this.contentLabel.maxWidth = this.actualWidth - this._paddingLeft - this._paddingRight;
		}
		
		if (Std.isOfType(this.content, IValidating))
		{
			cast(this.content, IValidating).validate();
		}
		switch (this._horizontalAlign)
		{
			case HorizontalAlign.CENTER:
				this.content.x = this._paddingLeft + (this.actualWidth - this._paddingLeft - this._paddingRight - this.content.width) / 2;
			
			case HorizontalAlign.RIGHT:
				this.content.x = this.actualWidth - this._paddingRight - this.content.width;
			
			case HorizontalAlign.JUSTIFY:
				this.content.x = this._paddingLeft;
				this.content.width = this.actualWidth - this._paddingLeft - this._paddingRight;
			
			default: //left
				this.content.x = this._paddingLeft;
		}
		
		switch (this._verticalAlign)
		{
			case VerticalAlign.TOP:
				this.content.y = this._paddingTop;
			
			case VerticalAlign.BOTTOM:
				this.content.y = this.actualHeight - this._paddingBottom - this.content.height;
			
			case VerticalAlign.JUSTIFY:
				this.content.y = this._paddingTop;
				this.content.height = this.actualHeight - this._paddingTop - this._paddingBottom;
			
			default: //middle
				this.content.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.content.height) / 2;
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
	private function contentLabelProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}