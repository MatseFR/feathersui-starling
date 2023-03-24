/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.text.FontStylesSet;
import feathers.utils.geom.GeomUtils;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.events.TextEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.AntiAliasType;
import openfl.text.FontType;
import openfl.text.GridFitType;
import openfl.text.StyleSheet;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import feathers.controls.supportClasses.IViewPort;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.rendering.Painter;
import starling.utils.MatrixUtil;
import starling.utils.Pool;
import starling.utils.SystemUtil;

/**
 * @private
 * Used internally by ScrollText. Not meant to be used on its own.
 *
 * @productversion Feathers 1.0.0
 */
class TextFieldViewPort extends FeathersControl implements IViewPort
{
	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	
	private var _textFieldContainer:Sprite;
	private var _textField:TextField;
	
	/**
	 * @private
	 */
	public var nativeFocus(get, never):TextField;
	private function get_nativeFocus():TextField { return this._textField; }
	
	/**
	 * @see feathers.controls.ScrollText#text
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
	 * @see feathers.controls.ScrollText#isHTML
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
	private var _fontStylesTextFormat:openfl.text.TextFormat;
	
	/**
	 * Generic font styles.
	 */
	public var fontStyles(get, set):FontStylesSet;
	private var _fontStyles:FontStylesSet;
	private function get_fontStyles():FontStylesSet { return this._fontStyles; }
	private function set_fontStyles(value:FontStylesSet):FontStylesSet
	{
		if (this._fontStyles == value)
		{
			return value;
		}
		if (this._fontStyles != null)
		{
			this._fontStyles.removeEventListener(Event.CHANGE, fontStylesSet_changeHandler);
		}
		this._fontStyles = value;
		if (this._fontStyles != null)
		{
			this._fontStyles.addEventListener(Event.CHANGE, fontStylesSet_changeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._fontStyles;
	}
	
	/**
	 * @private
	 */
	private var _currentTextFormat:openfl.text.TextFormat;
	
	/**
	 * @see feathers.controls.ScrollText#textFormat
	 */
	public var textFormat(get, set):openfl.text.TextFormat;
	private var _textFormat:openfl.text.TextFormat;
	private function get_textFormat():openfl.text.TextFormat { return this._textFormat; }
	private function set_textFormat(value:openfl.text.TextFormat):openfl.text.TextFormat
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
	 * @see feathers.controls.ScrollText#disabledTextFormat
	 */
	public var disabledTextFormat(get, set):openfl.text.TextFormat;
	private var _disabledTextFormat:openfl.text.TextFormat;
	private function get_disabledTextFormat():openfl.text.TextFormat { return this._disabledTextFormat; }
	private function set_disabledTextFormat(value:openfl.text.TextFormat):openfl.text.TextFormat
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
	 * @see feathers.controls.ScrollText#styleSheet
	 */
	public var styleSheet(get, set):StyleSheet;
	private var _styleSheet:StyleSheet;
	private function get_styleSheet():StyleSheet { return this._styleSheet; }
	private function set_styleSheet(value:StyleSheet):StyleSheet
	{
		if (this._styleSheet == value)
		{
			return value;
		}
		this._styleSheet = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._styleSheet;
	}
	
	/**
	 * @see feathers.controls.ScrollText#embedFonts
	 */
	public var embedFonts(get, set):Bool;
	private var _embedFonts:Bool = false;
	private function get_embedFonts():Bool { return this._embedFonts; }
	private function set_embedFonts(value:Bool):Bool
	{
		if (this._embedFonts == value)
		{
			return value;
		}
		this._embedFonts = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._embedFonts;
	}
	
	/**
	 * @see feathers.controls.ScrollText#antiAliasType
	 */
	public var antiAliasType(get, set):String;
	private var _antiAliasType:String = AntiAliasType.ADVANCED;
	private function get_antiAliasType():String { return this._antiAliasType; }
	private function set_antiAliasType(value:String):String
	{
		if (this._antiAliasType == value)
		{
			return value;
		}
		this._antiAliasType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._antiAliasType;
	}
	
	/**
	 * @see feathers.controls.ScrollText#background
	 */
	public var background(get, set):Bool;
	private var _background:Bool = false;
	private function get_background():Bool { return this._background; }
	private function set_background(value:Bool):Bool
	{
		if (this._background == value)
		{
			return value;
		}
		this._background = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._background;
	}
	
	/**
	 * @see feathers.controls.ScrollText#backgroundColor
	 */
	public var backgroundColor(get, set):Int;
	private var _backgroundColor:Int = 0xffffff;
	private function get_backgroundColor():Int { return this._backgroundColor; }
	private function set_backgroundColor(value:Int):Int
	{
		if (this._backgroundColor == value)
		{
			return value;
		}
		this._backgroundColor = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundColor;
	}
	
	/**
	 * @see feathers.controls.ScrollText#border
	 */
	public var border(get, set):Bool;
	private var _border:Bool = false;
	private function get_border():Bool { return this._border; }
	private function set_border(value:Bool):Bool
	{
		if (this._border == value)
		{
			return value;
		}
		this._border = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._border;
	}
	
	/**
	 * @see feathers.controls.ScrollText#borderColor
	 */
	public var borderColor(get, set):Int;
	private var _borderColor:Int = 0x000000;
	private function get_borderColor():Int { return this._borderColor; }
	private function set_borderColor(value:Int):Int
	{
		if (this._borderColor == value)
		{
			return value;
		}
		this._borderColor = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._borderColor;
	}
	
	/**
	 * @see feathers.controls.ScrollText#cacheAsBitmap
	 */
	public var cacheAsBitmap(get, set):Bool;
	private var _cacheAsBitmap:Bool = true;
	private function get_cacheAsBitmap():Bool { return this._cacheAsBitmap; }
	private function set_cacheAsBitmap(value:Bool):Bool
	{
		if (this._cacheAsBitmap == value)
		{
			return value;
		}
		this._cacheAsBitmap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._cacheAsBitmap;
	}
	
	/**
	 * @see feathers.controls.ScrollText#condenseWhite
	 */
	public var condenseWhite(get, set):Bool;
	private var _condenseWhite:Bool = false;
	private function get_condenseWhite():Bool { return this._condenseWhite; }
	private function set_condenseWhite(value:Bool):Bool
	{
		if (this._condenseWhite == value)
		{
			return value;
		}
		this._condenseWhite = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._condenseWhite;
	}
	
	/**
	 * @see feathers.controls.ScrollText#displayAsPassword
	 */
	public var displayAsPassword(get, set):Bool;
	private var _displayAsPassword:Bool = false;
	private function get_displayAsPassword():Bool { return this._displayAsPassword; }
	private function set_displayAsPassword(value:Bool):Bool
	{
		if (this._displayAsPassword == value)
		{
			return value;
		}
		this._displayAsPassword = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._displayAsPassword;
	}
	
	/**
	 * @see feathers.controls.ScrollText#gridFitType
	 */
	public var gridFitType(get, set):String;
	private var _gridFitType:String = GridFitType.PIXEL;
	private function get_gridFitType():String { return this._gridFitType; }
	private function set_gridFitType(value:String):String
	{
		if (this._gridFitType == value)
		{
			return value;
		}
		this._gridFitType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._gridFitType;
	}
	
	/**
	 * @see feathers.controls.ScrollText#sharpness
	 */
	public var sharpness(get, set):Float;
	private var _sharpness:Float = 0;
	private function get_sharpness():Float { return this._sharpness; }
	private function set_sharpness(value:Float):Float
	{
		if (this._sharpness == value)
		{
			return value;
		}
		this._sharpness = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._sharpness;
	}
	
	/**
	 * @see feathers.controls.ScrollText#thickness
	 */
	public var thickness(get, set):Float;
	private var _thickness:Float = 0;
	private function get_thickness():Float { return this._thickness; }
	private function set_thickness(value:Float):Float
	{
		if (this._thickness == value)
		{
			return value;
		}
		this._thickness = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._thickness;
	}
	
	private var _actualMinVisibleWidth:Float = 0;
	
	private var _explicitMinVisibleWidth:Float;
	
	public var minVisibleWidth(get, set):Float;
	private function get_minVisibleWidth():Float
	{
		if (this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return this._actualMinVisibleWidth;
		}
		return this._explicitMinVisibleWidth;
	}
	
	private function set_minVisibleWidth(value:Float):Float
	{
		if (this._explicitMinVisibleWidth == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return value;
		}
		var oldValue:Float = this._explicitMinVisibleWidth;
		this._explicitMinVisibleWidth = value;
		if (valueIsNaN)
		{
			this._actualMinVisibleWidth = 0;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleWidth = value;
			if (this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
				(this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue))
			{
				//only invalidate if this change might affect the visibleWidth
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
		return value;
	}
	
	public var maxVisibleWidth(get, set):Float;
	private var _maxVisibleWidth:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleWidth():Float { return this._maxVisibleWidth; }
	private function set_maxVisibleWidth(value:Float):Float
	{
		if (this._maxVisibleWidth == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleWidth cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleWidth;
		this._maxVisibleWidth = value;
		if (this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
			(this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue))
		{
			//only invalidate if this change might affect the visibleWidth
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._maxVisibleWidth;
	}
	
	private var _actualVisibleWidth:Float = 0;

	private var _explicitVisibleWidth:Float = Math.NaN;
	
	public var visibleWidth(get, set):Float;
	private function get_visibleWidth():Float
	{
		if (this._explicitVisibleWidth != this._explicitVisibleWidth) //isNaN
		{
			return this._actualVisibleWidth;
		}
		return this._explicitVisibleWidth;
	}
	
	private function set_visibleWidth(value:Float):Float
	{
		if (this._explicitVisibleWidth == value ||
			(value != value && this._explicitVisibleWidth != this._explicitVisibleWidth)) //isNaN
		{
			return value;
		}
		this._explicitVisibleWidth = value;
		if (this._actualVisibleWidth != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._explicitVisibleWidth;
	}
	
	private var _actualMinVisibleHeight:Float = 0;

	private var _explicitMinVisibleHeight:Float;
	
	public var minVisibleHeight(get, set):Float;
	private function get_minVisibleHeight():Float
	{
		if (this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) //isNaN
		{
			return this._actualMinVisibleHeight;
		}
		return this._explicitMinVisibleHeight;
	}
	
	private function set_minVisibleHeight(value:Float):Float
	{
		if (this._explicitMinVisibleHeight == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) //isNaN
		{
			return value;
		}
		var oldValue:Float = this._explicitMinVisibleHeight;
		this._explicitMinVisibleHeight = value;
		if (valueIsNaN)
		{
			this._actualMinVisibleHeight = 0;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight != this._explicitVisibleHeight && //isNaN
				(this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue))
			{
				//only invalidate if this change might affect the visibleHeight
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
		return this._explicitMinVisibleHeight;
	}
	
	public var maxVisibleHeight(get, set):Float;
	private var _maxVisibleHeight:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleHeight():Float { return this._maxVisibleHeight; }
	private function set_maxVisibleHeight(value:Float):Float
	{
		if (this._maxVisibleHeight == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleHeight cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleHeight;
		this._maxVisibleHeight = value;
		if (this._explicitVisibleHeight != this._explicitVisibleHeight && //isNaN
			(this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue))
		{
			//only invalidate if this change might affect the visibleHeight
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._maxVisibleHeight;
	}
	
	private var _actualVisibleHeight:Float = 0;
	
	private var _explicitVisibleHeight:Float = Math.NaN;
	
	public var visibleHeight(get, set):Float;
	private function get_visibleHeight():Float
	{
		if (this._explicitVisibleHeight != this._explicitVisibleHeight) //isNaN
		{
			return this._actualVisibleHeight;
		}
		return this._explicitVisibleHeight;
	}
	
	private function set_visibleHeight(value:Float):Float
	{
		if (this._explicitVisibleHeight == value ||
			(value != value && this._explicitVisibleHeight != this._explicitVisibleHeight)) //isNaN
		{
			return value;
		}
		this._explicitVisibleHeight = value;
		if (this._actualVisibleHeight != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._explicitVisibleHeight;
	}
	
	public var contentX(get, never):Float;
	private function get_contentX():Float { return 0; }
	
	public var contentY(get, never):Float;
	private function get_contentY():Float { return 0; }
	
	private var _scrollStep:Float;
	
	public var horizontalScrollStep(get, never):Float;
	private function get_horizontalScrollStep():Float { return this._scrollStep; }
	
	public var verticalScrollStep(get, never):Float;
	private function get_verticalScrollStep():Float { return this._scrollStep; }
	
	public var horizontalScrollPosition(get, set):Float;
	private var _horizontalScrollPosition:Float = 0;
	private function get_horizontalScrollPosition():Float { return this._horizontalScrollPosition; }
	private function set_horizontalScrollPosition(value:Float):Float
	{
		if (this._horizontalScrollPosition == value)
		{
			return value;
		}
		this._horizontalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		return this._horizontalScrollPosition;
	}
	
	public var verticalScrollPosition(get, set):Float;
	private var _verticalScrollPosition:Float = 0;
	private function get_verticalScrollPosition():Float { return this._verticalScrollPosition; }
	private function set_verticalScrollPosition(value:Float):Float
	{
		if (this._verticalScrollPosition == value)
		{
			return value;
		}
		this._verticalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		return this._verticalScrollPosition;
	}
	
	public var requiresMeasurementOnScroll(get, never):Bool;
	private function get_requiresMeasurementOnScroll():Bool { return false; }
	
	public var paddingTop(get, set):Float;
	private var _paddingTop:Float = 0;
	private function get_paddingTop():Float { return this._paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		if (this._paddingTop == value)
		{
			return value;
		}
		this._paddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingTop;
	}
	
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight():Float { return this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if (this._paddingRight == value)
		{
			return value;
		}
		this._paddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingRight;
	}
	
	public var paddingBottom(get, set):Float;
	private var _paddingBottom:Float = 0;
	private function get_paddingBottom():Float { return this._paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		if (this._paddingBottom == value)
		{
			return value;
		}
		this._paddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingBottom;
	}
	
	public var paddingLeft(get, set):Float;
	private var _paddingLeft:Float = 0;
	private function get_paddingLeft():Float { return this._paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		if (this._paddingLeft == value)
		{
			return value;
		}
		this._paddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingLeft;
	}
	
	override function render(painter:Painter):Void
	{
		//this component is an overlay above Starling, and it should be
		//excluded from the render cache
		painter.excludeFromCache(this);

		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var starlingViewPort:Rectangle = starling.viewPort;
		var matrix:Matrix = Pool.getMatrix();
		var point:Point = Pool.getPoint();
		this.parent.getTransformationMatrix(this.stage, matrix);
		MatrixUtil.transformCoords(matrix, 0, 0, point);
		var nativeScaleFactor:Float = 1;
		if (starling.supportHighResolutions)
		{
			nativeScaleFactor = starling.nativeStage.contentsScaleFactor;
		}
		var scaleFactor:Float = starling.contentScaleFactor / nativeScaleFactor;
		this._textFieldContainer.x = starlingViewPort.x + point.x * scaleFactor;
		this._textFieldContainer.y = starlingViewPort.y + point.y * scaleFactor;
		this._textFieldContainer.scaleX = GeomUtils.matrixToScaleX(matrix) * scaleFactor;
		this._textFieldContainer.scaleY = GeomUtils.matrixToScaleY(matrix) * scaleFactor;
		this._textFieldContainer.rotation = GeomUtils.matrixToRotation(matrix) * 180 / Math.PI;
		this._textFieldContainer.alpha = painter.state.alpha;
		Pool.putPoint(point);
		Pool.putMatrix(matrix);
		super.render(painter);
	}
	
	override function initialize():Void
	{
		this._textFieldContainer = new Sprite();
		this._textFieldContainer.visible = false;
		this._textField = new TextField();
		this._textField.autoSize = TextFieldAutoSize.LEFT;
		this._textField.selectable = false;
		this._textField.mouseWheelEnabled = false;
		this._textField.wordWrap = true;
		this._textField.multiline = true;
		this._textField.addEventListener(TextEvent.LINK, textField_linkHandler);
		this._textFieldContainer.addChild(this._textField);
	}
	
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var scrollInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SCROLL);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		
		if (stylesInvalid)
		{
			this.refreshTextFormat();
			this._textField.antiAliasType = this._antiAliasType;
			this._textField.background = this._background;
			this._textField.backgroundColor = this._backgroundColor;
			this._textField.border = this._border;
			this._textField.borderColor = this._borderColor;
			this._textField.condenseWhite = this._condenseWhite;
			this._textField.displayAsPassword = this._displayAsPassword;
			this._textField.gridFitType = this._gridFitType;
			this._textField.sharpness = this._sharpness;
			// TODO : openfl.text.TextField.thickness only exists on flash target
			#if flash
			this._textField.thickness = this._thickness;
			#end
			this._textField.cacheAsBitmap = this._cacheAsBitmap;
			this._textField.x = this._paddingLeft;
			this._textField.y = this._paddingTop;
		}
		
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		if (dataInvalid || stylesInvalid || stateInvalid)
		{
			if (this._styleSheet != null)
			{
				this._textField.embedFonts = this._embedFonts;
				this._textField.styleSheet = this._styleSheet;
			}
			else
			{
				if (!this._embedFonts &&
					this._currentTextFormat == this._fontStylesTextFormat)
				{
					//when font styles are passed in from the parent component, we
					//automatically determine if the TextField should use embedded
					//fonts, unless embedFonts is explicitly true
					this._textField.embedFonts = SystemUtil.isEmbeddedFont(
						this._currentTextFormat.font, this._currentTextFormat.bold,
						this._currentTextFormat.italic, FontType.EMBEDDED);
				}
				else
				{
					this._textField.embedFonts = this._embedFonts;
				}
				this._textField.styleSheet = null;
				this._textField.defaultTextFormat = this._currentTextFormat;
			}
			if (this._isHTML)
			{
				this._textField.htmlText = this._text;
			}
			else
			{
				this._textField.text = this._text;
			}
			this._scrollStep = this._textField.getLineMetrics(0).height * starling.contentScaleFactor;
		}
		
		var calculatedVisibleWidth:Float = this._explicitVisibleWidth;
		if (calculatedVisibleWidth != calculatedVisibleWidth)
		{
			if (this.stage != null)
			{
				calculatedVisibleWidth = this.stage.stageWidth;
			}
			else
			{
				calculatedVisibleWidth = starling.stage.stageWidth;
			}
			if (calculatedVisibleWidth < this._explicitMinVisibleWidth)
			{
				calculatedVisibleWidth = this._explicitMinVisibleWidth;
			}
			else if (calculatedVisibleWidth > this._maxVisibleWidth)
			{
				calculatedVisibleWidth = this._maxVisibleWidth;
			}
		}
		this._textField.width = calculatedVisibleWidth - this._paddingLeft - this._paddingRight;
		var totalContentHeight:Float = this._textField.height + this._paddingTop + this._paddingBottom;
		var calculatedVisibleHeight:Float = this._explicitVisibleHeight;
		if (calculatedVisibleHeight != calculatedVisibleHeight)
		{
			calculatedVisibleHeight = totalContentHeight;
			if (calculatedVisibleHeight < this._explicitMinVisibleHeight)
			{
				calculatedVisibleHeight = this._explicitMinVisibleHeight;
			}
			else if (calculatedVisibleHeight > this._maxVisibleHeight)
			{
				calculatedVisibleHeight = this._maxVisibleHeight;
			}
		}
		sizeInvalid = this.saveMeasurements(
			calculatedVisibleWidth, totalContentHeight,
			calculatedVisibleWidth, totalContentHeight) || sizeInvalid;
		this._actualVisibleWidth = calculatedVisibleWidth;
		this._actualVisibleHeight = calculatedVisibleHeight;
		this._actualMinVisibleWidth = calculatedVisibleWidth;
		this._actualMinVisibleHeight = calculatedVisibleHeight;
		
		if (sizeInvalid || scrollInvalid)
		{
			var scrollRect:Rectangle = this._textFieldContainer.scrollRect;
			if (scrollRect == null)
			{
				scrollRect = new Rectangle();
			}
			scrollRect.width = calculatedVisibleWidth;
			scrollRect.height = calculatedVisibleHeight;
			scrollRect.x = this._horizontalScrollPosition;
			scrollRect.y = this._verticalScrollPosition;
			this._textFieldContainer.scrollRect = scrollRect;
		}
	}
	
	private function refreshTextFormat():Void
	{
		if (!this._isEnabled && this._disabledTextFormat != null)
		{
			this._currentTextFormat = this._disabledTextFormat;
		}
		else if (this._textFormat != null)
		{
			this._currentTextFormat = this._textFormat;
		}
		else if (this._fontStyles != null)
		{
			this._currentTextFormat = this.getTextFormatFromFontStyles();
		}
	}
	
	private function getTextFormatFromFontStyles():flash.text.TextFormat
	{
		if (this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES) ||
			this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE))
		{
			var fontStylesFormat:starling.text.TextFormat = null;
			if (this._fontStyles != null)
			{
				fontStylesFormat = this._fontStyles.getTextFormatForTarget(this);
			}
			if (fontStylesFormat != null)
			{
				this._fontStylesTextFormat = fontStylesFormat.toNativeFormat(this._fontStylesTextFormat);
			}
			else if (this._fontStylesTextFormat == null)
			{
				//fallback to a default so that something is displayed
				this._fontStylesTextFormat = new flash.text.TextFormat();
			}
		}
		return this._fontStylesTextFormat;
	}
	
	private function addedToStageHandler(event:Event):Void
	{
		this.stage.starling.nativeStage.addChild(this._textFieldContainer);
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	private function removedFromStageHandler(event:Event):Void
	{
		this.stage.starling.nativeStage.removeChild(this._textFieldContainer);
		this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	private function enterFrameHandler(event:Event):Void
	{
		var target:DisplayObject = this;
		do
		{
			if (!target.visible)
			{
				this._textFieldContainer.visible = false;
				return;
			}
			target = target.parent;
		}
		while (target != null);
		this._textFieldContainer.visible = true;
	}
	
	private function textField_linkHandler(event:TextEvent):Void
	{
		this.dispatchEventWith(Event.TRIGGERED, false, event.text);
	}
	
	private function fontStylesSet_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}