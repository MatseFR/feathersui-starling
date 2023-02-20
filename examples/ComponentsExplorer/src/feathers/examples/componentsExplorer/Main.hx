package feathers.examples.componentsExplorer;

import feathers.controls.Drawers;
import feathers.controls.StackScreenNavigator;
import feathers.controls.StackScreenNavigatorItem;
import feathers.core.IFeathersControl;
import feathers.examples.componentsExplorer.data.EmbeddedAssets;
import feathers.examples.componentsExplorer.screens.AlertScreen;
import feathers.motion.Slide;
import feathers.system.DeviceCapabilities;
import feathers.themes.MetalWorksDesktopTheme;
import starling.events.Event;

/**
 * ...
 * @author Matse
 */
class Main extends Drawers 
{

	public function new(content:IFeathersControl=null) 
	{
		//set up the theme right away!
		new MetalWorksDesktopTheme();
		super(content);
	}
	
	private var _navigator:StackScreenNavigator;
	
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
		
		//if (DeviceCapabilities.isTablet(Starling.current.nativeStage))
		//{
			////we don't want the screens bleeding outside the navigator's
			////bounds on top of a drawer when a transition is active, so
			////enable clipping.
			//this._navigator.clipContent = true;
			//this._menu = new MainMenuScreen();
			//this._menu.addEventListener(Event.CHANGE, mainMenu_tabletChangeHandler);
			//this._menu.height = 200;
			//this.leftDrawer = this._menu;
			//this.leftDrawerDockMode = Orientation.BOTH;
		//}
		//else
		//{
			//var mainMenuItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(MainMenuScreen);
			//mainMenuItem.setFunctionForPushEvent(Event.CHANGE, mainMenu_phoneChangeHandler);
			//this._navigator.addScreen(ScreenID.MAIN_MENU, mainMenuItem);
			//this._navigator.rootScreenID = ScreenID.MAIN_MENU;
		//}
		
		this._navigator.pushTransition = Slide.createSlideLeftTransition();
		this._navigator.popTransition = Slide.createSlideRightTransition();
	}
	
}