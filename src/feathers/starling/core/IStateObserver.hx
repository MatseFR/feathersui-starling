/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.core;

/**
 * @author Matse
 */
interface IStateObserver 
{
	/**
	 * The current state context that is being observed.
	 */
	public var stateContext(get, set):IStateContext;
}