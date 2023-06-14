/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;
import feathers.starling.core.IFeathersControl;

/**
 * A UI component that displays a range of values from a minimum to a maximum.
 *
 * @productversion Feathers 1.3.0
 */
interface IRange extends IFeathersControl
{
	/**
	 * The minimum numeric value of the range.
	 *
	 * <p>In the following example, the minimum is changed to 0:</p>
	 *
	 * <listing version="3.0">
	 * component.minimum = 0;
	 * component.maximum = 100;
	 * component.step = 1;
	 * component.page = 10
	 * component.value = 12;</listing>
	 */
	public var minimum(get, set):Float;
	
	/**
	 * The maximum numeric value of the range.
	 *
	 * <p>In the following example, the maximum is changed to 100:</p>
	 *
	 * <listing version="3.0">
	 * component.minimum = 0;
	 * component.maximum = 100;
	 * component.step = 1;
	 * component.page = 10
	 * component.value = 12;</listing>
	 */
	public var maximum(get, set):Float;
	
	/**
	 * The current numeric value.
	 *
	 * <p>In the following example, the value is changed to 12:</p>
	 *
	 * <listing version="3.0">
	 * component.minimum = 0;
	 * component.maximum = 100;
	 * component.step = 1;
	 * component.page = 10
	 * component.value = 12;</listing>
	 */
	public var value(get, set):Float;
	
	/**
	 * The amount the value must change to increment or decrement.
	 *
	 * <p>In the following example, the step is changed to 1:</p>
	 *
	 * <listing version="3.0">
	 * component.minimum = 0;
	 * component.maximum = 100;
	 * component.step = 1;
	 * component.page = 10
	 * component.value = 12;</listing>
	 */
	public var step(get, set):Float;
}