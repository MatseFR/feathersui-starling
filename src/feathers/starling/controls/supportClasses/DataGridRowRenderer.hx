/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.supportClasses;

import feathers.starling.controls.DataGrid;
import feathers.starling.controls.DataGridColumn;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.controls.renderers.DefaultDataGridCellRenderer;
import feathers.starling.controls.renderers.IDataGridCellRenderer;
import feathers.starling.core.FeathersControl;
import feathers.starling.core.IToggle;
import feathers.starling.data.IListCollection;
import feathers.starling.events.CollectionEventType;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.HorizontalLayout;
import feathers.starling.layout.HorizontalLayoutData;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.utils.touch.TapToSelect;
import feathers.starling.utils.touch.TapToTrigger;
import feathers.starling.utils.type.SafeCast;
import openfl.errors.IllegalOperationError;
import starling.events.Event;

/**
 * @private
 * Used internally by DataGrid. Not meant to be used on its own.
 *
 * @see feathers.controls.DataGrid
 *
 * @productversion Feathers 3.4.0
 */
class DataGridRowRenderer extends LayoutGroup implements IToggle
{
	/**
	 * @private
	 */
	private static function defaultCellRendererFactory():IDataGridCellRenderer
	{
		return new DefaultDataGridCellRenderer();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * @private
	 */
	private var _tapToTrigger:TapToTrigger = null;

	/**
	 * @private
	 */
	private var _tapToSelect:TapToSelect = null;

	/**
	 * @private
	 */
	private var _unrenderedData:Array<Int> = new Array<Int>();

	/**
	 * @private
	 */
	private var _cellRendererMap:Map<DataGridColumn, IDataGridCellRenderer> = new Map<DataGridColumn, IDataGridCellRenderer>();

	/**
	 * @private
	 */
	private var _defaultStorage:CellRendererFactoryStorage = new CellRendererFactoryStorage();

	/**
	 * @private
	 */
	private var _additionalStorage:Array<CellRendererFactoryStorage> = null;
	
	/**
	 * The index (numeric position, starting from zero) of the item within
	 * the data grid's dat provider.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 */
	public var index(get, set):Int;
	private var _index:Int = -1;
	private function get_index():Int { return this._index; }
	private function set_index(value:Int):Int
	{
		if (this._index == value)
		{
			return value;
		}
		this._index = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._index;
	}
	
	/**
	 * The <code>DataGrid</code> component that owns this row renderer.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 */
	public var owner(get, set):DataGrid;
	private var _owner:DataGrid;
	private function get_owner():DataGrid { return this._owner; }
	private function set_owner(value:DataGrid):DataGrid
	{
		if (this._owner == value)
		{
			return value;
		}
		this._owner = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._owner;
	}
	
	/**
	 * The item from the data provider that is rendered by this row.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 */
	public var data(get, set):Dynamic;
	private var _data:Dynamic;
	private function get_data():Dynamic { return this._data; }
	private function set_data(value:Dynamic):Dynamic
	{
		if (this._data == value)
		{
			return value;
		}
		this._data = value;
		if (value == null)
		{
			//ensure that the data property of each cell renderer
			//is set to null before being set to any new value
			this._updateForDataReset = true;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._data;
	}
	
	/**
	 * @private
	 */
	private var _updateForDataReset:Bool = false;
	
	/**
	 * The columns from the data grid.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
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
		this._updateForDataReset = true;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._columns;
	}
	
	/**
	 * Indicates if the row is selected or not.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 */
	public var isSelected(get, set):Bool;
	private var _isSelected:Bool;
	private function get_isSelected():Bool { return this._isSelected; }
	private function set_isSelected(value:Bool):Bool
	{
		if (this._isSelected == value)
		{
			return value;
		}
		this._isSelected = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
		return this._isSelected;
	}
	
	/**
	 * @private
	 */
	public var customColumnSizes(get, set):Array<Float>;
	private var _customColumnSizes:Array<Float>;
	private function get_customColumnSizes():Array<Float> { return this._customColumnSizes; }
	private function set_customColumnSizes(value:Array<Float>):Array<Float>
	{
		if (this._customColumnSizes == value)
		{
			return value;
		}
		this._customColumnSizes = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._customColumnSizes;
	}
	
	/**
	 * Returns the cell renderer for the specified column index, or
	 * <code>null</code>, if no cell renderer can be found.
	 */
	public function getCellRendererForColumn(columnIndex:Int):IDataGridCellRenderer
	{
		var column:DataGridColumn = cast this._columns.getItemAt(columnIndex);
		var storage:CellRendererFactoryStorage = this.factoryToStorage(column.cellRendererFactory);
		var activeCellRenderers:Array<IDataGridCellRenderer> = storage.activeCellRenderers;
		if (columnIndex < 0 || columnIndex > activeCellRenderers.length)
		{
			return null;
		}
		return cast activeCellRenderers[columnIndex];
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void 
	{
		this.refreshInactiveCellRenderers(this._defaultStorage, true);
		if (this._additionalStorage != null)
		{
			var storageCount:Int = this._additionalStorage.length;
			var storage:CellRendererFactoryStorage;
			for (i in 0...storageCount)
			{
				storage = this._additionalStorage[i];
				this.refreshInactiveCellRenderers(storage, true);
			}
		}
		this.owner = null;
		this.data = null;
		this.columns = null;
		this._cellRendererMap.clear();
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void 
	{
		super.initialize();
		
		if (this._layout == null)
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = VerticalAlign.MIDDLE;
			layout.useVirtualLayout = false;
			this._layout = layout;
		}
		
		if (this._tapToTrigger == null)
		{
			this._tapToTrigger = new TapToTrigger(this);
		}
		
		if (this._tapToSelect == null)
		{
			this._tapToSelect = new TapToSelect(this);
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void 
	{
		var oldIgnoreChildChanges:Bool = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this.preLayout();
		this._ignoreChildChanges = oldIgnoreChildChanges;
		
		this.refreshSelectionEvents();
		
		super.draw();
	}
	
	/**
	 * @private
	 */
	private function preLayout():Void
	{
		this.refreshInactiveCellRenderers(this._defaultStorage, false);
		var storageCount:Int;
		var storage:CellRendererFactoryStorage;
		if (this._additionalStorage != null)
		{
			storageCount = this._additionalStorage.length;
			for (i in 0...storageCount)
			{
				storage = this._additionalStorage[i];
				this.refreshInactiveCellRenderers(storage, false);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveCellRenderers(this._defaultStorage);
		if (this._additionalStorage != null)
		{
			storageCount = this._additionalStorage.length;
			for (i in 0...storageCount)
			{
				storage = this._additionalStorage[i];
				this.recoverInactiveCellRenderers(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveCellRenderers(this._defaultStorage);
		if (this._additionalStorage != null)
		{
			storageCount = this._additionalStorage.length;
			for (i in 0...storageCount)
			{
				storage = this._additionalStorage[i];
				this.freeInactiveCellRenderers(storage);
			}
		}
		
		this._updateForDataReset = false;
	}
	
	/**
	 * @private
	 */
	private function refreshSelectionEvents():Void
	{
		this._tapToSelect.isEnabled = this._isEnabled;
		this._tapToSelect.tapToDeselect = this._owner.allowMultipleSelection;
	}
	
	/**
	 * @private
	 */
	private function createCellRenderer(columnIndex:Int, column:DataGridColumn):IDataGridCellRenderer
	{
		var cellRenderer:IDataGridCellRenderer = null;
		var storage:CellRendererFactoryStorage = this.factoryToStorage(column.cellRendererFactory);
		var activeCellRenderers:Array<IDataGridCellRenderer> = storage.activeCellRenderers;
		var inactiveCellRenderers:Array<IDataGridCellRenderer> = storage.inactiveCellRenderers;
		do
		{
			if (inactiveCellRenderers.length == 0)
			{
				var cellRendererFactory:Void->IDataGridCellRenderer = column.cellRendererFactory;
				if (cellRendererFactory == null)
				{
					cellRendererFactory = this._owner.cellRendererFactory;
				}
				if (cellRendererFactory == null)
				{
					cellRendererFactory = defaultCellRendererFactory;
				}
				cellRenderer = cellRendererFactory();
				var customCellRendererStyleName:String = column.customCellRendererStyleName;
				if (customCellRendererStyleName == null)
				{
					customCellRendererStyleName = this._owner.customCellRendererStyleName;
				}
				if (customCellRendererStyleName != null && customCellRendererStyleName.length != 0)
				{
					cellRenderer.styleNameList.add(customCellRendererStyleName);
				}
				this.addChildAt(cast cellRenderer, columnIndex);
			}
			else
			{
				cellRenderer = inactiveCellRenderers.shift();
			}
			//wondering why this all is in a loop?
			//_inactiveRenderers.shift() may return null because we're
			//storing null values instead of calling splice() to improve
			//performance.
		}
		while (cellRenderer == null);
		this.refreshCellRendererProperties(cellRenderer, columnIndex, column);
		
		column.addEventListener(Event.CHANGE, column_changeHandler);
		
		this._cellRendererMap[column] = cellRenderer;
		activeCellRenderers[activeCellRenderers.length] = cellRenderer;
		this._owner.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, cellRenderer);
		
		return cellRenderer;
	}
	
	/**
	 * @private
	 */
	private function destroyCellRenderer(cellRenderer:IDataGridCellRenderer):Void
	{
		if (cellRenderer.column != null)
		{
			cellRenderer.column.removeEventListener(Event.CHANGE, column_changeHandler);
		}
		cellRenderer.data = null;
		cellRenderer.owner = null;
		cellRenderer.rowIndex = -1;
		cellRenderer.columnIndex = -1;
		this.removeChild(cast cellRenderer, true);
	}
	
	/**
	 * @private
	 */
	private function factoryToStorage(factory:Void->IDataGridCellRenderer):CellRendererFactoryStorage
	{
		if (factory != null)
		{
			if (this._additionalStorage == null)
			{
				this._additionalStorage = new Array<CellRendererFactoryStorage>();
			}
			var storageCount:Int = this._additionalStorage.length;
			var storage:CellRendererFactoryStorage;
			for (i in 0...storageCount)
			{
				storage = this._additionalStorage[i];
				if (storage.factory == factory)
				{
					return storage;
				}
			}
			storage = new CellRendererFactoryStorage(factory);
			this._additionalStorage[this._additionalStorage.length] = storage;
			return storage;
		}
		return this._defaultStorage;
	}
	
	/**
	 * @private
	 */
	private function refreshInactiveCellRenderers(storage:CellRendererFactoryStorage, forceCleanup:Bool):Void
	{
		var temp:Array<IDataGridCellRenderer> = storage.inactiveCellRenderers;
		storage.inactiveCellRenderers = storage.activeCellRenderers;
		storage.activeCellRenderers = temp;
		if (storage.activeCellRenderers.length != 0)
		{
			throw new IllegalOperationError("DataGridRowRenderer: active cell renderers should be empty.");
		}
		if (forceCleanup)
		{
			this.recoverInactiveCellRenderers(storage);
			this.freeInactiveCellRenderers(storage);
		}
	}
	
	/**
	 * @private
	 */
	private function findUnrenderedData():Void
	{
		var columns:IListCollection = this._owner.columns;
		var columnCount:Int = columns.length;
		var unrenderedDataLastIndex:Int = this._unrenderedData.length;
		var column:DataGridColumn;
		var cellRenderer:IDataGridCellRenderer;
		var storage:CellRendererFactoryStorage;
		var activeCellRenderers:Array<IDataGridCellRenderer>;
		var inactiveCellRenderers:Array<IDataGridCellRenderer>;
		var inactiveIndex:Int;
		
		for (i in 0...columnCount)
		{
			if (i < 0 || i >= columnCount)
			{
				continue;
			}
			column = cast columns.getItemAt(i);
			cellRenderer = SafeCast.safe_cast(this._cellRendererMap[column], IDataGridCellRenderer);
			if (cellRenderer != null)
			{
				//the properties may have changed if items were added, removed or
				//reordered in the data provider
				this.refreshCellRendererProperties(cellRenderer, i, column);
				
				storage = this.factoryToStorage(column.cellRendererFactory);
				activeCellRenderers = storage.activeCellRenderers;
				inactiveCellRenderers = storage.inactiveCellRenderers;
				
				activeCellRenderers[activeCellRenderers.length] = cellRenderer;
				inactiveIndex = inactiveCellRenderers.indexOf(cellRenderer);
				if (inactiveIndex != -1)
				{
					inactiveCellRenderers[inactiveIndex] = null;
				}
				else
				{
					throw new IllegalOperationError("DataGridRowRenderer: cell renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
			}
			else
			{
				this._unrenderedData[unrenderedDataLastIndex] = i;
				unrenderedDataLastIndex++;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function recoverInactiveCellRenderers(storage:CellRendererFactoryStorage):Void
	{
		var inactiveCellRenderers:Array<IDataGridCellRenderer> = storage.inactiveCellRenderers;
		var itemCount:Int = inactiveCellRenderers.length;
		var cellRenderer:IDataGridCellRenderer;
		for (i in 0...itemCount)
		{
			cellRenderer = inactiveCellRenderers[i];
			if (cellRenderer == null || cellRenderer.column == null)
			{
				continue;
			}
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, cellRenderer);
			this._cellRendererMap.remove(cellRenderer.column);
		}
	}
	
	/**
	 * @private
	 */
	private function renderUnrenderedData():Void
	{
		var columns:IListCollection = this._owner.columns;
		var cellRendererCount:Int = this._unrenderedData.length;
		var columnIndex:Int;
		var column:DataGridColumn;
		var cellRenderer:IDataGridCellRenderer;
		for (i in 0...cellRendererCount)
		{
			columnIndex = this._unrenderedData.shift();
			column = cast columns.getItemAt(i);
			cellRenderer = this.createCellRenderer(columnIndex, column);
		}
	}
	
	/**
	 * @private
	 */
	private function freeInactiveCellRenderers(storage:CellRendererFactoryStorage):Void
	{
		//var activeCellRenderers:Array<IDataGridCellRenderer> = storage.activeCellRenderers; // this is not in use
		var inactiveCellRenderers:Array<IDataGridCellRenderer> = storage.inactiveCellRenderers;
		//var activeCellRenderersCount:Int = activeCellRenderers.length; // this is not in use
		var itemCount:Int = inactiveCellRenderers.length;
		var cellRenderer:IDataGridCellRenderer;
		for (i in 0...itemCount)
		{
			cellRenderer = inactiveCellRenderers.shift();
			if (cellRenderer == null)
			{
				continue;
			}
			this.destroyCellRenderer(cellRenderer);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshCellRendererProperties(cellRenderer:IDataGridCellRenderer, columnIndex:Int, column:DataGridColumn):Void
	{
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
			cellRenderer.data = null;
			cellRenderer.column = null;
		}
		cellRenderer.owner = this._owner;
		cellRenderer.data = this._data;
		cellRenderer.rowIndex = this._index;
		cellRenderer.column = column;
		cellRenderer.columnIndex = columnIndex;
		cellRenderer.isSelected = this._isSelected;
		cellRenderer.dataField = column.dataField;
		cellRenderer.minWidth = column.minWidth;
		if (column.width == column.width) //!isNaN
		{
			cellRenderer.width = column.width;
			cellRenderer.layoutData = null;
		}
		else if (this._customColumnSizes != null && columnIndex < this._customColumnSizes.length)
		{
			cellRenderer.width = this._customColumnSizes[columnIndex];
			cellRenderer.layoutData = null;
		}
		else
		{
			var layoutData:HorizontalLayoutData = SafeCast.safe_cast(cellRenderer.layoutData, HorizontalLayoutData);
			if (layoutData == null)
			{
				cellRenderer.layoutData = new HorizontalLayoutData(100, Math.NaN);
			}
			else
			{
				layoutData.percentWidth = 100;
				layoutData.percentHeight = Math.NaN;
			}
		}
		this.setChildIndex(cast cellRenderer, columnIndex);
	}
	
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function column_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		//since we extend LayoutGroup, and the DataGridColumn includes some
		//layout information, we need to use this flag too
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
}

class CellRendererFactoryStorage
{
	public function new(factory:Void->IDataGridCellRenderer = null)
	{
		this.factory = factory;
	}

	public var activeCellRenderers:Array<IDataGridCellRenderer> = new Array<IDataGridCellRenderer>();
	public var inactiveCellRenderers:Array<IDataGridCellRenderer> = new Array<IDataGridCellRenderer>();
	public var factory:Void->IDataGridCellRenderer;
}