package feathers.examples.magic8.themes;

import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.themes.MetalWorksMobileTheme;
import openfl.utils.Assets;
import starling.display.Image;
import starling.textures.Texture;

class Magic8ChatTheme extends MetalWorksMobileTheme 
{
	private static inline var EIGHT_BALL_ICON:String = "assets/img/8ball@2x.png";
	private static inline var QUESTION_ICON:String = "assets/img/question@2x.png";
	
	private static inline var THEME_STYLE_NAME_MESSAGE_ITEM_RENDERER_LABEL:String = "magic8Ball-message-item-renderer-label";
	
	public function new() 
	{
		super();
	}
	
	private var eightBallTexture:Texture;
	private var questionTexture:Texture;
	
	override function initializeTextures():Void
	{
		super.initializeTextures();
		this.eightBallTexture = Texture.fromBitmapData(Assets.getBitmapData(EIGHT_BALL_ICON), false, false, 2);
		this.questionTexture = Texture.fromBitmapData(Assets.getBitmapData(QUESTION_ICON), false, false, 2);
	}
	
	override function initializeStyleProviders():Void
	{
		super.initializeStyleProviders();
		this.getStyleProviderForClass(DefaultListItemRenderer)
			.setFunctionForStyleName(StyleNames.USER_MESSAGE_ITEM_RENDERER, this.setUserMessageItemRendererStyles);
		this.getStyleProviderForClass(DefaultListItemRenderer)
			.setFunctionForStyleName(StyleNames.EIGHT_BALL_MESSAGE_ITEM_RENDERER, this.setEightBallMessageItemRendererStyles);
		this.getStyleProviderForClass(TextFieldTextRenderer)
			.setFunctionForStyleName(THEME_STYLE_NAME_MESSAGE_ITEM_RENDERER_LABEL, this.setMessageItemRendererLabelStyles);
	}
	
	private function setUserMessageItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.customLabelStyleName = THEME_STYLE_NAME_MESSAGE_ITEM_RENDERER_LABEL;
		
		itemRenderer.horizontalAlign = HorizontalAlign.RIGHT;
		itemRenderer.iconPosition = RelativePosition.RIGHT;
		
		itemRenderer.itemHasIcon = false;
		itemRenderer.defaultIcon = new Image(this.questionTexture);
	}

	private function setEightBallMessageItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.customLabelStyleName = THEME_STYLE_NAME_MESSAGE_ITEM_RENDERER_LABEL;
		
		itemRenderer.itemHasIcon = false;
		itemRenderer.defaultIcon = new Image(this.eightBallTexture);
	}

	private function setMessageItemRendererLabelStyles(text:TextFieldTextRenderer):Void
	{
		text.wordWrap = true;
	}
}