/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;
import openfl.errors.ArgumentError;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

/**
 * Adds a display object as a pop-up above all content.
 *
 * @productversion Feathers 1.0.0
 */
class PopUpManager 
{
	/**
	 * @private
	 */
	private static var _starlingToPopUpManager:Map<Starling, IPopUpManager> = new Map<Starling, IPopUpManager>();
	
	/**
	 * The default factory that creates a pop-up manager.
	 *
	 * @see feathers.core.DefaultPopUpManager
	 */
	public static function defaultPopUpManagerFactory():IPopUpManager
	{
		return new DefaultPopUpManager();
	}
	
	/**
	 * Returns the <code>IPopUpManager</code> associated with the specified
	 * <code>Starling</code> instance. If a pop-up manager hasn't been
	 * created yet, it will be created using <code>PopUpManager.popUpManagerFactory</code>.
	 *
	 * <p>In the following example, a pop-up is added:</p>
	 *
	 * <listing version="3.0">
	 * PopUpManager.forStarling( Starling.current ).addPopUp( popUp );</listing>
	 *
	 * @see #popUpManagerFactory
	 */
	public static function forStarling(starling:Starling):IPopUpManager
	{
		if (starling == null)
		{
			throw new ArgumentError("PopUpManager not found. Starling cannot be null.");
		}
		var popUpManager:IPopUpManager = _starlingToPopUpManager[starling];
		if (popUpManager == null)
		{
			var factory:Void->IPopUpManager = PopUpManager.popUpManagerFactory;
			if (factory == null)
			{
				factory = PopUpManager.defaultPopUpManagerFactory;
			}
			popUpManager = factory();
			//this allows the factory to optionally set the root, but it
			//also enforces the root being on the correct stage.
			if (popUpManager.root == null || !starling.stage.contains(popUpManager.root))
			{
				popUpManager.root = Starling.current.stage;
			}
			PopUpManager._starlingToPopUpManager[starling] = popUpManager;
		}
		return popUpManager;
	}
	
	/**
	 * A function that creates a pop-up manager.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():IPopUpManager</pre>
	 *
	 * <p>In the following example, the overlay factory is changed:</p>
	 *
	 * <listing version="3.0">
	 * PopUpManager.popUpManagerFactory = function():IPopUpManager
	 * {
	 *     var popUpManager:DefaultPopUpManager = new DefaultPopUpManager();
	 *     popUpManager.overlayFactory = function():DisplayObject
	 *     {
	 *         var overlay:Quad = new Quad( 100, 100, 0x000000 );
	 *         overlay.alpha = 0.75;
	 *         return overlay;
	 *     };
	 *     return popUpManager;
	 * };</listing>
	 *
	 * @see feathers.core.IPopUpManager
	 */
	public static var popUpManagerFactory:Void->IPopUpManager = defaultPopUpManagerFactory;
	
	/**
	 * A function that returns a display object to use as an overlay for
	 * modal pop-ups.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():DisplayObject</pre>
	 *
	 * <p>In the following example, the overlay factory is changed:</p>
	 *
	 * <listing version="3.0">
	 * PopUpManager.overlayFactory = function():DisplayObject
	 * {
	 *     var overlay:Quad = new Quad( 100, 100, 0x000000 );
	 *     overlay.alpha = 0.75;
	 *     return overlay;
	 * };</listing>
	 */
	public static var overlayFactory(get, set):Void->DisplayObject;
	private static function get_overlayFactory():Void->DisplayObject
	{
		return PopUpManager.forStarling(Starling.current).overlayFactory;
	}
	private static function set_overlayFactory(value:Void->DisplayObject):Void->DisplayObject
	{
		return PopUpManager.forStarling(Starling.current).overlayFactory = value;
	}
	
	/**
	 * The default factory that creates overlays for modal pop-ups. Creates
	 * an invisible <code>Quad</code>.
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/Quad.html starling.display.Quad
	 */
	public static function defaultOverlayFactory():DisplayObject
	{
		return DefaultPopUpManager.defaultOverlayFactory();
	}
	
