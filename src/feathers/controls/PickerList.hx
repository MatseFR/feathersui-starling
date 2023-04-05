/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.utils.type.Property;
import feathers.controls.popups.CalloutPopUpContentManager;
import feathers.controls.popups.DropDownPopUpContentManager;
import feathers.controls.popups.IPersistentPopUpContentManager;
import feathers.controls.popups.IPopUpContentManager;
import feathers.controls.popups.IPopUpContentManagerWithPrompt;
import feathers.controls.popups.VerticalCenteredPopUpContentManager;
import feathers.controls.renderers.IListItemRenderer;
import feathers.core.FeathersControl;
import feathers.core.IFocusDisplayObject;
import feathers.core.ITextBaselineControl;
import feathers.core.IToggle;
import feathers.core.PropertyProxy;
import feathers.data.IListCollection;
import feathers.events.CollectionEventType;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import openfl.ui.Keyboard;
import starling.core.Starling;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.SystemUtil;

/**
 * Displays a button that may be triggered to display a pop-up list.
 * The list may be customized to display in different ways, such as a
 * drop-down, in a <code>Callout</code>, or as a modal overlay.
 *
 * <p>The following example creates a picker list, gives it a data provider,
 * tells the item renderer how to interpret the data, and listens for when
 * the selection changes:</p>
 *
 * <listing version="3.0">
 * var list:PickerList = new PickerList();
 * 
 * list.dataProvider = new ArrayCollection(
 * [
 *     { text: "Milk", thumbnail: textureAtlas.getTexture( "milk" ) },
 *     { text: "Eggs", thumbnail: textureAtlas.getTexture( "eggs" ) },
 *     { text: "Bread", thumbnail: textureAtlas.getTexture( "bread" ) },
 *     { text: "Chicken", thumbnail: textureAtlas.getTexture( "chicken" ) },
 * ]);
 * 
 * list.itemRendererFactory = function():IListItemRenderer
 * {
 *     var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
 *     renderer.labelField = "text";
 *     renderer.iconSourceField = "thumbnail";
 *     return renderer;
 * };
 * 
 * list.addEventListener( Event.CHANGE, list_changeHandler );
 * 
 * this.addChild( list );</listing>
 *
 * @see ../../../help/picker-list.html How to use the Feathers PickerList component
 *
 * @productversion Feathers 1.0.0
 */
