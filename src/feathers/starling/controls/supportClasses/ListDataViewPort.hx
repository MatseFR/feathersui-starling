/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.supportClasses;

import feathers.starling.controls.List;
import feathers.starling.controls.renderers.IDragAndDropItemRenderer;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.core.FeathersControl;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IMeasureDisplayObject;
import feathers.starling.core.IValidating;
import feathers.starling.core.PropertyProxy;
import feathers.starling.data.IListCollection;
import feathers.starling.data.ListCollection;
import feathers.starling.display.RenderDelegate;
import feathers.starling.dragDrop.DragData;
import feathers.starling.dragDrop.DragDropManager;
import feathers.starling.events.CollectionEventType;
import feathers.starling.events.DragDropEvent;
import feathers.starling.events.ExclusiveTouch;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.IDragDropLayout;
import feathers.starling.layout.ILayout;
import feathers.starling.layout.ISpinnerLayout;
import feathers.starling.layout.ITrimmedVirtualLayout;
import feathers.starling.layout.IVariableVirtualLayout;
import feathers.starling.layout.IVirtualLayout;
import feathers.starling.layout.LayoutBoundsResult;
import feathers.starling.layout.ViewPortBounds;
import feathers.starling.motion.effectClasses.IEffectContext;
import feathers.starling.controls.Scroller;
import feathers.starling.controls.supportClasses.IViewPort;
import feathers.starling.system.DeviceCapabilities;
import feathers.starling.utils.type.ArgumentsCount;
import feathers.starling.utils.type.Property;
import feathers.starling.utils.type.SafeCast;
import haxe.Constraints.Function;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * @private
 * Used internally by List. Not meant to be used on its own.
 *
 * @productversion Feathers 1.0.0
 */
class ListDataViewPort extends FeathersControl implements IViewPort
{
	private static inline var INVALIDATION_FLAG_ITEM_RENDERER_FACTORY:String = "itemRendererFactory";
	
	private static var HELPER_VECTOR:Array<Int> = new Array<Int>();
	
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
			if (this.explicitVisibleWidth != this.explicitVisibleWidth && //isNaN
				(this.actualVisibleWidth < value || this.actualVisibleWidth == oldValue))
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
		if (this.explicitVisibleWidth != this.explicitVisibleWidth && //isNaN
			(this.actualVisibleWidth > value || this.actualVisibleWidth == oldValue))
		{
			//only invalidate if this change might affect the visibleWidth
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this.maxVisibleWidth;
	}
	
	private var actualVisibleWidth:Float = 0;
	
	private var explicitVisibleWidth:Float;
	
