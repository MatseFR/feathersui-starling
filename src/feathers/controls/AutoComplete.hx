/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.popups.DropDownPopUpContentManager;
import feathers.controls.popups.IPopUpContentManager;
import feathers.core.FeathersControl;
import feathers.core.PropertyProxy;
import feathers.data.ArrayCollection;
import feathers.data.IAutoCompleteSource;
import feathers.data.IListCollection;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.display.DisplayUtils;
import feathers.utils.type.Property;
import openfl.Lib;
import openfl.ui.Keyboard;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * A text input that provides a pop-up list with suggestions as you type.
 *
 * <p>The following example creates an <code>AutoComplete</code> with a
 * local collection of suggestions:</p>
 *
 * <listing version="3.0">
 * var input:AutoComplete = new AutoComplete();
 * input.source = new LocalAutoCompleteSource( new VectorCollection(new &lt;String&gt;
 * [
 *     "Apple",
 *     "Banana",
 *     "Cherry",
 *     "Grape",
 *     "Lemon",
 *     "Orange",
 *     "Watermelon"
 * ]));
 * this.addChild( input );</listing>
 *
 * @see ../../../help/auto-complete.html How to use the Feathers AutoComplete component
 * @see feathers.controls.TextInput
 *
 * @productversion Feathers 2.1.0
 */
