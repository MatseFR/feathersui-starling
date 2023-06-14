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
package feathers.starling.themes;
import feathers.starling.controls.Alert;
import feathers.starling.controls.AutoComplete;
import feathers.starling.controls.AutoSizeMode;
import feathers.starling.controls.Button;
import feathers.starling.controls.ButtonGroup;
import feathers.starling.controls.ButtonState;
import feathers.starling.controls.Callout;
import feathers.starling.controls.Check;
import feathers.starling.controls.DataGrid;
import feathers.starling.controls.DateTimeSpinner;
import feathers.starling.controls.Drawers;
import feathers.starling.controls.GroupedList;
import feathers.starling.controls.Header;
import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.Label;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.controls.List;
import feathers.starling.controls.NumericStepper;
import feathers.starling.controls.PageIndicator;
import feathers.starling.controls.PageIndicatorInteractionMode;
import feathers.starling.controls.Panel;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.PickerList;
import feathers.starling.controls.ProgressBar;
import feathers.starling.controls.Radio;
import feathers.starling.controls.ScrollBar;
import feathers.starling.controls.ScrollBarDisplayMode;
import feathers.starling.controls.ScrollContainer;
import feathers.starling.controls.ScrollInteractionMode;
import feathers.starling.controls.ScrollPolicy;
import feathers.starling.controls.ScrollScreen;
import feathers.starling.controls.ScrollText;
import feathers.starling.controls.Scroller;
import feathers.starling.controls.SimpleScrollBar;
import feathers.starling.controls.Slider;
import feathers.starling.controls.SpinnerList;
import feathers.starling.controls.StepperButtonLayoutMode;
import feathers.starling.controls.TabBar;
import feathers.starling.controls.TextArea;
import feathers.starling.controls.TextCallout;
import feathers.starling.controls.TextInput;
import feathers.starling.controls.TextInputState;
import feathers.starling.controls.Toast;
import feathers.starling.controls.ToggleButton;
import feathers.starling.controls.ToggleSwitch;
import feathers.starling.controls.TrackLayoutMode;
import feathers.starling.controls.Tree;
import feathers.starling.controls.popups.DropDownPopUpContentManager;
import feathers.starling.controls.renderers.BaseDefaultItemRenderer;
import feathers.starling.controls.renderers.DefaultDataGridCellRenderer;
import feathers.starling.controls.renderers.DefaultDataGridHeaderRenderer;
import feathers.starling.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.starling.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.controls.renderers.DefaultTreeItemRenderer;
import feathers.starling.controls.text.TextFieldTextEditor;
import feathers.starling.controls.text.TextFieldTextRenderer;
import feathers.starling.core.FeathersControl;
import feathers.starling.core.FocusManager;
import feathers.starling.core.PopUpManager;
import feathers.starling.core.ToolTipManager;
import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.HorizontalLayout;
import feathers.starling.layout.RelativePosition;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.skins.ImageSkin;
import openfl.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Stage;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

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
	public static inline var FONT_NAME:String = "Source Sans Pro";
	
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
	private static function textRendererFactory():TextFieldTextRenderer
	{
		return new TextFieldTextRenderer();
	}
	
	/**
	 * The default global text editor factory for this theme creates a
	 * TextBlockTextEditor.
	 */
	private static function textEditorFactory():TextFieldTextEditor
	{
		return new TextFieldTextEditor();
	}
	
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
	
	/**
	 * A smaller font size for details.
	 */
	private var smallFontSize:Int = 11;
	
	/**
	 * A normal font size.
	 */
	private var regularFontSize:Int = 14;
	
	/**
	 * A larger font size for headers.
	 */
	private var largeFontSize:Int = 18;
	
	/**
	 * The size, in pixels, of major regions in the grid. Used for sizing
	 * containers and larger UI controls.
	 */
	private var gridSize:Int = 32;
	
	/**
	 * The size, in pixels, of minor regions in the grid. Used for larger
	 * padding and gaps.
	 */
	private var gutterSize:Int = 8;
	
	/**
	 * The size, in pixels, of smaller padding and gaps within the major
	 * regions in the grid.
	 */
	private var smallGutterSize:Int = 4;
	
	/**
	 * The size, in pixels, of very smaller padding and gaps.
	 */
	private var extraSmallGutterSize:Int = 2;
	
	/**
	 * The minimum width, in pixels, of some types of buttons.
	 */
	private var buttonMinWidth:Int = 68;
	
	/**
	 * The width, in pixels, of UI controls that span across multiple grid regions.
	 */
	private var wideControlSize:Int = 144;
	
	/**
	 * The width, in pixels, of very large UI controls.
	 */
	private var extraWideControlSize:Int = 210;
	
	/**
	 * The size, in pixels, of a typical UI control.
	 */
	private var controlSize:Int = 26;
	
	/**
	 * The size, in pixels, of smaller UI controls.
	 */
	private var smallControlSize:Int = 12;
	
	/**
	 * The size, in pixels, of a border around any control.
	 */
	private var borderSize:Int = 1;
	
	/**
	 * The size, in pixels, of the focus indicator skin's padding.
	 */
	private var focusPaddingSize:Int = -2;
	
	private var calloutArrowOverlapGap:Int = -2;
	private var calloutBackgroundMinSize:Int = 5;
	private var progressBarFillMinSize:Int = 7;
	private var scrollBarGutterSize:Int = 4;
	private var popUpSize:Int = 336;
	private var popUpVolumeSliderPaddingSize:Int = 10;
	
	/**
	 * The font styles for standard-sized, light text.
	 */
	private var lightFontStyles:TextFormat;
	
	/**
	 * The font styles for standard-sized, dark text.
	 */
	private var darkFontStyles:TextFormat;
	
	/**
	 * The font styles for standard-sized, selected text.
	 */
	private var selectedFontStyles:TextFormat;
	
	/**
	 * The font styles for standard-sized, light, disabled text.
	 */
	private var lightDisabledFontStyles:TextFormat;

	/**
	 * The font styles for light UI text.
	 */
	private var lightUIFontStyles:TextFormat;
	
	/**
	 * The font styles for dark UI text.
	 */
	private var darkUIFontStyles:TextFormat;
	
	/**
	 * The font styles for selected UI text.
	 */
	private var selectedUIFontStyles:TextFormat;
	
	/**
	 * The font styles for light disabled UI text.
	 */
	private var lightDisabledUIFontStyles:TextFormat;
	
	/**
	 * The font styles for light, centered UI text.
	 */
	private var lightCenteredUIFontStyles:TextFormat;
	
	/**
	 * The font styles for light, centered, disabled UI text.
	 */
	private var lightCenteredDisabledUIFontStyles:TextFormat;
	
	/**
	 * The font styles for small, light text.
	 */
	private var smallLightFontStyles:TextFormat;
	
	/**
	 * The font styles for small, light, disabled text.
	 */
	private var smallLightDisabledFontStyles:TextFormat;
	
	/**
	 * The font styles for large, light text.
	 */
	private var largeLightFontStyles:TextFormat;
	
	/**
	 * The font styles for large, dark text.
	 */
	private var largeDarkFontStyles:TextFormat;
	
	/**
	 * The font styles for large, light, disabled text.
	 */
	private var largeLightDisabledFontStyles:TextFormat;
	
	/**
	 * The font styles for dark, disabled UI text.
	 */
	private var darkDisabledUIFontStyles:TextFormat;
	
	/**
	 * ScrollText uses TextField instead of FTE, so it has a separate TextFormat.
	 */
	private var lightScrollTextFontStyles:TextFormat;
	
	/**
	 * ScrollText uses TextField instead of FTE, so it has a separate disabled TextFormat.
	 */
	private var lightDisabledScrollTextFontStyles:TextFormat;
	
	/**
	 * The texture atlas that contains skins for this theme. This base class
	 * does not initialize this member variable. Subclasses are expected to
	 * load the assets somehow and set the <code>atlas</code> member
	 * variable before calling <code>initialize()</code>.
	 */
	private var atlas:TextureAtlas;
	
	private var focusIndicatorSkinTexture:Texture;
	private var headerBackgroundSkinTexture:Texture;
	private var headerPopupBackgroundSkinTexture:Texture;
	private var backgroundSkinTexture:Texture;
	private var backgroundDisabledSkinTexture:Texture;
	private var backgroundFocusedSkinTexture:Texture;
	private var backgroundDangerSkinTexture:Texture;
	private var listBackgroundSkinTexture:Texture;
	private var buttonUpSkinTexture:Texture;
	private var buttonDownSkinTexture:Texture;
	private var buttonDisabledSkinTexture:Texture;
	private var toggleButtonSelectedUpSkinTexture:Texture;
	private var toggleButtonSelectedDisabledSkinTexture:Texture;
	private var buttonQuietHoverSkinTexture:Texture;
	private var buttonCallToActionUpSkinTexture:Texture;
	private var buttonCallToActionDownSkinTexture:Texture;
	private var buttonDangerUpSkinTexture:Texture;
	private var buttonDangerDownSkinTexture:Texture;
	private var buttonBackUpSkinTexture:Texture;
	private var buttonBackDownSkinTexture:Texture;
	private var buttonBackDisabledSkinTexture:Texture;
	private var buttonForwardUpSkinTexture:Texture;
	private var buttonForwardDownSkinTexture:Texture;
	private var buttonForwardDisabledSkinTexture:Texture;
	private var pickerListButtonIconTexture:Texture;
	private var pickerListButtonIconSelectedTexture:Texture;
	private var pickerListButtonIconDisabledTexture:Texture;
	private var tabUpSkinTexture:Texture;
	private var tabDownSkinTexture:Texture;
	private var tabDisabledSkinTexture:Texture;
	private var tabSelectedSkinTexture:Texture;
	private var tabSelectedDisabledSkinTexture:Texture;
	private var radioUpIconTexture:Texture;
	private var radioDownIconTexture:Texture;
	private var radioDisabledIconTexture:Texture;
	private var radioSelectedUpIconTexture:Texture;
	private var radioSelectedDownIconTexture:Texture;
	private var radioSelectedDisabledIconTexture:Texture;
	private var checkUpIconTexture:Texture;
	private var checkDownIconTexture:Texture;
	private var checkDisabledIconTexture:Texture;
	private var checkSelectedUpIconTexture:Texture;
	private var checkSelectedDownIconTexture:Texture;
	private var checkSelectedDisabledIconTexture:Texture;
	private var pageIndicatorNormalSkinTexture:Texture;
	private var pageIndicatorSelectedSkinTexture:Texture;
	private var itemRendererUpSkinTexture:Texture;
	private var itemRendererHoverSkinTexture:Texture;
	private var itemRendererSelectedUpSkinTexture:Texture;
	private var backgroundPopUpSkinTexture:Texture;
	private var backgroundDangerPopUpSkinTexture:Texture;
	private var calloutTopArrowSkinTexture:Texture;
	private var calloutRightArrowSkinTexture:Texture;
	private var calloutBottomArrowSkinTexture:Texture;
	private var calloutLeftArrowSkinTexture:Texture;
	private var dangerCalloutTopArrowSkinTexture:Texture;
	private var dangerCalloutRightArrowSkinTexture:Texture;
	private var dangerCalloutBottomArrowSkinTexture:Texture;
	private var dangerCalloutLeftArrowSkinTexture:Texture;
	private var horizontalSimpleScrollBarThumbSkinTexture:Texture;
	private var horizontalScrollBarDecrementButtonIconTexture:Texture;
	private var horizontalScrollBarDecrementButtonDisabledIconTexture:Texture;
	private var horizontalScrollBarDecrementButtonUpSkinTexture:Texture;
	private var horizontalScrollBarDecrementButtonDownSkinTexture:Texture;
	private var horizontalScrollBarDecrementButtonDisabledSkinTexture:Texture;
	private var horizontalScrollBarIncrementButtonIconTexture:Texture;
	private var horizontalScrollBarIncrementButtonDisabledIconTexture:Texture;
	private var horizontalScrollBarIncrementButtonUpSkinTexture:Texture;
	private var horizontalScrollBarIncrementButtonDownSkinTexture:Texture;
	private var horizontalScrollBarIncrementButtonDisabledSkinTexture:Texture;
	private var verticalSimpleScrollBarThumbSkinTexture:Texture;
	private var verticalScrollBarDecrementButtonIconTexture:Texture;
	private var verticalScrollBarDecrementButtonDisabledIconTexture:Texture;
	private var verticalScrollBarDecrementButtonUpSkinTexture:Texture;
	private var verticalScrollBarDecrementButtonDownSkinTexture:Texture;
	private var verticalScrollBarDecrementButtonDisabledSkinTexture:Texture;
	private var verticalScrollBarIncrementButtonIconTexture:Texture;
	private var verticalScrollBarIncrementButtonDisabledIconTexture:Texture;
	private var verticalScrollBarIncrementButtonUpSkinTexture:Texture;
	private var verticalScrollBarIncrementButtonDownSkinTexture:Texture;
	private var verticalScrollBarIncrementButtonDisabledSkinTexture:Texture;
	private var searchIconTexture:Texture;
	private var searchIconDisabledTexture:Texture;
	private var listDrillDownAccessoryTexture:Texture;
	private var listDrillDownAccessorySelectedTexture:Texture;
	private var treeDisclosureOpenIconTexture:Texture;
	private var treeDisclosureOpenSelectedIconTexture:Texture;
	private var treeDisclosureClosedIconTexture:Texture;
	private var treeDisclosureClosedSelectedIconTexture:Texture;
	private var dataGridHeaderSortAscendingIconTexture:Texture;
	private var dataGridHeaderSortDescendingIconTexture:Texture;
	private var dataGridHeaderDividerSkinTexture:Texture;
	private var dataGridVerticalDividerSkinTexture:Texture;
	private var dataGridColumnResizeSkinTexture:Texture;
	private var dataGridColumnDropIndicatorSkinTexture:Texture;
	
	//media textures
	private var playPauseButtonPlayUpIconTexture:Texture;
	private var playPauseButtonPlayDownIconTexture:Texture;
	private var playPauseButtonPauseUpIconTexture:Texture;
	private var playPauseButtonPauseDownIconTexture:Texture;
	private var overlayPlayPauseButtonPlayUpIconTexture:Texture;
	private var overlayPlayPauseButtonPlayDownIconTexture:Texture;
	private var fullScreenToggleButtonEnterUpIconTexture:Texture;
	private var fullScreenToggleButtonEnterDownIconTexture:Texture;
	private var fullScreenToggleButtonExitUpIconTexture:Texture;
	private var fullScreenToggleButtonExitDownIconTexture:Texture;
	private var muteToggleButtonLoudUpIconTexture:Texture;
	private var muteToggleButtonLoudDownIconTexture:Texture;
	private var muteToggleButtonMutedUpIconTexture:Texture;
	private var muteToggleButtonMutedDownIconTexture:Texture;
	private var volumeSliderMinimumTrackSkinTexture:Texture;
	private var volumeSliderMaximumTrackSkinTexture:Texture;
	private var popUpVolumeSliderTrackSkinTexture:Texture;
	private var seekSliderProgressSkinTexture:Texture;
	
	/**
	 * Disposes the texture atlas before calling super.dispose()
	 */
	override public function dispose():Void
	{
		if (this.atlas != null)
		{
			//if anything is keeping a reference to the texture, we don't
			//want it to keep a reference to the theme too.
			this.atlas.texture.root.onRestore = null;
			
			this.atlas.dispose();
			this.atlas = null;
		}
		
		var stage:Stage = this.starling.stage;
		FocusManager.setEnabledForStage(stage, false);
		ToolTipManager.setEnabledForStage(stage, false);
		
		//don't forget to call super.dispose()!
		super.dispose();
	}
	
	/**
	 * Initializes the theme. Expected to be called by subclasses after the
	 * assets have been loaded and the skin texture atlas has been created.
	 */
	private function initialize():Void
	{
		this.initializeFonts();
		this.initializeTextures();
		this.initializeGlobals();
		this.initializeStage();
		this.initializeStyleProviders();
	}
	
	/**
	 * Sets the stage background color.
	 */
	private function initializeStage():Void
	{
		this.starling.stage.color = PRIMARY_BACKGROUND_COLOR;
		this.starling.nativeStage.color = PRIMARY_BACKGROUND_COLOR;
	}
	
	/**
	 * Initializes global variables (not including global style providers).
	 */
	private function initializeGlobals():Void
	{
		FeathersControl.defaultTextRendererFactory = textRendererFactory;
		FeathersControl.defaultTextEditorFactory = textEditorFactory;
		
		PopUpManager.overlayFactory = popUpOverlayFactory;
		Callout.stagePadding = this.smallGutterSize;
		Toast.containerFactory = toastContainerFactory;
		
		var stage:Stage = this.starling.stage;
		FocusManager.setEnabledForStage(stage, true);
		ToolTipManager.setEnabledForStage(stage, true);
	}
	
	/**
	 * Initializes font sizes and formats.
	 */
	private function initializeFonts():Void
	{
		this.lightFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.darkFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.selectedFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, SELECTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		
		this.smallLightFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.smallLightDisabledFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		
		this.largeLightFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeDarkFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeLightDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		
		this.lightUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightUIFontStyles.bold = true;
		this.darkUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.darkUIFontStyles.bold = true;
		this.selectedUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, SELECTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.selectedUIFontStyles.bold = true;
		this.lightDisabledUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightDisabledUIFontStyles.bold = true;
		this.darkDisabledUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DARK_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.darkDisabledUIFontStyles.bold = true;
		this.lightCenteredUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.CENTER, VerticalAlign.TOP);
		this.lightCenteredUIFontStyles.bold = true;
		this.lightCenteredDisabledUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.CENTER, VerticalAlign.TOP);
		this.lightCenteredDisabledUIFontStyles.bold = true;
		
		this.lightScrollTextFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightDisabledScrollTextFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	}
	
	/**
	 * Initializes the textures by extracting them from the atlas and
	 * setting up any scaling grids that are needed.
	 */
	private function initializeTextures():Void
	{
		var checkUpIconTexture:Texture = this.atlas.getTexture("check-up-icon0000");
		var checkDownIconTexture:Texture = this.atlas.getTexture("check-down-icon0000");
		var checkDisabledIconTexture:Texture = this.atlas.getTexture("check-disabled-icon0000");
		
		this.focusIndicatorSkinTexture = this.atlas.getTexture("focus-indicator-skin0000");
		
		this.backgroundSkinTexture = this.atlas.getTexture("background-skin0000");
		this.backgroundDisabledSkinTexture = this.atlas.getTexture("background-disabled-skin0000");
		this.backgroundFocusedSkinTexture = this.atlas.getTexture("background-focused-skin0000");
		this.backgroundDangerSkinTexture = this.atlas.getTexture("background-danger-skin0000");
		this.backgroundPopUpSkinTexture = this.atlas.getTexture("background-popup-skin0000");
		this.backgroundDangerPopUpSkinTexture = this.atlas.getTexture("background-danger-popup-skin0000");
		this.listBackgroundSkinTexture = this.atlas.getTexture("list-background-skin0000");
		
		this.buttonUpSkinTexture = this.atlas.getTexture("button-up-skin0000");
		this.buttonDownSkinTexture = this.atlas.getTexture("button-down-skin0000");
		this.buttonDisabledSkinTexture = this.atlas.getTexture("button-disabled-skin0000");
		this.toggleButtonSelectedUpSkinTexture = this.atlas.getTexture("toggle-button-selected-up-skin0000");
		this.toggleButtonSelectedDisabledSkinTexture = this.atlas.getTexture("toggle-button-selected-disabled-skin0000");
		this.buttonQuietHoverSkinTexture = this.atlas.getTexture("quiet-button-hover-skin0000");
		this.buttonCallToActionUpSkinTexture = this.atlas.getTexture("call-to-action-button-up-skin0000");
		this.buttonCallToActionDownSkinTexture = this.atlas.getTexture("call-to-action-button-down-skin0000");
		this.buttonDangerUpSkinTexture = this.atlas.getTexture("danger-button-up-skin0000");
		this.buttonDangerDownSkinTexture = this.atlas.getTexture("danger-button-down-skin0000");
		this.buttonBackUpSkinTexture = this.atlas.getTexture("back-button-up-skin0000");
		this.buttonBackDownSkinTexture = this.atlas.getTexture("back-button-down-skin0000");
		this.buttonBackDisabledSkinTexture = this.atlas.getTexture("back-button-disabled-skin0000");
		this.buttonForwardUpSkinTexture = this.atlas.getTexture("forward-button-up-skin0000");
		this.buttonForwardDownSkinTexture = this.atlas.getTexture("forward-button-down-skin0000");
		this.buttonForwardDisabledSkinTexture = this.atlas.getTexture("forward-button-disabled-skin0000");
		
		this.tabUpSkinTexture = this.atlas.getTexture("tab-up-skin0000");
		this.tabDownSkinTexture = this.atlas.getTexture("tab-down-skin0000");
		this.tabDisabledSkinTexture = this.atlas.getTexture("tab-disabled-skin0000");
		this.tabSelectedSkinTexture = this.atlas.getTexture("tab-selected-up-skin0000");
		this.tabSelectedDisabledSkinTexture = this.atlas.getTexture("tab-selected-disabled-skin0000");
		
		this.pickerListButtonIconTexture = this.atlas.getTexture("picker-list-icon0000");
		this.pickerListButtonIconSelectedTexture = this.atlas.getTexture("picker-list-selected-icon0000");
		this.pickerListButtonIconDisabledTexture = this.atlas.getTexture("picker-list-disabled-icon0000");
		
		this.radioUpIconTexture = checkUpIconTexture;
		this.radioDownIconTexture = checkDownIconTexture;
		this.radioDisabledIconTexture = checkDisabledIconTexture;
		this.radioSelectedUpIconTexture = this.atlas.getTexture("radio-selected-up-icon0000");
		this.radioSelectedDownIconTexture = this.atlas.getTexture("radio-selected-down-icon0000");
		this.radioSelectedDisabledIconTexture = this.atlas.getTexture("radio-selected-disabled-icon0000");
		
		this.checkUpIconTexture = checkUpIconTexture;
		this.checkDownIconTexture = checkDownIconTexture;
		this.checkDisabledIconTexture = checkDisabledIconTexture;
		this.checkSelectedUpIconTexture = this.atlas.getTexture("check-selected-up-icon0000");
		this.checkSelectedDownIconTexture = this.atlas.getTexture("check-selected-down-icon0000");
		this.checkSelectedDisabledIconTexture = this.atlas.getTexture("check-selected-disabled-icon0000");
		
		this.pageIndicatorSelectedSkinTexture = this.atlas.getTexture("page-indicator-selected-symbol0000");
		this.pageIndicatorNormalSkinTexture = this.atlas.getTexture("page-indicator-symbol0000");
		
		this.searchIconTexture = this.atlas.getTexture("search-icon0000");
		this.searchIconDisabledTexture = this.atlas.getTexture("search-disabled-icon0000");
		
		this.itemRendererUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-up-skin0000"), ITEM_RENDERER_SKIN_TEXTURE_REGION);
		this.itemRendererHoverSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-hover-skin0000"), ITEM_RENDERER_SKIN_TEXTURE_REGION);
		this.itemRendererSelectedUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-selected-up-skin0000"), ITEM_RENDERER_SELECTED_SKIN_TEXTURE_REGION);
		
		this.headerBackgroundSkinTexture = this.atlas.getTexture("header-background-skin0000");
		this.headerPopupBackgroundSkinTexture = this.atlas.getTexture("header-popup-background-skin0000");
		this.headerBackgroundSkinTexture = Texture.fromTexture(headerBackgroundSkinTexture, HEADER_SKIN_TEXTURE_REGION);
		this.headerPopupBackgroundSkinTexture = Texture.fromTexture(headerPopupBackgroundSkinTexture, HEADER_SKIN_TEXTURE_REGION);
		
		this.calloutTopArrowSkinTexture = this.atlas.getTexture("callout-arrow-top-skin0000");
		this.calloutRightArrowSkinTexture = this.atlas.getTexture("callout-arrow-right-skin0000");
		this.calloutBottomArrowSkinTexture = this.atlas.getTexture("callout-arrow-bottom-skin0000");
		this.calloutLeftArrowSkinTexture = this.atlas.getTexture("callout-arrow-left-skin0000");
		this.dangerCalloutTopArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-top-skin0000");
		this.dangerCalloutRightArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-right-skin0000");
		this.dangerCalloutBottomArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-bottom-skin0000");
		this.dangerCalloutLeftArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-left-skin0000");
		
		this.horizontalSimpleScrollBarThumbSkinTexture = this.atlas.getTexture("horizontal-simple-scroll-bar-thumb-skin0000");
		this.horizontalScrollBarDecrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-icon0000");
		this.horizontalScrollBarDecrementButtonDisabledIconTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-disabled-icon0000");
		this.horizontalScrollBarDecrementButtonUpSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-up-skin0000");
		this.horizontalScrollBarDecrementButtonDownSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-down-skin0000");
		this.horizontalScrollBarDecrementButtonDisabledSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-disabled-skin0000");
		this.horizontalScrollBarIncrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-icon0000");
		this.horizontalScrollBarIncrementButtonDisabledIconTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-disabled-icon0000");
		this.horizontalScrollBarIncrementButtonUpSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-up-skin0000");
		this.horizontalScrollBarIncrementButtonDownSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-down-skin0000");
		this.horizontalScrollBarIncrementButtonDisabledSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-disabled-skin0000");
		
		this.verticalSimpleScrollBarThumbSkinTexture = this.atlas.getTexture("vertical-simple-scroll-bar-thumb-skin0000");
		this.verticalScrollBarDecrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-icon0000");
		this.verticalScrollBarDecrementButtonDisabledIconTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-disabled-icon0000");
		this.verticalScrollBarDecrementButtonUpSkinTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-up-skin0000");
		this.verticalScrollBarDecrementButtonDownSkinTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-down-skin0000");
		this.verticalScrollBarDecrementButtonDisabledSkinTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-disabled-skin0000");
		this.verticalScrollBarIncrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-icon0000");
		this.verticalScrollBarIncrementButtonDisabledIconTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-disabled-icon0000");
		this.verticalScrollBarIncrementButtonUpSkinTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-up-skin0000");
		this.verticalScrollBarIncrementButtonDownSkinTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-down-skin0000");
		this.verticalScrollBarIncrementButtonDisabledSkinTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-disabled-skin0000");
		
		this.listDrillDownAccessoryTexture = this.atlas.getTexture("item-renderer-drill-down-accessory-icon0000");
		this.listDrillDownAccessorySelectedTexture = this.atlas.getTexture("item-renderer-drill-down-accessory-selected-icon0000");
		
		this.treeDisclosureOpenIconTexture = this.atlas.getTexture("tree-disclosure-open-icon0000");
		this.treeDisclosureOpenSelectedIconTexture = this.atlas.getTexture("tree-disclosure-open-selected-icon0000");
		this.treeDisclosureClosedIconTexture = this.atlas.getTexture("tree-disclosure-closed-icon0000");
		this.treeDisclosureClosedSelectedIconTexture = this.atlas.getTexture("tree-disclosure-closed-selected-icon0000");
		
		this.dataGridHeaderSortAscendingIconTexture = this.atlas.getTexture("data-grid-header-sort-ascending-icon0000");
		this.dataGridHeaderSortDescendingIconTexture = this.atlas.getTexture("data-grid-header-sort-descending-icon0000");
		this.dataGridHeaderDividerSkinTexture = this.atlas.getTexture("data-grid-header-divider-skin0000");
		this.dataGridVerticalDividerSkinTexture = this.atlas.getTexture("data-grid-vertical-divider-skin0000");
		this.dataGridColumnResizeSkinTexture = this.atlas.getTexture("data-grid-column-resize-skin0000");
		this.dataGridColumnDropIndicatorSkinTexture = this.atlas.getTexture("data-grid-column-drop-indicator-skin0000");
		
		this.playPauseButtonPlayUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-play-up-icon0000");
		this.playPauseButtonPlayDownIconTexture = this.atlas.getTexture("play-pause-toggle-button-play-down-icon0000");
		this.playPauseButtonPauseUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-pause-up-icon0000");
		this.playPauseButtonPauseDownIconTexture = this.atlas.getTexture("play-pause-toggle-button-pause-down-icon0000");
		this.overlayPlayPauseButtonPlayUpIconTexture = this.atlas.getTexture("overlay-play-pause-toggle-button-play-up-icon0000");
		this.overlayPlayPauseButtonPlayDownIconTexture = this.atlas.getTexture("overlay-play-pause-toggle-button-play-down-icon0000");
		this.fullScreenToggleButtonEnterUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-enter-up-icon0000");
		this.fullScreenToggleButtonEnterDownIconTexture = this.atlas.getTexture("full-screen-toggle-button-enter-down-icon0000");
		this.fullScreenToggleButtonExitUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-exit-up-icon0000");
		this.fullScreenToggleButtonExitDownIconTexture = this.atlas.getTexture("full-screen-toggle-button-exit-down-icon0000");
		this.muteToggleButtonMutedUpIconTexture = this.atlas.getTexture("mute-toggle-button-muted-up-icon0000");
		this.muteToggleButtonMutedDownIconTexture = this.atlas.getTexture("mute-toggle-button-muted-down-icon0000");
		this.muteToggleButtonLoudUpIconTexture = this.atlas.getTexture("mute-toggle-button-loud-up-icon0000");
		this.muteToggleButtonLoudDownIconTexture = this.atlas.getTexture("mute-toggle-button-loud-down-icon0000");
		this.popUpVolumeSliderTrackSkinTexture = this.atlas.getTexture("pop-up-volume-slider-track-skin0000");
		this.volumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("volume-slider-minimum-track-skin0000");
		this.volumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("volume-slider-maximum-track-skin0000");
		this.seekSliderProgressSkinTexture = this.atlas.getTexture("seek-slider-progress-skin0000");
	}
	
	/**
	 * Sets global style providers for all components.
	 */
	private function initializeStyleProviders():Void
	{
		//alert
		this.getStyleProviderForClass(Alert).defaultStyleFunction = this.setAlertStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPopupHeaderStyles);
		this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_BUTTON_GROUP, this.setAlertButtonGroupStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON, this.setAlertButtonGroupButtonStyles);
		
		//autocomplete
		this.getStyleProviderForClass(AutoComplete).defaultStyleFunction = this.setTextInputStyles;
		this.getStyleProviderForClass(List).setFunctionForStyleName(AutoComplete.DEFAULT_CHILD_STYLE_NAME_LIST, this.setDropDownListStyles);
		
		//button
		this.getStyleProviderForClass(Button).defaultStyleFunction = this.setButtonStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_CALL_TO_ACTION_BUTTON, this.setCallToActionButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_DANGER_BUTTON, this.setDangerButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON, this.setBackButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_FORWARD_BUTTON, this.setForwardButtonStyles);
		
		//button group
		this.getStyleProviderForClass(ButtonGroup).defaultStyleFunction = this.setButtonGroupStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ButtonGroup.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setButtonGroupButtonStyles);
		
		//callout
		this.getStyleProviderForClass(Callout).defaultStyleFunction = this.setCalloutStyles;
		
		//check
		this.getStyleProviderForClass(Check).defaultStyleFunction = this.setCheckStyles;
		
		//data grid (see also: item renderers)
		this.getStyleProviderForClass(DataGrid).defaultStyleFunction = this.setDataGridStyles;
		
		//date time spinner
		this.getStyleProviderForClass(DateTimeSpinner).defaultStyleFunction = this.setDateTimeSpinnerStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER, this.setDateTimeSpinnerListItemRendererStyles);
		
		//drawers
		this.getStyleProviderForClass(Drawers).defaultStyleFunction = this.setDrawersStyles;
		
		//grouped list (see also: item renderers)
		this.getStyleProviderForClass(GroupedList).defaultStyleFunction = this.setGroupedListStyles;
		
		//header
		this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;
		
		//header and footer renderers for grouped list
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).defaultStyleFunction = this.setGroupedListHeaderRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.DEFAULT_CHILD_STYLE_NAME_FOOTER_RENDERER, this.setGroupedListFooterRendererStyles);
		
		//header renderers for data grid
		this.getStyleProviderForClass(DefaultDataGridHeaderRenderer).defaultStyleFunction = this.setDataGridHeaderRendererStyles;
		
		//item renderers for lists
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);
		this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);
		this.getStyleProviderForClass(DefaultDataGridCellRenderer).defaultStyleFunction = this.setDataGridCellRendererStyles;
		
		//labels
		this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_HEADING, this.setHeadingLabelStyles);
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_DETAIL, this.setDetailLabelStyles);
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_TOOL_TIP, this.setToolTipLabelStyles);
		
		//layout group
		this.getStyleProviderForClass(LayoutGroup).setFunctionForStyleName(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarLayoutGroupStyles);
		
		//list (see also: item renderers)
		this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
		
		//numeric stepper
		this.getStyleProviderForClass(NumericStepper).defaultStyleFunction = this.setNumericStepperStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT, this.setNumericStepperTextInputStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON, this.setNumericStepperDecrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON, this.setNumericStepperIncrementButtonStyles);
		
		//page indicator
		this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;
		
		//panel
		this.getStyleProviderForClass(Panel).defaultStyleFunction = this.setPanelStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Panel.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPopupHeaderStyles);
		
		//panel screen
		this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(PanelScreen.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPanelScreenHeaderStyles);
		
		//picker list (see also: list and item renderers)
		this.getStyleProviderForClass(PickerList).defaultStyleFunction = this.setPickerListStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
		this.getStyleProviderForClass(List).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_LIST, this.setDropDownListStyles);
		
		//progress bar
		this.getStyleProviderForClass(ProgressBar).defaultStyleFunction = this.setProgressBarStyles;
		
		//radio
		this.getStyleProviderForClass(Radio).defaultStyleFunction = this.setRadioStyles;
		
		//scroll bar
		this.getStyleProviderForClass(ScrollBar).setFunctionForStyleName(Scroller.DEFAULT_CHILD_STYLE_NAME_HORIZONTAL_SCROLL_BAR, this.setHorizontalScrollBarStyles);
		this.getStyleProviderForClass(ScrollBar).setFunctionForStyleName(Scroller.DEFAULT_CHILD_STYLE_NAME_VERTICAL_SCROLL_BAR, this.setVerticalScrollBarStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON, this.setHorizontalScrollBarIncrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON, this.setHorizontalScrollBarDecrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_THUMB, this.setHorizontalScrollBarThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MINIMUM_TRACK, this.setHorizontalScrollBarMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MAXIMUM_TRACK, this.setHorizontalScrollBarMaximumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON, this.setVerticalScrollBarIncrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON, this.setVerticalScrollBarDecrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_THUMB, this.setVerticalScrollBarThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MINIMUM_TRACK, this.setVerticalScrollBarMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MAXIMUM_TRACK, this.setVerticalScrollBarMaximumTrackStyles);
		
		//scroll container
		this.getStyleProviderForClass(ScrollContainer).defaultStyleFunction = this.setScrollContainerStyles;
		this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(ScrollContainer.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarScrollContainerStyles);
		
		//scroll screen
		this.getStyleProviderForClass(ScrollScreen).defaultStyleFunction = this.setScrollScreenStyles;
		
		//scroll text
		this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;
		
		//simple scroll bar
		this.getStyleProviderForClass(SimpleScrollBar).defaultStyleFunction = this.setSimpleScrollBarStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB, this.setHorizontalSimpleScrollBarThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB, this.setVerticalSimpleScrollBarThumbStyles);
		
		//slider
		this.getStyleProviderForClass(Slider).defaultStyleFunction = this.setSliderStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Slider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSliderThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK, this.setHorizontalSliderMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK, this.setHorizontalSliderMaximumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK, this.setVerticalSliderMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK, this.setVerticalSliderMaximumTrackStyles);
		
		//spinner list
		this.getStyleProviderForClass(SpinnerList).defaultStyleFunction = this.setSpinnerListStyles;
		
		//tab bar
		this.getStyleProviderForClass(TabBar).defaultStyleFunction = this.setTabBarStyles;
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(TabBar.DEFAULT_CHILD_STYLE_NAME_TAB, this.setTabStyles);
		
		//text input
		this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TextInput.ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT, this.setSearchTextInputStyles);
		//this.getStyleProviderForClass(TextBlockTextEditor).setFunctionForStyleName(TextInput.DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR, this.setTextInputTextEditorStyles);
		this.getStyleProviderForClass(TextCallout).setFunctionForStyleName(TextInput.DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT, this.setTextInputErrorCalloutStyles);
		
		//text area
		this.getStyleProviderForClass(TextArea).defaultStyleFunction = this.setTextAreaStyles;
		this.getStyleProviderForClass(TextCallout).setFunctionForStyleName(TextArea.DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT, this.setTextAreaErrorCalloutStyles);
		
		//text callout
		this.getStyleProviderForClass(TextCallout).defaultStyleFunction = this.setTextCalloutStyles;
		
		//toast
		this.getStyleProviderForClass(Toast).defaultStyleFunction = this.setToastStyles;
		this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName(Toast.DEFAULT_CHILD_STYLE_NAME_ACTIONS, this.setToastActionsStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON, this.setToastActionsButtonStyles);
		
		//toggle button
		this.getStyleProviderForClass(ToggleButton).defaultStyleFunction = this.setButtonStyles;
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);
		
		//toggle switch
		this.getStyleProviderForClass(ToggleSwitch).defaultStyleFunction = this.setToggleSwitchStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setToggleSwitchThumbStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setToggleSwitchThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_TRACK, this.setToggleSwitchTrackStyles);
		//we don't need a style function for the off track in this theme
		//the toggle switch layout uses a single track
		
		//tree
		this.getStyleProviderForClass(Tree).defaultStyleFunction = this.setTreeStyles;
		this.getStyleProviderForClass(DefaultTreeItemRenderer).defaultStyleFunction = this.setTreeItemRendererStyles;
		
		//media controls
		//this.getStyleProviderForClass(VideoPlayer).defaultStyleFunction = this.setVideoPlayerStyles;
		
		//play/pause toggle button
		//this.getStyleProviderForClass(PlayPauseToggleButton).defaultStyleFunction = this.setPlayPauseToggleButtonStyles;
		//this.getStyleProviderForClass(PlayPauseToggleButton).setFunctionForStyleName(PlayPauseToggleButton.ALTERNATE_STYLE_NAME_OVERLAY_PLAY_PAUSE_TOGGLE_BUTTON, this.setOverlayPlayPauseToggleButtonStyles);
		
		//full screen toggle button
		//this.getStyleProviderForClass(FullScreenToggleButton).defaultStyleFunction = this.setFullScreenToggleButtonStyles;
		
		//mute toggle button
		//this.getStyleProviderForClass(MuteToggleButton).defaultStyleFunction = this.setMuteToggleButtonStyles;
		//this.getStyleProviderForClass(VolumeSlider).setFunctionForStyleName(MuteToggleButton.DEFAULT_CHILD_STYLE_NAME_VOLUME_SLIDER, this.setPopUpVolumeSliderStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_THUMB, this.setSliderThumbStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK, this.setPopUpVolumeSliderTrackStyles);
		
		//seek slider
		//this.getStyleProviderForClass(SeekSlider).defaultStyleFunction = this.setSeekSliderStyles;
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSeekSliderThumbStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setSeekSliderMinimumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK, this.setSeekSliderMaximumTrackStyles);
		
		//volume slider
		//this.getStyleProviderForClass(VolumeSlider).defaultStyleFunction = this.setVolumeSliderStyles;
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setVolumeSliderThumbStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setVolumeSliderMinimumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK, this.setVolumeSliderMaximumTrackStyles);
	}
	
	private function pageIndicatorNormalSymbolFactory():DisplayObject
	{
		var symbol:ImageLoader = new ImageLoader();
		symbol.source = this.pageIndicatorNormalSkinTexture;
		return symbol;
	}
	
	private function pageIndicatorSelectedSymbolFactory():DisplayObject
	{
		var symbol:ImageLoader = new ImageLoader();
		symbol.source = this.pageIndicatorSelectedSkinTexture;
		return symbol;
	}
	
	private function dataGridHeaderDividerFactory():DisplayObject
	{
		var skin:ImageSkin = new ImageSkin(this.dataGridHeaderDividerSkinTexture);
		skin.scale9Grid = DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID;
		return skin;
	}
	
	private function dataGridVerticalDividerFactory():DisplayObject
	{
		var skin:ImageSkin = new ImageSkin(this.dataGridVerticalDividerSkinTexture);
		skin.scale9Grid = DATA_GRID_VERTICAL_DIVIDER_SCALE_9_GRID;
		return skin;
	}
	
	private function toastContainerFactory():DisplayObjectContainer
	{
		var container:LayoutGroup = new LayoutGroup();
		container.autoSizeMode = AutoSizeMode.STAGE;
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.verticalAlign = VerticalAlign.BOTTOM;
		layout.horizontalAlign = HorizontalAlign.LEFT;
		layout.padding = this.gutterSize;
		layout.gap = this.gutterSize;
		container.layout = layout;
		
		return container;
	}
	
	//-------------------------
	// Shared
	//-------------------------
	
	private function setScrollerStyles(scroller:Scroller):Void
	{
		scroller.horizontalScrollBarFactory = scrollBarFactory;
		scroller.verticalScrollBarFactory = scrollBarFactory;
		scroller.scrollBarDisplayMode = ScrollBarDisplayMode.FIXED;
		scroller.interactionMode = ScrollInteractionMode.MOUSE;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		scroller.focusIndicatorSkin = focusIndicatorSkin;
		scroller.focusPadding = 0;
	}
	
	private function setDropDownListStyles(list:List):Void
	{
		this.setListStyles(list);
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.useVirtualLayout = true;
		layout.padding = 0;
		layout.gap = 0;
		layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		layout.verticalAlign = VerticalAlign.TOP;
		layout.resetTypicalItemDimensionsOnMeasure = true;
		layout.maxRowCount = 5;
		list.layout = layout;
	}
	
	//-------------------------
	// Alert
	//-------------------------
	
	private function setAlertStyles(alert:Alert):Void
	{
		this.setScrollerStyles(alert);
		
		var backgroundSkin:Image = new Image(this.backgroundPopUpSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_SCALE9_GRID;
		alert.backgroundSkin = backgroundSkin;
		
		alert.fontStyles = this.lightFontStyles.clone();
		alert.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		alert.paddingTop = this.gutterSize;
		alert.paddingRight = this.gutterSize;
		alert.paddingBottom = this.smallGutterSize;
		alert.paddingLeft = this.gutterSize;
		alert.outerPadding = this.borderSize;
		alert.gap = this.smallGutterSize;
		alert.maxWidth = this.popUpSize;
		alert.maxHeight = this.popUpSize;
	}
	
	//see Panel section for Header styles
	
	private function setAlertButtonGroupStyles(group:ButtonGroup):Void
	{
		group.customButtonStyleName = THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON;
		group.direction = Direction.HORIZONTAL;
		group.horizontalAlign = HorizontalAlign.CENTER;
		group.verticalAlign = VerticalAlign.JUSTIFY;
		group.distributeButtonSizes = false;
		group.gap = this.smallGutterSize;
		group.padding = this.smallGutterSize;
	}
	
	private function setAlertButtonGroupButtonStyles(button:Button):Void
	{
		this.setButtonStyles(button);
	}
	
	//-------------------------
	// Button
	//-------------------------
	
	private function setBaseButtonStyles(button:Button):Void
	{
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		button.focusIndicatorSkin = focusIndicatorSkin;
		button.focusPadding = this.focusPaddingSize;
		
		button.paddingTop = this.smallGutterSize;
		button.paddingBottom = this.smallGutterSize;
		button.paddingLeft = this.gutterSize;
		button.paddingRight = this.gutterSize;
		button.gap = this.smallGutterSize;
		button.minGap = this.smallGutterSize;
	}
	
	private function setButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			var selectedSkin:ImageSkin = new ImageSkin(this.toggleButtonSelectedUpSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
			selectedSkin.scale9Grid = TOGGLE_BUTTON_SCALE9_GRID;
			selectedSkin.width = this.controlSize;
			selectedSkin.height = this.controlSize;
			cast(button, ToggleButton).defaultSelectedSkin = selectedSkin;
		}
		
		button.fontStyles = this.darkUIFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledUIFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setCallToActionButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonCallToActionUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonCallToActionDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkUIFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledUIFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setQuietButtonStyles(button:Button):Void
	{
		var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		defaultSkin.alpha = 0;
		button.defaultSkin = defaultSkin;
		
		var otherSkin:ImageSkin = new ImageSkin(null);
		otherSkin.setTextureForState(ButtonState.HOVER, this.buttonQuietHoverSkinTexture);
		otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		button.hoverSkin = otherSkin;
		button.downSkin = otherSkin;
		
		var toggleButton:ToggleButton = null;
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			toggleButton = cast button;
			otherSkin.selectedTexture = this.toggleButtonSelectedUpSkinTexture;
			otherSkin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
			toggleButton.defaultSelectedSkin = otherSkin;
			toggleButton.setSkinForState(ButtonState.DISABLED_AND_SELECTED, otherSkin);
		}
		otherSkin.scale9Grid = BUTTON_SCALE9_GRID;
		otherSkin.width = this.controlSize;
		otherSkin.height = this.controlSize;
		otherSkin.minWidth = this.controlSize;
		otherSkin.minHeight = this.controlSize;
		
		button.fontStyles = this.lightUIFontStyles.clone();
		button.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		button.setFontStylesForState(ButtonState.DOWN, this.darkUIFontStyles.clone());
		button.setFontStylesForState(ButtonState.DISABLED, this.lightDisabledUIFontStyles.clone());
		if (Std.isOfType(button, ToggleButton))
		{
			toggleButton.selectedFontStyles = this.darkUIFontStyles.clone();
			toggleButton.setFontStylesForState(ButtonState.DISABLED_AND_SELECTED, this.darkDisabledUIFontStyles.clone());
		}
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		button.focusIndicatorSkin = focusIndicatorSkin;
		button.focusPadding = this.focusPaddingSize;
		
		button.paddingTop = this.smallGutterSize;
		button.paddingBottom = this.smallGutterSize;
		button.paddingLeft = this.gutterSize;
		button.paddingRight = this.gutterSize;
		button.gap = this.smallGutterSize;
		button.minGap = this.smallGutterSize;
	}
	
	private function setDangerButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonDangerUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDangerDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.buttonMinWidth;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkUIFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledUIFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setBackButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonBackUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonBackDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonBackDisabledSkinTexture);
		skin.scale9Grid = BACK_BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkUIFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledUIFontStyles.clone();
		
		this.setBaseButtonStyles(button);
		
		button.paddingLeft = 2 * this.gutterSize;
	}
	
	private function setForwardButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonForwardUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonForwardDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonForwardDisabledSkinTexture);
		skin.scale9Grid = FORWARD_BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkUIFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledUIFontStyles.clone();
		
		this.setBaseButtonStyles(button);
		
		button.paddingRight = 2 * this.gutterSize;
	}
	
	//-------------------------
	// ButtonGroup
	//-------------------------
	
	private function setButtonGroupStyles(group:ButtonGroup):Void
	{
		group.gap = this.smallGutterSize;
	}
	
	private function setButtonGroupButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			var selectedSkin:ImageSkin = new ImageSkin(this.toggleButtonSelectedUpSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
			selectedSkin.scale9Grid = TOGGLE_BUTTON_SCALE9_GRID;
			selectedSkin.width = this.controlSize;
			selectedSkin.height = this.controlSize;
			cast(button, ToggleButton).defaultSelectedSkin = selectedSkin;
		}
		
		button.fontStyles = this.darkUIFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledUIFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	//-------------------------
	// Callout
	//-------------------------
	
	private function setCalloutStyles(callout:Callout):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundPopUpSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_SCALE9_GRID;
		backgroundSkin.width = this.calloutBackgroundMinSize;
		backgroundSkin.height = this.calloutBackgroundMinSize;
		callout.backgroundSkin = backgroundSkin;
		
		var topArrowSkin:Image = new Image(this.calloutTopArrowSkinTexture);
		callout.topArrowSkin = topArrowSkin;
		callout.topArrowGap = this.calloutArrowOverlapGap;
		
		var rightArrowSkin:Image = new Image(this.calloutRightArrowSkinTexture);
		callout.rightArrowSkin = rightArrowSkin;
		callout.rightArrowGap = this.calloutArrowOverlapGap;
		
		var bottomArrowSkin:Image = new Image(this.calloutBottomArrowSkinTexture);
		callout.bottomArrowSkin = bottomArrowSkin;
		callout.bottomArrowGap = this.calloutArrowOverlapGap;
		
		var leftArrowSkin:Image = new Image(this.calloutLeftArrowSkinTexture);
		callout.leftArrowSkin = leftArrowSkin;
		callout.leftArrowGap = this.calloutArrowOverlapGap;
		
		callout.padding = this.gutterSize;
	}
	
	private function setDangerCalloutStyles(callout:Callout):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundDangerPopUpSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_SCALE9_GRID;
		backgroundSkin.width = this.calloutBackgroundMinSize;
		backgroundSkin.height = this.calloutBackgroundMinSize;
		callout.backgroundSkin = backgroundSkin;
		
		var topArrowSkin:Image = new Image(this.dangerCalloutTopArrowSkinTexture);
		callout.topArrowSkin = topArrowSkin;
		callout.topArrowGap = this.calloutArrowOverlapGap;
		
		var rightArrowSkin:Image = new Image(this.dangerCalloutRightArrowSkinTexture);
		callout.rightArrowSkin = rightArrowSkin;
		callout.rightArrowGap = this.calloutArrowOverlapGap;
		
		var bottomArrowSkin:Image = new Image(this.dangerCalloutBottomArrowSkinTexture);
		callout.bottomArrowSkin = bottomArrowSkin;
		callout.bottomArrowGap = this.calloutArrowOverlapGap;
		
		var leftArrowSkin:Image = new Image(this.dangerCalloutLeftArrowSkinTexture);
		callout.leftArrowSkin = leftArrowSkin;
		callout.leftArrowGap = this.calloutArrowOverlapGap;
		
		callout.padding = this.gutterSize;
	}
	
	//-------------------------
	// Check
	//-------------------------
	
	private function setCheckStyles(check:Check):Void
	{
		var skin:Quad = new Quad(this.controlSize, this.controlSize);
		skin.alpha = 0;
		check.defaultSkin = skin;
		
		var icon:ImageSkin = new ImageSkin(this.checkUpIconTexture);
		icon.selectedTexture = this.checkSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.DOWN, this.checkDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.checkDisabledIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.checkSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.checkSelectedDisabledIconTexture);
		check.defaultIcon = icon;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		check.focusIndicatorSkin = focusIndicatorSkin;
		check.focusPaddingLeft = this.focusPaddingSize;
		check.focusPaddingRight = this.focusPaddingSize;
		
		check.fontStyles = this.lightUIFontStyles.clone();
		check.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		check.horizontalAlign = HorizontalAlign.LEFT;
		check.gap = this.smallGutterSize;
	}
	
	//-------------------------
	// DataGrid
	//-------------------------
	
	private function setDataGridStyles(grid:DataGrid):Void
	{
		this.setScrollerStyles(grid);
		
		grid.padding = this.borderSize;
		
		var backgroundSkin:Image = new Image(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		grid.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.backgroundDisabledSkinTexture);
		backgroundDisabledSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		backgroundDisabledSkin.width = this.controlSize;
		backgroundDisabledSkin.height = this.controlSize;
		grid.backgroundDisabledSkin = backgroundDisabledSkin;
		
		grid.headerBackgroundSkin = new Quad(this.controlSize, this.controlSize, GROUPED_LIST_HEADER_BACKGROUND_COLOR);
		
		var columnResizeSkin:ImageSkin = new ImageSkin(this.dataGridColumnResizeSkinTexture);
		columnResizeSkin.scale9Grid = DATA_GRID_COLUMN_RESIZE_SCALE_9_GRID;
		grid.columnResizeSkin = columnResizeSkin;
		
		var columnDragOverlaySkin:Quad = new Quad(1, 1, DATA_GRID_COLUMN_OVERLAY_COLOR);
		columnDragOverlaySkin.alpha = DATA_GRID_COLUMN_OVERLAY_ALPHA;
		grid.columnDragOverlaySkin = columnDragOverlaySkin;
		
		var columnDropIndicatorSkin:ImageSkin = new ImageSkin(this.dataGridColumnDropIndicatorSkinTexture);
		columnDropIndicatorSkin.scale9Grid = DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID;
		grid.columnDropIndicatorSkin = columnDropIndicatorSkin;
		grid.extendedColumnDropIndicator = true;
		
		grid.headerDividerFactory = this.dataGridHeaderDividerFactory;
		grid.verticalDividerFactory = this.dataGridVerticalDividerFactory;
		
		grid.verticalScrollPolicy = ScrollPolicy.AUTO;
	}
	
	private function setDataGridCellRendererStyles(cellRenderer:DefaultDataGridCellRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.itemRendererHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedUpSkinTexture);
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		cellRenderer.defaultSkin = skin;
		
		cellRenderer.fontStyles = this.lightFontStyles.clone();
		cellRenderer.disabledFontStyles = this.lightDisabledFontStyles.clone();
		cellRenderer.selectedFontStyles = this.darkFontStyles.clone();
		cellRenderer.setFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		cellRenderer.setFontStylesForState(ButtonState.HOVER, this.darkFontStyles.clone());
		
		cellRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		cellRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		cellRenderer.iconLabelSelectedFontStyles = this.darkFontStyles.clone();
		cellRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		cellRenderer.setIconLabelFontStylesForState(ButtonState.HOVER, this.darkFontStyles.clone());
		
		cellRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		cellRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		cellRenderer.accessoryLabelSelectedFontStyles = this.darkFontStyles.clone();
		cellRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		cellRenderer.setAccessoryLabelFontStylesForState(ButtonState.HOVER, this.darkFontStyles.clone());
		
		cellRenderer.horizontalAlign = HorizontalAlign.LEFT;
		cellRenderer.paddingTop = this.smallGutterSize;
		cellRenderer.paddingBottom = this.smallGutterSize;
		cellRenderer.paddingLeft = this.gutterSize;
		cellRenderer.paddingRight = this.gutterSize;
		cellRenderer.gap = this.smallGutterSize;
		cellRenderer.minGap = this.smallGutterSize;
		cellRenderer.iconPosition = RelativePosition.LEFT;
		cellRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		cellRenderer.minAccessoryGap = this.smallGutterSize;
		cellRenderer.accessoryPosition = RelativePosition.RIGHT;
		
		cellRenderer.useStateDelayTimer = false;
	}
	
	private function setDataGridHeaderRendererStyles(headerRenderer:DefaultDataGridHeaderRenderer):Void
	{
		headerRenderer.backgroundSkin = new Quad(this.controlSize, this.controlSize, GROUPED_LIST_HEADER_BACKGROUND_COLOR);
		
		headerRenderer.sortAscendingIcon = new ImageSkin(this.dataGridHeaderSortAscendingIconTexture);
		headerRenderer.sortDescendingIcon = new ImageSkin(this.dataGridHeaderSortDescendingIconTexture);
		
		headerRenderer.fontStyles = this.lightUIFontStyles.clone();
		headerRenderer.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		headerRenderer.horizontalAlign = HorizontalAlign.LEFT;
		
		headerRenderer.paddingTop = this.smallGutterSize;
		headerRenderer.paddingBottom = this.smallGutterSize;
		headerRenderer.paddingLeft = this.gutterSize;
		headerRenderer.paddingRight = this.gutterSize;
	}
	
	//-------------------------
	// DateTimeSpinner
	//-------------------------
	
	private function setDateTimeSpinnerStyles(spinner:DateTimeSpinner):Void
	{
		spinner.customItemRendererStyleName = THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER;
	}
	
	private function setDateTimeSpinnerListItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.accessoryPosition = RelativePosition.LEFT;
		itemRenderer.accessoryGap = this.smallGutterSize;
	}
	
	//-------------------------
	// Drawers
	//-------------------------
	
	private function setDrawersStyles(drawers:Drawers):Void
	{
		var overlaySkin:Quad = new Quad(1, 1, DRAWER_OVERLAY_COLOR);
		overlaySkin.alpha = DRAWER_OVERLAY_ALPHA;
		drawers.overlaySkin = overlaySkin;
	}
	
	//-------------------------
	// GroupedList
	//-------------------------
	
	private function setGroupedListStyles(list:GroupedList):Void
	{
		this.setScrollerStyles(list);
		
		list.padding = this.borderSize;
		
		var backgroundSkin:Image = new Image(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		list.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.backgroundDisabledSkinTexture);
		backgroundDisabledSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		list.backgroundDisabledSkin = backgroundDisabledSkin;
		
		list.verticalScrollPolicy = ScrollPolicy.AUTO;
	}
	
	//see List section for item renderer styles
	
	private function setGroupedListHeaderRendererStyles(headerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		headerRenderer.backgroundSkin = new Quad(this.controlSize, this.controlSize, GROUPED_LIST_HEADER_BACKGROUND_COLOR);
		
		headerRenderer.fontStyles = this.lightUIFontStyles.clone();
		headerRenderer.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		headerRenderer.horizontalAlign = HorizontalAlign.LEFT;
		
		headerRenderer.paddingTop = this.smallGutterSize;
		headerRenderer.paddingBottom = this.smallGutterSize;
		headerRenderer.paddingLeft = this.gutterSize;
		headerRenderer.paddingRight = this.gutterSize;
	}
	
	private function setGroupedListFooterRendererStyles(footerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		footerRenderer.backgroundSkin = new Quad(this.controlSize, this.controlSize, GROUPED_LIST_FOOTER_BACKGROUND_COLOR);
		
		footerRenderer.fontStyles = this.lightFontStyles.clone();
		footerRenderer.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		footerRenderer.horizontalAlign = HorizontalAlign.CENTER;
		
		footerRenderer.paddingTop = this.smallGutterSize;
		footerRenderer.paddingBottom = this.smallGutterSize;
		footerRenderer.paddingLeft = this.gutterSize;
		footerRenderer.paddingRight = this.gutterSize;
	}
	
	//-------------------------
	// Header
	//-------------------------
	
	private function setHeaderStyles(header:Header):Void
	{
		header.paddingTop = this.smallGutterSize;
		header.paddingBottom = this.smallGutterSize;
		header.paddingRight = this.gutterSize;
		header.paddingLeft = this.gutterSize;
		header.gap = this.smallGutterSize;
		header.titleGap = this.smallGutterSize;
		
		header.fontStyles = this.lightFontStyles.clone();
		header.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
		backgroundSkin.tileGrid = new Rectangle();
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		header.backgroundSkin = backgroundSkin;
	}
	
	//-------------------------
	// Label
	//-------------------------
	
	private function setLabelStyles(label:Label):Void
	{
		trace("setLabelStyles");
		label.fontStyles = this.lightFontStyles.clone();
		label.disabledFontStyles = this.lightDisabledFontStyles.clone();
	}
	
	private function setHeadingLabelStyles(label:Label):Void
	{
		label.fontStyles = this.largeLightFontStyles.clone();
		label.disabledFontStyles = this.largeLightDisabledFontStyles.clone();
	}
	
	private function setDetailLabelStyles(label:Label):Void
	{
		label.fontStyles = this.smallLightFontStyles.clone();
		label.disabledFontStyles = this.smallLightDisabledFontStyles.clone();
	}
	
	private function setToolTipLabelStyles(label:Label):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		label.backgroundSkin = backgroundSkin;
		
		label.fontStyles = this.lightFontStyles.clone();
		label.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		label.padding = this.smallGutterSize;
	}
	
	//-------------------------
	// LayoutGroup
	//-------------------------
	
	private function setToolbarLayoutGroupStyles(group:LayoutGroup):Void
	{
		if (group.layout == null)
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.padding = this.gutterSize;
			layout.gap = this.smallGutterSize;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			group.layout = layout;
		}
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
		backgroundSkin.tileGrid = new Rectangle();
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		group.backgroundSkin = backgroundSkin;
	}
	
	//-------------------------
	// List
	//-------------------------
	
	private function setListStyles(list:List):Void
	{
		this.setScrollerStyles(list);
		
		list.padding = this.borderSize;
		
		var backgroundSkin:Image = new Image(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		list.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.backgroundDisabledSkinTexture);
		backgroundDisabledSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		backgroundDisabledSkin.width = this.controlSize;
		backgroundDisabledSkin.height = this.controlSize;
		list.backgroundDisabledSkin = backgroundDisabledSkin;
		
		var dropIndicatorSkin:Quad = new Quad(this.borderSize, this.borderSize, LIGHT_TEXT_COLOR);
		list.dropIndicatorSkin = dropIndicatorSkin;
		
		list.verticalScrollPolicy = ScrollPolicy.AUTO;
	}
	
	private function setItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.itemRendererHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedUpSkinTexture);
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.lightFontStyles.clone();
		itemRenderer.disabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.selectedFontStyles = this.darkFontStyles.clone();
		itemRenderer.setFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		itemRenderer.setFontStylesForState(ButtonState.HOVER, this.darkFontStyles.clone());
		
		itemRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.iconLabelSelectedFontStyles = this.darkFontStyles.clone();
		itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		itemRenderer.setIconLabelFontStylesForState(ButtonState.HOVER, this.darkFontStyles.clone());
		
		itemRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.accessoryLabelSelectedFontStyles = this.darkFontStyles.clone();
		itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.HOVER, this.darkFontStyles.clone());
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.gap = this.smallGutterSize;
		itemRenderer.minGap = this.smallGutterSize;
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		
		itemRenderer.useStateDelayTimer = false;
	}
	
	private function setDrillDownItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.itemHasAccessory = false;
		
		var defaultAccessory:ImageSkin = new ImageSkin(this.listDrillDownAccessoryTexture);
		defaultAccessory.selectedTexture = this.listDrillDownAccessorySelectedTexture;
		defaultAccessory.setTextureForState(ButtonState.HOVER, this.listDrillDownAccessorySelectedTexture);
		defaultAccessory.setTextureForState(ButtonState.DOWN, this.listDrillDownAccessorySelectedTexture);
		itemRenderer.defaultAccessory = defaultAccessory;
	}
	
	private function setCheckItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.width = this.controlSize;
		skin.width = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.itemHasIcon = false;
		
		var icon:ImageSkin = new ImageSkin(this.checkUpIconTexture);
		icon.selectedTexture = this.checkSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.DOWN, this.checkDownIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.checkSelectedDownIconTexture);
		itemRenderer.defaultIcon = icon;
		
		itemRenderer.fontStyles = this.lightFontStyles.clone();
		itemRenderer.disabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.gap = this.smallGutterSize;
		itemRenderer.minGap = this.smallGutterSize;
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		
		itemRenderer.useStateDelayTimer = false;
	}
	
	//-------------------------
	// NumericStepper
	//-------------------------
	
	private function setNumericStepperStyles(stepper:NumericStepper):Void
	{
		stepper.buttonLayoutMode = StepperButtonLayoutMode.RIGHT_SIDE_VERTICAL;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		stepper.focusIndicatorSkin = focusIndicatorSkin;
		stepper.focusPadding = this.focusPaddingSize;
	}
	
	private function setNumericStepperTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.backgroundDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.backgroundFocusedSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = this.gridSize;
		skin.height = this.controlSize;
		skin.minWidth = this.gridSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		input.fontStyles = this.lightCenteredUIFontStyles.clone();
		input.disabledFontStyles = this.lightCenteredDisabledUIFontStyles.clone();
		
		input.gap = this.smallGutterSize;
		input.paddingTop = this.smallGutterSize;
		input.paddingBottom = this.smallGutterSize;
		input.paddingLeft = this.gutterSize;
		input.paddingRight = this.gutterSize;
	}
	
	private function setNumericStepperDecrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.verticalScrollBarIncrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.verticalScrollBarIncrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.verticalScrollBarIncrementButtonDisabledSkinTexture);
		skin.scale9Grid = SCROLL_BAR_STEP_BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.smallControlSize;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.verticalScrollBarIncrementButtonIconTexture);
		button.disabledIcon = new Image(this.verticalScrollBarIncrementButtonDisabledIconTexture);
		
		var incrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		incrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = incrementButtonDisabledIcon;
		
		button.keepDownStateOnRollOut = true;
		button.hasLabelTextRenderer = false;
	}
	
	private function setNumericStepperIncrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.verticalScrollBarDecrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.verticalScrollBarDecrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.verticalScrollBarDecrementButtonDisabledSkinTexture);
		skin.scale9Grid = SCROLL_BAR_STEP_BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.smallControlSize;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.verticalScrollBarDecrementButtonIconTexture);
		button.disabledIcon = new Image(this.verticalScrollBarDecrementButtonDisabledIconTexture);
		
		var incrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		incrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = incrementButtonDisabledIcon;
		
		button.keepDownStateOnRollOut = true;
		button.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// PageIndicator
	//-------------------------
	
	private function setPageIndicatorStyles(pageIndicator:PageIndicator):Void
	{
		pageIndicator.interactionMode = PageIndicatorInteractionMode.PRECISE;
		
		pageIndicator.normalSymbolFactory = this.pageIndicatorNormalSymbolFactory;
		pageIndicator.selectedSymbolFactory = this.pageIndicatorSelectedSymbolFactory;
		
		pageIndicator.gap = this.gutterSize;
		pageIndicator.padding = this.smallGutterSize;
	}
	
	//-------------------------
	// Panel
	//-------------------------
	
	private function setPanelStyles(panel:Panel):Void
	{
		this.setScrollerStyles(panel);
		
		var backgroundSkin:Image = new Image(this.backgroundPopUpSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_SCALE9_GRID;
		panel.backgroundSkin = backgroundSkin;
		
		panel.padding = this.gutterSize;
		panel.outerPadding = this.borderSize;
	}
	
	private function setPopupHeaderStyles(header:Header):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerPopupBackgroundSkinTexture);
		backgroundSkin.tileGrid = new Rectangle();
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		header.backgroundSkin = backgroundSkin;
		
		header.fontStyles = this.lightFontStyles.clone();
		header.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		header.paddingTop = this.smallGutterSize;
		header.paddingBottom = this.smallGutterSize;
		header.paddingRight = this.gutterSize;
		header.paddingLeft = this.gutterSize;
		header.gap = this.smallGutterSize;
		header.titleGap = this.smallGutterSize;
	}
	
	//-------------------------
	// PanelScreen
	//-------------------------
	
	private function setPanelScreenStyles(screen:PanelScreen):Void
	{
		this.setScrollerStyles(screen);
	}
	
	private function setPanelScreenHeaderStyles(header:Header):Void
	{
		this.setHeaderStyles(header);
		header.useExtraPaddingForOSStatusBar = true;
	}
	
	//-------------------------
	// PickerList
	//-------------------------
	
	private function setPickerListStyles(list:PickerList):Void
	{
		list.popUpContentManager = new DropDownPopUpContentManager();
		list.toggleButtonOnOpenAndClose = true;
		list.buttonFactory = pickerListButtonFactory;
	}
	
	private function setPickerListButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.buttonMinWidth;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		var icon:ImageSkin = new ImageSkin(this.pickerListButtonIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.pickerListButtonIconDisabledTexture);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			icon.selectedTexture = this.pickerListButtonIconSelectedTexture;
			icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.pickerListButtonIconDisabledTexture);
		}
		button.defaultIcon = icon;
		
		button.fontStyles = this.darkUIFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledUIFontStyles.clone();
		
		this.setBaseButtonStyles(button);
		
		button.gap = Math.POSITIVE_INFINITY; //fill as completely as possible
		button.horizontalAlign = HorizontalAlign.LEFT;
		button.iconPosition = RelativePosition.RIGHT;
	}
	
	//for the PickerList's pop-up list, see setDropDownListStyles()
	
	//-------------------------
	// ProgressBar
	//-------------------------
	
	private function setProgressBarStyles(progress:ProgressBar):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		if (progress.direction == Direction.VERTICAL)
		{
			backgroundSkin.width = this.smallControlSize;
			backgroundSkin.height = this.wideControlSize;
		}
		else
		{
			backgroundSkin.width = this.wideControlSize;
			backgroundSkin.height = this.smallControlSize;
		}
		progress.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.backgroundDisabledSkinTexture);
		backgroundDisabledSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		if (progress.direction == Direction.VERTICAL)
		{
			backgroundDisabledSkin.width = this.smallControlSize;
			backgroundDisabledSkin.height = this.wideControlSize;
		}
		else
		{
			backgroundDisabledSkin.width = this.wideControlSize;
			backgroundDisabledSkin.height = this.smallControlSize;
		}
		progress.backgroundDisabledSkin = backgroundDisabledSkin;
		
		var fillSkin:Image = new Image(this.buttonUpSkinTexture);
		fillSkin.scale9Grid = BUTTON_SCALE9_GRID;
		if (progress.direction == Direction.VERTICAL)
		{
			fillSkin.width = this.smallControlSize;
			fillSkin.height = this.progressBarFillMinSize;
		}
		else
		{
			fillSkin.width = this.progressBarFillMinSize;
			fillSkin.height = this.smallControlSize;
		}
		progress.fillSkin = fillSkin;
		
		var fillDisabledSkin:Image = new Image(this.buttonDisabledSkinTexture);
		fillDisabledSkin.scale9Grid = BUTTON_SCALE9_GRID;
		if (progress.direction == Direction.VERTICAL)
		{
			fillDisabledSkin.width = this.smallControlSize;
			fillDisabledSkin.height = this.progressBarFillMinSize;
		}
		else
		{
			fillDisabledSkin.width = this.progressBarFillMinSize;
			fillDisabledSkin.height = this.smallControlSize;
		}
		progress.fillDisabledSkin = fillDisabledSkin;
	}
	
	//-------------------------
	// Radio
	//-------------------------
	
	private function setRadioStyles(radio:Radio):Void
	{
		var skin:Quad = new Quad(this.controlSize, this.controlSize);
		skin.alpha = 0;
		radio.defaultSkin = skin;
		
		var icon:ImageSkin = new ImageSkin(this.radioUpIconTexture);
		icon.selectedTexture = this.radioSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.DOWN, this.radioDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.radioDisabledIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.radioSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.radioSelectedDisabledIconTexture);
		radio.defaultIcon = icon;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		radio.focusIndicatorSkin = focusIndicatorSkin;
		radio.focusPaddingLeft = this.focusPaddingSize;
		radio.focusPaddingRight = this.focusPaddingSize;
		
		radio.fontStyles = this.lightUIFontStyles.clone();
		radio.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		radio.horizontalAlign = HorizontalAlign.LEFT;
		radio.gap = this.smallGutterSize;
	}
	
	//-------------------------
	// ScrollBar
	//-------------------------
	
	private function setHorizontalScrollBarStyles(scrollBar:ScrollBar):Void
	{
		scrollBar.direction = Direction.HORIZONTAL;
		scrollBar.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		scrollBar.customIncrementButtonStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON;
		scrollBar.customDecrementButtonStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON;
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_THUMB;
		scrollBar.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MINIMUM_TRACK;
	}
	
	private function setVerticalScrollBarStyles(scrollBar:ScrollBar):Void
	{
		scrollBar.direction = Direction.VERTICAL;
		scrollBar.trackLayoutMode = TrackLayoutMode.SPLIT;
		
		scrollBar.customIncrementButtonStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON;
		scrollBar.customDecrementButtonStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON;
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_THUMB;
		scrollBar.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MINIMUM_TRACK;
		scrollBar.customMaximumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MAXIMUM_TRACK;
	}
	
	private function setHorizontalScrollBarIncrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.horizontalScrollBarIncrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.horizontalScrollBarIncrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.horizontalScrollBarIncrementButtonDisabledSkinTexture);
		skin.scale9Grid = SCROLL_BAR_STEP_BUTTON_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.horizontalScrollBarIncrementButtonIconTexture);
		button.disabledIcon = new Image(this.horizontalScrollBarIncrementButtonDisabledIconTexture);
		
		var incrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		incrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = incrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarDecrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.horizontalScrollBarDecrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.horizontalScrollBarDecrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.horizontalScrollBarDecrementButtonDisabledSkinTexture);
		skin.scale9Grid = SCROLL_BAR_STEP_BUTTON_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.horizontalScrollBarDecrementButtonIconTexture);
		button.disabledIcon = new Image(this.horizontalScrollBarDecrementButtonDisabledIconTexture);
		
		var decrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		decrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = decrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		skin.minHeight = this.smallControlSize;
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarMinimumTrackStyles(track:Button):Void
	{
		track.defaultSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_COLOR);
		track.downSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_DOWN_COLOR);
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarMaximumTrackStyles(track:Button):Void
	{
		track.defaultSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_COLOR);
		track.downSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_DOWN_COLOR);
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarIncrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.verticalScrollBarIncrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.verticalScrollBarIncrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.verticalScrollBarIncrementButtonDisabledSkinTexture);
		skin.scale9Grid = SCROLL_BAR_STEP_BUTTON_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.verticalScrollBarIncrementButtonIconTexture);
		button.disabledIcon = new Image(this.verticalScrollBarIncrementButtonDisabledIconTexture);
		
		var incrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		incrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = incrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarDecrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.verticalScrollBarDecrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.verticalScrollBarDecrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.verticalScrollBarDecrementButtonDisabledSkinTexture);
		skin.scale9Grid = SCROLL_BAR_STEP_BUTTON_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.verticalScrollBarDecrementButtonIconTexture);
		button.disabledIcon = new Image(this.verticalScrollBarDecrementButtonDisabledIconTexture);
		
		var decrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		decrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = decrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		skin.minHeight = this.smallControlSize;
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarMinimumTrackStyles(track:Button):Void
	{
		track.defaultSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_COLOR);
		track.downSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_DOWN_COLOR);
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarMaximumTrackStyles(track:Button):Void
	{
		track.defaultSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_COLOR);
		track.downSkin = new Quad(this.smallControlSize, this.smallControlSize, SCROLL_BAR_TRACK_DOWN_COLOR);
		
		track.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// ScrollContainer
	//-------------------------
	
	private function setScrollContainerStyles(container:ScrollContainer):Void
	{
		this.setScrollerStyles(container);
	}
	
	private function setToolbarScrollContainerStyles(container:ScrollContainer):Void
	{
		this.setScrollerStyles(container);
		if (container.layout == null)
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.padding = this.gutterSize;
			layout.gap = this.smallGutterSize;
			container.layout = layout;
		}
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
		backgroundSkin.tileGrid = new Rectangle();
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		container.backgroundSkin = backgroundSkin;
	}
	
	//-------------------------
	// ScrollScreen
	//-------------------------
	
	private function setScrollScreenStyles(screen:ScrollScreen):Void
	{
		this.setScrollerStyles(screen);
	}
	
	//-------------------------
	// ScrollText
	//-------------------------
	
	private function setScrollTextStyles(text:ScrollText):Void
	{
		this.setScrollerStyles(text);
		
		text.fontStyles = this.lightScrollTextFontStyles.clone();
		text.disabledFontStyles = this.lightDisabledScrollTextFontStyles.clone();
		
		text.padding = this.gutterSize;
	}
	
	//-------------------------
	// SimpleScrollBar
	//-------------------------
	
	private function setSimpleScrollBarStyles(scrollBar:SimpleScrollBar):Void
	{
		if (scrollBar.direction == Direction.HORIZONTAL)
		{
			scrollBar.paddingRight = this.scrollBarGutterSize;
			scrollBar.paddingBottom = this.scrollBarGutterSize;
			scrollBar.paddingLeft = this.scrollBarGutterSize;
			scrollBar.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB;
		}
		else
		{
			scrollBar.paddingTop = this.scrollBarGutterSize;
			scrollBar.paddingRight = this.scrollBarGutterSize;
			scrollBar.paddingBottom = this.scrollBarGutterSize;
			scrollBar.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB;
		}
	}
	
	private function setHorizontalSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var defaultSkin:Image = new Image(this.horizontalSimpleScrollBarThumbSkinTexture);
		defaultSkin.width = this.smallControlSize;
		defaultSkin.scale9Grid = HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
		thumb.defaultSkin = defaultSkin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var defaultSkin:Image = new Image(this.verticalSimpleScrollBarThumbSkinTexture);
		defaultSkin.height = this.smallControlSize;
		defaultSkin.scale9Grid = VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
		thumb.defaultSkin = defaultSkin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Slider
	//-------------------------
	
	private function setSliderStyles(slider:Slider):Void
	{
		slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		if (slider.direction == Direction.VERTICAL)
		{
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK;
			slider.customMaximumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK;
		}
		else //horizontal
		{
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK;
			slider.customMaximumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK;
		}
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		slider.focusIndicatorSkin = focusIndicatorSkin;
		slider.focusPadding = this.focusPaddingSize;
	}
	
	private function setSliderThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		skin.minWidth = this.smallControlSize;
		skin.minHeight = this.smallControlSize;
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.smallControlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.smallControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalSliderMaximumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.smallControlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.smallControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.wideControlSize;
		skin.minWidth = this.smallControlSize;
		skin.minHeight = this.wideControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMaximumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.wideControlSize;
		skin.minWidth = this.smallControlSize;
		skin.minHeight = this.wideControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// SpinnerList
	//-------------------------
	
	private function setSpinnerListStyles(list:SpinnerList):Void
	{
		this.setListStyles(list);
	}
	
	//-------------------------
	// TabBar
	//-------------------------
	
	private function setTabBarStyles(tabBar:TabBar):Void
	{
		tabBar.distributeTabSizes = false;
		tabBar.horizontalAlign = HorizontalAlign.LEFT;
		tabBar.verticalAlign = VerticalAlign.JUSTIFY;
	}
	
	private function setTabStyles(tab:ToggleButton):Void
	{
		var skin:ImageSkin = new ImageSkin(this.tabUpSkinTexture);
		skin.selectedTexture = this.tabSelectedSkinTexture;
		skin.setTextureForState(ButtonState.DOWN, this.tabDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.tabDisabledSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.tabSelectedDisabledSkinTexture);
		skin.scale9Grid = TAB_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		tab.defaultSkin = skin;
		
		tab.fontStyles = this.lightUIFontStyles.clone();
		tab.selectedFontStyles = this.darkUIFontStyles.clone();
		tab.setFontStylesForState(ButtonState.DOWN, this.darkUIFontStyles.clone());
		tab.setFontStylesForState(ButtonState.DISABLED, this.lightDisabledUIFontStyles.clone());
		tab.setFontStylesForState(ButtonState.DISABLED_AND_SELECTED, this.darkDisabledUIFontStyles.clone());
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		tab.focusIndicatorSkin = focusIndicatorSkin;
		tab.focusPadding = this.focusPaddingSize;
		
		tab.paddingTop = this.smallGutterSize;
		tab.paddingBottom = this.smallGutterSize;
		tab.paddingLeft = this.gutterSize;
		tab.paddingRight = this.gutterSize;
		tab.gap = this.smallGutterSize;
	}
	
	//-------------------------
	// TextArea
	//-------------------------
	
	private function setTextAreaStyles(textArea:TextArea):Void
	{
		this.setScrollerStyles(textArea);
		
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.backgroundDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.backgroundFocusedSkinTexture);
		skin.setTextureForState(TextInputState.ERROR, this.backgroundDangerSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = this.wideControlSize * 2;
		skin.height = this.wideControlSize;
		textArea.backgroundSkin = skin;
		
		textArea.fontStyles = this.lightScrollTextFontStyles.clone();
		textArea.disabledFontStyles = this.lightDisabledScrollTextFontStyles.clone();
		
		textArea.promptFontStyles = this.lightFontStyles.clone();
		textArea.promptDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		textArea.padding = this.borderSize;
		textArea.innerPadding = this.smallGutterSize;
	}
	
	private function setTextAreaErrorCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerCalloutStyles(callout);
		
		callout.fontStyles = this.lightFontStyles.clone();
		callout.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		callout.horizontalAlign = HorizontalAlign.LEFT;
		callout.verticalAlign = VerticalAlign.TOP;
	}
	
	//-------------------------
	// TextCallout
	//-------------------------
	
	private function setTextCalloutStyles(callout:TextCallout):Void
	{
		this.setCalloutStyles(callout);
		
		callout.fontStyles = this.lightFontStyles.clone();
		callout.disabledFontStyles = this.lightDisabledFontStyles.clone();
	}
	
	//-------------------------
	// TextInput
	//-------------------------
	
	private function setBaseTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.backgroundDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.backgroundFocusedSkinTexture);
		skin.setTextureForState(TextInputState.ERROR, this.backgroundDangerSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		input.fontStyles = this.lightFontStyles.clone();
		input.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		input.promptFontStyles = this.lightFontStyles.clone();
		input.promptDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		input.gap = this.smallGutterSize;
		input.paddingTop = this.smallGutterSize;
		input.paddingBottom = this.smallGutterSize;
		input.paddingLeft = this.gutterSize;
		input.paddingRight = this.gutterSize;
	}
	
	private function setTextInputStyles(input:TextInput):Void
	{
		this.setBaseTextInputStyles(input);
	}
	
	//private function setTextInputTextEditorStyles(textEditor:TextBlockTextEditor):Void
	//{
		//textEditor.cursorSkin = new Quad(1, 1, LIGHT_TEXT_COLOR);
		//textEditor.selectionSkin = new Quad(1, 1, TEXT_SELECTION_BACKGROUND_COLOR);
	//}
	
	private function setTextInputErrorCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerCalloutStyles(callout);
		
		callout.fontStyles = this.lightFontStyles.clone();
		callout.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		callout.horizontalAlign = HorizontalAlign.LEFT;
		callout.verticalAlign = VerticalAlign.TOP;
	}
	
	private function setSearchTextInputStyles(input:TextInput):Void
	{
		this.setBaseTextInputStyles(input);
		
		var icon:ImageSkin = new ImageSkin(this.searchIconTexture);
		icon.disabledTexture = this.searchIconDisabledTexture;
		input.defaultIcon = icon;
	}
	
	//-------------------------
	// Toast
	//-------------------------
	
	private function setToastStyles(toast:Toast):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundPopUpSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_SCALE9_GRID;
		toast.backgroundSkin = backgroundSkin;
		
		toast.fontStyles = this.lightFontStyles.clone();
		
		toast.width = this.extraWideControlSize;
		toast.paddingTop = this.gutterSize;
		toast.paddingRight = this.gutterSize;
		toast.paddingBottom = this.gutterSize;
		toast.paddingLeft = this.gutterSize;
		toast.gap = Math.POSITIVE_INFINITY;
		toast.minGap = this.smallGutterSize;
		toast.horizontalAlign = HorizontalAlign.LEFT;
		toast.verticalAlign = VerticalAlign.MIDDLE;
	}
	
	private function setToastActionsStyles(group:ButtonGroup):Void
	{
		group.direction = Direction.HORIZONTAL;
		group.gap = this.smallGutterSize;
		group.customButtonStyleName = THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON;
	}
	
	private function setToastActionsButtonStyles(button:Button):Void
	{
		button.fontStyles = this.selectedUIFontStyles.clone();
		button.setFontStylesForState(ButtonState.DOWN, this.lightUIFontStyles);
	}
	
	//-------------------------
	// ToggleSwitch
	//-------------------------
	
	private function setToggleSwitchStyles(toggle:ToggleSwitch):Void
	{
		toggle.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		toggle.focusIndicatorSkin = focusIndicatorSkin;
		toggle.focusPadding = this.focusPaddingSize;
		
		toggle.offLabelFontStyles = this.lightUIFontStyles.clone();
		toggle.offLabelDisabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		toggle.onLabelFontStyles = this.selectedUIFontStyles.clone();
		toggle.onLabelDisabledFontStyles = this.lightDisabledUIFontStyles.clone();
	}
	
	private function setToggleSwitchThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setToggleSwitchTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_SCALE9_GRID;
		skin.width = Math.fround(this.controlSize * 2.5);
		skin.height = this.controlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Tree
	//-------------------------
	
	private function setTreeStyles(tree:Tree):Void
	{
		this.setScrollerStyles(tree);
		
		tree.padding = this.borderSize;
		
		var backgroundSkin:Image = new Image(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		tree.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.backgroundDisabledSkinTexture);
		backgroundDisabledSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		backgroundDisabledSkin.width = this.controlSize;
		backgroundDisabledSkin.height = this.controlSize;
		tree.backgroundDisabledSkin = backgroundDisabledSkin;
		
		tree.verticalScrollPolicy = ScrollPolicy.AUTO;
	}
	
	private function setTreeItemRendererStyles(itemRenderer:DefaultTreeItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.indentation = this.treeDisclosureOpenIconTexture.width;
		
		var disclosureOpenIcon:ImageSkin = new ImageSkin(this.treeDisclosureOpenIconTexture);
		disclosureOpenIcon.selectedTexture = this.treeDisclosureOpenSelectedIconTexture;
		itemRenderer.disclosureOpenIcon = disclosureOpenIcon;
		
		var disclosureClosedIcon:ImageSkin = new ImageSkin(this.treeDisclosureClosedIconTexture);
		disclosureClosedIcon.selectedTexture = this.treeDisclosureClosedSelectedIconTexture;
		itemRenderer.disclosureClosedIcon = disclosureClosedIcon;
	}
	
	//-------------------------
	// VideoPlayer
	//-------------------------
	
	//private function setVideoPlayerStyles(player:VideoPlayer):Void
	//{
		//player.backgroundSkin = new Quad(1, 1, 0x000000);
	//}
	
	//-------------------------
	// PlayPauseToggleButton
	//-------------------------
	
	//private function setPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):Void
	//{
		//var skin:Quad = new Quad(this.controlSize, this.controlSize);
		//skin.alpha = 0;
		//button.defaultSkin = skin;
		//
		//var icon:ImageSkin = new ImageSkin(this.playPauseButtonPlayUpIconTexture);
		//icon.selectedTexture = this.playPauseButtonPauseUpIconTexture;
		//icon.setTextureForState(ButtonState.DOWN, this.playPauseButtonPlayDownIconTexture);
		//icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.playPauseButtonPauseDownIconTexture);
		//button.defaultIcon = icon;
		//
		//button.hasLabelTextRenderer = false;
	//}
	
	//private function setOverlayPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):Void
	//{
		//var icon:ImageSkin = new ImageSkin(null);
		//icon.setTextureForState(ButtonState.UP, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.HOVER, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.DOWN, this.overlayPlayPauseButtonPlayDownIconTexture);
		//button.setIconForState(ButtonState.UP, icon);
		//button.setIconForState(ButtonState.HOVER, icon);
		//button.setIconForState(ButtonState.DOWN, icon);
		//
		//var defaultIcon:Quad = new Quad(1, 1, 0xff00ff);
		//defaultIcon.alpha = 0;
		//button.defaultIcon = defaultIcon;
		//
		//button.hasLabelTextRenderer = false;
		//
		//var overlaySkin:Quad = new Quad(1, 1, VIDEO_OVERLAY_COLOR);
		//overlaySkin.alpha = VIDEO_OVERLAY_ALPHA;
		//button.upSkin = overlaySkin;
		//button.hoverSkin = overlaySkin;
	//}
	
	//-------------------------
	// FullScreenToggleButton
	//-------------------------
	
	//private function setFullScreenToggleButtonStyles(button:FullScreenToggleButton):Void
	//{
		//var skin:Quad = new Quad(this.controlSize, this.controlSize);
		//skin.alpha = 0;
		//button.defaultSkin = skin;
		//
		//var icon:ImageSkin = new ImageSkin(this.fullScreenToggleButtonEnterUpIconTexture);
		//icon.selectedTexture = this.fullScreenToggleButtonExitUpIconTexture;
		//icon.setTextureForState(ButtonState.DOWN, this.fullScreenToggleButtonEnterDownIconTexture);
		//icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.fullScreenToggleButtonExitDownIconTexture);
		//button.defaultIcon = icon;
		//
		//button.hasLabelTextRenderer = false;
	//}
	
	//-------------------------
	// VolumeSlider
	//-------------------------
	
	//private function setVolumeSliderStyles(slider:VolumeSlider):Void
	//{
		//slider.direction = Direction.HORIZONTAL;
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		//slider.focusIndicatorSkin = focusIndicatorSkin;
		//slider.focusPadding = this.focusPaddingSize;
		//
		//slider.showThumb = false;
	//}
	
	private function setVolumeSliderThumbStyles(thumb:Button):Void
	{
		var thumbSize:Float = 6;
		var defaultSkin:Quad = new Quad(thumbSize, thumbSize);
		defaultSkin.width = 0;
		defaultSkin.height = 0;
		thumb.defaultSkin = defaultSkin;
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVolumeSliderMinimumTrackStyles(track:Button):Void
	{
		var defaultSkin:ImageLoader = new ImageLoader();
		defaultSkin.scaleContent = false;
		defaultSkin.source = this.volumeSliderMinimumTrackSkinTexture;
		track.defaultSkin = defaultSkin;
		track.hasLabelTextRenderer = false;
	}
	
	private function setVolumeSliderMaximumTrackStyles(track:Button):Void
	{
		var defaultSkin:ImageLoader = new ImageLoader();
		defaultSkin.scaleContent = false;
		defaultSkin.horizontalAlign = HorizontalAlign.RIGHT;
		defaultSkin.source = this.volumeSliderMaximumTrackSkinTexture;
		track.defaultSkin = defaultSkin;
		track.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// MuteToggleButton
	//-------------------------
	
	//private function setMuteToggleButtonStyles(button:MuteToggleButton):Void
	//{
		//var skin:Quad = new Quad(this.controlSize, this.controlSize);
		//skin.alpha = 0;
		//button.defaultSkin = skin;
		//
		//var icon:ImageSkin = new ImageSkin(this.muteToggleButtonLoudUpIconTexture);
		//icon.selectedTexture = this.muteToggleButtonMutedUpIconTexture;
		//icon.setTextureForState(ButtonState.DOWN, this.muteToggleButtonLoudDownIconTexture);
		//icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.muteToggleButtonMutedDownIconTexture);
		//button.defaultIcon = icon;
		//
		//button.showVolumeSliderOnHover = true;
		//button.hasLabelTextRenderer = false;
	//}
	
	//private function setPopUpVolumeSliderStyles(slider:VolumeSlider):Void
	//{
		//slider.direction = Direction.VERTICAL;
		//slider.trackLayoutMode = TrackLayoutMode.SINGLE;
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		//slider.focusIndicatorSkin = focusIndicatorSkin;
		//slider.focusPadding = this.focusPaddingSize;
		//
		//slider.minimumPadding = this.popUpVolumeSliderPaddingSize;
		//slider.maximumPadding = this.popUpVolumeSliderPaddingSize;
		//slider.customThumbStyleName = THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_THUMB;
		//slider.customMinimumTrackStyleName = THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK;
	//}
	
	//private function setPopUpVolumeSliderTrackStyles(track:Button):Void
	//{
		//var skin:ImageSkin = new ImageSkin(this.popUpVolumeSliderTrackSkinTexture);
		//skin.scale9Grid = VOLUME_SLIDER_TRACK_SCALE9_GRID;
		//skin.width = this.gridSize;
		//skin.height = this.wideControlSize;
		//track.defaultSkin = skin;
		//
		//track.hasLabelTextRenderer = false;
	//}
	
	//-------------------------
	// SeekSlider
	//-------------------------
	
	//private function setSeekSliderStyles(slider:SeekSlider):Void
	//{
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		//slider.showThumb = false;
		//var progressSkin:Image = new Image(this.seekSliderProgressSkinTexture);
		//progressSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		//progressSkin.width = this.smallControlSize;
		//progressSkin.height = this.smallControlSize;
		//slider.progressSkin = progressSkin;
	//}
	
	//private function setSeekSliderThumbStyles(thumb:Button):Void
	//{
		//var thumbSize:Number = 6;
		//var defaultSkin:Quad = new Quad(thumbSize, thumbSize);
		//defaultSkin.width = 0;
		//defaultSkin.height = 0;
		//thumb.defaultSkin = defaultSkin;
		//thumb.hasLabelTextRenderer = false;
	//}
	
	//private function setSeekSliderMinimumTrackStyles(track:Button):Void
	//{
		//var defaultSkin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		//defaultSkin.scale9Grid = BUTTON_SCALE9_GRID;
		//defaultSkin.width = this.wideControlSize;
		//defaultSkin.height = this.smallControlSize;
		//defaultSkin.minWidth = this.wideControlSize;
		//defaultSkin.minHeight = this.smallControlSize;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	
	//private function setSeekSliderMaximumTrackStyles(track:Button):Void
	//{
		//var defaultSkin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		//defaultSkin.scale9Grid = DEFAULT_SCALE9_GRID;
		//defaultSkin.width = this.wideControlSize;
		//defaultSkin.height = this.smallControlSize;
		//defaultSkin.minWidth = this.wideControlSize;
		//defaultSkin.minHeight = this.smallControlSize;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	
}