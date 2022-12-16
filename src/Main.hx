package;

import feathers.core.PropertyProxy;
import feathers.core.Proxy;
import feathers.utils.ReverseIterator;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author Matse
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();
		
		// Assets:
		// openfl.Assets.getBitmapData("img/assetname.jpg");
		
		//var test:Float = Math.NaN;
		//if (test != test)
		//{
			//trace("ok");
		//}
		//
		//for (i in new ReverseIterator(5, 0)) {
			//trace(i);
		//}
		
		var proxy:Proxy = new Proxy();
		proxy.setProperty("prop1", "pouet");
		proxy.setProperty("prop2", true);
		
		proxy.property = "value";
		
		for (p in proxy)
		{
			trace(p);
		}
	}

}
