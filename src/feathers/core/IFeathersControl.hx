/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package src.feathers.core;
import feathers.core.TokenList;
import feathers.skins.IStyleProvider;

/**
 * Basic interface for Feathers UI controls. A Feathers control must also
 * be a Starling display object.
 *
 * @productversion Feathers 1.0.0
 */
interface IFeathersControl 
{
	
	/**
	 * @copy feathers.core.FeathersControl#isEnabled
	 */
	public var isEnabled(get, set):Bool;
	
	/**
	 * @copy feathers.core.FeathersControl#isInitialized
	 */
	public var isInitialized(get, never):Bool;
	
	/**
	 * @copy feathers.core.FeathersControl#isCreated
	 */
	public var isCreated(get, never):Bool;
	
	/**
	 * @copy feathers.core.FeathersControl#styleNameList
	 */
	public var styleNameList(get, never):TokenList
	
	/**
	 * @copy feathers.core.FeathersControl#styleName
	 */
	public var styleName(get, set):String;
	
	/**
	 * @copy feathers.core.FeathersControl#styleProvider
	 */
	public var styleProvider(get, set):IStyleProvider;
	
	/**
	 * @copy feathers.core.FeathersControl#toolTip
	 */
	public var toolTip(get, set):String;
	
	/**
	 * @copy feathers.core.FeathersControl#effectsSuspended
	 */
	public var effectsSuspended(get, never):Bool;
	
	/**
	 * @copy feathers.core.FeathersControl#setSize()
	 */
	function setSize(width:Float, height:Float):Void;
	
	/**
	 * @copy feathers.core.FeathersControl#move()
	 */
	function move(x:Float, y:Float):Void;
	
	/**
	 * @copy feathers.core.FeathersControl#resetStyleProvider()
	 */
	function resetStyleProvider():Void;
	
	/**
	 * @copy feathers.core.FeathersControl#initializeNow()
	 */
	function initializeNow():Void;
	
	/**
	 * @copy feathers.core.FeathersControl#suspendEffects()
	 */
	function suspendEffects():Void;
	
	/**
	 * @copy feathers.core.FeathersControl#resumeEffects()
	 */
	function resumeEffects():Void;
}