/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.IGroupedListFooterRenderer;
import feathers.controls.renderers.IGroupedListHeaderRenderer;
import feathers.controls.renderers.IGroupedListItemRenderer;
import feathers.controls.supportClasses.GroupedListDataViewPort;
import feathers.core.FeathersControl;
import feathers.core.IFocusContainer;
import feathers.core.PropertyProxy;
import feathers.data.IHierarchicalCollection;
import feathers.events.CollectionEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.ILayout;
import feathers.layout.IVariableVirtualLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.events.Event;
import starling.utils.Pool;

/**
 * Displays a list of items divided into groups or sections. Takes a
 * hierarchical provider limited to two levels of hierarchy. This component
 * supports scrolling, custom item (and header and footer) renderers, and
 * custom layouts.
 *
 * <p>Layouts may be, and are highly encouraged to be, <em>virtual</em>,
 * meaning that the List is capable of creating a limited number of item
 * renderers to display a subset of the data provider instead of creating a
 * renderer for every single item. This allows for optimal performance with
 * very large data providers.</p>
 *
 * <p>The following example creates a grouped list, gives it a data
 * provider, tells the item renderer how to interpret the data, and listens
 * for when the selection changes:</p>
 *
 * <listing version="3.0">
 * var list:GroupedList = new GroupedList();
 * 
 * list.dataProvider = new ArrayHierarchicalCollection(
 * [
 *     {
 *         header: "Dairy",
 *         children:
 *         [
 *             { text: "Milk", thumbnail: textureAtlas.getTexture( "milk" ) },
 *             { text: "Cheese", thumbnail: textureAtlas.getTexture( "cheese" ) },
 *         ]
 *     },
 *     {
 *         header: "Bakery",
 *         children:
 *         [
 *             { text: "Bread", thumbnail: textureAtlas.getTexture( "bread" ) },
 *         ]
 *     },
 *     {
 *         header: "Produce",
 *         children:
 *         [
 *             { text: "Bananas", thumbnail: textureAtlas.getTexture( "bananas" ) },
 *             { text: "Lettuce", thumbnail: textureAtlas.getTexture( "lettuce" ) },
 *             { text: "Onion", thumbnail: textureAtlas.getTexture( "onion" ) },
 *         ]
 *     },
 * ]);
 * 
 * list.itemRendererFactory = function():IGroupedListItemRenderer
 * {
 *     var renderer:DefaultGroupedListItemRenderer = new DefaultGroupedListItemRenderer();
 *     renderer.labelField = "text";
 *     renderer.iconSourceField = "thumbnail";
 *     return renderer;
 * };
 * 
 * list.addEventListener( Event.CHANGE, list_changeHandler );
 * 
 * this.addChild( list );</listing>
 *
 * @see ../../../help/grouped-list.html How to use the Feathers GroupedList component
 * @see ../../../help/default-item-renderers.html How to use the Feathers default item renderer
 * @see ../../../help/item-renderers.html Creating custom item renderers for the Feathers List and GroupedList components
 * @see feathers.controls.List
 *
 * @productversion Feathers 1.0.0
 */
