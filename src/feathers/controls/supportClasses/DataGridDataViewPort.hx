/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.supportClasses;

import feathers.controls.renderers.IDataGridCellRenderer;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IValidating;
import feathers.data.IListCollection;
import feathers.data.ListCollection;
import feathers.events.CollectionEventType;
import feathers.events.FeathersEventType;
import feathers.layout.ILayout;
import feathers.layout.IVariableVirtualLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.ViewPortBounds;
import feathers.utils.type.SafeCast;
import haxe.ds.ObjectMap;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.utils.Pool;

/**
 * @private
 * Used internally by DataGrid. Not meant to be used on its own.
 *
 * @see feathers.controls.DataGrid
 *
 * @productversion Feathers 3.4.0
 */
class DataGridDataViewPort extends FeathersControl implements IViewPort
{
	private static inline var INVALIDATION_FLAG_ROW_RENDERER_FACTORY:String = "rowRendererFactory";
	private static var HELPER_VECTOR:Array<Int> = new Array<Int>();
	
	public function new() 
	{
		super();
	}
	
	private var _viewPortBounds:ViewPortBounds = new ViewPortBounds();
	
	private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
	
	private var _typicalRowIsInDataProvider:Bool = false;
	private var _typicalRowRenderer:DataGridRowRenderer;
	private var _rows:Array<DisplayObject> = new Array<DisplayObject>();
	private var _rowRendererMap:ObjectMap<Dynamic, DataGridRowRenderer> = new ObjectMap<Dynamic, DataGridRowRenderer>();
	private var _unrenderedRows:Array<Int> = new Array<Int>();
	private var _rowStorage:RowRendererFactoryStorage = new RowRendererFactoryStorage();
	private var _minimumRowCount:Int = 0;
	
	private var _actualMinVisibleWidth:Float = 0;
	
	private var _explicitMinVisibleWidth:Float = Math.NaN;
	
	public var minVisibleWidth(get, set):Float;
	private function get_minVisibleWidth():Float
	{
		if (this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return this._actualMinVisibleWidth;
		}
		return this._explicitMinVisibleWidth;
	}
	
