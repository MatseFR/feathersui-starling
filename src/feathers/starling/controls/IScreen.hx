/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;
import feathers.starling.core.IFeathersControl;

/**
 * A screen to display in a screen navigator.
 *
 * @see feathers.controls.StackScreenNavigator
 * @see feathers.controls.ScreenNavigator
 *
 * @productversion Feathers 1.0.0
 */
interface IScreen extends IFeathersControl
{
	/**
	 * The identifier for the screen. This value is passed in by the
	 * <code>ScreenNavigator</code> when the screen is instantiated.
	 */
	public var screenID(get, set):String;
	
	/**
	 * The screen navigator that is currently displaying this screen.
	 */
	public var owner(get, set):Dynamic;
}