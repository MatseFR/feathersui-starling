/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.renderers.DefaultTreeItemRenderer;
import feathers.controls.renderers.ITreeItemRenderer;
import feathers.controls.supportClasses.TreeDataViewPort;
import feathers.core.FeathersControl;
import feathers.data.ArrayCollection;
import feathers.data.IHierarchicalCollection;
import feathers.events.CollectionEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.ILayout;
import feathers.layout.IVariableVirtualLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.utils.type.TypeUtil;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.events.Event;
import starling.utils.Pool;

/**
 * Displays a hierarchical tree of items. Supports scrolling, custom item
 * renderers, and custom layouts.
 *
 * <p>The following example creates a tree, gives it a data provider, and
 * tells the item renderer how to interpret the data:</p>
 *
 * <listing version="3.0">
 * var tree:Tree = new Tree();
 * 
 * tree.dataProvider = new ArrayHierarchicalCollection(
 * [
 *     {
 *         text: "Node 1",
 *         children:
 *         [
 *             {
 *                 text: "Node 1A",
 *                 children:
 *                 [
 *                     { text: "Node 1A-I" },
 *                     { text: "Node 1A-II" },
 *                 ]
 *             },
 *             { text: "Node 1B" },
 *         ]
 *     },
 *     { text: "Node 2" },
 *     {
 *         text: "Node 3",
 *         children:
 *         [
 *             { text: "Node 3A" },
 *             { text: "Node 3B" },
 *             { text: "Node 3C" },
 *         ]
 *     }
 * ]);
 * 
 * tree.itemRendererFactory = function():ITreeItemRenderer
 * {
 *     var itemRenderer:DefaultTreeItemRenderer = new DefaultTreeItemRenderer();
 *     itemRenderer.labelField = "text";
 *     return itemRenderer;
 * };
 * 
 * this.addChild( tree );</listing>
 *
 * @see ../../../help/tree.html How to use the Feathers Tree component
 * @see ../../../help/default-item-renderers.html How to use the Feathers default item renderer
 * @see ../../../help/item-renderers.html Creating custom item renderers for the Feathers Tree component
 *
 * @productversion Feathers 3.3.0
 */