	private function set_minVisibleWidth(value:Float):Float
	{
		if (this._explicitMinVisibleWidth == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return value;
		}
		var oldValue:Float = this._explicitMinVisibleWidth;
		this._explicitMinVisibleWidth = value;
		if (valueIsNaN)
		{
			this._actualMinVisibleWidth = 0;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleWidth = value;
			if(this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
				(this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue))
			{
				//only invalidate if this change might affect the visibleWidth
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
		return this._explicitMinVisibleWidth;
	}
	
	public var maxVisibleWidth(get, set):Float;
	private var _maxVisibleWidth:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleWidth():Float { return this._maxVisibleWidth; }
	private function set_maxVisibleWidth(value:Float):Float
	{
		if (this._maxVisibleWidth == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleWidth cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleWidth;
		this._maxVisibleWidth = value;
		if (this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
			(this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue))
		{
			//only invalidate if this change might affect the visibleWidth
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._maxVisibleWidth;
	}
	
	private var _actualVisibleWidth:Float = 0;
	
	private var _explicitVisibleWidth:Float = Math.NaN;
	
	public var visibleWidth(get, set):Float;
	private function get_visibleWidth():Float { return this._actualVisibleWidth; }
	private function set_visibleWidth(value:Float):Float
	{
		if (this._explicitVisibleWidth == value ||
			(value != value && this._explicitVisibleWidth != this._explicitVisibleWidth)) //isNaN
		{
			return value;
		}
		this._explicitVisibleWidth = value;
		if (this._actualVisibleWidth != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._explicitVisibleWidth;
	}
	
	private var _actualMinVisibleHeight:Float = 0;
	
	private var _explicitMinVisibleHeight:Float = Math.NaN;
	
	public var minVisibleHeight(get, set):Float;
	private function get_minVisibleHeight():Float
	{
		if (this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) //isNaN
		{
			return this._actualMinVisibleHeight;
		}
		return this._explicitMinVisibleHeight;
	}
	
	private function set_minVisibleHeight(value:Float):Float
	{
		if (this._explicitMinVisibleHeight == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) //isNaN
		{
			return value;
		}
		var oldValue:Float = this._explicitMinVisibleHeight;
		this._explicitMinVisibleHeight = value;
		if (valueIsNaN)
		{
			this._actualMinVisibleHeight = 0;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight != this._explicitVisibleHeight && //isNaN
				(this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue))
			{
				//only invalidate if this change might affect the visibleHeight
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
		return this._explicitMinVisibleHeight;
	}
	
	public var maxVisibleHeight(get, set):Float;
	private var _maxVisibleHeight:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleHeight():Float { return this._maxVisibleHeight; }
	private function set_maxVisibleHeight(value:Float):Float
	{
		if (this._maxVisibleHeight == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleHeight cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleHeight;
		this._maxVisibleHeight = value;
		if (this._explicitVisibleHeight != this._explicitVisibleHeight && //isNaN
			(this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue))
		{
			//only invalidate if this change might affect the visibleHeight
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._maxVisibleHeight;
	}
	
	private var _actualVisibleHeight:Float = 0;
	
	private var _explicitVisibleHeight:Float = Math.NaN;
	
	public var visibleHeight(get, set):Float;
	private function get_visibleHeight():Float { return this._actualVisibleHeight; }
	private function set_visibleHeight(value:Float):Float
	{
		if(this._explicitVisibleHeight == value ||
			(value != value && this._explicitVisibleHeight != this._explicitVisibleHeight)) //isNaN
		{
			return value;
		}
		this._explicitVisibleHeight = value;
		if (this._actualVisibleHeight != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._explicitVisibleHeight;
	}
	
	public var contentX(get, never):Float;
	private var _contentX:Float = 0;
	private function get_contentX():Float { return this._contentX; }
	
	public var contentY(get, never):Float;
	private var _contentY:Float = 0;
	private function get_contentY():Float { return this._contentY; }
	
	public var horizontalScrollPosition(get, set):Float;
	private var _horizontalScrollPosition:Float = 0;
	private function get_horizontalScrollPosition():Float { return this._horizontalScrollPosition; }
	private function set_horizontalScrollPosition(value:Float):Float
	{
		if (this._horizontalScrollPosition == value)
		{
			return value;
		}
		this._horizontalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		return this._horizontalScrollPosition;
	}
	
	public var verticalScrollPosition(get, set):Float;
	private var _verticalScrollPosition:Float = 0;
	private function get_verticalScrollPosition():Float { return this._verticalScrollPosition; }
	private function set_verticalScrollPosition(value:Float):Float
	{
		if (this._verticalScrollPosition == value)
		{
			return value;
		}
		this._verticalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		return this._verticalScrollPosition;
	}
	
	public var horizontalScrollStep(get, never):Float;
	private function get_horizontalScrollStep():Float
	{
		var rowRenderer:DisplayObject = null;
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			if (this._rows.length != 0)
			{
				rowRenderer = cast this._rows[0];
			}
		}
		if (rowRenderer == null)
		{
			rowRenderer = this._typicalRowRenderer != null ? cast this._typicalRowRenderer : null;
		}
		if (rowRenderer == null)
		{
			return 0;
		}
		var rowRendererWidth:Float = rowRenderer.width;
		var rowRendererHeight:Float = rowRenderer.height;
		if (rowRendererWidth < rowRendererHeight)
		{
			return rowRendererWidth;
		}
		return rowRendererHeight;
	}
	
	public var verticalScrollStep(get, never):Float;
	private function get_verticalScrollStep():Float
	{
		var rowRenderer:DisplayObject = null;
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			if (this._rows.length != 0)
			{
				rowRenderer = cast this._rows[0];
			}
		}
		if (rowRenderer == null)
		{
			rowRenderer = this._typicalRowRenderer != null ? cast this._typicalRowRenderer : null;
		}
		if (rowRenderer == null)
		{
			return 0;
		}
		var rowRendererWidth:Float = rowRenderer.width;
		var rowRendererHeight:Float = rowRenderer.height;
		if (rowRendererWidth < rowRendererHeight)
		{
			return rowRendererWidth;
		}
		return rowRendererHeight;
	}
	
	public var owner(get, set):DataGrid;
	private var _owner:DataGrid;
	private function get_owner():DataGrid { return this._owner; }
	private function set_owner(value:DataGrid):DataGrid
	{
		return this._owner = value;
	}
	
	private var _updateForDataReset:Bool = false;
	
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
			this._dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
			this._dataProvider.removeEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null)
		{
			this._dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
			this._dataProvider.addEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
			this._dataProvider.addEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);
		}
		if (Std.isOfType(this._layout, IVariableVirtualLayout))
		{
			cast(this._layout, IVariableVirtualLayout).resetVariableVirtualCache();
		}
		this._updateForDataReset = true;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataProvider;
	}
	
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
		}
		this._columns = value;
		if (this._columns != null)
		{
			this._columns.addEventListener(Event.CHANGE, columns_changeHandler);
		}
		
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._columns;
	}
	
	private var _ignoreLayoutChanges:Bool = false;
	private var _ignoreRendererResizing:Bool = false;
	
	public var layout(get, set):ILayout;
	private var _layout:ILayout;
	private function get_layout():ILayout { return this._layout; }
	private function set_layout(value:ILayout):ILayout
	{
		if (this._layout == value)
		{
			return value;
		}
		if (this._layout != null)
		{
			this._layout.removeEventListener(Event.CHANGE, layout_changeHandler);
		}
		this._layout = value;
		if (this._layout != null)
		{
			if (Std.isOfType(this._layout, IVariableVirtualLayout))
			{
				cast(this._layout, IVariableVirtualLayout).resetVariableVirtualCache();
			}
			this._layout.addEventListener(Event.CHANGE, layout_changeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._layout;
	}
	
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._customColumnSizes;
	}
	
	private var _ignoreSelectionChanges:Bool = false;
	
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
		if (!value)
		{
			this.selectedIndices = null;
		}
		return this._isSelectable;
	}
	
	public var allowMultipleSelection(get, set):Bool;
	private var _allowMultipleSelection:Bool = false;
	private function get_allowMultipleSelection():Bool { return this._allowMultipleSelection; }
	private function set_allowMultipleSelection(value:Bool):Bool
	{
		return this._allowMultipleSelection = value;
	}
	
	public var selectedIndices(get, set):ListCollection;
	private var _selectedIndices:ListCollection;
	private function get_selectedIndices():ListCollection { return this._selectedIndices; }
	private function set_selectedIndices(value:ListCollection):ListCollection
	{
		if (this._selectedIndices == value)
		{
			return value;
		}
		if (this._selectedIndices != null)
		{
			this._selectedIndices.removeEventListener(Event.CHANGE, selectedIndices_changeHandler);
		}
		this._selectedIndices = value;
		if (this._selectedIndices != null)
		{
			this._selectedIndices.addEventListener(Event.CHANGE, selectedIndices_changeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._selectedIndices;
	}
	
	public var requiresMeasurementOnScroll(get, never):Bool;
	private function get_requiresMeasurementOnScroll():Bool
	{
		return this._layout.requiresLayoutOnScroll &&
				(this._explicitVisibleWidth != this._explicitVisibleWidth || //isNaN
				this._explicitVisibleHeight != this._explicitVisibleHeight); //isNaN
	}
	
	public function calculateNavigationDestination(index:Int, keyCode:Int):Int
	{
		return this._layout.calculateNavigationDestination(this._rows, index, keyCode, this._layoutResult);
	}
	
	public function getScrollPositionForIndex(index:Int, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		return this._layout.getScrollPositionForIndex(index, this._rows,
			0, 0, this._actualVisibleWidth, this._actualVisibleHeight, result);
	}
	
	public function getNearestScrollPositionForIndex(index:Int, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		return this._layout.getNearestScrollPositionForIndex(index,
			this._horizontalScrollPosition, this._verticalScrollPosition,
			this._rows, 0, 0, this._actualVisibleWidth, this._actualVisibleHeight, result);
	}
	
	public function itemToCellRenderer(item:Dynamic, columnIndex:Int):IDataGridCellRenderer
	{
		var rowRenderer:DataGridRowRenderer = this._rowRendererMap.get(item);
		if (rowRenderer == null)
		{
			return null;
		}
		return rowRenderer.getCellRendererForColumn(columnIndex);
	}
	
	override public function dispose():Void
	{
		this.refreshInactiveRowRenderers(true);
		this.owner = null;
		this.layout = null;
		this.dataProvider = null;
		this.columns = null;
		this._rowRendererMap.clear();
		super.dispose();
	}
	
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var scrollInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SCROLL);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var selectionInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		var rowRendererInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_ROW_RENDERER_FACTORY);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		
		//scrolling only affects the layout is requiresLayoutOnScroll is true
		if (!layoutInvalid && scrollInvalid && this._layout != null && this._layout.requiresLayoutOnScroll)
		{
			layoutInvalid = true;
		}
		
		var basicsInvalid:Bool = sizeInvalid || dataInvalid || layoutInvalid || rowRendererInvalid;
		
		var oldIgnoreRendererResizing:Bool = this._ignoreRendererResizing;
		this._ignoreRendererResizing = true;
		var oldIgnoreLayoutChanges:Bool = this._ignoreLayoutChanges;
		this._ignoreLayoutChanges = true;
		
		if (scrollInvalid || sizeInvalid)
		{
			this.refreshViewPortBounds();
		}
		if (basicsInvalid)
		{
			this.refreshInactiveRowRenderers(false);
		}
		if (dataInvalid || layoutInvalid || rowRendererInvalid)
		{
			this.refreshLayoutTypicalItem();
		}
		if (basicsInvalid)
		{
			this.refreshRowRenderers();
		}
		if (selectionInvalid || basicsInvalid)
		{
			//unlike resizing renderers and layout changes, we only want to
			//stop listening for selection changes when we're forcibly
			//updating selection. other property changes on item renderers
			//can validly change selection, and we need to detect that.
			var oldIgnoreSelectionChanges:Bool = this._ignoreSelectionChanges;
			this._ignoreSelectionChanges = true;
			this.refreshSelection();
			this._ignoreSelectionChanges = oldIgnoreSelectionChanges;
		}
		if (stateInvalid || basicsInvalid)
		{
			this.refreshEnabled();
		}
		this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
		
		if (stateInvalid || selectionInvalid || stylesInvalid || basicsInvalid)
		{
			this._layout.layout(this._rows, this._viewPortBounds, this._layoutResult);
		}
		
		this._ignoreRendererResizing = oldIgnoreRendererResizing;
		
		this._contentX = this._layoutResult.contentX;
		this._contentY = this._layoutResult.contentY;
		this.saveMeasurements(this._layoutResult.contentWidth, this._layoutResult.contentHeight,
			this._layoutResult.contentWidth, this._layoutResult.contentHeight);
		this._actualVisibleWidth = this._layoutResult.viewPortWidth;
		this._actualVisibleHeight = this._layoutResult.viewPortHeight;
		this._actualMinVisibleWidth = this._layoutResult.viewPortWidth;
		this._actualMinVisibleHeight = this._layoutResult.viewPortHeight;
		
		//final validation to avoid juggler next frame issues
		this.validateRowRenderers();
	}
	
	private function refreshViewPortBounds():Void
	{
		var needsMinWidth:Bool = this._explicitMinVisibleWidth != this._explicitMinVisibleWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinVisibleHeight != this._explicitMinVisibleHeight; //isNaN
		this._viewPortBounds.x = 0;
		this._viewPortBounds.y = 0;
		this._viewPortBounds.scrollX = this._horizontalScrollPosition;
		this._viewPortBounds.scrollY = this._verticalScrollPosition;
		this._viewPortBounds.explicitWidth = this._explicitVisibleWidth;
		this._viewPortBounds.explicitHeight = this._explicitVisibleHeight;
		if (needsMinWidth)
		{
			this._viewPortBounds.minWidth = 0;
		}
		else
		{
			this._viewPortBounds.minWidth = this._explicitMinVisibleWidth;
		}
		if (needsMinHeight)
		{
			this._viewPortBounds.minHeight = 0;
		}
		else
		{
			this._viewPortBounds.minHeight = this._explicitMinVisibleHeight;
		}
		this._viewPortBounds.maxWidth = this._maxVisibleWidth;
		this._viewPortBounds.maxHeight = this._maxVisibleHeight;
	}
	
	private function refreshInactiveRowRenderers(forceCleanup:Bool):Void
	{
		var temp:Array<DataGridRowRenderer> = this._rowStorage.inactiveRowRenderers;
		this._rowStorage.inactiveRowRenderers = this._rowStorage.activeRowRenderers;
		this._rowStorage.activeRowRenderers = temp;
		if (this._rowStorage.activeRowRenderers.length != 0)
		{
			throw new IllegalOperationError("DataGridDataViewPort: active row renderers should be empty.");
		}
		if (forceCleanup)
		{
			this.recoverInactiveRowRenderers();
			this.freeInactiveRowRenderers(0);
			if (this._typicalRowRenderer != null)
			{
				if (this._typicalRowIsInDataProvider && this._typicalRowRenderer.data != null)
				{
					this._rowRendererMap.remove(this._typicalRowRenderer.data);
				}
				this.destroyRowRenderer(this._typicalRowRenderer);
				this._typicalRowRenderer = null;
				this._typicalRowIsInDataProvider = false;
			}
		}
		this._rows.resize(0);
	}
	
	private function recoverInactiveRowRenderers():Void
	{
		var inactiveRowRenderers:Array<DataGridRowRenderer> = this._rowStorage.inactiveRowRenderers;
		var itemCount:Int = inactiveRowRenderers.length;
		var rowRenderer:DataGridRowRenderer;
		for (i in 0...itemCount)
		{
			rowRenderer = inactiveRowRenderers[i];
			if (rowRenderer == null || rowRenderer.data == null)
			{
				continue;
			}
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, rowRenderer);
			this._rowRendererMap.remove(rowRenderer.data);
		}
	}
	
