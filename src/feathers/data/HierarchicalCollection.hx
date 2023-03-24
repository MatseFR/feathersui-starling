/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;

import feathers.events.CollectionEventType;
import haxe.Constraints.Function;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.utils.Execute;

/**
 * Wraps a two-dimensional data source with a common API for use with UI
 * controls that support this type of data.
 *
 * @productversion Feathers 1.0.0
 */
class HierarchicalCollection extends EventDispatcher implements IHierarchicalCollection
{
	/**
	 * Constructor.
	 */
	public function new(data:Dynamic = null) 
	{
		if (data == null)
		{
			data = new Array<Dynamic>();
		}
		this.data = data;
	}
	
	/**
	 * The data source for this collection. May be any type of data, but a
	 * <code>dataDescriptor</code> needs to be provided to translate from
	 * the data source's APIs to something that can be understood by
	 * hierarchical collection.
	 */
	public var data(get, set):Dynamic;
	private var _data:Dynamic;
	private function get_data():Dynamic { return this._data; }
	private function set_data(value:Dynamic):Dynamic
	{
		if (this._data == value)
		{
			return;
		}
		this._data = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._data;
	}
	
	/**
	 * Describes the underlying data source by translating APIs.
	 */
	public var dataDescriptor(get, set):IHierarchicalCollectionDataDescriptor;
	private var _dataDescriptor:IHierarchicalCollectionDataDescriptor = new ArrayChildrenHierarchicalCollectionDataDescriptor();
	private function get_dataDescriptor():IHierarchicalCollectionDataDescriptor { return this._dataDescriptor; }
	private function set_dataDescriptor(value:IHierarchicalCollectionDataDescriptor):IHierarchicalCollectionDataDescriptor
	{
		if (this._dataDescriptor == value)
		{
			return value;
		}
		this._dataDescriptor = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._dataDescriptor;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#isBranch()
	 */
	public function isBranch(node:Dynamic):Bool
	{
		return this._dataDescriptor.isBranch(node);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getLength()
	 *
	 * @see #getLengthAtLocation()
	 */
	public function getLength(...rest:Array<Dynamic>):Int
	{
		rest.insert(0, this._data);
		//return this._dataDescriptor.getLength.apply(null, rest);
		return Execute.execute(this._dataDescriptor.getLength, rest);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getLengthAtLocation()
	 */
	public function getLengthAtLocation(location:Array<Int> = null):Int
	{
		return this._dataDescriptor.getLengthAtLocation(this._data, location);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#updateItemAt()
	 *
	 * @see #updateAll()
	 */
	public function updateItemAt(indices:Array<Int>):Void
	{
		this.dispatchEventWith(CollectionEventType.UPDATE_ITEM, false, indices);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#updateAll()
	 *
	 * @see #updateItemAt()
	 */
	public function updateAll():Void
	{
		this.dispatchEventWith(CollectionEventType.UPDATE_ALL);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getItemAt()
	 *
	 * @see #getItemAtLocation()
	 */
	public function getItemAt(indices:Array<Int>):Dynamic
	{
		rest.insert(0, index);
		rest.insert(0, this._data);
		//return this._dataDescriptor.getItemAt.apply(null, rest);
		return Execute.execute(this._dataDescriptor.getItemAt, rest);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getItemAtLocation()
	 */
	public function getItemAtLocation(location:Array<Int>):Dynamic
	{
		return this._dataDescriptor.getItemAtLocation(this._data, location);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getItemLocation()
	 */
	public function getItemLocation(item:Dynamic, result:Array<Int> = null):Array<Int>
	{
		return this._dataDescriptor.getItemLocation(this._data, item, result);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#addItemAt()
	 *
	 * @see #addItemAtLocation()
	 */
	public function addItemAt(item:Dynamic, index:Int, ...rest:Array<Dynamic>):Void
	{
		rest.insertAt(0, index);
		rest.insertAt(0, item);
		rest.insertAt(0, this._data);
		//this._dataDescriptor.addItemAt.apply(null, rest);
		Execute.execute(this._dataDescriptor.addItemAt, rest);
		this.dispatchEventWith(Event.CHANGE);
		rest.shift();
		rest.shift();
		this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, rest);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#addItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function addItemAtLocation(item:Dynamic, location:Array<Int>):Void
	{
		this._dataDescriptor.addItemAtLocation(this._data, item, location);
		this.dispatchEventWith(Event.CHANGE);
		//var result:Array = [];
		//var locationCount:int = location.length;
		//for(var i:int = 0; i < locationCount; i++)
		//{
			//result[i] = location[i];
		//}
		//var result:Array<Int> = location.copy();
		this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, location.copy());
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#removeItemAt()
	 *
	 * @see #removeItemAtLocation()
	 */
	public function removeItemAt(index:Int, ...rest:Array<Dynamic>):Dynamic
	{
		rest.insertAt(0, index);
		rest.insertAt(0, this._data);
		//var item:Dynamic = this._dataDescriptor.removeItemAt.apply(null, rest);
		var item:Dynamic = Execute.execute(this._dataDescriptor.removeItemAt, rest);
		this.dispatchEventWith(Event.CHANGE);
		rest.shift();
		this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, rest);
		return item;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#removeItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function removeItemAtLocation(location:Array<Int>):Dynamic
	{
		var item:Dynamic = this._dataDescriptor.removeItemAtLocation(this._data, location);
		//var result:Array = [];
		//var locationCount:int = location.length;
		//for(var i:int = 0; i < locationCount; i++)
		//{
			//result[i] = location[i];
		//}
		
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, location);
		return item;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#removeItem()
	 */
	public function removeItem(item:Dynamic):Void
	{
		var location:Array<Int> = this.getItemLocation(item);
		if (location != null)
		{
			this.removeItemAtLocation(location);
		}
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#removeAll()
	 */
	public function removeAll():Void
	{
		if (this.getLength() == 0)
		{
			return;
		}
		this._dataDescriptor.removeAll(this._data);
		this.dispatchEventWith(CollectionEventType.REMOVE_ALL);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#setItemAt()
	 *
	 * @see #setItemAtLocation()
	 */
	public function setItemAt(item:Dynamic, index:Int, ...rest:Array<Dynamic>):Void
	{
		rest.insertAt(0, index);
		rest.insertAt(0, item);
		rest.insertAt(0, this._data);
		//this._dataDescriptor.setItemAt.apply(null, rest);
		Execute.execute(this._dataDescriptor.setItemAt, rest);
		rest.shift();
		rest.shift();
		this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, rest);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#setItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function setItemAtLocation(item:Dynamic, location:Array<Int>):Void
	{
		this._dataDescriptor.setItemAtLocation(data, item, location);
		this.dispatchEventWith(Event.CHANGE);
		//var result:Array = [];
		//var locationCount:int = location.length;
		//for(var i:int = 0; i < locationCount; i++)
		//{
			//result[i] = location[i];
		//}
		this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, location);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#dispose()
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/DisplayObject.html#dispose() starling.display.DisplayObject.dispose()
	 * @see http://doc.starling-framework.org/core/starling/textures/Texture.html#dispose() starling.textures.Texture.dispose()
	 */
	public function dispose(disposeGroup:Function, disposeItem:Function):Void
	{
		var groupCount:int = this.getLength();
		var path:Array<Int> = [];
		var group:Dynamic;
		for (i in 0...groupCount)
		{
			group = this.getItemAt(i);
			path[0] = i;
			this.disposeGroupInternal(group, path, disposeGroup, disposeItem);
			path.resize(0);
		}
	}
	
	/**
	 * @private
	 */
	private function disposeGroupInternal(group:Dynamic, path:Array<Dynamic>, disposeGroup:Function, disposeItem:Function):Void
	{
		if (disposeGroup != null)
		{
			disposeGroup(group);
		}
		
		//var itemCount:Int = this.getLength.apply(this, path);
		var itemCount:Int = Execute.execute(this.getLength, path);
		var item:Dynamic;
		for (i in 0...itemCount)
		{
			path[path.length] = i;
			//item = this.getItemAt.apply(this, path);
			item = Execute.execute(this.getItemAt, path);
			if (this.isBranch(item))
			{
				this.disposeGroupInternal(item, path, disposeGroup, disposeItem);
			}
			else if (disposeItem != null)
			{
				disposeItem(item);
			}
			//path.length--;
			path.pop();
		}
	}
	
}