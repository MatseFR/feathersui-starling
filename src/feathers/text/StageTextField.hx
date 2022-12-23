/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.text;

import openfl.display.BitmapData;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.FocusEvent;
import openfl.events.IEventDispatcher;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * A StageText replacement for Flash Player with matching properties, since
 * StageText is only available in AIR.
 *
 * @productversion Feathers 1.0.0
 */
class StageTextField extends EventDispatcher 
{
	/**
	 * Constructor.
	 */
	public function new(initOptions:Dynamic = null) 
	{
		super(target);
		this.initialize(initOptions);
	}
	
	private var _textField:TextField;
	private var _textFormat:TextFormat;
	private var _isComplete:Bool = false;
	
	
	public var autoCapitalize(get, set):String;
	private var _autoCapitalize:String = "none";
	private function get_autoCapitalize():String { return this._autoCapitalize; }
	private function set_autoCapitalize(value:String):String
	{
		return this._autoCapitalize = value;
	}
	
	
	public var autoCorrect(get, set):Bool;
	private var _autoCorrect:Bool = false;
	private function get_autoCorrect():Bool { return this._autoCorrect; }
	private function set_autoCorrect(value:Bool):Bool
	{
		return this._autoCorrect = value;
	}
	
	
	public var color(get, set):Int;
	private var _color:Int = 0x000000;
	private function get_color():Int { return this._textFormat.color; }
	private function set_color(value:Int):Int
	{
		if (this._textFormat.color == value)
		{
			return value;
		}
		this._textFormat.color = value;
		this._textField.defaultTextFormat = this._textFormat;
		this._textField.setTextFormat(this._textFormat);
	}
	
	
	public var displayAsPassword(get, set):Bool;
	private function get_displayAsPassword():Bool { return this._textField.displayAsPassword; }
	private function set_displayAsPassword(value:Bool):Bool
	{
		return this._textField.displayAsPassword = value;
	}
	
	
	public var editable(get, set):Bool;
	private function get_editable():Bool { return this._textField.type == TextFieldType.INPUT; }
	private function set_editable(value:Bool):Bool
	{
		this._textField.type = value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		return value;
	}
	
	
	public var fontFamily(get, set):String;
	//private var _fontFamily:String = null;
	private function get_fontFamily():String { return this._textFormat.font; }
	private function set_fontFamily(value:String):String
	{
		if (this._textFormat.font == value)
		{
			return value;
		}
		this._textFormat.font = value;
		this._textField.defaultTextFormat = this._textFormat;
		this._textField.setTextFormat(this._textFormat);
		return value;
	}
	
	
	public var fontPosture(get, set):String;
	private function get_fontPosture():String { return this._textFormat.italic ? FontPosture.ITALIC : FontPosture.NORMAL; }
	private function set_fontPosture(value:String):String
	{
		if (this.fontPosture == value)
		{
			return value;
		}
		this._textFormat.italic = value == FontPosture.ITALIC;
		this._textField.defaultTextFormat = this._textFormat;
		this._textField.setTextFormat(this._textFormat);
		return value;
	}
	
	
	public var fontSize(get, set):Int;
	private function get_fontSize():Int { return this._textFormat.size; }
	private function set_fontSize(value:Int):Int
	{
		if (this._textFormat.size == value)
		{
			return value;
		}
		this._textFormat.size = value;
		this._textField.defaultTextFormat = this._textFormat;
		this._textField.setTextFormat(this._textFormat);
		return value;
	}
	
	
	public var fontWeight(get, set):String;
	private function get_fontWeight():String { return this._textFormat.bold ? FontWeight.BOLD : FontWeight.NORMAL; }
	private function set_fontWeight(value:String):String
	{
		if (this.fontWeight == value)
		{
			return value;
		}
		this._textFormat.bold = value == FontWeight.BOLD;
		this._textField.defaultTextFormat = this._textFormat;
		this._textField.setTextFormat(this._textFormat);
		return value;
	}
	
	
	public var locale(get, set):String;
	private var _locale:String = "en";
	private function get_locale():String { return this._locale; }
	private function set_locale(value:String):String
	{
		return this._locale = value;
	}
	
	
	public var maxChars(get, set):Int;
	private function get_maxChars():Int { return this._textField.maxChars; }
	private function set_maxChars(value:Int):Int
	{
		return this._textField.maxChars = value;
	}
	
	
	public var multiline(get, never):Bool;
	private function get_multiline():Bool { return this._textField.multiline; }
	
	
	public var restrict(get, set):String;
	private function get_restrict():String { return this._textField.restrict; }
	private function set_restrict(value:String):String
	{
		return this._textField.restrict = value;
	}
	
	
	public var returnKeyLabel(get, set):String;
	private var _returnKeyLabel:String = "default";
	private function get_returnKeyLabel():String { return this._returnKeyLabel; }
	private function set_returnKeyLabel(value:String):String
	{
		return this._returnKeyLabel = value;
	}
	
	
	public var selectionActiveIndex(get, never):Int;
	private function get_selectionActiveIndex():Int { return this._textField.selectionBeginIndex; }
	
	
	public var selectionAnchorIndex(get, never):Int;
	private function get_selectionAnchorIndex():Int { return this._textField.selectionEndIndex; }
	
	
	public var softKeyboardType(get, set):String;
	private var _softKeyboardType:String = "default";
	private function get_softKeyboardType():String { return this._softKeyboardType; }
	private function set_softKeyboardType(value:String):String
	{
		return this._softKeyboardType = value;
	}
	
	
	public var stage(get, set):Stage;
	private function get_stage():Stage { return this._textField.stage; }
	private function set_stage(value:Stage):Stage
	{
		if (this._textField.stage == value)
		{
			return value;
		}
		if (this._textField.stage != null)
		{
			this._textField.parent.removeChild(this._textField);
		}
		if (value != null)
		{
			value.addChild(this._textField);
			this.dispatchCompleteIfPossible();
		}
		return value;
	}
	
	
	public var text(get, set):String;
	private function get_text():String { return this._textField.text; }
	private function set_text(value:String):String
	{
		return this._textField.text = value;
	}
	
	
	public var textAlign(get, set):String;
	private var _textAlign:String = TextFormatAlign.START;
	private function get_textAlign():String { return this._textAlign; }
	private function set_textAlign(value:String):String
	{
		if (this._textAlign == value)
		{
			return value;
		}
		this._textAlign = value;
		if (value == TextFormatAlign.START)
		{
			value = TextFormatAlign.LEFT;
		}
		else if (value == TextFormatAlign.END)
		{
			value = TextFormatAlign.RIGHT;
		}
		this._textFormat.align = value;
		this._textField.defaultTextFormat = this._textFormat;
		this._textField.setTextFormat(this._textFormat);
		return value;
	}
	
	
	public var viewPort(get, set):Rectangle;
	private var _viewPort:Rectangle = new Rectangle();
	private function get_viewPort():Rectangle { return this._viewPort; }
	private function set_viewPort(value:Rectangle):Rectangle
	{
		if (value == null || value.width < 0 || value.height < 0)
		{
			throw new RangeError("The Rectangle value is not valid.");
		}
		this._viewPort = value;
		this._textField.x = this._viewPort.x;
		this._textField.y = this._viewPort.y;
		this._textField.width = this._viewPort.width;
		this._textField.height = this._viewPort.height;
		
		this.dispatchCompleteIfPossible();
		return value;
	}
	
	
	public var visible(get, set):Bool;
	private function get_visible():Bool { return this._textField.visible; }
	private function set_visible(value:Bool):Bool
	{
		return this._textField.visible = value;
	}
	
