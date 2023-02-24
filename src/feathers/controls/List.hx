/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.controls.supportClasses.ListDataViewPort;
import feathers.core.FeathersControl;
import feathers.core.IFocusContainer;
import feathers.core.PropertyProxy;
import feathers.core.PropertyProxyReal;
import feathers.data.IListCollection;
import feathers.data.ListCollection;
import feathers.dragDrop.IDragSource;
import feathers.events.CollectionEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.ILayout;
import feathers.layout.ISpinnerLayout;
import feathers.layout.IVariableVirtualLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.utils.math.MathUtils;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.utils.Pool;

import feathers.dragDrop.IDropTarget;

/**
 * Displays a one-dimensional list of items. Supports scrolling, custom
 * item renderers, and custom layouts.
 *
 * <p>Layouts may be, and are highly encouraged to be, <em>virtual</em>,
 * meaning that the List is capable of creating a limited number of item
 * renderers to display a subset of the data provider instead of creating a
 * renderer for every single item. This allows for optimal performance with
 * very large data providers.</p>
 *
 * <p>The following example creates a list, gives it a data provider, tells
 * the item renderer how to interpret the data, and listens for when the
 * selection changes:</p>
 *
 * <listing version="3.0">
 * var list:List = new List();
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
 *     var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
 *     itemRenderer.labelField = "text";
 *     itemRenderer.iconSourceField = "thumbnail";
 *     return itemRenderer;
 * };
 * 
 * list.addEventListener( Event.CHANGE, list_changeHandler );
 * 
 * this.addChild( list );</listing>
 *
 * @see ../../../help/list.html How to use the Feathers List component
 * @see ../../../help/default-item-renderers.html How to use the Feathers default item renderer
 * @see ../../../help/item-renderers.html Creating custom item renderers for the Feathers List and GroupedList components
 * @see feathers.controls.GroupedList
 * @see feathers.controls.SpinnerList
 *
 * @productversion Feathers 1.0.0
 */
class List extends Scroller implements IFocusContainer implements IDragSource implements IDropTarget
{
	/**
	 * @private
	 */
	private static inline var DEFAULT_DRAG_FORMAT:String = "feathers-list-item";

