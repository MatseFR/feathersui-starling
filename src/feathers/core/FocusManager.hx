/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import starling.display.DisplayObjectContainer;
import starling.display.Stage;

/**
 * Manages touch and keyboard focus.
 *
 * @see ../../../help/focus.html Keyboard focus management in Feathers
 *
 * @productversion Feathers 1.1.0
 */
class FocusManager 
{
	/**
	   @private
	**/
	private static inline var FOCUS_MANAGER_NOT_ENABLED_ERROR:String = "The specified action is not permitted when the focus manager is not enabled.";
	
	/**
	   @private
	**/
	private static inline var FOCUS_MANAGER_ROOT_MUST_BE_ON_STAGE_ERROR:String = "A focus manager may not be added or removed for a display object that is not on stage.";
	
	/**
	   @private
	**/
	private static inline var STAGE_TO_STACK:Map<Stage, Array<IFocusManager>> = new Map<Stage, Array<IFocusManager>>();
	
	/**
	 * Returns the active focus manager for the specified Starling stage.
	 * May return <code>null</code> if focus management has not been enabled
	 * for the specified stage.
	 *
	 * @see #isEnabledForStage()
	 * @see #setEnabledForStage()
	 */
	public static function getFocusManagerForStage(stage:Stage):IFocusManager
	{
		var stack:Array<IFocusManager> = STAGE_TO_STACK[stage];
		if (stack == null || stack.length == 0)
		{
			return null;
		}
		return stack[stack.length - 1];
	}
	
	
	public static function defaultFocuManagerFactory(root:DisplayObjectContainer):IFocusManager
	{
		
	}
	
}