	public function assignFocus():Void
	{
		if (this._textField.parent == null)
		{
			return;
		}
		this._textField.stage.focus = this._textField;
	}
	
	public function dispose():Void
	{
		this.stage = null;
		this._textField = null;
		this._textFormat = null;
	}
	
	public function drawViewPortToBitmapData(bitmap:BitmapData):Void
	{
		if (bitmap == null)
		{
			throw new Error("The bitmap is null.");
		}
		if (bitmap.width != this._viewPort.width || bitmap.height != this._viewPort.height)
		{
			throw new ArgumentError("The bitmap's width or height is different from view port's width or height.");
		}
		bitmap.draw(this._textField);
	}
	
	public function selectRange(anchorIndex:Int, activeIndex:Int):Void
	{
		this._textField.setSelection(anchorIndex, activeIndex);
	}
	
	private function dispatchCompleteIfPossible():Void
	{
		if (this._textField.stage == null || this._viewPort.isEmpty())
		{
			this._isComplete = false;
		}
		if (this._textField.stage != null && !this._viewPort.isEmpty())
		{
			this._isComplete = true;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
	private function initialize(initOptions:Dynamic):Void
	{
		this._textField = new TextField();
		this._textField.type = TextFieldType.INPUT;
		var isMultiline:Bool = initOptions != null && initOptions.hasOwnProperty("multiline") && initOptions.multiline;
		this._textField.multiline = isMultiline;
		this._textField.wordWrap = isMultiline;
		this._textField.addEventListener(Event.CHANGE, textField_eventHandler);
		this._textField.addEventListener(FocusEvent.FOCUS_IN, textField_eventHandler);
		this._textField.addEventListener(FocusEvent.FOCUS_OUT, textField_eventHandler);
		this._textField.addEventListener(KeyboardEvent.KEY_DOWN, textField_eventHandler);
		this._textField.addEventListener(KeyboardEvent.KEY_UP, textField_eventHandler);
		this._textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, textField_keyFocusChangeHandler);
		this._textFormat = new TextFormat(null, 11, 0x000000, false, false, false);
		this._textField.defaultTextFormat = this._textFormat;
	}
	
	private function textField_eventHandler(event:Event):Void
	{
		this.dispatchEvent(event);
	}
	
	private function textField_keyFocusChangeHandler(event:FocusEvent):Void
	{
		//StageText doesn't dispatch this event, so we shouldn't either
		event.preventDefault();
		event.stopImmediatePropagation();
		event.stopPropagation();
	}
	
}