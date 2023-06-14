package feathers.starling.examples.tabs.themes;

import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.ItemRendererLayoutOrder;
import feathers.starling.controls.renderers.BaseDefaultItemRenderer;
import feathers.starling.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.layout.RelativePosition;
import feathers.starling.themes.MetalWorksMobileTheme;
import starling.display.Canvas;

class TabsTheme extends MetalWorksMobileTheme 
{
	public function new() 
	{
		super();
	}
	
	override function initializeStyleProviders():Void
	{
		super.initializeStyleProviders();
		
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(
				StyleNames.MESSAGE_LIST_ITEM_RENDERER, this.setMessageListItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(
			StyleNames.MESSAGE_LIST_ITEM_RENDERER, this.setMessageListItemRendererStyles);
		this.getStyleProviderForClass(ImageLoader).setFunctionForStyleName(
			StyleNames.SMALL_PROFILE_IMAGE, this.setSmallProfileImageStyles);
		this.getStyleProviderForClass(ImageLoader).setFunctionForStyleName(
			StyleNames.LARGE_PROFILE_IMAGE, this.setLargeProfileImageStyles);
	}
	
	private function setMessageListItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		itemRenderer.accessoryPosition = RelativePosition.BOTTOM;
		itemRenderer.accessoryGap = 4;
		itemRenderer.layoutOrder = ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON;
		itemRenderer.customIconLoaderStyleName = StyleNames.SMALL_PROFILE_IMAGE;
	}
	
	private function setProfileImageStyles(image:ImageLoader, size:Float):Void
	{
		var halfSize:Float = size / 2;
		image.setSize(size, size);
		var mask:Canvas = new Canvas();
		mask.beginFill(0xff00ff, 1);
		mask.drawCircle(halfSize, halfSize, halfSize);
		mask.endFill();
		image.mask = mask;
		image.addChild(mask);
	}
	
	private function setSmallProfileImageStyles(image:ImageLoader):Void
	{
		this.setProfileImageStyles(image, 48);
	}
	
	private function setLargeProfileImageStyles(image:ImageLoader):Void
	{
		this.setProfileImageStyles(image, 100);
	}
}