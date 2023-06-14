/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

import feathers.starling.core.FeathersControl;
import feathers.starling.core.IValidating;
import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.HorizontalLayout;
import feathers.starling.layout.ILayout;
import feathers.starling.layout.IVirtualLayout;
import feathers.starling.layout.LayoutBoundsResult;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.layout.ViewPortBounds;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.PageIndicatorInteractionMode;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Displays a selected index, usually corresponding to a page index in
 * another UI control, using a highlighted symbol.
 *
 * @see ../../../help/page-indicator.html How to use the Feathers PageIndicator component
 *
 * @productversion Feathers 1.0.0
 */
class PageIndicator extends FeathersControl 
{
	/**
	 * @private
	 */
	private static var LAYOUT_RESULT:LayoutBoundsResult = new LayoutBoundsResult();

	/**
	 * @private
	 */
	private static var SUGGESTED_BOUNDS:ViewPortBounds = new ViewPortBounds();

	/**
	 * The default <code>IStyleProvider</code> for all <code>PageIndicator</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * @private
	 */
	private static function defaultSelectedSymbolFactory():Quad
	{
		return new Quad(25, 25, 0xffffff);
	}

	/**
	 * @private
	 */
	private static function defaultNormalSymbolFactory():Quad
	{
		return new Quad(25, 25, 0xcccccc);
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.isQuickHitAreaEnabled = true;
		this.addEventListener(TouchEvent.TOUCH, touchHandler);
	}
	
	/**
	 * @private
	 */
	private var selectedSymbol:DisplayObject;

	/**
	 * @private
	 */
	private var cache:Array<DisplayObject> = new Array<DisplayObject>();

	/**
	 * @private
	 */
	private var unselectedSymbols:Array<DisplayObject> = new Array<DisplayObject>();

	/**
	 * @private
	 */
	private var symbols:Array<DisplayObject> = new Array<DisplayObject>();

