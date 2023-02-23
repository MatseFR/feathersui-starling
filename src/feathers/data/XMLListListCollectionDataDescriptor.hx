/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;
import haxe.xml.Access;

/**
 * An <code>IListCollectionDataDescriptor</code> implementation for
 * XMLLists. Has some limitations due to certain things that cannot be done
 * to XMLLists.
 *
 * @see ListCollection
 * @see IListCollectionDataDescriptor
 *
 * @productversion Feathers 1.0.0
 */
class XMLListListCollectionDataDescriptor implements IListCollectionDataDescriptor
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		
	}
	
	/**
	 * @inheritDoc
	 */
	//public function getLength(data:Dynamic):Int
	//{
		//this.checkForCorrectDataType(data);
		//return cast(data, Xml).length();
		//Access
	//}
	
}