class PickerList extends FeathersControl implements IFocusDisplayObject implements ITextBaselineControl
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_BUTTON_FACTORY:String = "buttonFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_LIST_FACTORY:String = "listFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the button.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_BUTTON:String = "feathers-picker-list-button";

	/**
	 * The default value added to the <code>styleNameList</code> of the pop-up
	 * list.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LIST:String = "feathers-picker-list-list";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>PickerList</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

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
	private static function defaultListFactory():List
	{
		return new List();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * button. This variable is <code>protected</code> so that sub-classes
	 * can customize the button style name in their constructors instead of
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
	 * The default value added to the <code>styleNameList</code> of the
	 * pop-up list. This variable is <code>protected</code> so that
	 * sub-classes can customize the list style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_LIST</code>.
	 *
	 * <p>To customize the pop-up list name without subclassing, see
	 * <code>customListStyleName</code>.</p>
	 *
	 * @see #style:customListStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var listStyleName:String = DEFAULT_CHILD_STYLE_NAME_LIST;

	/**
	 * The button sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #buttonFactory
	 * @see #createButton()
	 */
	private var button:Button;

	/**
	 * The list sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #listFactory
	 * @see #createList()
	 */
	private var list:List;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return PickerList.globalStyleProvider;
	}

	/**
	 * @private
	 */
	private var buttonExplicitWidth:Float;

	/**
	 * @private
	 */
	private var buttonExplicitHeight:Float;

	/**
	 * @private
	 */
	private var buttonExplicitMinWidth:Float;

	/**
	 * @private
	 */
	private var buttonExplicitMinHeight:Float;
	
	/**
	 * The collection of data displayed by the list.
	 *
	 * <p>The following example passes in a data provider and tells the item
	 * renderer how to interpret the data:</p>
	 *
	 * <listing version="3.0">
	 * list.dataProvider = new ArrayCollection(
	 * [
	 *     { text: "Milk", thumbnail: textureAtlas.getTexture( "milk" ) },
	 *     { text: "Eggs", thumbnail: textureAtlas.getTexture( "eggs" ) },
	 *     { text: "Bread", thumbnail: textureAtlas.getTexture( "bread" ) },
	 *     { text: "Chicken", thumbnail: textureAtlas.getTexture( "chicken" ) },
	 * ]);
	 * 
	 * list.itemRendererFactory = function():IListItemRenderer
	 * {
	 *     var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
	 *     renderer.labelField = "text";
	 *     renderer.iconSourceField = "thumbnail";
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
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
			this._dataProvider.removeEventListener(CollectionEventType.RESET, dataProvider_multipleEventHandler);
			this._dataProvider.removeEventListener(CollectionEventType.ADD_ITEM, dataProvider_multipleEventHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_multipleEventHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REMOVE_ALL, dataProvider_multipleEventHandler);
			this._dataProvider.removeEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_multipleEventHandler);
			this._dataProvider.removeEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null)
		{
			this._dataProvider.addEventListener(CollectionEventType.RESET, dataProvider_multipleEventHandler);
			this._dataProvider.addEventListener(CollectionEventType.ADD_ITEM, dataProvider_multipleEventHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ITEM, dataProvider_multipleEventHandler);
			this._dataProvider.addEventListener(CollectionEventType.REMOVE_ALL, dataProvider_multipleEventHandler);
			this._dataProvider.addEventListener(CollectionEventType.REPLACE_ITEM, dataProvider_multipleEventHandler);
			this._dataProvider.addEventListener(CollectionEventType.UPDATE_ITEM, dataProvider_updateItemHandler);
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
	private var _ignoreSelectionChanges:Bool = false;

	/**
	 * The index of the currently selected item. Returns <code>-1</code> if
	 * no item is selected.
	 *
	 * <p>The following example selects an item by its index:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndex = 2;</listing>
	 *
	 * <p>The following example clears the selected index:</p>
	 *
	 * <listing version="3.0">
	 * list.selectedIndex = -1;</listing>
	 *
	 * <p>The following example listens for when selection changes and
	 * requests the selected index:</p>
	 *
	 * <listing version="3.0">
	 * function list_changeHandler( event:Event ):void
	 * {
	 *     var list:PickerList = PickerList( event.currentTarget );
	 *     var index:int = list.selectedIndex;
	 * 
	 * }
	 * list.addEventListener( Event.CHANGE, list_changeHandler );</listing>
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
		if (this._selectedIndex == value)
		{
			return value;
		}
		this._selectedIndex = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		this.dispatchEventWith(Event.CHANGE);
		return this._selectedIndex;
	}
	
	
	public var selectedItem(get, set):Dynamic;
	private function get_selectedItem():Dynamic
	{
		if (this._dataProvider == null || this._selectedIndex < 0 || this._selectedIndex >= this._dataProvider.length)
		{
			return null;
		}
		return this._dataProvider.getItemAt(this._selectedIndex);
	}
	
	private function set_selectedItem(value:Dynamic):Dynamic
	{
		if (this._dataProvider == null)
		{
			this.selectedIndex = -1;
			return value;
		}
		this.selectedIndex = this._dataProvider.getItemIndex(value);
		return value;
	}
	
	/**
	 * Text displayed by the button sub-component when no items are
	 * currently selected.
	 *
	 * <p>In the following example, a prompt is given to the picker list
	 * and the selected item is cleared to display the prompt:</p>
	 *
	 * <listing version="3.0">
	 * list.prompt = "Select an Item";
	 * list.selectedIndex = -1;</listing>
	 *
	 * @default null
	 */
	public var prompt(get, set):String;
	private var _prompt:String;
	private function get_prompt():String { return this._prompt; }
	private function set_prompt(value:String):String
	{
		if (this._prompt == value)
		{
			return value;
		}
		this._prompt = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		return this._prompt;
	}
	
	/**
	 * The field in the selected item that contains the label text to be
	 * displayed by the picker list's button control. If the selected item
	 * does not have this field, and a <code>labelFunction</code> is not
	 * defined, then the picker list will default to calling
	 * <code>toString()</code> on the selected item. To omit the
	 * label completely, define a <code>labelFunction</code> that returns an
	 * empty string.
	 *
	 * <p><strong>Important:</strong> This value only affects the selected
	 * item displayed by the picker list's button control. It will <em>not</em>
	 * affect the label text of the pop-up list's item renderers.</p>
	 *
	 * <p>In the following example, the label field is changed:</p>
	 *
	 * <listing version="3.0">
	 * list.labelField = "text";</listing>
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
	 * A function used to generate label text for the selected item
	 * displayed by the picker list's button control. If this
	 * function is not null, then the <code>labelField</code> will be
	 * ignored.
	 *
	 * <p><strong>Important:</strong> This value only affects the selected
	 * item displayed by the picker list's button control. It will <em>not</em>
	 * affect the label text of the pop-up list's item renderers.</p>
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
	 * <p>In the following example, the label field is changed:</p>
	 *
	 * <listing version="3.0">
	 * list.labelFunction = function( item:Object ):String
	 * {
	 *     return item.firstName + " " + item.lastName;
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
		this._labelFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._labelFunction;
	}
	
	/**
	 * @private
	 */
	public var popUpContentManager(get, set):IPopUpContentManager;
	private var _popUpContentManager:IPopUpContentManager;
	private function get_popUpContentManager():IPopUpContentManager { return this._popUpContentManager; }
	private function set_popUpContentManager(value:IPopUpContentManager):IPopUpContentManager
	{
		if (this.processStyleRestriction("popUpContentManager"))
		{
			return value;
		}
		if (this._popUpContentManager == value)
		{
			return value;
		}
		var dispatcher:EventDispatcher;
		if (Std.isOfType(this._popUpContentManager, EventDispatcher))
		{
			dispatcher = cast this._popUpContentManager;
			dispatcher.removeEventListener(Event.OPEN, popUpContentManager_openHandler);
			dispatcher.removeEventListener(Event.CLOSE, popUpContentManager_closeHandler);
		}
		this._popUpContentManager = value;
		if (Std.isOfType(this._popUpContentManager, EventDispatcher))
		{
			dispatcher = cast this._popUpContentManager;
			dispatcher.addEventListener(Event.OPEN, popUpContentManager_openHandler);
			dispatcher.addEventListener(Event.CLOSE, popUpContentManager_closeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return value;
	}
	
	/**
	 * Used to auto-size the list. If the list's width or height is NaN, the
	 * list will try to automatically pick an ideal size. This item is
	 * used in that process to create a sample item renderer.
	 *
	 * <p>The following example provides a typical item:</p>
	 *
	 * <listing version="3.0">
	 * list.typicalItem = { text: "A typical item", thumbnail: texture };</listing>
	 *
	 * @default null
	 */
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._typicalItem;
	}
	
	/**
	 * A function used to generate the picker list's button sub-component.
	 * The button must be an instance of <code>Button</code>. This factory
	 * can be used to change properties on the button when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to set skins and other
	 * styles on the button.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():Button</pre>
	 *
	 * <p>In the following example, a custom button factory is passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.buttonFactory = function():Button
	 * {
	 *     var button:Button = new Button();
	 *     button.defaultSkin = new Image( upTexture );
	 *     button.downSkin = new Image( downTexture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
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
	 * An object that stores properties for the picker's button
	 * sub-component, and the properties will be passed down to the button
	 * when the picker validates. For a list of available
	 * properties, refer to
	 * <a href="Button.html"><code>feathers.controls.Button</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>buttonFactory</code> function
	 * instead of using <code>buttonProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the button properties are passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.buttonProperties.defaultSkin = new Image( upTexture );
	 * list.buttonProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #buttonFactory
	 * @see feathers.controls.Button
	 */
	public var buttonProperties(get, set):PropertyProxy;
	private var _buttonProperties:PropertyProxy;
	private function get_buttonProperties():PropertyProxy
	{
		if (this._buttonProperties == null)
		{
			this._buttonProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._buttonProperties;
	}
	
	private function set_buttonProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._buttonProperties == value)
		{
			return value;
		}
		if (this._buttonProperties != null)
		{
			this._buttonProperties.dispose();
		}
		this._buttonProperties = value;
		if (this._buttonProperties != null)
		{
			this._buttonProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._buttonProperties;
	}
	
	/**
	 * A function used to generate the picker list's pop-up list
	 * sub-component. The list must be an instance of <code>List</code>.
	 * This factory can be used to change properties on the list when it is
	 * first created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to set skins and other
	 * styles on the list.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():List</pre>
	 *
	 * <p>In the following example, a custom list factory is passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.listFactory = function():List
	 * {
	 *     var popUpList:List = new List();
	 *     popUpList.backgroundSkin = new Image( texture );
	 *     return popUpList;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.List
	 */
	public var listFactory(get, set):Void->List;
	private var _listFactory:Void->List;
	private function get_listFactory():Void->List { return this._listFactory; }
	private function set_listFactory(value:Void->List):Void->List
	{
		if (this._listFactory == value)
		{
			return value;
		}
		this._listFactory = value;
		this.invalidate(INVALIDATION_FLAG_LIST_FACTORY);
		return this._listFactory = value;
	}
	
	/**
	 * @private
	 */
	public var customListStyleName(get, set):String;
	private var _customListStyleName:String;
	private function get_customListStyleName():String { return this._customListStyleName; }
	private function set_customListStyleName(value:String):String
	{
		if (this.processStyleRestriction("customListStyleName"))
		{
			return value;
		}
		if (this._customListStyleName == value)
		{
			return value;
		}
		this._customListStyleName = value;
		this.invalidate(INVALIDATION_FLAG_LIST_FACTORY);
		return this._customListStyleName;
	}
	
	/**
	 * An object that stores properties for the picker's pop-up list
	 * sub-component, and the properties will be passed down to the pop-up
	 * list when the picker validates. For a list of available
	 * properties, refer to
	 * <a href="List.html"><code>feathers.controls.List</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>listFactory</code> function
	 * instead of using <code>listProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the list properties are passed to the
	 * picker list:</p>
	 *
	 * <listing version="3.0">
	 * list.listProperties.backgroundSkin = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #listFactory
	 * @see feathers.controls.List
	 */
	public var listProperties(get, set):PropertyProxy;
	private var _listProperties:PropertyProxy;
	private function get_listProperties():PropertyProxy
	{
		if (this._listProperties == null)
		{
			this._listProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._listProperties;
	}
	
	private function set_listProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._listProperties == value)
		{
			return value;
		}
		if (this._listProperties != null)
		{
			this._listProperties.dispose();
		}
		this._listProperties = value;
		if (this._listProperties != null)
		{
			this._listProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._listProperties;
	}
	
	/**
	 * @private
	 */
	public var toggleButtonOnOpenAndClose(get, set):Bool;
	private var _toggleButtonOnOpenAndClose:Bool = false;
	private function get_toggleButtonOnOpenAndClose():Bool { return this._toggleButtonOnOpenAndClose; }
	private function set_toggleButtonOnOpenAndClose(value:Bool):Bool
	{
		if (this.processStyleRestriction("toggleButtonOnOpenAndClose"))
		{
			return value;
		}
		if (this._toggleButtonOnOpenAndClose == value)
		{
			return value;
		}
		this._toggleButtonOnOpenAndClose = value;
		if (Std.isOfType(this.button, IToggle))
		{
			if (this._toggleButtonOnOpenAndClose && this._popUpContentManager.isOpen)
			{
				cast(this.button, IToggle).isSelected = true;
			}
			else
			{
				cast(this.button, IToggle).isSelected = false;
			}
		}
		return this._toggleButtonOnOpenAndClose;
	}
	
	/**
	 * A function called that is expected to return a new item renderer.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 *
	 * <pre>function():IListItemRenderer</pre>
	 *
	 * <p>The following example provides a factory for the item renderer:</p>
	 *
	 * <listing version="3.0">
	 * list.itemRendererFactory = function():IListItemRenderer
	 * {
	 *     var renderer:CustomItemRendererClass = new CustomItemRendererClass();
	 *     renderer.backgroundSkin = new Quad( 10, 10, 0xff0000 );
	 *     return renderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.IListItemRenderer
	 */
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
		this.invalidate(INVALIDATION_FLAG_LIST_FACTORY);
		return this._itemRendererFactory;
	}
	
	/**
	 * @private
	 */
	public var customItemRendererStyleName(get, set):String;
	private var _customItemRendererStyleName:String;
	private function get_customItemRendererStyleName():String { return this._customItemRendererStyleName; }
	private function set_customItemRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customItemRendererStyleName"))
		{
			return value;
		}
		if (this._customItemRendererStyleName == value)
		{
			return value;
		}
		this._customItemRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_LIST_FACTORY);
		return this._customItemRendererStyleName;
	}
	
	/**
	 * @inheritDoc
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.button == null)
		{
			return this.scaledActualHeight;
		}
		return this.scaleY * (this.button.y + this.button.baseline);
	}
	
	/**
	 * @private
	 */
	private var _triggered:Bool = false;

	/**
	 * @private
	 */
	private var _isOpenListPending:Bool = false;

	/**
	 * @private
	 */
	private var _isCloseListPending:Bool = false;
	
	/**
	 * Using <code>labelField</code> and <code>labelFunction</code>,
	 * generates a label from the selected item to be displayed by the
	 * picker list's button control.
	 *
	 * <p><strong>Important:</strong> This value only affects the selected
	 * item displayed by the picker list's button control. It will <em>not</em>
	 * affect the label text of the pop-up list's item renderers.</p>
	 */
	public function itemToLabel(item:Dynamic):String
	{
		var labelResult:Dynamic;
		if (this._labelFunction != null)
		{
			labelResult = this._labelFunction(item);
			if (Std.isOfType(labelResult, String))
			{
				return cast labelResult;
			}
			else if (labelResult != null)
			{
				return Std.string(labelResult);
			}
		}
		else if (this._labelField != null && item != null && Property.existsRead(item, this._labelField))
		{
			labelResult = Property.read(item, this._labelField);
			if (Std.isOfType(labelResult, String))
			{
				return cast labelResult;
			}
			else if (labelResult != null)
			{
				return Std.string(labelResult);
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
			return Std.string(item);
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private var _buttonHasFocus:Bool = false;

	/**
	 * @private
	 */
	private var _buttonTouchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _listIsOpenOnTouchBegan:Bool = false;
	
	/**
	 * Opens the pop-up list, if it isn't already open.
	 */
	public function openList():Void
	{
		this._isCloseListPending = false;
		if (this._popUpContentManager.isOpen)
		{
			return;
		}
		if (!this._isValidating && this.isInvalid())
		{
			this._isOpenListPending = true;
			return;
		}
		this._isOpenListPending = false;
		if (Std.isOfType(this._popUpContentManager, IPopUpContentManagerWithPrompt))
		{
			cast(this._popUpContentManager, IPopUpContentManagerWithPrompt).prompt = this._prompt;
		}
		this._popUpContentManager.open(this.list, this);
		this.list.scrollToDisplayIndex(this._selectedIndex);
		this.list.validate();
		if (this.list.focusManager != null)
		{
			this.list.focusManager.focus = this.list;
			this.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this.list.addEventListener(FeathersEventType.FOCUS_OUT, list_focusOutHandler);
		}
	}
	
	/**
	 * Closes the pop-up list, if it is open.
	 */
	public function closeList():Void
	{
		this._isOpenListPending = false;
		if (!this._popUpContentManager.isOpen)
		{
			return;
		}
		if (!this._isValidating && this.isInvalid())
		{
			this._isCloseListPending = true;
			return;
		}
		this._isCloseListPending = false;
		this.list.validate();
		//don't clean up anything from openList() in closeList(). The list
		//may be closed by removing it from the PopUpManager, which would
		//result in closeList() never being called.
		//instead, clean up in the Event.REMOVED_FROM_STAGE listener.
		this._popUpContentManager.close();
	}
	
	/**
	 * @inheritDoc
	 */
	override public function dispose():Void
	{
		if (this.list != null)
		{
			this.closeList();
			this.list.dispose();
			this.list = null;
		}
		if (this._popUpContentManager != null)
		{
			this._popUpContentManager.dispose();
			this._popUpContentManager = null;
		}
		if (this._buttonProperties != null)
		{
			this._buttonProperties.dispose();
			this._buttonProperties = null;
		}
		if (this._listProperties != null)
		{
			this._listProperties.dispose();
			this._listProperties = null;
		}
		//clearing selection now so that the data provider setter won't
		//cause a selection change that triggers events.
		this._selectedIndex = -1;
		this.dataProvider = null;
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override public function showFocus():Void
	{
		if (this.button == null)
		{
			return;
		}
		this.button.showFocus();
	}

	/**
	 * @private
	 */
	override public function hideFocus():Void
	{
		if (this.button == null)
		{
			return;
		}
		this.button.hideFocus();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		if (this._popUpContentManager == null)
		{
			var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
			var popUpContentManager:IPopUpContentManager;
			if (SystemUtil.isDesktop)
			{
				popUpContentManager = new DropDownPopUpContentManager();
			}
			else if (DeviceCapabilities.isTablet(starling.nativeStage))
			{
				popUpContentManager = new CalloutPopUpContentManager();
			}
			else
			{
				popUpContentManager = new VerticalCenteredPopUpContentManager();
			}
			this.ignoreNextStyleRestriction();
			this.popUpContentManager = popUpContentManager;
		}
		super.initialize();
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
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var buttonFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		var listFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_LIST_FACTORY);
		
		if (buttonFactoryInvalid)
		{
			this.createButton();
		}
		
		if (listFactoryInvalid)
		{
			this.createList();
		}
		
		if (buttonFactoryInvalid || stylesInvalid || selectionInvalid)
		{
			//this section asks the button to auto-size again, if our
			//explicit dimensions aren't set.
			//set this before buttonProperties is used because it might
			//contain width or height changes.
			if (this._explicitWidth != this._explicitWidth) //isNaN
			{
				this.button.width = Math.NaN;
			}
			if (this._explicitHeight != this._explicitHeight) //isNaN
			{
				this.button.height = Math.NaN;
			}
		}
		
		if (buttonFactoryInvalid || stylesInvalid)
		{
			this.refreshButtonProperties();
		}
		
		if (listFactoryInvalid || stylesInvalid)
		{
			this.refreshListProperties();
		}
		
		var oldIgnoreSelectionChanges:Bool;
		if (listFactoryInvalid || dataInvalid)
		{
			oldIgnoreSelectionChanges = this._ignoreSelectionChanges;
			this._ignoreSelectionChanges = true;
			this.list.dataProvider = this._dataProvider;
			this._ignoreSelectionChanges = oldIgnoreSelectionChanges;
		}
		
		if (buttonFactoryInvalid || listFactoryInvalid || stateInvalid)
		{
			this.button.isEnabled = this._isEnabled;
			this.list.isEnabled = this._isEnabled;
		}
		
		if (buttonFactoryInvalid || dataInvalid || selectionInvalid)
		{
			this.refreshButtonLabel();
		}
		if (listFactoryInvalid || dataInvalid || selectionInvalid)
		{
			oldIgnoreSelectionChanges = this._ignoreSelectionChanges;
			this._ignoreSelectionChanges = true;
			this.list.selectedIndex = this._selectedIndex;
			this._ignoreSelectionChanges = oldIgnoreSelectionChanges;
		}
		
		this.autoSizeIfNeeded();
		this.layout();
		
		if (this.list.stage != null)
		{
			//final validation to avoid juggler next frame issues
			//only validate if it's on the display list, though, because the
			//popUpContentManager may need to place restrictions on
			//dimensions or make other important changes.
			//otherwise, the List may create an item renderer for every item
			//in the data provider, which is not good for performance!
			this.list.validate();
		}
		
		this.handlePendingActions();
	}
	
	/**
	 * If the component's dimensions have not been set explicitly, it will
	 * measure its content and determine an ideal size for itself. If the
	 * <code>explicitWidth</code> or <code>explicitHeight</code> member
	 * variables are set, those value will be used without additional
	 * measurement. If one is set, but not the other, the dimension with the
	 * explicit value will not be measured, but the other non-explicit
	 * dimension will still need measurement.
	 *
	 * <p>Calls <code>saveMeasurements()</code> to set up the
	 * <code>actualWidth</code> and <code>actualHeight</code> member
	 * variables used for layout.</p>
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 */
	private function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		var buttonWidth:Float = this._explicitWidth;
		if (buttonWidth != buttonWidth) //isNaN
		{
			//we save the button's explicitWidth (and other explicit
			//dimensions) after the buttonFactory() returns so that
			//measurement always accounts for it, even after the button's
			//width is set by the PickerList
			buttonWidth = this.buttonExplicitWidth;
		}
		var buttonHeight:Float = this._explicitHeight;
		if (buttonHeight != buttonHeight) //isNaN
		{
			buttonHeight = this.buttonExplicitHeight;
		}
		var buttonMinWidth:Float = this._explicitMinWidth;
		if (buttonMinWidth != buttonMinWidth) //isNaN
		{
			buttonMinWidth = this.buttonExplicitMinWidth;
		}
		var buttonMinHeight:Float = this._explicitMinHeight;
		if (buttonMinHeight != buttonMinHeight) //isNaN
		{
			buttonMinHeight = this.buttonExplicitMinHeight;
		}
		if (this._typicalItem != null)
		{
			this.button.label = this.itemToLabel(this._typicalItem);
		}
		this.button.width = buttonWidth;
		this.button.height = buttonHeight;
		this.button.minWidth = buttonMinWidth;
		this.button.minHeight = buttonMinHeight;
		this.button.validate();
		
		if (this._typicalItem != null)
		{
			this.refreshButtonLabel();
		}
		
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		
		if (needsWidth)
		{
			newWidth = this.button.width;
		}
		if (needsHeight)
		{
			newHeight = this.button.height;
		}
		if (needsMinWidth)
		{
			newMinWidth = this.button.minWidth;
		}
		if (needsMinHeight)
		{
			newMinHeight = this.button.minHeight;
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Creates and adds the <code>button</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #button
	 * @see #buttonFactory
	 * @see #style:customButtonStyleName
	 */
	private function createButton():Void
	{
		if (this.button != null)
		{
			this.button.removeFromParent(true);
			this.button = null;
		}
		
		var factory:Void->Button = this._buttonFactory != null ? this._buttonFactory : defaultButtonFactory;
		var buttonStyleName:String = this._customButtonStyleName != null ? this._customButtonStyleName : this.buttonStyleName;
		this.button = factory();
		if (Std.isOfType(this.button, ToggleButton))
		{
			//we'll control the value of isSelected manually
			cast(this.button, ToggleButton).isToggle = false;
		}
		this.button.styleNameList.add(buttonStyleName);
		this.button.addEventListener(TouchEvent.TOUCH, button_touchHandler);
		this.button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
		this.addChild(this.button);
		
		//we will use these values for measurement, if possible
		this.button.initializeNow();
		this.buttonExplicitWidth = this.button.explicitWidth;
		this.buttonExplicitHeight = this.button.explicitHeight;
		this.buttonExplicitMinWidth = this.button.explicitMinWidth;
		this.buttonExplicitMinHeight = this.button.explicitMinHeight;
	}
	
	/**
	 * Creates and adds the <code>list</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #list
	 * @see #listFactory
	 * @see #style:customListStyleName
	 */
	private function createList():Void
	{
		if (this.list != null)
		{
			this.list.removeFromParent(false);
			//disposing separately because the list may not have a parent
			this.list.dispose();
			this.list = null;
		}
		
		var factory:Void->List = this._listFactory != null ? this._listFactory : defaultListFactory;
		var listStyleName:String = this._customListStyleName != null ? this._customListStyleName : this.listStyleName;
		this.list = factory();
		this.list.focusOwner = cast this;
		this.list.styleNameList.add(listStyleName);
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets customItemRendererStyleName and our
		//value is null. if our value is not null, we'll use it.
		if (this._customItemRendererStyleName != null)
		{
			this.list.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		if (this._itemRendererFactory != null)
		{
			this.list.itemRendererFactory = this._itemRendererFactory;
		}
		this.list.addEventListener(Event.CHANGE, list_changeHandler);
		this.list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
		this.list.addEventListener(TouchEvent.TOUCH, list_touchHandler);
		this.list.addEventListener(Event.REMOVED_FROM_STAGE, list_removedFromStageHandler);
	}
	
	/**
	 * @private
	 */
	private function refreshButtonLabel():Void
	{
		if (this._selectedIndex >= 0)
		{
			this.button.label = this.itemToLabel(this.selectedItem);
		}
		else
		{
			this.button.label = this._prompt;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshButtonProperties():Void
	{
		if (this._buttonProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._buttonProperties)
			{
				propertyValue = this._buttonProperties[propertyName];
				Property.write(this.button, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshListProperties():Void
	{
		if (this._listProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._listProperties)
			{
				propertyValue = this._listProperties[propertyName];
				Property.write(this.list, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function layout():Void
	{
		this.button.width = this.actualWidth;
		this.button.height = this.actualHeight;
		
		//final validation to avoid juggler next frame issues
		this.button.validate();
	}
	
	/**
	 * @private
	 */
	private function handlePendingActions():Void
	{
		if (this._isOpenListPending)
		{
			this.openList();
		}
		if (this._isCloseListPending)
		{
			this.closeList();
		}
	}
	
	/**
	 * @private
	 */
	override function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		this._buttonHasFocus = true;
		this.button.dispatchEventWith(FeathersEventType.FOCUS_IN);
	}
	
	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		if (this._buttonHasFocus)
		{
			this.button.dispatchEventWith(FeathersEventType.FOCUS_OUT);
			this._buttonHasFocus = false;
		}
		super.focusOutHandler(event);
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
	private function button_touchHandler(event:TouchEvent):Void
	{
		var touch:Touch;
		if (this._buttonTouchPointID >= 0)
		{
			touch = event.getTouch(this.button, TouchPhase.ENDED, this._buttonTouchPointID);
			if (touch == null)
			{
				return;
			}
			this._buttonTouchPointID = -1;
			//the button will dispatch Event.TRIGGERED before this touch
			//listener is called, so it is safe to clear this flag.
			//we're clearing it because Event.TRIGGERED may also be
			//dispatched after keyboard input.
			this._listIsOpenOnTouchBegan = false;
		}
		else
		{
			touch = event.getTouch(this.button, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			this._buttonTouchPointID = touch.id;
			this._listIsOpenOnTouchBegan = this._popUpContentManager.isOpen;
		}
	}
	
	/**
	 * @private
	 */
	private function button_triggeredHandler(event:Event):Void
	{
		if (this._focusManager != null && this._listIsOpenOnTouchBegan)
		{
			return;
		}
		if (this._popUpContentManager.isOpen)
		{
			this.closeList();
			return;
		}
		this.openList();
	}
	
	/**
	 * @private
	 */
	private function list_changeHandler(event:Event):Void
	{
		if (this._ignoreSelectionChanges ||
			Std.isOfType(this._popUpContentManager, IPersistentPopUpContentManager))
		{
			return;
		}
		this.selectedIndex = this.list.selectedIndex;
	}
	
	/**
	 * @private
	 */
	private function popUpContentManager_openHandler(event:Event):Void
	{
		if (this._toggleButtonOnOpenAndClose && Std.isOfType(this.button, IToggle))
		{
			cast(this.button, IToggle).isSelected = true;
		}
		this.list.revealScrollBars();
		this.dispatchEventWith(Event.OPEN);
	}
	
	/**
	 * @private
	 */
	private function popUpContentManager_closeHandler(event:Event):Void
	{
		if (Std.isOfType(this._popUpContentManager, IPersistentPopUpContentManager))
		{
			this.selectedIndex = this.list.selectedIndex;
		}
		if (this._toggleButtonOnOpenAndClose && Std.isOfType(this.button, IToggle))
		{
			cast(this.button, IToggle).isSelected = false;
		}
		this.dispatchEventWith(Event.CLOSE);
	}
	
	/**
	 * @private
	 */
	private function list_removedFromStageHandler(event:Event):Void
	{
		if (this._focusManager != null)
		{
			this.list.stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			this.list.removeEventListener(FeathersEventType.FOCUS_OUT, list_focusOutHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function list_focusOutHandler(event:Event):Void
	{
		if (!this._popUpContentManager.isOpen)
		{
			return;
		}
		this.closeList();
	}
	
	/**
	 * @private
	 */
	private function list_triggeredHandler(event:Event):Void
	{
		if (!this._isEnabled ||
			Std.isOfType(this._popUpContentManager, IPersistentPopUpContentManager))
		{
			return;
		}
		this._triggered = true;
	}
	
	/**
	 * @private
	 */
	private function list_touchHandler(event:TouchEvent):Void
	{
		var touch:Touch = event.getTouch(this.list);
		if (touch == null)
		{
			return;
		}
		if (touch.phase == TouchPhase.BEGAN)
		{
			this._triggered = false;
		}
		if (touch.phase == TouchPhase.ENDED && this._triggered)
		{
			this.closeList();
		}
	}
	
	/**
	 * @private
	 */
	private function dataProvider_multipleEventHandler(event:Event):Void
	{
		//we need to ensure that the pop-up list has received the new
		//selected index, or it might update the selected index to an
		//incorrect value after an item is added, removed, or replaced.
		this.validate();
	}
	
	/**
	 * @private
	 */
	private function dataProvider_updateItemHandler(event:Event, index:Int):Void
	{
		if (index == this._selectedIndex)
		{
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		}
	}
	
	/**
	 * @private
	 */
	private function stage_keyUpHandler(event:KeyboardEvent):Void
	{
		if (!this._popUpContentManager.isOpen)
		{
			return;
		}
		if (event.keyCode == Keyboard.ENTER)
		{
			this.closeList();
		}
	}
	
}