/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.supportClasses;

/**
 * Interface used for the view port of scrolling containers.
 *
 * @see feathers.controls.Scroller
 *
 * @productversion Feathers 1.0.0
 */
interface IViewPort 
{
	public var visibleWidth(get, set):Float;
	public var minVisibleWidth(get, set):Float;
	public var maxVisibleWidth(get, set):Float;
	public var visibleHeight(get, set):Float;
	public var minVisibleHeight(get, set):Float;
	public var maxVisibleHeight(get, set):Float;
	
	public var contentX(get, never):Float;
	public var contentY(get, never):Float;
	
	public var horizontalScrollPosition(get, set):Float;
	public var verticalScrollPosition(get, set):Float;
	public var horizontalScrollStep(get, never):Float;
	public var verticalScrollStep(get, never):Float;
	
	public var requiresMeasurementOnScroll(get, never):Bool;
}