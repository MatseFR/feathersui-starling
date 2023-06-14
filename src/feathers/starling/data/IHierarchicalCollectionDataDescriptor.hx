/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.data;

/**
 * An adapter interface to support any kind of data source in
 * hierarchical collections.
 *
 * @see HierarchicalCollection
 *
 * @productversion Feathers 1.0.0
 */
interface IHierarchicalCollectionDataDescriptor 
{
	/**
	 * Determines if a node from the data source is a branch.
	 */
	function isBranch(node:Dynamic):Bool;

	/**
	 * The number of items at the specified location in the data source.
	 *
	 * <p>The rest arguments are the indices that make up the location. If
	 * a location is omitted, the length returned will be for the root level
	 * of the collection.</p>
	 *
	 * <p>Calling <code>getLengthOfBranch()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function getLength(data:Dynamic, indices:Array<Int>):Int;

	/**
	 * The number of items at the specified location in the data source.
	 */
	function getLengthAtLocation(data:Dynamic, location:Array<Int> = null):Int;
	
	/**
	 * Returns the item at the specified location in the data source.
	 *
	 * <p>The rest arguments are the indices that make up the location.</p>
	 *
	 * <p>Calling <code>getItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function getItemAt(data:Dynamic, indices:Array<Int>):Dynamic;
	
	/**
	 * Returns the item at the specified location in the data source.
	 */
	function getItemAtLocation(data:Dynamic, location:Array<Int>):Dynamic;
	
	/**
	 * Replaces the item at the specified location with a new item.
	 *
	 * <p>The rest arguments are the indices that make up the location.</p>
	 *
	 * <p>Calling <code>setItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function setItemAt(data:Dynamic, item:Dynamic, indices:Array<Int>):Void;
	
	/**
	 * Replaces the item at the specified location with a new item.
	 *
	 * <p>The rest arguments are the indices that make up the location.</p>
	 */
	function setItemAtLocation(data:Dynamic, item:Dynamic, location:Array<Int>):Void;
	
	/**
	 * Adds an item to the data source, at the specified location.
	 *
	 * <p>The rest arguments are the indices that make up the location.</p>
	 *
	 * <p>Calling <code>addItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function addItemAt(data:Dynamic, item:Dynamic, indices:Array<Int>):Void;
	
	/**
	 * Adds an item to the data source, at the specified location.
	 */
	function addItemAtLocation(data:Dynamic, item:Dynamic, location:Array<Int>):Void;
	
	/**
	 * Removes the item at the specified location from the data source and
	 * returns it.
	 *
	 * <p>The rest arguments are the indices that make up the location.</p>
	 */
	function removeItemAt(data:Dynamic, indices:Array<Int>):Dynamic;
	
	/**
	 * Removes the item at the specified location from the data source and
	 * returns it.
	 *
	 * <p>The rest arguments are the indices that make up the location.</p>
	 *
	 * <p>Calling <code>removeItemAtLocation()</code> instead is recommended
	 * because the <code>Vector.&lt;int&gt;</code> location may be reused to
	 * avoid excessive garbage collection from temporary objects created by
	 * <code>...rest</code> arguments.</p>
	 */
	function removeItemAtLocation(data:Dynamic, location:Array<Int>):Dynamic;
	
	/**
	 * Removes all items from the data source.
	 */
	function removeAll(data:Dynamic):Void;
	
	/**
	 * Determines which location the item appears at within the data source.
	 * If the item isn't in the data source, returns an empty <code>Vector.&lt;int&gt;</code>.
	 *
	 * <p>The <code>rest</code> arguments are optional indices to narrow
	 * the search.</p>
	 */
	function getItemLocation(data:Dynamic, item:Dynamic, indices:Array<Int>, result:Array<Int> = null):Array<Int>;
}