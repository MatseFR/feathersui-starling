package feathers.starling.examples.layoutExplorer.data;
import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;

class TiledRowsLayoutSettings 
{
	public function new() 
	{
		
	}
	
	public var paging:String = Direction.NONE;
	public var itemCount:Int = 75;
	public var requestedColumnCount:Int = 0;
	public var horizontalAlign:String = HorizontalAlign.LEFT;
	public var verticalAlign:String = VerticalAlign.TOP;
	public var tileHorizontalAlign:String = HorizontalAlign.LEFT;
	public var tileVerticalAlign:String = VerticalAlign.TOP;
	public var horizontalGap:Float = 2;
	public var verticalGap:Float = 2;
	public var paddingTop:Float = 0;
	public var paddingRight:Float = 0;
	public var paddingBottom:Float = 0;
	public var paddingLeft:Float = 0;
}