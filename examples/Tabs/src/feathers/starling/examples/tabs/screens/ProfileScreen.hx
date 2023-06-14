package feathers.starling.examples.tabs.screens;

import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.Label;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.controls.Screen;
import feathers.starling.examples.tabs.themes.StyleNames;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;

class ProfileScreen extends Screen 
{
	public function new() 
	{
		super();
	}
	
	private var _image:ImageLoader;
	private var _nameLabel:Label;
	private var _emailLabel:Label;

	override function initialize():Void
	{
		super.initialize();
		
		var mainLayout:VerticalLayout = new VerticalLayout();
		mainLayout.horizontalAlign = HorizontalAlign.CENTER;
		mainLayout.verticalAlign = VerticalAlign.MIDDLE;
		mainLayout.padding = 10;
		this.layout = mainLayout;
		
		var header:LayoutGroup = new LayoutGroup();
		var headerLayout:VerticalLayout = new VerticalLayout();
		headerLayout.gap = 4;
		headerLayout.horizontalAlign = HorizontalAlign.CENTER;
		header.layout = headerLayout;
		this.addChild(header);
		
		this._image = new ImageLoader();
		this._image.styleNameList.add(StyleNames.LARGE_PROFILE_IMAGE);
		this._image.source = "https://matse.skwatt.com/haxe/starling/feathers/examples/Tabs/images/men67.jpg";
		header.addChild(this._image);
		
		this._nameLabel = new Label();
		this._nameLabel.styleNameList.add(Label.ALTERNATE_STYLE_NAME_HEADING);
		this._nameLabel.text = "Flynn Reynolds";
		header.addChild(this._nameLabel);
		
		this._emailLabel = new Label();
		this._emailLabel.text = "flynn.reynolds84@example.com";
		this.addChild(this._emailLabel);
	}
}