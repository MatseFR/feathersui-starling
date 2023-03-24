/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.renderers.IListItemRenderer;
import feathers.core.FeathersControl;
import feathers.core.IValidating;
import feathers.data.IListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.ILayout;
import feathers.layout.ISpinnerLayout;
import feathers.layout.VerticalSpinnerLayout;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import openfl.errors.ArgumentError;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * A customized <code>List</code> component where scrolling updates the
 * the selected item. Layouts may loop infinitely.
 *
 * <p>The following example creates a list, gives it a data provider, tells
 * the item renderer how to interpret the data, and listens for when the
 * selection changes:</p>
 *
 * <listing version="3.0">
 * var list:SpinnerList = new SpinnerList();
 * 
 * list.dataProvider = new ArrayCollection(
 * [
 *     { text: "Milk", thumbnail: textureAtlas.getTexture( "milk" ) },
 *     { text: "Eggs", thumbnail: textureAtlas.getTexture( "eggs" ) },
 *     { text: "Bread", thumbnail: textureAtlas.getTexture( "bread" ) },
 *     { text: "Chicken", thumbnail: textureAtlas.getTexture( "chicken" ) },
 * ]);
 * 
 * list.itemRendererFactory = function():IListItemRenderer
 * {
 *     var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
 *     renderer.labelField = "text";
 *     renderer.iconSourceField = "thumbnail";
 *     return renderer;
 * };
 * 
 * list.addEventListener( Event.CHANGE, list_changeHandler );
 * 
 * this.addChild( list );</listing>
 *
 * @see ../../../help/spinner-list.html How to use the Feathers SpinnerList component
 *
 * @productversion Feathers 2.1.0
 */