	private function freeInactiveRowRenderers(minimumItemCount:Int):Void
	{
		var inactiveRowRenderers:Array<DataGridRowRenderer> = this._rowStorage.inactiveRowRenderers;
		var activeRowRenderers:Array<DataGridRowRenderer> = this._rowStorage.activeRowRenderers;
		var activeRowRenderersCount:Int = activeRowRenderers.length;
		
		//we may keep around some extra renderers to avoid too much
		//allocation and garbage collection. they'll be hidden.
		var itemCount:Int = inactiveRowRenderers.length;
		var keepCount:Int = minimumItemCount - activeRowRenderersCount;
		if (keepCount > itemCount)
		{
			keepCount = itemCount;
		}
		var rowRenderer:DataGridRowRenderer;
		var i:Int = 0;
		//for (i in 0...keepCount)
		while (i < keepCount)
		{
			i++;
			rowRenderer = inactiveRowRenderers.shift();
			if (rowRenderer == null)
			{
				keepCount++;
				if (itemCount < keepCount)
				{
					keepCount = itemCount;
				}
				continue;
			}
			rowRenderer.data = null;
			rowRenderer.columns = null;
			rowRenderer.index = -1;
			rowRenderer.visible = false;
			rowRenderer.customColumnSizes = null;
			activeRowRenderers[activeRowRenderersCount] = rowRenderer;
			activeRowRenderersCount++;
		}
		itemCount -= keepCount;
		for (i in 0...itemCount)
		{
			rowRenderer = inactiveRowRenderers.shift();
			if (rowRenderer == null)
			{
				continue;
			}
			this.destroyRowRenderer(rowRenderer);
		}
	}
	
