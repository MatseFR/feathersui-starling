package feathers.examples.layoutExplorer;

import feathers.controls.Drawers;
import feathers.controls.StackScreenNavigator;
import feathers.controls.StackScreenNavigatorItem;
import feathers.examples.layoutExplorer.data.FlowLayoutSettings;
import feathers.examples.layoutExplorer.data.HorizontalLayoutSettings;
import feathers.examples.layoutExplorer.data.SlideShowLayoutSettings;
import feathers.examples.layoutExplorer.data.TiledColumnsLayoutSettings;
import feathers.examples.layoutExplorer.data.TiledRowsLayoutSettings;
import feathers.examples.layoutExplorer.data.VerticalLayoutSettings;
import feathers.examples.layoutExplorer.data.WaterfallLayoutSettings;
import feathers.examples.layoutExplorer.screens.AnchorLayoutScreen;
import feathers.examples.layoutExplorer.screens.FlowLayoutScreen;
import feathers.examples.layoutExplorer.screens.FlowLayoutSettingsScreen;
import feathers.examples.layoutExplorer.screens.HorizontalLayoutScreen;
import feathers.examples.layoutExplorer.screens.HorizontalLayoutSettingsScreen;
import feathers.examples.layoutExplorer.screens.MainMenuScreen;
import feathers.examples.layoutExplorer.screens.SlideShowLayoutScreen;
import feathers.examples.layoutExplorer.screens.SlideShowLayoutSettingsScreen;
import feathers.examples.layoutExplorer.screens.TiledColumnsLayoutScreen;
import feathers.examples.layoutExplorer.screens.TiledColumnsLayoutSettingsScreen;
import feathers.examples.layoutExplorer.screens.TiledRowsLayoutScreen;
import feathers.examples.layoutExplorer.screens.TiledRowsLayoutSettingsScreen;
import feathers.examples.layoutExplorer.screens.VerticalLayoutScreen;
import feathers.examples.layoutExplorer.screens.VerticalLayoutSettingsScreen;
import feathers.examples.layoutExplorer.screens.WaterfallLayoutScreen;
import feathers.examples.layoutExplorer.screens.WaterfallLayoutSettingsScreen;
import feathers.layout.Orientation;
import feathers.motion.Cover;
import feathers.motion.Reveal;
import feathers.motion.Slide;
import feathers.system.DeviceCapabilities;
import feathers.themes.MetalWorksMobileTheme;
import starling.core.Starling;
import starling.events.Event;

class Main extends Drawers 
{
	private static inline var MAIN_MENU:String = "mainMenu";
	private static inline var ANCHOR:String = "anchor";
	private static inline var FLOW:String = "flow";
	private static inline var HORIZONTAL:String = "horizontal";
	private static inline var VERTICAL:String = "vertical";
	private static inline var TILED_ROWS:String = "tiledRows";
	private static inline var TILED_COLUMNS:String = "tiledColumns";
	private static inline var WATERFALL:String = "waterfall";
	private static inline var SLIDE_SHOW:String = "slideShow";
	private static inline var FLOW_SETTINGS:String = "flowSettings";
	private static inline var HORIZONTAL_SETTINGS:String = "horizontalSettings";
	private static inline var VERTICAL_SETTINGS:String = "verticalSettings";
	private static inline var TILED_ROWS_SETTINGS:String = "tiledRowsSettings";
	private static inline var TILED_COLUMNS_SETTINGS:String = "tiledColumnsSettings";
	private static inline var WATERFALL_SETTINGS:String = "waterfallSettings";
	private static inline var SLIDE_SHOW_SETTINGS:String = "slideShowSettings";
	
	private static var MAIN_MENU_EVENTS:Map<String, String> =
	[
		"showAnchor"=>ANCHOR,
		"showFlow"=>FLOW,
		"showHorizontal"=>HORIZONTAL,
		"showVertical"=>VERTICAL,
		"showTiledRows"=>TILED_ROWS,
		"showTiledColumns"=>TILED_COLUMNS,
		"showWaterfall"=>WATERFALL,
		"showSlideShow"=>SLIDE_SHOW
	];
	
