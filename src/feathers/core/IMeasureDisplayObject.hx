/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;

/**
 * A display object with extra measurement properties.
 *
 * @productversion Feathers 3.0.0
 */
interface IMeasureDisplayObject 
{
	/**
	 * @copy feathers.core.FeathersControl#explicitWidth
	 */
	public var explicitWidth(get, never):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#explicitMinWidth
	 */
	public var explicitMinWidth(get, never):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#minWidth
	 */
	public var minWidth(get, set):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#explicitMaxWidth
	 */
	public var explicitMaxWidth(get, never):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#maxWidth
	 */
	public var maxWidth(get, set):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#explicitHeight
	 */
	public var explicitHeight(get, never):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#explicitMinHeight
	 */
	public var explicitMinHeight(get, never):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#minHeight
	 */
	public var minHeight(get, set):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#explicitMaxHeight
	 */
	public var explicitMaxHeight(get, never):Float;
	
	/**
	 * @copy feathers.core.FeathersControl#maxHeight
	 */
	public var maxHeight(get, set):Float;
}