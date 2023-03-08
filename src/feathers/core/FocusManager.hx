/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import starling.core.Starling;
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
	private static var STAGE_TO_STACK:Map<Stage, Array<IFocusManager>> = new Map<Stage, Array<IFocusManager>>();
	
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
	
	/**
	 * The default factory that creates a focus manager.
	 *
	 * @see #focusManagerFactory
	 * @see feathers.core.DefaultFocusManager
	 */
	public static function defaultFocusManagerFactory(root:DisplayObjectContainer):IFocusManager
	{
		return new DefaultFocusManager(root);
	}
	
	/**
	 * A function that creates a focus manager.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():IFocusManager</pre>
	 *
	 * <p>In the following example, the focus manager factory is modified:</p>
	 *
	 * <listing version="3.0">
	 * FocusManager.focusManagerFactory = function(root:DisplayObjectContainer):IFocusManager
	 * {
	 *     return new CustomFocusManager(); //a custom class that implements IFocusManager
	 * };</listing>
	 *
	 * @see feathers.core.IFocusManager
	 */
	public static var focusManagerFactory:DisplayObjectContainer->IFocusManager = defaultFocusManagerFactory;
	
	/**
	 * Determines if the focus manager is enabled or disabled for the
	 * specified Starling stage.
	 *
	 * @see #setEnabledForStage()
	 * @see #getFocusManagerForStage()
	 */
	public static function isEnabledForStage(stage:Stage):Bool
	{
		return STAGE_TO_STACK.exists(stage);
	}
	
	/**
	 * Enables or disables focus management on the specified Starling stage.
	 * For mobile apps, the focus manager should generally remain disabled.
	 * For desktop apps, it is recommended to enable the focus manager to
	 * support keyboard navigation.
	 *
	 * <p>In the following example, focus management is enabled:</p>
	 *
	 * <listing version="3.0">
	 * FocusManager.setEnabledForStage(stage, true);</listing>
	 *
	 * @see #isEnabledForStage()
	 * @see #getFocusManagerForStage()
	 */
	public static function setEnabledForStage(stage:Stage, isEnabled:Bool):Void
	{
		var stack:Array<IFocusManager> = STAGE_TO_STACK[stage];
		if ((isEnabled && stack != null) || (!isEnabled && stack == null))
		{
			return;
		}
		if (isEnabled)
		{
			STAGE_TO_STACK[stage] = new Array<IFocusManager>();
			pushFocusManager(stage);
		}
		else
		{
			while (stack.length != 0)
			{
				stack.pop().isEnabled = false;
			}
			STAGE_TO_STACK.remove(stage);
		}
	}
	
	/**
	 * Disables focus management on all stages where it has previously been
	 * enabled.
	 */
	public function disableAll():Void
	{
		for (stack in STAGE_TO_STACK)
		{
			while (stack.length != 0)
			{
				stack.pop().isEnabled = false;
			}
		}
		STAGE_TO_STACK.clear();
	}
	
	/**
	 * The object that currently has focus on <code>Starling.current.stage</code>.
	 * May return <code>null</code> if no object has focus.
	 *
	 * <p>You can call <code>geFocusManagerForStage()</code> to access the
	 * active <code>IFocusManager</code> instance for any <code>Stage</code>
	 * instance that isn't equal to <code>Starling.current.stage</code>.</p>
	 *
	 * <p>In the following example, the focus is changed on the current stage:</p>
	 *
	 * <listing version="3.0">
	 * FocusManager.focus = someObject;</listing>
	 *
	 * @see #getFocusManagerForStage()
	 */
	public static var focus(get, set):IFocusDisplayObject;
	private static function get_focus():IFocusDisplayObject
	{
		var manager:IFocusManager = getFocusManagerForStage(Starling.current.stage);
		if (manager != null)
		{
			return manager.focus;
		}
		return null;
	}
	
	private static function set_focus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		var manager:IFocusManager = getFocusManagerForStage(Starling.current.stage);
		if (manager == null)
		{
			throw new Error(FOCUS_MANAGER_NOT_ENABLED_ERROR);
		}
		return manager.focus = value;
	}
	
	/**
	 * Adds a focus manager to the stack for the <code>root</code>
	 * argument's stage, and gives it exclusive focus. If focus management
	 * has not been enabled for the root's stage, then calling this function
	 * will throw a runtime error.
	 */
	public static function pushFocusManager(root:DisplayObjectContainer):IFocusManager
	{
		var stage:Stage = root.stage;
		if (stage == null)
		{
			throw new ArgumentError(FOCUS_MANAGER_ROOT_MUST_BE_ON_STAGE_ERROR);
		}
		var stack:Array<IFocusManager> = STAGE_TO_STACK[stage];
		if (stack == null)
		{
			throw new Error(FOCUS_MANAGER_NOT_ENABLED_ERROR);
		}
		var manager:IFocusManager = FocusManager.focusManagerFactory(root);
		manager.isEnabled = true;
		if (stack.length != 0)
		{
			var oldManager:IFocusManager = stack[stack.length - 1];
			oldManager.isEnabled = false;
		}
		stack.push(manager);
		return manager;
	}
	
	/**
	 * Removes the specified focus manager from the stack. If it was
	 * the top-most focus manager, the next top-most focus manager is
	 * enabled.
	 */
	public static function removeFocusManager(manager:IFocusManager):Void
	{
		var stage:Stage = manager.root.stage.stage;
		var stack:Array<IFocusManager> = STAGE_TO_STACK[stage];
		if (stack == null)
		{
			throw new Error(FOCUS_MANAGER_NOT_ENABLED_ERROR);
		}
		var index:Int = stack.indexOf(manager);
		if (index == -1)
		{
			return;
		}
		manager.isEnabled = false;
		stack.splice(index, 1);
		//if this is the top-level focus manager, enable the previous one
		if (index != 0 && index == stack.length)
		{
			manager = stack[index - 1];
			manager.isEnabled = true;
		}
	}
	
}