/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

/**
 * Constants that determine how a component should automatically calculate
 * its own dimensions when no explicit dimensions are provided.
 *
 * @productversion Feathers 3.0.0
 */
class AutoSizeMode 
{
	/**
	 * The component will automatically calculate its dimensions to fill the
	 * entire stage.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var STAGE:String = "stage";
	
	/**
	 * The component will automatically calculate its dimensions to fit its
	 * content's ideal dimensions.
	 *
	 * @productversion Feathers 3.0.0
	 */
	public static inline var CONTENT:String = "content";
	
}