package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PageIndicator;
import feathers.starling.controls.PanelScreen;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class PageIndicatorScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _pageIndicator:PageIndicator;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Page Indicator";
		
		this.layout = new AnchorLayout();
		
		this._pageIndicator = new PageIndicator();
		this._pageIndicator.pageCount = 5;
		this._pageIndicator.addEventListener(Event.CHANGE, pageIndicator_changeHandler);
		var pageIndicatorLayoutData:AnchorLayoutData = new AnchorLayoutData();
		pageIndicatorLayoutData.left = 0;
		pageIndicatorLayoutData.right = 0;
		pageIndicatorLayoutData.verticalCenter = 0;
		this._pageIndicator.layoutData = pageIndicatorLayoutData;
		this.addChild(this._pageIndicator);
		
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

	private function pageIndicator_changeHandler(event:Event):Void
	{
		trace("page indicator change:", this._pageIndicator.selectedIndex);
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
}