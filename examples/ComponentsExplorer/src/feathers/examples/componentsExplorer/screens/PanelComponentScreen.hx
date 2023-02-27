package feathers.examples.componentsExplorer.screens;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.Panel;
import feathers.controls.PanelScreen;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;


class PanelComponentScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _panel:Panel;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Panel";
		
		this.layout = new AnchorLayout();
		
		this._panel = new Panel();
		this._panel.title = "Title";
		this._panel.width = 200;
		this._panel.height = 150;
		
		//how the component is positioned in its parent's layout
		var panelLayoutData:AnchorLayoutData = new AnchorLayoutData();
		panelLayoutData.horizontalCenter = 0;
		panelLayoutData.verticalCenter = 0;
		this._panel.layoutData = panelLayoutData;
		
		//the panel's own internal layout
		var panelLayout:VerticalLayout = new VerticalLayout();
		panelLayout.horizontalAlign = HorizontalAlign.CENTER;
		panelLayout.verticalAlign = VerticalAlign.MIDDLE;
		this._panel.layout = panelLayout;
		
		this.addChild(this._panel);
		
		var content:Label = new Label();
		content.text = "This is the Panel's content.";
		content.wordWrap = true;
		this._panel.addChild(content);
		
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
	
}