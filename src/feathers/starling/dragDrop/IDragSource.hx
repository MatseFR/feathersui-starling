/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.dragDrop;
import starling.events.Event;

/**
 * An object that can initiate drag actions with the drag and drop manager.
 *
 * @see feathers.dragDrop.DragDropManager
 *
 * @productversion Feathers 1.0.0
 */
interface IDragSource 
{
	function dispatchEvent(event:Event):Void;
	function dispatchEventWith(type:String, bubbles:Bool = false, data:Dynamic = null):Void;
}