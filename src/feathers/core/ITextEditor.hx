/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import feathers.text.FontStylesSet;
import openfl.geom.Point;
import src.feathers.core.IFeathersControl;

/**
 * Handles the editing of text.
 *
 * @see feathers.controls.TextInput
 * @see ../../../help/text-editors.html Introduction to Feathers text editors
 *
 * @productversion Feathers 1.0.0
 */
interface ITextEditor extends IFeathersControl extends ITextBaselineControl
{
	/**
	 * The text displayed by the editor.
	 */
	public var text(get, set):String;
	
	/**
	 * Determines if the entered text will be masked so that it cannot be
	 * seen, such as for a password input.
	 */
	public var displayAsPassword(get, set):Bool;
	
	/**
	 * The maximum number of characters that may be entered.
	 */
	public var maxChars(get, set):Int;
	
	/**
	 * Limits the set of characters that may be entered.
	 */
	public var restrict(get, set):String;
	
	/**
	 * Determines if the text is editable.
	 *
	 * @see #isSelectable
	 */
	public var isEditable(get, set):Bool;
	
	/**
	 * If the <code>isEditable</code> property is set to <code>false</code>,
	 * the <code>isSelectable</code> property determines if the text is
	 * selectable. If the <code>isEditable</code> property is set to
	 * <code>true</code>, the text will always be selectable.
	 *
	 * @see #isEditable
	 */
	public var isSelectable(get, set):Bool;
	
	/**
	 * Determines if the owner should call <code>setFocus()</code> on
	 * <code>TouchPhase.ENDED</code> or on <code>TouchPhase.BEGAN</code>.
	 * This is a hack because <code>StageText</code> doesn't like being
	 * assigned focus on <code>TouchPhase.BEGAN</code>. In general, most
	 * text editors should simply return <code>false</code>.
	 *
	 * @see #setFocus()
	 */
	public var setTouchFocusOnEndedPhase(get, never):Bool;
	
	/**
	 * The index of the first character of the selection. If no text is
	 * selected, then this is the value of the caret index. This value will
	 * always be smaller than <code>selectionEndIndex</code>.
	 *
	 * @see #selectionEndIndex
	 */
	public var selectionBeginIndex(get, never):Int;
	
	/**
	 * The index of the last character of the selection. If no text is
	 * selected, then this is the value of the caret index. This value will
	 * always be larger than <code>selectionBeginIndex</code>.
	 *
	 * @see #selectionBeginIndex
	 */
	public var selectionEndIndex(get, never):Int;
	
	/**
	 * The internal font styles used to render the text that are passed down
	 * from the parent component. Generally, most developers will set font
	 * styles on the parent component.
	 *
	 * <p>Warning: The <code>fontStyles</code> property may be ignored if
	 * more advanced styles defined by the text renderer implementation have
	 * been set.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 */
	public var fontStyles(get, set):FontStylesSet;
	
	/**
	 * Gives focus to the text editor. Includes an optional position which
	 * may be used by the text editor to determine the cursor position. The
	 * position may be outside of the editors bounds.
	 */
	function setFocus(position:Point = null):Void;
	
	/**
	 * Removes focus from the text editor.
	 */
	function clearFocus():Void;
	
	/**
	 * Sets the range of selected characters. If both values are the same,
	 * the text insertion position is changed and nothing is selected.
	 */
	function selectRange(startIndex:Int, endIndex:Int):Void;
	
	/**
	 * Measures the text's bounds (without a full validation, if
	 * possible).
	 */
	function measureText(result:Point = null):Point;
	
}