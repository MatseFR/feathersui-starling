/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.renderers;

import feathers.controls.ItemRendererLayoutOrder;
import feathers.controls.ToggleButton;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IFocusContainer;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IStateObserver;
import feathers.core.ITextRenderer;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.core.PropertyProxyReal;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.text.FontStylesSet;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.touch.DelayedDownTouchToState;
import feathers.utils.type.ArgumentsCount;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextFormat;

/**
 * An abstract class for item renderer implementations.
 *
 * @productversion Feathers 1.0.0
 */
class BaseDefaultItemRenderer extends ToggleButton implements IFocusContainer
{
	/**
	 * An alternate style name to use with the default item renderer to
	 * allow a theme to give it a "drill-down" style. If a theme
	 * does not provide a style for a drill-down item renderer, the theme
	 * will automatically fall back to using the default item renderer
	 * style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the drill-down style is applied to
	 * a list's item renderers:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererFactory = function():IListItemRenderer
	 * {
	 *     var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
	 *     itemRenderer.styleNameList.add( DefaultListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN );
	 *     return itemRenderer;
	 * };</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_DRILL_DOWN:String = "feathers-drill-down-item-renderer";

	/**
	 * An alternate style name to use with the default item renderer to
	 * allow a theme to give it a "check" style. If a theme does not provide
	 * a style for a check item renderer, the theme will automatically fall
	 * back to using the default item renderer style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the check item renderer style is applied
	 * to a list's item renderers:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererFactory = function():IListItemRenderer
	 * {
	 *     var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
	 *     itemRenderer.styleNameList.add( DefaultListItemRenderer.ALTERNATE_STYLE_NAME_CHECK );
	 *     return itemRenderer;
	 * };</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_CHECK:String = "feathers-check-item-renderer";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * primary label.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-item-renderer-label";

	/**
	 * The default value added to the <code>styleNameList</code> of the icon
	 * label, if it exists.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ICON_LABEL:String = "feathers-item-renderer-icon-label";

	/**
	 * The default value added to the <code>styleNameList</code> of the icon
	 * loader, if it exists.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ICON_LOADER:String = "feathers-item-renderer-icon-loader";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * accessory label, if it exists.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL:String = "feathers-item-renderer-accessory-label";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * accessory loader, if it exists.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LOADER:String = "feathers-item-renderer-accessory-loader";

	/**
	 * @private
	 */
	private static var HELPER_POINT:Point = new Point();
	
