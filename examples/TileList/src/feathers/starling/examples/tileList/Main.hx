package feathers.starling.examples.tileList;

import feathers.starling.controls.LayoutGroup;
import feathers.starling.controls.List;
import feathers.starling.controls.PageIndicator;
import feathers.starling.controls.ScrollBarDisplayMode;
import feathers.starling.controls.ScrollPolicy;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.RelativePosition;
import feathers.starling.layout.TiledRowsLayout;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.themes.MinimalMobileTheme;
import starling.assets.AssetManager;
import starling.events.Event;
import starling.textures.TextureAtlas;

class Main extends LayoutGroup 
{

	public function new() 
	{
		new MinimalMobileTheme();
		super();
	}
	
	private var _assetManager:AssetManager;
	private var _list:List;
	private var _pageIndicator:PageIndicator;
	
	override public function dispose():Void
	{
		//don't forget to clean up textures and things!
		if (this._assetManager != null)
		{
			this._assetManager.dispose();
			this._assetManager = null;
		}
		super.dispose();
	}
	
	override function initialize():Void
	{
		//don't forget to call super.initialize()
		super.initialize();
		
		//a nice, fluid layout
		this.layout = new AnchorLayout();
		
		//the page indicator can be used to scroll the list
		this._pageIndicator = new PageIndicator();
		this._pageIndicator.direction = Direction.HORIZONTAL;
		this._pageIndicator.pageCount = 1;
		
		//we listen to the change event to update the list's scroll position
		this._pageIndicator.addEventListener(Event.CHANGE, pageIndicator_changeHandler);
		
		//we'll position the page indicator on the bottom and stretch its
		//width to fill the container's width
		var pageIndicatorLayoutData:AnchorLayoutData = new AnchorLayoutData();
		pageIndicatorLayoutData.bottom = 0;
		pageIndicatorLayoutData.left = 0;
		pageIndicatorLayoutData.right = 0;
		this._pageIndicator.layoutData = pageIndicatorLayoutData;
		
		this.addChild(this._pageIndicator);
		
		this._list = new List();
		this._list.itemRendererFactory = tileListItemRendererFactory;
		this._list.snapToPages = true;
		this._list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
		this._list.horizontalScrollPolicy = ScrollPolicy.ON;
		this._list.verticalScrollPolicy = ScrollPolicy.OFF;
		
		var listLayout:TiledRowsLayout = new TiledRowsLayout();
		listLayout.paging = Direction.HORIZONTAL;
		listLayout.useSquareTiles = false;
		listLayout.tileHorizontalAlign = HorizontalAlign.JUSTIFY;
		listLayout.tileVerticalAlign = HorizontalAlign.JUSTIFY;
		listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		listLayout.verticalAlign = VerticalAlign.TOP;
		listLayout.requestedColumnCount = 4;
		listLayout.distributeWidths = true;
		this._list.layout = listLayout;
		
		//we listen to the scroll event to update the page indicator
		this._list.addEventListener(Event.SCROLL, list_scrollHandler);
		
		//the list fills the container's width and the remaining height
		//above the page indicator
		var listLayoutData:AnchorLayoutData = new AnchorLayoutData();
		listLayoutData.top = 0;
		listLayoutData.right = 0;
		listLayoutData.bottom = 0;
		listLayoutData.bottomAnchorDisplayObject = this._pageIndicator;
		listLayoutData.left = 0;
		this._list.layoutData = listLayoutData;
		
		this.addChild(this._list);
		
		this.loadIcons();
	}
	
	private function loadIcons():Void
	{
		this._assetManager = new AssetManager(2);
		this._assetManager.enqueue([
			"assets/images/atlas@2x.png",
			"assets/images/atlas@2x.xml"
		]);
		this._assetManager.loadQueue(assetManager_onComplete);
	}
	
	private function tileListItemRendererFactory():IListItemRenderer
	{
		var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
		itemRenderer.labelField = "label";
		itemRenderer.iconSourceField = "texture";
		itemRenderer.iconPosition = RelativePosition.TOP;
		itemRenderer.horizontalAlign = HorizontalAlign.CENTER;
		itemRenderer.verticalAlign = VerticalAlign.BOTTOM;
		itemRenderer.maxWidth = 80;
		itemRenderer.gap = 2;
		return itemRenderer;
	}
	
	private function list_scrollHandler(event:Event):Void
	{
		this._pageIndicator.pageCount = this._list.horizontalPageCount;
		this._pageIndicator.selectedIndex = this._list.horizontalPageIndex;
	}
	
	private function pageIndicator_changeHandler(event:Event):Void
	{
		this._list.scrollToPageIndex(this._pageIndicator.selectedIndex, 0, this._list.pageThrowDuration);
	}
	
	private function assetManager_onComplete():Void
	{
		//get the texture atlas from the asset manager
		var atlas:TextureAtlas = this._assetManager.getTextureAtlas("atlas@2x");
		
		//populate the list using the textures
		this._list.dataProvider = new ArrayCollection(
		[
			{ label: "Behance", texture: atlas.getTexture("behance") },
			{ label: "Blogger", texture: atlas.getTexture("blogger") },
			{ label: "Delicious", texture: atlas.getTexture("delicious") },
			{ label: "DeviantArt", texture: atlas.getTexture("deviantart") },
			{ label: "Digg", texture: atlas.getTexture("digg") },
			{ label: "Dribbble", texture: atlas.getTexture("dribbble") },
			{ label: "Facebook", texture: atlas.getTexture("facebook") },
			{ label: "Flickr", texture: atlas.getTexture("flickr") },
			{ label: "Github", texture: atlas.getTexture("github") },
			{ label: "Google", texture: atlas.getTexture("google") },
			{ label: "Instagram", texture: atlas.getTexture("instagram") },
			{ label: "LinkedIn", texture: atlas.getTexture("linkedin") },
			{ label: "Pinterest", texture: atlas.getTexture("pinterest") },
			{ label: "Snapchat", texture: atlas.getTexture("snapchat") },
			{ label: "SoundCloud", texture: atlas.getTexture("soundcloud") },
			{ label: "StackOverflow", texture: atlas.getTexture("stackoverflow") },
			{ label: "StumbleUpon", texture: atlas.getTexture("stumbleupon") },
			{ label: "Tumblr", texture: atlas.getTexture("tumblr") },
			{ label: "Twitter", texture: atlas.getTexture("twitter") },
			{ label: "Vimeo", texture: atlas.getTexture("vimeo") },
			{ label: "Vine", texture: atlas.getTexture("vine") },
			{ label: "WordPress", texture: atlas.getTexture("wordpress") },
			{ label: "Yahoo!", texture: atlas.getTexture("yahoo") },
			{ label: "Yelp", texture: atlas.getTexture("yelp") },
			{ label: "YouTube", texture: atlas.getTexture("youtube") },
		]);
	}
}