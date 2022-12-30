/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.text;
import feathers.core.FeathersControl;
import feathers.core.ITextRenderer;
import feathers.core.IToggle;
import feathers.skins.IStyleProvider;
import feathers.text.BitmapFontTextFormat;
import feathers.utils.ReverseIterator;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextFormatAlign;
import feathers.core.IFeathersControl;
import starling.display.Image;
import starling.display.MeshBatch;
import starling.rendering.Painter;
import starling.styles.MeshStyle;
import starling.text.BitmapChar;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.utils.Align;
import starling.utils.MathUtil;
import starling.utils.Pool;

/**
 * Renders text using
 * <a href="http://wiki.starling-framework.org/manual/displaying_text#bitmap_fonts" target="_top">bitmap fonts</a>.
 *
 * <p>The following example shows how to use
 * <code>BitmapFontTextRenderer</code> with a <code>Label</code>:</p>
 *
 * <listing version="3.0">
 * var label:Label = new Label();
 * label.text = "I am the very model of a modern Major General";
 * label.textRendererFactory = function():ITextRenderer
 * {
 *     return new BitmapFontTextRenderer();
 * };
 * this.addChild( label );</listing>
 *
 * @see ../../../../help/text-renderers.html Introduction to Feathers text renderers
 * @see ../../../../help/bitmap-font-text-renderer.html How to use the Feathers BitmapFontTextRenderer component
 * @see http://wiki.starling-framework.org/manual/displaying_text#bitmap_fonts Starling Wiki: Displaying Text with Bitmap Fonts
 *
 * @productversion Feathers 1.0.0
 */
class BitmapFontTextRenderer extends BaseTextRenderer implements ITextRenderer
{
	/**
	 * @private
	 */
	private static var HELPER_RESULT:MeasureTextResult = new MeasureTextResult();
	
	/**
	 * @private
	 */
	private static inline var CHARACTER_ID_SPACE:Int = 32;
	
	/**
	 * @private
	 */
	private static inline var CHARACTER_ID_TAB:Int = 9;
	
	/**
	 * @private
	 */
	private static inline var CHARACTER_ID_LINE_FEED:Int = 10;
	
	/**
	 * @private
	 */
	private static inline var CHARACTER_ID_CARRIAGE_RETURN:Int = 13;
	
	/**
	 * @private
	 */
	private static var CHARACTER_BUFFER:Array<CharLocation>;
	
	/**
	 * @private
	 */
	private static var CHAR_LOCATION_POOL:Array<CharLocation>;
	
	/**
	 * @private
	 */
	private static inline var FUZZY_MAX_WIDTH_PADDING:Float = 0.000001;
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>BitmapFontTextRenderer</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	   Constructor.
	**/
	public function new() 
	{
		super();
		if (CHAR_LOCATION_POOL == null)
		{
			//compiler doesn't like referencing CharLocation class in a
			//static constant
			CHAR_LOCATION_POOL = new Array<CharLocation>();
		}
		if (CHARACTER_BUFFER == null)
		{
			CHARACTER_BUFFER = new Array<CharLocation>();
		}
		this.isQuickHitAreaEnabled = true;
	}
	
	/**
	 * @private
	 */
	private var _characterBatch:MeshBatch = null;
	
	/**
	 * @private
	 * This variable may be used by subclasses to affect the x position of
	 * the text.
	 */
	private var _batchX:Float = 0;
	
	/**
	 * @private
	 */
	private var _textFormatChanged:Bool = true;
	
	/**
	 * @private
	 */
	private var _currentFontStyles:TextFormat = null;
	
	/**
	 * @private
	 */
	private var _fontStylesTextFormat:BitmapFontTextFormat;
	
	/**
	 * @private
	 */
	private var _currentVerticalAlign:String;
	
	/**
	 * @private
	 */
	private var _verticalAlignOffsetY:Float = 0;
	
	/**
	 * For debugging purposes, the current
	 * <code>feathers.text.BitmapFontTextFormat</code> used to render the
	 * text. Updated during validation, and may be <code>null</code> before
	 * the first validation.
	 *
	 * <p>Do not modify this value. It is meant for testing and debugging
	 * only. Use the parent's <code>starling.text.TextFormat</code> font
	 * styles APIs instead.</p>
	 */
	public var currentTextFormat(get, never):BitmapFontTextFormat;
	private var _currentTextFormat:BitmapFontTextFormat;
	private function get_currentTextFormat():BitmapFontTextFormat { return this._currentTextFormat; }
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return BitmapFontTextRenderer.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override function set_maxWidth(value:Float):Float
	{
		//this is a special case because truncation may bypass normal rules
		//for determining if changing maxWidth should invalidate
		var needsInvalidate:Bool = value > this._explicitMaxWidth && this._lastLayoutIsTruncated;
		super.maxWidth = value;
		if (needsInvalidate)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return value;
	}
	
	public var numLines(get, never):Int;
	private var _numLines:Int = 0;
	private function get_numLines():Int { return this._numLines; }
	
	/**
	 * @private
	 */
	private var _textFormatForState:Map<String, BitmapFontTextFormat>;
	
	/**
	 * Advanced font formatting used to draw the text, if
	 * <code>fontStyles</code> and <code>starling.text.TextFormat</code>
	 * cannot be used on the parent component because the other features of
	 * bitmap fonts are required.
	 *
	 * <p>In the following example, the text format is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.textFormat = new BitmapFontTextFormat( bitmapFont );</listing>
	 *
	 * <p><strong>Warning:</strong> If this property is not
	 * <code>null</code>, any <code>starling.text.TextFormat</code> font
	 * styles that are passed in from the parent component may be ignored.
	 * In other words, advanced font styling with
	 * <code>BitmapFontTextFormat</code> will always take precedence.</p>
	 *
	 * @default null
	 *
	 * @see #setTextFormatForState()
	 * @see #disabledTextFormat
	 * @see #selectedTextFormat
	 */
	public var textFormat(get, set):BitmapFontTextFormat;
	private var _textFormat:BitmapFontTextFormat;
	private function get_textFormat():BitmapFontTextFormat { return this._textFormat; }
	private function set_textFormat(value:BitmapFontTextFormat):BitmapFontTextFormat
	{
		if (this._textFormat == value)
		{
			return value;
		}
		this._textFormat = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textFormat;
	}
	
