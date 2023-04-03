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
import feathers.controls.Alert;
import feathers.controls.AutoComplete;
import feathers.controls.AutoSizeMode;
import feathers.controls.Button;
import feathers.controls.ButtonGroup;
import feathers.controls.ButtonState;
import feathers.controls.Callout;
import feathers.controls.Check;
import feathers.controls.DataGrid;
import feathers.controls.DateTimeSpinner;
import feathers.controls.Drawers;
import feathers.controls.GroupedList;
import feathers.controls.Header;
import feathers.controls.IScrollBar;
import feathers.controls.ImageLoader;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.NumericStepper;
import feathers.controls.PageIndicator;
import feathers.controls.PageIndicatorInteractionMode;
import feathers.controls.Panel;
import feathers.controls.PanelScreen;
import feathers.controls.PickerList;
import feathers.controls.ProgressBar;
import feathers.controls.Radio;
import feathers.controls.ScrollBar;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollInteractionMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.ScrollScreen;
import feathers.controls.ScrollText;
import feathers.controls.Scroller;
import feathers.controls.SimpleScrollBar;
import feathers.controls.Slider;
import feathers.controls.SpinnerList;
import feathers.controls.StepperButtonLayoutMode;
import feathers.controls.TabBar;
import feathers.controls.TextArea;
import feathers.controls.TextCallout;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.controls.Toast;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleSwitch;
import feathers.controls.TrackLayoutMode;
import feathers.controls.Tree;
import feathers.controls.popups.DropDownPopUpContentManager;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.controls.renderers.DefaultDataGridCellRenderer;
import feathers.controls.renderers.DefaultDataGridHeaderRenderer;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.DefaultTreeItemRenderer;
import feathers.controls.text.BitmapFontTextEditor;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.core.FeathersControl;
import feathers.core.FocusManager;
import feathers.core.PopUpManager;
import feathers.core.ToolTipManager;
import feathers.layout.Direction;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.ImageSkin;
import openfl.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Stage;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.textures.TextureSmoothing;

/**
 * The base class for the "Minimal" theme for desktop Feathers apps. Handles
 * everything except asset loading, which is left to subclasses.
 *
 * @see MinimalDesktopTheme
 * @see MinimalDesktopThemeWithAssetManager
 */
class BaseMinimalDesktopTheme extends StyleNameFunctionTheme 
{
	/**
	 * The name of the embedded bitmap font used by controls in this theme.
	 */
	public static inline var FONT_NAME:String = "PF Ronda Seven";

	/**
	 * The stack of fonts to use for controls that don't use embedded fonts.
	 */
	public static inline var FONT_NAME_STACK:String = "PF Ronda Seven,Roboto,Helvetica,Arial,_sans";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a horizontal slider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK:String = "minimal-desktop-horizontal-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a vertical slider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK:String = "minimal-desktop-vertical-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the decrement button of a horizontal scroll bar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON:String = "minimal-desktop-horizontal-scroll-bar-decrement-button";

	/**
	 * @private
	 * The theme's custom style name for the increment button of a horizontal scroll bar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON:String = "minimal-desktop-horizontal-scroll-bar-increment-button";

	/**
	 * @private
	 * The theme's custom style name for the decrement button of a horizontal scroll bar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON:String = "minimal-desktop-vertical-scroll-bar-decrement-button";

	/**
	 * @private
	 * The theme's custom style name for the increment button of a vertical scroll bar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON:String = "minimal-desktop-vertical-scroll-bar-increment-button";

	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_THUMB:String = "minimal-desktop-pop-up-volume-slider-thumb";

	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK:String = "minimal-desktop-pop-up-volume-slider-minimum-track";

	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_NUMERIC_STEPPER_TEXT_INPUT_TEXT_EDITOR:String = "minimal-desktop-numeric-stepper-text-input-text-editor";

	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER:String = "minimal-desktop-date-time-spinner-list-item-renderer";

	/**
	 * @private
	 * The theme's custom style name for the text renderer of a tool tip Label.
	 */
	private static inline var THEME_STYLE_NAME_TOOL_TIP_LABEL_TEXT_RENDERER:String = "minimal-desktop-tool-tip-label-text-renderer";

	/**
	 * @private
	 */
	private static inline var THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON:String = "minimal-desktop-alert-button-group-button";
	
	/**
	 * @private
	 * The theme's custom style name for a button in a Toast.
	 */
	private static inline var THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON:String = "minimal-mobile-toast-actions-button";

	private static inline var FONT_TEXTURE_NAME:String = "pf-ronda-seven-font";

	private static inline var ATLAS_SCALE_FACTOR:Float = 2;

