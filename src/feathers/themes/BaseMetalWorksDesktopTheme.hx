/*
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package feathers.themes;
import openfl.geom.Rectangle;

/**
 * The base class for the "Metal Works" theme for desktop Feathers apps.
 * Handles everything except asset loading, which is left to subclasses.
 *
 * @see MetalWorksDesktopTheme
 * @see MetalWorksDesktopThemeWithAssetManager
 */
class BaseMetalWorksDesktopTheme extends StyleNameFunctionTheme 
{
	/**
	 * The name of the embedded font used by controls in this theme. Comes
	 * in normal and bold weights.
	 */
	public static inline var FONT_NAME:String = "SourceSansPro";
	
	private static inline var PRIMARY_BACKGROUND_COLOR:Int = 0x4a4137;
	private static inline var LIGHT_TEXT_COLOR:Int = 0xe5e5e5;
	private static inline var DARK_TEXT_COLOR:Int = 0x1a1816;
	private static inline var SELECTED_TEXT_COLOR:Int = 0xff9900;
	private static inline var LIGHT_DISABLED_TEXT_COLOR:Int = 0x8a8a8a;
	private static inline var DARK_DISABLED_TEXT_COLOR:Int = 0x383430;
	private static inline var GROUPED_LIST_HEADER_BACKGROUND_COLOR:Int = 0x292523;
	private static inline var GROUPED_LIST_FOOTER_BACKGROUND_COLOR:Int = 0x292523;
	private static inline var SCROLL_BAR_TRACK_COLOR:Int = 0x1a1816;
	private static inline var SCROLL_BAR_TRACK_DOWN_COLOR:Int = 0xff7700;
	private static inline var TEXT_SELECTION_BACKGROUND_COLOR:Int = 0x574f46;
	private static inline var MODAL_OVERLAY_COLOR:Int = 0x29241e;
	private static inline var MODAL_OVERLAY_ALPHA:Float = 0.8;
	private static inline var DRAWER_OVERLAY_COLOR:Int = 0x29241e;
	private static inline var DRAWER_OVERLAY_ALPHA:Float = 0.4;
	private static inline var VIDEO_OVERLAY_COLOR:Int = 0x1a1816;
	private static inline var VIDEO_OVERLAY_ALPHA:Float = 0.2;
	private static inline var DATA_GRID_COLUMN_OVERLAY_COLOR:Int = 0x383430;
	private static inline var DATA_GRID_COLUMN_OVERLAY_ALPHA:Float = 0.4;

