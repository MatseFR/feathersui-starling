/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

import feathers.starling.controls.renderers.IDataGridCellRenderer;
import feathers.starling.controls.renderers.IDataGridHeaderRenderer;
import feathers.starling.data.SortOrder;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * Configures a column in a <code>DataGrid</code> component.
 *
 * @see feathers.controls.DataGrid
 *
 * @productversion Feathers 3.4.0
 */
class DataGridColumn extends EventDispatcher 
{
	/**
	 * Constructor.
	 */
	public function new(dataField:String = null, headerText:String = null) 
	{
		super();
		this.dataField = dataField;
		this.headerText = headerText;
	}
	
	/**
	 * The text to display in the column's header.
	 *
	 * <p>In the following example, the header text is customized:</p>
	 *
	 * <listing version="3.0">
	 * column.headerText = "Customer Name";</listing>
	 *
	 * @default null
	 */
	public var headerText(get, set):String;
	private var _headerText:String;
	private function get_headerText():String { return this._headerText; }
	private function set_headerText(value:String):String
	{
		if (this._headerText == value)
		{
			return value;
		}
		this._headerText = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._headerText;
	}
	
	/**
	 * The field in the item that contains the data to be displayed by
	 * the cell renderers in this column. If the item does not have this
	 * field, then the renderer may default to calling <code>toString()</code>
	 * on the item.
	 *
	 * <p>In the following example, the data field is customized:</p>
	 *
	 * <listing version="3.0">
	 * column.dataField = "name";</listing>
	 *
	 * @default null
	 */
	public var dataField(get, set):String;
	private var _dataField:String;
	private function get_dataField():String { return this._dataField; }
	private function set_dataField(value:String):String
	{
		if (this._dataField == value)
		{
			return value;
		}
		this._dataField = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._dataField;
	}
	
	/**
	 * A function called that is expected to return a new cell renderer.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IDataGridCellRenderer</pre>
	 *
	 * <p>The following example provides a factory for the cell renderer:</p>
	 *
	 * <listing version="3.0">
	 * column.cellRendererFactory = function():IDataGridCellRenderer
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
	 * A style name to add to all cell renderers in this column. Typically
	 * used by a theme to provide different skins to different columns.
	 *
	 * <p>The following example sets the cell renderer style name:</p>
	 *
	 * <listing version="3.0">
	 * column.customCellRendererStyleName = "my-custom-cell-renderer";</listing>
	 *
	 * <p>In your theme, you can target this sub-component name to provide
	 * different skins than the default style:</p>
	 *
	 * <listing version="3.0">
	 * getStyleProviderForClass( DefaultDataGridCellRenderer ).setFunctionForStyleName( "my-custom-cell-renderer", setCustomCellRendererStyles );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.FeathersControl#styleNameList
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
	 * A function called that is expected to return a new header renderer.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IDataGridHeaderRenderer</pre>
	 *
	 * <p>The following example provides a factory for the header renderer:</p>
	 *
	 * <listing version="3.0">
	 * column.headerRendererFactory = function():IDataGridHeaderRenderer
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
	 * A style name to add to all header renderers in this column. Typically
	 * used by a theme to provide different skins to different columns.
	 *
	 * <p>The following example sets the header renderer name:</p>
	 *
	 * <listing version="3.0">
	 * column.customHeaderRendererStyleName = "my-custom-header-renderer";</listing>
	 *
	 * <p>In your theme, you can target this sub-component name to provide
	 * different skins than the default style:</p>
	 *
	 * <listing version="3.0">
	 * getStyleProviderForClass( DefaultDataGridHeaderRenderer ).setFunctionForStyleName( "my-custom-header-renderer", setCustomHeaderRendererStyles );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.FeathersControl#styleNameList
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
	 * The minimum width of the column, in pixels.
	 *
	 * <p>The following example sets the column minimum width:</p>
	 *
	 * <listing version="3.0">
	 * column.minWidth = 200;</listing>
	 *
	 * @default 10
	 */
	public var minWidth(get, set):Float;
	private var _minWidth:Float = 10;
	private function get_minWidth():Float { return this._minWidth; }
	private function set_minWidth(value:Float):Float
	{
		if (this._minWidth == value)
		{
			return value;
		}
		this._minWidth = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._minWidth;
	}
	
