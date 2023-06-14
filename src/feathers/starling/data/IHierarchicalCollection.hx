/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.data;
import feathers.starling.core.IFeathersEventDispatcher;
import haxe.Constraints.Function;

/**
 * An interface for hierarchical collections.
 *
 * @productversion 3.3.0
 */
interface IHierarchicalCollection extends IFeathersEventDispatcher
{
	/**
	 * Determines if a node from the data source is a branch.
	 */
	function isBranch(node:Dynamic):Bool;
	
	/**
	 * The number of items at the specified location in the collection.
	 *
	 * <p>Calling <code>getLengthOfBranch()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	//function getLength(indices:Array<Int>):Int;
	
	/**
	 * The number of items at the specified location in the collection.
	 */
	function getLengthAtLocation(location:Array<Int> = null):Int;
	
	/**
	 * Call <code>updateItemAt()</code> to manually inform any component
	 * rendering the hierarchical collection that the properties of a
	 * single item in the collection have changed, and that any views
	 * associated with the item should be updated. The collection will
	 * dispatch the <code>CollectionEventType.UPDATE_ITEM</code> event.
	 *
	 * <p>Alternatively, the item can dispatch an event when one of its
	 * properties has changed, and  a custom item renderer can listen for
	 * that event and update itself automatically.</p>
	 *
	 * @see #updateAll()
	 */
	function updateItemAt(indices:Array<Int>):Void;
	
	/**
	 * Call <code>updateAll()</code> to manually inform any component
	 * rendering the hierarchical collection that the properties of all, or
	 * many, of the collection's items have changed, and that any rendered
	 * views should be updated. The collection will dispatch the
	 * <code>CollectionEventType.UPDATE_ALL</code> event.
	 *
	 * <p>Alternatively, the item can dispatch an event when one of its
	 * properties has changed, and  a custom item renderer can listen for
	 * that event and update itself automatically.</p>
	 *
	 * @see #updateItemAt()
	 */
	function updateAll():Void;
	
	/**
	 * Returns the item at the specified location in the collection.
	 *
	 * <p>Calling <code>getItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function getItemAt(indices:Array<Int>):Dynamic;
	
	/**
	 * Returns the item at the specified location in the collection.
	 */
	function getItemAtLocation(location:Array<Int>):Dynamic;
	
	/**
	 * Determines which location the item appears at within the collection. If
	 * the item isn't in the collection, returns an empty vector.
	 */
	function getItemLocation(item:Dynamic, result:Array<Int> = null):Array<Int>;
	
	/**
	 * Adds an item to the collection, at the specified location.
	 *
	 * <p>Calling <code>addItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function addItemAt(item:Dynamic, indices:Array<Int>):Void;
	
	/**
	 * Adds an item to the collection, at the specified location.
	 */
	function addItemAtLocation(item:Dynamic, location:Array<Int>):Void;

	/**
	 * Removes the item at the specified location from the collection and
	 * returns it.
	 *
	 * <p>Calling <code>removeItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function removeItemAt(indices:Array<Int>):Dynamic;

	/**
	 * Removes the item at the specified location from the collection and
	 * returns it.
	 */
	function removeItemAtLocation(location:Array<Int>):Dynamic;

	/**
	 * Removes a specific item from the collection.
	 */
	function removeItem(item:Dynamic):Void;

	/**
	 * Removes all items from the collection.
	 */
	function removeAll():Void;

	/**
	 * Replaces the item at the specified location with a new item.
	 *
	 * <p>Calling <code>setItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function setItemAt(item:Dynamic, indices:Array<Int>):Void;

	/**
	 * Replaces the item at the specified location with a new item.
	 */
	function setItemAtLocation(item:Dynamic, location:Array<Int>):Void;
	
	/**
	 * Calls a function for each group in the collection and another
	 * function for each item in a group, where each function handles any
	 * properties that require disposal on these objects. For example,
	 * display objects or textures may need to be disposed. You may pass in
	 * a value of <code>null</code> for either function if you don't have
	 * anything to dispose in one or the other.
	 *
	 * <p>The function to dispose a group is expected to have the following signature:</p>
	 * <pre>function( group:Object ):void</pre>
	 *
	 * <p>The function to dispose an item is expected to have the following signature:</p>
	 * <pre>function( item:Object ):void</pre>
	 *
	 * <p>In the following example, the items in the collection are disposed:</p>
	 *
	 * <listing version="3.0">
	 * collection.dispose( function( group:Object ):void
	 * {
	 *     var content:DisplayObject = DisplayObject(group.content);
	 *     content.dispose();
	 * },
	 * function( item:Object ):void
	 * {
	 *     var accessory:DisplayObject = DisplayObject(item.accessory);
	 *     accessory.dispose();
	 * },)</listing>
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/DisplayObject.html#dispose() starling.display.DisplayObject.dispose()
	 * @see http://doc.starling-framework.org/core/starling/textures/Texture.html#dispose() starling.textures.Texture.dispose()
	 */
	function dispose(disposeGroup:Function, disposeItem:Function):Void;
}