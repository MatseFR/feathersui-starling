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
import openfl.errors.ArgumentError;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Wraps a <code>Vector</code> in the common <code>IListCollection</code>
 * API used by many Feathers UI controls, including <code>List</code> and
 * <code>TabBar</code>.
 *
 * @productversion Feathers 3.3.0
 */
class VectorCollection extends EventDispatcher implements IListCollection
{
	/**
	 * Constructor.
	 */
	public function new(data:Vector<Dynamic> = null) 
	{
		super();
		if (data == null)
		{
			data = new Vector<Dynamic>();
		}
		//else if (!Std.isOfType(data, Vector))
		//{
			//throw new ArgumentError("VectorCollection data must be of type Vector");
		//}
		this._vectorData = data;
	}
	
	/**
	 * @private
	 */
	private var _filterAndSortData:Vector<Dynamic>;
	
	/**
	 * The <code>Vector</code> data source for this collection.
	 *
	 * <p>Note: Ideally, this property would be typed as something other
	 * than <code>Object</code>, but there is no type that will accept all
	 * <code>Vector</code> objects without requiring a cast first.</p>
	 */
	public var vectorData(get, set):Vector<Dynamic>;
	private var _vectorData:Vector<Dynamic>;
	private function get_vectorData():Vector<Dynamic> { return this._vectorData; }
	private function set_vectorData(value:Vector<Dynamic>):Vector<Dynamic>
	{
		if (this._vectorData == value)
		{
			return value;
		}
		//else if(value !== null && !(value is Vector.<*>))
		//{
			//throw new ArgumentError("VectorCollection vectorData must be of type Vector");
		//}
		this._vectorData = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._vectorData;
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
		if (this._pendingRefresh)
		{
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null)
		{
			return this._filterAndSortData.length;
		}
		return this._vectorData.length;
	}
	
