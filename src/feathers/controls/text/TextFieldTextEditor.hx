/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.text;

import feathers.core.BaseTextEditor;
import feathers.core.FeathersControl;
import feathers.core.FocusManager;
import feathers.core.INativeFocusOwner;
import feathers.core.ITextEditor;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.geom.GeomUtils;
#if flash
import flash.events.SoftKeyboardEvent;
import flash.text.TextField;
#end
import openfl.display.BitmapData;
import openfl.display.Stage;
import openfl.display3D.Context3DProfile;
import openfl.errors.Error;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.geom.Matrix;
import openfl.geom.Matrix3D;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;
import openfl.text.AntiAliasType;
import openfl.text.FontType;
import openfl.text.GridFitType;
#if !flash
import openfl.text.TextField;
#end
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.ui.Keyboard;
import feathers.core.IFeathersControl;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.rendering.Painter;
import starling.text.TextFormat;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;
import starling.utils.Align;
import starling.utils.MathUtil;
import starling.utils.MatrixUtil;
import starling.utils.Pool;
import starling.utils.SystemUtil;

/**
 * Text that may be edited at runtime by the user with the
 * <code>TextInput</code> component, using the native
 * <code>flash.text.TextField</code> class with its <code>type</code>
 * property set to <code>flash.text.TextInputType.INPUT</code>. When not in
 * focus, the <code>TextField</code> is drawn to <code>BitmapData</code> and
 * uploaded to a texture on the GPU. Textures are managed internally by this
 * component, and they will be automatically disposed when the component is
 * disposed.
 *
 * <p>For desktop apps, <code>TextFieldTextEditor</code> is recommended
 * instead of <code>StageTextTextEditor</code>. <code>StageTextTextEditor</code>
 * will still work in desktop apps, but it is more appropriate for mobile
 * apps.</p>
 *
 * <p>The following example shows how to use
 * <code>TextFieldTextEditor</code> with a <code>TextInput</code>:</p>
 *
 * <listing version="3.0">
 * var input:TextInput = new TextInput();
 * input.textEditorFactory = function():ITextEditor
 * {
 *     return new TextFieldTextEditor();
 * };
 * this.addChild( input );</listing>
 *
 * @see feathers.controls.TextInput
 * @see ../../../../help/text-editors.html Introduction to Feathers text editors
 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html flash.text.TextField
 *
 * @productversion Feathers 1.0.0
 */
