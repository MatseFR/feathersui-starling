/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.text;
import feathers.starling.controls.supportClasses.IViewPort;
import feathers.starling.core.ITextEditor;

/**
 * Handles the editing of multiline text.
 *
 * @see feathers.controls.TextArea
 *
 * @productversion Feathers 1.1.0
 */
interface ITextEditorViewPort extends ITextEditor extends IViewPort
{
	/**
	 * The padding between the top edge of the viewport and the text.
	 */
	public var paddingTop(get, set):Float;
	
	/**
	 * The padding between the right edge of the viewport and the text.
	 */
	public var paddingRight(get, set):Float;
	
	/**
	 * The padding between the bottom edge of the viewport and the text.
	 */
	public var paddingBottom(get, set):Float;
	
	/**
	 * The padding between the left edge of the viewport and the text.
	 */
	public var paddingLeft(get, set):Float;
}