class SpinnerList extends List 
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>SpinnerList</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this._scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
		this._snapToPages = true;
		this._snapOnComplete = true;
		this.decelerationRate = DecelerationRate.FAST;
		this.addEventListener(Event.TRIGGERED, spinnerList_triggeredHandler);
		this.addEventListener(FeathersEventType.SCROLL_COMPLETE, spinnerList_scrollCompleteHandler);
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		if (SpinnerList.globalStyleProvider != null)
		{
			return SpinnerList.globalStyleProvider;
		}
		return List.globalStyleProvider;
	}
	
	/**
	 * <code>SpinnerList</code> requires that the <code>snapToPages</code>
	 * property is set to <code>true</code>. Attempts to set it to
	 * <code>false</code> will result in a runtime error.
	 *
	 * @throws ArgumentError SpinnerList requires snapToPages to be true.
	 */
	override function set_snapToPages(value:Bool):Bool 
	{
		if (!value)
		{
			throw new ArgumentError("SpinnerList requires snapToPages to be true.");
		}
		return super.set_snapToPages(value);
	}
	
	/**
	 * <code>SpinnerList</code> requires that the <code>allowMultipleSelection</code>
	 * property is set to <code>false</code>. Attempts to set it to
	 * <code>true</code> will result in a runtime error.
	 *
	 * @throws ArgumentError SpinnerList requires allowMultipleSelection to be false.
	 */
	override function set_allowMultipleSelection(value:Bool):Bool 
	{
		if (value)
		{
			throw new ArgumentError("SpinnerList requires allowMultipleSelection to be false.");
		}
		return super.set_allowMultipleSelection(value);
	}
	
	/**
	 * <code>SpinnerList</code> requires that the <code>isSelectable</code>
	 * property is set to <code>true</code>. Attempts to set it to
	 * <code>false</code> will result in a runtime error.
	 *
	 * @throws ArgumentError SpinnerList requires isSelectable to be true.
	 */
	override function set_isSelectable(value:Bool):Bool 
	{
		if (!value)
		{
			throw new ArgumentError("SpinnerList requires isSelectable to be true.");
		}
		return super.set_isSelectable(value);
	}
	
	/**
	 * @private
	 */
	private var _spinnerLayout:ISpinnerLayout;
	
	/**
	 * @private
	 */
	override function set_layout(value:ILayout):ILayout 
	{
		if (value != null && !Std.isOfType(value, ISpinnerLayout))
		{
			throw new ArgumentError("SpinnerList requires layouts to implement the ISpinnerLayout interface.");
		}
		super.set_layout(value);
		this._spinnerLayout = cast value;
		return value;
	}
	
	/**
	 * @private
	 */
	override function set_selectedIndex(value:Int):Int 
	{
		if (value < 0 && this._dataProvider != null && this._dataProvider.length != 0)
		{
			//a SpinnerList must always select an item, unless the data
			//provider is empty
			return value;
		}
		if (this._selectedIndex != value)
		{
			this.scrollToDisplayIndex(value, 0);
		}
		return super.set_selectedIndex(value);
	}
	
	/**
	 * @private
	 */
	override function set_selectedItem(value:Dynamic):Dynamic 
	{
		if (this._dataProvider == null)
		{
			this.selectedIndex = -1;
			return value;
		}
		var index:Int = this._dataProvider.getItemIndex(value);
		if (index < 0)
		{
			return value;
		}
		return this.selectedIndex = index;
	}
	
	/**
	 * @private
	 */
	override function set_dataProvider(value:IListCollection):IListCollection 
	{
		if (this._dataProvider == value)
		{
			return value;
		}
		super.dataProvider = value;
		if (this._dataProvider == null || this._dataProvider.length == 0)
		{
			this.selectedIndex = -1;
		}
		else
		{
			this.selectedIndex = 0;
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var selectionOverlaySkin(get, set):DisplayObject;
	private var _selectionOverlaySkin:DisplayObject = null;
	private function get_selectionOverlaySkin():DisplayObject { return this._selectionOverlaySkin; }
	private function set_selectionOverlaySkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("selectionOverlaySkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._selectionOverlaySkin == value)
		{
			return value;
		}
		if (this._selectionOverlaySkin != null && this._selectionOverlaySkin.parent == this)
		{
			this.removeRawChildInternal(this._selectionOverlaySkin);
		}
		this._selectionOverlaySkin = value;
		if (this._selectionOverlaySkin != null)
		{
			this.addRawChildInternal(this._selectionOverlaySkin);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._selectionOverlaySkin;
	}
	
	/**
	 * @private
	 */
	public var showSelectionOverlay(get, set):Bool;
	private var _showSelectionOverlay:Bool = true;
	private function get_showSelectionOverlay():Bool { return this._showSelectionOverlay; }
	private function set_showSelectionOverlay(value:Bool):Bool
	{
		if (this.processStyleRestriction("showSelectionOverlay"))
		{
			return value;
		}
		if (this._showSelectionOverlay == value)
		{
			return value;
		}
		this._showSelectionOverlay = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._showSelectionOverlay;
	}
	
	/**
	 * @private
	 */
	public var hideSelectionOverlayUnlessFocused(get, set):Bool;
	private var _hideSelectionOverlayUnlessFocused:Bool = false;
	private function get_hideSelectionOverlayUnlessFocused():Bool { return this._hideSelectionOverlayUnlessFocused; }
	private function set_hideSelectionOverlayUnlessFocused(value:Bool):Bool
	{
		if (this.processStyleRestriction("hideSelectionOverlayUnlessFocused"))
		{
			return value;
		}
		if (this._hideSelectionOverlayUnlessFocused == value)
		{
			return value;
		}
		this._hideSelectionOverlayUnlessFocused = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._hideSelectionOverlayUnlessFocused;
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		//SpinnerList has a different default layout than its superclass,
		//List, so set it before calling super.initialize()
		if (this._layout == null)
		{
			if (this._hasElasticEdges &&
				this._verticalScrollPolicy == ScrollPolicy.AUTO &&
				this._scrollBarDisplayMode != ScrollBarDisplayMode.FIXED)
			{
				//so that the elastic edges work even when the max scroll
				//position is 0, similar to iOS.
				this._verticalScrollPolicy = ScrollPolicy.ON;
			}
			
			var layout:VerticalSpinnerLayout = new VerticalSpinnerLayout();
			layout.useVirtualLayout = true;
			layout.padding = 0;
			layout.gap = 0;
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
			layout.requestedRowCount = 4;
			this.ignoreNextStyleRestriction();
			this.layout = layout;
		}
		
		super.initialize();
	}
	
	/**
	 * @private
	 */
	override function refreshMinAndMaxScrollPositions():Void
	{
		var oldActualPageWidth:Float = this.actualPageWidth;
		var oldActualPageHeight:Float = this.actualPageHeight;
		super.refreshMinAndMaxScrollPositions();
		if (this._maxVerticalScrollPosition != this._minVerticalScrollPosition)
		{
			this.actualPageHeight = this._spinnerLayout.snapInterval;
			if (!this.isScrolling && this.pendingItemIndex == -1 &&
				this.actualPageHeight != oldActualPageHeight)
			{
				//if the height of items have changed, we need to tweak the
				//scroll position to re-center the selected item.
				//we don't do this if the user is currently scrolling or if
				//the selected index has changed (which will set
				//pendingItemIndex).
				var verticalPageIndex:Int = this.calculateNearestPageIndexForItem(this._selectedIndex, this._verticalPageIndex, this._maxVerticalPageIndex);
				this._verticalScrollPosition = this.actualPageHeight * verticalPageIndex;
			}
		}
		else if (this._maxHorizontalScrollPosition != this._minHorizontalScrollPosition)
		{
			this.actualPageWidth = this._spinnerLayout.snapInterval;
			if (!this.isScrolling && this.pendingItemIndex == -1 &&
				this.actualPageWidth != oldActualPageWidth)
			{
				var horizontalPageIndex:Int = this.calculateNearestPageIndexForItem(this._selectedIndex, this._horizontalPageIndex, this._maxHorizontalPageIndex);
				this._horizontalScrollPosition = this.actualPageWidth * horizontalPageIndex;
			}
		}
	}
	
	/**
	 * @private
	 */
	override function handlePendingScroll():Void
	{
		if (this.pendingItemIndex != -1)
		{
			var itemIndex:Int = this.pendingItemIndex;
			this.pendingItemIndex = -1;
			if (this._maxVerticalPageIndex != this._minVerticalPageIndex)
			{
				this.pendingVerticalPageIndex = this.calculateNearestPageIndexForItem(itemIndex, this._verticalPageIndex, this._maxVerticalPageIndex);
				this.hasPendingVerticalPageIndex = this.pendingVerticalPageIndex != this._verticalPageIndex;
			}
			else if (this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
			{
				this.pendingHorizontalPageIndex = this.calculateNearestPageIndexForItem(itemIndex, this._horizontalPageIndex, this._maxHorizontalPageIndex);
				this.hasPendingHorizontalPageIndex = this.pendingHorizontalPageIndex != this._horizontalPageIndex;
			}
		}
		super.handlePendingScroll();
	}
	
	/**
	 * @private
	 */
	override function layoutChildren():Void
	{
		super.layoutChildren();
		
		if (this._selectionOverlaySkin != null)
		{
			if (this._showSelectionOverlay && this._hideSelectionOverlayUnlessFocused &&
				this._focusManager != null && this._isFocusEnabled)
			{
				this._selectionOverlaySkin.visible = this._hasFocus;
			}
			else
			{
				this._selectionOverlaySkin.visible = this._showSelectionOverlay;
			}
			var selectionBounds:Rectangle = this._spinnerLayout.selectionBounds;
			this._selectionOverlaySkin.x = this._leftViewPortOffset + selectionBounds.x;
			this._selectionOverlaySkin.y = this._topViewPortOffset + selectionBounds.y;
			this._selectionOverlaySkin.width = selectionBounds.width;
			this._selectionOverlaySkin.height = selectionBounds.height;
			if (Std.isOfType(this._selectionOverlaySkin, IValidating))
			{
				cast(this._selectionOverlaySkin, IValidating).validate();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function calculateNearestPageIndexForItem(itemIndex:Int, currentPageIndex:Int, maxPageIndex:Int):Int
	{
		if (maxPageIndex != MathUtils.INT_MAX)
		{
			return itemIndex;
		}
		var itemCount:Int = this._dataProvider.length;
		var fullDataProviderOffsets:Int = Std.int(currentPageIndex / itemCount);
		var currentItemIndex:Int = currentPageIndex % itemCount;
		var previousPageIndex:Float;
		var nextPageIndex:Float;
		if (itemIndex < currentItemIndex)
		{
			previousPageIndex = fullDataProviderOffsets * itemCount + itemIndex;
			nextPageIndex = (fullDataProviderOffsets + 1) * itemCount + itemIndex;
		}
		else
		{
			previousPageIndex = (fullDataProviderOffsets - 1) * itemCount + itemIndex;
			nextPageIndex = fullDataProviderOffsets * itemCount + itemIndex;
		}
		if ((nextPageIndex - currentPageIndex) < (currentPageIndex - previousPageIndex))
		{
			return Std.int(nextPageIndex);
		}
		return Std.int(previousPageIndex);
	}
	
	/**
	 * @private
	 */
	override function scroller_removedFromStageHandler(event:Event):Void
	{
		if (this._verticalAutoScrollTween != null)
		{
			this._verticalAutoScrollTween.advanceTime(this._verticalAutoScrollTween.totalTime);
		}
		if (this._horizontalAutoScrollTween != null)
		{
			this._horizontalAutoScrollTween.advanceTime(this._horizontalAutoScrollTween.totalTime);
		}
		super.scroller_removedFromStageHandler(event);
	}
	
	/**
	 * @private
	 */
	private function spinnerList_scrollCompleteHandler(event:Event):Void
	{
		var itemCount:Int = this._dataProvider.length;
		var pageIndex:Int = 0;
		if (this._maxVerticalPageIndex != this._minVerticalPageIndex)
		{
			pageIndex = this._verticalPageIndex % itemCount;
		}
		else if (this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
		{
			pageIndex = this._horizontalPageIndex % itemCount;
		}
		if (pageIndex < 0)
		{
			pageIndex = itemCount + pageIndex;
		}
		var item:Dynamic = this._dataProvider.getItemAt(pageIndex);
		var itemRenderer:IListItemRenderer = this.itemToItemRenderer(item);
		if (itemRenderer != null && !itemRenderer.isEnabled)
		{
			//if the item renderer isn't enabled, we cannot select it
			//go back to the previously selected index
			if (this._maxVerticalPageIndex != this._minVerticalPageIndex)
			{
				this.scrollToPageIndex(this._horizontalPageIndex, this._selectedIndex, this._pageThrowDuration);
			}
			else if (this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
			{
				this.scrollToPageIndex(this._selectedIndex, this._verticalPageIndex, this._pageThrowDuration);
			}
			return;
		}
		this.selectedIndex = pageIndex;
	}
	
	/**
	 * @private
	 */
	private function spinnerList_triggeredHandler(event:Event, item:Dynamic):Void
	{
		var itemIndex:Int = this._dataProvider.getItemIndex(item);
		//property must change immediately, but the animation can take longer
		this.selectedIndex = itemIndex;
		if (this._maxVerticalPageIndex != this._minVerticalPageIndex)
		{
			itemIndex = this.calculateNearestPageIndexForItem(itemIndex, this._verticalPageIndex, this._maxVerticalPageIndex);
			this.throwToPage(this._horizontalPageIndex, itemIndex, this._pageThrowDuration);
		}
		else if (this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
		{
			itemIndex = this.calculateNearestPageIndexForItem(itemIndex, this._horizontalPageIndex, this._maxHorizontalPageIndex);
			this.throwToPage(itemIndex, this._verticalPageIndex, this._pageThrowDuration);
		}
	}
	
	/**
	 * @private
	 */
	override function dataProvider_removeItemHandler(event:Event, index:Int):Void
	{
		super.dataProvider_removeItemHandler(event, index);
		var itemIndex:Int;
		if (this._maxVerticalPageIndex != this._minVerticalPageIndex)
		{
			itemIndex = this.calculateNearestPageIndexForItem(this._selectedIndex, this._verticalPageIndex, this._maxVerticalPageIndex);
			if (itemIndex > this._dataProvider.length)
			{
				itemIndex -= this._dataProvider.length;
			}
			this.scrollToDisplayIndex(itemIndex, 0);
		}
		else if (this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
		{
			itemIndex = this.calculateNearestPageIndexForItem(this._selectedIndex, this._horizontalPageIndex, this._maxHorizontalPageIndex);
			if (itemIndex > this._dataProvider.length)
			{
				itemIndex -= this._dataProvider.length;
			}
			this.scrollToDisplayIndex(itemIndex, 0);
		}
	}
	
	/**
	 * @private
	 */
	override function dataProvider_addItemHandler(event:Event, index:Int):Void
	{
		super.dataProvider_addItemHandler(event, index);
		var itemIndex:Int;
		if (this._maxVerticalPageIndex != this._minVerticalPageIndex)
		{
			itemIndex = this.calculateNearestPageIndexForItem(this._selectedIndex, this._verticalPageIndex, this._maxVerticalPageIndex);
			if (itemIndex > this._dataProvider.length)
			{
				itemIndex -= this._dataProvider.length;
			}
			this.scrollToDisplayIndex(itemIndex, 0);
		}
		else if (this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
		{
			itemIndex = this.calculateNearestPageIndexForItem(this._selectedIndex, this._horizontalPageIndex, this._maxHorizontalPageIndex);
			if (itemIndex > this._dataProvider.length)
			{
				itemIndex -= this._dataProvider.length;
			}
			this.scrollToDisplayIndex(itemIndex, 0);
		}
	}
	
	/**
	 * @private
	 */
	override function nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			return;
		}
		if (this._dataProvider == null)
		{
			return;
		}
		if (event.keyCode == Keyboard.HOME || event.keyCode == Keyboard.END ||
			event.keyCode == Keyboard.PAGE_UP || event.keyCode == Keyboard.PAGE_DOWN ||
			event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN ||
			event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT)
		{
			var newIndex:Int = this.dataViewPort.calculateNavigationDestination(this.selectedIndex, event.keyCode);
			if (this.selectedIndex != newIndex)
			{
				//property must change immediately, but the animation can take longer
				this.selectedIndex = newIndex;
				var pageIndex:Int;
				if (this._maxVerticalPageIndex != this._minVerticalPageIndex)
				{
					event.preventDefault();
					pageIndex = this.calculateNearestPageIndexForItem(newIndex, this._verticalPageIndex, this._maxVerticalPageIndex);
					this.throwToPage(this._horizontalPageIndex, pageIndex, this._pageThrowDuration);
				}
				else if (this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
				{
					event.preventDefault();
					pageIndex = this.calculateNearestPageIndexForItem(newIndex, this._horizontalPageIndex, this._maxHorizontalPageIndex);
					this.throwToPage(pageIndex, this._verticalPageIndex, this._pageThrowDuration);
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	// TODO : there is no TransformGestureEvent in OpenFL
	//override function stage_gestureDirectionalTapHandler(event:TransformGestureEvent):Void
	//{
		//if(event.isDefaultPrevented())
		//{
			////something else has already handled this event
			//return;
		//}
		//var keyCode:uint = int.MAX_VALUE;
		//if(event.offsetY < 0)
		//{
			//keyCode = Keyboard.UP;
		//}
		//else if(event.offsetY > 0)
		//{
			//keyCode = Keyboard.DOWN;
		//}
		//else if(event.offsetX > 0)
		//{
			//keyCode = Keyboard.RIGHT;
		//}
		//else if(event.offsetX < 0)
		//{
			//keyCode = Keyboard.LEFT;
		//}
		//if(keyCode == int.MAX_VALUE)
		//{
			//return;
		//}
		//var newIndex:int = this.dataViewPort.calculateNavigationDestination(this.selectedIndex, keyCode);
		//if(this.selectedIndex != newIndex)
		//{
			////property must change immediately, but the animation can take longer
			//this.selectedIndex = newIndex;
			//if(this._maxVerticalPageIndex != this._minVerticalPageIndex)
			//{
				//event.stopImmediatePropagation();
				////event.preventDefault();
				//var pageIndex:int = this.calculateNearestPageIndexForItem(newIndex, this._verticalPageIndex, this._maxVerticalPageIndex);
				//this.throwToPage(this._horizontalPageIndex, pageIndex, this._pageThrowDuration);
			//}
			//else if(this._maxHorizontalPageIndex != this._minHorizontalPageIndex)
			//{
				//event.stopImmediatePropagation();
				////event.preventDefault();
				//pageIndex = this.calculateNearestPageIndexForItem(newIndex, this._horizontalPageIndex, this._maxHorizontalPageIndex);
				//this.throwToPage(pageIndex, this._verticalPageIndex, this._pageThrowDuration);
			//}
		//}
	//}
	
}