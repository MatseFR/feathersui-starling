package feathers.starling.controls;
import feathers.starling.controls.supportClasses.TextFieldViewPort;
import feathers.starling.core.FeathersControl;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.text.FontStylesSet;
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
import openfl.text.StyleSheet;
import starling.events.Event;

/**
 * Displays long passages of text in a scrollable container using the
 * runtime's software-based <code>flash.text.TextField</code> as an overlay
 * above Starling content on the classic display list. This component will
 * <strong>always</strong> appear above Starling content. The only way to
 * put something above ScrollText is to put something above it on the
 * classic display list.
 *
 * <p>Meant as a workaround component for when TextFieldTextRenderer runs
 * into the runtime texture limits.</p>
 *
 * <p>Since this component is rendered with the runtime's software renderer,
 * rather than on the GPU, it may not perform very well on mobile devices
 * with high resolution screens.</p>
 *
 * <p>The following example displays some text:</p>
 *
 * <listing version="3.0">
 * var scrollText:ScrollText = new ScrollText();
 * scrollText.text = "Hello World";
 * this.addChild( scrollText );</listing>
 *
 * @see ../../../help/scroll-text.html How to use the Feathers ScrollText component
 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html flash.text.TextField
 *
 * @productversion Feathers 1.0.0
 */
