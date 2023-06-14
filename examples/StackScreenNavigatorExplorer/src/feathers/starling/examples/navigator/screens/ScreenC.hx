package feathers.starling.examples.navigator.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.PanelScreen;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.layout.VerticalLayoutData;
import starling.events.Event;

class ScreenC extends PanelScreen 
{

	public function new() 
	{
		super();
		this.title = "Screen C";
	}
	
	override function initialize():Void
	{
		super.initialize();
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.gap = 10;
		this.layout = layout;
		
		var popToB1Button:Button = new Button();
		popToB1Button.label = "Pop to Screen B";
		popToB1Button.layoutData = new VerticalLayoutData(50);
		popToB1Button.addEventListener(Event.TRIGGERED, popToB1Button_triggeredHandler);
		this.addChild(popToB1Button);
		
		var popToRootButton:Button = new Button();
		popToRootButton.label = "Pop to Root";
		popToRootButton.layoutData = new VerticalLayoutData(50);
		popToRootButton.addEventListener(Event.TRIGGERED, popToRootButton_triggeredHandler);
		this.addChild(popToRootButton);
	}

	private function popToB1Button_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.CANCEL);
	}

	private function popToRootButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.CLOSE);
	}
}