package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.ScrollPolicy;
import feathers.starling.controls.TextArea;
import feathers.starling.controls.TextInput;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class TextInputScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _input:TextInput;
	private var _disabledInput:TextInput;
	private var _passwordInput:TextInput;
	private var _errorInput:TextInput;
	private var _notEditableInput:TextInput;
	private var _searchInput:TextInput;
	private var _textArea:TextArea;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Text Input";
		
		var verticalLayout:VerticalLayout = new VerticalLayout();
		verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
		verticalLayout.verticalAlign = VerticalAlign.TOP;
		verticalLayout.padding = 12;
		verticalLayout.gap = 8;
		this.layout = verticalLayout;
		
		this.verticalScrollPolicy = ScrollPolicy.ON;
		
		this._input = new TextInput();
		this._input.prompt = "Normal Text Input";
		this.addChild(this._input);
		
		this._disabledInput = new TextInput();
		this._disabledInput.prompt = "Disabled Input";
		this._disabledInput.isEnabled = false;
		this.addChild(this._disabledInput);
		
		this._searchInput = new TextInput();
		this._searchInput.styleNameList.add(TextInput.ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT);
		this._searchInput.prompt = "Search Input";
		this.addChild(this._searchInput);
		
		this._passwordInput = new TextInput();
		this._passwordInput.prompt = "Password Input";
		this._passwordInput.displayAsPassword = true;
		this.addChild(this._passwordInput);
		
		this._errorInput = new TextInput();
		this._errorInput.prompt = "Error Input";
		this._errorInput.errorString = "Oh, no! It's an error!";
		this.addChild(this._errorInput);
		
		this._notEditableInput = new TextInput();
		this._notEditableInput.text = "Not Editable";
		this._notEditableInput.isEditable = false;
		this.addChild(this._notEditableInput);
		
		//note: using TextArea on mobile generally isn't recommended.
		//consider TextInput with a multiline StageTextTextEditor instead.
		this._textArea = new TextArea();
		this.addChild(this._textArea);
		
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