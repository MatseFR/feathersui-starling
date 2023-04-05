/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.supportClasses;

import feathers.controls.GroupedList;
import feathers.controls.renderers.IGroupedListFooterRenderer;
import feathers.controls.renderers.IGroupedListHeaderRenderer;
import feathers.controls.renderers.IGroupedListItemRenderer;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.core.PropertyProxyReal;
import feathers.data.IHierarchicalCollection;
import feathers.events.CollectionEventType;
import feathers.events.FeathersEventType;
import feathers.layout.IGroupedLayout;
import feathers.layout.ILayout;
import feathers.layout.IVariableVirtualLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.ViewPortBounds;
import feathers.utils.type.ArgumentsCount;
import feathers.utils.type.Property;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.utils.Pool;

/**
 * @private
 * Used internally by GroupedList. Not meant to be used on its own.
 *
 * @productversion Feathers 1.0.0
 */
class GroupedListDataViewPort extends FeathersControl implements IViewPort
{
	private static inline var INVALIDATION_FLAG_ITEM_RENDERER_FACTORY:String = "itemRendererFactory";
	
	private static inline var FIRST_ITEM_RENDERER_FACTORY_ID:String = "GroupedListDataViewPort-first";
	private static inline var SINGLE_ITEM_RENDERER_FACTORY_ID:String = "GroupedListDataViewPort-single";
	private static inline var LAST_ITEM_RENDERER_FACTORY_ID:String = "GroupedListDataViewPort-last";
	
	private static var HELPER_VECTOR:Array<Int> = new Array<Int>();
	private static var LOCATION_HELPER_VECTOR:Array<Int> = new Array<Int>();
	
	public function new() 
	{
		super();
	}
	
	private var _viewPortBounds:ViewPortBounds = new ViewPortBounds();
	
	private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
	
	private var _actualMinVisibleWidth:Float = 0;
	
	private var _explicitMinVisibleWidth:Float;
	
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
			if (this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
				(this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue))
			{
				//only invalidate if this change might affect the visibleWidth
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
		return value;
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
	
	private var _actualVisibleWidth:Float;
	
	private var _explicitVisibleWidth:Float;
	
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

	private var _explicitMinVisibleHeight:Float;
	
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
		if(valueIsNaN &&
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
	
	private var _actualVisibleHeight:Float;

	private var _explicitVisibleHeight:Float;
	
	public var visibleHeight(get, set):Float;
	private function get_visibleHeight():Float { return this._actualVisibleHeight; }
	private function set_visibleHeight(value:Float):Float
	{
		if (this._explicitVisibleHeight == value ||
			(value != value && this._explicitVisibleHeight != this._explicitVisibleHeight)) //isNaN
		{
			return value;
		}
		this._explicitVisibleHeight = value;
		if (this._actualVisibleHeight != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._actualVisibleHeight;
	}
	
	public var contentX(get, never):Float;
	private var _contentX:Float = 0;
	private function get_contentX():Float { return this._contentX; }
	
	public var contentY(get, never):Float;
	private var _contentY:Float = 0;
	private function get_contentY():Float { return this._contentY; }
	
	public var horizontalScrollStep(get, never):Float;
	private function get_horizontalScrollStep():Float
	{
		var itemRenderer:DisplayObject = null;
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			if (this._layoutItems.length != 0)
			{
				itemRenderer = this._layoutItems[0];
			}
		}
		if (itemRenderer == null)
		{
			itemRenderer = this._typicalItemRenderer != null ? cast this._typicalItemRenderer : null;
		}
		if (itemRenderer == null)
		{
			return 0;
		}
		var itemRendererWidth:Float = itemRenderer.width;
		var itemRendererHeight:Float = itemRenderer.height;
		if (itemRendererWidth < itemRendererHeight)
		{
			return itemRendererWidth;
		}
		return itemRendererHeight;
	}
	
	public var verticalScrollStep(get, never):Float;
	private function get_verticalScrollStep():Float
	{
		var itemRenderer:DisplayObject = null;
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			if (this._layoutItems.length != 0)
			{
				itemRenderer = this._layoutItems[0];
			}
		}
		if (itemRenderer == null)
		{
			itemRenderer = this._typicalItemRenderer != null ? cast this._typicalItemRenderer : null;
		}
		if (itemRenderer == null)
		{
			return 0;
		}
		var itemRendererWidth:Float = itemRenderer.width;
		var itemRendererHeight:Float = itemRenderer.height;
		if (itemRendererWidth < itemRendererHeight)
		{
			return itemRendererWidth;
		}
		return itemRendererHeight;
	}
	
	private var _layoutItems:Array<DisplayObject> = new Array<DisplayObject>();
	
	private var _typicalItemIsInDataProvider:Bool = false;
	private var _typicalItemRenderer:IGroupedListItemRenderer;
	
	private var _unrenderedItems:Array<Int> = new Array<Int>();
	private var _defaultItemRendererStorage:GroupItemRendererFactoryStorage = new GroupItemRendererFactoryStorage();
	private var _itemStorageMap:Map<String, GroupItemRendererFactoryStorage> = new Map<String, GroupItemRendererFactoryStorage>();
	
	private var _itemObjectRendererMap:ObjectMap<Dynamic, IGroupedListItemRenderer> = new ObjectMap<Dynamic, IGroupedListItemRenderer>();
	private var _itemIntRendererMap:IntMap<IGroupedListItemRenderer> = new IntMap<IGroupedListItemRenderer>();
	private var _itemStringRendererMap:StringMap<IGroupedListItemRenderer> = new StringMap<IGroupedListItemRenderer>();
	
	private var _unrenderedHeaders:Array<Int> = new Array<Int>();
	private var _defaultHeaderRendererStorage:HeaderRendererFactoryStorage = new HeaderRendererFactoryStorage();
	private var _headerStorageMap:Map<String, HeaderRendererFactoryStorage> = new Map<String, HeaderRendererFactoryStorage>();
	
	private var _headerObjectRendererMap:ObjectMap<Dynamic, IGroupedListHeaderRenderer> = new ObjectMap<Dynamic, IGroupedListHeaderRenderer>();
	private var _headerIntRendererMap:IntMap<IGroupedListHeaderRenderer> = new IntMap<IGroupedListHeaderRenderer>();
	private var _headerStringRendererMap:StringMap<IGroupedListHeaderRenderer> = new StringMap<IGroupedListHeaderRenderer>();
	
	private var _unrenderedFooters:Array<Int> = new Array<Int>();
	private var _defaultFooterRendererStorage:FooterRendererFactoryStorage = new FooterRendererFactoryStorage();
	private var _footerStorageMap:Map<String, FooterRendererFactoryStorage> = new Map<String, FooterRendererFactoryStorage>();
	
	private var _footerObjectRendererMap:ObjectMap<Dynamic, IGroupedListFooterRenderer> = new ObjectMap<Dynamic, IGroupedListFooterRenderer>();
	private var _footerIntRendererMap:IntMap<IGroupedListFooterRenderer> = new IntMap<IGroupedListFooterRenderer>();
	private var _footerStringRendererMap:StringMap<IGroupedListFooterRenderer> = new StringMap<IGroupedListFooterRenderer>();
	
	private var _headerIndices:Array<Int> = new Array<Int>();
	private var _footerIndices:Array<Int> = new Array<Int>();
	
	public var owner(get, set):GroupedList;
	private var _owner:GroupedList;
	private function get_owner():GroupedList { return this._owner; }
	private function set_owner(value:GroupedList):GroupedList
	{
		return this._owner = value;
	}
	
	private var _updateForDataReset:Bool = false;
	
	public var dataProvider(get, set):IHierarchicalCollection;
	private var _dataProvider:IHierarchicalCollection;
	private function get_dataProvider():IHierarchicalCollection { return this._dataProvider; }
	private function set_dataProvider(value:IHierarchicalCollection):IHierarchicalCollection
	{
		if (this._dataProvider == value)
		{
			return value;
		}
		if (this._dataProvider != null)
		{
			this._dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
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
			this.setSelectedLocation(-1, -1);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isSelectable;
	}
	
	public var selectedGroupIndex(get, never):Int;
	private var _selectedGroupIndex:Int = -1;
	private function get_selectedGroupIndex():Int { return this._selectedGroupIndex; }
	
	public var selectedItemIndex(get, never):Int;
	private var _selectedItemIndex:Int = -1;
	private function get_selectedItemIndex():Int { return this._selectedItemIndex; }
	
	public var itemRendererType(get, set):Class<Dynamic>;
	private var _itemRendererType:Class<Dynamic>;
	private function get_itemRendererType():Class<Dynamic> { return this._itemRendererType; }
	private function set_itemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._itemRendererType == value)
		{
			return value;
		}
		
		this._itemRendererType = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererType;
	}
	
	public var itemRendererFactory(get, set):Function;
	private var _itemRendererFactory:Function;
	private function get_itemRendererFactory():Function { return this._itemRendererFactory; }
	private function set_itemRendererFactory(value:Function):Function
	{
		if (this._itemRendererFactory == value)
		{
			return value;
		}
		
		this._itemRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererFactory;
	}
	
	public var itemRendererFactories(get, set):Map<String, Function>;
	private var _itemRendererFactories:Map<String, Function>;
	private function get_itemRendererFactories():Map<String, Function> { return this._itemRendererFactories; }
	private function set_itemRendererFactories(value:Map<String, Function>):Map<String, Function>
	{
		if (this._itemRendererFactories == value)
		{
			return value;
		}
		if (this._itemRendererFactories != null)
		{
			this._itemRendererFactories.clear();
		}
		this._itemRendererFactories = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererFactories;
	}
	
	public var factoryIDFunction(get, set):Function;
	private var _factoryIDFunction:Function;
	private function get_factoryIDFunction():Function { return this._factoryIDFunction; }
	private function set_factoryIDFunction(value:Function):Function
	{
		if (this._factoryIDFunction == value)
		{
			return value;
		}
		
		this._factoryIDFunction = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._factoryIDFunction;
	}
	
