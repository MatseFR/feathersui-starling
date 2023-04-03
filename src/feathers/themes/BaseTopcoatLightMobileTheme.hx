/*
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved., Marcel Piestansky

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
import feathers.controls.ImageLoader;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.NumericStepper;
import feathers.controls.PageIndicator;
import feathers.controls.Panel;
import feathers.controls.PanelScreen;
import feathers.controls.PickerList;
import feathers.controls.ProgressBar;
import feathers.controls.Radio;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
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
import feathers.controls.popups.BottomDrawerPopUpContentManager;
import feathers.controls.popups.CalloutPopUpContentManager;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.controls.renderers.DefaultDataGridCellRenderer;
import feathers.controls.renderers.DefaultDataGridHeaderRenderer;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.DefaultTreeItemRenderer;
import feathers.controls.text.ITextEditorViewPort;
import feathers.controls.text.TextFieldTextEditor;
import feathers.controls.text.TextFieldTextEditorViewPort;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.FeathersControl;
import feathers.core.ITextEditor;
import feathers.core.ITextRenderer;
import feathers.core.PopUpManager;
import feathers.layout.Direction;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.ImageSkin;
import feathers.system.DeviceCapabilities;
import openfl.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class BaseTopcoatLightMobileTheme extends StyleNameFunctionTheme 
{
	public static inline var SOURCE_SANS_PRO_REGULAR:String = "assets/fonts/SourceSansPro-Regular.ttf";
	
	public static inline var SOURCE_SANS_PRO_SEMIBOLD:String = "assets/fonts/SourceSansPro-Semibold.ttf";
	
	/**
	 * The name of the embedded font used by controls in this theme. Comes
	 * in normal and bold weights.
	 */
	public static inline var FONT_NAME:String = "Source Sans Pro";
	
	private static inline var COLOR_TEXT_DARK:Int = 0x454545;
	private static inline var COLOR_TEXT_LIGHT:Int = 0xFFFFFF;
	private static inline var COLOR_TEXT_SELECTED:Int = 0x0083E8;
	private static inline var COLOR_TEXT_DARK_DISABLED:Int = 0x848585;
	private static inline var COLOR_TEXT_SELECTED_DISABLED:Int = 0x96AFC3;
	private static inline var COLOR_TEXT_ACTION_DISABLED:Int = 0xC6DFF3;
	private static inline var COLOR_TEXT_DANGER_DISABLED:Int = 0xF7B4AF;
	private static inline var COLOR_BACKGROUND_LIGHT:Int = 0xDFE2E2;
	private static inline var COLOR_SPINNER_LIST_BACKGROUND:Int = 0xE5E9E8;
	private static inline var COLOR_MODAL_OVERLAY:Int = 0xDFE2E2;
	private static inline var ALPHA_MODAL_OVERLAY:Float = 0.8;
	private static inline var COLOR_DRAWER_OVERLAY:Int = 0x454545;
	private static inline var ALPHA_DRAWER_OVERLAY:Float = 0.8;
	private static inline var COLOR_DRAWERS_DIVIDER:Int = 0x9DACA9;
	private static inline var ALPHA_DATA_GRID_DRAG_OVERLAY:Float = 0.5;
	private static inline var COLOR_DATA_GRID_DRAG_OVERLAY:Int = 0xDFE2E2;
	private static inline var COLOR_TOAST_BACKGROUND:Int = 0x454545;

	private static var BUTTON_SCALE9_GRID:Rectangle = new Rectangle(7, 7, 1, 1);
	private static var BACK_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(26, 5, 10, 40);
	private static var FORWARD_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 10, 10);
	private static var TEXT_INPUT_SCALE9_GRID:Rectangle = new Rectangle(7, 7, 1, 1);
	private static var HORIZONTAL_MINIMUM_TRACK_SCALE9_GRID:Rectangle = new Rectangle(5, 0, 1, 13);
	private static var HORIZONTAL_MAXIMUM_TRACK_SCALE9_GRID:Rectangle = new Rectangle(0, 0, 1, 13);
	private static var VERTICAL_MINIMUM_TRACK_SCALE9_GRID:Rectangle = new Rectangle(0, 0, 13, 1);
	private static var VERTICAL_MAXIMUM_TRACK_SCALE9_GRID:Rectangle = new Rectangle(0, 5, 13, 1);
	private static var BAR_HORIZONTAL_SCALE9_GRID:Rectangle = new Rectangle(8, 8, 1, 1);
	private static var BAR_VERTICAL_SCALE9_GRID:Rectangle = new Rectangle(8, 8, 1, 1);
	private static var HEADER_BACKGROUND_SCALE9_GRID:Rectangle = new Rectangle(3, 3, 10, 56);
	private static var TAB_SCALE9_GRID:Rectangle = new Rectangle(3, 3, 5, 5);
	private static var SEARCH_INPUT_SCALE9_GRID:Rectangle = new Rectangle(25, 25, 10, 1);
	private static var BACKGROUND_POPUP_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 10, 10);
	private static var POP_UP_DRAWER_BACKGROUND_SCALE9_GRID:Rectangle = new Rectangle(1, 3, 3, 4);
	private static var LIST_ITEM_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 1, 6);
	private static var GROUPED_LIST_HEADER_OR_FOOTER_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 1, 6);
	private static var SPINNER_LIST_OVERLAY_SCALE9_GRID:Rectangle = new Rectangle(2, 5, 1, 1);
	private static var HORIZONTAL_SIMPLE_SCROLL_BAR_SCALE9_GRID:Rectangle = new Rectangle(5, 0, 3, 6);
	private static var VERTICAL_SIMPLE_SCROLL_BAR_SCALE9_GRID:Rectangle = new Rectangle(0, 5, 6, 3);
	private static var DATA_GRID_HEADER_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 1, 6);
	private static var DATA_GRID_COLUMN_RESIZE_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 3, 1);
	private static var DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 3, 1);
	private static var DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 2, 5, 1);

	private static inline var THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB:String = "topcoat-light-mobile-vertical-simple-scroll-bar-thumb";
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB:String = "topcoat-light-mobile-horizontal-simple-scroll-bar-thumb";
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_THUMB:String = "topcoat-light-mobile-horizontal-slider-thumb";
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK:String = "topcoat-light-mobile-horizontal-slider-minimum-track";
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK:String = "topcoat-light-mobile-horizontal-slider-maximum-track";
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_THUMB:String = "topcoat-light-mobile-vertical-slider-thumb";
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK:String = "topcoat-light-mobile-vertical-slider-minimum-track";
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK:String = "topcoat-light-mobile-vertical-slider-maximum-track";
	private static inline var THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON:String = "topcoat-light-mobile-alert-button-group-button";
	private static inline var THEME_STYLE_NAME_ALERT_BUTTON_GROUP_LAST_BUTTON:String = "topcoat-light-mobile-alert-button-group-last-button";
	private static inline var THEME_STYLE_NAME_GROUPED_LIST_FIRST_ITEM_RENDERER:String = "topcoat-light-mobile-grouped-list-first-item-renderer";
	private static inline var THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER:String = "topcoat-light-mobile-spinner-list-item-renderer";
	private static inline var THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER:String = "topcoat-light-mobile-date-time-spinner-list-item-renderer";
	private static inline var THEME_STYLE_NAME_POP_UP_DRAWER:String = "topcoat-light-mobile-pop-up-drawer";
	private static inline var THEME_STYLE_NAME_POP_UP_DRAWER_HEADER:String = "topcoat-light-mobile-pop-up-drawer-header";
	private static inline var THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER:String = "topcoat-light-mobile-tablet-picker-list-item-renderer";
	private static inline var THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON:String = "topcoat-light-mobile-toast-actions-button";
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	private var gridSize:Int = 70;
	private var gutterSize:Int = 20;
	private var smallGutterSize:Int = 10;
	private var extraSmallGutterSize:Int = 5;
	private var borderSize:Int = 1;
	private var controlSize:Int = 50;
	private var smallControlSize:Int = 16;
	private var wideControlSize:Int = 230;
	private var popUpFillSize:Int = 300;
	private var thumbSize:Int = 34;
	private var shadowSize:Int = 2;
	private var calloutBackgroundMinSize:Int = 53;
	private var calloutVerticalArrowGap:Int = -8;
	private var calloutHorizontalArrowGap:Int = -7;

	private var smallFontSize:Int = 14;
	private var regularFontSize:Int = 16;
	private var largeFontSize:Int = 20;

	private var darkFontStyles:TextFormat;
	private var lightFontStyles:TextFormat;
	private var selectedFontStyles:TextFormat;
	private var darkDisabledFontStyles:TextFormat;
	private var selectedDisabledFontStyles:TextFormat;
	private var actionDisabledFontStyles:TextFormat;
	private var dangerDisabledFontStyles:TextFormat;
	private var darkCenteredFontStyles:TextFormat;
	private var darkCenteredDisabledFontStyles:TextFormat;
	private var smallDarkFontStyles:TextFormat;
	private var smallSelectedFontStyles:TextFormat;
	private var smallDarkDisabledFontStyles:TextFormat;
	private var largeDarkFontStyles:TextFormat;
	private var largeDarkDisabledFontStyles:TextFormat;
	private var darkScrollTextFontStyles:TextFormat;
	private var darkScrollTextDisabledFontStyles:TextFormat;
	private var lightBoldFontStyles:TextFormat;
	private var selectedBoldFontStyles:TextFormat;
	
	/**
	 * The texture atlas that contains skins for this theme. This base class
	 * does not initialize this member variable. Subclasses are expected to
	 * load the assets somehow and set the <code>atlas</code> member
	 * variable before calling <code>initialize()</code>.
	 */
	private var atlas:TextureAtlas;

	private var focusIndicatorTexture:Texture;
	private var buttonUpTexture:Texture;
	private var buttonDownTexture:Texture;
	private var buttonDisabledTexture:Texture;
	private var quietButtonDownTexture:Texture;
	private var backButtonUpTexture:Texture;
	private var backButtonDownTexture:Texture;
	private var backButtonDisabledTexture:Texture;
	private var forwardButtonUpTexture:Texture;
	private var forwardButtonDownTexture:Texture;
	private var forwardButtonDisabledTexture:Texture;
	private var dangerButtonUpTexture:Texture;
	private var dangerButtonDownTexture:Texture;
	private var dangerButtonDisabledTexture:Texture;
	private var callToActionButtonUpTexture:Texture;
	private var callToActionButtonDownTexture:Texture;
	private var callToActionButtonDisabledTexture:Texture;
	private var toggleButtonSelectedUpTexture:Texture;
	private var toggleButtonSelectedDisabledTexture:Texture;
	private var toggleSwitchOnTrackTexture:Texture;
	private var toggleSwitchOnTrackDisabledTexture:Texture;
	private var toggleSwitchOffTrackTexture:Texture;
	private var toggleSwitchOffTrackDisabledTexture:Texture;
	private var checkUpIconTexture:Texture;
	private var checkSelectedUpIconTexture:Texture;
	private var checkDownIconTexture:Texture;
	private var checkDisabledIconTexture:Texture;
	private var checkSelectedDownIconTexture:Texture;
	private var checkSelectedDisabledIconTexture:Texture;
	private var radioUpIconTexture:Texture;
	private var radioSelectedUpIconTexture:Texture;
	private var radioDownIconTexture:Texture;
	private var radioDisabledIconTexture:Texture;
	private var radioSelectedDownIconTexture:Texture;
	private var radioSelectedDisabledIconTexture:Texture;
	private var horizontalProgressBarFillTexture:Texture;
	private var horizontalProgressBarFillDisabledTexture:Texture;
	private var horizontalProgressBarBackgroundTexture:Texture;
	private var horizontalProgressBarBackgroundDisabledTexture:Texture;
	private var verticalProgressBarFillTexture:Texture;
	private var verticalProgressBarFillDisabledTexture:Texture;
	private var verticalProgressBarBackgroundTexture:Texture;
	private var verticalProgressBarBackgroundDisabledTexture:Texture;
	private var headerBackgroundSkinTexture:Texture;
	private var verticalSimpleScrollBarThumbTexture:Texture;
	private var horizontalSimpleScrollBarThumbTexture:Texture;
	private var tabUpTexture:Texture;
	private var tabDownTexture:Texture;
	private var tabSelectedUpTexture:Texture;
	private var tabSelectedDisabledTexture:Texture;
	private var horizontalSliderMinimumTrackTexture:Texture;
	private var horizontalSliderMinimumTrackDisabledTexture:Texture;
	private var horizontalSliderMaximumTrackTexture:Texture;
	private var horizontalSliderMaximumTrackDisabledTexture:Texture;
	private var verticalSliderMinimumTrackTexture:Texture;
	private var verticalSliderMinimumTrackDisabledTexture:Texture;
	private var verticalSliderMaximumTrackTexture:Texture;
	private var verticalSliderMaximumTrackDisabledTexture:Texture;
	private var textInputBackgroundEnabledTexture:Texture;
	private var textInputBackgroundFocusedTexture:Texture;
	private var textInputBackgroundErrorTexture:Texture;
	private var textInputBackgroundDisabledTexture:Texture;
	private var searchTextInputBackgroundEnabledTexture:Texture;
	private var searchTextInputBackgroundFocusedTexture:Texture;
	private var searchTextInputBackgroundDisabledTexture:Texture;
	private var searchIconTexture:Texture;
	private var popUpBackgroundTexture:Texture;
	private var calloutTopArrowTexture:Texture;
	private var calloutRightArrowTexture:Texture;
	private var calloutBottomArrowTexture:Texture;
	private var calloutLeftArrowTexture:Texture;
	private var itemRendererUpTexture:Texture;
	private var itemRendererDownTexture:Texture;
	private var itemRendererSelectedTexture:Texture;
	private var firstItemRendererUpTexture:Texture;
	private var groupedListHeaderTexture:Texture;
	private var groupedListFooterTexture:Texture;
	private var pickerListButtonIcon:Texture;
	private var pickerListButtonDisabledIcon:Texture;
	private var popUpDrawerBackgroundTexture:Texture;
	private var spinnerListSelectionOverlayTexture:Texture;
	private var pageIndicatorNormalTexture:Texture;
	private var pageIndicatorSelectedTexture:Texture;
	private var treeDisclosureOpenIconTexture:Texture;
	private var treeDisclosureClosedIconTexture:Texture;
	private var dataGridHeaderTexture:Texture;
	private var dataGridHeaderSortAscendingIconTexture:Texture;
	private var dataGridHeaderSortDescendingIconTexture:Texture;
	private var dataGridColumnResizeSkinTexture:Texture;
	private var dataGridColumnDropIndicatorSkinTexture:Texture;
	private var dataGridHeaderDividerSkinTexture:Texture;
	private var dragHandleIconTexture:Texture;
	
	/**
	 * Disposes the atlas before calling super.dispose()
	 */
	override public function dispose():Void
	{
		if (this.atlas != null)
		{
			this.atlas.dispose();
			this.atlas = null;
		}
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
	
	private function initializeStage():Void
	{
		this.starling.stage.color = COLOR_BACKGROUND_LIGHT;
		this.starling.nativeStage.color = COLOR_BACKGROUND_LIGHT;
	}
	
	private function initializeTextures():Void
	{
		this.popUpBackgroundTexture = this.atlas.getTexture("background-popup-skin0000");
		this.popUpDrawerBackgroundTexture = this.atlas.getTexture("pop-up-drawer-background-skin0000");
		
		this.focusIndicatorTexture = this.atlas.getTexture("focus-indicator-skin0000");
		
		this.buttonUpTexture = this.atlas.getTexture("button-up-skin0000");
		this.buttonDownTexture = this.atlas.getTexture("button-down-skin0000");
		this.buttonDisabledTexture = this.atlas.getTexture("button-disabled-skin0000");
		this.quietButtonDownTexture = this.atlas.getTexture("button-down-skin0000");
		this.dangerButtonUpTexture = this.atlas.getTexture("button-danger-up-skin0000");
		this.dangerButtonDownTexture = this.atlas.getTexture("button-danger-down-skin0000");
		this.dangerButtonDisabledTexture = this.atlas.getTexture("button-danger-disabled-skin0000");
		this.callToActionButtonUpTexture = this.atlas.getTexture("button-call-to-action-up-skin0000");
		this.callToActionButtonDownTexture = this.atlas.getTexture("button-call-to-action-down-skin0000");
		this.callToActionButtonDisabledTexture = this.atlas.getTexture("button-call-to-action-disabled-skin0000");
		this.backButtonUpTexture = this.atlas.getTexture("button-back-up-skin0000");
		this.backButtonDownTexture = this.atlas.getTexture("button-back-down-skin0000");
		this.backButtonDisabledTexture = this.atlas.getTexture("button-back-disabled-skin0000");
		this.forwardButtonUpTexture = this.atlas.getTexture("button-forward-up-skin0000");
		this.forwardButtonDownTexture = this.atlas.getTexture("button-forward-down-skin0000");
		this.forwardButtonDisabledTexture = this.atlas.getTexture("button-forward-disabled-skin0000");
		this.toggleButtonSelectedUpTexture = this.atlas.getTexture("toggle-button-selected-up-skin0000");
		this.toggleButtonSelectedDisabledTexture = this.atlas.getTexture("toggle-button-selected-disabled-skin0000");
		
		this.calloutTopArrowTexture = this.atlas.getTexture("callout-arrow-top-skin0000");
		this.calloutRightArrowTexture = this.atlas.getTexture("callout-arrow-right-skin0000");
		this.calloutBottomArrowTexture = this.atlas.getTexture("callout-arrow-bottom-skin0000");
		this.calloutLeftArrowTexture = this.atlas.getTexture("callout-arrow-left-skin0000");
		
		this.checkUpIconTexture = this.atlas.getTexture("check-up-icon0000");
		this.checkDownIconTexture = this.atlas.getTexture("check-down-icon0000");
		this.checkDisabledIconTexture = this.atlas.getTexture("check-disabled-icon0000");
		this.checkSelectedUpIconTexture = this.atlas.getTexture("check-selected-up-icon0000");
		this.checkSelectedDownIconTexture = this.atlas.getTexture("check-selected-down-icon0000");
		this.checkSelectedDisabledIconTexture = this.atlas.getTexture("check-selected-disabled-icon0000");
		
		this.headerBackgroundSkinTexture = this.atlas.getTexture("header-background-skin0000");
		
		this.itemRendererUpTexture = this.atlas.getTexture("list-item-up-skin0000");
		this.itemRendererDownTexture = this.atlas.getTexture("list-item-down-skin0000");
		this.itemRendererSelectedTexture = this.atlas.getTexture("list-item-selected-skin0000");
		this.firstItemRendererUpTexture = this.atlas.getTexture("list-first-item-up-skin0000");
		this.groupedListHeaderTexture = this.atlas.getTexture("grouped-list-header-skin0000");
		this.groupedListFooterTexture = this.atlas.getTexture("grouped-list-footer-skin0000");
		
		this.pageIndicatorNormalTexture = this.atlas.getTexture("page-indicator-normal-skin0000");
		this.pageIndicatorSelectedTexture = this.atlas.getTexture("page-indicator-selected-skin0000");
		
		this.pickerListButtonIcon = this.atlas.getTexture("picker-list-button-icon0000");
		this.pickerListButtonDisabledIcon = this.atlas.getTexture("picker-list-button-disabled-icon0000");
		
		this.horizontalProgressBarFillTexture = this.atlas.getTexture("progress-bar-horizontal-fill-skin0000");
		this.horizontalProgressBarFillDisabledTexture = this.atlas.getTexture("progress-bar-horizontal-fill-disabled-skin0000");
		this.horizontalProgressBarBackgroundTexture = this.atlas.getTexture("progress-bar-horizontal-background-skin0000");
		this.horizontalProgressBarBackgroundDisabledTexture = this.atlas.getTexture("progress-bar-horizontal-background-disabled-skin0000");
		this.verticalProgressBarFillTexture = this.atlas.getTexture("progress-bar-vertical-fill-skin0000");
		this.verticalProgressBarFillDisabledTexture = this.atlas.getTexture("progress-bar-vertical-fill-disabled-skin0000");
		this.verticalProgressBarBackgroundTexture = this.atlas.getTexture("progress-bar-vertical-background-skin0000");
		this.verticalProgressBarBackgroundDisabledTexture = this.atlas.getTexture("progress-bar-vertical-background-disabled-skin0000");
		
		this.radioUpIconTexture = this.atlas.getTexture("radio-up-icon0000");
		this.radioDownIconTexture = this.atlas.getTexture("radio-down-icon0000");
		this.radioDisabledIconTexture = this.atlas.getTexture("radio-disabled-icon0000");
		this.radioSelectedUpIconTexture = this.atlas.getTexture("radio-selected-up-icon0000");
		this.radioSelectedDownIconTexture = this.atlas.getTexture("radio-selected-down-icon0000");
		this.radioSelectedDisabledIconTexture = this.atlas.getTexture("radio-selected-disabled-icon0000");
		
		this.verticalSimpleScrollBarThumbTexture = this.atlas.getTexture("simple-scroll-bar-vertical-thumb-skin0000");
		this.horizontalSimpleScrollBarThumbTexture = this.atlas.getTexture("simple-scroll-bar-horizontal-thumb-skin0000");
		
		this.horizontalSliderMinimumTrackTexture = this.atlas.getTexture("slider-horizontal-minimum-track-skin0000");
		this.horizontalSliderMinimumTrackDisabledTexture = this.atlas.getTexture("slider-horizontal-minimum-track-disabled-skin0000");
		this.horizontalSliderMaximumTrackTexture = this.atlas.getTexture("slider-horizontal-maximum-track-skin0000");
		this.horizontalSliderMaximumTrackDisabledTexture = this.atlas.getTexture("slider-horizontal-maximum-track-disabled-skin0000");
		this.verticalSliderMinimumTrackTexture = this.atlas.getTexture("slider-vertical-minimum-track-skin0000");
		this.verticalSliderMinimumTrackDisabledTexture = this.atlas.getTexture("slider-vertical-minimum-track-disabled-skin0000");
		this.verticalSliderMaximumTrackTexture = this.atlas.getTexture("slider-vertical-maximum-track-skin0000");
		this.verticalSliderMaximumTrackDisabledTexture = this.atlas.getTexture("slider-vertical-maximum-track-disabled-skin0000");
		
		this.spinnerListSelectionOverlayTexture = this.atlas.getTexture("spinner-list-selection-overlay-skin0000");
		
		this.tabUpTexture = this.atlas.getTexture("tab-up-skin0000");
		this.tabDownTexture = this.atlas.getTexture("tab-down-skin0000");
		this.tabSelectedUpTexture = this.atlas.getTexture("tab-selected-up-skin0000");
		this.tabSelectedDisabledTexture = this.atlas.getTexture("tab-selected-disabled-skin0000");
		
		this.textInputBackgroundEnabledTexture = this.atlas.getTexture("text-input-up-skin0000");
		this.textInputBackgroundFocusedTexture = this.atlas.getTexture("text-input-focused-skin0000");
		this.textInputBackgroundErrorTexture = this.atlas.getTexture("text-input-error-skin0000");
		this.textInputBackgroundDisabledTexture = this.atlas.getTexture("text-input-disabled-skin0000");
		this.searchTextInputBackgroundEnabledTexture = this.atlas.getTexture("search-input-up-skin0000");
		this.searchTextInputBackgroundFocusedTexture = this.atlas.getTexture("search-input-focused-skin0000");
		this.searchTextInputBackgroundDisabledTexture = this.atlas.getTexture("search-input-disabled-skin0000");
		this.searchIconTexture = this.atlas.getTexture("search-input-icon0000");
		
		this.toggleSwitchOnTrackTexture = this.atlas.getTexture("toggle-switch-on-track-skin0000");
		this.toggleSwitchOnTrackDisabledTexture = this.atlas.getTexture("toggle-switch-on-track-disabled-skin0000");
		this.toggleSwitchOffTrackTexture = this.atlas.getTexture("toggle-switch-off-track-skin0000");
		this.toggleSwitchOffTrackDisabledTexture = this.atlas.getTexture("toggle-switch-off-track-disabled-skin0000");
		
		this.treeDisclosureOpenIconTexture = this.atlas.getTexture("tree-disclosure-open-icon0000");
		this.treeDisclosureClosedIconTexture = this.atlas.getTexture("tree-disclosure-closed-icon0000");
		
		this.dataGridHeaderTexture = this.atlas.getTexture("data-grid-header-skin0000");
		this.dataGridHeaderSortAscendingIconTexture = this.atlas.getTexture("data-grid-header-sort-ascending-icon0000");
		this.dataGridHeaderSortDescendingIconTexture = this.atlas.getTexture("data-grid-header-sort-descending-icon0000");
		this.dataGridColumnResizeSkinTexture = this.atlas.getTexture("data-grid-column-resize-skin0000");
		this.dataGridColumnDropIndicatorSkinTexture = this.atlas.getTexture("data-grid-column-drop-indicator-skin0000");
		this.dataGridHeaderDividerSkinTexture = this.atlas.getTexture("data-grid-header-divider-skin0000");
		
		this.dragHandleIconTexture = this.atlas.getTexture("drag-handle-icon0000");
	}
	
	private function initializeFonts():Void
	{
		this.darkFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_DARK, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_LIGHT, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.selectedFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_SELECTED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.darkDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_DARK_DISABLED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.selectedDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_SELECTED_DISABLED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.dangerDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_DANGER_DISABLED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.actionDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_ACTION_DISABLED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.darkCenteredFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_DARK, HorizontalAlign.CENTER, VerticalAlign.TOP);
		this.darkCenteredDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_DARK_DISABLED, HorizontalAlign.CENTER, VerticalAlign.TOP);
		this.lightBoldFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_LIGHT, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightBoldFontStyles.bold = true;
		this.selectedBoldFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_SELECTED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.selectedBoldFontStyles.bold = true;
		
		this.smallDarkFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, COLOR_TEXT_DARK, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.smallSelectedFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, COLOR_TEXT_SELECTED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.smallDarkDisabledFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, COLOR_TEXT_DARK_DISABLED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeDarkFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, COLOR_TEXT_DARK, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeDarkDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, COLOR_TEXT_DARK_DISABLED, HorizontalAlign.LEFT, VerticalAlign.TOP);
		
		this.darkScrollTextFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_DARK, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.darkScrollTextDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, COLOR_TEXT_DARK_DISABLED, HorizontalAlign.LEFT, VerticalAlign.TOP);
	}
	
	private function initializeGlobals():Void
	{
		FeathersControl.defaultTextRendererFactory = textRendererFactory;
		FeathersControl.defaultTextEditorFactory = textEditorFactory;
		
		PopUpManager.overlayFactory = popUpOverlayFactory;
		Callout.stagePadding = this.smallGutterSize;
		Toast.containerFactory = toastContainerFactory;
	}
	
	private function initializeStyleProviders():Void
	{
		//alert
		this.getStyleProviderForClass(Alert).defaultStyleFunction = this.setAlertStyles;
		this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_BUTTON_GROUP, this.setAlertButtonGroupStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON, this.setAlertButtonGroupButtonStyles);
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setHeaderWithoutBackgroundStyles);
		
		//auto complete
		this.getStyleProviderForClass(AutoComplete).defaultStyleFunction = this.setTextInputStyles;
		this.getStyleProviderForClass(List).setFunctionForStyleName(AutoComplete.DEFAULT_CHILD_STYLE_NAME_LIST, this.setDropDownListStyles);
		
		//button
		this.getStyleProviderForClass(Button).defaultStyleFunction = this.setButtonStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_DANGER_BUTTON, this.setDangerButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_CALL_TO_ACTION_BUTTON, this.setCallToActionButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON, this.setBackButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_FORWARD_BUTTON, this.setForwardButtonStyles);
		
		//button group
		this.getStyleProviderForClass(ButtonGroup).defaultStyleFunction = this.setButtonGroupStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ButtonGroup.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setButtonGroupButtonStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ButtonGroup.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setButtonStyles);
		
		//callout
		this.getStyleProviderForClass(Callout).defaultStyleFunction = this.setCalloutStyles;
		
		//check
		this.getStyleProviderForClass(Check).defaultStyleFunction = this.setCheckStyles;
		
		//data grid
		this.getStyleProviderForClass(DataGrid).defaultStyleFunction = this.setDataGridStyles;
		this.getStyleProviderForClass(DefaultDataGridCellRenderer).defaultStyleFunction = this.setItemRendererStyles;
		this.getStyleProviderForClass(DefaultDataGridHeaderRenderer).defaultStyleFunction = this.setDataGridHeaderRendererStyles;
		
		//date time spinner
		this.getStyleProviderForClass(DateTimeSpinner).defaultStyleFunction = this.setDateTimeSpinnerStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER, this.setDateTimeSpinnerListItemRendererStyles);
		
		//drawers
		this.getStyleProviderForClass(Drawers).defaultStyleFunction = this.setDrawersStyles;
		
		//grouped list
		this.getStyleProviderForClass(GroupedList).defaultStyleFunction = this.setGroupedListStyles;
		this.getStyleProviderForClass(GroupedList).setFunctionForStyleName(GroupedList.ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST, this.setInsetGroupedListStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).defaultStyleFunction = this.setGroupedListHeaderRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.DEFAULT_CHILD_STYLE_NAME_FOOTER_RENDERER, this.setGroupedListFooterRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER, this.setGroupedListInsetHeaderRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER, this.setGroupedListInsetFooterRendererStyles);
		//custom style for the first item in GroupedList (without highlight at the top)
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_GROUPED_LIST_FIRST_ITEM_RENDERER, this.setGroupedListFirstItemRendererStyles);
		
		//header
		this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;
		
		//label
		this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_HEADING, this.setHeadingLabelStyles);
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_DETAIL, this.setDetailLabelStyles);
		
		//layout group
		this.getStyleProviderForClass(LayoutGroup).setFunctionForStyleName(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarLayoutGroupStyles);
		
		//list
		this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setListItemRendererStyles;
		
		//numeric stepper
		this.getStyleProviderForClass(NumericStepper).defaultStyleFunction = this.setNumericStepperStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT, this.setNumericStepperTextInputStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON, this.setNumericStepperButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON, this.setNumericStepperButtonStyles);
		
		//page indicator
		this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;
		
		//panel
		this.getStyleProviderForClass(Panel).defaultStyleFunction = this.setPanelStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Panel.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setHeaderWithoutBackgroundStyles);
		
		//panel screen
		this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(PanelScreen.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPanelScreenHeaderStyles);
		
		//picker list
		this.getStyleProviderForClass(PickerList).defaultStyleFunction = this.setPickerListStyles;
		this.getStyleProviderForClass(List).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_LIST, this.setPickerListListStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
		this.getStyleProviderForClass(Panel).setFunctionForStyleName(THEME_STYLE_NAME_POP_UP_DRAWER, this.setPickerListPopUpDrawerStyles);
		this.getStyleProviderForClass(Header).setFunctionForStyleName(THEME_STYLE_NAME_POP_UP_DRAWER_HEADER, this.setHeaderStyles);
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER, this.setTabletPickerListItemRendererStyles);
		
		//progress bar
		this.getStyleProviderForClass(ProgressBar).defaultStyleFunction = this.setProgressBarStyles;
		
		//radio
		this.getStyleProviderForClass(Radio).defaultStyleFunction = this.setRadioStyles;
		
		//scroll container
		this.getStyleProviderForClass(ScrollContainer).defaultStyleFunction = this.setScrollContainerStyles;
		this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(ScrollContainer.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarScrollContainerStyles);
		
		//scroll text
		this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;
		
		//simple scroll bar
		this.getStyleProviderForClass(SimpleScrollBar).defaultStyleFunction = this.setSimpleScrollBarStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB, this.setVerticalSimpleScrollBarThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB, this.setHorizontalSimpleScrollBarThumbStyles);
		
		//slider
		this.getStyleProviderForClass(Slider).defaultStyleFunction = this.setSliderStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_THUMB, this.setHorizontalThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_THUMB, this.setVerticalThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK, this.setHorizontalSliderMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK, this.setHorizontalSliderMaximumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK, this.setVerticalSliderMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK, this.setVerticalSliderMaximumTrackStyles);
		
		//spinner list
		this.getStyleProviderForClass(SpinnerList).defaultStyleFunction = this.setSpinnerListStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER, this.setSpinnerListItemRendererStyles);
		
		//tab bar
		this.getStyleProviderForClass(TabBar).defaultStyleFunction = this.setTabBarStyles;
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(TabBar.DEFAULT_CHILD_STYLE_NAME_TAB, this.setTabStyles);
		
		//text input
		this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TextInput.ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT, this.setSearchTextInputStyles);
		
		//text area
		this.getStyleProviderForClass(TextArea).defaultStyleFunction = this.setTextAreaStyles;
		
		//text callout
		this.getStyleProviderForClass(TextCallout).defaultStyleFunction = this.setTextCalloutStyles;
		
		//toast
		this.getStyleProviderForClass(Toast).defaultStyleFunction = this.setToastStyles;
		this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName(Toast.DEFAULT_CHILD_STYLE_NAME_ACTIONS, this.setToastActionsStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON, this.setToastActionsButtonStyles);
		
		//toggle button
		this.getStyleProviderForClass(ToggleButton).defaultStyleFunction = this.setToggleButtonStyles;
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);
		
		//toggle switch
		this.getStyleProviderForClass(ToggleSwitch).defaultStyleFunction = this.setToggleSwitchStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_TRACK, this.setToggleSwitchOnTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_OFF_TRACK, this.setToggleSwitchOffTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setHorizontalThumbStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setHorizontalThumbStyles);
		
		//tree
		this.getStyleProviderForClass(Tree).defaultStyleFunction = this.setTreeStyles;
		this.getStyleProviderForClass(DefaultTreeItemRenderer).defaultStyleFunction = this.setTreeItemRendererStyles;
	}
	
	private static function textRendererFactory():ITextRenderer
	{
		return new TextFieldTextRenderer();
	}
	
	private static function textEditorFactory():ITextEditor
	{
		return new TextFieldTextEditor();
	}
	
	private static function textAreaTextEditorFactory():ITextEditorViewPort
	{
		return new TextFieldTextEditorViewPort();
	}
	
	private static function popUpOverlayFactory():DisplayObject
	{
		var quad:Quad = new Quad(10, 10, COLOR_MODAL_OVERLAY);
		quad.alpha = ALPHA_MODAL_OVERLAY;
		return quad;
	}
	
	private static function scrollBarFactory():SimpleScrollBar
	{
		return new SimpleScrollBar();
	}
	
	private static function stepperTextEditorFactory():ITextEditor
	{
		/* We are only using this text editor in the NumericStepper because
		 * isEditable is false on the TextInput. this text editor is not
		 * suitable for mobile use if the TextInput needs to be editable
		 * because it can't use the soft keyboard or other mobile-friendly UI */
		return new TextFieldTextEditor();
	}
	
	private static function pickerListSpinnerListFactory():SpinnerList
	{
		return new SpinnerList();
	}
	
	private function pageIndicatorNormalSymbolFactory():DisplayObject
	{
		var symbol:ImageLoader = new ImageLoader();
		symbol.source = this.pageIndicatorNormalTexture;
		return symbol;
	}
	
	private function pageIndicatorSelectedSymbolFactory():DisplayObject
	{
		var symbol:ImageLoader = new ImageLoader();
		symbol.source = this.pageIndicatorSelectedTexture;
		return symbol;
	}
	
	private function dataGridHeaderDividerFactory():DisplayObject
	{
		var skin:ImageSkin = new ImageSkin(this.dataGridHeaderDividerSkinTexture);
		skin.scale9Grid = DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID;
		skin.minTouchWidth = this.controlSize;
		return skin;
	}
	
	private function toastContainerFactory():DisplayObjectContainer
	{
		var container:LayoutGroup = new LayoutGroup();
		container.autoSizeMode = AutoSizeMode.STAGE;
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.verticalAlign = VerticalAlign.BOTTOM;
		if (DeviceCapabilities.isPhone())
		{
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		}
		else
		{
			layout.horizontalAlign = HorizontalAlign.LEFT;
			layout.padding = this.gutterSize;
			layout.gap = this.gutterSize;
		}
		container.layout = layout;
		return container;
	}
	
	//-------------------------
	// Shared
	//-------------------------
	
	private function setScrollerStyles(scroller:Scroller):Void
	{
		scroller.verticalScrollBarFactory = scrollBarFactory;
		scroller.horizontalScrollBarFactory = scrollBarFactory;
	}
	
	private function setDropDownListStyles(list:List):Void
	{
		var backgroundSkin:Quad = new Quad(10, 10, COLOR_SPINNER_LIST_BACKGROUND);
		list.backgroundSkin = backgroundSkin;
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		layout.maxRowCount = 4;
		list.layout = layout;
	}
	
	//-------------------------
	// Alert
	//-------------------------
	
	private function setAlertStyles(alert:Alert):Void
	{
		this.setScrollerStyles(alert);
		
		var backgroundSkin:Image = new Image(this.popUpBackgroundTexture);
		backgroundSkin.scale9Grid = BACKGROUND_POPUP_SCALE9_GRID;
		alert.backgroundSkin = backgroundSkin;
		
		alert.fontStyles = this.darkFontStyles.clone();
		alert.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		alert.paddingTop = 0;
		alert.paddingRight = this.gutterSize;
		alert.paddingBottom = this.gutterSize;
		alert.paddingLeft = this.gutterSize;
		alert.gap = this.gutterSize;
		alert.maxWidth = this.popUpFillSize;
		alert.maxHeight = this.popUpFillSize;
	}
	
	//see Panel section for Header styles
	
	private function setAlertButtonGroupStyles(group:ButtonGroup):Void
	{
		group.direction = Direction.HORIZONTAL;
		group.horizontalAlign = HorizontalAlign.CENTER;
		group.verticalAlign = VerticalAlign.JUSTIFY;
		group.distributeButtonSizes = false;
		group.gap = this.gutterSize;
		group.padding = this.gutterSize;
		group.paddingTop = 0;
		group.customLastButtonStyleName = THEME_STYLE_NAME_ALERT_BUTTON_GROUP_LAST_BUTTON;
		group.customButtonStyleName = THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON;
	}
	
	private function setAlertButtonGroupButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledTexture);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			skin.selectedTexture = this.toggleButtonSelectedUpTexture;
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledTexture);
		}
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize * 2;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	//-------------------------
	// Button
	//-------------------------
	
	private function setBaseButtonStyles(button:Button):Void
	{
		button.paddingBottom = this.smallGutterSize;
		button.paddingTop = this.smallGutterSize;
		button.paddingRight = this.gutterSize;
		button.paddingLeft = this.gutterSize;
		button.gap = this.smallGutterSize;
	}
	
	private function setButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledTexture);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			skin.selectedTexture = this.toggleButtonSelectedUpTexture;
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledTexture);
		}
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setQuietButtonStyles(button:Button):Void
	{
		var downSkin:Image = new Image(this.quietButtonDownTexture);
		downSkin.scale9Grid = BUTTON_SCALE9_GRID;
		button.setSkinForState(ButtonState.DOWN, downSkin);
		
		var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		defaultSkin.alpha = 0;
		button.defaultSkin = defaultSkin;
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}

	private function setDangerButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.dangerButtonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.dangerButtonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.dangerButtonDisabledTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.lightFontStyles.clone();
		button.disabledFontStyles = this.dangerDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setCallToActionButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.callToActionButtonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.callToActionButtonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.callToActionButtonDisabledTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.lightFontStyles.clone();
		button.disabledFontStyles = this.actionDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setBackButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backButtonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.backButtonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.backButtonDisabledTexture);
		skin.scale9Grid = BACK_BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
		
		button.paddingLeft = this.gutterSize + this.smallGutterSize;
	}
	
	private function setForwardButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.forwardButtonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.forwardButtonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.forwardButtonDisabledTexture);
		skin.scale9Grid = FORWARD_BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		setBaseButtonStyles(button);
		
		button.paddingRight = this.gutterSize + this.smallGutterSize;
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
		var skin:ImageSkin = new ImageSkin(this.buttonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledTexture);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			skin.selectedTexture = this.toggleButtonSelectedUpTexture;
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledTexture);
		}
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	//-------------------------
	// Callout
	//-------------------------
	
	private function setCalloutStyles(callout:Callout):Void
	{
		var backgroundSkin:Image = new Image(this.popUpBackgroundTexture);
		backgroundSkin.scale9Grid = BACKGROUND_POPUP_SCALE9_GRID;
		backgroundSkin.width = this.calloutBackgroundMinSize;
		backgroundSkin.height = this.calloutBackgroundMinSize;
		callout.backgroundSkin = backgroundSkin;
		
		var topArrowSkin:Image = new Image(this.calloutTopArrowTexture);
		callout.topArrowSkin = topArrowSkin;
		callout.topArrowGap = this.calloutVerticalArrowGap;
		
		var rightArrowSkin:Image = new Image(this.calloutRightArrowTexture);
		callout.rightArrowSkin = rightArrowSkin;
		callout.rightArrowGap = this.calloutHorizontalArrowGap;
		
		var bottomArrowSkin:Image = new Image(this.calloutBottomArrowTexture);
		callout.bottomArrowSkin = bottomArrowSkin;
		callout.bottomArrowGap = this.calloutVerticalArrowGap;
		
		var leftArrowSkin:Image = new Image(this.calloutLeftArrowTexture);
		callout.leftArrowSkin = leftArrowSkin;
		callout.leftArrowGap = this.calloutHorizontalArrowGap;
		
		callout.padding = this.gutterSize;
	}
	
	//-------------------------
	// Check
	//-------------------------
	
	private function setCheckStyles(check:Check):Void
	{
		var icon:ImageSkin = new ImageSkin(this.checkUpIconTexture);
		icon.selectedTexture = this.checkSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.DOWN, this.checkDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.checkDisabledIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.checkSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.checkSelectedDisabledIconTexture);
		check.defaultIcon = icon;
		
		check.fontStyles = this.darkFontStyles.clone();
		check.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		check.gap = this.smallGutterSize;
	}
	
	//-------------------------
	// DataGrid
	//-------------------------
	
	private function setDataGridStyles(grid:DataGrid):Void
	{
		this.setScrollerStyles(grid);
		grid.backgroundSkin = new Quad(10, 10, COLOR_BACKGROUND_LIGHT);
		
		var columnResizeSkin:ImageSkin = new ImageSkin(this.dataGridColumnResizeSkinTexture);
		columnResizeSkin.scale9Grid = DATA_GRID_COLUMN_RESIZE_SCALE_9_GRID;
		grid.columnResizeSkin = columnResizeSkin;
		
		var columnDropIndicatorSkin:ImageSkin = new ImageSkin(this.dataGridColumnDropIndicatorSkinTexture);
		columnDropIndicatorSkin.scale9Grid = DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID;
		grid.columnDropIndicatorSkin = columnDropIndicatorSkin;
		grid.extendedColumnDropIndicator = true;
		
		var columnDragOverlaySkin:Quad = new Quad(1, 1, COLOR_DATA_GRID_DRAG_OVERLAY);
		columnDragOverlaySkin.alpha = ALPHA_DATA_GRID_DRAG_OVERLAY;
		grid.columnDragOverlaySkin = columnDragOverlaySkin;
		
		grid.headerDividerFactory = this.dataGridHeaderDividerFactory;
	}
	
	private function setDataGridHeaderRendererStyles(headerRenderer:DefaultDataGridHeaderRenderer):Void
	{
		var backgroundSkin:Image = new Image(this.dataGridHeaderTexture);
		backgroundSkin.scale9Grid = DATA_GRID_HEADER_SCALE9_GRID;
		headerRenderer.backgroundSkin = backgroundSkin;
		
		headerRenderer.sortAscendingIcon = new ImageSkin(this.dataGridHeaderSortAscendingIconTexture);
		headerRenderer.sortDescendingIcon = new ImageSkin(this.dataGridHeaderSortDescendingIconTexture);
		
		headerRenderer.fontStyles = this.smallDarkFontStyles.clone();
		headerRenderer.disabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		headerRenderer.horizontalAlign = HorizontalAlign.LEFT;
		headerRenderer.paddingTop = this.smallGutterSize;
		headerRenderer.paddingRight = this.gutterSize;
		headerRenderer.paddingBottom = this.smallGutterSize;
		headerRenderer.paddingLeft = this.gutterSize;
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
		this.setSpinnerListItemRendererStyles(itemRenderer);
		
		itemRenderer.paddingLeft = this.smallGutterSize;
		itemRenderer.paddingRight = this.smallGutterSize;
		itemRenderer.gap = this.extraSmallGutterSize;
		itemRenderer.minGap = this.extraSmallGutterSize;
		itemRenderer.accessoryGap = this.extraSmallGutterSize;
		itemRenderer.minAccessoryGap = this.extraSmallGutterSize;
		itemRenderer.accessoryPosition = RelativePosition.LEFT;
	}
	
	//-------------------------
	// Drawers
	//-------------------------
	
	private function setDrawersStyles(drawers:Drawers):Void
	{
		var overlaySkin:Quad = new Quad(10, 10, COLOR_DRAWER_OVERLAY);
		overlaySkin.alpha = ALPHA_DRAWER_OVERLAY;
		drawers.overlaySkin = overlaySkin;
		
		var topDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, COLOR_DRAWERS_DIVIDER);
		drawers.topDrawerDivider = topDrawerDivider;
		
		var rightDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, COLOR_DRAWERS_DIVIDER);
		drawers.rightDrawerDivider = rightDrawerDivider;
		
		var bottomDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, COLOR_DRAWERS_DIVIDER);
		drawers.bottomDrawerDivider = bottomDrawerDivider;
		
		var leftDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, COLOR_DRAWERS_DIVIDER);
		drawers.leftDrawerDivider = leftDrawerDivider;
	}
	
	//-------------------------
	// GroupedList
	//-------------------------
	
	private function setGroupedListStyles(list:GroupedList):Void
	{
		this.setScrollerStyles(list);
		list.backgroundSkin = new Quad(10, 10, COLOR_BACKGROUND_LIGHT);
		list.customFirstItemRendererStyleName = THEME_STYLE_NAME_GROUPED_LIST_FIRST_ITEM_RENDERER;
	}
	
	private function setInsetGroupedListStyles(list:GroupedList):Void
	{
		this.setGroupedListStyles(list);
		list.customHeaderRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER;
		list.customFooterRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER;
	}
	
	//see List section for item renderer styles
	
	private function setGroupedListFirstItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.firstItemRendererUpTexture);
		skin.selectedTexture = this.itemRendererSelectedTexture;
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererDownTexture);
		skin.scale9Grid = LIST_ITEM_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.darkFontStyles.clone();
		itemRenderer.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		itemRenderer.iconLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		itemRenderer.accessoryLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		this.setBaseItemRendererStyles(itemRenderer);
	}
	
	private function setGroupedListHeaderRendererStyles(headerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var backgroundSkin:Image = new Image(this.groupedListHeaderTexture);
		backgroundSkin.scale9Grid = GROUPED_LIST_HEADER_OR_FOOTER_SCALE9_GRID;
		headerRenderer.backgroundSkin = backgroundSkin;
		
		headerRenderer.fontStyles = this.smallDarkFontStyles.clone();
		headerRenderer.disabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		headerRenderer.horizontalAlign = HorizontalAlign.LEFT;
		headerRenderer.paddingTop = this.smallGutterSize;
		headerRenderer.paddingRight = this.gutterSize;
		headerRenderer.paddingBottom = this.smallGutterSize;
		headerRenderer.paddingLeft = this.gutterSize;
	}

	private function setGroupedListInsetHeaderRendererStyles(headerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		headerRenderer.fontStyles = this.smallDarkFontStyles.clone();
		headerRenderer.disabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		headerRenderer.horizontalAlign = HorizontalAlign.LEFT;
		headerRenderer.paddingTop = this.gutterSize;
		headerRenderer.paddingRight = this.gutterSize;
		headerRenderer.paddingBottom = this.smallGutterSize;
		headerRenderer.paddingLeft = this.gutterSize;
	}
	
	private function setGroupedListFooterRendererStyles(footerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var backgroundSkin:Image = new Image(this.groupedListFooterTexture);
		backgroundSkin.scale9Grid = GROUPED_LIST_HEADER_OR_FOOTER_SCALE9_GRID;
		footerRenderer.backgroundSkin = backgroundSkin;
		
		footerRenderer.fontStyles = this.smallDarkFontStyles.clone();
		footerRenderer.disabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		footerRenderer.horizontalAlign = HorizontalAlign.CENTER;
		footerRenderer.paddingTop = this.smallGutterSize;
		footerRenderer.paddingRight = this.gutterSize;
		footerRenderer.paddingBottom = this.smallGutterSize;
		footerRenderer.paddingLeft = this.gutterSize;
	}
	
	private function setGroupedListInsetFooterRendererStyles(footerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		footerRenderer.fontStyles = this.darkFontStyles.clone();
		footerRenderer.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		footerRenderer.horizontalAlign = HorizontalAlign.LEFT;
		footerRenderer.paddingTop = this.smallGutterSize;
		footerRenderer.paddingRight = this.gutterSize;
		footerRenderer.paddingBottom = this.gutterSize;
		footerRenderer.paddingLeft = this.gutterSize;
	}
	
	//-------------------------
	// Header
	//-------------------------
	
	private function setHeaderStyles(header:Header):Void
	{
		this.setHeaderWithoutBackgroundStyles(header);
		
		header.fontStyles = this.largeDarkFontStyles.clone();
		header.disabledFontStyles = this.largeDarkDisabledFontStyles.clone();
		
		var backgroundSkin:Image = new Image(this.headerBackgroundSkinTexture);
		backgroundSkin.scale9Grid = HEADER_BACKGROUND_SCALE9_GRID;
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		header.backgroundSkin = backgroundSkin;
	}
	
	//-------------------------
	// Label
	//-------------------------
	
	private function setLabelStyles(label:Label):Void
	{
		label.fontStyles = this.darkFontStyles.clone();
		label.disabledFontStyles = this.darkDisabledFontStyles.clone();
	}
	
	private function setHeadingLabelStyles(label:Label):Void
	{
		label.fontStyles = this.largeDarkFontStyles.clone();
		label.disabledFontStyles = this.largeDarkDisabledFontStyles.clone();
	}
	
	private function setDetailLabelStyles(label:Label):Void
	{
		label.fontStyles = this.smallDarkFontStyles.clone();
		label.disabledFontStyles = this.smallDarkDisabledFontStyles.clone();
	}
	
	//-------------------------
	// LayoutGroup
	//-------------------------
	
	private function setToolbarLayoutGroupStyles(group:LayoutGroup):Void
	{
		if (group.layout == null)
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.paddingTop = this.smallGutterSize;
			layout.paddingRight = this.smallGutterSize;
			layout.paddingBottom = this.smallGutterSize;
			layout.paddingLeft = this.smallGutterSize;
			layout.gap = this.smallGutterSize;
			group.layout = layout;
		}
		
		group.backgroundSkin = new Quad(this.controlSize, this.controlSize, COLOR_BACKGROUND_LIGHT);
	}
	
	//-------------------------
	// List
	//-------------------------
	
	private function setListStyles(list:List):Void
	{
		this.setScrollerStyles(list);
		list.backgroundSkin = new Quad(10, 10, COLOR_BACKGROUND_LIGHT);
		
		var dropIndicatorSkin:Quad = new Quad(this.borderSize, this.borderSize, COLOR_TEXT_DARK);
		list.dropIndicatorSkin = dropIndicatorSkin;
	}
	
	private function setListItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		var dragIcon:ImageSkin = new ImageSkin(this.dragHandleIconTexture);
		dragIcon.minTouchWidth = this.gridSize;
		dragIcon.minTouchHeight = this.gridSize;
		itemRenderer.dragIcon = dragIcon;
	}
	
	private function setBaseItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.gap = this.gutterSize;
		itemRenderer.minGap = this.gutterSize;
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.gutterSize;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		itemRenderer.minTouchWidth = this.controlSize;
		itemRenderer.minTouchHeight = this.controlSize;
	}
	
	private function setItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpTexture);
		skin.selectedTexture = this.itemRendererSelectedTexture;
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererDownTexture);
		skin.scale9Grid = LIST_ITEM_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.darkFontStyles.clone();
		itemRenderer.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		itemRenderer.iconLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		itemRenderer.accessoryLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		this.setBaseItemRendererStyles(itemRenderer);
	}
	
	//-------------------------
	// NumericStepper
	//-------------------------
	
	private function setNumericStepperStyles(stepper:NumericStepper):Void
	{
		stepper.buttonLayoutMode = StepperButtonLayoutMode.SPLIT_HORIZONTAL;
		stepper.incrementButtonLabel = "+";
		stepper.decrementButtonLabel = "-";
	}
	
	private function setNumericStepperTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledTexture);
		skin.disabledTexture = this.textInputBackgroundDisabledTexture;
		skin.scale9Grid = TEXT_INPUT_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		input.textEditorFactory = stepperTextEditorFactory;
		input.fontStyles = this.darkCenteredFontStyles.clone();
		input.disabledFontStyles = this.darkCenteredDisabledFontStyles.clone();
		
		input.padding = this.smallGutterSize;
		input.isEditable = false;
		input.isSelectable = false;
	}
	
	private function setNumericStepperButtonStyles(button:Button):Void
	{
		setQuietButtonStyles(button);
		
		button.keepDownStateOnRollOut = true;
		
		button.fontStyles = this.largeDarkFontStyles.clone();
		button.disabledFontStyles = this.largeDarkDisabledFontStyles.clone();
	}
	
	//-------------------------
	// PageIndicator
	//-------------------------
	
	private function setPageIndicatorStyles(pageIndicator:PageIndicator):Void
	{
		pageIndicator.normalSymbolFactory = pageIndicatorNormalSymbolFactory;
		pageIndicator.selectedSymbolFactory = pageIndicatorSelectedSymbolFactory;
		pageIndicator.gap = this.gutterSize;
		pageIndicator.padding = this.gutterSize;
		pageIndicator.minTouchWidth = this.controlSize;
		pageIndicator.minTouchHeight = this.controlSize;
	}
	
	//-------------------------
	// Panel
	//-------------------------
	
	private function setPanelStyles(panel:Panel):Void
	{
		this.setScrollerStyles(panel);
		
		var backgroundSkin:Image = new Image(this.popUpBackgroundTexture);
		backgroundSkin.scale9Grid = BACKGROUND_POPUP_SCALE9_GRID;
		panel.backgroundSkin = backgroundSkin;
		
		panel.paddingTop = this.smallGutterSize;
		panel.paddingRight = this.smallGutterSize;
		panel.paddingBottom = this.smallGutterSize;
		panel.paddingLeft = this.smallGutterSize;
	}
	
	private function setHeaderWithoutBackgroundStyles(header:Header):Void
	{
		header.fontStyles = this.largeDarkFontStyles.clone();
		header.disabledFontStyles = this.largeDarkDisabledFontStyles.clone();
		
		header.gap = this.gutterSize;
		header.paddingTop = this.smallGutterSize;
		header.paddingRight = this.smallGutterSize;
		header.paddingBottom = this.smallGutterSize;
		header.paddingLeft = this.smallGutterSize;
		header.titleGap = this.smallGutterSize;
		header.minHeight = this.gridSize;
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
		if (DeviceCapabilities.isPhone(this.starling.nativeStage))
		{
			list.listFactory = pickerListSpinnerListFactory;
			
			var popUpContentManager:BottomDrawerPopUpContentManager = new BottomDrawerPopUpContentManager();
			popUpContentManager.customPanelStyleName = THEME_STYLE_NAME_POP_UP_DRAWER;
			list.popUpContentManager = popUpContentManager;
		}
		else
		{
			list.popUpContentManager = new CalloutPopUpContentManager();
			list.customItemRendererStyleName = THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER;
		}
	}
	
	private function setPickerListButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		button.defaultSkin = skin;
		
		var icon:ImageSkin = new ImageSkin(this.pickerListButtonIcon);
		icon.disabledTexture = this.pickerListButtonDisabledIcon;
		button.defaultIcon = icon;
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
		
		button.gap = Math.POSITIVE_INFINITY;
		button.minGap = this.gutterSize;
		button.iconPosition = RelativePosition.RIGHT;
		button.paddingLeft = this.gutterSize;
	}
	
	private function setPickerListListStyles(list:List):Void
	{
		this.setDropDownListStyles(list);
	}
	
	private function setTabletPickerListItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpTexture);
		skin.selectedTexture = this.itemRendererSelectedTexture;
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererDownTexture);
		skin.scale9Grid = LIST_ITEM_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.popUpFillSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.darkFontStyles.clone();
		itemRenderer.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		itemRenderer.iconLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		itemRenderer.accessoryLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		
		this.setBaseItemRendererStyles(itemRenderer);
	}
	
	private function setPickerListPopUpDrawerStyles(panel:Panel):Void
	{
		this.setScrollerStyles(panel);
		
		panel.customHeaderStyleName = THEME_STYLE_NAME_POP_UP_DRAWER_HEADER;
		
		var backgroundSkin:Image = new Image(this.popUpDrawerBackgroundTexture);
		backgroundSkin.scale9Grid = POP_UP_DRAWER_BACKGROUND_SCALE9_GRID;
		panel.backgroundSkin = backgroundSkin;
		
		panel.outerPaddingTop = this.shadowSize;
	}
	
	//-------------------------
	// ProgressBar
	//-------------------------
	
	private function setProgressBarStyles(progress:ProgressBar):Void
	{
		var backgroundSkin:Image;
		var backgroundDisabledSkin:Image;
		/* Horizontal background skin */
		if (progress.direction == Direction.HORIZONTAL)
		{
			backgroundSkin = new Image(this.horizontalProgressBarBackgroundTexture);
			backgroundSkin.scale9Grid = BAR_HORIZONTAL_SCALE9_GRID;
			backgroundSkin.width = this.wideControlSize;
			backgroundSkin.height = this.smallControlSize;
			backgroundDisabledSkin = new Image(this.horizontalProgressBarBackgroundDisabledTexture);
			backgroundDisabledSkin.scale9Grid = BAR_HORIZONTAL_SCALE9_GRID;
			backgroundDisabledSkin.width = this.wideControlSize;
			backgroundDisabledSkin.height = this.smallControlSize;
		}
		else //vertical
		{
			backgroundSkin = new Image(this.verticalProgressBarBackgroundTexture);
			backgroundSkin.scale9Grid = BAR_VERTICAL_SCALE9_GRID;
			backgroundSkin.width = this.smallControlSize;
			backgroundSkin.height = this.wideControlSize;
			backgroundDisabledSkin = new Image(this.verticalProgressBarBackgroundDisabledTexture);
			backgroundDisabledSkin.scale9Grid = BAR_VERTICAL_SCALE9_GRID;
			backgroundDisabledSkin.width = this.smallControlSize;
			backgroundDisabledSkin.height = this.wideControlSize;
		}
		progress.backgroundSkin = backgroundSkin;
		progress.backgroundDisabledSkin = backgroundDisabledSkin;
		
		var fillSkin:Image;
		var fillDisabledSkin:Image;
		/* Horizontal fill skin */
		if (progress.direction == Direction.HORIZONTAL)
		{
			fillSkin = new Image(this.horizontalProgressBarFillTexture);
			fillSkin.scale9Grid = BAR_HORIZONTAL_SCALE9_GRID;
			fillSkin.width = this.smallControlSize;
			fillSkin.height = this.smallControlSize;
			fillDisabledSkin = new Image(this.horizontalProgressBarFillDisabledTexture);
			fillDisabledSkin.scale9Grid = BAR_HORIZONTAL_SCALE9_GRID;
			fillDisabledSkin.width = this.smallControlSize;
			fillDisabledSkin.height = this.smallControlSize;
		}
		else //vertical
		{
			fillSkin = new Image(this.verticalProgressBarFillTexture);
			fillSkin.scale9Grid = BAR_VERTICAL_SCALE9_GRID;
			fillSkin.width = this.smallControlSize;
			fillSkin.height = this.smallControlSize;
			fillDisabledSkin = new Image(verticalProgressBarFillDisabledTexture);
			fillDisabledSkin.scale9Grid = BAR_VERTICAL_SCALE9_GRID;
			fillDisabledSkin.width = this.smallControlSize;
			fillDisabledSkin.height = this.smallControlSize;
		}
		progress.fillSkin = fillSkin;
		progress.fillDisabledSkin = fillDisabledSkin;
	}
	
	//-------------------------
	// Radio
	//-------------------------
	
	private function setRadioStyles(radio:Radio):Void
	{
		var icon:ImageSkin = new ImageSkin(this.radioUpIconTexture);
		icon.selectedTexture = this.radioSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.DOWN, this.radioDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.radioDisabledIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.radioSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.radioSelectedDisabledIconTexture);
		radio.defaultIcon = icon;
		
		radio.fontStyles = this.darkFontStyles.clone();
		radio.disabledFontStyles = this.darkDisabledFontStyles.clone();
		
		radio.gap = this.smallGutterSize;
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
			layout.paddingTop = this.smallGutterSize;
			layout.paddingRight = this.smallGutterSize;
			layout.paddingBottom = this.smallGutterSize;
			layout.paddingLeft = this.smallGutterSize;
			layout.gap = this.smallGutterSize;
			container.layout = layout;
		}
		
		container.backgroundSkin = new Quad(this.controlSize, this.controlSize, COLOR_BACKGROUND_LIGHT);
	}
	
	//-------------------------
	// ScrollText
	//-------------------------
	
	private function setScrollTextStyles(text:ScrollText):Void
	{
		this.setScrollerStyles(text);
		
		text.fontStyles = this.darkScrollTextFontStyles.clone();
		text.disabledFontStyles = this.darkScrollTextDisabledFontStyles.clone();
		
		text.padding = this.gutterSize;
		text.paddingRight = this.gutterSize + this.smallGutterSize;
	}
	
	//-------------------------
	// SimpleScrollBar
	//-------------------------
	
	private function setSimpleScrollBarStyles(scrollBar:SimpleScrollBar):Void
	{
		if (scrollBar.direction == Direction.HORIZONTAL)
		{
			scrollBar.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB;
		}
		else //vertical
		{
			scrollBar.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB;
		}
		scrollBar.paddingTop = this.extraSmallGutterSize;
		scrollBar.paddingRight = this.extraSmallGutterSize;
		scrollBar.paddingBottom = this.extraSmallGutterSize;
	}
	
	private function setHorizontalSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var defaultSkin:Image = new Image(this.horizontalSimpleScrollBarThumbTexture);
		defaultSkin.scale9Grid = HORIZONTAL_SIMPLE_SCROLL_BAR_SCALE9_GRID;
		thumb.defaultSkin = defaultSkin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var defaultSkin:Image = new Image(this.verticalSimpleScrollBarThumbTexture);
		defaultSkin.scale9Grid = VERTICAL_SIMPLE_SCROLL_BAR_SCALE9_GRID;
		thumb.defaultSkin = defaultSkin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// SpinnerList
	//-------------------------
	
	private function setSpinnerListStyles(list:SpinnerList):Void
	{
		list.verticalScrollPolicy = ScrollPolicy.ON;
		list.backgroundSkin = new Quad(this.controlSize, this.controlSize, COLOR_SPINNER_LIST_BACKGROUND);
		var selectionOverlaySkin:Image = new Image(this.spinnerListSelectionOverlayTexture);
		selectionOverlaySkin.scale9Grid = SPINNER_LIST_OVERLAY_SCALE9_GRID;
		list.selectionOverlaySkin = selectionOverlaySkin;
		list.customItemRendererStyleName = THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER;
	}
	
	private function setSpinnerListItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		var defaultSkin:Quad = new Quad(this.gridSize, this.gridSize, 0xff00ff);
		defaultSkin.alpha = 0;
		itemRenderer.defaultSkin = defaultSkin;
		
		itemRenderer.fontStyles = this.darkFontStyles.clone();
		itemRenderer.disabledFontStyles = this.darkDisabledFontStyles.clone();
		itemRenderer.selectedFontStyles = this.selectedFontStyles.clone();
		
		itemRenderer.iconLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		itemRenderer.iconLabelSelectedFontStyles = this.smallSelectedFontStyles.clone();
		
		itemRenderer.accessoryLabelFontStyles = this.smallDarkFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.smallDarkDisabledFontStyles.clone();
		itemRenderer.accessoryLabelSelectedFontStyles = this.smallSelectedFontStyles.clone();
		
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
	}
	
	//-------------------------
	// Slider
	//-------------------------
	
	private function setSliderStyles(slider:Slider):Void
	{
		slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		if (slider.direction == Direction.VERTICAL)
		{
			slider.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_THUMB;
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK;
			slider.customMaximumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK;
		}
		else //horizontal
		{
			slider.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_THUMB;
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK;
			slider.customMaximumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK;
		}
	}
	
	private function setHorizontalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.horizontalSliderMinimumTrackTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.horizontalSliderMinimumTrackDisabledTexture);
		skin.scale9Grid = HORIZONTAL_MINIMUM_TRACK_SCALE9_GRID;
		skin.width = this.wideControlSize - this.thumbSize / 2;
		skin.height = this.smallControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalSliderMaximumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.horizontalSliderMaximumTrackTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.horizontalSliderMaximumTrackDisabledTexture);
		skin.scale9Grid = HORIZONTAL_MAXIMUM_TRACK_SCALE9_GRID;
		skin.width = this.wideControlSize - this.thumbSize / 2;
		skin.height = this.smallControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.verticalSliderMinimumTrackTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.verticalSliderMinimumTrackDisabledTexture);
		skin.scale9Grid = VERTICAL_MINIMUM_TRACK_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.wideControlSize - this.thumbSize / 2;
		track.defaultSkin = skin;
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMaximumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.verticalSliderMaximumTrackTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.verticalSliderMaximumTrackDisabledTexture);
		skin.scale9Grid = VERTICAL_MAXIMUM_TRACK_SCALE9_GRID;
		skin.width = this.smallControlSize;
		skin.height = this.wideControlSize - this.thumbSize / 2;
		track.defaultSkin = skin;
		track.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// TabBar
	//-------------------------
	
	private function setTabBarStyles(tabBar:TabBar):Void
	{
		tabBar.distributeTabSizes = true;
	}
	
	private function setTabStyles(tab:ToggleButton):Void
	{
		var skin:ImageSkin = new ImageSkin(this.tabUpTexture);
		skin.selectedTexture = this.tabSelectedUpTexture;
		skin.setTextureForState(ButtonState.DOWN, this.tabDownTexture);
		skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.tabSelectedDisabledTexture);
		skin.scale9Grid = TAB_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.gridSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.gridSize;
		tab.defaultSkin = skin;
		
		tab.fontStyles = this.darkFontStyles.clone();
		tab.disabledFontStyles = this.darkDisabledFontStyles.clone();
		tab.selectedFontStyles = this.selectedFontStyles.clone();
		tab.setFontStylesForState(ButtonState.DISABLED_AND_SELECTED, this.selectedDisabledFontStyles.clone());
		
		tab.paddingLeft = this.gutterSize;
		tab.paddingRight = this.gutterSize;
	}
	
	//-------------------------
	// TextArea
	//-------------------------
	
	private function setTextAreaStyles(textArea:TextArea):Void
	{
		this.setScrollerStyles(textArea);
		
		var skin:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledTexture);
		skin.disabledTexture = this.textInputBackgroundDisabledTexture;
		skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
		skin.setTextureForState(TextInputState.ERROR, this.textInputBackgroundErrorTexture);
		skin.scale9Grid = TEXT_INPUT_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.wideControlSize;
		textArea.backgroundSkin = skin;
		
		textArea.fontStyles = this.darkScrollTextFontStyles.clone();
		textArea.disabledFontStyles = this.darkScrollTextDisabledFontStyles.clone();
		
		textArea.promptFontStyles = this.darkFontStyles.clone();
		textArea.promptDisabledFontStyles = this.darkDisabledFontStyles.clone();
		
		textArea.textEditorFactory = textAreaTextEditorFactory;
		
		textArea.innerPadding = this.smallGutterSize;
	}
	
	//-------------------------
	// TextCallout
	//-------------------------
	
	private function setTextCalloutStyles(callout:TextCallout):Void
	{
		this.setCalloutStyles(callout);
		
		callout.fontStyles = this.darkFontStyles.clone();
		callout.disabledFontStyles = this.darkDisabledFontStyles;
	}
	
	//-------------------------
	// TextInput
	//-------------------------
	
	private function setBaseTextInputStyles(input:TextInput):Void
	{
		input.paddingTop = this.smallGutterSize;
		input.paddingRight = this.gutterSize;
		input.paddingBottom = this.smallGutterSize;
		input.paddingLeft = this.gutterSize;
		input.gap = this.smallGutterSize;
	}
	
	private function setTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledTexture);
		skin.disabledTexture = this.textInputBackgroundDisabledTexture;
		skin.setTextureForState(TextInputState.FOCUSED, this.textInputBackgroundFocusedTexture);
		skin.setTextureForState(TextInputState.ERROR, this.textInputBackgroundErrorTexture);
		skin.scale9Grid = TEXT_INPUT_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		input.fontStyles = this.darkScrollTextFontStyles.clone();
		input.disabledFontStyles = this.darkScrollTextDisabledFontStyles.clone();
		
		input.promptFontStyles = this.darkFontStyles.clone();
		input.promptDisabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseTextInputStyles(input);
	}
	
	private function setSearchTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.searchTextInputBackgroundEnabledTexture);
		skin.disabledTexture = this.searchTextInputBackgroundDisabledTexture;
		skin.setTextureForState(TextInputState.FOCUSED, this.searchTextInputBackgroundFocusedTexture);
		skin.scale9Grid = SEARCH_INPUT_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		var icon:Image = new Image(this.searchIconTexture);
		input.defaultIcon = icon;
		
		input.fontStyles = this.darkScrollTextFontStyles.clone();
		input.disabledFontStyles = this.darkScrollTextDisabledFontStyles.clone();
		
		input.promptFontStyles = this.darkFontStyles.clone();
		input.promptDisabledFontStyles = this.darkDisabledFontStyles.clone();
		
		this.setBaseTextInputStyles(input);
	}
	
	//-------------------------
	// Toast
	//-------------------------
	
	private function setToastStyles(toast:Toast):Void
	{
		var backgroundSkin:Quad = new Quad(1, 1, COLOR_TOAST_BACKGROUND);
		toast.backgroundSkin = backgroundSkin;
		
		toast.fontStyles = this.lightFontStyles.clone();
		
		toast.width = this.popUpFillSize;
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
		button.fontStyles = this.selectedBoldFontStyles.clone();
		button.setFontStylesForState(ButtonState.DOWN, this.lightBoldFontStyles);
	}
	
	//-------------------------
	// ToggleButton
	//-------------------------
	
	private function setToggleButtonStyles(button:ToggleButton):Void
	{
		this.setButtonStyles(button);
		
		button.fontStyles = this.darkFontStyles.clone();
		button.disabledFontStyles = this.darkDisabledFontStyles.clone();
		button.selectedFontStyles = this.selectedFontStyles.clone();
		button.setFontStylesForState(ButtonState.DISABLED_AND_SELECTED, this.selectedDisabledFontStyles.clone());
	}
	
	//-------------------------
	// ToggleSwitch
	//-------------------------
	
	private function setToggleSwitchStyles(toggle:ToggleSwitch):Void
	{
		toggle.offLabelFontStyles = this.darkFontStyles.clone();
		toggle.offLabelDisabledFontStyles = this.darkDisabledFontStyles.clone();
		toggle.onLabelFontStyles = this.selectedFontStyles.clone();
		toggle.onLabelDisabledFontStyles = this.darkDisabledFontStyles.clone();
		
		toggle.trackLayoutMode = TrackLayoutMode.SPLIT;
	}
	
	private function setToggleSwitchOnTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.toggleSwitchOnTrackTexture);
		skin.disabledTexture = this.toggleSwitchOnTrackDisabledTexture;
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.gridSize;
		skin.height = this.controlSize;
		
		track.defaultSkin = skin;
		track.hasLabelTextRenderer = false;
	}
	
	private function setToggleSwitchOffTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.toggleSwitchOffTrackTexture);
		skin.disabledTexture = this.toggleSwitchOffTrackDisabledTexture;
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.gridSize;
		skin.height = this.controlSize;
		
		track.defaultSkin = skin;
		track.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.thumbSize;
		skin.height = this.controlSize;
		thumb.defaultSkin = skin;
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.thumbSize;
		thumb.defaultSkin = skin;
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Tree
	//-------------------------
	
	private function setTreeStyles(tree:Tree):Void
	{
		this.setScrollerStyles(tree);
		tree.backgroundSkin = new Quad(10, 10, COLOR_BACKGROUND_LIGHT);
	}
	
	private function setTreeItemRendererStyles(itemRenderer:DefaultTreeItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.indentation = this.treeDisclosureOpenIconTexture.width;
		
		var disclosureOpenIcon:ImageSkin = new ImageSkin(this.treeDisclosureOpenIconTexture);
		//make sure the hit area is large enough for touch screens
		disclosureOpenIcon.minTouchWidth = this.gridSize;
		disclosureOpenIcon.minTouchHeight = this.gridSize;
		itemRenderer.disclosureOpenIcon = disclosureOpenIcon;
		
		var disclosureClosedIcon:ImageSkin = new ImageSkin(this.treeDisclosureClosedIconTexture);
		disclosureClosedIcon.minTouchWidth = this.gridSize;
		disclosureClosedIcon.minTouchHeight = this.gridSize;
		itemRenderer.disclosureClosedIcon = disclosureClosedIcon;
	}
}