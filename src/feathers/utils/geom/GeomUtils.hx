/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.geom;
import openfl.geom.Matrix;

/**
 * ...
 * @author Matse
 */
class GeomUtils 
{
	
	/**
	 * Extracts the rotation value (in radians) from a <code>flash.geom.Matrix</code>
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/geom/Matrix.html flash.geom.Matrix
	 *
	 * @productversion Feathers 1.2.0
	 */
	static public inline function matrixToRotation(matrix:Matrix):Float
	{
		var c:Float = matrix.c;
		var d:Float = matrix.d;
		return -Math.atan(c / d);
	}
	
	/**
	 * Extracts the x scale value from a <code>flash.geom.Matrix</code>
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/geom/Matrix.html flash.geom.Matrix
	 *
	 * @productversion Feathers 1.2.0
	 */
	static public inline function matrixToScaleX(matrix:Matrix):Float
	{
		var a:Float = matrix.a;
		var b:Float = matrix.b;
		return Math.sqrt(a * a + b * b);
	}
	
	/**
	 * Extracts the y scale value from a <code>flash.geom.Matrix</code>
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/geom/Matrix.html flash.geom.Matrix
	 *
	 * @productversion Feathers 1.2.0
	 */
	static public inline function matrixToScaleY(matrix:Matrix):Float
	{
		var c:Float = matrix.c;
		var d:Float = matrix.d;
		return Math.sqrt(c * c + d * d);
	}
	
}