	/**
	 * The width of the column, in pixels. If the width is set to
	 * <code>NaN</code>, the column will be sized automatically by the
	 * data grid's layout.
	 *
	 * <p>The following example sets the column width:</p>
	 *
	 * <listing version="3.0">
	 * column.width = 200;</listing>
	 *
	 * @default NaN
	 */
	public var width(get, set):Float;
	private var _width:Float = Math.NaN;
	private function get_width():Float { return this._width; }
	private function set_width(value:Float):Float
	{
		if (this._width == value)
		{
			return value;
		}
		this._width = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._width;
	}
	
	/**
	 * A function to compare each item in the collection to determine the
	 * order when sorted.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( a:Object, b:Object ):int</pre>
	 *
	 * <p>The return value should be <code>-1</code> if the first item
	 * should appear before the second item when the collection is sorted.
	 * The return value should be <code>1</code> if the first item should
	 * appear after the second item when the collection in sorted. Finally,
	 * the return value should be <code>0</code> if both items have the
	 * same sort order.</p>
	 *
	 * @default null
	 *
	 * @see #sortOrder
	 */
	public var sortCompareFunction(get, set):Dynamic->Dynamic->Int;
	private var _sortCompareFunction:Dynamic->Dynamic->Int;
	private function get_sortCompareFunction():Dynamic->Dynamic->Int { return this._sortCompareFunction; }
	private function set_sortCompareFunction(value:Dynamic->Dynamic->Int):Dynamic->Dynamic->Int
	{
		if (this._sortCompareFunction == value)
		{
			return value;
		}
		this._sortCompareFunction = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._sortCompareFunction;
	}
	
	/**
	 * Indicates if the column may be sorted by triggering the
	 * header renderer, and which direction it should be sorted
	 * by default (ascending or descending).
	 *
	 * <p>Setting this property will not start a sort. It only provides the
	 * initial order of the sort when triggered by the user.</p>
	 *
	 * <p>If the <code>sortableColumns</code> property of the
	 * <code>DataGrid</code> is <code>false</code>, it takes precendence
	 * over this property, and the column will not be sortable.</p>
	 *
	 * <p>The following example disables sorting:</p>
	 *
	 * <listing version="3.0">
	 * column.sortOrder = SortOrder.NONE;</listing>
	 *
	 * @default feathers.data.SortOrder.ASCENDING
	 *
	 * @see feathers.controls.DataGrid#sortableColumns
	 * @see #sortCompareFunction
	 * @see feathers.data.SortOrder#ASCENDING
	 * @see feathers.data.SortOrder#DESCENDING
	 * @see feathers.data.SortOrder#NONE
	 */
	public var sortOrder(get, set):String;
	private var _sortOrder:String = SortOrder.ASCENDING;
	private function get_sortOrder():String { return this._sortOrder; }
	private function set_sortOrder(value:String):String
	{
		if (this._sortOrder == value)
		{
			return value;
		}
		this._sortOrder = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._sortOrder;
	}
	
	/**
	 * Indicates if the column may be resized by dragging from its right edge.
	 *
	 * <p>If the <code>resizableColumns</code> property of the
	 * <code>DataGrid</code> is <code>false</code>, it takes precendence
	 * over this property, and the column will not be resizable.</p>
	 *
	 * <p>The following example disables resizing:</p>
	 *
	 * <listing version="3.0">
	 * column.resizable = false;</listing>
	 *
	 * @default true
	 *
	 * @see feathers.controls.DataGrid#resizableColumns
	 */
	public var resizable(get, set):Bool;
	private var _resizable:Bool = true;
	private function get_resizable():Bool { return this._resizable; }
	private function set_resizable(value:Bool):Bool
	{
		if (this._resizable == value)
		{
			return value;
		}
		this._resizable = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._resizable;
	}
	
}