/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.ITextBaselineControl;
import feathers.core.PropertyProxy;
import feathers.core.PropertyProxyReal;
import feathers.data.IListCollection;
import feathers.events.CollectionEventType;
import feathers.events.FeathersEventType;
import feathers.layout.Direction;
import feathers.layout.FlowLayout;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.ViewPortBounds;
import feathers.skins.IStyleProvider;
import feathers.utils.type.ArgumentsCount;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * A set of related buttons with layout, customized using a data provider.
 *
 * <p>The following example creates a button group with a few buttons:</p>
 *
 * <listing version="3.0">
 * var group:ButtonGroup = new ButtonGroup();
 * group.dataProvider = new ArrayCollection(
 * [
 *     { label: "Yes", triggered: yesButton_triggeredHandler },
 *     { label: "No", triggered: noButton_triggeredHandler },
 *     { label: "Cancel", triggered: cancelButton_triggeredHandler },
 * ]);
 * this.addChild( group );</listing>
 *
 * @see ../../../help/button-group.html How to use the Feathers ButtonGroup component
 * @see feathers.controls.TabBar
 *
 * @productversion Feathers 1.0.0
 */
class ButtonGroup extends FeathersControl implements ITextBaselineControl
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>ButtonGroup</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_BUTTON_FACTORY:String = "buttonFactory";

	/**
	 * @private
	 */
	private static inline var LABEL_FIELD:String = "label";

	/**
	 * @private
	 */
	private static inline var ENABLED_FIELD:String = "isEnabled";
	
	/**
	 * @private
	 */
	private static  var DEFAULT_BUTTON_FIELDS:Array<String> = 
		[
			"defaultIcon",
			"upIcon",
			"downIcon",
			"hoverIcon",
			"disabledIcon",
			"defaultSelectedIcon",
			"selectedUpIcon",
			"selectedDownIcon",
			"selectedHoverIcon",
			"selectedDisabledIcon",
			"isSelected",
			"isToggle",
			"isLongPressEnabled",
			"name",
		];
	
	/**
	 * The default value added to the <code>styleNameList</code> of the buttons.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_BUTTON:String = "feathers-button-group-button";
	
	/**
	 * @private
	 */
	private static function defaultButtonFactory():Button
	{
		return new Button();
	}
	
	/**
	 * @private
	 */
	private static var DEFAULT_BUTTON_EVENTS:Array<String> = 
		[
			Event.TRIGGERED,
			Event.CHANGE,
			FeathersEventType.LONG_PRESS,
		];
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the buttons.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the button style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_BUTTON</code>.
	 *
	 * <p>To customize the button style name without subclassing, see
	 * <code>customButtonStyleName</code>.</p>
	 *
	 * @see #style:customButtonStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var buttonStyleName:String = DEFAULT_CHILD_STYLE_NAME_BUTTON;
	
	/**
	 * The value added to the <code>styleNameList</code> of the first button.
	 *
	 * <p>To customize the first button name without subclassing, see
	 * <code>customFirstButtonStyleName</code>.</p>
	 *
	 * @see #style:customFirstButtonStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var firstButtonStyleName:String = DEFAULT_CHILD_STYLE_NAME_BUTTON;
	
	/**
	 * The value added to the <code>styleNameList</code> of the last button.
	 *
	 * <p>To customize the last button style name without subclassing, see
	 * <code>customLastButtonStyleName</code>.</p>
	 *
	 * @see #style:customLastButtonStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var lastButtonStyleName:String = DEFAULT_CHILD_STYLE_NAME_BUTTON;
	
	/**
	 * @private
	 */
	private var activeFirstButton:Button;

	/**
	 * @private
	 */
	private var inactiveFirstButton:Button;

	/**
	 * @private
	 */
	private var activeLastButton:Button;

	/**
	 * @private
	 */
	private var inactiveLastButton:Button;
	
	/**
	 * @private
	 */
	private var _layoutItems:Array<DisplayObject> = new Array<DisplayObject>();

	/**
	 * @private
	 */
	private var activeButtons:Array<Button> = new Array<Button>();

	/**
	 * @private
	 */
	private var inactiveButtons:Array<Button> = new Array<Button>();

	/**
	 * @private
	 */
	private var _buttonToItem:Map<Button, Dynamic> = new Map();
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return ButtonGroup.globalStyleProvider;
	}
	
	/**
	 * The collection of data to be displayed with buttons.
	 *
	 * <p>The following example sets the button group's data provider:</p>
	 *
	 * <listing version="3.0">
	 * group.dataProvider = new ArrayCollection(
	 * [
	 *     { label: "Yes", triggered: yesButton_triggeredHandler },
	 *     { label: "No", triggered: noButton_triggeredHandler },
	 *     { label: "Cancel", triggered: cancelButton_triggeredHandler },
	 * ]);</listing>
	 *
	 * <p>By default, items in the data provider support the following
	 * properties from <code>Button</code></p>
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
	 *     <li>isSelected (only supported by <code>ToggleButton</code>)</li>
	 *     <li>isToggle (only supported by <code>ToggleButton</code>)</li>
	 *     <li>isEnabled</li>
	 *     <li>name</li>
	 * </ul>
	 *
	 * <p>Additionally, you can add the following event listeners:</p>
	 *
	 * <ul>
	 *     <li>Event.TRIGGERED</li>
	 *     <li>Event.CHANGE (only supported by <code>ToggleButton</code>)</li>
	 * </ul>
	 *
	 * <p>Event listeners may have one of the following signatures:</p>
	 * <pre>function(event:Event):void</pre>
	 * <pre>function(event:Event, eventData:Object):void</pre>
	 * <pre>function(event:Event, eventData:Object, dataProviderItem:Object):void</pre>
	 *
	 * <p>To use properties and events that are only supported by
	 * <code>ToggleButton</code>, you must provide a <code>buttonFactory</code>
	 * that returns a <code>ToggleButton</code> instead of a <code>Button</code>.</p>
	 *
	 * <p>You can pass a function to the <code>buttonInitializer</code>
	 * property that can provide custom logic to interpret each item in the
	 * data provider differently. For example, you could use it to support
	 * additional properties or events.</p>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 * @see #buttonInitializer
	 * @see feathers.data.ArrayCollection
	 * @see feathers.data.VectorCollection
	 * @see feathers.data.XMLListCollection
	 */
	public var dataProvider(get, set):IListCollection;
	private var _dataProvider:IListCollection;
	private function get_dataProvider():IListCollection { return this._dataProvider; }
	private function set_dataProvider(value:IListCollection):IListCollection
	{
		if (this.dataProvider == value)
		{
			return value;
		}
		if (this._dataProvider != null)
		{
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null)
		{
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ALL, dataProvider_updateAllHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._dataProvider;
	}
	
	/**
	 * @private
	 */
	private var layout:ILayout;

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
	private var _direction:String = Direction.VERTICAL;
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
	public var distributeButtonSizes(get, set):Bool;
	private var _distributeButtonSizes:Bool = true;
	private function get_distributeButtonSizes():Bool { return this._distributeButtonSizes; }
	private function set_distributeButtonSizes(value:Bool):Bool
	{
		if (this.processStyleRestriction("distributeButtonSizes"))
		{
			return value;
		}
		if (this._distributeButtonSizes == value)
		{
			return value;
		}
		this._distributeButtonSizes = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._distributeButtonSizes;
	}
	
	/**
	 * 
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
	 * Creates each button in the group. A button must be an instance of
	 * <code>Button</code>. This factory can be used to change properties on
	 * the buttons when they are first created. For instance, if you are
	 * skinning Feathers components without a theme, you might use this
	 * factory to set skins and other styles on a button.
	 *
	 * <p>Optionally, the first button and the last button may be different
	 * than the other buttons that are in the middle. Use the
	 * <code>firstButtonFactory</code> and/or the
	 * <code>lastButtonFactory</code> to customize one or both of these
	 * buttons.</p>
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():Button</pre>
	 *
	 * <p>The following example skins the buttons using a custom button
	 * factory:</p>
	 *
	 * <listing version="3.0">
	 * group.buttonFactory = function():Button
	 * {
	 *     var button:Button = new Button();
	 *     button.defaultSkin = new Image( texture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 * @see #firstButtonFactory
	 * @see #lastButtonFactory
	 */
	public var buttonFactory(get, set):Void->Button;
	private var _buttonFactory:Void->Button;
	private function get_buttonFactory():Void->Button { return this._buttonFactory; }
	private function set_buttonFactory(value:Void->Button):Void->Button
	{
		if (this._buttonFactory == value)
		{
			return value;
		}
		this._buttonFactory = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._buttonFactory;
	}
	
	/**
	 * If not <code>null</code>, creates the first button. If the
	 * <code>firstButtonFactory</code> is <code>null</code>, then the button
	 * group will use the <code>buttonFactory</code>. The first button must
	 * be an instance of <code>Button</code>. This factory can be used to
	 * change properties on the first button when it is initially created.
	 * For instance, if you are skinning Feathers components without a
	 * theme, you might use this factory to set skins and other styles on
	 * the first button.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():Button</pre>
	 *
	 * <p>The following example skins the first button using a custom
	 * factory:</p>
	 *
	 * <listing version="3.0">
	 * group.firstButtonFactory = function():Button
	 * {
	 *     var button:Button = new Button();
	 *     button.defaultSkin = new Image( texture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 * @see #buttonFactory
	 * @see #lastButtonFactory
	 */
	public var firstButtonFactory(get, set):Void->Button;
	private var _firstButtonFactory:Void->Button;
	private function get_firstButtonFactory():Void->Button { return this._firstButtonFactory; }
	private function set_firstButtonFactory(value:Void->Button):Void->Button
	{
		if (this._firstButtonFactory == value)
		{
			return value;
		}
		this._firstButtonFactory = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._firstButtonFactory;
	}
	
	/**
	 * If not <code>null</code>, creates the last button. If the
	 * <code>lastButtonFactory</code> is <code>null</code>, then the button
	 * group will use the <code>buttonFactory</code>. The last button must
	 * be an instance of <code>Button</code>. This factory can be used to
	 * change properties on the last button when it is initially created.
	 * For instance, if you are skinning Feathers components without a
	 * theme, you might use this factory to set skins and other styles on
	 * the last button.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():Button</pre>
	 *
	 * <p>The following example skins the last button using a custom
	 * factory:</p>
	 *
	 * <listing version="3.0">
	 * group.lastButtonFactory = function():Button
	 * {
	 *     var button:Button = new Button();
	 *     button.defaultSkin = new Image( texture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 * @see #buttonFactory
	 * @see #firstButtonFactory
	 */
	public var lastButtonFactory(get, set):Void->Button;
	private var _lastButtonFactory:Void->Button;
	private function get_lastButtonFactory():Void->Button { return this._lastButtonFactory; }
	private function set_lastButtonFactory(value:Void->Button):Void->Button
	{
		if (this._lastButtonFactory == value)
		{
			return value;
		}
		this._lastButtonFactory = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._lastButtonFactory;
	}
	
	/**
	 * Modifies a button, perhaps by changing its label and icons, based on the
	 * item from the data provider that the button is meant to represent. The
	 * default buttonInitializer function can set the button's label and icons if
	 * <code>label</code> and/or any of the <code>Button</code> icon fields
	 * (<code>defaultIcon</code>, <code>upIcon</code>, etc.) are present in
	 * the item. You can listen to <code>Event.TRIGGERED</code> and
	 * <code>Event.CHANGE</code> by passing in functions for each.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function( button:Button, item:Object ):void</pre>
	 *
	 * <p>The following example provides a custom button initializer:</p>
	 *
	 * <listing version="3.0">
	 * group.buttonInitializer = function( button:Button, item:Object ):void
	 * {
	 *     button.label = item.label;
	 * };</listing>
	 *
	 * @see #dataProvider
	 */
	public var buttonInitializer(get, set):Button->Dynamic->Void;
	private var _buttonInitializer:Button->Dynamic->Void;
	private function get_buttonInitializer():Button->Dynamic->Void { return this._buttonInitializer; }
	private function set_buttonInitializer(value:Button->Dynamic->Void):Button->Dynamic->Void
	{
		if (this._buttonInitializer == value)
		{
			return value;
		}
		this._buttonInitializer = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._buttonInitializer;
	}
	
	/**
	 * Resets the properties of an individual button, using the item from the
	 * data provider that was associated with the button.
	 *
	 * <p>This function is expected to have one of the following signatures:</p>
	 * <pre>function( tab:Button ):void</pre>
	 * <pre>function( tab:Button, oldItem:Object ):void</pre>
	 *
	 * <p>In the following example, a custom button releaser is passed to the
	 * button group:</p>
	 *
	 * <listing version="3.0">
	 * group.buttonReleaser = function( button:Button, oldItem:Object ):void
	 * {
	 *     button.label = null;
	 * };</listing>
	 *
	 * @see #buttonInitializer
	 */
	public var buttonReleaser(get, set):Function;
	private var _buttonReleaser:Function;
	private function get_buttonReleaser():Function { return this._buttonReleaser; }
	private function set_buttonReleaser(value:Function):Function
	{
		if (this._buttonReleaser == value)
		{
			return value;
		}
		this._buttonReleaser = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._buttonReleaser;
	}
	
	/**
	 * @private
	 */
	public var customButtonStyleName(get, set):String;
	private var _customButtonStyleName:String;
	private function get_customButtonStyleName():String { return this._customButtonStyleName; }
	private function set_customButtonStyleName(value:String):String
	{
		if (this.processStyleRestriction("customButtonStyleName"))
		{
			return value;
		}
		if (this._customButtonStyleName == value)
		{
			return value;
		}
		this._customButtonStyleName = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._customButtonStyleName;
	}
	
	/**
	 * @private
	 */
	public var customFirstButtonStyleName(get, set):String;
	private var _customFirstButtonStyleName:String;
	private function get_customFirstButtonStyleName():String { return this._customFirstButtonStyleName; }
	private function set_customFirstButtonStyleName(value:String):String
	{
		if (this.processStyleRestriction("customFirstButtonStyleName"))
		{
			return value;
		}
		if (this._customFirstButtonStyleName == value)
		{
			return value;
		}
		this._customFirstButtonStyleName = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._customFirstButtonStyleName;
	}
	
	/**
	 * @private
	 */
	public var customLastButtonStyleName(get, set):String;
	private var _customLastButtonStyleName:String;
	private function get_customLastButtonStyleName():String { return this._customLastButtonStyleName; }
	private function set_customLastButtonStyleName(value:String):String
	{
		if (this.processStyleRestriction("customLastButtonStyleName"))
		{
			return value;
		}
		if (this._customLastButtonStyleName == value)
		{
			return value;
		}
		this._customLastButtonStyleName = value;
		this.invalidate(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._customLastButtonStyleName;
	}
	
	/**
	 * An object that stores properties for all of the button group's
	 * buttons, and the properties will be passed down to every button when
	 * the button group validates. For a list of available properties,
	 * refer to <a href="Button.html"><code>feathers.controls.Button</code></a>.
	 *
	 * <p>These properties are shared by every button, so anything that cannot
	 * be shared (such as display objects, which cannot be added to multiple
	 * parents) should be passed to buttons using the
	 * <code>buttonFactory</code> or in the theme.</p>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>The following example sets some properties on all of the buttons:</p>
	 *
	 * <listing version="3.0">
	 * group.buttonProperties.horizontalAlign = HorizontalAlign.LEFT;
	 * group.buttonProperties.verticalAlign = VerticalAlign.TOP;</listing>
	 *
	 * <p>Setting properties in a <code>buttonFactory</code> function instead
	 * of using <code>buttonProperties</code> will result in better
	 * performance.</p>
	 *
	 * @default null
	 *
	 * @see #buttonFactory
	 * @see #firstButtonFactory
	 * @see #lastButtonFactory
	 * @see feathers.controls.Button
	 */
	public var buttonProperties(get, set):Dynamic;
	private var _buttonProperties:PropertyProxy;
	private function get_buttonProperties():Dynamic
	{
		if (this._buttonProperties == null)
		{
			this._buttonProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._buttonProperties;
	}
	
	private function set_buttonProperties(value:Dynamic):Dynamic
	{
		if (this._buttonProperties == value)
		{
			return value;
		}
		if (value == null)
		{
			value = new PropertyProxy();
		}
		if (!Std.isOfType(value, PropertyProxyReal))
		{
			value = PropertyProxy.fromObject(value);
		}
		if (this._buttonProperties != null)
		{
			this._buttonProperties.removeOnChangeCallback(childProperties_onChange);
			this._buttonProperties.dispose();
		}
		this._buttonProperties = cast value;
		if (this._buttonProperties != null)
		{
			this._buttonProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._buttonProperties;
	}
	
	/**
	 * @inheritDoc
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.activeButtons == null || this.activeButtons.length == 0)
		{
			return this.scaledActualHeight;
		}
		var firstButton:Button = this.activeButtons[0];
		return this.scaleY * (firstButton.y + firstButton.baseline);
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._buttonToItem != null)
		{
			this._buttonToItem.clear();
			this._buttonToItem = null;
		}
		if (this._buttonProperties != null)
		{
			this._buttonProperties.dispose();
			this._buttonProperties = null;
		}
		this.dataProvider = null;
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var buttonFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		
		if (dataInvalid || stateInvalid || buttonFactoryInvalid)
		{
			this.refreshButtons(buttonFactoryInvalid);
		}
		
		if (dataInvalid || buttonFactoryInvalid || stylesInvalid)
		{
			this.refreshButtonStyles();
		}
		
		if (dataInvalid || stateInvalid || buttonFactoryInvalid)
		{
			this.commitEnabled();
		}
		
		if (stylesInvalid)
		{
			this.refreshLayoutStyles();
		}
		
		this.layoutButtons();
	}
	
	/**
	 * @private
	 */
	private function commitEnabled():Void
	{
		for (button in this.activeButtons)
		{
			button.isEnabled = button.isEnabled && this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshButtonStyles():Void
	{
		if (this._buttonProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._buttonProperties)
			{
				propertyValue = this._buttonProperties[propertyName];
				for (button in this.activeButtons)
				{
					//button[propertyName] = propertyValue;
					Reflect.setProperty(button, propertyName, propertyValue);
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
			var verticalLayout:VerticalLayout = SafeCast.safe_cast(this.layout, VerticalLayout);
			if (verticalLayout == null)
			{
				this.layout = verticalLayout = new VerticalLayout();
			}
			verticalLayout.distributeHeights = this._distributeButtonSizes;
			verticalLayout.horizontalAlign = this._horizontalAlign;
			verticalLayout.verticalAlign = (this._verticalAlign == VerticalAlign.JUSTIFY) ? VerticalAlign.TOP : this._verticalAlign;
			verticalLayout.gap = this._gap;
			verticalLayout.firstGap = this._firstGap;
			verticalLayout.lastGap = this._lastGap;
			verticalLayout.paddingTop = this._paddingTop;
			verticalLayout.paddingRight = this._paddingRight;
			verticalLayout.paddingBottom = this._paddingBottom;
			verticalLayout.paddingLeft = this._paddingLeft;
		}
		else //horizontal
		{
			if (this._distributeButtonSizes)
			{
				var horizontalLayout:HorizontalLayout = SafeCast.safe_cast(this.layout, HorizontalLayout);
				if (horizontalLayout == null)
				{
					this.layout = horizontalLayout = new HorizontalLayout();
				}
				horizontalLayout.distributeWidths = true;
				horizontalLayout.horizontalAlign = (this._horizontalAlign == HorizontalAlign.JUSTIFY) ? HorizontalAlign.LEFT : this._horizontalAlign;
				horizontalLayout.verticalAlign = this._verticalAlign;
				horizontalLayout.gap = this._gap;
				horizontalLayout.firstGap = this._firstGap;
				horizontalLayout.lastGap = this._lastGap;
				horizontalLayout.paddingTop = this._paddingTop;
				horizontalLayout.paddingRight = this._paddingRight;
				horizontalLayout.paddingBottom = this._paddingBottom;
				horizontalLayout.paddingLeft = this._paddingLeft;
			}
			else
			{
				var flowLayout:FlowLayout = SafeCast.safe_cast(this.layout, FlowLayout);
				if (flowLayout == null)
				{
					this.layout = flowLayout = new FlowLayout();
				}
				flowLayout.horizontalAlign = (this._horizontalAlign == HorizontalAlign.JUSTIFY) ? HorizontalAlign.LEFT : this._horizontalAlign;
				flowLayout.verticalAlign = this._verticalAlign;
				flowLayout.gap = this._gap;
				flowLayout.firstHorizontalGap = this._firstGap;
				flowLayout.lastHorizontalGap = this._lastGap;
				flowLayout.paddingTop = this._paddingTop;
				flowLayout.paddingRight = this._paddingRight;
				flowLayout.paddingBottom = this._paddingBottom;
				flowLayout.paddingLeft = this._paddingLeft;
			}
		}
		if (Std.isOfType(layout, IVirtualLayout))
		{
			cast(layout, IVirtualLayout).useVirtualLayout = false;
		}
	}
	
	/**
	 * @private
	 */
	private function defaultButtonInitializer(button:Button, item:Dynamic):Void
	{
		if (Std.isOfType(item, Dynamic))
		{
			if (item.label != null)
			{
				button.label = item.label;
			}
			else
			{
				button.label = item.toString();
			}
			if (item.isEnabled != null)
			{
				button.isEnabled = item.isEnabled;
			}
			else
			{
				button.isEnabled = this._isEnabled;
			}
			for (field in DEFAULT_BUTTON_FIELDS)
			{
				if (Reflect.hasField(item, field))
				{
					Reflect.setProperty(button, field, Reflect.field(item, field));
				}
			}
			var removeListener:Bool;
			var listener:Dynamic;
			for (field in DEFAULT_BUTTON_EVENTS)
			{
				removeListener = true;
				if (Reflect.hasField(item, field))
				{
					listener = Reflect.field(item, field);
					if (listener == null || !Reflect.isFunction(listener))
					{
						continue;
					}
					removeListener = false;
					//we can't add the listener directly because we don't
					//know how to remove it later if the data provider
					//changes and we lose the old item. we'll use another
					//event listener that we control as a delegate, and
					//we'll be able to remove it later.
					button.addEventListener(field, defaultButtonEventsListener);
				}
				if (removeListener)
				{
					button.removeEventListener(field, defaultButtonEventsListener);
				}
			}
		}
		else
		{
			button.label = "";
			button.isEnabled = this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function defaultButtonReleaser(button:Button, oldItem:Dynamic):Void
	{
		button.label = null;
		for (field in DEFAULT_BUTTON_FIELDS)
		{
			if (Reflect.hasField(oldItem, field))
			{
				Reflect.setProperty(button, field, null);
			}
		}
		var removeListener:Bool;
		var listener:Dynamic;
		for (field in DEFAULT_BUTTON_EVENTS)
		{
			removeListener = true;
			if (Reflect.hasField(oldItem, field))
			{
				listener = Reflect.field(oldItem, field);
				if (listener == null || !Reflect.isFunction(listener))
				{
					continue;
				}
				button.removeEventListener(field, defaultButtonEventsListener);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshButtons(isFactoryInvalid:Bool):Void
	{
		var temp:Array<Button> = this.inactiveButtons;
		this.inactiveButtons = this.activeButtons;
		this.activeButtons = temp;
		this.activeButtons.resize(0);
		this._layoutItems.resize(0);
		temp = null;
		if (isFactoryInvalid)
		{
			this.clearInactiveButtons();
		}
		else
		{
			if (this.activeFirstButton != null)
			{
				this.inactiveButtons.shift();
			}
			this.inactiveFirstButton = this.activeFirstButton;
			
			if (this.activeLastButton != null)
			{
				this.inactiveButtons.pop();
			}
			this.inactiveLastButton = this.activeLastButton;
		}
		this.activeFirstButton = null;
		this.activeLastButton = null;
		
		var pushIndex:Int = 0;
		var itemCount:Int = this._dataProvider != null ? this._dataProvider.length : 0;
		var lastItemIndex:Int = itemCount - 1;
		var item:Dynamic;
		var button:Button;
		for (i in 0...itemCount)
		{
			item = this._dataProvider.getItemAt(i);
			if (i == 0)
			{
				button = this.activeFirstButton = this.createFirstButton(item);
			}
			else if (i == lastItemIndex)
			{
				button = this.activeLastButton = this.createLastButton(item);
			}
			else
			{
				button = this.createButton(item);
			}
			this.activeButtons[pushIndex] = button;
			this._layoutItems[pushIndex] = button;
			pushIndex++;
		}
		this.clearInactiveButtons();
	}
	
	/**
	 * @private
	 */
	private function clearInactiveButtons():Void
	{
		var itemCount:Int = this.inactiveButtons.length;
		var button:Button;
		for (i in 0...itemCount)
		{
			button = this.inactiveButtons.shift();
			this.destroyButton(button);
		}
		
		if (this.inactiveFirstButton != null)
		{
			this.destroyButton(this.inactiveFirstButton);
			this.inactiveFirstButton = null;
		}
		
		if (this.inactiveLastButton != null)
		{
			this.destroyButton(this.inactiveLastButton);
			this.inactiveLastButton = null;
		}
	}
	
	/**
	 * @private
	 */
	private function createFirstButton(item:Dynamic):Button
	{
		var isNewInstance:Bool = false;
		var button:Button;
		if (this.inactiveFirstButton != null)
		{
			button = this.inactiveFirstButton;
			this.releaseButton(button);
			this.inactiveFirstButton = null;
		}
		else
		{
			isNewInstance = true;
			var factory:Void->Button = this._firstButtonFactory != null ? this._firstButtonFactory : this._buttonFactory;
			button = factory();
			if (this._customFirstButtonStyleName != null)
			{
				button.styleNameList.add(this._customFirstButtonStyleName);
			}
			else if (this._customButtonStyleName != null)
			{
				button.styleNameList.add(this._customButtonStyleName);
			}
			else
			{
				button.styleNameList.add(this.firstButtonStyleName);
			}
			this.addChild(button);
		}
		this._buttonInitializer(button, item);
		this._buttonToItem[button] = item;
		if (isNewInstance)
		{
			//we need to listen for Event.TRIGGERED after the initializer
			//is called to avoid runtime errors because the button may be
			//disposed by the time listeners in the initializer are called.
			button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
		}
		return button;
	}
	
	/**
	 * @private
	 */
	private function createLastButton(item:Dynamic):Button
	{
		var isNewInstance:Bool = false;
		var button:Button;
		if (this.inactiveLastButton != null)
		{
			button = this.inactiveLastButton;
			this.releaseButton(button);
			this.inactiveLastButton = null;
		}
		else
		{
			isNewInstance = true;
			var factory:Void->Button = this._lastButtonFactory != null ? this._lastButtonFactory : this._buttonFactory;
			button = factory();
			if (this._customLastButtonStyleName != null)
			{
				button.styleNameList.add(this._customLastButtonStyleName);
			}
			else if (this._customButtonStyleName != null)
			{
				button.styleNameList.add(this._customButtonStyleName);
			}
			else
			{
				button.styleNameList.add(this.lastButtonStyleName);
			}
			this.addChild(button);
		}
		this._buttonInitializer(button, item);
		this._buttonToItem[button] = item;
		if(isNewInstance)
		{
			//we need to listen for Event.TRIGGERED after the initializer
			//is called to avoid runtime errors because the button may be
			//disposed by the time listeners in the initializer are called.
			button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
		}
		return button;
	}
	
	/**
	 * @private
	 */
	private function createButton(item:Dynamic):Button
	{
		var isNewInstance:Bool = false;
		var button:Button;
		if (this.inactiveButtons.length == 0)
		{
			isNewInstance = true;
			button = this._buttonFactory();
			if (this._customButtonStyleName != null)
			{
				button.styleNameList.add(this._customButtonStyleName);
			}
			else
			{
				button.styleNameList.add(this.buttonStyleName);
			}
			this.addChild(button);
		}
		else
		{
			button = this.inactiveButtons.shift();
			this.releaseButton(button);
		}
		this._buttonInitializer(button, item);
		this._buttonToItem[button] = item;
		if (isNewInstance)
		{
			//we need to listen for Event.TRIGGERED after the initializer
			//is called to avoid runtime errors because the button may be
			//disposed by the time listeners in the initializer are called.
			button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
		}
		return button;
	}
	
	/**
	 * @private
	 */
	private function releaseButton(button:Button):Void
	{
		var item:Dynamic = this._buttonToItem[button];
		this._buttonToItem.remove(button);
		
		if (ArgumentsCount.count_args(this._buttonReleaser) == 1)
		{
			this._buttonReleaser(button);
		}
		else
		{
			this._buttonReleaser(button, item);
		}
	}
	
	/**
	 * @private
	 */
	private function destroyButton(button:Button):Void
	{
		button.removeEventListener(Event.TRIGGERED, button_triggeredHandler);
		this.releaseButton(button);
		this.removeChild(button, true);
	}
	
	/**
	 * @private
	 */
	private function layoutButtons():Void
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
		this.layout.layout(this._layoutItems, this._viewPortBounds, this._layoutResult);
		
		var contentWidth:Float = this._layoutResult.contentWidth;
		var contentHeight:Float = this._layoutResult.contentHeight;
		//minimum dimensions are the same as the measured dimensions
		this.saveMeasurements(contentWidth, contentHeight, contentWidth, contentHeight);
		
		//final validation to avoid juggler next frame issues
		for (button in this.activeButtons)
		{
			button.validate();
		}
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
	private function dataProvider_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_updateAllHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_updateItemHandler(event:Event, index:Int):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function button_triggeredHandler(event:Event):Void
	{
		//if this was called after dispose, ignore it
		if (this._dataProvider == null || this.activeButtons == null)
		{
			return;
		}
		var button:Button = cast event.currentTarget;
		var index:Int = this.activeButtons.indexOf(button);
		var item:Dynamic = this._dataProvider.getItemAt(index);
		this.dispatchEventWith(Event.TRIGGERED, false, item);
	}
	
	/**
	 * @private
	 */
	private function defaultButtonEventsListener(event:Event):Void
	{
		var button:Button = cast event.currentTarget;
		var index:Int = this.activeButtons.indexOf(button);
		var item:Dynamic = this._dataProvider.getItemAt(index);
		var field:String = event.type;
		if (Reflect.hasField(item, field))
		{
			var listener:Function = Reflect.field(item, field);
			if (listener == null)
			{
				return;
			}
			var argCount:Int = ArgumentsCount.count_args(listener);
			switch(argCount)
			{
				case 3:
					listener(event, event.data, item);
				
				case 2:
					listener(event, event.data);
				
				case 1:
					listener(event);
				
				default:
					listener();
			}
		}
	}
	
}