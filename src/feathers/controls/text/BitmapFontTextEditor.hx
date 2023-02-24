
/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.text;
import feathers.core.FocusManager;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import feathers.utils.text.TextInputNavigation;
import feathers.utils.text.TextInputRestrict;
import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.display.Sprite;
import openfl.events.TextEvent;
import openfl.geom.Point;
import openfl.text.TextFormatAlign;
import openfl.ui.Keyboard;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.rendering.Painter;
import starling.text.BitmapChar;
import starling.text.BitmapFont;
import starling.utils.Pool;

/**
 * Text that may be edited at runtime by the user with the
 * <code>TextInput</code> component, rendered with
 * <a href="http://wiki.starling-framework.org/manual/displaying_text#bitmap_fonts" target="_top">bitmap fonts</a>.
 *
 * <p>The following example shows how to use
 * <code>BitmapFontTextEditor</code> with a <code>TextInput</code>:</p>
 *
 * <listing version="3.0">
 * var input:TextInput = new TextInput();
 * input.textEditorFactory = function():ITextEditor
 * {
 *     return new BitmapFontTextEditor();
 * };
 * this.addChild( input );</listing>
 *
 * <p><strong>Warning:</strong> This text editor is intended for use in
 * desktop applications only, and it does not provide support for software
 * keyboards on mobile devices.</p>
 *
 * @see feathers.controls.TextInput
 * @see ../../../../help/text-editors.html Introduction to Feathers text editors
 * @see http://wiki.starling-framework.org/manual/displaying_text#bitmap_fonts Starling Wiki: Displaying Text with Bitmap Fonts
 *
 * @productversion Feathers 2.0.0
 */
class BitmapFontTextEditor extends BitmapFontTextRenderer 
{
	/**
	 * @private
	 */
	private static inline var LINE_FEED:String = "\n";

	/**
	 * @private
	 */
	private static inline var CARRIAGE_RETURN:String = "\r";

