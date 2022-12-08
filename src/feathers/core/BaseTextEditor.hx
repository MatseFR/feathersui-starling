/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import feathers.events.FeathersEventType;
import feathers.text.FontStyleSet;
import starling.events.Event;

/**
 * A base class for text editors that implements some common properties.
 *
 * @productversion Feathers 3.1.0
 */
class BaseTextEditor extends FeathersControl implements IStateObserver
{
	/**
	   Constructor.
	**/
	public function new() 
	{
		super();
	}
	
	/**
	 * @copy feathers.core.ITextEditor#text
	 */
	public var text(get, set):String;
	private var _text:String = "";
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (value == null)
		{
			//don't allow null or undefined
			value = "";
		}
		if (this._text == value)
		{
			return value;
		}
		this._text = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(Event.CHANGE);
		return this._text;
	}
	
	/**
	 * When the text editor observes a state context, the text editor may
	 * change its font styles based on the current state of that context.
	 * Typically, a relevant component will automatically assign itself as
	 * the state context of a text editor, so this property is typically
	 * meant for internal use only.
	 *
	 * @default null
	 *
	 * @see #setFontStylesForState()
	 */
	public var stateContext(get, set):IStateContext;
	private var _stateContext:IStateContext;
	private function get_stateContext():IStateContext { return this._stateContext; }
	private function set_stateContext(value:IStateContext):IStateContext
	{
		if (this._stateContext == value)
		{
			return;
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
	 * @copy feathers.core.ITextEditor#fontStyles
	 */
	public var fontStyles(get, set):FontStyleSet;
	private var _fontStyles:FontStyleSet;
	private function get_fontStyles():FontStyleSet { return this._fontStyles; }
	private function set_fontStyles(value:FontStyleSet):FontStyleSet
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
		if (this._fontStles != null)
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
	
	/**
	   @private
	**/
	private function stateContext_stateChangeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
	}
	
	/**
	   @private
	**/
	private function fontStyleSet_changeHandler(event:Event):Void
	{
		this.invaliddate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}