package feathers.starling.examples.navigator.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.PanelScreen;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.layout.VerticalLayoutData;
import starling.events.Event;

class ScreenB2 extends PanelScreen 
{
	public function new() 
	{
		super();
		this.title = "Screen B2";
	}
	
	override function initialize():Void
	{
		super.initialize();
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.gap = 10;
		this.layout = layout;
		
		var popToAButton:Button = new Button();
		popToAButton.label = "Pop to Screen A";
		popToAButton.layoutData = new VerticalLayoutData(50);
		popToAButton.addEventListener(Event.TRIGGERED, popToAButton_triggeredHandler);
		this.addChild(popToAButton);
	}

	private function popToAButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.CANCEL);
	}
}