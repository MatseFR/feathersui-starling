package feathers.examples.componentsExplorer.screens;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.ToggleSwitch;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.core.FeathersControl;
import feathers.data.ArrayCollection;
import feathers.examples.componentsExplorer.data.EmbeddedAssets;
import feathers.examples.componentsExplorer.data.ItemRendererSettings;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.system.DeviceCapabilities;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

class ItemRendererScreen extends PanelScreen 
{
	public static inline var SHOW_SETTINGS:String = "showSettings";
	
	public function new() 
	{
		super();
	}
	
	private var _list:List;
	private var _listItem:Dynamic;
	
	public var settings(get, set):ItemRendererSettings;
	private var _settings:ItemRendererSettings;
	private function get_settings():ItemRendererSettings { return this._settings; }
	private function set_settings(value:ItemRendererSettings):ItemRendererSettings
	{
		if (this._settings == value)
		{
			return value;
		}
		this._settings = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._settings;
	}
	
	override public function dispose():Void
	{
		//icon and accessory display objects in the list's data provider
		//won't be automatically disposed because feathers cannot know if
		//they need to be used again elsewhere or not. we need to dispose
		//them manually.
		this._list.dataProvider.dispose(disposeItemIconOrAccessory);
		
		//never forget to call super.dispose() because you don't want to
		//create a memory leak!
		super.dispose();
	}

	override function initialize():Void
	{
		//never forget to call super.initialize()!
		super.initialize();
		
		this.title = "Item Renderer";
		
		this.layout = new AnchorLayout();
		
		this._list = new List();
		
		this._listItem = { text: "Primary Text" };
		this._list.itemRendererFactory = this.customItemRendererFactory;
		this._list.dataProvider = new ArrayCollection([this._listItem]);
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._list.isSelectable = false;
		this._list.clipContent = false;
		this._list.autoHideBackground = true;
		this.addChild(this._list);
		
		this.headerFactory = this.customHeaderFactory;
		
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this.backButtonHandler = this.onBackButton;
		}
	}
	
	private function customItemRendererFactory():IListItemRenderer
	{
		var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
		itemRenderer.labelField = "text";
		if (this.settings.hasIcon)
		{
			switch (this.settings.iconType)
			{
				case ItemRendererSettings.ICON_ACCESSORY_TYPE_LABEL:
					this._listItem.iconText = "Icon Text";
					itemRenderer.iconLabelField = "iconText";
					
					//clear these in case this setting has changed
					Reflect.deleteField(this._listItem, "iconTexture");
					Reflect.deleteField(this._listItem, "icon");
				
				case ItemRendererSettings.ICON_ACCESSORY_TYPE_TEXTURE:
					this._listItem.iconTexture = EmbeddedAssets.SKULL_ICON_LIGHT;
					itemRenderer.iconSourceField = "iconTexture";
					
					//clear these in case this setting has changed
					Reflect.deleteField(this._listItem, "iconText");
					Reflect.deleteField(this._listItem, "icon");
				
				default:
				{
					this._listItem.icon = new ToggleSwitch();
					itemRenderer.iconField = "icon";
					
					//clear these in case this setting has changed
					Reflect.deleteField(this._listItem, "iconText");
					Reflect.deleteField(this._listItem, "iconTexture");
					
				}
			}
			itemRenderer.iconPosition = this.settings.iconPosition;
		}
		if (this.settings.hasAccessory)
		{
			switch(this.settings.accessoryType)
			{
				case ItemRendererSettings.ICON_ACCESSORY_TYPE_LABEL:
					this._listItem.accessoryText = "Accessory Text";
					itemRenderer.accessoryLabelField = "accessoryText";
					
					//clear these in case this setting has changed
					Reflect.deleteField(this._listItem, "accessoryTexture");
					Reflect.deleteField(this._listItem, "accessory");
				
				case ItemRendererSettings.ICON_ACCESSORY_TYPE_TEXTURE:
					this._listItem.accessoryTexture = EmbeddedAssets.SKULL_ICON_LIGHT;
					itemRenderer.accessorySourceField = "accessoryTexture";
				
				default:
					this._listItem.accessory = new ToggleSwitch();
					itemRenderer.accessoryField = "accessory";
					
					//clear these in case this setting has changed
					Reflect.deleteField(this._listItem, "accessoryText");
					Reflect.deleteField(this._listItem, "accessoryTexture");
			}
			itemRenderer.accessoryPosition = this.settings.accessoryPosition;
		}
		if (this.settings.useInfiniteGap)
		{
			itemRenderer.gap = Math.POSITIVE_INFINITY;
		}
		else
		{
			itemRenderer.gap = 12;
		}
		if (this.settings.useInfiniteAccessoryGap)
		{
			itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		}
		else
		{
			itemRenderer.accessoryGap = 12;
		}
		itemRenderer.horizontalAlign = this.settings.horizontalAlign;
		itemRenderer.verticalAlign = this.settings.verticalAlign;
		itemRenderer.layoutOrder = this.settings.layoutOrder;
		return itemRenderer;
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
		var settingsButton:Button = new Button();
		settingsButton.label = "Settings";
		settingsButton.addEventListener(Event.TRIGGERED, settingsButton_triggeredHandler);
		header.rightItems = 
		[
			settingsButton
		];
		return header;
	}

	private function disposeItemIconOrAccessory(item:Dynamic):Void
	{
		if (Reflect.hasField(item, "icon"))
		{
			cast(item.icon, DisplayObject).dispose();
		}
		if (Reflect.hasField(item, "accessory"))
		{
			cast(item.accessory, DisplayObject).dispose();
		}
	}

	private function onBackButton():Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}

	private function settingsButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(SHOW_SETTINGS);
	}
	
}