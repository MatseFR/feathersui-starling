/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import feathers.starling.controls.GroupedList;
import feathers.starling.core.FeathersControl;
import feathers.starling.events.FeathersEventType;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.renderers.BaseDefaultItemRenderer;

/**
 * The default item renderer for a GroupedList control. Supports up to three
 * optional sub-views, including a label to display text, an icon to display
 * an image, and an "accessory" to display a UI control or another display
 * object (with shortcuts for including a second image or a second label).
 *
 * @see feathers.controls.GroupedList
 *
 * @productversion Feathers 1.0.0
 */
class DefaultGroupedListItemRenderer extends BaseDefaultItemRenderer implements IGroupedListItemRenderer
{
	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#ALTERNATE_STYLE_NAME_DRILL_DOWN
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_DRILL_DOWN:String = "feathers-drill-down-item-renderer";

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
	 * The default <code>IStyleProvider</code> for all <code>DefaultGroupedListItemRenderer</code>
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
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return DefaultGroupedListItemRenderer.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var groupIndex(get, set):Int;
	private var _groupIndex:Int = -1;
	private function get_groupIndex():Int { return this._groupIndex; }
	private function set_groupIndex(value:Int):Int
	{
		return this._groupIndex = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var itemIndex(get, set):Int;
	private var _itemIndex:Int = -1;
	private function get_itemIndex():Int { return this._itemIndex; }
	private function set_itemIndex(value:Int):Int
	{
		return this._itemIndex = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var layoutIndex(get, set):Int;
	private var _layoutIndex:Int = -1;
	private function get_layoutIndex():Int { return this._layoutIndex; }
	private function set_layoutIndex(value:Int):Int
	{
		return this._layoutIndex = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):GroupedList;
	private function get_owner():GroupedList { return cast this._owner; }
	private function set_owner(value:GroupedList):GroupedList
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
			var list:GroupedList = cast this._owner;
			this.isSelectableWithoutToggle = list.isSelectable;
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
	
}