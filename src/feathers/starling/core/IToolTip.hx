/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;

/**
 * An interface for tool tips created by the tool tip manager.
 *
 * @see ../../../help/tool-tips.html Tool tips in Feathers
 * @see feathers.core.ToolTipManager
 *
 * @productversion Feathers 3.0.0
 */
interface IToolTip extends IFeathersControl
{
	public var text(get, set):String;
}