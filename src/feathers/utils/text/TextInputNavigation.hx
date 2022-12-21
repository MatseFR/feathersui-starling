/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.text;
import feathers.utils.ReverseIterator;

/**
 * Functions for navigating text inputs with the keyboard.
 *
 * @productversion Feathers 2.0.0
 */
class TextInputNavigation 
{
	/**
	 * @private
	 */
	private static var IS_WORD:EReg = ~/\w/;

	/**
	 * @private
	 */
	private static var IS_WHITESPACE:EReg = ~/\s/;
	
	/**
	 * Finds the start index of the word that starts before the selection.
	 */
	public static function findPreviousWordStartIndex(text:String, selectionStartIndex:Int):Int
	{
		if (selectionStartIndex <= 0)
		{
			return 0;
		}
		var nextCharIsWord:Bool = IS_WORD.match(text.charAt(selectionStartIndex - 1));
		//for(var i:int = selectionStartIndex - 2; i >= 0; i--)
		for (i in new ReverseIterator(selectionStartIndex - 2, 0))
		{
			var charIsWord:Bool = IS_WORD.match(text.charAt(i));
			if (!charIsWord && nextCharIsWord)
			{
				return i + 1;
			}
			nextCharIsWord = charIsWord;
		}
		return 0;
	}
	
	/**
	 * Finds the start index of the word that starts with the current
	 * selection. If the current selection is in the whitespace between
	 * words, returns the start index of the previous word.
	 */
	public static function findCurrentWordStartIndex(text:String, selectionStartIndex:Int):Int
	{
		if (selectionStartIndex <= 0)
		{
			return 0;
		}
		var nextCharIsWord:Bool = IS_WORD.match(text.charAt(selectionStartIndex + 1));
		//for(var i:int = selectionStartIndex; i >= 0; i--)
		for (i in new ReverseIterator(selectionStartIndex, 0))
		{
			var charIsWord:Bool = IS_WORD.match(text.charAt(i));
			if (!charIsWord && i == selectionStartIndex)
			{
				//this is whitespace between words
				return findPreviousWordStartIndex(text, selectionStartIndex);
			}
			if (!charIsWord && nextCharIsWord)
			{
				return i + 1;
			}
			nextCharIsWord = charIsWord;
		}
		return 0;
	}
	
	/**
	 * Finds the end index of the word that starts with the current
	 * selection. If the current selection is in the whitespace between
	 * words, returns the end index of the next word.
	 */
	public static function findCurrentWordEndIndex(text:String, selectionEndIndex:Int):Int
	{
		var textLength:Int = text.length;
		if (selectionEndIndex >= textLength - 1)
		{
			return textLength;
		}
		//for(var i:int = selectionEndIndex; i < textLength; i++)
		for (i in selectionEndIndex...textLength)
		{
			var charIsWord:Bool = IS_WORD.match(text.charAt(i));
			if (!charIsWord && i == selectionEndIndex)
			{
				//this is whitespace between words
				var nextStart:Int = findNextWordStartIndex(text, selectionEndIndex);
				return findCurrentWordEndIndex(text, nextStart);
			}
			if (!charIsWord)
			{
				return i;
			}
		}
		return textLength;
	}
	
	/**
	 * Finds the start index of the next word that starts after the
	 * selection.
	 */
	public static function findNextWordStartIndex(text:String, selectionEndIndex:Int):Int
	{
		var textLength:Int = text.length;
		if (selectionEndIndex >= textLength - 1)
		{
			return textLength;
		}
		//the first character is a special case. any non-whitespace is
		//considered part of the word.
		var prevCharIsWord:Bool = !IS_WHITESPACE.match(text.charAt(selectionEndIndex));
		//for(var i:int = selectionEndIndex + 1; i < textLength; i++)
		for (i in selectionEndIndex + 1...textLength)
		{
			var charIsWord:Bool = IS_WORD.match(text.charAt(i));
			if (charIsWord && !prevCharIsWord)
			{
				return i;
			}
			prevCharIsWord = charIsWord;
		}
		return textLength;
	}
	
}