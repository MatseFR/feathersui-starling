/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.text;

import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IToggle;
import src.feathers.core.IFeathersControl;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.text.TextFormat;

/**
 * Used internally by <code>ITextRenderer</code> implementations to pass
 * around sets of <code>TextFormat</code> objects for a component's
 * different states.
 *
 * <p>A custom component that uses one or more text renderers is expected to
 * provide user-facing APIs to set its font styles using
 * separate <code>TextFormat</code> instances. The combined set of these
 * formats should be stored in a <code>FontStylesSet</code> that can be
 * passed into the text renderer.</p>
 *
 * @see feathers.core.ITextRenderer
 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
 *
 * @productversion Feathers 3.1.0
 */
class FontStylesSet extends EventDispatcher 
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * Stores formats for specific state. The key is the state constant,
	 * and the value is a TextFormat.
	 */
	private var _stateToFormat:Map<String, TextFormat> = null;
	
	/**
	 * The default font format used to display the text.
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 */
	public var format(get, set):TextFormat;
	
	private var _format:TextFormat;
	private function get_format():TextFormat { return this._format; }
	private function set_format(value:TextFormat):TextFormat
	{
		if (this._format == value)
		{
			return value;
		}
		if (this._format != null)
		{
			this._format.removeEventListener(Event.CHANGE, format_changeHandler);
		}
		this._format = value;
		if (this._format != null)
		{
			this._format.addEventListener(Event.CHANGE, format_changeHandler);
		}
		this.dispatchEventWith(Event.CHANGE);
		return this._format;
	}
	
	
	public var disabledFormat(get, set):TextFormat;
	
	private var _disabledFormat:TextFormat;
	private function get_disabledFormat():TextFormat { return this._disabledFormat; }
	private function set_disabledFormat(value:TextFormat):TextFormat
	{
		if (this._disabledFormat == value)
		{
			return value;
		}
		if (this._disabledFormat != null)
		{
			this._disabledFormat.removeEventListener(Event.CHANGE, format_changeHandler);
		}
		this._disabledFormat = value;
		if (this._disabledFormat != null)
		{
			this._disabledFormat.addEventListener(Event.CHANGE, format_changeHandler);
		}
		this.dispatchEventWith(Event.CHANGE);
		return this._disabledFormat;
	}
	
	/**
	 * The font styles used to display the text when the component is
	 * selected. If <code>null</code>, the value of the <code>format</code>
	 * property will typically be used.
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 */
	public var selectedFormat(get, set):TextFormat;
	
	private var _selectedFormat:TextFormat;
	private function get_selectedFormat():TextFormat { return this._selectedFormat; }
	private function set_selectedFormat(value:TextFormat):TextFormat
	{
		if (this._selectedFormat == value)
		{
			return value;
		}
		if (this._selectedFormat != null)
		{
			this._selectedFormat.removeEventListener(Event.CHANGE, format_changeHandler);
		}
		this._selectedFormat = value;
		if (this._selectedFormat != null)
		{
			this._selectedFormat.addEventListener(Event.CHANGE, format_changeHandler);
		}
		this.dispatchEventWith(Event.CHANGE);
		return this._selectedFormat;
	}
	
	/**
	 * Cleans up all TextFormat objects.
	 */
	public function dispose():Void
	{
		this.format = null;
		this.disabledFormat = null;
		this.selectedFormat = null;
		if (this._stateToFormat != null)
		{
			for (format in this._stateToFormat)
			{
				format.removeEventListener(Event.CHANGE, format_changeHandler);
			}
			this._stateToFormat.clear();
			this._stateToFormat = null;
		}
	}
	
	/**
	 * Returns the <code>TextFormat</code> for a specific state, or
	 * <code>null</code> if the <code>TextFormat</code> has not been set
	 * for that state.
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 */
	public function getFormatForState(state:String):TextFormat
	{
		if (this._stateToFormat == null)
		{
			return null;
		}
		return this._stateToFormat[state];
	}
	
	/**
	   
	   @param	state
	   @param	value
	**/
	public function setFormatForState(state:String, value:TextFormat):Void
	{
		var oldFormat:TextFormat = null;
		if (value != null)
		{
			if (this._stateToFormat == null)
			{
				this._stateToFormat = new Map<String, TextFormat>();
			}
			else
			{
				oldFormat = this._stateToFormat[state];
			}
			if (oldFormat != null)
			{
				oldFormat.removeEventListener(Event.CHANGE, format_changeHandler);
			}
			this._stateToFormat[state] = value;
			value.addEventListener(Event.CHANGE, format_changeHandler);
		}
		else if (this._stateToFormat != null)
		{
			oldFormat = this._stateToFormat[state];
			if (oldFormat != null)
			{
				oldFormat.removeEventListener(Event.CHANGE, format_changeHandler);
				this._stateToFormat.remove(state);
			}
		}
	}
	
	/**
	 * Chooses the appropriate <code>TextFormat</code> to use based on the
	 * state of the text renderer passed in. If the text renderer has a
	 * <code>stateContext</code>, the state of the <code>stateContext</code>
	 * takes precedent.
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 */
	public function getTextFormatForTarget(target:IFeathersControl):TextFormat
	{
		var textFormat:TextFormat;
		var stateContext:IStateContext;
		if (Std.isOfType(target, IStateObserver))
		{
			stateContext = cast(target, IStateObserver).stateContext;
		}
		if (stateContext != null)
		{
			//first, look for a format defined for a specific state
			if (this._stateToFormat != null)
			{
				var currentState:String = stateContext.currentState;
				textFormat = this._stateToFormat[currentState];
			}
			//the disabled format is a convenience that can cover multiple
			//disabled states
			if (textFormat == null && this._disabledFormat != null &&
				Std.isOfType(stateContext, IFeathersControl) && !cast(stateContext, IFeathersControl).isEnabled)
			{
				textFormat = this._disabledFormat;
			}
			//similar with the selected format that can cover multiple
			//selected states
			if (textFormat == null && this._selectedFormat != null &&
				Std.isOfType(stateContext, IToggle) && cast(stateContext, IToggle).isSelected)
			{
				textFormat = this._selectedFormat;
			}
		}
		else //no state context, so only text renderer can be used
		{
			if (this._disabledFormat != null && !target.isEnabled)
			{
				textFormat = this._disabledFormat;
			}
		}
		if (textFormat == null)
		{
			//finally, fall back to the default format, if needed
			//(it may still be null, though)
			textFormat = this._format;
		}
		return textFormat;
	}
	
	private function format_changeHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.CHANGE);
	}
}