	/**
	 * Advanced font formatting used to draw the text when the component is
	 * disabled, if <code>disabledFontStyles</code> and
	 * <code>starling.text.TextFormat</code> cannot be used on the parent
	 * component because the other features of bitmap fonts are required.
	 *
	 * <p>In the following example, the disabled text format is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.isEnabled = false;
	 * textRenderer.disabledTextFormat = new BitmapFontTextFormat( bitmapFont );</listing>
	 *
	 * <p><strong>Warning:</strong> If this property is not
	 * <code>null</code>, any <code>starling.text.TextFormat</code> font
	 * styles that are passed in from the parent component may be ignored.
	 * In other words, advanced font styling with
	 * <code>BitmapFontTextFormat</code> will always take precedence.</p>
	 *
	 * @default null
	 *
	 * @see #textFormat
	 * @see #selectedTextFormat
	 */
	public var disabledTextFormat(get, set):BitmapFontTextFormat;
	private var _disabledTextFormat:BitmapFontTextFormat;
	private function get_disabledTextFormat():BitmapFontTextFormat { return this._disabledTextFormat; }
	private function set_disabledTextFormat(value:BitmapFontTextFormat):BitmapFontTextFormat
	{
		if (this._disabledTextFormat == value)
		{
			return value;
		}
		this._disabledTextFormat = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._disabledTextFormat;
	}
	
	/**
	 * Advanced font formatting used to draw the text when the
	 * <code>stateContext</code> is disabled, if
	 * <code>selectedFontStyles</code> and
	 * <code>starling.text.TextFormat</code> cannot be used on the parent
	 * component because the other features of bitmap fonts are required.
	 *
	 * <p>In the following example, the selected text format is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.selectedTextFormat = new BitmapFontTextFormat( bitmapFont );</listing>
	 *
	 * <p><strong>Warning:</strong> If this property is not
	 * <code>null</code>, any <code>starling.text.TextFormat</code> font
	 * styles that are passed in from the parent component may be ignored.
	 * In other words, advanced font styling with
	 * <code>BitmapFontTextFormat</code> will always take precedence.</p>
	 *
	 * @default null
	 *
	 * @see #stateContext
	 * @see feathers.core.IToggle
	 * @see #textFormat
	 * @see #disabledTextFormat
	 */
	public var selectedTextFormat(get, set):BitmapFontTextFormat;
	private var _selectedTextFormat:BitmapFontTextFormat;
	private function get_selectedTextFormat():BitmapFontTextFormat { return this._selectedTextFormat; }
	private function set_selectedTextFormat(value:BitmapFontTextFormat):BitmapFontTextFormat
	{
		if (this._selectedTextFormat == value)
		{
			return value;
		}
		this._selectedTextFormat = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._selectedTextFormat;
	}
	
	/**
	 * A texture smoothing value passed to each character image. If
	 * <code>null</code>, defaults to the value specified by the
	 * <code>smoothing</code> property of the <code>BitmapFont</code>.
	 *
	 * <p>In the following example, the texture smoothing is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.textureSmoothing = TextureSmoothing.NONE;</listing>
	 *
	 * @default null
	 *
	 * @see http://doc.starling-framework.org/core/starling/textures/TextureSmoothing.html starling.textures.TextureSmoothing
	 */
	public var textureSmoothing(get, set):String;
	private var _textureSmoothing:String = null;
	private function get_textureSmoothing():String { return this._textureSmoothing; }
	private function set_textureSmoothing(value:String):String
	{
		if (this._textureSmoothing == value)
		{
			return value;
		}
		this._textureSmoothing = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textureSmoothing;
	}
	
	/**
	 * Determines if the position of the text should be snapped to the
	 * nearest whole pixel when rendered. When snapped to a whole pixel, the
	 * text is often more readable. When not snapped, the text may become
	 * blurry due to texture smoothing.
	 *
	 * <p>In the following example, the text is not snapped to pixels:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.pixelSnapping = false;</listing>
	 *
	 * @default true
	 */
	public var pixelSnapping(get, set):Bool;
	private var _pixelSnapping:Bool = true;
	private function get_pixelSnapping():Bool { return this._pixelSnapping; }
	private function set_pixelSnapping(value:Bool):Bool
	{
		if (this._pixelSnapping == value)
		{
			return value;
		}
		this._pixelSnapping = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._pixelSnapping;
	}
	
	/**
	 * If <code>wordWrap</code> is <code>true</code>, determines if words
	 * longer than the width of the text renderer will break in the middle
	 * or if the word will extend outside the edges until it ends.
	 *
	 * <p>In the following example, the text will break long words:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.breakLongWords = true;</listing>
	 *
	 * @default false
	 *
	 * @see #wordWrap
	 */
	public var breakLongWords(get, set):Bool;
	private var _breakLongWords:Bool = false;
	private function get_breakLongWords():Bool { return this._breakLongWords; }
	private function set_breakLongWords(value:Bool):Bool
	{
		if (this._breakLongWords == value)
		{
			return value;
		}
		this._breakLongWords = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._breakLongWords;
	}
	
	/**
	 * If word wrap is disabled, and the text is longer than the width of
	 * the label, the text may be truncated using <code>truncationText</code>.
	 *
	 * <p>This feature may be disabled to improve performance.</p>
	 *
	 * <p>This feature does not currently support the truncation of text
	 * displayed on multiple lines.</p>
	 *
	 * <p>In the following example, truncation is disabled:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.truncateToFit = false;</listing>
	 *
	 * @default true
	 *
	 * @see #truncationText
	 */
	public var truncateToFit(get, set):Bool;
	private var _truncateToFit:Bool = true;
	private function get_truncateToFit():Bool { return _truncateToFit; }
	private function set_truncateToFit(value:Bool):Bool
	{
		if (this._truncateToFit == value)
		{
			return value;
		}
		this._truncateToFit = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._truncateToFit;
	}
	
