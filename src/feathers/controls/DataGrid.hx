/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.renderers.DefaultDataGridHeaderRenderer;
import feathers.controls.renderers.IDataGridCellRenderer;
import feathers.controls.renderers.IDataGridHeaderRenderer;
import feathers.controls.supportClasses.DataGridDataViewPort;
import feathers.core.FeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.data.ArrayCollection;
import feathers.data.IListCollection;
import feathers.data.ListCollection;
import feathers.data.SortOrder;
import feathers.display.RenderDelegate;
import feathers.dragDrop.DragData;
import feathers.dragDrop.DragDropManager;
import feathers.dragDrop.IDragSource;
import feathers.dragDrop.IDropTarget;
import feathers.events.CollectionEventType;
import feathers.events.DragDropEvent;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.ILayout;
import feathers.layout.IVariableVirtualLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.utils.ReverseIterator;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.Property;
import feathers.utils.type.SafeCast;
import feathers.utils.type.TypeUtil;
import openfl.errors.IllegalOperationError;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;
import starling.utils.SystemUtil;

/**
 * Displays a collection of items as a table. Each item is rendered as a
 * row, divided into columns for each of the item's fields. Supports
 * scrolling, custom cell renderers, sorting columns, resizing columns, and
 * drag and drop reordering of columns.
 *
 * <p>The following example creates a data grid, gives it a data provider,
 * defines its columns, and listens for when the selection changes:</p>
 *
 * <listing version="3.0">
 * var grid:DataGrid = new DataGrid();
 * 
 * grid.dataProvider = new ArrayCollection(
 * [
 *     { item: "Chicken breast", dept: "Meat", price: "5.90" },
 *     { item: "Butter", dept: "Dairy", price: "4.69" },
 *     { item: "Broccoli", dept: "Produce", price: "2.99" },
 *     { item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" },
 * ]);
 * 
 * grid.columns = new ArrayCollection(
 * [
 *     new DataGridColumn("item", "Item"),
 *     new DataGridColumn("dept", "Department"),
 *     new DataGridColumn("price", "Unit Price"),
 * ]);
 * 
 * grid.addEventListener( Event.CHANGE, grid_changeHandler );
 * 
 * this.addChild( grid );</listing>
 *
 * @see ../../../help/data-grid.html How to use the Feathers DataGrid component
 *
 * @productversion Feathers 3.4.0
 */
