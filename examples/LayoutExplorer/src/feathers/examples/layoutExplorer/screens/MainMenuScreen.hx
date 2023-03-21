package feathers.examples.layoutExplorer.screens;

import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ArrayCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class MainMenuScreen extends PanelScreen 
{
	public static inline var SHOW_ANCHOR:String = "showAnchor";
	public static inline var SHOW_FLOW:String = "showFlow";
	public static inline var SHOW_HORIZONTAL:String = "showHorizontal";
	public static inline var SHOW_VERTICAL:String = "showVertical";
	public static inline var SHOW_TILED_ROWS:String = "showTiledRows";
	public static inline var SHOW_TILED_COLUMNS:String = "showTiledColumns";
	public static inline var SHOW_WATERFALL:String = "showWaterfall";
	public static inline var SHOW_SLIDE_SHOW:String = "showSlideShow";
	
	public function new() 
	{
		super();
	}
	
	private var _list:List;
	
	public var savedVerticalScrollPosition:Float = 0;
	public var savedSelectedIndex:Int = -1;

	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Layouts in Feathers";
		
		var isTablet:Bool = DeviceCapabilities.isTablet(Starling.current.nativeStage);
		
		this.layout = new AnchorLayout();
		
		this._list = new List();
		this._list.dataProvider = new ArrayCollection(
		[
			{ text: "Anchor", event: SHOW_ANCHOR },
			{ text: "Flow", event: SHOW_FLOW },
			{ text: "Horizontal", event: SHOW_HORIZONTAL },
			{ text: "Vertical", event: SHOW_VERTICAL },
			{ text: "Tiled Rows", event: SHOW_TILED_ROWS },
			{ text: "Tiled Columns", event: SHOW_TILED_COLUMNS },
			{ text: "Waterfall", event: SHOW_WATERFALL },
			{ text: "Slide Show", event: SHOW_SLIDE_SHOW },
		]);
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._list.verticalScrollPosition = this.savedVerticalScrollPosition;
		
		this._list.itemRendererFactory = this.createItemRenderer;
		
		if (isTablet)
		{
			this._list.addEventListener(Event.CHANGE, list_changeHandler);
			this._list.selectedIndex = 0;
			this._list.revealScrollBars();
		}
		else
		{
			this._list.selectedIndex = this.savedSelectedIndex;
			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
		}
		this.addChild(this._list);
	}
	
	private function createItemRenderer():IListItemRenderer
	{
		var isTablet:Bool = DeviceCapabilities.isTablet(Starling.current.nativeStage);
		
		var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
		if (!isTablet)
		{
			renderer.styleNameList.add(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN);
		}
		
		//enable the quick hit area to optimize hit tests when an item
		//is only selectable and doesn't have interactive children.
		renderer.isQuickHitAreaEnabled = true;
		
		renderer.labelField = "text";
		return renderer;
	}
	
	private function transitionInCompleteHandler(event:Event):Void
	{
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this._list.selectedIndex = -1;
			this._list.addEventListener(Event.CHANGE, list_changeHandler);
		}
		this._list.revealScrollBars();
	}
	
	private function list_changeHandler(event:Event):Void
	{
		var eventType:String = this._list.selectedItem.event;
		if (DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this.dispatchEventWith(eventType);
			return;
		}
		
		//save the list's scroll position and selected index so that we
		//can restore some context when this screen when we return to it
		//again later.
		this.dispatchEventWith(eventType, false,
		{
			savedVerticalScrollPosition: this._list.verticalScrollPosition,
			savedSelectedIndex: this._list.selectedIndex
		});
		
	}
}