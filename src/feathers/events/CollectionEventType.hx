/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.events;

/**
 * Event <code>type</code> constants for collections. This class is
 * not a subclass of <code>starling.events.Event</code> because these
 * constants are meant to be used with <code>dispatchEventWith()</code> and
 * take advantage of the Starling's event object pooling. The object passed
 * to an event listener will be of type <code>starling.events.Event</code>.
 *
 * <listing version="3.0">
 * function listener( event:Event ):void
 * {
 *     trace( "add item" );
 * }
 * collection.addEventListener( CollectionEventType.ADD_ITEM, listener );</listing>
 *
 * @productversion Feathers 1.0.0
 */
class CollectionEventType 
{
	/**
	 * Dispatched when the data provider's source is completely replaced.
	 */
	public static inline var RESET:String = "reset";

	/**
	 * Dispatched when a filter has been applied to or removed from the
	 * collection. The underlying source remains the same, but zero or more
	 * items may have been removed or added.
	 */
	public static inline var FILTER_CHANGE:String = "filterChange";

	/**
	 * Dispatched when a sort compare function has been applied to or
	 * removed from the collection. The underlying source remains the same,
	 * but the order may be modified.
	 */
	public static inline var SORT_CHANGE:String = "sortChange";

	/**
	 * Dispatched when an item is added to the collection.
	 */
	public static inline var ADD_ITEM:String = "addItem";

	/**
	 * Dispatched when an item is removed from the collection.
	 */
	public static inline var REMOVE_ITEM:String = "removeItem";

	/**
	 * Dispatched when an item is replaced in the collection with a
	 * different item.
	 */
	public static inline var REPLACE_ITEM:String = "replaceItem";

	/**
	 * Dispatched when an item in the collection has changed.
	 */
	public static inline var UPDATE_ITEM:String = "updateItem";

	/**
	 * Dispatched when all existing items in the collection have changed
	 * (but they have not been replaced by different items).
	 */
	public static inline var UPDATE_ALL:String = "updateAll";

	/**
	 * Dispatched when all items are removed from the collection.
	 */
	public static inline var REMOVE_ALL:String = "removeAll";
}