package feathers.examples.componentsExplorer.screens;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.PanelScreen;
import feathers.controls.TextCallout;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;
import feathers.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class TextCalloutScreen extends PanelScreen 
{
	private static inline var MESSAGE:String = "Thank you for trying Feathers.\nHappy coding.";
	
	public function new() 
	{
		super();
	}
	
	private var _rightButton:Button;
	private var _bottomButton:Button;
	private var _topButton:Button;
	private var _leftButton:Button;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = " Text Callout";
		
		this.layout = new AnchorLayout();
		
		this._rightButton = new Button();
		this._rightButton.label = "Right";
		this._rightButton.addEventListener(Event.TRIGGERED, rightButton_triggeredHandler);
		var rightButtonLayoutData:AnchorLayoutData = new AnchorLayoutData();
		rightButtonLayoutData.top = 12;
		rightButtonLayoutData.left = 12;
		this._rightButton.layoutData = rightButtonLayoutData;
		this.addChild(this._rightButton);
		
		this._bottomButton = new Button();
		this._bottomButton.label = "Bottom";
		this._bottomButton.addEventListener(Event.TRIGGERED, bottomButton_triggeredHandler);
		var bottomButtonLayoutData:AnchorLayoutData = new AnchorLayoutData();
		bottomButtonLayoutData.top = 12;
		bottomButtonLayoutData.right = 12;
		this._bottomButton.layoutData = bottomButtonLayoutData;
		this.addChild(this._bottomButton);
		
		this._topButton = new Button();
		this._topButton.label = "Top";
		this._topButton.addEventListener(Event.TRIGGERED, topButton_triggeredHandler);
		var topButtonLayoutData:AnchorLayoutData = new AnchorLayoutData();
		topButtonLayoutData.bottom = 12;
		topButtonLayoutData.left = 12;
		this._topButton.layoutData = topButtonLayoutData;
		this.addChild(this._topButton);
		
		this._leftButton = new Button();
		this._leftButton.label = "Left";
		this._leftButton.addEventListener(Event.TRIGGERED, leftButton_triggeredHandler);
		var leftButtonLayoutData:AnchorLayoutData = new AnchorLayoutData();
		leftButtonLayoutData.bottom = 12;
		leftButtonLayoutData.right = 12;
		this._leftButton.layoutData = leftButtonLayoutData;
		this.addChild(this._leftButton);
		
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

	private function rightButton_triggeredHandler(event:Event):Void
	{
		TextCallout.show(MESSAGE, this._rightButton, [RelativePosition.RIGHT]);
	}

	private function bottomButton_triggeredHandler(event:Event):Void
	{
		TextCallout.show(MESSAGE, this._bottomButton,[RelativePosition.BOTTOM]);
	}

	private function topButton_triggeredHandler(event:Event):Void
	{
		TextCallout.show(MESSAGE, this._topButton, [RelativePosition.TOP]);
	}

	private function leftButton_triggeredHandler(event:Event):Void
	{
		TextCallout.show(MESSAGE, this._leftButton, [RelativePosition.LEFT]);
	}
	
}