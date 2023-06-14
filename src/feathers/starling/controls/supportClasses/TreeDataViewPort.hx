/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.supportClasses;

import feathers.starling.controls.Scroller;
import feathers.starling.controls.Tree;
import feathers.starling.controls.renderers.ITreeItemRenderer;
import feathers.starling.core.FeathersControl;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IValidating;
import feathers.starling.data.IHierarchicalCollection;
import feathers.starling.data.IListCollection;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.ILayout;
import feathers.starling.layout.IVariableVirtualLayout;
import feathers.starling.layout.IVirtualLayout;
import feathers.starling.layout.LayoutBoundsResult;
import feathers.starling.layout.ViewPortBounds;
import feathers.starling.controls.supportClasses.IViewPort;
import feathers.starling.utils.type.ArgumentsCount;
import feathers.starling.utils.type.SafeCast;
import haxe.Constraints.Function;
import haxe.ds.ObjectMap;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.utils.Pool;

/**
 * @private
 * Used internally by Tree. Not meant to be used on its own.
 *
 * @productversion Feathers 3.3.0
 */
class TreeDataViewPort extends FeathersControl implements IViewPort
{
	private static inline var INVALIDATION_FLAG_ITEM_RENDERER_FACTORY:String = "itemRendererFactory";
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
	
	private var _actualVisibleWidth:Float = Math.NaN;
	
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
	
	private var _actualVisibleHeight:Float;
	
	private var _explicitVisibleHeight:Float = Math.NaN;
	
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
		return this._explicitVisibleHeight;
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
	
