/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

/**
 * Minimum requirements for a scroll bar to be usable with a <code>Scroller</code>
 * component.
 *
 * @see Scroller
 *
 * @productversion Feathers 1.0.0
 */
interface IScrollBar 
{
	/**
	 * The amount the scroll bar value must change to get from one "page" to
	 * the next.
	 *
	 * <p>If this value is <code>0</code>, the <code>step</code> value
	 * will be used instead. If the <code>step</code> value is
	 * <code>0</code>, paging is not possible.</p>
	 *
	 * <p>In the following example, the page is changed to 10:</p>
	 *
	 * <listing version="3.0">
	 * scrollBar.minimum = 0;
	 * scrollBar.maximum = 100;
	 * scrollBar.step = 1;
	 * scrollBar.page = 10
	 * scrollBar.value = 12;</listing>
	 */
	public var page(get, set):Float;
	
	
}