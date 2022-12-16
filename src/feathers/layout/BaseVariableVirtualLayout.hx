/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.layout;

import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;


abstract class BaseVariableVirtualLayout extends EventDispatcher 
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * @private
	 */
	private var _virtualCache:Array<Float> = new Array<Float>();
	
	/**
	 * @copy feathers.layout.IVirtualLayout#useVirtualLayout
	 *
	 * @default true
	 */
	public var useVirtualLayout(get, set):Bool;
	private var _useVirtualLayout:Bool = true;
	private function get_useVirtualLayout():Bool { return this._useVirtualLayout; }
	private function set_useVirutalLayout(value:Bool):Bool
	{
		if (this._useVirtualLayout == value)
		{
			return value;
		}
		this._useVirtualLayout = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._useVirtualLayout;
	}
	
	/**
	 * @copy feathers.layout.IVirtualLayout#typicalItem
	 *
	 * @see #resetTypicalItemDimensionsOnMeasure
	 * @see #typicalItemWidth
	 * @see #typicalItemHeight
	 */
	public var typicalItem(get, set):DisplayObject;
	private var _typicalItem:DisplayObject;
	private function get_typicalItem():DisplayObject { return this._typicalItem; }
	private function set_typicalItem(value:DisplayObject):DisplayObject
	{
		if (this._typicalItem == value)
		{
			return value;
		}
		this._typicalItem = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._typicalItem;
	}
	
	/**
	 * When the layout is virtualized, and this value is true, the items
	 * may have variable dimensions. If false, the items will all share
	 * the same dimensions with the typical item.
	 *
	 * @default false
	 */
	public var hasVariableItemDimensions(get, set):Bool;
	private var _hasVariableItemDimensions:Bool = false;
	private function get_hasVariableItemDimensions():Bool { return this._hasVariableItemDimensions; }
	private function set_hasVariableItemDimensions(value:Bool):Bool
	{
		if (this._hasVariableItemDimensions == value)
		{
			return value;
		}
		this._hasVariableItemDimensions = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._hasVariableItemDimensions;
	}
	
	/**
	 * @copy feathers.layout.ILayout#requiresLayoutOnScroll
	 */
	public var requiresLayoutOnScroll(get, never):Bool;
	private function get_requiresLayoutOnScroll():Bool { return this._useVirtualLayout; }
	
	/**
	 * @copy feathers.layout.IVariableVirtualLayout#resetVariableVirtualCache()
	 */
	public function resetVariableVirtualCache():Void
	{
		this._virtualCache.length = 0;
	}
	
	/**
	 * @copy feathers.layout.IVariableVirtualLayout#resetVariableVirtualCacheAtIndex()
	 */
	public function resetVariableVirtualCacheAtIndex(index:Int, item:DisplayObject = null):Void
	{
		this._virtualCache.splice(index, 1);
		if (item != null)
		{
			this._virtualCache[index] = item.height;
			this.dispatchEventWith(Event.CHANGE);
		}
	}
	
	/**
	 * @copy feathers.layout.IVariableVirtualLayout#addToVariableVirtualCacheAtIndex()
	 */
	public function addToVariableVirtualCacheAtIndex(index:Int, item:DisplayObject = null):Void
	{
		var heightValue:Float = item != null ? item.height : Math.NaN;
		this._virtualCache.insert(index, heightValue);
	}
	
	/**
	 * @copy feathers.layout.IVariableVirtualLayout#removeFromVariableVirtualCacheAtIndex()
	 */
	public function removeFromVariableVirtualCacheAtIndex(index:Int):Void
	{
		this._virtualCache.splice(index, 1);
	}
	
}