	public var customItemRendererStyleName(get, set):String;
	private var _customItemRendererStyleName:String;
	private function get_customItemRendererStyleName():String { return this._customItemRendererStyleName; }
	private function set_customItemRendererStyleName(value:String):String
	{
		if (this._customItemRendererStyleName == value)
		{
			return value;
		}
		this._customItemRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._customItemRendererStyleName;
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
	
	public var itemRendererProperties(get, set):PropertyProxy;
	private var _itemRendererProperties:PropertyProxy;
	private function get_itemRendererProperties():PropertyProxy
	{
		if (this._itemRendererProperties == null)
		{
			this._itemRendererProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._itemRendererProperties;
	}
	
	private function set_itemRendererProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._itemRendererProperties == value)
		{
			return value;
		}
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.dispose();
		}
		this._itemRendererProperties = value;
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._itemRendererProperties;
	}
	
	public var firstItemRendererType(get, set):Class<Dynamic>;
	private var _firstItemRendererType:Class<Dynamic>;
	private function get_firstItemRendererType():Class<Dynamic> { return this._firstItemRendererType; }
	private function set_firstItemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._firstItemRendererType == value)
		{
			return value;
		}
		
		this._firstItemRendererType = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._firstItemRendererType;
	}
	
	public var firstItemRendererFactory(get, set):Function;
	private var _firstItemRendererFactory:Function;
	private function get_firstItemRendererFactory():Function { return this._firstItemRendererFactory; }
	private function set_firstItemRendererFactory(value:Function):Function
	{
		if (this._firstItemRendererFactory == value)
		{
			return value;
		}
		
		this._firstItemRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._firstItemRendererFactory;
	}
	
	public var customFirstItemRendererStyleName(get, set):String;
	private var _customFirstItemRendererStyleName:String;
	private function get_customFirstItemRendererStyleName():String { return this._customFirstItemRendererStyleName; }
	private function set_customFirstItemRendererStyleName(value:String):String
	{
		if (this._customFirstItemRendererStyleName == value)
		{
			return value;
		}
		this._customFirstItemRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._customFirstItemRendererStyleName;
	}
	
	public var lastItemRendererType(get, set):Class<Dynamic>;
	private var _lastItemRendererType:Class<Dynamic>;
	private function get_lastItemRendererType():Class<Dynamic> { return this._lastItemRendererType; }
	private function set_lastItemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._lastItemRendererType == value)
		{
			return value;
		}
		
		this._lastItemRendererType = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._lastItemRendererType;
	}
	
	public var lastItemRendererFactory(get, set):Function;
	private var _lastItemRendererFactory:Function;
	private function get_lastItemRendererFactory():Function { return this._lastItemRendererFactory; }
	private function set_lastItemRendererFactory(value:Function):Function
	{
		if (this._lastItemRendererFactory == value)
		{
			return value;
		}
		
		this._lastItemRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._lastItemRendererFactory;
	}
	
	public var customLastItemRendererStyleName(get, set):String;
	private var _customLastItemRendererStyleName:String;
	private function get_customLastItemRendererStyleName():String { return this._customLastItemRendererStyleName; }
	private function set_customLastItemRendererStyleName(value:String):String
	{
		if (this._customLastItemRendererStyleName == value)
		{
			return value;
		}
		this._customLastItemRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._customLastItemRendererStyleName;
	}
	
	public var singleItemRendererType(get, set):Class<Dynamic>;
	private var _singleItemRendererType:Class<Dynamic>;
	private function get_singleItemRendererType():Class<Dynamic> { return this._singleItemRendererType; }
	private function set_singleItemRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._singleItemRendererType == value)
		{
			return value;
		}
		
		this._singleItemRendererType = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._singleItemRendererType;
	}
	
	public var singleItemRendererFactory(get, set):Function;
	private var _singleItemRendererFactory:Function;
	private function get_singleItemRendererFactory():Function { return this._singleItemRendererFactory; }
	private function set_singleItemRendererFactory(value:Function):Function
	{
		if (this._singleItemRendererFactory == value)
		{
			return value;
		}
		
		this._singleItemRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._singleItemRendererFactory;
	}
	
	public var customSingleItemRendererStyleName(get, set):String;
	private var _customSingleItemRendererStyleName:String;
	private function get_customSingleItemRendererStyleName():String { return this._customSingleItemRendererStyleName; }
	private function set_customSingleItemRendererStyleName(value:String):String
	{
		if (this._customSingleItemRendererStyleName == value)
		{
			return value;
		}
		this._customSingleItemRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._customSingleItemRendererStyleName;
	}
	
	public var headerRendererType(get, set):Class<Dynamic>;
	private var _headerRendererType:Class<Dynamic>;
	private function get_headerRendererType():Class<Dynamic> { return this._headerRendererType; }
	private function set_headerRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._headerRendererType == value)
		{
			return value;
		}
		
		this._headerRendererType = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._headerRendererType;
	}
	
	public var headerRendererFactory(get, set):Function;
	private var _headerRendererFactory:Function;
	private function get_headerRendererFactory():Function { return this._headerRendererFactory; }
	private function set_headerRendererFactory(value:Function):Function
	{
		if (this._headerRendererFactory == value)
		{
			return value;
		}
		
		this._headerRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._headerRendererFactory;
	}
	
	public var headerRendererFactories(get, set):Map<String, Function>;
	private var _headerRendererFactories:Map<String, Function>;
	private function get_headerRendererFactories():Map<String, Function> { return this._headerRendererFactories; }
	private function set_headerRendererFactories(value:Map<String, Function>):Map<String, Function>
	{
		if (this._headerRendererFactories == value)
		{
			return value;
		}
		if (this._headerRendererFactories != null)
		{
			this._headerRendererFactories.clear();
		}
		this._headerRendererFactories = value;
		if (value != null)
		{
			this._headerStorageMap = new Map<String, HeaderRendererFactoryStorage>();
		}
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._headerRendererFactories;
	}
	
	public var headerFactoryIDFunction(get, set):Function;
	private var _headerFactoryIDFunction:Function;
	private function get_headerFactoryIDFunction():Function { return this._headerFactoryIDFunction; }
	private function set_headerFactoryIDFunction(value:Function):Function
	{
		if (this._headerFactoryIDFunction == value)
		{
			return value;
		}
		
		this._headerFactoryIDFunction = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._headerFactoryIDFunction;
	}
	
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
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._customHeaderRendererStyleName;
	}
	
	public var headerRendererProperties(get, set):PropertyProxy;
	private var _headerRendererProperties:PropertyProxy;
	private function get_headerRendererProperties():PropertyProxy
	{
		if (this._headerRendererProperties == null)
		{
			this._headerRendererProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._headerRendererProperties;
	}
	
	private function set_headerRendererProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._headerRendererProperties == value)
		{
			return value;
		}
		if (this._headerRendererProperties != null)
		{
			this._headerRendererProperties.dispose();
		}
		this._headerRendererProperties = value;
		if (this._headerRendererProperties != null)
		{
			this._headerRendererProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerRendererProperties;
	}
	
	public var footerRendererType(get, set):Class<Dynamic>;
	private var _footerRendererType:Class<Dynamic>;
	private function get_footerRendererType():Class<Dynamic> { return this._footerRendererType; }
	private function set_footerRendererType(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._footerRendererType == value)
		{
			return value;
		}
		
		this._footerRendererType = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._footerRendererType;
	}
	
	public var footerRendererFactory(get, set):Function;
	private var _footerRendererFactory:Function;
	private function get_footerRendererFactory():Function { return this._footerRendererFactory; }
	private function set_footerRendererFactory(value:Function):Function
	{
		if (this._footerRendererFactory == value)
		{
			return value;
		}
		
		this._footerRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._footerRendererFactory;
	}
	
	public var footerRendererFactories(get, set):Map<String, Function>;
	private var _footerRendererFactories:Map<String, Function>;
	private function get_footerRendererFactories():Map<String, Function> { return this._footerRendererFactories; }
	private function set_footerRendererFactories(value:Map<String, Function>):Map<String, Function>
	{
		if (this._footerRendererFactories == value)
		{
			return value;
		}
		
		this._footerRendererFactories = value;
		if (value != null)
		{
			this._footerStorageMap = new Map<String, FooterRendererFactoryStorage>();
		}
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._footerRendererFactories;
	}
	
	public var footerFactoryIDFunction(get, set):Function;
	private var _footerFactoryIDFunction:Function;
	private function get_footerFactoryIDFunction():Function { return this._footerFactoryIDFunction; }
	private function set_footerFactoryIDFunction(value:Function):Function
	{
		if (this._footerFactoryIDFunction == value)
		{
			return value;
		}
		
		this._footerFactoryIDFunction = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._footerFactoryIDFunction;
	}
	
	public var customFooterRendererStyleName(get, set):String;
	private var _customFooterRendererStyleName:String;
	private function get_customFooterRendererStyleName():String { return this._customFooterRendererStyleName; }
	private function set_customFooterRendererStyleName(value:String):String
	{
		if (this._customFooterRendererStyleName == value)
		{
			return value;
		}
		this._customFooterRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._customFooterRendererStyleName;
	}
	
	public var footerRendererProperties(get, set):PropertyProxy;
	private var _footerRendererProperties:PropertyProxy;
	private function get_footerRendererProperties():PropertyProxy 
	{
		if (this._footerRendererProperties == null)
		{
			this._footerRendererProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._footerRendererProperties;
	}
	
	private function set_footerRendererProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._footerRendererProperties == value)
		{
			return value;
		}
		if (this._footerRendererProperties != null)
		{
			this._footerRendererProperties.dispose();
		}
		this._footerRendererProperties = value;
		if (this._footerRendererProperties != null)
		{
			this._footerRendererProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._footerRendererProperties;
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
				var variableVirtualLayout:IVariableVirtualLayout = cast this._layout;
				
				//headers and footers are almost always going to have a
				//different height, so we might as well force it because if
				//we don't, there will be a lot of support requests
				variableVirtualLayout.hasVariableItemDimensions = true;
				
				variableVirtualLayout.resetVariableVirtualCache();
			}
			this._layout.addEventListener(Event.CHANGE, layout_changeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._layout;
	}
	
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
	
	public var requiresMeasurementOnScroll(get, never):Bool;
	private function get_requiresMeasurementOnScroll():Bool
	{
		return this._layout.requiresLayoutOnScroll &&
				(this._explicitVisibleWidth != this._explicitVisibleWidth ||
				this._explicitVisibleHeight != this._explicitVisibleHeight);
	}
	
	private var _minimumItemCount:Int;
	private var _minimumHeaderCount:Int;
	private var _minimumFooterCount:Int;
	private var _minimumFirstAndLastItemCount:Int;
	private var _minimumSingleItemCount:Int;
	
	private var _ignoreSelectionChanges:Bool = false;
	
	public function setSelectedLocation(groupIndex:Int, itemIndex:Int):Void
	{
		if (this._selectedGroupIndex == groupIndex && this._selectedItemIndex == itemIndex)
		{
			return;
		}
		if ((groupIndex < 0 && itemIndex >= 0) || (groupIndex >= 0 && itemIndex < 0))
		{
			throw new ArgumentError("To deselect items, group index and item index must both be < 0.");
		}
		this._selectedGroupIndex = groupIndex;
		this._selectedItemIndex = itemIndex;
		
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	public function calculateNavigationDestination(groupIndex:Int, itemIndex:Int, keyCode:Int, result:Array<Int>):Void
	{
		var displayIndex:Int = this.locationToDisplayIndex(groupIndex, itemIndex);
		var newDisplayIndex:Int = this._layout.calculateNavigationDestination(this._layoutItems, displayIndex, keyCode, this._layoutResult);
		this.displayIndexToLocation(newDisplayIndex, result);
	}
	
	public function getScrollPositionForIndex(groupIndex:Int, itemIndex:Int, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var displayIndex:Int = this.locationToDisplayIndex(groupIndex, itemIndex);
		return this._layout.getScrollPositionForIndex(displayIndex, this._layoutItems,
			0, 0, this._actualVisibleWidth, this._actualVisibleHeight, result);
	}
	
	public function getNearestScrollPositionForIndex(groupIndex:Int, itemIndex:Int, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var displayIndex:Int = this.locationToDisplayIndex(groupIndex, itemIndex);
		return this._layout.getNearestScrollPositionForIndex(displayIndex, this._horizontalScrollPosition,
			this._verticalScrollPosition, this._layoutItems, 0, 0, this._actualVisibleWidth, this._actualVisibleHeight, result);
	}
	
	public function itemToItemRenderer(item:Dynamic):IGroupedListItemRenderer
	{
		// TODO : XML
		//if(item is XML || item is XMLList)
		//{
			//return IGroupedListItemRenderer(this._itemRendererMap[item.toXMLString()]);
		//}
		if (Std.isOfType(item, String))
		{
			return this._itemStringRendererMap.get(item);
		}
		else if (Std.isOfType(item, Int))
		{
			return this._itemIntRendererMap.get(item);
		}
		else
		{
			return this._itemObjectRendererMap.get(item);
		}
	}
	
	public function headerDataToHeaderRenderer(headerData:Dynamic):IGroupedListHeaderRenderer
	{
		// TODO : XML
		//if(headerData is XML || headerData is XMLList)
		//{
			//return IGroupedListHeaderRenderer(this._headerRendererMap[headerData.toXMLString()]);
		//}
		if (Std.isOfType(headerData, String))
		{
			return this._headerStringRendererMap.get(headerData);
		}
		else if (Std.isOfType(headerData, Int))
		{
			return this._headerIntRendererMap.get(headerData);
		}
		else
		{
			return this._headerObjectRendererMap.get(headerData);
		}
	}
	
	public function footerDataToFooterRenderer(footerData:Dynamic):IGroupedListFooterRenderer
	{
		// TODO : XML
		//if(footerData is XML || footerData is XMLList)
		//{
			//return IGroupedListFooterRenderer(this._footerRendererMap[footerData.toXMLString()]);
		//}
		if (Std.isOfType(footerData, String))
		{
			return this._footerStringRendererMap.get(footerData);
		}
		else if (Std.isOfType(footerData, Int))
		{
			return this._footerIntRendererMap.get(footerData);
		}
		else
		{
			return this._footerObjectRendererMap.get(footerData);
		}
	}
	
	override public function dispose():Void
	{
		this.refreshInactiveRenderers(true);
		this.owner = null;
		this.dataProvider = null;
		this.layout = null;
		
		if (this._itemRendererFactories != null)
		{
			this._itemRendererFactories.clear();
			this._itemRendererFactories = null;
		}
		if (this._itemObjectRendererMap != null)
		{
			this._itemObjectRendererMap.clear();
			this._itemObjectRendererMap = null;
		}
		if (this._itemIntRendererMap != null)
		{
			this._itemIntRendererMap.clear();
			this._itemIntRendererMap = null;
		}
		if (this._itemStringRendererMap != null)
		{
			this._itemStringRendererMap.clear();
			this._itemStringRendererMap = null;
		}
		if (this._itemStorageMap != null)
		{
			this._itemStorageMap.clear();
			this._itemStorageMap = null;
		}
		
		if (this._headerRendererFactories != null)
		{
			this._headerRendererFactories.clear();
			this._headerRendererFactories = null;
		}
		if (this._headerObjectRendererMap != null)
		{
			this._headerObjectRendererMap.clear();
			this._headerObjectRendererMap = null;
		}
		if (this._headerIntRendererMap != null)
		{
			this._headerIntRendererMap.clear();
			this._headerIntRendererMap = null;
		}
		if (this._headerStringRendererMap != null)
		{
			this._headerStringRendererMap.clear();
			this._headerStringRendererMap = null;
		}
		if (this._headerStorageMap != null)
		{
			this._headerStorageMap.clear();
			this._headerStorageMap = null;
		}
		
		if (this._footerRendererFactories != null)
		{
			this._footerRendererFactories.clear();
			this._footerRendererFactories = null;
		}
		if (this._footerObjectRendererMap != null)
		{
			this._footerObjectRendererMap.clear();
			this._footerObjectRendererMap = null;
		}
		if (this._footerIntRendererMap != null)
		{
			this._footerIntRendererMap.clear();
			this._footerIntRendererMap = null;
		}
		if (this._footerStringRendererMap != null)
		{
			this._footerStringRendererMap.clear();
			this._footerStringRendererMap = null;
		}
		if (this._footerStorageMap != null)
		{
			this._footerStorageMap.clear();
			this._footerStorageMap = null;
		}
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.dispose();
			this._itemRendererProperties = null;
		}
		if (this._headerRendererProperties != null)
		{
			this._headerRendererProperties.dispose();
			this._headerRendererProperties = null;
		}
		if (this._footerRendererProperties != null)
		{
			this._footerRendererProperties.dispose();
			this._footerRendererProperties = null;
		}
		super.dispose();
	}
	
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var scrollInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SCROLL);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var selectionInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		var itemRendererInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		
		//scrolling only affects the layout is requiresLayoutOnScroll is true
		if (!layoutInvalid && scrollInvalid && this._layout != null && this._layout.requiresLayoutOnScroll)
		{
			layoutInvalid = true;
		}
		
		var basicsInvalid:Bool = sizeInvalid || dataInvalid || layoutInvalid || itemRendererInvalid;
		
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
			this.refreshInactiveRenderers(itemRendererInvalid);
		}
		if (dataInvalid || layoutInvalid || itemRendererInvalid)
		{
			this.refreshLayoutTypicalItem();
		}
		if (basicsInvalid)
		{
			this.refreshRenderers();
		}
		if (stylesInvalid || basicsInvalid)
		{
			this.refreshHeaderRendererStyles();
			this.refreshFooterRendererStyles();
			this.refreshItemRendererStyles();
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
			this._layout.layout(this._layoutItems, this._viewPortBounds, this._layoutResult);
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
		this.validateRenderers();
	}
	
	private function validateRenderers():Void
	{
		var itemCount:Int = this._layoutItems.length;
		var item:IValidating;
		for (i in 0...itemCount)
		{
			item = SafeCast.safe_cast(this._layoutItems[i], IValidating);
			if (item != null)
			{
				item.validate();
			}
		}
	}
	
	private function refreshEnabled():Void
	{
		var control:IFeathersControl;
		for (item in this._layoutItems)
		{
			control = SafeCast.safe_cast(item, IFeathersControl);
			if (control != null)
			{
				control.isEnabled = this._isEnabled;
			}
		}
	}
	
	private function invalidateParent(flag:String = FeathersControl.INVALIDATION_FLAG_ALL):Void
	{
		cast(this.parent, Scroller).invalidate(flag);
	}
	
	private function refreshLayoutTypicalItem():Void
	{
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			if (!this._typicalItemIsInDataProvider && this._typicalItemRenderer != null)
			{
				//the old layout was virtual, but this one isn't
				this.destroyItemRenderer(this._typicalItemRenderer);
				this._typicalItemRenderer = null;
			}
			return;
		}
		
		var newTypicalItemIsInDataProvider:Bool = false;
		var typicalItem:Dynamic = this._typicalItem;
		var groupCount:Int = 0;
		var typicalGroupLength:Int = 0;
		var typicalItemGroupIndex:Int = 0;
		var typicalItemItemIndex:Int = 0;
		if (this._dataProvider != null)
		{
			if (typicalItem != null)
			{
				this._dataProvider.getItemLocation(typicalItem, HELPER_VECTOR);
				if (HELPER_VECTOR.length > 1)
				{
					newTypicalItemIsInDataProvider = true;
					typicalItemGroupIndex = HELPER_VECTOR[0];
					typicalItemItemIndex = HELPER_VECTOR[1];
					HELPER_VECTOR.resize(0);
				}
			}
			else
			{
				groupCount = this._dataProvider.getLengthAtLocation();
				if (groupCount > 0)
				{
					for (i in 0...groupCount)
					{
						LOCATION_HELPER_VECTOR.resize(1);
						LOCATION_HELPER_VECTOR[0] = i;
						typicalGroupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
						if (typicalGroupLength > 0)
						{
							newTypicalItemIsInDataProvider = true;
							typicalItemGroupIndex = i;
							LOCATION_HELPER_VECTOR.resize(2);
							LOCATION_HELPER_VECTOR[1] = 0;
							typicalItem = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
							break;
						}
					}
					LOCATION_HELPER_VECTOR.resize(0);
				}
			}
		}
		
		var typicalItemRenderer:IGroupedListItemRenderer = null;
		//#1645 The typicalItem can be null if the data provider contains
		//a null value at index 0. this is the only time we allow null.
		if (typicalItem != null || newTypicalItemIsInDataProvider)
		{
			typicalItemRenderer = this.itemToItemRenderer(typicalItem);
			if (typicalItemRenderer != null)
			{
				//at this point, the item already has an item renderer.
				//(this doesn't necessarily mean that the current typical
				//item was the typical item last time this function was
				//called)
				
				//the indices may have changed if items were added, removed,
				//or reordered in the data provider
				typicalItemRenderer.groupIndex = typicalItemGroupIndex;
				typicalItemRenderer.itemIndex = typicalItemItemIndex;
			}
			if (typicalItemRenderer != null && this._typicalItemRenderer != null)
			{
				//the typical item has changed, and doesn't have an item
				//renderer yet. the previous typical item had an item
				//renderer, so we will try to reuse it.
				
				var canReuse:Bool = !this._typicalItemIsInDataProvider;
				if (canReuse)
				{
					//we can't reuse if the factoryID has changed, though!
					var factoryID:String = this.getFactoryID(typicalItem, typicalItemGroupIndex, typicalItemItemIndex);
					if (this._typicalItemRenderer.factoryID != factoryID)
					{
						canReuse = false;
					}
				}
				if (canReuse)
				{
					//we can reuse the item renderer used for the old
					//typical item!
					typicalItemRenderer = this._typicalItemRenderer;
					typicalItemRenderer.data = typicalItem;
					typicalItemRenderer.groupIndex = typicalItemGroupIndex;
					typicalItemRenderer.itemIndex = typicalItemItemIndex;
				}
			}
			if (typicalItemRenderer == null)
			{
				typicalItemRenderer = this.createItemRenderer(typicalItem, 0, 0, 0, false, !newTypicalItemIsInDataProvider);
				if (!this._typicalItemIsInDataProvider && this._typicalItemRenderer != null)
				{
					//get rid of the old one if it isn't needed anymore
					//since it is not in the data provider, we don't need to mess
					//with the renderer map dictionary.
					this.destroyItemRenderer(this._typicalItemRenderer);
					this._typicalItemRenderer = null;
				}
			}
		}
		
		virtualLayout.typicalItem = SafeCast.safe_cast(typicalItemRenderer, DisplayObject);
		this._typicalItemRenderer = typicalItemRenderer;
		this._typicalItemIsInDataProvider = newTypicalItemIsInDataProvider;
		if (this._typicalItemRenderer != null && !this._typicalItemIsInDataProvider)
		{
			//we need to know if this item renderer resizes to adjust the
			//layout because the layout may use this item renderer to resize
			//the other item renderers
			this._typicalItemRenderer.addEventListener(FeathersEventType.RESIZE, itemRenderer_resizeHandler);
		}
	}
	
	private function refreshItemRendererStyles():Void
	{
		var itemRenderer:IGroupedListItemRenderer;
		for (item in this._layoutItems)
		{
			itemRenderer = SafeCast.safe_cast(item, IGroupedListItemRenderer);
			if (itemRenderer != null)
			{
				this.refreshOneItemRendererStyles(itemRenderer);
			}
		}
	}
	
	private function refreshHeaderRendererStyles():Void
	{
		var headerRenderer:IGroupedListHeaderRenderer;
		for (item in this._layoutItems)
		{
			headerRenderer = SafeCast.safe_cast(item, IGroupedListHeaderRenderer);
			if (headerRenderer != null)
			{
				this.refreshOneHeaderRendererStyles(headerRenderer);
			}
		}
	}
	
	private function refreshFooterRendererStyles():Void
	{
		var footerRenderer:IGroupedListFooterRenderer;
		for (item in this._layoutItems)
		{
			footerRenderer = SafeCast.safe_cast(item, IGroupedListFooterRenderer);
			if (footerRenderer != null)
			{
				this.refreshOneFooterRendererStyles(footerRenderer);
			}
		}
	}
	
	private function refreshOneItemRendererStyles(renderer:IGroupedListItemRenderer):Void
	{
		if (this._itemRendererProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._itemRendererProperties)
			{
				propertyValue = this._itemRendererProperties[propertyName];
				Property.write(renderer, propertyName, propertyValue);
			}
		}
	}
	
	private function refreshOneHeaderRendererStyles(renderer:IGroupedListHeaderRenderer):Void
	{
		if (this._headerRendererProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._headerRendererProperties)
			{
				propertyValue = this._headerRendererProperties[propertyName];
				Property.write(renderer, propertyName, propertyValue);
			}
		}
	}
	
	private function refreshOneFooterRendererStyles(renderer:IGroupedListFooterRenderer):Void
	{
		if (this._footerRendererProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._footerRendererProperties)
			{
				propertyValue = this._footerRendererProperties[propertyName];
				Property.write(renderer, propertyName, propertyValue);
			}
		}
	}
	
	private function refreshSelection():Void
	{
		var itemRenderer:IGroupedListItemRenderer;
		for (item in this._layoutItems)
		{
			itemRenderer = SafeCast.safe_cast(item, IGroupedListItemRenderer);
			if (itemRenderer != null)
			{
				itemRenderer.isSelected = itemRenderer.groupIndex == this._selectedGroupIndex &&
					itemRenderer.itemIndex == this._selectedItemIndex;
			}
		}
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
	
	private function refreshInactiveRenderers(itemRendererTypeIsInvalid:Bool):Void
	{
		this.refreshInactiveItemRenderers(this._defaultItemRendererStorage, itemRendererTypeIsInvalid);
		for (itemStorage in this._itemStorageMap)
		{
			this.refreshInactiveItemRenderers(itemStorage, itemRendererTypeIsInvalid);
		}
		
		this.refreshInactiveHeaderRenderers(this._defaultHeaderRendererStorage, itemRendererTypeIsInvalid);
		for (headerStorage in this._headerStorageMap)
		{
			this.refreshInactiveHeaderRenderers(headerStorage, itemRendererTypeIsInvalid);
		}
		
		this.refreshInactiveFooterRenderers(this._defaultFooterRendererStorage, itemRendererTypeIsInvalid);
		for (footerStorage in this._footerStorageMap)
		{
			this.refreshInactiveFooterRenderers(footerStorage, itemRendererTypeIsInvalid);
		}
		
		if (itemRendererTypeIsInvalid && this._typicalItemRenderer != null)
		{
			if (this._typicalItemIsInDataProvider)
			{
				var item:Dynamic = this._typicalItemRenderer.data;
				// TODO : XML
				//if (item is XML || item is XMLList)
				//{
					//this._itemRendererMap.remove(item.toXMLString());
				//}
				//else
				//{
					#if neko
					if (item != null)
					{
					#end
					trace("item " + item);
					if (Std.isOfType(item, String))
					{
						this._itemStringRendererMap.remove(item);
					}
					else if (Std.isOfType(item, Int))
					{
						this._itemIntRendererMap.remove(item);
					}
					else
					{
						this._itemObjectRendererMap.remove(item);
					}
					#if neko
					}
					#end
				//}
			}
			this.destroyItemRenderer(this._typicalItemRenderer);
			this._typicalItemRenderer = null;
			this._typicalItemIsInDataProvider = false;
		}
		
		this._headerIndices.resize(0);
		this._footerIndices.resize(0);
	}
	
	private function refreshInactiveItemRenderers(storage:GroupItemRendererFactoryStorage, itemRendererTypeIsInvalid:Bool):Void
	{
		var temp:Array<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
		storage.inactiveItemRenderers = storage.activeItemRenderers;
		storage.activeItemRenderers = temp;
		if (storage.activeItemRenderers.length != 0)
		{
			throw new IllegalOperationError("GroupedListDataViewPort: active item renderers should be empty.");
		}
		
		if (itemRendererTypeIsInvalid)
		{
			this.recoverInactiveItemRenderers(storage);
			this.freeInactiveItemRenderers(storage, 0);
		}
	}
	
	private function refreshInactiveHeaderRenderers(storage:HeaderRendererFactoryStorage, itemRendererTypeIsInvalid:Bool):Void
	{
		var temp:Array<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
		storage.inactiveHeaderRenderers = storage.activeHeaderRenderers;
		storage.activeHeaderRenderers = temp;
		if (storage.activeHeaderRenderers.length != 0)
		{
			throw new IllegalOperationError("GroupedListDataViewPort: active header renderers should be empty.");
		}
		
		if (itemRendererTypeIsInvalid)
		{
			this.recoverInactiveHeaderRenderers(storage);
			this.freeInactiveHeaderRenderers(storage, 0);
		}
	}
	
	private function refreshInactiveFooterRenderers(storage:FooterRendererFactoryStorage, itemRendererTypeIsInvalid:Bool):Void
	{
		var temp:Array<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
		storage.inactiveFooterRenderers = storage.activeFooterRenderers;
		storage.activeFooterRenderers = temp;
		if (storage.activeFooterRenderers.length != 0)
		{
			throw new IllegalOperationError("GroupedListDataViewPort: active footer renderers should be empty.");
		}
		
		if (itemRendererTypeIsInvalid)
		{
			this.recoverInactiveFooterRenderers(storage);
			this.freeInactiveFooterRenderers(storage, 0);
		}
	}
	
	private function refreshRenderers():Void
	{
		if (this._typicalItemRenderer != null)
		{
			if (this._typicalItemIsInDataProvider)
			{
				var itemStorage:GroupItemRendererFactoryStorage = this.factoryIDToStorage(this._typicalItemRenderer.factoryID,
					this._typicalItemRenderer.groupIndex, this._typicalItemRenderer.itemIndex);
				var inactiveItemRenderers:Array<IGroupedListItemRenderer> = itemStorage.inactiveItemRenderers;
				var activeItemRenderers:Array<IGroupedListItemRenderer> = itemStorage.activeItemRenderers;
				
				//this renderer is already is use by the typical item, so we
				//don't want to allow it to be used by other items.
				var inactiveIndex:Int = inactiveItemRenderers.indexOf(this._typicalItemRenderer);
				if (inactiveIndex != -1)
				{
					inactiveItemRenderers.splice(inactiveIndex, 1);
				}
				//if refreshLayoutTypicalItem() was called, it will have already
				//added the typical item renderer to the active renderers. if
				//not, we need to do it here.
				var activeRenderersCount:Int = activeItemRenderers.length;
				if (activeRenderersCount == 0)
				{
					activeItemRenderers[activeRenderersCount] = this._typicalItemRenderer;
				}
			}
			//we need to set the typical item renderer's properties here
			//because they may be needed for proper measurement in a virtual
			//layout.
			this.refreshOneItemRendererStyles(this._typicalItemRenderer);
		}
		
		this.findUnrenderedData();
		this.recoverInactiveItemRenderers(this._defaultItemRendererStorage);
		if (this._itemStorageMap != null)
		{
			for (itemStorage in this._itemStorageMap)
			{
				this.recoverInactiveItemRenderers(itemStorage);
			}
		}
		this.recoverInactiveHeaderRenderers(this._defaultHeaderRendererStorage);
		if (this._headerStorageMap != null)
		{
			for (headerStorage in this._headerStorageMap)
			{
				this.recoverInactiveHeaderRenderers(headerStorage);
			}
		}
		this.recoverInactiveFooterRenderers(this._defaultFooterRendererStorage);
		if (this._footerStorageMap != null)
		{
			for (footerStorage in this._footerStorageMap)
			{
				this.recoverInactiveFooterRenderers(footerStorage);
			}
		}
		
		this.renderUnrenderedData();
		
		this.freeInactiveItemRenderers(this._defaultItemRendererStorage, this._minimumItemCount);
		if (this._itemStorageMap != null)
		{
			for (itemStorage in this._itemStorageMap)
			{
				this.freeInactiveItemRenderers(itemStorage, 1);
			}
		}
		this.freeInactiveHeaderRenderers(this._defaultHeaderRendererStorage, this._minimumHeaderCount);
		if (this._headerStorageMap != null)
		{
			for (headerStorage in this._headerStorageMap)
			{
				this.freeInactiveHeaderRenderers(headerStorage, 1);
			}
		}
		this.freeInactiveFooterRenderers(this._defaultFooterRendererStorage, this._minimumFooterCount);
		if (this._footerStorageMap != null)
		{
			for (footerStorage in this._footerStorageMap)
			{
				this.freeInactiveFooterRenderers(footerStorage, 1);
			}
		}
		
		this._updateForDataReset = false;
	}
	
	private function findUnrenderedData():Void
	{
		var groupCount:Int = this._dataProvider != null ? this._dataProvider.getLengthAtLocation() : 0;
		var totalLayoutCount:Int = 0;
		var totalHeaderCount:Int = 0;
		var totalFooterCount:Int = 0;
		var totalSingleItemCount:Int = 0;
		var averageItemsPerGroup:Int = 0;
		LOCATION_HELPER_VECTOR.resize(1);
		var group:Dynamic;
		var currentItemCount:Int;
		for (i in 0...groupCount)
		{
			LOCATION_HELPER_VECTOR[0] = i;
			group = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			if (this._owner.groupToHeaderData(group) != null)
			{
				this._headerIndices[totalHeaderCount] = totalLayoutCount;
				totalLayoutCount++;
				totalHeaderCount++;
			}
			currentItemCount = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			totalLayoutCount += currentItemCount;
			averageItemsPerGroup += currentItemCount;
			if (currentItemCount == 0)
			{
				totalSingleItemCount++;
			}
			if (this._owner.groupToFooterData(group) != null)
			{
				this._footerIndices[totalFooterCount] = totalLayoutCount;
				totalLayoutCount++;
				totalFooterCount++;
			}
		}
		LOCATION_HELPER_VECTOR.resize(0);
		this._layoutItems.resize(totalLayoutCount);
		if (Std.isOfType(this._layout, IGroupedLayout))
		{
			cast(this._layout, IGroupedLayout).headerIndices = this._headerIndices;
		}
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		var useVirtualLayout:Bool = virtualLayout != null && virtualLayout.useVirtualLayout;
		if (useVirtualLayout)
		{
			var point:Point = Pool.getPoint();
			virtualLayout.measureViewPort(totalLayoutCount, this._viewPortBounds, point);
			var viewPortWidth:Float = point.x;
			var viewPortHeight:Float = point.y;
			Pool.putPoint(point);
			virtualLayout.getVisibleIndicesAtScrollPosition(this._horizontalScrollPosition, this._verticalScrollPosition, viewPortWidth, viewPortHeight, totalLayoutCount, HELPER_VECTOR);
			
			averageItemsPerGroup = Std.int(averageItemsPerGroup / groupCount);
			
			if (this._typicalItemRenderer != null)
			{
				var minimumTypicalItemEdge:Float = this._typicalItemRenderer.height;
				if (this._typicalItemRenderer.width < minimumTypicalItemEdge)
				{
					minimumTypicalItemEdge = this._typicalItemRenderer.width;
				}
				
				var maximumViewPortEdge:Float = viewPortWidth;
				if (viewPortHeight > viewPortWidth)
				{
					maximumViewPortEdge = viewPortHeight;
				}
				this._minimumFirstAndLastItemCount = this._minimumSingleItemCount = this._minimumHeaderCount = this._minimumFooterCount = Math.ceil(maximumViewPortEdge / (minimumTypicalItemEdge * averageItemsPerGroup));
				this._minimumHeaderCount = Std.int(Math.min(this._minimumHeaderCount, totalHeaderCount));
				this._minimumFooterCount = Std.int(Math.min(this._minimumFooterCount, totalFooterCount));
				this._minimumSingleItemCount = Std.int(Math.min(this._minimumSingleItemCount, totalSingleItemCount));
				
				//assumes that zero headers/footers might be visible
				this._minimumItemCount = Math.ceil(maximumViewPortEdge / minimumTypicalItemEdge) + 1;
			}
			else
			{
				this._minimumFirstAndLastItemCount = 1;
				this._minimumHeaderCount = 1;
				this._minimumFooterCount = 1;
				this._minimumSingleItemCount = 1;
				this._minimumItemCount = 1;
			}
		}
		var currentIndex:Int = 0;
		var header:Dynamic;
		var item:Dynamic;
		var footer:Dynamic;
		for (i in 0...groupCount)
		{
			LOCATION_HELPER_VECTOR.resize(1);
			LOCATION_HELPER_VECTOR[0] = i;
			group = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
			header = this._owner.groupToHeaderData(group);
			if (header != null)
			{
				//the end index is included in the visible items
				if (useVirtualLayout && HELPER_VECTOR.indexOf(currentIndex) == -1)
				{
					this._layoutItems[currentIndex] = null;
				}
				else
				{
					this.findRendererForHeader(header, i, currentIndex);
				}
				currentIndex++;
			}
			LOCATION_HELPER_VECTOR.resize(1);
			LOCATION_HELPER_VECTOR[0] = i;
			currentItemCount = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
			for (j in 0...currentItemCount)
			{
				if (useVirtualLayout && HELPER_VECTOR.indexOf(currentIndex) == -1)
				{
					if (this._typicalItemRenderer != null && this._typicalItemIsInDataProvider &&
						this._typicalItemRenderer.groupIndex == i &&
						this._typicalItemRenderer.itemIndex == j)
					{
						//the indices may have changed if items were added, removed,
						//or reordered in the data provider
						this._typicalItemRenderer.layoutIndex = currentIndex;
					}
					this._layoutItems[currentIndex] = null;
				}
				else
				{
					LOCATION_HELPER_VECTOR.resize(2);
					LOCATION_HELPER_VECTOR[0] = i;
					LOCATION_HELPER_VECTOR[1] = j;
					item = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
					LOCATION_HELPER_VECTOR.resize(0);
					this.findRendererForItem(item, i, j, currentIndex);
				}
				currentIndex++;
			}
			footer = this._owner.groupToFooterData(group);
			if (footer != null)
			{
				if (useVirtualLayout && HELPER_VECTOR.indexOf(currentIndex) == -1)
				{
					this._layoutItems[currentIndex] = null;
				}
				else
				{
					this.findRendererForFooter(footer, i, currentIndex);
				}
				currentIndex++;
			}
		}
		LOCATION_HELPER_VECTOR.resize(0);
		//update the typical item renderer's visibility
		if (this._typicalItemRenderer != null)
		{
			if (useVirtualLayout && this._typicalItemIsInDataProvider)
			{
				var index:Int = HELPER_VECTOR.indexOf(this._typicalItemRenderer.layoutIndex);
				if (index != -1)
				{
					this._typicalItemRenderer.visible = true;
				}
				else
				{
					this._typicalItemRenderer.visible = false;
					
					//uncomment these lines to see a hidden typical item for
					//debugging purposes...
					/*this._typicalItemRenderer.visible = true;
					this._typicalItemRenderer.x = this._horizontalScrollPosition;
					this._typicalItemRenderer.y = this._verticalScrollPosition;*/
				}
			}
			else
			{
				this._typicalItemRenderer.visible = this._typicalItemIsInDataProvider;
			}
		}
		HELPER_VECTOR.resize(0);
	}
	
	private function findRendererForItem(item:Dynamic, groupIndex:Int, itemIndex:Int, layoutIndex:Int):Void
	{
		var itemRenderer:IGroupedListItemRenderer = this.itemToItemRenderer(item);
		if (this._factoryIDFunction != null && itemRenderer != null)
		{
			var newFactoryID:String = this.getFactoryID(itemRenderer.data, groupIndex, itemIndex);
			if (newFactoryID != itemRenderer.factoryID)
			{
				itemRenderer = null;
				// TODO : XML
				//if (item is XML || item is XMLList)
				//{
					//this._itemRendererMap.remove(item.toXMLString());
				//}
				//else
				//{
					if (Std.isOfType(item, String))
					{
						this._itemStringRendererMap.remove(item);
					}
					else if (Std.isOfType(item, Int))
					{
						this._itemIntRendererMap.remove(item);
					}
					else
					{
						this._itemObjectRendererMap.remove(item);
					}
				//}
			}
		}
		if (itemRenderer != null)
		{
			//the indices may have changed if items were added, removed,
			//or reordered in the data provider
			itemRenderer.groupIndex = groupIndex;
			itemRenderer.itemIndex = itemIndex;
			itemRenderer.layoutIndex = layoutIndex;
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
				itemRenderer.data = null;
				itemRenderer.data = item;
			}
			
			//the typical item renderer is a special case, and we will
			//have already put it into the active renderers, so we don't
			//want to do it again!
			if (this._typicalItemRenderer != itemRenderer)
			{
				var storage:GroupItemRendererFactoryStorage = this.factoryIDToStorage(itemRenderer.factoryID,
					itemRenderer.groupIndex, itemRenderer.itemIndex);
				var activeItemRenderers:Array<IGroupedListItemRenderer> = storage.activeItemRenderers;
				var inactiveItemRenderers:Array<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
				activeItemRenderers[activeItemRenderers.length] = itemRenderer;
				var inactiveIndex:Int = inactiveItemRenderers.indexOf(itemRenderer);
				if (inactiveIndex != -1)
				{
					inactiveItemRenderers.splice(inactiveIndex, 1);
				}
				else
				{
					throw new IllegalOperationError("GroupedListDataViewPort: item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
			}
			itemRenderer.visible = true;
			this._layoutItems[layoutIndex] = cast itemRenderer;
		}
		else
		{
			var pushIndex:Int = this._unrenderedItems.length;
			this._unrenderedItems[pushIndex] = groupIndex;
			pushIndex++;
			this._unrenderedItems[pushIndex] = itemIndex;
			pushIndex++;
			this._unrenderedItems[pushIndex] = layoutIndex;
		}
	}
	
	private function findRendererForHeader(header:Dynamic, groupIndex:Int, layoutIndex:Int):Void
	{
		var headerRenderer:IGroupedListHeaderRenderer = this.headerDataToHeaderRenderer(header);
		if (this._headerFactoryIDFunction != null && headerRenderer != null)
		{
			var newFactoryID:String = this.getHeaderFactoryID(headerRenderer.data, groupIndex);
			if (newFactoryID != headerRenderer.factoryID)
			{
				headerRenderer = null;
				// TODO : XML
				//if (header is XML || header is XMLList)
				//{
					//this._headerRendererMap.remove(header.toXMLString());
				//}
				//else
				//{
					if (Std.isOfType(header, String))
					{
						this._headerStringRendererMap.remove(header);
					}
					else if (Std.isOfType(header, Int))
					{
						this._headerIntRendererMap.remove(header);
					}
					else
					{
						this._headerObjectRendererMap.remove(header);
					}
				//}
			}
		}
		if (headerRenderer != null)
		{
			headerRenderer.groupIndex = groupIndex;
			headerRenderer.layoutIndex = layoutIndex;
			if (this._updateForDataReset)
			{
				//see comments in item renderer section below
				headerRenderer.data = null;
				headerRenderer.data = header;
			}
			var storage:HeaderRendererFactoryStorage = this.headerFactoryIDToStorage(headerRenderer.factoryID);
			var activeHeaderRenderers:Array<IGroupedListHeaderRenderer> = storage.activeHeaderRenderers;
			var inactiveHeaderRenderers:Array<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
			activeHeaderRenderers[activeHeaderRenderers.length] = headerRenderer;
			var inactiveIndex:Int = inactiveHeaderRenderers.indexOf(headerRenderer);
			if (inactiveIndex != -1)
			{
				inactiveHeaderRenderers.splice(inactiveIndex, 1);
			}
			else
			{
				throw new IllegalOperationError("GroupedListDataViewPort: header renderer map contains bad data. This may be caused by duplicate headers in the data provider, which is not allowed.");
			}
			headerRenderer.visible = true;
			this._layoutItems[layoutIndex] = cast headerRenderer;
		}
		else
		{
			var pushIndex:Int = this._unrenderedHeaders.length;
			this._unrenderedHeaders[pushIndex] = groupIndex;
			pushIndex++;
			this._unrenderedHeaders[pushIndex] = layoutIndex;
		}
	}
	
	private function findRendererForFooter(footer:Dynamic, groupIndex:Int, layoutIndex:Int):Void
	{
		var footerRenderer:IGroupedListFooterRenderer = this.footerDataToFooterRenderer(footer);
		if (this._footerFactoryIDFunction != null && footerRenderer != null)
		{
			var newFactoryID:String = this.getFooterFactoryID(footerRenderer.data, groupIndex);
			if (newFactoryID != footerRenderer.factoryID)
			{
				footerRenderer = null;
				// TODO : XML
				//if (footer is XML || footer is XMLList)
				//{
					//this._footerRendererMap.remove(footer.toXMLString());
				//}
				//else
				//{
					if (Std.isOfType(footer, String))
					{
						this._footerStringRendererMap.remove(footer);
					}
					else if (Std.isOfType(footer, Int))
					{
						this._footerIntRendererMap.remove(footer);
					}
					else
					{
						this._footerObjectRendererMap.remove(footer);
					}
				//}
			}
		}
		if (footerRenderer != null)
		{
			footerRenderer.groupIndex = groupIndex;
			footerRenderer.layoutIndex = layoutIndex;
			if (this._updateForDataReset)
			{
				//see comments in item renderer section above
				footerRenderer.data = null;
				footerRenderer.data = footer;
			}
			var storage:FooterRendererFactoryStorage = this.footerFactoryIDToStorage(footerRenderer.factoryID);
			var activeFooterRenderers:Array<IGroupedListFooterRenderer> = storage.activeFooterRenderers;
			var inactiveFooterRenderers:Array<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
			activeFooterRenderers[activeFooterRenderers.length] = footerRenderer;
			var inactiveIndex:Int = inactiveFooterRenderers.indexOf(footerRenderer);
			if (inactiveIndex != -1)
			{
				inactiveFooterRenderers.splice(inactiveIndex, 1);
			}
			else
			{
				throw new IllegalOperationError("GroupedListDataViewPort: footer renderer map contains bad data. This may be caused by duplicate footers in the data provider, which is not allowed.");
			}
			footerRenderer.visible = true;
			this._layoutItems[layoutIndex] = cast footerRenderer;
		}
		else
		{
			var pushIndex:Int = this._unrenderedFooters.length;
			this._unrenderedFooters[pushIndex] = groupIndex;
			pushIndex++;
			this._unrenderedFooters[pushIndex] = layoutIndex;
		}
	}
	
	private function renderUnrenderedData():Void
	{
		LOCATION_HELPER_VECTOR.resize(2);
		var rendererCount:Int = this._unrenderedItems.length;
		var groupIndex:Int;
		var itemIndex:Int;
		var layoutIndex:Int;
		var item:Dynamic;
		var itemRenderer:IGroupedListItemRenderer;
		var i:Int = 0;
		while (i < rendererCount)
		{
			groupIndex = this._unrenderedItems.shift();
			itemIndex = this._unrenderedItems.shift();
			layoutIndex = this._unrenderedItems.shift();
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			LOCATION_HELPER_VECTOR[1] = itemIndex;
			item = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			itemRenderer = this.createItemRenderer(
				item, groupIndex, itemIndex, layoutIndex, true, false);
			this._layoutItems[layoutIndex] = cast itemRenderer;
			i += 3;
		}
		
		LOCATION_HELPER_VECTOR.resize(1);
		rendererCount = this._unrenderedHeaders.length;
		var headerRenderer:IGroupedListHeaderRenderer;
		i = 0;
		while (i < rendererCount)
		{
			groupIndex = this._unrenderedHeaders.shift();
			layoutIndex = this._unrenderedHeaders.shift();
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			item = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			item = this._owner.groupToHeaderData(item);
			headerRenderer = this.createHeaderRenderer(item, groupIndex, layoutIndex, false);
			this._layoutItems[layoutIndex] = cast headerRenderer;
			i += 2;
		}
		
		rendererCount = this._unrenderedFooters.length;
		var footerRenderer:IGroupedListFooterRenderer;
		i = 0;
		while (i < rendererCount)
		{
			groupIndex = this._unrenderedFooters.shift();
			layoutIndex = this._unrenderedFooters.shift();
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			item = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			item = this._owner.groupToFooterData(item);
			footerRenderer = this.createFooterRenderer(item, groupIndex, layoutIndex, false);
			this._layoutItems[layoutIndex] = cast footerRenderer;
			i += 2;
		}
		LOCATION_HELPER_VECTOR.resize(0);
	}
	
	private function recoverInactiveItemRenderers(storage:GroupItemRendererFactoryStorage):Void
	{
		var inactiveItemRenderers:Array<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
		var rendererCount:Int = inactiveItemRenderers.length;
		var itemRenderer:IGroupedListItemRenderer;
		var item:Dynamic;
		for (i in 0...rendererCount)
		{
			itemRenderer = inactiveItemRenderers[i];
			if (itemRenderer == null || itemRenderer.groupIndex < 0)
			{
				continue;
			}
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, itemRenderer);
			item = itemRenderer.data;
			if (item == null) continue;
			// TODO : XML
			//if (item is XML || item is XMLList)
			//{
				//this._itemRendererMap.remove(item.toXMLString());
			//}
			//else
			//{
				if (Std.isOfType(item, String))
				{
					this._itemStringRendererMap.remove(item);
				}
				else if (Std.isOfType(item, Int))
				{
					this._itemIntRendererMap.remove(item);
				}
				else
				{
					this._itemObjectRendererMap.remove(item);
				}
			//}
		}
	}
	
	private function recoverInactiveHeaderRenderers(storage:HeaderRendererFactoryStorage):Void
	{
		var inactiveHeaderRenderers:Array<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
		var headerRendererCount:Int = inactiveHeaderRenderers.length;
		var headerRenderer:IGroupedListHeaderRenderer;
		var headerData:Dynamic;
		for (i in 0...headerRendererCount)
		{
			headerRenderer = inactiveHeaderRenderers[i];
			if (headerRenderer == null)
			{
				continue;
			}
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, headerRenderer);
			headerData = headerRenderer.data;
			if (headerData == null) continue;
			// TODO : XML
			//if (headerData is XML || headerData is XMLList)
			//{
				//this._headerRendererMap.remove(headerData.toXMLString());
			//}
			//else
			//{
				if (Std.isOfType(headerData, String))
				{
					this._headerStringRendererMap.remove(headerData);
				}
				else if (Std.isOfType(headerData, Int))
				{
					this._headerIntRendererMap.remove(headerData);
				}
				else
				{
					this._headerObjectRendererMap.remove(headerData);
				}
			//}
		}
	}
	
	private function recoverInactiveFooterRenderers(storage:FooterRendererFactoryStorage):Void
	{
		var inactiveFooterRenderers:Array<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
		var footerRendererCount:Int = inactiveFooterRenderers.length;
		var footerRenderer:IGroupedListFooterRenderer;
		var footerData:Dynamic;
		for (i in 0...footerRendererCount)
		{
			footerRenderer = inactiveFooterRenderers[i];
			if (footerRenderer == null)
			{
				continue;
			}
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, footerRenderer);
			footerData = footerRenderer.data;
			if (footerData == null) continue;
			// TODO : XML
			//if (footerData is XML || footerData is XMLList)
			//{
				//this._footerRendererMap.remove(footerData.toXMLString());
			//}
			//else
			//{
				if (Std.isOfType(footerData, String))
				{
					this._footerStringRendererMap.remove(footerData);
				}
				else if (Std.isOfType(footerData, Int))
				{
					this._footerIntRendererMap.remove(footerData);
				}
				else
				{
					this._footerObjectRendererMap.remove(footerData);
				}
			//}
		}
	}
	
	private function freeInactiveItemRenderers(storage:GroupItemRendererFactoryStorage, minimumItemCount:Int):Void
	{
		var inactiveItemRenderers:Array<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
		var activeItemRenderers:Array<IGroupedListItemRenderer> = storage.activeItemRenderers;
		var activeItemRenderersCount:Int = activeItemRenderers.length;
		
		//we may keep around some extra renderers to avoid too much
		//allocation and garbage collection. they'll be hidden.
		var keepCount:Int = minimumItemCount - activeItemRenderersCount;
		if (keepCount > inactiveItemRenderers.length)
		{
			keepCount = inactiveItemRenderers.length;
		}
		var itemRenderer:IGroupedListItemRenderer;
		for (i in 0...keepCount)
		{
			itemRenderer = inactiveItemRenderers.shift();
			itemRenderer.data = null;
			itemRenderer.groupIndex = -1;
			itemRenderer.itemIndex = -1;
			itemRenderer.layoutIndex = -1;
			itemRenderer.visible = false;
			activeItemRenderers[activeItemRenderersCount] = itemRenderer;
			activeItemRenderersCount++;
		}
		var rendererCount:Int = inactiveItemRenderers.length;
		for (i in 0...rendererCount)
		{
			itemRenderer = inactiveItemRenderers.shift();
			if (itemRenderer == null)
			{
				continue;
			}
			this.destroyItemRenderer(itemRenderer);
		}
	}
	
	private function freeInactiveHeaderRenderers(storage:HeaderRendererFactoryStorage, minimumHeaderCount:Int):Void
	{
		var inactiveHeaderRenderers:Array<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
		var activeHeaderRenderers:Array<IGroupedListHeaderRenderer> = storage.activeHeaderRenderers;
		var activeHeaderRenderersCount:Int = activeHeaderRenderers.length;
		
		var keepCount:Int = minimumHeaderCount - activeHeaderRenderersCount;
		if (keepCount > inactiveHeaderRenderers.length)
		{
			keepCount = inactiveHeaderRenderers.length;
		}
		var headerRenderer:IGroupedListHeaderRenderer;
		for (i in 0...keepCount)
		{
			headerRenderer = inactiveHeaderRenderers.shift();
			headerRenderer.visible = false;
			headerRenderer.data = null;
			headerRenderer.groupIndex = -1;
			headerRenderer.layoutIndex = -1;
			activeHeaderRenderers[activeHeaderRenderersCount] = headerRenderer;
			activeHeaderRenderersCount++;
		}
		var inactiveHeaderRendererCount:Int = inactiveHeaderRenderers.length;
		for (i in 0...inactiveHeaderRendererCount)
		{
			headerRenderer = inactiveHeaderRenderers.shift();
			if (headerRenderer == null)
			{
				continue;
			}
			this.destroyHeaderRenderer(headerRenderer);
		}
	}
	
	private function freeInactiveFooterRenderers(storage:FooterRendererFactoryStorage, minimumFooterCount:Int):Void
	{
		var inactiveFooterRenderers:Array<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
		var activeFooterRenderers:Array<IGroupedListFooterRenderer> = storage.activeFooterRenderers;
		var activeFooterRenderersCount:Int = activeFooterRenderers.length;
		
		var keepCount:Int = minimumFooterCount - activeFooterRenderersCount;
		if (keepCount > inactiveFooterRenderers.length)
		{
			keepCount = inactiveFooterRenderers.length;
		}
		var footerRenderer:IGroupedListFooterRenderer;
		for (i in 0...keepCount)
		{
			footerRenderer = inactiveFooterRenderers.shift();
			footerRenderer.visible = false;
			footerRenderer.data = null;
			footerRenderer.groupIndex = -1;
			footerRenderer.layoutIndex = -1;
			activeFooterRenderers[activeFooterRenderersCount] = footerRenderer;
			activeFooterRenderersCount++;
		}
		var inactiveFooterRendererCount:Int = inactiveFooterRenderers.length;
		for (i in 0...inactiveFooterRendererCount)
		{
			footerRenderer = inactiveFooterRenderers.shift();
			if (footerRenderer == null)
			{
				continue;
			}
			this.destroyFooterRenderer(footerRenderer);
		}
	}
	
	private function createItemRenderer(item:Dynamic, groupIndex:Int, itemIndex:Int,
		layoutIndex:Int, useCache:Bool, isTemporary:Bool):IGroupedListItemRenderer
	{
		var factoryID:String = this.getFactoryID(item, groupIndex, itemIndex);
		var itemRendererFactory:Function = this.factoryIDToFactory(factoryID, groupIndex, itemIndex);
		var storage:GroupItemRendererFactoryStorage = this.factoryIDToStorage(factoryID, groupIndex, itemIndex);
		var customStyleName:String = this.indexToCustomStyleName(groupIndex, itemIndex);
		var inactiveItemRenderers:Array<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
		var activeItemRenderers:Array<IGroupedListItemRenderer> = storage.activeItemRenderers;
		var itemRenderer:IGroupedListItemRenderer;
		if (!useCache || isTemporary || inactiveItemRenderers.length == 0)
		{
			if (itemRendererFactory != null)
			{
				itemRenderer = itemRendererFactory();
			}
			else
			{
				var ItemRendererType:Class<Dynamic> = this.indexToItemRendererType(groupIndex, itemIndex);
				itemRenderer = cast Type.createInstance(ItemRendererType, []);
			}
			
			if (customStyleName != null && customStyleName.length != 0)
			{
				var uiRenderer:IFeathersControl = cast itemRenderer;
				uiRenderer.styleNameList.add(customStyleName);
			}
			this.addChild(cast itemRenderer);
		}
		else
		{
			itemRenderer = inactiveItemRenderers.shift();
		}
		itemRenderer.data = item;
		itemRenderer.groupIndex = groupIndex;
		itemRenderer.itemIndex = itemIndex;
		itemRenderer.layoutIndex = layoutIndex;
		itemRenderer.owner = this._owner;
		itemRenderer.factoryID = factoryID;
		itemRenderer.visible = true;
		
		if (!isTemporary)
		{
			// TODO : XML
			//if (item is XML || item is XMLList)
			//{
				//this._itemRendererMap[item.toXMLString()] = itemRenderer;
			//}
			//else
			//{
				if (Std.isOfType(item, String))
				{
					this._itemStringRendererMap.set(item, itemRenderer);
				}
				else if (Std.isOfType(item, Int))
				{
					this._itemIntRendererMap.set(item, itemRenderer);
				}
				else
				{
					this._itemObjectRendererMap.set(item, itemRenderer);
				}
			//}
			activeItemRenderers.push(itemRenderer);
			itemRenderer.addEventListener(Event.TRIGGERED, renderer_triggeredHandler);
			itemRenderer.addEventListener(Event.CHANGE, renderer_changeHandler);
			itemRenderer.addEventListener(FeathersEventType.RESIZE, itemRenderer_resizeHandler);
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, itemRenderer);
		}
		
		return itemRenderer;
	}
	
	private function createHeaderRenderer(header:Dynamic, groupIndex:Int, layoutIndex:Int, isTemporary:Bool = false):IGroupedListHeaderRenderer
	{
		var factoryID:String = this.getHeaderFactoryID(header, groupIndex);
		var headerRendererFactory:Function = this.headerFactoryIDToFactory(factoryID);
		var storage:HeaderRendererFactoryStorage = this.headerFactoryIDToStorage(factoryID);
		var inactiveHeaderRenderers:Array<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
		var activeHeaderRenderers:Array<IGroupedListHeaderRenderer> = storage.activeHeaderRenderers;
		var headerRenderer:IGroupedListHeaderRenderer;
		if (isTemporary || inactiveHeaderRenderers.length == 0)
		{
			if (headerRendererFactory != null)
			{
				headerRenderer = headerRendererFactory();
			}
			else
			{
				headerRenderer = cast Type.createInstance(this._headerRendererType, []);
			}
			
			if (this._customHeaderRendererStyleName != null && this._customHeaderRendererStyleName.length != 0)
			{
				var uiRenderer:IFeathersControl = cast headerRenderer;
				uiRenderer.styleNameList.add(this._customHeaderRendererStyleName);
			}
			this.addChild(cast headerRenderer);
		}
		else
		{
			headerRenderer = inactiveHeaderRenderers.shift();
		}
		headerRenderer.data = header;
		headerRenderer.groupIndex = groupIndex;
		headerRenderer.layoutIndex = layoutIndex;
		headerRenderer.owner = this._owner;
		headerRenderer.factoryID = factoryID;
		headerRenderer.visible = true;
		
		if (!isTemporary)
		{
			// TODO : XML
			//if (header is XML || header is XMLList)
			//{
				//this._headerRendererMap[header.toXMLString()] = headerRenderer;
			//}
			//else
			//{
				if (Std.isOfType(header, String))
				{
					this._headerStringRendererMap.set(header, headerRenderer);
				}
				else if (Std.isOfType(header, Int))
				{
					this._headerIntRendererMap.set(header, headerRenderer);
				}
				else
				{
					this._headerObjectRendererMap.set(header, headerRenderer);
				}
			//}
			activeHeaderRenderers.push(headerRenderer);
			headerRenderer.addEventListener(FeathersEventType.RESIZE, headerRenderer_resizeHandler);
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, headerRenderer);
		}
		
		return headerRenderer;
	}
	
	private function createFooterRenderer(footer:Dynamic, groupIndex:Int, layoutIndex:Int, isTemporary:Bool = false):IGroupedListFooterRenderer
	{
		var factoryID:String = this.getFooterFactoryID(footer, groupIndex);
		var footerRendererFactory:Function = this.footerFactoryIDToFactory(factoryID);
		var storage:FooterRendererFactoryStorage = this.footerFactoryIDToStorage(factoryID);
		var inactiveFooterRenderers:Array<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
		var activeFooterRenderers:Array<IGroupedListFooterRenderer> = storage.activeFooterRenderers;
		var footerRenderer:IGroupedListFooterRenderer;
		if (isTemporary || inactiveFooterRenderers.length == 0)
		{
			if (footerRendererFactory != null)
			{
				footerRenderer = cast footerRendererFactory();
			}
			else
			{
				footerRenderer = cast Type.createInstance(this._footerRendererType, []);
			}
			
			if (this._customFooterRendererStyleName != null && this._customFooterRendererStyleName.length != 0)
			{
				var uiRenderer:IFeathersControl = cast footerRenderer;
				uiRenderer.styleNameList.add(this._customFooterRendererStyleName);
			}
			this.addChild(cast footerRenderer);
		}
		else
		{
			footerRenderer = inactiveFooterRenderers.shift();
		}
		footerRenderer.data = footer;
		footerRenderer.groupIndex = groupIndex;
		footerRenderer.layoutIndex = layoutIndex;
		footerRenderer.owner = this._owner;
		footerRenderer.factoryID = factoryID;
		footerRenderer.visible = true;
		
		if (!isTemporary)
		{
			// TODO : XML
			//if (footer is XML || footer is XMLList)
			//{
				//this._footerRendererMap[footer.toXMLString()] = footerRenderer;
			//}
			//else
			//{
				if (Std.isOfType(footer, String))
				{
					this._footerStringRendererMap.set(footer, footerRenderer);
				}
				else if (Std.isOfType(footer, Int))
				{
					this._footerIntRendererMap.set(footer, footerRenderer);
				}
				else
				{
					this._footerObjectRendererMap.set(footer, footerRenderer);
				}
			//}
			activeFooterRenderers[activeFooterRenderers.length] = footerRenderer;
			footerRenderer.addEventListener(FeathersEventType.RESIZE, footerRenderer_resizeHandler);
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, footerRenderer);
		}
		
		return footerRenderer;
	}
	
	private function destroyItemRenderer(renderer:IGroupedListItemRenderer):Void
	{
		renderer.removeEventListener(Event.TRIGGERED, renderer_triggeredHandler);
		renderer.removeEventListener(Event.CHANGE, renderer_changeHandler);
		renderer.removeEventListener(FeathersEventType.RESIZE, itemRenderer_resizeHandler);
		renderer.owner = null;
		renderer.data = null;
		this.removeChild(cast renderer, true);
	}
	
	private function destroyHeaderRenderer(renderer:IGroupedListHeaderRenderer):Void
	{
		renderer.removeEventListener(FeathersEventType.RESIZE, headerRenderer_resizeHandler);
		renderer.owner = null;
		renderer.data = null;
		this.removeChild(cast renderer, true);
	}
	
	private function destroyFooterRenderer(renderer:IGroupedListFooterRenderer):Void
	{
		renderer.removeEventListener(FeathersEventType.RESIZE, footerRenderer_resizeHandler);
		renderer.owner = null;
		renderer.data = null;
		this.removeChild(cast renderer, true);
	}
	
	private function groupToHeaderDisplayIndex(groupIndex:Int):Int
	{
		LOCATION_HELPER_VECTOR.resize(1);
		LOCATION_HELPER_VECTOR[0] = groupIndex;
		var group:Dynamic = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
		var header:Dynamic = this._owner.groupToHeaderData(group);
		if (header == null)
		{
			LOCATION_HELPER_VECTOR.resize(0);
			return -1;
		}
		LOCATION_HELPER_VECTOR.resize(1);
		var displayIndex:Int = 0;
		var groupCount:Int = this._dataProvider.getLengthAtLocation();
		var groupLength:Int;
		var footer:Dynamic;
		for (i in 0...groupCount)
		{
			LOCATION_HELPER_VECTOR[0] = i;
			group = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			header = this._owner.groupToHeaderData(group);
			if (header != null)
			{
				if (groupIndex == i)
				{
					LOCATION_HELPER_VECTOR.resize(0);
					return displayIndex;
				}
				displayIndex++;
			}
			groupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			displayIndex += groupLength;
			footer = this._owner.groupToFooterData(group);
			if (footer != null)
			{
				displayIndex++;
			}
		}
		LOCATION_HELPER_VECTOR.resize(0);
		return -1;
	}
	
	private function groupToFooterDisplayIndex(groupIndex:Int):Int
	{
		LOCATION_HELPER_VECTOR.resize(1);
		LOCATION_HELPER_VECTOR[0] = groupIndex;
		var group:Dynamic = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
		var footer:Dynamic = this._owner.groupToFooterData(group);
		if (footer == null)
		{
			LOCATION_HELPER_VECTOR.resize(0);
			return -1;
		}
		LOCATION_HELPER_VECTOR.resize(1);
		var displayIndex:Int = 0;
		var groupCount:Int = this._dataProvider.getLengthAtLocation();
		var header:Dynamic;
		var groupLength:Int;
		for (i in 0...groupCount)
		{
			LOCATION_HELPER_VECTOR[0] = i;
			group = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			header = this._owner.groupToHeaderData(group);
			if (header != null)
			{
				displayIndex++;
			}
			groupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			displayIndex += groupLength;
			footer = this._owner.groupToFooterData(group);
			if (footer != null)
			{
				if (groupIndex == i)
				{
					LOCATION_HELPER_VECTOR.resize(0);
					return displayIndex;
				}
				displayIndex++;
			}
		}
		LOCATION_HELPER_VECTOR.resize(0);
		return -1;
	}
	
	private function displayIndexToLocation(displayIndex:Int, result:Array<Int>):Void
	{
		result.resize(2);
		LOCATION_HELPER_VECTOR.resize(1);
		var totalCount:Int = 0;
		var groupCount:Int = this._dataProvider.getLengthAtLocation();
		var group:Dynamic;
		var header:Dynamic;
		var groupLength:Int;
		var itemIndex:Int;
		var footer:Dynamic;
		for (i in 0...groupCount)
		{
			LOCATION_HELPER_VECTOR[0] = i;
			group = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			header = this._owner.groupToHeaderData(group);
			if (header != null)
			{
				totalCount++;
			}
			groupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			totalCount += groupLength;
			if (totalCount > displayIndex)
			{
				itemIndex = displayIndex - (totalCount - groupLength);
				if (itemIndex == -1)
				{
					result[0] = -1;
					result[1] = -1;
				}
				else
				{
					result[0] = i;
					result[1] = itemIndex;
				}
				LOCATION_HELPER_VECTOR.resize(0);
				return;
			}
			footer = this._owner.groupToFooterData(group);
			if (footer != null)
			{
				totalCount++;
			}
		}
		//we didn't find it!
		result[0] = -1;
		result[1] = -1;
		LOCATION_HELPER_VECTOR.resize(0);
	}
	
	private function locationToDisplayIndex(groupIndex:Int, itemIndex:Int):Int
	{
		LOCATION_HELPER_VECTOR.resize(1);
		var displayIndex:Int = 0;
		var groupCount:Int = this._dataProvider.getLengthAtLocation();
		var group:Dynamic;
		var header:Dynamic;
		var groupLength:Int;
		var footer:Dynamic;
		for (i in 0...groupCount)
		{
			if (itemIndex < 0 && groupIndex == i)
			{
				LOCATION_HELPER_VECTOR.resize(0);
				return displayIndex;
			}
			LOCATION_HELPER_VECTOR[0] = i;
			group = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			header = this._owner.groupToHeaderData(group);
			if (header != null)
			{
				displayIndex++;
			}
			groupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			for (j in 0...groupLength)
			{
				if (groupIndex == i && itemIndex == j)
				{
					LOCATION_HELPER_VECTOR.resize(0);
					return displayIndex;
				}
				displayIndex++;
			}
			footer = this._owner.groupToFooterData(group);
			if (footer != null)
			{
				displayIndex++;
			}
		}
		LOCATION_HELPER_VECTOR.resize(0);
		return -1;
	}
	
	private function indexToItemRendererType(groupIndex:Int, itemIndex:Int):Class<Dynamic>
	{
		var groupLength:Int = 0;
		if (this._dataProvider != null && this._dataProvider.getLengthAtLocation() != -1)
		{
			LOCATION_HELPER_VECTOR.resize(1);
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			groupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
		}
		if (itemIndex == 0)
		{
			if (this._singleItemRendererType != null && groupLength == 1)
			{
				return this._singleItemRendererType;
			}
			else if (this._firstItemRendererType != null)
			{
				return this._firstItemRendererType;
			}
		}
		if (this._lastItemRendererType != null && itemIndex == (groupLength - 1))
		{
			return this._lastItemRendererType;
		}
		return this._itemRendererType;
	}
	
	private function indexToCustomStyleName(groupIndex:Int, itemIndex:Int):String
	{
		var groupLength:Int = 0;
		if (this._dataProvider != null && this._dataProvider.getLengthAtLocation() != -1)
		{
			LOCATION_HELPER_VECTOR.resize(1);
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			groupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
		}
		if (itemIndex == 0)
		{
			if (this._customSingleItemRendererStyleName != null && groupLength == 1)
			{
				return this._customSingleItemRendererStyleName;
			}
			else if (this._customFirstItemRendererStyleName != null)
			{
				return this._customFirstItemRendererStyleName;
			}
		}
		if (this._customLastItemRendererStyleName != null && itemIndex == (groupLength - 1))
		{
			return this._customLastItemRendererStyleName;
		}
		return this._customItemRendererStyleName;
	}
	
	private function getFactoryID(item:Dynamic, groupIndex:Int, itemIndex:Int):String
	{
		var factoryID:String = null;
		if (this._factoryIDFunction != null)
		{
			if (ArgumentsCount.count_args(this._factoryIDFunction) == 1)
			{
				factoryID = this._factoryIDFunction(item);
			}
			else
			{
				factoryID = this._factoryIDFunction(item, groupIndex, itemIndex);
			}
		}
		if (factoryID != null)
		{
			return factoryID;
		}
		var groupLength:Int = 0;
		if (this._dataProvider != null && this._dataProvider.getLengthAtLocation() != -1)
		{
			LOCATION_HELPER_VECTOR.resize(1);
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			groupLength = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
		}
		if (itemIndex == 0)
		{
			if ((this._singleItemRendererType != null ||
				this._singleItemRendererFactory != null ||
				this._customSingleItemRendererStyleName != null) &&
				groupLength == 1)
			{
				return SINGLE_ITEM_RENDERER_FACTORY_ID;
			}
			else if (this._firstItemRendererType != null || this._firstItemRendererFactory != null || this._customFirstItemRendererStyleName != null)
			{
				return FIRST_ITEM_RENDERER_FACTORY_ID;
			}
		}
		if ((this._lastItemRendererType != null ||
			this._lastItemRendererFactory != null ||
			this._customLastItemRendererStyleName != null) &&
			itemIndex == (groupLength - 1))
		{
			return LAST_ITEM_RENDERER_FACTORY_ID;
		}
		return null;
	}
	
	private function factoryIDToFactory(id:String, groupIndex:Int, itemIndex:Int):Function
	{
		if (id != null)
		{
			if (id == FIRST_ITEM_RENDERER_FACTORY_ID)
			{
				if (this._firstItemRendererFactory != null)
				{
					return this._firstItemRendererFactory;
				}
				else
				{
					return this._itemRendererFactory;
				}
			}
			else if (id == LAST_ITEM_RENDERER_FACTORY_ID)
			{
				if (this._lastItemRendererFactory != null)
				{
					return this._lastItemRendererFactory;
				}
				else
				{
					return this._itemRendererFactory;
				}
			}
			else if (id == SINGLE_ITEM_RENDERER_FACTORY_ID)
			{
				if (this._singleItemRendererFactory != null)
				{
					return this._singleItemRendererFactory;
				}
				else
				{
					return this._itemRendererFactory;
				}
			}
			if (this._itemRendererFactories.exists(id))
			{
				return this._itemRendererFactories[id];
			}
			else
			{
				throw new Error("Cannot find item renderer factory for ID \"" + id + "\".");
			}
		}
		return this._itemRendererFactory;
	}
	
	private function factoryIDToStorage(id:String, groupIndex:Int, itemIndex:Int):GroupItemRendererFactoryStorage
	{
		if (id != null)
		{
			if (this._itemStorageMap.exists(id))
			{
				return this._itemStorageMap[id];
			}
			var storage:GroupItemRendererFactoryStorage = new GroupItemRendererFactoryStorage();
			this._itemStorageMap[id] = storage;
			return storage;
		}
		return this._defaultItemRendererStorage;
	}
	
	private function getHeaderFactoryID(header:Dynamic, groupIndex:Int):String
	{
		if (this._headerFactoryIDFunction == null)
		{
			return null;
		}
		if (ArgumentsCount.count_args(this._headerFactoryIDFunction) == 1)
		{
			return this._headerFactoryIDFunction(header);
		}
		return this._headerFactoryIDFunction(header, groupIndex);
	}
	
	private function getFooterFactoryID(footer:Dynamic, groupIndex:Int):String
	{
		if (this._footerFactoryIDFunction == null)
		{
			return null;
		}
		if (ArgumentsCount.count_args(this._footerFactoryIDFunction) == 1)
		{
			return this._footerFactoryIDFunction(footer);
		}
		return this._footerFactoryIDFunction(footer, groupIndex);
	}
	
	private function headerFactoryIDToFactory(id:String):Function
	{
		if (id != null)
		{
			if (this._headerRendererFactories.exists(id))
			{
				return this._headerRendererFactories[id];
			}
			else
			{
				throw new Error("Cannot find header renderer factory for ID \"" + id + "\".");
			}
		}
		return this._headerRendererFactory;
	}
	
	private function headerFactoryIDToStorage(id:String):HeaderRendererFactoryStorage
	{
		if (id != null)
		{
			if (this._headerStorageMap.exists(id))
			{
				return this._headerStorageMap[id];
			}
			var storage:HeaderRendererFactoryStorage = new HeaderRendererFactoryStorage();
			this._headerStorageMap[id] = storage;
			return storage;
		}
		return this._defaultHeaderRendererStorage;
	}
	
	private function footerFactoryIDToFactory(id:String):Function
	{
		if (id != null)
		{
			if (this._footerRendererFactories.exists(id))
			{
				return this._footerRendererFactories[id];
			}
			else
			{
				throw new Error("Cannot find footer renderer factory for ID \"" + id + "\".");
			}
		}
		return this._footerRendererFactory;
	}
	
	private function footerFactoryIDToStorage(id:String):FooterRendererFactoryStorage
	{
		if (id != null)
		{
			if (this._footerStorageMap.exists(id))
			{
				return this._footerStorageMap[id];
			}
			var storage:FooterRendererFactoryStorage = new FooterRendererFactoryStorage();
			this._footerStorageMap[id] = storage;
			return storage;
		}
		return this._defaultFooterRendererStorage;
	}
	
	private function childProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	private function dataProvider_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	private function dataProvider_addItemHandler(event:Event, indices:Array<Int>):Void
	{
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		var groupIndex:Int = indices[0];
		if (indices.length > 1) //adding an item
		{
			var itemIndex:Int = indices[1];
			var itemDisplayIndex:Int = this.locationToDisplayIndex(groupIndex, itemIndex);
			layout.addToVariableVirtualCacheAtIndex(itemDisplayIndex);
		}
		else //adding a whole group
		{
			var headerDisplayIndex:Int = this.groupToHeaderDisplayIndex(groupIndex);
			if (headerDisplayIndex != -1)
			{
				layout.addToVariableVirtualCacheAtIndex(headerDisplayIndex);
			}
			LOCATION_HELPER_VECTOR.resize(1);
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			var groupLength:Int = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
			if (groupLength > 0)
			{
				var displayIndex:Int = headerDisplayIndex;
				if (displayIndex < 0)
				{
					displayIndex = this.locationToDisplayIndex(groupIndex, 0);
				}
				groupLength += displayIndex;
				for (i in displayIndex...groupLength)
				{
					layout.addToVariableVirtualCacheAtIndex(displayIndex);
				}
			}
			var footerDisplayIndex:Int = this.groupToFooterDisplayIndex(groupIndex);
			if (footerDisplayIndex != -1)
			{
				layout.addToVariableVirtualCacheAtIndex(footerDisplayIndex);
			}
		}
	}
	
	private function dataProvider_removeItemHandler(event:Event, indices:Array<Int>):Void
	{
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		var groupIndex:Int = indices[0];
		if (indices.length > 1) //removing an item
		{
			var itemIndex:Int = indices[1];
			var displayIndex:Int = this.locationToDisplayIndex(groupIndex, itemIndex);
			layout.removeFromVariableVirtualCacheAtIndex(displayIndex);
		}
		else //removing a whole group
		{
			//TODO: figure out the length of the previous group so that we
			//don't need to reset the whole cache
			layout.resetVariableVirtualCache();
		}
	}
	
	private function dataProvider_replaceItemHandler(event:Event, indices:Array<Int>):Void
	{
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		var groupIndex:Int = indices[0];
		if (indices.length > 1) //replacing an item
		{
			var itemIndex:Int = indices[1];
			var displayIndex:Int = this.locationToDisplayIndex(groupIndex, itemIndex);
			layout.resetVariableVirtualCacheAtIndex(displayIndex);
		}
		else //replacing a whole group
		{
			//TODO: figure out the length of the previous group so that we
			//don't need to reset the whole cache
			layout.resetVariableVirtualCache();
		}
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
	
	private function dataProvider_updateItemHandler(event:Event, indices:Array<Int>):Void
	{
		var groupIndex:Int = indices[0];
		var item:Dynamic;
		var itemRenderer:IGroupedListItemRenderer;
		if (indices.length > 1) //updating a single item
		{
			var itemIndex:Int = indices[1];
			LOCATION_HELPER_VECTOR.resize(2);
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			LOCATION_HELPER_VECTOR[1] = itemIndex;
			item = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
			itemRenderer = this.itemToItemRenderer(item);
			if (itemRenderer != null)
			{
				//in order to display the same item with modified properties, this
				//hack tricks the item renderer into thinking that it has been given
				//a different item to render.
				itemRenderer.data = null;
				itemRenderer.data = item;
				if (this._explicitVisibleWidth != this._explicitVisibleWidth || //isNaN
					this._explicitVisibleHeight != this._explicitVisibleHeight) //isNaN
				{
					this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
					this.invalidateParent(FeathersControl.INVALIDATION_FLAG_SIZE);
				}
			}
		}
		else //updating a whole group
		{
			LOCATION_HELPER_VECTOR.resize(1);
			LOCATION_HELPER_VECTOR[0] = groupIndex;
			var groupLength:Int = this._dataProvider.getLengthAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(2);
			for (i in 0...groupLength)
			{
				LOCATION_HELPER_VECTOR[1] = i;
				item = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
				if (item != null)
				{
					itemRenderer = this.itemToItemRenderer(item);
					if (itemRenderer != null)
					{
						itemRenderer.data = null;
						itemRenderer.data = item;
					}
				}
			}
			LOCATION_HELPER_VECTOR.resize(1);
			var group:Dynamic = this._dataProvider.getItemAtLocation(LOCATION_HELPER_VECTOR);
			LOCATION_HELPER_VECTOR.resize(0);
			item = this._owner.groupToHeaderData(group);
			if (item != null)
			{
				var headerRenderer:IGroupedListHeaderRenderer = this.headerDataToHeaderRenderer(item);
				if (headerRenderer != null)
				{
					headerRenderer.data = null;
					headerRenderer.data = item;
				}
			}
			item = this._owner.groupToFooterData(group);
			if (item != null)
			{
				var footerRenderer:IGroupedListFooterRenderer = this.footerDataToFooterRenderer(item);
				if (footerRenderer != null)
				{
					footerRenderer.data = null;
					footerRenderer.data = item;
				}
			}
			
			//we need to invalidate because the group may have more or fewer items
			this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
			
			var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
			if (layout == null || !layout.hasVariableItemDimensions)
			{
				return;
			}
			//TODO: figure out the length of the previous group so that we
			//don't need to reset the whole cache
			layout.resetVariableVirtualCache();
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
	
	private function layout_changeHandler(event:Event):Void
	{
		if (this._ignoreLayoutChanges)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	private function itemRenderer_resizeHandler(event:Event):Void
	{
		if (this._ignoreRendererResizing)
		{
			return;
		}
		//if (event.currentTarget == this._typicalItemRenderer && !this._typicalItemIsInDataProvider)
		if (cast(event.currentTarget, IGroupedListItemRenderer) == this._typicalItemRenderer && !this._typicalItemIsInDataProvider)
		{
			return;
		}
		var renderer:IGroupedListItemRenderer = cast event.currentTarget;
		if (renderer.layoutIndex < 0)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.resetVariableVirtualCacheAtIndex(renderer.layoutIndex, cast renderer);
	}
	
	private function headerRenderer_resizeHandler(event:Event):Void
	{
		if (this._ignoreRendererResizing)
		{
			return;
		}
		var renderer:IGroupedListHeaderRenderer = cast event.currentTarget;
		if (renderer.layoutIndex < 0)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.resetVariableVirtualCacheAtIndex(renderer.layoutIndex, cast renderer);
	}
	
	private function footerRenderer_resizeHandler(event:Event):Void
	{
		if (this._ignoreRendererResizing)
		{
			return;
		}
		var renderer:IGroupedListFooterRenderer = cast event.currentTarget;
		if (renderer.layoutIndex < 0)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		layout.resetVariableVirtualCacheAtIndex(renderer.layoutIndex, cast renderer);
	}
	
	private function renderer_triggeredHandler(event:Event):Void
	{
		var renderer:IGroupedListItemRenderer = cast event.currentTarget;
		this.parent.dispatchEventWith(Event.TRIGGERED, false, renderer.data);
	}
	
	private function renderer_changeHandler(event:Event):Void
	{
		if (this._ignoreSelectionChanges)
		{
			return;
		}
		var renderer:IGroupedListItemRenderer = cast event.currentTarget;
		if (!this._isSelectable || this._owner.isScrolling)
		{
			renderer.isSelected = false;
			return;
		}
		if (renderer.isSelected)
		{
			this.setSelectedLocation(renderer.groupIndex, renderer.itemIndex);
		}
		else
		{
			this.setSelectedLocation(-1, -1);
		}
	}
	
}

class GroupItemRendererFactoryStorage
{
	public function new()
	{
		
	}
	
	public var activeItemRenderers:Array<IGroupedListItemRenderer> = new Array<IGroupedListItemRenderer>();
	public var inactiveItemRenderers:Array<IGroupedListItemRenderer> = new Array<IGroupedListItemRenderer>();
}

class HeaderRendererFactoryStorage
{
	public function new()
	{
		
	}
	
	public var activeHeaderRenderers:Array<IGroupedListHeaderRenderer> = new Array<IGroupedListHeaderRenderer>();
	public var inactiveHeaderRenderers:Array<IGroupedListHeaderRenderer> = new Array<IGroupedListHeaderRenderer>();
}

class FooterRendererFactoryStorage
{
	public function new()
	{

	}

	public var activeFooterRenderers:Array<IGroupedListFooterRenderer> = new Array<IGroupedListFooterRenderer>();
	public var inactiveFooterRenderers:Array<IGroupedListFooterRenderer> = new Array<IGroupedListFooterRenderer>();
}