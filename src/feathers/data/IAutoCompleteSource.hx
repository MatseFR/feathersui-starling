/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;
import feathers.core.IFeathersEventDispatcher;

/**
 * A source of items to display in the pop-up list of an
 * <code>AutoComplete</code> component.
 *
 * @see feathers.controls.AutoComplete
 *
 * @productversion Feathers 2.1.0
 */
interface IAutoCompleteSource extends IFeathersEventDispatcher
{
	/**
	 * Loads suggestions based on the text entered into an
	 * <code>AutoComplete</code> component.
	 *
	 * <p>If an existing <code>ListCollection</code> is passed in as the
	 * result, all items will be removed before new items are added.</p>
	 */
	function load(textToMatch:String, suggestionsResult:IListCollection = null):Void;
}