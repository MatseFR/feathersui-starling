/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.data;
import feathers.starling.events.CollectionEventType;
import haxe.Constraints.Function;
import openfl.Vector;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Wraps a data source with a common API for use with UI controls, like
 * lists, that support one dimensional collections of data. Supports custom
 * "data descriptors" so that unexpected data sources may be used. Supports
 * Arrays, Vectors, and XMLLists automatically.
 *
 * @productversion Feathers 1.0.0
 */
class ListCollection extends EventDispatcher implements IListCollection
{
	/**
	 * Constructor.
	 */
	public function new(data:Dynamic = null) 
	{
		super();
		if (data == null)
		{
			data = new Array<Dynamic>();
		}
		this.data = data;
	}
	
	/**
	 * @private
	 */
	private var _localDataDescriptor:ArrayListCollectionDataDescriptor;

	/**
	 * @private
	 */
	private var _localData:Array<Dynamic>;
	
	/**
	 * The data source for this collection. May be any type of data, but a
	 * <code>dataDescriptor</code> needs to be provided to translate from
	 * the data source's APIs to something that can be understood by
	 * <code>ListCollection</code>.
	 *
	 * <p>Data sources of type Array, Vector, and XMLList are automatically
	 * detected, and no <code>dataDescriptor</code> needs to be set if the
	 * <code>ListCollection</code> uses one of these types.</p>
	 */
	public var data(get, set):Dynamic;
	private var _data:Dynamic;
	private function get_data():Dynamic { return this._data; }
	private function set_data(value:Dynamic):Dynamic
	{
		if (this._data == value)
		{
			return value;
		}
		this._data = value;
		//we'll automatically detect an array, vector, or xmllist for convenience
		//if (Std.isOfType(this._data, Array) && !Std.isOfType(this._dataDescriptor, ArrayListCollectionDataDescriptor))
		//{
			//this._dataDescriptor = new ArrayListCollectionDataDescriptor();
		//}
		//else if (Std.isOfType(this._data, Vector<Float>) && !Std.isOfType(this._dataDescriptor, VectorFloatListCollectionDataDescriptor))
		//{
			//this._dataDescriptor = new VectorFloatListCollectionDataDescriptor();
		//}
		//else if (Std.isOfType(this._data, Vector<Int>) && !Std.isOfType(this._dataDescriptor, VectorIntListCollectionDataDescriptor))
		//{
			//this._dataDescriptor = new VectorIntListCollectionDataDescriptor();
		//}
		//else if (Std.isOfType(this._data, Vector<UInt>) && !Std.isOfType(this._dataDescriptor, VectorUintListCollectionDataDescriptor))
		//{
			//this._dataDescriptor = new VectorUintListCollectionDataDescriptor();
		//}
		//else if (Std.isOfType(this._data, Vector<Dynamic>) && !Std.isOfType(this._dataDescriptor, VectorListCollectionDataDescriptor))
		//{
			//this._dataDescriptor = new VectorListCollectionDataDescriptor();
		//}
		if (Std.isOfType(this._data, Array) && !Std.isOfType(this._dataDescriptor, ArrayListCollectionDataDescriptor))
		{
			this._dataDescriptor = new ArrayListCollectionDataDescriptor();
		}
		//else if (Std.isOfType(this._data, Vector))
		//{
			//if (checkVectorType(this._data, Float) && !Std.isOfType(this._dataDescriptor, VectorFloatListCollectionDataDescriptor))
			//{
				//this._dataDescriptor = new VectorFloatListCollectionDataDescriptor();
			//}
			//else if (checkVectorType(this._data, Int) && !Std.isOfType(this._dataDescriptor, VectorIntListCollectionDataDescriptor))
			//{
				//this._dataDescriptor = new VectorIntListCollectionDataDescriptor();
			//}
			//else if (checkVectorType(this._data, UInt) && !Std.isOfType(this._dataDescriptor, VectorUintListCollectionDataDescriptor))
			//{
				//this._dataDescriptor = new VectorUintListCollectionDataDescriptor();
			//}
			//else if (!Std.isOfType(this._dataDescriptor, VectorListCollectionDataDescriptor))
			//{
				//this._dataDescriptor = new VectorListCollectionDataDescriptor();
			//}
		//}
		// TODO : XML
		//else if (this._data is XMLList && !(this._dataDescriptor is XMLListListCollectionDataDescriptor))
		//{
			//this._dataDescriptor = new XMLListListCollectionDataDescriptor();
		//}
		if (this._data == null)
		{
			this._dataDescriptor = null;
		}
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._data;
	}
	
