/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

/**
 * Interface for pop-up management.
 *
 * @see feathers.core.PopUpManager
 *
 * @productversion Feathers 1.3.0
 */
interface IPopUpManager 
{
	/**
	 * @copy PopUpManager#overlayFactory
	 */
	public var overlayFactory(get, set):Void->DisplayObject
	
	/**
	 * @copy PopUpManager#root
	 */
	public var root(get, set):DisplayObjectContainer;
	
	/**
	 * @copy PopUpManager#popUpCount
	 */
	public var popUpCount(get, never):Int;
	
	/**
	 * @copy PopUpManager#addPopUp()
	 */
	function addPopUp(popUp:DisplayObject, isModal:Bool = true, isCentered:Bool = true, customOverlayFactory:Void->DisplayObject = null):DisplayObject;
	
	/**
	 * @copy PopUpManager#removePopUp()
	 */
	function removePopUp(popUp:DisplayObject, dispose:Bool = false):DisplayObject;
	
	/**
	 * @copy PopUpManager#removeAllPopUps()
	 */
	function removeAllPopUps(dispose:Bool = false):Void;
	
	/**
	 * @copy PopUpManager#isPopUp()
	 */
	function isPopUp(popUp:DisplayObject):Bool;
	
	/**
	 * @copy PopUpManager#isTopLevelPopUp()
	 */
	function isTopLevelPopUp(popUp:DisplayObject):Bool;
	
	/**
	 * @copy PopUpManager#centerPopUp()
	 */
	function centerPopUp(popUp:DisplayObject):Void;
	
}