class Tree extends Scroller 
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>Tree</code>
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
	}
	
	/**
	 * @private
	 * The guts of the Tree's functionality. Handles layout and selection.
	 */
	private var dataViewPort:TreeDataViewPort;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Tree.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override function get_isFocusEnabled():Bool
	{
		return (this._isSelectable || this._minHorizontalScrollPosition != this._maxHorizontalScrollPosition ||
			this._minVerticalScrollPosition != this._maxVerticalScrollPosition) &&
			this._isEnabled && this._isFocusEnabled;
	}
	
	/**
	 * The collection of data displayed by the tree. Changing this property
	 * to a new value is considered a drastic change to the tree's data, so
	 * the horizontal and vertical scroll positions will be reset, and the
	 * tree's selection will be cleared.
	 *
	 * <p>The following example passes in a data provider and tells the item
	 * renderer how to interpret the data:</p>
	 *
	 * <listing version="3.0">
	 * tree.dataProvider = new ArrayHierarchicalCollection(
	 * [
	 *     {
	 *         text: "Node 1",
	 *         children:
	 *         [
	 *             {
	 *                 text: "Node 1A",
	 *                 children:
	 *                 [
	 *                     { text: "Node 1A-I" },
	 *                     { text: "Node 1A-II" },
	 *                 ]
	 *             },
	 *             { text: "Node 1B" },
	 *         ]
	 *     },
	 *     { text: "Node 2" },
	 *     {
	 *         text: "Node 3",
	 *         children:
	 *         [
	 *             { text: "Node 3A" },
	 *             { text: "Node 3B" },
	 *             { text: "Node 3C" },
	 *         ]
	 *     }
	 * ]);
	 * 
	 * tree.itemRendererFactory = function():ITreeItemRenderer
	 * {
	 *     var itemRenderer:DefaultTreeItemRenderer = new DefaultTreeItemRenderer();
	 *     itemRenderer.labelField = "text";
	 *     return itemRenderer;
	 * };</listing>
	 *
	 * <p><em>Warning:</em> A tree's data provider cannot contain duplicate
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
	 * <code>dispose()</code> function on <code>IHierarchicalCollection</code> to
	 * see how the data provider can be disposed properly.</p>
	 *
	 * @default null
	 *
	 * @see feathers.data.IHierarchicalCollection#dispose()
	 * @see feathers.data.ArrayHierarchicalCollection
	 * @see feathers.data.VectorHierarchicalCollection
	 * @see feathers.data.XMLListHierarchicalCollection
	 */
	public var dataProvider(get, set):IHierarchicalCollection;
	private var _dataProvider:IHierarchicalCollection;
	private function get_dataProvider():IHierarchicalCollection { return this._dataProvider; }
	private function set_dataProvider(value:IHierarchicalCollection):IHierarchicalCollection
	{
		if (this._dataProvider == value)
		{
			return value;
		}
		if (this._dataProvider != null)
		{
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ALL, dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
			this._dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null)
		{
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
		this.selectedItem = null;
		
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataProvider;
	}
	
	/**
	 * Determines if an item in the tree may be selected.
	 *
	 * <p>The following example disables selection:</p>
	 *
	 * <listing version="3.0">
	 * tree.isSelectable = false;</listing>
	 *
	 * @default true
	 *
	 * @see #selectedItem
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
			this.selectedItem = null;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isSelectable;
	}
	
	/**
	 * @private
	 */
	private var _helperLocation:Array<Int> = new Array<Int>();
	
	/**
	 * The currently selected location. Returns an empty
	 * <code>Vector.&lt;int&gt;</code> if no item is selected.
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected location:</p>
	 *
	 * <listing version="3.0">
	 * function tree_changeHandler( event:Event ):void
	 * {
	 *     var tree:Tree = Tree( event.currentTarget );
	 *     var location:Vector.&lt;int&gt; = tree.selectedLocation;
	 * 
	 * }
	 * tree.addEventListener( Event.CHANGE, tree_changeHandler );</listing>
	 *
	 * <p>Alternatively, you may use the <code>getSelectedLocation()</code>
	 * method to get the selected location without creating a new
	 * <code>Vector.&lt;int&gt;</code> instance, to avoid garbage
	 * collection of temporary objects.</p>
	 *
	 * @see #getSelectedLocation()
	 */
	public var selectedLocation(get, set):Array<Int>;
	private function get_selectedLocation():Array<Int> { return this.getSelectedLocation(); }
	private function set_selectedLocation(value:Array<Int>):Array<Int>
	{
		this.selectedItem = this._dataProvider.getItemAtLocation(value);
		return value;
	}
	
	/**
	 * The currently selected item. Returns <code>null</code> if no item is
	 * selected.
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected item:</p>
	 *
	 * <listing version="3.0">
	 * function tree_changeHandler( event:Event ):void
	 * {
	 *     var tree:Tree = Tree( event.currentTarget );
	 *     var item:Object = tree.selectedItem;
	 * 
	 * }
	 * tree.addEventListener( Event.CHANGE, tree_changeHandler );</listing>
	 *
	 * @default null
	 */
	public var selectedItem(get, set):Dynamic;
	private var _selectedItem:Dynamic;
	private function get_selectedItem():Dynamic { return this._selectedItem; }
	private function set_selectedItem(value:Dynamic):Dynamic
	{
		if (this._selectedItem == value)
		{
			return value;
		}
		if (this._dataProvider == null)
		{
			value = null;
		}
		if (value != null)
		{
			var result:Array<Int> = this._dataProvider.getItemLocation(value, this._helperLocation);
			if (result == null || result.length == 0)
			{
				value = null;
			}
		}
		if (this._selectedItem == value)
		{
			return value;
		}
		this._selectedItem = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
		return this._selectedItem;
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
	 * The class used to instantiate item renderers. Must implement the
	 * <code>ITreeItemRenderer</code> interface.
	 *
	 * <p>To customize properties on the item renderer, use
	 * <code>itemRendererFactory</code> instead.</p>
	 *
	 * <p>The following example changes the item renderer type:</p>
	 *
	 * <listing version="3.0">
	 * tree.itemRendererType = CustomItemRendererClass;</listing>
	 *
	 * @default feathers.controls.renderers.DefaultTreeItemRenderer
	 *
	 * @see feathers.controls.renderers.ITreeItemRenderer
	 * @see #itemRendererFactory
	 */
	public var itemRendererType(get, set):Class<Dynamic>;
	private var _itemRendererType:Class<Dynamic> = DefaultTreeItemRenderer;
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
	private var _itemRendererFactories:Map<String, Void->ITreeItemRenderer>;
	
	/**
	 * A function called that is expected to return a new item renderer. Has
	 * a higher priority than <code>itemRendererType</code>. Typically, you
	 * would use an <code>itemRendererFactory</code> instead of an
	 * <code>itemRendererType</code> if you wanted to initialize some
	 * properties on each separate item renderer, such as skins.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():ITreeItemRenderer</pre>
	 *
	 * <p>The following example provides a factory for the item renderer:</p>
	 *
	 * <listing version="3.0">
	 * tree.itemRendererFactory = function():ITreeItemRenderer
	 * {
	 *     var renderer:CustomItemRendererClass = new CustomItemRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.ITreeItemRenderer
	 * @see #itemRendererType
	 * @see #setItemRendererFactoryWithID()
	 */
	public var itemRendererFactory(get, set):Void->ITreeItemRenderer;
	private var _itemRendererFactory:Void->ITreeItemRenderer;
	private function get_itemRendererFactory():Void->ITreeItemRenderer { return this._itemRendererFactory; }
	private function set_itemRendererFactory(value:Void->ITreeItemRenderer):Void->ITreeItemRenderer
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
	 * When a tree requires multiple item renderer types, this function is
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
	 * <pre>function(item:Object, location:Vector.&lt;int&gt;):String</pre>
	 *
	 * <p>The following example provides a <code>factoryIDFunction</code>:</p>
	 *
	 * <listing version="3.0">
	 * function regularItemFactory():ITreeItemRenderer
	 * {
	 *     return new DefaultTreeItemRenderer();
	 * }
	 * function firstItemFactory():ITreeItemRenderer
	 * {
	 *     return new CustomItemRenderer();
	 * }
	 * tree.setItemRendererFactoryWithID( "regular-item", regularItemFactory );
	 * tree.setItemRendererFactoryWithID( "first-item", firstItemFactory );
	 * 
	 * tree.factoryIDFunction = function( item:Object, location:Vector.&lt;int&gt; ):String
	 * {
	 *     if(location.length == 1 &amp;&amp; location[0] == 0)
	 *     {
	 *         return "first-item";
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
			this._itemRendererFactories = new Map<String, Void->ITreeItemRenderer>();
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._factoryIDFunction;
	}
	
	/**
	 * Used to auto-size the tree when a virtualized layout is used. If the
	 * tree's width or height is unknown, the tree will try to automatically
	 * pick an ideal size. This item is used to create a sample item
	 * renderer to measure item renderers that are virtual and not visible
	 * in the viewport.
	 *
	 * <p>The following example provides a typical item:</p>
	 *
	 * <listing version="3.0">
	 * tree.typicalItem = { text: "A typical item", thumbnail: texture };</listing>
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
		if (this._keyScrollDuration == value)
		{
			return value;
		}
		return this._keyScrollDuration = value;
	}
	
	/**
	 * @private
	 */
	private var pendingLocation:Array<Int> = null;

	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//clearing selection now so that the data provider setter won't
		//cause a selection change that triggers events.
		this._selectedItem = null;
		this.dataProvider = null;
		this.layout = null;
		if (this._itemRendererFactories != null)
		{
			this._itemRendererFactories.clear();
		}
		super.dispose();
	}
	
	/**
	 * Returns the item renderer factory associated with a specific ID.
	 * Returns <code>null</code> if no factory is associated with the ID.
	 *
	 * @see #setItemRendererFactoryWithID()
	 */
	public function getItemRendererFactoryWithID(id:String):Void->ITreeItemRenderer
	{
		if (this._itemRendererFactories != null && this._itemRendererFactories.exists(id))
		{
			return this._itemRendererFactories[id];
		}
		return null;
	}
	
	/**
	 * Associates an item renderer factory with an ID to allow multiple
	 * types of item renderers may be displayed in the tree. A custom
	 * <code>factoryIDFunction</code> may be specified to return the ID of
	 * the factory to use for a specific item in the data provider.
	 *
	 * @see #factoryIDFunction
	 * @see #getItemRendererFactoryWithID()
	 */
	public function setItemRendererFactoryWithID(id:String, factory:Void->ITreeItemRenderer):Void
	{
		if (id == null)
		{
			this.itemRendererFactory = factory;
			return;
		}
		if (this._itemRendererFactories == null)
		{
			this._itemRendererFactories = new Map<String, Void->ITreeItemRenderer>();
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
	 * renderer. Most trees use virtual layouts where only the visible items
	 * will have an item renderer, so the result will usually be
	 * <code>null</code> for most items in the data provider.
	 *
	 * @see ../../../help/faq/layout-virtualization.html What is layout virtualization?
	 */
	public function itemToItemRenderer(item:Dynamic):ITreeItemRenderer
	{
		return this.dataViewPort.itemToItemRenderer(item);
	}
	
	/**
	 * @private
	 */
	private var _openBranches:ArrayCollection = new ArrayCollection();
	
	/**
	 * Opens or closes a branch.
	 *
	 * @see #isBranchOpen()
	 * @see #event:open starling.events.Event.OPEN
	 * @see #event:close starling.events.Event.CLOSE
	 */
	public function toggleBranch(branch:Dynamic, open:Bool):Void
	{
		if (this._dataProvider == null || !this._dataProvider.isBranch(branch))
		{
			throw new ArgumentError("toggleBranch() may not open an item that is not a branch.");
		}
		var index:Int = this._openBranches.getItemIndex(branch);
		if (open)
		{
			if (index != -1)
			{
				//the branch is already open
				return;
			}
			this._openBranches.addItem(branch);
			this.dispatchEventWith(Event.OPEN, false, branch);
		}
		else //close
		{
			if (index == -1)
			{
				//the branch is already closed
				return;
			}
			this._openBranches.removeItem(branch);
			this.dispatchEventWith(Event.CLOSE, false, branch);
		}
	}
	
	/**
	 * Indicates if a branch from the data provider is open or closed.
	 *
	 * @see #toggleBranch()
	 * @see #event:open starling.events.Event.OPEN
	 * @see #event:close starling.events.Event.CLOSE
	 */
	public function isBranchOpen(branch:Dynamic):Bool
	{
		if (this._dataProvider == null || !this._dataProvider.isBranch(branch))
		{
			return false;
		}
		return this._openBranches.getItemIndex(branch) != -1;
	}
	
	/**
	 * Returns the currently selected location, or an empty
	 * <code>Vector.&lt;int&gt;</code>, if no item is currently selected.
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected location:</p>
	 *
	 * <listing version="3.0">
	 * function tree_changeHandler( event:Event ):void
	 * {
	 *     var tree:Tree = Tree( event.currentTarget );
	 *     var result:Vector.&lt;int&gt; = new &lt;int&gt;[];
	 *     var location:Vector.&lt;int&gt; = tree.getSelectedLocation(result);
	 * }
	 * tree.addEventListener( Event.CHANGE, tree_changeHandler );</listing>
	 *
	 * @see #selectedItem
	 * @see #selectedLocation
	 */
	public function getSelectedLocation(result:Array<Int> = null):Array<Int>
	{
		if (result == null)
		{
			result = new Array<Int>();
		}
		else
		{
			result.resize(0);
		}
		if (this._dataProvider == null || this._selectedItem == null)
		{
			return result;
		}
		return this._dataProvider.getItemLocation(this._selectedItem, result);
	}
	
	/**
	 * @private
	 */
	override public function scrollToPosition(horizontalScrollPosition:Float, verticalScrollPosition:Float, ?animationDuration:Float):Void
	{
		if (animationDuration == null) animationDuration = Math.NaN;
		this.pendingLocation = null;
		super.scrollToPosition(horizontalScrollPosition, verticalScrollPosition, animationDuration);
	}

	/**
	 * @private
	 */
	override public function scrollToPageIndex(horizontalPageIndex:Int, verticalPageIndex:Int, ?animationDuration:Float):Void
	{
		if (animationDuration == null) animationDuration = Math.NaN;
		this.pendingLocation = null;
		super.scrollToPageIndex(horizontalPageIndex, verticalPageIndex, animationDuration);
	}
	
	/**
	 * After the next validation, scrolls the list so that the specified
	 * item is visible. If <code>animationDuration</code> is greater than
	 * zero, the scroll will animate. The duration is in seconds.
	 *
	 * <p>In the following example, the list is scrolled to display the
	 * third item in the second branch:</p>
	 *
	 * <listing version="3.0">
	 * tree.scrollToDisplayLocation( new &lt;int&gt;[1, 2] );</listing>
	 */
	public function scrollToDisplayLocation(location:Array<Int>, animationDuration:Float = 0):Void
	{
		//cancel any pending scroll to a different page or scroll position.
		//we can have only one type of pending scroll at a time.
		this.hasPendingHorizontalPageIndex = false;
		this.hasPendingVerticalPageIndex = false;
		this.pendingHorizontalScrollPosition = Math.NaN;
		this.pendingVerticalScrollPosition = Math.NaN;
		if (this.pendingLocation != null &&
			this.pendingLocation.length == location.length &&
			this.pendingScrollDuration == animationDuration)
		{
			//var locationsEqual:Bool = this.pendingLocation.every(function(item:int, index:int, source:Vector.<int>):Boolean
			//{
				//return item == location[index];
			//});
			var locationsEqual:Bool = true;
			var count:Int = this.pendingLocation.length;
			for (i in 0...count)
			{
				if (this.pendingLocation[i] != location[i])
				{
					locationsEqual = false;
					break;
				}
			}
			
			if (locationsEqual)
			{
				return;
			}
		}
		this.pendingLocation = location;
		this.pendingScrollDuration = animationDuration;
		this.invalidate(Scroller.INVALIDATION_FLAG_PENDING_SCROLL);
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
			this.viewPort = this.dataViewPort = new TreeDataViewPort();
			this.dataViewPort.owner = this;
			this.dataViewPort.addEventListener(Event.CHANGE, dataViewPort_changeHandler);
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
	override function handlePendingScroll():Void
	{
		if (this.pendingLocation != null)
		{
			var pendingData:Dynamic = null;
			if (this._dataProvider != null)
			{
				pendingData = this._dataProvider.getItemAtLocation(this.pendingLocation);
			}
			if (TypeUtil.isObject(pendingData))
			{
				var point:Point = Pool.getPoint();
				var result:Point = this.dataViewPort.getScrollPositionForLocation(this.pendingLocation, point);
				this.pendingLocation = null;
				if (result == null)
				{
					//we can't scroll to that location...
					//probably because the branch isn't open!
					Pool.putPoint(point);
				}
				else
				{
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
		}
		super.handlePendingScroll();
	}
	
	/**
	 * @private
	 */
	private function refreshDataViewPortProperties():Void
	{
		this.dataViewPort.isSelectable = this._isSelectable;
		this.dataViewPort.selectedItem = this._selectedItem;
		this.dataViewPort.dataProvider = this._dataProvider;
		this.dataViewPort.typicalItem = this._typicalItem;
		this.dataViewPort.openBranches = this._openBranches;
		
		this.dataViewPort.itemRendererType = this._itemRendererType;
		this.dataViewPort.itemRendererFactory = this._itemRendererFactory;
		this.dataViewPort.itemRendererFactories = this._itemRendererFactories;
		this.dataViewPort.factoryIDFunction = this._factoryIDFunction;
		this.dataViewPort.customItemRendererStyleName = this._customItemRendererStyleName;
		
		this.dataViewPort.layout = this._layout;
	}
	
	/**
	 * @private
	 */
	private function validateSelectedItemIsInCollection():Void
	{
		if (this._selectedItem == null)
		{
			return;
		}
		var selectedItemLocation:Array<Int> = this._dataProvider.getItemLocation(this._selectedItem, this._helperLocation);
		if (selectedItemLocation == null || selectedItemLocation.length == 0)
		{
			this.selectedItem = null;
		}
	}
	
	/**
	 * @private
	 */
	private function dataViewPort_changeHandler(event:Event):Void
	{
		this.selectedItem = this.dataViewPort.selectedItem;
	}

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
		this.selectedItem = null;
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeAllHandler(event:Event):Void
	{
		this.selectedItem = null;
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeItemHandler(event:Event, indices:Array<Int>):Void
	{
		this.validateSelectedItemIsInCollection();
	}

	/**
	 * @private
	 */
	private function dataProvider_filterChangeHandler(event:Event):Void
	{
		this.validateSelectedItemIsInCollection();
	}

	/**
	 * @private
	 */
	private function dataProvider_replaceItemHandler(event:Event, indices:Array<Int>):Void
	{
		this.validateSelectedItemIsInCollection();
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
		if (this._selectedItem != null &&
			(event.keyCode == Keyboard.SPACE ||
			((event.keyLocation == 4 || DeviceCapabilities.simulateDPad) && event.keyCode == Keyboard.ENTER)))
		{
			this.dispatchEventWith(Event.TRIGGERED, false, this.selectedItem);
		}
	}
	
}