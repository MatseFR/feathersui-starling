/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.text;

import feathers.core.FeathersControl;
import feathers.core.IStateContext;
import feathers.events.FeathersEventType;
import feathers.text.FontStylesSet;
import starling.events.Event;

/**
 * A base class for text renderers that implements some common properties.
 *
 * @productversion Feathers 3.1.0
 */
class BaseTextRenderer extends FeathersControl 
{
	/**
	   Constructor
	**/
	public function new() 
	{
		super();
	}
	
	/**
	 * @copy feathers.core.ITextRenderer#text
	 */
	public var text(get, set):String;
	
	private var _text:String = null;
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (this._text == value)
		{
			return;
		}
		this._text = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * When the text renderer observes a state context, the text renderer
	 * may change its font styles based on the current state of that
	 * context. Typically, a relevant component will automatically assign
	 * itself as the state context of a text renderer, so this property is
	 * typically meant for internal use only.
	 *
	 * @default null
	 *
	 * @see #setFontStylesForState()
	 */
	public var stateContext(get, set):IStateContext;
	
	private var _stateContext:IStateContext;
	private function get_stateContext():IStateContext { return _stateContext; }
	private function set_stateContext(value:IStateContext):IStateContext
	{
		if (this._stateContext == value)
		{
			return value;
		}
		if (this._stateContext != null)
		{
			this._stateContext.removeEventListener(FeathersEventType.STATE_CHANGE, stateContext_stateChangeHandler);
		}
		this._stateContext = value;
		if (this._stateContext != null)
		{
			this._stateContext.addEventListener(FeathersEventType.STATE_CHANGE, stateContext_stateChangeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		return this._stateContext;
	}
	
	/**
	 * @copy feathers.core.ITextRenderer#wordWrap
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
			this._fontStyles.removeEventListener(Event.CHANGE, fontStyleSet_changeHandler);
		}
		this._fontStyles = value;
		if (this._fontStyles != null)
		{
			this._fontStyles.addEventListener(Event.CHANGE, fontStyleSet_changeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._fontStyles;
	}
	
	override public function dispose():Void 
	{
		this.stateContext = null;
		this.fontStyles = null;
		super.dispose();
	}
	
	private function stateContext_stateChangeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
	}
	
	private function fontStyleSet_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
}