	/**
	 * The text to display at the end of the label if it is truncated.
	 *
	 * <p>In the following example, the truncation text is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.truncationText = " [more]";</listing>
	 *
	 * @default "..."
	 */
	public var truncationText(get, set):String;
	private var _truncationText:String = "...";
	private function get_truncationText():String { return this._truncationText; }
	private function set_truncationText(value:String):String
	{
		if (this._truncationText == value)
		{
			return value;
		}
		this._truncationText = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._truncationText;
	}
	
	/**
	 * Determines if the characters are batched normally by Starling or if
	 * they're batched separately. Batching separately may improve
	 * performance for text that changes often, while batching normally
	 * may be better when a lot of text is displayed on screen at once.
	 *
	 * <p>In the following example, separate batching is disabled:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.useSeparateBatch = false;</listing>
	 *
	 * @default true
	 */
	public var useSeparateBatch(get, set):Bool;
	private var _useSeparateBatch:Bool = true;
	private function get_useSeparateBatch():Bool { return this._useSeparateBatch; }
	private function set_useSeparateBatch(value:Bool):Bool
	{
		if (this._useSeparateBatch == value)
		{
			return value;
		}
		this._useSeparateBatch = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._useSeparateBatch;
	}
	
	/**
	   private
	**/
	private var _defaultStyle:MeshStyle = null;
	
	/**
	 * The style that is used to render the text's mesh.
	 *
	 * <p>In the following example, the text renderer uses a custom style:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.style = new DistanceFieldStyle();</listing>
	 *
	 * @default null
	 */
	public var style(get, set):MeshStyle;
	private var _style:MeshStyle = null;
	private function get_style():MeshStyle { return _style; }
	private function set_style(value:MeshStyle):MeshStyle
	{
		if (this._style == value)
		{
			return value;
		}
		this._style = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._style;
	}
	
	/**
	 * @inheritDoc
	 */
	public var baseLine(get, never):Float;
	private function get_baseLine():Float
	{
		if (this._currentTextFormat == null)
		{
			return 0;
		}
		var font:BitmapFont = this._currentTextFormat.font;
		var formatSize:Float = this._currentTextFormat.size;
		var fontSizeScale:Float = formatSize / font.size;
		if (fontSizeScale != fontSizeScale) //isNaN
		{
			fontSizeScale = 1;
		}
		var baseLine:Float = font.baseline;
		//for some reason, if we do the != check on a local variable right
		//here, compiling with the flex 4.6 SDK will throw a VerifyError
		//for a stack overflow.
		//we could change the != check back to isNaN() instead, but
		//isNaN() can allocate an object that needs garbage collection.
		this._compilerWorkaround = baseLine;
		if (baseLine != baseLine) // isNaN
		{
			return font.lineHeight * fontSizeScale;
		}
		return baseLine * fontSizeScale;
	}
	
	/**
	   @private
	**/
	private var _image:Image = null;
	
	/**
	 * @private
	 * This function is here to work around a bug in the Flex 4.6 SDK
	 * compiler. For explanation, see the places where it gets called.
	 */
	private var _compilerWorkaround:Dynamic;
	
	override public function render(painter:Painter):Void 
	{
		this._characterBatch.x = this._batchX;
		this._characterBatch.y = this._verticalAlignOffsetY;
		super.render(painter);
	}
	
	/**
	 * @inheritDoc
	 */
	public function measureText(result:Point = null):Point
	{
		return this.measureTextInternal(result, true);
	}
	
	/**
	 * Gets the advanced <code>BitmapFontTextFormat</code> font formatting
	 * passed in using <code>setTextFormatForState()</code> for the
	 * specified state.
	 *
	 * <p>If an <code>BitmapFontTextFormat</code> is not defined for a
	 * specific state, returns <code>null</code>.</p>
	 *
	 * @see #setTextFormatForState()
	 */
	public function getTextFormatForState(state:String):BitmapFontTextFormat
	{
		if (this._textFormatForState == null)
		{
			return null;
		}
		return this._textFormatForState[state];
	}
	