	/**
	 * The default <code>IStyleProvider</code> for all <code>List</code>
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
		this._selectedIndices.addEventListener(Event.CHANGE, selectedIndices_changeHandler);
	}
	
	/**
	 * @private
	 * The guts of the List's functionality. Handles layout and selection.
	 */
	private var dataViewPort:ListDataViewPort;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return List.globalStyleProvider;
	}
	
	override function get_isFocusEnabled():Bool 
	{
		return (this._isSelectable || this._minHorizontalScrollPosition != this._maxHorizontalScrollPosition ||
				this._minVerticalScrollPosition != this._maxVerticalScrollPosition) &&
				this._isEnabled && this._isFocusEnabled;
	}
	
	/**
	 * @copy feathers.core.IFocusContainer#isChildFocusEnabled
	 *
	 * @default true
	 *
	 * @see #isFocusEnabled
	 */
	public var isChildFocusEnabled(get, set):Bool;
	private var _isChildFocusEnabled:Bool = false;
	private function get_isChildFocusEnabled():Bool { return this._isEnabled && this._isChildFocusEnabled; }
	private function set_isChildFocusEnabled(value:Bool):Bool
	{
		return this._isChildFocusEnabled = value;
	}
	
	/**
	 * @private
	 */
	public var layout(get, set):ILayout;
	private var _layout:ILayout;
	private function get_layout():ILayout { return this._layout; }
	private function set_layout(value:ILayout):ILayout
	{
		if (this.processStyleRestriction("layout"))
		{
			return value;
		}
		if (this._layout == value)
		{
			return value;
		}
		if (!Std.isOfType(this, SpinnerList) && Std.isOfType(value, ISpinnerLayout))
		{
			throw new ArgumentError("Layouts that implement the ISpinnerLayout interface should be used with the SpinnerList component.");
		}
		if (this._layout != null)
		{
			this._layout.removeEventListener(Event.SCROLL, layout_scrollHandler);
		}
		this._layout = value;
		if (Std.isOfType(this._layout, IVariableVirtualLayout))
		{
			this._layout.addEventListener(Event.SCROLL, layout_scrollHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._layout;
	}
	
	/**
	 * @private
	 */
	private var _addedItems:Map<Dynamic, Function>;

	/**
	 * @private
	 */
	private var _removedItems:Map<Dynamic, Function>;
	
	/**
	 * The collection of data displayed by the list. Changing this property
	 * to a new value is considered a drastic change to the list's data, so
	 * the horizontal and vertical scroll positions will be reset, and the
	 * list's selection will be cleared.
	 *
	 * <p>The following example passes in a data provider and tells the item
	 * renderer how to interpret the data:</p>
	 *
	 * <listing version="3.0">
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
	 * };</listing>
	 *
	 * <p><em>Warning:</em> A list's data provider cannot contain duplicate
	 * items. To display the same item in multiple item renderers, you must
	 * create separate objects with the same properties. This restriction
	 * exists because it significantly improves performance.</p>
	 *
	 * <p><em>Warning:</em> If the data provider contains display objects,
	 * concrete textures, or anything that needs to be disposed, those
	 * objects will not be automatically disposed when the list is disposed.
	 * Similar to how <code>starling.display.Image</code> cannot
	 * automatically dispose its texture because the texture may be used
	 * by other display objects, a list cannot dispose its data provider
	 * because the data provider may be used by other lists. See the
	 * <code>dispose()</code> function on <code>IListCollection</code> to
	 * see how the data provider can be disposed properly.</p>
	 *
	 * @default null
	 *
	 * @see feathers.data.IListCollection#dispose()
	 * @see feathers.data.ArrayCollection
	 * @see feathers.data.VectorCollection
	 * @see feathers.data.XMLListCollection
	 */
	public var dataProvider(get, set):IListCollection;
	private var _dataProvider:IListCollection;
	private function get_dataProvider():IListCollection { return this._dataProvider; }
	private function set_dataProvider(value:IListCollection):IListCollection
	{
		if (this._dataProvider == value)
		{
			return value;
		}
		if (this._dataProvider != null)
		{
			this._dataProvider.removeEventListener(CollectionEventType.SORT_CHANGE, dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ALL, dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
			this._dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null)
		{
			this._dataProvider.addEventListener(CollectionEventType.SORT_CHANGE, dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ALL, dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
			this._dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
		}
		
		//reset the scroll position because this is a drastic change and
		//the data is probably completely different
		this.horizontalScrollPosition = 0;
		this.verticalScrollPosition = 0;
		
		//clear the selection for the same reason
		this.selectedIndex = -1;
		
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataProvider;
	}
	
	/**
	 * Determines if items in the list may be selected. By default only a
	 * single item may be selected at any given time. In other words, if
	 * item A is selected, and the user selects item B, item A will be
	 * deselected automatically. Set <code>allowMultipleSelection</code>
	 * to <code>true</code> to select more than one item without
	 * automatically deselecting other items.
	 *
	 * <p>The following example disables selection:</p>
	 *
	 * <listing version="3.0">
	 * list.isSelectable = false;</listing>
	 *
	 * @default true
	 *
	 * @see #selectedItem
	 * @see #selectedIndex
	 * @see #allowMultipleSelection
	 */
	public var isSelectable(get, set):Bool;
	private var _isSelectable:Bool = true;
	private function get_isSelectable():Bool { return this._isSelectable; }
	private function set_isSelectable(value:Bool):Bool
	{
		if (this._isSelectable == value)
		{
			return value;
		}
		this._isSelectable = value;
		if (!this._isSelectable)
		{
			this.selectedIndex = -1;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isSelectable;
	}
	
	/**
	 * The index of the currently selected item. Returns <code>-1</code> if
	 * no item is selected.
	 *
	 * <p>The following example selects an item by its index:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndex = 2;</listing>
	 *
	 * <p>The following example clears the selected index:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndex = -1;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected index:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:List = List( event.currentTarget );
	 *     var index:int = list.selectedIndex;
	 *     trace( "change: " + index );
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @default -1
	 *
	 * @see #selectedItem
	 * @see #allowMultipleSelection
	 * @see #selectedItems
	 * @see #selectedIndices
	 */
	public var selectedIndex(get, set):Int;
	private var _selectedIndex:Int = -1;
	private function get_selectedIndex():Int { return this._selectedIndex; }
	private function set_selectedIndex(value:Int):Int
	{
		if (this._selectedIndex == value)
		{
			return value;
		}
		if (value >= 0)
		{
			var indices:Array<Int> = [value];
			this._selectedIndices.data = indices;
		}
		else
		{
			this._selectedIndices.removeAll();
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._selectedIndex;
	}
	
	/**
	 * The currently selected item. Returns <code>null</code> if no item is
	 * selected.
	 *
	 * <p>The following example changes the selected item:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedItem = list.dataProvider.getItemAt(0);</listing>
	 *
	 * <p>The following example clears the selected item:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedItem = null;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected item:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:List = List( event.currentTarget );
	 *     var item:Object = list.selectedItem;
	 *     trace( "change: " + item );
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @default null
	 *
	 * @see #selectedIndex
	 * @see #allowMultipleSelection
	 * @see #selectedItems
	 * @see #selectedIndices
	 */
	public var selectedItem(get, set):Dynamic;
	private function get_selectedItem():Dynamic
	{
		if (this._dataProvider == null || this._selectedIndex < 0 || this._selectedIndex >= this._dataProvider.length)
		{
			return null;
		}
		
		return this._dataProvider.getItemAt(this._selectedIndex);
	}
	
	private function set_selectedItem(value:Dynamic):Dynamic
	{
		if (this._dataProvider == null)
		{
			this.selectedIndex = -1;
			return value;
		}
		this.selectedIndex = this._dataProvider.getItemIndex(value);
		return value;
	}
	
	/**
	 * If <code>true</code> multiple items may be selected at a time. If
	 * <code>false</code>, then only a single item may be selected at a
	 * time, and if the selection changes, other items are deselected. Has
	 * no effect if <code>isSelectable</code> is <code>false</code>.
	 *
	 * <p>In the following example, multiple selection is enabled:</p>
	 *
	 * <listing version="3.0">
	 * list.allowMultipleSelection = true;</listing>
	 *
	 * @default false
	 *
	 * @see #isSelectable
	 * @see #selectedIndices
	 * @see #selectedItems
	 */
	public var allowMultipleSelection(get, set):Bool;
	private var _allowMultipleSelection:Bool = false;
	private function get_allowMultipleSelection():Bool { return this._allowMultipleSelection; }
	private function set_allowMultipleSelection(value:Bool):Bool
	{
		if (this._allowMultipleSelection == value)
		{
			return value;
		}
		this._allowMultipleSelection = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._allowMultipleSelection;
	}
	
	/**
	 * The indices of the currently selected items. Returns an empty <code>Vector.&lt;int&gt;</code>
	 * if no items are selected. If <code>allowMultipleSelection</code> is
	 * <code>false</code>, only one item may be selected at a time.
	 *
	 * <p>The following example selects two items by their indices:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndices = new &lt;int&gt;[ 2, 3 ];</listing>
	 *
	 * <p>The following example clears the selected indices:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndices = null;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected indices:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:List = List( event.currentTarget );
	 *     var indices:Vector.&lt;int&gt; = list.selectedIndices;
	 * 
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @see #allowMultipleSelection
	 * @see #selectedItems
	 * @see #selectedIndex
	 * @see #selectedItem
	 */
	public var selectedIndices(get, set):Array<Int>;
	private var _selectedIndices:ListCollection = new ListCollection(new Array<Int>());
	private function get_selectedIndices():Array<Int> { return cast this._selectedIndices.data; }
	private function set_selectedIndices(value:Array<Int>):Array<Int>
	{
		var oldValue:Array<Int> = cast this._selectedIndices.data;
		if (oldValue == value)
		{
			return value;
		}
		if (value == null)
		{
			if (this._selectedIndices.length == 0)
			{
				return value;
			}
			this._selectedIndices.removeAll();
		}
		else
		{
			if (!this._allowMultipleSelection && value.length > 1)
			{
				value.resize(1);
			}
			this._selectedIndices.data = value;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return value;
	}
	
	/**
	 * The currently selected item. The getter returns an empty
	 * <code>Vector.&lt;Object&gt;</code> if no item is selected. If any
	 * items are selected, the getter creates a new
	 * <code>Vector.&lt;Object&gt;</code> to return a list of selected
	 * items.
	 *
	 * <p>The following example selects two items:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedItems = new &lt;Object&gt;[ list.dataProvider.getItemAt(2) , list.dataProvider.getItemAt(3) ];</listing>
	 *
	 * <p>The following example clears the selected items:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedItems = null;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected items:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:List = List( event.currentTarget );
	 *     var items:Vector.&lt;Object&gt; = list.selectedItems;
	 * 
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @see #allowMultipleSelection
	 * @see #selectedIndices
	 * @see #selectedIndex
	 * @see #selectedItem
	 */
	public var selectedItems(get, set):Array<Dynamic>;
	private var _selectedItems:Array<Dynamic> = new Array<Dynamic>();
	private function get_selectedItems():Array<Dynamic> { return this._selectedItems; }
	private function set_selectedItems(value:Array<Dynamic>):Array<Dynamic>
	{
		if (value == null || this._dataProvider == null)
		{
			this.selectedIndex = -1;
			return value;
		}
		var indices:Array<Int> = new Array<Int>();
		var itemCount:Int = value.length;
		var item:Dynamic;
		var index:Int;
		for (i in 0...itemCount)
		{
			item = value[i];
			index = this._dataProvider.getItemIndex(item);
			if (index != -1)
			{
				indices.push(index);
			}
		}
		this.selectedIndices = indices;
		return this._selectedItems;
	}
	
	/**
	 * Returns the selected items, with the ability to pass in an optional
	 * result vector. Better for performance than the <code>selectedItems</code>
	 * getter because it can avoid the allocation, and possibly garbage
	 * collection, of the result object.
	 *
	 * @see #selectedItems
	 */
	public function getSelectedItems(result:Array<Dynamic> = null):Array<Dynamic>
	{
		if (result != null)
		{
			result.resize(0);
		}
		else
		{
			result = new Array<Dynamic>();
		}
		if (this._dataProvider == null)
		{
			return result;
		}
		var indexCount:Int = this._selectedIndices.length;
		var index:Int;
		var item:Dynamic;
		for (i in 0...indexCount)
		{
			index = cast this._selectedIndices.getItemAt(i);
			item = this._dataProvider.getItemAt(index);
			result[i] = item;
		}
		return result;
	}
	
	/**
	 * The class used to instantiate item renderers. Must implement the
	 * <code>IListItemRenderer</code> interface.
	 *
	 * <p>To customize properties on the item renderer, use
	 * <code>itemRendererFactory</code> instead.</p>
	 *
	 * <p>The following example changes the item renderer type:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererType = CustomItemRendererClass;</listing>
	 *
	 * @default feathers.controls.renderers.DefaultListItemRenderer
	 *
	 * @see feathers.controls.renderers.IListItemRenderer
	 * @see #itemRendererFactory
	 */
	public var itemRendererType(get, set):Class<Dynamic>;
	private var _itemRendererType:Class<Dynamic> = DefaultListItemRenderer;
	private function get_itemRendererType():Class<Dynamic> { return this._itemRendererType; }
	private function set_itemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._itemRendererType == value)
		{
			return value;
		}
		
		this._itemRendererType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._itemRendererType;
	}
	
	/**
	 * @private
	 */
	private var _itemRendererFactories:Map<String, Function>;
	
	/**
	 * A function called that is expected to return a new item renderer. Has
	 * a higher priority than <code>itemRendererType</code>. Typically, you
	 * would use an <code>itemRendererFactory</code> instead of an
	 * <code>itemRendererType</code> if you wanted to initialize some
	 * properties on each separate item renderer, such as skins.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IListItemRenderer</pre>
	 *
	 * <p>The following example provides a factory for the item renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererFactory = function():IListItemRenderer
	 * {
	 *     var renderer:CustomItemRendererClass = new CustomItemRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IListItemRenderer
	 * @see #itemRendererType
	 * @see #setItemRendererFactoryWithID()
	 */
	public var itemRendererFactory(get, set):Function;
	private var _itemRendererFactory:Function;
	private function get_itemRendererFactory():Function { return this._itemRendererFactory; }
	private function set_itemRendererFactory(value:Function):Function
	{
		if (this._itemRendererFactory == value)
		{
			return value;
		}
		
		this._itemRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._itemRendererFactory;
	}
	
	/**
	 * When a list requires multiple item renderer types, this function is
	 * used to determine which type of item renderer is required for a
	 * specific item (or index). Returns the ID of the item renderer type
	 * to use for the item, or <code>null</code> if the default
	 * <code>itemRendererFactory</code> should be used.
	 *
	 * <p>The function is expected to have one of the following
	 * signatures:</p>
	 *
	 * <pre>function(item:Object):String</pre>
	 *
	 * <pre>function(item:Object, index:int):String</pre>
	 *
	 * <p>The following example provides a <code>factoryIDFunction</code>:</p>
	 *
	 * <listing version="3.0">
	 * function regularItemFactory():IListItemRenderer
	 * {
	 *     return new DefaultListItemRenderer();
	 * }
	 * function headerItemFactory():IListItemRenderer
	 * {
	 *     return new CustomItemRenderer();
	 * }
	 * list.setItemRendererFactoryWithID( "regular-item", regularItemFactory );
	 * list.setItemRendererFactoryWithID( "header-item", listHeaderFactory );
	 * 
	 * list.factoryIDFunction = function( item:Object, index:int ):String
	 * {
	 *     if(index == 0)
	 *     {
	 *         return "header-item";
	 *     }
	 *     return "regular-item";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #setItemRendererFactoryWithID()
	 * @see #itemRendererFactory
	 */
	public var factoryIDFunction(get, set):Function;
	private var _factoryIDFunction:Function;
	private function get_factoryIDFunction():Function { return this._factoryIDFunction; }
	private function set_factoryIDFunction(value:Function):Function
	{
		if (this._factoryIDFunction == value)
		{
			return value;
		}
		this._factoryIDFunction = value;
		if (value != null && this._itemRendererFactories == null)
		{
			this._itemRendererFactories = new Map<String, Function>();
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._factoryIDFunction;
	}
	
	/**
	 * Used to auto-size the list when a virtualized layout is used. If the
	 * list's width or height is unknown, the list will try to automatically
	 * pick an ideal size. This item is used to create a sample item
	 * renderer to measure item renderers that are virtual and not visible
	 * in the viewport.
	 *
	 * <p>The following example provides a typical item:</p>
	 *
	 * <listing version="3.0">
	 * list.typicalItem = { text: "A typical item", thumbnail: texture };</listing>
	 *
	 * @default null
	 */
	public var typicalItem(get, set):Dynamic;
	private var _typicalItem:Dynamic;
	private function get_typicalItem():Dynamic { return this._typicalItem; }
	private function set_typicalItem(value:Dynamic):Dynamic
	{
		if (this._typicalItem == value)
		{
			return value;
		}
		this._typicalItem = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._typicalItem;
	}
	
	/**
	 * @private
	 */
	public var customItemRendererStyleName(get, set):String;
	private var _customItemRendererStyleName:String;
	private function get_customItemRendererStyleName():String { return this._customItemRendererStyleName; }
	private function set_customItemRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customItemRendererStyleName"))
		{
			return value;
		}
		if (this._customItemRendererStyleName == value)
		{
			return value;
		}
		this._customItemRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._customItemRendererStyleName;
	}
	
	/**
	 * An object that stores properties for all of the list's item
	 * renderers, and the properties will be passed down to every item
	 * renderer when the list validates. The available properties
	 * depend on which <code>IListItemRenderer</code> implementation is
	 * returned by <code>itemRendererFactory</code>.
	 *
	 * <p>By default, the <code>itemRendererFactory</code> will return a
	 * <code>DefaultListItemRenderer</code> instance. If you aren't using a
	 * custom item renderer, you can refer to
	 * <a href="renderers/DefaultListItemRenderer.html"><code>feathers.controls.renderers.DefaultListItemRenderer</code></a>
	 * for a list of available properties.</p>
	 *
	 * <p>These properties are shared by every item renderer, so anything
	 * that cannot be shared (such as display objects, which cannot be added
	 * to multiple parents) should be passed to item renderers using the
	 * <code>itemRendererFactory</code> or in the theme.</p>
	 *
	 * <p>The following example customizes some item renderer properties
	 * (this example assumes that the item renderer's label text renderer
	 * is a <code>BitmapFontTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererProperties.labelField = "text";
	 * list.itemRendererProperties.accessoryField = "control";</listing>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>itemRendererFactory</code> function
	 * instead of using <code>itemRendererProperties</code> will result in
	 * better performance.</p>
	 *
	 * @default null
	 *
	 * @see #itemRendererFactory
	 * @see feathers.controls.renderers.IListItemRenderer
	 * @see feathers.controls.renderers.DefaultListItemRenderer
	 */
	public var itemRendererProperties(get, set):Dynamic;
	private var _itemRendererProperties:PropertyProxy;
	private function get_itemRendererProperties():Dynamic
	{
		if (this._itemRendererProperties == null)
		{
			this._itemRendererProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._itemRendererProperties;
	}
	
	private function set_itemRendererProperties(value:Dynamic):Dynamic
	{
		if (this._itemRendererProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxyReal))
		{
			value = PropertyProxy.fromObject(value);
		}
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.removeOnChangeCallback(childProperties_onChange);
			this._itemRendererProperties.dispose();
		}
		this._itemRendererProperties = cast value;
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._itemRendererProperties;
	}
	
	/**
	 * @private
	 */
	public var keyScrollDuration(get, set):Float;
	private var _keyScrollDuration:Float = 0.25;
	private function get_keyScrollDuration():Float { return this._keyScrollDuration; }
	private function set_keyScrollDuration(value:Float):Float
	{
		if (this.processStyleRestriction("keyScrollDuration"))
		{
			return value;
		}
		return this._keyScrollDuration = value;
	}
	
	/**
	 * Drag and drop is restricted to components that have the same
	 * <code>dragFormat</code>.
	 *
	 * <p>In the following example, the drag format of two lists is customized:</p>
	 *
	 * <listing version="3.0">
	 * list1.dragFormat = "my-custom-format";
	 * list2.dragFormat = "my-custom-format";</listing>
	 *
	 * @default "feathers-list-item"
	 */
	public var dragFormat(get, set):String;
	private var _dragFormat:String = DEFAULT_DRAG_FORMAT;
	private function get_dragFormat():String { return this._dragFormat; }
	private function set_dragFormat(value:String):String
	{
		if (value == null)
		{
			value = DEFAULT_DRAG_FORMAT;
		}
		if (this._dragFormat == value)
		{
			return value;
		}
		this._dragFormat = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dragFormat;
	}
	
	/**
	 * Indicates if this list can initiate drag and drop operations by
	 * touching an item and dragging it. The <code>dragEnabled</code>
	 * property enables dragging items, but dropping items must be enabled
	 * separately with the <code>dropEnabled</code> property.
	 *
	 * <p>In the following example, a list's items may be dragged:</p>
	 *
	 * <listing version="3.0">
	 * list.dragEnabled = true;</listing>
	 *
	 * @see #dropEnabled
	 * @see #dragFormat
	 */
	public var dragEnabled(get, set):Bool;
	private var _dragEnabled:Bool = false;
	private function get_dragEnabled():Bool { return this._dragEnabled; }
	private function set_dragEnabled(value:Bool):Bool
	{
		if (this._dragEnabled == value)
		{
			return value;
		}
		this._dragEnabled = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dragEnabled;
	}
	
	/**
	 * Indicates if this list can accept items that are dragged and
	 * dropped over the list's hit area.
	 *
	 * <p>In the following example, a list's items may be dropped:</p>
	 *
	 * <listing version="3.0">
	 * list.dropEnabled = true;</listing>
	 *
	 * @see #dragEnabled
	 * @see #dragFormat
	 */
	public var dropEnabled(get, set):Bool;
	private var _dropEnabled:Bool = false;
	private function get_dropEnabled():Bool { return this._dropEnabled; }
	private function set_dropEnabled(value:Bool):Bool
	{
		if (this._dropEnabled == value)
		{
			return value;
		}
		this._dropEnabled = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dropEnabled;
	}
	
	/**
	 * @private
	 */
	public var dropIndicatorSkin(get, set):DisplayObject;
	private var _dropIndicatorSkin:DisplayObject;
	private function get_dropIndicatorSkin():DisplayObject { return this._dropIndicatorSkin; }
	private function set_dropIndicatorSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("dropIndicatorSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		return this._dropIndicatorSkin = value;
	}
	
	/**
	 * The minimum physical distance (in inches) that a touch must be from
	 * the edge of the container during a drag and drop action before the
	 * container starts scrolling.
	 *
	 * <p>In the following example, the minimum auto-scroll distance is customized:</p>
	 *
	 * <listing version="3.0">
	 * scroller.minimumAutoScrollDistance = 0.1;</listing>
	 *
	 * @default 0.3
	 */
	public var minimumAutoScrollDistance(get, set):Float;
	private var _minimumAutoScrollDistance:Float = 0.2;
	private function get_minimumAutoScrollDistance():Float { return this._minimumAutoScrollDistance; }
	private function set_minimumAutoScrollDistance(value:Float):Float
	{
		if (this._minimumAutoScrollDistance == value)
		{
			return value;
		}
		this._minimumAutoScrollDistance = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._minimumAutoScrollDistance;
	}
	
	/**
	 * The pending item index to scroll to after validating. A value of
	 * <code>-1</code> means that the scroller won't scroll to an item after
	 * validating.
	 */
	private var pendingItemIndex:Int = -1;
	
	/**
	 * @private
	 */
	override public function scrollToPosition(horizontalScrollPosition:Float, verticalScrollPosition:Float, animationDuration:Null<Float> = null):Void 
	{
		this.pendingItemIndex = -1;
		super.scrollToPosition(horizontalScrollPosition, verticalScrollPosition, animationDuration);
	}
	
	/**
	 * @private
	 */
	override public function scrollToPageIndex(horizontalPageIndex:Int, verticalPageIndex:Int, animationDuration:Null<Float> = null):Void 
	{
		this.pendingItemIndex = -1;
		super.scrollToPageIndex(horizontalPageIndex, verticalPageIndex, animationDuration);
	}
	
	/**
	 * Scrolls the list so that the specified item is visible. If
	 * <code>animationDuration</code> is greater than zero, the scroll will
	 * animate. The duration is in seconds.
	 *
	 * <p>If the layout is virtual with variable item dimensions, this
	 * function may not accurately scroll to the exact correct position. A
	 * virtual layout with variable item dimensions is often forced to
	 * estimate positions, so the results aren't guaranteed to be accurate.</p>
	 *
	 * <p>If you want to scroll to the end of the list, it is better to use
	 * <code>scrollToPosition()</code> with <code>maxHorizontalScrollPosition</code>
	 * or <code>maxVerticalScrollPosition</code>.</p>
	 *
	 * <p>In the following example, the list is scrolled to display index 10:</p>
	 *
	 * <listing version="3.0">
	 * list.scrollToDisplayIndex( 10 );</listing>
	 *
	 * @param index The integer index of an item from the data provider.
	 * @param animationDuration The length of time, in seconds, of the animation. May be zero to scroll instantly.
	 *
	 * @see #scrollToPosition()
	 */
	public function scrollToDisplayIndex(index:Int, animationDuration:Float = 0):Void
	{
		//cancel any pending scroll to a different page or scroll position.
		//we can have only one type of pending scroll at a time.
		this.hasPendingHorizontalPageIndex = false;
		this.hasPendingVerticalPageIndex = false;
		this.pendingHorizontalScrollPosition = Math.NaN;
		this.pendingVerticalScrollPosition = Math.NaN;
		if (this.pendingItemIndex == index &&
			this.pendingScrollDuration == animationDuration)
		{
			return;
		}
		this.pendingItemIndex = index;
		this.pendingScrollDuration = animationDuration;
		this.invalidate(Scroller.INVALIDATION_FLAG_PENDING_SCROLL);
	}
	
	/**
	 * Returns the item renderer factory associated with a specific ID.
	 * Returns <code>null</code> if no factory is associated with the ID.
	 *
	 * @see #setItemRendererFactoryWithID()
	 */
	public function getItemRendererFactoryWithID(id:String):Function
	{
		if (this._itemRendererFactories != null)// && this._itemRendererFactories.exists(id))
		{
			return this._itemRendererFactories[id];
		}
		return null;
	}
	
	/**
	 * Associates an item renderer factory with an ID to allow multiple
	 * types of item renderers may be displayed in the list. A custom
	 * <code>factoryIDFunction</code> may be specified to return the ID of
	 * the factory to use for a specific item in the data provider.
	 *
	 * @see #factoryIDFunction
	 * @see #getItemRendererFactoryWithID()
	 */
	public function setItemRendererFactoryWithID(id:String, factory:Function):Void
	{
		if (id == null)
		{
			this.itemRendererFactory = factory;
			return;
		}
		if (this._itemRendererFactories == null)
		{
			this._itemRendererFactories = new Map<String, Function>();
		}
		if (factory != null)
		{
			this._itemRendererFactories[id] = factory;
		}
		else
		{
			this._itemRendererFactories.remove(id);
		}
	}
	
	/**
	 * Returns the current item renderer used to render a specific item. May
	 * return <code>null</code> if an item doesn't currently have an item
	 * renderer. Most lists use virtual layouts where only the visible items
	 * will have an item renderer, so the result will usually be
	 * <code>null</code> for most items in the data provider.
	 *
	 * @see ../../../help/faq/layout-virtualization.html What is layout virtualization?
	 */
	public function itemToItemRenderer(item:Dynamic):IListItemRenderer
	{
		return this.dataViewPort.itemToItemRenderer(item);
	}
	
	/**
	 * Adds an item from the data provider and animates its item renderer
	 * using an effect.
	 *
	 * <p>In the following example, an effect fades the item renderer's
	 * <code>alpha</code> property from <code>0</code> to <code>1</code>:</p>
	 *
	 * <listing version="3.0">
	 * list.addItemWithEffect(newItem, list.dataProvider.length, Fade.createFadeBetweenEffect(0, 1));</listing>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>. In the following example, we
	 * recreate the <code>Fade.createFadeBetweenEffect()</code> used in the
	 * previous example.</p>
	 *
	 * <listing version="3.0">
	 * function customEffect(target:DisplayObject):IEffectContext
	 * {
	 *     target.alpha = 0;
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(1);
	 *     return new TweenEffectContext(target, tween);
	 * }
	 * list.addItemWithEffect(newItem, list.dataProvider.length, customEffect);</listing>
	 *
	 * @see #removeItemWithEffect()
	 * @see feathers.data.IListCollection#addItem()
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public function addItemWithEffect(item:Dynamic, index:Int, effect:Function):Void
	{
		//add to the data provider immediately
		this._dataProvider.addItemAt(item, index);
		if (this._addedItems == null)
		{
			this._addedItems = new Map<Dynamic, Function>();
		}
		this._addedItems[item] = effect;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * Removes an item from the data provider <strong>after</strong>
	 * animating its item renderer using an effect.
	 *
	 * <p>In the following example, an effect fades the item renderer's
	 * <code>alpha</code> property to <code>0</code>:</p>
	 *
	 * <listing version="3.0">
	 * list.removeItemWithEffect(newItem, list.dataProvider.length, Fade.createFadeOutEffect());</listing>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>. In the following example, we
	 * recreate the <code>Fade.createFadeOutEffect()</code> used in the
	 * previous example.</p>
	 *
	 * <listing version="3.0">
	 * function customEffect(target:DisplayObject):IEffectContext
	 * {
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(0);
	 *     return new TweenEffectContext(target, tween);
	 * }
	 * list.removeItemWithEffect(newItem, customEffect);</listing>
	 *
	 * @see #addItemWithEffect()
	 * @see feathers.data.IListCollection#removeItem()
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public function removeItemWithEffect(item:Dynamic, effect:Function):Void
	{
		//don't remove from the data provider yet because that will
		//immediately remove the item renderer. we'll wait until the effect
		//finishes instead.
		if (this._removedItems == null)
		{
			this._removedItems = new Map<Dynamic, Function>();
		}
		this._removedItems[item] = effect;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//clearing selection now so that the data provider setter won't
		//cause a selection change that triggers events.
		this._selectedIndices.removeEventListeners();
		this._selectedIndex = -1;
		this.dataProvider = null;
		this.layout = null;
		if (this._itemRendererFactories != null)
		{
			this._itemRendererFactories.clear();
			this._itemRendererFactories = null;
		}
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.dispose();
			this._itemRendererProperties = null;
		}
		if (this._addedItems != null)
		{
			this._addedItems.clear();
			this._addedItems = null;
		}
		if (this._removedItems != null)
		{
			this._removedItems.clear();
			this._removedItems = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		var hasLayout:Bool = this._layout != null;
		
		super.initialize();
		
		if (this.dataViewPort == null)
		{
			this.viewPort = this.dataViewPort = new ListDataViewPort();
			this.dataViewPort.owner = this;
			this.viewPort = this.dataViewPort;
		}
		
		if (!hasLayout)
		{
			if (this._hasElasticEdges &&
				this._verticalScrollPolicy == ScrollPolicy.AUTO &&
				this._scrollBarDisplayMode != ScrollBarDisplayMode.FIXED)
			{
				//so that the elastic edges work even when the max scroll
				//position is 0, similar to iOS.
				this._verticalScrollPolicy = ScrollPolicy.ON;
			}
			
			var layout:VerticalLayout = new VerticalLayout();
			layout.useVirtualLayout = true;
			layout.padding = 0;
			layout.gap = 0;
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
			layout.verticalAlign = VerticalAlign.TOP;
			this.ignoreNextStyleRestriction();
			this.layout = layout;
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		this.refreshDataViewPortProperties();
		super.draw();
	}
	
	/**
	 * @private
	 */
	private function refreshDataViewPortProperties():Void
	{
		this.dataViewPort.isSelectable = this._isSelectable;
		this.dataViewPort.allowMultipleSelection = this._allowMultipleSelection;
		this.dataViewPort.selectedIndices = this._selectedIndices;
		this.dataViewPort.dataProvider = this._dataProvider;
		this.dataViewPort.itemRendererType = this._itemRendererType;
		this.dataViewPort.itemRendererFactory = this._itemRendererFactory;
		this.dataViewPort.itemRendererFactories = this._itemRendererFactories;
		this.dataViewPort.factoryIDFunction = this._factoryIDFunction;
		this.dataViewPort.itemRendererProperties = this._itemRendererProperties;
		this.dataViewPort.customItemRendererStyleName = this._customItemRendererStyleName;
		this.dataViewPort.typicalItem = this._typicalItem;
		this.dataViewPort.layout = this._layout;
		this.dataViewPort.addedItems = this._addedItems;
		this.dataViewPort.removedItems = this._removedItems;
		this.dataViewPort.dragFormat = this._dragFormat;
		this.dataViewPort.dragEnabled = this._dragEnabled;
		this.dataViewPort.dropEnabled = this._dropEnabled;
		this.dataViewPort.dropIndicatorSkin = this._dropIndicatorSkin;
		this.dataViewPort.minimumAutoScrollDistance = this._minimumAutoScrollDistance;
		this._addedItems = null;
		this._removedItems = null;
	}
	
	/**
	 * @private
	 */
	override function handlePendingScroll():Void
	{
		if (this.pendingItemIndex >= 0)
		{
			var item:Dynamic = null;
			if (this._dataProvider != null)
			{
				item = this._dataProvider.getItemAt(this.pendingItemIndex);
			}
			if (item != null)
			{
				var point:Point = Pool.getPoint();
				this.dataViewPort.getScrollPositionForIndex(this.pendingItemIndex, point);
				this.pendingItemIndex = -1;
				
				var targetHorizontalScrollPosition:Float = point.x;
				var targetVerticalScrollPosition:Float = point.y;
				Pool.putPoint(point);
				if (targetHorizontalScrollPosition < this._minHorizontalScrollPosition)
				{
					targetHorizontalScrollPosition = this._minHorizontalScrollPosition;
				}
				else if (targetHorizontalScrollPosition > this._maxHorizontalScrollPosition)
				{
					targetHorizontalScrollPosition = this._maxHorizontalScrollPosition;
				}
				if (targetVerticalScrollPosition < this._minVerticalScrollPosition)
				{
					targetVerticalScrollPosition = this._minVerticalScrollPosition;
				}
				else if (targetVerticalScrollPosition > this._maxVerticalScrollPosition)
				{
					targetVerticalScrollPosition = this._maxVerticalScrollPosition;
				}
				this.throwTo(targetHorizontalScrollPosition, targetVerticalScrollPosition, this.pendingScrollDuration);
			}
		}
		super.handlePendingScroll();
	}
	
	/**
	 * @private
	 */
	override function nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (!this._isSelectable)
		{
			//not selectable, but should scroll
			super.nativeStage_keyDownHandler(event);
			return;
		}
		if (event.isDefaultPrevented())
		{
			return;
		}
		if (this._dataProvider == null)
		{
			return;
		}
		if (this._selectedIndex != -1 && (event.keyCode == Keyboard.SPACE ||
			((event.keyLocation == 4 || DeviceCapabilities.simulateDPad) && event.keyCode == Keyboard.ENTER)))
		{
			this.dispatchEventWith(Event.TRIGGERED, false, this.selectedItem);
		}
		if (event.keyCode == Keyboard.HOME || event.keyCode == Keyboard.END ||
			event.keyCode == Keyboard.PAGE_UP || event.keyCode == Keyboard.PAGE_DOWN ||
			event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN ||
			event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT)
		{
			var newIndex:Int = this.dataViewPort.calculateNavigationDestination(this.selectedIndex, event.keyCode);
			if (this.selectedIndex != newIndex)
			{
				event.preventDefault();
				this.selectedIndex = newIndex;
				var point:Point = Pool.getPoint();
				this.dataViewPort.getNearestScrollPositionForIndex(this.selectedIndex, point);
				this.scrollToPosition(point.x, point.y, this._keyScrollDuration);
				Pool.putPoint(point);
			}
		}
	}
	
	/**
	 * @private
	 */
	// TODO : openfl has no TransformGestureEvent
	//override function stage_gestureDirectionalTapHandler(event:TransformGestureEvent):Void
	//{
		//if (event.isDefaultPrevented())
		//{
			////something else has already handled this event
			//return;
		//}
		//var keyCode:Int = MathUtils.INT_MAX;
		//if (event.offsetY < 0)
		//{
			//keyCode = Keyboard.UP;
		//}
		//else if (event.offsetY > 0)
		//{
			//keyCode = Keyboard.DOWN;
		//}
		//else if (event.offsetX > 0)
		//{
			//keyCode = Keyboard.RIGHT;
		//}
		//else if (event.offsetX < 0)
		//{
			//keyCode = Keyboard.LEFT;
		//}
		//if (keyCode == MathUtils.INT_MAX)
		//{
			//return;
		//}
		//var newIndex:Int = this.dataViewPort.calculateNavigationDestination(this.selectedIndex, keyCode);
		//if (this.selectedIndex != newIndex)
		//{
			//event.stopImmediatePropagation();
			////event.preventDefault();
			//this.selectedIndex = newIndex;
			//var point:Point = Pool.getPoint();
			//this.dataViewPort.getNearestScrollPositionForIndex(this.selectedIndex, point);
			//this.scrollToPosition(point.x, point.y, this._keyScrollDuration);
			//Pool.putPoint(point);
		//}
	//}
	
	/**
	 * @private
	 */
	private function dataProvider_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_resetHandler(event:Event):Void
	{
		this.horizontalScrollPosition = 0;
		this.verticalScrollPosition = 0;
		
		//the entire data provider was replaced. select no item.
		this._selectedIndices.removeAll();
	}
	
	/**
	 * @private
	 */
	private function dataProvider_addItemHandler(event:Event, index:Int):Void
	{
		if (this._selectedIndex == -1)
		{
			return;
		}
		var selectionChanged:Bool = false;
		var newIndices:Array<Int> = new Array<Int>();
		var indexCount:Int = this._selectedIndices.length;
		var currentIndex:Int;
		for (i in 0...indexCount)
		{
			currentIndex = cast this._selectedIndices.getItemAt(i);
			if (currentIndex >= index)
			{
				currentIndex++;
				selectionChanged = true;
			}
			newIndices.push(currentIndex);
		}
		if (selectionChanged)
		{
			this._selectedIndices.data = newIndices;
		}
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeAllHandler(event:Event):Void
	{
		this.selectedIndex = -1;
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeItemHandler(event:Event, index:Int):Void
	{
		if (this._selectedIndex == -1)
		{
			return;
		}
		var selectionChanged:Bool = false;
		var newIndices:Array<Int> = new Array<Int>();
		var indexCount:Int = this._selectedIndices.length;
		var currentIndex:Int;
		for (i in 0...indexCount)
		{
			currentIndex = cast this._selectedIndices.getItemAt(i);
			if (currentIndex == index)
			{
				selectionChanged = true;
			}
			else
			{
				if (currentIndex > index)
				{
					currentIndex--;
					selectionChanged = true;
				}
				newIndices.push(currentIndex);
			}
		}
		if (selectionChanged)
		{
			this._selectedIndices.data = newIndices;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshSelectedIndicesAfterFilterOrSort():Void
	{
		if (this._selectedIndex == -1)
		{
			return;
		}
		var selectionChanged:Bool = false;
		var newIndices:Array<Int> = new Array<Int>();
		var pushIndex:Int = 0;
		var count:Int = this._selectedItems.length;
		var selectedItem:Dynamic;
		var oldIndex:Int;
		var newIndex:Int;
		for (i in 0...count)
		{
			selectedItem = this._selectedItems[i];
			oldIndex = this._selectedIndices.getItemAt(i);
			newIndex = this._dataProvider.getItemIndex(selectedItem);
			if (newIndex != -1)
			{
				if (newIndex != oldIndex)
				{
					//the item was not filtered, but it moved to a new index
					selectionChanged = true;
				}
				newIndices[pushIndex] = newIndex;
				pushIndex++;
			}
			else
			{
				//the item is filtered, so it should not be selected
				selectionChanged = true;
			}
		}
		if (selectionChanged)
		{
			this._selectedIndices.data = newIndices;
		}
	}
	
	/**
	 * @private
	 */
	private function dataProvider_filterChangeHandler(event:Event):Void
	{
		this.refreshSelectedIndicesAfterFilterOrSort();
	}
	
	/**
	 * @private
	 */
	private function dataProvider_sortChangeHandler(event:Event):Void
	{
		this.refreshSelectedIndicesAfterFilterOrSort();
	}
	
	/**
	 * @private
	 */
	private function dataProvider_replaceItemHandler(event:Event, index:Int):Void
	{
		if (this._selectedIndex == -1)
		{
			return;
		}
		var indexOfIndex:Int = this._selectedIndices.getItemIndex(index);
		if (indexOfIndex != -1)
		{
			this._selectedIndices.removeItemAt(indexOfIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function selectedIndices_changeHandler(event:Event):Void
	{
		this.getSelectedItems(this._selectedItems);
		if (this._selectedIndices.length != 0)
		{
			this._selectedIndex = cast this._selectedIndices.getItemAt(0);
		}
		else
		{
			if (this._selectedIndex == -1)
			{
				//no change
				return;
			}
			this._selectedIndex = -1;
		}
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @private
	 */
	private function layout_scrollHandler(event:Event, scrollOffset:Point):Void
	{
		var layout:IVariableVirtualLayout = cast this._layout;
		if (!this.isScrolling || !layout.useVirtualLayout || !layout.hasVariableItemDimensions)
		{
			return;
		}
		
		var scrollOffsetX:Float = scrollOffset.x;
		this._startHorizontalScrollPosition += scrollOffsetX;
		this._horizontalScrollPosition += scrollOffsetX;
		if (this._horizontalAutoScrollTween != null)
		{
			this._targetHorizontalScrollPosition += scrollOffsetX;
			this.throwTo(this._targetHorizontalScrollPosition, Math.NaN, this._horizontalAutoScrollTween.totalTime - this._horizontalAutoScrollTween.currentTime);
		}
		
		var scrollOffsetY:Float = scrollOffset.y;
		this._startVerticalScrollPosition += scrollOffsetY;
		this._verticalScrollPosition += scrollOffsetY;
		if (this._verticalAutoScrollTween != null)
		{
			this._targetVerticalScrollPosition += scrollOffsetY;
			this.throwTo(Math.NaN, this._targetVerticalScrollPosition, this._verticalAutoScrollTween.totalTime - this._verticalAutoScrollTween.currentTime);
		}
	}
	
}