class GroupedList extends Scroller implements IFocusContainer
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>GroupedList</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * An alternate style name to use with <code>GroupedList</code> to allow
	 * a theme to give it an inset style. If a theme does not provide a
	 * style for an inset grouped list, the theme will automatically fall
	 * back to using the default grouped list style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the inset style is applied to a grouped
	 * list:</p>
	 *
	 * <listing version="3.0">
	 * var list:GroupedList = new GroupedList();
	 * list.styleNameList.add( GroupedList.ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST );
	 * this.addChild( list );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST:String = "feathers-inset-grouped-list";
	
	/**
	 * The default name to use with header renderers.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_HEADER_RENDERER:String = "feathers-grouped-list-header-renderer";
	
	/**
	 * An alternate name to use with header renderers to give them an inset
	 * style. This name is usually only referenced inside themes.
	 *
	 * <p>In the following example, the inset style is applied to a grouped
	 * list's header:</p>
	 *
	 * <listing version="3.0">
	 * list.customHeaderRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER;</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER:String = "feathers-grouped-list-inset-header-renderer";
	
	/**
	 * The default name to use with footer renderers.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_FOOTER_RENDERER:String = "feathers-grouped-list-footer-renderer";
	
	/**
	 * An alternate name to use with footer renderers to give them an inset
	 * style. This name is usually only referenced inside themes.
	 *
	 * <p>In the following example, the inset style is applied to a grouped
	 * list's footer:</p>
	 *
	 * <listing version="3.0">
	 * list.customFooterRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER;</listing>
	 */
	public static inline var ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER:String = "feathers-grouped-list-inset-footer-renderer";
	
	/**
	 * An alternate name to use with item renderers to give them an inset
	 * style. This name is usually only referenced inside themes.
	 *
	 * <p>In the following example, the inset style is applied to a grouped
	 * list's item renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.customItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER;</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER:String = "feathers-grouped-list-inset-item-renderer";
	
	/**
	 * An alternate name to use for item renderers to give them an inset
	 * style. Typically meant to be used for the renderer of the first item
	 * in a group. This name is usually only referenced inside themes.
	 *
	 * <p>In the following example, the inset style is applied to a grouped
	 * list's first item renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.customFirstItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FIRST_ITEM_RENDERER;</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_CHILD_STYLE_NAME_INSET_FIRST_ITEM_RENDERER:String = "feathers-grouped-list-inset-first-item-renderer";
	
	/**
	 * An alternate name to use for item renderers to give them an inset
	 * style. Typically meant to be used for the renderer of the last item
	 * in a group. This name is usually only referenced inside themes.
	 *
	 * <p>In the following example, the inset style is applied to a grouped
	 * list's last item renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.customLastItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_LAST_ITEM_RENDERER;</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_CHILD_STYLE_NAME_INSET_LAST_ITEM_RENDERER:String = "feathers-grouped-list-inset-last-item-renderer";
	
	/**
	 * An alternate name to use for item renderers to give them an inset
	 * style. Typically meant to be used for the renderer of an item in a
	 * group that has no other items. This name is usually only referenced
	 * inside themes.
	 *
	 * <p>In the following example, the inset style is applied to a grouped
	 * list's single item renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.customSingleItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_SINGLE_ITEM_RENDERER;</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_CHILD_STYLE_NAME_INSET_SINGLE_ITEM_RENDERER:String = "feathers-grouped-list-inset-single-item-renderer";
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * @private
	 * The guts of the List's functionality. Handles layout and selection.
	 */
	private var dataViewPort:GroupedListDataViewPort;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return GroupedList.globalStyleProvider;
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
	 * @copy feathers.core.IFocusContainer#isChildFocusEnabled
	 *
	 * @default true
	 *
	 * @see #isFocusEnabled
	 */
	public var isChildFocusEnabled(get, set):Bool;
	private var _isChildFocusEnabled:Bool = true;
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
	 * The collection of data displayed by the list. Changing this property
	 * to a new value is considered a drastic change to the list's data, so
	 * the horizontal and vertical scroll positions will be reset, and the
	 * list's selection will be cleared.
	 *
	 * <p>The following example passes in a data provider and tells the item
	 * renderer how to interpret the data:</p>
	 *
	 * <listing version="3.0">
	 * list.dataProvider = new ArrayHierarchicalCollection(
	 * [
	 *     {
	 *     	   header: "Dairy",
	 *     	   children:
	 *     	   [
	 *     	       { text: "Milk", thumbnail: textureAtlas.getTexture( "milk" ) },
	 *     	       { text: "Cheese", thumbnail: textureAtlas.getTexture( "cheese" ) },
	 *     	   ]
	 *     },
	 *     {
	 *         header: "Bakery",
	 *         children:
	 *         [
	 *             { text: "Bread", thumbnail: textureAtlas.getTexture( "bread" ) },
	 *         ]
	 *     },
	 *     {
	 *         header: "Produce",
	 *         children:
	 *         [
	 *             { text: "Bananas", thumbnail: textureAtlas.getTexture( "bananas" ) },
	 *             { text: "Lettuce", thumbnail: textureAtlas.getTexture( "lettuce" ) },
	 *             { text: "Onion", thumbnail: textureAtlas.getTexture( "onion" ) },
	 *         ]
	 *     },
	 * ]);
	 * 
	 * list.itemRendererFactory = function():IGroupedListItemRenderer
	 * {
	 *     var renderer:DefaultGroupedListItemRenderer = new DefaultGroupedListItemRenderer();
	 *     renderer.labelField = "text";
	 *     renderer.iconSourceField = "thumbnail";
	 *     return renderer;
	 * };</listing>
	 *
	 * <p><em>Warning:</em> A grouped list's data provider cannot contain
	 * duplicate items. To display the same item in multiple item renderers,
	 * you must create separate objects with the same properties. This
	 * restriction exists because it significantly improves performance.</p>
	 *
	 * <p><em>Warning:</em> If the data provider contains display objects,
	 * concrete textures, or anything that needs to be disposed, those
	 * objects will not be automatically disposed when the grouped list is
	 * disposed. Similar to how <code>starling.display.Image</code> cannot
	 * automatically dispose its texture because the texture may be used
	 * by other display objects, a list cannot dispose its data provider
	 * because the data provider may be used by other lists. See the
	 * <code>dispose()</code> function on <code>IHierarchicalCollection</code>
	 * to see how the data provider can be disposed properly.</p>
	 *
	 * @default null
	 *
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
		this.setSelectedLocation(-1, -1);
		
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataProvider;
	}
	
	/**
	 * Determines if an item in the list may be selected.
	 *
	 * <p>The following example disables selection:</p>
	 *
	 * <listing version="3.0">
	 * list.isSelectable = false;</listing>
	 *
	 * @default true
	 *
	 * @see #selectedItem
	 * @see #selectedGroupIndex
	 * @see #selectedItemIndex
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
			this.setSelectedLocation(-1, -1);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isSelectable;
	}
	
	/**
	 * @private
	 */
	private var _helperLocation:Array<Int> = new Array<Int>();
	
	/**
	 * The group index of the currently selected item. Returns <code>-1</code>
	 * if no item is selected.
	 *
	 * <p>Because the selection consists of both a group index and an item
	 * index, this property does not have a setter. To change the selection,
	 * call <code>setSelectedLocation()</code> instead.</p>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected group index and selected item index:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:List = GroupedList(event.currentTarget);
	 *     var groupIndex:int = list.selectedGroupIndex;
	 *     var itemIndex:int = list.selectedItemIndex;
	 * 
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @default -1
	 *
	 * @see #selectedItemIndex
	 * @see #setSelectedLocation()
	 */
	public var selectedGroupIndex(get, never):Int;
	private var _selectedGroupIndex:Int = -1;
	private function get_selectedGroupIndex():Int { return this._selectedGroupIndex; }
	
	/**
	 * The item index of the currently selected item. Returns <code>-1</code>
	 * if no item is selected.
	 *
	 * <p>Because the selection consists of both a group index and an item
	 * index, this property does not have a setter. To change the selection,
	 * call <code>setSelectedLocation()</code> instead.</p>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected group index and selected item index:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:GroupedList = GroupedList( event.currentTarget );
	 *     var groupIndex:int = list.selectedGroupIndex;
	 *     var itemIndex:int = list.selectedItemIndex;
	 * 
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @default -1
	 *
	 * @see #selectedGroupIndex
	 * @see #setSelectedLocation()
	 */
	public var selectedItemIndex(get, never):Int;
	private var _selectedItemIndex:Int = -1;
	private function get_selectedItemIndex():Int { return this._selectedItemIndex; }
	
	/**
	 * The currently selected item. Returns <code>null</code> if no item is
	 * selected.
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected item:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:GroupedList = GroupedList( event.currentTarget );
	 *     var item:Object = list.selectedItem;
	 * 
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
	 *
	 * @default null
	 */
	public var selectedItem(get, set):Dynamic;
	private function get_selectedItem():Dynamic
	{
		if (this._dataProvider == null || this._selectedGroupIndex < 0 || this._selectedItemIndex < 0)
		{
			return null;
		}
		this._helperLocation.resize(2);
		this._helperLocation[0] = this._selectedGroupIndex;
		this._helperLocation[1] = this._selectedItemIndex;
		//var result:Dynamic = this._dataProvider.getItemAt(this._selectedGroupIndex, this._selectedItemIndex);
		var result:Dynamic = this._dataProvider.getItemAt(this._helperLocation);
		this._helperLocation.resize(0);
		return result;
	}
	
	private function set_selectedItem(value:Dynamic):Dynamic
	{
		if (this._dataProvider == null)
		{
			this.setSelectedLocation(-1, -1);
			return value;
		}
		var result:Array<Int> = this._dataProvider.getItemLocation(value);
		if (result.length == 2)
		{
			this.setSelectedLocation(result[0], result[1]);
		}
		else
		{
			this.setSelectedLocation(-1, -1);
		}
		return value;
	}
	
	/**
	 * The class used to instantiate item renderers. Must implement the
	 * <code>IGroupedListItemRenderer</code> interface.
	 *
	 * <p>To customize properties on the item renderer, use
	 * <code>itemRendererFactory</code> instead.</p>
	 *
	 * <p>The following example changes the item renderer type:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererType = CustomItemRendererClass;</listing>
	 *
	 * <p>The first item and last item in a group may optionally use
	 * different item renderer types, if desired. Use the
	 * <code>firstItemRendererType</code> and <code>lastItemRendererType</code>,
	 * respectively. Additionally, if a group contains only one item, it may
	 * also have a different type. Use the <code>singleItemRendererType</code>.
	 * Finally, factories for each of these types may also be customized.</p>
	 *
	 * @default feathers.controls.renderers.DefaultGroupedListItemRenderer
	 *
	 * @see feathers.controls.renderers.IGroupedListItemRenderer
	 * @see #itemRendererFactory
	 * @see #firstItemRendererType
	 * @see #lastItemRendererType
	 * @see #singleItemRendererType
	 */
	public var itemRendererType(get, set):Class<Dynamic>;
	private var _itemRendererType:Class<Dynamic> = DefaultGroupedListItemRenderer;
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
	 * <pre>function():IGroupedListItemRenderer</pre>
	 *
	 * <p>The following example provides a factory for the item renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererFactory = function():IGroupedListItemRenderer
	 * {
	 *     var renderer:CustomItemRendererClass = new CustomItemRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * <p>The first item and last item in a group may optionally use
	 * different item renderer factories, if desired. Use the
	 * <code>firstItemRendererFactory</code> and <code>lastItemRendererFactory</code>,
	 * respectively. Additionally, if a group contains only one item, it may
	 * also have a different factory. Use the <code>singleItemRendererFactory</code>.</p>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IGroupedListItemRenderer
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
	 * <pre>function(item:Object, groupIndex:int, itemIndex:int):String</pre>
	 *
	 * <p>The following example provides a <code>factoryIDFunction</code>:</p>
	 *
	 * <listing version="3.0">
	 * function regularItemFactory():IGroupedListItemRenderer
	 * {
	 *     return new DefaultGroupedListItemRenderer();
	 * }
	 * function firstItemFactory():IGroupedListItemRenderer
	 * {
	 *     return new CustomItemRenderer();
	 * }
	 * list.setItemRendererFactoryWithID( "regular-item", regularItemFactory );
	 * list.setItemRendererFactoryWithID( "first-item", firstItemFactory );
	 * 
	 * list.factoryIDFunction = function( item:Object, groupIndex:int, itemIndex:int ):String
	 * {
	 *     if(index == 0)
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
	 * depend on which <code>IGroupedListItemRenderer</code> implementation
	 * is returned by <code>itemRendererFactory</code>.
	 *
	 * <p>By default, the <code>itemRendererFactory</code> will return a
	 * <code>DefaultGroupedListItemRenderer</code> instance. If you aren't
	 * using a custom item renderer, you can refer to
	 * <a href="renderers/DefaultGroupedListItemRenderer.html"><code>feathers.controls.renderers.DefaultGroupedListItemRenderer</code></a>
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
	 * <p>Setting properties in a <code>itemRendererFactory</code> function instead
	 * of using <code>itemRendererProperties</code> will result in better
	 * performance.</p>
	 *
	 * @default null
	 *
	 * @see #itemRendererFactory
	 * @see feathers.controls.renderers.IGroupedListItemRenderer
	 * @see feathers.controls.renderers.DefaultGroupedListItemRenderer
	 */
	public var itemRendererProperties(get, set):PropertyProxy;
	private var _itemRendererProperties:PropertyProxy;
	private function get_itemRendererProperties():PropertyProxy
	{
		if (this._itemRendererProperties == null)
		{
			this._itemRendererProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._itemRendererProperties;
	}
	
	private function set_itemRendererProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._itemRendererProperties == value)
		{
			return value;
		}
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.dispose();
		}
		this._itemRendererProperties = value;
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._itemRendererProperties;
	}
	
	/**
	 * The class used to instantiate the item renderer for the first item in
	 * a group. Must implement the <code>IGroupedListItemRenderer</code>
	 * interface.
	 *
	 * <p>The following example changes the first item renderer type:</p>
	 *
	 * <listing version="3.0">
	 * list.firstItemRendererType = CustomItemRendererClass;</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderer.IGroupedListItemRenderer
	 * @see #itemRendererType
	 * @see #lastItemRendererType
	 * @see #singleItemRendererType
	 */
	public var firstItemRendererType(get, set):Class<Dynamic>;
	private var _firstItemRendererType:Class<Dynamic>;
	private function get_firstItemRendererType():Class<Dynamic> { return this._firstItemRendererType; }
	private function set_firstItemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._firstItemRendererType == value)
		{
			return value;
		}
		
		this._firstItemRendererType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._firstItemRendererType;
	}
	
	/**
	 * A function called that is expected to return a new item renderer for
	 * the first item in a group. Has a higher priority than
	 * <code>firstItemRendererType</code>. Typically, you would use an
	 * <code>firstItemRendererFactory</code> instead of an
	 * <code>firstItemRendererType</code> if you wanted to initialize some
	 * properties on each separate item renderer, such as skins.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IGroupedListItemRenderer</pre>
	 *
	 * <p>The following example provides a factory for the item renderer
	 * used for the first item in a group:</p>
	 *
	 * <listing version="3.0">
	 * list.firstItemRendererFactory = function():IGroupedListItemRenderer
	 * {
	 *     var renderer:CustomItemRendererClass = new CustomItemRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IGroupedListItemRenderer
	 * @see #firstItemRendererType
	 * @see #itemRendererFactory
	 * @see #lastItemRendererFactory
	 * @see #singleItemRendererFactory
	 */
	public var firstItemRendererFactory(get, set):Function;
	private var _firstItemRendererFactory:Function;
	private function get_firstItemRendererFactory():Function { return this._firstItemRendererFactory; }
	private function set_firstItemRendererFactory(value:Function):Function
	{
		if (this._firstItemRendererFactory == value)
		{
			return value;
		}
		
		this._firstItemRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._firstItemRendererFactory;
	}
	
	/**
	 * @private
	 */
	public var customFirstItemRendererStyleName(get, set):String;
	private var _customFirstItemRendererStyleName:String;
	private function get_customFirstItemRendererStyleName():String { return this._customFirstItemRendererStyleName; }
	private function set_customFirstItemRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customFirstItemRendererStyleName"))
		{
			return value;
		}
		if (this._customFirstItemRendererStyleName == value)
		{
			return value;
		}
		this._customFirstItemRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._customFirstItemRendererStyleName;
	}
	
	/**
	 * The class used to instantiate the item renderer for the last item in
	 * a group. Must implement the <code>IGroupedListItemRenderer</code>
	 * interface.
	 *
	 * <p>The following example changes the last item renderer type:</p>
	 *
	 * <listing version="3.0">
	 * list.lastItemRendererType = CustomItemRendererClass;</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderer.IGroupedListItemRenderer
	 * @see #lastItemRendererFactory
	 * @see #itemRendererType
	 * @see #firstItemRendererType
	 * @see #singleItemRendererType
	 */
	public var lastItemRendererType(get, set):Class<Dynamic>;
	private var _lastItemRendererType:Class<Dynamic>;
	private function get_lastItemRendererType():Class<Dynamic> { return this._lastItemRendererType; }
	private function set_lastItemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._lastItemRendererType == value)
		{
			return value;
		}
		
		this._lastItemRendererType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._lastItemRendererType;
	}
	
	/**
	 * A function called that is expected to return a new item renderer for
	 * the last item in a group. Has a higher priority than
	 * <code>lastItemRendererType</code>. Typically, you would use an
	 * <code>lastItemRendererFactory</code> instead of an
	 * <code>lastItemRendererType</code> if you wanted to initialize some
	 * properties on each separate item renderer, such as skins.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IGroupedListItemRenderer</pre>
	 *
	 * <p>The following example provides a factory for the item renderer
	 * used for the last item in a group:</p>
	 *
	 * <listing version="3.0">
	 * list.firstItemRendererFactory = function():IGroupedListItemRenderer
	 * {
	 *     var renderer:CustomItemRendererClass = new CustomItemRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IGroupedListItemRenderer
	 * @see #lastItemRendererType
	 * @see #itemRendererFactory
	 * @see #firstItemRendererFactory
	 * @see #singleItemRendererFactory
	 */
	public var lastItemRendererFactory(get, set):Function;
	private var _lastItemRendererFactory:Function;
	private function get_lastItemRendererFactory():Function { return this._lastItemRendererFactory; }
	private function set_lastItemRendererFactory(value:Function):Function
	{
		if (this._lastItemRendererFactory == value)
		{
			return value;
		}
		
		this._lastItemRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._lastItemRendererFactory;
	}
	
	/**
	 * @private
	 */
	public var customLastItemRendererStyleName(get, set):String;
	private var _customLastItemRendererStyleName:String;
	private function get_customLastItemRendererStyleName():String { return this._customLastItemRendererStyleName; }
	private function set_customLastItemRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customLastItemRendererStyleName"))
		{
			return value;
		}
		if (this._customLastItemRendererStyleName == value)
		{
			return value;
		}
		this._customLastItemRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._customLastItemRendererStyleName;
	}
	
	/**
	 * The class used to instantiate the item renderer for an item in a
	 * group with no other items. Must implement the
	 * <code>IGroupedListItemRenderer</code> interface.
	 *
	 * <p>The following example changes the single item renderer type:</p>
	 *
	 * <listing version="3.0">
	 * list.singleItemRendererType = CustomItemRendererClass;</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderer.IGroupedListItemRenderer
	 * @see #singleItemRendererFactory
	 * @see #itemRendererType
	 * @see #firstItemRendererType
	 * @see #lastItemRendererType
	 */
	public var singleItemRendererType(get, set):Class<Dynamic>;
	private var _singleItemRendererType:Class<Dynamic>;
	private function get_singleItemRendererType():Class<Dynamic> { return this._singleItemRendererType; }
	private function set_singleItemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._singleItemRendererType == value)
		{
			return value;
		}
		
		this._singleItemRendererType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._singleItemRendererType;
	}
	
	/**
	 * A function called that is expected to return a new item renderer for
	 * an item in a group with no other items. Has a higher priority than
	 * <code>singleItemRendererType</code>. Typically, you would use an
	 * <code>singleItemRendererFactory</code> instead of an
	 * <code>singleItemRendererType</code> if you wanted to initialize some
	 * properties on each separate item renderer, such as skins.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IGroupedListItemRenderer</pre>
	 *
	 * <p>The following example provides a factory for the item renderer
	 * used for when only one item appears in a group:</p>
	 *
	 * <listing version="3.0">
	 * list.firstItemRendererFactory = function():IGroupedListItemRenderer
	 * {
	 *     var renderer:CustomItemRendererClass = new CustomItemRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IGroupedListItemRenderer
	 * @see #singleItemRendererType
	 * @see #itemRendererFactory
	 * @see #firstItemRendererFactory
	 * @see #lastItemRendererFactory
	 */
	public var singleItemRendererFactory(get, set):Function;
	private var _singleItemRendererFactory:Function;
	private function get_singleItemRendererFactory():Function { return this._singleItemRendererFactory; }
	private function set_singleItemRendererFactory(value:Function):Function
	{
		if (this._singleItemRendererFactory == value)
		{
			return value;
		}
		
		this._singleItemRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._singleItemRendererFactory;
	}
	
	/**
	 * @private
	 */
	public var customSingleItemRendererStyleName(get, set):String;
	private var _customSingleItemRendererStyleName:String;
	private function get_customSingleItemRendererStyleName():String { return this._customSingleItemRendererStyleName; }
	private function set_customSingleItemRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customSingleItemRendererStyleName"))
		{
			return value;
		}
		if (this._customSingleItemRendererStyleName == value)
		{
			return value;
		}
		this._customSingleItemRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._customSingleItemRendererStyleName;
	}
	
	/**
	 * The class used to instantiate header renderers. Must implement the
	 * <code>IGroupedListHeaderOrFooterRenderer</code> interface.
	 *
	 * <p>The following example changes the header renderer type:</p>
	 *
	 * <listing version="3.0">
	 * list.headerRendererType = CustomHeaderRendererClass;</listing>
	 *
	 * @default feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer
	 *
	 * @see feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer
	 * @see #headerRendererFactory
	 */
	public var headerRendererType(get, set):Class<Dynamic>;
	private var _headerRendererType:Class<Dynamic> = DefaultGroupedListHeaderOrFooterRenderer;
	private function get_headerRendererType():Class<Dynamic> { return this._headerRendererType; }
	private function set_headerRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._headerRendererType == value)
		{
			return value;
		}
		
		this._headerRendererType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerRendererType;
	}
	
	/**
	 * @private
	 */
	private var _headerRendererFactories:Map<String, Function>;
	
	/**
	 * A function called that is expected to return a new header renderer.
	 * Has a higher priority than <code>headerRendererType</code>.
	 * Typically, you would use an <code>headerRendererFactory</code>
	 * instead of a <code>headerRendererType</code> if you wanted to
	 * initialize some properties on each separate header renderer, such as
	 * skins.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IGroupedListHeaderOrFooterRenderer</pre>
	 *
	 * <p>The following example provides a factory for the header renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererFactory = function():IGroupedListHeaderOrFooterRenderer
	 * {
	 *     var renderer:CustomHeaderRendererClass = new CustomHeaderRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer
	 * @see #headerRendererType
	 * @see #setHeaderRendererFactoryWithID()
	 */
	public var headerRendererFactory(get, set):Function;
	private var _headerRendererFactory:Function;
	private function get_headerRendererFactory():Function { return this._headerRendererFactory; }
	private function set_headerRendererFactory(value:Function):Function
	{
		if (this._headerRendererFactory == value)
		{
			return value;
		}
		
		this._headerRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerRendererFactory;
	}
	
	/**
	 * When a list requires multiple header renderer types, this function is
	 * used to determine which type of header renderer is required for a
	 * specific header (or group index). Returns the ID of the factory
	 * to use for the header, or <code>null</code> if the default
	 * <code>headerRendererFactory</code> should be used.
	 *
	 * <p>The function is expected to have one of the following
	 * signatures:</p>
	 *
	 * <pre>function(header:Object):String</pre>
	 *
	 * <pre>function(header:Object, groupIndex:int):String</pre>
	 *
	 * <p>The following example provides a <code>headerFactoryIDFunction</code>:</p>
	 *
	 * <listing version="3.0">
	 * function regularHeaderFactory():IGroupedListHeaderRenderer
	 * {
	 *     return new DefaultGroupedListHeaderOrFooterRenderer();
	 * }
	 * function customHeaderFactory():IGroupedListHeaderRenderer
	 * {
	 *     return new CustomHeaderRenderer();
	 * }
	 * list.setHeaderRendererFactoryWithID( "regular-header", regularHeaderFactory );
	 * list.setHeaderRendererFactoryWithID( "custom-header", customHeaderFactory );
	 * 
	 * list.headerFactoryIDFunction = function( header:Object, groupIndex:int ):String
	 * {
	 *     //check if the subTitle property exists in the header data
	 *     if( "subTitle" in header )
	 *     {
	 *         return "custom-header";
	 *     }
	 *     return "regular-header";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #setHeaderRendererFactoryWithID()
	 * @see #headerRendererFactory
	 */
	public var headerFactoryIDFunction(get, set):Function;
	private var _headerFactoryIDFunction:Function;
	private function get_headerFactoryIDFunction():Function { return this._headerFactoryIDFunction; }
	private function set_headerFactoryIDFunction(value:Function):Function
	{
		if (this._headerFactoryIDFunction == value)
		{
			return value;
		}
		this._headerFactoryIDFunction = value;
		if (value != null && this._headerRendererFactories == null)
		{
			this._headerRendererFactories = new Map<String, Function>();
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerFactoryIDFunction;
	}
	
	/**
	 * @private
	 */
	public var customHeaderRendererStyleName(get, set):String;
	private var _customHeaderRendererStyleName:String = DEFAULT_CHILD_STYLE_NAME_HEADER_RENDERER;
	private function get_customHeaderRendererStyleName():String { return this._customHeaderRendererStyleName; }
	private function set_customHeaderRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customHeaderRendererStyleName"))
		{
			return value;
		}
		if (this._customHeaderRendererStyleName == value)
		{
			return value;
		}
		this._customHeaderRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._customHeaderRendererStyleName;
	}
	
	/**
	 * An object that stores properties for all of the list's header
	 * renderers, and the properties will be passed down to every header
	 * renderer when the list validates. The available properties
	 * depend on which <code>IGroupedListHeaderOrFooterRenderer</code>
	 * implementation is returned by <code>headerRendererFactory</code>.
	 *
	 * <p>By default, the <code>headerRendererFactory</code> will return a
	 * <code>DefaultGroupedListHeaderOrFooterRenderer</code> instance. If
	 * you aren't using a custom header renderer, you can refer to
	 * <a href="renderers/DefaultGroupedListHeaderOrFooterRenderer.html"><code>feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer</code></a>
	 * for a list of available properties.</p>
	 *
	 * <p>These properties are shared by every header renderer, so anything
	 * that cannot be shared (such as display objects, which cannot be added
	 * to multiple parents) should be passed to header renderers using the
	 * <code>headerRendererFactory</code> or in the theme.</p>
	 *
	 * <p>The following example customizes some header renderer properties:</p>
	 *
	 * <listing version="3.0">
	 * list.headerRendererProperties.contentLabelField = "headerText";
	 * list.headerRendererProperties.contentLabelStyleName = "custom-header-renderer-content-label";</listing>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>headerRendererFactory</code> function instead
	 * of using <code>headerRendererProperties</code> will result in better
	 * performance.</p>
	 *
	 * @default null
	 *
	 * @see #headerRendererFactory
	 * @see feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer
	 * @see feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer
	 */
	public var headerRendererProperties(get, set):PropertyProxy;
	private var _headerRendererProperties:PropertyProxy;
	private function get_headerRendererProperties():PropertyProxy
	{
		if (this._headerRendererProperties == null)
		{
			this._headerRendererProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._headerRendererProperties;
	}
	
	private function set_headerRendererProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._headerRendererProperties == value)
		{
			return value;
		}
		if (this._headerRendererProperties != null)
		{
			this._headerRendererProperties.dispose();
		}
		this._headerRendererProperties = value;
		if (this._headerRendererProperties != null)
		{
			this._headerRendererProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerRendererProperties;
	}
	
	/**
	 * The class used to instantiate footer renderers. Must implement the
	 * <code>IGroupedListHeaderOrFooterRenderer</code> interface.
	 *
	 * <p>The following example changes the footer renderer type:</p>
	 *
	 * <listing version="3.0">
	 * list.footerRendererType = CustomFooterRendererClass;</listing>
	 *
	 * @default feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer
	 *
	 * @see feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer
	 * @see #footerRendererFactory
	 */
	public var footerRendererType(get, set):Class<Dynamic>;
	private var _footerRendererType:Class<Dynamic> = DefaultGroupedListHeaderOrFooterRenderer;
	private function get_footerRendererType():Class<Dynamic> { return this._footerRendererType; }
	private function set_footerRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._footerRendererType == value)
		{
			return value;
		}
		
		this._footerRendererType = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._footerRendererType;
	}
	
	/**
	 * @private
	 */
	private var _footerRendererFactories:Map<String, Function>;
	
	/**
	 * A function called that is expected to return a new footer renderer.
	 * Has a higher priority than <code>footerRendererType</code>.
	 * Typically, you would use an <code>footerRendererFactory</code>
	 * instead of a <code>footerRendererType</code> if you wanted to
	 * initialize some properties on each separate footer renderer, such as
	 * skins.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IGroupedListHeaderOrFooterRenderer</pre>
	 *
	 * <p>The following example provides a factory for the footer renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererFactory = function():IGroupedListHeaderOrFooterRenderer
	 * {
	 *     var renderer:CustomFooterRendererClass = new CustomFooterRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer
	 * @see #footerRendererType
	 * @see #setFooterRendererFactoryWithID()
	 */
	public var footerRendererFactory(get, set):Function;
	private var _footerRendererFactory:Function;
	private function get_footerRendererFactory():Function { return this._footerRendererFactory; }
	private function set_footerRendererFactory(value:Function):Function
	{
		if (this._footerRendererFactory == value)
		{
			return value;
		}
		
		this._footerRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._footerRendererFactory;
	}
	
	/**
	 * When a list requires multiple footer renderer types, this function is
	 * used to determine which type of footer renderer is required for a
	 * specific footer (or group index). Returns the ID of the factory
	 * to use for the footer, or <code>null</code> if the default
	 * <code>footerRendererFactory</code> should be used.
	 *
	 * <p>The function is expected to have one of the following
	 * signatures:</p>
	 *
	 * <pre>function(footer:Object):String</pre>
	 *
	 * <pre>function(footer:Object, groupIndex:int):String</pre>
	 *
	 * <p>The following example provides a <code>footerFactoryIDFunction</code>:</p>
	 *
	 * <listing version="3.0">
	 * function regularFooterFactory():IGroupedListFooterRenderer
	 * {
	 *     return new DefaultGroupedListHeaderOrFooterRenderer();
	 * }
	 * function customFooterFactory():IGroupedListFooterRenderer
	 * {
	 *     return new CustomFooterRenderer();
	 * }
	 * list.setFooterRendererFactoryWithID( "regular-footer", regularFooterFactory );
	 * list.setFooterRendererFactoryWithID( "custom-footer", customFooterFactory );
	 * 
	 * list.footerFactoryIDFunction = function( footer:Object, groupIndex:int ):String
	 * {
	 *     //check if the footerAccessory property exists in the footer data
	 *     if( "footerAccessory" in footer )
	 *     {
	 *         return "custom-footer";
	 *     }
	 *     return "regular-footer";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #setFooterRendererFactoryWithID()
	 * @see #footerRendererFactory
	 */
	public var footerFactoryIDFunction(get, set):Function;
	private var _footerFactoryIDFunction:Function;
	private function get_footerFactoryIDFunction():Function { return this._footerFactoryIDFunction; }
	private function set_footerFactoryIDFunction(value:Function):Function
	{
		if (this._footerFactoryIDFunction == value)
		{
			return value;
		}
		this._footerFactoryIDFunction = value;
		if (value != null && this._footerRendererFactories == null)
		{
			this._footerRendererFactories = new Map<String, Function>();
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._footerFactoryIDFunction;
	}
	
	/**
	 * @private
	 */
	public var customFooterRendererStyleName(get, set):String;
	private var _customFooterRendererStyleName:String;
	private function get_customFooterRendererStyleName():String { return this._customFooterRendererStyleName; }
	private function set_customFooterRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customFooterRendererStyleName"))
		{
			return value;
		}
		if (this._customFooterRendererStyleName == value)
		{
			return value;
		}
		this._customFooterRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._customFooterRendererStyleName;
	}
	
	/**
	 * An object that stores properties for all of the list's footer
	 * renderers, and the properties will be passed down to every footer
	 * renderer when the list validates. The available properties
	 * depend on which <code>IGroupedListHeaderOrFooterRenderer</code>
	 * implementation is returned by <code>footerRendererFactory</code>.
	 *
	 * <p>By default, the <code>footerRendererFactory</code> will return a
	 * <code>DefaultGroupedListHeaderOrFooterRenderer</code> instance. If
	 * you aren't using a custom footer renderer, you can refer to
	 * <a href="renderers/DefaultGroupedListHeaderOrFooterRenderer.html"><code>feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer</code></a>
	 * for a list of available properties.</p>
	 *
	 * <p>These properties are shared by every footer renderer, so anything
	 * that cannot be shared (such as display objects, which cannot be added
	 * to multiple parents) should be passed to footer renderers using the
	 * <code>footerRendererFactory</code> or in the theme.</p>
	 *
	 * <p>The following example customizes some footer renderer properties:</p>
	 *
	 * <listing version="3.0">
	 * list.footerRendererProperties.contentLabelField = "footerText";
	 * list.footerRendererProperties.contentLabelStyleName = "custom-footer-renderer-content-label";</listing>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>footerRendererFactory</code> function instead
	 * of using <code>footerRendererProperties</code> will result in better
	 * performance.</p>
	 *
	 * @default null
	 *
	 * @see #footerRendererFactory
	 * @see feathers.controls.renderers.IGroupedListHeaderOrFooterRenderer
	 * @see feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer
	 */
	public var footerRendererProperties(get, set):PropertyProxy;
	private var _footerRendererProperties:PropertyProxy;
	private function get_footerRendererProperties():PropertyProxy
	{
		if (this._footerRendererProperties == null)
		{
			this._footerRendererProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._footerRendererProperties;
	}
	
	private function set_footerRendererProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._footerRendererProperties == value)
		{
			return value;
		}
		//if (!Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._footerRendererProperties != null)
		{
			this._footerRendererProperties.dispose();
		}
		this._footerRendererProperties = value;
		if (this._footerRendererProperties != null)
		{
			this._footerRendererProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._footerRendererProperties;
	}
	
	/**
	 * The field in a group that contains the data for a header. If the
	 * group does not have this field, and a <code>headerFunction</code> is
	 * not defined, then no header will be displayed for the group. In other
	 * words, a header is optional, and a group may not have one.
	 *
	 * <p>All of the header fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>headerFunction</code></li>
	 *     <li><code>headerField</code></li>
	 * </ol>
	 *
	 * <p>The following example sets the header field:</p>
	 *
	 * <listing version="3.0">
	 * list.headerField = "alphabet";</listing>
	 *
	 * @default "header"
	 *
	 * @see #headerFunction
	 */
	public var headerField(get, set):String;
	private var _headerField:String = "header";
	private function get_headerField():String { return this._headerField; }
	private function set_headerField(value:String):String
	{
		if (this._headerField == value)
		{
			return value;
		}
		this._headerField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._headerField;
	}
	
	/**
	 * A function used to generate header data for a specific group. If this
	 * function is not null, then the <code>headerField</code> will be
	 * ignored.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Object</pre>
	 *
	 * <p>All of the header fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>headerFunction</code></li>
	 *     <li><code>headerField</code></li>
	 * </ol>
	 *
	 * <p>The following example sets the header function:</p>
	 *
	 * <listing version="3.0">
	 * list.headerFunction = function( group:Object ):Object
	 * {
	 *    return group.header;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #headerField
	 */
	public var headerFunction(get, set):Function;
	private var _headerFunction:Function;
	private function get_headerFunction():Function { return this._headerFunction; }
	private function set_headerFunction(value:Function):Function
	{
		if (this._headerFunction == value)
		{
			return value;
		}
		this._headerFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._headerFunction;
	}
	
	/**
	 * The field in a group that contains the data for a footer. If the
	 * group does not have this field, and a <code>footerFunction</code> is
	 * not defined, then no footer will be displayed for the group. In other
	 * words, a footer is optional, and a group may not have one.
	 *
	 * <p>All of the footer fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>footerFunction</code></li>
	 *     <li><code>footerField</code></li>
	 * </ol>
	 *
	 * <p>The following example sets the footer field:</p>
	 *
	 * <listing version="3.0">
	 * list.footerField = "controls";</listing>
	 *
	 * @default "footer"
	 *
	 * @see #footerFunction
	 */
	public var footerField(get, set):String;
	private var _footerField:String = "footer";
	private function get_footerField():String { return this._footerField; }
	private function set_footerField(value:String):String
	{
		if (this._footerField == value)
		{
			return value;
		}
		this._footerField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._footerField;
	}
	
	/**
	 * A function used to generate footer data for a specific group. If this
	 * function is not null, then the <code>footerField</code> will be
	 * ignored.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Object</pre>
	 *
	 * <p>All of the footer fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>footerFunction</code></li>
	 *     <li><code>footerField</code></li>
	 * </ol>
	 *
	 * <p>The following example sets the footer function:</p>
	 *
	 * <listing version="3.0">
	 * list.footerFunction = function( group:Object ):Object
	 * {
	 *    return group.footer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #footerField
	 */
	public var footerFunction(get, set):Function;
	private var _footerFunction:Function;
	private function get_footerFunction():Function { return this._footerFunction; }
	private function set_footerFunction(value:Function):Function
	{
		if (this._footerFunction == value)
		{
			return value;
		}
		this._footerFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._footerFunction;
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
	 * The pending group index to scroll to after validating. A value of
	 * <code>-1</code> means that the scroller won't scroll to a group after
	 * validating.
	 */
	private var pendingGroupIndex:Int = -1;

	/**
	 * The pending item index to scroll to after validating. A value of
	 * <code>-1</code> means that the scroller won't scroll to an item after
	 * validating.
	 */
	private var pendingItemIndex:Int = -1;

	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//clearing selection now so that the data provider setter won't
		//cause a selection change that triggers events.
		this._selectedGroupIndex = -1;
		this._selectedItemIndex = -1;
		this.dataProvider = null;
		this.layout = null;
		if (this._footerRendererFactories != null)
		{
			this._footerRendererFactories.clear();
			this._footerRendererFactories = null;
		}
		if (this._headerRendererFactories != null)
		{
			this._headerRendererFactories.clear();
			this._headerRendererFactories = null;
		}
		if (this._itemRendererFactories != null)
		{
			this._itemRendererFactories.clear();
			this._itemRendererFactories = null;
		}
		if (this._footerRendererProperties != null)
		{
			this._footerRendererProperties.dispose();
			this._footerRendererProperties = null;
		}
		if (this._headerRendererProperties != null)
		{
			this._headerRendererProperties.dispose();
			this._headerRendererProperties = null;
		}
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.dispose();
			this._itemRendererProperties = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override public function scrollToPosition(horizontalScrollPosition:Float, verticalScrollPosition:Float, animationDuration:Null<Float> = null):Void
	{
		if (animationDuration == null) animationDuration = Math.NaN;
		
		this.pendingItemIndex = -1;
		super.scrollToPosition(horizontalScrollPosition, verticalScrollPosition, animationDuration);
	}

	/**
	 * @private
	 */
	override public function scrollToPageIndex(horizontalPageIndex:Int, verticalPageIndex:Int, animationDuration:Null<Float> = null):Void
	{
		if (animationDuration == null) animationDuration = Math.NaN;
		
		this.pendingGroupIndex = -1;
		this.pendingItemIndex = -1;
		super.scrollToPageIndex(horizontalPageIndex, verticalPageIndex, animationDuration);
	}
	
	/**
	 * After the next validation, scrolls the list so that the specified
	 * item is visible. If <code>animationDuration</code> is greater than
	 * zero, the scroll will animate. The duration is in seconds.
	 *
	 * <p>The <code>itemIndex</code> parameter is optional. If set to
	 * <code>-1</code>, the list will scroll to the start of the specified
	 * group.</p>
	 *
	 * <p>In the following example, the list is scrolled to display the
	 * third item in the second group:</p>
	 *
	 * <listing version="3.0">
	 * list.scrollToDisplayIndex( 1, 2 );</listing>
	 *
	 * <p>In the following example, the list is scrolled to display the
	 * third group:</p>
	 *
	 * <listing version="3.0">
	 * list.scrollToDisplayIndex( 2 );</listing>
	 */
	public function scrollToDisplayIndex(groupIndex:Int, itemIndex:Int = -1, animationDuration:Float = 0):Void
	{
		//cancel any pending scroll to a different page or scroll position.
		//we can have only one type of pending scroll at a time.
		this.hasPendingHorizontalPageIndex = false;
		this.hasPendingVerticalPageIndex = false;
		this.pendingHorizontalScrollPosition = Math.NaN;
		this.pendingVerticalScrollPosition = Math.NaN;
		if (this.pendingGroupIndex == groupIndex &&
			this.pendingItemIndex == itemIndex &&
			this.pendingScrollDuration == animationDuration)
		{
			return;
		}
		this.pendingGroupIndex = groupIndex;
		this.pendingItemIndex = itemIndex;
		this.pendingScrollDuration = animationDuration;
		this.invalidate(Scroller.INVALIDATION_FLAG_PENDING_SCROLL);
	}
	
	/**
	 * Sets the selected group and item index.
	 *
	 * <p>In the following example, the third item in the second group
	 * is selected:</p>
	 *
	 * <listing version="3.0">
	 * list.setSelectedLocation( 1, 2 );</listing>
	 *
	 * <p>In the following example, the selection is cleared:</p>
	 *
	 * <listing version="3.0">
	 * list.setSelectedLocation( -1, -1 );</listing>
	 *
	 * @see #selectedGroupIndex
	 * @see #selectedItemIndex
	 * @see #selectedItem
	 */
	public function setSelectedLocation(groupIndex:Int, itemIndex:Int):Void
	{
		if (this._selectedGroupIndex == groupIndex && this._selectedItemIndex == itemIndex)
		{
			return;
		}
		if ((groupIndex < 0 && itemIndex >= 0) || (groupIndex >= 0 && itemIndex < 0))
		{
			throw new ArgumentError("To deselect items, group index and item index must both be < 0.");
		}
		this._selectedGroupIndex = groupIndex;
		this._selectedItemIndex = itemIndex;
		
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * Returns the item renderer factory associated with a specific ID.
	 * Returns <code>null</code> if no factory is associated with the ID.
	 *
	 * @see #setItemRendererFactoryWithID()
	 */
	public function getItemRendererFactoryWithID(id:String):Function
	{
		if (this._itemRendererFactories != null)
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
	 * Returns the header renderer factory associated with a specific ID.
	 * Returns <code>null</code> if no factory is associated with the ID.
	 *
	 * @see #setHeaderRendererFactoryWithID()
	 */
	public function getHeaderRendererFactoryWithID(id:String):Function
	{
		if (this._headerRendererFactories != null)
		{
			return this._headerRendererFactories[id];
		}
		return null;
	}
	
	/**
	 * Associates a header renderer factory with an ID to allow multiple
	 * types of header renderers may be displayed in the list. A custom
	 * <code>headerFactoryIDFunction</code> may be specified to return the
	 * ID of the factory to use for a specific header in the data provider.
	 *
	 * @see #headerFactoryIDFunction
	 * @see #getHeaderRendererFactoryWithID()
	 */
	public function setHeaderRendererFactoryWithID(id:String, factory:Function):Void
	{
		if (id == null)
		{
			this.headerRendererFactory = factory;
			return;
		}
		if (this._headerRendererFactories == null)
		{
			this._headerRendererFactories = new Map<String, Function>();
		}
		if (factory != null)
		{
			this._headerRendererFactories[id] = factory;
		}
		else
		{
			this._headerRendererFactories.remove(id);
		}
	}
	
	/**
	 * Returns the footer renderer factory associated with a specific ID.
	 * Returns <code>null</code> if no factory is associated with the ID.
	 *
	 * @see #setFooterRendererFactoryWithID()
	 */
	public function getFooterRendererFactoryWithID(id:String):Function
	{
		if (this._footerRendererFactories != null)
		{
			return this._footerRendererFactories[id];
		}
		return null;
	}
	
	/**
	 * Associates a footer renderer factory with an ID to allow multiple
	 * types of footer renderers may be displayed in the list. A custom
	 * <code>footerFactoryIDFunction</code> may be specified to return the
	 * ID of the factory to use for a specific footer in the data provider.
	 *
	 * @see #footerFactoryIDFunction
	 * @see #getFooterRendererFactoryWithID()
	 */
	public function setFooterRendererFactoryWithID(id:String, factory:Function):Void
	{
		if (id == null)
		{
			this.footerRendererFactory = factory;
			return;
		}
		if (this._footerRendererFactories == null)
		{
			this._footerRendererFactories = new Map<String, Function>();
		}
		if (factory != null)
		{
			this._footerRendererFactories[id] = factory;
		}
		else
		{
			this._footerRendererFactories.remove(id);
		}
	}
	
	/**
	 * Extracts header data from a group object.
	 */
	public function groupToHeaderData(group:Dynamic):Dynamic
	{
		if (this._headerFunction != null)
		{
			return this._headerFunction(group);
		}
		else if (this._headerField != null && group != null && Reflect.hasField(group, this._headerField))
		{
			return Reflect.getProperty(group, this._headerField);
		}
		
		return null;
	}
	
	/**
	 * Extracts footer data from a group object.
	 */
	public function groupToFooterData(group:Dynamic):Dynamic
	{
		if (this._footerFunction != null)
		{
			return this._footerFunction(group);
		}
		else if (this._footerField != null && group != null && Reflect.hasField(group, this._footerField))
		{
			return Reflect.getProperty(group, this._footerField);
		}
		
		return null;
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
	public function itemToItemRenderer(item:Dynamic):IGroupedListItemRenderer
	{
		return this.dataViewPort.itemToItemRenderer(item);
	}
	
	/**
	 * Returns the current header renderer used to render specific header
	 * data. May return <code>null</code> if the header data doesn't
	 * currently have a header renderer. Most lists use virtual layouts
	 * where only the visible headers will have a header renderer, so the
	 * result will usually be <code>null</code> for most header data in the
	 * data provider.
	 *
	 * @see #groupToHeaderData()
	 * @see ../../../help/faq/layout-virtualization.html What is layout virtualization?
	 */
	public function headerDataToHeaderRenderer(headerData:Dynamic):IGroupedListHeaderRenderer
	{
		return this.dataViewPort.headerDataToHeaderRenderer(headerData);
	}
	
	/**
	 * Returns the current footer renderer used to render specific footer
	 * data. May return <code>null</code> if the footer data doesn't
	 * currently have a footer renderer. Most lists use virtual layouts
	 * where only the visible footers will have a footer renderer, so the
	 * result will usually be <code>null</code> for most footer data in the
	 * data provider.
	 *
	 * @see #groupToFooterData()
	 * @see ../../../help/faq/layout-virtualization.html What is layout virtualization?
	 */
	public function footerDataToFooterRenderer(footerData:Dynamic):IGroupedListFooterRenderer
	{
		return this.dataViewPort.footerDataToFooterRenderer(footerData);
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
			this.viewPort = this.dataViewPort = new GroupedListDataViewPort();
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
			layout.stickyHeader = !this._styleNameList.contains(ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST);
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
		this.dataViewPort.setSelectedLocation(this._selectedGroupIndex, this._selectedItemIndex);
		this.dataViewPort.dataProvider = this._dataProvider;
		this.dataViewPort.typicalItem = this._typicalItem;
		
		this.dataViewPort.itemRendererType = this._itemRendererType;
		this.dataViewPort.itemRendererFactory = this._itemRendererFactory;
		this.dataViewPort.itemRendererFactories = this._itemRendererFactories;
		this.dataViewPort.factoryIDFunction = this._factoryIDFunction;
		this.dataViewPort.itemRendererProperties = this._itemRendererProperties;
		this.dataViewPort.customItemRendererStyleName = this._customItemRendererStyleName;
		
		this.dataViewPort.firstItemRendererType = this._firstItemRendererType;
		this.dataViewPort.firstItemRendererFactory = this._firstItemRendererFactory;
		this.dataViewPort.customFirstItemRendererStyleName = this._customFirstItemRendererStyleName;
		
		this.dataViewPort.lastItemRendererType = this._lastItemRendererType;
		this.dataViewPort.lastItemRendererFactory = this._lastItemRendererFactory;
		this.dataViewPort.customLastItemRendererStyleName = this._customLastItemRendererStyleName;
		
		this.dataViewPort.singleItemRendererType = this._singleItemRendererType;
		this.dataViewPort.singleItemRendererFactory = this._singleItemRendererFactory;
		this.dataViewPort.customSingleItemRendererStyleName = this._customSingleItemRendererStyleName;
		
		this.dataViewPort.headerRendererType = this._headerRendererType;
		this.dataViewPort.headerRendererFactory = this._headerRendererFactory;
		this.dataViewPort.headerRendererFactories = this._headerRendererFactories;
		this.dataViewPort.headerFactoryIDFunction = this._headerFactoryIDFunction;
		this.dataViewPort.headerRendererProperties = this._headerRendererProperties;
		this.dataViewPort.customHeaderRendererStyleName = this._customHeaderRendererStyleName;
		
		this.dataViewPort.footerRendererType = this._footerRendererType;
		this.dataViewPort.footerRendererFactory = this._footerRendererFactory;
		this.dataViewPort.footerRendererFactories = this._footerRendererFactories;
		this.dataViewPort.footerFactoryIDFunction = this._footerFactoryIDFunction;
		this.dataViewPort.footerRendererProperties = this._footerRendererProperties;
		this.dataViewPort.customFooterRendererStyleName = this._customFooterRendererStyleName;
		
		this.dataViewPort.layout = this._layout;
	}
	
	/**
	 * @private
	 */
	override function handlePendingScroll():Void
	{
		if (this.pendingGroupIndex >= 0)
		{
			var pendingData:Dynamic = null;
			if (this._dataProvider != null)
			{
				if (this.pendingItemIndex >= 0)
				{
					this._helperLocation.resize(2);
					this._helperLocation[0] = this._selectedGroupIndex;
					this._helperLocation[1] = this._selectedItemIndex;
					pendingData = this._dataProvider.getItemAt(this._helperLocation);
					this._helperLocation.resize(0);
				}
				else
				{
					this._helperLocation.resize(1);
					this._helperLocation[0] = this._selectedGroupIndex;
					pendingData = this._dataProvider.getItemAt(this._helperLocation);
					this._helperLocation.resize(0);
				}
			}
			if (Std.isOfType(pendingData, Dynamic))
			{
				var point:Point = Pool.getPoint();
				this.dataViewPort.getScrollPositionForIndex(this.pendingGroupIndex, this.pendingItemIndex, point);
				this.pendingGroupIndex = -1;
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
		if (this._selectedGroupIndex != -1 && this._selectedItemIndex != -1 &&
			(event.keyCode == Keyboard.SPACE ||
			((event.keyLocation == 4 || DeviceCapabilities.simulateDPad) && event.keyCode == Keyboard.ENTER)))
		{
			this.dispatchEventWith(Event.TRIGGERED, false, this.selectedItem);
		}
		if (event.keyCode == Keyboard.HOME || event.keyCode == Keyboard.END ||
			event.keyCode == Keyboard.PAGE_UP || event.keyCode == Keyboard.PAGE_DOWN ||
			event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN ||
			event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT)
		{
			this.dataViewPort.calculateNavigationDestination(this._selectedGroupIndex, this._selectedItemIndex, event.keyCode, this._helperLocation);
			var newGroupIndex:Int = this._helperLocation[0];
			var newItemIndex:Int = this._helperLocation[1];
			if (newGroupIndex == -1 || newItemIndex == -1)
			{
				this.setSelectedLocation(-1, -1);
			}
			else if (this._selectedGroupIndex != newGroupIndex || this._selectedItemIndex != newItemIndex)
			{
				event.preventDefault();
				this.setSelectedLocation(newGroupIndex, newItemIndex);
				var point:Point = Pool.getPoint();
				this.dataViewPort.getNearestScrollPositionForIndex(this._selectedGroupIndex, this.selectedItemIndex, point);
				this.scrollToPosition(point.x, point.y, this._keyScrollDuration);
				Pool.putPoint(point);
			}
		}
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
		this.setSelectedLocation(-1, -1);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_addItemHandler(event:Event, indices:Array<Int>):Void
	{
		if (this._selectedGroupIndex == -1)
		{
			return;
		}
		var groupIndex:Int = indices[0];
		if (indices.length > 1) //adding an item to a group
		{
			var itemIndex:Int = indices[1];
			if (this._selectedGroupIndex == groupIndex && this._selectedItemIndex >= itemIndex)
			{
				//adding an item at an index that is less than or equal to
				//the item that is selected. need to update the selected
				//item index.
				this.setSelectedLocation(this._selectedGroupIndex, this._selectedItemIndex + 1);
			}
		}
		else //adding an entire group
		{
			//adding a group before the group that the selected item is in.
			//need to update the selected group index.
			this.setSelectedLocation(this._selectedGroupIndex + 1, this._selectedItemIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeAllHandler(event:Event):Void
	{
		this.setSelectedLocation(-1, -1);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeItemHandler(event:Event, indices:Array<Int>):Void
	{
		if (this._selectedGroupIndex == -1)
		{
			return;
		}
		var groupIndex:Int = indices[0];
		if (indices.length > 1) //removing an item from a group
		{
			var itemIndex:Int = indices[1];
			if (this._selectedGroupIndex == groupIndex)
			{
				if (this._selectedItemIndex == itemIndex)
				{
					//removing the item that was selected.
					//now, nothing will be selected.
					this.setSelectedLocation(-1, -1);
				}
				else if (this._selectedItemIndex > itemIndex)
				{
					//removing an item from the same group that appears
					//before the item that is selected. need to update the
					//selected item index.
					this.setSelectedLocation(this._selectedGroupIndex, this._selectedItemIndex - 1);
				}
			}
		}
		else //removing an entire group
		{
			if (this._selectedGroupIndex == groupIndex)
			{
				//removing the group that the selected item was in.
				//now, nothing will be selected.
				this.setSelectedLocation(-1, -1);
			}
			else if (this._selectedGroupIndex > groupIndex)
			{
				//removing a group before the group that the selected item
				//is in. need to update the selected group index.
				this.setSelectedLocation(this._selectedGroupIndex - 1, this._selectedItemIndex);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function dataProvider_replaceItemHandler(event:Event, indices:Array<Int>):Void
	{
		if (this._selectedGroupIndex == -1)
		{
			return;
		}
		var groupIndex:Int = indices[0];
		if (indices.length > 1) //replacing an item from a group
		{
			var itemIndex:Int = indices[1];
			if (this._selectedGroupIndex == groupIndex && this._selectedItemIndex == itemIndex)
			{
				//replacing the selected item.
				//now, nothing will be selected.
				this.setSelectedLocation(-1, -1);
			}
		}
		else if (this._selectedGroupIndex == groupIndex) //replacing an entire group
		{
			//replacing the group with the selected item.
			//now, nothing will be selected.
			this.setSelectedLocation(-1, -1);
		}
	}
	
	/**
	 * @private
	 */
	private function dataViewPort_changeHandler(event:Event):Void
	{
		this.setSelectedLocation(this.dataViewPort.selectedGroupIndex, this.dataViewPort.selectedItemIndex);
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