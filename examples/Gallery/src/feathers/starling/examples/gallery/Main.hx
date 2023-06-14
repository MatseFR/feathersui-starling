package feathers.starling.examples.gallery;

import feathers.starling.controls.DecelerationRate;
import feathers.starling.controls.Label;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.controls.List;
import feathers.starling.controls.ScrollBarDisplayMode;
import feathers.starling.controls.ScrollPolicy;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.HorizontalLayout;
import feathers.starling.layout.SlideShowLayout;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.themes.MetalWorksMobileTheme;
import feathers.starling.utils.texture.TextureCache;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

class Main extends LayoutGroup 
{
	private static inline var FLICKR_API_KEY:String;
	private static inline var FLICKR_URL:String = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=" + FLICKR_API_KEY + "&format=rest";
	private static inline var FLICKR_PHOTO_URL:String = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_{size}.jpg";
	
	public function new() 
	{
		//set up the theme right away!
		//this is an *extended* version of MetalWorksMobileTheme
		new MetalWorksMobileTheme();
		super();
	}
	
	private var fullSizeList:List;
	private var thumbnailList:List;
	private var message:Label;
	private var apiLoader:URLLoader;
	private var thumbnailTextureCache:TextureCache;
	
	override public function dispose():Void
	{
		if (this.thumbnailTextureCache != null)
		{
			this.thumbnailTextureCache.dispose();
			this.thumbnailTextureCache = null;
		}
		super.dispose();
	}

	override function initialize():Void
	{
		//don't forget to call super.initialize() when you override it!
		super.initialize();
		
		this.layout = new AnchorLayout();
		
		//keep some thumbnails in memory so that they don't need to be
		//reloaded from the web
		this.thumbnailTextureCache = new TextureCache(30);
		
		this.apiLoader = new URLLoader();
		this.apiLoader.addEventListener(openfl.events.Event.COMPLETE, apiLoader_completeListener);
		this.apiLoader.addEventListener(IOErrorEvent.IO_ERROR, apiLoader_errorListener);
		this.apiLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, apiLoader_errorListener);
		this.apiLoader.load(new URLRequest(FLICKR_URL));
		
		//the thumbnail list is positioned on the bottom edge of the app
		//and fills the entire width
		var thumbnailListLayoutData:AnchorLayoutData = new AnchorLayoutData();
		thumbnailListLayoutData.left = 0;
		thumbnailListLayoutData.right = 0;
		thumbnailListLayoutData.bottom = 0;
		
		var thumbnailListLayout:HorizontalLayout = new HorizontalLayout();
		thumbnailListLayout.verticalAlign = VerticalAlign.JUSTIFY;
		thumbnailListLayout.hasVariableItemDimensions = true;
		
		this.thumbnailList = new List();
		this.thumbnailList.layout = thumbnailListLayout;
		//make sure that we have elastic edges horizontally
		this.thumbnailList.horizontalScrollPolicy = ScrollPolicy.ON;
		//we're not displaying scroll bars
		this.thumbnailList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
		//make a swipe scroll a shorter distance
		this.thumbnailList.decelerationRate = DecelerationRate.FAST;
		this.thumbnailList.itemRendererFactory = thumbnailItemRendererFactory;
		this.thumbnailList.addEventListener(starling.events.Event.CHANGE, thumbnailList_changeHandler);
		this.thumbnailList.height = 100;
		this.thumbnailList.layoutData = thumbnailListLayoutData;
		this.addChild(this.thumbnailList);
		
		//the full size list fills the remaining space above the thumbnails
		var fullSizeListLayoutData:AnchorLayoutData = new AnchorLayoutData(0, 0, 0, 0);
		fullSizeListLayoutData.bottomAnchorDisplayObject = this.thumbnailList;
		
		//show a single item per page
		var fullSizeListLayout:SlideShowLayout = new SlideShowLayout();
		fullSizeListLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		fullSizeListLayout.verticalAlign = VerticalAlign.JUSTIFY;
		//load the previous and next items so that they are already visible
		//if images use a lot of memory, this might not be possible for
		//some galleries!
		fullSizeListLayout.minimumItemCount = 3;
		
		this.fullSizeList = new List();
		//snap to the nearest page when scrolling
		this.fullSizeList.snapToPages = true;
		//there is nothing to select in this list
		this.fullSizeList.isSelectable = false;
		//no need to display scroll bars in this list
		this.fullSizeList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
		//make sure that we have elastic edges horizontally
		this.fullSizeList.horizontalScrollPolicy = ScrollPolicy.ON;
		this.fullSizeList.layout = fullSizeListLayout;
		this.fullSizeList.layoutData = fullSizeListLayoutData;
		this.fullSizeList.itemRendererFactory = fullSizeItemRendererFactory;
		this.addChild(this.fullSizeList);
		
		//display at the center of the list of full size images
		var messageLayoutData:AnchorLayoutData = new AnchorLayoutData();
		messageLayoutData.horizontalCenter = 0;
		messageLayoutData.verticalCenter = 0;
		messageLayoutData.verticalCenterAnchorDisplayObject = this.fullSizeList;
		
		this.message = new Label();
		this.message.text = "Loading...";
		this.message.layoutData = messageLayoutData;
		this.addChild(this.message);
	}
	
	private function fullSizeItemRendererFactory():IListItemRenderer
	{
		return new GalleryItemRenderer();
	}

	private function thumbnailItemRendererFactory():IListItemRenderer
	{
		var itemRenderer:ThumbItemRenderer = new ThumbItemRenderer();
		//cache the textures so that they don't need to be reloaded from URLs
		itemRenderer.textureCache = this.thumbnailTextureCache;
		//limit how large these item renderers can be
		itemRenderer.maxWidth = 100;
		itemRenderer.maxHeight = 100;
		return itemRenderer;
	}

	private function thumbnailList_changeHandler(event:starling.events.Event):Void
	{
		var item:GalleryItem = cast this.thumbnailList.selectedItem;
		if (item == null)
		{
			return;
		}
		this.fullSizeList.scrollToDisplayIndex(this.thumbnailList.selectedIndex, 0.5);
	}
	
	private function apiLoader_completeListener(event:openfl.events.Event):Void
	{
		var result:XML = XML(this.apiLoader.data);
		if (result.attribute("stat") == "fail")
		{
			message.text = "Unable to load the list of images from Flickr at this time.";
			return;
		}
		var items:Array<GalleryItem> = new Array<GalleryItem>();
		var photosList:XMLList = result.photos.photo;
		var photoCount:Int = photosList.length();
		for (i in 0...photoCount)
		{
			var photoXML:XML = photosList[i];
			var url:String = FLICKR_PHOTO_URL.replace("{farm-id}", photoXML.@farm.toString());
			url = url.replace("{server-id}", photoXML.@server.toString());
			url = url.replace("{id}", photoXML.@id.toString());
			url = url.replace("{secret}", photoXML.@secret.toString());
			var thumbURL:String = url.replace("{size}", "t");
			url = url.replace("{size}", "b");
			var title:String = photoXML.@title.toString();
			items.push(new GalleryItem(title, url, thumbURL));
		}
		
		this.message.text = "";
		
		var collection:ArrayCollection = new ArrayCollection(items);
		this.thumbnailList.dataProvider = collection;
		this.fullSizeList.dataProvider = collection;
	}

	private function apiLoader_errorListener(event:openfl.events.Event):Void
	{
		this.message.text = "Error loading images.";
	}
}