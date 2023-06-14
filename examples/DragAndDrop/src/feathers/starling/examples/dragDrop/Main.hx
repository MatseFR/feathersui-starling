package feathers.starling.examples.dragDrop;

import feathers.starling.controls.Button;
import feathers.starling.controls.Label;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.dragDrop.IDragSource;
import feathers.starling.dragDrop.IDropTarget;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.themes.MetalWorksDesktopTheme;
import openfl.Lib;
import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;

class Main extends LayoutGroup implements IDragSource implements IDropTarget
{
	private static inline var DRAG_FORMAT:String = "draggableQuad";
	
	public function new() 
	{
		//set up the theme right away!
		new MetalWorksDesktopTheme();
		//this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		super();
	}
	
	private var _draggableQuad:Quad;
	private var _dragSource:DragSource;
	private var _dropTarget:DropTarget;
	private var _resetButton:Button;
	
	private function reset():Void
	{
		this._draggableQuad.x = 40;
		this._draggableQuad.y = 40;
		this._dragSource.addChild(this._draggableQuad);
	}

	override function initialize():Void
	{
		super.initialize();
		
		this.layout = new AnchorLayout();
		
		var aData:AnchorLayoutData;
		
		var instructions:Label = new Label();
		instructions.text = "Drag the square from the left container to the right container.";
		instructions.layoutData = new AnchorLayoutData(40, null, null, null, 0);
		this.addChild(instructions);
		
		this._resetButton = new Button();
		this._resetButton.label = "Reset";
		this._resetButton.layoutData = new AnchorLayoutData(null, null, 40, null, 0);
		this._resetButton.addEventListener(Event.TRIGGERED, resetButton_triggeredHandler);
		this.addChild(this._resetButton);
		
		this._draggableQuad = new Quad(100, 100, 0xff8800);
		
		this._dragSource = new DragSource(DRAG_FORMAT);
		aData = new AnchorLayoutData(40, null, 40, 80);
		aData.percentWidth = 30;
		aData.topAnchorDisplayObject = instructions;
		aData.bottomAnchorDisplayObject = this._resetButton;
		this._dragSource.layoutData = aData;
		this.addChild(this._dragSource);
		
		this._dropTarget = new DropTarget(DRAG_FORMAT);
		aData = new AnchorLayoutData(40, 80, 40, null);
		aData.percentWidth = 30;
		aData.topAnchorDisplayObject = instructions;
		aData.bottomAnchorDisplayObject = this._resetButton;
		this._dropTarget.layoutData = aData;
		this.addChild(this._dropTarget);
		
		this.reset();
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
	}
	
	private function resetButton_triggeredHandler(event:Event):Void
	{
		this.reset();
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
	}
	
	private function updateViewPort(width:Int, height:Int):Void
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		stage.stageWidth = Std.int(width / scale);
		stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width = width;//stage.stageWidth * scale;
		current.viewPort.height = height;//stage.stageHeight * scale;
	}
}