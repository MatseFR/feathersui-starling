/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;
import openfl.errors.RangeError;

/**
 * A hierarchical data descriptor where children are defined as arrays in a
 * property defined on each branch. The property name defaults to <code>"children"</code>,
 * but it may be customized.
 *
 * <p>The basic structure of the data source takes the following form. The
 * root must always be an Array.</p>
 * <pre>
 * [
 *     {
 *         text: "Branch 1",
 *         children:
 *         [
 *             { text: "Child 1-1" },
 *             { text: "Child 1-2" }
 *         ]
 *     },
 *     {
 *         text: "Branch 2",
 *         children:
 *         [
 *             { text: "Child 2-1" },
 *             { text: "Child 2-2" },
 *             { text: "Child 2-3" }
 *         ]
 *     }
 * ]</pre>
 *
 * @productversion Feathers 1.0.0
 */
class ArrayChildrenHierarchicalCollectionDataDescriptor implements IHierarchicalCollectionDataDescriptor
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		
	}
	
	/**
	 * The field used to access the Array of a branch's children.
	 */
	public var childrenField:String = "children";
	
	/**
	 * @inheritDoc
	 */
	public function getLength(data:Dynamic, indices:Array<Int>):Int
	{
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = indices.length;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = indices[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
		}
		
		return branch.length;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getLengthAtLocation(data:Dynamic, location:Array<Int> = null):Int
	{
		var branch:Array<Dynamic> = cast data;
		if (location != null)
		{
			var indexCount:Int = location.length;
			var index:Int;
			for (i in 0...indexCount)
			{
				index = location[i];
				branch = cast Reflect.getProperty(branch[index], childrenField);
			}
		}
		return branch.length;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemAt(data:Dynamic, indices:Array<Int>):Dynamic
	{
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = indices.length - 1;
		for (i in 0...indexCount)
		{
			index = indices[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
		}
		var lastIndex:Int = indices[indexCount];
		return branch[lastIndex];
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemAtLocation(data:Dynamic, location:Array<Int>):Dynamic
	{
		if (location == null || location.length == 0)
		{
			return null;
		}
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = location.length - 1;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + location);
			}
		}
		var lastIndex:Int = location[indexCount];
		return branch[lastIndex];
	}
	
	/**
	 * @inheritDoc
	 */
	public function setItemAt(data:Dynamic, item:Dynamic, indices:Array<Int>):Void
	{
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = indices.length - 1;
		for (i in 0...indexCount)
		{
			index = indices[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
		}
		var lastIndex:Int = indices[indexCount];
		branch[lastIndex] = item;
	}
	
	/**
	 * @inheritDoc
	 */
	public function setItemAtLocation(data:Dynamic, item:Dynamic, location:Array<Int>):Void
	{
		if (location == null || location.length == 0)
		{
			throw new RangeError("Branch not found at location: " + location);
		}
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = location.length - 1;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + location);
			}
		}
		var lastIndex:Int = location[indexCount];
		branch[lastIndex] = item;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addItemAt(data:Dynamic, item:Dynamic, indices:Array<Int>):Void
	{
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = indices.length - 1;
		for (i in 0...indexCount)
		{
			index = indices[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
		}
		var lastIndex:Int = indices[indexCount];
		branch.insert(lastIndex, item);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addItemAtLocation(data:Dynamic, item:Dynamic, location:Array<Int>):Void
	{
		if (location == null || location.length == 0)
		{
			throw new RangeError("Branch not found at location: " + location);
		}
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = location.length - 1;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + location);
			}
		}
		var lastIndex:Int = location[indexCount];
		branch.insert(lastIndex, item);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeItemAt(data:Dynamic, indices:Array<Int>):Dynamic
	{
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = indices.length - 1;
		for (i in 0...indexCount)
		{
			index = rest[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
		}
		var lastIndex:Int = indices[indexCount];
		return branch.splice(lastIndex, 1);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeItemAtLocation(data:Dynamic, location:Array<Int>):Dynamic
	{
		if (location == null || location.length == 0)
		{
			throw new RangeError("Branch not found at location: " + location);
		}
		var branch:Array<Dynamic> = cast data;
		var indexCount:Int = location.length - 1;
		var index:Int;
		for (i in 0...indexCount)
		{
			index = location[i];
			branch = cast Reflect.getProperty(branch[index], childrenField);
			if (branch == null)
			{
				throw new RangeError("Branch not found at location: " + location);
			}
		}
		var lastIndex:Int = location[indexCount];
		return branch.splice(lastIndex, 1);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeAll(data:Dynamic):Void
	{
		var branch:Array<Dynamic> = cast data;
		branch.resize(0);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getItemLocation(data:Dynamic, item:Dynamic, indices:Array<Int>, result:Array<Int> = null):Array<Int>
	{
		if (result == null)
		{
			result = new Array<Int>();
		}
		else
		{
			result.resize(0);
		}
		var branch:Array<Dynamic> = cast data;
		var count:Int = indices.length;
		var index:Int;
		for (i in 0...restCount)
		{
			index = indices[i];
			result[i] = index;
			branch = cast Reflect.getProperty(branch[index], childrenField);
		}
		
		var isFound:Bool = this.findItemInBranch(branch, item, result);
		if (!isFound)
		{
			result.resize(0);
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function isBranch(node:Dynamic):Bool
	{
		if (node == null)
		{
			return false;
		}
		return Reflect.hasField(node, this.childrenField) && Std.isOfType(Reflect.getProperty(node, this.childrenField), Array<Dynamic>);
	}
	
	/**
	 * @private
	 */
	private function findItemInBranch(branch:Array<Dynamic>, item:Dynamic, result:Array<Int>):Bool
	{
		var index:Int = branch.indexOf(item);
		if (index != -1)
		{
			result.push(index);
			return true;
		}
		
		var branchLength:Int = branch.length;
		var branchItem:Dynamic;
		var isFound:Bool;
		for (i in 0...branchLength)
		{
			branchItem = branch[i];
			if (this.isBranch(branchItem))
			{
				result.push(i);
				isFound:Bool = this.findItemInBranch(cast Reflect.getProperty(branchItem, childrenField), item, result);
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