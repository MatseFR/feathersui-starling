/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.text;
import openfl.errors.ArgumentError;
import openfl.text.TextFormatAlign;
import starling.text.BitmapFont;
import starling.text.TextField;

/**
 * Customizes a bitmap font for use by a <code>BitmapFontTextRenderer</code>.
 *
 * @see feathers.controls.text.BitmapFontTextRenderer
 *
 * @productversion Feathers 1.0.0
 */
class BitmapFontTextFormat 
{
	/**
	   Constructor.
	**/
	public function new(font:Dynamic, size:Null<Float> = null, color:Int = 0xffffff, align:String = null, leading:Float = 0) 
	{
		if (size == null) size = Math.NaN;
		if (align == null) align = TextFormatAlign.LEFT;
		
		if (Std.isOfType(font, String))
		{
			font = TextField.getBitmapFont(font);
		}
		if (!Std.isOfType(font, BitmapFont))
		{
			throw new ArgumentError("BitmapFontTextFormat font must be a BitmapFont instance or a String representing the name of a registered bitmap font.");
		}
		this.font = cast font;
		this.size = size;
		this.color = color;
		this.align = align;
		this.leading = leading;
	}
	
	/**
	 * The name of the font.
	 */
	public var fontName(get, never):String;
	private function get_fontName():String { return this.font != null ? this.font.name : null; }
	
	/**
	 * The BitmapFont instance to use.
	 */
	public var font:BitmapFont;
	
	/**
	 * The color used to tint the bitmap font's texture when rendered.
	 * Tinting works like the "multiply" blend mode. In other words, the
	 * <code>color</code> property can only make the text render with a
	 * darker color. With that in mind, if the characters in the original
	 * texture are black, then you cannot change their color at all. To be
	 * able to render the text using any color, the characters in the
	 * original texture should be white.
	 *
	 * @default 0xffffff
	 *
	 * @see http://doc.starling-framework.org/core/starling/display/BlendMode.html#MULTIPLY starling.display.BlendMode.MULTIPLY
	 */
	public var color:Int;
	
	/**
	 * The size at which to display the bitmap font. Set to <code>Math.NaN</code>
	 * to use the default size in the BitmapFont instance.
	 *
	 * @default NaN
	 */
	public var size:Float;
	
	/**
	 * The number of extra pixels between characters. May be positive or
	 * negative.
	 *
	 * @default 0
	 */
	public var letterSpacing:Float = 0;
	
	/**
	 * Determines the alignment of the text, either left, center, or right.
	 *
	 * @default openfl.text.TextFormatAlign.LEFT
	 */
	public var align:String = TextFormatAlign.LEFT;
	
	/**
	 * A number representing the amount of vertical space (called leading)
	 * between lines. The total vertical distance between lines is this
	 * value added to the BitmapFont instance's lineHeight property.
	 *
	 * @default 0
	 */
	public var leading:Float;
	
	/**
	 * Determines if the kerning values defined in the BitmapFont instance
	 * will be used for layout.
	 *
	 * @default true
	 */
	public var isKerningEnabled:Bool = true;
	
}