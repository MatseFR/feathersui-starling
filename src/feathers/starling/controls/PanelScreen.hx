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
 * A screen for use with <code>ScreenNavigator</code>, based on <code>Panel</code>
 * in order to provide a header and layout.
 *
 * <p>This component is generally not instantiated directly. Instead it is
 * typically used as a super class for concrete implementations of screens.
 * With that in mind, no code example is included here.</p>
 *
 * <p>The following example provides a basic framework for a new panel screen:</p>
 *
 * <listing version="3.0">
 * package
 * {
 *     import feathers.controls.PanelScreen;
 * 
 *     public class CustomScreen extends PanelScreen
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
 * @see ../../../panel-screen.html How to use the Feathers PanelScreen component
 * @see feathers.controls.StackScreenNavigator
 * @see feathers.controls.ScreenNavigator
 *
 * @productversion Feathers 1.1.0
 */
class PanelScreen extends Panel implements IScreen
{
	/**
	 * The default value added to the <code>styleNameList</code> of the header.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_HEADER:String = "feathers-panel-screen-header";

	/**
	 * The default value added to the <code>styleNameList</code> of the footer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_FOOTER:String = "feathers-panel-screen-footer";

	/**
	 * The default <code>IStyleProvider</code> for all <code>PanelScreen</code>
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
		this.addEventListener(Event.ADDED_TO_STAGE, panelScreen_addedToStageHandler);
		super();
		this.headerStyleName = DEFAULT_CHILD_STYLE_NAME_HEADER;
	}
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return PanelScreen.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	public var screenID(get, set):String;
	private var _screenID:String;
	private function get_screenID():String { return this._screenID; }
	private function set_screenID(value:String):String
	{
		return this._screenID = value;
	}
	
	/**
	 * @private
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
	private function panelScreen_addedToStageHandler(event:Event):Void
	{
		this.addEventListener(Event.REMOVED_FROM_STAGE, panelScreen_removedFromStageHandler);
		//using priority here is a hack so that objects higher up in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this);
		this.stage.starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, panelScreen_nativeStage_keyDownHandler, false, priority, true);
	}
	
	/**
	 * @private
	 */
	private function panelScreen_removedFromStageHandler(event:Event):Void
	{
		this.removeEventListener(Event.REMOVED_FROM_STAGE, panelScreen_removedFromStageHandler);
		this.stage.starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, panelScreen_nativeStage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	private function panelScreen_nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			//someone else already handled this one
			return;
		}
		
		// TODO : Keyboard.BACK only available on flash target
		#if flash
		if (this.backButtonHandler != null &&
			event.keyCode == Keyboard.BACK)
		{
			event.preventDefault();
			this.backButtonHandler();
		}
		#end
		
		// TODO : Keyboard.MENU only available on flash target
		#if flash
		if (this.menuButtonHandler != null &&
			event.keyCode == Keyboard.MENU)
		{
			event.preventDefault();
			this.menuButtonHandler();
		}
		#end
		
		// TODO : Keyboard.SEARCH only available on flash target
		#if flash
		if (this.searchButtonHandler != null &&
			event.keyCode == Keyboard.SEARCH)
		{
			event.preventDefault();
			this.searchButtonHandler();
		}
		#end
	}
	
}