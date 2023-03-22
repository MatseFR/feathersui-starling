package feathers.examples.navigator.screens;

import feathers.controls.Button;
import feathers.controls.PanelScreen;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import starling.events.Event;

class ScreenA extends PanelScreen 
{
	public function new() 
	{
		super();
		this.title = "Screen A";
	}
	
	override function initialize():Void
	{
		super.initialize();
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.gap = 10;
		this.layout = layout;
		
		var pushB1Button:Button = new Button();
		pushB1Button.label = "Push Screen B1";
		pushB1Button.layoutData = new VerticalLayoutData(50);
		pushB1Button.addEventListener(Event.TRIGGERED, pushB1Button_triggeredHandler);
		this.addChild(pushB1Button);
	}

	private function pushB1Button_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}
}