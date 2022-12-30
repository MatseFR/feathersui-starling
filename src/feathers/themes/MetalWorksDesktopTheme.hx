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
package feathers.themes;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * The "Metal Works" theme for desktop Feathers apps.
 *
 * <p>This version of the theme embeds its assets. To load assets at
 * runtime, see <code>MetalWorksDesktopThemeWithAssetManager</code> instead.</p>
 *
 * @see http://feathersui.com/help/theme-assets.html
 */
class MetalWorksDesktopTheme extends BaseMetalWorksDesktopTheme 
{
	private static inline var ATLAS_XML:String = "assets/img/metalworks_desktop.xml";
	
	private static inline var ATLAS_BITMAP:String = "assets/img/metalworks_desktop.png";
	
	/**
	 * @private
	 */
	private static inline var ATLAS_SCALE_FACTOR:Int = 2;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.initialize();
	}
	
	override function initialize():Void 
	{
		this.initializeTextureAtlas();
		super.initialize();
	}
	
	/**
	 * @private
	 */
	private function initializeTextureAtlas():Void
	{
		//atlas = new TextureAtlas(Texture.fromBitmapData(Assets.getBitmapData(Config.PATH_IMAGE + "hex/hex_types.png")),
		//Xml.parse(Assets.getText(Config.PATH_IMAGE + "hex/hex_types.xml")));
		var atlasBitmapData:BitmapData = Assets.getBitmapData(ATLAS_BITMAP);
		var atlasTexture:Texture = Texture.fromBitmapData(atlasBitmapData, false, false, ATLAS_SCALE_FACTOR);
		atlasTexture.root.onRestore = this.atlasTexture_onRestore;
		atlasBitmapData.dispose();
		this.atlas = new TextureAtlas(atlasTexture, Xml.parse(Assets.getText(ATLAS_XML)));
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