package feathers.starling.examples.componentsExplorer.data;
import openfl.utils.Assets;
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class EmbeddedAssets 
{
	public static var SKULL_ICON_DARK:Texture;
	
	public static var SKULL_ICON_LIGHT:Texture;
	
	public static function initialize():Void
	{
		//we can't create these textures until Starling is ready
		SKULL_ICON_DARK = Texture.fromBitmapData(Assets.getBitmapData("assets/images/skull.png"), false, false, 2);
		SKULL_ICON_LIGHT = Texture.fromBitmapData(Assets.getBitmapData("assets/images/skull-white.png"), false, false, 2);
	}
}