	private function checkArrayType<T>(array:Array<T>, type:Dynamic):Bool
	{
		if (array.length != 0) return Std.isOfType(array[0], type);
		return false;
	}
	
	private function checkVectorType<T>(vector:Vector<T>, type:Dynamic):Bool
	{
		if (vector.length != 0) return Std.isOfType(vector[0], type);
		return false;
	}
	
	/**
	 * Describes the underlying data source by translating APIs.
	 *
	 * @see IListCollectionDataDescriptor
	 */
	public var dataDescriptor(get, set):IListCollectionDataDescriptor;
	private var _dataDescriptor:IListCollectionDataDescriptor;
	private function get_dataDescriptor():IListCollectionDataDescriptor { return this._dataDescriptor; }
	private function set_dataDescriptor(value:IListCollectionDataDescriptor):IListCollectionDataDescriptor
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
	 * @private
	 */
	private var _pendingRefresh:Bool = false;
	
	/**
	 * @copy feathers.data.IListCollection#filterFunction
	 */
	public var filterFunction(get, set):Dynamic->Bool;
	private var _filterFunction:Dynamic->Bool;
	private function get_filterFunction():Dynamic->Bool { return this._filterFunction; }
	private function set_filterFunction(value:Dynamic->Bool):Dynamic->Bool
	{
		if (this._filterFunction == value)
		{
			return value;
		}
		this._filterFunction = value;
		this._pendingRefresh = true;
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.FILTER_CHANGE);
		return this._filterFunction;
	}
	
	/**
	 * @copy feathers.data.IListCollection#sortCompareFunction
	 */
	public var sortCompareFunction(get, set):Dynamic->Dynamic->Int;
	private var _sortCompareFunction:Dynamic->Dynamic->Int;
	private function get_sortCompareFunction():Dynamic->Dynamic->Int { return this._sortCompareFunction; }
	private function set_sortCompareFunction(value:Dynamic->Dynamic->Int):Dynamic->Dynamic->Int
	{
		if (this._sortCompareFunction == value)
		{
			return value;
		}
		this._sortCompareFunction = value;
		this._pendingRefresh = true;
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.SORT_CHANGE);
		return this._sortCompareFunction;
	}
	
	/**
	 * @copy feathers.data.IListCollection#length
	 */
	public var length(get, never):Int;
	private function get_length():Int
	{
		if (this._dataDescriptor == null)
		{
			return 0;
		}
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		if (this._localData != null)
		{
			return this._localDataDescriptor.getLength(this._localData);
		}
		return this._dataDescriptor.getLength(this._data);
	}
	
	/**
	 * @copy feathers.data.IListCollection#refresh()
	 */
	public function refresh():Void
	{
		if (this._filterFunction == null && this._sortCompareFunction == null)
		{
			return;
		}
		this._pendingRefresh = true;
		this.dispatchEventWith(Event.CHANGE);
		if (this._filterFunction != null)
		{
			this.dispatchEventWith(CollectionEventType.FILTER_CHANGE);
		}
		if (this._sortCompareFunction != null)
		{
			this.dispatchEventWith(CollectionEventType.SORT_CHANGE);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshFilterAndSort():Void
	{
		this._pendingRefresh = false;
		var count:Int;
		if (this._filterFunction != null)
		{
			var result:Array<Dynamic> = this._localData;
			if (result != null)
			{
				//reuse the old array to avoid garbage collection
				result.resize(0);
			}
			else
			{
				result = [];
			}
			count = this._dataDescriptor.getLength(this._data);
			var pushIndex:Int = -1;
			var item:Dynamic;
			for (i in 0...count)
			{
				item = this._dataDescriptor.getItemAt(this._data, i);
				if (this._filterFunction(item))
				{
					result[++pushIndex] = item;
					//pushIndex++;
				}
			}
			this._localData = result;
			this._localDataDescriptor = new ArrayListCollectionDataDescriptor();
		}
		else if (this._sortCompareFunction != null) //no filter
		{
			count = this._dataDescriptor.getLength(this._data);
			if (this._localData == null)
			{
				this._localData = new Array<Dynamic>();
			}
			else
			{
				this._localData.resize(count);
			}
			for (i in 0...count)
			{
				this._localData[i] = this._dataDescriptor.getItemAt(this._data, i);
			}
			this._localDataDescriptor = new ArrayListCollectionDataDescriptor();
		}
		else //no filter or sort
		{
			this._localData = null;
			this._localDataDescriptor = null;
		}
		if (this._sortCompareFunction != null)
		{
			this._localData.sort(this._sortCompareFunction);
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#updateItemAt()
	 *
	 * @see #updateAll()
	 */
	public function updateItemAt(index:Int):Void
	{
		this.dispatchEventWith(CollectionEventType.UPDATE_ITEM, false, index);
	}
	
	/**
	 * @copy feathers.data.IListCollection#updateAll()
	 *
	 * @see #updateItemAt()
	 */
	public function updateAll():Void
	{
		this.dispatchEventWith(CollectionEventType.UPDATE_ALL);
	}
	
	/**
	 * @copy feathers.data.IListCollection#getItemAt()
	 */
	public function getItemAt(index:Int):Dynamic
	{
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		if (this._localData != null)
		{
			return this._localDataDescriptor.getItemAt(this._localData, index);
		}
		return this._dataDescriptor.getItemAt(this._data, index);
	}
	
	/**
	 * @copy feathers.data.IListCollection#getItemIndex()
	 */
	public function getItemIndex(item:Dynamic):Int
	{
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		if (this._localData != null)
		{
			return this._localDataDescriptor.getItemIndex(this._localData, item);
		}
		return this._dataDescriptor.getItemIndex(this._data, item);
	}
	
	/**
	 * @copy feathers.data.IListCollection#addItemAt()
	 */
	public function addItemAt(item:Dynamic, index:Int):Void
	{
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		if (this._localData != null)
		{
			var unfilteredIndex:Int;
			if (index < this._localDataDescriptor.getLength(this._localData))
			{
				//find the item at the index in the filtered data, and use
				//its index from the unfiltered data
				var oldItem:Dynamic = this._localDataDescriptor.getItemAt(this._localData, index);
				unfilteredIndex = this._dataDescriptor.getItemIndex(this._data, oldItem);
			}
			else
			{
				//if the item is added at the end of the filtered data
				//then add it at the end of the unfiltered data
				unfilteredIndex = this._dataDescriptor.getLength(this._data);
			}
			//always add to the original data
			this._dataDescriptor.addItemAt(this._data, item, unfilteredIndex);
			//but check if the item should be in the filtered data
			var includeItem:Bool = true;
			if (this._filterFunction != null)
			{
				includeItem = this._filterFunction(item);
			}
			if (includeItem)
			{
				var sortedIndex:Int = index;
				if (this._sortCompareFunction != null)
				{
					sortedIndex = this.getSortedInsertionIndex(item);
				}
				this._localDataDescriptor.addItemAt(this._localData, item, sortedIndex);
				//don't dispatch these events if the item is filtered!
				this.dispatchEventWith(Event.CHANGE);
				this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, sortedIndex);
			}
		}
		else //no filter or sort
		{
			this._dataDescriptor.addItemAt(this._data, item, index);
			this.dispatchEventWith(Event.CHANGE);
			this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, index);
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#removeItemAt()
	 */
	public function removeItemAt(index:Int):Dynamic
	{
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		var item:Dynamic;
		if (this._localData != null)
		{
			item = this._localDataDescriptor.removeItemAt(this._localData, index);
			var unfilteredIndex:Int = this._dataDescriptor.getItemIndex(this._data, item);
			this._dataDescriptor.removeItemAt(this._data, unfilteredIndex);
		}
		else
		{
			item = this._dataDescriptor.removeItemAt(this._data, index);
		}
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, index);
		return item;
	}
	
	/**
	 * @copy feathers.data.IListCollection#removeItem()
	 */
	public function removeItem(item:Dynamic):Void
	{
		var index:Int = this.getItemIndex(item);
		if (index != -1)
		{
			this.removeItemAt(index);
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#removeAll()
	 */
	public function removeAll():Void
	{
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		if (this.length == 0)
		{
			return;
		}
		if (this._localData != null)
		{
			this._localDataDescriptor.removeAll(this._localData);
		}
		else
		{
			this._dataDescriptor.removeAll(this._data);
		}
		this.dispatchEventWith(CollectionEventType.REMOVE_ALL);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @copy feathers.data.IListCollection#setItemAt()
	 */
	public function setItemAt(item:Dynamic, index:Int):Void
	{
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		if (this._localData != null)
		{
			var oldItem:Dynamic = this._localDataDescriptor.getItemAt(this._localData, index);
			var unfilteredIndex:Int = this._dataDescriptor.getItemIndex(this._data, oldItem);
			this._dataDescriptor.setItemAt(this._data, item, unfilteredIndex);
			if (this._filterFunction != null)
			{
				var includeItem:Bool = this._filterFunction(item);
				if (includeItem)
				{
					this._localDataDescriptor.setItemAt(this._localData, item, index);
					this.dispatchEventWith(Event.CHANGE);
					this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, index);
					return;
				}
				else
				{
					//if the item is excluded, the item at this index is
					//removed instead of being replaced by the new item
					this._localDataDescriptor.removeItemAt(this._localData, index);
					this.dispatchEventWith(Event.CHANGE);
					this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, index);
				}
			}
			else if (this._sortCompareFunction != null)
			{
				//remove the old item first!
				this._localDataDescriptor.removeItemAt(this._localData, index);
				//then try to figure out where the new item goes when inserted
				var sortedIndex:Int = this.getSortedInsertionIndex(item);
				this._localDataDescriptor.setItemAt(this._localData, item, sortedIndex);
				this.dispatchEventWith(Event.CHANGE);
				this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, index);
				return;
			}
		}
		else //no filter or sort
		{
			this._dataDescriptor.setItemAt(this._data, item, index);
			this.dispatchEventWith(Event.CHANGE);
			this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, index);
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#addItem()
	 */
	public function addItem(item:Dynamic):Void
	{
		this.addItemAt(item, this.length);
	}
	
	/**
	 * @copy feathers.data.IListCollection#push()
	 *
	 * @see #addItem()
	 */
	public function push(item:Dynamic):Void
	{
		this.addItemAt(item, this.length);
	}
	
	/**
	 * @copy feathers.data.IListCollection#addAll()
	 */
	public function addAll(collection:IListCollection):Void
	{
		var otherCollectionLength:Int = collection.length;
		var item:Dynamic;
		for (i in 0...otherCollectionLength)
		{
			item = collection.getItemAt(i);
			this.addItem(item);
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#addAllAt()
	 */
	public function addAllAt(collection:IListCollection, index:Int):Void
	{
		var otherCollectionLength:Int = collection.length;
		var currentIndex:Int = index;
		var item:Dynamic;
		for (i in 0...otherCollectionLength)
		{
			item = collection.getItemAt(i);
			this.addItemAt(item, currentIndex);
			currentIndex++;
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#reset()
	 */
	public function reset(collection:IListCollection):Void
	{
		this._dataDescriptor.removeAll(this._data);
		var otherCollectionLength:Int = collection.length;
		var item:Dynamic;
		for (i in 0...otherCollectionLength)
		{
			item = collection.getItemAt(i);
			this._dataDescriptor.addItemAt(this._data, item, i);
		}
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @copy feathers.data.IListCollection#pop()
	 */
	public function pop():Dynamic
	{
		return this.removeItemAt(this.length - 1);
	}

	/**
	 * @copy feathers.data.IListCollection#unshift()
	 */
	public function unshift(item:Dynamic):Void
	{
		this.addItemAt(item, 0);
	}

	/**
	 * @copy feathers.data.IListCollection#shift()
	 */
	public function shift():Dynamic
	{
		return this.removeItemAt(0);
	}

	/**
	 * @copy feathers.data.IListCollection#contains()
	 */
	public function contains(item:Dynamic):Bool
	{
		return this.getItemIndex(item) != -1;
	}
	
	/**
	 * @copy feathers.data.IListCollection#dispose()
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/DisplayObject.html#dispose() starling.display.DisplayObject.dispose()
	 * @see http://doc.starling-framework.org/core/starling/textures/Texture.html#dispose() starling.textures.Texture.dispose()
	 */
	public function dispose(disposeItem:Function):Void
	{
		//if we're disposing the collection, filters don't matter anymore,
		//and we should ensure that all items are disposed.
		this._filterFunction = null;
		this.refreshFilterAndSort();
		
		var itemCount:Int = this.length;
		var item:Dynamic;
		for (i in 0...itemCount)
		{
			item = this.getItemAt(i);
			disposeItem(item);
		}
	}
	
	/**
	 * @private
	 */
	private function getSortedInsertionIndex(item:Dynamic):Int
	{
		var itemCount:Int = this._localDataDescriptor.getLength(this._localData);
		if (this._sortCompareFunction == null)
		{
			return itemCount;
		}
		var otherItem:Dynamic;
		var result:Int;
		for (i in 0...itemCount)
		{
			otherItem = this._localDataDescriptor.getItemAt(this._localData, i);
			result = this._sortCompareFunction(item, otherItem);
			if (result < 1)
			{
				return i;
			}
		}
		return itemCount;
	}
	
}