	private static var SOLID_COLOR_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 1, 1);
	
	private static var DEFAULT_SCALE_9_GRID:Rectangle = new Rectangle(3, 3, 1, 1);
	private static var SCROLLBAR_THUMB_SCALE_9_GRID:Rectangle = new Rectangle(1, 1, 2, 2);
	private static var TAB_SCALE_9_GRID:Rectangle = new Rectangle(4, 4, 1, 1);
	private static var HEADER_SCALE_9_GRID:Rectangle = new Rectangle(0, 2, 3, 1);
	private static var VOLUME_SLIDER_TRACK_SCALE9_GRID:Rectangle = new Rectangle(18, 13, 1, 1);
	private static var SEEK_SLIDER_PROGRESS_SKIN_SCALE9_GRID:Rectangle = new Rectangle(0, 2, 2, 10);
	private static var BACK_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(11, 0, 1, 20);
	private static var FORWARD_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(1, 0, 1, 20);
	private static var DATA_GRID_COLUMN_RESIZE_SKIN_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 1, 3);
	private static var DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 3, 3);
	private static var DATA_GRID_HEADER_RENDERER_SCALE_9_GRID:Rectangle = new Rectangle(1, 1, 1, 1);
	private static var DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 1, 3);

	private static inline var BACKGROUND_COLOR:Int = 0xf3f3f3;
	private static inline var PRIMARY_TEXT_COLOR:Int = 0x666666;
	private static inline var DISABLED_TEXT_COLOR:Int = 0x999999;
	private static inline var DANGER_TEXT_COLOR:Int = 0x990000;
	private static inline var MODAL_OVERLAY_COLOR:Int = 0xcccccc;
	private static inline var MODAL_OVERLAY_ALPHA:Float = 0.4;
	private static inline var VIDEO_OVERLAY_COLOR:Int = 0xcccccc;
	private static inline var VIDEO_OVERLAY_ALPHA:Float = 0.2;
	private static inline var DATA_GRID_COLUMN_OVERLAY_COLOR:Int = 0xeeeeee;
	private static inline var DATA_GRID_COLUMN_OVERLAY_ALPHA:Float = 0.6;
	
	/**
	 * The default global text renderer factory for this theme creates a
	 * BitmapFontTextRenderer.
	 */
	private static function textRendererFactory():BitmapFontTextRenderer
	{
		var renderer:BitmapFontTextRenderer = new BitmapFontTextRenderer();
		//since it's a pixel font, we don't want to smooth it.
		renderer.textureSmoothing = TextureSmoothing.NONE;
		return renderer;
	}
	
	/**
	 * The default global text editor factory for this theme creates a
	 * BitmapFontTextEditor.
	 */
	private static function textEditorFactory():BitmapFontTextEditor
	{
		return new BitmapFontTextEditor();
	}
	
	/**
	 * This theme's scroll bar type is ScrollBar.
	 */
	private static function scrollBarFactory():IScrollBar
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
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * A normal font size. Since it's a pixel font, we want a multiple of
	 * the original size, which, in this case, is 8.
	 */
	private var fontSize:Int = 8;

	/**
	 * A larger font size for headers.
	 */
	private var largeFontSize:Int = 16;

	/**
	 * The size, in pixels, of major regions in the grid. Used for sizing
	 * containers and larger UI controls.
	 */
	private var gridSize:Int = 30;

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
	 * The width, in pixels, of UI controls that span across multiple grid regions.
	 */
	private var wideControlSize:Int = 98;

	/**
	 * The width, in pixels, of very large UI controls.
	 */
	private var extraWideControlSize:Int = 210;

	/**
	 * The minimum width, in pixels, of some types of buttons.
	 */
	private var buttonMinWidth:Int = 64;

	/**
	 * The size, in pixels, of a typical UI control.
	 */
	private var controlSize:Int = 20;

	/**
	 * The size, in pixels, of smaller UI controls.
	 */
	private var smallControlSize:Int = 12;

	/**
	 * The size, in pixels, of a border around any control.
	 */
	private var borderSize:Int = 1;

	/**
	 * The size, in pixels, of a drop shadow on a control's bottom right.
	 */
	private var dropShadowSize:Int = 4;
	
	private var calloutBackgroundMinSize:Int = 5;
	private var calloutTopLeftArrowOverlapGapSize:Int = -2;
	private var calloutBottomRightArrowOverlapGapSize:Int = -6;
	private var progressBarFillMinSize:Int = 7;
	private var popUpSize:Int = 336;
	private var dropDownGapSize:Int = -1;
	private var focusPaddingSize:Int = -2;
	private var popUpVolumeSliderPaddingTopLeft:Int = 9;
	private var popUpVolumeSliderPaddingBottomRight:Int = 13;

	/**
	 * The texture atlas that contains skins for this theme. This base class
	 * does not initialize this member variable. Subclasses are expected to
	 * load the assets somehow and set the <code>atlas</code> member
	 * variable before calling <code>initialize()</code>.
	 */
	private var atlas:TextureAtlas;

	private var focusIndicatorSkinTexture:Texture;
	
	private var buttonUpSkinTexture:Texture;
	private var buttonDownSkinTexture:Texture;
	private var buttonDisabledSkinTexture:Texture;
	private var buttonSelectedSkinTexture:Texture;
	private var buttonSelectedDisabledSkinTexture:Texture;
	private var buttonCallToActionUpSkinTexture:Texture;
	private var buttonDangerUpSkinTexture:Texture;
	private var buttonDangerDownSkinTexture:Texture;
	private var buttonBackUpSkinTexture:Texture;
	private var buttonBackDownSkinTexture:Texture;
	private var buttonBackDisabledSkinTexture:Texture;
	private var buttonForwardUpSkinTexture:Texture;
	private var buttonForwardDownSkinTexture:Texture;
	private var buttonForwardDisabledSkinTexture:Texture;

	private var tabSkinTexture:Texture;
	private var tabDisabledSkinTexture:Texture;
	private var tabSelectedSkinTexture:Texture;
	private var tabSelectedDisabledSkinTexture:Texture;

	private var thumbSkinTexture:Texture;
	private var thumbDisabledSkinTexture:Texture;

	private var simpleScrollBarThumbSkinTexture:Texture;

	private var insetBackgroundSkinTexture:Texture;
	private var insetBackgroundDisabledSkinTexture:Texture;
	private var insetBackgroundFocusedSkinTexture:Texture;
	private var insetBackgroundDangerSkinTexture:Texture;

	private var pickerListButtonIconUpTexture:Texture;
	private var pickerListButtonIconSelectedTexture:Texture;
	private var pickerListButtonIconDisabledTexture:Texture;
	private var searchIconTexture:Texture;
	private var searchIconDisabledTexture:Texture;
	private var verticalScrollBarDecrementButtonIconTexture:Texture;
	private var verticalScrollBarIncrementButtonIconTexture:Texture;
	private var horizontalScrollBarIncrementButtonIconTexture:Texture;
	private var horizontalScrollBarDecrementButtonIconTexture:Texture;

	private var headerSkinTexture:Texture;
	private var panelHeaderSkinTexture:Texture;

	private var panelBackgroundSkinTexture:Texture;
	private var popUpBackgroundSkinTexture:Texture;
	private var dangerPopUpBackgroundSkinTexture:Texture;
	
	private var calloutTopArrowSkinTexture:Texture;
	private var calloutBottomArrowSkinTexture:Texture;
	private var calloutLeftArrowSkinTexture:Texture;
	private var calloutRightArrowSkinTexture:Texture;
	private var dangerCalloutTopArrowSkinTexture:Texture;
	private var dangerCalloutBottomArrowSkinTexture:Texture;
	private var dangerCalloutLeftArrowSkinTexture:Texture;
	private var dangerCalloutRightArrowSkinTexture:Texture;

	private var checkIconTexture:Texture;
	private var checkDisabledIconTexture:Texture;
	private var checkSelectedIconTexture:Texture;
	private var checkSelectedDisabledIconTexture:Texture;

	private var radioIconTexture:Texture;
	private var radioDisabledIconTexture:Texture;
	private var radioSelectedIconTexture:Texture;
	private var radioSelectedDisabledIconTexture:Texture;

	private var pageIndicatorSymbolTexture:Texture;
	private var pageIndicatorSelectedSymbolTexture:Texture;

	private var listBackgroundSkinTexture:Texture;
	private var listInsetBackgroundSkinTexture:Texture;
	
	private var itemRendererUpSkinTexture:Texture;
	private var itemRendererHoverSkinTexture:Texture;
	private var itemRendererSelectedSkinTexture:Texture;
	private var headerRendererSkinTexture:Texture;
	
	private var listDrillDownAccessoryTexture:Texture;

	private var treeDisclosureOpenIconTexture:Texture;
	private var treeDisclosureClosedIconTexture:Texture;

	private var dataGridHeaderRendererSkinTexture:Texture;
	private var dataGridColumnResizeSkinTexture:Texture;
	private var dataGridHeaderDividerSkinTexture:Texture;
	private var dataGridColumnDropIndicatorSkinTexture:Texture;
	private var dataGridHeaderSortAscendingIconTexture:Texture;
	private var dataGridHeaderSortDescendingIconTexture:Texture;

	//media textures
	private var playPauseButtonPlayUpIconTexture:Texture;
	private var playPauseButtonPauseUpIconTexture:Texture;
	private var overlayPlayPauseButtonPlayUpIconTexture:Texture;
	private var overlayPlayPauseButtonPlayDownIconTexture:Texture;
	private var fullScreenToggleButtonEnterUpIconTexture:Texture;
	private var fullScreenToggleButtonExitUpIconTexture:Texture;
	private var muteToggleButtonLoudUpIconTexture:Texture;
	private var muteToggleButtonMutedUpIconTexture:Texture;
	private var volumeSliderMinimumTrackSkinTexture:Texture;
	private var volumeSliderMaximumTrackSkinTexture:Texture;
	private var popUpVolumeSliderTrackSkinTexture:Texture;
	private var seekSliderProgressSkinTexture:Texture;

	private var primaryFontStyles:TextFormat;
	private var disabledFontStyles:TextFormat;
	private var headingFontStyles:TextFormat;
	private var headingDisabledFontStyles:TextFormat;
	private var centeredFontStyles:TextFormat;
	private var centeredDisabledFontStyles:TextFormat;
	private var dangerFontStyles:TextFormat;
	private var scrollTextFontStyles:TextFormat;
	private var scrollTextDisabledFontStyles:TextFormat;
	
	/**
	 * Disposes the texture atlas and bitmap font before calling
	 * super.dispose().
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
		TextField.unregisterCompositor(FONT_NAME);
		
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
		this.starling.stage.color = BACKGROUND_COLOR;
		this.starling.nativeStage.color = BACKGROUND_COLOR;
	}
	
	/**
	 * Initializes global variables (not including global style providers).
	 */
	private function initializeGlobals():Void
	{
		var stage:Stage = this.starling.stage;
		FocusManager.setEnabledForStage(stage, true);
		ToolTipManager.setEnabledForStage(stage, true);
		
		PopUpManager.overlayFactory = popUpOverlayFactory;
		Callout.stagePadding = this.smallGutterSize;
		Toast.containerFactory = toastContainerFactory;
		
		FeathersControl.defaultTextRendererFactory = textRendererFactory;
		FeathersControl.defaultTextEditorFactory = textEditorFactory;
	}
	
	/**
	 * Initializes the textures by extracting them from the atlas and
	 * setting up any scaling grids that are needed.
	 */
	private function initializeTextures():Void
	{
		this.focusIndicatorSkinTexture = this.atlas.getTexture("focus-indicator-skin0000");
		
		this.buttonUpSkinTexture = this.atlas.getTexture("button-up-skin0000");
		this.buttonDownSkinTexture = this.atlas.getTexture("button-down-skin0000");
		this.buttonDisabledSkinTexture = this.atlas.getTexture("button-disabled-skin0000");
		this.buttonSelectedSkinTexture = this.atlas.getTexture("inset-background-enabled-skin0000");
		this.buttonSelectedDisabledSkinTexture = this.atlas.getTexture("inset-background-disabled-skin0000");
		this.buttonCallToActionUpSkinTexture = this.atlas.getTexture("call-to-action-button-up-skin0000");
		this.buttonDangerUpSkinTexture = this.atlas.getTexture("danger-button-up-skin0000");
		this.buttonDangerDownSkinTexture = this.atlas.getTexture("danger-button-down-skin0000");
		this.buttonBackUpSkinTexture = this.atlas.getTexture("back-button-up-skin0000");
		this.buttonBackDownSkinTexture = this.atlas.getTexture("back-button-down-skin0000");
		this.buttonBackDisabledSkinTexture = this.atlas.getTexture("back-button-disabled-skin0000");
		this.buttonForwardUpSkinTexture = this.atlas.getTexture("forward-button-up-skin0000");
		this.buttonForwardDownSkinTexture = this.atlas.getTexture("forward-button-down-skin0000");
		this.buttonForwardDisabledSkinTexture = this.atlas.getTexture("forward-button-disabled-skin0000");
		
		this.tabSkinTexture = this.atlas.getTexture("tab-up-skin0000");
		this.tabDisabledSkinTexture = this.atlas.getTexture("tab-disabled-skin0000");
		this.tabSelectedSkinTexture = this.atlas.getTexture("tab-selected-up-skin0000");
		this.tabSelectedDisabledSkinTexture = this.atlas.getTexture("tab-selected-disabled-skin0000");
		
		this.thumbSkinTexture = this.atlas.getTexture("face-up-skin0000");
		this.thumbDisabledSkinTexture = this.atlas.getTexture("face-disabled-skin0000");
		
		this.simpleScrollBarThumbSkinTexture = this.atlas.getTexture("simple-scroll-bar-thumb-skin0000");
		
		this.listBackgroundSkinTexture = this.atlas.getTexture("list-background-skin0000");
		this.listInsetBackgroundSkinTexture = this.atlas.getTexture("list-inset-background-skin0000");
		
		this.itemRendererUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-up-skin0000"), SOLID_COLOR_TEXTURE_REGION);
		this.itemRendererHoverSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-hover-skin0000"), SOLID_COLOR_TEXTURE_REGION);
		this.itemRendererSelectedSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-selected-skin0000"), SOLID_COLOR_TEXTURE_REGION);
		this.headerRendererSkinTexture = Texture.fromTexture(this.atlas.getTexture("header-renderer-skin0000"), SOLID_COLOR_TEXTURE_REGION);
		
		this.insetBackgroundSkinTexture = this.atlas.getTexture("inset-background-enabled-skin0000");
		this.insetBackgroundDisabledSkinTexture = this.atlas.getTexture("inset-background-disabled-skin0000");
		this.insetBackgroundFocusedSkinTexture = this.atlas.getTexture("inset-background-focused-skin0000");
		this.insetBackgroundDangerSkinTexture = this.atlas.getTexture("inset-background-danger-skin0000");
		
		this.pickerListButtonIconUpTexture = this.atlas.getTexture("picker-list-icon0000");
		this.pickerListButtonIconSelectedTexture = this.atlas.getTexture("picker-list-selected-icon0000");
		this.pickerListButtonIconDisabledTexture = this.atlas.getTexture("picker-list-disabled-icon0000");
		this.searchIconTexture = this.atlas.getTexture("search-enabled-icon0000");
		this.searchIconDisabledTexture = this.atlas.getTexture("search-disabled-icon0000");
		this.verticalScrollBarDecrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-icon0000");
		this.verticalScrollBarIncrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-icon0000");
		this.horizontalScrollBarDecrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-icon0000");
		this.horizontalScrollBarIncrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-icon0000");
		
		this.headerSkinTexture = this.atlas.getTexture("header-background-skin0000");
		this.panelHeaderSkinTexture = this.atlas.getTexture("panel-header-background-skin0000");
		
		this.popUpBackgroundSkinTexture = this.atlas.getTexture("pop-up-background-skin0000");
		this.dangerPopUpBackgroundSkinTexture = this.atlas.getTexture("danger-pop-up-background-skin0000");
		this.panelBackgroundSkinTexture = this.atlas.getTexture("panel-background-skin0000");
		this.calloutTopArrowSkinTexture = this.atlas.getTexture("callout-top-arrow-skin0000");
		this.calloutBottomArrowSkinTexture = this.atlas.getTexture("callout-bottom-arrow-skin0000");
		this.calloutLeftArrowSkinTexture = this.atlas.getTexture("callout-left-arrow-skin0000");
		this.calloutRightArrowSkinTexture = this.atlas.getTexture("callout-right-arrow-skin0000");
		this.dangerCalloutTopArrowSkinTexture = this.atlas.getTexture("danger-callout-top-arrow-skin0000");
		this.dangerCalloutBottomArrowSkinTexture = this.atlas.getTexture("danger-callout-bottom-arrow-skin0000");
		this.dangerCalloutLeftArrowSkinTexture = this.atlas.getTexture("danger-callout-left-arrow-skin0000");
		this.dangerCalloutRightArrowSkinTexture = this.atlas.getTexture("danger-callout-right-arrow-skin0000");
		
		this.checkIconTexture = this.atlas.getTexture("check-up-icon0000");
		this.checkDisabledIconTexture = this.atlas.getTexture("check-disabled-icon0000");
		this.checkSelectedIconTexture = this.atlas.getTexture("check-selected-up-icon0000");
		this.checkSelectedDisabledIconTexture = this.atlas.getTexture("check-selected-disabled-icon0000");
		
		this.radioIconTexture = this.atlas.getTexture("radio-up-icon0000");
		this.radioDisabledIconTexture = this.atlas.getTexture("radio-disabled-icon0000");
		this.radioSelectedIconTexture = this.atlas.getTexture("radio-selected-up-icon0000");
		this.radioSelectedDisabledIconTexture = this.atlas.getTexture("radio-selected-disabled-icon0000");
		
		this.pageIndicatorSymbolTexture = this.atlas.getTexture("page-indicator-symbol0000");
		this.pageIndicatorSelectedSymbolTexture = this.atlas.getTexture("page-indicator-selected-symbol0000");
		
		this.playPauseButtonPlayUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-play-up-icon0000");
		this.playPauseButtonPauseUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-pause-up-icon0000");
		this.overlayPlayPauseButtonPlayUpIconTexture = this.atlas.getTexture("overlay-play-pause-toggle-button-play-up-icon0000");
		this.overlayPlayPauseButtonPlayDownIconTexture = this.atlas.getTexture("overlay-play-pause-toggle-button-play-down-icon0000");
		this.fullScreenToggleButtonEnterUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-enter-up-icon0000");
		this.fullScreenToggleButtonExitUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-exit-up-icon0000");
		this.muteToggleButtonMutedUpIconTexture = this.atlas.getTexture("mute-toggle-button-muted-up-icon0000");
		this.muteToggleButtonLoudUpIconTexture = this.atlas.getTexture("mute-toggle-button-loud-up-icon0000");
		this.volumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("volume-slider-minimum-track-skin0000");
		this.volumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("volume-slider-maximum-track-skin0000");
		this.popUpVolumeSliderTrackSkinTexture = this.atlas.getTexture("pop-up-volume-slider-track-skin0000");
		this.seekSliderProgressSkinTexture = this.atlas.getTexture("seek-slider-progress-skin0000");
		
		this.listDrillDownAccessoryTexture = this.atlas.getTexture("list-accessory-drill-down-icon0000");
		
		this.treeDisclosureOpenIconTexture = this.atlas.getTexture("tree-disclosure-open-icon0000");
		this.treeDisclosureClosedIconTexture = this.atlas.getTexture("tree-disclosure-closed-icon0000");
		
		this.dataGridColumnResizeSkinTexture = this.atlas.getTexture("data-grid-column-resize-skin0000");
		this.dataGridHeaderDividerSkinTexture = this.atlas.getTexture("data-grid-header-divider-skin0000");
		this.dataGridHeaderRendererSkinTexture = this.atlas.getTexture("data-grid-header-renderer-skin0000");
		this.dataGridColumnDropIndicatorSkinTexture = this.atlas.getTexture("data-grid-column-drop-indicator-skin0000");
		this.dataGridHeaderSortAscendingIconTexture = this.atlas.getTexture("data-grid-header-sort-ascending-icon0000");
		this.dataGridHeaderSortDescendingIconTexture = this.atlas.getTexture("data-grid-header-sort-descending-icon0000");
	}
	
	/**
	 * Initializes font sizes and formats.
	 */
	private function initializeFonts():Void
	{
		this.primaryFontStyles = new TextFormat(FONT_NAME, this.fontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.disabledFontStyles = new TextFormat(FONT_NAME, this.fontSize, DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.headingFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.headingDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.centeredFontStyles = new TextFormat(FONT_NAME, this.fontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.CENTER, VerticalAlign.TOP);
		this.centeredDisabledFontStyles = new TextFormat(FONT_NAME, this.fontSize, DISABLED_TEXT_COLOR, HorizontalAlign.CENTER, VerticalAlign.TOP);
		this.dangerFontStyles = new TextFormat(FONT_NAME, this.fontSize, DANGER_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.scrollTextFontStyles = new TextFormat(FONT_NAME_STACK, this.fontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.scrollTextDisabledFontStyles = new TextFormat(FONT_NAME_STACK, this.fontSize, DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	}
	
	/**
	 * Sets global style providers for all components.
	 */
	private function initializeStyleProviders():Void
	{
		//alert
		this.getStyleProviderForClass(Alert).defaultStyleFunction = this.setAlertStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPanelHeaderStyles);
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
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ButtonGroup.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setButtonGroupButtonStyles);
		
		//callout
		this.getStyleProviderForClass(Callout).defaultStyleFunction = this.setCalloutStyles;
		
		//check
		this.getStyleProviderForClass(Check).defaultStyleFunction = this.setCheckStyles;
		
		//data grid
		this.getStyleProviderForClass(DataGrid).defaultStyleFunction = this.setDataGridStyles;
		this.getStyleProviderForClass(DefaultDataGridHeaderRenderer).defaultStyleFunction = this.setDataGridHeaderRendererStyles;
		this.getStyleProviderForClass(DefaultDataGridCellRenderer).defaultStyleFunction = this.setItemRendererStyles;
		
		//date time spinner
		this.getStyleProviderForClass(DateTimeSpinner).defaultStyleFunction = this.setDateTimeSpinnerStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER, this.setDateTimeSpinnerListItemRendererStyles);
		
		//drawers
		this.getStyleProviderForClass(Drawers).defaultStyleFunction = this.setDrawersStyles;
		
		//grouped list (see also: item renderers)
		this.getStyleProviderForClass(GroupedList).defaultStyleFunction = this.setGroupedListStyles;
		this.getStyleProviderForClass(GroupedList).setFunctionForStyleName(GroupedList.ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST, this.setInsetGroupedListStyles);
		
		//header
		this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;
		
		//item renderers for lists
		this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);
		
		//header and footer renderers for grouped list
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).defaultStyleFunction = this.setGroupedListHeaderOrFooterRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER, this.setInsetGroupedListHeaderOrFooterRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER, this.setInsetGroupedListHeaderOrFooterRendererStyles);
		
		//label
		this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_HEADING, this.setHeadingLabelStyles);
		//no detail label because the font size would be too small
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_TOOL_TIP, this.setToolTipLabelStyles);
		
		//layout group
		this.getStyleProviderForClass(LayoutGroup).setFunctionForStyleName(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarLayoutGroupStyles);
		
		//list (see also: item renderers)
		this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
		
		//numeric stepper
		this.getStyleProviderForClass(NumericStepper).defaultStyleFunction = this.setNumericStepperStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT, this.setNumericStepperTextInputStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON, this.setNumericStepperButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON, this.setNumericStepperButtonStyles);
		this.getStyleProviderForClass(BitmapFontTextEditor).setFunctionForStyleName(THEME_STYLE_NAME_NUMERIC_STEPPER_TEXT_INPUT_TEXT_EDITOR, this.setNumericStepperTextInputTextEditorStyles);
		
		//page indicator
		this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;
		
		//panel
		this.getStyleProviderForClass(Panel).defaultStyleFunction = this.setPanelStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Panel.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPanelHeaderStyles);
		
		//panel screen
		this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
		
		//picker list (see also: item renderers)
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
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ScrollBar.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setScrollBarThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ScrollBar.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setScrollBarMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON, this.setHorizontalScrollBarDecrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON, this.setHorizontalScrollBarIncrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON, this.setVerticalScrollBarDecrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON, this.setVerticalScrollBarIncrementButtonStyles);
		
		//scroll container
		this.getStyleProviderForClass(ScrollContainer).defaultStyleFunction = this.setScrollContainerStyles;
		this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(ScrollContainer.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarScrollContainerStyles);
		
		//scroll screen
		this.getStyleProviderForClass(ScrollScreen).defaultStyleFunction = this.setScrollScreenStyles;
		
		//scroll text
		this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;
		
		//simple scroll bar
		this.getStyleProviderForClass(Button).setFunctionForStyleName(SimpleScrollBar.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleScrollBarThumbStyles);
		
		//slider
		this.getStyleProviderForClass(Slider).defaultStyleFunction = this.setSliderStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Slider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSliderThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK, this.setHorizontalSliderMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK, this.setVerticalSliderMinimumTrackStyles);
		
		//spinner list
		this.getStyleProviderForClass(SpinnerList).defaultStyleFunction = this.setSpinnerListStyles;
		
		//tab bar
		this.getStyleProviderForClass(TabBar).defaultStyleFunction = this.setTabBarStyles;
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(TabBar.DEFAULT_CHILD_STYLE_NAME_TAB, this.setTabStyles);
		
		//text input
		this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TextInput.ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT, this.setSearchTextInputStyles);
		this.getStyleProviderForClass(BitmapFontTextEditor).setFunctionForStyleName(TextInput.DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR, this.setTextInputTextEditorStyles);
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
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_TRACK, this.setToggleSwitchOnTrackStyles);
		
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
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSliderThumbStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setHorizontalSliderMinimumTrackStyles);
		
		//volume slider
		//this.getStyleProviderForClass(VolumeSlider).defaultStyleFunction = this.setVolumeSliderStyles;
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setVolumeSliderThumbStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setVolumeSliderMinimumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK, this.setVolumeSliderMaximumTrackStyles);
	}
	
	private function pageIndicatorNormalSymbolFactory():DisplayObject
	{
		return new Image(this.pageIndicatorSymbolTexture);
	}
	
	private function pageIndicatorSelectedSymbolFactory():DisplayObject
	{
		return new Image(this.pageIndicatorSelectedSymbolTexture);
	}
	
	private function dataGridHeaderDividerFactory():DisplayObject
	{
		var skin:ImageSkin = new ImageSkin(this.dataGridHeaderDividerSkinTexture);
		skin.scale9Grid = DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID;
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
		scroller.interactionMode = ScrollInteractionMode.MOUSE;
		scroller.scrollBarDisplayMode = ScrollBarDisplayMode.FIXED;
		scroller.horizontalScrollBarFactory = scrollBarFactory;
		scroller.verticalScrollBarFactory = scrollBarFactory;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
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
		
		var backgroundSkin:Image = new Image(this.popUpBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		alert.backgroundSkin = backgroundSkin;
		
		alert.fontStyles = this.primaryFontStyles.clone();
		alert.disabledFontStyles = this.disabledFontStyles.clone();
		
		alert.paddingTop = this.gutterSize;
		alert.paddingRight = this.gutterSize;
		alert.paddingBottom = this.smallGutterSize;
		alert.paddingLeft = this.gutterSize;
		alert.outerPadding = this.borderSize;
		alert.outerPaddingBottom = this.borderSize + this.dropShadowSize;
		alert.outerPaddingRight = this.borderSize + this.dropShadowSize;
		alert.gap = this.smallGutterSize;
		alert.maxWidth = this.popUpSize;
		alert.maxHeight = this.popUpSize;
	}
	
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
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
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
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			skin.selectedTexture = this.buttonSelectedSkinTexture;
			skin.setTextureForState(ButtonState.DOWN_AND_SELECTED,  this.buttonDownSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED,  this.buttonSelectedDisabledSkinTexture);
		}
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}

	private function setCallToActionButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonCallToActionUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.buttonMinWidth;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}

	private function setQuietButtonStyles(button:Button):Void
	{
		var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		defaultSkin.alpha = 0;
		button.defaultSkin = defaultSkin;
		
		var otherSkin:ImageSkin = new ImageSkin(null);
		otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			otherSkin.selectedTexture = this.buttonSelectedSkinTexture;
			otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED,  this.buttonDownSkinTexture);
			otherSkin.setTextureForState(ButtonState.DISABLED_AND_SELECTED,  this.buttonSelectedDisabledSkinTexture);
			cast(button, ToggleButton).defaultSelectedSkin = otherSkin;
			button.setSkinForState(ButtonState.DOWN_AND_SELECTED, otherSkin);
			button.setSkinForState(ButtonState.DISABLED_AND_SELECTED, otherSkin);
		}
		button.setSkinForState(ButtonState.DOWN, otherSkin);
		otherSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		otherSkin.width = this.controlSize;
		otherSkin.height = this.controlSize;
		otherSkin.minWidth = this.controlSize;
		otherSkin.minHeight = this.controlSize;
		
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setDangerButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonDangerUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDangerDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.buttonMinWidth;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.dangerFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setBackButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonBackUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonBackDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonBackDisabledSkinTexture);
		skin.scale9Grid = BACK_BUTTON_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		skin.textureSmoothing = TextureSmoothing.NONE;
		button.defaultSkin = skin;
		
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
		
		button.paddingLeft = 2 * this.gutterSize;
	}
	
	private function setForwardButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonForwardUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonForwardDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonForwardDisabledSkinTexture);
		skin.scale9Grid = FORWARD_BUTTON_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		skin.textureSmoothing = TextureSmoothing.NONE;
		button.defaultSkin = skin;
		
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
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
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			skin.selectedTexture = this.buttonSelectedSkinTexture;
			skin.setTextureForState(ButtonState.DOWN_AND_SELECTED,  this.buttonDownSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED,  this.buttonSelectedDisabledSkinTexture);
		}
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		button.focusIndicatorSkin = focusIndicatorSkin;
		button.focusPadding = this.focusPaddingSize;
		
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		button.paddingTop = this.smallGutterSize;
		button.paddingBottom = this.smallGutterSize;
		button.paddingLeft = this.gutterSize;
		button.paddingRight = this.gutterSize;
		button.gap = this.smallGutterSize;
		button.minGap = this.smallGutterSize;
	}
	
	//-------------------------
	// Callout
	//-------------------------
	
	private function setCalloutStyles(callout:Callout):Void
	{
		callout.padding = this.gutterSize;
		callout.paddingRight = this.gutterSize + this.dropShadowSize;
		callout.paddingBottom = this.gutterSize + this.dropShadowSize;
		
		var backgroundSkin:Image = new Image(this.popUpBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.calloutBackgroundMinSize;
		backgroundSkin.height = this.calloutBackgroundMinSize;
		callout.backgroundSkin = backgroundSkin;
		
		var topArrowSkin:Image = new Image(this.calloutTopArrowSkinTexture);
		callout.topArrowSkin = topArrowSkin;
		callout.topArrowGap = this.calloutTopLeftArrowOverlapGapSize;
		
		var bottomArrowSkin:Image = new Image(this.calloutBottomArrowSkinTexture);
		callout.bottomArrowSkin = bottomArrowSkin;
		callout.bottomArrowGap = this.calloutBottomRightArrowOverlapGapSize;
		
		var leftArrowSkin:Image = new Image(this.calloutLeftArrowSkinTexture);
		callout.leftArrowSkin = leftArrowSkin;
		callout.leftArrowGap = this.calloutTopLeftArrowOverlapGapSize;
		
		var rightArrowSkin:Image = new Image(this.calloutRightArrowSkinTexture);
		callout.rightArrowSkin = rightArrowSkin;
		callout.rightArrowGap = this.calloutBottomRightArrowOverlapGapSize;
	}
	
	private function setDangerCalloutStyles(callout:Callout):Void
	{
		callout.padding = this.gutterSize;
		callout.paddingRight = this.gutterSize + this.dropShadowSize;
		callout.paddingBottom = this.gutterSize + this.dropShadowSize;
		
		var backgroundSkin:Image = new Image(this.dangerPopUpBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.calloutBackgroundMinSize;
		backgroundSkin.height = this.calloutBackgroundMinSize;
		callout.backgroundSkin = backgroundSkin;
		
		var topArrowSkin:Image = new Image(this.dangerCalloutTopArrowSkinTexture);
		callout.topArrowSkin = topArrowSkin;
		callout.topArrowGap = this.calloutTopLeftArrowOverlapGapSize;
		
		var bottomArrowSkin:Image = new Image(this.dangerCalloutBottomArrowSkinTexture);
		callout.bottomArrowSkin = bottomArrowSkin;
		callout.bottomArrowGap = this.calloutBottomRightArrowOverlapGapSize;
		
		var leftArrowSkin:Image = new Image(this.dangerCalloutLeftArrowSkinTexture);
		callout.leftArrowSkin = leftArrowSkin;
		callout.leftArrowGap = this.calloutTopLeftArrowOverlapGapSize;
		
		var rightArrowSkin:Image = new Image(this.dangerCalloutRightArrowSkinTexture);
		callout.rightArrowSkin = rightArrowSkin;
		callout.rightArrowGap = this.calloutBottomRightArrowOverlapGapSize;
	}
	
	//-------------------------
	// Check
	//-------------------------
	
	private function setCheckStyles(check:Check):Void
	{
		var skin:Quad = new Quad(this.controlSize, this.controlSize);
		skin.alpha = 0;
		check.defaultSkin = skin;
		
		var icon:ImageSkin = new ImageSkin(this.checkIconTexture);
		icon.selectedTexture = this.checkSelectedIconTexture;
		icon.setTextureForState(ButtonState.DISABLED, this.checkDisabledIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED,  this.checkSelectedDisabledIconTexture);
		icon.textureSmoothing = TextureSmoothing.NONE;
		check.defaultIcon = icon;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		check.focusIndicatorSkin = focusIndicatorSkin;
		check.focusPaddingLeft = this.focusPaddingSize;
		check.focusPaddingRight = this.focusPaddingSize;
		
		check.fontStyles = this.primaryFontStyles.clone();
		check.disabledFontStyles = this.disabledFontStyles.clone();
		
		check.gap = this.smallGutterSize;
		check.horizontalAlign = HorizontalAlign.LEFT;
		check.verticalAlign = VerticalAlign.MIDDLE;
	}
	
	//-------------------------
	// DataGrid
	//-------------------------
	
	private function setDataGridStyles(grid:DataGrid):Void
	{
		this.setScrollerStyles(grid);
		
		grid.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		grid.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:ImageSkin = new ImageSkin(this.buttonDisabledSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundDisabledSkin.width = this.controlSize;
		backgroundDisabledSkin.height = this.controlSize;
		grid.backgroundDisabledSkin = backgroundDisabledSkin;
		
		var columnDragOverlaySkin:Quad = new Quad(1, 1, DATA_GRID_COLUMN_OVERLAY_COLOR);
		columnDragOverlaySkin.alpha = DATA_GRID_COLUMN_OVERLAY_ALPHA;
		grid.columnDragOverlaySkin = columnDragOverlaySkin;
		
		var columnResizeSkin:ImageSkin = new ImageSkin(this.dataGridColumnResizeSkinTexture);
		columnResizeSkin.scale9Grid = DATA_GRID_COLUMN_RESIZE_SKIN_SCALE_9_GRID;
		grid.columnResizeSkin = columnResizeSkin;
		
		var columnDropIndicatorSkin:ImageSkin = new ImageSkin(this.dataGridColumnDropIndicatorSkinTexture);
		columnDropIndicatorSkin.scale9Grid = DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID;
		grid.columnDropIndicatorSkin = columnDropIndicatorSkin;
		
		grid.headerDividerFactory = this.dataGridHeaderDividerFactory;
		
		grid.padding = this.borderSize;
		grid.paddingRight = 0;
	}
	
	private function setDataGridHeaderRendererStyles(headerRenderer:DefaultDataGridHeaderRenderer):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.dataGridHeaderRendererSkinTexture);
		backgroundSkin.scale9Grid = DATA_GRID_HEADER_RENDERER_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		backgroundSkin.minWidth = this.controlSize;
		backgroundSkin.minHeight = this.controlSize;
		headerRenderer.backgroundSkin = backgroundSkin;
		
		headerRenderer.sortAscendingIcon = new ImageSkin(this.dataGridHeaderSortAscendingIconTexture);
		headerRenderer.sortDescendingIcon = new ImageSkin(this.dataGridHeaderSortDescendingIconTexture);
		
		headerRenderer.fontStyles = this.primaryFontStyles.clone();
		headerRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		
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
		var overlaySkin:Quad = new Quad(10, 10, MODAL_OVERLAY_COLOR);
		overlaySkin.alpha = MODAL_OVERLAY_ALPHA;
		drawers.overlaySkin = overlaySkin;
	}
	
	//-------------------------
	// GroupedList
	//-------------------------
	
	private function setGroupedListStyles(list:GroupedList):Void
	{
		this.setScrollerStyles(list);
		
		list.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:Image = new Image(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		list.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.buttonDisabledSkinTexture);
		backgroundDisabledSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundDisabledSkin.width = this.gridSize;
		backgroundDisabledSkin.height = this.gridSize;
		list.backgroundDisabledSkin = backgroundDisabledSkin;
		
		list.padding = this.borderSize;
	}
	
	//see List section for item renderer styles
	
	private function setGroupedListHeaderOrFooterRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerRendererSkinTexture);
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		backgroundSkin.minWidth = this.controlSize;
		backgroundSkin.minHeight = this.controlSize;
		renderer.backgroundSkin = backgroundSkin;
		
		renderer.fontStyles = this.primaryFontStyles.clone();
		renderer.disabledFontStyles = this.disabledFontStyles.clone();
		
		renderer.paddingTop = this.smallGutterSize;
		renderer.paddingBottom = this.smallGutterSize;
		renderer.paddingLeft = this.gutterSize;
		renderer.paddingRight = this.gutterSize;
	}

	private function setInsetGroupedListStyles(list:GroupedList):Void
	{
		this.setScrollerStyles(list);
		
		var backgroundSkin:Image = new Image(this.listInsetBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		list.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.buttonDisabledSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundDisabledSkin.width = this.gridSize;
		backgroundDisabledSkin.height = this.gridSize;
		list.backgroundDisabledSkin = backgroundDisabledSkin;
		
		list.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		list.customHeaderRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER;
		list.customFooterRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER;
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.useVirtualLayout = true;
		layout.padding = this.gutterSize;
		layout.paddingTop = 0;
		layout.gap = 0;
		layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		layout.verticalAlign = VerticalAlign.TOP;
		list.layout = layout;
	}
	
	private function setInsetGroupedListHeaderOrFooterRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var skin:Quad = new Quad(this.controlSize, this.controlSize);
		skin.alpha = 0;
		renderer.backgroundSkin = skin;
		
		renderer.fontStyles = this.primaryFontStyles.clone();
		renderer.disabledFontStyles = this.disabledFontStyles.clone();
		
		renderer.paddingTop = this.smallGutterSize;
		renderer.paddingBottom = this.smallGutterSize;
		renderer.paddingLeft = this.gutterSize;
		renderer.paddingRight = this.gutterSize;
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
		
		header.fontStyles = this.primaryFontStyles.clone();
		header.disabledFontStyles = this.disabledFontStyles.clone();
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		header.backgroundSkin = backgroundSkin;
	}
	
	//-------------------------
	// Label
	//-------------------------
	
	private function setLabelStyles(label:Label):Void
	{
		label.fontStyles = this.primaryFontStyles.clone();
		label.disabledFontStyles = this.disabledFontStyles.clone();
	}
	
	private function setHeadingLabelStyles(label:Label):Void
	{
		label.fontStyles = this.headingFontStyles.clone();
		label.disabledFontStyles = this.headingDisabledFontStyles.clone();
	}
	
	private function setToolTipLabelStyles(label:Label):Void
	{
		var backgroundSkin:Image = new Image(this.popUpBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		label.backgroundSkin = backgroundSkin;
		
		label.fontStyles = this.primaryFontStyles.clone();
		label.disabledFontStyles = this.disabledFontStyles.clone();
		
		label.padding = this.smallGutterSize;
		label.paddingBottom = this.smallGutterSize + this.dropShadowSize;
		label.paddingRight = this.smallGutterSize + this.dropShadowSize;
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
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
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
		
		list.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:Image = new Image(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		list.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.buttonDisabledSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundDisabledSkin.width = this.controlSize;
		backgroundDisabledSkin.height = this.controlSize;
		list.backgroundDisabledSkin = backgroundDisabledSkin;
		
		var dropIndicatorSkin:Quad = new Quad(this.borderSize, this.borderSize, PRIMARY_TEXT_COLOR);
		list.dropIndicatorSkin = dropIndicatorSkin;
		
		list.padding = this.borderSize;
		list.paddingRight = 0;
	}
	
	private function setItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.itemRendererHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.primaryFontStyles.clone();
		itemRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.iconLabelFontStyles = this.primaryFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.accessoryLabelFontStyles = this.primaryFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
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
		var defaultAccessory:ImageLoader = new ImageLoader();
		defaultAccessory.source = this.listDrillDownAccessoryTexture;
		itemRenderer.defaultAccessory = defaultAccessory;
	}
	
	private function setCheckItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.itemRendererHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.itemHasIcon = false;
		
		var icon:ImageSkin = new ImageSkin(this.checkIconTexture);
		icon.selectedTexture = this.checkSelectedIconTexture;
		itemRenderer.defaultIcon = icon;
		
		itemRenderer.fontStyles = this.primaryFontStyles.clone();
		itemRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.iconLabelFontStyles = this.primaryFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.accessoryLabelFontStyles = this.primaryFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
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
		stepper.buttonLayoutMode = StepperButtonLayoutMode.SPLIT_HORIZONTAL;
		stepper.incrementButtonLabel = "+";
		stepper.decrementButtonLabel = "-";
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		stepper.focusIndicatorSkin = focusIndicatorSkin;
		stepper.focusPadding = this.focusPaddingSize;
	}
	
	private function setNumericStepperButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		button.defaultSkin = skin;
		button.keepDownStateOnRollOut = true;
		this.setBaseButtonStyles(button);
	}
	
	private function setNumericStepperTextInputStyles(input:TextInput):Void
	{
		input.gap = this.smallGutterSize;
		input.paddingTop = this.smallGutterSize;
		input.paddingBottom = this.smallGutterSize;
		input.paddingLeft = this.gutterSize;
		input.paddingRight = this.gutterSize;
		
		input.fontStyles = this.centeredFontStyles.clone();
		input.disabledFontStyles = this.centeredDisabledFontStyles.clone();
		
		var skin:ImageSkin = new ImageSkin(this.insetBackgroundSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.insetBackgroundDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.insetBackgroundFocusedSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.gridSize;
		skin.height = this.controlSize;
		skin.minWidth = this.gridSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
	}
	
	private function setNumericStepperTextInputTextEditorStyles(textEditor:BitmapFontTextEditor):Void
	{
		textEditor.cursorSkin = new Quad(1, 1, PRIMARY_TEXT_COLOR);
		textEditor.selectionSkin = new Quad(1, 1, BACKGROUND_COLOR);
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
		
		var backgroundSkin:Image = new Image(this.panelBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		panel.backgroundSkin = backgroundSkin;
		
		panel.padding = this.gutterSize;
	}
	
	private function setPanelHeaderStyles(header:Header):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.panelHeaderSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		header.backgroundSkin = backgroundSkin;
		
		header.fontStyles = this.primaryFontStyles.clone();
		header.disabledFontStyles = this.disabledFontStyles.clone();
		
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
	
	//-------------------------
	// PickerList
	//-------------------------
	
	private function setPickerListStyles(list:PickerList):Void
	{
		list.toggleButtonOnOpenAndClose = true;
		var popUpContentManager:DropDownPopUpContentManager = new DropDownPopUpContentManager();
		popUpContentManager.gap = this.dropDownGapSize;
		list.popUpContentManager = popUpContentManager;
		list.buttonFactory = pickerListButtonFactory;
	}
	
	private function setPickerListButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DOWN_AND_SELECTED,  this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		var icon:ImageSkin = new ImageSkin(this.pickerListButtonIconUpTexture);
		icon.disabledTexture = this.pickerListButtonIconDisabledTexture;
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			icon.selectedTexture = this.pickerListButtonIconSelectedTexture;
		}
		button.defaultIcon = icon;
		
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
		
		button.gap = Math.POSITIVE_INFINITY; //fill as completely as possible
		button.minGap = this.gutterSize;
		button.iconPosition = RelativePosition.RIGHT;
		button.horizontalAlign =  HorizontalAlign.LEFT;
	}
	
	//for the PickerList's pop-up list, see setDropDownListStyles()
	
	//-------------------------
	// ProgressBar
	//-------------------------
	
	private function setProgressBarStyles(progress:ProgressBar):Void
	{
		var backgroundSkin:Image = new Image(this.insetBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
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
		
		var backgroundDisabledSkin:Image = new Image(this.insetBackgroundDisabledSkinTexture);
		backgroundDisabledSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
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
		fillSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
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
		fillDisabledSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
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
		
		var icon:ImageSkin = new ImageSkin(this.radioIconTexture);
		icon.selectedTexture = this.radioSelectedIconTexture;
		icon.setTextureForState(ButtonState.DISABLED, this.radioDisabledIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED,  this.radioSelectedDisabledIconTexture);
		radio.defaultIcon = icon;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		radio.focusIndicatorSkin = focusIndicatorSkin;
		radio.focusPadding = this.focusPaddingSize;
		
		radio.fontStyles = this.primaryFontStyles.clone();
		radio.disabledFontStyles = this.disabledFontStyles.clone();
		
		radio.gap = this.smallGutterSize;
		radio.horizontalAlign = HorizontalAlign.LEFT;
		radio.verticalAlign = VerticalAlign.MIDDLE;
	}
	
	//-------------------------
	// ScrollBar
	//-------------------------
	
	private function setHorizontalScrollBarStyles(scrollBar:ScrollBar):Void
	{
		scrollBar.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		scrollBar.customIncrementButtonStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON;
		scrollBar.customDecrementButtonStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON;
	}
	
	private function setVerticalScrollBarStyles(scrollBar:ScrollBar):Void
	{
		scrollBar.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		scrollBar.customIncrementButtonStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON;
		scrollBar.customDecrementButtonStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON;
	}
	
	private function setScrollBarThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.thumbSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.thumbDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.minWidth = this.smallControlSize;
		skin.minHeight = this.smallControlSize;
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setScrollBarMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.insetBackgroundSkinTexture);
		skin.disabledTexture = this.insetBackgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setBaseScrollBarButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		skin.minWidth = this.smallControlSize;
		skin.minHeight = this.smallControlSize;
		button.defaultSkin = skin;
		
		button.horizontalAlign = HorizontalAlign.CENTER;
		button.verticalAlign = VerticalAlign.MIDDLE;
		button.padding = 0;
		button.gap = 0;
		button.minGap = 0;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarDecrementButtonStyles(button:Button):Void
	{
		this.setBaseScrollBarButtonStyles(button);
		
		var defaultIcon:Image = new Image(this.horizontalScrollBarDecrementButtonIconTexture);
		button.defaultIcon = defaultIcon;
		
		var disabledIcon:Quad = new Quad(this.horizontalScrollBarDecrementButtonIconTexture.frameWidth,
			this.horizontalScrollBarDecrementButtonIconTexture.frameHeight);
		button.disabledIcon = disabledIcon;
	}
	
	private function setHorizontalScrollBarIncrementButtonStyles(button:Button):Void
	{
		this.setBaseScrollBarButtonStyles(button);
		
		var defaultIcon:Image = new Image(this.horizontalScrollBarIncrementButtonIconTexture);
		button.defaultIcon = defaultIcon;
		
		var disabledIcon:Quad = new Quad(this.horizontalScrollBarIncrementButtonIconTexture.frameWidth,
			this.horizontalScrollBarIncrementButtonIconTexture.frameHeight);
		button.disabledIcon = disabledIcon;
	}
	
	private function setVerticalScrollBarDecrementButtonStyles(button:Button):Void
	{
		this.setBaseScrollBarButtonStyles(button);
		
		var defaultIcon:Image = new Image(this.verticalScrollBarDecrementButtonIconTexture);
		button.defaultIcon = defaultIcon;
		
		var disabledIcon:Quad = new Quad(this.verticalScrollBarDecrementButtonIconTexture.frameWidth,
			this.verticalScrollBarDecrementButtonIconTexture.frameHeight);
		button.disabledIcon = disabledIcon;
	}
	
	private function setVerticalScrollBarIncrementButtonStyles(button:Button):Void
	{
		this.setBaseScrollBarButtonStyles(button);
		
		var defaultIcon:Image = new Image(this.verticalScrollBarIncrementButtonIconTexture);
		button.defaultIcon = defaultIcon;
		
		var disabledIcon:Quad = new Quad(this.verticalScrollBarIncrementButtonIconTexture.frameWidth,
			this.verticalScrollBarIncrementButtonIconTexture.frameHeight);
		button.disabledIcon = disabledIcon;
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
			layout.verticalAlign = VerticalAlign.MIDDLE;
			container.layout = layout;
		}
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
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
		
		text.fontStyles = this.scrollTextFontStyles.clone();
		text.disabledFontStyles = this.scrollTextDisabledFontStyles.clone();
		
		text.padding = this.gutterSize;
	}
	
	//-------------------------
	// SimpleScrollBar
	//-------------------------
	
	private function setSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var defaultSkin:Image = new Image(this.simpleScrollBarThumbSkinTexture);
		defaultSkin.scale9Grid = SCROLLBAR_THUMB_SCALE_9_GRID;
		defaultSkin.width = this.smallControlSize;
		defaultSkin.height = this.smallControlSize;
		thumb.defaultSkin = defaultSkin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Slider
	//-------------------------
	
	private function setSliderStyles(slider:Slider):Void
	{
		slider.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		if (slider.direction == Direction.VERTICAL)
		{
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK;
		}
		else //horizontal
		{
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK;
		}
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		slider.focusIndicatorSkin = focusIndicatorSkin;
		slider.focusPadding = this.focusPaddingSize;
	}
	
	private function setHorizontalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.insetBackgroundSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.insetBackgroundDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.smallControlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.smallControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.insetBackgroundSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.insetBackgroundDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.wideControlSize;
		skin.minWidth = this.smallControlSize;
		skin.minHeight = this.wideControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setSliderThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.thumbSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.thumbDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.smallControlSize;
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
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
		var skin:ImageSkin = new ImageSkin(this.tabSkinTexture);
		skin.selectedTexture = this.tabSelectedSkinTexture;
		skin.setTextureForState(ButtonState.DISABLED, this.tabDisabledSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED,  this.tabSelectedDisabledSkinTexture);
		skin.scale9Grid = TAB_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		tab.defaultSkin = skin;
		
		tab.fontStyles = this.primaryFontStyles.clone();
		tab.disabledFontStyles = this.disabledFontStyles.clone();
		
		tab.iconPosition = RelativePosition.LEFT;
		
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
		
		textArea.padding = this.borderSize;
		
		var skin:ImageSkin = new ImageSkin(this.insetBackgroundSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.insetBackgroundDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.insetBackgroundFocusedSkinTexture);
		skin.setTextureForState(TextInputState.ERROR, this.insetBackgroundDangerSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.wideControlSize * 2;
		skin.height = this.wideControlSize;
		textArea.backgroundSkin = skin;
		
		textArea.fontStyles = this.scrollTextFontStyles.clone();
		textArea.disabledFontStyles = this.scrollTextDisabledFontStyles.clone();
		
		textArea.promptFontStyles = this.primaryFontStyles.clone();
		textArea.promptDisabledFontStyles = this.disabledFontStyles.clone();
		
		textArea.focusPadding = this.focusPaddingSize;
		
		textArea.innerPaddingTop = this.extraSmallGutterSize;
		textArea.innerPaddingRight = this.smallGutterSize;
		textArea.innerPaddingBottom = this.extraSmallGutterSize;
		textArea.innerPaddingLeft = this.smallGutterSize;
	}
	
	private function setTextAreaErrorCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerTextCalloutStyles(callout);
		callout.horizontalAlign = HorizontalAlign.LEFT;
		callout.verticalAlign = VerticalAlign.TOP;
	}
	
	//-------------------------
	// TextCallout
	//-------------------------
	
	private function setTextCalloutStyles(callout:TextCallout):Void
	{
		this.setCalloutStyles(callout);
		
		callout.fontStyles = this.primaryFontStyles.clone();
		callout.disabledFontStyles = this.disabledFontStyles.clone();
	}
	
	private function setDangerTextCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerCalloutStyles(callout);
		
		callout.fontStyles = this.dangerFontStyles.clone();
		callout.disabledFontStyles = this.disabledFontStyles.clone();
	}
	
	//-------------------------
	// TextInput
	//-------------------------
	
	private function setBaseTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.insetBackgroundSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.insetBackgroundDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.insetBackgroundFocusedSkinTexture);
		skin.setTextureForState(TextInputState.ERROR, this.insetBackgroundDangerSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		input.focusIndicatorSkin = focusIndicatorSkin;
		input.focusPadding = this.focusPaddingSize;
		
		input.fontStyles = this.primaryFontStyles.clone();
		input.disabledFontStyles = this.disabledFontStyles.clone();
		
		input.promptFontStyles = this.primaryFontStyles.clone();
		input.promptDisabledFontStyles = this.disabledFontStyles.clone();
		
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
	
	private function setSearchTextInputStyles(input:TextInput):Void
	{
		this.setBaseTextInputStyles(input);
		
		var icon:ImageSkin = new ImageSkin(this.searchIconTexture);
		icon.disabledTexture = this.searchIconDisabledTexture;
		input.defaultIcon = icon;
	}
	
	private function setTextInputTextEditorStyles(textEditor:BitmapFontTextEditor):Void
	{
		textEditor.cursorSkin = new Quad(1, 1, PRIMARY_TEXT_COLOR);
		textEditor.selectionSkin = new Quad(1, 1, BACKGROUND_COLOR);
	}
	
	private function setTextInputErrorCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerTextCalloutStyles(callout);
		callout.horizontalAlign = HorizontalAlign.LEFT;
		callout.verticalAlign = VerticalAlign.TOP;
	}
	
	//-------------------------
	// Toast
	//-------------------------
	
	private function setToastStyles(toast:Toast):Void
	{
		var backgroundSkin:Quad = new Quad(1, 1, MODAL_OVERLAY_COLOR);
		toast.backgroundSkin = backgroundSkin;
		
		toast.fontStyles = this.primaryFontStyles.clone();
		toast.disabledFontStyles = this.disabledFontStyles.clone();
		
		toast.width = this.extraWideControlSize;
		toast.paddingTop = this.smallGutterSize;
		toast.paddingRight = this.gutterSize;
		toast.paddingBottom = this.smallGutterSize;
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
		button.fontStyles = this.primaryFontStyles.clone();
		button.disabledFontStyles = this.primaryFontStyles.clone();
	}
	
	//-------------------------
	// ToggleSwitch
	//-------------------------
	
	private function setToggleSwitchStyles(toggleSwitch:ToggleSwitch):Void
	{
		toggleSwitch.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		toggleSwitch.focusIndicatorSkin = focusIndicatorSkin;
		toggleSwitch.focusPadding = this.focusPaddingSize;
		
		toggleSwitch.offLabelFontStyles = this.primaryFontStyles.clone();
		toggleSwitch.offLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
		toggleSwitch.onLabelFontStyles = this.primaryFontStyles.clone();
		toggleSwitch.onLabelDisabledFontStyles = this.disabledFontStyles.clone();
	}
	
	private function setToggleSwitchOnTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.insetBackgroundSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.insetBackgroundDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = Math.round(this.controlSize * 2.5);
		skin.height = this.controlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}

	private function setToggleSwitchThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.thumbSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.thumbDisabledSkinTexture);
		skin.scale9Grid = DEFAULT_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Tree
	//-------------------------
	
	private function setTreeStyles(tree:Tree):Void
	{
		this.setScrollerStyles(tree);
		
		tree.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:Image = new Image(this.listBackgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		tree.backgroundSkin = backgroundSkin;
		
		var backgroundDisabledSkin:Image = new Image(this.buttonDisabledSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		backgroundDisabledSkin.width = this.controlSize;
		backgroundDisabledSkin.height = this.controlSize;
		tree.backgroundDisabledSkin = backgroundDisabledSkin;
		
		tree.padding = this.borderSize;
		tree.paddingRight = 0;
	}
	
	private function setTreeItemRendererStyles(itemRenderer:DefaultTreeItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.indentation = this.treeDisclosureOpenIconTexture.width;
		itemRenderer.disclosureGap = this.gutterSize;
		
		var disclosureOpenIcon:ImageSkin = new ImageSkin(this.treeDisclosureOpenIconTexture);
		disclosureOpenIcon.textureSmoothing = TextureSmoothing.NONE;
		disclosureOpenIcon.pixelSnapping = true;
		itemRenderer.disclosureOpenIcon = disclosureOpenIcon;
		
		var disclosureClosedIcon:ImageSkin = new ImageSkin(this.treeDisclosureClosedIconTexture);
		disclosureClosedIcon.textureSmoothing = TextureSmoothing.NONE;
		disclosureClosedIcon.pixelSnapping = true;
		itemRenderer.disclosureClosedIcon = disclosureClosedIcon;
	}
	
	//-------------------------
	// VideoPlayer
	//-------------------------
	
	//protected function setVideoPlayerStyles(player:VideoPlayer):void
	//{
		//player.backgroundSkin = new Quad(1, 1, 0x000000);
	//}
	
	//-------------------------
	// PlayPauseToggleButton
	//-------------------------
	
	//protected function setPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):void
	//{
		//var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		//defaultSkin.alpha = 0;
		//button.defaultSkin = defaultSkin;
		//
		//var otherSkin:ImageSkin = new ImageSkin(null);
		//otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.buttonDownSkinTexture);
		//otherSkin.width = this.controlSize;
		//otherSkin.height = this.controlSize;
		//otherSkin.minWidth = this.controlSize;
		//otherSkin.minHeight = this.controlSize;
		//button.setSkinForState(ButtonState.DOWN, otherSkin);
		//button.setSkinForState(ButtonState.DOWN_AND_SELECTED, otherSkin);
		//
		//var icon:ImageSkin = new ImageSkin(this.playPauseButtonPlayUpIconTexture);
		//icon.selectedTexture = this.playPauseButtonPauseUpIconTexture;
		//icon.textureSmoothing = TextureSmoothing.NONE;
		//button.defaultIcon = icon;
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		//button.focusIndicatorSkin = focusIndicatorSkin;
		//button.focusPadding = this.focusPaddingSize;
		//
		//button.hasLabelTextRenderer = false;
		//
		//button.padding = this.smallGutterSize;
		//button.gap = this.smallGutterSize;
		//button.minGap = this.smallGutterSize;
	//}
	//
	//protected function setOverlayPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):void
	//{
		//var icon:ImageSkin = new ImageSkin(null);
		//icon.setTextureForState(ButtonState.UP, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.HOVER, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.DOWN, this.overlayPlayPauseButtonPlayDownIconTexture);
		//button.defaultIcon = icon;
		//
		//button.hasLabelTextRenderer = false;
		//
		//var skin:Quad = new Quad(this.overlayPlayPauseButtonPlayUpIconTexture.width,
			//this.overlayPlayPauseButtonPlayUpIconTexture.height);
		//skin.alpha = 0;
		//button.defaultSkin = skin;
		//
		//var overlaySkin:Quad = new Quad(1, 1, VIDEO_OVERLAY_COLOR);
		//overlaySkin.alpha = VIDEO_OVERLAY_ALPHA;
		//button.upSkin = overlaySkin;
		//button.hoverSkin = overlaySkin;
	//}
	
	//-------------------------
	// FullScreenToggleButton
	//-------------------------
	
	//protected function setFullScreenToggleButtonStyles(button:FullScreenToggleButton):void
	//{
		//var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		//defaultSkin.alpha = 0;
		//button.defaultSkin = defaultSkin;
		//
		//var otherSkin:ImageSkin = new ImageSkin(null);
		//otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.buttonDownSkinTexture);
		//otherSkin.width = this.controlSize;
		//otherSkin.height = this.controlSize;
		//otherSkin.minWidth = this.controlSize;
		//otherSkin.minHeight = this.controlSize;
		//button.setSkinForState(ButtonState.DOWN, otherSkin);
		//button.setSkinForState(ButtonState.DOWN_AND_SELECTED, otherSkin);
		//
		//var icon:ImageSkin = new ImageSkin(this.fullScreenToggleButtonEnterUpIconTexture);
		//icon.selectedTexture = this.fullScreenToggleButtonExitUpIconTexture;
		//button.defaultIcon = icon;
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		//button.focusIndicatorSkin = focusIndicatorSkin;
		//button.focusPadding = this.focusPaddingSize;
		//
		//button.hasLabelTextRenderer = false;
		//
		//button.padding = this.smallGutterSize;
		//button.gap = this.smallGutterSize;
		//button.minGap = this.smallGutterSize;
	//}
	
	//-------------------------
	// MuteToggleButton
	//-------------------------
	
	//protected function setMuteToggleButtonStyles(button:MuteToggleButton):void
	//{
		//var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		//defaultSkin.alpha = 0;
		//button.defaultSkin = defaultSkin;
		//
		//var otherSkin:ImageSkin = new ImageSkin(null);
		//otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.buttonDownSkinTexture);
		//otherSkin.width = this.controlSize;
		//otherSkin.height = this.controlSize;
		//otherSkin.minWidth = this.controlSize;
		//otherSkin.minHeight = this.controlSize;
		//button.setSkinForState(ButtonState.DOWN, otherSkin);
		//button.setSkinForState(ButtonState.DOWN_AND_SELECTED, otherSkin);
		//
		//var icon:ImageSkin = new ImageSkin(this.muteToggleButtonLoudUpIconTexture);
		//icon.selectedTexture = this.muteToggleButtonMutedUpIconTexture;
		//icon.textureSmoothing = TextureSmoothing.NONE;
		//button.defaultIcon = icon;
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		//button.focusIndicatorSkin = focusIndicatorSkin;
		//button.focusPadding = this.focusPaddingSize;
		//
		//button.hasLabelTextRenderer = false;
		//button.showVolumeSliderOnHover = true;
		//
		//button.padding = this.smallGutterSize;
		//button.gap = this.smallGutterSize;
		//button.minGap = this.smallGutterSize;
	//}
	//
	//protected function setPopUpVolumeSliderStyles(slider:VolumeSlider):void
	//{
		//slider.direction = Direction.VERTICAL;
		//slider.trackLayoutMode = TrackLayoutMode.SINGLE;
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		//slider.focusIndicatorSkin = focusIndicatorSkin;
		//slider.focusPadding = this.focusPaddingSize;
		//slider.maximumPadding = this.popUpVolumeSliderPaddingTopLeft;
		//slider.minimumPadding = this.popUpVolumeSliderPaddingBottomRight;
		//slider.thumbOffset = -Math.round(this.dropShadowSize / 2);
		//slider.customThumbStyleName = THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_THUMB;
		//slider.customMinimumTrackStyleName = THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK;
		//slider.width = this.smallControlSize + this.popUpVolumeSliderPaddingTopLeft + this.popUpVolumeSliderPaddingBottomRight;
		//slider.height = this.wideControlSize + this.popUpVolumeSliderPaddingTopLeft + this.popUpVolumeSliderPaddingBottomRight;
	//}
	//
	//protected function setPopUpVolumeSliderTrackStyles(track:Button):void
	//{
		//var skin:Image = new Image(this.popUpVolumeSliderTrackSkinTexture);
		//skin.scale9Grid = VOLUME_SLIDER_TRACK_SCALE9_GRID;
		//track.defaultSkin = skin;
		//
		//track.hasLabelTextRenderer = false;
	//}
	
	//-------------------------
	// SeekSlider
	//-------------------------
	
	//protected function setSeekSliderStyles(slider:SeekSlider):void
	//{
		//this.setSliderStyles(slider);
		//
		//var progressSkin:Image = new Image(this.seekSliderProgressSkinTexture);
		//progressSkin.scale9Grid = SEEK_SLIDER_PROGRESS_SKIN_SCALE9_GRID;
		//slider.progressSkin = progressSkin;
	//}

	//-------------------------
	// VolumeSlider
	//-------------------------
	
	//protected function setVolumeSliderStyles(slider:VolumeSlider):void
	//{
		//slider.direction = Direction.HORIZONTAL;
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = DEFAULT_SCALE_9_GRID;
		//slider.focusIndicatorSkin = focusIndicatorSkin;
		//slider.focusPadding = this.focusPaddingSize;
		//slider.showThumb = false;
	//}
	//
	//protected function setVolumeSliderThumbStyles(thumb:Button):void
	//{
		//var thumbSize:Number = 6;
		//var defaultSkin:Quad = new Quad(thumbSize, thumbSize);
		//defaultSkin.width = 0;
		//defaultSkin.height = 0;
		//thumb.defaultSkin = defaultSkin;
		//thumb.hasLabelTextRenderer = false;
	//}
	//
	//protected function setVolumeSliderMinimumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.source = this.volumeSliderMinimumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//
		//track.hasLabelTextRenderer = false;
	//}
	//
	//protected function setVolumeSliderMaximumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.horizontalAlign = HorizontalAlign.RIGHT;
		//defaultSkin.source = this.volumeSliderMaximumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//
		//track.hasLabelTextRenderer = false;
	//}
}