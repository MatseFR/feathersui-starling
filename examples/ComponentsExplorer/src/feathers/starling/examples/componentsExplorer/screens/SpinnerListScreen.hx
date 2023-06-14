package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.SpinnerList;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class SpinnerListScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _list:SpinnerList;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Spinner List";
		
		this.layout = new AnchorLayout();
		
		this._list = new SpinnerList();
		this._list.dataProvider = new ArrayCollection(
		[
			{ text: "Aardvark" },
			{ text: "Alligator" },
			{ text: "Alpaca" },
			{ text: "Anteater" },
			{ text: "Baboon" },
			{ text: "Bear" },
			{ text: "Beaver" },
			{ text: "Canary" },
			{ text: "Cat" },
			{ text: "Deer" },
			{ text: "Dingo" },
			{ text: "Dog" },
			{ text: "Dolphin" },
			{ text: "Donkey" },
			{ text: "Dragonfly" },
			{ text: "Duck" },
			{ text: "Dung Beetle" },
			{ text: "Eagle" },
			{ text: "Earthworm" },
			{ text: "Eel" },
			{ text: "Elk" },
			{ text: "Fox" },
		]);
		this._list.typicalItem = {text: "Item 1000"};
		this._list.itemRendererFactory = function():IListItemRenderer
		{
			var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
			
			//enable the quick hit area to optimize hit tests when an item
			//is only selectable and doesn't have interactive children.
			renderer.isQuickHitAreaEnabled = true;
			
			renderer.labelField = "text";
			return renderer;
		};
		this._list.addEventListener(Event.CHANGE, list_changeHandler);
		
		var listLayoutData:AnchorLayoutData = new AnchorLayoutData();
		listLayoutData.left = 0;
		listLayoutData.right = 0;
		listLayoutData.verticalCenter = 0;
		this._list.layoutData = listLayoutData;
		
		this.addChild(this._list);
		
		this.headerFactory = this.customHeaderFactory;
		
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this.backButtonHandler = this.onBackButton;
		}
		
		this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
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

	private function transitionInCompleteHandler(event:Event):Void
	{
		this._list.revealScrollBars();
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}

	private function list_changeHandler(event:Event):Void
	{
		trace("SpinnerList change:", this._list.selectedIndex);
	}
}