	/**
	 * @private
	 */
	private var touchPointID:Int = -1;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return PageIndicator.globalStyleProvider;
	}
	
	/**
	 * The number of available pages.
	 *
	 * <p>In the following example, the page count is changed:</p>
	 *
	 * <listing version="3.0">
	 * pages.pageCount = 5;</listing>
	 *
	 * @default 1
	 */
	public var pageCount(get, set):Int;
	private var _pageCount:Int = 1;
	private function get_pageCount():Int { return this._pageCount; }
	private function set_pageCount(value:Int):Int
	{
		if (this._pageCount == value)
		{
			return value;
		}
		this._pageCount = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._pageCount;
	}
	
	/**
	 * The currently selected index.
	 *
	 * <p>In the following example, the page indicator's selected index is
	 * changed:</p>
	 *
	 * <listing version="3.0">
	 * pages.selectedIndex = 2;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected index:</p>
	 *
	 * <listing version="3.0">
	 * function pages_changeHandler( event:Event ):void
	 * {
	 *     var pages:PageIndicator = PageIndicator( event.currentTarget );
	 *     var index:int = pages.selectedIndex;
	 * 
	 * }
	 * pages.addEventListener( Event.CHANGE, pages_changeHandler );</listing>
	 *
	 * @default 0
	 */
	public var selectedIndex(get, set):Int;
	private var _selectedIndex:Int = 0;
	private function get_selectedIndex():Int { return this._selectedIndex; }
	private function set_selectedIndex(value:Int):Int
	{
		value = Std.int(Math.max(0, Math.min(value, this._pageCount - 1)));
		if (this._selectedIndex == value)
		{
			return value;
		}
		this._selectedIndex = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
		return this._selectedIndex;
	}
	
	/**
	 * @private
	 */
	public var interactionMode(get, set):String;
	private var _interactionMode:String = PageIndicatorInteractionMode.PREVIOUS_NEXT;
	private function get_interactionMode():String { return this._interactionMode; }
	private function set_interactionMode(value:String):String
	{
		if (this.processStyleRestriction("interactionMode"))
		{
			return value;
		}
		return this._interactionMode = value;
	}
	
	/**
	 * @private
	 */
	private var _layout:ILayout;
	
	/**
	 * @private
	 */
	public var direction(get, set):String;
	private var _direction:String = Direction.HORIZONTAL;
	private function get_direction():String { return this._direction; }
	private function set_direction(value:String):String
	{
		if (this.processStyleRestriction("direction"))
		{
			return value;
		}
		if (this._direction == value)
		{
			return value;
		}
		this._direction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._direction;
	}
	
	/**
	 * @private
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.CENTER;
	private function get_horizontalAlign():String { return this._horizontalAlign; }
	private function set_horizontalAlign(value:String):String
	{
		if (this.processStyleRestriction("horizontalAlign"))
		{
			return value;
		}
		if (this._horizontalAlign == value)
		{
			return value;
		}
		this._horizontalAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._horizontalAlign;
	}
	
	/**
	 * @private
	 */
	public var verticalAlign(get, set):String;
	private var _verticalAlign:String = VerticalAlign.MIDDLE;
	private function get_verticalAlign():String { return this._verticalAlign; }
	private function set_verticalAlign(value:String):String
	{
		if (this.processStyleRestriction("verticalAlign"))
		{
			return value;
		}
		if (this._verticalAlign == value)
		{
			return value;
		}
		this._verticalAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._verticalAlign;
	}
	
	/**
	 * @private
	 */
	public var gap(get, set):Float;
	private var _gap:Float = 0;
	private function get_gap():Float { return this._gap; }
	private function set_gap(value:Float):Float
	{
		if (this.processStyleRestriction("gap"))
		{
			return value;
		}
		if (this._gap == value)
		{
			return value;
		}
		this._gap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._gap;
	}
	
	/**
	 * @private
	 */
	public var padding(get, set):Float;
	private function get_padding():Float { return this._paddingTop; }
	private function set_padding(value:Float):Float
	{
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		return this.paddingLeft = value;
	}
	
	/**
	 * @private
	 */
	public var paddingTop(get, set):Float;
	private var _paddingTop:Float = 0;
	private function get_paddingTop():Float { return this._paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		if (this.processStyleRestriction("paddingTop"))
		{
			return value;
		}
		if (this._paddingTop == value)
		{
			return value;
		}
		this._paddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingTop;
	}
	
	/**
	 * @private
	 */
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight():Float { return this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if (this.processStyleRestriction("paddingRight"))
		{
			return value;
		}
		if (this._paddingRight == value)
		{
			return value;
		}
		this._paddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingRight;
	}
	
	/**
	 * @private
	 */
	public var paddingBottom(get, set):Float;
	private var _paddingBottom:Float = 0;
	private function get_paddingBottom():Float { return this._paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		if (this.processStyleRestriction("paddingBottom"))
		{
			return value;
		}
		if (this._paddingBottom == value)
		{
			return value;
		}
		this._paddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingBottom;
	}
	
	/**
	 * @private
	 */
	public var paddingLeft(get, set):Float;
	private var _paddingLeft:Float = 0;
	private function get_paddingLeft():Float { return this._paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		if (this.processStyleRestriction("paddingLeft"))
		{
			return value;
		}
		if (this._paddingLeft == value)
		{
			return value;
		}
		this._paddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingLeft;
	}
	
	/**
	 * @private
	 */
	public var normalSymbolFactory(get, set):Void->DisplayObject;
	private var _normalSymbolFactory:Void->DisplayObject = defaultNormalSymbolFactory;
	private function get_normalSymbolFactory():Void->DisplayObject { return this._normalSymbolFactory; }
	private function set_normalSymbolFactory(value:Void->DisplayObject):Void->DisplayObject
	{
		if (this.processStyleRestriction("normalSymbolFactory"))
		{
			return value;
		}
		if (this._normalSymbolFactory == value)
		{
			return value;
		}
		this._normalSymbolFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._normalSymbolFactory;
	}
	
	/**
	 * @private
	 */
	public var selectedSymbolFactory(get, set):Void->DisplayObject;
	private var _selectedSymbolFactory:Void->DisplayObject = defaultSelectedSymbolFactory;
	private function get_selectedSymbolFactory():Void->DisplayObject { return this._selectedSymbolFactory; }
	private function set_selectedSymbolFactory(value:Void->DisplayObject):Void->DisplayObject
	{
		if (this.processStyleRestriction("selectedSymbolFactory"))
		{
			return value;
		}
		if (this._selectedSymbolFactory == value)
		{
			return value;
		}
		this._selectedSymbolFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._selectedSymbolFactory;
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var selectionInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		
		if (dataInvalid || selectionInvalid || stylesInvalid)
		{
			this.refreshSymbols(stylesInvalid);
		}
		
		this.layoutSymbols(layoutInvalid);
	}
	
	/**
	 * @private
	 */
	private function refreshSymbols(symbolsInvalid:Bool):Void
	{
		this.symbols.resize(0);
		var temp:Array<DisplayObject> = this.cache;
		var symbolCount:Int;
		var symbol:DisplayObject;
		if (symbolsInvalid)
		{
			symbolCount = this.unselectedSymbols.length;
			for (i in 0...symbolCount)
			{
				symbol = this.unselectedSymbols.shift();
				this.removeChild(symbol, true);
			}
			if (this.selectedSymbol != null)
			{
				this.removeChild(this.selectedSymbol, true);
				this.selectedSymbol = null;
			}
		}
		this.cache = this.unselectedSymbols;
		this.unselectedSymbols = temp;
		for (i in 0...this._pageCount)
		{
			if (i == this._selectedIndex)
			{
				if (this.selectedSymbol == null)
				{
					this.selectedSymbol = this._selectedSymbolFactory();
					this.addChild(this.selectedSymbol);
				}
				this.symbols.push(this.selectedSymbol);
				if (Std.isOfType(this.selectedSymbol, IValidating))
				{
					cast(this.selectedSymbol, IValidating).validate();
				}
			}
			else
			{
				if (this.cache.length != 0)
				{
					symbol = this.cache.shift();
				}
				else
				{
					symbol = this._normalSymbolFactory();
					this.addChild(symbol);
				}
				this.unselectedSymbols.push(symbol);
				this.symbols.push(symbol);
				if  (Std.isOfType(symbol, IValidating))
				{
					cast(symbol, IValidating).validate();
				}
			}
		}
		
		symbolCount = this.cache.length;
		for (i in 0...symbolCount)
		{
			symbol = this.cache.shift();
			this.removeChild(symbol, true);
		}
	}
	
	/**
	 * @private
	 */
	private function layoutSymbols(layoutInvalid:Bool):Void
	{
		if (layoutInvalid)
		{
			if (this._direction == Direction.VERTICAL && !Std.isOfType(this._layout, VerticalLayout))
			{
				this._layout = new VerticalLayout();
				cast(this._layout, IVirtualLayout).useVirtualLayout = false;
			}
			else if (this._direction != Direction.VERTICAL && !Std.isOfType(this._layout, HorizontalLayout))
			{
				this._layout = new HorizontalLayout();
				cast(this._layout, IVirtualLayout).useVirtualLayout = false;
			}
			if (Std.isOfType(this._layout, VerticalLayout))
			{
				var verticalLayout:VerticalLayout = cast this._layout;
				verticalLayout.paddingTop = this._paddingTop;
				verticalLayout.paddingRight = this._paddingRight;
				verticalLayout.paddingBottom = this._paddingBottom;
				verticalLayout.paddingLeft = this._paddingLeft;
				verticalLayout.gap = this._gap;
				verticalLayout.horizontalAlign = this._horizontalAlign;
				verticalLayout.verticalAlign = this._verticalAlign;
			}
			if (Std.isOfType(this._layout, HorizontalLayout))
			{
				var horizontalLayout:HorizontalLayout = cast this._layout;
				horizontalLayout.paddingTop = this._paddingTop;
				horizontalLayout.paddingRight = this._paddingRight;
				horizontalLayout.paddingBottom = this._paddingBottom;
				horizontalLayout.paddingLeft = this._paddingLeft;
				horizontalLayout.gap = this._gap;
				horizontalLayout.horizontalAlign = this._horizontalAlign;
				horizontalLayout.verticalAlign = this._verticalAlign;
			}
		}
		SUGGESTED_BOUNDS.x = SUGGESTED_BOUNDS.y = 0;
		SUGGESTED_BOUNDS.scrollX = SUGGESTED_BOUNDS.scrollY = 0;
		SUGGESTED_BOUNDS.explicitWidth = this._explicitWidth;
		SUGGESTED_BOUNDS.explicitHeight = this._explicitHeight;
		SUGGESTED_BOUNDS.maxWidth = this._explicitMaxWidth;
		SUGGESTED_BOUNDS.maxHeight = this._explicitMaxHeight;
		SUGGESTED_BOUNDS.minWidth = this._explicitMinWidth;
		SUGGESTED_BOUNDS.minHeight = this._explicitMinHeight;
		this._layout.layout(this.symbols, SUGGESTED_BOUNDS, LAYOUT_RESULT);
		this.saveMeasurements(LAYOUT_RESULT.contentWidth, LAYOUT_RESULT.contentHeight,
			LAYOUT_RESULT.contentWidth, LAYOUT_RESULT.contentHeight);
	}
	
	/**
	 * @private
	 */
	private function touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled || this._pageCount < 2)
		{
			this.touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		if (this.touchPointID >= 0)
		{
			touch = event.getTouch(this, TouchPhase.ENDED, this.touchPointID);
			if (touch == null)
			{
				return;
			}
			this.touchPointID = -1;
			var point:Point = Pool.getPoint();
			touch.getLocation(this.stage, point);
			var isInBounds:Bool = this.contains(this.stage.hitTest(point));
			if (isInBounds)
			{
				var lastPageIndex:Int = this._pageCount - 1;
				this.globalToLocal(point, point);
				var newIndex:Int;
				if (this._direction == Direction.VERTICAL)
				{
					if (this._interactionMode == PageIndicatorInteractionMode.PRECISE)
					{
						var symbolHeight:Float = this.selectedSymbol.height + (this.unselectedSymbols[0].height + this._gap) * lastPageIndex;
						newIndex = Math.round(lastPageIndex * (point.y - this.symbols[0].y) / symbolHeight);
						if (newIndex < 0)
						{
							newIndex = 0;
						}
						else if (newIndex > lastPageIndex)
						{
							newIndex = lastPageIndex;
						}
						this.selectedIndex = newIndex;
					}
					else //previous/next
					{
						if (point.y < this.selectedSymbol.y)
						{
							this.selectedIndex = Std.int(Math.max(0, this._selectedIndex - 1));
						}
						if (point.y > (this.selectedSymbol.y + this.selectedSymbol.height))
						{
							this.selectedIndex = Std.int(Math.min(lastPageIndex, this._selectedIndex + 1));
						}
					}
				}
				else
				{
					if (this._interactionMode == PageIndicatorInteractionMode.PRECISE)
					{
						var symbolWidth:Float = this.selectedSymbol.width + (this.unselectedSymbols[0].width + this._gap) * lastPageIndex;
						newIndex = Math.round(lastPageIndex * (point.x - this.symbols[0].x) / symbolWidth);
						if (newIndex < 0)
						{
							newIndex = 0;
						}
						else if (newIndex >= this._pageCount)
						{
							newIndex = lastPageIndex;
						}
						this.selectedIndex = newIndex;
					}
					else //previous/next
					{
						if (point.x < this.selectedSymbol.x)
						{
							this.selectedIndex = Std.int(Math.max(0, this._selectedIndex - 1));
						}
						if (point.x > (this.selectedSymbol.x + this.selectedSymbol.width))
						{
							this.selectedIndex = Std.int(Math.min(lastPageIndex, this._selectedIndex + 1));
						}
					}
				}
			}
			Pool.putPoint(point);
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this.touchPointID = touch.id;
		}
	}
	
}