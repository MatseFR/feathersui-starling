package feathers.examples.layoutExplorer.data;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;

class SlideShowLayoutSettings 
{
	public function new() 
	{
		
	}
	
	public var itemCount:Int = 5;
	public var horizontalAlign:String = HorizontalAlign.CENTER;
	public var verticalAlign:String = VerticalAlign.MIDDLE;
	public var paddingTop:Float = 0;
	public var paddingRight:Float = 0;
	public var paddingBottom:Float = 0;
	public var paddingLeft:Float = 0;
}