	private function createRowRenderer(item:Dynamic, rowIndex:Int, useCache:Bool, isTemporary:Bool):DataGridRowRenderer
	{
		var inactiveRowRenderers:Array<DataGridRowRenderer> = this._rowStorage.inactiveRowRenderers;
		var activeRowRenderers:Array<DataGridRowRenderer> = this._rowStorage.activeRowRenderers;
		var rowRenderer:DataGridRowRenderer = null;
		do
		{
			if (!useCache || isTemporary || inactiveRowRenderers.length == 0)
			{
				rowRenderer = new DataGridRowRenderer();
				this.addChild(rowRenderer);
			}
			else
			{
				rowRenderer = inactiveRowRenderers.shift();
			}
			//wondering why this all is in a loop?
			//_inactiveRenderers.shift() may return null because we're
			//storing null values instead of calling splice() to improve
			//performance.
		}
		while (rowRenderer == null);
		rowRenderer.data = item;
		rowRenderer.columns = this._columns;
		rowRenderer.index = rowIndex;
		rowRenderer.owner = this._owner;
		rowRenderer.customColumnSizes = this._customColumnSizes;
		
		if (!isTemporary)
		{
			this._rowRendererMap.set(item, rowRenderer);
			activeRowRenderers[activeRowRenderers.length] = rowRenderer;
			rowRenderer.addEventListener(Event.TRIGGERED, rowRenderer_triggeredHandler);
			rowRenderer.addEventListener(Event.CHANGE, rowRenderer_changeHandler);
			rowRenderer.addEventListener(FeathersEventType.RESIZE, rowRenderer_resizeHandler);
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, rowRenderer);
		}
		