class DataGrid extends Scroller implements IDragSource implements IDropTarget
{
	/**
	 * @private
	 */
	private static function defaultSortCompareFunction(a:Dynamic, b:Dynamic):Int
	{
		var aString:String = a.toString().toLowerCase();
		var bString:String = b.toString().toLowerCase();
		if (aString < bString)
		{
			return -1;
		}
		if (aString > bString)
		{
			return 1;
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	private static function defaultHeaderRendererFactory():IDataGridHeaderRenderer
	{
		return new DefaultDataGridHeaderRenderer();
	}

	/**
	 * @private
	 */
	private static inline var DATA_GRID_HEADER_DRAG_FORMAT:String = "feathers-data-grid-header";

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
		this.addEventListener(DragDropEvent.DRAG_ENTER, dataGrid_dragEnterHandler);
		this.addEventListener(DragDropEvent.DRAG_MOVE, dataGrid_dragMoveHandler);
		this.addEventListener(DragDropEvent.DRAG_DROP, dataGrid_dragDropHandler);
		this._selectedIndices.addEventListener(Event.CHANGE, selectedIndices_changeHandler);
	}
	
	/**
	 * @private
	 * The guts of the DataGrid's functionality. Handles layout and selection.
	 */
	private var dataViewPort:DataGridDataViewPort;

	/**
	 * @private
	 */
	private var _headerGroup:LayoutGroup = null;

	/**
	 * @private
	 */
	private var _headerDividerGroup:LayoutGroup = null;

	/**
	 * @private
	 */
	private var _verticalDividerGroup:LayoutGroup = null;

	/**
	 * @private
	 */
	private var _headerLayout:HorizontalLayout = null;

	/**
	 * @private
	 */
	private var _headerRendererMap:Map<DataGridColumn, IDataGridHeaderRenderer> = new Map<DataGridColumn, IDataGridHeaderRenderer>();

	/**
	 * @private
	 */
	private var _unrenderedHeaders:Array<Int> = new Array<Int>();

	/**
	 * @private
	 */
	private var _headerStorage:HeaderRendererFactoryStorage = new HeaderRendererFactoryStorage();

	/**
	 * @private
	 */
	private var _headerDividerStorage:DividerFactoryStorage = new DividerFactoryStorage();

	/**
	 * @private
	 */
	private var _verticalDividerStorage:DividerFactoryStorage = new DividerFactoryStorage();
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return DataGrid.globalStyleProvider;
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
	 * Determines if the data grid's columns may be reordered using drag
	 * and drop.
	 *
	 * <p>The following example enables column reordering:</p>
	 *
	 * <listing version="3.0">
	 * grid.reorderColumns = true;</listing>
	 *
	 * @default false
	 */
	public var reorderColumns(get, set):Bool;
	private var _reorderColumns:Bool = false;
	private function get_reorderColumns():Bool { return this._reorderColumns; }
	private function set_reorderColumns(value:Bool):Bool
	{
		return this._reorderColumns = value;
	}
	
	/**
	 * Determines if the data grid's columns may be sorted.
	 *
	 * <p>The following example enables column sorting:</p>
	 *
	 * <listing version="3.0">
	 * grid.sortableColumns = true;</listing>
	 *
	 * @default false
	 *
	 * @see feathers.controls.DataGridColumn#sortOrder
	 */
	public var sortableColumns(get, set):Bool;
	private var _sortableColumns:Bool = false;
	private function get_sortableColumns():Bool { return this._sortableColumns; }
	private function set_sortableColumns(value:Bool):Bool
	{
		return this._sortableColumns = value;
	}
	
	/**
	 * Determines if the data grid's columns may be resized.
	 *
	 * <p>The following example enables column resizing:</p>
	 *
	 * <listing version="3.0">
	 * grid.resizableColumns = true;</listing>
	 *
	 * @default false
	 *
	 * @see #style:columnResizeSkin
	 */
	public var resizableColumns(get, set):Bool;
	private var _resizableColumns:Bool = false;
	private function get_resizableColumns():Bool { return this._resizableColumns; }
	private function set_resizableColumns(value:Bool):Bool
	{
		return this._resizableColumns = value;
	}
	
	/**
	 * @private
	 */
	private var _currentColumnDropIndicatorSkin:DisplayObject = null;
	
	/**
	 * @private
	 */
	public var columnDropIndicatorSkin(get, set):DisplayObject;
	private var _columnDropIndicatorSkin:DisplayObject;
	private function get_columnDropIndicatorSkin():DisplayObject { return this._columnDropIndicatorSkin; }
	private function set_columnDropIndicatorSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("columnDropIndicatorSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		return this._columnDropIndicatorSkin = value;
	}
	
	/**
	 * @private
	 */
	private var _currentColumnResizeSkin:DisplayObject = null;
	
	/**
	 * @private
	 */
	public var columnResizeSkin(get, set):DisplayObject;
	private var _columnResizeSkin:DisplayObject;
	private function get_columnResizeSkin():DisplayObject { return this._columnResizeSkin; }
	private function set_columnResizeSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("columnResizeSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		return this._columnResizeSkin = value;
	}
	
	/**
	 * @private
	 */
	private var _currentColumnDragOverlaySkin:DisplayObject = null;
	
	/**
	 * @private
	 */
	public var columnDragOverlaySkin(get, set):DisplayObject;
	private var _columnDragOverlaySkin:DisplayObject;
	private function get_columnDragOverlaySkin():DisplayObject { return this._columnDragOverlaySkin; }
	private function set_columnDragOverlaySkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("columnDragOverlaySkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		return this._columnDragOverlaySkin = value;
	}
	
	/**
	 * @private
	 */
	public var columnDragAvatarAlpha(get, set):Float;
	private var _columnDragAvatarAlpha:Float = 0.8;
	private function get_columnDragAvatarAlpha():Float { return this._columnDragAvatarAlpha; }
	private function set_columnDragAvatarAlpha(value:Float):Float
	{
		if (this.processStyleRestriction("columnDragAvatarAlpha"))
		{
			return value;
		}
		return this._columnDragAvatarAlpha = value;
	}
	
	/**
	 * @private
	 */
	public var extendedColumnDropIndicator(get, set):Bool;
	private var _extendedColumnDropIndicator:Bool = false;
	private function get_extendedColumnDropIndicator():Bool { return this._extendedColumnDropIndicator; }
	private function set_extendedColumnDropIndicator(value:Bool):Bool
	{
		if (this.processStyleRestriction("extendedColumnDropIndicator"))
		{
			return value;
		}
		return this._extendedColumnDropIndicator = value;
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
	 * @private
	 */
	private var _updateForDataReset:Bool = false;
	
	/**
	 * The collection of data displayed by the data grid. Changing this
	 * property to a new value is considered a drastic change to the data
	 * grid's data, so the horizontal and vertical scroll positions will be
	 * reset, and the data grid's selection will be cleared.
	 *
	 * <p>The following example passes in a data provider and columns:</p>
	 *
	 * <listing version="3.0">
	 * grid.dataProvider = new ArrayCollection(
	 * [
	 *     { item: "Chicken breast", dept: "Meat", price: "5.90" },
	 *     { item: "Butter", dept: "Dairy", price: "4.69" },
	 *     { item: "Broccoli", dept: "Produce", price: "2.99" },
	 *     { item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" },
	 * ]);
	 * 
	 * grid.columns = new ArrayCollection(
	 * [
	 *     new DataGridColumn("item", "Item"),
	 *     new DataGridColumn("dept", "Department"),
	 *     new DataGridColumn("price", "Unit Price"),
	 * ]);</listing>
	 *
	 * <p><em>Warning:</em> A data grid's data provider cannot contain
	 * duplicate items. To display the same item in multiple item
	 * renderers, you must create separate objects with the same
	 * properties. This restriction exists because it significantly improves
	 * performance.</p>
	 *
	 * <p><em>Warning:</em> If the data provider contains display objects,
	 * concrete textures, or anything that needs to be disposed, those
	 * objects will not be automatically disposed when the data grid is
	 * disposed. Similar to how <code>starling.display.Image</code> cannot
	 * automatically dispose its texture because the texture may be used
	 * by other display objects, a data grid cannot dispose its data
	 * provider because the data provider may be used by other data grids.
	 * See the <code>dispose()</code> function on
	 * <code>IListCollection</code> to see how the data provider can be
	 * disposed properly.</p>
	 *
	 * @default null
	 *
	 * @see #columns
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
			this._dataProvider.removeEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.SORT_CHANGE, dataProvider_sortChangeHandler);
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
			this._dataProvider.addEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(CollectionEventType.SORT_CHANGE, dataProvider_sortChangeHandler);
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
	 * Defines the columns to display for each item in the data provider.
	 * If <code>null</code>, the data grid will attempt to populate the
	 * columns automatically.
	 *
	 * <p>The following example passes in a data provider and columns:</p>
	 *
	 * <listing version="3.0">
	 * grid.dataProvider = new ArrayCollection(
	 * [
	 *     { item: "Chicken breast", dept: "Meat", price: "5.90" },
	 *     { item: "Butter", dept: "Dairy", price: "4.69" },
	 *     { item: "Broccoli", dept: "Produce", price: "2.99" },
	 *     { item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" },
	 * ]);
	 * 
	 * grid.columns = new ArrayCollection(
	 * [
	 *     new DataGridColumn("item", "Item"),
	 *     new DataGridColumn("dept", "Department"),
	 *     new DataGridColumn("price", "Unit Price"),
	 * ]);</listing>
	 *
	 * @default null
	 *
	 * @see #dataProvider
	 * @see feathers.controls.DataGridColumn
	 */
	public var columns(get, set):IListCollection;
	private var _columns:IListCollection;
	private function get_columns():IListCollection { return this._columns; }
	private function set_columns(value:IListCollection):IListCollection
	{
		if (this._columns == value)
		{
			return value;
		}
		this.setColumns(value);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._columns;
	}
	
	/**
	 * @private
	 */
	private function setColumns(value:IListCollection):Void
	{
		if (this._columns != null)
		{
			this._columns.removeEventListener(Event.CHANGE, columns_changeHandler);
			this._columns.removeEventListener(CollectionEventType.RESET, columns_resetHandler);
			this._columns.removeEventListener(CollectionEventType.UPDATE_ALL, columns_updateAllHandler);
		}
		this._columns = value;
		if (this._columns != null)
		{
			this._columns.addEventListener(Event.CHANGE, columns_changeHandler);
			this._columns.addEventListener(CollectionEventType.RESET, columns_resetHandler);
			this._columns.addEventListener(CollectionEventType.UPDATE_ALL, columns_updateAllHandler);
		}
	}
	
	/**
	 * Determines if items in the data grid may be selected. By default
	 * only a single item may be selected at any given time. In other
	 * words, if item A is selected, and the user selects item B, item A
	 * will be deselected automatically. Set
	 * <code>allowMultipleSelection</code> to <code>true</code> to select
	 * more than one item without automatically deselecting other items.
	 *
	 * <p>The following example disables selection:</p>
	 *
	 * <listing version="3.0">
	 * grid.isSelectable = false;</listing>
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
	 * grid.selectedIndex = 2;</listing>
	 *
	 * <p>The following example clears the selected index:</p>
	 *
	 * <listing version="3.0">
	 * grid.selectedIndex = -1;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected index:</p>
	 *
	 * <listing version="3.0">
	 * function grid_changeHandler( event:Event ):void
	 * {
	 *     var grid:DataGrid = DataGrid( event.currentTarget );
	 *     var index:int = grid.selectedIndex;
	 * 
	 * }
	 * grid.addEventListener( Event.CHANGE, grid_changeHandler );</listing>
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
			this._selectedIndices.data = [value];
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
	 * grid.selectedItem = grid.dataProvider.getItemAt(0);</listing>
	 *
	 * <p>The following example clears the selected item:</p>
	 *
	 * <listing version="3.0">
	 * grid.selectedItem = null;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected item:</p>
	 *
	 * <listing version="3.0">
	 * function grid_changeHandler( event:Event ):void
	 * {
	 *     var grid:DataGrid = DataGrid( event.currentTarget );
	 *     var item:Object = grid.selectedItem;
	 * 
	 * }
	 * grid.addEventListener( Event.CHANGE, grid_changeHandler );</listing>
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
	 * grid.allowMultipleSelection = true;</listing>
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
	 * grid.selectedIndices = new &lt;int&gt;[ 2, 3 ];</listing>
	 *
	 * <p>The following example clears the selected indices:</p>
	 *
	 * <listing version="3.0">
	 * grid.selectedIndices = null;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected indices:</p>
	 *
	 * <listing version="3.0">
	 * function grid_changeHandler( event:Event ):void
	 * {
	 *     var grid:DataGrid = DataGrid( event.currentTarget );
	 *     var indices:Vector.&lt;int&gt; = grid.selectedIndices;
	 * 
	 * }
	 * grid.addEventListener( Event.CHANGE, grid_changeHandler );</listing>
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
			if (!this._allowMultipleSelection && value.length != 0)
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
	 * grid.selectedItems = new &lt;Object&gt;[ grid.dataProvider.getItemAt(2) , grid.dataProvider.getItemAt(3) ];</listing>
	 *
	 * <p>The following example clears the selected items:</p>
	 *
	 * <listing version="3.0">
	 * grid.selectedItems = null;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected items:</p>
	 *
	 * <listing version="3.0">
	 * function grid_changeHandler( event:Event ):void
	 * {
	 *     var grid:DataGrid = DataGrid( event.currentTarget );
	 *     var items:Vector.&lt;Object&gt; = grid.selectedItems;
	 * 
	 * }
	 * grid.addEventListener( Event.CHANGE, grid_changeHandler );</listing>
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
			index = this._selectedIndices.getItemAt(i);
			item = this._dataProvider.getItemAt(index);
			result[i] = item;
		}
		return result;
	}
	
	/**
	 * Used to auto-size the data grid when a virtualized layout is used.
	 * If the data grid's width or height is unknown, the data grid will
	 * try to automatically pick an ideal size. This item is used to create
	 * a sample item renderer to measure item renderers that are virtual
	 * and not visible in the viewport.
	 *
	 * <p>The following example provides a typical item:</p>
	 *
	 * <listing version="3.0">
	 * grid.typicalItem = { text: "A typical item", thumbnail: texture };</listing>
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
	 * @private
	 */
	public var headerBackgroundSkin(get, set):DisplayObject;
	private var _headerBackgroundSkin:DisplayObject;
	private function get_headerBackgroundSkin():DisplayObject { return this._headerBackgroundSkin; }
	private function set_headerBackgroundSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("headerBackgroundSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._headerBackgroundSkin == value)
		{
			return value;
		}
		this._headerBackgroundSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerBackgroundSkin;
	}
	
	/**
	 * @private
	 */
	public var headerBackgroundDisabledSkin(get, set):DisplayObject;
	private var _headerBackgroundDisabledSkin:DisplayObject;
	private function get_headerBackgroundDisabledSkin():DisplayObject { return this._headerBackgroundDisabledSkin; }
	private function set_headerBackgroundDisabledSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("headerBackgroundDisabledSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._headerBackgroundDisabledSkin == value)
		{
			return value;
		}
		this._headerBackgroundDisabledSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerBackgroundDisabledSkin;
	}
	
	/**
	 * @private
	 *
	 * @see #style:verticalDividerFactory
	 */
	public var verticalDividerFactory(get, set):Void->DisplayObject;
	private var _verticalDividerFactory:Void->DisplayObject;
	private function get_verticalDividerFactory():Void->DisplayObject { return this._verticalDividerFactory; }
	private function set_verticalDividerFactory(value:Void->DisplayObject):Void->DisplayObject
	{
		if (this.processStyleRestriction("verticalDividerFactory"))
		{
			return value;
		}
		if (this._verticalDividerFactory == value)
		{
			return value;
		}
		this._verticalDividerFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._verticalDividerFactory;
	}
	
	/**
	 * @private
	 *
	 * @see #style:headerDividerFactory
	 */
	public var headerDividerFactory(get, set):Void->DisplayObject;
	private var _headerDividerFactory:Void->DisplayObject;
	private function get_headerDividerFactory():Void->DisplayObject { return this._headerDividerFactory; }
	private function set_headerDividerFactory(value:Void->DisplayObject):Void->DisplayObject
	{
		if (this.processStyleRestriction("headerDividerFactory"))
		{
			return value;
		}
		if (this._headerDividerFactory == value)
		{
			return value;
		}
		this._headerDividerFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerDividerFactory;
	}
	
	/**
	 * Specifies a default factory for cell renderers that will be used if
	 * the <code>cellRendererFactory</code> from a
	 * <code>DataGridColumn</code> is <code>null</code>.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IDataGridCellRenderer</pre>
	 *
	 * <p>The following example provides a factory for the data grid:</p>
	 *
	 * <listing version="3.0">
	 * grid.cellRendererFactory = function():IDataGridCellRenderer
	 * {
	 *     var cellRenderer:CustomCellRendererClass = new CustomCellRendererClass();
	 *     cellRenderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return cellRenderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IDataGridCellRenderer
	 */
	public var cellRendererFactory(get, set):Void->IDataGridCellRenderer;
	private var _cellRendererFactory:Void->IDataGridCellRenderer;
	private function get_cellRendererFactory():Void->IDataGridCellRenderer { return this._cellRendererFactory; }
	private function set_cellRendererFactory(value:Void->IDataGridCellRenderer):Void->IDataGridCellRenderer
	{
		if (this._cellRendererFactory == value)
		{
			return value;
		}
		this._cellRendererFactory = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._cellRendererFactory;
	}
	
	/**
	 * @private
	 *
	 * @see #style:customCellRendererStyleName
	 */
	public var customCellRendererStyleName(get, set):String;
	private var _customCellRendererStyleName:String;
	private function get_customCellRendererStyleName():String { return this._customCellRendererStyleName; }
	private function set_customCellRendererStyleName(value:String):String
	{
		if (this._customCellRendererStyleName == value)
		{
			return value;
		}
		this._customCellRendererStyleName = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._customCellRendererStyleName;
	}
	
	/**
	 * Specifies a default factory for header renderers that will be used if
	 * the <code>headerRendererFactory</code> from a
	 * <code>DataGridColumn</code> is <code>null</code>.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IDataGridHeaderRenderer</pre>
	 *
	 * <p>The following example provides a factory for the data grid:</p>
	 *
	 * <listing version="3.0">
	 * grid.headerRendererFactory = function():IDataGridHeaderRenderer
	 * {
	 *     var headerRenderer:CustomHeaderRendererClass = new CustomHeaderRendererClass();
	 *     headerRenderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return headerRenderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IDataGridHeaderRenderer
	 */
	public var headerRendererFactory(get, set):Void->IDataGridHeaderRenderer;
	private var _headerRendererFactory:Void->IDataGridHeaderRenderer;
	private function get_headerRendererFactory():Void->IDataGridHeaderRenderer { return this._headerRendererFactory; }
	private function set_headerRendererFactory(value:Void->IDataGridHeaderRenderer):Void->IDataGridHeaderRenderer
	{
		if (this._headerRendererFactory == value)
		{
			return value;
		}
		this._headerRendererFactory = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._headerRendererFactory;
	}
	
	/**
	 * @private
	 *
	 * @see #style:customHeaderRendererStyleName
	 */
	public var customHeaderRendererStyleName(get, set):String;
	private var _customHeaderRendererStyleName:String;
	private function get_customHeaderRendererStyleName():String { return this._customHeaderRendererStyleName; }
	private function set_customHeaderRendererStyleName(value:String):String
	{
		if (this._customHeaderRendererStyleName == value)
		{
			return value;
		}
		this._customHeaderRendererStyleName = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._customHeaderRendererStyleName;
	}
	
	/**
	 * @private
	 */
	private var _draggedHeaderIndex:Int = -1;

	/**
	 * @private
	 */
	private var _headerTouchID:Int = -1;

	/**
	 * @private
	 */
	private var _headerTouchX:Float;

	/**
	 * @private
	 */
	private var _headerTouchY:Float;

	/**
	 * @private
	 */
	private var _headerDividerTouchID:Int = -1;

	/**
	 * @private
	 */
	private var _headerDividerTouchX:Float;

	/**
	 * @private
	 */
	private var _resizingColumnIndex:Int = -1;

	/**
	 * @private
	 */
	private var _customColumnSizes:Array<Float> = null;

	/**
	 * The pending item index to scroll to after validating. A value of
	 * <code>-1</code> means that the scroller won't scroll to an item after
	 * validating.
	 */
	private var pendingItemIndex:Int = -1;
	
	/**
	 * @private
	 */
	override public function scrollToPosition(horizontalScrollPosition:Float, verticalScrollPosition:Float, ?animationDuration:Float):Void
	{
		if (animationDuration == null) animationDuration = Math.NaN;
		this.pendingItemIndex = -1;
		super.scrollToPosition(horizontalScrollPosition, verticalScrollPosition, animationDuration);
	}
	
	/**
	 * @private
	 */
	override public function scrollToPageIndex(horizontalPageIndex:Int, verticalPageIndex:Int, ?animationDuration:Float):Void
	{
		if (animationDuration == null) animationDuration = Math.NaN;
		this.pendingItemIndex = -1;
		super.scrollToPageIndex(horizontalPageIndex, verticalPageIndex, animationDuration);
	}
	
	/**
	 * Scrolls the data grid so that the specified item is visible. If
	 * <code>animationDuration</code> is greater than zero, the scroll will
	 * animate. The duration is in seconds.
	 *
	 * <p>If the layout is virtual with variable item dimensions, this
	 * function may not accurately scroll to the exact correct position. A
	 * virtual layout with variable item dimensions is often forced to
	 * estimate positions, so the results aren't guaranteed to be accurate.</p>
	 *
	 * <p>If you want to scroll to the end of the data grid, it is better
	 * to use <code>scrollToPosition()</code> with
	 * <code>maxHorizontalScrollPosition</code> or
	 * <code>maxVerticalScrollPosition</code>.</p>
	 *
	 * <p>In the following example, the data grid is scrolled to display index 10:</p>
	 *
	 * <listing version="3.0">
	 * grid.scrollToDisplayIndex( 10 );</listing>
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
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._columnDropIndicatorSkin != null &&
			this._columnDropIndicatorSkin.parent == null)
		{
			this._columnDropIndicatorSkin.dispose();
			this._columnDropIndicatorSkin = null;
		}
		if (this._columnDragOverlaySkin != null &&
			this._columnDragOverlaySkin.parent == null)
		{
			this._columnDragOverlaySkin.dispose();
			this._columnDragOverlaySkin = null;
		}
		this.refreshInactiveHeaderDividers(true);
		this.refreshInactiveVerticalDividers(true);
		//clearing selection now so that the data provider setter won't
		//cause a selection change that triggers events.
		this._selectedIndices.removeEventListeners();
		this._selectedIndex = -1;
		this.dataProvider = null;
		this.columns = null;
		this.layout = null;
		this._headerRendererMap.clear();
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
			this.viewPort = this.dataViewPort = new DataGridDataViewPort();
			this.dataViewPort.owner = this;
			this.viewPort = this.dataViewPort;
		}
		
		if (this._verticalDividerGroup == null)
		{
			this._verticalDividerGroup = new LayoutGroup();
			this._verticalDividerGroup.touchable = false;
			this.addChild(this._verticalDividerGroup);
		}
		
		if (this._headerLayout == null)
		{
			this._headerLayout = new HorizontalLayout();
			this._headerLayout.useVirtualLayout = false;
			this._headerLayout.verticalAlign = VerticalAlign.JUSTIFY;
		}
		
		if (this._headerGroup == null)
		{
			this._headerGroup = new LayoutGroup();
			this.addChild(this._headerGroup);
		}
		
		this._headerGroup.layout = this._headerLayout;
		
		if (this._headerDividerGroup == null)
		{
			this._headerDividerGroup = new LayoutGroup();
			this.addChild(this._headerDividerGroup);
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
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
			this.ignoreNextStyleRestriction();
			this.layout = layout;
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		
		if (stylesInvalid)
		{
			this.refreshHeaderStyles();
		}
		
		this.refreshColumns();
		
		this.refreshHeaderRenderers();
		this.refreshDataViewPortProperties();
		super.draw();
	}
	
	/**
	 * @inheritDoc
	 */
	override function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		var measureBackground:IMeasureDisplayObject = SafeCast.safe_cast(this.currentBackgroundSkin, IMeasureDisplayObject);
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			cast(this.currentBackgroundSkin, IValidating).validate();
		}
		
		//we don't measure the header and footer here because they are
		//handled in calculateViewPortOffsets(), which is automatically
		//called by Scroller before autoSizeIfNeeded().
		
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsWidth)
		{
			if (this._measureViewPort)
			{
				newWidth = this._viewPort.visibleWidth;
			}
			else
			{
				newWidth = 0;
			}
			newWidth += this._rightViewPortOffset + this._leftViewPortOffset;
			var headerWidth:Float = this._headerGroup.width;
			if (headerWidth > newWidth)
			{
				newWidth = headerWidth;
			}
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.width > newWidth)
			{
				newWidth = this.currentBackgroundSkin.width;
			}
		}
		if (needsHeight)
		{
			if (this._measureViewPort)
			{
				newHeight = this._viewPort.visibleHeight;
			}
			else
			{
				newHeight = 0;
			}
			newHeight += this._bottomViewPortOffset + this._topViewPortOffset;
			//we don't need to account for the header and footer because
			//they're already included in the top and bottom offsets
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.height > newHeight)
			{
				newHeight = this.currentBackgroundSkin.height;
			}
		}
		if (needsMinWidth)
		{
			if (this._measureViewPort)
			{
				newMinWidth = this._viewPort.minVisibleWidth;
			}
			else
			{
				newMinWidth = 0;
			}
			newMinWidth += this._rightViewPortOffset + this._leftViewPortOffset;
			var headerMinWidth:Float = this._headerGroup.minWidth;
			if (headerMinWidth > newMinWidth)
			{
				newMinWidth = headerMinWidth;
			}
			if (this.currentBackgroundSkin != null)
			{
				if (measureBackground != null)
				{
					if (measureBackground.minWidth > newMinWidth)
					{
						newMinWidth = measureBackground.minWidth;
					}
				}
				else if (this._explicitBackgroundMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitBackgroundMinWidth;
				}
			}
		}
		if (needsMinHeight)
		{
			if (this._measureViewPort)
			{
				newMinHeight = this._viewPort.minVisibleHeight;
			}
			else
			{
				newMinHeight = 0;
			}
			newMinHeight += this._bottomViewPortOffset + this._topViewPortOffset;
			//we don't need to account for the header and footer because
			//they're already included in the top and bottom offsets
			if (this.currentBackgroundSkin != null)
			{
				if (measureBackground != null)
				{
					if (measureBackground.minHeight > newMinHeight)
					{
						newMinHeight = measureBackground.minHeight;
					}
				}
				else if (this._explicitBackgroundMinHeight > newMinHeight)
				{
					newMinHeight = this._explicitBackgroundMinHeight;
				}
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 * If the columns are not defined, we can try to create them automatically.
	 */
	private function refreshColumns():Void
	{
		if (this._columns != null || this._dataProvider == null || this._dataProvider.length == 0)
		{
			return;
		}
		var columns:Array<DataGridColumn> = [];
		var firstItem:Dynamic = this._dataProvider.getItemAt(0);
		var pushIndex:Int = 0;
		var fields:Array<String> = Reflect.fields(firstItem);
		for (key in fields)
		{
			columns[pushIndex] = new DataGridColumn(key);
			pushIndex++;
		}
		this.setColumns(new ArrayCollection(columns));
	}
	
	/**
	 * @private
	 */
	private function refreshHeaderStyles():Void
	{
		this._headerGroup.backgroundSkin = this._headerBackgroundSkin;
		this._headerGroup.backgroundDisabledSkin = this._headerBackgroundDisabledSkin;
	}
	
	/**
	 * @private
	 */
	override function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void
	{
		super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
		
		this._headerLayout.paddingLeft = this._leftViewPortOffset;
		this._headerLayout.paddingRight = this._rightViewPortOffset;
		if (useActualBounds)
		{
			this._headerGroup.width = this.actualWidth;
			this._headerGroup.minWidth = this.actualMinWidth;
		}
		else
		{
			this._headerGroup.width = this._explicitWidth;
			this._headerGroup.minWidth = this._explicitMinWidth;
		}
		this._headerGroup.maxWidth = this._explicitMaxWidth;
		this._headerGroup.validate();
		this._topViewPortOffset += this._headerGroup.height;
	}
	
	/**
	 * @private
	 */
	override function layoutChildren():Void
	{
		this.validateCustomColumnSizes();
		this.layoutHeaderRenderers();
		
		this._headerLayout.paddingLeft = this._leftViewPortOffset;
		this._headerLayout.paddingRight = this._rightViewPortOffset;
		this._headerGroup.width = this.actualWidth;
		this._headerGroup.validate();
		this._headerGroup.x = 0;
		this._headerGroup.y = this._topViewPortOffset - this._headerGroup.height;
		this._headerDividerGroup.x = this._headerGroup.x;
		this._headerDividerGroup.y = this._headerGroup.y;
		this._headerDividerGroup.width = this._headerGroup.width;
		
		super.layoutChildren();
		
		this._verticalDividerGroup.x = this._headerGroup.x;
		this._verticalDividerGroup.y = this._headerGroup.y + this._headerGroup.height;
		this._verticalDividerGroup.width = this._headerGroup.width;
		this._verticalDividerGroup.height = this.viewPort.visibleHeight;
		
		this.refreshHeaderDividers();
		this.refreshVerticalDividers();
	}
	
	/**
	 * @private
	 */
	private function validateCustomColumnSizes():Void
	{
		if (this._customColumnSizes == null || this._customColumnSizes.length < this._columns.length)
		{
			return;
		}
		
		var availableWidth:Float = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset;
		var count:Int = this._customColumnSizes.length;
		var totalWidth:Float = 0;
		var indices:Array<Int> = new Array<Int>();
		var currentIndex:Int = 0;
		var column:DataGridColumn;
		for (i in 0...count)
		{
			column = cast this._columns.getItemAt(i);
			if (column.width == column.width) //!isNaN
			{
				//if the width is set explicitly, skip it!
				availableWidth -= column.width;
				continue;
			}
			var size:Float = this._customColumnSizes[i];
			totalWidth += size;
			indices[currentIndex] = i;
			currentIndex++;
		}
		if (totalWidth == availableWidth)
		{
			return;
		}
		
		//make a copy so that this is detected as a change
		this._customColumnSizes = this._customColumnSizes.copy();
		
		var widthToDistribute:Float = availableWidth - totalWidth;
		this.distributeWidthToIndices(widthToDistribute, indices, totalWidth);
		this.dataViewPort.customColumnSizes = this._customColumnSizes;
	}
	
	/**
	 * @private
	 */
	private function distributeWidthToIndices(widthToDistribute:Float, indices:Array<Int>, totalWidthOfIndices:Float):Void
	{
		var nextWidthToDistribute:Float;
		var count:Int;
		var index:Int;
		var headerRenderer:IDataGridHeaderRenderer;
		var columnWidth:Float;
		var column:DataGridColumn;
		var percent:Float;
		var offset:Float;
		var newWidth:Float;
		while (Math.abs(widthToDistribute) > 1)
		{
			//this will be the store value if we need to loop again
			nextWidthToDistribute = widthToDistribute;
			count = indices.length;
			for (i in new ReverseIterator(count-1, 0))
			{
				index = indices[i];
				headerRenderer = cast this._headerGroup.getChildAt(index);
				columnWidth = headerRenderer.width;
				column = cast this._columns.getItemAt(index);
				percent = columnWidth / totalWidthOfIndices;
				offset = widthToDistribute * percent;
				newWidth = this._customColumnSizes[index] + offset;
				if (newWidth < column.minWidth)
				{
					offset += (column.minWidth - newWidth);
					newWidth = column.minWidth;
					//we've hit the minimum, so skip it if we loop again
					indices.splice(i, 1);
					//also readjust the total to exclude this column
					//so that the percentages still add up to 100%
					totalWidthOfIndices -= columnWidth;
				}
				this._customColumnSizes[index] = newWidth;
				nextWidthToDistribute -= offset;
			}
			widthToDistribute = nextWidthToDistribute;
		}
		
		if (widthToDistribute != 0)
		{
			//if we have less than a pixel left, just add it to the
			//final column and exit the loop
			this._customColumnSizes[this._customColumnSizes.length - 1] += widthToDistribute;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutHeaderRenderers():Void
	{
		var columnCount:Int = 0;
		if (this._columns != null)
		{
			columnCount = this._columns.length;
		}
		var headerRenderer:IDataGridHeaderRenderer;
		var column:DataGridColumn;
		for (i in 0...columnCount)
		{
			headerRenderer = cast this._headerGroup.getChildAt(i);
			column = cast this._columns.getItemAt(i);
			if (column.width == column.width) //!isNaN
			{
				headerRenderer.width = column.width;
				headerRenderer.layoutData = null;
			}
			else if (this._customColumnSizes != null && i < this._customColumnSizes.length)
			{
				headerRenderer.width = this._customColumnSizes[i];
				headerRenderer.layoutData = null;
			}
			else if (headerRenderer.layoutData == null)
			{
				headerRenderer.layoutData = new HorizontalLayoutData(100);
			}
			headerRenderer.minWidth = column.minWidth;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshVerticalDividers():Void
	{
		this.refreshInactiveVerticalDividers(this._verticalDividerStorage.factory != this._verticalDividerFactory);
		this._verticalDividerStorage.factory = this._verticalDividerFactory;
		
		var columnCount:Int = 0;
		if (this._columns != null)
		{
			columnCount = this._columns.length;
		}
		var dividerCount:Int = 0;
		if (this._verticalDividerFactory != null)
		{
			dividerCount = columnCount - 1;
		}

		this._headerGroup.validate();
		var activeDividers:Array<DisplayObject> = this._verticalDividerStorage.activeDividers;
		var inactiveDividers:Array<DisplayObject> = this._verticalDividerStorage.inactiveDividers;
		var verticalDivider:DisplayObject;
		var headerRenderer:IDataGridHeaderRenderer;
		for (i in 0...dividerCount)
		{
			verticalDivider = null;
			if (inactiveDividers.length != 0)
			{
				verticalDivider = inactiveDividers.shift();
				this._verticalDividerGroup.setChildIndex(verticalDivider, i);
			}
			else
			{
				verticalDivider = this._verticalDividerFactory();
				this._verticalDividerGroup.addChildAt(verticalDivider, i);
			}
			activeDividers[i] = verticalDivider;
			verticalDivider.height = this._viewPort.visibleHeight;
			if (Std.isOfType(verticalDivider, IValidating))
			{
				cast(verticalDivider, IValidating).validate();
			}
			headerRenderer = cast this._headerGroup.getChildAt(i);
			verticalDivider.x = headerRenderer.x + headerRenderer.width - (verticalDivider.width / 2);
			verticalDivider.y = 0;
		}
		this.freeInactiveVerticalDividers();
	}
	
	/**
	 * @private
	 */
	private function refreshInactiveVerticalDividers(forceCleanup:Bool):Void
	{
		var temp:Array<DisplayObject> = this._verticalDividerStorage.inactiveDividers;
		this._verticalDividerStorage.inactiveDividers = this._verticalDividerStorage.activeDividers;
		this._verticalDividerStorage.activeDividers = temp;
		if (forceCleanup)
		{
			this.freeInactiveVerticalDividers();
		}
	}
	
	/**
	 * @private
	 */
	private function freeInactiveVerticalDividers():Void
	{
		var inactiveDividers:Array<DisplayObject> = this._verticalDividerStorage.inactiveDividers;
		var dividerCount:Int = inactiveDividers.length;
		var verticalDivider:DisplayObject;
		for (i in 0...dividerCount)
		{
			verticalDivider = inactiveDividers.shift();
			verticalDivider.removeFromParent(true);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshHeaderDividers():Void
	{
		this.refreshInactiveHeaderDividers(this._headerDividerStorage.factory != this._headerDividerFactory);
		this._headerDividerStorage.factory = this._headerDividerFactory;
		
		var dividerCount:Int = 0;
		if (this._columns != null)
		{
			dividerCount = this._columns.length;
			if (this._scrollBarDisplayMode != ScrollBarDisplayMode.FIXED ||
				this._minVerticalScrollPosition == this._maxVerticalScrollPosition)
			{
				dividerCount--;
			}
		}
		
		this._headerGroup.validate();
		var activeDividers:Array<DisplayObject> = this._headerDividerStorage.activeDividers;
		var inactiveDividers:Array<DisplayObject> = this._headerDividerStorage.inactiveDividers;
		var headerDivider:DisplayObject;
		var headerRenderer:IDataGridHeaderRenderer;
		for (i in 0...dividerCount)
		{
			headerDivider = null;
			if (inactiveDividers.length != 0)
			{
				headerDivider = inactiveDividers.shift();
				this._headerDividerGroup.setChildIndex(headerDivider, i);
			}
			else if (this._headerDividerFactory != null)
			{
				headerDivider = this._headerDividerFactory();
				headerDivider.addEventListener(TouchEvent.TOUCH, headerDivider_touchHandler);
				this._headerDividerGroup.addChildAt(headerDivider, i);
			}
			else
			{
				headerDivider = new Quad(3, 1, 0xff00ff);
				headerDivider.alpha = 0;
				if (!SystemUtil.isDesktop)
				{
					headerDivider.width = 22;
				}
				headerDivider.addEventListener(TouchEvent.TOUCH, headerDivider_touchHandler);
				this._headerDividerGroup.addChildAt(headerDivider, i);
			}
			activeDividers[i] = headerDivider;
			headerRenderer = cast this._headerGroup.getChildAt(i);
			headerDivider.height = headerRenderer.height;
			if (Std.isOfType(headerDivider, IValidating))
			{
				cast(headerDivider, IValidating).validate();
			}
			headerDivider.x = headerRenderer.x + headerRenderer.width - (headerDivider.width / 2);
			headerDivider.y = headerRenderer.y;
		}
		this.freeInactiveHeaderDividers();
	}
	
	/**
	 * @private
	 */
	private function refreshInactiveHeaderDividers(forceCleanup:Bool):Void
	{
		var temp:Array<DisplayObject> = this._headerDividerStorage.inactiveDividers;
		this._headerDividerStorage.inactiveDividers = this._headerDividerStorage.activeDividers;
		this._headerDividerStorage.activeDividers = temp;
		if (forceCleanup)
		{
			this.freeInactiveHeaderDividers();
		}
	}
	
	/**
	 * @private
	 */
	private function freeInactiveHeaderDividers():Void
	{
		var inactiveDividers:Array<DisplayObject> = this._headerDividerStorage.inactiveDividers;
		var dividerCount:Int = inactiveDividers.length;
		var headerDivider:DisplayObject;
		for (i in 0...dividerCount)
		{
			headerDivider = inactiveDividers.shift();
			headerDivider.removeEventListener(TouchEvent.TOUCH, headerDivider_touchHandler);
			headerDivider.removeFromParent(true);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshHeaderRenderers():Void
	{
		this.findUnrenderedData();
		this.recoverInactiveHeaderRenderers();
		this.renderUnrenderedData();
		this.freeInactiveHeaderRenderers();
		this._updateForDataReset = false;
	}
	
	/**
	 * @private
	 */
	private function findUnrenderedData():Void
	{
		var temp:Array<IDataGridHeaderRenderer> = this._headerStorage.inactiveHeaderRenderers;
		this._headerStorage.inactiveHeaderRenderers = this._headerStorage.activeHeaderRenderers;
		this._headerStorage.activeHeaderRenderers = temp;
		
		var activeHeaderRenderers:Array<IDataGridHeaderRenderer> = this._headerStorage.activeHeaderRenderers;
		var inactiveHeaderRenderers:Array<IDataGridHeaderRenderer> = this._headerStorage.inactiveHeaderRenderers;
		
		var columnCount:Int = 0;
		if (this._columns != null)
		{
			columnCount = this._columns.length;
		}
		
		var activePushIndex:Int = activeHeaderRenderers.length;
		var unrenderedDataLastIndex:Int = this._unrenderedHeaders.length;
		var column:DataGridColumn;
		var headerRenderer:IDataGridHeaderRenderer;
		var inactiveIndex:Int;
		for (i in 0...columnCount)
		{
			column = cast this._columns.getItemAt(i);
			headerRenderer = this._headerRendererMap[column];
			if (headerRenderer != null)
			{
				headerRenderer.columnIndex = i;
				headerRenderer.visible = true;
				if (column == this._sortedColumn)
				{
					if (this._reverseSort)
					{
						headerRenderer.sortOrder = SortOrder.DESCENDING;
					}
					else
					{
						headerRenderer.sortOrder = SortOrder.ASCENDING;
					}
				}
				else
				{
					headerRenderer.sortOrder = SortOrder.NONE;
				}
				this._headerGroup.setChildIndex(cast headerRenderer, i);
				if (this._updateForDataReset)
				{
					//similar to calling updateItemAt(), replacing the data
					//provider or resetting its source means that we should
					//trick the item renderer into thinking it has new data.
					//many developers seem to expect this behavior, so while
					//it's not the most optimal for performance, it saves on
					//support time in the forums. thankfully, it's still
					//somewhat optimized since the same item renderer will
					//receive the same data, and the children generally
					//won't have changed much, if at all.
					headerRenderer.data = null;
					headerRenderer.data = column;
				}
				activeHeaderRenderers[activePushIndex] = headerRenderer;
				activePushIndex++;
				
				inactiveIndex = inactiveHeaderRenderers.indexOf(headerRenderer);
				if (inactiveIndex != -1)
				{
					inactiveHeaderRenderers[inactiveIndex] = null;
				}
				else
				{
					throw new IllegalOperationError("DataGrid: header renderer map contains bad data. This may be caused by duplicate items in the columns collection, which is not allowed.");
				}
			}
			else
			{
				this._unrenderedHeaders[unrenderedDataLastIndex] = i;
				unrenderedDataLastIndex++;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function recoverInactiveHeaderRenderers():Void
	{
		var inactiveHeaderRenderers:Array<IDataGridHeaderRenderer> = this._headerStorage.inactiveHeaderRenderers;
		var count:Int = inactiveHeaderRenderers.length;
		var headerRenderer:IDataGridHeaderRenderer;
		for (i in 0...count)
		{
			headerRenderer = inactiveHeaderRenderers[i];
			if (headerRenderer == null || headerRenderer.data == null)
			{
				continue;
			}
			this.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, headerRenderer);
			this._headerRendererMap.remove(headerRenderer.data);
		}
	}
	
	/**
	 * @private
	 */
	private function renderUnrenderedData():Void
	{
		var headerRendererCount:Int = this._unrenderedHeaders.length;
		var columnIndex:Int;
		var column:DataGridColumn;
		for (i in 0...headerRendererCount)
		{
			columnIndex = this._unrenderedHeaders.shift();
			column = cast this._columns.getItemAt(columnIndex);
			this.createHeaderRenderer(column, columnIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function freeInactiveHeaderRenderers():Void
	{
		var inactiveHeaderRenderers:Array<IDataGridHeaderRenderer> = this._headerStorage.inactiveHeaderRenderers;
		var count:Int = inactiveHeaderRenderers.length;
		var headerRenderer:IDataGridHeaderRenderer;
		for (i in 0...count)
		{
			headerRenderer = inactiveHeaderRenderers.shift();
			if (headerRenderer == null)
			{
				continue;
			}
			this.destroyHeaderRenderer(headerRenderer);
		}
	}
	
	/**
	 * @private
	 */
	private function createHeaderRenderer(column:DataGridColumn, columnIndex:Int):IDataGridHeaderRenderer
	{
		var headerRendererFactory:Void->IDataGridHeaderRenderer = column.headerRendererFactory;
		if (headerRendererFactory == null)
		{
			headerRendererFactory = this._headerRendererFactory;
		}
		if (headerRendererFactory == null)
		{
			headerRendererFactory = defaultHeaderRendererFactory;
		}
		var customHeaderRendererStyleName:String = column.customHeaderRendererStyleName;
		if (customHeaderRendererStyleName == null)
		{
			customHeaderRendererStyleName = this._customHeaderRendererStyleName;
		}
		var inactiveHeaderRenderers:Array<IDataGridHeaderRenderer> = this._headerStorage.inactiveHeaderRenderers;
		var activeHeaderRenderers:Array<IDataGridHeaderRenderer> = this._headerStorage.activeHeaderRenderers;
		var headerRenderer:IDataGridHeaderRenderer = null;
		do
		{
			if (inactiveHeaderRenderers.length == 0)
			{
				headerRenderer = headerRendererFactory();
				headerRenderer.addEventListener(TouchEvent.TOUCH, headerRenderer_touchHandler);
				headerRenderer.addEventListener(Event.TRIGGERED, headerRenderer_triggeredHandler);
				if (customHeaderRendererStyleName != null && customHeaderRendererStyleName.length != 0)
				{
					headerRenderer.styleNameList.add(customHeaderRendererStyleName);
				}
				this._headerGroup.addChild(cast headerRenderer);
			}
			else
			{
				headerRenderer = inactiveHeaderRenderers.shift();
			}
		}
		while (headerRenderer == null);
		headerRenderer.data = column;
		headerRenderer.columnIndex = columnIndex;
		headerRenderer.owner = this;
		
		this._headerRendererMap[column] = headerRenderer;
		activeHeaderRenderers[activeHeaderRenderers.length] = headerRenderer;
		this.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, headerRenderer);
		
		column.addEventListener(Event.CHANGE, column_changeHandler);
		
		return headerRenderer;
	}
	
	/**
	 * @private
	 */
	private function destroyHeaderRenderer(headerRenderer:IDataGridHeaderRenderer):Void
	{
		if (headerRenderer.data != null)
		{
			headerRenderer.data.removeEventListener(Event.CHANGE, column_changeHandler);
		}
		headerRenderer.removeEventListener(Event.TRIGGERED, headerRenderer_triggeredHandler);
		headerRenderer.removeEventListener(TouchEvent.TOUCH, headerRenderer_touchHandler);
		headerRenderer.owner = null;
		headerRenderer.data = null;
		headerRenderer.columnIndex = -1;
		this._headerGroup.removeChild(cast headerRenderer, true);
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
		this.dataViewPort.columns = this._columns;
		this.dataViewPort.typicalItem = this._typicalItem;
		this.dataViewPort.layout = this._layout;
		this.dataViewPort.customColumnSizes = this._customColumnSizes;
	}
	
	/**
	 * @private
	 */
	override function handlePendingScroll():Void
	{
		if (this.pendingItemIndex != -1)
		{
			var item:Dynamic = null;
			if (this._dataProvider != null)
			{
				item = this._dataProvider.getItemAt(this.pendingItemIndex);
			}
			if (TypeUtil.isObject(item))
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
	private function column_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
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
	// TODO : TransformFestureEvent doesn't exist in OpenFL
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
	private function columns_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}

	/**
	 * @private
	 */
	private function columns_resetHandler(event:Event):Void
	{
		this._updateForDataReset = true;
	}
	
	/**
	 * @private
	 */
	private function columns_updateAllHandler(event:Event):Void
	{
		//we're treating this similar to the RESET event because enough
		//users are treating UPDATE_ALL similarly. technically, UPDATE_ALL
		//is supposed to affect only existing items, but it's confusing when
		//new items are added and not displayed.
		this._updateForDataReset = true;
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
			currentIndex = this._selectedIndices.getItemAt(i);
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
			currentIndex = this._selectedIndices.getItemAt(i);
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
	private function dataProvider_sortChangeHandler(event:Event):Void
	{
		this.refreshSelectedIndicesAfterFilterOrSort();
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
			this._selectedIndex = this._selectedIndices.getItemAt(0);
		}
		else
		{
			if (this._selectedIndex < 0)
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
	
	/**
	 * @private
	 */
	private function headerRenderer_triggeredHandler(event:Event):Void
	{
		var headerRenderer:IDataGridHeaderRenderer = cast event.currentTarget;
		var column:DataGridColumn = headerRenderer.data;
		if (!this._sortableColumns || column.sortOrder == SortOrder.NONE)
		{
			return;
		}
		if (this._sortedColumn != column)
		{
			this._sortedColumn = column;
			this._reverseSort = column.sortOrder == SortOrder.DESCENDING;
		}
		else
		{
			this._reverseSort = !this._reverseSort;
		}
		if (this._reverseSort)
		{
			this._dataProvider.sortCompareFunction = this.reverseSortCompareFunction;
		}
		else
		{
			this._dataProvider.sortCompareFunction = this.sortCompareFunction;
		}
		//the sortCompareFunction might not have changed if we're sorting a
		//different column, so force a refresh.
		this._dataProvider.refresh();
	}
	
	/**
	 * @private
	 */
	private var _reverseSort:Bool = false;

	/**
	 * @private
	 */
	private var _sortedColumn:DataGridColumn = null;

	/**
	 * @private
	 */
	private function reverseSortCompareFunction(a:Dynamic, b:Dynamic):Int
	{
		return -this.sortCompareFunction(a, b);
	}
	
	/**
	 * @private
	 */
	private function sortCompareFunction(a:Dynamic, b:Dynamic):Int
	{
		var aField:Dynamic = Property.read(a, this._sortedColumn.dataField);
		var bField:Dynamic = Property.read(b, this._sortedColumn.dataField);
		var sortCompareFunction:Dynamic->Dynamic->Int = this._sortedColumn.sortCompareFunction;
		if (sortCompareFunction == null)
		{
			sortCompareFunction = defaultSortCompareFunction;
		}
		return sortCompareFunction(aField, bField);
	}
	
	/**
	 * @private
	 */
	private function dataGrid_touchHandler(event:TouchEvent):Void
	{
		if (this._headerTouchID != -1)
		{
			//a touch has begun, so we'll ignore all other touches.
			var touch:Touch = event.getTouch(this, null, this._headerTouchID);
			if (touch == null)
			{
				//this should not happen.
				return;
			}
			
			if (touch.phase == TouchPhase.ENDED)
			{
				this.removeEventListener(TouchEvent.TOUCH, dataGrid_touchHandler);
				//these might be null if there was no TouchPhase.MOVED
				if (this._currentColumnDropIndicatorSkin != null)
				{
					this._currentColumnDropIndicatorSkin.removeFromParent(this._currentColumnDropIndicatorSkin != this._columnDropIndicatorSkin);
					this._currentColumnDropIndicatorSkin = null;
				}
				if (this._currentColumnDragOverlaySkin != null)
				{
					this._currentColumnDragOverlaySkin.removeFromParent(this._currentColumnDragOverlaySkin != this._columnDragOverlaySkin);
					this._currentColumnDragOverlaySkin = null;
				}
				this._headerTouchID = -1;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function headerRenderer_touchHandler(event:TouchEvent):Void
	{
		var headerRenderer:IDataGridHeaderRenderer = cast event.currentTarget;
		if (!this._isEnabled)
		{
			this._headerTouchID = -1;
			return;
		}
		var touch:Touch;
		if (this._headerTouchID != -1)
		{
			//a touch has begun, so we'll ignore all other touches.
			touch = event.getTouch(cast headerRenderer, null, this._headerTouchID);
			if (touch == null)
			{
				//this should not happen.
				return;
			}
			
			if (touch.phase == TouchPhase.MOVED)
			{
				if (!DragDropManager.isDragging && this._reorderColumns)
				{
					var column:DataGridColumn = cast this._columns.getItemAt(headerRenderer.columnIndex);
					var dragData:DragData = new DragData();
					dragData.setDataForFormat(DATA_GRID_HEADER_DRAG_FORMAT, column);
					//var self:DataGrid = this; // this is not in use
					var avatar:RenderDelegate = new RenderDelegate(cast headerRenderer);
					avatar.alpha = this._columnDragAvatarAlpha;
					DragDropManager.startDrag(this, touch, dragData, avatar);
					if (this._columnDropIndicatorSkin == null)
					{
						this._currentColumnDropIndicatorSkin = new Quad(1, 1, 0x000000);
					}
					if (this._columnDropIndicatorSkin != null)
					{
						this._currentColumnDropIndicatorSkin = this._columnDropIndicatorSkin;
					}
					//start out invisible and TouchPhase.MOVED will reveal it, if necessary
					this._currentColumnDropIndicatorSkin.visible = false;
					this.addChild(this._currentColumnDropIndicatorSkin);
					
					if (this._columnDragOverlaySkin == null)
					{
						this._currentColumnDragOverlaySkin = new Quad(1, 1, 0xff00ff);
						this._currentColumnDragOverlaySkin.alpha = 0;
					}
					else
					{
						this._currentColumnDragOverlaySkin = this._columnDragOverlaySkin;
					}
					this._currentColumnDragOverlaySkin.x = this._headerGroup.x + headerRenderer.x;
					this._currentColumnDragOverlaySkin.y = this._headerGroup.y + headerRenderer.y;
					this._currentColumnDragOverlaySkin.width = headerRenderer.width;
					this._currentColumnDragOverlaySkin.height = this._viewPort.y + this._viewPort.visibleHeight - this._headerGroup.y;
					this.addChild(this._currentColumnDragOverlaySkin);
				}
			}
		}
		else if (!DragDropManager.isDragging && this._reorderColumns)
		{
			//we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(cast headerRenderer, TouchPhase.BEGAN);
			if (touch == null)
			{
				//we only care about the began phase. ignore all other
				//phases when we don't have a saved touch ID.
				return;
			}
			this._headerTouchID = touch.id;
			this._headerTouchX = touch.globalX;
			this._headerTouchY = touch.globalX;
			this._draggedHeaderIndex = headerRenderer.columnIndex;
			//we want to check for TouchPhase.ENDED after it's bubbled
			//beyond the header renderer
			this.addEventListener(TouchEvent.TOUCH, dataGrid_touchHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function getHeaderDropIndex(globalX:Float):Int
	{
		var headerCount:Int = this._headerGroup.numChildren;
		var header:IDataGridHeaderRenderer;
		var point:Point;
		var headerGlobalMiddleX:Float;
		for (i in 0...headerCount)
		{
			header = cast this._headerGroup.getChildAt(i);
			point = Pool.getPoint(header.width / 2, 0);
			header.localToGlobal(point, point);
			headerGlobalMiddleX = point.x;
			Pool.putPoint(point);
			if (globalX < headerGlobalMiddleX)
			{
				return i;
			}
		}
		return headerCount;
	}
	
	/**
	 * @private
	 */
	private function dataGrid_dragEnterHandler(event:DragDropEvent):Void
	{
		if (DragDropManager.dragSource != this || !event.dragData.hasDataForFormat(DATA_GRID_HEADER_DRAG_FORMAT))
		{
			return;
		}
		DragDropManager.acceptDrag(this);
	}
	
	/**
	 * @private
	 */
	private function dataGrid_dragMoveHandler(event:DragDropEvent):Void
	{
		if (DragDropManager.dragSource != this || !event.dragData.hasDataForFormat(DATA_GRID_HEADER_DRAG_FORMAT))
		{
			return;
		}
		var point:Point = Pool.getPoint(event.localX, event.localY);
		this.localToGlobal(point, point);
		var globalDropX:Float = point.x;
		Pool.putPoint(point);
		var dropIndex:Int = this.getHeaderDropIndex(globalDropX);
		var showDropIndicator:Bool = dropIndex != this._draggedHeaderIndex &&
			dropIndex != (this._draggedHeaderIndex + 1);
		this._currentColumnDropIndicatorSkin.visible = showDropIndicator;
		if (!showDropIndicator)
		{
			return;
		}
		if (this._extendedColumnDropIndicator)
		{
			this._currentColumnDropIndicatorSkin.height = this._headerGroup.height + this._viewPort.visibleHeight;
		}
		else
		{
			this._currentColumnDropIndicatorSkin.height = this._headerGroup.height;
		}
		if (Std.isOfType(this._currentColumnDropIndicatorSkin, IValidating))
		{
			cast(this._currentColumnDropIndicatorSkin, IValidating).validate();
		}
		var dropIndicatorX:Float = 0;
		var header:DisplayObject;
		if (dropIndex == this._columns.length)
		{
			header = this._headerGroup.getChildAt(dropIndex - 1);
			dropIndicatorX = header.x + header.width;
		}
		else
		{
			header = this._headerGroup.getChildAt(dropIndex);
			dropIndicatorX = header.x;
		}
		this._currentColumnDropIndicatorSkin.x = this._headerGroup.x + dropIndicatorX - (this._currentColumnDropIndicatorSkin.width / 2);
		this._currentColumnDropIndicatorSkin.y = this._headerGroup.y;
	}
	
	/**
	 * @private
	 */
	private function dataGrid_dragDropHandler(event:DragDropEvent):Void
	{
		if (DragDropManager.dragSource != this || !event.dragData.hasDataForFormat(DATA_GRID_HEADER_DRAG_FORMAT))
		{
			return;
		}
		var point:Point = Pool.getPoint(event.localX, event.localY);
		this.localToGlobal(point, point);
		var globalDropX:Float = point.x;
		Pool.putPoint(point);
		var dropIndex:Int = this.getHeaderDropIndex(globalDropX);
		if (dropIndex == this._draggedHeaderIndex ||
			(dropIndex == (this._draggedHeaderIndex + 1)))
		{
			//it's the same position, so do nothing
			return;
		}
		if (dropIndex > this._draggedHeaderIndex)
		{
			dropIndex--;
		}
		var column:DataGridColumn = cast this._columns.removeItemAt(this._draggedHeaderIndex);
		this._columns.addItemAt(column, dropIndex);
	}
	
	/**
	 * @private
	 */
	private function headerDivider_touchHandler(event:TouchEvent):Void
	{
		var divider:DisplayObject = cast event.currentTarget;
		if (!this._isEnabled)
		{
			this._headerDividerTouchID = -1;
			return;
		}
		var dividerIndex:Int = this._headerDividerStorage.activeDividers.indexOf(divider);
		if (dividerIndex == (this._headerDividerStorage.activeDividers.length - 1) &&
			this._scrollBarDisplayMode == ScrollBarDisplayMode.FIXED &&
			this._minVerticalScrollPosition != this._maxVerticalScrollPosition)
		{
			//no resizing!
			return;
		}
		var column:DataGridColumn;
		var headerRenderer:IDataGridHeaderRenderer;
		var touch:Touch;
		if (this._headerDividerTouchID != -1)
		{
			//a touch has begun, so we'll ignore all other touches.
			touch = event.getTouch(divider, null, this._headerDividerTouchID);
			if (touch == null)
			{
				//this should not happen.
				return;
			}
			
			if (touch.phase == TouchPhase.ENDED)
			{
				this.calculateResizedColumnWidth();
				this._resizingColumnIndex = -1;
				
				this._currentColumnResizeSkin.removeFromParent(this._currentColumnResizeSkin != this._columnResizeSkin);
				this._currentColumnResizeSkin = null;
				this._headerDividerTouchID = -1;
			}
			else if (touch.phase == TouchPhase.MOVED)
			{
				column = cast this._columns.getItemAt(this._resizingColumnIndex);
				headerRenderer = cast this._headerGroup.getChildAt(this._resizingColumnIndex);
				var minX:Float = headerRenderer.x + column.minWidth;
				var maxX:Float = this.actualWidth - this._currentColumnResizeSkin.width - this._rightViewPortOffset;
				var difference:Float = touch.globalX - this._headerDividerTouchX;
				var newX:Float = divider.x + (divider.width / 2) - (this._currentColumnResizeSkin.width / 2) + difference;
				if (newX < minX)
				{
					newX = minX;
				}
				else if (newX > maxX)
				{
					newX = maxX;
				}
				this._currentColumnResizeSkin.x = newX;
				this._currentColumnResizeSkin.y = this._headerGroup.y;
				this._currentColumnResizeSkin.height = this.actualHeight - this._bottomViewPortOffset - this._currentColumnResizeSkin.y;
			}
		}
		else if (this._resizableColumns)
		{
			//we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(divider, TouchPhase.BEGAN);
			if  (touch == null)
			{
				return;
			}
			column = cast this._columns.getItemAt(dividerIndex);
			if (!column.resizable)
			{
				return;
			}
			this._resizingColumnIndex = dividerIndex;
			this._headerDividerTouchID = touch.id;
			this._headerDividerTouchX = touch.globalX;
			headerRenderer = cast this._headerGroup.getChildAt(dividerIndex);
			if (this._columnResizeSkin == null)
			{
				this._currentColumnResizeSkin = new Quad(1, 1, 0x000000);
			}
			else
			{
				this._currentColumnResizeSkin = this._columnResizeSkin;
			}
			this._currentColumnResizeSkin.height = this.actualHeight;
			this.addChild(this._currentColumnResizeSkin);
			if (Std.isOfType(this._currentColumnResizeSkin, IValidating))
			{
				cast(this._currentColumnResizeSkin, IValidating).validate();
			}
			this._currentColumnResizeSkin.x = divider.x + (divider.width / 2) - (this._currentColumnResizeSkin.width / 2);
		}
	}
	
	/**
	 * @private
	 */
	private function calculateResizedColumnWidth():Void
	{
		var columnCount:Int = this._columns.length;
		if (this._customColumnSizes == null)
		{
			this._customColumnSizes = new Array<Float>();
		}
		else
		{
			//make a copy so that it will be detected as a change
			this._customColumnSizes = this._customColumnSizes.copy();
			//try to keep any column widths we already saved
			this._customColumnSizes.resize(columnCount);
		}
		var column:DataGridColumn = cast this._columns.getItemAt(this._resizingColumnIndex);
		//clear the explicit width because the user resized it
		column.width = Math.NaN;
		var headerRenderer:IDataGridHeaderRenderer = cast this._headerGroup.getChildAt(this._resizingColumnIndex);
		var preferredWidth:Float = this._currentColumnResizeSkin.x + (this._currentColumnResizeSkin.width / 2) - headerRenderer.x;
		var totalMinWidth:Float = 0;
		var originalWidth:Float = headerRenderer.width;
		var totalWidthAfter:Float = 0;
		var indicesAfter:Array<Int> = new Array<Int>();
		var currentColumn:DataGridColumn;
		var columnWidth:Float;
		for (i in 0...columnCount)
		{
			currentColumn = cast this._columns.getItemAt(i);
			if (i == this._resizingColumnIndex)
			{
				continue;
			}
			else if (i < this._resizingColumnIndex)
			{
				//we want these columns to maintain their width so that the
				//resized one will start at the same x position
				//however, we're not setting the width property on the
				//DataGridColumn because we want them to be able to resize
				//later if the whole DataGrid resizes.
				headerRenderer = cast this._headerGroup.getChildAt(i);
				this._customColumnSizes[i] = headerRenderer.width;
				totalMinWidth += headerRenderer.width;
			}
			else
			{
				if (currentColumn.width == currentColumn.width) //!isNaN
				{
					totalMinWidth += currentColumn.width;
					continue;
				}
				else
				{
					totalMinWidth += currentColumn.minWidth;
				}
				headerRenderer = cast this._headerGroup.getChildAt(i);
				columnWidth = headerRenderer.width;
				totalWidthAfter += columnWidth;
				this._customColumnSizes[i] = columnWidth;
				indicesAfter[indicesAfter.length] = i;
			}
		}
		if (indicesAfter.length == 0)
		{
			//if all of the columns after the resizing one have explicit
			//widths, we need to force one to be resized
			var index:Int = this._resizingColumnIndex + 1;
			indicesAfter[0] = index;
			column = cast this._columns.getItemAt(index);
			totalWidthAfter = column.width;
			totalMinWidth -= totalWidthAfter;
			totalMinWidth += column.minWidth;
			this._customColumnSizes[index] = totalWidthAfter;
			column.width = Math.NaN;
		}
		var newWidth:Float = preferredWidth;
		var maxWidth:Float = this._headerGroup.width - totalMinWidth - this._leftViewPortOffset - this._rightViewPortOffset;
		if (newWidth > maxWidth)
		{
			newWidth = maxWidth;
		}
		if (newWidth < column.minWidth)
		{
			newWidth = column.minWidth;
		}
		this._customColumnSizes[this._resizingColumnIndex] = newWidth;
		
		//the width to distribute may be positive or negative, depending on
		//whether the resized column was made smaller or larger
		var widthToDistribute:Float = originalWidth - newWidth;
		this.distributeWidthToIndices(widthToDistribute, indicesAfter, totalWidthAfter);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
}

class HeaderRendererFactoryStorage
{
	public function new()
	{
		
	}
	
	public var activeHeaderRenderers:Array<IDataGridHeaderRenderer> = new Array<IDataGridHeaderRenderer>();
	public var inactiveHeaderRenderers:Array<IDataGridHeaderRenderer> = new Array<IDataGridHeaderRenderer>();
	public var factory:Void->IDataGridHeaderRenderer;
	public var customHeaderRendererStyleName:String;
	public var columnIndex:Int = -1;
}

class DividerFactoryStorage
{
	public function new()
	{
		
	}
	
	public var activeDividers:Array<DisplayObject> = new Array<DisplayObject>();
	public var inactiveDividers:Array<DisplayObject> = new Array<DisplayObject>();
	public var factory:Void->DisplayObject;
}