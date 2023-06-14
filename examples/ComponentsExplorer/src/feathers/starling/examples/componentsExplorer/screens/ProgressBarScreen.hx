package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.ProgressBar;
import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.HorizontalLayout;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.system.DeviceCapabilities;
import feathers.starling.utils.math.MathUtils;
import starling.animation.Tween;
import starling.core.Starling;
import starling.events.Event;

class ProgressBarScreen extends PanelScreen 
{

	public function new() 
	{
		super();
	}
	
	private var _horizontalProgress:ProgressBar;
	private var _verticalProgress:ProgressBar;

	private var _horizontalProgressTween:Tween;
	private var _verticalProgressTween:Tween;
	
	override function initialize():Void 
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Progress Bar";
		
		var layout:HorizontalLayout = new HorizontalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.padding = 12;
		layout.gap = 12;
		this.layout = layout;
		
		this._horizontalProgress = new ProgressBar();
		this._horizontalProgress.direction = Direction.HORIZONTAL;
		this._horizontalProgress.minimum = 0;
		this._horizontalProgress.maximum = 1;
		this._horizontalProgress.value = 0;
		this.addChild(this._horizontalProgress);
		
		this._verticalProgress = new ProgressBar();
		this._verticalProgress.direction = Direction.VERTICAL;
		this._verticalProgress.minimum = 0;
		this._verticalProgress.maximum = 100;
		this._verticalProgress.value = 0;
		this.addChild(this._verticalProgress);
		
		this.headerFactory = this.customHeaderFactory;
		
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this.backButtonHandler = this.onBackButton;
		}
		
		this._horizontalProgressTween = new Tween(this._horizontalProgress, 5);
		this._horizontalProgressTween.animate("value", 1);
		this._horizontalProgressTween.repeatCount = MathUtils.INT_MAX;
		Starling.currentJuggler.add(this._horizontalProgressTween);
		
		this._verticalProgressTween = new Tween(this._verticalProgress, 8);
		this._verticalProgressTween.animate("value", 100);
		this._verticalProgressTween.repeatCount = MathUtils.INT_MAX;
		Starling.currentJuggler.add(this._verticalProgressTween);
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
		if (this._horizontalProgressTween != null)
		{
			Starling.currentJuggler.remove(this._horizontalProgressTween);
			this._horizontalProgressTween = null;
		}
		if (this._verticalProgressTween != null)
		{
			Starling.currentJuggler.remove(this._verticalProgressTween);
			this._verticalProgressTween = null;
		}
		this.dispatchEventWith(Event.COMPLETE);
	}
	
	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
}