/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.layout;
import feathers.starling.core.IFeathersEventDispatcher;
import feathers.starling.layout.LayoutBoundsResult;
import feathers.starling.layout.ViewPortBounds;
import flash.geom.Point;
import starling.display.DisplayObject;

/**
 * Interface providing layout capabilities for containers.
 *
 * @productversion Feathers 1.0.0
 */
interface ILayout extends IFeathersEventDispatcher
{
	/**
	 * Determines if the container calls <code>layout()</code> when the
	 * scroll position changes. Useful for transforming items as the view
	 * port scrolls. This value should be <code>true</code> for layouts that
	 * implement the <code>IVirtualLayout</code> interface and the
	 * <code>useVirtualLayout</code> property is set to <code>true</code>.
	 * May also be used by layouts that toggle item visibility as the items
	 * scroll into and out of the view port.
	 */
	public var requiresLayoutOnScroll(get, never):Bool;
	
	/**
	 * Positions (and possibly resizes) the supplied items within the
	 * optional bounds argument. If no bounds are specified, the layout
	 * algorithm will assume that the bounds start a 0,0 and have unbounded
	 * dimensions. Returns the actual bounds of the content, which may
	 * be different than the specified bounds.
	 *
	 * <p>Note: The items are <strong>not</strong> absolutely
	 * restricted to appear only within the bounds. The bounds can affect
	 * positioning, but the algorithm may very well ignore them completely.</p>
	 *
	 * <p>If a layout implementation needs to access accurate <code>width</code>
	 * and <code>height</code> values from items that are of type
	 * <code>IFeathersControl</code>, it must call <code>validate()</code>
	 * manually. For performance reasons, the container that is the parent
	 * of the items will not call <code>validate()</code> before passing the
	 * items to a layout implementation. Meeting this requirement may be as
	 * simple as looping through the items at the beginning of
	 * <code>layout()</code> and validating all items that are Feathers UI
	 * controls:</p>
	 *
	 * <listing version="3.0">
	 * const itemCount:int = items.length;
	 * for(var i:int = 0; i &lt; itemCount; i++)
	 * {
	 *     var item:IFeathersControl = items[i] as IFeathersControl;
	 *     if(item)
	 *     {
	 *         item.validate();
	 *     }
	 * }</listing>
	 *
	 * @see feathers.core.FeathersControl#validate()
	 */
	function layout(items:Array<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult;
	
	/**
	 * Using the current index and a key press, calculates the new index.
	 * This might be use to change a list's <code>selectedIndex</code> when
	 * a key is pressed.
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#UP flash.ui.Keyboard.UP
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#DOWN flash.ui.Keyboard.DOWN
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#LEFT flash.ui.Keyboard.LEFT
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#RIGHT flash.ui.Keyboard.RIGHT
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#HOME flash.ui.Keyboard.HOME
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#END flash.ui.Keyboard.END
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#PAGE_UP flash.ui.Keyboard.PAGE_UP
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html#PAGE_DOWN flash.ui.Keyboard.PAGE_DOWN
	 */
	function calculateNavigationDestination(items:Array<DisplayObject>, index:Int, keyCode:Int, bounds:LayoutBoundsResult):Int;
	
	/**
	 * Using the item dimensions, calculates a scroll position that will
	 * ensure that the item at a given index will be visible within the
	 * specified bounds.
	 *
	 * <p>Typically, this function is used to show the item in the most
	 * prominent way, such as centering. To scroll a minimum distance
	 * required to display the full bounds of the item in the view port,
	 * use <code>getNearestScrollPositionForIndex()</code> instead.</p>
	 *
	 * <p>This function should always be called <em>after</em> the
	 * <code>layout()</code> function. The width and height arguments are
	 * the final bounds of the view port, which may be calculated in the
	 * layout() function.</p>
	 *
	 * @see #getNearestScrollPositionForIndex()
	 */
	function getScrollPositionForIndex(index:Int, items:Array<DisplayObject>,
		x:Float, y:Float, width:Float, height:Float, result:Point = null):Point;
	
	/**
	 * Calculates the scroll position nearest to the current scroll position
	 * that will display the full bounds of the item within the view port.
	 * If the item is already fully displayed in the view port, the current
	 * scroll position will be returned unchanged.
	 *
	 * <p>While the item will be displayed in the view port without being
	 * clipped in any way, it may not be placed in the most prominent
	 * position possible. To give the item a more prominent location, use
	 * <code>getScrollPositionForIndex()</code> instead.</p>
	 *
	 * <p>This function should always be called <em>after</em> the
	 * <code>layout()</code> function. The width and height arguments are
	 * the final bounds of the view port, which may be calculated in the
	 * layout() function.</p>
	 *
	 * @see #getScrollPositionForIndex()
	 */
	function getNearestScrollPositionForIndex(index:Int, scrollX:Float, scrollY:Float,
	items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float, result:Point = null):Point;
}