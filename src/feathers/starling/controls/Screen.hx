/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.utils.display.DisplayUtils;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import starling.events.Event;

/**
 * A basic screen to be displayed by <code>ScreenNavigator</code>. Provides
 * layout capabilities, but no scrolling.
 *
 * <p>The following example provides a basic framework for a new screen:</p>
 *
 * <listing version="3.0">
 * package
 * {
 *     import feathers.controls.Screen;
 * 
 *     public class CustomScreen extends Screen
 *     {
 *         public function CustomScreen()
 *         {
 *             super();
 *         }
 * 
 *         override protected function initialize():void
 *         {
 *             //runs once when screen is first added to the stage
 *             //a good place to add children and customize the layout
 * 
 *             //don't forget to call this!
 *             super.initialize()
 *         }
 *     }
 * }</listing>
 *
 * @see ../../../help/screen.html How to use the Feathers Screen component
 * @see feathers.controls.StackScreenNavigator
 * @see feathers.controls.ScreenNavigator
 *
 * @productversion Feathers 1.0.0
 */
class Screen extends LayoutGroup
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>Screen</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		this.addEventListener(Event.ADDED_TO_STAGE, screen_addedToStageHandler);
		super();
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return Screen.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var screenID(get, set):String;
	private var _screenID:String;
	private function get_screenID():String { return this._screenID; }
	private function set_screenID(value:String):String
	{
		return this._screenID = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):Dynamic;
	private var _owner:Dynamic;
	private function get_owner():Dynamic { return this._owner; }
	private function set_owner(value:Dynamic):Dynamic
	{
		return this._owner = value;
	}
	
	/**
	 * Optional callback for the back hardware key. Automatically handles
	 * keyboard events to cancel the default behavior.
	 *
	 * <p>This function has the following signature:</p>
	 *
	 * <pre>function():void</pre>
	 *
	 * <p>In the following example, a function will dispatch <code>Event.COMPLETE</code>
	 * when the back button is pressed:</p>
	 *
	 * <listing version="3.0">
	 * this.backButtonHandler = onBackButton;
	 * 
	 * private function onBackButton():void
	 * {
	 *     this.dispatchEvent( Event.COMPLETE );
	 * };</listing>
	 *
	 * @default null
	 */
	private var backButtonHandler:Void->Void;

	/**
	 * Optional callback for the menu hardware key. Automatically handles
	 * keyboard events to cancel the default behavior.
	 *
	 * <p>This function has the following signature:</p>
	 *
	 * <pre>function():void</pre>
	 *
	 * <p>In the following example, a function will be called when the menu
	 * button is pressed:</p>
	 *
	 * <listing version="3.0">
	 * this.menuButtonHandler = onMenuButton;
	 * 
	 * private function onMenuButton():void
	 * {
	 *     //do something with the menu button
	 * };</listing>
	 *
	 * @default null
	 */
	private var menuButtonHandler:Void->Void;

	/**
	 * Optional callback for the search hardware key. Automatically handles
	 * keyboard events to cancel the default behavior.
	 *
	 * <p>This function has the following signature:</p>
	 *
	 * <pre>function():void</pre>
	 *
	 * <p>In the following example, a function will be called when the search
	 * button is pressed:</p>
	 *
	 * <listing version="3.0">
	 * this.searchButtonHandler = onSearchButton;
	 * 
	 * private function onSearchButton():void
	 * {
	 *     //do something with the search button
	 * };</listing>
	 *
	 * @default null
	 */
	private var searchButtonHandler:Void->Void;
	
	/**
	 * @private
	 */
	private function screen_addedToStageHandler(event:Event):Void
	{
		if (event.target != this)
		{
			return;
		}
		this.addEventListener(Event.REMOVED_FROM_STAGE, screen_removedFromStageHandler);
		//using priority here is a hack so that objects higher up in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this);
		this.stage.starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, screen_nativeStage_keyDownHandler, false, priority, true);
	}
	
	/**
	 * @private
	 */
	private function screen_removedFromStageHandler(event:Event):Void
	{
		if (event.target != this)
		{
			return;
		}
		this.removeEventListener(Event.REMOVED_FROM_STAGE, screen_removedFromStageHandler);
		this.stage.starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, screen_nativeStage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	private function screen_nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			//someone else already handled this one
			return;
		}
		// TODO : Keyboard.BACK is only available on flash target
		#if flash
		if (this.backButtonHandler != null &&
			event.keyCode == Keyboard.BACK)
		{
			event.preventDefault();
			this.backButtonHandler();
		}
		#end
		// TODO : Keyboard.MENU is only available on flash target
		#if flash
		if(this.menuButtonHandler != null &&
			event.keyCode == Keyboard.MENU)
		{
			event.preventDefault();
			this.menuButtonHandler();
		}
		#end
		// TODO : Keyboard.SEARCH only available on flash target
		#if flash
		if(this.searchButtonHandler != null &&
			event.keyCode == Keyboard.SEARCH)
		{
			event.preventDefault();
			this.searchButtonHandler();
		}
		#end
	}
}