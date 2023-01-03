package;

import feathers.controls.AutoSizeMode;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.core.PropertyProxy;
import feathers.core.PropertyProxyReal;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.themes.MetalWorksDesktopTheme;
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
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		group.layout = hLayout;
		
		var label:Label = new Label();
		label.text = "Hello World !";
		group.addChild(label);
		
		//var prox:Proxy = new Proxy(new PropertyProxy());
		//var prox:Proxy = new Proxy();
		//prox["plop"] = true;
		//prox.test = 123;
		//trace(prox.test);
		//trace(prox["plop"]);
		
		var data:Dynamic = {test:123, plop:true, blop:"blip"};
		var prox:PropertyProxy = PropertyProxy.fromObject(data);
		//trace(prox.test);
		//trace(prox.plop);
		//trace(prox.blop);
		//trace(Std.isOfType(prox, PropertyProxyReal));
		
		for (n in prox)
		{
			trace(n);
		}
	}
	
}