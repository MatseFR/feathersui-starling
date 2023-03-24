/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusDisplayObject;
import feathers.core.IMeasureDisplayObject;
import feathers.core.ITextBaselineControl;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.core.ToggleGroup;
import feathers.data.IListCollection;
import feathers.dragDrop.DragData;
import feathers.dragDrop.DragDropManager;
import feathers.dragDrop.IDragSource;
import feathers.dragDrop.IDropTarget;
import feathers.events.CollectionEventType;
import feathers.events.DragDropEvent;
import feathers.events.ExclusiveTouch;
import feathers.events.FeathersEventType;
import feathers.layout.Direction;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.ViewPortBounds;
import feathers.skins.IStyleProvider;
import feathers.utils.type.ArgumentsCount;
import feathers.utils.type.Property;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * A line of tabs (vertical or horizontal), where one may be selected at a
 * time.
 *
 * <p>The following example sets the data provider, selects the second tab,
 * and listens for when the selection changes:</p>
 *
 * <listing version="3.0">
 * var tabs:TabBar = new TabBar();
 * tabs.dataProvider = new ArrayCollection(
 * [
 *     { label: "One" },
 *     { label: "Two" },
 *     { label: "Three" },
 * ]);
 * tabs.selectedIndex = 1;
 * tabs.addEventListener( Event.CHANGE, tabs_changeHandler );
 * this.addChild( tabs );</listing>
 *
 * @see ../../../help/tab-bar.html How to use the Feathers TabBar component
 *
 * @productversion Feathers 1.0.0
 */