	public function new() 
	{
		//set up the theme right away!
		new MetalWorksMobileTheme();
		super();
	}
	
	private var _navigator:StackScreenNavigator;
	private var _menu:MainMenuScreen;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this._navigator = new StackScreenNavigator();
		//we're using Drawers because we want to display the menu on the
		//side when running on tablets.
		this.content = this._navigator;
		
		var anchorItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(AnchorLayoutScreen);
		anchorItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ANCHOR, anchorItem);
		
		var flowLayoutSettings:FlowLayoutSettings = new FlowLayoutSettings();
		var flowItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(FlowLayoutScreen);
		flowItem.setScreenIDForPushEvent(FlowLayoutScreen.SHOW_SETTINGS, FLOW_SETTINGS);
		flowItem.addPopEvent(Event.COMPLETE);
		flowItem.properties.settings = flowLayoutSettings;
		this._navigator.addScreen(FLOW, flowItem);
		
		var flowSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(FlowLayoutSettingsScreen);
		flowSettingsItem.addPopEvent(Event.COMPLETE);
		flowSettingsItem.properties.settings = flowLayoutSettings;
		flowSettingsItem.pushTransition = Cover.createCoverUpTransition();
		flowSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(FLOW_SETTINGS, flowSettingsItem);
		
		var horizontalLayoutSettings:HorizontalLayoutSettings = new HorizontalLayoutSettings();
		var horizontalItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(HorizontalLayoutScreen);
		horizontalItem.setScreenIDForPushEvent(HorizontalLayoutScreen.SHOW_SETTINGS, HORIZONTAL_SETTINGS);
		horizontalItem.addPopEvent(Event.COMPLETE);
		horizontalItem.properties.settings = horizontalLayoutSettings;
		this._navigator.addScreen(HORIZONTAL, horizontalItem);
		
		var horizontalSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(HorizontalLayoutSettingsScreen);
		horizontalSettingsItem.addPopEvent(Event.COMPLETE);
		horizontalSettingsItem.properties.settings = horizontalLayoutSettings;
		horizontalSettingsItem.pushTransition = Cover.createCoverUpTransition();
		horizontalSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(HORIZONTAL_SETTINGS, horizontalSettingsItem);
		
		var verticalLayoutSettings:VerticalLayoutSettings = new VerticalLayoutSettings();
		var verticalItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(VerticalLayoutScreen);
		verticalItem.setScreenIDForPushEvent(VerticalLayoutScreen.SHOW_SETTINGS, VERTICAL_SETTINGS);
		verticalItem.addPopEvent(Event.COMPLETE);
		verticalItem.properties.settings = verticalLayoutSettings;
		this._navigator.addScreen(VERTICAL, verticalItem);
		
		var verticalSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(VerticalLayoutSettingsScreen);
		verticalSettingsItem.addPopEvent(Event.COMPLETE);
		verticalSettingsItem.properties.settings = verticalLayoutSettings;
		verticalSettingsItem.pushTransition = Cover.createCoverUpTransition();
		verticalSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(VERTICAL_SETTINGS, verticalSettingsItem);
		
		var tiledRowsLayoutSettings:TiledRowsLayoutSettings = new TiledRowsLayoutSettings();
		var tiledRowsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TiledRowsLayoutScreen);
		tiledRowsItem.setScreenIDForPushEvent(TiledRowsLayoutScreen.SHOW_SETTINGS, TILED_ROWS_SETTINGS);
		tiledRowsItem.addPopEvent(Event.COMPLETE);
		tiledRowsItem.properties.settings = tiledRowsLayoutSettings;
		this._navigator.addScreen(TILED_ROWS, tiledRowsItem);
		
		var tiledRowsSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TiledRowsLayoutSettingsScreen);
		tiledRowsSettingsItem.addPopEvent(Event.COMPLETE);
		tiledRowsSettingsItem.properties.settings = tiledRowsLayoutSettings;
		tiledRowsSettingsItem.pushTransition = Cover.createCoverUpTransition();
		tiledRowsSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(TILED_ROWS_SETTINGS, tiledRowsSettingsItem);
		
		var tiledColumnsLayoutSettings:TiledColumnsLayoutSettings = new TiledColumnsLayoutSettings();
		var tiledColumnsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TiledColumnsLayoutScreen);
		tiledColumnsItem.setScreenIDForPushEvent(TiledColumnsLayoutScreen.SHOW_SETTINGS, TILED_COLUMNS_SETTINGS);
		tiledColumnsItem.addPopEvent(Event.COMPLETE);
		tiledColumnsItem.properties.settings = tiledColumnsLayoutSettings;
		this._navigator.addScreen(TILED_COLUMNS, tiledColumnsItem);
		
		var tiledColumnsSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TiledColumnsLayoutSettingsScreen);
		tiledColumnsSettingsItem.addPopEvent(Event.COMPLETE);
		tiledColumnsSettingsItem.properties.settings = tiledColumnsLayoutSettings;
		tiledColumnsSettingsItem.pushTransition = Cover.createCoverUpTransition();
		tiledColumnsSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(TILED_COLUMNS_SETTINGS, tiledColumnsSettingsItem);
		
		var waterfallLayoutSettings:WaterfallLayoutSettings = new WaterfallLayoutSettings();
		var waterfallItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(WaterfallLayoutScreen);
		waterfallItem.setScreenIDForPushEvent(TiledColumnsLayoutScreen.SHOW_SETTINGS, WATERFALL_SETTINGS);
		waterfallItem.addPopEvent(Event.COMPLETE);
		waterfallItem.properties.settings = waterfallLayoutSettings;
		this._navigator.addScreen(WATERFALL, waterfallItem);
		
		var waterfallSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(WaterfallLayoutSettingsScreen);
		waterfallSettingsItem.addPopEvent(Event.COMPLETE);
		waterfallSettingsItem.properties.settings = waterfallLayoutSettings;
		waterfallSettingsItem.pushTransition = Cover.createCoverUpTransition();
		waterfallSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(WATERFALL_SETTINGS, waterfallSettingsItem);
		
		var slideShowSettings:SlideShowLayoutSettings = new SlideShowLayoutSettings();
		var slideShowItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SlideShowLayoutScreen);
		slideShowItem.setScreenIDForPushEvent(SlideShowLayoutScreen.SHOW_SETTINGS, SLIDE_SHOW_SETTINGS);
		slideShowItem.addPopEvent(Event.COMPLETE);
		slideShowItem.properties.settings = slideShowSettings;
		this._navigator.addScreen(SLIDE_SHOW, slideShowItem);
		
		var slideShowSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SlideShowLayoutSettingsScreen);
		slideShowSettingsItem.addPopEvent(Event.COMPLETE);
		slideShowSettingsItem.properties.settings = slideShowSettings;
		slideShowSettingsItem.pushTransition = Cover.createCoverUpTransition();
		slideShowSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(SLIDE_SHOW_SETTINGS, slideShowSettingsItem);
		
		if (DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			//we don't want the screens bleeding outside the navigator's
			//bounds on top of a drawer when a transition is active, so
			//enable clipping.
			this._navigator.clipContent = true;
			this._menu = new MainMenuScreen();
			for (eventType in MAIN_MENU_EVENTS.keys())
			{
				this._menu.addEventListener(eventType, mainMenuEventHandler);
			}
			this.leftDrawer = this._menu;
			this.leftDrawerDockMode = Orientation.BOTH;
		}
		else
		{
			var mainMenuItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(MainMenuScreen);
			for (eventType in MAIN_MENU_EVENTS.keys())
			{
				mainMenuItem.setScreenIDForPushEvent(eventType, MAIN_MENU_EVENTS[eventType]);
			}
			this._navigator.addScreen(MAIN_MENU, mainMenuItem);
			this._navigator.rootScreenID = MAIN_MENU;
		}
		
		this._navigator.pushTransition = Slide.createSlideLeftTransition();
		this._navigator.popTransition = Slide.createSlideRightTransition();
	}
	
	private function mainMenuEventHandler(event:Event):Void
	{
		var screenName:String = MAIN_MENU_EVENTS[event.type];
		//since this navigation is triggered by an external menu, we don't
		//want to push a new screen onto the stack. we want to start fresh.
		this._navigator.rootScreenID = screenName;
	}
	
}