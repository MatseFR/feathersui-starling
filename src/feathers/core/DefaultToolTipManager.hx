/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;

/**
 * The default <code>IToolTipManager</code> implementation.
 *
 * @see ../../../help/tool-tips.html Tool tips in Feathers
 * @see feathers.core.ToolTipManager
 *
 * @productversion Feathers 3.0.0
 */
class DefaultToolTipManager 
{
	/**
	 * The default factory that creates a tool tip. Creates a
	 * <code>Label</code> with the style name
	 * <code>Label.ALTERNATE_STYLE_NAME_TOOL_TIP</code>.
	 *
	 * @see #toolTipFactory
	 * @see feathers.controls.Label
	 * @see feathers.controls.Label#ALTERNATE_STYLE_NAME_TOOL_TIP
	 */
	public static function defaultToolTipFactory():IToolTip
	{
		var toolTip:Label = new Label();
		toolTip.styleNameList.add(Label.ALTERNATE_STYLE_NAME_TOOL_TIP);
		return toolTip;
	}
	
	public function new() 
	{
		
	}
	
}