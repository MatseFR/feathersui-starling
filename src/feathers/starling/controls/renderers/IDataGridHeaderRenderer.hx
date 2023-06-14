/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import feathers.starling.controls.DataGrid;
import feathers.starling.controls.DataGridColumn;
import feathers.starling.core.IFeathersControl;
import feathers.starling.layout.ILayoutDisplayObject;

/**
 * Interface to implement a renderer for a data grid header.
 *
 * @productversion Feathers 3.4.0
 */
interface IDataGridHeaderRenderer extends IFeathersControl extends ILayoutDisplayObject
{
	/**
	 * A column from a data grid. The data may change if this header
	 * renderer is reused for a new column because it's no longer needed
	 * for the original column.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 */
	public var data(get, set):DataGridColumn;
	
	/**
	 * The index of the header within the layout.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 */
	public var columnIndex(get, set):Int;
	
	/**
	 * The data grid that contains this header renderer.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 */
	public var owner(get, set):DataGrid;
	
	/**
	 * Indicates if this column is sorted.
	 *
	 * <p>This property is set by the data grid, and should not be set manually.</p>
	 *
	 * @see feathers.data.SortOrder
	 */
	public var sortOrder(get, set):String;
}