	public var owner(get, set):Tree;
	private var _owner:Tree;
	private function get_owner():Tree { return this._owner; }
	private function set_owner(value:Tree):Tree
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
			/*this._dataProvider.removeEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
			this._dataProvider.removeEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);*/
		}
		this._dataProvider = value;
		if (this._dataProvider != null)
		{
			this._dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
			/*this._dataProvider.addEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
			this._dataProvider.addEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);*/
		}
		if (Std.isOfType(this._layout, IVariableVirtualLayout))
		{
			cast(this._layout, IVariableVirtualLayout).resetVariableVirtualCache();
		}
		this._updateForDataReset = true;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataProvider;
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
			(this._explicitVisibleWidth != this._explicitVisibleWidth || //isNaN
			this._explicitVisibleHeight != this._explicitVisibleHeight); //isNaN
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
		if (!this._isSelectable)
		{
			this.selectedItem = null;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._isSelectable;
	}
	
	public var selectedItem(get, set):Dynamic;
	private var _selectedItem:Dynamic;
	private function get_selectedItem():Dynamic { return this._selectedItem; }
	private function set_selectedItem(value:Dynamic):Dynamic
	{
		if (this._selectedItem == value)
		{
			return value;
		}
		this._selectedItem = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
		return this._selectedItem;
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
	
	public var itemRendererFactory(get, set):Void->ITreeItemRenderer;
	private var _itemRendererFactory:Void->ITreeItemRenderer;
	private function get_itemRendererFactory():Void->ITreeItemRenderer { return this._itemRendererFactory; }
	private function set_itemRendererFactory(value:Void->ITreeItemRenderer):Void->ITreeItemRenderer
	{
		if (this._itemRendererFactory == value)
		{
			return value;
		}
		
		this._itemRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererFactory;
	}
	
	public var itemRendererFactories(get, set):Map<String, Void->ITreeItemRenderer>;
	private var _itemRendererFactories:Map<String, Void->ITreeItemRenderer>;
	private function get_itemRendererFactories():Map<String, Void->ITreeItemRenderer> { return this._itemRendererFactories; }
	private function set_itemRendererFactories(value:Map<String, Void->ITreeItemRenderer>):Map<String, Void->ITreeItemRenderer>
	{
		if (this._itemRendererFactories == value)
		{
			return value;
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
	
	public var openBranches(get, set):IListCollection;
	private var _openBranches:IListCollection;
	private function get_openBranches():IListCollection { return this._openBranches; }
	private function set_openBranches(value:IListCollection):IListCollection
	{
		if (this._openBranches == value)
		{
			return value;
		}
		if (this._openBranches != null)
		{
			this._openBranches.removeEventListener(Event.CHANGE, openBranches_changeHandler);
		}
		this._openBranches = value;
		if (this._openBranches != null)
		{
			this._openBranches.addEventListener(Event.CHANGE, openBranches_changeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._openBranches;
	}
	
	private var _typicalItemIsInDataProvider:Bool = false;
	private var _typicalItemRenderer:ITreeItemRenderer;
	
	private var _layoutItems:Array<DisplayObject> = new Array<DisplayObject>();
	
	private var _unrenderedItems:Array<Dynamic> = new Array<Dynamic>();
	private var _defaultItemRendererStorage:TreeItemRendererFactoryStorage = new TreeItemRendererFactoryStorage();
	private var _itemStorageMap:Map<String, TreeItemRendererFactoryStorage> = new Map<String, TreeItemRendererFactoryStorage>();
	private var _itemRendererMap:ObjectMap<Dynamic, ITreeItemRenderer> = new ObjectMap<Dynamic, ITreeItemRenderer>();
	private var _minimumItemCount:Int;
	
	public function calculateNavigationDestination(location:Array<Int>, keyCode:Int, result:Array<Int>):Void
	{
		var displayIndex:Int = this.locationToDisplayIndex(location, false);
		if (displayIndex == -1)
		{
			throw new ArgumentError("Cannot calculate navigation destination for location: " + location);
		}
		var newDisplayIndex:Int = this._layout.calculateNavigationDestination(this._layoutItems, displayIndex, keyCode, this._layoutResult);
		this.displayIndexToLocation(newDisplayIndex, result);
	}
	
	public function getScrollPositionForLocation(location:Array<Int>, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var displayIndex:Int = this.locationToDisplayIndex(location, true);
		if (displayIndex == -1)
		{
			throw new ArgumentError("Cannot calculate scroll position for location: " + location);
		}
		return this._layout.getScrollPositionForIndex(displayIndex, this._layoutItems,
			0, 0, this._actualVisibleWidth, this._actualVisibleHeight, result);
	}
	
	public function getNearestScrollPositionForIndex(location:Array<Int>, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var displayIndex:Int = this.locationToDisplayIndex(location, true);
		if (displayIndex == -1)
		{
			throw new ArgumentError("Cannot calculate nearest scroll position for location: " + location);
		}
		return this._layout.getNearestScrollPositionForIndex(displayIndex, this._horizontalScrollPosition,
			this._verticalScrollPosition, this._layoutItems, 0, 0, this._actualVisibleWidth, this._actualVisibleHeight, result);
	}
	
	public function itemToItemRenderer(item:Dynamic):ITreeItemRenderer
	{
		// TODO : XML
		//if(item is XML || item is XMLList)
		//{
			//return ITreeItemRenderer(this._itemRendererMap[item.toXMLString()]);
		//}
		return this._itemRendererMap.get(item);
	}
	
	override public function dispose():Void
	{
		this.refreshInactiveItemRenderers(null, true);
		if (this._itemStorageMap != null)
		{
			for (factoryID in this._itemStorageMap.keys())
			{
				this.refreshInactiveItemRenderers(factoryID, true);
			}
			this._itemStorageMap.clear();
		}
		this.owner = null;
		this.dataProvider = null;
		this.layout = null;
		this._itemRendererMap.clear();
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
			this.refreshInactiveItemRenderers(null, itemRendererInvalid);
			if (this._itemStorageMap != null)
			{
				for (factoryID in this._itemStorageMap.keys())
				{
					this.refreshInactiveItemRenderers(factoryID, itemRendererInvalid);
				}
			}
		}
		if (dataInvalid || layoutInvalid || itemRendererInvalid)
		{
			this.refreshLayoutTypicalItem();
		}
		if (basicsInvalid)
		{
			this.refreshItemRenderers();
		}
		var oldIgnoreSelectionChanges:Bool;
		if (selectionInvalid || basicsInvalid)
		{
			//unlike resizing renderers and layout changes, we only want to
			//stop listening for selection changes when we're forcibly
			//updating selection. other property changes on item renderers
			//can validly change selection, and we need to detect that.
			oldIgnoreSelectionChanges = this._ignoreSelectionChanges;
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
	
	// TODO : empty function, is this an issue
	private function displayIndexToLocation(displayIndex:Int, result:Array<Int>):Void
	{
	}
	
	private var _displayIndex:Int;

	private function locationToDisplayIndex(location:Array<Int>, returnNearestIfBranchNotOpen:Bool):Int
	{
		this._displayIndex = -1;
		var result:Dynamic = this.locationToDisplayIndexAtBranch(new Array<Int>(), location, returnNearestIfBranchNotOpen);
		if (result != null)
		{
			return this._displayIndex;
		}
		return -1;
	}
	
	private function locationToDisplayIndexAtBranch(locationOfBranch:Array<Int>, locationToFind:Array<Int>, returnNearestIfBranchNotOpen:Bool):Dynamic
	{
		var childCount:Int = this._dataProvider.getLengthAtLocation(locationOfBranch);
		var child:Dynamic;
		var every:Bool;
		var count:Int;
		for (i in 0...childCount)
		{
			this._displayIndex++;
			locationOfBranch[locationOfBranch.length] = i;
			child = this._dataProvider.getItemAtLocation(locationOfBranch);
			if (locationOfBranch.length == locationToFind.length)
			{
				//var every:Boolean = locationOfBranch.every(function(item:int, index:int, source:Vector.<int>):Boolean
				//{
					//return item === locationToFind[index];
				//});
				every = true;
				count = locationOfBranch.length;
				for (j in 0...count)
				{
					if (locationOfBranch[j] != locationToFind[j])
					{
						every = false;
						break;
					}
				}
				
				if (every)
				{
					return child;
				}
			}
			if (this._dataProvider.isBranch(child))
			{
				if (this._owner.isBranchOpen(child))
				{
					var result:Dynamic = this.locationToDisplayIndexAtBranch(locationOfBranch, locationToFind, returnNearestIfBranchNotOpen);
					if (result != null)
					{
						return result;
					}
				}
				else if (returnNearestIfBranchNotOpen)
				{
					//if the location is inside a closed branch
					//return that branch
					//every = locationOfBranch.every(function(item:int, index:int, source:Vector.<int>):Boolean
					//{
						//return item === locationToFind[index];
					//});
					every = true;
					count = locationOfBranch.length;
					for (j in 0...count)
					{
						if (locationOfBranch[j] != locationToFind[j])
						{
							every = false;
							break;
						}
					}
					if (every)
					{
						return child;
					}
				}
			}
			locationOfBranch.resize(locationOfBranch.length - 1);
		}
		//location was not found!
		return null;
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
	
	private function refreshLayoutTypicalItem():Void
	{
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			//the old layout was virtual, but this one isn't
			if (!this._typicalItemIsInDataProvider && this._typicalItemRenderer != null)
			{
				//it's safe to destroy this renderer
				this.destroyItemRenderer(this._typicalItemRenderer);
				this._typicalItemRenderer = null;
			}
			return;
		}
		var typicalItemLocation:Array<Int> = null;
		var newTypicalItemIsInDataProvider:Bool = false;
		var typicalItem:Dynamic = this._typicalItem;
		if (typicalItem != null)
		{
			if (this._dataProvider != null)
			{
				typicalItemLocation = this._dataProvider.getItemLocation(typicalItem);
				newTypicalItemIsInDataProvider = typicalItemLocation != null && typicalItemLocation.length != 0;
			}
		}
		else
		{
			if (this._dataProvider != null && this._dataProvider.getLengthAtLocation() != 0)
			{
				newTypicalItemIsInDataProvider = true;
				typicalItem = this._dataProvider.getItemAt([0]);
				typicalItemLocation = [0];
			}
		}
		
		var typicalItemRenderer:ITreeItemRenderer = null;
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
				
				//the location may have changed if items were added,
				//removed or reordered in the data provider
				typicalItemRenderer.location = typicalItemLocation;
			}
			if (typicalItemRenderer == null && this._typicalItemRenderer != null)
			{
				//the typical item has changed, and doesn't have an item
				//renderer yet. the previous typical item had an item
				//renderer, so we will try to reuse it.
				
				//we can reuse the existing typical item renderer if the old
				//typical item wasn't in the data provider. otherwise, it
				//may still be needed for the same item.
				var canReuse:Bool = !this._typicalItemIsInDataProvider;
				var oldTypicalItemRemoved:Bool = this._typicalItemIsInDataProvider &&
					this._dataProvider != null && this._dataProvider.getItemLocation(this._typicalItemRenderer.data) == null;
				if (!canReuse && oldTypicalItemRemoved)
				{
					//special case: if the old typical item was in the data
					//provider, but it has been removed, it's safe to reuse.
					canReuse = true;
				}
				if (canReuse)
				{
					//we can't reuse if the factoryID has changed, though!
					var factoryID:String = null;
					if (this._factoryIDFunction != null)
					{
						factoryID = this.getFactoryID(typicalItem, typicalItemLocation);
					}
					if (this._typicalItemRenderer.factoryID != factoryID)
					{
						canReuse = false;
					}
				}
				if (canReuse)
				{
					//we can reuse the item renderer used for the old
					//typical item!
					
					//if the old typical item was in the data provider,
					//remove it from the renderer map.
					if (this._typicalItemIsInDataProvider)
					{
						var oldData:Dynamic = this._typicalItemRenderer.data;
						// TODO : XML
						//if (oldData is XML || oldData is XMLList)
						//{
							//delete this._itemRendererMap[oldData.toXMLString()];
						//}
						//else
						//{
							this._itemRendererMap.remove(oldData);
						//}
					}
					typicalItemRenderer = this._typicalItemRenderer;
					typicalItemRenderer.data = typicalItem;
					typicalItemRenderer.location = typicalItemLocation;
					//if the new typical item is in the data provider, add it
					//to the renderer map.
					if (newTypicalItemIsInDataProvider)
					{
						// TODO : XML
						//if (typicalItem is XML || typicalItem is XMLList)
						//{
							//this._itemRendererMap[typicalItem.toXMLString()] = typicalItemRenderer;
						//}
						//else
						//{
							this._itemRendererMap.set(typicalItem, typicalItemRenderer);
						//}
					}
				}
			}
			if (typicalItemRenderer == null)
			{
				//if we still don't have a typical item renderer, we need to
				//create a new one.
				typicalItemRenderer = this.createItemRenderer(typicalItem, typicalItemLocation, 0, false, !newTypicalItemIsInDataProvider);
				if (!this._typicalItemIsInDataProvider && this._typicalItemRenderer != null)
				{
					//get rid of the old typical item renderer if it isn't
					//needed anymore.  since it was not in the data
					//provider, we don't need to mess with the renderer map
					//dictionary or dispatch any events.
					this.destroyItemRenderer(this._typicalItemRenderer);
					this._typicalItemRenderer = null;
				}
			}
		}
		
		virtualLayout.typicalItem = typicalItemRenderer != null ? cast typicalItemRenderer : null;
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
	
	private function refreshItemRenderers():Void
	{
		var storage:TreeItemRendererFactoryStorage;
		if (this._typicalItemRenderer != null && this._typicalItemIsInDataProvider)
		{
			storage = this.factoryIDToStorage(this._typicalItemRenderer.factoryID);
			var inactiveItemRenderers:Array<ITreeItemRenderer> = storage.inactiveItemRenderers;
			var activeItemRenderers:Array<ITreeItemRenderer> = storage.activeItemRenderers;
			//this renderer is already is use by the typical item, so we
			//don't want to allow it to be used by other items.
			var inactiveIndex:Int = inactiveItemRenderers.indexOf(this._typicalItemRenderer);
			if (inactiveIndex != -1)
			{
				inactiveItemRenderers[inactiveIndex] = null;
			}
			//if refreshLayoutTypicalItem() was called, it will have already
			//added the typical item renderer to the active renderers. if
			//not, we need to do it here.
			var activeRendererCount:Int = activeItemRenderers.length;
			if (activeRendererCount == 0)
			{
				activeItemRenderers[activeRendererCount] = this._typicalItemRenderer;
			}
		}
		
		this.findUnrenderedData();
		this.recoverInactiveItemRenderers(this._defaultItemRendererStorage);
		if (this._itemStorageMap != null)
		{
			for (itemStorage in this._itemStorageMap)
			{
				//storage = this._itemStorageMap[factoryID];
				this.recoverInactiveItemRenderers(itemStorage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveItemRenderers(this._defaultItemRendererStorage, this._minimumItemCount);
		if (this._itemStorageMap != null)
		{
			for (itemStorage in this._itemStorageMap)
			{
				//storage = this._itemStorageMap[factoryID];
				this.freeInactiveItemRenderers(itemStorage, 1);
			}
		}
		this._updateForDataReset = false;
	}
	
	private function findTotalLayoutCount(location:Array<Int>):Int
	{
		var itemCount:Int = 0;
		if (this._dataProvider != null)
		{
			itemCount = this._dataProvider.getLengthAtLocation(location);
		}
		var result:Int = itemCount;
		var item:Dynamic;
		for (i in 0...itemCount)
		{
			location[location.length] = i;
			item = this._dataProvider.getItemAtLocation(location);
			if (this._dataProvider.isBranch(item) &&
				this._openBranches.contains(item))
			{
				result += this.findTotalLayoutCount(location);
			}
			location.resize(location.length - 1);
		}
		return result;
	}
	
	private function findUnrenderedDataForLocation(location:Array<Int>, currentIndex:Int):Int
	{
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		var useVirtualLayout:Bool = virtualLayout != null && virtualLayout.useVirtualLayout;
		var itemCount:Int = 0;
		if (this._dataProvider != null)
		{
			itemCount = this._dataProvider.getLengthAtLocation(location);
		}
		var item:Dynamic;
		for (i in 0...itemCount)
		{
			location[location.length] = i;
			item = this._dataProvider.getItemAtLocation(location);
			
			if (useVirtualLayout && HELPER_VECTOR.indexOf(currentIndex) == -1)
			{
				if (this._typicalItemRenderer != null &&
					this._typicalItemIsInDataProvider &&
					this._typicalItemRenderer.data == item)
				{
					//the index may have changed if items were added, removed,
					//or reordered in the data provider
					this._typicalItemRenderer.layoutIndex = currentIndex;
				}
				this._layoutItems[currentIndex] = null;
			}
			else
			{
				this.findRendererForItem(item, location.copy(), currentIndex);
			}
			currentIndex++;
			
			if (this._dataProvider.isBranch(item) &&
				this._openBranches.contains(item))
			{
				currentIndex = this.findUnrenderedDataForLocation(location, currentIndex);
			}
			location.resize(location.length - 1);
		}
		return currentIndex;
	}
	
	private function findUnrenderedData():Void
	{
		LOCATION_HELPER_VECTOR.resize(0);
		var totalLayoutCount:Int = this.findTotalLayoutCount(LOCATION_HELPER_VECTOR);
		LOCATION_HELPER_VECTOR.resize(0);
		this._layoutItems.resize(totalLayoutCount);
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
				
				this._minimumItemCount = Math.ceil(maximumViewPortEdge / minimumTypicalItemEdge) + 1;
			}
			else
			{
				this._minimumItemCount = 1;
			}
		}
		LOCATION_HELPER_VECTOR.resize(0);
		this.findUnrenderedDataForLocation(LOCATION_HELPER_VECTOR, 0);
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
	
	private function findRendererForItem(item:Dynamic, location:Array<Int>, layoutIndex:Int):Void
	{
		var itemRenderer:ITreeItemRenderer = this.itemToItemRenderer(item);
		if (this._factoryIDFunction != null && itemRenderer != null)
		{
			var newFactoryID:String = this.getFactoryID(itemRenderer.data, location);
			if (newFactoryID != itemRenderer.factoryID)
			{
				itemRenderer = null;
				// TODO : XML
				//if (item is XML || item is XMLList)
				//{
					//delete this._itemRendererMap[item.toXMLString()];
				//}
				//else
				//{
					this._itemRendererMap.remove(item);
				//}
			}
		}
		if (itemRenderer != null)
		{
			//the indices may have changed if items were added, removed,
			//or reordered in the data provider
			itemRenderer.location = location;
			itemRenderer.layoutIndex = layoutIndex;
			itemRenderer.isOpen = this._dataProvider.isBranch(item) && this._openBranches.contains(item);
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
				var storage:TreeItemRendererFactoryStorage = this.factoryIDToStorage(itemRenderer.factoryID);
				var activeItemRenderers:Array<ITreeItemRenderer> = storage.activeItemRenderers;
				var inactiveItemRenderers:Array<ITreeItemRenderer> = storage.inactiveItemRenderers;
				activeItemRenderers[activeItemRenderers.length] = itemRenderer;
				var inactiveIndex:Int = inactiveItemRenderers.indexOf(itemRenderer);
				if (inactiveIndex != -1)
				{
					inactiveItemRenderers.splice(inactiveIndex, 1);
				}
				else
				{
					throw new IllegalOperationError("TreeDataViewPort: item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
			}
			itemRenderer.visible = true;
			this._layoutItems[layoutIndex] = cast itemRenderer;
		}
		else
		{
			var pushIndex:Int = this._unrenderedItems.length;
			this._unrenderedItems[pushIndex] = location;
			pushIndex++;
			this._unrenderedItems[pushIndex] = layoutIndex;
		}
	}
	
	private function renderUnrenderedData():Void
	{
		LOCATION_HELPER_VECTOR.resize(2);
		var rendererCount:Int = this._unrenderedItems.length;
		var location:Array<Int>;
		var layoutIndex:Int;
		var item:Dynamic;
		var itemRenderer:ITreeItemRenderer;
		var i:Int = 0;
		while (i < rendererCount)
		{
			location = this._unrenderedItems.shift();
			layoutIndex = this._unrenderedItems.shift();
			item = this._dataProvider.getItemAtLocation(location);
			itemRenderer = this.createItemRenderer(item, location, layoutIndex, true, false);
			itemRenderer.visible = true;
			this._layoutItems[layoutIndex] = cast itemRenderer;
			i += 2;
		}
		LOCATION_HELPER_VECTOR.resize(0);
	}
	
	private function refreshInactiveItemRenderers(factoryID:String, itemRendererTypeIsInvalid:Bool):Void
	{
		var storage:TreeItemRendererFactoryStorage;
		if (factoryID != null)
		{
			storage = this._itemStorageMap[factoryID];
		}
		else
		{
			storage = this._defaultItemRendererStorage;
		}
		var temp:Array<ITreeItemRenderer> = storage.inactiveItemRenderers;
		storage.inactiveItemRenderers = storage.activeItemRenderers;
		storage.activeItemRenderers = temp;
		if (storage.activeItemRenderers.length != 0)
		{
			throw new IllegalOperationError("TreeDataViewPort: active renderers should be empty.");
		}
		if (itemRendererTypeIsInvalid)
		{
			this.recoverInactiveItemRenderers(storage);
			this.freeInactiveItemRenderers(storage, 0);
			if (this._typicalItemRenderer != null && this._typicalItemRenderer.factoryID == factoryID)
			{
				if (this._typicalItemIsInDataProvider)
				{
					var item:Dynamic = this._typicalItemRenderer.data;
					// TODO : XML
					//if (item is XML || item is XMLList)
					//{
						//delete this._itemRendererMap[item.toXMLString()];
					//}
					//else
					//{
						this._itemRendererMap.remove(item);
					//}
				}
				this.destroyItemRenderer(this._typicalItemRenderer);
				this._typicalItemRenderer = null;
				this._typicalItemIsInDataProvider = false;
			}
		}
		
		this._layoutItems.resize(0);
	}
	
	private function recoverInactiveItemRenderers(storage:TreeItemRendererFactoryStorage):Void
	{
		var inactiveItemRenderers:Array<ITreeItemRenderer> = storage.inactiveItemRenderers;
		
		var itemCount:Int = inactiveItemRenderers.length;
		var itemRenderer:ITreeItemRenderer;
		for (i in 0...itemCount)
		{
			itemRenderer = inactiveItemRenderers[i];
			if (itemRenderer == null || itemRenderer.data == null)
			{
				continue;
			}
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, itemRenderer);
			var item:Dynamic = itemRenderer.data;
			// TODO : XML
			//if (item is XML || item is XMLList)
			//{
				//delete this._itemRendererMap[item.toXMLString()];
			//}
			//else
			//{
				this._itemRendererMap.remove(item);
			//}
		}
	}
	
	private function freeInactiveItemRenderers(storage:TreeItemRendererFactoryStorage, minimumItemCount:Int):Void
	{
		var inactiveItemRenderers:Array<ITreeItemRenderer> = storage.inactiveItemRenderers;
		var activeItemRenderers:Array<ITreeItemRenderer> = storage.activeItemRenderers;
		var activeItemRenderersCount:Int = activeItemRenderers.length;
		
		//we may keep around some extra renderers to avoid too much
		//allocation and garbage collection. they'll be hidden.
		var itemCount:Int = inactiveItemRenderers.length;
		var keepCount:Int = minimumItemCount - activeItemRenderersCount;
		if (keepCount > itemCount)
		{
			keepCount = itemCount;
		}
		var itemRenderer:ITreeItemRenderer;
		var i:Int = 0;
		//for (i in 0...keepCount)
		while (i < keepCount)
		{
			i++;
			itemRenderer = inactiveItemRenderers.shift();
			if (itemRenderer == null)
			{
				keepCount++;
				if (itemCount < keepCount)
				{
					keepCount = itemCount;
				}
				continue;
			}
			itemRenderer.data = null;
			itemRenderer.location = null;
			itemRenderer.visible = false;
			activeItemRenderers[activeItemRenderersCount] = itemRenderer;
			activeItemRenderersCount++;
		}
		itemCount -= keepCount;
		for (i in 0...itemCount)
		{
			itemRenderer = inactiveItemRenderers.shift();
			if (itemRenderer == null)
			{
				continue;
			}
			this.destroyItemRenderer(itemRenderer);
		}
	}
	
	private function createItemRenderer(item:Dynamic, location:Array<Int>, layoutIndex:Int, useCache:Bool, isTemporary:Bool):ITreeItemRenderer
	{
		var factoryID:String = null;
		if (this._factoryIDFunction != null)
		{
			factoryID = this.getFactoryID(item, location);
		}
		var itemRendererFactory:Void->ITreeItemRenderer = this.factoryIDToFactory(factoryID);
		var storage:TreeItemRendererFactoryStorage = this.factoryIDToStorage(factoryID);
		var inactiveItemRenderers:Array<ITreeItemRenderer> = storage.inactiveItemRenderers;
		var activeItemRenderers:Array<ITreeItemRenderer> = storage.activeItemRenderers;
		var itemRenderer:ITreeItemRenderer = null;
		do
		{
			if (!useCache || isTemporary || inactiveItemRenderers.length == 0)
			{
				if (itemRendererFactory != null)
				{
					itemRenderer = itemRendererFactory();
				}
				else
				{
					itemRenderer = cast Type.createInstance(this._itemRendererType, []);
				}
				if (this._customItemRendererStyleName != null && this._customItemRendererStyleName.length != 0)
				{
					itemRenderer.styleNameList.add(this._customItemRendererStyleName);
				}
				this.addChild(cast itemRenderer);
			}
			else
			{
				itemRenderer = inactiveItemRenderers.shift();
			}
			//wondering why this all is in a loop?
			//_inactiveRenderers.shift() may return null because we're
			//storing null values instead of calling splice() to improve
			//performance.
		}
		while (itemRenderer == null);
		itemRenderer.data = item;
		itemRenderer.owner = this._owner;
		itemRenderer.factoryID = factoryID;
		itemRenderer.location = location;
		itemRenderer.layoutIndex = layoutIndex;
		var isBranch:Bool = this._dataProvider != null && this._dataProvider.isBranch(item);
		itemRenderer.isBranch = isBranch;
		itemRenderer.isOpen = isBranch && this._openBranches.contains(item);
		
		if (!isTemporary)
		{
			// TODO : XML
			//if (item is XML || item is XMLList)
			//{
				//this._itemRendererMap[item.toXMLString()] = itemRenderer;
			//}
			//else
			//{
				this._itemRendererMap.set(item, itemRenderer);
			//}
			activeItemRenderers[activeItemRenderers.length] = itemRenderer;
			itemRenderer.addEventListener(Event.TRIGGERED, itemRenderer_triggeredHandler);
			itemRenderer.addEventListener(Event.CHANGE, itemRenderer_changeHandler);
			itemRenderer.addEventListener(FeathersEventType.RESIZE, itemRenderer_resizeHandler);
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, itemRenderer);
		}
		
		return itemRenderer;
	}
	
	private function destroyItemRenderer(itemRenderer:ITreeItemRenderer):Void
	{
		itemRenderer.removeEventListener(Event.TRIGGERED, itemRenderer_triggeredHandler);
		itemRenderer.removeEventListener(Event.CHANGE, itemRenderer_changeHandler);
		itemRenderer.removeEventListener(FeathersEventType.RESIZE, itemRenderer_resizeHandler);
		itemRenderer.owner = null;
		itemRenderer.data = null;
		itemRenderer.location = null;
		itemRenderer.layoutIndex = -1;
		itemRenderer.factoryID = null;
		this.removeChild(cast itemRenderer, true);
	}
	
	private function getFactoryID(item:Dynamic, location:Array<Int>):String
	{
		if (this._factoryIDFunction == null)
		{
			return null;
		}
		if (ArgumentsCount.count_args(this._factoryIDFunction) == 2)
		{
			return this._factoryIDFunction(item, location);
		}
		return this._factoryIDFunction(item);
	}
	
	private function factoryIDToFactory(id:String):Void->ITreeItemRenderer
	{
		if (id != null)
		{
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
	
	private function factoryIDToStorage(id:String):TreeItemRendererFactoryStorage
	{
		if (id != null)
		{
			if (this._itemStorageMap.exists(id))
			{
				return this._itemStorageMap[id];
			}
			var storage:TreeItemRendererFactoryStorage = new TreeItemRendererFactoryStorage();
			this._itemStorageMap[id] = storage;
			return storage;
		}
		return this._defaultItemRendererStorage;
	}
	
	private function invalidateParent(flag:String = FeathersControl.INVALIDATION_FLAG_ALL):Void
	{
		cast(this.parent, Scroller).invalidate(flag);
	}
	
	private function refreshSelection():Void
	{
		var itemRenderer:ITreeItemRenderer;
		for (item in this._layoutItems)
		{
			itemRenderer = SafeCast.safe_cast(item, ITreeItemRenderer);
			if (itemRenderer != null)
			{
				itemRenderer.isSelected = itemRenderer.data == this._selectedItem;
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
	
	private function layout_changeHandler(event:Event):Void
	{
		if (this._ignoreLayoutChanges)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	private function dataProvider_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	private function itemRenderer_triggeredHandler(event:Event):Void
	{
		var itemRenderer:ITreeItemRenderer = cast event.currentTarget;
		this.parent.dispatchEventWith(Event.TRIGGERED, false, itemRenderer.data);
	}
	
	private function itemRenderer_changeHandler(event:Event):Void
	{
		if (this._ignoreSelectionChanges)
		{
			return;
		}
		var itemRenderer:ITreeItemRenderer = cast event.currentTarget;
		if (!this._isSelectable || this._owner.isScrolling)
		{
			itemRenderer.isSelected = false;
			return;
		}
		var isSelected:Bool = itemRenderer.isSelected;
		if (isSelected)
		{
			this.selectedItem = itemRenderer.data;
		}
		else
		{
			this.selectedItem = null;
		}
	}
	
	private function itemRenderer_resizeHandler(event:Event):Void
	{
		if (this._ignoreRendererResizing)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var itemRenderer:ITreeItemRenderer = cast event.currentTarget;
		if (itemRenderer == this._typicalItemRenderer && !this._typicalItemIsInDataProvider)
		{
			return;
		}
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		//var itemRenderer:ITreeItemRenderer = cast event.currentTarget;
		layout.resetVariableVirtualCacheAtIndex(itemRenderer.layoutIndex, cast itemRenderer);
	}
	
	private function openBranches_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
}

class TreeItemRendererFactoryStorage
{
	public function new()
	{
		
	}

	public var activeItemRenderers:Array<ITreeItemRenderer> = new Array<ITreeItemRenderer>();
	public var inactiveItemRenderers:Array<ITreeItemRenderer> = new Array<ITreeItemRenderer>();
}