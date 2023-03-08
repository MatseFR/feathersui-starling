/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.popups;

/**
 * A custom <code>IPopUpContentManager</code> that has a prompt that may
 * be customized by the parent component.
 *
 * @productversion Feathers 2.3.0
 */
interface IPopUpContentManagerWithPrompt extends IPopUpContentManager
{
	/**
	 * Some descriptive text to display with the pop-up.
	 */
	public var prompt(get, set):String;
}