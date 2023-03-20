package feathers.examples.componentsExplorer.screens;

import feathers.controls.Button;
import feathers.controls.DateTimeSpinner;
import feathers.controls.Header;
import feathers.controls.PanelScreen;
import feathers.examples.componentsExplorer.data.DateTimeSpinnerSettings;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class DateTimeSpinnerScreen extends PanelScreen 
{
	public static inline var SHOW_SETTINGS:String = "showSettings";
	
	public function new() 
	{
		super();
	}
	
	public var settings:DateTimeSpinnerSettings;
	
	private var _dateTimeSpinner:DateTimeSpinner;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Date Time Spinner";
		
		var verticalLayout:VerticalLayout = new VerticalLayout();
		verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
		verticalLayout.verticalAlign = VerticalAlign.MIDDLE;
		verticalLayout.padding = 12;
		verticalLayout.gap = 8;
		this.layout = verticalLayout;
		
		this._dateTimeSpinner = new DateTimeSpinner();
		this._dateTimeSpinner.editingMode = this.settings.editingMode;
		this._dateTimeSpinner.addEventListener(Event.CHANGE, dateTimeSpinner_changeHandler);
		this.addChild(this._dateTimeSpinner);
		
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
		var settingsButton:Button = new Button();
		settingsButton.label = "Settings";
		settingsButton.addEventListener(Event.TRIGGERED, settingsButton_triggeredHandler);
		header.rightItems = 
		[
			settingsButton
		];
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

	private function settingsButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(SHOW_SETTINGS);
	}

	private function dateTimeSpinner_changeHandler(event:Event):Void
	{
		trace("DateTimeSpinner change:", this._dateTimeSpinner.value);
	}
	
}