class ScrollText extends Scroller 
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>ScrollText</code>
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
		this.textViewPort = new TextFieldViewPort();
		this.textViewPort.addEventListener(Event.TRIGGERED, textViewPort_triggeredHandler);
		this.viewPort = this.textViewPort;
	}
	
	/**
	 * @private
	 */
	private var textViewPort:TextFieldViewPort;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return ScrollText.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	public var nativeFocus(get, never):Dynamic;
	private function get_nativeFocus():Dynamic
	{
		if (this.viewPort == null)
		{
			return null;
		}
		return this.textViewPort.nativeFocus;
	}
	
	/**
	 * The text to display. If <code>isHTML</code> is <code>true</code>, the
	 * text will be rendered as HTML with the same capabilities as the
	 * <code>htmlText</code> property of <code>flash.text.TextField</code>.
	 *
	 * <p>In the following example, some text is displayed:</p>
	 *
	 * <listing version="3.0">
	 * scrollText.text = "Hello World";</listing>
	 *
	 * @default ""
	 *
	 * @see #isHTML
	 */
	public var text(get, set):String;
	private var _text:String = "";
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (value == null)
		{
			value = "";
		}
		if (this._text == value)
		{
			return value;
		}
		this._text = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._text;
	}
	
	/**
	 * Determines if the TextField should display the text as HTML or not.
	 *
	 * <p>In the following example, some HTML-formatted text is displayed:</p>
	 *
	 * <listing version="3.0">
	 * scrollText.isHTML = true;
	 * scrollText.text = "&lt;b&gt;Hello&lt;/b&gt; &lt;i&gt;World&lt;/i&gt;";</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#htmlText flash.text.TextField.htmlText
	 * @see #text
	 */
	public var isHTML(get, set):Bool;
	private var _isHTML:Bool = false;
	private function get_isHTML():Bool { return this._isHTML; }
	private function set_isHTML(value:Bool):Bool
	{
		if (this._isHTML == value)
		{
			return value;
		}
		this._isHTML = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._isHTML;
	}
	
	/**
	 * @private
	 */
	private var _fontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var fontStyles(get, set):starling.text.TextFormat;
	private function get_fontStyles():starling.text.TextFormat { return this._fontStylesSet.format; }
	private function set_fontStyles(value:starling.text.TextFormat):starling.text.TextFormat
	{
		if (this.processStyleRestriction("fontStyles"))
		{
			return value;
		}
		return this._fontStylesSet.format = value;
	}
	
	/**
	 * @private
	 */
	public var disabledFontStyles(get, set):starling.text.TextFormat;
	private function get_disabledFontStyles():starling.text.TextFormat { return this._fontStylesSet.disabledFormat; }
	private function set_disabledFontStyles(value:starling.text.TextFormat):starling.text.TextFormat
	{
		if (this.processStyleRestriction("disabledFontStyles"))
		{
			return value;
		}
		return this._fontStylesSet.disabledFormat = value;
	}
	
	/**
	 * @private
	 */
	public var textFormat(get, set):openfl.text.TextFormat;
	private var _textFormat:openfl.text.TextFormat;
	private function get_textFormat():openfl.text.TextFormat { return this._textFormat; }
	private function set_textFormat(value:openfl.text.TextFormat):openfl.text.TextFormat
	{
		if (this.processStyleRestriction("textFormat"))
		{
			return value;
		}
		if (this._textFormat == value)
		{
			return value;
		}
		this._textFormat = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textFormat;
	}
	
	/**
	 * @private
	 */
	public var disabledTextFormat(get, set):openfl.text.TextFormat;
	private var _disabledTextFormat:openfl.text.TextFormat;
	private function get_disabledTextFormat():openfl.text.TextFormat { return this._disabledTextFormat; }
	private function set_disabledTextFormat(value:openfl.text.TextFormat):openfl.text.TextFormat
	{
		if (this.processStyleRestriction("disabledTextFormat"))
		{
			return value;
		}
		if (this._disabledTextFormat == value)
		{
			return value;
		}
		this._disabledTextFormat = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._disabledTextFormat;
	}
	
	/**
	 * @private
	 */
	public var styleSheet(get, set):StyleSheet;
	private var _styleSheet:StyleSheet;
	private function get_styleSheet():StyleSheet { return this._styleSheet; }
	private function set_styleSheet(value:StyleSheet):StyleSheet
	{
		if (this.processStyleRestriction("styleSheet"))
		{
			return value;
		}
		if (this._styleSheet == value)
		{
			return value;
		}
		this._styleSheet = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._styleSheet;
	}
	
	/**
	 * @private
	 */
	public var embedFonts(get, set):Bool;
	private var _embedFonts:Bool = false;
	private function get_embedFonts():Bool { return this._embedFonts; }
	private function set_embedFonts(value:Bool):Bool
	{
		if (this.processStyleRestriction("embedFonts"))
		{
			return value;
		}
		if (this._embedFonts == value)
		{
			return value;
		}
		this._embedFonts = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._embedFonts;
	}
	
	/**
	 * @private
	 */
	public var antiAliasType(get, set):String;
	private var _antiAliasType:String = AntiAliasType.ADVANCED;
	private function get_antiAliasType():String { return this._antiAliasType; }
	private function set_antiAliasType(value:String):String
	{
		if (this.processStyleRestriction("antiAliasType"))
		{
			return value;
		}
		if (this._antiAliasType == value)
		{
			return value;
		}
		this._antiAliasType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._antiAliasType;
	}
	
	/**
	 * @private
	 */
	public var background(get, set):Bool;
	private var _background:Bool = false;
	private function get_background():Bool { return this._background; }
	private function set_background(value:Bool):Bool
	{
		if (this.processStyleRestriction("background"))
		{
			return value;
		}
		if (this._background == value)
		{
			return value;
		}
		this._background = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._background;
	}
	
	/**
	 * @private
	 */
	public var backgroundColor(get, set):Int;
	private var _backgroundColor:Int = 0xffffff;
	private function get_backgroundColor():Int { return this._backgroundColor; }
	private function set_backgroundColor(value:Int):Int
	{
		if (this.processStyleRestriction("backgroundColor"))
		{
			return value;
		}
		if (this._backgroundColor == value)
		{
			return value;
		}
		this._backgroundColor = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundColor;
	}
	
	/**
	 * @private
	 */
	public var border(get, set):Bool;
	private var _border:Bool = false;
	private function get_border():Bool { return this._border; }
	private function set_border(value:Bool):Bool
	{
		if (this.processStyleRestriction("border"))
		{
			return value;
		}
		if (this._border == value)
		{
			return value;
		}
		this._border = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._border;
	}
	
	/**
	 * @private
	 */
	public var borderColor(get, set):Int;
	private var _borderColor:Int = 0x000000;
	private function get_borderColor():Int { return this._borderColor; }
	private function set_borderColor(value:Int):Int
	{
		if (this.processStyleRestriction("borderColor"))
		{
			return value;
		}
		if (this._borderColor == value)
		{
			return value;
		}
		this._borderColor = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._borderColor;
	}
	
	/**
	 * @private
	 */
	public var cacheAsBitmap(get, set):Bool;
	private var _cacheAsBitmap:Bool = true;
	private function get_cacheAsBitmap():Bool { return this._cacheAsBitmap; }
	private function set_cacheAsBitmap(value:Bool):Bool
	{
		if (this.processStyleRestriction("cacheAsBitmap"))
		{
			return value;
		}
		if (this._cacheAsBitmap == value)
		{
			return value;
		}
		this._cacheAsBitmap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._cacheAsBitmap;
	}
	
	/**
	 * @private
	 */
	public var condenseWhite(get, set):Bool;
	private var _condenseWhite:Bool = false;
	private function get_condenseWhite():Bool { return this._condenseWhite; }
	private function set_condenseWhite(value:Bool):Bool
	{
		if (this.processStyleRestriction("condenseWhite"))
		{
			return value;
		}
		if (this._condenseWhite == value)
		{
			return value;
		}
		this._condenseWhite = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._condenseWhite;
	}
	
	/**
	 * @private
	 */
	public var displayAsPassword(get, set):Bool;
	private var _displayAsPassword:Bool = false;
	private function get_displayAsPassword():Bool { return this._displayAsPassword; }
	private function set_displayAsPassword(value:Bool):Bool
	{
		if (this.processStyleRestriction("displayAsPassword"))
		{
			return value;
		}
		if (this._displayAsPassword == value)
		{
			return value;
		}
		this._displayAsPassword = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._displayAsPassword;
	}
	
	/**
	 * @private
	 */
	public var gridFitType(get, set):String;
	private var _gridFitType:String = GridFitType.PIXEL;
	private function get_gridFitType():String { return this._gridFitType; }
	private function set_gridFitType(value:String):String
	{
		if (this.processStyleRestriction("gridFitType"))
		{
			return value;
		}
		if (this._gridFitType == value)
		{
			return value;
		}
		this._gridFitType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._gridFitType;
	}
	
	/**
	 * @private
	 */
	public var sharpness(get, set):Float;
	private var _sharpness:Float = 0;
	private function get_sharpness():Float { return this._sharpness; }
	private function set_sharpness(value:Float):Float
	{
		if (this.processStyleRestriction("sharpness"))
		{
			return value;
		}
		if (this._sharpness == value)
		{
			return value;
		}
		this._sharpness = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._sharpness;
	}
	
	/**
	 * @private
	 */
	public var thickness(get, set):Float;
	private var _thickness:Float = 0;
	private function get_thickness():Float { return this._thickness; }
	private function set_thickness(value:Float):Float
	{
		if (this.processStyleRestriction("thickness"))
		{
			return value;
		}
		if (this._thickness == value)
		{
			return value;
		}
		this._thickness = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._thickness;
	}
	
	/**
	 * @private
	 */
	override function get_padding():Float 
	{
		return this._textPaddingTop;
	}
	
	//no setter for padding because the one in Scroller is acceptable
	
	/**
	 * @private
	 */
	private var _textPaddingTop:Float = 0;
	
	override function get_paddingTop():Float { return this._textPaddingTop; }
	
	override function set_paddingTop(value:Float):Float 
	{
		if (this.processStyleRestriction("paddingTop"))
		{
			return value;
		}
		if (this._textPaddingTop == value)
		{
			return value;
		}
		this._textPaddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textPaddingTop;
	}
	
	/**
	 * @private
	 */
	private var _textPaddingRight:Float = 0;
	
	override function get_paddingRight():Float { return this._textPaddingRight; }
	
	override function set_paddingRight(value:Float):Float 
	{
		if (this.processStyleRestriction("paddingRight"))
		{
			return value;
		}
		if (this._textPaddingRight == value)
		{
			return value;
		}
		this._textPaddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textPaddingRight;
	}
	
	/**
	 * @private
	 */
	private var _textPaddingBottom:Float = 0;
	
	override function get_paddingBottom():Float { return this._textPaddingBottom; }
	
	override function set_paddingBottom(value:Float):Float 
	{
		if (this.processStyleRestriction("paddingBottom"))
		{
			return value;
		}
		if (this._textPaddingBottom == value)
		{
			return value;
		}
		this._textPaddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textPaddingBottom;
	}
	
	/**
	 * @private
	 */
	private var _textPaddingLeft:Float = 0;
	
	override function get_paddingLeft():Float { return this._textPaddingLeft; }
	
	override function set_paddingLeft(value:Float):Float 
	{
		if (this.processStyleRestriction("paddingLeft"))
		{
			return value;
		}
		if (this._textPaddingLeft == value)
		{
			return value;
		}
		this._textPaddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textPaddingLeft;
	}
	
	/**
	 * @private
	 */
	public var outerPadding(get, set):Float;
	private function get_outerPadding():Float { return this._outerPaddingTop; }
	private function set_outerPadding(value:Float):Float
	{
		this.outerPaddingTop = value;
		this.outerPaddingRight = value;
		this.outerPaddingBottom = value;
		return this.outerPaddingLeft = value;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingTop(get, set):Float;
	private var _outerPaddingTop:Float = 0;
	private function get_outerPaddingTop():Float { return this._outerPaddingTop; }
	private function set_outerPaddingTop(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingTop"))
		{
			return value;
		}
		if (this._outerPaddingTop == value)
		{
			return value;
		}
		this._outerPaddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingTop;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingRight(get, set):Float;
	private var _outerPaddingRight:Float = 0;
	private function get_outerPaddingRight():Float { return this._outerPaddingRight; }
	private function set_outerPaddingRight(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingRight"))
		{
			return value;
		}
		if (this._outerPaddingRight == value)
		{
			return value;
		}
		this._outerPaddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingRight;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingBottom(get, set):Float;
	private var _outerPaddingBottom:Float = 0;
	private function get_outerPaddingBottom():Float { return this._outerPaddingBottom; }
	private function set_outerPaddingBottom(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingBottom"))
		{
			return value;
		}
		if (this._outerPaddingBottom == value)
		{
			return value;
		}
		this._outerPaddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingBottom;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingLeft(get, set):Float;
	private var _outerPaddingLeft:Float = 0;
	private function get_outerPaddingLeft():Float { return this._outerPaddingLeft; }
	private function set_outerPaddingLeft(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingLeft"))
		{
			return value;
		}
		if (this._outerPaddingLeft == value)
		{
			return value;
		}
		this._outerPaddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingLeft;
	}
	
	/**
	 * @private
	 */
	private var _visible:Bool = true;
	override function get_visible():Bool 
	{
		return this._visible;
	}
	
	override function set_visible(value:Bool):Bool 
	{
		if (this._visible == value)
		{
			return value;
		}
		this._visible = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._visible;
	}
	
	/**
	 * @private
	 */
	private var _alpha:Float = 1;
	override function get_alpha():Float 
	{
		return this._alpha;
	}
	
	override function set_alpha(value:Float):Float 
	{
		if (this._alpha == value)
		{
			return value;
		}
		this._alpha = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._alpha;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var scrollInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SCROLL);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		
		if (dataInvalid)
		{
			this.textViewPort.text = this._text;
			this.textViewPort.isHTML = this._isHTML;
		}
		
		if (stylesInvalid)
		{
			this.textViewPort.antiAliasType = this._antiAliasType;
			this.textViewPort.background = this._background;
			this.textViewPort.backgroundColor = this._backgroundColor;
			this.textViewPort.border = this._border;
			this.textViewPort.borderColor = this._borderColor;
			this.textViewPort.cacheAsBitmap = this._cacheAsBitmap;
			this.textViewPort.condenseWhite = this._condenseWhite;
			this.textViewPort.displayAsPassword = this._displayAsPassword;
			this.textViewPort.gridFitType = this._gridFitType;
			this.textViewPort.sharpness = this._sharpness;
			this.textViewPort.thickness = this._thickness;
			this.textViewPort.textFormat = this._textFormat;
			this.textViewPort.disabledTextFormat = this._disabledTextFormat;
			this.textViewPort.fontStyles = this._fontStylesSet;
			this.textViewPort.styleSheet = this._styleSheet;
			this.textViewPort.embedFonts = this._embedFonts;
			this.textViewPort.paddingTop = this._textPaddingTop;
			this.textViewPort.paddingRight = this._textPaddingRight;
			this.textViewPort.paddingBottom = this._textPaddingBottom;
			this.textViewPort.paddingLeft = this._textPaddingLeft;
			this.textViewPort.visible = this._visible;
			this.textViewPort.alpha = this._alpha;
		}
		
		super.draw();
	}
	
	/**
	 * @private
	 */
	override function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void
	{
		super.calculateViewPortOffsets(forceScrollBars);
		
		this._topViewPortOffset += this._outerPaddingTop;
		this._rightViewPortOffset += this._outerPaddingRight;
		this._bottomViewPortOffset += this._outerPaddingBottom;
		this._leftViewPortOffset += this._outerPaddingLeft;
	}
	
	/**
	 * @private
	 */
	private function textViewPort_triggeredHandler(event:Event, link:String):Void
	{
		this.dispatchEventWith(Event.TRIGGERED, false, link);
	}

	/**
	 * @private
	 */
	private function fontStyles_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}