class TextFieldTextEditor extends BaseTextEditor implements ITextEditor implements INativeFocusOwner
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>TextFieldTextEditor</code>
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
		this.isQuickHitAreaEnabled = true;
		this.addEventListener(Event.ADDED_TO_STAGE, textEditor_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, textEditor_removedFromStageHandler);
	}
	
	/**
	   @private
	**/
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return globalStyleProvider;
	}
	
	/**
	 * The text field sub-component.
	 */
	private var textField:TextField;
	
	/**
	 * @copy feathers.core.INativeFocusOwner#nativeFocus
	 */
	public var nativeFocus(get, never):Dynamic;
	private function get_nativeFocus():Dynamic { return this.textField; }
	
	/**
	 * An image that displays a snapshot of the native <code>TextField</code>
	 * in the Starling display list when the editor doesn't have focus.
	 */
	private var textSnapshot:Image;
	
	/**
	 * The separate text field sub-component used for measurement.
	 * Typically, the main text field often doesn't report correct values
	 * for a full frame if its dimensions are changed too often.
	 */
	private var measureTextField:TextField;
	
	/**
	   @private
	**/
	private var _snapshotWidth:Int = 0;
	
	/**
	   @private
	**/
	private var _snapshotHeight:Int = 0;
	
	/**
	   @private
	**/
	private var _textFieldSnapshotClipRect:Rectangle = new Rectangle();
	
	/**
	   @private
	**/
	private var _textFieldOffsetX:Float = 0;
	
	/**
	   @private
	**/
	private var _textFieldOffsetY:Float = 0;
	
	/**
	   @private
	**/
	private var _lastGlobalScaleX:Float = 0;
	
	/**
	   @private
	**/
	private var _lastGlobalScaleY:Float = 0;
	
	/**
	   @private
	**/
	private var _needsTextureUpdate:Bool = false;
	
	/**
	   @private
	**/
	private var _needsNewTexture:Bool = false;
	
	/**
	 * @inheritDoc
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.textField == null)
		{
			return 0;
		}
		var gutterDimensionsOffset:Float = 0;
		if (this._useGutter || this._border)
		{
			gutterDimensionsOffset = 2;
		}
		return gutterDimensionsOffset + this.textField.getLineMetrics(0).ascent;
	}
	
	/**
	   @private
	**/
	private var _previousStarlingTextFormat:starling.text.TextFormat;
	
	/**
	   @private
	**/
	private var _currentStarlingTextFormat:starling.text.TextFormat;
	
	/**
	   @private
	**/
	private var _previousTextFormat:openfl.text.TextFormat;
	
	/**
	   @private
	**/
	private var _currentTextFormat:openfl.text.TextFormat;
	
	/**
	 * For debugging purposes, the current
	 * <code>flash.text.TextFormat</code> used to render the text. Updated
	 * during validation, and may be <code>null</code> before the first
	 * validation.
	 *
	 * <p>Do not modify this value. It is meant for testing and debugging
	 * only. Use the parent's <code>starling.text.TextFormat</code> font
	 * styles APIs instead.</p>
	 */
	public var currentTextFormat(get, never):openfl.text.TextFormat;
	private function get_currentTextFormat():openfl.text.TextFormat { return this._currentTextFormat; }
	
	/**
	   @private
	**/
	private var _textFormatForState:Map<String, openfl.text.TextFormat>;
	
	/**
	   @private
	**/
	private var _fontStylesTextFormat:openfl.text.TextFormat;
	
	/**
	 * Advanced font formatting used to draw the text, if
	 * <code>fontStyles</code> and <code>starling.text.TextFormat</code>
	 * cannot be used on the parent component because the full capabilities
	 * of <code>flash.text.TextField</code> are required.
	 *
	 * <p>In the following example, the text format is changed:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.textFormat = new TextFormat( "Source Sans Pro" );;</listing>
	 *
	 * <p><strong>Warning:</strong> If this property is not
	 * <code>null</code>, any <code>starling.text.TextFormat</code> font
	 * styles that are passed in from the parent component may be ignored.
	 * In other words, advanced font styling with
	 * <code>flash.text.TextFormat</code> will always take precedence.</p>
	 *
	 * @default null
	 *
	 * @see #setTextFormatForState()
	 * @see #disabledTextFormat
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextFormat.html flash.text.TextFormat
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
	 * Advanced font formatting used to draw the text when the component is
	 * disabled, if <code>disabledFontStyles</code> and
	 * <code>starling.text.TextFormat</code> cannot be used on the parent
	 * component because the full capabilities of
	 * <code>flash.text.TextField</code> are required.
	 *
	 * <p>In the following example, the disabled text format is changed:</p>
	 *
	 * <p><strong>Warning:</strong> If this property is not
	 * <code>null</code>, any <code>starling.text.TextFormat</code> font
	 * styles that are passed in from the parent component may be ignored.
	 * In other words, advanced font styling with
	 * <code>flash.text.TextFormat</code> will always take precedence.</p>
	 *
	 * <listing version="3.0">
	 * textEditor.isEnabled = false;
	 * textEditor.disabledTextFormat = new TextFormat( "Source Sans Pro" );</listing>
	 *
	 * @default null
	 *
	 * @see #textFormat
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextFormat.html flash.text.TextFormat
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
	 * If advanced <code>flash.text.TextFormat</code> styles are specified,
	 * determines if the TextField should use an embedded font or not. If
	 * the specified font is not embedded, the text may not be displayed at
	 * all.
	 *
	 * <p>If the font styles are passed in from the parent component, the
	 * text renderer will automatically detect if a font is embedded or not,
	 * and the <code>embedFonts</code> property will be ignored if it is set
	 * to <code>false</code>. Setting it to <code>true</code> will force the
	 * <code>TextField</code> to always try to use embedded fonts.</p>
	 *
	 * <p>In the following example, the font is embedded:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.embedFonts = true;</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#embedFonts Full description of flash.text.TextField.embedFonts in Adobe's Flash Platform API Reference
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
	 * Determines if the TextField wraps text to the next line.
	 *
	 * <p>In the following example, word wrap is enabled:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.wordWrap = true;</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#wordWrap Full description of flash.text.TextField.wordWrap in Adobe's Flash Platform API Reference
	 */
	public var wordWrap(get, set):Bool;
	private var _wordWrap:Bool = false;
	private function get_wordWrap():Bool { return this._wordWrap; }
	private function set_wordWrap(value:Bool):Bool
	{
		if (this._wordWrap == value)
		{
			return value;
		}
		this._wordWrap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._wordWrap;
	}
	
	/**
	 * Indicates whether field is a multiline text field.
	 *
	 * <p>In the following example, multiline is enabled:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.multiline = true;</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#multiline Full description of flash.text.TextField.multiline in Adobe's Flash Platform API Reference
	 */
	public var multiline(get, set):Bool;
	private var _multiline:Bool = false;
	private function get_multiline():Bool { return this._multiline; }
	private function set_multiline(value:Bool):Bool
	{
		if (this._multiline == value)
		{
			return value;
		}
		this._multiline = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._multiline;
	}
	
	/**
	 * Determines if the TextField should display the value of the
	 * <code>text</code> property as HTML or not.
	 *
	 * <p>In the following example, the text is displayed as HTML:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.isHTML = true;</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#htmlText flash.text.TextField.htmlText
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
	 * TODO : openfl.text.TextField has no alwaysShowSelection property, remove ?
	 * 
	 * When set to <code>true</code> and the text field is not in focus,
	 * Flash Player highlights the selection in the text field in gray. When
	 * set to <code>false</code> and the text field is not in focus, Flash
	 * Player does not highlight the selection in the text field.
	 *
	 * <p>In the following example, the selection is always shown:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.alwaysShowSelection = true;</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#alwaysShowSelection Full description of flash.text.TextField.alwaysShowSelection in Adobe's Flash Platform API Reference
	 */
	public var alwaysShowSelection(get, set):Bool;
	private var _alwaysShowSelection:Bool = false;
	private function get_alwaysShowSelection():Bool { return this._alwaysShowSelection; }
	private function set_alwaysShowSelection(value:Bool):Bool
	{
		if (this._alwaysShowSelection == value)
		{
			return value;
		}
		this._alwaysShowSelection = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._alwaysShowSelection;
	}
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * Specifies whether the text field is a password text field that hides
	 * the input characters using asterisks instead of the actual
	 * characters.
	 *
	 * @see feathers.controls.TextInput#displayAsPassword
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#displayAsPassword Full description of flash.text.TextField.displayAsPassword in Adobe's Flash Platform API Reference
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
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#maxChars
	 *
	 * @see feathers.controls.TextInput#maxChars
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#maxChars Full description of flash.text.TextField.maxChars in Adobe's Flash Platform API Reference
	 */
	public var maxChars(get, set):Int;
	private var _maxChars:Int = 0;
	private function get_maxChars():Int { return this._maxChars; }
	private function set_maxChars(value:Int):Int
	{
		if (this._maxChars == value)
		{
			return value;
		}
		this._maxChars = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._maxChars;
	}
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#restrict
	 *
	 * @see feathers.controls.TextInput#restrict
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#restrict Full description of flash.text.TextField.restrict in Adobe's Flash Platform API Reference
	 */
	public var restrict(get, set):String;
	@:native("_restrict1")
	private var _restrict:String;
	private function get_restrict():String { return this._restrict; }
	private function set_restrict(value:String):String
	{
		if (this._restrict == value)
		{
			return value;
		}
		this._restrict = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._restrict;
	}
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#isEditable
	 *
	 * @see feathers.controls.TextInput#isEditable
	 */
	public var isEditable(get, set):Bool;
	private var _isEditable:Bool = false;
	private function get_isEditable():Bool { return this._isEditable; }
	private function set_isEditable(value:Bool):Bool
	{
		if (this._isEditable == value)
		{
			return value;
		}
		this._isEditable = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._isEditable;
	}
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#isSelectable
	 *
	 * @see feathers.controls.TextInput#isSelectable
	 */
	public var isSelectable(get, set):Bool;
	private var _isSelectable:Bool = true;
	private function get_isSelectable():Bool { return this._isSelectable; }
	private function set_isSelectable(value:Bool):Bool
	{
		if (this._isSelectable == value)
		{
			return value;
		}
		this._isSelectable = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._isSelectable;
	}
	
	/**
	 * The type of anti-aliasing used for this text field, defined as
	 * constants in the <code>flash.text.AntiAliasType</code> class. You can
	 * control this setting only if the font is embedded (with the
	 * <code>embedFonts</code> property set to true).
	 *
	 * <p>In the following example, the anti-alias type is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.antiAliasType = AntiAliasType.NORMAL;</listing>
	 *
	 * @default flash.text.AntiAliasType.ADVANCED
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#antiAliasType Full description of flash.text.TextField.antiAliasType in Adobe's Flash Platform API Reference
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/AntiAliasType.html flash.text.AntiAliasType
	 * @see #embedFonts
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
	 * Determines whether Flash Player forces strong horizontal and vertical
	 * lines to fit to a pixel or subpixel grid, or not at all using the
	 * constants defined in the <code>flash.text.GridFitType</code> class.
	 * This property applies only if the <code>antiAliasType</code> property
	 * of the text field is set to <code>flash.text.AntiAliasType.ADVANCED</code>.
	 *
	 * <p>In the following example, the grid fit type is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.gridFitType = GridFitType.SUBPIXEL;</listing>
	 *
	 * @default flash.text.GridFitType.PIXEL
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#gridFitType Full description of flash.text.TextField.gridFitType in Adobe's Flash Platform API Reference
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/GridFitType.html flash.text.GridFitType
	 * @see #antiAliasType
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
	 * The sharpness of the glyph edges in this text field. This property
	 * applies only if the <code>antiAliasType</code> property of the text
	 * field is set to <code>flash.text.AntiAliasType.ADVANCED</code>. The
	 * range for <code>sharpness</code> is a number from <code>-400</code>
	 * to <code>400</code>.
	 *
	 * <p>In the following example, the sharpness is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.sharpness = 200;</listing>
	 *
	 * @default 0
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#sharpness Full description of flash.text.TextField.sharpness in Adobe's Flash Platform API Reference
	 * @see #antiAliasType
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
	 * TODO : openfl.text.TextField has no .thickness property, remove ?
	 * 
	 * The thickness of the glyph edges in this text field. This property
	 * applies only if the <code>antiAliasType</code> property is set to
	 * <code>flash.text.AntiAliasType.ADVANCED</code>. The range for
	 * <code>thickness</code> is a number from <code>-200</code> to
	 * <code>200</code>.
	 *
	 * <p>In the following example, the thickness is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.thickness = 100;</listing>
	 *
	 * @default 0
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#thickness Full description of flash.text.TextField.thickness in Adobe's Flash Platform API Reference
	 * @see #antiAliasType
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._sharpness;
	}
	
	/**
	 * Specifies whether the text field has a background fill. Use the
	 * <code>backgroundColor</code> property to set the background color of
	 * a text field.
	 *
	 * <p>In the following example, the background is enabled:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.background = true;
	 * textRenderer.backgroundColor = 0xff0000;</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#background Full description of flash.text.TextField.background in Adobe's Flash Platform API Reference
	 * @see #backgroundColor
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
	 * The color of the text field background that is displayed if the
	 * <code>background</code> property is set to <code>true</code>.
	 *
	 * <p>In the following example, the background color is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.background = true;
	 * textRenderer.backgroundColor = 0xff000ff;</listing>
	 *
	 * @default 0xffffff
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#backgroundColor Full description of flash.text.TextField.backgroundColor in Adobe's Flash Platform API Reference
	 * @see #background
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
	 * Specifies whether the text field has a border. Use the
	 * <code>borderColor</code> property to set the border color.
	 *
	 * <p>Note: If <code>border</code> is set to <code>true</code>, the
	 * component will behave as if <code>useGutter</code> is also set to
	 * <code>true</code> because the border will not render correctly
	 * without the gutter.</p>
	 *
	 * <p>In the following example, the border is enabled:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.border = true;
	 * textRenderer.borderColor = 0xff0000;</listing>
	 *
	 * @default false
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#border Full description of flash.text.TextField.border in Adobe's Flash Platform API Reference
	 * @see #borderColor
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
	 * The color of the text field border that is displayed if the
	 * <code>border</code> property is set to <code>true</code>.
	 *
	 * <p>In the following example, the border color is changed:</p>
	 *
	 * <listing version="3.0">
	 * textRenderer.border = true;
	 * textRenderer.borderColor = 0xff00ff;</listing>
	 *
	 * @default 0x000000
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#borderColor Full description of flash.text.TextField.borderColor in Adobe's Flash Platform API Reference
	 * @see #border
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
	 * Determines if the 2-pixel gutter around the edges of the
	 * <code>flash.text.TextField</code> will be used in measurement and
	 * layout. To visually align with other text renderers and text editors,
	 * it is often best to leave the gutter disabled.
	 *
	 * <p>Returns <code>true</code> if the <code>border</code> property is
	 * <code>true</code>.</p>
	 *
	 * <p>In the following example, the gutter is enabled:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.useGutter = true;</listing>
	 *
	 * @default false
	 */
	public var useGutter(get, set):Bool;
	private var _useGutter:Bool = false;
	private function get_useGutter():Bool { return this._useGutter || this._border; }
	private function set_useGutter(value:Bool):Bool
	{
		if (this._useGutter == value)
		{
			return value;
		}
		this._useGutter = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._useGutter;
	}
	
	/**
	 * @inheritDoc
	 */
	public var setTouchFocusOnEndedPhase(get, never):Bool;
	private function get_setTouchFocusOnEndedPhase():Bool { return false; }
	
	/**
	   @private
	**/
	private var _textFieldHasFocus:Bool = false;
	
	/**
	   @private
	**/
	private var _isWaitingToSetFocus:Bool = false;
	
	/**
	   @private
	**/
	private var _pendingSelectionBeginIndex:Int = -1;
	
	/**
	 * @inheritDoc
	 */
	public var selectionBeginIndex(get, never):Int;
	private function get_selectionBeginIndex():Int
	{
		if (this._pendingSelectionBeginIndex >= 0)
		{
			return this._pendingSelectionBeginIndex;
		}
		if (this.textField != null)
		{
			return this.textField.selectionBeginIndex;
		}
		return 0;
	}
	
	/**
	   @private
	**/
	private var _pendingSelectionEndIndex:Int = -1;
	
	/**
	 * @inheritDoc
	 */
	public var selectionEndIndex(get, never):Int;
	private function get_selectionEndIndex():Int
	{
		if (this._pendingSelectionEndIndex >= 0)
		{
			return this._pendingSelectionEndIndex;
		}
		if (this.textField != null)
		{
			return this.textField.selectionEndIndex;
		}
		return 0;
	}
	
	/**
	 * If enabled, the text editor will remain in focus, even if something
	 * else is touched.
	 *
	 * <p>Note: If the <code>FocusManager</code> is enabled, this property
	 * will be ignored.</p>
	 *
	 * <p>In the following example, touch focus is maintained:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.maintainTouchFocus = true;</listing>
	 *
	 * @default false
	 */
	//public var maintainTouchFocus(get, set):Bool;
	private var _maintainTouchFocus:Bool;
	override function get_maintainTouchFocus():Bool { return this._maintainTouchFocus; }
	override function set_maintainTouchFocus(value:Bool):Bool
	{
		return this._maintainTouchFocus = value;
	}
	
	/**
	 * Refreshes the texture snapshot every time that the text editor is
	 * scaled. Based on the scale in global coordinates, so scaling the
	 * parent will require a new snapshot.
	 *
	 * <p>Warning: setting this property to true may result in reduced
	 * performance because every change of the scale requires uploading a
	 * new texture to the GPU. Use with caution. Consider setting this
	 * property to false temporarily during animations that modify the
	 * scale.</p>
	 *
	 * <p>In the following example, the snapshot will be updated when the
	 * text editor is scaled:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.updateSnapshotOnScaleChange = true;</listing>
	 *
	 * @default false
	 */
	public var updateSnapshotOnScaleChange(get, set):Bool;
	private var _updateSnapshotOnScaleChange:Bool = false;
	private function get_updateSnapshotOnScaleChange():Bool { return this._updateSnapshotOnScaleChange; }
	private function set_updateSnapshotOnScaleChange(value:Bool):Bool
	{
		if (this._updateSnapshotOnScaleChange == value)
		{
			return value;
		}
		this._updateSnapshotOnScaleChange = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._updateSnapshotOnScaleChange;
	}
	
	/**
	 * Fixes an issue where <code>flash.text.TextField</code> renders
	 * incorrectly when drawn to <code>BitmapData</code> by waiting one
	 * frame.
	 *
	 * <p>Warning: enabling this workaround may cause slight flickering
	 * after the <code>text</code> property is changed.</p>
	 *
	 * <p>In the following example, the workaround is enabled:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.useSnapshotDelayWorkaround = true;</listing>
	 *
	 * @default false
	 */
	public var useSnapshotDelayWorkaround(get, set):Bool;
	private var _useSnapshotDelayWorkaround:Bool = false;
	private function get_useSnapshotDelayWorkaround():Bool { return this._useSnapshotDelayWorkaround; }
	private function set_useSnapshotDelayWorkaround(value:Bool):Bool
	{
		if (this._useSnapshotDelayWorkaround == value)
		{
			return value;
		}
		this._useSnapshotDelayWorkaround = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._useSnapshotDelayWorkaround;
	}
	
	/**
	 * Customizes the soft keyboard that is displayed on a touch screen
	 * when the text editor has focus.
	 *
	 * <p>In the following example, the soft keyboard type is customized:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.softKeyboard = SoftKeyboardType.NUMBER;</listing>
	 *
	 * @default flash.text.SoftKeyboardType.DEFAULT
	 *
	 * @see https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/SoftKeyboardType.html flash.text.SoftKeyboardType
	 */
	public var softKeyboard(get, set):String;
	private var _softKeyboard:String = "default"; //constant is available in AIR only
	private function get_softKeyboard():String { return this._softKeyboard; }
	private function set_softKeyboard(value:String):String
	{
		if (this._softKeyboard == value)
		{
			return value;
		}
		this._softKeyboard = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._softKeyboard;
	}
	
	/**
	 * Indicates of the text editor resets its current scroll position to
	 * 0 on focus out.
	 *
	 * <p>In the following example, the scroll position is not reset on focus out:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.resetScrollOnFocusOut = false;</listing>
	 *
	 * @default true
	 */
	public var resetScrollOnFocusOut(get, set):Bool;
	private var _resetScrollOnFocusOut:Bool = true;
	private function get_resetScrollOnFocusOut():Bool { return this._resetScrollOnFocusOut; }
	private function set_resetScrollOnFocusOut(value:Bool):Bool
	{
		return this._resetScrollOnFocusOut = value;
	}
	
	/**
	   @private
	**/
	override public function dispose():Void 
	{
		if (this.textSnapshot != null)
		{
			//avoid the need to call dispose(). we'll create a new snapshot
			//when the renderer is added to stage again.
			this.textSnapshot.texture.dispose();
			this.removeChild(this.textSnapshot, true);
			this.textSnapshot = null;
		}
		
		if (this.textField != null)
		{
			if (this.textField.parent != null)
			{
				this.textField.parent.removeChild(this.textField);
			}
			this.textField.removeEventListener(flash.events.Event.CHANGE, textField_changeHandler);
			this.textField.removeEventListener(FocusEvent.FOCUS_IN, textField_focusInHandler);
			this.textField.removeEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
			this.textField.removeEventListener(KeyboardEvent.KEY_DOWN, textField_keyDownHandler);
			#if flash
			this.textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, textField_softKeyboardActivatingHandler);
			this.textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, textField_softKeyboardActivateHandler);
			this.textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, textField_softKeyboardDeactivateHandler);
			#end
		}
		//this isn't necessary, but if a memory leak keeps the text renderer
		//from being garbage collected, freeing up the text field may help
		//ease major memory pressure from native filters
		this.textField = null;
		this.measureTextField = null;
		
		this.stateContext = null;
		
		super.dispose();
	}
	
	/**
	   @private
	**/
	override public function render(painter:Painter):Void 
	{
		if (this.textSnapshot != null && this._updateSnapshotOnScaleChange)
		{
			var matrix:Matrix = Pool.getMatrix();
			this.getTransformationMatrix(this.stage, matrix);
			if (GeomUtils.matrixToScaleX(matrix) != this._lastGlobalScaleX ||
				GeomUtils.matrixToScaleY(matrix) != this._lastGlobalScaleY)
			{
				//the snapshot needs to be updated because the scale has
				//changed since the last snapshot was taken.
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
				this.validate();
			}
			Pool.putMatrix(matrix);
		}
		if (this._needsTextureUpdate)
		{
			this._needsTextureUpdate = false;
			if (this._useSnapshotDelayWorkaround)
			{
				//sometimes, we need to wait a frame for flash.text.TextField
				//to render properly when drawing to BitmapData.
				this.addEventListener(Event.ENTER_FRAME, refreshSnapshot_enterFrameHandler);
			}
			else
			{
				this.refreshSnapshot();
			}
			this.positionSnapshot();
		}
		//we'll skip this if the text field isn't visible to avoid running
		//that code every frame.
		if (this.textField != null && this.textField.visible)
		{
			this.transformTextField();
		}
		super.render(painter);
	}
	
	/**
	 * @inheritDoc
	 */
	public function setFocus(position:Point = null):Void
	{
		if (this.textField != null)
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			if (this.textField.parent == null)
			{
				starling.nativeStage.addChild(this.textField);
			}
			if (position != null)
			{
				var nativeScaleFactor:Float = 1;
				if (starling.supportHighResolutions)
				{
					nativeScaleFactor = starling.nativeStage.contentsScaleFactor;
				}
				var scaleFactor:Float = starling.contentScaleFactor / nativeScaleFactor;
				var scaleX:Float = this.textField.scaleX;
				var scaleY:Float = this.textField.scaleY;
				var gutterPositionOffset:Float = 2;
				if (this._useGutter || this._border)
				{
					gutterPositionOffset = 0;
				}
				var positionX:Float = position.x + gutterPositionOffset;
				var positionY:Float = position.y + gutterPositionOffset;
				if (positionX < gutterPositionOffset)
				{
					//account  for negative positions
					positionX = gutterPositionOffset;
				}
				else
				{
					var maxPositionX:Float = (this.textField.width / scaleX) - gutterPositionOffset;
					if (positionX > maxPositionX)
					{
						positionX = maxPositionX;
					}
				}
				if (positionY < gutterPositionOffset)
				{
					//account for negative positions
					positionY = gutterPositionOffset;
				}
				else
				{
					var maxPositionY:Float = (this.textField.height / scaleY) - gutterPositionOffset;
					if (positionY > maxPositionY)
					{
						positionY = maxPositionY;
					}
				}
				this._pendingSelectionBeginIndex = this.getSelectionIndexAtPoint(positionX, positionY);
				if (this._pendingSelectionBeginIndex < 0)
				{
					if (this._multiline)
					{
						var lineIndex:Int = this.textField.getLineIndexAtPoint((this.textField.width / 2) / scaleX, positionY);
						try
						{
							this._pendingSelectionBeginIndex = this.textField.getLineOffset(lineIndex) + this.textField.getLineLength(lineIndex);
							if (this._pendingSelectionBeginIndex != this._text.length)
							{
								this._pendingSelectionBeginIndex--;
							}
						}
						catch (error:Error)
						{
							//we may be checking for a line beyond the
							//end that doesn't exist
							this._pendingSelectionBeginIndex = this._text.length;
						}
					}
					else
					{
						this._pendingSelectionBeginIndex = this.getSelectionIndexAtPoint(positionX, this.textField.getLineMetrics(0).ascent / 2);
						if (this._pendingSelectionBeginIndex < 0)
						{
							this._pendingSelectionBeginIndex = this._text.length;
						}
					}
				}
				else
				{
					var bounds:Rectangle = this.textField.getCharBoundaries(this._pendingSelectionBeginIndex);
					//bounds should never be null because the character
					//index passed to getCharBoundaries() comes from a
					//call to getCharIndexAtPoint(). however, a user
					//reported that a null reference error happened
					//here! I couldn't reproduce, but I might as well
					//assume that the runtime has a bug. won't hurt.
					if (bounds != null)
					{
						var boundsX:Float = bounds.x;
						if ((boundsX + bounds.width - positionX) < (positionX - boundsX))
						{
							this._pendingSelectionBeginIndex++;
						}
					}
				}
				this._pendingSelectionEndIndex = this._pendingSelectionBeginIndex;
			}
			else
			{
				this._pendingSelectionBeginIndex = this._pendingSelectionEndIndex = -1;
			}
			if (!FocusManager.isEnabledForStage(this.stage))
			{
				starling.nativeStage.focus = this.textField;
			}
			this.textField.requestSoftKeyboard();
			if (this._textFieldHasFocus)
			{
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
			}
		}
		else
		{
			this._isWaitingToSetFocus = true;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function clearFocus():Void
	{
		if (!this._textFieldHasFocus)
		{
			return;
		}
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var nativeStage:Stage = starling.nativeStage;
		if (nativeStage.focus == this.textField)
		{
			//only clear the native focus when our native target has focus
			//because otherwise another component may lose focus.
			
			//setting the focus to Starling.current.nativeStage doesn't work
			//here, so we need to use null. on Android, if we give focus to the
			//nativeStage, focus will be removed from the StageText, but the
			//soft keyboard will incorrectly remain open.
			nativeStage.focus = null;
			
			//previously, there was a comment here that said that the native
			//stage focus should not be set to null. this was due to an
			//issue in focus manager where focus would be restored
			//incorrectly if the stage focus became null. this issue was
			//fixed, and it is now considered safe to use null.
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function selectRange(beginIndex:Int, endIndex:Int):Void
	{
		if (!this._isEditable && !this._isSelectable)
		{
			return;
		}
		if (this.textField != null)
		{
			if (!this._isValidating)
			{
				this.validate();
			}
			this.textField.setSelection(beginIndex, endIndex);
		}
		else
		{
			this._pendingSelectionBeginIndex = beginIndex;
			this._pendingSelectionEndIndex = endIndex;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function measureText(result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		if (!needsWidth && !needsHeight)
		{
			result.x = this._explicitWidth;
			result.y = this._explicitHeight;
			return result;
		}
		
		//if a parent component validates before we're added to the stage,
		//measureText() may be called before initialization, so we need to
		//force it.
		if (!this._isInitialized)
		{
			this.initializeNow();
		}
		
		this.commit();
		
		result = this.measure(result);
		
		return result;
	}
	
	/**
	 * Gets the advanced <code>flash.text.TextFormat</code> font formatting
	 * passed in using <code>setTextFormatForState()</code> for the
	 * specified state.
	 *
	 * <p>If an <code>flash.text.TextFormat</code> is not defined for a
	 * specific state, returns <code>null</code>.</p>
	 *
	 * @see #setTextFormatForState()
	 */
	public function getTextFormatForState(state:String):openfl.text.TextFormat
	{
		if (this._textFormatForState == null)
		{
			return null;
		}
		return this._textFormatForState[state];
	}
	
	/**
	 * Sets the advanced <code>flash.text.TextFormat</code> font formatting
	 * to be used by the text editor when the <code>currentState</code>
	 * property of the <code>stateContext</code> matches the specified state
	 * value.
	 *
	 * <p>If an <code>TextFormat</code> is not defined for a specific
	 * state, the value of the <code>textFormat</code> property will be
	 * used instead.</p>
	 *
	 * <p>If the <code>disabledTextFormat</code> property is not
	 * <code>null</code> and the <code>isEnabled</code> property is
	 * <code>false</code>, all other text formats will be ignored.</p>
	 *
	 * @see #stateContext
	 * @see #textFormat
	 */
	public function setTextFormatForState(state:String, textFormat:openfl.text.TextFormat):Void
	{
		if (textFormat != null)
		{
			if (this._textFormatForState == null)
			{
				this._textFormatForState = new Map<String, openfl.text.TextFormat>();
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
	 * @private
	 */
	override function initialize():Void 
	{
		this.textField = new TextField();
		//let's ensure that the text field can only get keyboard focus
		//through code. no need to set mouseEnabled to false since the text
		//field won't be visible until it needs to be interactive, so it
		//can't receive focus with mouse/touch anyway.
		this.textField.tabEnabled = false;
		this.textField.visible = false;
		this.textField.needsSoftKeyboard = true;
		this.textField.addEventListener(flash.events.Event.CHANGE, textField_changeHandler);
		this.textField.addEventListener(FocusEvent.FOCUS_IN, textField_focusInHandler);
		this.textField.addEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
		this.textField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, textField_mouseFocusChangeHandler);
		this.textField.addEventListener(KeyboardEvent.KEY_DOWN, textField_keyDownHandler);
		#if flash
		this.textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, textField_softKeyboardActivatingHandler);
		this.textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, textField_softKeyboardActivateHandler);
		this.textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, textField_softKeyboardDeactivateHandler);
		#end
		//when adding more events here, don't forget to remove them when the
		//text editor is disposed
		
		this.measureTextField = new TextField();
		this.measureTextField.autoSize = TextFieldAutoSize.LEFT;
		this.measureTextField.selectable = false;
		this.measureTextField.tabEnabled = false;
		this.measureTextField.mouseWheelEnabled = false;
		this.measureTextField.mouseEnabled = false;
	}
	
	/**
	 * @private
	 */
	override function draw():Void 
	{
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		
		this.commit();
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layout(sizeInvalid);
	}
	
	/**
	 * @private
	 */
	private function commit():Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		
		if (dataInvalid || stylesInvalid || stateInvalid)
		{
			this.refreshTextFormat();
			this.commitStylesAndData(this.textField);
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
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		var point:Point = Pool.getPoint();
		this.measure(point);
		var result:Bool = this.saveMeasurements(point.x, point.y, point.x, point.y);
		Pool.putPoint(point);
		return result;
	}
	
	/**
	 * @private
	 */
	private function measure(result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		
		if (!needsWidth && !needsHeight)
		{
			result.x = this._explicitWidth;
			result.y = this._explicitHeight;
			return result;
		}
		
		this.commitStylesAndData(this.measureTextField);
		
		var gutterDimensionsOffset:Float = 4;
		if (this._useGutter || this._border)
		{
			gutterDimensionsOffset = 0;
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			this.measureTextField.wordWrap = false;
			newWidth = this.measureTextField.width - gutterDimensionsOffset;
			if (newWidth < this._explicitMinWidth)
			{
				newWidth = this._explicitMinWidth;
			}
			else if (newWidth > this._explicitMaxWidth)
			{
				newWidth = this._explicitMaxWidth;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			this.measureTextField.wordWrap = this._wordWrap;
			this.measureTextField.width = newWidth + gutterDimensionsOffset;
			newHeight = this.measureTextField.height - gutterDimensionsOffset;
			if (this._useGutter || this._border)
			{
				newHeight += 4;
			}
			if (newHeight < this._explicitMinHeight)
			{
				newHeight = this._explicitMinHeight;
			}
			else if (newHeight > this._explicitMaxHeight)
			{
				newHeight = this._explicitMaxHeight;
			}
		}
		
		result.x = newWidth;
		result.y = newHeight;
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function commitStylesAndData(textField:TextField):Void
	{
		textField.antiAliasType = this._antiAliasType;
		textField.background = this._background;
		textField.backgroundColor = this._backgroundColor;
		textField.border = this._border;
		textField.borderColor = this._borderColor;
		textField.gridFitType = this._gridFitType;
		textField.sharpness = this._sharpness;
		#if flash
		// TODO : flash extern TextField misses thickness property
		//textField.thickness = this._thickness;
		#end
		textField.maxChars = this._maxChars;
		textField.restrict = this._restrict;
		#if flash
		textField.alwaysShowSelection = this._alwaysShowSelection;
		#end
		textField.displayAsPassword = this._displayAsPassword;
		textField.wordWrap = this._wordWrap;
		textField.multiline = this._multiline;
		#if air
		//The softKeyboard property is not available in Flash Player.
		//It's only available in AIR.
		//if ("softKeyboard" in textField)
		//{
			//textField["softKeyboard"] = this._softKeyboard;
		//}
		// TODO : missing softKeyboard property in flash externs
		//textField.softKeyboard = this._softKeyboard;
		#end
		if (!this._embedFonts &&
			this._currentTextFormat == this._fontStylesTextFormat)
		{
			//when font styles are passed in from the parent component, we
			//automatically determine if the TextField should use embedded
			//fonts, unless embedFonts is explicitly true
			textField.embedFonts = SystemUtil.isEmbeddedFont(
				this._currentTextFormat.font, this._currentTextFormat.bold,
				this._currentTextFormat.italic, FontType.EMBEDDED);
		}
		else
		{
			textField.embedFonts = this._embedFonts;
		}
		textField.type = this._isEditable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		textField.selectable = this._isEnabled && (this._isEditable || this._isSelectable);
		
		var isFormatDifferent:Bool = false;
		if (textField == this.textField)
		{
			//for some reason, textField.defaultTextFormat always fails
			//comparison against currentTextFormat. if we save to a member
			//variable and compare against that instead, it works.
			//I guess text field creates a different TextFormat object.
			if (this._currentTextFormat == this._fontStylesTextFormat)
			{
				isFormatDifferent = this._previousStarlingTextFormat != this._currentStarlingTextFormat;
			}
			else
			{
				isFormatDifferent = this._previousTextFormat != this._currentTextFormat;
			}
			this._previousStarlingTextFormat = this._currentStarlingTextFormat;
			this._previousTextFormat = this._currentTextFormat;
		}
		else
		{
			//for measurement
			isFormatDifferent = true;
		}
		textField.defaultTextFormat = this._currentTextFormat;
		
		if (this._isHTML)
		{
			if (isFormatDifferent || textField.htmlText != this._text)
			{
				if (textField == this.textField && this._pendingSelectionBeginIndex < 0)
				{
					//if the TextFormat has changed from the last commit,
					//the selection range may be lost when we set the text
					//so we need to save it to restore later.
					this._pendingSelectionBeginIndex = this.textField.selectionBeginIndex;
					this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
				}
				//the TextField's text should be updated after a TextFormat
				//change because otherwise it will keep using the old one.
				textField.htmlText = this._text;
			}
		}
		else
		{
			if (isFormatDifferent || textField.text != this._text)
			{
				if (textField == this.textField && this._pendingSelectionBeginIndex < 0)
				{
					this._pendingSelectionBeginIndex = this.textField.selectionBeginIndex;
					this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
				}
				textField.text = this._text;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTextFormat():Void
	{
		var textFormat:openfl.text.TextFormat = null;
		if (this._stateContext != null)
		{
			if (this._textFormatForState != null)
			{
				var currentState:String = this._stateContext.currentState;
				if (this._textFormatForState.exists(currentState))
				{
					textFormat = this._textFormatForState[currentState];
				}
			}
			if (textFormat == null && this._disabledTextFormat != null &&
				Std.isOfType(this._stateContext, IFeathersControl) && !cast(this._stateContext, IFeathersControl).isEnabled)
			{
				textFormat = this._disabledTextFormat;
			}
		}
		else //no state context
		{
			//we can still check if the text renderer is disabled to see if
			//we should use disabledTextFormat
			if (!this._isEnabled && this._disabledTextFormat != null)
			{
				textFormat = this._disabledTextFormat;
			}
		}
		if (textFormat == null)
		{
			textFormat = this._textFormat;
		}
		//flash.text.TextFormat is considered more advanced, so it gets
		//precedence over starling.text.TextFormat font styles
		if (textFormat == null)
		{
			textFormat = this.getTextFormatFromFontStyles();
		}
		this._currentTextFormat = textFormat;
	}
	
	/**
	 * @private
	 */
	private function getTextFormatFromFontStyles():flash.text.TextFormat
	{
		if (this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES) ||
			this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE))
		{
			if (this._fontStyles != null)
			{
				this._currentStarlingTextFormat = this._fontStyles.getTextFormatForTarget(this);
			}
			else
			{
				this._currentStarlingTextFormat = null;
			}
			if (this._currentStarlingTextFormat != null)
			{
				this._fontStylesTextFormat = this._currentStarlingTextFormat.toNativeFormat(this._fontStylesTextFormat);
			}
			else if (this._fontStylesTextFormat == null)
			{
				//fallback to a default so that something is displayed
				this._fontStylesTextFormat = new flash.text.TextFormat();
			}
		}
		return this._fontStylesTextFormat;
	}
	
	/**
	 * @private
	 */
	private function getVerticalAlignment():String
	{
		var verticalAlign:String = null;
		if (this._fontStyles != null)
		{
			var format:starling.text.TextFormat = this._fontStyles.getTextFormatForTarget(this);
			if (format != null)
			{
				verticalAlign = format.verticalAlign;
			}
		}
		if (verticalAlign == null)
		{
			verticalAlign = Align.TOP;
		}
		return verticalAlign;
	}
	
	/**
	 * @private
	 */
	private function getVerticalAlignmentOffsetY():Float
	{
		var verticalAlign:String = this.getVerticalAlignment();
		var textFieldTextHeight:Float = this.textField.textHeight;
		if (textFieldTextHeight > this.actualHeight)
		{
			return 0;
		}
		if (verticalAlign == Align.BOTTOM)
		{
			return this.actualHeight - textFieldTextHeight;
		}
		else if (verticalAlign == Align.CENTER)
		{
			return (this.actualHeight - textFieldTextHeight) / 2;
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	private function layout(sizeInvalid:Bool):Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		
		if (sizeInvalid)
		{
			this.refreshSnapshotParameters();
			this.refreshTextFieldSize();
			this.transformTextField();
			this.positionSnapshot();
		}
		
		this.checkIfNewSnapshotIsNeeded();
		
		if (!this._textFieldHasFocus && (sizeInvalid || stylesInvalid || dataInvalid || stateInvalid || this._needsNewTexture))
		{
			//we're going to update the texture in render() because
			//there's a chance that it will be updated more than once per
			//frame if we do it here.
			this._needsTextureUpdate = true;
			this.setRequiresRedraw();
		}
		this.doPendingActions();
	}
	
	/**
	 * @private
	 */
	private function getSelectionIndexAtPoint(pointX:Float, pointY:Float):Int
	{
		return this.textField.getCharIndexAtPoint(pointX, pointY);
	}
	
	/**
	 * @private
	 */
	private function refreshTextFieldSize():Void
	{
		var gutterDimensionsOffset:Float = 4;
		if (this._useGutter || this._border)
		{
			gutterDimensionsOffset = 0;
		}
		this.textField.width = this.actualWidth + gutterDimensionsOffset;
		this.textField.height = this.actualHeight + gutterDimensionsOffset;
	}
	
	/**
	 * @private
	 */
	private function refreshSnapshotParameters():Void
	{
		this._textFieldOffsetX = 0;
		this._textFieldOffsetY = 0;
		this._textFieldSnapshotClipRect.x = 0;
		this._textFieldSnapshotClipRect.y = 0;
		
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var scaleFactor:Float = starling.contentScaleFactor;
		var clipWidth:Float = this.actualWidth * scaleFactor;
		var matrix:Matrix = null;
		if (this._updateSnapshotOnScaleChange)
		{
			matrix = Pool.getMatrix();
			this.getTransformationMatrix(this.stage, matrix);
			clipWidth *= GeomUtils.matrixToScaleX(matrix);
		}
		if (clipWidth < 0)
		{
			clipWidth = 0;
		}
		var clipHeight:Float = this.actualHeight * scaleFactor;
		if (this._updateSnapshotOnScaleChange)
		{
			clipHeight *= GeomUtils.matrixToScaleY(matrix);
			Pool.putMatrix(matrix);
		}
		if (clipHeight < 0)
		{
			clipHeight = 0;
		}
		this._textFieldSnapshotClipRect.width = clipWidth;
		this._textFieldSnapshotClipRect.height = clipHeight;
	}
	
	/**
	 * @private
	 */
	private function transformTextField():Void
	{
		//there used to be some code here that returned immediately if the
		//TextField wasn't visible. some mobile devices displayed the text
		//at the wrong scale if the TextField weren't transformed before
		//being made visible, so I had to remove it. I moved the visible
		//check into render(), since it can still benefit from the
		//optimization there. see issue #1104.
		
		var matrix:Matrix = Pool.getMatrix();
		var point:Point = Pool.getPoint();
		this.getTransformationMatrix(this.stage, matrix);
		var globalScaleX:Float = GeomUtils.matrixToScaleX(matrix);
		var globalScaleY:Float = GeomUtils.matrixToScaleY(matrix);
		var smallerGlobalScale:Float = globalScaleX;
		if (globalScaleY < smallerGlobalScale)
		{
			smallerGlobalScale = globalScaleY;
		}
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var nativeScaleFactor:Float = 1;
		if (starling.supportHighResolutions)
		{
			nativeScaleFactor = starling.nativeStage.contentsScaleFactor;
		}
		var scaleFactor:Float = starling.contentScaleFactor / nativeScaleFactor;
		var gutterPositionOffset:Float = 0;
		if (!this._useGutter || this._border)
		{
			gutterPositionOffset = 2 * smallerGlobalScale;
		}
		var verticalAlignOffsetY:Float = this.getVerticalAlignmentOffsetY();
		if (this.is3D)
		{
			var matrix3D:Matrix3D = Pool.getMatrix3D();
			var point3D:Vector3D = Pool.getPoint3D();
			this.getTransformationMatrix3D(this.stage, matrix3D);
			MatrixUtil.transformCoords3D(matrix3D, -gutterPositionOffset, -gutterPositionOffset + verticalAlignOffsetY, 0, point3D);
			point.setTo(point3D.x, point3D.y);
			Pool.putPoint3D(point3D);
			Pool.putMatrix3D(matrix3D);
		}
		else
		{
			MatrixUtil.transformCoords(matrix, -gutterPositionOffset, -gutterPositionOffset + verticalAlignOffsetY, point);
		}
		var starlingViewPort:Rectangle = starling.viewPort;
		this.textField.x = Math.fround(starlingViewPort.x + (point.x * scaleFactor));
		this.textField.y = Math.fround(starlingViewPort.y + (point.y * scaleFactor));
		this.textField.rotation = GeomUtils.matrixToRotation(matrix) * 180 / Math.PI;
		this.textField.scaleX = GeomUtils.matrixToScaleX(matrix) * scaleFactor;
		this.textField.scaleY = GeomUtils.matrixToScaleY(matrix) * scaleFactor;
		
		Pool.putPoint(point);
		Pool.putMatrix(matrix);
	}
	
	/**
	 * @private
	 */
	private function positionSnapshot():Void
	{
		if (this.textSnapshot == null)
		{
			return;
		}
		var matrix:Matrix = Pool.getMatrix();
		this.getTransformationMatrix(this.stage, matrix);
		this.textSnapshot.x = Math.fround(matrix.tx) - matrix.tx;
		this.textSnapshot.y = Math.fround(matrix.ty) - matrix.ty;
		this.textSnapshot.y += this.getVerticalAlignmentOffsetY();
		Pool.putMatrix(matrix);
	}
	
	/**
	 * @private
	 */
	private function checkIfNewSnapshotIsNeeded():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var canUseRectangleTexture:Bool = starling.profile != Context3DProfile.BASELINE_CONSTRAINED;
		if (canUseRectangleTexture)
		{
			this._snapshotWidth = Std.int(this._textFieldSnapshotClipRect.width);
			this._snapshotHeight = Std.int(this._textFieldSnapshotClipRect.height);
		}
		else
		{
			this._snapshotWidth = MathUtil.getNextPowerOfTwo(this._textFieldSnapshotClipRect.width);
			this._snapshotHeight = MathUtil.getNextPowerOfTwo(this._textFieldSnapshotClipRect.height);
		}
		var textureRoot:ConcreteTexture = this.textSnapshot != null ? this.textSnapshot.texture.root : null;
		this._needsNewTexture = this._needsNewTexture || this.textSnapshot == null ||
			(textureRoot != null && (textureRoot.scale != starling.contentScaleFactor ||
			this._snapshotWidth != textureRoot.nativeWidth || this._snapshotHeight != textureRoot.nativeHeight));
	}
	
	/**
	 * @private
	 */
	private function doPendingActions():Void
	{
		if (this._isWaitingToSetFocus)
		{
			this._isWaitingToSetFocus = false;
			this.setFocus();
		}
		
		if (this._pendingSelectionBeginIndex >= 0)
		{
			var startIndex:Int = this._pendingSelectionBeginIndex;
			var endIndex:Int = this._pendingSelectionEndIndex;
			this._pendingSelectionBeginIndex = -1;
			this._pendingSelectionEndIndex = -1;
			this.selectRange(startIndex, endIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function texture_onRestore(texture:ConcreteTexture):Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		if (this.textSnapshot != null && this.textSnapshot.texture != null &&
			this.textSnapshot.texture.scale != starling.contentScaleFactor)
		{
			//if we've changed between scale factors, we need to recreate
			//the texture to match the new scale factor.
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this.refreshSnapshot();
		}
	}
	
	/**
	 * @private
	 */
	private function refreshSnapshot():Void
	{
		if (this._snapshotWidth <= 0 || this._snapshotHeight <= 0)
		{
			return;
		}
		var gutterPositionOffset:Float = 2;
		if (this._useGutter || this._border)
		{
			gutterPositionOffset = 0;
		}
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var scaleFactor:Float = starling.contentScaleFactor;
		var matrix:Matrix = Pool.getMatrix();
		var globalScaleX:Float = 0;
		var globalScaleY:Float = 0;
		if (this._updateSnapshotOnScaleChange)
		{
			this.getTransformationMatrix(this.stage, matrix);
			globalScaleX = GeomUtils.matrixToScaleX(matrix);
			globalScaleY = GeomUtils.matrixToScaleY(matrix);
		}
		matrix.identity();
		matrix.translate(this._textFieldOffsetX - gutterPositionOffset, this._textFieldOffsetY - gutterPositionOffset);
		matrix.scale(scaleFactor, scaleFactor);
		if (this._updateSnapshotOnScaleChange)
		{
			matrix.scale(globalScaleX, globalScaleY);
		}
		var bitmapData:BitmapData = new BitmapData(this._snapshotWidth, this._snapshotHeight, true, 0x00ff00ff);
		#if !flash
		var wasVisible:Bool = this.textField.visible;
		textField.visible = true;
		#end
		bitmapData.draw(this.textField, matrix, null, null, this._textFieldSnapshotClipRect);
		#if !flash
		textField.visible = wasVisible;
		#end
		Pool.putMatrix(matrix);
		var newTexture:Texture = null;
		if (this.textSnapshot == null || this._needsNewTexture)
		{
			//skip Texture.fromBitmapData() because we don't want
			//it to create an onRestore function that will be
			//immediately discarded for garbage collection.
			newTexture = Texture.empty(bitmapData.width / scaleFactor, bitmapData.height / scaleFactor,
				true, false, false, scaleFactor);
			newTexture.root.uploadBitmapData(bitmapData);
			newTexture.root.onRestore = texture_onRestore;
		}
		if (this.textSnapshot == null)
		{
			this.textSnapshot = new Image(newTexture);
			this.textSnapshot.pixelSnapping = true;
			this.addChild(this.textSnapshot);
		}
		else
		{
			if (this._needsNewTexture)
			{
				this.textSnapshot.texture.dispose();
				this.textSnapshot.texture = newTexture;
				this.textSnapshot.readjustSize();
			}
			else
			{
				//this is faster, if we haven't resized the bitmapdata
				var existingTexture:Texture = this.textSnapshot.texture;
				existingTexture.root.uploadBitmapData(bitmapData);
				//however, the image won't be notified that its
				//texture has changed, so we need to do it manually
				this.textSnapshot.setRequiresRedraw();
			}
		}
		if (this._updateSnapshotOnScaleChange)
		{
			this.textSnapshot.scaleX = 1 / globalScaleX;
			this.textSnapshot.scaleY = 1 / globalScaleY;
			this._lastGlobalScaleX = globalScaleX;
			this._lastGlobalScaleY = globalScaleY;
		}
		this.textSnapshot.alpha = this._text.length != 0 ? 1 : 0;
		bitmapData.dispose();
		this._needsNewTexture = false;
	}
	
	/**
	 * @private
	 */
	private function textEditor_addedToStageHandler(event:Event):Void
	{
		if (this.textField.parent == null)
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			//the text field needs to be on the native stage to measure properly
			starling.nativeStage.addChild(this.textField);
		}
	}
	
	/**
	 * @private
	 */
	private function textEditor_removedFromStageHandler(event:Event):Void
	{
		if (this.textField.parent != null)
		{
			//remove this from the stage, if needed
			//it will be added back next time we receive focus
			this.textField.parent.removeChild(this.textField);
		}
	}
	
	/**
	 * @private
	 */
	private function hasFocus_enterFrameHandler(event:Event):Void
	{
		if (this.textSnapshot != null)
		{
			this.textSnapshot.visible = !this._textFieldHasFocus;
		}
		this.textField.visible = this._textFieldHasFocus;
		
		if (this._textFieldHasFocus)
		{
			var target:DisplayObject = this;
			do
			{
				if (!target.visible)
				{
					this.clearFocus();
					break;
				}
				target = target.parent;
			}
			while(target != null);
		}
		else
		{
			this.removeEventListener(Event.ENTER_FRAME, hasFocus_enterFrameHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshSnapshot_enterFrameHandler(event:Event):Void
	{
		this.removeEventListener(Event.ENTER_FRAME, refreshSnapshot_enterFrameHandler);
		this.refreshSnapshot();
	}
	
	/**
	 * @private
	 */
	private function stage_touchHandler(event:TouchEvent):Void
	{
		if (this._maintainTouchFocus || FocusManager.isEnabledForStage(this.stage))
		{
			return;
		}
		var touch:Touch = event.getTouch(this.stage, TouchPhase.BEGAN);
		if (touch == null) //we only care about began touches
		{
			return;
		}
		var point:Point = Pool.getPoint();
		touch.getLocation(this.stage, point);
		var isInBounds:Bool = this.contains(this.stage.hitTest(point));
		Pool.putPoint(point);
		if (isInBounds) //if the touch is in the text editor, it's all good
		{
			return;
		}
		//if the touch begins anywhere else, it's a focus out!
		this.clearFocus();
	}
	
	/**
	 * @private
	 */
	private function textField_changeHandler(event:flash.events.Event):Void
	{
		if (this._isHTML)
		{
			this.text = this.textField.htmlText;
		}
		else
		{
			this.text = this.textField.text;
		}
	}
	
	/**
	 * @private
	 */
	private function textField_focusInHandler(event:FocusEvent):Void
	{
		this._textFieldHasFocus = true;
		this.stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		this.addEventListener(Event.ENTER_FRAME, hasFocus_enterFrameHandler);
		this.dispatchEventWith(FeathersEventType.FOCUS_IN);
	}
	
	/**
	 * @private
	 */
	private function textField_focusOutHandler(event:FocusEvent):Void
	{
		this._textFieldHasFocus = false;
		this.stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		
		if (this._resetScrollOnFocusOut)
		{
			this.textField.scrollH = this.textField.scrollV = 0;
		}
		
		//the text may have changed, so we invalidate the data flag
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(FeathersEventType.FOCUS_OUT);
	}
	
	/**
	 * @private
	 */
	private function textField_mouseFocusChangeHandler(event:FocusEvent):Void
	{
		if (!this._maintainTouchFocus)
		{
			return;
		}
		event.preventDefault();
	}
	
	/**
	 * @private
	 */
	private function textField_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.keyCode == Keyboard.ENTER)
		{
			this.dispatchEventWith(FeathersEventType.ENTER);
		}
		else if (!FocusManager.isEnabledForStage(this.stage) && event.keyCode == Keyboard.TAB)
		{
			this.clearFocus();
		}
	}
	
	#if flash
	/**
	 * @private
	 */
	private function textField_softKeyboardActivateHandler(event:SoftKeyboardEvent):Void
	{
		this.dispatchEventWith(FeathersEventType.SOFT_KEYBOARD_ACTIVATE, true);
	}
	#end
	
	#if flash
	/**
	 * @private
	 */
	private function textField_softKeyboardActivatingHandler(event:SoftKeyboardEvent):Void
	{
		this.dispatchEventWith(FeathersEventType.SOFT_KEYBOARD_ACTIVATING, true);
	}
	#end
	
	#if flash
	/**
	 * @private
	 */
	private function textField_softKeyboardDeactivateHandler(event:SoftKeyboardEvent):Void
	{
		this.dispatchEventWith(FeathersEventType.SOFT_KEYBOARD_DEACTIVATE, true);
	}
	#end
	
	/**
	 * @private
	 */
	override function fontStylesSet_changeHandler(event:Event):Void
	{
		this._previousStarlingTextFormat = null;
		super.fontStylesSet_changeHandler(event);
	}

}