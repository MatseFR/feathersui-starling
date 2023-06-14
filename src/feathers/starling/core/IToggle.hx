/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;
import feathers.starling.core.IFeathersControl;

/**
 * An interface for something that may be selected.
 *
 * @productversion Feathers 1.0.0
 */
interface IToggle extends IFeathersControl
{
	/**
	 * Indicates if the IToggle is selected or not.
	 */
	public var isSelected(get, set):Bool;
}