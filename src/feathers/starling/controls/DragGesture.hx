/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

/**
 * Gestures used to drag content.
 */
class DragGesture 
{

	/**
	 * The target may be dragged in the appropriate direction from any
	 * location within its bounds.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var CONTENT:String = "content";

	/**
	 * The target may be dragged in the appropriate direction starting from
	 * near the target's edge.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var EDGE:String = "edge";

	/**
	 * No gesture can be used to drag the target.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var NONE:String = "none";
	
}