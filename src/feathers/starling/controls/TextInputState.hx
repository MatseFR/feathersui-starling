/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

/**
 * States for text input components.
 *
 * @see feathers.controls.TextInput
 * @see feathers.controls.TextArea
 * @see feathers.controls.AutoComplete
 *
 * @productversion Feathers 3.0.0
 */
class TextInputState 
{

	/**
	 * The default state, when the input is enabled.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var ENABLED:String = "enabled";

	/**
	 * The disabled state, when the input is not enabled.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var DISABLED:String = "disabled";

	/**
	 * The focused state, when the input is currently in focus and the user
	 * can interact with it.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var FOCUSED:String = "focused";

	/**
	 * The state when the input has an error string.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var ERROR:String = "error";
	
}