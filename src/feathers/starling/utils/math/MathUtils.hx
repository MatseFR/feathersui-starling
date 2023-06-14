/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.utils.math;
import openfl.errors.ArgumentError;

class MathUtils 
{
	public static inline var FLOAT_MAX:Float = 999999999;
	public static inline var FLOAT_MIN:Float = -999999999;
	public static inline var INT_MAX:Int = 999999999;
	public static inline var INT_MIN:Int = -999999999;
	
	/**
	 * Forces a numeric value into a specified range.
	 *
	 * @param value		The value to force into the range.
	 * @param minimum	The minimum bound of the range.
	 * @param maximum	The maximum bound of the range.
	 * @return			A value within the specified range.
	 *
	 * @productversion Feathers 1.0.0
	 */
	public static inline function clamp(value:Float, minimum:Float, maximum:Float):Float
	{
		if (minimum > maximum)
		{
			throw new ArgumentError("minimum should be smaller than maximum.");
		}
		if (value < minimum)
		{
			value = minimum;
		}
		else if (value > maximum)
		{
			value = maximum;
		}
		return value;
	}
	
	/**
	 * Rounds a Number <em>down</em> to the nearest multiple of an input. For example, by rounding
	 * 16 down to the nearest 10, you will receive 10. Similar to the built-in function Math.floor().
	 *
	 * @param	numberToRound		the number to round down
	 * @param	nearest				the number whose mutiple must be found
	 * @return	the rounded number
	 *
	 * @see Math#floor
	 *
	 * @productversion Feathers 1.0.0
	 */
	public static inline function roundDownToNearest(number:Float, nearest:Float = 1):Float
	{
		if (nearest == 0)
		{
			return number;
		}
		return Math.ffloor(roundToPrecision(number / nearest, 10)) * nearest;
	}
	
	/**
	 * Rounds a Number to the nearest multiple of an input. For example, by rounding
	 * 16 to the nearest 10, you will receive 20. Similar to the built-in function Math.round().
	 *
	 * @param	numberToRound		the number to round
	 * @param	nearest				the number whose mutiple must be found
	 * @return	the rounded number
	 *
	 * @see Math#round
	 *
	 * @productversion Feathers 1.0.0
	 */
	public static inline function roundToNearest(number:Float, nearest:Float = 1):Float
	{
		if (nearest == 0)
		{
			return number;
		}
		var roundedNumber:Float = Math.fround(roundToPrecision(number / nearest, 10)) * nearest;
		return roundToPrecision(roundedNumber, 10);
	}
	
	/**
	 * Rounds a number to a certain level of precision. Useful for limiting the number of
	 * decimal places on a fractional number.
	 *
	 * @param		number		the input number to round.
	 * @param		precision	the number of decimal digits to keep
	 * @return		the rounded number, or the original input if no rounding is needed
	 *
	 * @see Math#round
	 *
	 * @productversion Feathers 1.0.0
	 */
	public static inline function roundToPrecision(number:Float, precision:Int = 0):Float
	{
		var decimalPlaces:Float = Math.pow(10, precision);
		return Math.fround(decimalPlaces * number) / decimalPlaces;
	}
	
	/**
	 * Rounds a Number <em>up</em> to the nearest multiple of an input. For example, by rounding
	 * 16 up to the nearest 10, you will receive 20. Similar to the built-in function Math.ceil().
	 *
	 * @param	numberToRound		the number to round up
	 * @param	nearest				the number whose mutiple must be found
	 * @return	the rounded number
	 *
	 * @see Math#ceil
	 *
	 * @productversion Feathers 1.0.0
	 */
	public static inline function roundUpToNearest(number:Float, nearest:Float = 1):Float
	{
		if (nearest == 0)
		{
			return number;
		}
		return Math.fceil(roundToPrecision(number / nearest, 10)) * nearest;
	}
}