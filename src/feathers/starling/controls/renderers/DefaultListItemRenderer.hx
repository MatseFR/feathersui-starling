/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.renderers;
import feathers.starling.controls.List;
import feathers.starling.core.FeathersControl;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IValidating;
import feathers.starling.events.FeathersEventType;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.renderers.BaseDefaultItemRenderer;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * The default item renderer for List control. Supports up to three optional
 * sub-views, including a label to display text, an icon to display an
 * image, and an "accessory" to display a UI control or another display
 * object (with shortcuts for including a second image or a second label).
 *
 * @see feathers.controls.List
 *
 * @productversion Feathers 1.0.0
 */
class DefaultListItemRenderer extends BaseDefaultItemRenderer implements IListItemRenderer implements IDragAndDropItemRenderer
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
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return DefaultListItemRenderer.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var index(get, set):Int;
	private var _index:Int = -1;
	private function get_index():Int { return this._index; }
	private function set_index(value:Int):Int
	{
		return this._index = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):List;
	private function get_owner():List { return cast this._owner; }
	private function set_owner(value:List):List
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
			var list:List = cast this._owner;
			this.isSelectableWithoutToggle = list.isSelectable;
			if (list.allowMultipleSelection)
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
	public var dragEnabled(get, set):Bool;
	private var _dragEnabled:Bool = false;
	private function get_dragEnabled():Bool { return this._dragEnabled; }
	private function set_dragEnabled(value:Bool):Bool
	{
		if (this._dragEnabled == value)
		{
			return value;
		}
		this._dragEnabled = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dragEnabled;
	}
	
	/**
	 * @private
	 */
	public var dragIcon(get, set):DisplayObject;
	private var _dragIcon:DisplayObject;
	private function get_dragIcon():DisplayObject { return this._dragIcon; }
	private function set_dragIcon(value:DisplayObject):DisplayObject
	{
		if (this._dragIcon == value)
		{
			return value;
		}
		if (this._dragIcon != null)
		{
			if (Std.isOfType(this._dragIcon, IFeathersControl))
			{
				this._dragIcon.removeEventListener(FeathersEventType.RESIZE, dragIcon_resizeHandler);
			}
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			if (this._dragIcon.parent == this)
			{
				this._dragIcon.removeFromParent(false);
			}
			this._dragIcon = null;
		}
		this._dragIcon = value;
		if (this._dragIcon != null)
		{
			this.addChild(this._dragIcon);
			if (Std.isOfType(this._dragIcon, IFeathersControl))
			{
				this._dragIcon.addEventListener(FeathersEventType.RESIZE, dragIcon_resizeHandler);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._dragIcon;
	}
	
	/**
	 * @private
	 */
	public var dragGap(get, set):Float;
	private var _dragGap:Float;
	private function get_dragGap():Float { return this._dragGap; }
	private function set_dragGap(value:Float):Float
	{
		if (this._dragGap == value)
		{
			return value;
		}
		this._dragGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._dragGap;
	}
	
	/**
	 * @private
	 */
	private var _ignoreDragIconResizes:Bool = false;
	
	/**
	 * @private
	 */
	public var dragProxy(get, never):DisplayObject;
	private function get_dragProxy():DisplayObject { return this._dragIcon; }
	
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
	override function refreshOffsets():Void
	{
		super.refreshOffsets();
		var dragGap:Float = this._gap;
		if (this._dragGap == this._dragGap) //!isNaN
		{
			dragGap = this._dragGap;
		}
		if (this._dragEnabled && this._dragIcon != null)
		{
			var oldIgnoreIconResizes:Bool = this._ignoreDragIconResizes;
			this._ignoreDragIconResizes = true;
			if (Std.isOfType(this._dragIcon, IValidating))
			{
				cast(this._dragIcon, IValidating).validate();
			}
			this._ignoreDragIconResizes = oldIgnoreIconResizes;
			this._leftOffset += this._dragIcon.width + dragGap;
		}
	}
	
	/**
	 * @private
	 */
	override function layoutContent():Void
	{
		super.layoutContent();
		if (this._dragIcon != null)
		{
			if (this._dragEnabled)
			{
				var oldIgnoreIconResizes:Bool = this._ignoreDragIconResizes;
				this._ignoreDragIconResizes = true;
				if (Std.isOfType(this._dragIcon, IValidating))
				{
					cast(this._dragIcon, IValidating).validate();
				}
				this._ignoreDragIconResizes = oldIgnoreIconResizes;
				this._dragIcon.x = this._paddingLeft;
				this._dragIcon.y = this._paddingTop + ((this.actualHeight - this._paddingTop - this._paddingBottom) - this._dragIcon.height) / 2;
				this._dragIcon.visible = true;
			}
			else
			{
				this._dragIcon.visible = false;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function dragIcon_resizeHandler(event:Event):Void
	{
		if (this._ignoreDragIconResizes)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
}