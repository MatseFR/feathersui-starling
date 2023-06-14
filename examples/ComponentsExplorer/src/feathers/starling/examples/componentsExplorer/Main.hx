package feathers.starling.examples.componentsExplorer;

import feathers.starling.controls.Drawers;
import feathers.starling.controls.StackScreenNavigator;
import feathers.starling.controls.StackScreenNavigatorItem;
import feathers.starling.core.IFeathersControl;
import feathers.starling.examples.componentsExplorer.data.DataGridSettings;
import feathers.starling.examples.componentsExplorer.data.DateTimeSpinnerSettings;
import feathers.starling.examples.componentsExplorer.data.EmbeddedAssets;
import feathers.starling.examples.componentsExplorer.data.GroupedListSettings;
import feathers.starling.examples.componentsExplorer.data.ItemRendererSettings;
import feathers.starling.examples.componentsExplorer.data.ListSettings;
import feathers.starling.examples.componentsExplorer.data.NumericStepperSettings;
import feathers.starling.examples.componentsExplorer.data.SliderSettings;
import feathers.starling.examples.componentsExplorer.screens.AlertScreen;
import feathers.starling.examples.componentsExplorer.screens.AutoCompleteScreen;
import feathers.starling.examples.componentsExplorer.screens.ButtonGroupScreen;
import feathers.starling.examples.componentsExplorer.screens.ButtonScreen;
import feathers.starling.examples.componentsExplorer.screens.CalloutScreen;
import feathers.starling.examples.componentsExplorer.screens.CheckScreen;
import feathers.starling.examples.componentsExplorer.screens.DataGridScreen;
import feathers.starling.examples.componentsExplorer.screens.DataGridSettingsScreen;
import feathers.starling.examples.componentsExplorer.screens.DateTimeSpinnerScreen;
import feathers.starling.examples.componentsExplorer.screens.DateTimeSpinnerSettingsScreen;
import feathers.starling.examples.componentsExplorer.screens.GroupedListScreen;
import feathers.starling.examples.componentsExplorer.screens.GroupedListSettingsScreen;
import feathers.starling.examples.componentsExplorer.screens.ItemRendererScreen;
import feathers.starling.examples.componentsExplorer.screens.ItemRendererSettingsScreen;
import feathers.starling.examples.componentsExplorer.screens.LabelScreen;
import feathers.starling.examples.componentsExplorer.screens.ListScreen;
import feathers.starling.examples.componentsExplorer.screens.ListSettingsScreen;
import feathers.starling.examples.componentsExplorer.screens.MainMenuScreen;
import feathers.starling.examples.componentsExplorer.screens.NumericStepperScreen;
import feathers.starling.examples.componentsExplorer.screens.NumericStepperSettingsScreen;
import feathers.starling.examples.componentsExplorer.screens.PageIndicatorScreen;
import feathers.starling.examples.componentsExplorer.screens.PanelComponentScreen;
import feathers.starling.examples.componentsExplorer.screens.PickerListScreen;
import feathers.starling.examples.componentsExplorer.screens.ProgressBarScreen;
import feathers.starling.examples.componentsExplorer.screens.RadioScreen;
import feathers.starling.examples.componentsExplorer.screens.ScrollTextScreen;
import feathers.starling.examples.componentsExplorer.screens.SliderScreen;
import feathers.starling.examples.componentsExplorer.screens.SliderSettingsScreen;
import feathers.starling.examples.componentsExplorer.screens.SpinnerListScreen;
import feathers.starling.examples.componentsExplorer.screens.TabBarScreen;
import feathers.starling.examples.componentsExplorer.screens.TextCalloutScreen;
import feathers.starling.examples.componentsExplorer.screens.TextInputScreen;
import feathers.starling.examples.componentsExplorer.screens.ToastScreen;
import feathers.starling.examples.componentsExplorer.screens.ToggleSwitchScreen;
import feathers.starling.examples.componentsExplorer.screens.TreeScreen;
import feathers.starling.layout.Orientation;
import feathers.starling.motion.Cover;
import feathers.starling.motion.Reveal;
import feathers.starling.motion.Slide;
import feathers.starling.system.DeviceCapabilities;
import feathers.starling.themes.MetalWorksMobileTheme;
import starling.core.Starling;
import starling.events.Event;
import starling.events.ResizeEvent;