		return rowRenderer;
	}
	
	private function destroyRowRenderer(rowRenderer:DataGridRowRenderer):Void
	{
		rowRenderer.removeEventListener(Event.TRIGGERED, rowRenderer_triggeredHandler);
		rowRenderer.removeEventListener(Event.CHANGE, rowRenderer_changeHandler);
		rowRenderer.removeEventListener(FeathersEventType.RESIZE, rowRenderer_resizeHandler);
		rowRenderer.data = null;
		rowRenderer.columns = null;
		rowRenderer.index = -1;
		this.removeChild(rowRenderer, true);
		rowRenderer.owner = null;
	}
	
	private function refreshLayoutTypicalItem():Void
	{
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			//the old layout was virtual, but this one isn't
			if (!this._typicalRowIsInDataProvider && this._typicalRowRenderer != null)
			{
				//it's safe to destroy this renderer
				this.destroyRowRenderer(this._typicalRowRenderer);
				this._typicalRowRenderer = null;
			}
			return;
		}
		var typicalItemIndex:Int = 0;
		var newTypicalItemIsInDataProvider:Bool = false;
		var typicalItem:Dynamic = this._typicalItem;
		if (typicalItem != null)
		{
			if (this._dataProvider != null)
			{
				typicalItemIndex = this._dataProvider.getItemIndex(typicalItem);
				newTypicalItemIsInDataProvider = typicalItemIndex != -1;
			}
			if (typicalItemIndex != -1)
			{
				typicalItemIndex = 0;
			}
		}
		else
		{
			if (this._dataProvider != null && this._dataProvider.length != 0)
			{
				newTypicalItemIsInDataProvider = true;
				typicalItem = this._dataProvider.getItemAt(0);
			}
		}
		
		var typicalRenderer:DataGridRowRenderer = null;
		//#1645 The typicalItem can be null if the data provider contains
		//a null value at index 0. this is the only time we allow null.
		if (typicalItem != null || newTypicalItemIsInDataProvider)
		{
			typicalRenderer = this._rowRendererMap.get(typicalItem);
			if (typicalRenderer != null)
			{
				//at this point, the item already has a row renderer.
				//(this doesn't necessarily mean that the current typical
				//item was the typical item last time this function was
				//called)
				
				//the index may have changed if items were added, removed or
				//reordered in the data provider
				typicalRenderer.index = typicalItemIndex;
			}
			if (typicalRenderer == null && this._typicalRowRenderer != null)
			{
				//the typical item has changed, and doesn't have a row
				//renderer yet. the previous typical item had a row
				//renderer, so we will try to reuse it.
				
				//we can reuse the existing typical row renderer if the old
				//typical item wasn't in the data provider. otherwise, it
				//may still be needed for the same item.
				var canReuse:Bool = !this._typicalRowIsInDataProvider;
				var oldTypicalItemRemoved:Bool = this._typicalRowIsInDataProvider &&
					this._dataProvider != null && this._dataProvider.getItemIndex(this._typicalRowRenderer.data) == -1;
				if (!canReuse && oldTypicalItemRemoved)
				{
					//special case: if the old typical item was in the data
					//provider, but it has been removed, it's safe to reuse.
					canReuse = true;
				}
				if (canReuse)
				{
					//we can reuse the item renderer used for the old
					//typical item!
					
					//if the old typical item was in the data provider,
					//remove it from the renderer map.
					if (this._typicalRowIsInDataProvider)
					{
						this._rowRendererMap.remove(this._typicalRowRenderer.data);
					}
					typicalRenderer = this._typicalRowRenderer;
					typicalRenderer.data = typicalItem;
					typicalRenderer.index = typicalItemIndex;
					//if the new typical item is in the data provider, add it
					//to the renderer map.
					if (newTypicalItemIsInDataProvider)
					{
						this._rowRendererMap.set(typicalItem, typicalRenderer);
					}
				}
			}
			if (typicalRenderer == null)
			{
				//if we still don't have a typical row renderer, we need to
				//create a new one.
				typicalRenderer = this.createRowRenderer(typicalItem, typicalItemIndex, false, !newTypicalItemIsInDataProvider);
				/* This is probably not necessary
				// typicalRenderer data must not be null or it will trigger an error on html5 target when the DataGrid is destroyed
				//typicalRenderer.data = typicalItem != null ? typicalItem : {};
				*/
				if (!this._typicalRowIsInDataProvider && this._typicalRowRenderer != null)
				{
					//get rid of the old typical row renderer if it isn't
					//needed anymore.  since it was not in the data
					//provider, we don't need to mess with the renderer map
					//dictionary or dispatch any events.
					this.destroyRowRenderer(this._typicalRowRenderer);
					this._typicalRowRenderer = null;
				}
			}
		}
		
		virtualLayout.typicalItem = typicalRenderer;
		this._typicalRowRenderer = typicalRenderer;
		this._typicalRowIsInDataProvider = newTypicalItemIsInDataProvider;
		if (this._typicalRowRenderer != null && !this._typicalRowIsInDataProvider)
		{
			//we need to know if this item renderer resizes to adjust the
			//layout because the layout may use this item renderer to resize
			//the other item renderers
			this._typicalRowRenderer.addEventListener(FeathersEventType.RESIZE, rowRenderer_resizeHandler);
		}
	}
	
	private function refreshRowRenderers():Void
	{
		if (this._typicalRowRenderer != null && this._typicalRowIsInDataProvider)
		{
			var inactiveRowRenderers:Array<DataGridRowRenderer> = this._rowStorage.inactiveRowRenderers;
			var activeRowRenderers:Array<DataGridRowRenderer> = this._rowStorage.activeRowRenderers;
			//this renderer is already is use by the typical item, so we
			//don't want to allow it to be used by other items.
			var inactiveIndex:Int = inactiveRowRenderers.indexOf(this._typicalRowRenderer);
			if (inactiveIndex != -1)
			{
				inactiveRowRenderers[inactiveIndex] = null;
			}
			//if refreshLayoutTypicalItem() was called, it will have already
			//added the typical row renderer to the active renderers. if
			//not, we need to do it here.
			var activeRendererCount:Int = activeRowRenderers.length;
			if (activeRendererCount == 0)
			{
				activeRowRenderers[activeRendererCount] = this._typicalRowRenderer;
			}
		}
		
		this.findUnrenderedRowData();
		this.recoverInactiveRowRenderers();
		this.renderUnrenderedRowData();
		this.freeInactiveRowRenderers(this._minimumRowCount);
	}
	
	private function findUnrenderedRowData():Void
	{
		var itemCount:Int = 0;
		if (this._dataProvider != null)
		{
			itemCount = this._dataProvider.length;
		}
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		var useVirtualLayout:Bool = virtualLayout != null && virtualLayout.useVirtualLayout;
		if (useVirtualLayout)
		{
			var point:Point = Pool.getPoint();
			virtualLayout.measureViewPort(itemCount, this._viewPortBounds, point);
			virtualLayout.getVisibleIndicesAtScrollPosition(this._horizontalScrollPosition, this._verticalScrollPosition, point.x, point.y, itemCount, HELPER_VECTOR);
			Pool.putPoint(point);
		}
		
		this._rows.resize(itemCount);
		
		var unrenderedItemCount:Int = itemCount;
		if (useVirtualLayout)
		{
			unrenderedItemCount = HELPER_VECTOR.length;
		}
		if (useVirtualLayout && this._typicalRowIsInDataProvider && this._typicalRowRenderer != null &&
			HELPER_VECTOR.indexOf(this._typicalRowRenderer.index) != -1)
		{
			//add an extra item renderer if the typical item is from the
			//data provider and it is visible. this helps keep the number of
			//item renderers constant!
			this._minimumRowCount = unrenderedItemCount + 1;
		}
		else
		{
			this._minimumRowCount = unrenderedItemCount;
		}
		
		var unrenderedDataLastIndex:Int = this._unrenderedRows.length;
		var index:Int;
		var item:Dynamic;
		var rowRenderer:DataGridRowRenderer;
		var activeRowRenderers:Array<DataGridRowRenderer>;
		var inactiveRowRenderers:Array<DataGridRowRenderer>;
		var inactiveIndex:Int;
		for (i in 0...unrenderedItemCount)
		{
			index = i;
			if (useVirtualLayout)
			{
				index = HELPER_VECTOR[i];
			}
			if (index < 0 || index >= itemCount)
			{
				continue;
			}
			item = this._dataProvider.getItemAt(index);
			rowRenderer = this._rowRendererMap.get(item);
			if (rowRenderer != null)
			{
				//the index may have changed if items were added, removed or
				//reordered in the data provider
				rowRenderer.index = index;
				//if this row renderer used to be the typical row
				//renderer, but it isn't anymore, it may have been set invisible!
				rowRenderer.visible = true;
				rowRenderer.customColumnSizes = this._customColumnSizes;
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
					rowRenderer.data = null;
					rowRenderer.data = item;
				}
				
				//the typical row renderer is a special case, and we will
				//have already put it into the active renderers, so we don't
				//want to do it again!
				if (this._typicalRowRenderer != rowRenderer)
				{
					activeRowRenderers = this._rowStorage.activeRowRenderers;
					inactiveRowRenderers = this._rowStorage.inactiveRowRenderers;
					activeRowRenderers[activeRowRenderers.length] = rowRenderer;
					inactiveIndex = inactiveRowRenderers.indexOf(rowRenderer);
					if (inactiveIndex != -1)
					{
						inactiveRowRenderers[inactiveIndex] = null;
					}
					else
					{
						throw new IllegalOperationError("DataGridDataViewPort: row renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
					}
				}
				this._rows[index] = rowRenderer;
			}
			else
			{
				this._unrenderedRows[unrenderedDataLastIndex] = index;
				unrenderedDataLastIndex++;
			}
		}
		//update the typical row renderer's visibility
		if (this._typicalRowRenderer != null)
		{
			if (useVirtualLayout && this._typicalRowIsInDataProvider)
			{
				index = HELPER_VECTOR.indexOf(this._typicalRowRenderer.index);
				if (index != -1)
				{
					this._typicalRowRenderer.visible = true;
				}
				else
				{
					this._typicalRowRenderer.visible = false;
					
					//uncomment these lines to see a hidden typical row for
					//debugging purposes...
					/*this._typicalRowRenderer.visible = true;
					this._typicalRowRenderer.x = this._horizontalScrollPosition;
					this._typicalRowRenderer.y = this._verticalScrollPosition;*/
				}
			}
			else
			{
				this._typicalRowRenderer.visible = this._typicalRowIsInDataProvider;
			}
		}
		HELPER_VECTOR.resize(0);
	}
	
	private function renderUnrenderedRowData():Void
	{
		var rowRendererCount:Int = this._unrenderedRows.length;
		var rowIndex:Int;
		var item:Dynamic;
		var rowRenderer:DataGridRowRenderer;
		for (i in 0...rowRendererCount)
		{
			rowIndex = this._unrenderedRows.shift();
			item = this._dataProvider.getItemAt(rowIndex);
			rowRenderer = this.createRowRenderer(item, rowIndex, true, false);
			rowRenderer.visible = true;
			this._rows[rowIndex] = rowRenderer;
		}
	}
	
	private function refreshSelection():Void
	{
		var itemCount:Int = this._rows.length;
		var rowRenderer:DataGridRowRenderer;
		for (i in 0...itemCount)
		{
			rowRenderer = SafeCast.safe_cast(this._rows[i], DataGridRowRenderer);
			if (rowRenderer != null)
			{
				rowRenderer.isSelected = this._selectedIndices.getItemIndex(rowRenderer.index) != -1;
			}
		}
	}
	
	private function refreshEnabled():Void
	{
		var itemCount:Int = this._rows.length;
		var control:IFeathersControl;
		for (i in 0...itemCount)
		{
			control = SafeCast.safe_cast(this._rows[i], IFeathersControl);
			if (control != null)
			{
				control.isEnabled = this._isEnabled;
			}
		}
	}
	
	private function validateRowRenderers():Void
	{
		var itemCount:Int = this._rows.length;
		var item:IValidating;
		for (i in 0...itemCount)
		{
			item = SafeCast.safe_cast(this._rows[i], IValidating);
			if (item != null)
			{
				item.validate();
			}
		}
	}
	
	private function invalidateParent(flag:String = FeathersControl.INVALIDATION_FLAG_ALL):Void
	{
		cast(this.parent, Scroller).invalidate(flag);
	}
	
	private function columns_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	private function dataProvider_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	private function dataProvider_addItemHandler(event:Event, index:Int):Void
	{
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.addToVariableVirtualCacheAtIndex(index);
	}
	
	private function dataProvider_removeItemHandler(event:Event, index:Int):Void
	{
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.removeFromVariableVirtualCacheAtIndex(index);
	}
	
	private function dataProvider_replaceItemHandler(event:Event, index:Int):Void
	{
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.resetVariableVirtualCacheAtIndex(index);
	}
	
	private function dataProvider_resetHandler(event:Event):Void
	{
		this._updateForDataReset = true;
		
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.resetVariableVirtualCache();
	}
	
	private function dataProvider_filterChangeHandler(event:Event):Void
	{
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		//we don't know exactly which indices have changed, so reset the
		//whole cache.
		layout.resetVariableVirtualCache();
	}
	
	private function dataProvider_updateItemHandler(event:Event, index:Int):Void
	{
		var item:Dynamic = this._dataProvider.getItemAt(index);
		var rowRenderer:DataGridRowRenderer = this._rowRendererMap.get(item);
		if (rowRenderer == null)
		{
			return;
		}
		//in order to display the same item with modified properties, this
		//hack tricks the item renderer into thinking that it has been given
		//a different item to render.
		rowRenderer.data = null;
		rowRenderer.data = item;
		if (this._explicitVisibleWidth != this._explicitVisibleWidth || //isNaN
			this._explicitVisibleHeight != this._explicitVisibleHeight) //isNaN
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			this.invalidateParent(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
	}
	
	private function dataProvider_updateAllHandler(event:Event):Void
	{
		//we're treating this similar to the RESET event because enough
		//users are treating UPDATE_ALL similarly. technically, UPDATE_ALL
		//is supposed to affect only existing items, but it's confusing when
		//new items are added and not displayed.
		this._updateForDataReset = true;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.resetVariableVirtualCache();
	}
	
	private function rowRenderer_triggeredHandler(event:Event):Void
	{
		var rowRenderer:DataGridRowRenderer = cast event.currentTarget;
		this.parent.dispatchEventWith(Event.TRIGGERED, false, rowRenderer.data);
	}
	
	private function rowRenderer_changeHandler(event:Event):Void
	{
		if (this._ignoreSelectionChanges)
		{
			return;
		}
		var rowRenderer:DataGridRowRenderer = cast event.currentTarget;
		if (!this._isSelectable || this._owner.isScrolling)
		{
			rowRenderer.isSelected = false;
			return;
		}
		var isSelected:Bool = rowRenderer.isSelected;
		var index:Int = rowRenderer.index;
		if (this._allowMultipleSelection)
		{
			var indexOfIndex:Int = this._selectedIndices.getItemIndex(index);
			if (isSelected && indexOfIndex == -1)
			{
				this._selectedIndices.addItem(index);
			}
			else if (!isSelected && indexOfIndex != -1)
			{
				this._selectedIndices.removeItemAt(indexOfIndex);
			}
		}
		else if (isSelected)
		{
			//var data:Array<Int> = [index];
			this._selectedIndices.data = [index];
		}
		else
		{
			this._selectedIndices.removeAll();
		}
	}
	
	private function rowRenderer_resizeHandler(event:Event):Void
	{
		if (this._ignoreRendererResizing)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		if (event.currentTarget == this._typicalRowRenderer && !this._typicalRowIsInDataProvider)
		{
			return;
		}
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		var rowRenderer:DataGridRowRenderer = cast event.currentTarget;
		layout.resetVariableVirtualCacheAtIndex(rowRenderer.index, rowRenderer);
	}
	
	private function layout_changeHandler(event:Event):Void
	{
		if (this._ignoreLayoutChanges)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	private function selectedIndices_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
}

class RowRendererFactoryStorage
{
	public function new()
	{
		
	}

	public var activeRowRenderers:Array<DataGridRowRenderer> = new Array<DataGridRowRenderer>();
	public var inactiveRowRenderers:Array<DataGridRowRenderer> = new Array<DataGridRowRenderer>();
}