	/**
	 * Sets the advanced <code>BitmapFontTextFormat</code> font formatting
	 * to be used by the text renderer when the <code>currentState</code>
	 * property of the <code>stateContext</code> matches the specified state
	 * value. For advanced use cases where
	 * <code>starling.text.TextFormat</code> cannot be used on the parent
	 * component because other features of bitmap fonts are required.
	 *
	 * <p>If an <code>BitmapFontTextFormat</code> is not defined for a
	 * specific state, the value of the <code>textFormat</code> property
	 * will be used instead.</p>
	 *
	 * <p>If the <code>disabledTextFormat</code> property is not
	 * <code>null</code> and the <code>isEnabled</code> property is
	 * <code>false</code>, all other text formats will be ignored.</p>
	 *
	 * @see #stateContext
	 * @see #textFormat
	 */
	public function setTextFormatForState(state:String, textFormat:BitmapFontTextFormat):Void
	{
		if (textFormat != null)
		{
			if (this._textFormatForState == null)
			{
				this._textFormatForState = new Map<String, BitmapFontTextFormat>();
			}
			this._textFormatForState[state] = textFormat;
		}
		else
		{
			this._textFormatForState.remove(state);
		}
		//if the context's current state is the state that we're modifying,
		//we need to use the new value immediately.
		if (this._stateContext != null && this._stateContext.currentState == state)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		}
	}
	
	/**
	   @private
	**/
	override function initialize():Void
	{
		if (this._characterBatch == null)
		{
			this._characterBatch = new MeshBatch();
			this._characterBatch.touchable = false;
			this.addChild(this._characterBatch);
		}
	}
	
	/**
	   @private
	**/
	private var _lastLayoutWidth:Float = 0;
	
	/**
	   @private
	**/
	private var _lastLayoutHeight:Float = 0;
	
	/**
	   @private
	**/
	private var _lastLayoutIsTruncated:Bool = false;
	
	/**
	   @private
	**/
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshTextFormat();
		}
		
		if (stylesInvalid)
		{
			this._characterBatch.pixelSnapping = this._pixelSnapping;
			this._characterBatch.batchable = !this._useSeparateBatch;
		}
		
		//sometimes, we can determine that the layout will be exactly
		//the same without needing to update. this will result in much
		//better performance.
		var newWidth:Float = this._explicitWidth;
		if (newWidth != newWidth) //isNaN
		{
			newWidth = this._explicitMaxWidth;
		}
		
		//sometimes, we can determine that the dimensions will be exactly
		//the same without needing to refresh the text lines. this will
		//result in much better performance.
		var sizeInvalid:Bool;
		if (this._wordWrap)
		{
			//when word wrapped, we need to measure again any time that the
			//width changes.
			sizeInvalid = newWidth != this._lastLayoutWidth;
		}
		else
		{
			//we can skip measuring again more frequently when the text is
			//a single line.
			
			//if the width is smaller than the last layout width, we need to
			//measure again. when it's larger, the result won't change...
			sizeInvalid = newWidth < this._lastLayoutWidth;
			
			//...unless the text was previously truncated!
			sizeInvalid = sizeInvalid || (this._lastLayoutIsTruncated && newWidth != this._lastLayoutWidth);
			
			//...or the text is aligned
			sizeInvalid = sizeInvalid || this._currentTextFormat.align != TextFormatAlign.LEFT;
		}
		
		if (dataInvalid || sizeInvalid || stylesInvalid || this._textFormatChanged)
		{
			this._textFormatChanged = false;
			this._characterBatch.clear();
			if (this._currentTextFormat == null || this._text == null)
			{
				this.saveMeasurements(0, 0, 0, 0);
				return;
			}
			this.layoutCharacters(HELPER_RESULT);
			//for some reason, we can't just set the style once...
			//we need to set up every time after layout
			if (this._style != null)
			{
				this._characterBatch.style = this._style;
			}
			else
			{
				//getDefaultMeshStyle doesn't exist in Starling 2.2
				this._defaultStyle = this._currentTextFormat.font.getDefaultMeshStyle(this._defaultStyle, this._currentFontStyles, null);
				if (this._defaultStyle != null)
				{
					this._characterBatch.style = this._defaultStyle;
				}
			}
			this._lastLayoutWidth = HELPER_RESULT.width;
			this._lastLayoutHeight = HELPER_RESULT.height;
			this._lastLayoutIsTruncated = HELPER_RESULT.isTruncated;
		}
		this.saveMeasurements(this._lastLayoutWidth, this._lastLayoutHeight,
			this._lastLayoutWidth, this._lastLayoutHeight);
		this._verticalAlignOffsetY = this.getVerticalAlignOffsetY();
	}
	
	/**
	   @private
	**/
	private function layoutCharacters(result:MeasureTextResult = null):MeasureTextResult
	{
		if (result == null)
		{
			result = new MeasureTextResult();
		}
		this._numLines = 1;
		
		var font:BitmapFont = this._currentTextFormat.font;
		var customSize:Float = this._currentTextFormat.size;
		var customLetterSpacing:Float = this._currentTextFormat.letterSpacing;
		var isKerningEnabled:Bool = this._currentTextFormat.isKerningEnabled;
		var scale:Float = customSize / font.size;
		if (scale != scale) //isNaN
		{
			scale = 1;
		}
		var lineHeight:Float = font.lineHeight * scale + this._currentTextFormat.leading;
		var offsetX:Float = font.offsetX * scale;
		var offsetY:Float = font.offsetY * scale;
		
		var hasExplicitWidth:Bool = this._explicitWidth == this._explicitWidth; //!isNaN
		var isAligned:Bool = this._currentTextFormat.align != TextFormatAlign.LEFT;
		var maxLineWidth:Float = hasExplicitWidth ? this._explicitWidth : this._explicitMaxWidth;
		if (isAligned && maxLineWidth == Math.POSITIVE_INFINITY)
		{
			//we need to measure the text to get the maximum line width
			//so that we can align the text
			var point:Point = Pool.getPoint();
			this.measureText(point);
			maxLineWidth = point.x;
			Pool.putPoint(point);
		}
		var textToDraw:String = this._text;
		if (this._truncateToFit)
		{
			var truncatedText = this.getTruncatedText(maxLineWidth);
			result.isTruncated = truncatedText != textToDraw;
			textToDraw = truncatedText;
		}
		else
		{
			result.isTruncated = false;
		}
		CHARACTER_BUFFER.resize(0);
		
		var maxX:Float = 0;
		var currentX:Float = 0;
		var currentY:Float = 0;
		var previousCharID:Int = -1;
		var isWordComplete:Bool = false;
		var startXOfPreviousWord:Float = 0;
		var widthOfWhitespaceAfterWord:Float = 0;
		var wordLength:Int = 0;
		var wordCountForLine:Int = 0;
		var charData:BitmapChar = null;
		var previousCharData:BitmapChar;
		var charCount:Int = textToDraw != null ? textToDraw.length : 0;
		for (i in 0...charCount)
		{
			isWordComplete = false;
			var charID:Int = textToDraw.charCodeAt(i);
			if (charID == CHARACTER_ID_LINE_FEED || charID == CHARACTER_ID_CARRIAGE_RETURN) //new line \n or \r
			{
				//remove whitespace after the final character in the line
				currentX -= customLetterSpacing;
				if (charData != null)
				{
					currentX -= (charData.xAdvance - charData.width) * scale;
				}
				if (currentX < 0)
				{
					currentX = 0;
				}
				if (this._wordWrap || isAligned)
				{
					this.alignBuffer(maxLineWidth, currentX, 0);
					this.addBufferToBatch(0);
				}
				if (maxX < currentX)
				{
					maxX = currentX;
				}
				previousCharID = -1;
				currentX = 0;
				currentY += lineHeight;
				startXOfPreviousWord = 0;
				widthOfWhitespaceAfterWord = 0;
				wordLength = 0;
				wordCountForLine = 0;
				this._numLines++;
				continue;
			}
			
			charData = font.getChar(charID);
			if (charData  == null)
			{
				trace("Missing character " + String.fromCharCode(charID) + " in font " + font.name + ".");
				continue;
			}
			
			if (isKerningEnabled && previousCharID != -1)
			{
				currentX += charData.getKerning(previousCharID) * scale;
			}
			
			var xAdvance:Float = charData.xAdvance * scale;
			if (this._wordWrap)
			{
				var currentCharIsWhiteSpace:Bool = charID == CHARACTER_ID_SPACE || charID == CHARACTER_ID_TAB;
				var previousCharIsWhiteSpace:Bool = previousCharID == CHARACTER_ID_SPACE || previousCharID == CHARACTER_ID_TAB;
				if (currentCharIsWhiteSpace)
				{
					if (!previousCharIsWhiteSpace)
					{
						//this is the spacing after the last character
						//that isn't whitespace
						previousCharData = font.getChar(previousCharID);
						widthOfWhitespaceAfterWord = customLetterSpacing + (previousCharData.xAdvance - previousCharData.width) * scale;
					}
					widthOfWhitespaceAfterWord += xAdvance;
				}
				else if (previousCharIsWhiteSpace)
				{
					startXOfPreviousWord = currentX;
					wordLength = 0;
					wordCountForLine++;
					isWordComplete = true;
				}
				
				//we may need to move to a new line at the same time
				//that our previous word in the buffer can be batched
				//so we need to add the buffer here rather than after
				//the next section
				if (isWordComplete && !isAligned)
				{
					this.addBufferToBatch(0);
				}
				
				//floating point errors can cause unnecessary line breaks,
				//so we're going to be a little bit fuzzy on the greater
				//than check. such tiny numbers shouldn't break anything.
				var charWidth:Float = charData.width * scale;
				if (!currentCharIsWhiteSpace && (wordCountForLine > 0 || this._breakLongWords) && ((currentX + charWidth) - maxLineWidth) > FUZZY_MAX_WIDTH_PADDING)
				{
					if (wordCountForLine == 0)
					{
						//if we're breaking long words, this is where we break.
						//we need to pretend that there's a word before this one.
						wordLength = 0;
						startXOfPreviousWord = currentX;
						widthOfWhitespaceAfterWord = 0;
						if (previousCharID != -1)
						{
							previousCharData = font.getChar(previousCharID);
							widthOfWhitespaceAfterWord = customLetterSpacing + (previousCharData.xAdvance - previousCharData.width) * scale;
						}
						if (!isAligned)
						{
							this.addBufferToBatch(0);
						}
					}
					if (isAligned)
					{
						this.trimBuffer(wordLength);
						this.alignBuffer(maxLineWidth, startXOfPreviousWord - widthOfWhitespaceAfterWord, wordLength);
						this.addBufferToBatch(wordLength);
					}
					this.moveBufferedCharacters( -startXOfPreviousWord, lineHeight, 0);
					//we're just reusing this variable to avoid creating a
					//new one. it'll be reset to 0 in a moment.
					widthOfWhitespaceAfterWord = startXOfPreviousWord - widthOfWhitespaceAfterWord;
					if (maxX < widthOfWhitespaceAfterWord)
					{
						maxX = widthOfWhitespaceAfterWord;
					}
					previousCharID = -1;
					currentX -= startXOfPreviousWord;
					currentY += lineHeight;
					startXOfPreviousWord = 0;
					widthOfWhitespaceAfterWord = 0;
					wordLength = 0;
					isWordComplete = false;
					wordCountForLine = 0;
					this._numLines++;
				}
			}
			if (this._wordWrap || isAligned)
			{
				var charLocation:CharLocation = CHAR_LOCATION_POOL.length != 0 ? CHAR_LOCATION_POOL.shift() : new CharLocation();
				charLocation.char = charData;
				charLocation.x = currentX + offsetX + charData.xOffset * scale;
				charLocation.y = currentY + offsetY + charData.yOffset * scale;
				charLocation.scale = scale;
				CHARACTER_BUFFER[CHARACTER_BUFFER.length] = charLocation;
				wordLength++;
			}
			else
			{
				this.addCharacterToBatch(charData,
					currentX + offsetX + charData.xOffset * scale,
					currentY + offsetY + charData.yOffset * scale,
					scale);
			}
			
			currentX += xAdvance + customLetterSpacing;
			previousCharID = charID;
		}
		//remove whitespace after the final character in the final line
		currentX = currentX - customLetterSpacing;
		if (charData != null)
		{
			currentX -= (charData.xAdvance - charData.width) * scale;
		}
		if (currentX < 0)
		{
			currentX = 0;
		}
		if (this._wordWrap || isAligned)
		{
			this.alignBuffer(maxLineWidth, currentX, 0);
			this.addBufferToBatch(0);
		}
		//if the text ends in extra whitespace, the currentX value will be
		//larger than the max line width. we'll remove that and add extra
		//lines.
		if (this._wordWrap)
		{
			while (currentX > maxLineWidth && !MathUtil.isEquivalent(currentX, maxLineWidth))
			{
				currentX -= maxLineWidth;
				currentY += lineHeight;
				if (maxLineWidth == 0)
				{
					//we don't want to get stuck in an infinite loop!
					break;
				}
			}
		}
		if (maxX < currentX)
		{
			maxX = currentX;
		}
		
		if (isAligned && !hasExplicitWidth)
		{
			var align:String = this._currentTextFormat.align;
			if (align == TextFormatAlign.CENTER)
			{
				this._batchX = (maxX - maxLineWidth) / 2;
			}
			else if (align == TextFormatAlign.RIGHT)
			{
				this._batchX = maxX - maxLineWidth;
			}
		}
		else
		{
			this._batchX = 0;
		}
		this._characterBatch.x = this._batchX;
		
		result.width = maxX;
		result.height = currentY + lineHeight - this._currentTextFormat.leading;
		return result;
	}
	
	/**
	   @private
	**/
	private function trimBuffer(skipCount:Int):Void
	{
		var countToRemove:Int = 0;
		var charCount:Int = CHARACTER_BUFFER.length - skipCount;
		var index:Int;
		for (i in new ReverseIterator(charCount - 1, 0))
		{
			var charLocation:CharLocation = CHARACTER_BUFFER[i];
			var charData:BitmapChar = charLocation.char;
			var charID:Int = charData.charID;
			if (charID == CHARACTER_ID_SPACE || charID == CHARACTER_ID_TAB)
			{
				countToRemove++;
			}
			else
			{
				index = i;
				break;
			}
		}
		if (countToRemove > 0)
		{
			CHARACTER_BUFFER.splice(index + 1, countToRemove);
		}
	}
	
	/**
	   @private
	**/
	private function alignBuffer(maxLineWidth:Float, currentLineWidth:Float, skipCount:Int):Void
	{
		var align:String = this._currentTextFormat.align;
		if (align == TextFormatAlign.CENTER)
		{
			this.moveBufferedCharacters(Math.round((maxLineWidth - currentLineWidth) / 2), 0, skipCount);
		}
		else if (align == TextFormatAlign.RIGHT)
		{
			this.moveBufferedCharacters(maxLineWidth - currentLineWidth, 0, skipCount);
		}
	}
	
	/**
	   @private
	**/
	private function addBufferToBatch(skipCount:Int):Void
	{
		var charCount:Int = CHARACTER_BUFFER.length - skipCount;
		var pushIndex:Int = CHAR_LOCATION_POOL.length;
		for (i in 0...charCount)
		{
			var charLocation:CharLocation = CHARACTER_BUFFER.shift();
			this.addCharacterToBatch(charLocation.char, charLocation.x, charLocation.y, charLocation.scale);
			charLocation.char = null;
			CHAR_LOCATION_POOL[pushIndex] = charLocation;
			pushIndex++;
		}
	}
	
	/**
	   @private
	**/
	private function moveBufferedCharacters(xOffset:Float, yOffset:Float, skipCount:Int):Void
	{
		var charCount:Int = CHARACTER_BUFFER.length - skipCount;
		for (i in 0...charCount)
		{
			var charLocation:CharLocation = CHARACTER_BUFFER[i];
			charLocation.x += xOffset;
			charLocation.y += yOffset;
		}
	}
	
	/**
	   @private
	**/
	private function addCharacterToBatch(charData:BitmapChar, x:Float, y:Float, scale:Float, painter:Painter = null):Void
	{
		var texture:Texture = charData.texture;
		var frame:Rectangle = texture.frame;
		if (frame != null)
		{
			if (frame.width == 0 || frame.height == 0)
			{
				return;
			}
		}
		else if (texture.width == 0 || texture.height == 0)
		{
			return;
		}
		var font:BitmapFont = this._currentTextFormat.font;
		if (this._image == null)
		{
			this._image = new Image(texture);
		}
		else
		{
			this._image.texture = texture;
			this._image.readjustSize();
		}
		this._image.scaleX = scale;
		this._image.scaleY = scale;
		this._image.x = x;
		this._image.y = y;
		this._image.color = this._currentTextFormat.color;
		if (this._textureSmoothing != null)
		{
			this._image.textureSmoothing = this._textureSmoothing;
		}
		else
		{
			this._image.textureSmoothing = font.smoothing;
		}
		
		if (painter != null)
		{
			painter.pushState();
			painter.setStateTo(this._image.transformationMatrix);
			painter.batchMesh(this._image);
			painter.popState();
		}
		else
		{
			this._characterBatch.addMesh(this._image);
		}
	}
	
	/**
	   @private
	**/
	private function refreshTextFormat():Void
	{
		var textFormat:BitmapFontTextFormat;
		if (this._stateContext != null)
		{
			if (this._textFormatForState != null)
			{
				var currentState:String = this._stateContext.currentState;
				textFormat = this._textFormatForState[currentState];
			}
			if (textFormat == null && this._disabledTextFormat != null &&
				Std.isOfType(this._stateContext, IFeathersControl) && !cast(this._stateContext, IFeathersControl).isEnabled)
			{
				textFormat = this._disabledTextFormat;
			}
			if (textFormat == null && this._selectedTextFormat != null &&
				Std.isOfType(this._stateContext, IToggle) && cast(this._stateContext, IToggle).isSelected)
			{
				textFormat = this._selectedTextFormat;
			}
		}
		else //no state context
		{
			//we can still check if the text renderer is disabled to see if
			//we should use disabledTextFormat
			if (!this._enabled && this._disabledTextFormat != null)
			{
				textFormat = this._disabledTextFormat;
			}
		}
		if (textFormat == null)
		{
			textFormat = this._textFormat;
		}
		if (textFormat == null)
		{
			textFormat = this.getTextFormatFromFontStyles();
		}
		else
		{
			//when using BitmapFontTextFormat, vertical align is always top
			this._currentVerticalAlign = Align.TOP;
			if (this._currentFontStyles == null)
			{
				this._currentFontStyles = new TextFormat();
			}
			// we need the size to determine the default mesh style
			this._currentFontStyles.size = textFormat.size;
		}
		if (this._currentTextFormat != textFormat)
		{
			this._currentTextFormat = textFormat;
			this._textFormatChanged = true;
		}
	}
	
	/**
	   @private
	**/
	private function getTextFormatFromFontStyles():BitmapFontTextFormat
	{
		if (this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES) ||
			this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE))
		{
			var textFormat:TextFormat;
			if (this._fontStyles != null)
			{
				textFormat = this._fontStyles.getTextFormatForTarget(this);
				this._currentFontStyles = textFormat;
			}
			if (textFormat != null)
			{
				this._fontStylesTextFormat = new BitmapFontTextFormat(
					textFormat.font, textFormat.size, textFormat.color,
					textFormat.horizontalAlign, textFormat.leading);
				this._fontStylesTextFormat.isKerningEnabled = textFormat.kerning;
				this._fontStylesTextFormat.letterSpacing = textFormat.letterSpacing;
				this._currentVerticalAlign = textFormat.verticalAlign;
			}
			else if (this._fontStylesTextFormat == null)
			{
				//let's fall back to using Starling's embedded mini font if no
				//text format has been specified
				
				//if it's not registered, do that first
				if (TextField.getBitmapFont(BitmapFont.MINI) != null)
				{
					var font:BitmapFont = new BitmapFont();
					TextField.registerCompositor(font, font.name);
				}
				this._fontStylesTextFormat = new BitmapFontTextFormat(BitmapFont.MINI, Math.NaN, 0x000000);
				this._currentVerticalAlign = Align.TOP;
			}
		}
		return this._fontStylesTextFormat;
	}
	
	/**
	   @private
	**/
	private function measureTextInternal(result:Point, useExplicit:Bool):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var needsWidth:Bool = !useExplicit || this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = !useExplicit || this._explicitHeight != this._explicitHeight; //isNaN
		if (!needsWidth && !needsHeight)
		{
			result.x = this._explicitWidth;
			result.y = this._explicitHeight;
			return result;
		}
		
		if (this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES) || this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE))
		{
			this.refreshTextFormat();
		}
		
		if (this._currentTextFormat == null || this._text == null)
		{
			result.setTo(0, 0);
			return result;
		}
		
		var font:BitmapFont = this._currentTextFormat.font;
		var customSize:Float = this._currentTextFormat.size;
		var customLetterSpacing:Float = this._currentTextFormat.letterSpacing;
		var isKerningEnabled:Bool = this._currentTextFormat.isKerningEnabled;
		var scale:Float = customSize / font.size;
		if (scale != scale) //isNaN
		{
			scale = 1;
		}
		var lineHeight:Float = font.lineHeight * scale + this._currentTextFormat.leading;
		var maxLineWidth:Float = this._explicitWidth;
		if (maxLineWidth != maxLineWidth) //isNaN
		{
			maxLineWidth = this._explicitMaxWidth;
		}
		
		var maxX:Float = 0;
		var currentX:Float = 0;
		var currentY:Float = 0;
		var previousCharID:Int = -1;
		var previousCharData:BitmapChar;
		var charCount:Int = this._text.length;
		var startXOfPreviousWord:Float = 0;
		var widthOfWhiteSpaceAfterWord:Float = 0;
		var wordCountForLine:Int = 0;
		var line:String = "";
		var word:String = "";
		var charData:BitmapChar = null;
		for (i in 0...charCount)
		{
			var charID:Int = this._text.charCodeAt(i);
			if (charID == CHARACTER_ID_LINE_FEED || charID == CHARACTER_ID_CARRIAGE_RETURN) //new line \n or \r
			{
				//remove whitespace after the final character in the line
				currentX -= customLetterSpacing;
				if (charData != null)
				{
					currentX -= (charData.xAdvance - charData.width) * scale;
				}
				if (currentX < 0)
				{
					currentX = 0;
				}
				if (maxX < currentX)
				{
					maxX = currentX;
				}
				previousCharID = -1;
				currentX = 0;
				currentY += lineHeight;
				startXOfPreviousWord = 0;
				wordCountForLine = 0;
				widthOfWhiteSpaceAfterWord = 0;
				continue;
			}
			
			charData = font.getChar(charID);
			if (charData  == null)
			{
				trace("Missing character " + String.fromCharCode(charID) + " in font " + font.name + ".");
				continue;
			}
			
			if (isKerningEnabled && 
				previousCharID != -1) //!isNaN
			{
				currentX += charData.getKerning(previousCharID) * scale;
			}
			
			var xAdvance:Float = charData.xAdvance * scale;
			if (this._wordWrap)
			{
				var currentCharIsWhiteSpace:Bool = charID == CHARACTER_ID_SPACE || charID == CHARACTER_ID_TAB;
				var previousCharIsWhiteSpace:Bool = previousCharID == CHARACTER_ID_SPACE || previousCharID == CHARACTER_ID_TAB;
				if (currentCharIsWhiteSpace)
				{
					if (!previousCharIsWhiteSpace)
					{
						//this is the spacing after the last character
						//that isn't whitespace
						previousCharData = font.getChar(previousCharID);
						widthOfWhiteSpaceAfterWord = customLetterSpacing + (previousCharData.xAdvance - previousCharData.width) * scale;
					}
					widthOfWhiteSpaceAfterWord += xAdvance;
				}
				else if (previousCharIsWhiteSpace)
				{
					startXOfPreviousWord = currentX;
					wordCountForLine++;
					line += word;
					word = "";
				}
				
				var charWidth:Float = charData.width * scale;
				if (!currentCharIsWhiteSpace && (wordCountForLine > 0 || this._breakLongWords) && (currentX + charWidth) > maxLineWidth)
				{
					if (wordCountForLine == 0)
					{
						// if we are breaking long words, this is where we break
						startXOfPreviousWord = currentX;
						if (previousCharID != -1) //!isNaN
						{
							previousCharData = font.getChar(previousCharID);
							widthOfWhiteSpaceAfterWord = customLetterSpacing + (previousCharData.xAdvance - previousCharData.width) * scale;
						}
					}
					//we're just reusing this variable to avoid creating a
					//new one. it'll be reset to 0 in a moment.
					widthOfWhiteSpaceAfterWord = startXOfPreviousWord - widthOfWhiteSpaceAfterWord;
					if (maxX < widthOfWhiteSpaceAfterWord)
					{
						maxX = widthOfWhiteSpaceAfterWord;
					}
					previousCharID = -1;
					currentX -= startXOfPreviousWord;
					currentY += lineHeight;
					startXOfPreviousWord = 0;
					widthOfWhiteSpaceAfterWord = 0;
					wordCountForLine = 0;
					line = "";
				}
			}
			currentX += xAdvance + customLetterSpacing;
			previousCharID = charID;
			word += String.fromCharCode(charID);
		}
		// remove whitespace after the final character in the final line
		currentX -= customLetterSpacing;
		if (charData != null)
		{
			currentX -= (charData.xAdvance - charData.width) * scale;
		}
		if (currentX < 0)
		{
			currentX = 0;
		}
		//if the text ends in extra whitespace, the currentX value will be
		//larger than the max line width. we'll remove that and add extra
		//lines.
		if (this._wordWrap)
		{
			while (currentX > maxLineWidth && !MathUtil.isEquivalent(currentX, maxLineWidth))
			{
				currentX -= maxLineWidth;
				currentY += lineHeight;
				if (maxLineWidth == 0)
				{
					//we don't want to get stuck in an infinite loop!
					break;
				}
			}
		}
		if (maxX < currentX)
		{
			maxX = currentX;
		}
		
		if (needsWidth)
		{
			result.x = maxX;
		}
		else
		{
			result.x = this._explicitWidth;
		}
		if (needsHeight)
		{
			result.y = currentY + lineHeight - this.currentTextFormat.leading;
		}
		else
		{
			result.y = this._explicitHeight;
		}
		
		return result;
	}
	
	/**
	   @private
	**/
	private function getTruncatedText(width:Float):String
	{
		if (this._text == null)
		{
			//this shouldn't be called if _text is null, but just in case...
			return "";
		}
		
		//if the width is infinity or the string is multiline, don't allow truncation
		if (width == Math.POSITIVE_INFINITY || this._wordWrap || this._text.indexOf(String.fromCharCode(CHARACTER_ID_LINE_FEED)) != -1 || this._text.indexOf(String.fromCharCode(CHARACTER_ID_CARRIAGE_RETURN)) != -1)
		{
			return this._text;
		}
		
		var font:BitmapFont = this._currentTextFormat.font;
		var customSize:Float = this._currentTextFormat.size;
		var customLetterSpacing:Float = this._currentTextFormat.letterSpacing;
		var isKerningEnabled:Bool = this._currentTextFormat.isKerningEnabled;
		var scale:Float = customSize / font.size;
		if (scale != scale) //isNaN
		{
			scale = 1;
		}
		var currentX:Float = 0;
		var charID:Int;
		var charData:BitmapChar;
		var previousCharID:Int = -1;
		var currentKerning:Float;
		var charCount:Int = this._text.length;
		var truncationIndex:Int = -1;
		for (i in 0...charCount)
		{
			charID = this._text.charCodeAt(i);
			charData = font.getChar(charID);
			if (charData == null)
			{
				continue;
			}
			currentKerning = 0;
			if (isKerningEnabled &&
				previousCharID != -1)
			{
				currentKerning = charData.getKerning(previousCharID) * scale;
			}
			var charWidth:Float = charData.width * scale;
			//add only the width of the character and not the xAdvance
			//because the final character doesn't have whitespace after it
			currentX += currentKerning + charWidth;
			if (currentX > width)
			{
				//floating point errors can cause unnecessary truncation,
				//so we're going to be a little bit fuzzy on the greater
				//than check. such tiny numbers shouldn't break anything.
				var difference:Float = Math.abs(currentX - width);
				if (difference > FUZZY_MAX_WIDTH_PADDING)
				{
					truncationIndex = i;
					//add the extra whitespace back to the end because we'll
					//be appending the truncation text (...)
					currentX += (charData.xAdvance * scale) - charWidth;
					break;
				}
			}
			//add the extra whitespace to the end for the next character
			currentX += customLetterSpacing + (charData.xAdvance * scale) - charWidth;
			previousCharID = charID;
		}
		
		if (truncationIndex >= 0)
		{
			//first add the width of the truncation text (...)
			charCount = this._truncationText.length;
			for (i in 0...charCount)
			{
				charID = this._truncationText.charCodeAt(i);
				charData = font.getChar(charID);
				if (charData == null)
				{
					continue;
				}
				currentKerning = 0;
				if (isKerningEnabled &&
					previousCharID != -1)
				{
					currentKerning = charData.getKerning(previousCharID) * scale;
				}
				currentX += currentKerning + charData.xAdvance * scale + customLetterSpacing;
				previousCharID = charID;
			}
			currentX -= customLetterSpacing;
			if (charData != null)
			{
				currentX -= (charData.xAdvance - charData.width) * scale;
			}
			
			// then work our way backwards until we fit into the width
			for (i in new ReverseIterator(truncationIndex, 0))
			{
				charID = this._text.charCodeAt(i);
				previousCharID = (i > 0) ? this._text.charCodeAt(i - 1) : -1;
				charData = font.getChar(charID);
				if (charData == null)
				{
					continue;
				}
				currentKerning = 0;
				if (isKerningEnabled &&
					previousCharID != -1)
				{
					currentKerning = charData.getKerning(previousCharID) * scale;
				}
				currentX -= (currentKerning + charData.xAdvance * scale + customLetterSpacing);
				if (currentX <= width)
				{
					return this._text.substr(0, i) + this._truncationText;
				}
			}
			return this._truncationText;
		}
		return this._text;
	}
	
	/**
	   @private
	**/
	private function getVerticalAlignOffsetY():Float
	{
		var font:BitmapFont = this._currentTextFormat.font;
		var customSize:Float = this._currentTextFormat.size;
		var scale:Float = customSize / font.size;
		if (scale != scale) //isNaN
		{
			scale = 1;
		}
		var lineHeight:Float = font.lineHeight * scale + this._currentTextFormat.leading;
		var textHeight:Float = this._numLines * lineHeight;
		if (textHeight > this.actualHeight)
		{
			return 0;
		}
		if (this._currentVerticalAlign == Align.BOTTOM)
		{
			return (this.actualHeight - textHeight);
		}
		else if (this._currentVerticalAlign == Align.CENTER)
		{
			return (this.actualHeight - textHeight) / 2;
		}
		return 0;
	}
	
}

class CharLocation
{
	public function new()
	{
		
	}

	public var char:BitmapChar;
	public var scale:Float;
	public var x:Float;
	public var y:Float;
}