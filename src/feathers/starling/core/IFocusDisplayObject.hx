/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;
import feathers.starling.core.IFocusManager;

/**
 * A component that can receive focus if a focus manager is enabled.
 *
 * @see ../../../help/focus.html Keyboard focus management in Feathers
 *
 * @productversion Feathers 1.1.0
 */
interface IFocusDisplayObject extends IFeathersDisplayObject
{
	/**
	 * The current focus manager for this component. May be
	 * <code>null</code> if no focus manager is enabled.
	 */
	public var focusManager(get, set):IFocusManager;
	
	/**
	 * Determines if this component can receive focus.
	 *
	 * <p>In the following example, the focus is disabled:</p>
	 *
	 * <listing version="3.0">
	 * object.isFocusEnabled = false;</listing>
	 */
	public var isFocusEnabled(get, set):Bool;
	
	/**
	 * The next object that will receive focus when the tab key is pressed
	 * when a focus manager is enabled. If <code>null</code>, defaults to
	 * the next child on the display list.
	 *
	 * <p>In the following example, the next tab focus is changed:</p>
	 *
	 * <listing version="3.0">
	 * object.nextTabFocus = otherObject;</listing>
	 */
	public var nextTabFocus(get, set):IFocusDisplayObject;
	
	/**
	 * The previous object that will receive focus when the tab key is
	 * pressed while holding shift when a focus manager is enabled. If
	 * <code>null</code>, defaults to the previous child on the display
	 * list.
	 *
	 * <p>In the following example, the previous tab focus is changed:</p>
	 *
	 * <listing version="3.0">
	 * object.previousTabFocus = otherObject;</listing>
	 */
	public var previousTabFocus(get, set):IFocusDisplayObject;
	
	/**
	 * The next object that will receive focus when
	 * <code>Keyboard.UP</code> is pressed at
	 * <code>KeyLocation.D_PAD</code> and a focus manager is enabled. If
	 * <code>null</code>, defaults to the best available child, as
	 * determined by the focus manager.
	 *
	 * <p>In the following example, the next up focus is changed:</p>
	 *
	 * <listing version="3.0">
	 * object.nextUpFocus = otherObject;</listing>
	 *
	 * <p>To simulate <code>KeyLocation.D_PAD</code> in the AIR Debug
	 * Launcher on desktop for debugging purposes, set
	 * <code>DeviceCapabilities.simulateDPad</code> to <code>true</code>.</p>
	 *
	 * @see feathers.system.DeviceCapabilities#simulateDPad
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextUpFocus(get, set):IFocusDisplayObject;
	
	/**
	 * The next object that will receive focus when
	 * <code>Keyboard.RIGHT</code> is pressed at
	 * <code>KeyLocation.D_PAD</code> and a focus manager is enabled. If
	 * <code>null</code>, defaults to the best available child, as
	 * determined by the focus manager.
	 *
	 * <p>In the following example, the next right focus is changed:</p>
	 *
	 * <listing version="3.0">
	 * object.nextRightFocus = otherObject;</listing>
	 *
	 * <p>To simulate <code>KeyLocation.D_PAD</code> in the AIR Debug
	 * Launcher on desktop for debugging purposes, set
	 * <code>DeviceCapabilities.simulateDPad</code> to <code>true</code>.</p>
	 *
	 * @see feathers.system.DeviceCapabilities#simulateDPad
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextRightFocus(get, set):IFocusDisplayObject;
	
	/**
	 * The next object that will receive focus when
	 * <code>Keyboard.DOWN</code> is pressed at
	 * <code>KeyLocation.D_PAD</code> and a focus manager is enabled. If
	 * <code>null</code>, defaults to the best available child, as
	 * determined by the focus manager.
	 *
	 * <p>In the following example, the next down focus is changed:</p>
	 *
	 * <listing version="3.0">
	 * object.nextDownFocus = otherObject;</listing>
	 *
	 * <p>To simulate <code>KeyLocation.D_PAD</code> in the AIR Debug
	 * Launcher on desktop for debugging purposes, set
	 * <code>DeviceCapabilities.simulateDPad</code> to <code>true</code>.</p>
	 *
	 * @see feathers.system.DeviceCapabilities#simulateDPad
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextDownFocus(get, set):IFocusDisplayObject;
	
	/**
	 * The next object that will receive focus when
	 * <code>Keyboard.LEFT</code> is pressed at
	 * <code>KeyLocation.D_PAD</code> and a focus manager is enabled. If
	 * <code>null</code>, defaults to the best available child, as
	 * determined by the focus manager.
	 *
	 * <p>In the following example, the next left focus is changed:</p>
	 *
	 * <listing version="3.0">
	 * object.nextLeftFocus = otherObject;</listing>
	 *
	 * <p>To simulate <code>KeyLocation.D_PAD</code> in the AIR Debug
	 * Launcher on desktop for debugging purposes, set
	 * <code>DeviceCapabilities.simulateDPad</code> to <code>true</code>.</p>
	 *
	 * @see feathers.system.DeviceCapabilities#simulateDPad
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextLeftFocus(get, set):IFocusDisplayObject;
	
	/**
	 * Used for associating focusable display objects that are not direct
	 * children with an "owner" focusable display object, such as pop-ups.
	 * A focus manager may use this property to influence the tab order.
	 *
	 * <p>In the following example, the focus owner is changed:</p>
	 *
	 * <listing version="3.0">
	 * object.focusOwner = otherObject;</listing>
	 */
	public var focusOwner(get, set):IFocusDisplayObject;
	
	/**
	 * Indicates if the <code>showFocus()</code> method has been called on
	 * the object when it has focus.
	 *
	 * <listing version="3.0">
	 * if(object.isShowingFocus)
	 * {
	 * 
	 * }</listing>
	 *
	 * @see #showFocus()
	 * @see #hideFocus()
	 */
	public var isShowingFocus(get, never):Bool;
	
	/**
	 * If <code>true</code>, the display object should remain in focus,
	 * even if something else is touched. If <code>false</code>, touching
	 * another object will pass focus normally.
	 */
	public var maintainTouchFocus(get, never):Bool;
	
	/**
	 * If the object has focus, an additional visual indicator may
	 * optionally be displayed to highlight the object. Calling this
	 * function may have no effect. It's merely a suggestion to the object.
	 *
	 * <p><strong>Important:</strong> This function will not give focus to
	 * the display object if it doesn't have focus. To give focus to the
	 * display object, you should set the <code>focus</code> property on
	 * the focus manager.</p>
	 *
	 * <listing version="3.0">
	 * object.focusManager.focus = object;</listing>
	 *
	 * @see #hideFocus()
	 * @see feathers.core.IFocusManager#focus
	 */
	function showFocus():Void;
	
	/**
	 * If the visual indicator of focus has been displayed by
	 * <code>showFocus()</code>, call this function to hide it.
	 *
	 * <p><strong>Important:</strong> This function will not clear focus
	 * from the display object if it has focus. To clear focus from the
	 * display object, you should set the <code>focus</code> property on
	 * the focus manager to <code>null</code> or another display object.</p>
	 *
	 * @see #showFocus()
	 * @see feathers.core.IFocusManager#focus
	 */
	function hideFocus():Void;
}