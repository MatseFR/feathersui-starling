/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;

/**
 * @private
 * A text editor that is compatible with <code>TextEditorIMEClient</code>.
 *
 * @see feathers.utils.text.TextEditorIMEClient
 *
 * @productversion Feathers 3.0.0
 */
interface IIMETextEditor 
{
	public var selectionAnchorIndex(get, set):Int;
}