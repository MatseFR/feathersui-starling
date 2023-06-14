/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.text;

/**
 * The result of text measurement.
 *
 * @productversion Feathers 3.0.0
 */
class MeasureTextResult 
{
	/**
	   Constructor.
	**/
	public function new(width:Float = 0, height:Float = 0, isTruncated:Bool = false) 
	{
		this.width = width;
		this.height = height;
		this.isTruncated = isTruncated;
	}
	
	/**
	 * The measured width of the text.
	 */
	public var width:Float;
	
	/**
	 * The measured height of the text.
	 */
	public var height:Float;
	
	/**
	 * Indicates if the text needed to be truncated.
	 */
	public var isTruncated:Bool;
	
}