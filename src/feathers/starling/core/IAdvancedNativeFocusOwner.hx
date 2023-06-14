/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;
import feathers.starling.core.INativeFocusOwner;

/**
 * If a display object implements <code>INativeFocusOwner</code> and its
 * <code>nativeFocus</code> property does not return a
 * <code>flash.display.InteractiveObject</code> (or <code>null</code>), it
 * must implement this interface so that the focus manager can tell it when
 * to give focus to its native focus object.
 *
 * @see ../../../help/focus.html
 *
 * @productversion Feathers 3.0.0
 */
interface IAdvancedNativeFocusOwner extends INativeFocusOwner
{
	/**
	 * Determines if <code>nativeFocus</code> currently has focus.
	 */
	public var hasFocus(get, never):Bool;
	
	/**
	 * Called by the focus manager to set focus on <code>nativeFocus</code>.
	 * May also be called manually.
	 */
	function setFocus():Void;
}