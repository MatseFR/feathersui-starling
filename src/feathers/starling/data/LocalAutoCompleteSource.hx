/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.data;

import haxe.Constraints.Function;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Creates a list of suggestions for an <code>AutoComplete</code> component
 * by searching through items in a <code>ListCollection</code>.
 *
 * @see feathers.controls.AutoComplete
 * @see feathers.data.ListCollection
 *
 * @productversion Feathers 2.1.0
 */
class LocalAutoCompleteSource extends EventDispatcher implements IAutoCompleteSource
{
	/**
	 * @private
	 */
	private static function defaultCompareFunction(item:Dynamic, textToMatch:String):Bool
	{
		return Std.string(item).toLowerCase().indexOf(textToMatch.toLowerCase()) != -1;
	}
	
	/**
	 * Constructor.
	 */
	public function new(source:IListCollection = null) 
	{
		super();
		this._dataProvider = source;
	}
	
	/**
	 * A collection of items to be used as a source for auto-complete
	 * results.
	 */
	public var dataProvider(get, set):IListCollection;
	private var _dataProvider:IListCollection;
	private function get_dataProvider():IListCollection { return this._dataProvider; }
	private function set_dataProvider(value:IListCollection):IListCollection
	{
		return this._dataProvider = value;
	}
	
	/**
	 * A function used to compare items from the data provider with the
	 * string passed to the <code>load()</code> function in order to
	 * generate a list of suggestions. The function should return
	 * <code>true</code> if the item should be included in the list of
	 * suggestions.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object, textToMatch:String ):Boolean</pre>
	 */
	public var compareFunction(get, set):Function;
	private var _compareFunction:Function = defaultCompareFunction;
	private function get_compareFunction():Function { return this._compareFunction; }
	private function set_compareFunction(value:Function):Function
	{
		if (value == null)
		{
			value = defaultCompareFunction;
		}
		return this._compareFunction = value;
	}
	
	/**
	 * @copy feathers.data.IAutoCompleteSource#load()
	 */
	public function load(textToMatch:String, result:IListCollection = null):Void
	{
		if (result != null)
		{
			result.removeAll();
		}
		else
		{
			result = new ArrayCollection();
		}
		if (this._dataProvider == null || textToMatch.length == 0)
		{
			this.dispatchEventWith(Event.COMPLETE, false, result);
			return;
		}
		var compareFunction:Function = this._compareFunction;
		var count:Int = this._dataProvider.length;
		var item:Dynamic;
		for (i in 0...count)
		{
			item = this._dataProvider.getItemAt(i);
			if (compareFunction(item, textToMatch))
			{
				result.addItem(item);
			}
		}
		this.dispatchEventWith(Event.COMPLETE, false, result);
	}
	
}