	/**
	 * The default <code>IStyleProvider</code> for all <code>BitmapFontTextEditor</code>
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
		this._text = "";
		this.isQuickHitAreaEnabled = true;
		this.truncateToFit = false;
		this.addEventListener(TouchEvent.TOUCH, textEditor_touchHandler);
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return globalStyleProvider;
	}
	
	/**
	 * The skin that indicates the currently selected range of text.
	 */
	public var selectionSkin(get, set):DisplayObject;
	private var _selectionSkin:DisplayObject;
	private function get_selectionSkin():DisplayObject { return this._selectionSkin; }
	private function set_selectionSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._selectionSkin == value)
		{
			return value;
		}
		if (this._selectionSkin && this._selectionSkin.parent == this)
		{
			this._selectionSkin.removeFromParent();
		}
		this._selectionSkin = value;
		if (this._selectionSkin)
		{
			this._selectionSkin.visible = false;
			this.addChildAt(this._selectionSkin, 0);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._selectionSkin;
	}
	
	/**
	 * @private
	 */
	private var _cursorDelay:Float = 0.53;

	/**
	 * @private
	 */
	private var _cursorDelayID:Int = MathUtils.INT_MAX;
	
	/**
	 * The skin that indicates the current position where text may be
	 * entered.
	 */
	public var cursorSkin(get, set):DisplayObject;
	private var _cursorSkin:DisplayObject;
	private function get_cursorSkin():DisplayObject { this._cursorSkin; }
	private function set_cursorSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._cursorSkin == value)
		{
			return value;
		}
		if (this._cursorSkin != null && this._cursorSkin.parent == this)
		{
			this._cursorSkin.removeFromParent();
		}
		this._cursorSkin = value;
		if (this._cursorSkin != null)
		{
			this._cursorSkin.visible = false;
			this.addChild(this._cursorSkin);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._cursorSkin;
	}
	
	/**
	 * @private
	 */
	private var _unmaskedText:String;
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#displayAsPassword
	 *
	 * @see feathers.controls.TextInput#displayAsPassword
	 * @see #passwordCharCode
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
		if (this._displayAsPassword)
		{
			this._unmaskedText = this._text;
			this.refreshMaskedText();
		}
		else
		{
			this._text = this._unmaskedText;
			this._unmaskedText = null;
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._displayAsPassword;
	}
	
	/**
	 * The character code of the character used to display a password.
	 *
	 * <p>In the following example, the substitute character for passwords
	 * is set to a bullet:</p>
	 *
	 * <listing version="3.0">
	 * textEditor.displayAsPassword = true;
	 * textEditor.passwordCharCode = "•".charCodeAt(0);</listing>
	 *
	 * @default 42 (asterisk)
	 *
	 * @see #displayAsPassword
	 */
	public var passwordCharCode(get, set):Int;
	private var _passwordCharCode:Int = 42; // asterisk
	private function get_passwordCharCode():Int { return this._passwordCharCode; }
	private function set_passwordCharCode(value:Int):Int
	{
		if (this._passwordCharCode == value)
		{
			return value;
		}
		this._passwordCharCode = value;
		if (this._displayAsPassword)
		{
			this.refreshMaskedText();
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._passwordCharCode;
	}
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#isEditable
	 *
	 * @see feathers.controls.TextInput#isEditable
	 */
	public var isEditable(get, set):Bool;
	private var _isEditable:Bool = true;
	private function get_isEditable():Bool { return this._isEditable; }
	private function set_isEditable(value:Bool):Bool
	{
		if (this._isEditable == value)
		{
			return value;
		}
		this._isEditable = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
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
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._isSelectable;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default false
	 */
	public var setTouchFocusOnEndedPhase(get, never):Bool;
	private function get_setTouchFocusOnEndedPhase():Bool { return false; }
	
	/**
	 * @private
	 */
	override function get_text():String 
	{
		if (this._displayAsPassword)
		{
			return this._unmaskedText;
		}
		return this._text;
	}
	
	override function set_text(value:String):String 
	{
		if (value == null)
		{
			//don't allow null or undefined
			value = "";
		}
		var currentValue:String = this._text;
		if (this._displayAsPassword)
		{
			currentValue = this._unmaskedText;
		}
		if (currentValue == value)
		{
			return;
		}
		if (this._displayAsPassword)
		{
			this._unmaskedText = value;
			this.refreshMaskedText();
		}
		else
		{
			this._text = value;
		}
		this.invalidate(INVALIDATION_FLAG_DATA);
		var textLength:Int = this._text.length;
		//we need to account for the possibility that the text is in the
		//middle of being selected when it changes
		if (this._selectionAnchorIndex > textLength)
		{
			this._selectionAnchorIndex = textLength;
		}
		//then, we need to make sure the selected range is still valid
		if (this._selectionBeginIndex > textLength)
		{
			this.selectRange(textLength, textLength);
		}
		else if (this._selectionEndIndex > textLength)
		{
			this.selectRange(this._selectionBeginIndex, textLength);
		}
		this.dispatchEventWith(starling.events.Event.CHANGE);
		return value;
	}
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#maxChars
	 *
	 * @see feathers.controls.TextInput#maxChars
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
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return this._maxChars;
	}
	
	/**
	 * <p>This property is managed by the <code>TextInput</code>.</p>
	 *
	 * @copy feathers.controls.TextInput#restrict
	 *
	 * @see feathers.controls.TextInput#restrict
	 */
	public var restrict(get, set):TextInputRestrict;
	@:native("_restrict1")
	private var _restrict:TextInputRestrict;
	private function get_restrict():String
	{
		if (this._restrict == null)
		{
			return null;
		}
		return this._restrict.restrict;
	}
	
	private function set_restrict(value:String):String
	{
		if (this._restrict != null && this._restrict.restrict == value)
		{
			return value;
		}
		if (this._restrict == null && value == null)
		{
			return value;
		}
		if (value == null)
		{
			this._restrict = null;
		}
		else
		{
			if (this._restrict != null)
			{
				this._restrict.restrict = value;
			}
			else
			{
				this._restrict = new TextInputRestrict(value);
			}
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
		return value;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @see #selectionEndIndex
	 */
	public var selectionBeginIndex(get, never):Int;
	private var _selectionBeginIndex:Int = 0;
	private function get_selectionBeginIndex():Int { return this._selectionBeginIndex; }
	
	/**
	 * @inheritDoc
	 *
	 * @see #selectionBeginIndex
	 */
	public var selectionEndIndex(get, never):Int;
	private var _selectionEndIndex:Int = 0;
	private function get_selectionEndIndex():Int { return this._selectionEndIndex; }
	
	/**
	 * @private
	 */
	private var _selectionAnchorIndex:Int = 0;

	/**
	 * @private
	 */
	private var _scrollX:Float = 0;

	/**
	 * @private
	 */
	private var touchPointID:Int = -1;
	
	/**
	 * @copy feathers.core.INativeFocusOwner#nativeFocus
	 */
	public var nativeFocus(get, never):Sprite;
	private var _nativeFocus:Sprite;
	private function get_nativeFocus():Sprite { return this._nativeFocus; }
	
	/**
	 * @private
	 */
	private var _isWaitingToSetFocus:Bool = false;
	
	/**
	 * @inheritDoc
	 */
	public function setFocus(position:Point = null):Void
	{
		if (this._hasFocus && position == null)
		{
			//we already have focus, and there isn't a touch position, we
			//can ignore this because nothing would change
			return;
		}
		if (this._nativeFocus != null)
		{
			if (this._nativeFocus.parent == null)
			{
				var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
				starling.nativeStage.addChild(this._nativeFocus);
			}
			var newIndex:Int = -1;
			if (position != null)
			{
				newIndex = this.getSelectionIndexAtPoint(position.x, position.y);
			}
			if (newIndex >= 0)
			{
				this.selectRange(newIndex, newIndex);
			}
			this.focusIn();
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
		if (!this._hasFocus)
		{
			return;
		}
		this._hasFocus = false;
		this._cursorSkin.visible = false;
		this._selectionSkin.visible = false;
		this.refreshCursorBlink();
		this.stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		this.removeEventListener(starling.events.Event.ENTER_FRAME, hasFocus_enterFrameHandler);
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var nativeStage:Stage = starling.nativeStage;
		if (nativeStage.focus == this._nativeFocus)
		{
			//only clear the native focus when our native target has focus
			//because otherwise another component may lose focus.
			
			//for consistency with StageTextTextEditor and
			//TextFieldTextEditor, we set the native stage's focus to null
			//here instead of setting it to the native stage due to issues
			//with those text editors on Android.
			nativeStage.focus = null;
		}
		this.dispatchEventWith(FeathersEventType.FOCUS_OUT);
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
		if (endIndex < beginIndex)
		{
			var temp:Int = endIndex;
			endIndex = beginIndex;
			beginIndex = temp;
		}
		this._selectionBeginIndex = beginIndex;
		this._selectionEndIndex = endIndex;
		if (beginIndex == endIndex)
		{
			this._selectionAnchorIndex = beginIndex;
			if (beginIndex < 0)
			{
				this._cursorSkin.visible = false;
			}
			else
			{
				//cursor skin is not shown if isSelectable == true and
				//isEditable is false
				this._cursorSkin.visible = this._hasFocus && this._isEditable;
			}
			this._selectionSkin.visible = false;
		}
		else
		{
			this._cursorSkin.visible = false;
			this._selectionSkin.visible = true;
		}
		this.refreshCursorBlink();
		this.invalidate(INVALIDATION_FLAG_SELECTED);
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._nativeFocus != null && this._nativeFocus.parent != null)
		{
			this._nativeFocus.parent.removeChild(this._nativeFocus);
		}
		this._nativeFocus = null;
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override public function render(painter:Painter):Void
	{
		var oldBatchX:Float = this._batchX;
		var oldCursorX:Float = this._cursorSkin.x;
		this._batchX -= this._scrollX;
		this._cursorSkin.x -= this._scrollX;
		super.render(painter);
		this._batchX = oldBatchX;
		this._cursorSkin.x = oldCursorX;
	}
	
	/**
	 * @private
	 */
	override private function initialize():Void
	{
		if (this._nativeFocus == null)
		{
			this._nativeFocus = new Sprite();
			//let's ensure that this can only get focus through code
			this._nativeFocus.tabEnabled = false;
			this._nativeFocus.tabChildren = false;
			this._nativeFocus.mouseEnabled = false;
			this._nativeFocus.mouseChildren = false;
			//adds support for mobile
			this._nativeFocus.needsSoftKeyboard = true;
		}
		this._nativeFocus.addEventListener(flash.events.Event.CUT, nativeFocus_cutHandler, false, 0, true);
		this._nativeFocus.addEventListener(flash.events.Event.COPY, nativeFocus_copyHandler, false, 0, true);
		this._nativeFocus.addEventListener(flash.events.Event.PASTE, nativeFocus_pasteHandler, false, 0, true);
		this._nativeFocus.addEventListener(flash.events.Event.SELECT_ALL, nativeFocus_selectAllHandler, false, 0, true);
		this._nativeFocus.addEventListener(TextEvent.TEXT_INPUT, nativeFocus_textInputHandler, false, 0, true);
		if (this._cursorSkin == null)
		{
			this.ignoreNextStyleRestriction();
			this.cursorSkin = new Quad(1, 1, 0x000000);
		}
		if (this._selectionSkin == null)
		{
			this.ignoreNextStyleRestriction();
			this.selectionSkin = new Quad(1, 1, 0x000000);
		}
		super.initialize();
	}
	
	/**
	 * @private
	 */
	override private function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_DATA);
		var selectionInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_SELECTED);
		
		super.draw();
		
		if (dataInvalid || selectionInvalid)
		{
			this.positionCursorAtCharIndex(this.getCursorIndexFromSelectionRange());
			this.positionSelectionBackground();
		}
		
		var mask:Quad = cast this.mask;
		if (mask != null)
		{
			mask.x = 0;
			mask.y = 0;
			mask.width = this.actualWidth;
			mask.height = this.actualHeight;
		}
		else
		{
			mask = new Quad(1, 1, 0xff00ff);
			//the initial dimensions cannot be 0 or there's a runtime error,
			//and these values might be 0
			mask.width = this.actualWidth;
			mask.height = this.actualHeight;
			this.mask = mask;
		}
	}
	
	/**
	 * @private
	 */
	override private function layoutCharacters(result:MeasureTextResult = null):MeasureTextResult
	{
		result = super.layoutCharacters(result);
		if (this._explicitWidth == this._explicitWidth && //!isNaN
			result.width > this._explicitWidth)
		{
			this._characterBatch.clear();
			var oldTextAlign:String = this._currentTextFormat.align;
			this._currentTextFormat.align = TextFormatAlign.LEFT;
			result = super.layoutCharacters(result);
			this._currentTextFormat.align = oldTextAlign;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	override private function refreshTextFormat():Void
	{
		super.refreshTextFormat();
		if (this._cursorSkin != null)
		{
			var font:BitmapFont = this._currentTextFormat.font;
			var customSize:Float = this._currentTextFormat.size;
			var scale:Float = customSize / font.size;
			if (scale != scale) //isNaN
			{
				scale = 1;
			}
			this._cursorSkin.height = font.lineHeight * scale;
		}
	}
	
	/**
	 * @private
	 */
	private function focusIn():Void
	{
		var showSelection:Bool = (this._isEditable || this._isSelectable) &&
			this._selectionBeginIndex >= 0 &&
			this._selectionBeginIndex != this._selectionEndIndex;
		var showCursor:Bool = this._isEditable &&
			this._selectionBeginIndex >= 0 &&
			this._selectionBeginIndex == this._selectionEndIndex;
		this._cursorSkin.visible = showCursor;
		this._selectionSkin.visible = showSelection;
		this.refreshCursorBlink();
		if (!FocusManager.isEnabledForStage(this.stage))
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			//if there isn't a focus manager, we need to set focus manually
			starling.nativeStage.focus = this._nativeFocus;
		}
		if (this._isEditable)
		{
			this._nativeFocus.requestSoftKeyboard();
		}
		if (this._hasFocus)
		{
			return;
		}
		//we're reusing this variable. since this isn't a display object
		//that the focus manager can see, it's not being used anyway.
		this._hasFocus = true;
		this.stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		this.addEventListener(starling.events.Event.ENTER_FRAME, hasFocus_enterFrameHandler);
		this.dispatchEventWith(FeathersEventType.FOCUS_IN);
	}
	
	/**
	 * @private
	 */
	private function refreshCursorBlink():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		if (this._cursorDelayID == MathUtils.INT_MAX && this._cursorSkin.visible)
		{
			this._cursorSkin.alpha = 1;
			this._cursorDelayID = starling.juggler.delayCall(toggleCursorSkin, this._cursorDelay);
		}
		else if (this._cursorDelayID != MathUtils.INT_MAX && !this._cursorSkin.visible)
		{
			starling.juggler.removeByID(this._cursorDelayID);
			this._cursorDelayID = MathUtils.INT_MAX;
		}
	}
	
	/**
	 * @private
	 */
	private function toggleCursorSkin():Void
	{
		if (this._cursorSkin.alpha > 0)
		{
			this._cursorSkin.alpha = 0;
		}
		else
		{
			this._cursorSkin.alpha = 1;
		}
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		this._cursorDelayID = starling.juggler.delayCall(toggleCursorSkin, this._cursorDelay);
	}
	
	/**
	 * @private
	 */
	private function getSelectionIndexAtPoint(pointX:Float, pointY:Float):Int
	{
		if (this._text == null || pointX <= 0)
		{
			return 0;
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
		var align:String = this._currentTextFormat.align;
		if (align != TextFormatAlign.LEFT)
		{
			var point:Point = Pool.getPoint();
			this.measureTextInternal(point, false);
			var lineWidth:Float = point.x;
			Pool.putPoint(point);
			var hasExplicitWidth:Bool = this._explicitWidth == this._explicitWidth; //!isNaN
			var maxLineWidth:Float = hasExplicitWidth ? this._explicitWidth : this._explicitMaxWidth;
			if (maxLineWidth > lineWidth)
			{
				if (align == TextFormatAlign.RIGHT)
				{
					pointX -= maxLineWidth - lineWidth;
				}
				else //center
				{
					pointX -= (maxLineWidth - lineWidth) / 2;
				}
			}
		}
		var currentX:Float = 0;
		var previousCharID:Float = Math.NaN;
		var charCount:Int = this._text.length;
		for (i in 0...charCount)
		{
			var charID:Int = this._text.charCodeAt(i);
			var charData:BitmapChar = font.getChar(charID);
			if (!charData)
			{
				continue;
			}
			var currentKerning:Float = 0;
			if (isKerningEnabled &&
				previousCharID == previousCharID) //!isNaN
			{
				currentKerning = charData.getKerning(previousCharID) * scale;
			}
			var charWidth:Float = customLetterSpacing + currentKerning + charData.xAdvance * scale;
			if (pointX >= currentX && pointX < (currentX + charWidth))
			{
				if (pointX > (currentX + charWidth / 2))
				{
					return i + 1;
				}
				return i;
			}
			currentX += charWidth;
			previousCharID = charID;
		}
		if (pointX >= currentX)
		{
			return this._text.length;
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	private function getXPositionOfIndex(index:Int):Float
	{
		var font:BitmapFont = this._currentTextFormat.font;
		var customSize:Float = this._currentTextFormat.size;
		var customLetterSpacing:Float = this._currentTextFormat.letterSpacing;
		var isKerningEnabled:Bool = this._currentTextFormat.isKerningEnabled;
		var scale:Float = customSize / font.size;
		if (scale != scale) //isNaN
		{
			scale = 1;
		}
		var xPositionOffset:Float = 0;
		var align:String = this._currentTextFormat.align;
		if (align != TextFormatAlign.LEFT)
		{
			var point:Point = Pool.getPoint();
			this.measureTextInternal(point, false);
			var lineWidth:Float = point.x;
			Pool.putPoint(point);
			var hasExplicitWidth:Bool = this._explicitWidth == this._explicitWidth; //!isNaN
			var maxLineWidth:Float = hasExplicitWidth ? this._explicitWidth : this._explicitMaxWidth;
			if (maxLineWidth > lineWidth)
			{
				if (align == TextFormatAlign.RIGHT)
				{
					xPositionOffset = maxLineWidth - lineWidth;
				}
				else //center
				{
					xPositionOffset = (maxLineWidth - lineWidth) / 2;
				}
			}
		}
		var currentX:Float = 0;
		var previousCharID:Float = Math.NaN;
		var charCount:Int = this._text.length;
		if (index < charCount)
		{
			charCount = index;
		}
		for (i in 0...charCount)
		{
			var charID:Int = this._text.charCodeAt(i);
			var charData:BitmapChar = font.getChar(charID);
			if (charData == null)
			{
				continue;
			}
			var currentKerning:Float = 0;
			if (isKerningEnabled &&
				previousCharID == previousCharID) //!isNaN
			{
				currentKerning = charData.getKerning(previousCharID) * scale;
			}
			currentX += customLetterSpacing + currentKerning + charData.xAdvance * scale;
			previousCharID = charID;
		}
		return currentX + xPositionOffset;
	}
	
	/**
	 * @private
	 */
	private function positionCursorAtCharIndex(index:Int):Void
	{
		if (index < 0)
		{
			index = 0;
		}
		var cursorX:Float = this.getXPositionOfIndex(index);
		cursorX = Std.int(cursorX - (this._cursorSkin.width / 2));
		this._cursorSkin.x = cursorX;
		this._cursorSkin.y = this._verticalAlignOffsetY;
		
		//then we update the scroll to always show the cursor
		var minScrollX:Float = cursorX + this._cursorSkin.width - this.actualWidth;
		var maxScrollX:Float = this.getXPositionOfIndex(this._text.length) - this.actualWidth;
		if (maxScrollX < 0)
		{
			maxScrollX = 0;
		}
		if (this._scrollX < minScrollX)
		{
			this._scrollX = minScrollX;
		}
		else if (this._scrollX > cursorX)
		{
			this._scrollX = cursorX;
		}
		if (this._scrollX > maxScrollX)
		{
			this._scrollX = maxScrollX;
		}
	}
	
	/**
	 * @private
	 */
	private function getCursorIndexFromSelectionRange():Int
	{
		var cursorIndex:Int = this._selectionEndIndex;
		if (this.touchPointID >= 0 && this._selectionAnchorIndex >= 0 && this._selectionAnchorIndex == this._selectionEndIndex)
		{
			cursorIndex = this._selectionBeginIndex;
		}
		return cursorIndex;
	}
	
	/**
	 * @private
	 */
	private function positionSelectionBackground():Void
	{
		var font:BitmapFont = this._currentTextFormat.font;
		var customSize:Float = this._currentTextFormat.size;
		var scale:Float = customSize / font.size;
		if (scale != scale) //isNaN
		{
			scale = 1;
		}
		
		var startX:Float = this.getXPositionOfIndex(this._selectionBeginIndex) - this._scrollX;
		if (startX < 0)
		{
			startX = 0;
		}
		var endX:Float = this.getXPositionOfIndex(this._selectionEndIndex) - this._scrollX;
		if (endX < 0)
		{
			endX = 0;
		}
		this._selectionSkin.x = startX;
		this._selectionSkin.width = endX - startX;
		this._selectionSkin.y = this._verticalAlignOffsetY;
		this._selectionSkin.height = font.lineHeight * scale;
	}
	
	/**
	 * @private
	 */
	private function getSelectedText():String
	{
		if (this._selectionBeginIndex == this._selectionEndIndex)
		{
			return null;
		}
		return this._text.substr(this._selectionBeginIndex, this._selectionEndIndex - this._selectionBeginIndex);
	}
	
	/**
	 * @private
	 */
	private function deleteSelectedText():Void
	{
		var currentValue:String = this._text;
		if (this._displayAsPassword)
		{
			currentValue = this._unmaskedText;
		}
		this.text = currentValue.substr(0, this._selectionBeginIndex) + currentValue.substr(this._selectionEndIndex);
		this.selectRange(this._selectionBeginIndex, this._selectionBeginIndex);
	}
	
	/**
	 * @private
	 */
	private function replaceSelectedText(text:String):Void
	{
		var currentValue:String = this._text;
		if (this._displayAsPassword)
		{
			currentValue = this._unmaskedText;
		}
		var newText:String = currentValue.substr(0, this._selectionBeginIndex) + text + currentValue.substr(this._selectionEndIndex);
		if (this._maxChars > 0 && newText.length > this._maxChars)
		{
			return;
		}
		this.text = newText;
		var selectionIndex:Int = this._selectionBeginIndex + text.length;
		this.selectRange(selectionIndex, selectionIndex);
	}
	
	/**
	 * @private
	 */
	private function hasFocus_enterFrameHandler(event:starling.events.Event):Void
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
	
	/**
	 * @private
	 */
	private function textEditor_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled || (!this._isEditable && !this._isSelectable))
		{
			this.touchPointID = -1;
			return;
		}
		if (this.touchPointID >= 0)
		{
			var touch:Touch = event.getTouch(this, null, this.touchPointID);
			var point:Point = Pool.getPoint();
			touch.getLocation(this, point);
			point.x += this._scrollX;
			this.selectRange(this._selectionAnchorIndex, this.getSelectionIndexAtPoint(point.x, point.y));
			Pool.putPoint(point);
			if (touch.phase == TouchPhase.ENDED)
			{
				this.touchPointID = -1;
			}
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			if (touch.tapCount == 2)
			{
				var start:Int = TextInputNavigation.findCurrentWordStartIndex(this._text, this._selectionBeginIndex);
				var end:Int = TextInputNavigation.findCurrentWordEndIndex(this._text, this._selectionEndIndex);
				this.selectRange(start, end);
				return;
			}
			else if (touch.tapCount > 2)
			{
				this.selectRange(0, this._text.length);
				return;
			}
			this.touchPointID = touch.id;
			point = Pool.getPoint();
			touch.getLocation(this, point);
			point.x += this._scrollX;
			if (event.shiftKey)
			{
				if (this._selectionAnchorIndex < 0)
				{
					this._selectionAnchorIndex = this._selectionBeginIndex;
				}
				this.selectRange(this._selectionAnchorIndex, this.getSelectionIndexAtPoint(point.x, point.y));
			}
			else
			{
				this.setFocus(point);
			}
			Pool.putPoint(point);
		}
	}
	
	/**
	 * @private
	 */
	private function stage_touchHandler(event:TouchEvent):Void
	{
		if (FocusManager.isEnabledForStage(this.stage))
		{
			//let the focus manager handle clearing focus
			return;
		}
		var touch:Touch = event.getTouch(this.stage, TouchPhase.BEGAN);
		if (!touch) //we only care about began touches
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
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (!this._isEnabled || (!this._isEditable && !this._isSelectable) ||
			this.touchPointID >= 0 || event.isDefaultPrevented())
		{
			return;
		}
		//ignore select all, cut, copy, and paste
		var charCode:UInt = event.charCode;
		if (event.ctrlKey && (charCode == 97 || charCode == 99 || charCode == 118 || charCode == 120)) //a, c, p, and x
		{
			return;
		}
		var newIndex:Int = -1;
		if (!FocusManager.isEnabledForStage(this.stage) && event.keyCode == Keyboard.TAB)
		{
			this.clearFocus();
			return;
		}
		else if (event.keyCode == Keyboard.HOME || event.keyCode == Keyboard.UP)
		{
			newIndex = 0;
			if (event.shiftKey)
			{
				this.selectRange(newIndex, this._selectionAnchorIndex);
				return;
			}
		}
		else if (event.keyCode == Keyboard.END || event.keyCode == Keyboard.DOWN)
		{
			newIndex = this._text.length;
			if (event.shiftKey)
			{
				this.selectRange(this._selectionAnchorIndex, newIndex);
				return;
			}
		}
		else if (event.keyCode == Keyboard.LEFT)
		{
			if (event.shiftKey)
			{
				if (this._selectionAnchorIndex >= 0 && this._selectionAnchorIndex == this._selectionBeginIndex &&
					this._selectionBeginIndex != this._selectionEndIndex)
				{
					newIndex = this._selectionEndIndex - 1;
					this.selectRange(this._selectionBeginIndex, newIndex);
				}
				else
				{
					newIndex = this._selectionBeginIndex - 1;
					if (newIndex < 0)
					{
						newIndex = 0;
					}
					this.selectRange(newIndex, this._selectionEndIndex);
				}
				return;
			}
			else if (this._selectionBeginIndex != this._selectionEndIndex)
			{
				newIndex = this._selectionBeginIndex;
			}
			else
			{
				if (event.altKey || event.ctrlKey)
				{
					newIndex = TextInputNavigation.findPreviousWordStartIndex(this._text, this._selectionBeginIndex);
				}
				else
				{
					newIndex = this._selectionBeginIndex - 1;
				}
				if (newIndex < 0)
				{
					newIndex = 0;
				}
			}
		}
		else if (event.keyCode == Keyboard.RIGHT)
		{
			if (event.shiftKey)
			{
				if (this._selectionAnchorIndex >= 0 && this._selectionAnchorIndex == this._selectionEndIndex &&
					this._selectionBeginIndex != this._selectionEndIndex)
				{
					newIndex = this._selectionBeginIndex + 1;
					this.selectRange(newIndex, this._selectionEndIndex);
				}
				else
				{
					newIndex = this._selectionEndIndex + 1;
					if (newIndex < 0 || newIndex > this._text.length)
					{
						newIndex = this._text.length;
					}
					this.selectRange(this._selectionBeginIndex, newIndex);
				}
				return;
			}
			else if (this._selectionBeginIndex != this._selectionEndIndex)
			{
				newIndex = this._selectionEndIndex;
			}
			else
			{
				if (event.altKey || event.ctrlKey)
				{
					newIndex = TextInputNavigation.findNextWordStartIndex(this._text, this._selectionEndIndex);
				}
				else
				{
					newIndex = this._selectionEndIndex + 1;
				}
				if (newIndex < 0 || newIndex > this._text.length)
				{
					newIndex = this._text.length;
				}
			}
		}
		if (newIndex < 0)
		{
			if (event.keyCode == Keyboard.ENTER)
			{
				this.dispatchEventWith(FeathersEventType.ENTER);
				return;
			}
			//everything after this point edits the text, so return if the text
			//editor isn't editable.
			if (!this._isEditable)
			{
				return;
			}
			var currentValue:String = this._text;
			if (this._displayAsPassword)
			{
				currentValue = this._unmaskedText;
			}
			if (event.keyCode == Keyboard.DELETE)
			{
				if (event.altKey || event.ctrlKey)
				{
					var nextWordStartIndex:Int = TextInputNavigation.findNextWordStartIndex(this._text, this._selectionEndIndex);
					this.text = currentValue.substr(0, this._selectionBeginIndex) + currentValue.substr(nextWordStartIndex);
				}
				else if (this._selectionBeginIndex != this._selectionEndIndex)
				{
					this.deleteSelectedText();
				}
				else if (this._selectionEndIndex < currentValue.length)
				{
					this.text = currentValue.substr(0, this._selectionBeginIndex) + currentValue.substr(this._selectionEndIndex + 1);
				}
			}
			else if (event.keyCode == Keyboard.BACKSPACE)
			{
				if (event.altKey || event.ctrlKey)
				{
					newIndex = TextInputNavigation.findPreviousWordStartIndex(this._text, this._selectionBeginIndex);
					this.text = currentValue.substr(0, newIndex) + currentValue.substr(this._selectionEndIndex);
				}
				else if (this._selectionBeginIndex != this._selectionEndIndex)
				{
					this.deleteSelectedText();
				}
				else if (this._selectionBeginIndex > 0)
				{
					newIndex = this._selectionBeginIndex - 1;
					this.text = currentValue.substr(0, this._selectionBeginIndex - 1) + currentValue.substr(this._selectionEndIndex);
				}
			}
		}
		if (newIndex >= 0)
		{
			this.selectRange(newIndex, newIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function nativeFocus_textInputHandler(event:TextEvent):Void
	{
		if (!this._isEditable || !this._isEnabled)
		{
			return;
		}
		var text:String = event.text;
		if (text == CARRIAGE_RETURN || text == LINE_FEED)
		{
			//ignore new lines
			return;
		}
		var charCode:Int = text.charCodeAt(0);
		if (!this._restrict || this._restrict.isCharacterAllowed(charCode))
		{
			this.replaceSelectedText(text);
		}
	}
	
	/**
	 * @private
	 */
	private function nativeFocus_selectAllHandler(event:flash.events.Event):Void
	{
		if (!this._isEnabled || (!this._isEditable && !this._isSelectable))
		{
			return;
		}
		this._selectionAnchorIndex = 0;
		this.selectRange(0, this._text.length);
	}
	
	/**
	 * @private
	 */
	private function nativeFocus_cutHandler(event:flash.events.Event):Void
	{
		if (!this._isEnabled || (!this._isEditable && !this._isSelectable) ||
			this._selectionBeginIndex == this._selectionEndIndex || this._displayAsPassword)
		{
			return;
		}
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, this.getSelectedText());
		if (!this._isEditable)
		{
			return;
		}
		this.deleteSelectedText();
	}
	
	/**
	 * @private
	 */
	private function nativeFocus_copyHandler(event:flash.events.Event):Void
	{
		if (!this._isEnabled || (!this._isEditable && !this._isSelectable) ||
			this._selectionBeginIndex == this._selectionEndIndex || this._displayAsPassword)
		{
			return;
		}
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, this.getSelectedText());
	}
	
	/**
	 * @private
	 */
	private function nativeFocus_pasteHandler(event:flash.events.Event):Void
	{
		if (!this._isEditable || !this._isEnabled)
		{
			return;
		}
		var pastedText:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
		if (pastedText == null)
		{
			//the clipboard doesn't contain any text to paste
			return;
		}
		//new lines are not allowed
		var reg:EReg = ~/[\n\r]/g;
		//pastedText = pastedText.replace(/[\n\r]/g, "");
		pastedText = reg.replace(pastedText, "");
		if (this._restrict != null)
		{
			pastedText = this._restrict.filterText(pastedText);
		}
		this.replaceSelectedText(pastedText);
	}
	
}