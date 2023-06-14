package feathers.starling.themes;
import feathers.starling.themes.BaseMinimalMobileTheme;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * ...
 * @author Matse
 */
class MinimalMobileTheme extends BaseMinimalMobileTheme 
{
	private static inline var ATLAS_XML:String = "assets/img/minimal_mobile.xml";
	
	private static inline var ATLAS_BITMAP:String = "assets/img/minimal_mobile.png";
	
	private static inline var FONT_XML:String = "assets/fonts/pf_ronda_seven.fnt";
	
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
		var atlasTexture:Texture = Texture.fromBitmapData(atlasBitmapData, false, false, 2);
		atlasTexture.root.onRestore = this.atlasTexture_onRestore;
		atlasBitmapData.dispose();
		this.atlas = new TextureAtlas(atlasTexture, Xml.parse(Assets.getText(ATLAS_XML)));
	}
	
	/**
	 * @private
	 */
	private function initializeBitmapFont():Void
	{
		var bitmapFont:BitmapFont = new BitmapFont(this.atlas.getTexture(BaseMinimalMobileTheme.FONT_TEXTURE_NAME), Xml.parse(Assets.getText(FONT_XML)));
		TextField.registerCompositor(bitmapFont, BaseMinimalMobileTheme.FONT_NAME);
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