	/**
	 * The container where pop-ups are added. If not set manually, defaults
	 * to the Starling stage.
	 *
	 * <p>In the following example, the next tab focus is changed:</p>
	 *
	 * <listing version="3.0">
	 * PopUpManager.root = someSprite;</listing>
	 *
	 * @default null
	 */
	public static var root(get, set):DisplayObjectContainer;
	private static function get_root():DisplayObjectContainer
	{
		return PopUpManager.forStarling(Starling.current).root;
	}
	private static function set_root(value:DisplayObjectContainer):DisplayObjectContainer
	{
		return PopUpManager.forStarling(Starling.current).root = value;
	}
	
	/**
	 * The current number of pop-ups.
	 *
	 * <p>In the following example, we check the number of pop-ups:</p>
	 *
	 * <listing version="3.0">
	 * if( PopUpManager.popUpCount > 0 )
	 * {
	 *     // do something
	 * }</listing>
	 */
	public static var popUpCount(get, never):Int;
	private static function get_popUpCount():Int
	{
		return PopUpManager.forStarling(Starling.current).popUpCount;
	}
	
	/**
	 * Adds a pop-up to the stage.
	 *
	 * <p>The pop-up may be modal, meaning that an overlay will be displayed
	 * between the pop-up and everything under the pop-up manager, and the
	 * overlay will block touches. The default overlay used for modal
	 * pop-ups is created by <code>PopUpManager.overlayFactory</code>. A
	 * custom overlay factory may be passed to <code>PopUpManager.addPopUp()</code>
	 * to create an overlay that is different from the default one.</p>
	 *
	 * <p>A pop-up may be centered globally on the Starling stage. If the
	 * stage or the pop-up resizes, the pop-up will be repositioned to
	 * remain in the center. To position a pop-up in the center once,
	 * specify a value of <code>false</code> when calling
	 * <code>PopUpManager.addPopUp()</code> and call
	 * <code>PopUpManager.centerPopUp()</code> manually.</p>
	 *
	 * <p>Note: The pop-up manager can only detect if Feathers components
	 * have been resized in order to reposition them to remain centered.
	 * Regular Starling display objects do not dispatch a proper resize
	 * event that the pop-up manager can listen to.</p>
	 */
	public static function addPopUp(popUp:DisplayObject, isModal:Bool = true, isCentered:Bool = true, customOverlayFactory:Void->DisplayObject = null):DisplayObject
	{
		return PopUpManager.forStarling(Starling.current).addPopUp(popUp, isModal, isCentered, customOverlayFactory);
	}
	
	/**
	 * Removes a pop-up from the stage.
	 */
	public static function removePopUp(popUp:DisplayObject, dispose:Bool = false):DisplayObject
	{
		return PopUpManager.forStarling(Starling.current).removePopUp(popUp, dispose);
	}
	
	/**
	 * Removes all pop-ups from the stage.
	 */
	public static function removeAllPopUps(dispose:Bool = false):Void
	{
		PopUpManager.forStarling(Starling.current).removeAllPopUps(dispose);
	}
	
	/**
	 * Determines if a display object is a pop-up.
	 *
	 * <p>In the following example, we check if a display object is a pop-up:</p>
	 *
	 * <listing version="3.0">
	 * if( PopUpManager.isPopUp( displayObject ) )
	 * {
	 *     // do something
	 * }</listing>
	 */
	public static function isPopUp(popUp:DisplayObject):Bool
	{
		return PopUpManager.forStarling(Starling.current).isPopUp(popUp);
	}
	
	/**
	 * Determines if a display object is above the highest modal overlay. If
	 * there are no modals overlays, determines if a display object is a
	 * pop-up.
	 */
	public static function isTopLevelPopUp(popUp:DisplayObject):Bool
	{
		return PopUpManager.forStarling(Starling.current).isTopLevelPopUp(popUp);
	}
	
	/**
	 * Centers a pop-up on the stage. Unlike the <code>isCentered</code>
	 * argument passed to <code>PopUpManager.addPopUp()</code>, the pop-up
	 * will only be positioned once. If the stage or the pop-up resizes,
	 * <code>PopUpManager.centerPopUp()</code> will need to be called again
	 * if it should remain centered.
	 *
	 * <p>In the following example, we center a pop-up:</p>
	 *
	 * <listing version="3.0">
	 * PopUpManager.centerPopUp( displayObject );</listing>
	 */
	public static function centerPopUp(popUp:DisplayObject):Void
	{
		PopUpManager.forStarling(Starling.current).centerPopUp(popUp);
	}
	
}