class AutoComplete extends TextInput 
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_LIST_FACTORY:String = "listFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the pop-up
	 * list.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LIST:String = "feathers-auto-complete-list";

	/**
	 * The default <code>IStyleProvider</code> for all
	 * <code>AutoComplete</code> components. If <code>null</code>, falls
	 * back to using <code>TextInput.globalStyleProvider</code> instead.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

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
		this.addEventListener(Event.CHANGE, autoComplete_changeHandler);
	}
	
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
	private var _listCollection:IListCollection;
	
	/**
	 * @private
	 */
	override private function get_defaultStyleProvider():IStyleProvider
	{
		if (AutoComplete.globalStyleProvider != null)
		{
			return AutoComplete.globalStyleProvider;
		}
		return TextInput.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _originalText:String;
	
	/**
	 * The source of the suggestions that appear in the pop-up list.
	 *
	 * <p>In the following example, a source of suggestions is provided:</p>
	 *
	 * <listing version="3.0">
	 * input.source = new LocalAutoCompleteSource( new VectorCollection(new &lt;String&gt;
	 * [
	 *     "Apple",
	 *     "Banana",
	 *     "Cherry",
	 *     "Grape",
	 *     "Lemon",
	 *     "Orange",
	 *     "Watermelon"
	 * ]));</listing>
	 *
	 * @default null
	 */
	public var source(get, set):IAutoCompleteSource;
	private var _source:IAutoCompleteSource;
	private function get_source():IAutoCompleteSource { return this._source; }
	private function set_source(value:IAutoCompleteSource):IAutoCompleteSource
	{
		if (this._source == value)
		{
			return value;
		}
		if (this._source != null)
		{
			this._source.removeEventListener(Event.COMPLETE, dataProvider_completeHandler);
		}
		if (value != null)
		{
			value.addEventListener(Event.COMPLETE, dataProvider_completeHandler);
		}
		return this._source = value;
	}
	
	/**
	 * The time, in seconds, after the text has changed before requesting
	 * suggestions from the <code>IAutoCompleteSource</code>.
	 *
	 * <p>In the following example, the delay is changed to 1.5 seconds:</p>
	 *
	 * <listing version="3.0">
	 * input.autoCompleteDelay = 1.5;</listing>
	 *
	 * @default 0.5
	 *
	 * @see #source
	 */
	public var autoCompleteDelay(get, set):Float;
	private var _autoCompleteDelay:Float = 0.5;
	private function get_autoCompleteDelay():Float { return this._autoCompleteDelay; }
	private function set_autoCompleteDelay(value:Float):Float
	{
		return this._autoCompleteDelay = value;
	}
	
	/**
	 * The minimum number of entered characters required to request
	 * suggestions from the <code>IAutoCompleteSource</code>.
	 *
	 * <p>In the following example, the minimum number of characters is
	 * changed to <code>3</code>:</p>
	 *
	 * <listing version="3.0">
	 * input.minimumAutoCompleteLength = 3;</listing>
	 *
	 * @default 2
	 *
	 * @see #source
	 */
	public var minimumAutoCompleteLength(get, set):Int;
	private var _minimumAutoCompleteLength:Int = 2;
	private function get_minimumAutoCompleteLength():Int { return this._minimumAutoCompleteLength; }
	private function set_minimumAutoCompleteLength(value:Int):Int
	{
		return this._minimumAutoCompleteLength = value;
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
		return this._popUpContentManager;
	}
	
	/**
	 * A function used to generate the pop-up list sub-component. The list
	 * must be an instance of <code>List</code>. This factory can be used to
	 * change properties on the list when it is first created. For instance,
	 * if you are skinning Feathers components without a theme, you might
	 * use this factory to set skins and other styles on the list.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():List</pre>
	 *
	 * <p>In the following example, a custom list factory is passed to the
	 * <code>AutoComplete</code>:</p>
	 *
	 * <listing version="3.0">
	 * input.listFactory = function():List
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
		return this._listFactory;
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
	 * An object that stores properties for the auto-complete's pop-up list
	 * sub-component, and the properties will be passed down to the pop-up
	 * list when the auto-complete validates. For a list of available
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
	 * auto complete:</p>
	 *
	 * <listing version="3.0">
	 * input.listProperties.backgroundSkin = new Image( texture );</listing>
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
			listProperties = new PropertyProxy(childProperties_onChange);
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
	private var _ignoreAutoCompleteChanges:Bool = false;

	/**
	 * @private
	 */
	private var _lastChangeTime:Int = 0;

	/**
	 * @private
	 */
	private var _listHasFocus:Bool = false;

	/**
	 * @private
	 */
	private var _listTouchPointID:Int = -1;

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
		this._popUpContentManager.open(this.list, this);
		this.list.validate();
		if (this._focusManager != null)
		{
			this.stage.addEventListener(starling.events.KeyboardEvent.KEY_UP, stage_keyUpHandler);
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
		if (this._listHasFocus)
		{
			this.list.dispatchEventWith(FeathersEventType.FOCUS_OUT);
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
		this.source = null;
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
		if (this._listProperties != null)
		{
			this._listProperties.dispose();
			this._listProperties = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		super.initialize();
		
		this._listCollection = new ArrayCollection();
		if (this._popUpContentManager == null)
		{
			this.ignoreNextStyleRestriction();
			this.popUpContentManager = new DropDownPopUpContentManager();
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var listFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_LIST_FACTORY);
		
		super.draw();
		
		if (listFactoryInvalid)
		{
			this.createList();
		}
		
		if (listFactoryInvalid || stylesInvalid)
		{
			this.refreshListProperties();
		}
		
		this.handlePendingActions();
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
		this.list.focusOwner = this;
		this.list.isFocusEnabled = false;
		this.list.isChildFocusEnabled = false;
		this.list.styleNameList.add(listStyleName);
		this.list.addEventListener(Event.CHANGE, list_changeHandler);
		this.list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
		this.list.addEventListener(TouchEvent.TOUCH, list_touchHandler);
		this.list.addEventListener(Event.REMOVED_FROM_STAGE, list_removedFromStageHandler);
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
		//using priority here is a hack so that objects deeper in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this);
		this.stage.starling.nativeStage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler, false, priority, true);
		super.focusInHandler(event);
	}
	
	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		this.stage.starling.nativeStage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler);
		super.focusOutHandler(event);
	}
	
	/**
	 * @private
	 */
	private function nativeStage_keyDownHandler(event:openfl.events.KeyboardEvent):Void
	{
		if (!this._popUpContentManager.isOpen)
		{
			return;
		}
		if (event.isDefaultPrevented())
		{
			return;
		}
		var isDown:Bool = event.keyCode == Keyboard.DOWN;
		var isUp:Bool = event.keyCode == Keyboard.UP;
		if (!isDown && !isUp)
		{
			return;
		}
		var oldSelectedIndex:Int = this.list.selectedIndex;
		var lastIndex:Int = this.list.dataProvider.length - 1;
		if (oldSelectedIndex == -1)
		{
			event.preventDefault();
			this._originalText = this._text;
			if (isDown)
			{
				this.list.selectedIndex = 0;
			}
			else
			{
				this.list.selectedIndex = lastIndex;
			}
			this.list.scrollToDisplayIndex(this.list.selectedIndex, this.list.keyScrollDuration);
			this._listHasFocus = true;
			this.list.dispatchEventWith(FeathersEventType.FOCUS_IN);
		}
		else if ((isDown && oldSelectedIndex == lastIndex) ||
			(isUp && oldSelectedIndex == 0))
		{
			event.preventDefault();
			var oldIgnoreAutoCompleteChanges:Bool = this._ignoreAutoCompleteChanges;
			this._ignoreAutoCompleteChanges = true;
			this.text = this._originalText;
			this._ignoreAutoCompleteChanges = oldIgnoreAutoCompleteChanges;
			this.list.selectedIndex = -1;
			this.selectRange(this.text.length, this.text.length);
			this._listHasFocus = false;
			this.list.dispatchEventWith(FeathersEventType.FOCUS_OUT);
		}
	}
	
	/**
	 * @private
	 */
	private function autoComplete_changeHandler(event:Event):Void
	{
		if (this._ignoreAutoCompleteChanges || this._source == null || !this.hasFocus)
		{
			return;
		}
		if (this.text.length < this._minimumAutoCompleteLength)
		{
			this.removeEventListener(Event.ENTER_FRAME, autoComplete_enterFrameHandler);
			this.closeList();
			return;
		}
		
		if (this._autoCompleteDelay == 0)
		{
			//just in case the enter frame listener was added before
			//sourceUpdateDelay was set to 0.
			this.removeEventListener(Event.ENTER_FRAME, autoComplete_enterFrameHandler);
			
			this._source.load(this.text, this._listCollection);
		}
		else
		{
			this._lastChangeTime = Lib.getTimer();
			this.addEventListener(Event.ENTER_FRAME, autoComplete_enterFrameHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function autoComplete_enterFrameHandler():Void
	{
		var currentTime:Int = Lib.getTimer();
		var secondsSinceLastUpdate:Float = (currentTime - this._lastChangeTime) / 1000;
		if (secondsSinceLastUpdate < this._autoCompleteDelay)
		{
			return;
		}
		this.removeEventListener(Event.ENTER_FRAME, autoComplete_enterFrameHandler);
		this._source.load(this.text, this._listCollection);
	}
	
	/**
	 * @private
	 */
	private function dataProvider_completeHandler(event:Event, data:IListCollection):Void
	{
		this.list.dataProvider = data;
		if (data.length == 0)
		{
			if (this._popUpContentManager.isOpen)
			{
				this.closeList();
			}
			return;
		}
		this.openList();
	}
	
	/**
	 * @private
	 */
	private function list_changeHandler(event:Event):Void
	{
		if (this.list.selectedItem == null)
		{
			return;
		}
		var oldIgnoreAutoCompleteChanges:Bool = this._ignoreAutoCompleteChanges;
		this._ignoreAutoCompleteChanges = true;
		this.text = Std.string(this.list.selectedItem);
		this.selectRange(this.text.length, this.text.length);
		this._ignoreAutoCompleteChanges = oldIgnoreAutoCompleteChanges;
	}
	
	/**
	 * @private
	 */
	private function popUpContentManager_openHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.OPEN);
	}

	/**
	 * @private
	 */
	private function popUpContentManager_closeHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.CLOSE);
	}
	
	/**
	 * @private
	 */
	private function list_removedFromStageHandler(event:Event):Void
	{
		if (this._focusManager != null)
		{
			this.list.stage.removeEventListener(starling.events.KeyboardEvent.KEY_UP, stage_keyUpHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function list_triggeredHandler(event:Event):Void
	{
		if (!this._isEnabled)
		{
			return;
		}
		if (this._listTouchPointID == -1)
		{
			//triggered by keyboard
			this.closeList();
			this.selectRange(this.text.length, this.text.length);
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
			this._listTouchPointID = touch.id;
			this._triggered = false;
		}
		if (touch.phase == TouchPhase.ENDED && this._triggered)
		{
			this._listTouchPointID = -1;
			this.closeList();
			this.selectRange(this.text.length, this.text.length);
		}
	}
	
	/**
	 * @private
	 */
	private function stage_keyUpHandler(event:starling.events.KeyboardEvent):Void
	{
		if (!this._popUpContentManager.isOpen)
		{
			return;
		}
		if (event.keyCode == Keyboard.ENTER)
		{
			this.closeList();
			this.selectRange(this.text.length, this.text.length);
		}
	}
	
}