	public var visibleWidth(get, set):Float;
	private function get_visibleWidth():Float { return this.actualVisibleWidth; }
	private function set_visibleWidth(value:Float):Float
	{
		if (this.explicitVisibleWidth == value ||
			(value != value && this.explicitVisibleWidth != this.explicitVisibleWidth)) //isNaN
		{
			return value;
		}
		this.explicitVisibleWidth = value;
		if (this.actualVisibleWidth != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this.explicitVisibleWidth;
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
			if (this.explicitVisibleHeight != this.explicitVisibleHeight && //isNaN
				(this.actualVisibleHeight < value || this.actualVisibleHeight == oldValue))
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
		if (this.explicitVisibleHeight != this.explicitVisibleHeight && //isNaN
			(this.actualVisibleHeight > value || this.actualVisibleHeight == oldValue))
		{
			//only invalidate if this change might affect the visibleHeight
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this._maxVisibleHeight;
	}
	
	private var actualVisibleHeight:Float = 0;
	
	private var explicitVisibleHeight:Float;
	
	public var visibleHeight(get, set):Float;
	private function get_visibleHeight():Float { return this.actualVisibleHeight; }
	private function set_visibleHeight(value:Float):Float
	{
		if (this.explicitVisibleHeight == value ||
			(value != value && this.explicitVisibleHeight != this.explicitVisibleHeight)) //isNaN
		{
			return value;
		}
		this.explicitVisibleHeight = value;
		if (this.actualVisibleHeight != value)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		return this.explicitVisibleHeight;
	}
	
	public var contentX(get, never):Float;
	private var _contentX:Float = 0;
	private function get_contentX():Float { return this._contentX; }
	
	public var contentY(get, never):Float;
	private var _contentY:Float = 0;
	private function get_contentY():Float { return this._contentY; }
	
	private var _typicalItemIsInDataProvider:Bool = false;
	private var _typicalItemRenderer:IListItemRenderer;
	private var _unrenderedData:Array<Dynamic> = new Array<Dynamic>();
	private var _layoutItems:Array<DisplayObject> = new Array<DisplayObject>();
	private var _defaultStorage:ItemRendererFactoryStorage = new ItemRendererFactoryStorage();
	private var _storageMap:Map<String, ItemRendererFactoryStorage> = new Map<String, ItemRendererFactoryStorage>();
	private var _objectRendererMap:ObjectMap<Dynamic, IListItemRenderer> = new ObjectMap<Dynamic, IListItemRenderer>();
	private var _intRendererMap:IntMap<IListItemRenderer> = new IntMap<IListItemRenderer>();
	private var _stringRendererMap:StringMap<IListItemRenderer> = new StringMap<IListItemRenderer>();
	private var _minimumItemCount:Int;
	
	private var _layoutIndexOffset:Int = 0;
	private var _layoutIndexRolloverIndex:Int = -1;
	
	public var owner(get, set):List;
	private var _owner:List;
	private function get_owner():List { return this._owner; }
	private function set_owner(value:List):List
	{
		if (this._owner == value)
		{
			return value;
		}
		if (this._owner != null)
		{
			this._owner.removeEventListener(DragDropEvent.DRAG_ENTER, dragEnterHandler);
			this._owner.removeEventListener(DragDropEvent.DRAG_MOVE, dragMoveHandler);
			this._owner.removeEventListener(DragDropEvent.DRAG_EXIT, dragExitHandler);
			this._owner.removeEventListener(DragDropEvent.DRAG_DROP, dragDropHandler);
			this._owner.removeEventListener(DragDropEvent.DRAG_COMPLETE, dragCompleteHandler);
		}
		this._owner = value;
		if (this._owner != null)
		{
			this._owner.addEventListener(DragDropEvent.DRAG_ENTER, dragEnterHandler);
			this._owner.addEventListener(DragDropEvent.DRAG_MOVE, dragMoveHandler);
			this._owner.addEventListener(DragDropEvent.DRAG_EXIT, dragExitHandler);
			this._owner.addEventListener(DragDropEvent.DRAG_DROP, dragDropHandler);
			this._owner.addEventListener(DragDropEvent.DRAG_COMPLETE, dragCompleteHandler);
		}
		return this._owner;
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
	
	public var itemRendererFactory(get, set):Void->IListItemRenderer;
	private var _itemRendererFactory:Void->IListItemRenderer;
	private function get_itemRendererFactory():Void->IListItemRenderer { return this._itemRendererFactory; }
	private function set_itemRendererFactory(value:Void->IListItemRenderer):Void->IListItemRenderer
	{
		if (this._itemRendererFactory == value)
		{
			return value;
		}
		
		this._itemRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererFactory;
	}
	
	public var itemRendererFactories(get, set):Map<String, Void->IListItemRenderer>;
	private var _itemRendererFactories:Map<String, Void->IListItemRenderer>;
	private function get_itemRendererFactories():Map<String, Void->IListItemRenderer> { return this._itemRendererFactories; }
	private function set_itemRendererFactories(value:Map<String, Void->IListItemRenderer>):Map<String, Void->IListItemRenderer>
	{
		if (this._itemRendererFactories == value)
		{
			return value;
		}
		
		this._itemRendererFactories = value;
		if (value != null)
		{
			if (this._storageMap == null)
			{
				this._storageMap = new Map<String, ItemRendererFactoryStorage>();
			}
			else
			{
				this._storageMap.clear();
			}
		}
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
	private function get_itemRendererProperties():PropertyProxy { return this._itemRendererProperties; }
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
	
	public var horizontalScrollStep(get, never):Float;
	private function get_horizontalScrollStep():Float
	{
		var itemRenderer:DisplayObject = null;
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			if (this._layoutItems.length != 0)
			{
				itemRenderer = cast this._layoutItems[0];
			}
		}
		if (itemRenderer == null)
		{
			itemRenderer = SafeCast.safe_cast(this._typicalItemRenderer, DisplayObject);
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
				itemRenderer = cast this._layoutItems[0];
			}
		}
		if (itemRenderer == null)
		{
			itemRenderer = SafeCast.safe_cast(this._typicalItemRenderer, DisplayObject);
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
	
	private var _addItemEffectContexts:Array<IEffectContext> = null;
	
	private var _removeItemEffectContexts:Array<IEffectContext> = null;
	
	public var addedItems(get, set):Array<Dynamic>;
	private var _addedItems:Array<Dynamic>;
	private function get_addedItems():Array<Dynamic> { return this._addedItems; }
	private function set_addedItems(value:Array<Dynamic>):Array<Dynamic>
	{
		if (this._addedItems == value)
		{
			return value;
		}
		this._addedItems = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._addedItems;
	}
	
	public var addedItemsEffects(get, set):Array<Function>;
	private var _addedItemsEffects:Array<Function>;
	private function get_addedItemsEffects():Array<Function> { return this._addedItemsEffects; }
	private function set_addedItemsEffects(value:Array<Function>):Array<Function>
	{
		if (this._addedItemsEffects == value)
		{
			return value;
		}
		return this._addedItemsEffects = value;
	}
	
	public var removedItems(get, set):Array<Dynamic>;
	private var _removedItems:Array<Dynamic>;
	private function get_removedItems():Array<Dynamic> { return this._removedItems; }
	private function set_removedItems(value:Array<Dynamic>):Array<Dynamic>
	{
		if (this._removedItems == value)
		{
			return value;
		}
		this._removedItems = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._removedItems;
	}
	
	public var removedItemsEffects(get, set):Array<Function>;
	private var _removedItemsEffects:Array<Function>;
	private function get_removedItemsEffects():Array<Function> { return this._removedItemsEffects; }
	private function set_removedItemsEffects(value:Array<Function>):Array<Function>
	{
		if (this._removedItemsEffects == value)
		{
			return value;
		}
		return this._removedItemsEffects = value;
	}
	
	private var _dragTouchPointID:Int = -1;
	
	public var dragFormat(get, set):String;
	private var _dragFormat:String;
	private function get_dragFormat():String { return this._dragFormat; }
	private function set_dragFormat(value:String):String
	{
		return this._dragFormat = value;
	}
	
	public var dragEnabled(get, set):Bool;
	private var _dragEnabled:Bool = false;
	private function get_dragEnabled():Bool { return this._dragEnabled; }
	private function set_dragEnabled(value:Bool):Bool
	{
		return this._dragEnabled = value;
	}
	
	public var dropEnabled(get, set):Bool;
	private var _dropEnabled:Bool = false;
	private function get_dropEnabled():Bool { return this._dropEnabled; }
	private function set_dropEnabled(value:Bool):Bool
	{
		return this._dropEnabled = value;
	}
	
	public var minimumAutoScrollDistance(get, set):Float;
	private var _minimumAutoScrollDistance:Float = 0.04;
	private function get_minimumAutoScrollDistance():Float { return this._minimumAutoScrollDistance; }
	private function set_minimumAutoScrollDistance(value:Float):Float
	{
		return this._minimumAutoScrollDistance = value;
	}
	
	private var _droppedOnSelf:Bool = false;
	
	/**
	 * @private
	 */
	private var _explicitDropIndicatorWidth:Float;

	/**
	 * @private
	 */
	private var _explicitDropIndicatorHeight:Float;
	
	public var dropIndicatorSkin(get, set):DisplayObject;
	private var _dropIndicatorSkin:DisplayObject;
	private function get_dropIndicatorSkin():DisplayObject { return this._dropIndicatorSkin; }
	private function set_dropIndicatorSkin(value:DisplayObject):DisplayObject
	{
		if (this._dropIndicatorSkin == value)
		{
			return value;
		}
		this._dropIndicatorSkin = value;
		if (Std.isOfType(this._dropIndicatorSkin, IMeasureDisplayObject))
		{
			var measureSkin:IMeasureDisplayObject = cast this._dropIndicatorSkin;
			this._explicitDropIndicatorWidth = measureSkin.explicitWidth;
			this._explicitDropIndicatorHeight = measureSkin.explicitHeight;
		}
		else if (this._dropIndicatorSkin != null)
		{
			this._explicitDropIndicatorWidth = this._dropIndicatorSkin.width;
			this._explicitDropIndicatorHeight = this._dropIndicatorSkin.height;
		}
		return this._dropIndicatorSkin;
	}
	
	private var _startDragX:Float;
	private var _startDragY:Float;
	
	private var _dragLocalX:Float = -1;
	private var _dragLocalY:Float = -1;
	
	private var _acceptedDrag:Bool = false;
	
	public var minimumDragDropDistance(get, set):Float;
	private var _minimumDragDropDistance:Float = 0.04;
	private function get_minimumDragDropDistance():Float { return this._minimumDragDropDistance; }
	private function set_minimumDragDropDistance(value:Float):Float
	{
		return this._minimumDragDropDistance = value;
	}
	
	public var requiresMeasurementOnScroll(get, never):Bool;
	private function get_requiresMeasurementOnScroll():Bool
	{
		return this._layout.requiresLayoutOnScroll &&
				(this.explicitVisibleWidth != this.explicitVisibleWidth ||
				this.explicitVisibleHeight != this.explicitVisibleHeight);
	}
	
	public function calculateNavigationDestination(index:Int, keyCode:Int):Int
	{
		return this._layout.calculateNavigationDestination(this._layoutItems, index, keyCode, this._layoutResult);
	}

	public function getScrollPositionForIndex(index:Int, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		return this._layout.getScrollPositionForIndex(index, this._layoutItems,
			0, 0, this.actualVisibleWidth, this.actualVisibleHeight, result);
	}
	
	public function getNearestScrollPositionForIndex(index:Int, result:Point = null):Point
	{
		if (result == null)
		{
			result = new Point();
		}
		return this._layout.getNearestScrollPositionForIndex(index,
			this._horizontalScrollPosition, this._verticalScrollPosition,
			this._layoutItems, 0, 0, this.actualVisibleWidth, this.actualVisibleHeight, result);
	}
	
	public function itemToItemRenderer(item:Dynamic):IListItemRenderer
	{
		if (Std.isOfType(item, String))
		{
			return this._stringRendererMap.get(item);
		}
		else if (Std.isOfType(item, Int))
		{
			return this._intRendererMap.get(item);
		}
		else 
		{
			return this._objectRendererMap.get(item);
		}
	}
	
	override public function dispose():Void
	{
		if (this._dropIndicatorSkin != null &&
			this._dropIndicatorSkin.parent == null)
		{
			this._dropIndicatorSkin.dispose();
			this._dropIndicatorSkin = null;
		}
		this.refreshInactiveRenderers(null, true);
		if (this._storageMap != null)
		{
			for (factoryID in this._storageMap.keys())
			{
				this.refreshInactiveRenderers(factoryID, true);
			}
			this._storageMap.clear();
			this._storageMap = null;
		}
		if (this._objectRendererMap != null)
		{
			this._objectRendererMap.clear();
			this._objectRendererMap = null;
		}
		if (this._intRendererMap != null)
		{
			this._intRendererMap.clear();
			this._intRendererMap = null;
		}
		if (this._stringRendererMap != null)
		{
			this._stringRendererMap.clear();
			this._stringRendererMap = null;
		}
		if (this._itemRendererFactories != null)
		{
			this._itemRendererFactories.clear();
			this._itemRendererFactories = null;
		}
		if (this._itemRendererProperties != null)
		{
			this._itemRendererProperties.dispose();
			this._itemRendererProperties = null;
		}
		if (this._addedItems != null)
		{
			//this._addedItems.clear();
			this._addedItems = null;
			this._addedItemsEffects = null;
		}
		if (this._removedItems != null)
		{
			//this._removedItems.clear();
			this._removedItems = null;
			this._removedItemsEffects = null;
		}
		this.owner = null;
		this.layout = null;
		this.dataProvider = null;
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override public function hitTest(localPoint:Point):DisplayObject
	{
		var result:DisplayObject = super.hitTest(localPoint);
		if (result != null && this._acceptedDrag)
		{
			return this._owner;
		}
		return result;
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
			this.refreshInactiveRenderers(null, itemRendererInvalid);
			if (this._storageMap != null)
			{
				for (factoryID in this._storageMap.keys()) // TODO : don't iterate over String keys ?
				{
					this.refreshInactiveRenderers(factoryID, itemRendererInvalid);
				}
			}
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
		this.actualVisibleWidth = this._layoutResult.viewPortWidth;
		this.actualVisibleHeight = this._layoutResult.viewPortHeight;
		this._actualMinVisibleWidth = this._layoutResult.viewPortWidth;
		this._actualMinVisibleHeight = this._layoutResult.viewPortHeight;
		
		//final validation to avoid juggler next frame issues
		this.validateItemRenderers();
		
		this.handlePendingItemRendererEffects();
		
		if (scrollInvalid && this.hasEventListener(Event.ENTER_FRAME, this.dragScroll_enterFrameHandler))
		{
			this.refreshDropIndicator(this._dragLocalX, this._dragLocalY);
		}
	}
	
	private function handlePendingItemRendererEffects():Void
	{
		var itemRenderer:IListItemRenderer;
		var effect:Function;
		var context:IEffectContext;
		var item:Dynamic;
		var count:Int;
		if (this._addedItems != null)
		{
			if (this._addItemEffectContexts == null)
			{
				this._addItemEffectContexts = new Array<IEffectContext>();
			}
			
			count = this._addedItems.length;
			for (i in 0...count)
			{
				item = this._addedItems[i];
				if (Std.isOfType(item, String))
				{
					itemRenderer = this._stringRendererMap.get(item);
				}
				else if (Std.isOfType(item, Int))
				{
					itemRenderer = this._intRendererMap.get(item);
				}
				else
				{
					itemRenderer = this._objectRendererMap.get(item);
				}
				if (itemRenderer != null)
				{
					this.interruptRemoveItemEffects(itemRenderer, false);
					effect = this._addedItemsEffects[i];
					context = effect(itemRenderer);
					context.addEventListener(Event.COMPLETE, addedItemEffectContext_completeHandler);
					this._addItemEffectContexts[this._addItemEffectContexts.length] = context;
					context.play();
				}
			}
			this._addedItems = null;
			this._addedItemsEffects = null;
		}
		if (this._removedItems != null)
		{
			if (this._removeItemEffectContexts == null)
			{
				this._removeItemEffectContexts = new Array<IEffectContext>();
			}
			
			count = this._removedItems.length;
			for (i in 0...count)
			{
				item = this._removedItems[i];
				if (Std.isOfType(item, String))
				{
					itemRenderer = this._stringRendererMap.get(item);
				}
				else if (Std.isOfType(item, Int))
				{
					itemRenderer = this._intRendererMap.get(item);
				}
				else
				{
					itemRenderer = this._objectRendererMap.get(item);
				}
				if (itemRenderer != null)
				{
					this.interruptRemoveItemEffects(itemRenderer, true);
					this.interruptAddItemEffects(itemRenderer);
					effect = this._removedItemsEffects[i];
					context = effect(itemRenderer);
					context.addEventListener(Event.COMPLETE, removedItemEffectContext_completeHandler);
					this._removeItemEffectContexts[this._removeItemEffectContexts.length] = context;
					context.play();
				}
			}
			this._removedItems = null;
			this._removedItemsEffects = null;
		}
	}
	
	private function interruptAddItemEffects(itemRenderer:IListItemRenderer):Void
	{
		if (this._addItemEffectContexts == null)
		{
			return;
		}
		var contextCount:Int = this._addItemEffectContexts.length;
		var context:IEffectContext;
		var i:Int = -1;
		while (i < contextCount)
		{
			i++;
			context = this._addItemEffectContexts[i];
			if (context.target != cast itemRenderer)
			{
				continue;
			}
			context.interrupt();
			//we've removed this context, so check the same index again
			//because it won't be the same context, and don't go beyond the
			//new, smaller length
			i--;
			contextCount--;
		}
	}
	
	private function interruptRemoveItemEffects(itemRenderer:IListItemRenderer, stop:Bool):Void
	{
		if (this._removeItemEffectContexts == null)
		{
			return;
		}
		var contextCount:Int = this._removeItemEffectContexts.length;
		var context:IEffectContext;
		var i:Int = -1;
		while (i < contextCount)
		{
			i++;
			context = this._removeItemEffectContexts[i];
			if (context.target != cast itemRenderer)
			{
				continue;
			}
			if (stop)
			{
				context.stop();
			}
			else
			{
				context.interrupt();
			}
			//we've removed this context, so check the same index again
			//because it won't be the same context, and don't go beyond the
			//new, smaller length
			i--;
			contextCount--;
		}
	}
	
	private function invalidateParent(flag:String = FeathersControl.INVALIDATION_FLAG_ALL):Void
	{
		cast(this.parent, Scroller).invalidate(flag);
	}
	
	private function validateItemRenderers():Void
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
	
	private function refreshLayoutTypicalItem():Void
	{
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		if (virtualLayout == null || !virtualLayout.useVirtualLayout)
		{
			//the old layout was virtual, but this one isn't
			if (!this._typicalItemIsInDataProvider && this._typicalItemRenderer != null)
			{
				//it's safe to destroy this renderer
				this.destroyRenderer(this._typicalItemRenderer);
				this._typicalItemRenderer = null;
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
				newTypicalItemIsInDataProvider = typicalItemIndex >= 0;
			}
			if (typicalItemIndex == -1)
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
		
		var typicalRenderer:IListItemRenderer = null;
		//#1645 The typicalItem can be null if the data provider contains
		//a null value at index 0. this is the only time we allow null.
		if (typicalItem != null || newTypicalItemIsInDataProvider)
		{
			if (Std.isOfType(typicalItem, String))
			{
				typicalRenderer = this._stringRendererMap.get(typicalItem);
			}
			else if (Std.isOfType(typicalItem, Int))
			{
				typicalRenderer = this._intRendererMap.get(typicalItem);
			}
			else
			{
				typicalRenderer = this._objectRendererMap.get(typicalItem);
			}
			if (typicalRenderer != null)
			{
				//at this point, the item already has an item renderer.
				//(this doesn't necessarily mean that the current typical
				//item was the typical item last time this function was
				//called)
				
				//the index may have changed if items were added, removed or
				//reordered in the data provider
				typicalRenderer.index = typicalItemIndex;
				if (Std.isOfType(typicalRenderer, IDragAndDropItemRenderer))
				{
					cast(typicalRenderer, IDragAndDropItemRenderer).dragEnabled = this._dragEnabled;
				}
			}
			if (typicalRenderer == null && this._typicalItemRenderer != null)
			{
				//the typical item has changed, and doesn't have an item
				//renderer yet. the previous typical item had an item
				//renderer, so we will try to reuse it.
				
				//we can reuse the existing typical item renderer if the old
				//typical item wasn't in the data provider. otherwise, it
				//may still be needed for the same item.
				var canReuse:Bool = !this._typicalItemIsInDataProvider;
				var oldTypicalItemRemoved:Bool = this._typicalItemIsInDataProvider &&
					this._dataProvider != null && this._dataProvider.getItemIndex(this._typicalItemRenderer.data) != -1;
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
						factoryID = this.getFactoryID(typicalItem, typicalItemIndex);
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
						if (Std.isOfType(this._typicalItemRenderer.data, String))
						{
							this._stringRendererMap.remove(this._typicalItemRenderer.data);
						}
						else if (Std.isOfType(this._typicalItemRenderer.data, Int))
						{
							this._intRendererMap.remove(this._typicalItemRenderer.data);
						}
						else 
						{
							this._objectRendererMap.remove(this._typicalItemRenderer.data);
						}
					}
					typicalRenderer = this._typicalItemRenderer;
					typicalRenderer.data = typicalItem;
					typicalRenderer.index = typicalItemIndex;
					//if the new typical item is in the data provider, add it
					//to the renderer map.
					if (newTypicalItemIsInDataProvider)
					{
						if (Std.isOfType(typicalItem, String))
						{
							this._stringRendererMap.set(typicalItem, typicalRenderer);
						}
						else if (Std.isOfType(typicalItem, Int))
						{
							this._intRendererMap.set(typicalItem, typicalRenderer);
						}
						else 
						{
							this._objectRendererMap.set(typicalItem, typicalRenderer);
						}
					}
				}
			}
			if (typicalRenderer == null)
			{
				//if we still don't have a typical item renderer, we need to
				//create a new one.
				typicalRenderer = this.createRenderer(typicalItem, typicalItemIndex, false, !newTypicalItemIsInDataProvider);
				if (!this._typicalItemIsInDataProvider && this._typicalItemRenderer != null)
				{
					//get rid of the old typical item renderer if it isn't
					//needed anymore.  since it was not in the data
					//provider, we don't need to mess with the renderer map
					//dictionary or dispatch any events.
					this.destroyRenderer(this._typicalItemRenderer);
					this._typicalItemRenderer = null;
				}
			}
		}
		
		virtualLayout.typicalItem = SafeCast.safe_cast(typicalRenderer, DisplayObject);
		this._typicalItemRenderer = typicalRenderer;
		this._typicalItemIsInDataProvider = newTypicalItemIsInDataProvider;
		if (this._typicalItemRenderer != null && !this._typicalItemIsInDataProvider)
		{
			//we need to know if this item renderer resizes to adjust the
			//layout because the layout may use this item renderer to resize
			//the other item renderers
			this._typicalItemRenderer.addEventListener(FeathersEventType.RESIZE, renderer_resizeHandler);
		}
	}
	
	private function refreshItemRendererStyles():Void
	{
		var itemRenderer:IListItemRenderer;
		for (item in this._layoutItems)
		{
			itemRenderer = SafeCast.safe_cast(item, IListItemRenderer);
			if (itemRenderer != null)
			{
				this.refreshOneItemRendererStyles(itemRenderer);
			}
		}
	}
	
	private function refreshOneItemRendererStyles(renderer:IListItemRenderer):Void
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
	
	private function refreshSelection():Void
	{
		var itemRenderer:IListItemRenderer;
		for (item in this._layoutItems)
		{
			itemRenderer = SafeCast.safe_cast(item, IListItemRenderer);
			if (itemRenderer != null)
			{
				itemRenderer.isSelected = this._selectedIndices.getItemIndex(itemRenderer.index) != -1;
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
	
	private function refreshViewPortBounds():Void
	{
		var needsMinWidth:Bool = this._explicitMinVisibleWidth != this._explicitMinVisibleWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinVisibleHeight != this._explicitMinVisibleHeight; //isNaN
		this._viewPortBounds.x = 0;
		this._viewPortBounds.y = 0;
		this._viewPortBounds.scrollX = this._horizontalScrollPosition;
		this._viewPortBounds.scrollY = this._verticalScrollPosition;
		this._viewPortBounds.explicitWidth = this.explicitVisibleWidth;
		this._viewPortBounds.explicitHeight = this.explicitVisibleHeight;
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
	
	private function refreshInactiveRenderers(factoryID:String, itemRendererTypeIsInvalid:Bool):Void
	{
		var storage:ItemRendererFactoryStorage;
		if (factoryID != null)
		{
			storage = this._storageMap[factoryID];
		}
		else
		{
			storage = this._defaultStorage;
		}
		var temp:Array<IListItemRenderer> = storage.inactiveItemRenderers;
		storage.inactiveItemRenderers = storage.activeItemRenderers;
		storage.activeItemRenderers = temp;
		if (storage.activeItemRenderers.length != 0)
		{
			throw new IllegalOperationError("ListDataViewPort: active renderers should be empty.");
		}
		if (itemRendererTypeIsInvalid)
		{
			this.recoverInactiveRenderers(storage);
			this.freeInactiveRenderers(storage, 0);
			if (this._typicalItemRenderer != null && this._typicalItemRenderer.factoryID == factoryID)
			{
				if (this._typicalItemIsInDataProvider && this._typicalItemRenderer.data != null)
				{
					if (Std.isOfType(this._typicalItemRenderer.data, String))
					{
						this._stringRendererMap.remove(this._typicalItemRenderer.data);
					}
					else if (Std.isOfType(this._typicalItemRenderer.data, Int))
					{
						this._intRendererMap.remove(this._typicalItemRenderer.data);
					}
					else
					{
						this._objectRendererMap.remove(this._typicalItemRenderer.data);
					}
				}
				this.destroyRenderer(this._typicalItemRenderer);
				this._typicalItemRenderer = null;
				this._typicalItemIsInDataProvider = false;
			}
		}
		
		this._layoutItems.resize(0);
	}
	
	private function refreshRenderers():Void
	{
		var storage:ItemRendererFactoryStorage;
		if (this._typicalItemRenderer != null)
		{
			if (this._typicalItemIsInDataProvider)
			{
				storage = this.factoryIDToStorage(this._typicalItemRenderer.factoryID);
				var inactiveItemRenderers:Array<IListItemRenderer> = storage.inactiveItemRenderers;
				var activeItemRenderers:Array<IListItemRenderer> = storage.activeItemRenderers;
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
			//we need to set the typical item renderer's properties here
			//because they may be needed for proper measurement in a virtual
			//layout.
			this.refreshOneItemRendererStyles(this._typicalItemRenderer);
		}
		
		this.findUnrenderedData();
		this.recoverInactiveRenderers(this._defaultStorage);
		if (this._storageMap != null)
		{
			for (factoryID in this._storageMap.keys())
			{
				storage = this._storageMap[factoryID];
				this.recoverInactiveRenderers(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveRenderers(this._defaultStorage, this._minimumItemCount);
		if (this._storageMap != null)
		{
			for (factoryID in this._storageMap.keys())
			{
				storage = this._storageMap[factoryID];
				this.freeInactiveRenderers(storage, 1);
			}
		}
		this._updateForDataReset = false;
	}
	
	private function findUnrenderedData():Void
	{
		var itemCount:Int = this._dataProvider != null ? this._dataProvider.length : 0;
		var virtualLayout:IVirtualLayout = SafeCast.safe_cast(this._layout, IVirtualLayout);
		var useVirtualLayout:Bool = virtualLayout != null && virtualLayout.useVirtualLayout;
		if (useVirtualLayout)
		{
			var point:Point = Pool.getPoint();
			virtualLayout.measureViewPort(itemCount, this._viewPortBounds, point);
			virtualLayout.getVisibleIndicesAtScrollPosition(this._horizontalScrollPosition, this._verticalScrollPosition, point.x, point.y, itemCount, HELPER_VECTOR);
			Pool.putPoint(point);
		}
		
		var unrenderedItemCount:Int = useVirtualLayout ? HELPER_VECTOR.length : itemCount;
		if (useVirtualLayout && this._typicalItemIsInDataProvider && this._typicalItemRenderer != null &&
			HELPER_VECTOR.indexOf(this._typicalItemRenderer.index) != -1)
		{
			//add an extra item renderer if the typical item is from the
			//data provider and it is visible. this helps keep the number of
			//item renderers constant!
			this._minimumItemCount = unrenderedItemCount + 1;
		}
		else
		{
			this._minimumItemCount = unrenderedItemCount;
		}
		var index:Int;
		var beforeItemCount:Int;
		var afterItemCount:Int;
		var canUseBeforeAndAfter:Bool = Std.isOfType(this._layout, ITrimmedVirtualLayout) && useVirtualLayout &&
			(!Std.isOfType(this._layout, IVariableVirtualLayout) || !cast(this._layout, IVariableVirtualLayout).hasVariableItemDimensions) &&
			unrenderedItemCount != 0;
		if (canUseBeforeAndAfter)
		{
			var minIndex:Int = HELPER_VECTOR[0];
			var maxIndex:Int = minIndex;
			for (i in 1...unrenderedItemCount)
			{
				index = HELPER_VECTOR[i];
				if (index < minIndex)
				{
					minIndex = index;
				}
				if (index > maxIndex)
				{
					maxIndex = index;
				}
			}
			if (Std.isOfType(this._layout, ISpinnerLayout) &&
				minIndex == 0 &&
				maxIndex == (this._dataProvider.length - 1) &&
				HELPER_VECTOR[0] > HELPER_VECTOR[HELPER_VECTOR.length - 1])
			{
				var newMin:Int = HELPER_VECTOR[0] - this._dataProvider.length;
				var newMax:Int = HELPER_VECTOR[HELPER_VECTOR.length - 1];
				beforeItemCount = newMin;
				afterItemCount = itemCount - 1 - newMax + beforeItemCount;
				this._layoutItems.resize(HELPER_VECTOR.length);
				this._layoutIndexOffset = -beforeItemCount;
				this._layoutIndexRolloverIndex = HELPER_VECTOR[0];
			}
			else
			{
				beforeItemCount = minIndex - 1;
				if (beforeItemCount < 0)
				{
					beforeItemCount = 0;
				}
				afterItemCount = itemCount - 1 - maxIndex;
				
				this._layoutItems.resize(itemCount - beforeItemCount - afterItemCount);
				this._layoutIndexOffset = -beforeItemCount;
				this._layoutIndexRolloverIndex = -1;
			}
			var trimmedLayout:ITrimmedVirtualLayout = cast this._layout;
			trimmedLayout.beforeVirtualizedItemCount = beforeItemCount;
			trimmedLayout.afterVirtualizedItemCount = afterItemCount;
		}
		else
		{
			this._layoutIndexOffset = 0;
			this._layoutItems.resize(itemCount);
		}
		
		var unrenderedDataLastIndex:Int = this._unrenderedData.length;
		var item:Dynamic;
		var itemRenderer:IListItemRenderer;
		var newFactoryID:String;
		var storage:ItemRendererFactoryStorage;
		var activeItemRenderers:Array<IListItemRenderer>;
		var inactiveItemRenderers:Array<IListItemRenderer>;
		var inactiveIndex:Int;
		var layoutIndex:Int;
		for (i in 0...unrenderedItemCount)
		{
			index = useVirtualLayout ? HELPER_VECTOR[i] : i;
			if (index < 0 || index >= itemCount)
			{
				continue;
			}
			item = this._dataProvider.getItemAt(index);
			if (Std.isOfType(item, String))
			{
				itemRenderer = this._stringRendererMap.get(item);
				if (this._factoryIDFunction != null && itemRenderer != null)
				{
					newFactoryID = this.getFactoryID(itemRenderer.data, index);
					if (newFactoryID != itemRenderer.factoryID)
					{
						itemRenderer = null;
						this._stringRendererMap.remove(item);
					}
				}
			}
			else if (Std.isOfType(item, Int))
			{
				itemRenderer = this._intRendererMap.get(item);
				if (this._factoryIDFunction != null && itemRenderer != null)
				{
					newFactoryID = this.getFactoryID(itemRenderer.data, index);
					if (newFactoryID != itemRenderer.factoryID)
					{
						itemRenderer = null;
						this._intRendererMap.remove(item);
					}
				}
			}
			else 
			{
				itemRenderer = this._objectRendererMap.get(item);
				if (this._factoryIDFunction != null && itemRenderer != null)
				{
					newFactoryID = this.getFactoryID(itemRenderer.data, index);
					if (newFactoryID != itemRenderer.factoryID)
					{
						itemRenderer = null;
						this._objectRendererMap.remove(item);
					}
				}
			}
			if (itemRenderer != null)
			{
				//the index may have changed if items were added, removed or
				//reordered in the data provider
				itemRenderer.index = index;
				if (Std.isOfType(itemRenderer, IDragAndDropItemRenderer))
				{
					cast(itemRenderer, IDragAndDropItemRenderer).dragEnabled = this._dragEnabled;
				}
				//if this item renderer used to be the typical item
				//renderer, but it isn't anymore, it may have been set invisible!
				itemRenderer.visible = true;
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
					storage = this.factoryIDToStorage(itemRenderer.factoryID);
					activeItemRenderers = storage.activeItemRenderers;
					inactiveItemRenderers = storage.inactiveItemRenderers;
					activeItemRenderers[activeItemRenderers.length] = itemRenderer;
					inactiveIndex = inactiveItemRenderers.indexOf(itemRenderer);
					if (inactiveIndex != -1)
					{
						inactiveItemRenderers[inactiveIndex] = null;
					}
					else
					{
						throw new IllegalOperationError("ListDataViewPort: renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
					}
				}
				if (this._layoutIndexRolloverIndex == -1 || index < this._layoutIndexRolloverIndex)
				{
					layoutIndex = index + this._layoutIndexOffset;
				}
				else
				{
					layoutIndex = index - this._dataProvider.length + this._layoutIndexOffset;
				}
				this._layoutItems[layoutIndex] = cast itemRenderer;
			}
			else
			{
				this._unrenderedData[unrenderedDataLastIndex] = item;
				unrenderedDataLastIndex++;
			}
		}
		//update the typical item renderer's visibility
		if (this._typicalItemRenderer != null)
		{
			if (useVirtualLayout && this._typicalItemIsInDataProvider)
			{
				index = HELPER_VECTOR.indexOf(this._typicalItemRenderer.index);
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
	
	private function renderUnrenderedData():Void
	{
		var item:Dynamic;
		var index:Int;
		var renderer:IListItemRenderer;
		var itemCount:Int = this._unrenderedData.length;
		var layoutIndex:Int;
		for (i in 0...itemCount)
		{
			item = this._unrenderedData.shift();
			index = this._dataProvider.getItemIndex(item);
			renderer = this.createRenderer(item, index, true, false);
			renderer.visible = true;
			if (this._layoutIndexRolloverIndex == -1 || index < this._layoutIndexRolloverIndex)
			{
				layoutIndex = index + this._layoutIndexOffset;
			}
			else
			{
				layoutIndex = index - this._dataProvider.length + this._layoutIndexOffset;
			}
			this._layoutItems[layoutIndex] = cast renderer;
		}
	}
	
	private function recoverInactiveRenderers(storage:ItemRendererFactoryStorage):Void
	{
		var inactiveItemRenderers:Array<IListItemRenderer> = storage.inactiveItemRenderers;
		var itemRenderer:IListItemRenderer;
		var itemCount:Int = inactiveItemRenderers.length;
		var data:Dynamic;
		for (i in 0...itemCount)
		{
			itemRenderer = inactiveItemRenderers[i];
			if (itemRenderer == null || itemRenderer.index < 0)
			{
				continue;
			}
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, itemRenderer);
			data = itemRenderer.data;
			if (Std.isOfType(itemRenderer.data, String))
			{
				this._stringRendererMap.remove(itemRenderer.data);
			}
			else if (Std.isOfType(itemRenderer.data, Int))
			{
				this._intRendererMap.remove(itemRenderer.data);
			}
			else
			{
				this._objectRendererMap.remove(itemRenderer.data);
			}
		}
	}
	
	private function freeInactiveRenderers(storage:ItemRendererFactoryStorage, minimumItemCount:Int):Void
	{
		var inactiveItemRenderers:Array<IListItemRenderer> = storage.inactiveItemRenderers;
		var activeItemRenderers:Array<IListItemRenderer> = storage.activeItemRenderers;
		var activeItemRenderersCount:Int = activeItemRenderers.length;
		
		//we may keep around some extra renderers to avoid too much
		//allocation and garbage collection. they'll be hidden.
		var itemCount:Int = inactiveItemRenderers.length;
		var keepCount:Int = minimumItemCount - activeItemRenderersCount;
		if (keepCount > itemCount)
		{
			keepCount = itemCount;
		}
		var itemRenderer:IListItemRenderer;
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
			itemRenderer.index = -1;
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
			this.destroyRenderer(itemRenderer);
		}
	}
	
	private function createRenderer(item:Dynamic, index:Int, useCache:Bool, isTemporary:Bool):IListItemRenderer
	{
		var factoryID:String = null;
		if (this._factoryIDFunction != null)
		{
			factoryID = this.getFactoryID(item, index);
		}
		var itemRendererFactory:Function = this.factoryIDToFactory(factoryID);
		var storage:ItemRendererFactoryStorage = this.factoryIDToStorage(factoryID);
		var inactiveItemRenderers:Array<IListItemRenderer> = storage.inactiveItemRenderers;
		var activeItemRenderers:Array<IListItemRenderer> = storage.activeItemRenderers;
		var itemRenderer:IListItemRenderer = null;
		do
		{
			if (!useCache || isTemporary || inactiveItemRenderers.length == 0)
			{
				if (itemRendererFactory != null)
				{
					itemRenderer = cast itemRendererFactory();
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
		itemRenderer.index = index;
		itemRenderer.owner = this._owner;
		itemRenderer.factoryID = factoryID;
		if (Std.isOfType(itemRenderer, IDragAndDropItemRenderer))
		{
			cast(itemRenderer, IDragAndDropItemRenderer).dragEnabled = this._dragEnabled;
		}
		
		if (!isTemporary)
		{
			if (Std.isOfType(item, String))
			{
				this._stringRendererMap.set(item, itemRenderer);
			}
			else if (Std.isOfType(item, Int))
			{
				this._intRendererMap.set(item, itemRenderer);
			}
			else
			{
				this._objectRendererMap.set(item, itemRenderer);
			}
			activeItemRenderers[activeItemRenderers.length] = itemRenderer;
			itemRenderer.addEventListener(Event.TRIGGERED, renderer_triggeredHandler);
			itemRenderer.addEventListener(Event.CHANGE, renderer_changeHandler);
			itemRenderer.addEventListener(FeathersEventType.RESIZE, renderer_resizeHandler);
			itemRenderer.addEventListener(TouchEvent.TOUCH, itemRenderer_drag_touchHandler);
			this._owner.dispatchEventWith(FeathersEventType.RENDERER_ADD, false, itemRenderer);
		}
		
		return itemRenderer;
	}
	
	private function destroyRenderer(renderer:IListItemRenderer):Void
	{
		renderer.removeEventListener(Event.TRIGGERED, renderer_triggeredHandler);
		renderer.removeEventListener(Event.CHANGE, renderer_changeHandler);
		renderer.removeEventListener(FeathersEventType.RESIZE, renderer_resizeHandler);
		renderer.removeEventListener(TouchEvent.TOUCH, itemRenderer_drag_touchHandler);
		renderer.owner = null;
		renderer.data = null;
		renderer.factoryID = null;
		this.removeChild(cast renderer, true);
	}
	
	private function getFactoryID(item:Dynamic, index:Int):String
	{
		if (this._factoryIDFunction == null)
		{
			return null;
		}
		
		if (ArgumentsCount.count_args(this._factoryIDFunction) == 1)
		{
			return this._factoryIDFunction(item);
		}
		return this._factoryIDFunction(item, index);
	}
	
	private function factoryIDToFactory(id:String):Function
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
	
	private function factoryIDToStorage(id:String):ItemRendererFactoryStorage
	{
		if (id != null)
		{
			if (this._storageMap.exists(id))
			{
				return this._storageMap[id];
			}
			var storage:ItemRendererFactoryStorage = new ItemRendererFactoryStorage();
			this._storageMap[id] = storage;
			return storage;
		}
		return this._defaultStorage;
	}
	
	private function refreshDropIndicator(localX:Float, localY:Float):Void
	{
		if (this._dropIndicatorSkin == null || !Std.isOfType(this._layout, IDragDropLayout))
		{
			return;
		}
		var layout:IDragDropLayout = cast this._layout;
		this._dropIndicatorSkin.width = this._explicitDropIndicatorWidth;
		this._dropIndicatorSkin.height = this._explicitDropIndicatorHeight;
		
		var dropX:Float = this._horizontalScrollPosition + localX;
		var dropY:Float = this._verticalScrollPosition + localY;
		var dropIndex:Int = layout.getDropIndex(dropX, dropY,
			this._layoutItems, 0, 0, this.actualVisibleWidth, this.actualVisibleHeight);
		layout.positionDropIndicator(this._dropIndicatorSkin, dropIndex,
			dropX, dropY, this._layoutItems, this.actualVisibleWidth, this.actualVisibleHeight);
		this.addChild(this._dropIndicatorSkin);
	}
	
	private function childProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
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
		var renderer:IListItemRenderer;
		if (Std.isOfType(item, String))
		{
			renderer = this._stringRendererMap.get(item);
		}
		else if (Std.isOfType(item, Int))
		{
			renderer = this._intRendererMap.get(item);
		}
		else
		{
			renderer = this._objectRendererMap.get(item);
		}
		if (renderer == null)
		{
			return;
		}
		//in order to display the same item with modified properties, this
		//hack tricks the item renderer into thinking that it has been given
		//a different item to render.
		renderer.data = null;
		renderer.data = item;
		if (this.explicitVisibleWidth != this.explicitVisibleWidth || //isNaN
			this.explicitVisibleHeight != this.explicitVisibleHeight) //isNaN
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
	
	private function layout_changeHandler(event:Event):Void
	{
		if (this._ignoreLayoutChanges)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	private function renderer_resizeHandler(event:Event):Void
	{
		if (this._ignoreRendererResizing)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		this.invalidateParent(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var renderer:IListItemRenderer = cast event.currentTarget;
		if (renderer == this._typicalItemRenderer && !this._typicalItemIsInDataProvider)
		{
			return;
		}
		var layout:IVariableVirtualLayout = SafeCast.safe_cast(this._layout, IVariableVirtualLayout);
		if (layout == null || !layout.hasVariableItemDimensions)
		{
			return;
		}
		//var renderer:IListItemRenderer = cast event.currentTarget;
		layout.resetVariableVirtualCacheAtIndex(renderer.index, cast renderer);
	}
	
	private function renderer_triggeredHandler(event:Event):Void
	{
		var renderer:IListItemRenderer = cast event.currentTarget;
		this.parent.dispatchEventWith(Event.TRIGGERED, false, renderer.data);
	}
	
	private function renderer_changeHandler(event:Event):Void
	{
		if (this._ignoreSelectionChanges)
		{
			return;
		}
		var renderer:IListItemRenderer = cast event.currentTarget;
		if (!this._isSelectable || this._owner.isScrolling)
		{
			renderer.isSelected = false;
			return;
		}
		var isSelected:Bool = renderer.isSelected;
		var index:Int = renderer.index;
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
			var indices:Array<Int> = [index];
			this._selectedIndices.data = indices;
		}
		else
		{
			this._selectedIndices.removeAll();
		}
	}
	
	private function selectedIndices_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
	}
	
	private function addedItemEffectContext_completeHandler(event:Event):Void
	{
		var context:IEffectContext = cast event.currentTarget;
		context.removeEventListener(Event.COMPLETE, addedItemEffectContext_completeHandler);
		var index:Int = this._addItemEffectContexts.indexOf(context);
		this._addItemEffectContexts.splice(index, 1);
	}
	
	private function removedItemEffectContext_completeHandler(event:Event):Void
	{
		var context:IEffectContext = cast event.currentTarget;
		context.removeEventListener(Event.COMPLETE, removedItemEffectContext_completeHandler);
		var contextIndex:Int = this._removeItemEffectContexts.indexOf(context);
		this._removeItemEffectContexts.splice(contextIndex, 1);
		//if it was stopped before completing, we won't remove the item from
		//the data provider
		if (event.data == true)
		{
			return;
		}
		
		var itemRenderer:IListItemRenderer = cast context.target;
		//don't remove it from the data provider until the effect is done
		//because we don't want to remove it from the layout yet
		this._dataProvider.removeItem(itemRenderer.data);
		
		//we're going to completely destroy this item renderer because the
		//effect may have left it in a state where it won't be valid for
		//use by a new item. for instance, if the item faded out, it would
		//start out invisible (unless an item added effect faded it back in,
		//but we can't assume that).
		
		//recover
		this._owner.dispatchEventWith(FeathersEventType.RENDERER_REMOVE, false, itemRenderer);
		if (Std.isOfType(itemRenderer.data, String))
		{
			this._stringRendererMap.remove(itemRenderer.data);
		}
		else if (Std.isOfType(itemRenderer.data, Int))
		{
			this._intRendererMap.remove(itemRenderer.data);
		}
		else
		{
			this._objectRendererMap.remove(itemRenderer.data);
		}
		
		//free
		var storage:ItemRendererFactoryStorage = this.factoryIDToStorage(itemRenderer.factoryID);
		var activeItemRenderers:Array<IListItemRenderer> = storage.activeItemRenderers;
		var activeIndex:Int = activeItemRenderers.indexOf(itemRenderer);
		activeItemRenderers.splice(activeIndex, 1);
		this.destroyRenderer(itemRenderer);
	}
	
	private function dragEnterHandler(event:DragDropEvent):Void
	{
		this._acceptedDrag = false;
		if (!this._dropEnabled)
		{
			return;
		}
		if (!event.dragData.hasDataForFormat(this._dragFormat))
		{
			return;
		}
		DragDropManager.acceptDrag(this._owner);
		this.refreshDropIndicator(event.localX, event.localY);
		
		this._acceptedDrag = true;
		this._dragLocalX = event.localX;
		this._dragLocalY = event.localY;
		this.addEventListener(Event.ENTER_FRAME, dragScroll_enterFrameHandler);
	}
	
	private function dragMoveHandler(event:DragDropEvent):Void
	{
		if (!this._dropEnabled)
		{
			return;
		}
		if (!event.dragData.hasDataForFormat(this._dragFormat))
		{
			return;
		}
		this.refreshDropIndicator(event.localX, event.localY);
		
		this._dragLocalX = event.localX;
		this._dragLocalY = event.localY;
	}
	
	private function dragScroll_enterFrameHandler(event:EnterFrameEvent):Void
	{
		var starling:Starling = this.stage.starling;
		var minAutoScrollPixels:Float = this._minimumAutoScrollDistance * (DeviceCapabilities.dpi / starling.contentScaleFactor);
		var velocity:Float = event.passedTime * 500;
		if (this._owner.maxVerticalScrollPosition > this._owner.minVerticalScrollPosition)
		{
			if (this._verticalScrollPosition < this._owner.maxVerticalScrollPosition &&
				this._dragLocalY > (this.visibleHeight - minAutoScrollPixels))
			{
				velocity *= (1 - ((this.visibleHeight - this._dragLocalY) / minAutoScrollPixels));
			}
			else if (this._verticalScrollPosition > this._owner.minVerticalScrollPosition &&
				this._dragLocalY < minAutoScrollPixels)
			{
				velocity *= -(1 - (this._dragLocalY / minAutoScrollPixels));
			}
			else
			{
				velocity = 0;
			}
			if (velocity != 0)
			{
				var verticalScrollPosition:Float = this._owner.verticalScrollPosition + velocity;
				if (verticalScrollPosition > this._owner.maxVerticalScrollPosition)
				{
					verticalScrollPosition = this._owner.maxVerticalScrollPosition;
				}
				else if (verticalScrollPosition < this._owner.minVerticalScrollPosition)
				{
					verticalScrollPosition = this._owner.minVerticalScrollPosition;
				}
				this._owner.verticalScrollPosition = verticalScrollPosition;
			}
		}
		if (this._owner.maxHorizontalScrollPosition > this._owner.minHorizontalScrollPosition)
		{
			if (this._horizontalScrollPosition < this._owner.maxHorizontalScrollPosition &&
				this._dragLocalX > (this.visibleWidth - minAutoScrollPixels))
			{
				velocity *= (1 - ((this.visibleWidth - this._dragLocalX) / minAutoScrollPixels));
			}
			else if (this._horizontalScrollPosition > this._owner.minHorizontalScrollPosition &&
				this._dragLocalX < minAutoScrollPixels)
			{
				velocity *= -(1 - (this._dragLocalX / minAutoScrollPixels));
			}
			else
			{
				velocity = 0;
			}
			if (velocity != 0)
			{
				var horizontalScrollPosition:Float = this._owner.horizontalScrollPosition + velocity;
				if (horizontalScrollPosition > this._owner.maxHorizontalScrollPosition)
				{
					horizontalScrollPosition = this._owner.maxHorizontalScrollPosition;
				}
				else if (verticalScrollPosition < this._owner.minHorizontalScrollPosition)
				{
					horizontalScrollPosition = this._owner.minHorizontalScrollPosition;
				}
				this._owner.horizontalScrollPosition = horizontalScrollPosition;
			}
		}
	}
	
	private function dragExitHandler(event:DragDropEvent):Void
	{
		this._acceptedDrag = false;
		if (this._dropIndicatorSkin != null)
		{
			this._dropIndicatorSkin.removeFromParent(false);
		}
		this._dragLocalX = -1;
		this._dragLocalY = -1;
		this.removeEventListener(Event.ENTER_FRAME, dragScroll_enterFrameHandler);
	}
	
	private function dragDropHandler(event:DragDropEvent):Void
	{
		this._acceptedDrag = false;
		if (this._dropIndicatorSkin != null)
		{
			this._dropIndicatorSkin.removeFromParent(false);
		}
		this._dragLocalX = -1;
		this._dragLocalY = -1;
		this.removeEventListener(Event.ENTER_FRAME, dragScroll_enterFrameHandler);

		var item:Dynamic = event.dragData.getDataForFormat(this._dragFormat);
		var dropIndex:Int = this._dataProvider.length;
		if (Std.isOfType(this._layout, IDragDropLayout))
		{
			var layout:IDragDropLayout = cast this._layout;
			dropIndex = layout.getDropIndex(
				this._horizontalScrollPosition + event.localX,
				this._verticalScrollPosition + event.localY,
				this._layoutItems, 0, 0, this.actualVisibleWidth, this.actualVisibleHeight);
		}
		var dropOffset:Int = 0;
		if (event.dragSource == this._owner)
		{
			var oldIndex:Int = this._dataProvider.getItemIndex(item);
			if (oldIndex < dropIndex)
			{
				dropOffset = -1;
			}
			
			//if we wait to remove this item in the dragComplete handler,
			//the wrong index might be removed.
			this._dataProvider.removeItem(item);
			this._droppedOnSelf = true;
		}
		this._dataProvider.addItemAt(item, dropIndex + dropOffset);
	}
	
	private function dragCompleteHandler(event:DragDropEvent):Void
	{
		if (!event.isDropped)
		{
			//nothing to modify
			return;
		}
		if (this._droppedOnSelf)
		{
			//already modified the data provider in the dragDrop handler
			this._droppedOnSelf = false;
			return;
		}
		var item:Dynamic = event.dragData.getDataForFormat(this._dragFormat);
		this._dataProvider.removeItem(item);
	}
	
	private function itemRenderer_drag_touchHandler(event:TouchEvent):Void
	{
		if (!this._dragEnabled || this.stage == null)
		{
			this._dragTouchPointID = -1;
			return;
		}
		var itemRenderer:IListItemRenderer = cast event.currentTarget;
		var touch:Touch;
		var point:Point;
		if (DragDropManager.isDragging)
		{
			this._dragTouchPointID = -1;
			return;
		}
		if (Std.isOfType(itemRenderer, IDragAndDropItemRenderer))
		{
			var dragProxy:DisplayObject = cast(itemRenderer, IDragAndDropItemRenderer).dragProxy;
			if (dragProxy != null)
			{
				touch = event.getTouch(dragProxy, null, this._dragTouchPointID);
				if (touch == null)
				{
					return;
				}
			}
		}
		if (this._dragTouchPointID != -1)
		{
			var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			if (exclusiveTouch.getClaim(this._dragTouchPointID) != null)
			{
				this._dragTouchPointID = -1;
				return;
			}
			touch = event.getTouch(cast itemRenderer, null, this._dragTouchPointID);
			if (touch.phase == TouchPhase.MOVED)
			{
				point = touch.getLocation(this, Pool.getPoint());
				var currentDragX:Float = point.x;
				var currentDragY:Float = point.y;
				Pool.putPoint(point);
				
				var starling:Starling = this.stage.starling;
				var verticalInchesMoved:Float = (currentDragX - this._startDragX) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
				var horizontalInchesMoved:Float = (currentDragY - this._startDragY) / (DeviceCapabilities.dpi / starling.contentScaleFactor);
				if (Math.abs(horizontalInchesMoved) > this._minimumDragDropDistance ||
					Math.abs(verticalInchesMoved) > this._minimumDragDropDistance)
				{
					var dragData:DragData = new DragData();
					dragData.setDataForFormat(this._dragFormat, itemRenderer.data);
					
					//we don't create a new item renderer here because
					//it might remove accessories or icons from the original
					//item renderer that is still visible in the list.
					var avatar:RenderDelegate = new RenderDelegate(cast itemRenderer);
					avatar.touchable = false;
					avatar.alpha = 0.8;
					
					this._droppedOnSelf = false;
					point = touch.getLocation(cast itemRenderer, Pool.getPoint());
					DragDropManager.startDrag(this._owner, touch, dragData, cast avatar, -point.x, -point.y);
					Pool.putPoint(point);
					exclusiveTouch.claimTouch(this._dragTouchPointID, cast itemRenderer);
					this._dragTouchPointID = -1;
				}
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				this._dragTouchPointID = -1;
			}
		}
		else
		{
			//we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(cast itemRenderer, TouchPhase.BEGAN);
			if (touch == null)
			{
				//we only care about the began phase. ignore all other
				//phases when we don't have a saved touch ID.
				return;
			}
			this._dragTouchPointID = touch.id;
			point = touch.getLocation(this, Pool.getPoint());
			this._startDragX = point.x;
			this._startDragY = point.y;
			Pool.putPoint(point);
		}
	}
	
}

class ItemRendererFactoryStorage
{
	public function new()
	{

	}

	public var activeItemRenderers:Array<IListItemRenderer> = new Array<IListItemRenderer>();
	public var inactiveItemRenderers:Array<IListItemRenderer> = new Array<IListItemRenderer>();
}