class TabBar extends FeathersControl implements IFocusDisplayObject implements ITextBaselineControl implements IDragSource implements IDropTarget
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_TAB_FACTORY:String = "tabFactory";

	/**
	 * @private
	 */
	private static var DEFAULT_TAB_FIELDS:Array<String> = 
	[
		"upIcon",
		"downIcon",
		"hoverIcon",
		"disabledIcon",
		"defaultSelectedIcon",
		"selectedUpIcon",
		"selectedDownIcon",
		"selectedHoverIcon",
		"selectedDisabledIcon",
		"name"
	];

	/**
	 * @private
	 */
	private static inline var DEFAULT_DRAG_FORMAT:String = "feathers-tab-bar-item";

	/**
	 * The default value added to the <code>styleNameList</code> of the tabs.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TAB:String = "feathers-tab-bar-tab";

	/**
	 * The default <code>IStyleProvider</code> for all <code>TabBar</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * @private
	 */
	private static function defaultTabFactory():ToggleButton
	{
		return new ToggleButton();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the tabs. This
	 * variable is <code>protected</code> so that sub-classes can customize
	 * the tab style name in their constructors instead of using the default
	 * style name defined by <code>DEFAULT_CHILD_STYLE_NAME_TAB</code>.
	 *
	 * <p>To customize the tab style name without subclassing, see
	 * <code>customTabStyleName</code>.</p>
	 *
	 * @see #style:customTabStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var tabStyleName:String = DEFAULT_CHILD_STYLE_NAME_TAB;

	/**
	 * The value added to the <code>styleNameList</code> of the first tab.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the first tab style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TAB</code>.
	 *
	 * <p>To customize the first tab name without subclassing, see
	 * <code>customFirstTabStyleName</code>.</p>
	 *
	 * @see #style:customFirstTabStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var firstTabStyleName:String = DEFAULT_CHILD_STYLE_NAME_TAB;

	/**
	 * The value added to the <code>styleNameList</code> of the last tab.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the last tab style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TAB</code>.
	 *
	 * <p>To customize the last tab name without subclassing, see
	 * <code>customLastTabStyleName</code>.</p>
	 *
	 * @see #style:customLastTabStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var lastTabStyleName:String = DEFAULT_CHILD_STYLE_NAME_TAB;
	
	/**
	 * The toggle group.
	 */
	private var toggleGroup:ToggleGroup;

	/**
	 * @private
	 */
	private var activeFirstTab:ToggleButton;

	/**
	 * @private
	 */
	private var inactiveFirstTab:ToggleButton;

	/**
	 * @private
	 */
	private var activeLastTab:ToggleButton;

	/**
	 * @private
	 */
	private var inactiveLastTab:ToggleButton;

	/**
	 * @private
	 */
	private var _layoutItems:Array<DisplayObject> = new Array<DisplayObject>();

	/**
	 * @private
	 */
	private var activeTabs:Array<ToggleButton> = new Array<ToggleButton>();

	/**
	 * @private
	 */
	private var inactiveTabs:Array<ToggleButton> = new Array<ToggleButton>();

	/**
	 * @private
	 */
	private var _tabToItem:Map<ToggleButton, Dynamic> = new Map<ToggleButton, Dynamic>();
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return TabBar.globalStyleProvider;
	}
	
	/**
	 * The collection of data to be displayed with tabs. The default
	 * <em>tab initializer</em> interprets this data to customize the tabs
	 * with various fields available to buttons, including the following:
	 *
	 * <ul>
	 *     <li>label</li>
	 *     <li>defaultIcon</li>
	 *     <li>upIcon</li>
	 *     <li>downIcon</li>
	 *     <li>hoverIcon</li>
	 *     <li>disabledIcon</li>
	 *     <li>defaultSelectedIcon</li>
	 *     <li>selectedUpIcon</li>
	 *     <li>selectedDownIcon</li>
	 *     <li>selectedHoverIcon</li>
	 *     <li>selectedDisabledIcon</li>
	 *     <li>isEnabled</li>
	 *     <li>name</li>
	 * </ul>
	 *
	 * <p>The following example passes in a data provider:</p>
	 *
	 * <listing version="3.0">
	 * list.dataProvider = new ArrayCollection(
	 * [
	 *     { label: "General", defaultIcon: new Image( generalTexture ) },
	 *     { label: "Security", defaultIcon: new Image( securityTexture ) },
	 *     { label: "Advanced", defaultIcon: new Image( advancedTexture ) },
	 * ]);</listing>
	 *
	 * @default null
	 *
	 * @see #tabInitializer
	 * @see feathers.data.ArrayCollection
	 * @see feathers.data.VectorCollection
	 * @see feathers.data.XMLListCollection
	 */
	public var dataProvider(get, set):IListCollection;
	private var _dataProvider:IListCollection;
	private function get_dataProvider():IListCollection { return this._dataProvider; }
	private function set_dataProvider(value:IListCollection):IListCollection
	{
		if (this._dataProvider == value)
		{
			return value;
		}
		var oldSelectedIndex:Int = this.selectedIndex;
		var oldSelectedItem:Dynamic = this.selectedItem;
		if (this._dataProvider != null)
		{
			this._dataProvider.removeEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ALL, dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.SORT_CHANGE, dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);
			this._dataProvider.removeEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null)
		{
			this._dataProvider.addEventListener(CollectionEventType.ADD_ITEM, dataProvider_addItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ALL, dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.FILTER_CHANGE, dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(CollectionEventType.SORT_CHANGE, dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);
			this._dataProvider.addEventListener(CollectionEventType.RESET, dataProvider_resetHandler);
		}
		if (this._dataProvider == null || this._dataProvider.length == 0)
		{
			this.selectedIndex = -1;
		}
		else
		{
			this.selectedIndex = 0;
		}
		//this ensures that Event.CHANGE will dispatch for selectedItem
		//changing, even if selectedIndex has not changed.
		if (this.selectedIndex == oldSelectedIndex && this.selectedItem != oldSelectedItem)
		{
			this.dispatchEventWith(Event.CHANGE);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataProvider;
	}
	
	/**
	 * @private
	 */
	private var verticalLayout:VerticalLayout;

	/**
	 * @private
	 */
	private var horizontalLayout:HorizontalLayout;

	/**
	 * @private
	 */
	private var _viewPortBounds:ViewPortBounds = new ViewPortBounds();

	/**
	 * @private
	 */
	private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
	
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._direction;
	}
	
	/**
	 * @private
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.JUSTIFY;
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._horizontalAlign;
	}
	
	/**
	 * @private
	 */
	public var verticalAlign(get, set):String;
	private var _verticalAlign:String = VerticalAlign.JUSTIFY;
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._verticalAlign;
	}
	
	/**
	 * @private
	 */
	public var selectionSkin(get, set):DisplayObject;
	private var _selectionSkin:DisplayObject;
	private function get_selectionSkin():DisplayObject { return this._selectionSkin; }
	private function set_selectionSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("selectionSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._selectionSkin == value)
		{
			return value;
		}
		if (this._selectionSkin != null &&
			this._selectionSkin.parent == this)
		{
			this._selectionSkin.removeFromParent(false);
		}
		this._selectionSkin = value;
		if (this._selectionSkin != null)
		{
			this._selectionSkin.touchable = false;
			this.addChild(this._selectionSkin);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._selectionSkin;
	}
	
	/**
	 * @private
	 */
	private var _selectionChangeTween:Tween;
	
	/**
	 * @private
	 */
	public var selectionChangeDuration(get, set):Float;
	private var _selectionChangeDuration:Float = 0.25;
	private function get_selectionChangeDuration():Float { return this._selectionChangeDuration; }
	private function set_selectionChangeDuration(value:Float):Float
	{
		if (this.processStyleRestriction("selectionChangeDuration"))
		{
			return value;
		}
		return this._selectionChangeDuration = value;
	}
	
	/**
	 * @private
	 */
	public var selectionChangeEase(get, set):Dynamic;
	private var _selectionChangeEase:Dynamic = Transitions.EASE_OUT;
	private function get_selectionChangeEase():Dynamic { return this._selectionChangeEase; }
	private function set_selectionChangeEase(value:Dynamic):Dynamic
	{
		if (this.processStyleRestriction("selectionChangeEase"))
		{
			return value;
		}
		return this._selectionChangeEase = value;
	}
	
	/**
	 * @private
	 */
	public var distributeTabSizes(get, set):Bool;
	private var _distributeTabSizes:Bool = true;
	private function get_distributeTabSizes():Bool { return this._distributeTabSizes; }
	private function set_distributeTabSizes(value:Bool):Bool
	{
		if (this.processStyleRestriction("distributeTabSizes"))
		{
			return value;
		}
		if (this._distributeTabSizes == value)
		{
			return value;
		}
		this._distributeTabSizes = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._distributeTabSizes;
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._gap;
	}
	
	/**
	 * @private
	 */
	public var firstGap(get, set):Float;
	private var _firstGap:Float = Math.NaN;
	private function get_firstGap():Float { return this._firstGap; }
	private function set_firstGap(value:Float):Float
	{
		if (this.processStyleRestriction("firstGap"))
		{
			return value;
		}
		if (this._firstGap == value)
		{
			return value;
		}
		this._firstGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._firstGap;
	}
	
	/**
	 * @private
	 */
	public var lastGap(get, set):Float;
	private var _lastGap:Float = Math.NaN;
	private function get_lastGap():Float { return this._lastGap; }
	private function set_lastGap(value:Float):Float
	{
		if (this.processStyleRestriction("lastGap"))
		{
			return value;
		}
		if (this._lastGap == value)
		{
			return value;
		}
		this._lastGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._lastGap;
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
	 * Creates each tab. A tab must be an instance of
	 * <code>ToggleButton</code>. This factory can be used to change
	 * properties on the tabs when they are first created. For instance, if
	 * you are skinning Feathers components without a theme, you might use
	 * this factory to set skins and other styles on a tab.
	 *
	 * <p>Optionally, the first tab and the last tab may be different than
	 * the other tabs in the middle. Use the <code>firstTabFactory</code>
	 * and/or the <code>lastTabFactory</code> to customize one or both of
	 * these tabs.</p>
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():ToggleButton</pre>
	 *
	 * <p>In the following example, a custom tab factory is passed to the
	 * tab bar:</p>
	 *
	 * <listing version="3.0">
	 * tabs.tabFactory = function():ToggleButton
	 * {
	 *     var tab:ToggleButton = new ToggleButton();
	 *     tab.defaultSkin = new Image( upTexture );
	 *     tab.defaultSelectedSkin = new Image( selectedTexture );
	 *     tab.downSkin = new Image( downTexture );
	 *     return tab;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ToggleButton
	 * @see #firstTabFactory
	 * @see #lastTabFactory
	 */
	public var tabFactory(get, set):Void->ToggleButton;
	private var _tabFactory:Void->ToggleButton = defaultTabFactory;
	private function get_tabFactory():Void->ToggleButton { return this._tabFactory; }
	private function set_tabFactory(value:Void->ToggleButton):Void->ToggleButton
	{
		if (this._tabFactory == value)
		{
			return value;
		}
		this._tabFactory = value;
		this.invalidate(INVALIDATION_FLAG_TAB_FACTORY);
		return this._tabFactory;
	}
	
	/**
	 * If not <code>null</code>, creates the first tab. If the
	 * <code>firstTabFactory</code> is <code>null</code>, then the tab bar
	 * will use the <code>tabFactory</code>. The first tab must be an
	 * instance of <code>ToggleButton</code>. This factory can be used to
	 * change properties on the first tab when it is initially created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the first
	 * tab.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():ToggleButton</pre>
	 *
	 * <p>In the following example, a custom first tab factory is passed to the
	 * tab bar:</p>
	 *
	 * <listing version="3.0">
	 * tabs.firstTabFactory = function():ToggleButton
	 * {
	 *     var tab:ToggleButton = new ToggleButton();
	 *     tab.defaultSkin = new Image( upTexture );
	 *     tab.defaultSelectedSkin = new Image( selectedTexture );
	 *     tab.downSkin = new Image( downTexture );
	 *     return tab;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ToggleButton
	 * @see #tabFactory
	 * @see #lastTabFactory
	 */
	public var firstTabFactory(get, set):Void->ToggleButton;
	private var _firstTabFactory:Void->ToggleButton;
	private function get_firstTabFactory():Void->ToggleButton { return this._firstTabFactory; }
	private function set_firstTabFactory(value:Void->ToggleButton):Void->ToggleButton
	{
		if (this._firstTabFactory == value)
		{
			return value;
		}
		this._firstTabFactory = value;
		this.invalidate(INVALIDATION_FLAG_TAB_FACTORY);
		return this._firstTabFactory;
	}
	
	/**
	 * If not <code>null</code>, creates the last tab. If the
	 * <code>lastTabFactory</code> is <code>null</code>, then the tab bar
	 * will use the <code>tabFactory</code>. The last tab must be an
	 * instance of <code>ToggleButton</code>. This factory can be used to
	 * change properties on the last tab when it is initially created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set skins and other styles on the last
	 * tab.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():ToggleButton</pre>
	 *
	 * <p>In the following example, a custom last tab factory is passed to the
	 * tab bar:</p>
	 *
	 * <listing version="3.0">
	 * tabs.lastTabFactory = function():ToggleButton
	 * {
	 *     var tab:ToggleButton = new Button();
	 *     tab.defaultSkin = new Image( upTexture );
	 *     tab.defaultSelectedSkin = new Image( selectedTexture );
	 *     tab.downSkin = new Image( downTexture );
	 *     return tab;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ToggleButton
	 * @see #tabFactory
	 * @see #firstTabFactory
	 */
	public var lastTabFactory(get, set):Void->ToggleButton;
	private var _lastTabFactory:Void->ToggleButton;
	private function get_lastTabFactory():Void->ToggleButton { return this._lastTabFactory; }
	private function set_lastTabFactory(value:Void->ToggleButton):Void->ToggleButton
	{
		if (this._lastTabFactory == value)
		{
			return value;
		}
		this._lastTabFactory = value;
		this.invalidate(INVALIDATION_FLAG_TAB_FACTORY);
		return this._lastTabFactory;
	}
	
	/**
	 * Modifies the properties of an individual tab, using an item from the
	 * data provider. The default initializer will set the tab's label and
	 * icons. A custom tab initializer can be provided to update additional
	 * properties or to use different field names in the data provider.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function( tab:ToggleButton, item:Object ):void</pre>
	 *
	 * <p>In the following example, a custom tab initializer is passed to the
	 * tab bar:</p>
	 *
	 * <listing version="3.0">
	 * tabs.tabInitializer = function( tab:ToggleButton, item:Object ):void
	 * {
	 *     tab.label = item.text;
	 *     tab.defaultIcon = item.icon;
	 * };</listing>
	 *
	 * @see #dataProvider
	 * @see #tabReleaser
	 */
	public var tabInitializer(get, set):ToggleButton->Dynamic->Void;
	private var _tabInitializer:ToggleButton->Dynamic->Void;
	private function get_tabInitializer():ToggleButton->Dynamic->Void { return this._tabInitializer; }
	private function set_tabInitializer(value:ToggleButton->Dynamic->Void):ToggleButton->Dynamic->Void
	{
		if (this._tabInitializer == value)
		{
			return value;
		}
		this._tabInitializer = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._tabInitializer;
	}
	
	/**
	 * Resets the properties of an individual tab, using the item from the
	 * data provider that was associated with the tab.
	 *
	 * <p>This function is expected to have one of the following signatures:</p>
	 * <pre>function( tab:ToggleButton ):void</pre>
	 * <pre>function( tab:ToggleButton, oldItem:Object ):void</pre>
	 *
	 * <p>In the following example, a custom tab releaser is passed to the
	 * tab bar:</p>
	 *
	 * <listing version="3.0">
	 * tabs.tabReleaser = function( tab:ToggleButton, oldItem:Object ):void
	 * {
	 *     tab.label = null;
	 *     tab.defaultIcon = null;
	 * };</listing>
	 *
	 * @see #tabInitializer
	 */
	public var tabReleaser(get, set):ToggleButton->Dynamic->Void;
	private var _tabReleaser:ToggleButton->Dynamic->Void;
	private function get_tabReleaser():ToggleButton->Dynamic->Void { return this._tabReleaser; }
	private function set_tabReleaser(value:ToggleButton->Dynamic->Void):ToggleButton->Dynamic->Void
	{
		if (this._tabReleaser == value)
		{
			return value;
		}
		this._tabReleaser = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._tabReleaser;
	}
	
	/**
	 * The field in the item that contains the label text to be displayed by
	 * the tabs. If the item does not have this field, and a
	 * <code>labelFunction</code> is not defined, then the tabs will
	 * default to calling <code>toString()</code> on the item.
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
	 * tabs.labelField = "text";</listing>
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
	 * A function used to generate label text for a specific tab. If this
	 * function is not <code>null</code>, then the <code>labelField</code>
	 * will be ignored.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):String</pre>
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
	 * tabs.labelFunction = function( item:Object ):String
	 * {
	 *    return item.label + " (" + item.unread + ")";
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #labelField
	 */
	public var labelFunction(get, set):Dynamic->String;
	private var _labelFunction:Dynamic->String;
	private function get_labelFunction():Dynamic->String { return this._labelFunction; }
	private function set_labelFunction(value:Dynamic->String):Dynamic->String
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
	 * The field in the item that determines if the tab is enabled. If the
	 * item does not have this field, and a <code>enabledFunction</code> is
	 * not defined, then the tab will default to being enabled, unless the
	 * tab bar is not enabled. All tabs will always be disabled if the tab
	 * bar is disabled.
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
	 * tabs.enabledField = "isEnabled";</listing>
	 *
	 * @default "enabled"
	 *
	 * @see #enabledFunction
	 */
	public var enabledField(get, set):String;
	private var _enabledField:String = "isEnabled";
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
	 * The field in the item that contains a display object to be displayed
	 * as an icon or other graphic next to the label in the tab.
	 *
	 * <p>Warning: It is your responsibility to dispose all icons
	 * included in the data provider and accessed with <code>iconField</code>,
	 * or any display objects returned by <code>iconFunction</code>.
	 * These display objects will not be disposed when the list is disposed.
	 * Not disposing an icon may result in a memory leak.</p>
	 *
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon field is customized:</p>
	 *
	 * <listing version="3.0">
	 * tabs.iconField = "photo";</listing>
	 *
	 * @default "icon"
	 *
	 * @see #iconFunction
	 */
	public var iconField(get, set):String;
	private var _iconField:String = "defaultIcon";
	//I'd like to use "icon" here instead, but defaultIcon is needed for
	//backwards compatibility...
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
	 * A function used to generate an icon for a specific tab, based on its
	 * associated item in the data provider.
	 *
	 * <p>Note: This function may be called more than once for each
	 * individual item in the tab bar's data provider. The function should
	 * not simply return a new icon every time. This will result in the
	 * unnecessary creation and destruction of many icons, which will
	 * overwork the garbage collector, hurt performance, and possibly lead
	 * to memory leaks. It's better to return a new icon the first time this
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
	 * <p>All of the icon fields and functions, ordered by priority:</p>
	 * <ol>
	 *     <li><code>iconFunction</code></li>
	 *     <li><code>iconField</code></li>
	 * </ol>
	 *
	 * <p>In the following example, the icon function is customized:</p>
	 *
	 * <listing version="3.0">
	 * var cachedIcons:Dictionary = new Dictionary( true );
	 * tabs.iconFunction = function( item:Object ):DisplayObject
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
	 * @see #iconField
	 */
	public var iconFunction(get, set):Dynamic->DisplayObject;
	private var _iconFunction:Dynamic->DisplayObject;
	private function get_iconFunction():Dynamic->DisplayObject { return this._iconFunction; }
	private function set_iconFunction(value:Dynamic->DisplayObject):Dynamic->DisplayObject
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
	 * A function used to determine if a specific tab is enabled. If this
	 * function is not <code>null</code>, then the <code>enabledField</code>
	 * will be ignored.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:Object ):Boolean</pre>
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
	 * tabs.enabledFunction = function( item:Object ):Boolean
	 * {
	 *    return item.isEnabled;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #enabledField
	 */
	public var enabledFunction(get, set):Dynamic->Bool;
	private var _enabledFunction:Dynamic->Bool;
	private function get_enabledFunction():Dynamic->Bool { return this._enabledFunction; }
	private function set_enabledFunction(value:Dynamic->Bool):Dynamic->Bool
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
	private var _ignoreSelectionChanges:Bool = false;
	
	/**
	 * The index of the currently selected tab. Returns -1 if no tab is
	 * selected.
	 *
	 * <p>In the following example, the tab bar's selected index is changed:</p>
	 *
	 * <listing version="3.0">
	 * tabs.selectedIndex = 2;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected index:</p>
	 *
	 * <listing version="3.0">
	 * function tabs_changeHandler( event:Event ):void
	 * {
	 *     var tabs:TabBar = TabBar( event.currentTarget );
	 *     var index:int = tabs.selectedIndex;
	 * 
	 * }
	 * tabs.addEventListener( Event.CHANGE, tabs_changeHandler );</listing>
	 *
	 * @default -1
	 *
	 * @see #selectedItem
	 */
	public var selectedIndex(get, set):Int;
	private var _selectedIndex:Int = -1;
	private function get_selectedIndex():Int { return this._selectedIndex; }
	private function set_selectedIndex(value:Int):Int
	{
		this._animateSelectionChange = false;
		if (this._selectedIndex == value)
		{
			return value;
		}
		this._selectedIndex = value;
		this.refreshSelectedItem();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
		return this._selectedIndex;
	}
	
	/**
	 * The currently selected item from the data provider. Returns
	 * <code>null</code> if no item is selected.
	 *
	 * <p>In the following example, the tab bar's selected item is changed:</p>
	 *
	 * <listing version="3.0">
	 * tabs.selectedItem = tabs.dataProvider.getItemAt(2);</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected item:</p>
	 *
	 * <listing version="3.0">
	 * function tabs_changeHandler( event:Event ):void
	 * {
	 *     var tabs:TabBar = TabBar( event.currentTarget );
	 *     var item:Object = tabs.selectedItem;
	 * 
	 * }
	 * tabs.addEventListener( Event.CHANGE, tabs_changeHandler );</listing>
	 *
	 * @default null
	 *
	 * @see #selectedIndex
	 */
	public var selectedItem(get, set):Dynamic;
	private var _selectedItem:Dynamic;
	private function get_selectedItem():Dynamic { return this._selectedItem; }
	private function set_selectedItem(value:Dynamic):Dynamic
	{
		if (this._selectedItem == value)
		{
			return value;
		}
		//we don't need to set _animateSelectionChange to false because we
		//always call the selectedIndex setter below, which sets it;
		if (this._dataProvider == null)
		{
			this.selectedIndex = -1;
			return value;
		}
		var newIndex:Int = this._dataProvider.getItemIndex(value);
		if (newIndex == -1)
		{
			this.selectedIndex = -1;
		}
		else if (this._selectedIndex != newIndex)
		{
			this.selectedIndex = newIndex;
		}
		else
		{
			//it's possible for the item to change, but not the index
			this._animateSelectionChange = false;
			this._selectedItem = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		return this._selectedItem;
	}
	
	/**
	 * @private
	 */
	public var customTabStyleName(get, set):String;
	private var _customTabStyleName:String;
	private function get_customTabStyleName():String { return this._customTabStyleName; }
	private function set_customTabStyleName(value:String):String
	{
		if (this.processStyleRestriction("customTabStyleName"))
		{
			return value;
		}
		if (this._customTabStyleName == value)
		{
			return value;
		}
		this._customTabStyleName = value;
		this.invalidate(INVALIDATION_FLAG_TAB_FACTORY);
		return this._customTabStyleName;
	}
	
	/**
	 * @private
	 */
	public var customFirstTabStyleName(get, set):String;
	private var _customFirstTabStyleName:String;
	private function get_customFirstTabStyleName():String { return this._customFirstTabStyleName; }
	private function set_customFirstTabStyleName(value:String):String
	{
		if (this.processStyleRestriction("customFirstTabStyleName"))
		{
			return value;
		}
		if (this._customFirstTabStyleName == value)
		{
			return value;
		}
		this._customFirstTabStyleName = value;
		this.invalidate(INVALIDATION_FLAG_TAB_FACTORY);
		return this._customFirstTabStyleName;
	}
	
	/**
	 * @private
	 */
	public var customLastTabStyleName(get, set):String;
	private var _customLastTabStyleName:String;
	private function get_customLastTabStyleName():String { return this._customLastTabStyleName; }
	private function set_customLastTabStyleName(value:String):String
	{
		if (this.processStyleRestriction("customLastTabStyleName"))
		{
			return value;
		}
		if (this._customLastTabStyleName == value)
		{
			return value;
		}
		this._customLastTabStyleName = value;
		this.invalidate(INVALIDATION_FLAG_TAB_FACTORY);
		return this._customLastTabStyleName;
	}
	
	/**
	 * An object that stores properties for all of the tab bar's tabs, and
	 * the properties will be passed down to every tab when the tab bar
	 * validates. For a list of available properties, refer to
	 * <a href="ToggleButton.html"><code>feathers.controls.ToggleButton</code></a>.
	 *
	 * <p>These properties are shared by every tab, so anything that cannot
	 * be shared (such as display objects, which cannot be added to multiple
	 * parents) should be passed to tabs using the <code>tabFactory</code>
	 * or in the theme.</p>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>tabFactory</code> function instead
	 * of using <code>tabProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the tab bar's tab properties are updated:</p>
	 *
	 * <listing version="3.0">
	 * tabs.tabProperties.iconPosition = RelativePosition.RIGHT;</listing>
	 *
	 * @default null
	 *
	 * @see #tabFactory
	 * @see feathers.controls.ToggleButton
	 */
	public var tabProperties(get, set):PropertyProxy;
	private var _tabProperties:PropertyProxy;
	private function get_tabProperties():PropertyProxy 
	{
		if (this._tabProperties == null)
		{
			this._tabProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._tabProperties;
	}
	private function set_tabProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._tabProperties == value)
		{
			return value;
		}
		if (this._tabProperties != null)
		{
			this._tabProperties.dispose();
		}
		this._tabProperties = value;
		if (this._tabProperties != null)
		{
			this._tabProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._tabProperties;
	}
	
	/**
	 * @inheritDoc
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.activeTabs == null || this.activeTabs.length == 0)
		{
			return this.scaledActualHeight;
		}
		var firstTab:ToggleButton = this.activeTabs[0];
		return this.scaleY * (firstTab.y + firstTab.baseline);
	}
	
	/**
	 * @private
	 */
	private var _animateSelectionChange:Bool = false;
	
	/**
	 * Drag and drop is restricted to components that have the same
	 * <code>dragFormat</code>.
	 *
	 * <p>In the following example, the drag format of two tab bars is customized:</p>
	 *
	 * <listing version="3.0">
	 * tabs1.dragFormat = "my-custom-format";
	 * tabs2.dragFormat = "my-custom-format";</listing>
	 *
	 * @default "feathers-tab-bar-item"
	 */
	public var dragFormat(get, set):String;
	private var _dragFormat:String = DEFAULT_DRAG_FORMAT;
	private function get_dragFormat():String { return this._dragFormat; }
	private function set_dragFormat(value:String):String
	{
		if (value == null)
		{
			value = DEFAULT_DRAG_FORMAT;
		}
		if (this._dragFormat == value)
		{
			return value;
		}
		return this._dragFormat = value;
	}
	
	/**
	 * @private
	 */
	private var _dragTouchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _droppedOnSelf:Bool = false;
	
	/**
	 * Indicates if this tab bar can initiate drag and drop operations by
	 * touching an item and dragging it. The <code>dragEnabled</code>
	 * property enables dragging items, but dropping items must be enabled
	 * separately with the <code>dropEnabled</code> property.
	 *
	 * <p>In the following example, a tab bar's items may be dragged:</p>
	 *
	 * <listing version="3.0">
	 * tabs.dragEnabled = true;</listing>
	 *
	 * @see #dropEnabled
	 * @see #dragFormat
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
		if (this._dragEnabled)
		{
			this.addEventListener(DragDropEvent.DRAG_COMPLETE, dragCompleteHandler);
		}
		else
		{
			this.removeEventListener(DragDropEvent.DRAG_COMPLETE, dragCompleteHandler);
		}
		return this._dragEnabled;
	}
	
	/**
	 * Indicates if this tab bar can accept items that are dragged and
	 * dropped over the tab bar's hit area.
	 *
	 * <p>In the following example, a tab bar's items may be dropped:</p>
	 *
	 * <listing version="3.0">
	 * tabs.dropEnabled = true;</listing>
	 *
	 * @see #dragEnabled
	 * @see #dragFormat
	 */
	public var dropEnabled(get, set):Bool;
	private var _dropEnabled:Bool = false;
	private function get_dropEnabled():Bool { return this._dropEnabled; }
	private function set_dropEnabled(value:Bool):Bool
	{
		if (this._dropEnabled == value)
		{
			return value;
		}
		this._dropEnabled = value;
		if (this._dropEnabled)
		{
			this.addEventListener(DragDropEvent.DRAG_ENTER, dragEnterHandler);
			this.addEventListener(DragDropEvent.DRAG_MOVE, dragMoveHandler);
			this.addEventListener(DragDropEvent.DRAG_EXIT, dragExitHandler);
			this.addEventListener(DragDropEvent.DRAG_DROP, dragDropHandler);
		}
		else
		{
			this.removeEventListener(DragDropEvent.DRAG_ENTER, dragEnterHandler);
			this.removeEventListener(DragDropEvent.DRAG_MOVE, dragMoveHandler);
			this.removeEventListener(DragDropEvent.DRAG_EXIT, dragExitHandler);
			this.removeEventListener(DragDropEvent.DRAG_DROP, dragDropHandler);
		}
		return this._dropEnabled;
	}
	
	/**
	 * @private
	 */
	private var _explicitDropIndicatorWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _explicitDropIndicatorHeight:Float = Math.NaN;
	
	/**
	 * @private
	 */
	public var dropIndicatorSkin(get, set):DisplayObject;
	private var _dropIndicatorSkin:DisplayObject;
	private function get_dropIndicatorSkin():DisplayObject { return this._dropIndicatorSkin; }
	private function set_dropIndicatorSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("dropIndicatorSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
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
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._dropIndicatorSkin != null &&
			this._dropIndicatorSkin.parent == null)
		{
			this._dropIndicatorSkin.dispose();
			this._dropIndicatorSkin = null;
		}
		
		//clearing selection now so that the data provider setter won't
		//cause a selection change that triggers events.
		this._selectedIndex = -1;
		//this flag also ensures that removing items from the ToggleGroup
		//won't result in selection events
		this._ignoreSelectionChanges = true;
		
		//the tabs may contain things that shouldn't be disposed, so clean
		//them up before super.dispose()
		var tabCount:Int = this.activeTabs.length;
		var tab:ToggleButton;
		for (i in 0...tabCount)
		{
			tab = this.activeTabs.shift();
			this.destroyTab(tab);
		}
		
		//ensures that listeners are removed to avoid memory leaks
		this.dataProvider = null;
		
		if (this._tabToItem != null)
		{
			this._tabToItem.clear();
			this._tabToItem = null;
		}
		
		if (this._tabProperties != null)
		{
			this._tabProperties.dispose();
			this._tabProperties = null;
		}
		
		super.dispose();
	}
	
	/**
	 * Changes the <code>selectedIndex</code> property, but animates the
	 * <code>selectionSkin</code> to the new position, as if the user
	 * triggered a tab.
	 *
	 * @see #selectedIndex
	 */
	public function setSelectedIndexWithAnimation(selectedIndex:Int):Void
	{
		if (this._selectedIndex == selectedIndex)
		{
			return;
		}
		this._selectedIndex = selectedIndex;
		this.refreshSelectedItem();
		//set this flag before dispatching the event because the TabBar
		//might be forced to validate in an event listener
		this._animateSelectionChange = true;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * Changes the <code>selectedItem</code> property, but animates the
	 * <code>selectionSkin</code> to the new position, as if the user
	 * triggered a tab.
	 *
	 * @see #selectedItem
	 * @see #selectedIndex
	 * @see #setSelectedIndexWithAnimation()
	 */
	public function setSelectedItemWithAnimation(selectedItem:Dynamic):Void
	{
		if (this.selectedItem == selectedItem)
		{
			return;
		}
		var selectedIndex:Int = -1;
		if (this._dataProvider != null)
		{
			selectedIndex = this._dataProvider.getItemIndex(selectedItem);
		}
		this.setSelectedIndexWithAnimation(selectedIndex);
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		if (this._tabInitializer == null) _tabInitializer = defaultTabInitializer;
		if (this._tabReleaser == null) _tabReleaser = defaultTabReleaser;
		
		this.toggleGroup = new ToggleGroup();
		this.toggleGroup.isSelectionRequired = true;
		this.toggleGroup.addEventListener(Event.CHANGE, toggleGroup_changeHandler);
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var selectionInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SELECTED);
		var tabFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_TAB_FACTORY);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		
		if (dataInvalid || tabFactoryInvalid || stateInvalid)
		{
			this.refreshTabs(tabFactoryInvalid);
		}
		
		if (dataInvalid || tabFactoryInvalid || stylesInvalid)
		{
			this.refreshTabStyles();
		}
		
		if (dataInvalid || tabFactoryInvalid || selectionInvalid)
		{
			this.commitSelection();
		}
		
		if (dataInvalid || tabFactoryInvalid || stateInvalid)
		{
			this.commitEnabled();
		}
		
		if (stylesInvalid)
		{
			this.refreshLayoutStyles();
		}
		
		this.layoutTabs();
	}
	
	/**
	 * @private
	 */
	private function commitSelection():Void
	{
		this.toggleGroup.selectedIndex = this._selectedIndex;
	}

	/**
	 * @private
	 */
	private function commitEnabled():Void
	{
		for (tab in this.activeTabs)
		{
			tab.isEnabled = tab.isEnabled && this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTabStyles():Void
	{
		if (this._tabProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._tabProperties)
			{
				propertyValue = this._tabProperties[propertyName];
				for (tab in this.activeTabs)
				{
					Reflect.setProperty(tab, propertyName, propertyValue);
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshLayoutStyles():Void
	{
		if (this._direction == Direction.VERTICAL)
		{
			if (this.horizontalLayout != null)
			{
				this.horizontalLayout = null;
			}
			if (this.verticalLayout == null)
			{
				this.verticalLayout = new VerticalLayout();
				this.verticalLayout.useVirtualLayout = false;
			}
			this.verticalLayout.distributeHeights = this._distributeTabSizes;
			this.verticalLayout.horizontalAlign = this._horizontalAlign;
			this.verticalLayout.verticalAlign = (this._verticalAlign == VerticalAlign.JUSTIFY) ? VerticalAlign.TOP : this._verticalAlign;
			this.verticalLayout.gap = this._gap;
			this.verticalLayout.firstGap = this._firstGap;
			this.verticalLayout.lastGap = this._lastGap;
			this.verticalLayout.paddingTop = this._paddingTop;
			this.verticalLayout.paddingRight = this._paddingRight;
			this.verticalLayout.paddingBottom = this._paddingBottom;
			this.verticalLayout.paddingLeft = this._paddingLeft;
		}
		else //horizontal
		{
			if (this.verticalLayout != null)
			{
				this.verticalLayout = null;
			}
			if (this.horizontalLayout == null)
			{
				this.horizontalLayout = new HorizontalLayout();
				this.horizontalLayout.useVirtualLayout = false;
			}
			this.horizontalLayout.distributeWidths = this._distributeTabSizes;
			this.horizontalLayout.horizontalAlign = (this._horizontalAlign == HorizontalAlign.JUSTIFY) ? HorizontalAlign.LEFT : this._horizontalAlign;
			this.horizontalLayout.verticalAlign = this._verticalAlign;
			this.horizontalLayout.gap = this._gap;
			this.horizontalLayout.firstGap = this._firstGap;
			this.horizontalLayout.lastGap = this._lastGap;
			this.horizontalLayout.paddingTop = this._paddingTop;
			this.horizontalLayout.paddingRight = this._paddingRight;
			this.horizontalLayout.paddingBottom = this._paddingBottom;
			this.horizontalLayout.paddingLeft = this._paddingLeft;
		}
	}
	
	/**
	 * @private
	 */
	private function commitTabData(tab:ToggleButton, item:Dynamic):Void
	{
		if (item != null)
		{
			if (this._labelFunction != null)
			{
				tab.label = this._labelFunction(item);
			}
			else if (this._labelField != null && item != null && Property.existsRead(item, this._labelField))
			{
				tab.label = Reflect.getProperty(item, this._labelField);
			}
			else if (Std.isOfType(item, String))
			{
				tab.label = cast item;
			}
			else
			{
				tab.label = item.toString();
			}
			if (this._iconFunction != null)
			{
				tab.defaultIcon = this._iconFunction(item);
			}
			else if (this._iconField != null && item != null && Property.existsRead(item, this._iconField))
			{
				tab.defaultIcon = cast Reflect.getProperty(item, this._iconField);
			}
			if (this._enabledFunction != null)
			{
				//we account for this._isEnabled later
				tab.isEnabled = this._enabledFunction(item);
			}
			else if (this._enabledField != null && item != null && Property.existsRead(item, this._enabledField))
			{
				//we account for this._isEnabled later
				tab.isEnabled = Reflect.getProperty(item, this._enabledField);
			}
			else
			{
				tab.isEnabled = this._isEnabled;
			}
			if (this._tabInitializer != null)
			{
				this._tabInitializer(tab, item);
			}
		}
		else
		{
			tab.label = "";
			tab.isEnabled = this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function defaultTabInitializer(tab:ToggleButton, item:Dynamic):Void
	{
		if (item != null)
		{
			for (field in DEFAULT_TAB_FIELDS)
			{
				if (Property.existsRead(item, field))
				{
					Reflect.setProperty(tab, field, Reflect.getProperty(item, field));
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function defaultTabReleaser(tab:ToggleButton, oldItem:Dynamic):Void
	{
		for (field in DEFAULT_TAB_FIELDS)
		{
			if (Property.existsRead(oldItem, field))
			{
				Reflect.setProperty(tab, field, null);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTabs(isFactoryInvalid:Bool):Void
	{
		var oldIgnoreSelectionChanges:Bool = this._ignoreSelectionChanges;
		this._ignoreSelectionChanges = true;
		var oldSelectedIndex:Int = this.toggleGroup.selectedIndex;
		this.toggleGroup.removeAllItems();
		var temp:Array<ToggleButton> = this.inactiveTabs;
		this.inactiveTabs = this.activeTabs;
		this.activeTabs = temp;
		this.activeTabs.resize(0);
		this._layoutItems.resize(0);
		temp = null;
		if (isFactoryInvalid)
		{
			this.clearInactiveTabs();
		}
		else
		{
			if (this.activeFirstTab != null)
			{
				this.inactiveTabs.shift();
			}
			this.inactiveFirstTab = this.activeFirstTab;
			
			if (this.activeLastTab != null)
			{
				this.inactiveTabs.pop();
			}
			this.inactiveLastTab = this.activeLastTab;
		}
		this.activeFirstTab = null;
		this.activeLastTab = null;
		
		var pushIndex:Int = 0;
		var itemCount:Int = this._dataProvider != null ? this._dataProvider.length : 0;
		var lastItemIndex:Int = itemCount - 1;
		var item:Dynamic;
		var tab:ToggleButton;
		for (i in 0...itemCount)
		{
			item = this._dataProvider.getItemAt(i);
			if (i == 0)
			{
				tab = this.activeFirstTab = this.createFirstTab(item);
			}
			else if (i == lastItemIndex)
			{
				tab = this.activeLastTab = this.createLastTab(item);
			}
			else
			{
				tab = this.createTab(item);
			}
			this.toggleGroup.addItem(tab);
			this.activeTabs[pushIndex] = tab;
			this._layoutItems[pushIndex] = tab;
			pushIndex++;
		}
		
		this.clearInactiveTabs();
		this._ignoreSelectionChanges = oldIgnoreSelectionChanges;
		if (oldSelectedIndex != -1)
		{
			var newSelectedIndex:Int = this.activeTabs.length - 1;
			if (oldSelectedIndex < newSelectedIndex)
			{
				newSelectedIndex = oldSelectedIndex;
			}
			//removing all items from the ToggleGroup clears the selection,
			//so we need to set it back to the old value (or a new clamped
			//value). we want the change event to dispatch only if the old
			//value and the new value don't match.
			this._ignoreSelectionChanges = oldSelectedIndex == newSelectedIndex;
			this.toggleGroup.selectedIndex = newSelectedIndex;
			this._ignoreSelectionChanges = oldIgnoreSelectionChanges;
		}
	}
	
	/**
	 * @private
	 */
	private function clearInactiveTabs():Void
	{
		var itemCount:Int = this.inactiveTabs.length;
		var tab:ToggleButton;
		for (i in 0...itemCount)
		{
			tab = this.inactiveTabs.shift();
			this.destroyTab(tab);
		}
		
		if (this.inactiveFirstTab != null)
		{
			this.destroyTab(this.inactiveFirstTab);
			this.inactiveFirstTab = null;
		}
		
		if (this.inactiveLastTab != null)
		{
			this.destroyTab(this.inactiveLastTab);
			this.inactiveLastTab = null;
		}
	}
	
	/**
	 * @private
	 */
	private function createFirstTab(item:Dynamic):ToggleButton
	{
		var isNewInstance:Bool = false;
		var tab:ToggleButton;
		if (this.inactiveFirstTab != null)
		{
			tab = this.inactiveFirstTab;
			this.releaseTab(tab);
			this.inactiveFirstTab = null;
		}
		else
		{
			isNewInstance = true;
			var factory:Void->ToggleButton = this._firstTabFactory != null ? this._firstTabFactory : this._tabFactory;
			tab = factory();
			if (this._customFirstTabStyleName != null)
			{
				tab.styleNameList.add(this._customFirstTabStyleName);
			}
			else if (this._customTabStyleName != null)
			{
				tab.styleNameList.add(this._customTabStyleName);
			}
			else
			{
				tab.styleNameList.add(this.firstTabStyleName);
			}
			tab.isToggle = true;
			this.addChild(tab);
		}
		this.commitTabData(tab, item);
		this._tabToItem[tab] = item;
		if (isNewInstance)
		{
			//we need to listen for events after the initializer
			//is called to avoid runtime errors because the tab may be
			//disposed by the time listeners in the initializer are called.
			this.addTabListeners(tab);
		}
		return tab;
	}
	
	/**
	 * @private
	 */
	private function createLastTab(item:Dynamic):ToggleButton
	{
		var isNewInstance:Bool = false;
		var tab:ToggleButton;
		if (this.inactiveLastTab != null)
		{
			tab = this.inactiveLastTab;
			this.releaseTab(tab);
			this.inactiveLastTab = null;
		}
		else
		{
			isNewInstance = true;
			var factory:Void->ToggleButton = this._lastTabFactory != null ? this._lastTabFactory : this._tabFactory;
			tab = factory();
			if (this._customLastTabStyleName != null)
			{
				tab.styleNameList.add(this._customLastTabStyleName);
			}
			else if (this._customTabStyleName != null)
			{
				tab.styleNameList.add(this._customTabStyleName);
			}
			else
			{
				tab.styleNameList.add(this.lastTabStyleName);
			}
			tab.isToggle = true;
			this.addChild(tab);
		}
		this.commitTabData(tab, item);
		this._tabToItem[tab] = item;
		if (isNewInstance)
		{
			//we need to listen for events after the initializer
			//is called to avoid runtime errors because the tab may be
			//disposed by the time listeners in the initializer are called.
			this.addTabListeners(tab);
		}
		return tab;
	}
	
	/**
	 * @private
	 */
	private function createTab(item:Dynamic):ToggleButton
	{
		var isNewInstance:Bool = false;
		var tab:ToggleButton;
		if (this.inactiveTabs.length == 0)
		{
			isNewInstance = true;
			tab = this._tabFactory();
			if (this._customTabStyleName != null)
			{
				tab.styleNameList.add(this._customTabStyleName);
			}
			else
			{
				tab.styleNameList.add(this.tabStyleName);
			}
			tab.isToggle = true;
			this.addChild(tab);
		}
		else
		{
			tab = this.inactiveTabs.shift();
			this.releaseTab(tab);
		}
		this.commitTabData(tab, item);
		this._tabToItem[tab] = item;
		if (isNewInstance)
		{
			//we need to listen for events after the initializer
			//is called to avoid runtime errors because the tab may be
			//disposed by the time listeners in the initializer are called.
			this.addTabListeners(tab);
		}
		return tab;
	}
	
	private function addTabListeners(tab:ToggleButton):Void
	{
		tab.addEventListener(Event.TRIGGERED, tab_triggeredHandler);
		tab.addEventListener(TouchEvent.TOUCH, tab_drag_touchHandler);
	}
	
	/**
	 * @private
	 */
	private function releaseTab(tab:ToggleButton):Void
	{
		var item:Dynamic = this._tabToItem[tab];
		this._tabToItem.remove(tab);
		if (this._labelFunction != null || Property.existsRead(item, this._labelField))
		{
			tab.label = null;
		}
		if (this._iconFunction != null || Property.existsRead(item, this._iconField ))
		{
			tab.defaultIcon = null;
		}
		if (this._tabReleaser != null)
		{
			//if (ArgumentsCount.count_args(this._tabReleaser) == 1)
			//{
				//this._tabReleaser(tab);
			//}
			//else
			//{
				this._tabReleaser(tab, item);
			//}
		}
	}
	
	/**
	 * @private
	 */
	private function destroyTab(tab:ToggleButton):Void
	{
		this.toggleGroup.removeItem(tab);
		this.releaseTab(tab);
		tab.removeEventListener(Event.TRIGGERED, tab_triggeredHandler);
		tab.removeEventListener(TouchEvent.TOUCH, tab_drag_touchHandler);
		this.removeChild(tab, true);
	}
	
	/**
	 * @private
	 */
	private function layoutTabs():Void
	{
		this._viewPortBounds.x = 0;
		this._viewPortBounds.y = 0;
		this._viewPortBounds.scrollX = 0;
		this._viewPortBounds.scrollY = 0;
		this._viewPortBounds.explicitWidth = this._explicitWidth;
		this._viewPortBounds.explicitHeight = this._explicitHeight;
		this._viewPortBounds.minWidth = this._explicitMinWidth;
		this._viewPortBounds.minHeight = this._explicitMinHeight;
		this._viewPortBounds.maxWidth = this._explicitMaxWidth;
		this._viewPortBounds.maxHeight = this._explicitMaxHeight;
		if (this.verticalLayout != null)
		{
			this.verticalLayout.layout(this._layoutItems, this._viewPortBounds, this._layoutResult);
		}
		else if (this.horizontalLayout != null)
		{
			this.horizontalLayout.layout(this._layoutItems, this._viewPortBounds, this._layoutResult);
		}
		
		var contentWidth:Float = this._layoutResult.contentWidth;
		var contentHeight:Float = this._layoutResult.contentHeight;
		//minimum dimensions are the same as the measured dimensions
		this.saveMeasurements(contentWidth, contentHeight, contentWidth, contentHeight);
		
		//final validation to avoid juggler next frame issues
		for (tb in this.activeTabs)
		{
			tb.validate();
		}
		var tab:ToggleButton;
		if (this._selectionSkin != null)
		{
			//always on top
			this.setChildIndex(this._selectionSkin, this.numChildren - 1);
			
			if (this._selectionChangeTween != null)
			{
				this._selectionChangeTween.advanceTime(this._selectionChangeTween.totalTime);
			}
			if (this._selectedIndex >= 0)
			{
				this._selectionSkin.visible = true;
				tab = this.activeTabs[this._selectedIndex];
				if (this._animateSelectionChange)
				{
					this._selectionChangeTween = new Tween(this._selectionSkin, this._selectionChangeDuration, this._selectionChangeEase);
					if (this._direction == Direction.VERTICAL)
					{
						this._selectionChangeTween.animate("y", tab.y);
						this._selectionChangeTween.animate("height", tab.height);
					}
					else //horizontal
					{
						this._selectionChangeTween.animate("x", tab.x);
						this._selectionChangeTween.animate("width", tab.width);
					}
					this._selectionChangeTween.onComplete = selectionChangeTween_onComplete;
					Starling.currentJuggler.add(this._selectionChangeTween);
				}
				else
				{
					if (this._direction == Direction.VERTICAL)
					{
						this._selectionSkin.y = tab.y;
						this._selectionSkin.height = tab.height;
					}
					else //horizontal
					{
						this._selectionSkin.x = tab.x;
						this._selectionSkin.width = tab.width;
					}
				}
			}
			else
			{
				this._selectionSkin.visible = false;
			}
			this._animateSelectionChange = false;
			if (Std.isOfType(this._selectionSkin, IValidating))
			{
				cast(this._selectionSkin, IValidating).validate();
			}
		}
	}
	
	/**
	 * @private
	 */
	override public function showFocus():Void
	{
		if (!this._hasFocus)
		{
			return;
		}
		
		this._showFocus = true;
		this.showFocusedTab();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_FOCUS);
	}

	/**
	 * @private
	 */
	override public function hideFocus():Void
	{
		if (!this._hasFocus)
		{
			return;
		}
		this._showFocus = false;
		this.hideFocusedTab();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_FOCUS);
	}
	
	/**
	 * @private
	 */
	private function hideFocusedTab():Void
	{
		if (this._focusedTabIndex < 0)
		{
			return;
		}
		var focusedTab:ToggleButton = this.activeTabs[this._focusedTabIndex];
		focusedTab.hideFocus();
	}

	/**
	 * @private
	 */
	private function showFocusedTab():Void
	{
		if (!this._showFocus || this._focusedTabIndex < 0)
		{
			return;
		}
		var tab:ToggleButton = this.activeTabs[this._focusedTabIndex];
		tab.showFocus();
	}
	
	/**
	 * @private
	 */
	private function focusedTabFocusIn():Void
	{
		if (this._focusedTabIndex < 0)
		{
			return;
		}
		var tab:ToggleButton = this.activeTabs[this._focusedTabIndex];
		tab.dispatchEventWith(FeathersEventType.FOCUS_IN);
	}

	/**
	 * @private
	 */
	private function focusedTabFocusOut():Void
	{
		if (this._focusedTabIndex < 0)
		{
			return;
		}
		var tab:ToggleButton = this.activeTabs[this._focusedTabIndex];
		tab.dispatchEventWith(FeathersEventType.FOCUS_OUT);
	}
	
	/**
	 * @private
	 */
	private function refreshSelectedItem():Void
	{
		if (this._selectedIndex == -1)
		{
			this._selectedItem = null;
		}
		else
		{
			this._selectedItem = this._dataProvider.getItemAt(this._selectedIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function getDropIndex(event:DragDropEvent):Int
	{
		var point:Point = Pool.getPoint(event.localX, event.localY);
		this.localToGlobal(point, point);
		var globalX:Float = point.x;
		var globalY:Float = point.y;
		Pool.putPoint(point);
		
		var tabCount:Int = this.activeTabs.length;
		var tab:ToggleButton;
		var tabGlobalMiddleX:Float;
		var tabGlobalMiddleY:Float;
		for (i in 0...tabCount)
		{
			tab = this.activeTabs[i];
			if (this._direction == Direction.HORIZONTAL)
			{
				point = Pool.getPoint(tab.width / 2, 0);
			}
			else
			{
				point = Pool.getPoint(0, tab.height / 2);
			}
			tab.localToGlobal(point, point);
			tabGlobalMiddleX = point.x;
			tabGlobalMiddleY = point.y;
			Pool.putPoint(point);
			if (this._direction == Direction.VERTICAL)
			{
				if (globalY < tabGlobalMiddleY)
				{
					return i;
				}
			}
			else //horizontal
			{
				if (globalX < tabGlobalMiddleX)
				{
					return i;
				}
			}
		}
		return tabCount;
	}
	
	/**
	 * @private
	 */
	private function refreshDropIndicator(event:DragDropEvent):Void
	{
		if (this._dropIndicatorSkin == null)
		{
			return;
		}
		var dropIndex:Int = this.getDropIndex(event);
		var tab:ToggleButton;
		if (this._direction == Direction.VERTICAL)
		{
			var dropIndicatorY:Float = 0;
			if (dropIndex == this.activeTabs.length)
			{
				dropIndicatorY = this.actualHeight - this._dropIndicatorSkin.height;
			}
			else if (dropIndex == 0)
			{
				dropIndicatorY = 0;
			}
			else
			{
				tab = this.activeTabs[dropIndex];
				dropIndicatorY = tab.y - (this._gap + this._dropIndicatorSkin.height) / 2;
			}
			this._dropIndicatorSkin.x = 0;
			this._dropIndicatorSkin.y = dropIndicatorY;
			this._dropIndicatorSkin.width = this.actualWidth;
			//just in case the direction changed, reset this value
			this._dropIndicatorSkin.height = this._explicitDropIndicatorHeight;
		}
		else //horizontal
		{
			var dropIndicatorX:Float = 0;
			if (dropIndex == this.activeTabs.length)
			{
				dropIndicatorX = this.actualWidth - this._dropIndicatorSkin.width;
			}
			else if (dropIndex == 0)
			{
				dropIndicatorX = 0;
			}
			else
			{
				tab = this.activeTabs[dropIndex];
				dropIndicatorX = tab.x - (this._gap + this._dropIndicatorSkin.width) / 2;
			}
			this._dropIndicatorSkin.x = dropIndicatorX;
			this._dropIndicatorSkin.y = 0;
			//just in case the direction changed, reset this value
			this._dropIndicatorSkin.width = this._explicitDropIndicatorWidth;
			this._dropIndicatorSkin.height = this.actualHeight;
		}
		this.addChild(this._dropIndicatorSkin);
	}
	
	/**
	 * @private
	 */
	private function childProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function selectionChangeTween_onComplete():Void
	{
		this._selectionChangeTween = null;
	}
	
	/**
	 * @private
	 */
	override function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		this._focusedTabIndex = this._selectedIndex;
		this.focusedTabFocusIn();
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
	}

	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		super.focusOutHandler(event);
		this.hideFocusedTab();
		this.focusedTabFocusOut();
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	private var _focusedTabIndex:Int = -1;

	/**
	 * @private
	 */
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (!this._isEnabled)
		{
			return;
		}
		if (this._dataProvider == null || this._dataProvider.length == 0)
		{
			return;
		}
		var newFocusedTabIndex:Int = this._focusedTabIndex;
		var maxFocusedTabIndex:Int = this._dataProvider.length - 1;
		if (event.keyCode == Keyboard.HOME)
		{
			this.selectedIndex = newFocusedTabIndex = 0;
		}
		else if (event.keyCode == Keyboard.END)
		{
			this.selectedIndex = newFocusedTabIndex = maxFocusedTabIndex;
		}
		else if (event.keyCode == Keyboard.PAGE_UP)
		{
			newFocusedTabIndex--;
			if (newFocusedTabIndex < 0)
			{
				newFocusedTabIndex = maxFocusedTabIndex;
			}
			this.selectedIndex = newFocusedTabIndex;
		}
		else if (event.keyCode == Keyboard.PAGE_DOWN)
		{
			newFocusedTabIndex++;
			if (newFocusedTabIndex > maxFocusedTabIndex)
			{
				newFocusedTabIndex = 0;
			}
			this.selectedIndex = newFocusedTabIndex;
		}
		else if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.LEFT)
		{
			newFocusedTabIndex--;
			if (newFocusedTabIndex < 0)
			{
				newFocusedTabIndex = maxFocusedTabIndex;
			}
		}
		else if (event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.RIGHT)
		{
			newFocusedTabIndex++;
			if (newFocusedTabIndex > maxFocusedTabIndex)
			{
				newFocusedTabIndex = 0;
			}
		}
		
		if (newFocusedTabIndex >= 0 && newFocusedTabIndex != this._focusedTabIndex)
		{
			this.hideFocusedTab();
			this.focusedTabFocusOut();
			this._focusedTabIndex = newFocusedTabIndex;
			this.focusedTabFocusIn();
			this.showFocusedTab();
		}
	}
	
	/**
	 * @private
	 */
	private function tab_triggeredHandler(event:Event):Void
	{
		//if this was called after dispose, ignore it
		if (this._dataProvider == null || this.activeTabs == null)
		{
			return;
		}
		var tab:ToggleButton = cast event.currentTarget;
		var index:Int = this.activeTabs.indexOf(tab);
		var item:Dynamic = this._dataProvider.getItemAt(index);
		this.dispatchEventWith(Event.TRIGGERED, false, item);
	}
	
	/**
	 * @private
	 */
	private function dragEnterHandler(event:DragDropEvent):Void
	{
		if (!this._dropEnabled)
		{
			return;
		}
		if (!event.dragData.hasDataForFormat(this._dragFormat))
		{
			return;
		}
		DragDropManager.acceptDrag(this);
		this.refreshDropIndicator(event);
	}
	
	/**
	 * @private
	 */
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
		this.refreshDropIndicator(event);
	}
	
	/**
	 * @private
	 */
	private function dragExitHandler(event:DragDropEvent):Void
	{
		if (this._dropIndicatorSkin != null)
		{
			this._dropIndicatorSkin.removeFromParent(false);
		}
	}
	
	/**
	 * @private
	 */
	private function dragDropHandler(event:DragDropEvent):Void
	{
		if (this._dropIndicatorSkin != null)
		{
			this._dropIndicatorSkin.removeFromParent(false);
		}
		var index:Int = this.getDropIndex(event);
		var item:Dynamic = event.dragData.getDataForFormat(this._dragFormat);
		var selectItem:Bool = this._selectedItem == item;
		if (event.dragSource == this)
		{
			//if we wait to remove this item in the dragComplete handler,
			//the wrong index might be removed.
			var oldIndex:Int = this._dataProvider.getItemIndex(item);
			this._dataProvider.removeItemAt(oldIndex);
			this._droppedOnSelf = true;
			if (index > oldIndex)
			{
				index--;
			}
		}
		this._dataProvider.addItemAt(item, index);
		if (selectItem)
		{
			this.selectedIndex = index;
		}
	}
	
	/**
	 * @private
	 */
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
	
	/**
	 * @private
	 */
	private function tab_drag_touchHandler(event:TouchEvent):Void
	{
		if (!this._dragEnabled)
		{
			this._dragTouchPointID = -1;
			return;
		}
		if (DragDropManager.isDragging)
		{
			this._dragTouchPointID = -1;
			return;
		}
		var tab:ToggleButton = cast event.currentTarget;
		var touch:Touch;
		if (this._dragTouchPointID != -1)
		{
			var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(tab.stage);
			if (exclusiveTouch.getClaim(this._dragTouchPointID) != null)
			{
				this._dragTouchPointID = -1;
				return;
			}
			var touch:Touch = event.getTouch(tab, null, this._dragTouchPointID);
			if (touch.phase == TouchPhase.MOVED)
			{
				var index:Int = this.activeTabs.indexOf(tab);
				var item:Dynamic = this._dataProvider.getItemAt(index);
				var dragData:DragData = new DragData();
				dragData.setDataForFormat(this._dragFormat, item);
				var avatar:ToggleButton = this.createTab(item);
				avatar.width = tab.width;
				avatar.height = tab.height;
				avatar.alpha = 0.8;
				var point:Point = Pool.getPoint();
				touch.getLocation(tab, point);
				this._droppedOnSelf = false;
				DragDropManager.startDrag(this, touch, dragData, avatar, -point.x, -point.y);
				Pool.putPoint(point);
				exclusiveTouch.claimTouch(this._dragTouchPointID, tab);
				this._dragTouchPointID = -1;
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				this._dragTouchPointID = -1;
			}
		}
		else
		{
			//we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(tab, TouchPhase.BEGAN);
			if (touch == null)
			{
				//we only care about the began phase. ignore all other
				//phases when we don't have a saved touch ID.
				return;
			}
			this._dragTouchPointID = touch.id;
		}
	}
	
	/**
	 * @private
	 */
	private function toggleGroup_changeHandler(event:Event):Void
	{
		if (this._ignoreSelectionChanges)
		{
			return;
		}
		//it should only get here if the change happened by the user
		//triggering a tab.
		this.setSelectedIndexWithAnimation(this.toggleGroup.selectedIndex);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_addItemHandler(event:Event, index:Int):Void
	{
		if (this._selectedIndex >= index)
		{
			//we're keeping the same selected item, but the selected index
			//will change, so we need to manually dispatch the change event
			this.selectedIndex += 1;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeAllHandler(event:Event):Void
	{
		this.selectedIndex = -1;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_removeItemHandler(event:Event, index:Int):Void
	{
		if (this._selectedIndex > index)
		{
			//the same item is selected, but its index has changed.
			this.selectedIndex -= 1;
		}
		else if (this._selectedIndex == index)
		{
			var oldIndex:Int = this._selectedIndex;
			var newIndex:Int = oldIndex;
			var maxIndex:Int = this._dataProvider.length - 1;
			if (newIndex > maxIndex)
			{
				newIndex = maxIndex;
			}
			if (oldIndex == newIndex)
			{
				//we're keeping the same selected index, but the selected
				//item will change, so we need to manually dispatch the
				//change event
				this.refreshSelectedItem();
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
				this.dispatchEventWith(Event.CHANGE);
			}
			else
			{
				//we're selecting both a different index and a different
				//item, so we'll just call the selectedIndex setter
				this.selectedIndex = newIndex;
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_resetHandler(event:Event):Void
	{
		if (this._dataProvider.length != 0)
		{
			//the data provider has changed drastically. we should reset the
			//selection to the first item.
			if (this._selectedIndex != 0)
			{
				this.selectedIndex = 0;
			}
			else
			{
				//we're keeping the same selected index, but the selected
				//item will change, so we need to manually dispatch the
				//change event
				this.refreshSelectedItem();
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
				this.dispatchEventWith(Event.CHANGE);
			}
		}
		else if (this._selectedIndex != -1)
		{
			this.selectedIndex = -1;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_replaceItemHandler(event:Event, index:Int):Void
	{
		if (this._selectedIndex == index)
		{
			//we're keeping the same selected index, but the selected
			//item will change, so we need to manually dispatch the
			//change event
			this.refreshSelectedItem();
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function refreshSelectedIndicesAfterFilterOrSort():Void
	{
		var oldIndex:Int = this._dataProvider.getItemIndex(this._selectedItem);
		if (oldIndex == -1)
		{
			//the selected item was filtered
			var newIndex:Int = this._selectedIndex;
			var maxIndex:Int = this._dataProvider.length - 1;
			if (newIndex > maxIndex)
			{
				//try to keep the same selectedIndex, but use the largest
				//index if the same one can't be used
				newIndex = maxIndex;
			}
			if (newIndex != -1)
			{
				this.selectedItem = this._dataProvider.getItemAt(newIndex);
			}
			else
			{
				this.selectedIndex = -1;
			}
		}
		else if (oldIndex != this._selectedIndex)
		{
			//the selectedItem is the same, but its index has changed
			this.selectedIndex = oldIndex;
		}
	}
	
	private function dataProvider_sortChangeHandler(event:Event):Void
	{
		this.refreshSelectedIndicesAfterFilterOrSort();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}

	/**
	 * @private
	 */
	private function dataProvider_filterChangeHandler(event:Event):Void
	{
		this.refreshSelectedIndicesAfterFilterOrSort();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_updateItemHandler(event:Event, index:Int):Void
	{
		//no need to dispatch a change event. the index and the item are the
		//same. the item's properties have changed, but that doesn't require
		//a change event.
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}

	/**
	 * @private
	 */
	private function dataProvider_updateAllHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
}