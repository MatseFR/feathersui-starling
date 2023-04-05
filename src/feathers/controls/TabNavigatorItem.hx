/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.supportClasses.IScreenNavigatorItem;
import feathers.utils.type.Property;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import starling.display.DisplayObject;

/**
 * Data for an individual tab that will be displayed by a
 * <code>TabNavigator</code> component.
 *
 * @see ../../../help/tab-navigator.html How to use the Feathers TabNavigator component
 * @see feathers.controls.TabNavigator
 *
 * @productversion Feathers 3.1.0
 */
class TabNavigatorItem implements IScreenNavigatorItem
{
	/**
	 * Constructor.
	 */
	public function new(classOrFunctionOrDisplayObject:Dynamic = null,
		label:String = null, icon:DisplayObject = null) 
	{
		if (Std.isOfType(classOrFunctionOrDisplayObject, DisplayObject))
		{
			this.screenDisplayObject = classOrFunctionOrDisplayObject;
		}
		else if (Std.isOfType(classOrFunctionOrDisplayObject, Class))
		{
			this.screenClass = classOrFunctionOrDisplayObject;
		}
		else if (Reflect.isFunction(classOrFunctionOrDisplayObject))
		{
			this.screenFunction = classOrFunctionOrDisplayObject;
		}
		else if (classOrFunctionOrDisplayObject != null)
		{
			throw new ArgumentError("Unknown view type. Must be Class, Function, or DisplayObject.");
		}
		this._label = label;
		this._icon = icon;
		this._properties = new Map<String, Dynamic>();
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispose():Void
	{
		if (this._properties != null)
		{
			this._properties.clear();
			this._properties = null;
		}
	}
	
	/**
	 * A <code>Class</code> that may be instantiated to create a
	 * <code>DisplayObject</code> instance to display when the associated
	 * tab is selected. A new instance of the screen will be instantiated
	 * every time that it is shown by the <code>TabNavigator</code>. The
	 * screen's state will not be saved automatically, but it may be saved
	 * in <code>properties</code>, if needed.
	 *
	 * @default null
	 *
	 * @see #screenFunction
	 * @see #screenDisplayObject
	 */
	public var screenClass(get, set):Class<Dynamic>;
	private var _screenClass:Class<Dynamic>;
	private function get_screenClass():Class<Dynamic> { return this._screenClass; }
	private function set_screenClass(value:Class<Dynamic>):Class<Dynamic>
	{
		if (this._screenClass == value)
		{
			return value;
		}
		this._screenClass = value;
		if (value != null)
		{
			this.screenFunction = null;
			this.screenDisplayObject = null;
		}
		return this._screenClass;
	}
	
	/**
	 * A <code>Function</code> that may be called to return a
	 * <code>DisplayObject</code> instance to display when the associated
	 * tab is selected. A new instance of the screen will be instantiated
	 * every time that it is shown by the <code>TabNavigator</code>. The
	 * screen's state will not be saved automatically, but it may be saved
	 * in <code>properties</code>, if needed.
	 *
	 * @default null
	 *
	 * @see #screenClass
	 * @see #screenDisplayObject
	 */
	public var screenFunction(get, set):Function;
	private var _screenFunction:Function;
	private function get_screenFunction():Function { return this._screenFunction; }
	private function set_screenFunction(value:Function):Function
	{
		if (this._screenFunction == value)
		{
			return value;
		}
		this._screenFunction = value;
		if (value != null)
		{
			this.screenClass = null;
			this.screenDisplayObject = null;
		}
		return this._screenFunction;
	}
	
	/**
	 * A display object to be displayed by the <code>TabNavigator</code>
	 * when the associted tab is selected. The same instance will be reused
	 * every time that it is shown by the <code>TabNavigator</code>. Whe
	 * the screen is hidden and shown again, its state will remain the same
	 * as when it was hidden. However, the screen will also be kept in
	 * memory even when it isn't displayed, limiting the resources that are
	 * available for other views.
	 *
	 * <p>Using <code>screenClass</code> or <code>screenFunction</code>
	 * instead of <code>screenDisplayObject</code> is the recommended best
	 * practice. In general, <code>screenDisplayObject</code> should only be
	 * used in rare situations where instantiating a new screen would be
	 * extremely expensive.</p>
	 *
	 * @default null
	 *
	 * @see #screenClass
	 * @see #screenFunction
	 */
	public var screenDisplayObject(get, set):DisplayObject;
	private var _screenDisplayObject:DisplayObject;
	private function get_screenDisplayObject():DisplayObject { return this._screenDisplayObject; }
	private function set_screenDisplayObject(value:DisplayObject):DisplayObject
	{
		if (this._screenDisplayObject == value)
		{
			return value;
		}
		this._screenDisplayObject = value;
		if (value != null)
		{
			this.screenClass = null;
			this.screenFunction = null;
		}
		return this._screenDisplayObject;
	}
	
	/**
	 * The label to display on the tab.
	 */
	public var label(get, set):String;
	private var _label:String;
	private function get_label():String { return this._label; }
	private function set_label(value:String):String
	{
		return this._label = value;
	}
	
	/**
	 * The optional icon to display on the tab.
	 */
	public var icon(get, set):DisplayObject;
	private var _icon:DisplayObject;
	private function get_icon():DisplayObject { return this._icon; }
	private function set_icon(value:DisplayObject):DisplayObject
	{
		return this._icon = value;
	}
	
	/**
	 * A set of key-value pairs representing properties to be set on the
	 * screen when it is shown. A pair's key is the name of the screen's
	 * property, and a pair's value is the value to be passed to the
	 * screen's property.
	 */
	public var properties(get, set):Map<String, Dynamic>;
	private var _properties:Map<String, Dynamic>;
	private function get_properties():Map<String, Dynamic> { return this._properties; }
	private function set_properties(value:Map<String, Dynamic>):Map<String, Dynamic>
	{
		if (this._properties == value)
		{
			return value;
		}
		if (this._properties != null)
		{
			this._properties.clear();
		}
		return this._properties = value;
	}
	
	/**
	 * A custom transition for this screen only. If <code>null</code>,
	 * the default <code>transition</code> defined by the
	 * <code>TabNavigator</code> will be used.
	 *
	 * <p>In the following example, the tab navigator item is given a custom
	 * transition:</p>
	 *
	 * <listing version="3.0">
	 * item.transition = Fade.createFadeInTransition();</listing>
	 *
	 * <p>A number of animated transitions may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these transitions. It's possible
	 * to create custom transitions too.</p>
	 *
	 * <p>A custom transition function should have the following signature:</p>
	 * <pre>function(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Function):void</pre>
	 *
	 * <p>Either of the <code>oldScreen</code> and <code>newScreen</code>
	 * arguments may be <code>null</code>, but never both. The
	 * <code>oldScreen</code> argument will be <code>null</code> when the
	 * first screen is displayed or when a new screen is displayed after
	 * clearing the screen. The <code>newScreen</code> argument will
	 * be null when clearing the screen.</p>
	 *
	 * <p>The <code>completeCallback</code> function <em>must</em> be called
	 * when the transition effect finishes. This callback indicate to the
	 * tab navigator that the transition has finished. This function has
	 * the following signature:</p>
	 *
	 * <pre>function(cancelTransition:Boolean = false):void</pre>
	 *
	 * <p>The first argument defaults to <code>false</code>, meaning that
	 * the transition completed successfully. In most cases, this callback
	 * may be called without arguments. If a transition is cancelled before
	 * completion (perhaps through some kind of user interaction), and the
	 * previous screen should be restored, pass <code>true</code> as the
	 * first argument to the callback to inform the tab navigator that
	 * the transition is cancelled.</p>
	 *
	 * @default null
	 *
	 * @see feathers.controls.TabNavigator#transition
	 * @see ../../../help/transitions.html Transitions for Feathers screen navigators
	 */
	public var transition(get, set):Function;
	private var _transition:Function;
	private function get_transition():Function { return this._transition; }
	private function set_transition(value:Function):Function
	{
		return this._transition = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var canDispose(get, never):Bool;
	private function get_canDispose():Bool { return this._screenDisplayObject == null; }
	
	/**
	 * @private
	 */
	public var transitionDelayEvent(get, never):String;
	private function get_transitionDelayEvent():String { return null; }
	
	/**
	 * @inheritDoc
	 */
	public function getScreen():DisplayObject
	{
		var viewInstance:DisplayObject = null;
		if (this._screenDisplayObject != null)
		{
			viewInstance = this._screenDisplayObject;
		}
		else if (this._screenClass != null)
		{
			viewInstance = Type.createInstance(this._screenClass, []);
		}
		else if (this._screenFunction != null)
		{
			viewInstance = cast this._screenFunction();
		}
		if (!Std.isOfType(viewInstance, DisplayObject))
		{
			throw new ArgumentError("TabNavigatorItem \"getScreen()\" must return a Starling display object.");
		}
		if (this._properties != null)
		{
			for (propertyName in this._properties.keys())
			{
				Property.write(viewInstance, propertyName, this._properties[propertyName]);
			}
		}
		
		return viewInstance;
	}
}