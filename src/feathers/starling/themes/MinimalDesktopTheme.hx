/*
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package feathers.starling.themes;
import feathers.starling.themes.BaseMinimalDesktopTheme;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * The "Minimal" theme for desktop Feathers apps.
 *
 * <p>This version of the theme embeds its assets. To load assets at
 * runtime, see <code>MinimalDesktopThemeWithAssetManager</code> instead.</p>
 *
 * @see http://feathersui.com/help/theme-assets.html
 */
class MinimalDesktopTheme extends BaseMinimalDesktopTheme 
{
	private static inline var ATLAS_XML:String = "assets/img/minimal_desktop.xml";
	
	private static inline var ATLAS_BITMAP:String = "assets/img/minimal_desktop.png";
	
	private static inline var FONT_XML:String = "assets/fonts/pf_ronda_seven_desktop.fnt";
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.initialize();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		this.initializeTextureAtlas();
		this.initializeBitmapFont();
		super.initialize();
	}
	
	/**
	 * @private
	 */
	private function initializeTextureAtlas():Void
	{
		var atlasBitmapData:BitmapData = Assets.getBitmapData(ATLAS_BITMAP);
		var atlasTexture:Texture = Texture.fromBitmapData(atlasBitmapData, false, false, BaseMinimalDesktopTheme.ATLAS_SCALE_FACTOR);
		atlasTexture.root.onRestore = this.atlasTexture_onRestore;
		atlasBitmapData.dispose();
		this.atlas = new TextureAtlas(atlasTexture,  Xml.parse(Assets.getText(ATLAS_XML)));
	}
	
	/**
	 * @private
	 */
	private function initializeBitmapFont():Void
	{
		var bitmapFont:BitmapFont = new BitmapFont(this.atlas.getTexture(BaseMinimalDesktopTheme.FONT_TEXTURE_NAME), Xml.parse(Assets.getText(FONT_XML)));
		TextField.registerCompositor(bitmapFont, BaseMinimalDesktopTheme.FONT_NAME);
	}
	
	/**
	 * @private
	 */
	private function atlasTexture_onRestore(texture:ConcreteTexture):Void
	{
		var atlasBitmapData:BitmapData = Assets.getBitmapData(ATLAS_BITMAP);
		this.atlas.texture.root.uploadBitmapData(atlasBitmapData);
		atlasBitmapData.dispose();
	}
}