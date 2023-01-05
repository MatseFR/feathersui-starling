package;

import feathers.controls.AutoSizeMode;
import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Radio;
import feathers.controls.ScrollContainer;
import feathers.controls.Slider;
import feathers.controls.ToggleButton;
import feathers.core.PropertyProxy;
import feathers.core.PropertyProxyReal;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.themes.MetalWorksDesktopTheme;
import feathers.utils.math.MathUtils;
import starling.display.Sprite;
import starling.events.Event;

/**
 * ...
 * @author Matse
 */
class Testing extends Sprite 
{

	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function addedToStageHandler(evt:Event):Void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		var theme:MetalWorksDesktopTheme = new MetalWorksDesktopTheme();
		
		var group:LayoutGroup = new LayoutGroup();
		group.autoSizeMode = AutoSizeMode.STAGE;
		addChild(group);
		group.validate();
		
		//var hLayout:HorizontalLayout = new HorizontalLayout();
		//hLayout.horizontalAlign = HorizontalAlign.CENTER;
		//hLayout.verticalAlign = VerticalAlign.MIDDLE;
		//group.layout = hLayout;
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.CENTER;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		vLayout.gap = 8;
		group.layout = vLayout;
		
		var container:ScrollContainer = new ScrollContainer();
		//vLayout.horizontalAlign = HorizontalAlign.CENTER;
		//vLayout.verticalAlign = VerticalAlign.MIDDLE;
		//vLayout.paddingLeft = vLayout.paddingRight = 8;
		//vLayout.gap = 24;
		//container.layout = vLayout;
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = 8;
		container.layout = hLayout;
		container.height = 100;
		container.width = 180;
		group.addChild(container);
		
		var label:Label = new Label();
		label.text = "Hello World !";
		//label.height = 20;
		//label.width = 100;
		//label.x = 200;
		//label.y = 200;
		//addChild(label);
		//label.validate();
		container.addChild(label);
		
		var btn:Button = new Button();
		var test = btn.defaultLabelProperties;
		trace(test);
		btn.label = "yep";
		container.addChild(btn);
		
		var toggle:ToggleButton = new ToggleButton();
		toggle.label = "toggle";
		container.addChild(toggle);
		
		var check:Check = new Check();
		check.label = "check";
		container.addChild(check);
		
		var radio:Radio = new Radio();
		radio.label = "cool!";
		container.addChild(radio);
		
		radio = new Radio();
		radio.label = "nice!";
		container.addChild(radio);
		
		var slider:Slider = new Slider();
		slider.minimum = 0;
		slider.maximum = 10;
		//slider.step = 1;
		container.addChild(slider);
		
		//var data:Dynamic = {test:123, plop:true, blop:"blip"};
		//var prox:PropertyProxy = PropertyProxy.fromObject(data);
		//prox.sub.pouet = "whatever";
		//trace(prox.test);
		//trace(prox.plop);
		//trace(prox.blop);
		//trace(Std.isOfType(prox, PropertyProxyReal));
		
		//for (n in prox)
		//{
			//trace(n);
		//}
		
	}
	
}