	/**
	 * @private
	 */
	private static function defaultLoaderFactory():ImageLoader
	{
		return new ImageLoader();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		if (this._iconLabelFontStylesSet == null)
		{
			this._iconLabelFontStylesSet = new FontStylesSet();
			this._iconLabelFontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
		if (this._accessoryLabelFontStylesSet == null)
		{
			this._accessoryLabelFontStylesSet = new FontStylesSet();
			this._accessoryLabelFontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
		this._explicitIsEnabled = this._isEnabled;
		this.labelStyleName = DEFAULT_CHILD_STYLE_NAME_LABEL;
		this.isFocusEnabled = false;
		this.isQuickHitAreaEnabled = false;
		this.addEventListener(Event.REMOVED_FROM_STAGE, itemRenderer_removedFromStageHandler);
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the icon label
	 * text renderer, if it exists. This variable is <code>protected</code>
	 * so that sub-classes can customize the icon label text renderer style
	 * name in their constructors instead of using the default style name
	 * defined by <code>DEFAULT_CHILD_STYLE_NAME_ICON_LABEL</code>.
	 *
	 * <p>To customize the icon label text renderer style name without
	 * subclassing, see <code>customIconLabelStyleName</code>.</p>
	 *
	 * @see #style:customIconLabelStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var iconLabelStyleName:String = DEFAULT_CHILD_STYLE_NAME_ICON_LABEL;

	/**
	 * The value added to the <code>styleNameList</code> of the icon loader,
	 * if it exists. This variable is <code>protected</code>
	 * so that sub-classes can customize the icon loader style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ICON_LOADER</code>.
	 *
	 * <p>To customize the icon loader style name without subclassing, see
	 * <code>customIconLoaderStyleName</code>.</p>
	 *
	 * @see #style:customIconLoaderStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var iconLoaderStyleName:String = DEFAULT_CHILD_STYLE_NAME_ICON_LOADER;

	/**
	 * The value added to the <code>styleNameList</code> of the accessory
	 * label text renderer, if it exists. This variable is
	 * <code>protected</code> so that sub-classes can customize the
	 * accessory label text renderer style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL</code>.
	 *
	 * <p>To customize the accessory label text renderer style name without
	 * subclassing, see <code>customAccessoryLabelStyleName</code>.</p>
	 *
	 * @see #style:customAccessoryLabelStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var accessoryLabelStyleName:String = DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL;

	/**
	 * The value added to the <code>styleNameList</code> of the accessory
	 * loader, if it exists. This variable is <code>protected</code> so that
	 * sub-classes can customize the accessory loader style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LOADER</code>.
	 *
	 * <p>To customize the accessory loader style name without subclassing,
	 * see <code>customAccessoryLoaderStyleName</code>.</p>
	 *
	 * @see #style:customAccessoryLoaderStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var accessoryLoaderStyleName:String = DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LOADER;
	
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
	private var skinLoader:ImageLoader;

	/**
	 * @private
	 */
	private var iconLoader:ImageLoader;

	/**
	 * @private
	 */
	private var iconLabel:ITextRenderer;

	/**
	 * @private
	 */
	private var accessoryLoader:ImageLoader;

	/**
	 * @private
	 */
	private var accessoryLabel:ITextRenderer;

	/**
	 * @private
	 */
	private var currentAccessory:DisplayObject;

	/**
	 * @private
	 */
	private var _skinIsFromItem:Bool = false;

	/**
	 * @private
	 */
	private var _iconIsFromItem:Bool = false;

	/**
	 * @private
	 */
	private var _accessoryIsFromItem:Bool = false;
	
	/**
	 * @private
	 */
	override function set_defaultIcon(value:DisplayObject):DisplayObject 
	{
		if (this.processStyleRestriction("defaultIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._defaultIcon == value)
		{
			return value;
		}
		this.replaceIcon(null);
		this._iconIsFromItem = false;
		return super.defaultIcon = value;
	}
	
	/**
	 * @private
	 */
	override function set_defaultSkin(value:DisplayObject):DisplayObject 
	{
		if (this.processStyleRestriction("defaultSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._defaultSkin == value)
		{
			return value;
		}
		this.replaceSkin(null);
		this._skinIsFromItem = false;
		return super.defaultSkin = value;
	}
	
	/**
	 * The item displayed by this renderer. This property is set by the
	 * list, and should not be set manually.
	 */
	public var data(get, set):Dynamic;
	private var _data:Dynamic;
	private function get_data():Dynamic { return this._data; }
	private function set_data(value:Dynamic):Dynamic
	{
		//we need to use strict equality here because the data can be
		//non-strictly equal to null
		if (this._data == value)
		{
			return value;
		}
		this._data = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._data;
	}
	
	/**
	 * @private
	 */
	private var _owner:Scroller;
	
	/**
	 * @copy feathers.controls.renderers.IListItemRenderer#factoryID
	 */
	public var factoryID(get, set):String;
	private var _factoryID:String;
	private function get_factoryID():String { return this._factoryID; }
	private function set_factoryID(value:String):String
	{
		return this._factoryID = value;
	}
	
	/**
	 * @private
	 */
	public var useStateDelayTimer(get, set):Bool;
	private var _useStateDelayTimer:Bool = true;
	private function get_useStateDelayTimer():Bool { return this._useStateDelayTimer; }
	private function set_useStateDelayTimer(value:Bool):Bool
	{
		if (this.processStyleRestriction("useStateDelayTimer"))
		{
			return value;
		}
		return this._useStateDelayTimer = value;
	}
	
	/**
	 * Determines if the item renderer can be selected even if
	 * <code>isToggle</code> is set to <code>false</code>. Subclasses are
	 * expected to change this value, if required.
	 */
	private var isSelectableWithoutToggle:Bool = true;
	
	/**
	 * If true, the label will come from the renderer's item using the
	 * appropriate field or function for the label. If false, the label may
	 * be set externally.
	 *
	 * <p>In the following example, the item doesn't have a label:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasLabel = false;</listing>
	 *
	 * @default true
	 *
	 * @see #labelField
	 * @see #labelFunction
	 * @see #label
	 */
	public var itemHasLabel(get, set):Bool;
	private var _itemHasLabel:Bool = true;
	private function get_itemHasLabel():Bool { return this._itemHasLabel; }
	private function set_itemHasLabel(value:Bool):Bool
	{
		if (this._itemHasLabel == value)
		{
			return value;
		}
		this._itemHasLabel = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._itemHasLabel;
	}
	
	/**
	 * If true, the icon will come from the renderer's item using the
	 * appropriate field or function for the icon. If false, the icon may
	 * be skinned for each state externally.
	 *
	 * <p>In the following example, the item doesn't have an icon:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasIcon = false;</listing>
	 *
	 * @default true
	 */
	public var itemHasIcon(get, set):Bool;
	private var _itemHasIcon:Bool = true;
	private function get_itemHasIcon():Bool { return this._itemHasIcon; }
	private function set_itemHasIcon(value:Bool):Bool
	{
		if (this._itemHasIcon == value)
		{
			return value;
		}
		this._itemHasIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._itemHasIcon;
	}
	
	/**
	 * If true, the accessory will come from the renderer's item using the
	 * appropriate field or function for the accessory. If false, the
	 * accessory may be set using other means.
	 *
	 * <p>In the following example, the item doesn't have an accessory:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasAccessory = false;</listing>
	 *
	 * @default true
	 */
	public var itemHasAccessory(get, set):Bool;
	private var _itemHasAccessory:Bool = true;
	private function get_itemHasAccessory():Bool { return this._itemHasAccessory; }
	private function set_itemHasAccessory(value:Bool):Bool
	{
		if (this._itemHasAccessory == value)
		{
			return value;
		}
		this._itemHasAccessory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._itemHasAccessory;
	}
	
	/**
	 * If true, the skin will come from the renderer's item using the
	 * appropriate field or function for the skin. If false, the skin may
	 * be set for each state externally.
	 *
	 * <p>In the following example, the item has a skin:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSkin = true;
	 * renderer.skinField = "background";</listing>
	 *
	 * @default false
	 */
	public var itemHasSkin(get, set):Bool;
	private var _itemHasSkin:Bool = false;
	private function get_itemHasSkin():Bool { return this._itemHasSkin; }
	private function set_itemHasSkin(value:Bool):Bool
	{
		if (this._itemHasSkin == value)
		{
			return value;
		}
		this._itemHasSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._itemHasSkin;
	}
	
	/**
	 * If true, the ability to select the renderer will come from the
	 * renderer's item using the appropriate field or function for
	 * selectable. If false, the renderer will be selectable if its owner
	 * is selectable.
	 *
	 * <p>In the following example, the item doesn't have an accessory:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSelectable = true;</listing>
	 *
	 * @default false
	 *
	 * @see #selectableField
	 * @see #selectableFunction
	 */
	public var itemHasSelectable(get, set):Bool;
	private var _itemHasSelectable:Bool = false;
	private function get_itemHasSelectable():Bool { return this._itemHasSelectable; }
	private function set_itemHasSelectable(value:Bool):Bool
	{
		if (this._itemHasSelectable == value)
		{
			return value;
		}
		this._itemHasSelectable = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._itemHasSelectable;
	}
	
	/**
	 * If true, the renderer's enabled state will come from the renderer's
	 * item using the appropriate field or function for enabled. If false,
	 * the renderer will be enabled if its owner is enabled.
	 *
	 * <p>In the following example, the item doesn't have an accessory:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasEnabled = true;</listing>
	 *
	 * @default false
	 *
	 * @see #enabledField
	 * @see #enabledFunction
	 */
	public var itemHasEnabled(get, set):Bool;
	private var _itemHasEnabled:Bool = false;
	private function get_itemHasEnabled():Bool { return this._itemHasEnabled; }
	private function set_itemHasEnabled(value:Bool):Bool
	{
		if (this._itemHasEnabled == value)
		{
			return value;
		}
		this._itemHasEnabled = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._itemHasEnabled;
	}
	
	/**
	 * @private
	 */
	public var accessoryPosition(get, set):String;
	private var _accessoryPosition:String = RelativePosition.RIGHT;
	private function get_accessoryPosition():String { return this._accessoryPosition; }
	private function set_accessoryPosition(value:String):String
	{
		if (this.processStyleRestriction("accessoryPosition"))
		{
			return value;
		}
		if (this._accessoryPosition == value)
		{
			return value;
		}
		this._accessoryPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._accessoryPosition;
	}
	
	/**
	 * @private
	 */
	public var layoutOrder(get, set):String;
	private var _layoutOrder:String = ItemRendererLayoutOrder.LABEL_ICON_ACCESSORY;
	private function get_layoutOrder():String { return this._layoutOrder; }
	private function set_layoutOrder(value:String):String
	{
		if (this.processStyleRestriction("layoutOrder"))
		{
			return value;
		}
		if (this._layoutOrder == value)
		{
			return value;
		}
		this._layoutOrder = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._layoutOrder;
	}
	
	/**
	 * @private
	 */
	public var accessoryOffsetX(get, set):Float;
	private var _accessoryOffsetX:Float = 0;
	private function get_accessoryOffsetX():Float { return this._accessoryOffsetX; }
	private function set_accessoryOffsetX(value:Float):Float
	{
		if (this.processStyleRestriction("accessoryOffsetX"))
		{
			return value;
		}
		if (this._accessoryOffsetX == value)
		{
			return value;
		}
		this._accessoryOffsetX = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._accessoryOffsetX;
	}
	
	/**
	 * @private
	 */
	public var accessoryOffsetY(get, set):Float;
	private var _accessoryOffsetY:Float = 0;
	private function get_accessoryOffsetY():Float { return this._accessoryOffsetY; }
	private function set_accessoryOffsetY(value:Float):Float
	{
		if (this.processStyleRestriction("accessoryOffsetY"))
		{
			return value;
		}
		if (this._accessoryOffsetY == value)
		{
			return value;
		}
		this._accessoryOffsetY = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._accessoryOffsetY;
	}
	
	/**
	 * @private
	 */
	public var accessoryGap(get, set):Float;
	private var _accessoryGap:Float;
	private function get_accessoryGap():Float { return this._accessoryGap; }
	private function set_accessoryGap(value:Float):Float
	{
		if (this.processStyleRestriction("accessoryGap"))
		{
			return value;
		}
		if (this._accessoryGap == value)
		{
			return value;
		}
		this._accessoryGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._accessoryGap;
	}
	
	/**
	 * @private
	 */
	public var minAccessoryGap(get, set):Float;
	private var _minAccessoryGap:Float;
	private function get_minAccessoryGap():Float { return this._minAccessoryGap; }
	private function set_minAccessoryGap(value:Float):Float
	{
		if (this.processStyleRestriction("minAccessoryGap"))
		{
			return value;
		}
		if (this._minAccessoryGap == value)
		{
			return value;
		}
		this._minAccessoryGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._minAccessoryGap;
	}
	
	/**
	 * The accessory used when no other accessory is defined for the current
	 * state. Intended to be used when multiple states should share the same
	 * accessory.
	 *
	 * <p>This property will be ignored if a function is passed to the
	 * <code>stateToAccessoryFunction</code> property. This property may be
	 * ignored if the <code>itemHasAccessory</code> property is
	 * <code>true</code>.</p>
	 *
	 * <p>The following example gives the item renderer a default accessory
	 * to use for all states when no specific accessory is available:</p>
	 *
	 * <listing version="3.0">
	 * itemRenderer.defaultAccessory = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #setAccessoryForState()
	 * @see #itemHasAccessory
	 */
	public var defaultAccessory(get, set):DisplayObject;
	private var _defaultAccessory:DisplayObject;
	private function get_defaultAccessory():DisplayObject { return this._defaultAccessory; }
	private function set_defaultAccessory(value:DisplayObject):DisplayObject
	{
		if (this._defaultAccessory == value)
		{
			return value;
		}
		this.replaceAccessory(null);
		this._accessoryIsFromItem = false;
		this._defaultAccessory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._defaultAccessory;
	}
	
	/**
	 * @private
	 */
	private var _stateToAccessory:Map<String, DisplayObject> = new Map<String, DisplayObject>();

	/**
	 * @private
	 */
	private var accessoryTouchPointID:Int = -1;
	
	/**
	 * If enabled, calls owner.stopScrolling() when TouchEvents are
	 * dispatched by the accessory.
	 *
	 * <p>In the following example, the list won't stop scrolling when the
	 * accessory is touched:</p>
	 *
	 * <listing version="3.0">
	 * renderer.stopScrollingOnAccessoryTouch = false;</listing>
	 *
	 * @default true
	 */
	public var stopScrollingOnAccessoryTouch(get, set):Bool;
	private var _stopScrollingOnAccessoryTouch:Bool = true;
	private function get_stopScrollingOnAccessoryTouch():Bool { return this._stopScrollingOnAccessoryTouch; }
	private function set_stopScrollingOnAccessoryTouch(value:Bool):Bool
	{
		return this._stopScrollingOnAccessoryTouch = value;
	}
	
	/**
	 * If enabled, the item renderer may be selected by touching the
	 * accessory. By default, the accessory will not trigger selection when
	 * using <code>defaultAccessory</code>, <code>accessoryField</code>, or
	 * <code>accessoryFunction</code> and the accessory is a Feathers
	 * component.
	 *
	 * <p>In the following example, the item renderer can be selected when
	 * the accessory is touched:</p>
	 *
	 * <listing version="3.0">
	 * renderer.isSelectableOnAccessoryTouch = true;</listing>
	 *
	 * @default false
	 */
	public var isSelectableOnAccessoryTouch(get, set):Bool;
	private var _isSelectableOnAccessoryTouch:Bool = false;
	private function get_isSelectableOnAccessoryTouch():Bool { return this._isSelectableOnAccessoryTouch; }
	private function set_isSelectableOnAccessoryTouch(value:Bool):Bool
	{
		return this._isSelectableOnAccessoryTouch = value;
	}
	
	/**
	 * If enabled, automatically manages the <code>delayTextureCreation</code>
	 * property on accessory and icon <code>ImageLoader</code> instances
	 * when the owner scrolls. This applies to the loaders created when the
	 * following properties are set: <code>accessorySourceField</code>,
	 * <code>accessorySourceFunction</code>, <code>iconSourceField</code>,
	 * and <code>iconSourceFunction</code>.
	 *
	 * <p>In the following example, any loaded textures won't be uploaded to
	 * the GPU until the owner stops scrolling:</p>
	 *
	 * <listing version="3.0">
	 * renderer.delayTextureCreationOnScroll = true;</listing>
	 *
	 * @default false
	 */
	public var delayTextureCreationOnScroll(get, set):Bool;
	private var _delayTextureCreationOnScroll:Bool = false;
	private function get_delayTextureCreationOnScroll():Bool { return this._delayTextureCreationOnScroll; }
	private function set_delayTextureCreationOnScroll(value:Bool):Bool
	{
		return this._delayTextureCreationOnScroll = value;
	}
	
	/**
	 * The field in the item that contains the label text to be displayed by
	 * the renderer. If the item does not have this field, and a
	 * <code>labelFunction</code> is not defined, then the renderer will
	 * default to calling <code>toString()</code> on the item. To omit the
	 * label completely, either provide a custom item renderer without a
	 * label or define a <code>labelFunction</code> that returns an empty
	 * string.
	 *
	 * <p>All of the label fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>labelFunction</code></li>
	 *     <li><code>labelField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the label field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.labelField = "text";</listing>
	 *
	 * @default "label"
	 *
	 * @see #labelFunction
	 */
	public var labelField(get, set):String;
	private var _labelField:String = "label";
	private function get_labelField():String { return this._labelField; }
	private function set_labelField(value:String):String
	{
		if (this._labelField == value)
		{
			return value;
		}
		this._labelField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._labelField;
	}
	
	/**
	 * A function used to generate label text for a specific item. If this
	 * function is not null, then the <code>labelField</code> will be
	 * ignored.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):String</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):String</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):String</pre>
	 *
	 * <p>All of the label fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>labelFunction</code></li>
	 *     <li><code>labelField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the label function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.labelFunction = function( item:Object ):String
	 * {
	 *    return item.firstName + " " + item.lastName;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #labelField
	 */
	public var labelFunction(get, set):Function;
	private var _labelFunction:Function;
	private function get_labelFunction():Function { return this._labelFunction; }
	private function set_labelFunction(value:Function):Function
	{
		if (this._labelFunction == value)
		{
			return value;
		}
		this._labelFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._labelFunction;
	}
	
	/**
	 * The field in the item that contains a display object to be displayed
	 * as an icon or other graphic next to the label in the renderer.
	 *
	 * <p>Warning: It is your responsibility to dispose all icons
	 * included in the data provider and accessed with <code>iconField</code>,
	 * or any display objects returned by <code>iconFunction</code>.
	 * These display objects will not be disposed when the list is disposed.
	 * Not disposing an icon may result in a memory leak.</p>
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconSourceFunction</code></li>
	 *     <li><code>iconSourceField</code></li>
	 *     <li><code>iconLabelFunction</code></li>
	 *     <li><code>iconLabelField</code></li>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconField = "photo";</listing>
	 *
	 * @default "icon"
	 *
	 * @see #itemHasIcon
	 * @see #iconFunction
	 * @see #iconSourceField
	 * @see #iconSourceFunction
	 */
	public var iconField(get, set):String;
	private var _iconField:String = "icon";
	private function get_iconField():String { return this._iconField; }
	private function set_iconField(value:String):String
	{
		if (this._iconField == value)
		{
			return value;
		}
		this._iconField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconField;
	}
	
	/**
	 * A function used to generate an icon for a specific item.
	 *
	 * <p>Note: As the list scrolls, this function will almost always be
	 * called more than once for each individual item in the list's data
	 * provider. Your function should not simply return a new icon every
	 * time. This will result in the unnecessary creation and destruction of
	 * many icons, which will overwork the garbage collector and hurt
	 * performance. It's better to return a new icon the first time this
	 * function is called for a particular item and then return the same
	 * icon if that item is passed to this function again.</p>
	 *
	 * <p>Warning: It is your responsibility to dispose all icons
	 * included in the data provider and accessed with <code>iconField</code>,
	 * or any display objects returned by <code>iconFunction</code>.
	 * These display objects will not be disposed when the list is disposed.
	 * Not disposing an icon may result in a memory leak.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):DisplayObject</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):DisplayObject</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):DisplayObject</pre>
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconSourceFunction</code></li>
	 *     <li><code>iconSourceField</code></li>
	 *     <li><code>iconLabelFunction</code></li>
	 *     <li><code>iconLabelField</code></li>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconFunction = function( item:Object ):DisplayObject
	 * {
	 *    if(item in cachedIcons)
	 *    {
	 *        return cachedIcons[item];
	 *    }
	 *    var icon:Image = new Image( textureAtlas.getTexture( item.textureName ) );
	 *    cachedIcons[item] = icon;
	 *    return icon;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #itemHasIcon
	 * @see #iconField
	 * @see #iconSourceField
	 * @see #iconSourceFunction
	 */
	public var iconFunction(get, set):Function;
	private var _iconFunction:Function;
	private function get_iconFunction():Function { return this._iconFunction; }
	private function set_iconFunction(value:Function):Function
	{
		if (this._iconFunction == value)
		{
			return value;
		}
		this._iconFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconFunction;
	}
	
	/**
	 * The field in the item that contains a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the item renderer's
	 * icon. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>iconLoaderFactory</code>.
	 *
	 * <p>Using an icon source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * a <code>iconField</code> or <code>iconFunction</code>
	 * because the renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconSourceFunction</code></li>
	 *     <li><code>iconSourceField</code></li>
	 *     <li><code>iconLabelFunction</code></li>
	 *     <li><code>iconLabelField</code></li>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon source field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconSourceField = "texture";</listing>
	 *
	 * @default "iconSource"
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #itemHasIcon
	 * @see #iconLoaderFactory
	 * @see #iconSourceFunction
	 * @see #iconField
	 * @see #iconFunction
	 */
	public var iconSourceField(get, set):String;
	private var _iconSourceField:String = "iconSource";
	private function get_iconSourceField():String { return this._iconSourceField; }
	private function set_iconSourceField(value:String):String
	{
		if (this._iconSourceField == value)
		{
			return value;
		}
		this._iconSourceField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconSourceField;
	}
	
	/**
	 * A function used to generate a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the item renderer's
	 * icon. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>iconLoaderFactory</code>.
	 *
	 * <p>Using an icon source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * a <code>iconField</code> or <code>iconFunction</code>
	 * because the renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>Note: As the list scrolls, this function will almost always be
	 * called more than once for each individual item in the list's data
	 * provider. Your function should not simply return a new texture every
	 * time. This will result in the unnecessary creation and destruction of
	 * many textures, which will overwork the garbage collector and hurt
	 * performance. Creating a new texture at all is dangerous, unless you
	 * are absolutely sure to dispose it when necessary because neither the
	 * list nor its item renderer will dispose of the texture for you. If
	 * you are absolutely sure that you are managing the texture memory with
	 * proper disposal, it's better to return a new texture the first
	 * time this function is called for a particular item and then return
	 * the same texture if that item is passed to this function again.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Object</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):Object</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):Object</pre>
	 *
	 * <p>The return value is a valid value for the <code>source</code>
	 * property of an <code>ImageLoader</code> component.</p>
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconSourceFunction</code></li>
	 *     <li><code>iconSourceField</code></li>
	 *     <li><code>iconLabelFunction</code></li>
	 *     <li><code>iconLabelField</code></li>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon source function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconSourceFunction = function( item:Object ):Object
	 * {
	 *    return "http://www.example.com/thumbs/" + item.name + "-thumb.png";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #itemHasIcon
	 * @see #iconLoaderFactory
	 * @see #iconSourceField
	 * @see #iconField
	 * @see #iconFunction
	 */
	public var iconSourceFunction(get, set):Function;
	private var _iconSourceFunction:Function;
	private function get_iconSourceFunction():Function { return this._iconSourceFunction; }
	private function set_iconSourceFunction(value:Function):Function
	{
		if (this._iconSourceFunction == value)
		{
			return value;
		}
		this._iconSourceFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconSourceFunction;
	}
	
	/**
	 * The field in the item that contains a string to be displayed in a
	 * renderer-managed <code>ITextRenderer</code> in the icon position of
	 * the renderer. The renderer will automatically reuse an internal
	 * <code>ITextRenderer</code> and swap the text when the data changes.
	 * This <code>ITextRenderer</code> may be skinned by changing the
	 * <code>iconLabelFactory</code>.
	 *
	 * <p>Using an icon label will result in better performance than
	 * passing in an <code>ITextRenderer</code> through a <code>iconField</code>
	 * or <code>iconFunction</code> because the renderer can avoid
	 * costly display list manipulation.</p>
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconSourceFunction</code></li>
	 *     <li><code>iconSourceField</code></li>
	 *     <li><code>iconLabelFunction</code></li>
	 *     <li><code>iconLabelField</code></li>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon label field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconLabelField = "text";</listing>
	 *
	 * @default "iconLabel"
	 *
	 * @see #itemHasIcon
	 * @see #iconLabelFactory
	 * @see #iconLabelFunction
	 * @see #iconField
	 * @see #iconFunction
	 * @see #iconySourceField
	 * @see #iconSourceFunction
	 */
	public var iconLabelField(get, set):String;
	private var _iconLabelField:String = "iconLabel";
	private function get_iconLabelField():String { return this._iconLabelField; }
	private function set_iconLabelField(value:String):String
	{
		if (this._iconLabelField == value)
		{
			return value;
		}
		this._iconLabelField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconLabelField;
	}
	
	/**
	 * A function that returns a string to be displayed in a
	 * renderer-managed <code>ITextRenderer</code> in the icon position of
	 * the renderer. The renderer will automatically reuse an internal
	 * <code>ITextRenderer</code> and swap the text when the data changes.
	 * This <code>ITextRenderer</code> may be skinned by changing the
	 * <code>iconLabelFactory</code>.
	 *
	 * <p>Using an icon label will result in better performance than
	 * passing in an <code>ITextRenderer</code> through a <code>iconField</code>
	 * or <code>iconFunction</code> because the renderer can avoid costly
	 * display list manipulation.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):String</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):String</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):String</pre>
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconSourceFunction</code></li>
	 *     <li><code>iconSourceField</code></li>
	 *     <li><code>iconLabelFunction</code></li>
	 *     <li><code>iconLabelField</code></li>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon label function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconLabelFunction = function( item:Object ):String
	 * {
	 *    return item.firstName + " " + item.lastName;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #itemHasIcon
	 * @see #iconLabelFactory
	 * @see #iconLabelField
	 * @see #iconField
	 * @see #iconFunction
	 * @see #iconSourceField
	 * @see #iconSourceFunction
	 */
	public var iconLabelFunction(get, set):Function;
	private var _iconLabelFunction:Function;
	private function get_iconLabelFunction():Function { return this._iconLabelFunction; }
	private function set_iconLabelFunction(value:Function):Function
	{
		if (this._iconLabelFunction == value)
		{
			return value;
		}
		this._iconLabelFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconLabelFunction;
	}
	
	/**
	 * @private
	 */
	public var customIconLoaderStyleName(get, set):String;
	private var _customIconLoaderStyleName:String;
	private function get_customIconLoaderStyleName():String { return this._customIconLoaderStyleName; }
	private function set_customIconLoaderStyleName(value:String):String
	{
		if (this.processStyleRestriction("customIconLoaderStyleName"))
		{
			return value;
		}
		if (this._customIconLoaderStyleName == value)
		{
			return value;
		}
		this._customIconLoaderStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._customIconLoaderStyleName;
	}
	
	/**
	 * @private
	 */
	public var customIconLabelStyleName(get, set):String;
	private var _customIconLabelStyleName:String;
	private function get_customIconLabelStyleName():String { return this._customIconLabelStyleName; }
	private function set_customIconLabelStyleName(value:String):String
	{
		if (this.processStyleRestriction("customIconLabelStyleName"))
		{
			return value;
		}
		if (this._customIconLabelStyleName == value)
		{
			return value;
		}
		this._customIconLabelStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customIconLabelStyleName;
	}
	
	/**
	 * The field in the item that contains a display object to be positioned
	 * in the accessory position of the renderer. If you wish to display an
	 * <code>Image</code> in the accessory position, it's better for
	 * performance to use <code>accessorySourceField</code> instead.
	 *
	 * <p>Warning: It is your responsibility to dispose all accessories
	 * included in the data provider and accessed with <code>accessoryField</code>,
	 * or any display objects returned by <code>accessoryFunction</code>.
	 * These display objects will not be disposed when the list is disposed.
	 * Not disposing an accessory may result in a memory leak.</p>
	 *
	 * <p>All of the accessory fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>accessorySourceFunction</code></li>
	 *     <li><code>accessorySourceField</code></li>
	 *     <li><code>accessoryLabelFunction</code></li>
	 *     <li><code>accessoryLabelField</code></li>
	 *     <li><code>accessoryFunction</code></li>
	 *     <li><code>accessoryField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the accessory field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessoryField = "component";</listing>
	 *
	 * @default "accessory"
	 *
	 * @see #itemHasAccessory
	 * @see #accessorySourceField
	 * @see #accessoryFunction
	 * @see #accessorySourceFunction
	 * @see #accessoryLabelField
	 * @see #accessoryLabelFunction
	 */
	public var accessoryField(get, set):String;
	private var _accessoryField:String = "accessory";
	private function get_accessoryField():String { return this._accessoryField; }
	private function set_accessoryField(value:String):String
	{
		if (this._accessoryField == value)
		{
			return value;
		}
		this._accessoryField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessoryField;
	}
	
	/**
	 * A function that returns a display object to be positioned in the
	 * accessory position of the renderer. If you wish to display an
	 * <code>Image</code> in the accessory position, it's better for
	 * performance to use <code>accessorySourceFunction</code> instead.
	 *
	 * <p>Note: As the list scrolls, this function will almost always be
	 * called more than once for each individual item in the list's data
	 * provider. Your function should not simply return a new accessory
	 * every time. This will result in the unnecessary creation and
	 * destruction of many icons, which will overwork the garbage collector
	 * and hurt performance. It's better to return a new accessory the first
	 * time this function is called for a particular item and then return
	 * the same accessory if that item is passed to this function again.</p>
	 *
	 * <p>Warning: It is your responsibility to dispose all accessories
	 * included in the data provider and accessed with <code>accessoryField</code>,
	 * or any display objects returned by <code>accessoryFunction</code>.
	 * These display objects will not be disposed when the list is disposed.
	 * Not disposing an accessory may result in a memory leak.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):DisplayObject</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):DisplayObject</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):DisplayObject</pre>
	 *
	 * <p>All of the accessory fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>accessorySourceFunction</code></li>
	 *     <li><code>accessorySourceField</code></li>
	 *     <li><code>accessoryLabelFunction</code></li>
	 *     <li><code>accessoryLabelField</code></li>
	 *     <li><code>accessoryFunction</code></li>
	 *     <li><code>accessoryField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the accessory function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessoryFunction = function( item:Object ):DisplayObject
	 * {
	 *    if(item in cachedAccessories)
	 *    {
	 *        return cachedAccessories[item];
	 *    }
	 *    var accessory:DisplayObject = createAccessoryForItem( item );
	 *    cachedAccessories[item] = accessory;
	 *    return accessory;
	 * };</listing>
	 *
	 * @default null
	 **
	 * @see #itemHasAccessory
	 * @see #accessoryField
	 * @see #accessorySourceField
	 * @see #accessorySourceFunction
	 * @see #accessoryLabelField
	 * @see #accessoryLabelFunction
	 */
	public var accessoryFunction(get, set):Function;
	private var _accessoryFunction:Function;
	private function get_accessoryFunction():Function { return this._accessoryFunction; }
	private function set_accessoryFunction(value:Function):Function
	{
		if (this._accessoryFunction == value)
		{
			return value;
		}
		this._accessoryFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessoryFunction;
	}
	
	/**
	 * A field in the item that contains a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the item renderer's
	 * accessory. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>accessoryLoaderFactory</code>.
	 *
	 * <p>Using an accessory source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * a <code>accessoryField</code> or <code>accessoryFunction</code> because
	 * the renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>All of the accessory fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>accessorySourceFunction</code></li>
	 *     <li><code>accessorySourceField</code></li>
	 *     <li><code>accessoryLabelFunction</code></li>
	 *     <li><code>accessoryLabelField</code></li>
	 *     <li><code>accessoryFunction</code></li>
	 *     <li><code>accessoryField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the accessory source field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessorySourceField = "texture";</listing>
	 *
	 * @default "accessorySource"
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #itemHasAccessory
	 * @see #accessoryLoaderFactory
	 * @see #accessorySourceFunction
	 * @see #accessoryField
	 * @see #accessoryFunction
	 * @see #accessoryLabelField
	 * @see #accessoryLabelFunction
	 */
	public var accessorySourceField(get, set):String;
	private var _accessorySourceField:String = "accessorySource";
	private function get_accessorySourceField():String { return this._accessorySourceField; }
	private function set_accessorySourceField(value:String):String
	{
		if (this._accessorySourceField == value)
		{
			return value;
		}
		this._accessorySourceField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessorySourceField;
	}
	
	/**
	 * A function that generates a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the item renderer's
	 * accessory. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>accessoryLoaderFactory</code>.
	 *
	 * <p>Using an accessory source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * a <code>accessoryField</code> or <code>accessoryFunction</code>
	 * because the renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>Note: As the list scrolls, this function will almost always be
	 * called more than once for each individual item in the list's data
	 * provider. Your function should not simply return a new texture every
	 * time. This will result in the unnecessary creation and destruction of
	 * many textures, which will overwork the garbage collector and hurt
	 * performance. Creating a new texture at all is dangerous, unless you
	 * are absolutely sure to dispose it when necessary because neither the
	 * list nor its item renderer will dispose of the texture for you. If
	 * you are absolutely sure that you are managing the texture memory with
	 * proper disposal, it's better to return a new texture the first
	 * time this function is called for a particular item and then return
	 * the same texture if that item is passed to this function again.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Object</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):Object</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):Object</pre>
	 *
	 * <p>The return value is a valid value for the <code>source</code>
	 * property of an <code>ImageLoader</code> component.</p>
	 *
	 * <p>All of the accessory fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>accessorySourceFunction</code></li>
	 *     <li><code>accessorySourceField</code></li>
	 *     <li><code>accessoryLabelFunction</code></li>
	 *     <li><code>accessoryLabelField</code></li>
	 *     <li><code>accessoryFunction</code></li>
	 *     <li><code>accessoryField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the accessory source function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessorySourceFunction = function( item:Object ):Object
	 * {
	 *    return "http://www.example.com/thumbs/" + item.name + "-thumb.png";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #itemHasAccessory
	 * @see #accessoryLoaderFactory
	 * @see #accessorySourceField
	 * @see #accessoryField
	 * @see #accessoryFunction
	 * @see #accessoryLabelField
	 * @see #accessoryLabelFunction
	 */
	public var accessorySourceFunction(get, set):Function;
	private var _accessorySourceFunction:Function;
	private function get_accessorySourceFunction():Function { return this._accessorySourceFunction; }
	private function set_accessorySourceFunction(value:Function):Function
	{
		if (this._accessorySourceFunction == value)
		{
			return value;
		}
		this._accessorySourceFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessorySourceFunction;
	}
	
	/**
	 * The field in the item that contains a string to be displayed in a
	 * renderer-managed <code>ITextRenderer</code> in the accessory position
	 * of the renderer. The renderer will automatically reuse an internal
	 * <code>ITextRenderer</code> and swap the text when the data changes.
	 * This <code>ITextRenderer</code> may be skinned by changing the
	 * <code>accessoryLabelFactory</code>.
	 *
	 * <p>Using an accessory label will result in better performance than
	 * passing in a <code>ITextRenderer</code> through an <code>accessoryField</code>
	 * or <code>accessoryFunction</code> because the renderer can avoid
	 * costly display list manipulation.</p>
	 *
	 * <p>All of the accessory fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>accessorySourceFunction</code></li>
	 *     <li><code>accessorySourceField</code></li>
	 *     <li><code>accessoryLabelFunction</code></li>
	 *     <li><code>accessoryLabelField</code></li>
	 *     <li><code>accessoryFunction</code></li>
	 *     <li><code>accessoryField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the accessory label field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessoryLabelField = "text";</listing>
	 *
	 * @default "accessoryLabel"
	 **
	 * @see #itemHasAccessory
	 * @see #accessoryLabelFactory
	 * @see #accessoryLabelFunction
	 * @see #accessoryField
	 * @see #accessoryFunction
	 * @see #accessorySourceField
	 * @see #accessorySourceFunction
	 */
	public var accessoryLabelField(get, set):String;
	private var _accessoryLabelField:String;
	private function get_accessoryLabelField():String { return this._accessoryLabelField; }
	private function set_accessoryLabelField(value:String):String
	{
		if (this._accessoryLabelField == value)
		{
			return value;
		}
		this._accessoryLabelField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessoryLabelField;
	}
	
	/**
	 * A function that returns a string to be displayed in a
	 * renderer-managed <code>ITextRenderer</code> in the accessory position
	 * of the renderer. The renderer will automatically reuse an internal
	 * <code>ITextRenderer</code> and swap the text when the data changes.
	 * This <code>ITextRenderer</code> may be skinned by changing the
	 * <code>accessoryLabelFactory</code>.
	 *
	 * <p>Using an accessory label will result in better performance than
	 * passing in an <code>ITextRenderer</code> through an <code>accessoryField</code>
	 * or <code>accessoryFunction</code> because the renderer can avoid
	 * costly display list manipulation.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):String</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):String</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):String</pre>
	 *
	 * <p>All of the accessory fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>accessorySourceFunction</code></li>
	 *     <li><code>accessorySourceField</code></li>
	 *     <li><code>accessoryLabelFunction</code></li>
	 *     <li><code>accessoryLabelField</code></li>
	 *     <li><code>accessoryFunction</code></li>
	 *     <li><code>accessoryField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the accessory label function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessoryLabelFunction = function( item:Object ):String
	 * {
	 *    return item.firstName + " " + item.lastName;
	 * };</listing>
	 *
	 * @default null
	 **
	 * @see #itemHasAccessory
	 * @see #accessoryLabelFactory
	 * @see #accessoryLabelField
	 * @see #accessoryField
	 * @see #accessoryFunction
	 * @see #accessorySourceField
	 * @see #accessorySourceFunction
	 */
	public var accessoryLabelFunction(get, set):Function;
	private var _accessoryLabelFunction:Function;
	private function get_accessoryLabelFunction():Function { return this._accessoryLabelFunction; }
	private function set_accessoryLabelFunction(value:Function):Function
	{
		if (this._accessoryLabelFunction == value)
		{
			return value;
		}
		this._accessoryLabelFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessoryLabelFunction;
	}
	
	/**
	 * @private
	 */
	public var customAccessoryLabelStyleName(get, set):String;
	private var _customAccessoryLabelStyleName:String;
	private function get_customAccessoryLabelStyleName():String { return this._customAccessoryLabelStyleName; }
	private function set_customAccessoryLabelStyleName(value:String):String
	{
		if (this.processStyleRestriction("customAccessoryLabelStyleName"))
		{
			return value;
		}
		if (this._customAccessoryLabelStyleName == value)
		{
			return value;
		}
		this._customAccessoryLabelStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customAccessoryLabelStyleName;
	}
	
	/**
	 * @private
	 */
	public var customAccessoryLoaderStyleName(get, set):String;
	private var _customAccessoryLoaderStyleName:String;
	private function get_customAccessoryLoaderStyleName():String { return this._customAccessoryLoaderStyleName; }
	private function set_customAccessoryLoaderStyleName(value:String):String
	{
		if (this.processStyleRestriction("customAccessoryLoaderStyleName"))
		{
			return value;
		}
		if (this._customAccessoryLoaderStyleName == value)
		{
			return value;
		}
		this._customAccessoryLoaderStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._customAccessoryLoaderStyleName;
	}
	
	/**
	 * The field in the item that contains a display object to be displayed
	 * as a background skin.
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>skinSourceFunction</code></li>
	 *     <li><code>skinSourceField</code></li>
	 *     <li><code>skinFunction</code></li>
	 *     <li><code>skinField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the skin field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSkin = true;
	 * renderer.skinField = "background";</listing>
	 *
	 * @default "skin"
	 *
	 * @see #itemHasSkin
	 * @see #skinFunction
	 * @see #skinSourceField
	 * @see #skinSourceFunction
	 */
	public var skinField(get, set):String;
	private var _skinField:String = "skin";
	private function get_skinField():String { return this._skinField; }
	private function set_skinField(value:String):String
	{
		if (this._skinField == value)
		{
			return value;
		}
		this._skinField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._skinField;
	}
	
	/**
	 * A function used to generate a background skin for a specific item.
	 *
	 * <p>Note: As the list scrolls, this function will almost always be
	 * called more than once for each individual item in the list's data
	 * provider. Your function should not simply return a new display object
	 * every time. This will result in the unnecessary creation and
	 * destruction of many skins, which will overwork the garbage collector
	 * and hurt performance. It's better to return a new skin the first time
	 * this function is called for a particular item and then return the same
	 * skin if that item is passed to this function again.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):DisplayObject</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):DisplayObject</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):DisplayObject</pre>
	 *
	 * <p>All of the skin fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>skinSourceFunction</code></li>
	 *     <li><code>skinSourceField</code></li>
	 *     <li><code>skinFunction</code></li>
	 *     <li><code>skinField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the skin function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSkin = true;
	 * renderer.skinFunction = function( item:Object ):DisplayObject
	 * {
	 *    if(item in cachedSkin)
	 *    {
	 *        return cachedSkin[item];
	 *    }
	 *    var skin:Image = new Image( textureAtlas.getTexture( item.textureName ) );
	 *    cachedSkin[item] = skin;
	 *    return skin;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #itemHasSkin
	 * @see #skinField
	 * @see #skinSourceField
	 * @see #skinSourceFunction
	 */
	public var skinFunction(get, set):Function;
	private var _skinFunction:Function;
	private function get_skinFunction():Function { return this._skinFunction; }
	private function set_skinFunction(value:Function):Function
	{
		if (this._skinFunction == value)
		{
			return value;
		}
		this._skinFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._skinFunction;
	}
	
	/**
	 * The field in the item that contains a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the item renderer's
	 * skin. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>skinLoaderFactory</code>.
	 *
	 * <p>Using a skin source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * a <code>skinField</code> or <code>skinFunction</code>
	 * because the renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>All of the skin fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>skinSourceFunction</code></li>
	 *     <li><code>skinSourceField</code></li>
	 *     <li><code>skinFunction</code></li>
	 *     <li><code>skinField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the skin source field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSkin = true;
	 * renderer.skinSourceField = "texture";</listing>
	 *
	 * @default "skinSource"
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #itemHasSkin
	 * @see #skinLoaderFactory
	 * @see #skinSourceFunction
	 * @see #skinField
	 * @see #skinFunction
	 */
	public var skinSourceField(get, set):String;
	private var _skinSourceField:String = "skinSource";
	private function get_skinSourceField():String { return this._skinSourceField; }
	private function set_skinSourceField(value:String):String
	{
		if (this._skinSourceField == value)
		{
			return value;
		}
		this._skinSourceField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._skinSourceField;
	}
	
	/**
	 * A function used to generate a <code>starling.textures.Texture</code>
	 * or a URL that points to a bitmap to be used as the item renderer's
	 * skin. The renderer will automatically manage and reuse an internal
	 * <code>ImageLoader</code> sub-component and this value will be passed
	 * to the <code>source</code> property. The <code>ImageLoader</code> may
	 * be customized by changing the <code>skinLoaderFactory</code>.
	 *
	 * <p>Using a skin source will result in better performance than
	 * passing in an <code>ImageLoader</code> or <code>Image</code> through
	 * a <code>skinField</code> or <code>skinnFunction</code>
	 * because the renderer can avoid costly display list manipulation.</p>
	 *
	 * <p>Note: As the list scrolls, this function will almost always be
	 * called more than once for each individual item in the list's data
	 * provider. Your function should not simply return a new texture every
	 * time. This will result in the unnecessary creation and destruction of
	 * many textures, which will overwork the garbage collector and hurt
	 * performance. Creating a new texture at all is dangerous, unless you
	 * are absolutely sure to dispose it when necessary because neither the
	 * list nor its item renderer will dispose of the texture for you. If
	 * you are absolutely sure that you are managing the texture memory with
	 * proper disposal, it's better to return a new texture the first
	 * time this function is called for a particular item and then return
	 * the same texture if that item is passed to this function again.</p>
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Object</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):Object</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):Object</pre>
	 *
	 * <p>The return value is a valid value for the <code>source</code>
	 * property of an <code>ImageLoader</code> component.</p>
	 *
	 * <p>All of the skin fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>skinSourceFunction</code></li>
	 *     <li><code>skinSourceField</code></li>
	 *     <li><code>skinFunction</code></li>
	 *     <li><code>skinField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the skin source function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSkin = true;
	 * renderer.skinSourceFunction = function( item:Object ):Object
	 * {
	 *    return "http://www.example.com/images/" + item.name + "-skin.png";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ImageLoader#source
	 * @see #itemHasSkin
	 * @see #skinLoaderFactory
	 * @see #skinSourceField
	 * @see #skinField
	 * @see #skinFunction
	 */
	public var skinSourceFunction(get, set):Function;
	private var _skinSourceFunction:Function;
	private function get_skinSourceFunction():Function { return this._skinSourceFunction; }
	private function set_skinSourceFunction(value:Function):Function
	{
		if (this._skinSourceFunction == value)
		{
			return value;
		}
		this._skinSourceFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._skinSourceFunction;
	}
	
	/**
	 * The field in the item that determines if the item renderer can be
	 * selected, if the list allows selection. If the item does not have
	 * this field, and a <code>selectableFunction</code> is not defined,
	 * then the renderer will default to being selectable.
	 *
	 * <p>All of the label fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>selectableFunction</code></li>
	 *     <li><code>selectableField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the selectable field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSelectable = true;
	 * renderer.selectableField = "isSelectable";</listing>
	 *
	 * @default "selectable"
	 *
	 * @see #selectableFunction
	 * @see #itemHasSelectable
	 */
	public var selectableField(get, set):String;
	private var _selectableField:String = "selectable";
	private function get_selectableField():String { return this._selectableField; }
	private function set_selectableField(value:String):String
	{
		if (this._selectableField == value)
		{
			return value;
		}
		this._selectableField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._selectableField;
	}
	
	/**
	 * A function used to determine if a specific item is selectable. If this
	 * function is not null, then the <code>selectableField</code> will be
	 * ignored.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Boolean</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):Boolean</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):Boolean</pre>
	 *
	 * <p>All of the selectable fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>selectableFunction</code></li>
	 *     <li><code>selectableField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the selectable function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasSelectable = true;
	 * renderer.selectableFunction = function( item:Object ):Boolean
	 * {
	 *    return item.isSelectable;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #selectableField
	 * @see #itemHasSelectable
	 */
	public var selectableFunction(get, set):Function;
	private var _selectableFunction:Function;
	private function get_selectableFunction():Function { return this._selectableFunction; }
	private function set_selectableFunction(value:Function):Function
	{
		if (this._selectableFunction == value)
		{
			return value;
		}
		this._selectableFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._selectableFunction;
	}
	
	/**
	 * The field in the item that determines if the item renderer is
	 * enabled, if the list is enabled. If the item does not have
	 * this field, and a <code>enabledFunction</code> is not defined,
	 * then the renderer will default to being enabled.
	 *
	 * <p>All of the label fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>enabledFunction</code></li>
	 *     <li><code>enabledField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the enabled field is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasEnabled = true;
	 * renderer.enabledField = "isEnabled";</listing>
	 *
	 * @default "enabled"
	 *
	 * @see #enabledFunction
	 * @see #itemHasEnabled
	 */
	public var enabledField(get, set):String;
	private var _enabledField:String = "enabled";
	private function get_enabledField():String { return this._enabledField; }
	private function set_enabledField(value:String):String
	{
		if (this._enabledField == value)
		{
			return value;
		}
		this._enabledField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._enabledField;
	}
	
	/**
	 * A function used to determine if a specific item is enabled. If this
	 * function is not null, then the <code>enabledField</code> will be
	 * ignored.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Boolean</pre>
	 *
	 * <p>If the item renderer is an <code>IListItemRenderer</code>, the
	 * function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, index:int ):Boolean</pre>
	 *
	 * <p>If the item renderer is an <code>IGroupedListItemRenderer</code>,
	 * the function may optionally have the following signature instead:</p>
	 * <pre>function( item:Object, groupIndex:int, itemIndex:int ):Boolean</pre>
	 *
	 * <p>All of the enabled fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>enabledFunction</code></li>
	 *     <li><code>enabledField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the enabled function is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.itemHasEnabled = true;
	 * renderer.enabledFunction = function( item:Object ):Boolean
	 * {
	 *    return item.isEnabled;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #enabledField
	 * @see #itemHasEnabled
	 */
	public var enabledFunction(get, set):Function;
	private var _enabledFunction:Function;
	private function get_enabledFunction():Function { return this._enabledFunction; }
	private function set_enabledFunction(value:Function):Function
	{
		if (this._enabledFunction == value)
		{
			return value;
		}
		this._enabledFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._enabledFunction;
	}
	
	/**
	 * @private
	 */
	private var _explicitIsToggle:Bool = false;
	
	/**
	 * @private
	 */
	override function set_isToggle(value:Bool):Bool 
	{
		if (this._explicitIsToggle == value)
		{
			return value;
		}
		super.isToggle = value;
		this._explicitIsToggle = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._explicitIsToggle;
	}
	
	/**
	 * @private
	 */
	private var _explicitIsEnabled:Bool;
	
	/**
	 * @private
	 */
	override function set_isEnabled(value:Bool):Bool 
	{
		if (this._explicitIsEnabled == value)
		{
			return value;
		}
		this._explicitIsEnabled = value;
		super.isEnabled = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._explicitIsEnabled;
	}
	
	/**
	 * A function that generates an <code>ImageLoader</code> that uses the result
	 * of <code>iconSourceField</code> or <code>iconSourceFunction</code>.
	 * Useful for transforming the <code>ImageLoader</code> in some way. For
	 * example, you might want to scale the texture for current screen
	 * density or apply pixel snapping.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function():ImageLoader</pre>
	 *
	 * <p>In the following example, the loader factory is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconLoaderFactory = function():ImageLoader
	 * {
	 *    var loader:ImageLoader = new ImageLoader();
	 *    loader.scaleFactor = 2;
	 *    return loader;
	 * };</listing>
	 *
	 * @default function():ImageLoader { return new ImageLoader(); }
	 *
	 * @see feathers.controls.ImageLoader
	 * @see #iconSourceField
	 * @see #iconSourceFunction
	 */
	public var iconLoaderFactory(get, set):Function;
	private var _iconLoaderFactory:Function = defaultLoaderFactory;
	private function get_iconLoaderFactory():Function { return this._iconLoaderFactory; }
	private function set_iconLoaderFactory(value:Function):Function
	{
		if (this._iconLoaderFactory == value)
		{
			return value;
		}
		this._iconLoaderFactory = value;
		this._iconIsFromItem = false;
		this.replaceIcon(null);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconLoaderFactory;
	}
	
	/**
	 * @private
	 */
	private var _iconLabelFontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var iconLabelFontStyles(get, set):TextFormat;
	private function get_iconLabelFontStyles():TextFormat { return this._iconLabelFontStylesSet.format; }
	private function set_iconLabelFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("iconLabelFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("iconLabelFontStyles");
		}
		
		var oldValue:TextFormat = this._iconLabelFontStylesSet.format;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._iconLabelFontStylesSet.format = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var iconLabelDisabledFontStyles(get, set):TextFormat;
	private function get_iconLabelDisabledFontStyles():TextFormat { return this._iconLabelFontStylesSet.disabledFormat; }
	private function set_iconLabelDisabledFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("iconLabelDisabledFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("iconLabelDisabledFontStyles");
		}
		
		var oldValue:TextFormat = this._iconLabelFontStylesSet.disabledFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._iconLabelFontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var iconLabelSelectedFontStyles(get, set):TextFormat;
	private function get_iconLabelSelectedFontStyles():TextFormat { return this._iconLabelFontStylesSet.selectedFormat; }
	private function set_iconLabelSelectedFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("iconLabelSelectedFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("iconLabelSelectedFontStyles");
		}
		
		var oldValue:TextFormat = this._iconLabelFontStylesSet.selectedFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._iconLabelFontStylesSet.selectedFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * A function that generates <code>ITextRenderer</code> that uses the result
	 * of <code>iconLabelField</code> or <code>iconLabelFunction</code>.
	 * CAn be used to set properties on the <code>ITextRenderer</code>.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, the icon label factory is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.iconLabelFactory = function():ITextRenderer
	 * {
	 *    var renderer:TextFieldTextRenderer = new TextFieldTextRenderer();
	 *    renderer.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 *    renderer.embedFonts = true;
	 *    return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 * @see #iconLabelField
	 * @see #iconLabelFunction
	 */
	public var iconLabelFactory(get, set):Function;
	private var _iconLabelFactory:Function;
	private function get_iconLabelFactory():Function { return this._iconLabelFactory; }
	private function set_iconLabelFactory(value:Function):Function
	{
		if (this._iconLabelFactory == value)
		{
			return value;
		}
		this._iconLabelFactory = value;
		this._iconIsFromItem = false;
		this.replaceIcon(null);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._iconLabelFactory;
	}
	
	/**
	 * An object that stores properties for the icon label text renderer
	 * sub-component (if using <code>iconLabelField</code> or
	 * <code>iconLabelFunction</code>), and the properties will be passed
	 * down to the text renderer when this component validates. The
	 * available properties depend on which <code>ITextRenderer</code>
	 * implementation is returned by <code>iconLabelFactory</code>. Refer to
	 * <a href="../../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>iconLabelFactory</code>
	 * function instead of using <code>iconLabelProperties</code> will
	 * result in better performance.</p>
	 *
	 * <p>In the following example, the icon label properties are customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.&#64;iconLabelProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 * renderer.&#64;iconLabelProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see #iconLabelFactory
	 * @see #iconLabelField
	 * @see #iconLabelFunction
	 */
	public var iconLabelProperties(get, set):Dynamic;
	private var _iconLabelProperties:PropertyProxy;
	private function get_iconLabelProperties():PropertyProxy
	{
		if (this._iconLabelProperties == null)
		{
			this._iconLabelProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._iconLabelProperties;
	}
	
	private function set_iconLabelProperties(value:Dynamic):Dynamic
	{
		if (this._iconLabelProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxyReal))
		{
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			//value = newValue;
			value = PropertyProxy.fromObject(value);
		}
		if (this._iconLabelProperties != null)
		{
			this._iconLabelProperties.removeOnChangeCallback(childProperties_onChange);
			this._iconLabelProperties.dispose();
		}
		this._iconLabelProperties = cast value;
		if (this._iconLabelProperties != null)
		{
			this._iconLabelProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._iconLabelProperties;
	}
	
	/**
	 * A function that generates an <code>ImageLoader</code> that uses the result
	 * of <code>accessorySourceField</code> or <code>accessorySourceFunction</code>.
	 * Useful for transforming the <code>ImageLoader</code> in some way. For
	 * example, you might want to scale the texture for current screen
	 * density or apply pixel snapping.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function():ImageLoader</pre>
	 *
	 * <p>In the following example, the loader factory is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessoryLoaderFactory = function():ImageLoader
	 * {
	 *    var loader:ImageLoader = new ImageLoader();
	 *    loader.scaleFactor = 2;
	 *    return loader;
	 * };</listing>
	 *
	 * @default function():ImageLoader { return new ImageLoader(); }
	 *
	 * @see feathers.controls.ImageLoader
	 * @see #accessorySourceField;
	 * @see #accessorySourceFunction;
	 */
	public var accessoryLoaderFactory(get, set):Function;
	private var _accessoryLoaderFactory:Function;
	private function get_accessoryLoaderFactory():Function { return this._accessoryLoaderFactory; }
	private function set_accessoryLoaderFactory(value:Function):Function
	{
		if (this._accessoryLoaderFactory == value)
		{
			return value;
		}
		this._accessoryLoaderFactory = value;
		this._accessoryIsFromItem = false;
		this.replaceAccessory(null);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessoryLoaderFactory;
	}
	
	/**
	 * @private
	 */
	private var _accessoryLabelFontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var accessoryLabelFontStyles(get, set):TextFormat;
	private function get_accessoryLabelFontStyles():TextFormat { return this._accessoryLabelFontStylesSet.format; }
	private function set_accessoryLabelFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("accessoryLabelFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("accessoryLabelFontStyles");
		}
		
		var oldValue:TextFormat = this._accessoryLabelFontStylesSet.format;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._accessoryLabelFontStylesSet.format = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var accessoryLabelDisabledFontStyles(get, set):TextFormat;
	private function get_accessoryLabelDisabledFontStyles():TextFormat { return this._accessoryLabelFontStylesSet.disabledFormat; }
	private function set_accessoryLabelDisabledFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("accessoryLabelDisabledFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("accessoryLabelDisabledFontStyles");
		}
		
		var oldValue:TextFormat = this._accessoryLabelFontStylesSet.disabledFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._accessoryLabelFontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var accessoryLabelSelectedFontStyles(get, set):TextFormat;
	private function get_accessoryLabelSelectedFontStyles():TextFormat { return this._accessoryLabelFontStylesSet.selectedFormat; }
	private function set_accessoryLabelSelectedFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("accessoryLabelSelectedFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("accessoryLabelSelectedFontStyles");
		}
		
		var oldValue:TextFormat = this._accessoryLabelFontStylesSet.selectedFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._accessoryLabelFontStylesSet.selectedFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * A function that generates <code>ITextRenderer</code> that uses the result
	 * of <code>accessoryLabelField</code> or <code>accessoryLabelFunction</code>.
	 * CAn be used to set properties on the <code>ITextRenderer</code>.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, the accessory label factory is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.accessoryLabelFactory = function():ITextRenderer
	 * {
	 *    var renderer:TextFieldTextRenderer = new TextFieldTextRenderer();
	 *    renderer.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 *    renderer.embedFonts = true;
	 *    return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 * @see #accessoryLabelField
	 * @see #accessoryLabelFunction
	 */
	public var accessoryLabelFactory(get, set):Function;
	private var _accessoryLabelFactory:Function;
	private function get_accessoryLabelFactory():Function { return this._accessoryLabelFactory; }
	private function set_accessoryLabelFactory(value:Function):Function
	{
		if (this._accessoryLabelFactory == value)
		{
			return value;
		}
		this._accessoryLabelFactory = value;
		this._accessoryIsFromItem = false;
		this.replaceAccessory(null);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._accessoryLabelFactory;
	}
	
	
	public var accessoryLabelProperties(get, set):Dynamic;
	private var _accessoryLabelProperties:PropertyProxy;
	private function get_accessoryLabelProperties():Dynamic
	{
		if (this._accessoryLabelProperties == null)
		{
			this._accessoryLabelProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._accessoryLabelProperties;
	}
	
	private function set_accessoryLabelProperties(value:Dynamic):Dynamic
	{
		if (this._accessoryLabelProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxyReal))
		{
			//var newValue:PropertyProxy = new PropertyProxy();
			//for(var propertyName:String in value)
			//{
				//newValue[propertyName] = value[propertyName];
			//}
			//value = newValue;
			value = PropertyProxy.fromObject(value);
		}
		if (this._accessoryLabelProperties != null)
		{
			this._accessoryLabelProperties.removeOnChangeCallback(childProperties_onChange);
			this._accessoryLabelProperties.dispose();
		}
		this._accessoryLabelProperties = cast value;
		if (this._accessoryLabelProperties != null)
		{
			this._accessoryLabelProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._accessoryLabelProperties;
	}
	
	/**
	 * A function that generates an <code>ImageLoader</code> that uses the result
	 * of <code>skinSourceField</code> or <code>skinSourceFunction</code>.
	 * Useful for transforming the <code>ImageLoader</code> in some way. For
	 * example, you might want to scale the texture for current screen
	 * density or apply pixel snapping.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function():ImageLoader</pre>
	 *
	 * <p>In the following example, the loader factory is customized:</p>
	 *
	 * <listing version="3.0">
	 * renderer.skinLoaderFactory = function():ImageLoader
	 * {
	 *    var loader:ImageLoader = new ImageLoader();
	 *    loader.scaleFactor = 2;
	 *    return loader;
	 * };</listing>
	 *
	 * @default function():ImageLoader { return new ImageLoader(); }
	 *
	 * @see feathers.controls.ImageLoader
	 * @see #skinSourceField
	 * @see #skinSourceFunction
	 */
	public var skinLoaderFactory(get, set):Function;
	private var _skinLoaderFactory:Function = defaultLoaderFactory;
	private function get_skinLoaderFactory():Function { return this._skinLoaderFactory; }
	private function set_skinLoaderFactory(value:Function):Function
	{
		if (this._skinLoaderFactory == value)
		{
			return value;
		}
		this._skinLoaderFactory = value;
		this._skinIsFromItem = false;
		this.replaceSkin(null);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._skinLoaderFactory;
	}
	
	/**
	 * @private
	 */
	private var _ignoreAccessoryResizes:Bool = false;

	/**
	 * @private
	 */
	private var _topOffset:Float = 0;

	/**
	 * @private
	 */
	private var _rightOffset:Float = 0;

	/**
	 * @private
	 */
	private var _bottomOffset:Float = 0;

	/**
	 * @private
	 */
	private var _leftOffset:Float = 0;
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._iconIsFromItem)
		{
			this.replaceIcon(null);
		}
		if (this._accessoryIsFromItem)
		{
			this.replaceAccessory(null);
		}
		if (this._skinIsFromItem)
		{
			this.replaceSkin(null);
		}
		if (this._iconLabelFontStylesSet != null)
		{
			this._iconLabelFontStylesSet.dispose();
			this._iconLabelFontStylesSet = null;
		}
		if (this._accessoryLabelFontStylesSet != null)
		{
			this._accessoryLabelFontStylesSet.dispose();
			this._accessoryLabelFontStylesSet = null;
		}
		if (this._accessoryLabelProperties != null)
		{
			this._accessoryLabelProperties.dispose();
			this._accessoryLabelProperties = null;
		}
		if (this._defaultLabelProperties != null)
		{
			this._defaultLabelProperties.dispose();
			this._defaultLabelProperties = null;
		}
		if (this._iconLabelProperties != null)
		{
			this._iconLabelProperties.dispose();
			this._iconLabelProperties = null;
		}
		super.dispose();
	}
	
	/**
	 * Using <code>labelField</code> and <code>labelFunction</code>,
	 * generates a label from the item.
	 *
	 * <p>All of the label fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>labelFunction</code></li>
	 *     <li><code>labelField</code></li>
	 * </ol>
	 */
	public function itemToLabel(item:Dynamic):String
	{
		var labelResult:Dynamic;
		if (this._labelFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._labelFunction) == 2)
			{
				labelResult = this._labelFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._labelFunction) == 3)
			{
				var groupItemRenderer:IGroupedListItemRenderer = cast this;
				labelResult = this._labelFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			else
			{
				labelResult = this._labelFunction(item);
			}
			if (Std.isOfType(labelResult, String))
			{
				return cast labelResult;
			}
			else if (labelResult != null)
			{
				return labelResult.toString();
			}
		}
		else if (this._labelField != null && item != null && Reflect.hasField(item, this._labelField))
		{
			labelResult = Reflect.getProperty(item, this._labelField);
			if (Std.isOfType(labelResult, String))
			{
				return cast labelResult;
			}
			else if (labelResult != null)
			{
				return labelResult.toString();
			}
		}
		else if (Std.isOfType(item, String))
		{
			return cast item;
		}
		else if (item != null)
		{
			//we need to use strict equality here because the data can be
			//non-strictly equal to null
			return item.toString();
		}
		return null;
	}
	
	/**
	 * Uses the icon fields and functions to generate an icon for a specific
	 * item.
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconSourceFunction</code></li>
	 *     <li><code>iconSourceField</code></li>
	 *     <li><code>iconLabelFunction</code></li>
	 *     <li><code>iconLabelField</code></li>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 */
	private function itemToIcon(item:Dynamic):DisplayObject
	{
		var source:Dynamic;
		var groupItemRenderer:IGroupedListItemRenderer;
		var labelResult:Dynamic;
		if (this._iconSourceFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._iconSourceFunction) == 2)
			{
				source = this._iconSourceFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._iconSourceFunction) == 3)
			{
				groupItemRenderer = cast this;
				source = this._iconSourceFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			else
			{
				source = this._iconSourceFunction(item);
			}
			this.refreshIconSource(source);
			return this.iconLoader;
		}
		else if (this._iconSourceField != null && item != null && Reflect.hasField(item, this._iconSourceField))
		{
			source = Reflect.getProperty(item, this._iconSourceField);
			this.refreshIconSource(source);
			return this.iconLoader;
		}
		else if (this._iconLabelFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._iconLabelFunction) == 2)
			{
				labelResult = this._iconLabelFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._iconLabelFunction) == 3)
			{
				groupItemRenderer = cast this;
				labelResult = this._iconLabelFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			else
			{
				labelResult = this._iconLabelFunction(item);
			}
			if (Std.isOfType(labelResult, String))
			{
				this.refreshIconLabel(cast labelResult);
			}
			else
			{
				this.refreshIconLabel(labelResult.toString());
			}
			return cast this.iconLabel;
		}
		else if (this._iconLabelField != null && item != null && Reflect.hasField(item, this._iconLabelField))
		{
			labelResult = Reflect.getProperty(item, this._iconLabelField);
			if (Std.isOfType(labelResult, String))
			{
				this.refreshIconLabel(cast labelResult);
			}
			else
			{
				this.refreshIconLabel(labelResult.toString());
			}
			return cast this.iconLabel;
		}
		else if (this._iconFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._iconFunction) == 2)
			{
				return cast this._iconFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._iconFunction) == 3)
			{
				groupItemRenderer = cast this;
				return cast this._iconFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			return cast this._iconFunction(item);
		}
		else if (this._iconField != null && item != null && Reflect.hasField(item, this._iconField))
		{
			return cast Reflect.getProperty(item, this._iconField);
		}
		
		return null;
	}
	
	/**
	 * Uses the accessory fields and functions to generate an accessory for
	 * a specific item.
	 *
	 * <p>All of the accessory fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>accessorySourceFunction</code></li>
	 *     <li><code>accessorySourceField</code></li>
	 *     <li><code>accessoryLabelFunction</code></li>
	 *     <li><code>accessoryLabelField</code></li>
	 *     <li><code>accessoryFunction</code></li>
	 *     <li><code>accessoryField</code></li>
	 * </ol>
	 */
	private function itemToAccessory(item:Dynamic):DisplayObject
	{
		var source:Dynamic;
		var groupItemRenderer:IGroupedListItemRenderer;
		var labelResult:Dynamic;
		if (this._accessorySourceFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._accessorySourceFunction) == 2)
			{
				source = this._accessorySourceFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._accessorySourceFunction) == 3)
			{
				groupItemRenderer = cast this;
				source = this._accessorySourceFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			else
			{
				source = this._accessorySourceFunction(item);
			}
			this.refreshAccessorySource(source);
			return this.accessoryLoader;
		}
		else if (this._accessorySourceField != null && item != null && Reflect.hasField(item, this._accessorySourceField))
		{
			source = Reflect.getProperty(item, this._accessorySourceField);
			this.refreshAccessorySource(source);
			return this.accessoryLoader;
		}
		else if (this._accessoryLabelFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._accessoryLabelFunction) == 2)
			{
				labelResult = this._accessoryLabelFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._accessoryLabelFunction) == 3)
			{
				groupItemRenderer = cast this;
				labelResult = this._accessoryLabelFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			else
			{
				labelResult = this._accessoryLabelFunction(item);
			}
			if (Std.isOfType(labelResult, String))
			{
				this.refreshAccessoryLabel(cast labelResult);
			}
			else
			{
				this.refreshAccessoryLabel(labelResult.toString());
			}
			return cast this.accessoryLabel;
		}
		else if (this._accessoryLabelField != null && item != null && Reflect.hasField(item, this._accessoryLabelField))
		{
			labelResult = Reflect.getProperty(item, this._accessoryLabelField);
			if (Std.isOfType(labelResult, String))
			{
				this.refreshAccessoryLabel(cast labelResult);
			}
			else
			{
				this.refreshAccessoryLabel(labelResult.toString());
			}
			return cast this.accessoryLabel;
		}
		else if (this._accessoryFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._accessoryFunction) == 2)
			{
				return cast this._accessoryFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._accessoryFunction) == 3)
			{
				groupItemRenderer = cast this;
				return cast this._accessoryFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			return cast this._accessoryFunction(item);
		}
		else if (this._accessoryField != null && item != null && Reflect.hasField(item, this._accessoryField))
		{
			return cast Reflect.getProperty(item, this._accessoryField);
		}
		
		return null;
	}
	
	/**
	 * Uses the skin fields and functions to generate a skin for a specific
	 * item.
	 *
	 * <p>All of the skin fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>skinSourceFunction</code></li>
	 *     <li><code>skinSourceField</code></li>
	 *     <li><code>skinFunction</code></li>
	 *     <li><code>skinField</code></li>
	 * </ol>
	 */
	private function itemToSkin(item:Dynamic):DisplayObject
	{
		var source:Dynamic;
		var groupItemRenderer:IGroupedListItemRenderer;
		if (this._skinSourceFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._skinSourceFunction) == 2)
			{
				source = this._skinSourceFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._skinSourceFunction) == 3)
			{
				groupItemRenderer = cast this;
				source = this._skinSourceFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			else
			{
				source = this._skinSourceFunction(item);
			}
			this.refreshSkinSource(source);
			return this.skinLoader;
		}
		else if (this._skinSourceField != null && item != null && Reflect.hasField(item, this._skinSourceField))
		{
			source = Reflect.getProperty(item, this._skinSourceField);
			this.refreshSkinSource(source);
			return this.skinLoader;
		}
		else if (this._skinFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._skinFunction) == 2)
			{
				return cast this._skinFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._skinFunction) == 3)
			{
				groupItemRenderer = cast this;
				return cast this._skinFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			return cast this._skinFunction(item);
		}
		else if (this._skinField != null && item != null && Reflect.hasField(item, this._skinField))
		{
			return cast Reflect.getProperty(item, this._skinField);
		}
		
		return null;
	}
	
	/**
	 * Uses the selectable fields and functions to generate a selectable
	 * value for a specific item.
	 *
	 * <p>All of the selectable fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>selectableFunction</code></li>
	 *     <li><code>selectableField</code></li>
	 * </ol>
	 */
	private function itemToSelectable(item:Dynamic):Bool
	{
		if (this._selectableFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._selectableFunction) == 2)
			{
				return cast this._selectableFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._selectableFunction) == 3)
			{
				var groupItemRenderer:IGroupedListItemRenderer = cast this;
				return cast this._selectableFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			return cast this._selectableFunction(item);
		}
		else if (this._selectableField != null && item != null && Reflect.hasField(item, this._selectableField))
		{
			return cast Reflect.getProperty(item, this._selectableField);
		}
		return true;
	}
	
	/**
	 * Uses the enabled fields and functions to generate a enabled value for
	 * a specific item.
	 *
	 * <p>All of the enabled fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>enabledFunction</code></li>
	 *     <li><code>enabledField</code></li>
	 * </ol>
	 */
	private function itemToEnabled(item:Dynamic):Bool
	{
		if (this._enabledFunction != null)
		{
			if (Std.isOfType(this, IListItemRenderer) && ArgumentsCount.count_args(this._enabledFunction) == 2)
			{
				return this._enabledFunction(item, cast(this, IListItemRenderer).index);
			}
			else if (Std.isOfType(this, IGroupedListItemRenderer) && ArgumentsCount.count_args(this._enabledFunction) == 3)
			{
				var groupItemRenderer:IGroupedListItemRenderer = cast this;
				return cast this._enabledFunction(item, groupItemRenderer.groupIndex, groupItemRenderer.itemIndex);
			}
			return cast this._enabledFunction(item);
		}
		else if (this._enabledField != null && item != null && Reflect.hasField(item, this._enabledField))
		{
			return cast Reflect.getProperty(item, this._enabledField);
		}
		
		return true;
	}
	
	/**
	 * Gets the font styles to be used to display the item renderer's icon
	 * label text when the item renderer's <code>currentState</code>
	 * property matches the specified state value.
	 *
	 * <p>If icon label font styles are not defined for a specific state,
	 * returns <code>null</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #setIconLabelFontStylesForState()
	 * @see #iconLabelFontStyles
	 */
	public function getIconLabelFontStylesForState(state:String):TextFormat
	{
		if (this._iconLabelFontStylesSet == null)
		{
			return null;
		}
		return this._iconLabelFontStylesSet.getFormatForState(state);
	}
	
	/**
	 * Sets the font styles to be used to display the icon label's text when
	 * the item renderer's <code>currentState</code> property matches the
	 * specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, the value of
	 * the <code>iconLabelFontStyles</code> property will be used instead.</p>
	 *
	 * <p>Note: if the text renderer has been customized with advanced font
	 * formatting, it may override the values specified with
	 * <code>setIconLabelFontStylesForState()</code> and properties like
	 * <code>iconLabelFontStyles</code> and
	 * <code>disabledIconLabelFontStyles</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #iconLabelFontStyles
	 */
	public function setIconLabelFontStylesForState(state:String, format:TextFormat):Void
	{
		var key:String = "setIconLabelFontStylesForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(key);
		}
		var oldFormat:TextFormat = this._iconLabelFontStylesSet.getFormatForState(state);
		if (oldFormat != null)
		{
			oldFormat.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._iconLabelFontStylesSet.setFormatForState(state, format);
		if (format != null)
		{
			format.addEventListener(Event.CHANGE, changeHandler);
		}
	}
	
	/**
	 * Gets the font styles to be used to display the item renderer's
	 * accessory label text when the item renderer's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If icon label font styles are not defined for a specific state,
	 * returns <code>null</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #setAccessoryLabelFontStylesForState()
	 * @see #accessoryLabelfontStyles
	 */
	public function getAccessoryLabelFontStylesForState(state:String):TextFormat
	{
		if (this._accessoryLabelFontStylesSet == null)
		{
			return null;
		}
		return this._accessoryLabelFontStylesSet.getFormatForState(state);
	}
	
	/**
	 * Sets the font styles to be used to display the accessory label's text
	 * when the item renderer's <code>currentState</code> property matches
	 * the specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, the value of
	 * the <code>accessoryLabelFontStyles</code> property will be used instead.</p>
	 *
	 * <p>Note: if the text renderer has been customized with advanced font
	 * formatting, it may override the values specified with
	 * <code>setAccessoryLabelFontStylesForState()</code> and properties like
	 * <code>accessoryLabelFontStyles</code> and
	 * <code>disabledAccessoryLabelFontStyles</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #accessoryLabelFontStyles
	 */
	public function setAccessoryLabelFontStylesForState(state:String, format:TextFormat):Void
	{
		var key:String = "setAccessoryLabelFontStylesForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(key);
		}
		var oldFormat:TextFormat = this._accessoryLabelFontStylesSet.getFormatForState(state);
		if (oldFormat != null)
		{
			oldFormat.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._accessoryLabelFontStylesSet.setFormatForState(state, format);
		if (format != null)
		{
			format.addEventListener(Event.CHANGE, changeHandler);
		}
	}
	
	/**
	 * Gets the accessory to be used by the item renderer when the item
	 * renderer's <code>currentState</code> property matches the specified
	 * state value.
	 *
	 * <p>If a accessory is not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see #setAccessoryForState()
	 */
	public function getAccessoryForState(state:String):DisplayObject
	{
		return SafeCast.safe_cast(this._stateToAccessory[state], DisplayObject);
	}
	
	/**
	 * Sets the accessory to be used by the item renderer when the item
	 * renderer's <code>currentState</code> property matches the specified
	 * state value.
	 *
	 * <p>If an accessory is not defined for a specific state, the value of
	 * the <code>defaultAccessory</code> property will be used instead.</p>
	 *
	 * @see #defaultAccessory
	 */
	public function setAccessoryForState(state:String, accessory:DisplayObject):Void
	{
		if (accessory != null)
		{
			this._stateToAccessory[state] = accessory;
		}
		else
		{
			this._stateToAccessory.remove(state);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		if (this.touchToState == null && this._useStateDelayTimer)
		{
			this.touchToState = new DelayedDownTouchToState(this, this.changeState);
		}
		super.initialize();
		this.tapToTrigger.customHitTest = this.hitTestWithAccessory;
		this.tapToSelect.customHitTest = this.hitTestWithAccessory;
		this.longPress.customHitTest = this.hitTestWithAccessory;
		this.touchToState.customHitTest = this.hitTestWithAccessory;
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		if (dataInvalid)
		{
			this.commitData();
		}
		if (stateInvalid || dataInvalid || stylesInvalid)
		{
			this.refreshAccessory();
		}
		this.refreshOffsets();
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
		
		var oldIgnoreAccessoryResizes:Bool = this._ignoreAccessoryResizes;
		this._ignoreAccessoryResizes = true;
		var labelRenderer:ITextRenderer = null;
		if (this._label != null && this.labelTextRenderer != null)
		{
			labelRenderer = this.labelTextRenderer;
			this.refreshLabelTextRendererDimensions(true);
			this.labelTextRenderer.measureText(HELPER_POINT);
		}
		if (Std.isOfType(this.currentIcon, IValidating))
		{
			cast(this.currentIcon, IValidating).validate();
		}
		if (Std.isOfType(this.currentAccessory, IValidating))
		{
			cast(this.currentAccessory, IValidating).validate();
		}
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitSkinWidth, this._explicitSkinHeight,
			this._explicitSkinMinWidth, this._explicitSkinMinHeight,
			this._explicitSkinMaxWidth, this._explicitSkinMaxHeight);
		var measureSkin:IMeasureDisplayObject = SafeCast.safe_cast(this.currentSkin, IMeasureDisplayObject);
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (labelRenderer != null)
			{
				newWidth = HELPER_POINT.x;
			}
			else
			{
				newWidth = 0;
			}
			if (this._layoutOrder == ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON)
			{
				newWidth = this.addAccessoryWidth(newWidth);
				newWidth = this.addIconWidth(newWidth);
			}
			else
			{
				newWidth = this.addIconWidth(newWidth);
				newWidth = this.addAccessoryWidth(newWidth);
			}
			newWidth += this._leftOffset + this._rightOffset;
			if (this.currentSkin != null &&
				this.currentSkin.width > newWidth)
			{
				newWidth = this.currentSkin.width;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (labelRenderer != null)
			{
				newHeight = HELPER_POINT.y;
			}
			else
			{
				newHeight = 0;
			}
			if (this._layoutOrder == ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON)
			{
				newHeight = this.addAccessoryHeight(newHeight);
				newHeight = this.addIconHeight(newHeight);
			}
			else
			{
				newHeight = this.addIconHeight(newHeight);
				newHeight = this.addAccessoryHeight(newHeight);
			}
			newHeight += this._topOffset + this._bottomOffset;
			if (this.currentSkin != null &&
				this.currentSkin.height > newHeight)
			{
				newHeight = this.currentSkin.height;
			}
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (labelRenderer != null)
			{
				newMinWidth = HELPER_POINT.x;
			}
			else
			{
				newMinWidth = 0;
			}
			if (this._layoutOrder == ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON)
			{
				newMinWidth = this.addAccessoryWidth(newMinWidth);
				newMinWidth = this.addIconWidth(newMinWidth);
			}
			else
			{
				newMinWidth = this.addIconWidth(newMinWidth);
				newMinWidth = this.addAccessoryWidth(newMinWidth);
			}
			newMinWidth += this._leftOffset + this._rightOffset;
			if (this.currentSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minWidth > newMinWidth)
					{
						newMinWidth = measureSkin.minWidth;
					}
				}
				else if (this._explicitSkinMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitSkinMinWidth;
				}
			}
		}
		
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (labelRenderer != null)
			{
				newMinHeight = HELPER_POINT.y;
			}
			else
			{
				newMinHeight = 0;
			}
			if (this._layoutOrder == ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON)
			{
				newMinHeight = this.addAccessoryHeight(newMinHeight);
				newMinHeight = this.addIconHeight(newMinHeight);
			}
			else
			{
				newMinHeight = this.addIconHeight(newMinHeight);
				newMinHeight = this.addAccessoryHeight(newMinHeight);
			}
			newMinHeight += this._topOffset + this._bottomOffset;
			if (this.currentSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minHeight > newMinHeight)
					{
						newMinHeight = measureSkin.minHeight;
					}
				}
				else if (this._explicitSkinMinHeight > newMinHeight)
				{
					newMinHeight = this._explicitSkinMinHeight;
				}
			}
		}
		this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	override function changeState(value:String):Void
	{
		if (this._isEnabled && !this._isToggle &&
			(!this.isSelectableWithoutToggle || (this._itemHasSelectable && !this.itemToSelectable(this._data))))
		{
			value = ButtonState.UP;
		}
		super.changeState(value);
	}
	
	/**
	 * @private
	 */
	private function addIconWidth(width:Float):Float
	{
		if (this.currentIcon == null)
		{
			return width;
		}
		var iconWidth:Float = this.currentIcon.width;
		if (iconWidth != iconWidth) //isNaN
		{
			return width;
		}
		
		var hasPreviousItem:Bool = width == width; //!isNaN
		if (!hasPreviousItem)
		{
			width = 0;
		}
		
		if (this._iconPosition == RelativePosition.LEFT || this._iconPosition == RelativePosition.LEFT_BASELINE || this._iconPosition == RelativePosition.RIGHT || this._iconPosition == RelativePosition.RIGHT_BASELINE)
		{
			if (hasPreviousItem)
			{
				var adjustedGap:Float = this._gap;
				if (this._gap == Math.POSITIVE_INFINITY)
				{
					adjustedGap = this._minGap;
				}
				width += adjustedGap;
			}
			width += iconWidth;
		}
		else if (iconWidth > width)
		{
			width = iconWidth;
		}
		return width;
	}
	
	/**
	 * @private
	 */
	private function addAccessoryWidth(width:Float):Float
	{
		if (this.currentAccessory == null)
		{
			return width;
		}
		var accessoryWidth:Float = this.currentAccessory.width;
		if (accessoryWidth != accessoryWidth) //isNaN
		{
			return width;
		}
		
		var hasPreviousItem:Bool = width == width; //!isNaN;
		if (!hasPreviousItem)
		{
			width = 0;
		}
		
		if (this._accessoryPosition == RelativePosition.LEFT || this._accessoryPosition == RelativePosition.RIGHT)
		{
			if (hasPreviousItem)
			{
				var adjustedAccessoryGap:Float = this._accessoryGap;
				//for some reason, if we do the !== check on a local variable right
				//here, compiling with the flex 4.6 SDK will throw a VerifyError
				//for a stack overflow.
				//we could change the !== check back to isNaN() instead, but
				//isNaN() can allocate an object that needs garbage collection.
				if (this._accessoryGap != this._accessoryGap) //isNaN
				{
					adjustedAccessoryGap = this._gap;
				}
				if (adjustedAccessoryGap == Math.POSITIVE_INFINITY)
				{
					if (this._minAccessoryGap != this._minAccessoryGap) //isNaN
					{
						adjustedAccessoryGap = this._minGap;
					}
					else
					{
						adjustedAccessoryGap = this._minAccessoryGap;
					}
				}
				width += adjustedAccessoryGap;
			}
			width += accessoryWidth;
		}
		else if (accessoryWidth > width)
		{
			width = accessoryWidth;
		}
		return width;
	}
	
	/**
	 * @private
	 */
	private function addIconHeight(height:Float):Float
	{
		if (this.currentIcon == null)
		{
			return height;
		}
		var iconHeight:Float = this.currentIcon.height;
		if (iconHeight != iconHeight) //isNaN
		{
			return height;
		}
		
		var hasPreviousItem:Bool = height == height; //!isNaN
		if (!hasPreviousItem)
		{
			height = 0;
		}
		
		if (this._iconPosition == RelativePosition.TOP || this._iconPosition == RelativePosition.BOTTOM)
		{
			if (hasPreviousItem)
			{
				var adjustedGap:Float = this._gap;
				if (this._gap == Math.POSITIVE_INFINITY)
				{
					adjustedGap = this._minGap;
				}
				height += adjustedGap;
			}
			height += iconHeight;
		}
		else if (iconHeight > height)
		{
			height = iconHeight;
		}
		return height;
	}
	
	/**
	 * @private
	 */
	private function addAccessoryHeight(height:Float):Float
	{
		if (this.currentAccessory == null)
		{
			return height;
		}
		var accessoryHeight:Float = this.currentAccessory.height;
		if (accessoryHeight != accessoryHeight) //isNaN
		{
			return height;
		}
		
		var hasPreviousItem:Bool = height == height; //!isNaN
		if (!hasPreviousItem)
		{
			height = 0;
		}
		
		if (this._accessoryPosition == RelativePosition.TOP || this._accessoryPosition == RelativePosition.BOTTOM)
		{
			if (hasPreviousItem)
			{
				var adjustedAccessoryGap:Float = this._accessoryGap;
				//for some reason, if we do the !== check on a local variable right
				//here, compiling with the flex 4.6 SDK will throw a VerifyError
				//for a stack overflow.
				//we could change the !== check back to isNaN() instead, but
				//isNaN() can allocate an object that needs garbage collection.
				if (this._accessoryGap != this._accessoryGap) //isNaN
				{
					adjustedAccessoryGap = this._gap;
				}
				if (adjustedAccessoryGap == Math.POSITIVE_INFINITY)
				{
					if (this._minAccessoryGap != this._minAccessoryGap) //isNaN
					{
						adjustedAccessoryGap = this._minGap;
					}
					else
					{
						adjustedAccessoryGap = this._minAccessoryGap;
					}
				}
				height += adjustedAccessoryGap;
			}
			height += accessoryHeight;
		}
		else if (accessoryHeight > height)
		{
			height = accessoryHeight;
		}
		return height;
	}
	
	/**
	 * @private
	 */
	private function getDataToRender():Dynamic
	{
		return this._data;
	}
	
	/**
	 * Updates the renderer to display the item's data. Override this
	 * function to pass data to sub-components and react to data changes.
	 *
	 * <p>Don't forget to handle the case where the data is <code>null</code>.</p>
	 */
	private function commitData():Void
	{
		var dataToRender:Dynamic = this.getDataToRender();
		//we need to use strict equality here because the data can be
		//non-strictly equal to null
		if (dataToRender != null)
		{
			if (this._itemHasLabel)
			{
				this._label = this.itemToLabel(dataToRender);
				//we don't need to invalidate because the label setter
				//uses the same data invalidation flag that triggered this
				//call to commitData(), so we're already properly invalid.
			}
			if (this._itemHasSkin)
			{
				var newSkin:DisplayObject = this.itemToSkin(dataToRender);
				this._skinIsFromItem = newSkin != null;
				this.replaceSkin(newSkin);
			}
			else if (this._skinIsFromItem)
			{
				this._skinIsFromItem = false;
				this.replaceSkin(null);
			}
			if (this._itemHasIcon)
			{
				var newIcon:DisplayObject = this.itemToIcon(dataToRender);
				this._iconIsFromItem = newIcon != null;
				this.replaceIcon(newIcon);
			}
			else if (this._iconIsFromItem)
			{
				this._iconIsFromItem = false;
				this.replaceIcon(null);
			}
			if (this._itemHasAccessory)
			{
				var newAccessory:DisplayObject = this.itemToAccessory(dataToRender);
				this._accessoryIsFromItem = newAccessory != null;
				this.replaceAccessory(newAccessory);
			}
			else if (this._accessoryIsFromItem)
			{
				this._accessoryIsFromItem = false;
				this.replaceAccessory(null);
			}
			if (this._itemHasSelectable)
			{
				this._isToggle = this._explicitIsToggle && this.itemToSelectable(dataToRender);
			}
			else
			{
				this._isToggle = this._explicitIsToggle;
			}
			if (this._itemHasEnabled)
			{
				this.refreshIsEnabled(this._explicitIsEnabled && this.itemToEnabled(dataToRender));
			}
			else
			{
				this.refreshIsEnabled(this._explicitIsEnabled);
			}
		}
		else
		{
			if (this._itemHasLabel)
			{
				this._label = "";
			}
			if (this._itemHasIcon || this._iconIsFromItem)
			{
				this._iconIsFromItem = false;
				this.replaceIcon(null);
			}
			if (this._itemHasSkin || this._skinIsFromItem)
			{
				this._skinIsFromItem = false;
				this.replaceSkin(null);
			}
			if (this._itemHasAccessory || this._accessoryIsFromItem)
			{
				this._accessoryIsFromItem = false;
				this.replaceAccessory(null);
			}
			if (this._itemHasSelectable)
			{
				this._isToggle = this._explicitIsToggle;
			}
			if (this._itemHasEnabled)
			{
				this.refreshIsEnabled(this._explicitIsEnabled);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshIsEnabled(value:Bool):Void
	{
		if (this._isEnabled == value)
		{
			return;
		}
		this._isEnabled = value;
		if (this._isEnabled)
		{
			//might be in another state for some reason
			//let's only change to up if needed
			if (this._currentState == ButtonState.DISABLED)
			{
				this._currentState = ButtonState.UP;
			}
			this.touchable = true;
		}
		else
		{
			this._currentState = ButtonState.DISABLED;
			this.touchable = false;
		}
		this.setInvalidationFlag(FeathersControl.INVALIDATION_FLAG_STATE);
		this.dispatchEventWith(FeathersEventType.STATE_CHANGE);
	}
	
	/**
	 * @private
	 */
	private function replaceIcon(newIcon:DisplayObject):Void
	{
		if (this.iconLoader != null && this.iconLoader != newIcon)
		{
			this.iconLoader.removeEventListener(Event.COMPLETE, loader_completeOrErrorHandler);
			this.iconLoader.removeEventListener(FeathersEventType.ERROR, loader_completeOrErrorHandler);
			this.iconLoader.dispose();
			this.iconLoader = null;
		}
		
		if (this.iconLabel != null && cast(this.iconLabel, DisplayObject) != newIcon)
		{
			//we can dispose this one, though, since we created it
			this.iconLabel.dispose();
			this.iconLabel = null;
		}
		
		if (this._itemHasIcon && this.currentIcon != null && this.currentIcon != newIcon && this.currentIcon.parent == this)
		{
			//the icon is created using the data provider, and it is not
			//created inside this class, so it is not our responsibility to
			//dispose the icon. if we dispose it, it may break something.
			this.currentIcon.removeFromParent(false);
			this.currentIcon = null;
		}
		//we're using currentIcon above, but we're emulating calling the
		//defaultIcon setter here. the Button class sets the currentIcon
		//elsewhere, so we want to take advantage of that exisiting code.
		
		//we're not calling the defaultIcon setter directly because we're in
		//the middle of validating, and it will just invalidate, which will
		//require another validation later. we want the Button class to
		//process the new icon immediately when we call super.draw().
		if (this._defaultIcon != newIcon)
		{
			this._defaultIcon = newIcon;
			//we don't need to do a full invalidation. the superclass will
			//correctly see this flag when we call super.draw().
			this.setInvalidationFlag(FeathersControl.INVALIDATION_FLAG_STYLES);
		}
		
		if (this.iconLoader != null)
		{
			this.iconLoader.delayTextureCreation = this._delayTextureCreationOnScroll && this._owner != null && this._owner.isScrolling;
		}
	}
	
	/**
	 * @private
	 */
	private function replaceAccessory(newAccessory:DisplayObject):Void
	{
		if (this.accessoryLoader != null && this.accessoryLoader != newAccessory)
		{
			this.accessoryLoader.removeEventListener(Event.COMPLETE, loader_completeOrErrorHandler);
			this.accessoryLoader.removeEventListener(FeathersEventType.ERROR, loader_completeOrErrorHandler);
			this.accessoryLoader.dispose();
			this.accessoryLoader = null;
		}
		
		if (this.accessoryLabel != null && cast(this.accessoryLabel, DisplayObject) != newAccessory)
		{
			//we can dispose this one, though, since we created it
			this.accessoryLabel.dispose();
			this.accessoryLabel = null;
		}
		
		if (this._itemHasAccessory && this.currentAccessory != null && this.currentAccessory != newAccessory && this.currentAccessory.parent == this)
		{
			//the icon is created using the data provider, and it is not
			//created inside this class, so it is not our responsibility to
			//dispose the icon. if we dispose it, it may break something.
			this.currentAccessory.removeFromParent(false);
			this.currentAccessory = null;
		}
		//we're using currentIcon above, but we're emulating calling the
		//defaultIcon setter here. the Button class sets the currentIcon
		//elsewhere, so we want to take advantage of that exisiting code.
		
		//we're not calling the defaultIcon setter directly because we're in
		//the middle of validating, and it will just invalidate, which will
		//require another validation later. we want the Button class to
		//process the new icon immediately when we call super.draw().
		if (this._defaultAccessory != newAccessory)
		{
			this._defaultAccessory = newAccessory;
			//we don't need to do a full invalidation. the superclass will
			//correctly see this flag when we call super.draw().
			this.setInvalidationFlag(FeathersControl.INVALIDATION_FLAG_STYLES);
		}
		
		if (this.accessoryLoader != null)
		{
			this.accessoryLoader.delayTextureCreation = this._delayTextureCreationOnScroll && this._owner != null && this._owner.isScrolling;
		}
	}
	
	/**
	 * @private
	 */
	private function replaceSkin(newSkin:DisplayObject):Void
	{
		if (this.skinLoader != null && this.skinLoader != newSkin)
		{
			this.skinLoader.removeEventListener(Event.COMPLETE, loader_completeOrErrorHandler);
			this.skinLoader.removeEventListener(FeathersEventType.ERROR, loader_completeOrErrorHandler);
			this.skinLoader.dispose();
			this.skinLoader = null;
		}
		
		if (this._itemHasSkin && this.currentSkin != null && this.currentSkin != newSkin && this.currentSkin.parent == this)
		{
			//the icon is created using the data provider, and it is not
			//created inside this class, so it is not our responsibility to
			//dispose the icon. if we dispose it, it may break something.
			this.currentSkin.removeFromParent(false);
			this.currentSkin = null;
		}
		//we're using currentIcon above, but we're emulating calling the
		//defaultIcon setter here. the Button class sets the currentIcon
		//elsewhere, so we want to take advantage of that exisiting code.
		
		//we're not calling the defaultSkin setter directly because we're in
		//the middle of validating, and it will just invalidate, which will
		//require another validation later. we want the Button class to
		//process the new skin immediately when we call super.draw().
		if (this._defaultSkin != newSkin)
		{
			this._defaultSkin = newSkin;
			//we don't need to do a full invalidation. the superclass will
			//correctly see this flag when we call super.draw().
			this.setInvalidationFlag(FeathersControl.INVALIDATION_FLAG_STYLES);
		}
		
		if (this.skinLoader != null)
		{
			this.skinLoader.delayTextureCreation = this._delayTextureCreationOnScroll && this._owner != null && this._owner.isScrolling;
		}
	}
	
	/**
	 * @private
	 */
	override function refreshIcon():Void
	{
		super.refreshIcon();
		if (this.iconLabel != null)
		{
			this.iconLabel.fontStyles = this._iconLabelFontStylesSet;
			//var displayIconLabel:DisplayObject = DisplayObject(this.iconLabel);
			//for(var propertyName:String in this._iconLabelProperties)
			//{
				//var propertyValue:Object = this._iconLabelProperties[propertyName];
				//displayIconLabel[propertyName] = propertyValue;
			//}
			var propertyValue:Dynamic;
			for (propertyName in this._iconLabelProperties)
			{
				propertyValue = this._iconLabelProperties[propertyName];
				Reflect.setProperty(this.iconLabel, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshAccessory():Void
	{
		var oldAccessory:DisplayObject = this.currentAccessory;
		this.currentAccessory = this.getCurrentAccessory();
		if (Std.isOfType(this.currentAccessory, IFeathersControl))
		{
			cast(this.currentAccessory, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (this.currentAccessory != oldAccessory)
		{
			if (oldAccessory != null)
			{
				if (Std.isOfType(oldAccessory, IStateObserver))
				{
					cast(oldAccessory, IStateObserver).stateContext = null;
				}
				if (Std.isOfType(oldAccessory, IFeathersControl))
				{
					oldAccessory.removeEventListener(FeathersEventType.RESIZE, accessory_resizeHandler);
					oldAccessory.removeEventListener(TouchEvent.TOUCH, accessory_touchHandler);
				}
				this.removeChild(oldAccessory, false);
			}
			if (this.currentAccessory != null)
			{
				if (Std.isOfType(this.currentAccessory, IStateObserver))
				{
					cast(this.currentAccessory, IStateObserver).stateContext = this;
				}
				this.addChild(this.currentAccessory);
				if (Std.isOfType(this.currentAccessory, IFeathersControl))
				{
					this.currentAccessory.addEventListener(FeathersEventType.RESIZE, accessory_resizeHandler);
					this.currentAccessory.addEventListener(TouchEvent.TOUCH, accessory_touchHandler);
				}
			}
		}
		if (this.accessoryLabel != null)
		{
			this.accessoryLabel.fontStyles = this._accessoryLabelFontStylesSet;
			//var displayAccessoryLabel:DisplayObject = cast this.accessoryLabel;
			//for(var propertyName:String in this._accessoryLabelProperties)
			//{
				//var propertyValue:Object = this._accessoryLabelProperties[propertyName];
				//displayAccessoryLabel[propertyName] = propertyValue;
			//}
			var propertyValue:Dynamic;
			for (propertyName in this._iconLabelProperties)
			{
				propertyValue = this._iconLabelProperties[propertyName];
				Reflect.setProperty(this.accessoryLabel, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function getCurrentAccessory():DisplayObject
	{
		//we use the currentState getter here instead of the variable
		//because the variable does not keep track of the selection
		var result:DisplayObject = this._stateToAccessory[this.currentState];
		if (result != null)
		{
			return result;
		}
		return this._defaultAccessory;
	}
	
	/**
	 * @private
	 */
	private function refreshIconSource(source:Dynamic):Void
	{
		if (this.iconLoader == null)
		{
			this.iconLoader = this._iconLoaderFactory();
			this.iconLoader.addEventListener(Event.COMPLETE, loader_completeOrErrorHandler);
			this.iconLoader.addEventListener(Event.IO_ERROR, loader_completeOrErrorHandler);
			this.iconLoader.addEventListener(Event.SECURITY_ERROR, loader_completeOrErrorHandler);
			var iconLoaderStyleName:String = this._customIconLoaderStyleName != null ? this._customIconLoaderStyleName : this.iconLoaderStyleName;
			this.iconLoader.styleNameList.add(iconLoaderStyleName);
		}
		this.iconLoader.source = source;
	}
	
	/**
	 * @private
	 */
	private function refreshIconLabel(label:String):Void
	{
		if (this.iconLabel == null)
		{
			var factory:Function = this._iconLabelFactory != null ? this._iconLabelFactory : FeathersControl.defaultTextRendererFactory;
			this.iconLabel = cast factory();
			if (Std.isOfType(this.iconLabel, IStateObserver))
			{
				cast(this.iconLabel, IStateObserver).stateContext = this;
			}
			var iconLabelStyleName:String = this._customIconLabelStyleName != null ? this._customIconLabelStyleName : this.iconLabelStyleName;
			this.iconLabel.styleNameList.add(iconLabelStyleName);
		}
		this.iconLabel.text = label;
	}
	
	/**
	 * @private
	 */
	private function refreshAccessorySource(source:Dynamic):Void
	{
		if (this.accessoryLoader == null)
		{
			this.accessoryLoader = this._accessoryLoaderFactory();
			this.accessoryLoader.addEventListener(Event.COMPLETE, loader_completeOrErrorHandler);
			this.accessoryLoader.addEventListener(Event.IO_ERROR, loader_completeOrErrorHandler);
			this.accessoryLoader.addEventListener(Event.SECURITY_ERROR, loader_completeOrErrorHandler);
			var accessoryLoaderStyleName:String = this._customAccessoryLoaderStyleName != null ? this._customAccessoryLoaderStyleName : this.accessoryLoaderStyleName;
			this.accessoryLoader.styleNameList.add(accessoryLoaderStyleName);
		}
		this.accessoryLoader.source = source;
	}
	
	/**
	 * @private
	 */
	private function refreshAccessoryLabel(label:String):Void
	{
		if (this.accessoryLabel == null)
		{
			var factory:Function = this._accessoryLabelFactory != null ? this._accessoryLabelFactory : FeathersControl.defaultTextRendererFactory;
			this.accessoryLabel = factory();
			if (Std.isOfType(this.accessoryLabel, IStateObserver))
			{
				cast(this.accessoryLabel, IStateObserver).stateContext = this;
			}
			var accessoryLabelStyleName:String = this._customAccessoryLabelStyleName != null ? this._customAccessoryLabelStyleName : this.accessoryLabelStyleName;
			this.accessoryLabel.styleNameList.add(accessoryLabelStyleName);
		}
		this.accessoryLabel.text = label;
	}
	
	/**
	 * @private
	 */
	private function refreshSkinSource(source:Dynamic):Void
	{
		if (this.skinLoader == null)
		{
			this.skinLoader = this._skinLoaderFactory();
			this.skinLoader.addEventListener(Event.COMPLETE, loader_completeOrErrorHandler);
			this.skinLoader.addEventListener(FeathersEventType.ERROR, loader_completeOrErrorHandler);
		}
		this.skinLoader.source = source;
	}
	
	/**
	 * @private
	 */
	override function layoutContent():Void
	{
		var oldIgnoreAccessoryResizes:Bool = this._ignoreAccessoryResizes;
		this._ignoreAccessoryResizes = true;
		var oldIgnoreIconResizes:Bool = this._ignoreIconResizes;
		this._ignoreIconResizes = true;
		this.refreshLabelTextRendererDimensions(false);
		var labelRenderer:DisplayObject = null;
		if (this._label != null && this.labelTextRenderer != null)
		{
			labelRenderer = cast this.labelTextRenderer;
		}
		var iconIsInLayout:Bool = this.currentIcon != null && this._iconPosition != RelativePosition.MANUAL;
		var accessoryIsInLayout:Bool = this.currentAccessory != null && this._accessoryPosition != RelativePosition.MANUAL;
		var accessoryGap:Float = this._accessoryGap;
		if (accessoryGap != accessoryGap) //isNaN
		{
			accessoryGap = this._gap;
		}
		if (labelRenderer != null && iconIsInLayout && accessoryIsInLayout)
		{
			this.positionSingleChild(labelRenderer);
			if (this._layoutOrder == ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON)
			{
				this.positionRelativeToOthers(this.currentAccessory, labelRenderer, null, this._accessoryPosition, accessoryGap, null, 0);
				var iconPosition:String = this._iconPosition;
				if (iconPosition == RelativePosition.LEFT_BASELINE)
				{
					iconPosition = RelativePosition.LEFT;
				}
				else if (iconPosition == RelativePosition.RIGHT_BASELINE)
				{
					iconPosition = RelativePosition.RIGHT;
				}
				this.positionRelativeToOthers(this.currentIcon, labelRenderer, this.currentAccessory, iconPosition, this._gap, this._accessoryPosition, accessoryGap);
			}
			else
			{
				this.positionLabelAndIcon();
				this.positionRelativeToOthers(this.currentAccessory, labelRenderer, this.currentIcon, this._accessoryPosition, accessoryGap, this._iconPosition, this._gap);
			}
		}
		else if (labelRenderer != null)
		{
			this.positionSingleChild(labelRenderer);
			//we won't position both the icon and accessory here, otherwise
			//we would have gone into the previous conditional
			if (iconIsInLayout)
			{
				this.positionLabelAndIcon();
			}
			else if (accessoryIsInLayout)
			{
				this.positionRelativeToOthers(this.currentAccessory, labelRenderer, null, this._accessoryPosition, accessoryGap, null, 0);
			}
		}
		else if (iconIsInLayout)
		{
			this.positionSingleChild(this.currentIcon);
			if (accessoryIsInLayout)
			{
				this.positionRelativeToOthers(this.currentAccessory, this.currentIcon, null, this._accessoryPosition, accessoryGap, null, 0);
			}
		}
		else if (accessoryIsInLayout)
		{
			this.positionSingleChild(this.currentAccessory);
		}
		
		if (this.currentAccessory != null)
		{
			if (!accessoryIsInLayout)
			{
				this.currentAccessory.x = this._leftOffset;
				this.currentAccessory.y = this._topOffset;
			}
			this.currentAccessory.x += this._accessoryOffsetX;
			this.currentAccessory.y += this._accessoryOffsetY;
		}
		if (this.currentIcon != null)
		{
			if (!iconIsInLayout)
			{
				this.currentIcon.x = this._leftOffset;
				this.currentIcon.y = this._topOffset;
			}
			this.currentIcon.x += this._iconOffsetX;
			this.currentIcon.y += this._iconOffsetY;
		}
		if (labelRenderer != null)
		{
			this.labelTextRenderer.x += this._labelOffsetX;
			this.labelTextRenderer.y += this._labelOffsetY;
		}
		this._ignoreIconResizes = oldIgnoreIconResizes;
		this._ignoreAccessoryResizes = oldIgnoreAccessoryResizes;
	}
	
	/**
	 * @private
	 */
	private function refreshOffsets():Void
	{
		this._topOffset = this._paddingTop;
		this._rightOffset = this._paddingRight;
		this._bottomOffset = this._paddingBottom;
		this._leftOffset = this._paddingLeft;
	}
	
	/**
	 * @private
	 */
	override function refreshLabelTextRendererDimensions(forMeasurement:Bool):Void
	{
		var oldIgnoreIconResizes:Bool = this._ignoreIconResizes;
		this._ignoreIconResizes = true;
		var calculatedWidth:Float = this.actualWidth;
		if (forMeasurement)
		{
			calculatedWidth = this._explicitWidth;
			if (calculatedWidth != calculatedWidth) //isNaN
			{
				calculatedWidth = this._explicitMaxWidth;
			}
		}
		calculatedWidth -= (this._leftOffset + this._rightOffset);
		var calculatedHeight:Float = this.actualHeight;
		if (forMeasurement)
		{
			calculatedHeight = this._explicitHeight;
			if (calculatedHeight != calculatedHeight) //isNaN
			{
				calculatedHeight = this._explicitMaxHeight;
			}
		}
		calculatedHeight -= (this._topOffset + this._bottomOffset);

		var adjustedGap:Float = this._gap;
		if (adjustedGap == Math.POSITIVE_INFINITY)
		{
			adjustedGap = this._minGap;
		}
		var adjustedAccessoryGap:Float = this._accessoryGap;
		if (adjustedAccessoryGap != adjustedAccessoryGap) //isNaN
		{
			adjustedAccessoryGap = this._gap;
		}
		if (adjustedAccessoryGap == Math.POSITIVE_INFINITY)
		{
			adjustedAccessoryGap = this._minAccessoryGap;
			if (adjustedAccessoryGap != adjustedAccessoryGap) //isNaN
			{
				adjustedAccessoryGap = this._minGap;
			}
		}
		
		var hasIconToLeftOrRight:Bool = this.currentIcon != null && (this._iconPosition == RelativePosition.LEFT || this._iconPosition == RelativePosition.LEFT_BASELINE ||
			this._iconPosition == RelativePosition.RIGHT || this._iconPosition == RelativePosition.RIGHT_BASELINE);
		var hasIconToTopOrBottom:Bool = this.currentIcon != null && (this._iconPosition == RelativePosition.TOP || this._iconPosition == RelativePosition.BOTTOM);
		var hasAccessoryToLeftOrRight:Bool = this.currentAccessory != null && (this._accessoryPosition == RelativePosition.LEFT || this._accessoryPosition == RelativePosition.RIGHT);
		var hasAccessoryToTopOrBottom:Bool = this.currentAccessory != null && (this._accessoryPosition == RelativePosition.TOP || this._accessoryPosition == RelativePosition.BOTTOM);
		
		if (this.accessoryLabel != null)
		{
			var iconAffectsAccessoryLabelMaxWidth:Bool = hasIconToLeftOrRight &&
				(hasAccessoryToLeftOrRight || this._layoutOrder == ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON);
			if (this.iconLabel != null)
			{
				this.iconLabel.maxWidth = calculatedWidth - adjustedGap;
				if (this.iconLabel.maxWidth < 0)
				{
					this.iconLabel.maxWidth = 0;
				}
			}
			if (Std.isOfType(this.currentIcon, IValidating))
			{
				cast(this.currentIcon, IValidating).validate();
			}
			if (iconAffectsAccessoryLabelMaxWidth)
			{
				calculatedWidth -= (this.currentIcon.width + adjustedGap);
			}
			if (calculatedWidth < 0)
			{
				calculatedWidth = 0;
			}
			this.accessoryLabel.maxWidth = calculatedWidth;
			this.accessoryLabel.maxHeight = calculatedHeight;
			if (hasIconToLeftOrRight && this.currentIcon != null && !iconAffectsAccessoryLabelMaxWidth)
			{
				calculatedWidth -= (this.currentIcon.width + adjustedGap);
			}
			if (Std.isOfType(this.currentAccessory, IValidating))
			{
				cast(this.currentAccessory, IValidating).validate();
			}
			if (hasAccessoryToLeftOrRight)
			{
				calculatedWidth -= (this.currentAccessory.width + adjustedAccessoryGap);
			}
			if (hasAccessoryToTopOrBottom)
			{
				calculatedHeight -= (this.currentAccessory.height + adjustedAccessoryGap);
			}
		}
		else if (this.iconLabel != null)
		{
			var accessoryAffectsIconLabelMaxWidth:Bool = hasAccessoryToLeftOrRight &&
				(hasIconToLeftOrRight || this._layoutOrder == ItemRendererLayoutOrder.LABEL_ICON_ACCESSORY);
			if (Std.isOfType(this.currentAccessory, IValidating))
			{
				cast(this.currentAccessory, IValidating).validate();
			}
			if (accessoryAffectsIconLabelMaxWidth)
			{
				calculatedWidth -= (adjustedAccessoryGap + this.currentAccessory.width);
			}
			if (calculatedWidth < 0)
			{
				calculatedWidth = 0;
			}
			this.iconLabel.maxWidth = calculatedWidth;
			this.iconLabel.maxHeight = calculatedHeight;
			if (hasAccessoryToLeftOrRight && this.currentAccessory != null && !accessoryAffectsIconLabelMaxWidth)
			{
				calculatedWidth -= (adjustedAccessoryGap + this.currentAccessory.width);
			}
			if (Std.isOfType(this.currentIcon, IValidating))
			{
				cast(this.currentIcon, IValidating).validate();
			}
			if (hasIconToLeftOrRight)
			{
				calculatedWidth -= (this.currentIcon.width + adjustedGap);
			}
			if (hasIconToTopOrBottom)
			{
				calculatedHeight -= (this.currentIcon.height + adjustedGap);
			}
		}
		else
		{
			if (Std.isOfType(this.currentIcon, IValidating))
			{
				cast(this.currentIcon, IValidating).validate();
			}
			if (hasIconToLeftOrRight)
			{
				calculatedWidth -= (adjustedGap + this.currentIcon.width);
			}
			if (hasIconToTopOrBottom)
			{
				calculatedHeight -= (adjustedGap + this.currentIcon.height);
			}
			if (Std.isOfType(this.currentAccessory, IValidating))
			{
				cast(this.currentAccessory, IValidating).validate();
			}
			if (hasAccessoryToLeftOrRight)
			{
				calculatedWidth -= (adjustedAccessoryGap + this.currentAccessory.width);
			}
			if (hasAccessoryToTopOrBottom)
			{
				calculatedHeight -= (adjustedAccessoryGap + this.currentAccessory.height);
			}
		}
		if (calculatedWidth < 0)
		{
			calculatedWidth = 0;
		}
		if (calculatedHeight < 0)
		{
			calculatedHeight = 0;
		}
		if (calculatedWidth > this._explicitLabelMaxWidth)
		{
			calculatedWidth = this._explicitLabelMaxWidth;
		}
		if (calculatedHeight > this._explicitLabelMaxHeight)
		{
			calculatedHeight = this._explicitLabelMaxHeight;
		}
		if (this.labelTextRenderer != null)
		{
			this.labelTextRenderer.width = this._explicitLabelWidth;
			this.labelTextRenderer.height = this._explicitLabelHeight;
			this.labelTextRenderer.minWidth = this._explicitLabelMinWidth;
			this.labelTextRenderer.minHeight = this._explicitLabelMinHeight;
			this.labelTextRenderer.maxWidth = calculatedWidth;
			this.labelTextRenderer.maxHeight = calculatedHeight;
			this.labelTextRenderer.validate();
			if (!forMeasurement)
			{
				calculatedWidth = this.labelTextRenderer.width;
				calculatedHeight = this.labelTextRenderer.height;
				//setting all of these dimensions explicitly means that the
				//text renderer won't measure itself again when it
				//validates, which helps performance. we'll reset them when
				//the item renderer needs to measure itself.
				this.labelTextRenderer.width = calculatedWidth;
				this.labelTextRenderer.height = calculatedHeight;
				this.labelTextRenderer.minWidth = calculatedWidth;
				this.labelTextRenderer.minHeight = calculatedHeight;
			}
		}
		this._ignoreIconResizes = oldIgnoreIconResizes;
	}
	
	/**
	 * @private
	 */
	override function positionSingleChild(displayObject:DisplayObject):Void
	{
		if (this._horizontalAlign == HorizontalAlign.LEFT)
		{
			displayObject.x = this._leftOffset;
		}
		else if (this._horizontalAlign == HorizontalAlign.RIGHT)
		{
			displayObject.x = this.actualWidth - this._rightOffset - displayObject.width;
		}
		else //center
		{
			displayObject.x = this._leftOffset + Math.fround((this.actualWidth - this._leftOffset - this._rightOffset - displayObject.width) / 2);
		}
		if (this._verticalAlign == VerticalAlign.TOP)
		{
			displayObject.y = this._topOffset;
		}
		else if (this._verticalAlign == VerticalAlign.BOTTOM)
		{
			displayObject.y = this.actualHeight - this._bottomOffset - displayObject.height;
		}
		else //middle
		{
			displayObject.y = this._topOffset + Math.fround((this.actualHeight - this._topOffset - this._bottomOffset - displayObject.height) / 2);
		}
	}
	
	/**
	 * @private
	 */
	private function positionRelativeToOthers(object:DisplayObject, relativeTo:DisplayObject, relativeTo2:DisplayObject, position:String, gap:Float, otherPosition:String, otherGap:Float):Void
	{
		var relativeToX:Float = relativeTo.x;
		if (relativeTo2 != null && relativeTo2.x < relativeToX)
		{
			relativeToX = relativeTo2.x;
		}
		var relativeToY:Float = relativeTo.y;
		if (relativeTo2 != null && relativeTo2.y < relativeToY)
		{
			relativeToY = relativeTo2.y;
		}
		var relativeToWidth:Float = relativeTo.width;
		if (relativeTo2 != null)
		{
			relativeToWidth = relativeTo.x + relativeTo.width;
			var relativeToWidth2:Float = relativeTo2.x + relativeTo2.width;
			if (relativeToWidth2 > relativeToWidth)
			{
				relativeToWidth = relativeToWidth2;
			}
			relativeToWidth -= relativeToX;
		}
		var relativeToHeight:Float = relativeTo.height;
		if (relativeTo2 != null)
		{
			relativeToHeight = relativeTo.y + relativeTo.height;
			var relativeToHeight2:Float = relativeTo2.y + relativeTo2.height;
			if (relativeToHeight2 > relativeToHeight)
			{
				relativeToHeight = relativeToHeight2;
			}
			relativeToHeight -= relativeToY;
		}
		var newRelativeToX:Float = relativeToX;
		var newRelativeToY:Float = relativeToY;
		var newRelativeToX2:Float;
		var newRelativeToY2:Float;
		if (position == RelativePosition.TOP)
		{
			if (gap == Math.POSITIVE_INFINITY)
			{
				object.y = this._topOffset;
				newRelativeToY = this.actualHeight - this._bottomOffset - relativeToHeight;
			}
			else
			{
				if (this._verticalAlign == VerticalAlign.TOP)
				{
					newRelativeToY += object.height + gap;
				}
				else if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					newRelativeToY += Math.fround((object.height + gap) / 2);
				}
				if (relativeTo2 != null)
				{
					newRelativeToY2 = this._topOffset + object.height + gap;
					if (newRelativeToY2 > newRelativeToY)
					{
						newRelativeToY = newRelativeToY2;
					}
				}
				object.y = newRelativeToY - object.height - gap;
			}
		}
		else if (position == RelativePosition.RIGHT)
		{
			if (gap == Math.POSITIVE_INFINITY)
			{
				newRelativeToX = this._leftOffset;
				object.x = this.actualWidth - this._rightOffset - object.width;
			}
			else
			{
				if (this._horizontalAlign == HorizontalAlign.RIGHT)
				{
					newRelativeToX -= (object.width + gap);
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					newRelativeToX -= Math.fround((object.width + gap) / 2);
				}
				if (relativeTo2 != null)
				{
					newRelativeToX2 = this.actualWidth - this._rightOffset - object.width - relativeToWidth - gap;
					if (newRelativeToX2 < newRelativeToX)
					{
						newRelativeToX = newRelativeToX2;
					}
				}
				object.x = newRelativeToX + relativeToWidth + gap;
			}
		}
		else if (position == RelativePosition.BOTTOM)
		{
			if (gap == Math.POSITIVE_INFINITY)
			{
				newRelativeToY = this._topOffset;
				object.y = this.actualHeight - this._bottomOffset - object.height;
			}
			else
			{
				if (this._verticalAlign == VerticalAlign.BOTTOM)
				{
					newRelativeToY -= (object.height + gap);
				}
				else if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					newRelativeToY -= Math.fround((object.height + gap) / 2);
				}
				if (relativeTo2 != null)
				{
					newRelativeToY2 = this.actualHeight - this._bottomOffset - object.height - relativeToHeight - gap;
					if (newRelativeToY2 < newRelativeToY)
					{
						newRelativeToY = newRelativeToY2;
					}
				}
				object.y = newRelativeToY + relativeToHeight + gap;
			}
		}
		else if (position == RelativePosition.LEFT)
		{
			if (gap == Math.POSITIVE_INFINITY)
			{
				object.x = this._leftOffset;
				newRelativeToX = this.actualWidth - this._rightOffset - relativeToWidth;
			}
			else
			{
				if (this._horizontalAlign == HorizontalAlign.LEFT)
				{
					newRelativeToX += gap + object.width;
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					newRelativeToX += Math.fround((gap + object.width) / 2);
				}
				if (relativeTo2 != null)
				{
					newRelativeToX2 = this._leftOffset + object.width + gap;
					if (newRelativeToX2 > newRelativeToX)
					{
						newRelativeToX = newRelativeToX2;
					}
				}
				object.x = newRelativeToX - gap - object.width;
			}
		}

		var offsetX:Float = newRelativeToX - relativeToX;
		var offsetY:Float = newRelativeToY - relativeToY;
		if (relativeTo2 == null || otherGap != Math.POSITIVE_INFINITY || !(
			(position == RelativePosition.TOP && otherPosition == RelativePosition.TOP) ||
			(position == RelativePosition.RIGHT && otherPosition == RelativePosition.RIGHT) ||
			(position == RelativePosition.BOTTOM && otherPosition == RelativePosition.BOTTOM) ||
			(position == RelativePosition.LEFT && otherPosition == RelativePosition.LEFT)
		))
		{
			relativeTo.x += offsetX;
			relativeTo.y += offsetY;
		}
		if (relativeTo2 != null)
		{
			if (otherGap != Math.POSITIVE_INFINITY || !(
				(position == RelativePosition.LEFT && otherPosition == RelativePosition.RIGHT) ||
				(position == RelativePosition.RIGHT && otherPosition == RelativePosition.LEFT) ||
				(position == RelativePosition.TOP && otherPosition == RelativePosition.BOTTOM) ||
				(position == RelativePosition.BOTTOM && otherPosition == RelativePosition.TOP)
			))
			{
				relativeTo2.x += offsetX;
				relativeTo2.y += offsetY;
			}
			if (gap == Math.POSITIVE_INFINITY && otherGap == Math.POSITIVE_INFINITY)
			{
				if (position == RelativePosition.RIGHT && otherPosition == RelativePosition.LEFT)
				{
					relativeTo.x = relativeTo2.x + Math.fround((object.x - relativeTo2.x + relativeTo2.width - relativeTo.width) / 2);
				}
				else if (position == RelativePosition.LEFT && otherPosition == RelativePosition.RIGHT)
				{
					relativeTo.x = object.x + Math.fround((relativeTo2.x - object.x + object.width - relativeTo.width) / 2);
				}
				else if (position == RelativePosition.RIGHT && otherPosition == RelativePosition.RIGHT)
				{
					relativeTo2.x = relativeTo.x + Math.fround((object.x - relativeTo.x + relativeTo.width - relativeTo2.width) / 2);
				}
				else if (position == RelativePosition.LEFT && otherPosition == RelativePosition.LEFT)
				{
					relativeTo2.x = object.x + Math.fround((relativeTo.x - object.x + object.width - relativeTo2.width) / 2);
				}
				else if (position == RelativePosition.BOTTOM && otherPosition == RelativePosition.TOP)
				{
					relativeTo.y = relativeTo2.y + Math.fround((object.y - relativeTo2.y + relativeTo2.height - relativeTo.height) / 2);
				}
				else if (position == RelativePosition.TOP && otherPosition == RelativePosition.BOTTOM)
				{
					relativeTo.y = object.y + Math.fround((relativeTo2.y - object.y + object.height - relativeTo.height) / 2);
				}
				else if (position == RelativePosition.BOTTOM && otherPosition == RelativePosition.BOTTOM)
				{
					relativeTo2.y = relativeTo.y + Math.fround((object.y - relativeTo.y + relativeTo.height - relativeTo2.height) / 2);
				}
				else if (position == RelativePosition.TOP && otherPosition == RelativePosition.TOP)
				{
					relativeTo2.y = object.y + Math.fround((relativeTo.y - object.y + object.height - relativeTo2.height) / 2);
				}
			}
		}
		
		if (position == RelativePosition.LEFT || position == RelativePosition.RIGHT)
		{
			if (this._verticalAlign == VerticalAlign.TOP)
			{
				object.y = this._topOffset;
			}
			else if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				object.y = this.actualHeight - this._bottomOffset - object.height;
			}
			else //middle
			{
				object.y = this._topOffset + Math.fround((this.actualHeight - this._topOffset - this._bottomOffset - object.height) / 2);
			}
		}
		else if (position == RelativePosition.TOP || position == RelativePosition.BOTTOM)
		{
			if (this._horizontalAlign == HorizontalAlign.LEFT)
			{
				object.x = this._leftOffset;
			}
			else if (this._horizontalAlign == HorizontalAlign.RIGHT)
			{
				object.x = this.actualWidth - this._rightOffset - object.width;
			}
			else //center
			{
				object.x = this._leftOffset + Math.fround((this.actualWidth - this._leftOffset - this._rightOffset - object.width) / 2);
			}
		}
	}
	
	/**
	 * @private
	 */
	override function refreshSelectionEvents():Void
	{
		var selectionEnabled:Bool = this._isEnabled &&
			(this._isToggle || this.isSelectableWithoutToggle);
		if (this._itemHasSelectable)
		{
			selectionEnabled = selectionEnabled && this.itemToSelectable(this._data);
		}
		if (this.accessoryTouchPointID != -1)
		{
			selectionEnabled = selectionEnabled && this._isSelectableOnAccessoryTouch;
		}
		this.tapToSelect.isEnabled = selectionEnabled;
		this.tapToSelect.tapToDeselect = this._isToggle;
		this.keyToSelect.isEnabled = false;
	}
	
	/**
	 * @private
	 */
	private function hitTestWithAccessory(localPosition:Point):Bool
	{
		if (this._isQuickHitAreaEnabled ||
			this._isSelectableOnAccessoryTouch ||
			this.currentAccessory == null ||
			this.currentAccessory == SafeCast.safe_cast(this.accessoryLabel, DisplayObject) ||
			this.currentAccessory == SafeCast.safe_cast(this.accessoryLoader, DisplayObject))
		{
			return true;
		}
		if (Std.isOfType(this.currentAccessory, DisplayObjectContainer))
		{
			var container:DisplayObjectContainer = cast this.currentAccessory;
			return !container.contains(this.hitTest(localPosition));
		}
		return this.hitTest(localPosition) != this.currentAccessory;
	}
	
	/**
	 * @private
	 */
	private function owner_scrollStartHandler(event:Event):Void
	{
		if (this._delayTextureCreationOnScroll)
		{
			if (this.accessoryLoader != null)
			{
				this.accessoryLoader.delayTextureCreation = true;
			}
			if (this.iconLoader != null)
			{
				this.iconLoader.delayTextureCreation = true;
			}
		}
		
		if (this.accessoryTouchPointID != -1)
		{
			this._owner.stopScrolling();
		}
	}
	
	/**
	 * @private
	 */
	private function owner_scrollCompleteHandler(event:Event):Void
	{
		if (this._delayTextureCreationOnScroll)
		{
			if (this.accessoryLoader != null)
			{
				this.accessoryLoader.delayTextureCreation = false;
			}
			if (this.iconLoader != null)
			{
				this.iconLoader.delayTextureCreation = false;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function itemRenderer_removedFromStageHandler(event:Event):Void
	{
		this.accessoryTouchPointID = -1;
	}
	
	/**
	 * @private
	 */
	private function accessory_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this.accessoryTouchPointID = -1;
			return;
		}
		if (!this._stopScrollingOnAccessoryTouch ||
			this.currentAccessory == SafeCast.safe_cast(this.accessoryLabel, DisplayObject) ||
			this.currentAccessory == SafeCast.safe_cast(this.accessoryLoader, DisplayObject))
		{
			//do nothing
			return;
		}
		
		var touch:Touch;
		if (this.accessoryTouchPointID != -1)
		{
			touch = event.getTouch(this.currentAccessory, TouchPhase.ENDED, this.accessoryTouchPointID);
			if (touch == null)
			{
				return;
			}
			this.accessoryTouchPointID = -1;
			this.refreshSelectionEvents();
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this.currentAccessory, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this.accessoryTouchPointID = touch.id;
			this.refreshSelectionEvents();
		}
	}
	
	/**
	 * @private
	 */
	private function accessory_resizeHandler(event:Event):Void
	{
		if (this._ignoreAccessoryResizes)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function loader_completeOrErrorHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
}