	private static var DEFAULT_SCALE9_GRID:Rectangle = new Rectangle(3, 3, 1, 1);
	private static var SIMPLE_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 1, 1);
	private static var BUTTON_SCALE9_GRID:Rectangle = new Rectangle(3, 3, 1, 16);
	private static var TOGGLE_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(4, 4, 1, 14);
	private static var SCROLL_BAR_STEP_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(3, 3, 6, 6);
	private static var VOLUME_SLIDER_TRACK_SCALE9_GRID:Rectangle = new Rectangle(12, 12, 1, 1);
	private static var BACK_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(13, 0, 1, 22);
	private static var FORWARD_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(3, 0, 1, 22);
	private static var FOCUS_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 1, 1);
	private static var TAB_SCALE9_GRID:Rectangle = new Rectangle(7, 7, 1, 11);
	private static var HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID:Rectangle = new Rectangle(5, 0, 14, 10);
	private static var VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID:Rectangle = new Rectangle(0, 5, 10, 14);
	private static var DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 2, 4);
	private static var DATA_GRID_VERTICAL_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 1, 4);
	private static var DATA_GRID_COLUMN_RESIZE_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 3, 28);
	private static var DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 3, 3);
	
	private static var ITEM_RENDERER_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 1, 1);
	private static var ITEM_RENDERER_SELECTED_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 1, 22);
	private static var HEADER_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 128, 64);
	
	/**
	 * @private
	 * The theme's custom style name for the increment button of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON:String = "metalworks-desktop-horizontal-scroll-bar-increment-button";
	
	/**
	 * @private
	 * The theme's custom style name for the decrement button of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON:String = "metalworks-desktop-horizontal-scroll-bar-decrement-button";
	
	/**
	 * @private
	 * The theme's custom style name for the thumb of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_THUMB:String = "metalworks-desktop-horizontal-scroll-bar-thumb";
	
	/**
	 * @private
	 * The theme's custom style name for the minimum track of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MINIMUM_TRACK:String = "metalworks-desktop-horizontal-scroll-bar-minimum-track";
	
	/**
	 * @private
	 * The theme's custom style name for the maximum track of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MAXIMUM_TRACK:String = "metalworks-desktop-horizontal-scroll-bar-maximum-track";
	
	/**
	 * @private
	 * The theme's custom style name for the increment button of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON:String = "metalworks-desktop-vertical-scroll-bar-increment-button";
	
	/**
	 * @private
	 * The theme's custom style name for the decrement button of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON:String = "metalworks-desktop-vertical-scroll-bar-decrement-button";
	
	/**
	 * @private
	 * The theme's custom style name for the thumb of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_THUMB:String = "metalworks-desktop-vertical-scroll-bar-thumb";
	
	/**
	 * @private
	 * The theme's custom style name for the minimum track of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MINIMUM_TRACK:String = "metalworks-desktop-vertical-scroll-bar-minimum-track";
	
	/**
	 * @private
	 * The theme's custom style name for the maximum track of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MAXIMUM_TRACK:String = "metalworks-desktop-vertical-scroll-bar-maximum-track";
	
	/**
	 * @private
	 * The theme's custom style name for the thumb of a horizontal SimpleScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB:String = "metalworks-desktop-horizontal-simple-scroll-bar-thumb";
	
	/**
	 * @private
	 * The theme's custom style name for the thumb of a vertical SimpleScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB:String = "metalworks-desktop-vertical-simple-scroll-bar-thumb";
	
	/**
	 * @private
	 * The theme's custom style name for the minimum track of a horizontal slider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK:String = "metalworks-desktop-horizontal-slider-minimum-track";
	
	/**
	 * @private
	 * The theme's custom style name for the maximum track of a horizontal slider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK:String = "metalworks-desktop-horizontal-slider-maximum-track";
	
	/**
	 * @private
	 * The theme's custom style name for the minimum track of a vertical slider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK:String = "metalworks-desktop-vertical-slider-minimum-track";
	
	/**
	 * @private
	 * The theme's custom style name for the maximum track of a vertical slider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK:String = "metalworks-desktop-vertical-slider-maximum-track";
	
	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_THUMB:String = "metalworks-desktop-pop-up-volume-slider-thumb";
	
	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK:String = "metalworks-desktop-pop-up-volume-slider-minimum-track";
	
	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER:String = "metalworks-desktop-date-time-spinner-list-item-renderer";
	
	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON:String = "metalworks-desktop-alert-button-group-button";
	
	/**
	 * @private
	 * The theme's custom style name for the action buttons of a toast.
	 */
	private static inline var THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON:String = "metal-works-mobile-toast-actions-button";
	
	/**
	 * The default global text renderer factory for this theme creates a
	 * TextBlockTextRenderer.
	 */
	//private static function textRendererFactory():TextBlockTextRenderer
	//{
		//return new TextBlockTextRenderer();
	//}

	/**
	 * The default global text editor factory for this theme creates a
	 * TextBlockTextEditor.
	 */
	//private static function textEditorFactory():TextBlockTextEditor
	//{
		//return new TextBlockTextEditor();
	//}

	/**
	 * This theme's scroll bar type is ScrollBar.
	 */
	private static function scrollBarFactory():ScrollBar
	{
		return new ScrollBar();
	}

	private static function popUpOverlayFactory():DisplayObject
	{
		var quad:Quad = new Quad(100, 100, MODAL_OVERLAY_COLOR);
		quad.alpha = MODAL_OVERLAY_ALPHA;
		return quad;
	}

	private static function pickerListButtonFactory():ToggleButton
	{
		return new ToggleButton();
	}
	
	public function new() 
	{
		super();
		
	}
	
}