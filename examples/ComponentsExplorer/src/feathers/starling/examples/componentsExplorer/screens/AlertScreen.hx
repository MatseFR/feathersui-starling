package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Alert;
import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.data.ArrayCollection;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class AlertScreen extends PanelScreen 
{

	public function new() 
	{
		super();
	}
	
	private var _showAlertButton:Button;
	
	override function initialize():Void 
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Alert";
		
		this.layout = new AnchorLayout();
		
		this._showAlertButton = new Button();
		this._showAlertButton.label = "Show Alert";
		this._showAlertButton.addEventListener(Event.TRIGGERED, showAlertButton_triggeredHandler);
		var buttonLayoutData:AnchorLayoutData = new AnchorLayoutData();
		buttonLayoutData.horizontalCenter = 0;
		buttonLayoutData.verticalCenter = 0;
		this._showAlertButton.layoutData = buttonLayoutData;
		this.addChild(this._showAlertButton);
		
		this.headerFactory = this.customHeaderFactory;
		
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this.backButtonHandler = this.onBackButton;
		}
	}
	
	private function customHeaderFactory():Header
	{
		var header:Header = new Header();
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			var backButton:Button = new Button();
			backButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON);
			backButton.label = "Back";
			backButton.addEventListener(Event.TRIGGERED, backButton_triggeredHandler);
			header.leftItems = 
			[
				backButton
			];
		}
		return header;
	}
	
	private function onBackButton():Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}
	
	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
	private function showAlertButton_triggeredHandler(event:Event):Void
	{
		var alert:Alert = Alert.show("I just wanted you to know that I have a very important message to share with you.", "Alert", new ArrayCollection(
		[
			{ label: "OK" },
			{ label: "Cancel" }
		]));
		//when the enter key is pressed, treat it as OK
		alert.acceptButtonIndex = 0;
		//when the back or escape key is pressed, treat it as cancel
		alert.cancelButtonIndex = 1;
		alert.addEventListener(Event.CLOSE, alert_closeHandler);
	}

	private function alert_closeHandler(event:Event, data:Dynamic):Void
	{
		if (data != null)
		{
			trace("alert closed with item:", data.label);
		}
		else
		{
			trace("alert closed without item");
		}
	}
	
}