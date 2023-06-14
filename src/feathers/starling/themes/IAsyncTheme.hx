/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.themes;
import feathers.starling.core.IFeathersEventDispatcher;
import starling.core.Starling;

/**
 * A theme that uses an asynchronous loading mechanism (such as the Starling
 * <code>AssetManager</code>), during initialization to load textures and
 * other assets. This type of theme may not be ready to style components
 * immediately, and it will dispatch <code>Event.COMPLETE</code> once the
 * it has fully initialized. Attempting to create Feathers components before
 * the theme has dispatched <code>Event.COMPLETE</code> may result in no
 * skins or even runtime errors.
 *
 * @productversion Feathers 2.3.0
 */
interface IAsyncTheme extends IFeathersEventDispatcher
{
	/**
	 * Indicates if the assets have been loaded and the theme has been
	 * initialized for a specific Starling instance.
	 *
	 * @see #event:complete starling.events.Event.COMPLETE
	 */
	function isCompleteForStarling(starling:Starling):Bool;
}