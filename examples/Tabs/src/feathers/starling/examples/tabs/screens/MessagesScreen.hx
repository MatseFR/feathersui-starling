package feathers.starling.examples.tabs.screens;

import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.List;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.examples.tabs.themes.StyleNames;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.utils.texture.TextureCache;

class MessagesScreen extends PanelScreen 
{
	public function new() 
	{
		super();
		this.title = "Messages";
	}
	
	private var _list:List;
	private var _cache:TextureCache;

	override public function dispose():Void
	{
		if (this._cache != null)
		{
			this._cache.dispose();
			this._cache = null;
		}
		super.dispose();
	}
	
	override function initialize():Void
	{
		super.initialize();
		
		this._cache = new TextureCache(10);
		
		this.layout = new AnchorLayout();
		
		this._list = new List();
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._list.customItemRendererStyleName = StyleNames.MESSAGE_LIST_ITEM_RENDERER;
		this._list.itemRendererFactory = this.createMessageItemRenderer;
		this.addChild(this._list);
		
		this._list.dataProvider = new ArrayCollection(
		[
			{
				name: "Patsy Brewer",
				message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
				photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/women79.jpg"
			},
			{
				name: "Wayne Adams",
				message: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
				photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/men36.jpg"
			},
			{
				name: "Andy Johnston",
				message: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
				photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/men92.jpg"
			},
			{
				name: "Pearl Boyd",
				message: "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
				photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/women69.jpg"
			},
		]);
	}
	
	private function createMessageItemRenderer():IListItemRenderer
	{
		var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
		itemRenderer.labelField = "name";
		itemRenderer.accessoryLabelField = "message";
		itemRenderer.iconSourceField = "photo";
		itemRenderer.iconLoaderFactory = this.createPhotoLoader;
		return itemRenderer;
	}

	private function createPhotoLoader():ImageLoader
	{
		var loader:ImageLoader = new ImageLoader();
		loader.textureCache = this._cache;
		return loader;
	}
}