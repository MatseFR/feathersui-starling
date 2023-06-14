/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import starling.display.DisplayObject;

interface IDragAndDropItemRenderer 
{
	/**
	 * Indicates if the owner has enabled drag actions.
	 *
	 * <p>This property is set by the list, and should not be set manually.</p>
	 */
	public var dragEnabled(get, set):Bool;
	
	/**
	 * An optional display object to use to trigger drag and drop in the
	 * list component. If <code>null</code>, the entire item renderer can
	 * be dragged.
	 */
	public var dragProxy(get, never):DisplayObject;
}