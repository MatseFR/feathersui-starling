/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;
import feathers.events.CollectionEventType;
import feathers.utils.type.FunctionApply;
import haxe.Constraints.Function;
import openfl.Vector;
import openfl.errors.RangeError;
import starling.events.Event;

/**
 * Wraps a <code>Vector</code> data source with a common API for use with
 * UI controls that support hierarchical data.
 *
 * @productversion Feathers 3.3.0
 */
class VectorHierarchicalCollection 
{
	/**
	 * Constructor.
	 */
	public function new(vectorData:Vector<Dynamic> = null) 
	{
		if (vectorData == null)
		{
			vectorData = new Vector<Dynamic>();
		}
		this._vectorData = vectorData;
	}
	
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
		this._vectorData = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._vectorData;
	}
	
	/**
	 * The field of a branch object used to access its children. The
	 * field's type must be <code>Vector</code> to be treated as a branch.
	 */
	public var childrenField(get, set):String;
	private var _childrenField:String = "children";
	private function get_childrenField():String { return this._childrenField; }
	private function set_childrenField(value:String):String
	{
		return this._childrenField = value;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#isBranch()
	 */
	public function isBranch(node:Dynamic):Bool
	{
		if (node == null)
		{
			return false;
		}
		//return node.hasOwnProperty(this._childrenField) && node[this._childrenField] is Vector.<*>;
		return Reflect.hasField(node, this._childrenField) && Std.isOfType(Reflect.getProperty(node, this._childrenField), Vector);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getLength()
	 *
	 * @see #getLengthAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function getLength(...rest:Array<Int>):Int
	{
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = rest.length;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = rest[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + rest);
			}
		}
		return branch.length;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getLengthAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function getLengthAtLocation(location:Vector<Int> = null):Int
	{
		var branch:Vector<Dynamic> = this._vectorData;
		if (location != null)
		{
			var indexCount:Int = location.length;
			var index:Int;
			for (i in 0...indexCount)
			{
				index = location[i];
				branch = cast Reflect.getProperty(branch[index], this._childrenField);
				if (branch == null)
				{
					throw new RangeError("Branch not found at location: " + location);
				}
			}
		}
		return branch.length;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#updateItemAt()
	 *
	 * @see #updateAll()
	 */
	public function updateItemAt(index:Int, ...rest:Array<Int>):Void
	{
		rest.insert(0, index);
		this.dispatchEventWith(CollectionEventType.UPDATE_ITEM, false, rest);
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
	public function getItemAt(index:Int, ...rest:Array<Int>):Dynamic
	{
		rest.insert(0, index);
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = rest.length - 1;
		for (i in 0...indexCount; i++)
		{
			index = rest[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				return null;
			}
		}
		var lastIndex:Int = rest[indexCount];
		return branch[lastIndex];
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getItemAtLocation()
	 */
	public function getItemAtLocation(location:Vector<Int>):Dynamic
	{
		if (location == null || location.length == 0)
		{
			return null;
		}
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = location.length - 1;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				return null;
			}
		}
		index = location[indexCount];
		return branch[index];
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#getItemLocation()
	 */
	public function getItemLocation(item:Dynamic, result:Vector<Int> = null):Vector<Int>
	{
		if (result == null)
		{
			result = new Vector<Int>();
		}
		else
		{
			result.length = 0;
		}
		//var branch:Vector.<*> = this._vectorData as Vector.<*>;
		this.findItemInBranch(this._vectorData, item, result);
		return result;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#addItemAt()
	 *
	 * @see #addItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function addItemAt(item:Dynamic, index:Int, ...rest:Array<Int>):Void
	{
		rest.insert(0, index);
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = rest.length - 1;
		for (i in 0...indexCount)
		{
			index = rest[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + rest);
			}
		}
		index = rest[indexCount];
		branch.insertAt(index, item);
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, rest);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#addItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function addItemAtLocation(item:Dynamic, location:Vector<Int>):Void
	{
		if (location == null || location.length == 0)
		{
			throw new RangeError("Branch not found at location: " + location);
		}
		var eventIndices:Array<Int> = [];
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = location.length - 1;
		var index:int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + location);
			}
			eventIndices[i] = index;
		}
		index = location[indexCount];
		eventIndices[indexCount] = index;
		branch.insertAt(index, item);
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.ADD_ITEM, false, eventIndices);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#removeItemAt()
	 *
	 * @see #removeItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function removeItemAt(index:Int, ...rest:Array<Int>):Dynamic
	{
		rest.insert(0, index);
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = rest.length - 1;
		for (i in 0...indexCount)
		{
			index = rest[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + rest);
			}
		}
		index = rest[indexCount];
		var item:Dynamic = branch.removeAt(index);
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, rest);
		return item;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#removeItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function removeItemAtLocation(location:Vector<Int>):Dynamic
	{
		if (location == null || location.length == 0)
		{
			throw new RangeError("Branch not found at location: " + location);
		}
		var eventIndices:Array<Int> = [];
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = location.length - 1;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + location);
			}
			eventIndices[i] = index;
		}
		index = location[indexCount];
		eventIndices[indexCount] = index;
		var item:Dynamic = branch.removeAt(index);
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.REMOVE_ITEM, false, eventIndices);
		return item;
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#removeItem()
	 */
	public function removeItem(item:Dynamic):Void
	{
		var location:Vector<Int> = this.getItemLocation(item);
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
		this._vectorData.length = 0;
		this.dispatchEventWith(CollectionEventType.REMOVE_ALL);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#setItemAt()
	 *
	 * @see #setItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function setItemAt(item:Dynamic, index:Int, ...rest:Array<Int>):Void
	{
		rest.insert(0, index);
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = rest.length - 1;
		for (i in 0...indexCount)
		{
			index = rest[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + rest);
			}
		}
		index = rest[indexCount];
		branch[index] = item;
		this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, rest);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#setItemAtLocation()
	 *
	 * @throws RangeError Branch not found at specified location
	 */
	public function setItemAtLocation(item:Dynamic, location:Vector<Int>):Void
	{
		if (location == null || location.length == 0)
		{
			throw new RangeError("Branch not found at location: " + location);
		}
		var eventIndices:Array<Int> = [];
		var branch:Vector<Dynamic> = this._vectorData;
		var indexCount:Int = location.length - 1;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], this._childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + location);
			}
			eventIndices[i] = index;
		}
		index = location[indexCount];
		eventIndices[indexCount] = index;
		branch[index] = item;
		this.dispatchEventWith(Event.CHANGE);
		this.dispatchEventWith(CollectionEventType.REPLACE_ITEM, false, eventIndices);
	}
	
	/**
	 * @copy feathers.data.IHierarchicalCollection#dispose()
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/DisplayObject.html#dispose() starling.display.DisplayObject.dispose()
	 * @see http://doc.starling-framework.org/core/starling/textures/Texture.html#dispose() starling.textures.Texture.dispose()
	 */
	public function dispose(disposeBranch:Function, disposeItem:Function):Void
	{
		var groupCount:Int = this._vectorData.length;
		var path:Array<Int> = [];
		var group:Dynamic;
		for (i in 0...groupCount)
		{
			group = this._vectorData[i];
			path[0] = i;
			this.disposeGroupInternal(group, path, disposeBranch, disposeItem);
			path.resize(0);
		}
	}
	
	/**
	 * @private
	 */
	private function disposeGroupInternal(group:Dynamic, path:Array<Int>, disposeBranch:Function, disposeItem:Function):Void
	{
		if (disposeBranch != null)
		{
			disposeBranch(group);
		}
		
		var itemCount:Int = getLength(path);//this.getLength.apply(this, path);
		var item:Dynamic;
		for (i in 0...itemCount)
		{
			path[path.length] = i;
			item = FunctionApply.apply(this.getItemAt, path);//this.getItemAt.apply(this, path);
			if (this.isBranch(item))
			{
				this.disposeGroupInternal(item, path, disposeBranch, disposeItem);
			}
			else if (disposeItem != null)
			{
				disposeItem(item);
			}
			path.pop();
		}
	}
	
	/**
	 * @private
	 */
	private function findItemInBranch(branch:Dynamic, item:Dynamic, result:Vector<Int>):Bool
	{
		var branchVector:Vector<Dynamic> = cast branch;
		var insertIndex:Int = result.length;
		var branchLength:Int = branchVector.length;
		var branchItem:Dynamic;
		var children:Vector<Dynamic>;
		var isFound:Bool;
		for (i in 0...branchLength)
		{
			branchItem = branchVector[i];
			if (branchItem == item)
			{
				result[insertIndex] = i;
				return true;
			}
			if (this.isBranch(branchItem))
			{
				result[insertIndex] = i;
				children = cast Reflect.getProperty(branchItem, this._childrenField);
				isFound = this.findItemInBranch(children, item, result);
				if (isFound)
				{
					return true;
				}
				result.pop();
			}
		}
		return false;
	}
	
}