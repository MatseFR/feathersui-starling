/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import feathers.starling.core.IToggle;
import feathers.starling.controls.Tree;

/**
 * Interface to implement a renderer for a tree item.
 *
 * @productversion Feathers 3.3.0
 */
interface ITreeItemRenderer extends IToggle
{
	/**
	 * An item from the tree's data provider. The data may change if this
	 * item renderer is reused for a new item because it's no longer needed
	 * for the original item.
	 *
	 * <p>This property is set by the tree, and it should not be set manually.</p>
	 */
	public var data(get, set):Dynamic;
	
	/**
	 * The tree that contains this item renderer.
	 *
	 * <p>This property is set by the tree, and it should not be set manually.</p>
	 */
	public var owner(get, set):Tree;
	
	/**
	 * The location (a vector of numeric indices, starting from zero) of
	 * the item within the tree's data provider. Like the <code>data</code>
	 * property, this value may change if this item renderer is reused by
	 * the tree for a different item.
	 *
	 * <p>This property is set by the tree, and it should not be set manually.</p>
	 */
	public var location(get, set):Array<Int>;
	
	/**
	 * The index of the item within the layout.
	 *
	 * <p>This property is set by the tree, and should not be set manually.</p>
	 */
	public var layoutIndex(get, set):Int;
	
	/**
	 * The ID of the factory used to create this item renderer.
	 *
	 * <p>This property is set by the tree, and it should not be set manually.</p>
	 */
	public var factoryID(get, set):String;
	
	/**
	 * Indicates if the data is a branch or a leaf.
	 *
	 * <p>This property is set by the tree, and it should not be set manually.</p>
	 *
	 * @see #isOpen
	 */
	public var isBranch(get, set):Bool;
	
	/**
	 * Indicates if a branch is open or closed. An item that is not a
	 * branch will always return <code>false</code>.
	 *
	 * <p>This property is set by the tree, and it should not be set manually.</p>
	 *
	 * @see #isBranch
	 */
	public var isOpen(get, set):Bool;
}