class Main extends Drawers 
{

	public function new(content:IFeathersControl=null) 
	{
		//set up the theme right away!
		//new MetalWorksDesktopTheme();
		new MetalWorksMobileTheme();
		super(content);
	}
	
	private var _navigator:StackScreenNavigator;
	private var _menu:MainMenuScreen;
	
	override function initialize():Void 
	{
		//never forget to call super.initialize()
		super.initialize();
		
		EmbeddedAssets.initialize();
		
		this._navigator = new StackScreenNavigator();
		this.content = this._navigator;
		
		var alertItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(AlertScreen);
		alertItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.ALERT, alertItem);
		
		var autoCompleteItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(AutoCompleteScreen);
		autoCompleteItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.AUTO_COMPLETE, autoCompleteItem);
		
		var buttonItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ButtonScreen);
		buttonItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.BUTTON, buttonItem);
		
		var buttonGroupItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ButtonGroupScreen);
		buttonGroupItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.BUTTON_GROUP, buttonGroupItem);
		
		var calloutItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(CalloutScreen);
		calloutItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.CALLOUT, calloutItem);
		
		var checkItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(CheckScreen);
		checkItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.CHECK, checkItem);
		
		var dataGridSettings:DataGridSettings = new DataGridSettings();
		var dataGridItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(DataGridScreen);
		dataGridItem.setScreenIDForPushEvent(DataGridScreen.SHOW_SETTINGS, ScreenID.DATA_GRID_SETTINGS);
		dataGridItem.addPopEvent(Event.COMPLETE);
		dataGridItem.properties.settings = dataGridSettings;
		this._navigator.addScreen(ScreenID.DATA_GRID, dataGridItem);
		
		var dataGridSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(DataGridSettingsScreen);
		dataGridSettingsItem.addPopEvent(Event.COMPLETE);
		dataGridSettingsItem.properties.settings = dataGridSettings;
		//custom push and pop transitions for this settings screen
		dataGridSettingsItem.pushTransition = Cover.createCoverUpTransition();
		dataGridSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(ScreenID.DATA_GRID_SETTINGS, dataGridSettingsItem);
		
		var dateTimeSpinnerSettings:DateTimeSpinnerSettings = new DateTimeSpinnerSettings();
		var dateTimeSpinnerItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(DateTimeSpinnerScreen);
		dateTimeSpinnerItem.setScreenIDForPushEvent(DateTimeSpinnerScreen.SHOW_SETTINGS, ScreenID.DATE_TIME_SPINNER_SETTINGS);
		dateTimeSpinnerItem.addPopEvent(Event.COMPLETE);
		dateTimeSpinnerItem.properties.settings = dateTimeSpinnerSettings;
		this._navigator.addScreen(ScreenID.DATE_TIME_SPINNER, dateTimeSpinnerItem);

		var dateTimeSpinnerSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(DateTimeSpinnerSettingsScreen);
		dateTimeSpinnerSettingsItem.addPopEvent(Event.COMPLETE);
		dateTimeSpinnerSettingsItem.properties.settings = dateTimeSpinnerSettings;
		//custom push and pop transitions for this settings screen
		dateTimeSpinnerSettingsItem.pushTransition = Cover.createCoverUpTransition();
		dateTimeSpinnerSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(ScreenID.DATE_TIME_SPINNER_SETTINGS, dateTimeSpinnerSettingsItem);
		
		var groupedListSettings:GroupedListSettings = new GroupedListSettings();
		var groupedListItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(GroupedListScreen);
		groupedListItem.setScreenIDForPushEvent(GroupedListScreen.SHOW_SETTINGS, ScreenID.GROUPED_LIST_SETTINGS);
		groupedListItem.addPopEvent(Event.COMPLETE);
		groupedListItem.properties.settings = groupedListSettings;
		this._navigator.addScreen(ScreenID.GROUPED_LIST, groupedListItem);
		
		var groupedListSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(GroupedListSettingsScreen);
		groupedListSettingsItem.addPopEvent(Event.COMPLETE);
		groupedListSettingsItem.properties.settings = groupedListSettings;
		//custom push and pop transitions for this settings screen
		groupedListSettingsItem.pushTransition = Cover.createCoverUpTransition();
		groupedListSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(ScreenID.GROUPED_LIST_SETTINGS, groupedListSettingsItem);
		
		var itemRendererSettings:ItemRendererSettings = new ItemRendererSettings();
		var itemRendererItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ItemRendererScreen);
		itemRendererItem.setScreenIDForPushEvent(ItemRendererScreen.SHOW_SETTINGS, ScreenID.ITEM_RENDERER_SETTINGS);
		itemRendererItem.addPopEvent(Event.COMPLETE);
		itemRendererItem.properties.settings = itemRendererSettings;
		this._navigator.addScreen(ScreenID.ITEM_RENDERER, itemRendererItem);

		var itemRendererSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ItemRendererSettingsScreen);
		itemRendererSettingsItem.addPopEvent(Event.COMPLETE);
		itemRendererSettingsItem.properties.settings = itemRendererSettings;
		//custom push and pop transitions for this settings screen
		itemRendererSettingsItem.pushTransition = Cover.createCoverUpTransition();
		itemRendererSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(ScreenID.ITEM_RENDERER_SETTINGS, itemRendererSettingsItem);
		
		var labelItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(LabelScreen);
		labelItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.LABEL, labelItem);
		
		var listSettings:ListSettings = new ListSettings();
		var listItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ListScreen);
		listItem.setScreenIDForPushEvent(ListScreen.SHOW_SETTINGS, ScreenID.LIST_SETTINGS);
		listItem.addPopEvent(Event.COMPLETE);
		listItem.properties.settings = listSettings;
		this._navigator.addScreen(ScreenID.LIST, listItem);
		
		var listSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ListSettingsScreen);
		listSettingsItem.addPopEvent(Event.COMPLETE);
		listSettingsItem.properties.settings = listSettings;
		//custom push and pop transitions for this settings screen
		listSettingsItem.pushTransition = Cover.createCoverUpTransition();
		listSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(ScreenID.LIST_SETTINGS, listSettingsItem);
		
		var numericStepperSettings:NumericStepperSettings = new NumericStepperSettings();
		var numericStepperItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(NumericStepperScreen);
		numericStepperItem.setScreenIDForPushEvent(NumericStepperScreen.SHOW_SETTINGS, ScreenID.NUMERIC_STEPPER_SETTINGS);
		numericStepperItem.addPopEvent(Event.COMPLETE);
		numericStepperItem.properties.settings = numericStepperSettings;
		this._navigator.addScreen(ScreenID.NUMERIC_STEPPER, numericStepperItem);
		
		var numericStepperSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(NumericStepperSettingsScreen);
		numericStepperSettingsItem.addPopEvent(Event.COMPLETE);
		numericStepperSettingsItem.properties.settings = numericStepperSettings;
		//custom push and pop transitions for this settings screen
		numericStepperSettingsItem.pushTransition = Cover.createCoverUpTransition();
		numericStepperSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(ScreenID.NUMERIC_STEPPER_SETTINGS, numericStepperSettingsItem);
		
		var pageIndicatorItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(PageIndicatorScreen);
		pageIndicatorItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.PAGE_INDICATOR, pageIndicatorItem);
		
		var panelItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(PanelComponentScreen);
		panelItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.PANEL, panelItem);
		
		var pickerListItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(PickerListScreen);
		pickerListItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.PICKER_LIST, pickerListItem);
		
		var progressBarItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ProgressBarScreen);
		progressBarItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.PROGRESS_BAR, progressBarItem);
		
		var radioItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(RadioScreen);
		radioItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.RADIO, radioItem);
		
		var scrollTextItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ScrollTextScreen);
		scrollTextItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.SCROLL_TEXT, scrollTextItem);
		
		var sliderSettings:SliderSettings = new SliderSettings();
		var sliderItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SliderScreen);
		sliderItem.setScreenIDForPushEvent(SliderScreen.SHOW_SETTINGS, ScreenID.SLIDER_SETTINGS);
		sliderItem.addPopEvent(Event.COMPLETE);
		sliderItem.properties.settings = sliderSettings;
		this._navigator.addScreen(ScreenID.SLIDER, sliderItem);
		
		var sliderSettingsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SliderSettingsScreen);
		sliderSettingsItem.addPopEvent(Event.COMPLETE);
		sliderSettingsItem.properties.settings = sliderSettings;
		//custom push and pop transitions for this settings screen
		sliderSettingsItem.pushTransition = Cover.createCoverUpTransition();
		sliderSettingsItem.popTransition = Reveal.createRevealDownTransition();
		this._navigator.addScreen(ScreenID.SLIDER_SETTINGS, sliderSettingsItem);
		
		var spinnerListItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SpinnerListScreen);
		spinnerListItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.SPINNER_LIST, spinnerListItem);
		
		var tabBarItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TabBarScreen);
		tabBarItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.TAB_BAR, tabBarItem);
		
		var textCalloutItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TextCalloutScreen);
		textCalloutItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.TEXT_CALLOUT, textCalloutItem);
		
		var textInputItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TextInputScreen);
		textInputItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.TEXT_INPUT, textInputItem);
		
		var toastItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ToastScreen);
		toastItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.TOAST, toastItem);
		
		var togglesItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ToggleSwitchScreen);
		togglesItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.TOGGLES, togglesItem);
		
		var treeItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(TreeScreen);
		treeItem.addPopEvent(Event.COMPLETE);
		this._navigator.addScreen(ScreenID.TREE, treeItem);
		
		if (DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			//we don't want the screens bleeding outside the navigator's
			//bounds on top of a drawer when a transition is active, so
			//enable clipping.
			this._navigator.clipContent = true;
			this._menu = new MainMenuScreen();
			this._menu.addEventListener(Event.CHANGE, mainMenu_tabletChangeHandler);
			this._menu.height = 200;
			this.leftDrawer = this._menu;
			this.leftDrawerDockMode = Orientation.BOTH;
		}
		else
		{
			var mainMenuItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(MainMenuScreen);
			mainMenuItem.setFunctionForPushEvent(Event.CHANGE, mainMenu_phoneChangeHandler);
			this._navigator.addScreen(ScreenID.MAIN_MENU, mainMenuItem);
			this._navigator.rootScreenID = ScreenID.MAIN_MENU;
		}
		
		this._navigator.pushTransition = Slide.createSlideLeftTransition();
		this._navigator.popTransition = Slide.createSlideRightTransition();
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
	}
	
	private function mainMenu_phoneChangeHandler(event:Event):Void
	{
		//when MainMenuScreen dispatches Event.CHANGE, its selectedScreenID
		//property has been updated. use that to show the correct screen.
		var screen:MainMenuScreen = cast event.currentTarget;
		this._navigator.pushScreen(screen.selectedScreenID, event.data);
		//pass the data from the event to save it for when we pop back.
	}
	
	private function mainMenu_tabletChangeHandler(event:Event):Void
	{
		//since this navigation is triggered by an external menu, we don't
		//want to push a new screen onto the stack. we want to start fresh.
		var screen:MainMenuScreen = cast event.currentTarget;
		this._navigator.rootScreenID = screen.selectedScreenID;
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
	}
	
	private function updateViewPort(width:Int, height:Int):Void
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		stage.stageWidth = Std.int(width / scale);
		stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width = width;//stage.stageWidth * scale;
		current.viewPort.height = height;//stage.stageHeight * scale;
	}
	
}