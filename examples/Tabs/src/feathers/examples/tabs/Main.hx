package feathers.examples.tabs;

import feathers.controls.TabNavigator;
import feathers.controls.TabNavigatorItem;
import feathers.examples.tabs.screens.ContactsScreen;
import feathers.examples.tabs.screens.MessagesScreen;
import feathers.examples.tabs.screens.ProfileScreen;
import feathers.examples.tabs.themes.TabsTheme;
import starling.display.Sprite;
import starling.events.Event;

class Main extends Sprite 
{
	private static inline var MESSAGES:String = "messages";
	private static inline var CONTACTS:String = "contacts";
	private static inline var PROFILE:String = "profile";
	
	public function new() 
	{
		new TabsTheme();
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private var navigator:TabNavigator;
	
	private function addedToStageHandler(event:Event):Void
	{
		this.navigator = new TabNavigator();
		this.addMessagesTab();
		this.addContactsTab();
		this.addProfileTab();
		this.addChild(this.navigator);
	}

	private function addMessagesTab():Void
	{
		var screen:MessagesScreen = new MessagesScreen();
		var item:TabNavigatorItem = new TabNavigatorItem(screen, "Messages");
		this.navigator.addScreen(MESSAGES, item);
	}

	private function addContactsTab():Void
	{
		var screen:ContactsScreen = new ContactsScreen();
		var item:TabNavigatorItem = new TabNavigatorItem(screen, "Contacts");
		this.navigator.addScreen(CONTACTS, item);
	}

	private function addProfileTab():Void
	{
		var screen:ProfileScreen = new ProfileScreen();
		var item:TabNavigatorItem = new TabNavigatorItem(screen, "Profile");
		this.navigator.addScreen(PROFILE, item);
	}
}