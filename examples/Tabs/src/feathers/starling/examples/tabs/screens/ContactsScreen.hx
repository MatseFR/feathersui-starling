package feathers.starling.examples.tabs.screens;

import feathers.starling.controls.GroupedList;
import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.starling.controls.renderers.IGroupedListItemRenderer;
import feathers.starling.data.ArrayHierarchicalCollection;
import feathers.starling.examples.tabs.themes.StyleNames;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.utils.texture.TextureCache;

class ContactsScreen extends PanelScreen 
{
	public function new() 
	{
		super();
		this.title = "Contacts";
	}
	
	private var _list:GroupedList;
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
		
		this._list = new GroupedList();
		this._list.isSelectable = false;
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._list.customItemRendererStyleName = StyleNames.MESSAGE_LIST_ITEM_RENDERER;
		this._list.itemRendererFactory = this.createContactItemRenderer;
		this.addChild(this._list);
		
		this._list.dataProvider = new ArrayHierarchicalCollection(
		[
			{
				header: "A",
				children:
				[
					{
						name: "Andy Johnston",
						email: "itsandy1981@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/men92.jpg"
					},
				]
			},
			{
				header: "D",
				children:
				[
					{
						name: "Denise Kim",
						email: "kim.denise@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/women83.jpg"
					},
					{
						name: "Dylan Curtis",
						email: "curtis1987@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/men87.jpg"
					},
				]
			},
			{
				header: "P",
				children: 
				[
					{
						name: "Pat Brewer",
						email: "pbrewer19@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/women79.jpg"
					},
					{
						name: "Pearl Boyd",
						email: "pearl.boyd@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/women69.jpg"
					},
				]
			},
			{
				header: "R",
				children:
				[
					{
						name: "Robin Taylor",
						email: "robintaylor@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/women89.jpg"
					},
				]
			},
			{
				header: "S",
				children:
				[
					{
						name: "Savannah Flores",
						email: "saflo79@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/women53.jpg"
					},
				]
			},
			{
				header: "W",
				children:
				[
					{
						name: "Wayne Adams",
						email: "superwayne@example.com",
						photo: "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/men36.jpg"
					},
				]
			},
		]);
	}
	
	private function createContactItemRenderer():IGroupedListItemRenderer
	{
		var itemRenderer:DefaultGroupedListItemRenderer = new DefaultGroupedListItemRenderer();
		itemRenderer.labelField = "name";
		itemRenderer.accessoryLabelField = "email";
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