	/**
	 * @copy feathers.data.IListCollection#refreshFilter()
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
		var result:Vector<Dynamic>;
		var itemCount:Int;
		if (this._filterFunction != null)
		{
			result = this._filterAndSortData;
			if (result != null)
			{
				//reuse the old array to avoid garbage collection
				result.length = 0;
			}
			else
			{
				result = new Vector<Dynamic>();
			}
			var vectorData:Vector<Dynamic> = this._vectorData;
			itemCount = vectorData.length;
			var pushIndex:Int = 0;
			var item:Dynamic;
			for (i in 0...itemCount)
			{
				item = vectorData[i];
				if (this._filterFunction(item))
				{
					result[pushIndex] = item;
					pushIndex++;
				}
			}
			this._filterAndSortData = result;
		}
		else if (this._sortCompareFunction != null) //no filter
		{
			itemCount = this._vectorData.length;
			result = this._filterAndSortData;
			if (result != null)
			{
				result.length = itemCount;
				for (i in 0...itemCount)
				{
					result[i] = this._vectorData[i];
				}
			}
			else
			{
				//simply make a copy!
				result = this._vectorData.copy();
			}
			this._filterAndSortData = result;
		}
		else //no filter or sort
		{
			this._filterAndSortData = null;
		}
		if (this._sortCompareFunction != null)
		{
			this._filterAndSortData.sort(this._sortCompareFunction);
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
		if (this._filterAndSortData != null)
		{
			return this._filterAndSortData[index];
		}
		return this._vectorData[index];
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
		if (this._filterAndSortData != null)
		{
			return this._filterAndSortData.indexOf(item);
		}
		return this._vectorData.indexOf(item);
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
		//var filteredData:Vector<Dynamic> = this._filterAndSortData;
		//var vectorData:Vector<Dynamic> = this._vectorData;
		if (this._filterAndSortData != null)
		{
			var unfilteredIndex:Int;
			if (index < this._filterAndSortData.length)
			{
				//find the item at the index in the filtered data, and use
				//its index from the unfiltered data
				var oldItem:Dynamic = this._filterAndSortData[index];
				unfilteredIndex = this._vectorData.indexOf(oldItem);
			}
			else
			{
				//if the item is added at the end of the filtered data
				//then add it at the end of the unfiltered data
				unfilteredIndex = this._vectorData.length;
			}
			//always add to the original data
			this._vectorData.insertAt(unfilteredIndex, item);
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
				this._filterAndSortData.insertAt(sortedIndex, item);
				//don't dispatch these events if the item is filtered!
				this.dispatchEventWith(Event.CHANGE);
				this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, sortedIndex);
			}
		}
		else //no filter or sort
		{
			this._vectorData.insertAt(index, item);
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
		//var filteredData:Vector.<*> = this._filterAndSortData as Vector.<*>;
		//var vectorData:Vector.<*> = this._vectorData as Vector.<*>;
		var item:Dynamic;
		if (this._filterAndSortData != null)
		{
			item = this._filterAndSortData.removeAt(index);
			var unfilteredIndex:Int = this._vectorData.indexOf(item);
			this._vectorData.removeAt(unfilteredIndex);
		}
		else
		{
			item = this._vectorData.removeAt(index);
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
		if (this._filterAndSortData != null)
		{
			this._filterAndSortData.length = 0;
		}
		else
		{
			this._vectorData.length = 0;
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
		//var filteredData:Vector.<*> = this._filterAndSortData as Vector.<*>;
		//var vectorData:Vector.<*> = this._vectorData as Vector.<*>;
		if (this._filterAndSortData != null)
		{
			var oldItem:Dynamic = this._filterAndSortData[index];
			var unfilteredIndex:Int = this._vectorData.indexOf(oldItem);
			this._vectorData[unfilteredIndex] = item;
			if (this._filterFunction != null)
			{
				var includeItem:Bool = this._filterFunction(item);
				if (includeItem)
				{
					this._filterAndSortData[index] = item;
					this.dispatchEventWith(Event.CHANGE);
					this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, index);
					return;
				}
				else
				{
					//if the item is excluded, the item at this index is
					//removed instead of being replaced by the new item
					this._filterAndSortData.removeAt(index);
					this.dispatchEventWith(Event.CHANGE);
					this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, index);
					return;
				}
			}
			else if (this._sortCompareFunction != null)
			{
				//remove the old item first!
				this._filterAndSortData.removeAt(index);
				//then try to figure out where the new item goes when inserted
				var sortedIndex:Int = this.getSortedInsertionIndex(item);
				this._filterAndSortData[sortedIndex] = item;
				this.dispatchEventWith(Event.CHANGE);
				this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, index);
				return;
			}
		}
		else //no filter or sort
		{
			this._vectorData[index] = item;
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
		//var vectorData:Vector.<*> = this._vectorData as Vector.<*>;
		var pushIndex:Int = this._vectorData.length;
		var item:Dynamic;
		for (i in 0...otherCollectionLength)
		{
			item = collection.getItemAt(i);
			this._vectorData[pushIndex] = item;
			pushIndex++;
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#addAllAt()
	 */
	public function addAllAt(collection:IListCollection, index:Int):Void
	{
		var otherCollectionLength:Int = collection.length;
		var currentIndex:Int = index;
		//var vectorData:Vector.<*> = this._vectorData as Vector.<*>;
		var item:Dynamic;
		for (i in 0...otherCollectionLength)
		{
			item = collection.getItemAt(i);
			this._vectorData.insertAt(currentIndex, item);
			currentIndex++;
		}
	}
	
	/**
	 * @copy feathers.data.IListCollection#reset()
	 */
	public function reset(collection:IListCollection):Void
	{
		//var vectorData:Vector.<*> = this._vectorData as Vector.<*>;
		this._vectorData.length = 0;
		var otherCollectionLength:Int = collection.length;
		var item:Dynamic;
		for (i in 0...otherCollectionLength)
		{
			item = collection.getItemAt(i);
			this._vectorData[i] = item;
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
		return this._vectorData.indexOf(item) != -1;
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
		
		//var vectorData:Vector.<*> = this._vectorData as Vector.<*>;
		var itemCount:Int = this._vectorData.length;
		var item:Dynamic;
		for (i in 0...itemCount)
		{
			item = this._vectorData[i];
			disposeItem(item);
		}
	}
	
	/**
	 * @private
	 */
	private function getSortedInsertionIndex(item:Dynamic):Int
	{
		var itemCount:Int = this._filterAndSortData.length;
		if (this._sortCompareFunction == null)
		{
			return itemCount;
		}
		var otherItem:Dynamic;
		var result:Int;
		for (i in 0...itemCount)
		{
			otherItem = this._filterAndSortData[i];
			result = this._sortCompareFunction(item, otherItem);
			if (result < 1)
			{
				return i;
			}
		}
		return itemCount;
	}
	
}