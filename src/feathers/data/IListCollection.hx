/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;
import feathers.core.IFeathersEventDispatcher;

/**
 * Interface for list collections.
 *
 * @productversion Feathers 3.3.0
 */
interface IListCollection extends IFeathersEventDispatcher
{
	/**
	 * The number of items in the collection.
	 */
	public var length(get, never):Int;
	
	/**
	 * A function to determine if each item in the collection should be
	 * included or excluded from visibility through APIs like
	 * <code>length</code> and <code>getItemAt()</code>.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Boolean</pre>
	 *
	 * <p>In the following example, the filter function is based on the
	 * text of a <code>TextInput</code> component:</p>
	 *
	 * <listing version="3.0">
	 * var collection:IListCollection; //this would be created from a concrete implementation
	 * 
	 * var list:List = new List();
	 * list.dataProvider = collection;
	 * this.addChild( list );
	 * 
	 * var input:TextInput = new TextInput();
	 * input.addEventListener( Event.CHANGE, function():void
	 * {
	 *    if( input.text.length == 0 )
	 *    {
	 *        collection.filterFunction = null;
	 *        return;
	 *    }
	 *    collection.filterFunction = function( item:Object ):Boolean
	 *    {
	 *        var itemText:String = item.label.toLowerCase();
	 *        var filterText:String = input.text.toLowerCase();
	 *        return itemText.indexOf( filterText ) >= 0;
	 *    };
	 * } );
	 * this.addChild( input );</listing>
	 *
	 * @default null
	 */
	public var filterFunction(get, set):Dynamic->Bool;
	
	/**
	 * A function to compare each item in the collection to determine the
	 * order when sorted.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( a:Object, b:Object ):int</pre>
	 *
	 * <p>The return value should be <code>-1</code> if the first item
	 * should appear before the second item when the collection is sorted.
	 * The return value should be <code>1</code> if the first item should
	 * appear after the second item when the collection in sorted. Finally,
	 * the return value should be <code>0</code> if both items have the
	 * same sort order.</p>
	 *
	 * @default null
	 */
	public var sortCompareFunction(get, set):Dynamic->Dynamic->Int;
	
	/**
	 * Refreshes the collection using the <code>filterFunction</code>
	 * or <code>sortCompareFunction</code> without passing in a new values
	 * for these properties. Useful when either of these functions relies
	 * on external variables that have changed.
	 */
	function refresh():Void;
	
	/**
	 * Call <code>updateItemAt()</code> to manually inform any component
	 * rendering the <code>IListCollection</code> that the properties of a
	 * single item in the collection have changed, and that any views
	 * associated with the item should be updated. The collection will
	 * dispatch the <code>CollectionEventType.UPDATE_ITEM</code> event.
	 *
	 * <p>Alternatively, the item can dispatch an event when one of its
	 * properties has changed, and a custom item renderer can listen for
	 * that event and update itself automatically.</p>
	 *
	 * @see #updateAll()
	 */
	function updateItemAt(index:Int):Void;
	
	/**
	 * Call <code>updateAll()</code> to manually inform any component
	 * rendering the <code>IListCollection</code> that the properties of all,
	 * or many, of the collection's items have changed, and that any
	 * rendered views should be updated. The collection will dispatch the
	 * <code>CollectionEventType.UPDATE_ALL</code> event.
	 *
	 * <p>Alternatively, the item can dispatch an event when one of its
	 * properties has changed, and a custom item renderer can listen for
	 * that event and update itself automatically.</p>
	 *
	 * @see #updateItemAt()
	 */
	function updateAll():Void;
	
	/**
	 * Returns the item at the specified index in the collection.
	 */
	function getItemAt(index:Int):Dynamic;
	
	/**
	 * Determines which index the item appears at within the collection. If
	 * the item isn't in the collection, returns <code>-1</code>.
	 *
	 * <p>If the collection is filtered, <code>getItemIndex()</code> will
	 * return <code>-1</code> for items that are excluded by the filter.</p>
	 */
	function getItemIndex(item:Dynamic):Int;
	
	/**
	 * Adds an item to the collection, at the specified index.
	 *
	 * <p>If the collection is filtered, the index is the position in the
	 * filtered data, rather than position in the unfiltered data.</p>
	 */
	function addItemAt(item:Dynamic, index:Int):Void;

	/**
	 * Removes the item at the specified index from the collection and
	 * returns it.
	 *
	 * <p>If the collection is filtered, the index is the position in the
	 * filtered data, rather than position in the unfiltered data.</p>
	 */
	function removeItemAt(index:Int):Dynamic;
	
	/**
	 * Removes a specific item from the collection.
	 *
	 * <p>If the collection is filtered, <code>removeItem()</code> will not
	 * remove the item from the unfiltered data if it is not included in the
	 * filtered data. If the item is not removed,
	 * <code>CollectionEventType.REMOVE_ITEM</code> will not be dispatched.</p>
	 */
	function removeItem(item:Dynamic):Void;

	/**
	 * Removes all items from the collection.
	 */
	function removeAll():Void;

	/**
	 * Replaces the item at the specified index with a new item.
	 */
	function setItemAt(item:Dynamic, index:Int):Void;
	
	/**
	 * Adds an item to the end of the collection.
	 *
	 * <p>If the collection is filtered, <code>addItem()</code> may add
	 * the item to the unfiltered data, but omit it from the filtered data.
	 * If the item is omitted from the filtered data,
	 * <code>CollectionEventType.ADD_ITEM</code> will not be dispatched.</p>
	 */
	function addItem(item:Dynamic):Void;

	/**
	 * Adds all items from another collection.
	 */
	function addAll(collection:IListCollection):Void;

	/**
	 * Adds all items from another collection, placing the items at a
	 * specific index in this collection.
	 */
	function addAllAt(collection:IListCollection, index:Int):Void;
	
	/**
	 * Replaces the collection's data with data from another collection.
	 */
	function reset(collection:IListCollection):Void;

	/**
	 * A convenient alias for <code>addItem()</code>.
	 *
	 * @see #addItem()
	 */
	function push(item:Dynamic):Void;

	/**
	 * Removes the item from the end of the collection and returns it.
	 */
	function pop():Dynamic;
	
	/**
	 * Adds an item to the beginning of the collection.
	 */
	function unshift(item:Dynamic):Void;

	/**
	 * Removes the first item in the collection and returns it.
	 */
	function shift():Dynamic;

	/**
	 * Determines if the specified item is in the collection.
	 *
	 * <p>If the collection is filtered, <code>contains()</code> will return
	 * <code>false</code> for items that are excluded by the filter.</p>
	 */
	function contains(item:Dynamic):Bool;

	/**
	 * Calls a function for each item in the collection that may be used
	 * to dispose any properties on the item. For example, display objects
	 * or textures may need to be disposed.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):void</pre>
	 *
	 * <p>In the following example, the items in the collection are disposed:</p>
	 *
	 * <listing version="3.0">
	 * collection.dispose( function( item:Object ):void
	 * {
	 *     var accessory:DisplayObject = DisplayObject(item.accessory);
	 *     accessory.dispose();
	 * }</listing>
	 *
	 * <p>If the collection has a <code>filterFunction</code>, it will be
	 * removed, and it will not be restored.</p>
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/DisplayObject.html#dispose() starling.display.DisplayObject.dispose()
	 * @see http://doc.starling-framework.org/core/starling/textures/Texture.html#dispose() starling.textures.Texture.dispose()
	 */
	function dispose(disposeItem:Dynamic->Void):Void;
}