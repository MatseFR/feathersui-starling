/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.renderers;

import feathers.controls.DataGrid;
import feathers.controls.DataGridColumn;
import feathers.controls.LayoutGroup;
import feathers.core.FeathersControl;
import feathers.skins.IStyleProvider;
import flash.display.DisplayObject;
import starling.events.Event;

/**
 * Based on <code>LayoutGroup</code>, this component is meant as a base
 * class for creating a custom item renderer for a <code>DataGrid</code>
 * component.
 *
 * <p>Sub-components may be created and added inside <code>initialize()</code>.
 * This is a good place to add event listeners and to set the layout.</p>
 *
 * <p>The <code>data</code> property may be parsed inside <code>commitData()</code>.
 * Use this function to change properties in your sub-components.</p>
 *
 * <p>Sub-components may be positioned manually, but a layout may be
 * provided as well. An <code>AnchorLayout</code> is recommended for fluid
 * layouts that can automatically adjust positions when the grid resizes.
 * Create <code>AnchorLayoutData</code> objects to define the constraints.</p>
 *
 * @see feathers.controls.DataGrid
 *
 * @productversion Feathers 3.4.0
 */
class LayoutGroupDataGridCellRenderer extends LayoutGroup 
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>LayoutGroupDataGridCellRenderer</code>
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
		return LayoutGroupDataGridCellRenderer.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var rowIndex(get, set):Int;
	private var _rowIndex:Int = -1;
	private function get_rowIndex():Int { return this._rowIndex; }
	private function set_rowIndex(value:Int):Int
	{
		return this._rowIndex = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var columnIndex(get, set):Int;
	private var _columnIndex:Int = -1;
	private function get_columnIndex():Int { return this._columnIndex; }
	private function set_columnIndex(value:Int):Int
	{
		return this._columnIndex = value;
	}
	
	/**
	 * @inheritDoc
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
	 * @inheritDoc
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		//LayoutGroup doesn't know about INVALIDATION_FLAG_DATA, so we need
		//set set another flag that it understands.
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._data;
	}
	
	/**
	 * @inheritDoc
	 */
	public var dataField(get, set):String;
	private var _dataField:String = null;
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
		//the state flag is needed for updating the background
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		this.dispatchEventWith(Event.CHANGE);
		return this._isSelected;
	}
	
	/**
	 * @private
	 */
	public var backgroundSelectedSkin(get, set):DisplayObject;
	private var _backgroundSelectedSkin:DisplayObject;
	private function get_backgroundSelectedSkin():DisplayObject { return this._backgroundSelectedSkin; }
	private function set_backgroundSelectedSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("backgroundSelectedSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._backgroundSelectedSkin == value)
		{
			return value;
		}
		if (this._backgroundSelectedSkin != null &&
			this.currentBackgroundSkin == this._backgroundSelectedSkin)
		{
			this.removeCurrentBackgroundSkin(this._backgroundSelectedSkin);
			this.currentBackgroundSkin = null;
		}
		this._backgroundSelectedSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SKIN);
		return this._backgroundSelectedSkin;
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
	override function draw():Void
	{
		//children are allowed to change during draw() in a subclass up
		//until it calls super.draw().
		this._ignoreChildChangesButSetFlags = false;
		
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var scrollInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SCROLL);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		
		if (dataInvalid)
		{
			this.commitData();
		}
		
		if (scrollInvalid || sizeInvalid || layoutInvalid)
		{
			this._ignoreChildChanges = true;
			this.preLayout();
			this._ignoreChildChanges = false;
		}
		
		super.draw();
		
		if (scrollInvalid || sizeInvalid || layoutInvalid)
		{
			this._ignoreChildChanges = true;
			this.postLayout();
			this._ignoreChildChanges = false;
		}
	}
	
	/**
	 * Makes final changes to the layout before it updates the item
	 * renderer's children. If your layout requires changing the
	 * <code>layoutData</code> property on the item renderer's
	 * sub-components, override the <code>preLayout()</code> function to
	 * make those changes.
	 *
	 * <p>In subclasses, if you create properties that affect the layout,
	 * invalidate using <code>INVALIDATION_FLAG_LAYOUT</code> to trigger a
	 * call to the <code>preLayout()</code> function when the component
	 * validates.</p>
	 *
	 * <p>The final width and height of the item renderer are not yet known
	 * when this function is called. It is meant mainly for adjusting values
	 * used by fluid layouts, such as constraints or percentages. If you
	 * need io access the final width and height of the item renderer,
	 * override the <code>postLayout()</code> function instead.</p>
	 *
	 * @see #postLayout()
	 */
	private function preLayout():Void
	{
		
	}
	
	/**
	 * Updates the renderer to display the item's data. Override this
	 * function to pass data to sub-components and react to data changes.
	 *
	 * <p>Don't forget to handle the case where the data is <code>null</code>.</p>
	 */
	private function commitData():Void
	{
		
	}
	
	/**
	 * @private
	 */
	override function getCurrentBackgroundSkin():DisplayObject
	{
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			return this._backgroundDisabledSkin;
		}
		if (this._isSelected && this._backgroundSelectedSkin != null)
		{
			return this._backgroundSelectedSkin;
		}
		return this._backgroundSkin;
	}
	
}