/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

/**
 * Deceleration rate, per millisecond.
 *
 * @productversion Feathers 3.0.0
 */
class DecelerationRate 
{
	/**
	 * The default deceleration rate per millisecond.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var NORMAL:Float = 0.998;

	/**
	 * Decelerates a bit faster than the normal amount.
	 *
	 * @see #NORMAL
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var FAST:Float = 0.99;
}