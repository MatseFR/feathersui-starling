package feathers.examples.navigator.screens;

import feathers.controls.Button;
import feathers.controls.PanelScreen;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import starling.events.Event;

class ScreenB1 extends PanelScreen 
{
	public function new() 
	{
		super();
		this.title = "Screen B1";
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
		
		var pushCButton:Button = new Button();
		pushCButton.label = "Push Screen C";
		pushCButton.layoutData = new VerticalLayoutData(50);
		pushCButton.addEventListener(Event.TRIGGERED, pushCButton_triggeredHandler);
		this.addChild(pushCButton);
		
		var replaceWithB2Button:Button = new Button();
		replaceWithB2Button.label = "Replace With Screen B2";
		replaceWithB2Button.layoutData = new VerticalLayoutData(50);
		replaceWithB2Button.addEventListener(Event.TRIGGERED, replaceWithB2Button_triggeredHandler);
		this.addChild(replaceWithB2Button);
	}
	
	private function popToAButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.CANCEL);
	}

	private function pushCButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}

	private function replaceWithB2Button_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.CHANGE);
	}
}