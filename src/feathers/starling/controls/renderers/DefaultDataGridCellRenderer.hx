/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import feathers.starling.controls.DataGrid;
import feathers.starling.controls.DataGridColumn;
import feathers.starling.core.FeathersControl;
import feathers.starling.events.FeathersEventType;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.renderers.BaseDefaultItemRenderer;
import feathers.starling.utils.type.Property;

/**
 * The default cell renderer for the <code>DataGrid</code> component.
 * Supports up to three optional sub-views, including a label to display
 * text, an icon to display an image, and an "accessory" to display a UI
 * component or another display object (with shortcuts for including a
 * second image or a second label).
 *
 * @see feathers.controls.DataGrid
 *
 * @productversion Feathers 3.4.0
 */
class DefaultDataGridCellRenderer extends BaseDefaultItemRenderer implements IDataGridCellRenderer
{
	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#ALTERNATE_STYLE_NAME_CHECK
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_CHECK:String = "feathers-check-item-renderer";

	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#DEFAULT_CHILD_STYLE_NAME_LABEL
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-item-renderer-label";

	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#DEFAULT_CHILD_STYLE_NAME_ICON_LABEL
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ICON_LABEL:String = "feathers-item-renderer-icon-label";

	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL:String = "feathers-item-renderer-accessory-label";

	/**
	 * The default <code>IStyleProvider</code> for all <code>DefaultListItemRenderer</code>
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
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return DefaultDataGridCellRenderer.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var rowIndex(get, set):Int;
	private var _rowIndex:Int = -1;
	private function get_rowIndex():Int { return this._rowIndex; }
	private function set_rowIndex(value:Int):Int
	{
		if (this._rowIndex == value)
		{
			return value;
		}
		this._rowIndex = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._rowIndex;
	}
	
	/**
	 * @inheritDoc
	 */
	public var columnIndex(get, set):Int;
	private var _columnIndex:Int = -1;
	private function get_columnIndex():Int { return this._columnIndex; }
	private function set_columnIndex(value:Int):Int
	{
		if (this._columnIndex == value)
		{
			return value;
		}
		this._columnIndex = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._columnIndex;
	}
	
	/**
	 * @inheritDoc
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataField;
	}
	
	/**
	 * @inheritDoc
	 */
	public var column(get, set):DataGridColumn;
	private var _column:DataGridColumn;
	private function get_column():DataGridColumn { return this._column; }
	private function set_column(value:DataGridColumn):DataGridColumn
	{
		if (this._column == value)
		{
			return value;
		}
		this._column = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._column;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):DataGrid;
	private function get_owner():DataGrid { return this._owner != null ? cast this._owner : null; }
	private function set_owner(value:DataGrid):DataGrid
	{
		if (this._owner == value)
		{
			return value;
		}
		if (this._owner != null)
		{
			this._owner.removeEventListener(FeathersEventType.SCROLL_START, owner_scrollStartHandler);
			this._owner.removeEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
		}
		this._owner = value;
		if (this._owner != null)
		{
			var grid:DataGrid = cast this._owner;
			this.isSelectableWithoutToggle = grid.isSelectable;
			if (grid.allowMultipleSelection)
			{
				//toggling is forced in this case
				this.isToggle = true;
			}
			this._owner.addEventListener(FeathersEventType.SCROLL_START, owner_scrollStartHandler);
			this._owner.addEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return value;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void 
	{
		this.owner = null;
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void 
	{
		super.initialize();
		//every cell in a row should be affected by touches anywhere
		//in the row, so use the parent as the target
		this.touchToState.target = this.parent;
	}
	
	override function getDataToRender():Dynamic 
	{
		if (this._data == null || this._dataField == null)
		{
			return this._data;
		}
		return Property.read(this._data, this._dataField);
	}
	
}