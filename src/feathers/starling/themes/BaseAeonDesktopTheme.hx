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
import feathers.starling.controls.IScrollBar;
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
import feathers.starling.core.ITextEditor;
import feathers.starling.core.ITextRenderer;
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
 * The base class for the "Aeon" theme for desktop Feathers apps. Handles
 * everything except asset loading, which is left to subclasses.
 *
 * @see AeonDesktopTheme
 * @see AeonDesktopThemeWithAssetManager
 */
class BaseAeonDesktopTheme extends StyleNameFunctionTheme 
{
	/**
	 * @private
	 * The theme's custom style name for the increment button of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON:String = "aeon-horizontal-scroll-bar-increment-button";

	/**
	 * @private
	 * The theme's custom style name for the decrement button of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON:String = "aeon-horizontal-scroll-bar-decrement-button";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_THUMB:String = "aeon-horizontal-scroll-bar-thumb";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a horizontal ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MINIMUM_TRACK:String = "aeon-horizontal-scroll-bar-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the increment button of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON:String = "aeon-vertical-scroll-bar-increment-button";

	/**
	 * @private
	 * The theme's custom style name for the decrement button of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON:String = "aeon-vertical-scroll-bar-decrement-button";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_THUMB:String = "aeon-vertical-scroll-bar-thumb";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a vertical ScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MINIMUM_TRACK:String = "aeon-vertical-scroll-bar-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a horizontal SimpleScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB:String = "aeon-horizontal-simple-scroll-bar-thumb";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a vertical SimpleScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB:String = "aeon-vertical-simple-scroll-bar-thumb";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a horizontal Slider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_THUMB:String = "aeon-horizontal-slider-thumb";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a horizontal Slider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK:String = "aeon-horizontal-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a vertical Slider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_THUMB:String = "aeon-vertical-slider-thumb";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a vertical Slider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK:String = "aeon-vertical-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a vertical VolumeSlider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MINIMUM_TRACK:String = "aeon-vertical-volume-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the maximum track of a vertical VolumeSlider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MAXIMUM_TRACK:String = "aeon-vertical-volume-slider-maximum-track";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a horizontal VolumeSlider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MINIMUM_TRACK:String = "aeon-horizontal-volume-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the maximum track of a horizontal VolumeSlider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MAXIMUM_TRACK:String = "aeon-horizontal-volume-slider-maximum-track";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a pop-up VolumeSlider.
	 */
	private static inline var THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK:String = "aeon-pop-up-volume-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the maximum track of a pop-up VolumeSlider.
	 */
	private static inline var THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MAXIMUM_TRACK:String = "aeon-pop-up-volume-slider-maximum-track";

	/**
	 * @private
	 * The theme's custom style name for the item renderer of a SpinnerList in a DateTimeSpinner.
	 */
	private static inline var THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER:String = "aeon-date-time-spinner-list-item-renderer";

	/**
	 * @private
	 * The theme's custom style name for the action buttons of a toast.
	 */
	private static inline var THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON:String = "metal-works-mobile-toast-actions-button";
	
	/**
	 * The name of the font used by controls in this theme. This font is not
	 * embedded. It is the default sans-serif system font.
	 */
	public static inline var FONT_NAME:String = "_sans";

	private static var FOCUS_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 2, 2);
	private static var TOOL_TIP_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 1, 1);
	private static var CALLOUT_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 1, 1);
	private static var BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 1, 12);
	private static var TAB_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 1, 15);
	private static var STEPPER_INCREMENT_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(1, 9, 15, 1);
	private static var STEPPER_DECREMENT_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(1, 1, 15, 1);
	private static var HORIZONTAL_SLIDER_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(3, 0, 1, 4);
	private static var VERTICAL_SLIDER_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(0, 3, 4, 1);
	private static var TEXT_INPUT_SCALE_9_GRID:Rectangle = new Rectangle(2, 2, 1, 1);
	private static var VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID:Rectangle = new Rectangle(2, 5, 6, 42);
	private static var VERTICAL_SCROLL_BAR_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(2, 1, 11, 2);
	private static var VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(2, 2, 11, 10);
	private static var HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID:Rectangle = new Rectangle(5, 2, 42, 6);
	private static var HORIZONTAL_SCROLL_BAR_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(1, 2, 2, 11);
	private static var HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(2, 2, 10, 11);
	private static var SIMPLE_BORDER_SCALE_9_GRID:Rectangle = new Rectangle(2, 2, 2, 2);
	private static var PANEL_BORDER_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 1, 1);
	private static var HEADER_SCALE_9_GRID:Rectangle = new Rectangle(1, 1, 2, 28);
	private static var SEEK_SLIDER_MINIMUM_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(3, 0, 1, 4);
	private static var SEEK_SLIDER_MAXIMUM_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(1, 0, 1, 4);
	private static var DATA_GRID_VERTICAL_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 2, 1, 2);
	private static var DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 2, 5, 2);
	private static var DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(0, 2, 3, 2);
	
	private static var ITEM_RENDERER_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 4, 4);
	private static var PROGRESS_BAR_FILL_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 4, 4);
	
	private static inline var BACKGROUND_COLOR:Int = 0x869CA7;
	private static inline var MODAL_OVERLAY_COLOR:Int = 0xDDDDDD;
	private static inline var MODAL_OVERLAY_ALPHA:Float = 0.5;
	private static inline var PRIMARY_TEXT_COLOR:Int = 0x0B333C;
	private static inline var DISABLED_TEXT_COLOR:Int = 0x5B6770;
	private static inline var INVERTED_TEXT_COLOR:Int = 0xffffff;
	private static inline var ACTIVE_TEXT_COLOR:Int = 0x009dff;
	private static inline var VIDEO_OVERLAY_COLOR:Int = 0xc9e0eE;
	private static inline var VIDEO_OVERLAY_ALPHA:Float = 0.25;
	
	/**
	 * The default global text renderer factory for this theme creates a
	 * TextFieldTextRenderer.
	 */
	private static function textRendererFactory():ITextRenderer
	{
		return new TextFieldTextRenderer();
	}
	
	/**
	 * The default global text editor factory for this theme creates a
	 * TextFieldTextEditor.
	 */
	private static function textEditorFactory():ITextEditor
	{
		return new TextFieldTextEditor();
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
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * A smaller font size for details.
	 */
	private var smallFontSize:Int = 10;
	
	/**
	 * A normal font size.
	 */
	private var regularFontSize:Int = 11;
	
	/**
	 * A larger font size for headers.
	 */
	private var largeFontSize:Int = 13;
	
	/**
	 * The size, in pixels, of major regions in the grid. Used for sizing
	 * containers and larger UI controls.
	 */
	private var gridSize:Int = 30;
	
	/**
	 * The size, in pixels, of minor regions in the grid. Used for larger
	 * padding and gaps.
	 */
	private var gutterSize:Int = 10;
	
	/**
	 * The size, in pixels, of smaller padding and gaps within the major
	 * regions in the grid.
	 */
	private var smallGutterSize:Int = 6;
	
	/**
	 * The size, in pixels, of very smaller padding and gaps.
	 */
	private var extraSmallGutterSize:Int = 2;
	
	/**
	 * The minimum width, in pixels, of some types of buttons.
	 */
	private var buttonMinWidth:Int = 40;
	
	/**
	 * The width, in pixels, of UI controls that span across multiple grid regions.
	 */
	private var wideControlSize:Int = 152;
	
	/**
	 * The width, in pixels, of very large UI controls.
	 */
	private var extraWideControlSize:Int = 210;
	
	/**
	 * The size, in pixels, of a typical UI control.
	 */
	private var controlSize:Int = 22;
	
	/**
	 * The size, in pixels, of smaller UI controls.
	 */
	private var smallControlSize:Int = 12;
	
	/**
	 * The size, in pixels, of a border around any control.
	 */
	private var borderSize:Int = 1;
	
	private var calloutBackgroundMinSize:Int = 5;
	private var calloutArrowOverlapGap:Int = -1;
	private var progressBarFillMinSize:Int = 7;
	private var popUpSize:Int = 354;
	private var popUpVolumeSliderPaddingSize:Int = 6;
	private var bottomDropShadowSize:Int = 3;
	private var leftAndRightDropShadowSize:Int = 1;
	
	/**
	 * The texture atlas that contains skins for this theme. This base class
	 * does not initialize this member variable. Subclasses are expected to
	 * load the assets somehow and set the <code>atlas</code> member
	 * variable before calling <code>initialize()</code>.
	 */
	private var atlas:TextureAtlas;
	
	/**
	 * Font styles for most UI controls and text.
	 */
	private var defaultFontStyles:TextFormat;
	
	/**
	 * Font styles for most disabled UI controls and text.
	 */
	private var disabledFontStyles:TextFormat;
	
	/**
	 * Font styles for larger text.
	 */
	private var headingFontStyles:TextFormat;
	
	/**
	 * Font styles for larger, disabled text.
	 */
	private var headingDisabledFontStyles:TextFormat;
	
	/**
	 * Font styles for smaller text.
	 */
	private var detailFontStyles:TextFormat;

	/**
	 * Font styles for smaller, disabled text.
	 */
	private var detailDisabledFontStyles:TextFormat;
	
	/**
	 * Font styles for text on dark backgrounds.
	 */
	private var invertedFontStyles:TextFormat;
	
	/**
	 * Font styles for toast actions.
	 */
	private var toastActionFontStyles:TextFormat;
	
	/**
	 * Font styles for active toast actions.
	 */
	private var toastActionActiveFontStyles:TextFormat;
	
	private var focusIndicatorSkinTexture:Texture;
	private var toolTipBackgroundSkinTexture:Texture;
	private var calloutBackgroundSkinTexture:Texture;
	private var calloutTopArrowSkinTexture:Texture;
	private var calloutRightArrowSkinTexture:Texture;
	private var calloutBottomArrowSkinTexture:Texture;
	private var calloutLeftArrowSkinTexture:Texture;
	private var dangerCalloutBackgroundSkinTexture:Texture;
	private var dangerCalloutTopArrowSkinTexture:Texture;
	private var dangerCalloutRightArrowSkinTexture:Texture;
	private var dangerCalloutBottomArrowSkinTexture:Texture;
	private var dangerCalloutLeftArrowSkinTexture:Texture;
	
	private var buttonUpSkinTexture:Texture;
	private var buttonHoverSkinTexture:Texture;
	private var buttonDownSkinTexture:Texture;
	private var buttonDisabledSkinTexture:Texture;
	private var toggleButtonSelectedUpSkinTexture:Texture;
	private var toggleButtonSelectedHoverSkinTexture:Texture;
	private var toggleButtonSelectedDownSkinTexture:Texture;
	private var toggleButtonSelectedDisabledSkinTexture:Texture;
	private var quietButtonHoverSkinTexture:Texture;
	private var callToActionButtonUpSkinTexture:Texture;
	private var callToActionButtonHoverSkinTexture:Texture;
	private var dangerButtonUpSkinTexture:Texture;
	private var dangerButtonHoverSkinTexture:Texture;
	private var dangerButtonDownSkinTexture:Texture;
	private var backButtonUpIconTexture:Texture;
	private var backButtonDisabledIconTexture:Texture;
	private var forwardButtonUpIconTexture:Texture;
	private var forwardButtonDisabledIconTexture:Texture;
	
	private var tabUpSkinTexture:Texture;
	private var tabHoverSkinTexture:Texture;
	private var tabDownSkinTexture:Texture;
	private var tabDisabledSkinTexture:Texture;
	private var tabSelectedUpSkinTexture:Texture;
	private var tabSelectedDisabledSkinTexture:Texture;
	
	private var stepperIncrementButtonUpSkinTexture:Texture;
	private var stepperIncrementButtonHoverSkinTexture:Texture;
	private var stepperIncrementButtonDownSkinTexture:Texture;
	private var stepperIncrementButtonDisabledSkinTexture:Texture;
	
	private var stepperDecrementButtonUpSkinTexture:Texture;
	private var stepperDecrementButtonHoverSkinTexture:Texture;
	private var stepperDecrementButtonDownSkinTexture:Texture;
	private var stepperDecrementButtonDisabledSkinTexture:Texture;
	
	private var hSliderThumbUpSkinTexture:Texture;
	private var hSliderThumbHoverSkinTexture:Texture;
	private var hSliderThumbDownSkinTexture:Texture;
	private var hSliderThumbDisabledSkinTexture:Texture;
	private var hSliderTrackEnabledSkinTexture:Texture;
	
	private var vSliderThumbUpSkinTexture:Texture;
	private var vSliderThumbHoverSkinTexture:Texture;
	private var vSliderThumbDownSkinTexture:Texture;
	private var vSliderThumbDisabledSkinTexture:Texture;
	private var vSliderTrackEnabledSkinTexture:Texture;
	
	private var itemRendererUpSkinTexture:Texture;
	private var itemRendererHoverSkinTexture:Texture;
	private var itemRendererSelectedUpSkinTexture:Texture;
	
	private var dataGridVerticalDividerSkinTexture:Texture;
	private var dataGridHeaderBackgroundSkinTexture:Texture;
	private var dataGridHeaderDividerSkinTexture:Texture;
	private var dataGridHeaderSortAscendingIconTexture:Texture;
	private var dataGridHeaderSortDescendingIconTexture:Texture;
	private var dataGridColumnDropIndicatorSkinTexture:Texture;
	private var dataGridColumnResizeSkinTexture:Texture;
	
	private var headerBackgroundSkinTexture:Texture;
	private var groupedListHeaderBackgroundSkinTexture:Texture;
	
	private var checkUpIconTexture:Texture;
	private var checkHoverIconTexture:Texture;
	private var checkDownIconTexture:Texture;
	private var checkDisabledIconTexture:Texture;
	private var checkSelectedUpIconTexture:Texture;
	private var checkSelectedHoverIconTexture:Texture;
	private var checkSelectedDownIconTexture:Texture;
	private var checkSelectedDisabledIconTexture:Texture;
	
	private var radioUpIconTexture:Texture;
	private var radioHoverIconTexture:Texture;
	private var radioDownIconTexture:Texture;
	private var radioDisabledIconTexture:Texture;
	private var radioSelectedUpIconTexture:Texture;
	private var radioSelectedHoverIconTexture:Texture;
	private var radioSelectedDownIconTexture:Texture;
	private var radioSelectedDisabledIconTexture:Texture;
	
	private var pageIndicatorNormalSkinTexture:Texture;
	private var pageIndicatorSelectedSkinTexture:Texture;
	
	private var pickerListUpIconTexture:Texture;
	private var pickerListHoverIconTexture:Texture;
	private var pickerListDownIconTexture:Texture;
	private var pickerListDisabledIconTexture:Texture;
	
	private var textInputBackgroundEnabledSkinTexture:Texture;
	private var textInputBackgroundDisabledSkinTexture:Texture;
	private var textInputBackgroundErrorSkinTexture:Texture;
	private var textInputSearchIconTexture:Texture;
	private var textInputSearchIconDisabledTexture:Texture;
	
	private var vScrollBarThumbUpSkinTexture:Texture;
	private var vScrollBarThumbHoverSkinTexture:Texture;
	private var vScrollBarThumbDownSkinTexture:Texture;
	private var vScrollBarTrackSkinTexture:Texture;
	private var vScrollBarThumbIconTexture:Texture;
	private var vScrollBarStepButtonUpSkinTexture:Texture;
	private var vScrollBarStepButtonHoverSkinTexture:Texture;
	private var vScrollBarStepButtonDownSkinTexture:Texture;
	private var vScrollBarStepButtonDisabledSkinTexture:Texture;
	private var vScrollBarDecrementButtonIconTexture:Texture;
	private var vScrollBarIncrementButtonIconTexture:Texture;
	
	private var hScrollBarThumbUpSkinTexture:Texture;
	private var hScrollBarThumbHoverSkinTexture:Texture;
	private var hScrollBarThumbDownSkinTexture:Texture;
	private var hScrollBarTrackSkinTexture:Texture;
	private var hScrollBarThumbIconTexture:Texture;
	private var hScrollBarStepButtonUpSkinTexture:Texture;
	private var hScrollBarStepButtonHoverSkinTexture:Texture;
	private var hScrollBarStepButtonDownSkinTexture:Texture;
	private var hScrollBarStepButtonDisabledSkinTexture:Texture;
	private var hScrollBarDecrementButtonIconTexture:Texture;
	private var hScrollBarIncrementButtonIconTexture:Texture;
	
	private var simpleBorderBackgroundSkinTexture:Texture;
	private var insetBorderBackgroundSkinTexture:Texture;
	private var panelBorderBackgroundSkinTexture:Texture;
	private var alertBorderBackgroundSkinTexture:Texture;
	
	private var progressBarFillSkinTexture:Texture;
	
	private var listDrillDownAccessoryTexture:Texture;
	
	private var treeBranchOpenIconTexture:Texture;
	private var treeBranchClosedIconTexture:Texture;
	private var treeLeafIconTexture:Texture;
	private var treeDisclosureOpenIconTexture:Texture;
	private var treeDisclosureClosedIconTexture:Texture;
	
	//media textures
	private var playPauseButtonPlayUpIconTexture:Texture;
	private var playPauseButtonPauseUpIconTexture:Texture;
	private var overlayPlayPauseButtonPlayUpIconTexture:Texture;
	private var fullScreenToggleButtonEnterUpIconTexture:Texture;
	private var fullScreenToggleButtonExitUpIconTexture:Texture;
	private var muteToggleButtonLoudUpIconTexture:Texture;
	private var muteToggleButtonMutedUpIconTexture:Texture;
	private var horizontalVolumeSliderMinimumTrackSkinTexture:Texture;
	private var horizontalVolumeSliderMaximumTrackSkinTexture:Texture;
	private var verticalVolumeSliderMinimumTrackSkinTexture:Texture;
	private var verticalVolumeSliderMaximumTrackSkinTexture:Texture;
	private var popUpVolumeSliderMinimumTrackSkinTexture:Texture;
	private var popUpVolumeSliderMaximumTrackSkinTexture:Texture;
	private var seekSliderMinimumTrackSkinTexture:Texture;
	private var seekSliderMaximumTrackSkinTexture:Texture;
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
		
		FeathersControl.defaultTextRendererFactory = textRendererFactory;
		FeathersControl.defaultTextEditorFactory = textEditorFactory;
		
		PopUpManager.overlayFactory = popUpOverlayFactory;
		Callout.stagePadding = this.smallGutterSize;
		Toast.containerFactory = toastContainerFactory;
	}
	
	/**
	 * Initializes font sizes and formats.
	 */
	private function initializeFonts():Void
	{
		this.defaultFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.disabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.headingFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.headingDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.detailFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.detailDisabledFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.invertedFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, INVERTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.toastActionFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, PRIMARY_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.toastActionFontStyles.bold = true;
		this.toastActionActiveFontStyles = new TextFormat(FONT_NAME, this.smallFontSize, ACTIVE_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.toastActionActiveFontStyles.bold = true;
	}
	
	/**
	 * Initializes the textures by extracting them from the atlas and
	 * setting up any scaling grids that are needed.
	 */
	private function initializeTextures():Void
	{
		this.focusIndicatorSkinTexture = this.atlas.getTexture("focus-indicator-skin0000");
		this.toolTipBackgroundSkinTexture = this.atlas.getTexture("tool-tip-background-skin0000");
		this.calloutBackgroundSkinTexture = this.atlas.getTexture("callout-background-skin0000");
		this.calloutTopArrowSkinTexture = this.atlas.getTexture("callout-top-arrow-skin0000");
		this.calloutRightArrowSkinTexture = this.atlas.getTexture("callout-right-arrow-skin0000");
		this.calloutBottomArrowSkinTexture = this.atlas.getTexture("callout-bottom-arrow-skin0000");
		this.calloutLeftArrowSkinTexture = this.atlas.getTexture("callout-left-arrow-skin0000");
		this.dangerCalloutBackgroundSkinTexture = this.atlas.getTexture("danger-callout-background-skin0000");
		this.dangerCalloutTopArrowSkinTexture = this.atlas.getTexture("danger-callout-top-arrow-skin0000");
		this.dangerCalloutRightArrowSkinTexture = this.atlas.getTexture("danger-callout-right-arrow-skin0000");
		this.dangerCalloutBottomArrowSkinTexture = this.atlas.getTexture("danger-callout-bottom-arrow-skin0000");
		this.dangerCalloutLeftArrowSkinTexture = this.atlas.getTexture("danger-callout-left-arrow-skin0000");
		
		this.buttonUpSkinTexture = this.atlas.getTexture("button-up-skin0000");
		this.buttonHoverSkinTexture = this.atlas.getTexture("button-hover-skin0000");
		this.buttonDownSkinTexture = this.atlas.getTexture("button-down-skin0000");
		this.buttonDisabledSkinTexture = this.atlas.getTexture("button-disabled-skin0000");
		this.toggleButtonSelectedUpSkinTexture = this.atlas.getTexture("toggle-button-selected-up-skin0000");
		this.toggleButtonSelectedHoverSkinTexture = this.atlas.getTexture("toggle-button-selected-hover-skin0000");
		this.toggleButtonSelectedDownSkinTexture = this.atlas.getTexture("toggle-button-selected-down-skin0000");
		this.toggleButtonSelectedDisabledSkinTexture = this.atlas.getTexture("toggle-button-selected-disabled-skin0000");
		this.quietButtonHoverSkinTexture = this.atlas.getTexture("quiet-button-hover-skin0000");
		this.callToActionButtonUpSkinTexture = this.atlas.getTexture("call-to-action-button-up-skin0000");
		this.callToActionButtonHoverSkinTexture = this.atlas.getTexture("call-to-action-button-hover-skin0000");
		this.dangerButtonUpSkinTexture = this.atlas.getTexture("danger-button-up-skin0000");
		this.dangerButtonHoverSkinTexture = this.atlas.getTexture("danger-button-hover-skin0000");
		this.dangerButtonDownSkinTexture = this.atlas.getTexture("danger-button-down-skin0000");
		this.backButtonUpIconTexture = this.atlas.getTexture("back-button-up-icon0000");
		this.backButtonDisabledIconTexture = this.atlas.getTexture("back-button-disabled-icon0000");
		this.forwardButtonUpIconTexture = this.atlas.getTexture("forward-button-up-icon0000");
		this.forwardButtonDisabledIconTexture = this.atlas.getTexture("forward-button-disabled-icon0000");
		
		this.tabUpSkinTexture = this.atlas.getTexture("tab-up-skin0000");
		this.tabHoverSkinTexture = this.atlas.getTexture("tab-hover-skin0000");
		this.tabDownSkinTexture = this.atlas.getTexture("tab-down-skin0000");
		this.tabDisabledSkinTexture = this.atlas.getTexture("tab-disabled-skin0000");
		this.tabSelectedUpSkinTexture = this.atlas.getTexture("tab-selected-up-skin0000");
		this.tabSelectedDisabledSkinTexture = this.atlas.getTexture("tab-selected-disabled-skin0000");
		
		this.stepperIncrementButtonUpSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-up-skin0000");
		this.stepperIncrementButtonHoverSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-hover-skin0000");
		this.stepperIncrementButtonDownSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-down-skin0000");
		this.stepperIncrementButtonDisabledSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-disabled-skin0000");
		
		this.stepperDecrementButtonUpSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-up-skin0000");
		this.stepperDecrementButtonHoverSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-hover-skin0000");
		this.stepperDecrementButtonDownSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-down-skin0000");
		this.stepperDecrementButtonDisabledSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-disabled-skin0000");
		
		this.hSliderThumbUpSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-up-skin0000");
		this.hSliderThumbHoverSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-hover-skin0000");
		this.hSliderThumbDownSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-down-skin0000");
		this.hSliderThumbDisabledSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-disabled-skin0000");
		this.hSliderTrackEnabledSkinTexture = this.atlas.getTexture("horizontal-slider-track-enabled-skin0000");
		
		this.vSliderThumbUpSkinTexture = this.atlas.getTexture("vertical-slider-thumb-up-skin0000");
		this.vSliderThumbHoverSkinTexture = this.atlas.getTexture("vertical-slider-thumb-hover-skin0000");
		this.vSliderThumbDownSkinTexture = this.atlas.getTexture("vertical-slider-thumb-down-skin0000");
		this.vSliderThumbDisabledSkinTexture = this.atlas.getTexture("vertical-slider-thumb-disabled-skin0000");
		this.vSliderTrackEnabledSkinTexture = this.atlas.getTexture("vertical-slider-track-enabled-skin0000");
		
		this.itemRendererUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-up-skin0000"), ITEM_RENDERER_SKIN_TEXTURE_REGION);
		//this.itemRendererHoverSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-hover-skin0000"), ITEM_RENDERER_SKIN_TEXTURE_REGION);
		this.itemRendererSelectedUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-selected-up-skin0000"), ITEM_RENDERER_SKIN_TEXTURE_REGION);
		
		this.headerBackgroundSkinTexture = this.atlas.getTexture("header-background-skin0000");
		this.groupedListHeaderBackgroundSkinTexture = this.atlas.getTexture("grouped-list-header-background-skin0000");
		
		this.checkUpIconTexture = this.atlas.getTexture("check-up-icon0000");
		this.checkHoverIconTexture = this.atlas.getTexture("check-hover-icon0000");
		this.checkDownIconTexture = this.atlas.getTexture("check-down-icon0000");
		this.checkDisabledIconTexture = this.atlas.getTexture("check-disabled-icon0000");
		this.checkSelectedUpIconTexture = this.atlas.getTexture("check-selected-up-icon0000");
		this.checkSelectedHoverIconTexture = this.atlas.getTexture("check-selected-hover-icon0000");
		this.checkSelectedDownIconTexture = this.atlas.getTexture("check-selected-down-icon0000");
		this.checkSelectedDisabledIconTexture = this.atlas.getTexture("check-selected-disabled-icon0000");
		
		this.radioUpIconTexture = this.atlas.getTexture("radio-up-icon0000");
		this.radioHoverIconTexture = this.atlas.getTexture("radio-hover-icon0000");
		this.radioDownIconTexture = this.atlas.getTexture("radio-down-icon0000");
		this.radioDisabledIconTexture = this.atlas.getTexture("radio-disabled-icon0000");
		this.radioSelectedUpIconTexture = this.atlas.getTexture("radio-selected-up-icon0000");
		this.radioSelectedHoverIconTexture = this.atlas.getTexture("radio-selected-hover-icon0000");
		this.radioSelectedDownIconTexture = this.atlas.getTexture("radio-selected-down-icon0000");
		this.radioSelectedDisabledIconTexture = this.atlas.getTexture("radio-selected-disabled-icon0000");
		
		this.pageIndicatorNormalSkinTexture = this.atlas.getTexture("page-indicator-normal-symbol0000");
		this.pageIndicatorSelectedSkinTexture = this.atlas.getTexture("page-indicator-selected-symbol0000");
		
		this.pickerListUpIconTexture = this.atlas.getTexture("picker-list-up-icon0000");
		this.pickerListHoverIconTexture = this.atlas.getTexture("picker-list-hover-icon0000");
		this.pickerListDownIconTexture = this.atlas.getTexture("picker-list-down-icon0000");
		this.pickerListDisabledIconTexture = this.atlas.getTexture("picker-list-disabled-icon0000");
		
		this.textInputBackgroundEnabledSkinTexture = this.atlas.getTexture("text-input-background-enabled-skin0000");
		this.textInputBackgroundDisabledSkinTexture = this.atlas.getTexture("text-input-background-disabled-skin0000");
		this.textInputBackgroundErrorSkinTexture = this.atlas.getTexture("text-input-background-error-skin0000");
		this.textInputSearchIconTexture = this.atlas.getTexture("search-icon0000");
		this.textInputSearchIconDisabledTexture = this.atlas.getTexture("search-icon-disabled0000");
		
		this.vScrollBarThumbUpSkinTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-up-skin0000");
		this.vScrollBarThumbHoverSkinTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-hover-skin0000");
		this.vScrollBarThumbDownSkinTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-down-skin0000");
		this.vScrollBarTrackSkinTexture = this.atlas.getTexture("vertical-scroll-bar-track-skin0000");
		this.vScrollBarThumbIconTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-icon0000");
		this.vScrollBarStepButtonUpSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-up-skin0000");
		this.vScrollBarStepButtonHoverSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-hover-skin0000");
		this.vScrollBarStepButtonDownSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-down-skin0000");
		this.vScrollBarStepButtonDisabledSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-disabled-skin0000");
		this.vScrollBarDecrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-icon0000");
		this.vScrollBarIncrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-icon0000");
		
		this.hScrollBarThumbUpSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-up-skin0000");
		this.hScrollBarThumbHoverSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-hover-skin0000");
		this.hScrollBarThumbDownSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-down-skin0000");
		this.hScrollBarTrackSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-track-skin0000");
		this.hScrollBarThumbIconTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-icon0000");
		this.hScrollBarStepButtonUpSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-up-skin0000");
		this.hScrollBarStepButtonHoverSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-hover-skin0000");
		this.hScrollBarStepButtonDownSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-down-skin0000");
		this.hScrollBarStepButtonDisabledSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-disabled-skin0000");
		this.hScrollBarDecrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-icon0000");
		this.hScrollBarIncrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-icon0000");
		
		this.simpleBorderBackgroundSkinTexture = this.atlas.getTexture("simple-border-background-skin0000");
		this.insetBorderBackgroundSkinTexture = this.atlas.getTexture("inset-border-background-skin0000");
		this.panelBorderBackgroundSkinTexture = this.atlas.getTexture("panel-background-skin0000");
		this.alertBorderBackgroundSkinTexture = this.atlas.getTexture("alert-background-skin0000");
		
		//this.progressBarFillSkinTexture = Texture.fromTexture(this.atlas.getTexture("progress-bar-fill-skin0000"), PROGRESS_BAR_FILL_TEXTURE_REGION);
		
		this.playPauseButtonPlayUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-play-up-icon0000");
		this.playPauseButtonPauseUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-pause-up-icon0000");
		this.overlayPlayPauseButtonPlayUpIconTexture = this.atlas.getTexture("overlay-play-pause-toggle-button-play-up-icon0000");
		this.fullScreenToggleButtonEnterUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-enter-up-icon0000");
		this.fullScreenToggleButtonExitUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-exit-up-icon0000");
		this.muteToggleButtonMutedUpIconTexture = this.atlas.getTexture("mute-toggle-button-muted-up-icon0000");
		this.muteToggleButtonLoudUpIconTexture = this.atlas.getTexture("mute-toggle-button-loud-up-icon0000");
		this.horizontalVolumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("horizontal-volume-slider-minimum-track-skin0000");
		this.horizontalVolumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("horizontal-volume-slider-maximum-track-skin0000");
		this.verticalVolumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("vertical-volume-slider-minimum-track-skin0000");
		this.verticalVolumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("vertical-volume-slider-maximum-track-skin0000");
		this.popUpVolumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("pop-up-volume-slider-minimum-track-skin0000");
		this.popUpVolumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("pop-up-volume-slider-maximum-track-skin0000");
		this.seekSliderMinimumTrackSkinTexture = this.atlas.getTexture("seek-slider-minimum-track-skin0000");
		this.seekSliderMaximumTrackSkinTexture = this.atlas.getTexture("seek-slider-maximum-track-skin0000");
		this.seekSliderProgressSkinTexture = this.atlas.getTexture("seek-slider-progress-skin0000");
		
		this.listDrillDownAccessoryTexture = this.atlas.getTexture("drill-down-icon0000");
		
		this.treeBranchOpenIconTexture = this.atlas.getTexture("tree-branch-open-icon0000");
		this.treeBranchClosedIconTexture = this.atlas.getTexture("tree-branch-closed-icon0000");
		this.treeLeafIconTexture = this.atlas.getTexture("tree-leaf-icon0000");
		this.treeDisclosureOpenIconTexture = this.atlas.getTexture("tree-disclosure-open-icon0000");
		this.treeDisclosureClosedIconTexture = this.atlas.getTexture("tree-disclosure-closed-icon0000");
		
		this.dataGridVerticalDividerSkinTexture = this.atlas.getTexture("data-grid-vertical-divider-skin0000");
		this.dataGridColumnDropIndicatorSkinTexture = this.atlas.getTexture("data-grid-column-drop-indicator-skin0000");
		this.dataGridColumnResizeSkinTexture = this.atlas.getTexture("data-grid-column-resize-skin0000");
		this.dataGridHeaderBackgroundSkinTexture = this.atlas.getTexture("data-grid-header-background-skin0000");
		this.dataGridHeaderDividerSkinTexture = this.atlas.getTexture("data-grid-header-divider-skin0000");
		this.dataGridHeaderSortAscendingIconTexture = this.atlas.getTexture("data-grid-header-sort-ascending-icon0000");
		this.dataGridHeaderSortDescendingIconTexture = this.atlas.getTexture("data-grid-header-sort-descending-icon0000");
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
		
		//autocomplete
		this.getStyleProviderForClass(AutoComplete).defaultStyleFunction = this.setTextInputStyles;
		this.getStyleProviderForClass(List).setFunctionForStyleName(AutoComplete.DEFAULT_CHILD_STYLE_NAME_LIST, this.setDropDownListStyles);
		
		//button
		this.getStyleProviderForClass(Button).defaultStyleFunction = this.setButtonStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_CALL_TO_ACTION_BUTTON, this.setCallToActionButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_DANGER_BUTTON, this.setDangerButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON, this.setBackButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_FORWARD_BUTTON, this.setForwardButtonStyles);
		
		//button group
		this.getStyleProviderForClass(ButtonGroup).defaultStyleFunction = this.setButtonGroupStyles;
		
		//callout
		this.getStyleProviderForClass(Callout).defaultStyleFunction = this.setCalloutStyles;
		
		//check
		this.getStyleProviderForClass(Check).defaultStyleFunction = this.setCheckStyles;
		
		//data grid
		this.getStyleProviderForClass(DataGrid).defaultStyleFunction = this.setDataGridStyles;
		this.getStyleProviderForClass(DefaultDataGridHeaderRenderer).defaultStyleFunction = this.setDataGridHeaderRendererStyles;
		this.getStyleProviderForClass(DefaultDataGridCellRenderer).defaultStyleFunction = this.setDataGridCellRendererStyles;
		
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
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER, this.setInsetGroupedListItemRendererStyles);
		this.getStyleProviderForClass(DefaultTreeItemRenderer).defaultStyleFunction = this.setTreeItemRendererStyles;
		
		//header and footer renderers for grouped list
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).defaultStyleFunction = this.setGroupedListHeaderOrFooterRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER, this.setInsetGroupedListHeaderRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER, this.setInsetGroupedListFooterRendererStyles);
		
		//label
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
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON, this.setNumericStepperIncrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON, this.setNumericStepperDecrementButtonStyles);
		
		//panel
		this.getStyleProviderForClass(Panel).defaultStyleFunction = this.setPanelStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Panel.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPanelHeaderStyles);
		
		//panel screen
		this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
		
		//page indicator
		this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;
		
		//picker list (see also: item renderers)
		this.getStyleProviderForClass(PickerList).defaultStyleFunction = this.setPickerListStyles;
		this.getStyleProviderForClass(List).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_LIST, this.setDropDownListStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
		
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
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON, this.setVerticalScrollBarIncrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON, this.setVerticalScrollBarDecrementButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_THUMB, this.setVerticalScrollBarThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MINIMUM_TRACK, this.setVerticalScrollBarMinimumTrackStyles);
		
		//scroll container
		this.getStyleProviderForClass(ScrollContainer).defaultStyleFunction = this.setScrollContainerStyles;
		this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName(ScrollContainer.ALTERNATE_STYLE_NAME_TOOLBAR, this.setToolbarScrollContainerStyles);
		
		//scroll screen
		this.getStyleProviderForClass(ScrollScreen).defaultStyleFunction = this.setScrollScreenStyles;
		
		//scroll text
		this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;
		
		//simple scroll bar
		this.getStyleProviderForClass(SimpleScrollBar).setFunctionForStyleName(Scroller.DEFAULT_CHILD_STYLE_NAME_HORIZONTAL_SCROLL_BAR, this.setHorizontalSimpleScrollBarStyles);
		this.getStyleProviderForClass(SimpleScrollBar).setFunctionForStyleName(Scroller.DEFAULT_CHILD_STYLE_NAME_VERTICAL_SCROLL_BAR, this.setVerticalSimpleScrollBarStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB, this.setHorizontalSimpleScrollBarThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB, this.setVerticalSimpleScrollBarThumbStyles);
		
		//slider
		this.getStyleProviderForClass(Slider).defaultStyleFunction = this.setSliderStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_THUMB, this.setHorizontalSliderThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK, this.setHorizontalSliderMinimumTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_THUMB, this.setVerticalSliderThumbStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK, this.setVerticalSliderMinimumTrackStyles);
		
		//spinner list
		this.getStyleProviderForClass(SpinnerList).defaultStyleFunction = this.setSpinnerListStyles;
		
		//tab bar
		this.getStyleProviderForClass(TabBar).defaultStyleFunction = this.setTabBarStyles;
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(TabBar.DEFAULT_CHILD_STYLE_NAME_TAB, this.setTabStyles);
		
		//text area
		this.getStyleProviderForClass(TextArea).defaultStyleFunction = this.setTextAreaStyles;
		this.getStyleProviderForClass(TextCallout).setFunctionForStyleName(TextArea.DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT, this.setTextAreaErrorCalloutStyles);
		
		//text callout
		this.getStyleProviderForClass(TextCallout).defaultStyleFunction = this.setTextCalloutStyles;
		
		//text input
		this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(TextInput.ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT, this.setSearchTextInputStyles);
		this.getStyleProviderForClass(TextCallout).setFunctionForStyleName(TextInput.DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT, this.setTextInputErrorCalloutStyles);
		
		//toast
		this.getStyleProviderForClass(Toast).defaultStyleFunction = this.setToastStyles;
		this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName(Toast.DEFAULT_CHILD_STYLE_NAME_ACTIONS, this.setToastActionsStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON, this.setToastActionsButtonStyles);
		
		//toggle button
		this.getStyleProviderForClass(ToggleButton).defaultStyleFunction = this.setButtonStyles;
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(Button.ALTERNATE_STYLE_NAME_QUIET_BUTTON, this.setQuietButtonStyles);
		
		//toggle switch
		this.getStyleProviderForClass(ToggleSwitch).defaultStyleFunction = this.setToggleSwitchStyles;
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_TRACK, this.setToggleSwitchOnTrackStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setToggleSwitchThumbStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setToggleSwitchThumbStyles);
		
		//tree
		this.getStyleProviderForClass(Tree).defaultStyleFunction = this.setTreeStyles;
		
		//media controls
		
		//play/pause toggle button
		//this.getStyleProviderForClass(PlayPauseToggleButton).defaultStyleFunction = this.setPlayPauseToggleButtonStyles;
		//this.getStyleProviderForClass(PlayPauseToggleButton).setFunctionForStyleName(PlayPauseToggleButton.ALTERNATE_STYLE_NAME_OVERLAY_PLAY_PAUSE_TOGGLE_BUTTON, this.setOverlayPlayPauseToggleButtonStyles);
		
		//full screen toggle button
		//this.getStyleProviderForClass(FullScreenToggleButton).defaultStyleFunction = this.setFullScreenToggleButtonStyles;
		
		//mute toggle button
		//this.getStyleProviderForClass(MuteToggleButton).defaultStyleFunction = this.setMuteToggleButtonStyles;
		//this.getStyleProviderForClass(VolumeSlider).setFunctionForStyleName(MuteToggleButton.DEFAULT_CHILD_STYLE_NAME_VOLUME_SLIDER, this.setPopUpVolumeSliderStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK, this.setPopUpVolumeSliderMinimumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MAXIMUM_TRACK, this.setPopUpVolumeSliderMaximumTrackStyles);
		
		//seek slider
		//this.getStyleProviderForClass(SeekSlider).defaultStyleFunction = this.setSeekSliderStyles;
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setHorizontalSliderThumbStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK, this.setSeekSliderMinimumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(SeekSlider.DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK, this.setSeekSliderMaximumTrackStyles);
		
		//volume slider
		//this.getStyleProviderForClass(VolumeSlider).defaultStyleFunction = this.setVolumeSliderStyles;
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(VolumeSlider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setVolumeSliderThumbStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MINIMUM_TRACK, this.setHorizontalVolumeSliderMinimumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MAXIMUM_TRACK, this.setHorizontalVolumeSliderMaximumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MINIMUM_TRACK, this.setVerticalVolumeSliderMinimumTrackStyles);
		//this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MAXIMUM_TRACK, this.setVerticalVolumeSliderMaximumTrackStyles);
	}
	
	private function pageIndicatorNormalSymbolFactory():Image
	{
		return new Image(this.pageIndicatorNormalSkinTexture);
	}
	
	private function pageIndicatorSelectedSymbolFactory():Image
	{
		return new Image(this.pageIndicatorSelectedSkinTexture);
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
		scroller.clipContent = true;
		scroller.horizontalScrollBarFactory = scrollBarFactory;
		scroller.verticalScrollBarFactory = scrollBarFactory;
		scroller.interactionMode = ScrollInteractionMode.MOUSE;
		scroller.scrollBarDisplayMode = ScrollBarDisplayMode.FIXED;
		
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
		
		var backgroundSkin:Image = new Image(this.alertBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = PANEL_BORDER_SCALE_9_GRID;
		alert.backgroundSkin = backgroundSkin;
		
		alert.fontStyles = this.defaultFontStyles.clone();
		alert.disabledFontStyles = this.disabledFontStyles.clone();
		
		alert.outerPadding = this.borderSize;
		
		alert.paddingTop = this.smallGutterSize;
		alert.paddingBottom = this.smallGutterSize;
		alert.paddingRight = this.gutterSize;
		alert.paddingLeft = this.gutterSize;
		alert.gap = this.gutterSize;
		
		alert.maxWidth = this.popUpSize;
		alert.maxHeight = this.popUpSize;
	}
	
	private function setAlertButtonGroupStyles(group:ButtonGroup):Void
	{
		group.direction = Direction.HORIZONTAL;
		group.horizontalAlign = HorizontalAlign.CENTER;
		group.verticalAlign = VerticalAlign.JUSTIFY;
		group.distributeButtonSizes = false;
		group.gap = this.smallGutterSize;
		group.padding = this.smallGutterSize;
	}
	
	//-------------------------
	// Button
	//-------------------------
	
	private function setBaseButtonStyles(button:Button):Void
	{
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		button.focusIndicatorSkin = focusIndicatorSkin;
		button.focusPadding = -1;
		
		button.paddingTop = this.extraSmallGutterSize;
		button.paddingBottom = this.extraSmallGutterSize;
		button.paddingLeft = this.smallGutterSize;
		button.paddingRight = this.smallGutterSize;
		button.gap = this.smallGutterSize;
		button.minGap = this.smallGutterSize;
	}
	
	private function setButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.buttonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			skin.selectedTexture = this.toggleButtonSelectedUpSkinTexture;
			skin.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.toggleButtonSelectedHoverSkinTexture);
			skin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.toggleButtonSelectedDownSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
		}
		skin.scale9Grid = BUTTON_SCALE_9_GRID;
		skin.width = this.buttonMinWidth;
		skin.height = this.controlSize;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.defaultFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setQuietButtonStyles(button:Button):Void
	{
		var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		defaultSkin.alpha = 0;
		button.defaultSkin = defaultSkin;
		
		var otherSkin:ImageSkin = new ImageSkin(null);
		otherSkin.setTextureForState(ButtonState.HOVER, this.quietButtonHoverSkinTexture);
		otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		button.setSkinForState(ButtonState.HOVER, otherSkin);
		button.setSkinForState(ButtonState.DOWN, otherSkin);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			otherSkin.selectedTexture = this.toggleButtonSelectedUpSkinTexture;
			otherSkin.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.toggleButtonSelectedHoverSkinTexture);
			otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.toggleButtonSelectedDownSkinTexture);
			otherSkin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
			cast(button, ToggleButton).defaultSelectedSkin = otherSkin;
		}
		otherSkin.scale9Grid = BUTTON_SCALE_9_GRID;
		otherSkin.width = this.controlSize;
		otherSkin.height = this.controlSize;
		otherSkin.minWidth = this.controlSize;
		otherSkin.minHeight = this.controlSize;
		
		button.fontStyles = this.defaultFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setCallToActionButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.callToActionButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.callToActionButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.scale9Grid = BUTTON_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.defaultFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setDangerButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.dangerButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.dangerButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.dangerButtonDownSkinTexture);
		skin.scale9Grid = BUTTON_SCALE_9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.fontStyles = this.defaultFontStyles.clone();
		button.disabledFontStyles = this.disabledFontStyles.clone();
		
		this.setBaseButtonStyles(button);
	}
	
	private function setBackButtonStyles(button:Button):Void
	{
		this.setButtonStyles(button);
		
		var icon:ImageSkin = new ImageSkin(this.backButtonUpIconTexture);
		icon.disabledTexture = this.backButtonDisabledIconTexture;
		button.defaultIcon = icon;
		
		button.iconPosition = RelativePosition.LEFT_BASELINE;
	}
	
	private function setForwardButtonStyles(button:Button):Void
	{
		this.setButtonStyles(button);
		
		var icon:ImageSkin = new ImageSkin(this.forwardButtonUpIconTexture);
		icon.disabledTexture = this.forwardButtonDisabledIconTexture;
		button.defaultIcon = icon;
		
		button.iconPosition = RelativePosition.RIGHT_BASELINE;
	}
	
	//-------------------------
	// ButtonGroup
	//-------------------------
	
	private function setButtonGroupStyles(group:ButtonGroup):Void
	{
		group.gap = this.smallGutterSize;
	}
	
	//-------------------------
	// Callout
	//-------------------------
	
	private function setCalloutStyles(callout:Callout):Void
	{
		var backgroundSkin:Image = new Image(this.calloutBackgroundSkinTexture);
		backgroundSkin.scale9Grid = CALLOUT_SCALE_9_GRID;
		callout.backgroundSkin = backgroundSkin;
		
		var topArrowSkin:Image = new Image(this.calloutTopArrowSkinTexture);
		callout.topArrowSkin = topArrowSkin;
		callout.topArrowGap = this.calloutArrowOverlapGap;
		var rightArrowSkin:Image = new Image(this.calloutRightArrowSkinTexture);
		callout.rightArrowSkin = rightArrowSkin;
		callout.rightArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
		var bottomArrowSkin:Image = new Image(this.calloutBottomArrowSkinTexture);
		callout.bottomArrowSkin = bottomArrowSkin;
		callout.bottomArrowGap = this.calloutArrowOverlapGap - this.bottomDropShadowSize;
		var leftArrowSkin:Image = new Image(this.calloutLeftArrowSkinTexture);
		callout.leftArrowSkin = leftArrowSkin;
		callout.leftArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
		
		callout.paddingTop = this.smallGutterSize;
		callout.paddingBottom = this.smallGutterSize + this.bottomDropShadowSize;
		callout.paddingRight = this.gutterSize + this.leftAndRightDropShadowSize;
		callout.paddingLeft = this.gutterSize + this.leftAndRightDropShadowSize;
	}
	
	private function setDangerCalloutStyles(callout:Callout):Void
	{
		var backgroundSkin:Image = new Image(this.dangerCalloutBackgroundSkinTexture);
		backgroundSkin.scale9Grid = CALLOUT_SCALE_9_GRID;
		callout.backgroundSkin = backgroundSkin;
		
		var topArrowSkin:Image = new Image(this.dangerCalloutTopArrowSkinTexture);
		callout.topArrowSkin = topArrowSkin;
		callout.topArrowGap = this.calloutArrowOverlapGap;
		var rightArrowSkin:Image = new Image(this.dangerCalloutRightArrowSkinTexture);
		callout.rightArrowSkin = rightArrowSkin;
		callout.rightArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
		var bottomArrowSkin:Image = new Image(this.dangerCalloutBottomArrowSkinTexture);
		callout.bottomArrowSkin = bottomArrowSkin;
		callout.bottomArrowGap = this.calloutArrowOverlapGap - this.bottomDropShadowSize;
		var leftArrowSkin:Image = new Image(this.dangerCalloutLeftArrowSkinTexture);
		callout.leftArrowSkin = leftArrowSkin;
		callout.leftArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
		
		callout.paddingTop = this.smallGutterSize;
		callout.paddingBottom = this.smallGutterSize + this.bottomDropShadowSize;
		callout.paddingRight = this.gutterSize + this.leftAndRightDropShadowSize;
		callout.paddingLeft = this.gutterSize + this.leftAndRightDropShadowSize;
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
		icon.setTextureForState(ButtonState.HOVER, this.checkHoverIconTexture);
		icon.setTextureForState(ButtonState.DOWN, this.checkDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.checkDisabledIconTexture);
		icon.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.checkSelectedHoverIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.checkSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.checkSelectedDisabledIconTexture);
		check.defaultIcon = icon;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		check.focusIndicatorSkin = focusIndicatorSkin;
		check.focusPadding = -2;
		
		check.fontStyles = this.defaultFontStyles.clone();
		check.disabledFontStyles = this.disabledFontStyles.clone();
		
		check.horizontalAlign = HorizontalAlign.LEFT;
		check.verticalAlign = VerticalAlign.MIDDLE;
		
		check.gap = this.smallGutterSize;
	}
	
	//-------------------------
	// Data Grid
	//-------------------------
	
	private function setDataGridStyles(grid:DataGrid):Void
	{
		this.setScrollerStyles(grid);
		
		grid.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.simpleBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		grid.backgroundSkin = backgroundSkin;
		
		var headerBackgroundSkin:ImageSkin = new ImageSkin(this.dataGridHeaderBackgroundSkinTexture);
		headerBackgroundSkin.width = this.controlSize;
		headerBackgroundSkin.height = this.controlSize;
		grid.headerBackgroundSkin = headerBackgroundSkin;
		
		var columnResizeSkin:ImageSkin = new ImageSkin(this.dataGridColumnResizeSkinTexture);
		columnResizeSkin.scale9Grid = DATA_GRID_VERTICAL_DIVIDER_SCALE_9_GRID;
		grid.columnResizeSkin = columnResizeSkin;
		
		var columnDropIndicatorSkin:ImageSkin = new ImageSkin(this.dataGridColumnDropIndicatorSkinTexture);
		columnDropIndicatorSkin.scale9Grid = DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID;
		grid.columnDropIndicatorSkin = columnDropIndicatorSkin;
		grid.extendedColumnDropIndicator = true;
		
		var columnDragOverlaySkin:Quad = new Quad(1, 1, MODAL_OVERLAY_COLOR);
		columnDragOverlaySkin.alpha = MODAL_OVERLAY_ALPHA;
		grid.columnDragOverlaySkin = columnDragOverlaySkin;
		
		grid.verticalDividerFactory = this.dataGridVerticalDividerFactory;
		grid.headerDividerFactory = this.dataGridHeaderDividerFactory;
		
		grid.padding = this.borderSize;
	}
	
	private function setDataGridHeaderRendererStyles(headerRenderer:DefaultDataGridHeaderRenderer):Void
	{
		headerRenderer.sortAscendingIcon = new ImageSkin(this.dataGridHeaderSortAscendingIconTexture);
		headerRenderer.sortDescendingIcon = new ImageSkin(this.dataGridHeaderSortDescendingIconTexture);
		
		headerRenderer.fontStyles = this.defaultFontStyles.clone();
		headerRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		
		headerRenderer.paddingTop = this.extraSmallGutterSize;
		headerRenderer.paddingBottom = this.extraSmallGutterSize;
		headerRenderer.paddingLeft = this.smallGutterSize;
		headerRenderer.paddingRight = this.smallGutterSize;
	}
	
	private function setDataGridCellRendererStyles(cellRenderer:DefaultDataGridCellRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.itemRendererHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedUpSkinTexture);
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		cellRenderer.defaultSkin = skin;
		
		cellRenderer.fontStyles = this.defaultFontStyles.clone();
		cellRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		cellRenderer.iconLabelFontStyles = this.defaultFontStyles.clone();
		cellRenderer.iconLabelDisabledFontStyles = this.disabledFontStyles.clone();
		cellRenderer.accessoryLabelFontStyles = this.defaultFontStyles.clone();
		cellRenderer.accessoryLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
		cellRenderer.horizontalAlign = HorizontalAlign.LEFT;
		
		cellRenderer.iconPosition = RelativePosition.LEFT;
		cellRenderer.accessoryPosition = RelativePosition.RIGHT;
		
		cellRenderer.paddingTop = this.extraSmallGutterSize;
		cellRenderer.paddingBottom = this.extraSmallGutterSize;
		cellRenderer.paddingRight = this.smallGutterSize;
		cellRenderer.paddingLeft = this.smallGutterSize;
		cellRenderer.gap = this.extraSmallGutterSize;
		cellRenderer.minGap = this.extraSmallGutterSize;
		cellRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		cellRenderer.minAccessoryGap = this.smallGutterSize;
		
		cellRenderer.useStateDelayTimer = false;
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
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.simpleBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
		list.backgroundSkin = backgroundSkin;
		
		list.padding = this.borderSize;
	}
	
	//see List section for item renderer styles
	
	private function setGroupedListHeaderOrFooterRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.groupedListHeaderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
		backgroundSkin.height = this.controlSize;
		backgroundSkin.minWidth = this.controlSize;
		backgroundSkin.minHeight = this.controlSize;
		renderer.backgroundSkin = backgroundSkin;
		
		renderer.fontStyles = this.defaultFontStyles.clone();
		renderer.disabledFontStyles = this.disabledFontStyles.clone();
		
		renderer.paddingTop = this.extraSmallGutterSize;
		renderer.paddingBottom = this.extraSmallGutterSize;
		renderer.paddingRight = this.smallGutterSize;
		renderer.paddingLeft = this.smallGutterSize;
	}
	
	private function setInsetGroupedListStyles(list:GroupedList):Void
	{
		this.setScrollerStyles(list);
		
		list.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:Image = new Image(this.insetBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
		list.backgroundSkin = backgroundSkin;
		
		list.padding = this.borderSize;
		
		list.customItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER;
		list.customHeaderRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER;
		list.customFooterRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER;
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.useVirtualLayout = true;
		layout.paddingTop = this.gutterSize;
		layout.paddingBottom = this.gutterSize;
		layout.gap = 0;
		layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		layout.verticalAlign = VerticalAlign.TOP;
		list.layout = layout;
	}
	
	private function setInsetGroupedListItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.itemRendererHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedUpSkinTexture);
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.defaultFontStyles.clone();
		itemRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.iconLabelFontStyles = this.defaultFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.accessoryLabelFontStyles = this.defaultFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		
		itemRenderer.paddingTop = this.extraSmallGutterSize;
		itemRenderer.paddingBottom = this.extraSmallGutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.gap = this.extraSmallGutterSize;
		itemRenderer.minGap = this.extraSmallGutterSize;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
		
		itemRenderer.useStateDelayTimer = false;
	}
	
	private function setInsetGroupedListHeaderRendererStyles(headerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var skin:Quad = new Quad(this.controlSize, this.controlSize);
		skin.alpha = 0;
		headerRenderer.backgroundSkin = skin;
		
		headerRenderer.fontStyles = this.defaultFontStyles.clone();
		headerRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		
		headerRenderer.paddingTop = this.gutterSize;
		headerRenderer.paddingBottom = this.smallGutterSize;
		headerRenderer.paddingRight = this.gutterSize;
		headerRenderer.paddingLeft = this.gutterSize;
	}
	
	private function setInsetGroupedListFooterRendererStyles(footerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var skin:Quad = new Quad(this.controlSize, this.controlSize);
		skin.alpha = 0;
		footerRenderer.backgroundSkin = skin;
		
		footerRenderer.fontStyles = this.defaultFontStyles.clone();
		footerRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		
		footerRenderer.paddingTop = this.smallGutterSize;
		footerRenderer.paddingBottom = this.smallGutterSize;
		footerRenderer.paddingRight = this.gutterSize;
		footerRenderer.paddingLeft = this.gutterSize;
	}
	
	//-------------------------
	// Header
	//-------------------------
	
	private function setHeaderStyles(header:Header):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		header.backgroundSkin = backgroundSkin;
		
		header.fontStyles = this.defaultFontStyles.clone();
		header.disabledFontStyles = this.disabledFontStyles.clone();
		
		header.paddingTop = this.extraSmallGutterSize;
		header.paddingBottom = this.extraSmallGutterSize + this.borderSize;
		header.paddingLeft = this.smallGutterSize;
		header.paddingRight = this.smallGutterSize;
		
		header.gap = this.extraSmallGutterSize;
		header.titleGap = this.gutterSize;
	}
	
	//-------------------------
	// Label
	//-------------------------
	
	private function setLabelStyles(label:Label):Void
	{
		label.fontStyles = this.defaultFontStyles.clone();
		label.disabledFontStyles = this.disabledFontStyles.clone();
	}

	private function setHeadingLabelStyles(label:Label):Void
	{
		label.fontStyles = this.headingFontStyles.clone();
		label.disabledFontStyles = this.headingDisabledFontStyles.clone();
	}
	
	private function setDetailLabelStyles(label:Label):Void
	{
		label.fontStyles = this.detailFontStyles.clone();
		label.disabledFontStyles = this.detailDisabledFontStyles.clone();
	}
	
	private function setToolTipLabelStyles(label:Label):Void
	{
		var backgroundSkin:Image = new Image(this.toolTipBackgroundSkinTexture);
		backgroundSkin.scale9Grid = TOOL_TIP_SCALE_9_GRID;
		label.backgroundSkin = backgroundSkin;
		
		label.fontStyles = this.defaultFontStyles.clone();
		label.disabledFontStyles = this.disabledFontStyles.clone();
		
		label.paddingTop = this.extraSmallGutterSize;
		label.paddingRight = this.smallGutterSize + this.leftAndRightDropShadowSize;
		label.paddingBottom = this.extraSmallGutterSize + this.bottomDropShadowSize;
		label.paddingLeft = this.smallGutterSize + this.leftAndRightDropShadowSize;
	}
	
	//-------------------------
	// LayoutGroup
	//-------------------------
	
	private function setToolbarLayoutGroupStyles(group:LayoutGroup):Void
	{
		if (group.layout == null)
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.paddingTop = this.extraSmallGutterSize;
			layout.paddingBottom = this.extraSmallGutterSize;
			layout.paddingRight = this.smallGutterSize;
			layout.paddingLeft = this.smallGutterSize;
			layout.gap = this.smallGutterSize;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			group.layout = layout;
		}
		
		group.minHeight = this.gridSize;
		
		var backgroundSkin:Image = new Image(this.headerBackgroundSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
		group.backgroundSkin = backgroundSkin;
	}
	
	//-------------------------
	// List
	//-------------------------
	
	private function setListStyles(list:List):Void
	{
		this.setScrollerStyles(list);
		
		list.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.simpleBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		list.backgroundSkin = backgroundSkin;
		
		var dropIndicatorSkin:Quad = new Quad(this.borderSize, this.borderSize, PRIMARY_TEXT_COLOR);
		list.dropIndicatorSkin = dropIndicatorSkin;
		
		list.padding = this.borderSize;
	}
	
	private function setItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.itemRendererHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedUpSkinTexture);
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.defaultFontStyles.clone();
		itemRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.iconLabelFontStyles = this.defaultFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.accessoryLabelFontStyles = this.defaultFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		
		itemRenderer.paddingTop = this.extraSmallGutterSize;
		itemRenderer.paddingBottom = this.extraSmallGutterSize;
		itemRenderer.paddingRight = this.smallGutterSize;
		itemRenderer.paddingLeft = this.smallGutterSize;
		itemRenderer.gap = this.extraSmallGutterSize;
		itemRenderer.minGap = this.extraSmallGutterSize;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
		
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
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.itemHasIcon = false;
		
		var icon:ImageSkin = new ImageSkin(this.checkUpIconTexture);
		icon.selectedTexture = this.checkSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.HOVER, this.checkHoverIconTexture);
		icon.setTextureForState(ButtonState.DOWN, this.checkDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.checkDisabledIconTexture);
		icon.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.checkSelectedHoverIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.checkSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.checkSelectedDisabledIconTexture);
		itemRenderer.defaultIcon = icon;
		
		itemRenderer.fontStyles = this.defaultFontStyles.clone();
		itemRenderer.disabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.iconLabelFontStyles = this.defaultFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.disabledFontStyles.clone();
		itemRenderer.accessoryLabelFontStyles = this.defaultFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		
		itemRenderer.paddingTop = this.extraSmallGutterSize;
		itemRenderer.paddingBottom = this.extraSmallGutterSize;
		itemRenderer.paddingRight = this.smallGutterSize;
		itemRenderer.paddingLeft = this.smallGutterSize;
		itemRenderer.gap = this.smallGutterSize;
		itemRenderer.minGap = this.smallGutterSize;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
		
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
		stepper.focusPadding = -1;
	}
	
	private function setNumericStepperIncrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.stepperIncrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.stepperIncrementButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.stepperIncrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.stepperIncrementButtonDisabledSkinTexture);
		skin.scale9Grid = STEPPER_INCREMENT_BUTTON_SCALE_9_GRID;
		button.defaultSkin = skin;
		button.keepDownStateOnRollOut = true;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setNumericStepperDecrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.stepperDecrementButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.stepperDecrementButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.stepperDecrementButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.stepperDecrementButtonDisabledSkinTexture);
		skin.scale9Grid = STEPPER_DECREMENT_BUTTON_SCALE_9_GRID;
		button.defaultSkin = skin;
		button.keepDownStateOnRollOut = true;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setNumericStepperTextInputStyles(input:TextInput):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledSkinTexture);
		backgroundSkin.disabledTexture = this.textInputBackgroundDisabledSkinTexture;
		backgroundSkin.scale9Grid = TEXT_INPUT_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		backgroundSkin.minWidth = this.controlSize;
		backgroundSkin.minHeight = this.controlSize;
		input.backgroundSkin = backgroundSkin;
		
		input.fontStyles = this.defaultFontStyles.clone();
		input.disabledFontStyles = this.disabledFontStyles.clone();
		
		input.gap = this.extraSmallGutterSize;
		input.paddingTop = this.extraSmallGutterSize;
		input.paddingBottom = this.extraSmallGutterSize;
		input.paddingRight = this.smallGutterSize;
		input.paddingLeft = this.smallGutterSize;
	}
	
	//-------------------------
	// PanelScreen
	//-------------------------
	
	private function setPanelScreenStyles(screen:PanelScreen):Void
	{
		this.setScrollerStyles(screen);
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
		
		var backgroundSkin:Image = new Image(this.panelBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = PANEL_BORDER_SCALE_9_GRID;
		panel.backgroundSkin = backgroundSkin;
		
		panel.paddingTop = 0;
		panel.paddingRight = this.gutterSize;
		panel.paddingBottom = this.gutterSize;
		panel.paddingLeft = this.gutterSize;
	}

	private function setPanelHeaderStyles(header:Header):Void
	{
		header.fontStyles = this.defaultFontStyles.clone();
		header.disabledFontStyles = this.disabledFontStyles.clone();
		
		header.minHeight = this.gridSize;
		
		header.paddingTop = this.extraSmallGutterSize;
		header.paddingBottom = this.extraSmallGutterSize;
		header.paddingLeft = this.gutterSize;
		header.paddingRight = this.gutterSize;
		header.gap = this.extraSmallGutterSize;
		header.titleGap = this.smallGutterSize;
	}
	
	//-------------------------
	// PickerList
	//-------------------------
	
	private function setPickerListStyles(list:PickerList):Void
	{
		list.popUpContentManager = new DropDownPopUpContentManager();
	}
	
	private function setPickerListButtonStyles(button:Button):Void
	{
		this.setButtonStyles(button);
		
		var icon:ImageSkin = new ImageSkin(this.pickerListUpIconTexture);
		icon.setTextureForState(ButtonState.HOVER, this.pickerListHoverIconTexture);
		icon.setTextureForState(ButtonState.DOWN, this.pickerListDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.pickerListDisabledIconTexture);
		button.defaultIcon = icon;
		
		button.gap = Math.POSITIVE_INFINITY; //fill as completely as possible
		button.minGap = this.smallGutterSize;
		button.horizontalAlign = HorizontalAlign.LEFT;
		button.iconPosition = RelativePosition.RIGHT;
		button.paddingRight = this.smallGutterSize;
	}
	
	//for the PickerList's pop-up list, see setDropDownListStyles()
	
	//-------------------------
	// ProgressBar
	//-------------------------
	
	private function setProgressBarStyles(progress:ProgressBar):Void
	{
		var backgroundSkin:Image = new Image(this.simpleBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
		if (progress.direction == Direction.VERTICAL)
		{
			backgroundSkin.height = this.wideControlSize;
		}
		else
		{
			backgroundSkin.width = this.wideControlSize;
		}
		progress.backgroundSkin = backgroundSkin;
		
		var fillSkin:Image = new Image(this.progressBarFillSkinTexture);
		if (progress.direction == Direction.VERTICAL)
		{
			fillSkin.height = 0;
		}
		else
		{
			fillSkin.width = 0;
		}
		progress.fillSkin = fillSkin;
		
		progress.padding = this.borderSize;
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
		icon.setTextureForState(ButtonState.HOVER, this.radioHoverIconTexture);
		icon.setTextureForState(ButtonState.DOWN, this.radioDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.radioDisabledIconTexture);
		icon.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.radioSelectedHoverIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.radioSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.radioSelectedDisabledIconTexture);
		radio.defaultIcon = icon;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		radio.focusIndicatorSkin = focusIndicatorSkin;
		radio.focusPadding = -2;
		
		radio.fontStyles = this.defaultFontStyles.clone();
		radio.disabledFontStyles = this.disabledFontStyles.clone();
		
		radio.horizontalAlign = HorizontalAlign.LEFT;
		radio.verticalAlign = VerticalAlign.MIDDLE;
		
		radio.gap = this.smallGutterSize;
	}
	
	//-------------------------
	// ScrollBar
	//-------------------------
	
	private function setHorizontalScrollBarStyles(scrollBar:ScrollBar):Void
	{
		scrollBar.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		scrollBar.customIncrementButtonStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON;
		scrollBar.customDecrementButtonStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON;
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_THUMB;
		scrollBar.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MINIMUM_TRACK;
	}
	
	private function setVerticalScrollBarStyles(scrollBar:ScrollBar):Void
	{
		scrollBar.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		scrollBar.customIncrementButtonStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON;
		scrollBar.customDecrementButtonStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON;
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_THUMB;
		scrollBar.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MINIMUM_TRACK;
	}
	
	private function setHorizontalScrollBarIncrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.hScrollBarStepButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.hScrollBarStepButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.hScrollBarStepButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.hScrollBarStepButtonDisabledSkinTexture);
		skin.scale9Grid = HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.hScrollBarIncrementButtonIconTexture);
		
		var incrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		incrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = incrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarDecrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(hScrollBarStepButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.hScrollBarStepButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.hScrollBarStepButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.hScrollBarStepButtonDisabledSkinTexture);
		skin.scale9Grid = HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.hScrollBarDecrementButtonIconTexture);
		
		var decrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		decrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = decrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.hScrollBarThumbUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.hScrollBarThumbHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.hScrollBarThumbDownSkinTexture);
		skin.scale9Grid = HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
		skin.minWidth = this.smallControlSize;
		thumb.defaultSkin = skin;
		
		thumb.defaultIcon = new Image(this.hScrollBarThumbIconTexture);
		thumb.verticalAlign = VerticalAlign.MIDDLE;
		thumb.paddingBottom = this.extraSmallGutterSize;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalScrollBarMinimumTrackStyles(track:Button):Void
	{
		var defaultSkin:Image = new Image(this.hScrollBarTrackSkinTexture);
		defaultSkin.scale9Grid = HORIZONTAL_SCROLL_BAR_TRACK_SCALE_9_GRID;
		track.defaultSkin = defaultSkin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarIncrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.vScrollBarStepButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.vScrollBarStepButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.vScrollBarStepButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.vScrollBarStepButtonDisabledSkinTexture);
		skin.scale9Grid = VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.vScrollBarIncrementButtonIconTexture);
		
		var incrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		incrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = incrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarDecrementButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.vScrollBarStepButtonUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.vScrollBarStepButtonHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.vScrollBarStepButtonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.vScrollBarStepButtonDisabledSkinTexture);
		skin.scale9Grid = VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
		button.defaultSkin = skin;
		
		button.defaultIcon = new Image(this.vScrollBarDecrementButtonIconTexture);
		
		var decrementButtonDisabledIcon:Quad = new Quad(1, 1, 0xff00ff);
		decrementButtonDisabledIcon.alpha = 0;
		button.disabledIcon = decrementButtonDisabledIcon;
		
		button.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.vScrollBarThumbUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.vScrollBarThumbHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.vScrollBarThumbDownSkinTexture);
		skin.scale9Grid = VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
		skin.minHeight = this.smallControlSize;
		thumb.defaultSkin = skin;
		
		thumb.defaultIcon = new Image(this.vScrollBarThumbIconTexture);
		thumb.horizontalAlign = HorizontalAlign.CENTER;
		thumb.paddingRight = this.extraSmallGutterSize;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalScrollBarMinimumTrackStyles(track:Button):Void
	{
		var defaultSkin:Image = new Image(this.vScrollBarTrackSkinTexture);
		defaultSkin.scale9Grid = VERTICAL_SCROLL_BAR_TRACK_SCALE_9_GRID;
		track.defaultSkin = defaultSkin;
		
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
			layout.paddingTop = this.extraSmallGutterSize;
			layout.paddingBottom = this.extraSmallGutterSize;
			layout.paddingRight = this.smallGutterSize;
			layout.paddingLeft = this.smallGutterSize;
			layout.gap = this.extraSmallGutterSize;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			container.layout = layout;
		}
		
		var backgroundSkin:Image = new Image(this.headerBackgroundSkinTexture);
		backgroundSkin.scale9Grid = HEADER_SCALE_9_GRID;
		container.backgroundSkin = backgroundSkin;
		
		container.minHeight = this.gridSize;
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
		
		text.fontStyles = this.defaultFontStyles.clone();
		text.disabledFontStyles = this.disabledFontStyles.clone();
		
		text.padding = this.gutterSize;
	}
	
	//-------------------------
	// SimpleScrollBar
	//-------------------------
	
	private function setHorizontalSimpleScrollBarStyles(scrollBar:SimpleScrollBar):Void
	{
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB;
	}
	
	private function setVerticalSimpleScrollBarStyles(scrollBar:SimpleScrollBar):Void
	{
		scrollBar.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB;
	}
	
	private function setHorizontalSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.hScrollBarThumbUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.hScrollBarThumbHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.hScrollBarThumbDownSkinTexture);
		skin.scale9Grid = HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
		thumb.defaultSkin = skin;
		
		thumb.defaultIcon = new Image(this.hScrollBarThumbIconTexture);
		thumb.verticalAlign = VerticalAlign.TOP;
		thumb.paddingTop = this.smallGutterSize;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.vScrollBarThumbUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.vScrollBarThumbHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.vScrollBarThumbDownSkinTexture);
		skin.scale9Grid = VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
		thumb.defaultSkin = skin;
		
		thumb.defaultIcon = new Image(this.vScrollBarThumbIconTexture);
		thumb.horizontalAlign = HorizontalAlign.LEFT;
		thumb.paddingLeft = this.smallGutterSize;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Slider
	//-------------------------
	
	private function setSliderStyles(slider:Slider):Void
	{
		slider.trackLayoutMode = TrackLayoutMode.SINGLE;
		slider.minimumPadding = slider.maximumPadding = -vSliderThumbUpSkinTexture.height / 2;
		
		if(slider.direction == Direction.VERTICAL)
		{
			slider.customThumbStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_THUMB;
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK;
			
			slider.focusPaddingLeft = slider.focusPaddingRight = -2;
			slider.focusPaddingTop = slider.focusPaddingBottom = -2 + slider.minimumPadding;
		}
		else //horizontal
		{
			slider.customThumbStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_THUMB;
			slider.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK;
			
			slider.focusPaddingTop = slider.focusPaddingBottom = -2;
			slider.focusPaddingLeft = slider.focusPaddingRight = -2 + slider.minimumPadding;
		}
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		slider.focusIndicatorSkin = focusIndicatorSkin;
	}
	
	private function setHorizontalSliderThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.hSliderThumbUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.hSliderThumbHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.hSliderThumbDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.hSliderThumbDisabledSkinTexture);
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setHorizontalSliderMinimumTrackStyles(track:Button):Void
	{
		var defaultSkin:Image = new Image(this.hSliderTrackEnabledSkinTexture);
		defaultSkin.scale9Grid = HORIZONTAL_SLIDER_TRACK_SCALE_9_GRID;
		defaultSkin.width = this.wideControlSize;
		track.defaultSkin = defaultSkin;
		
		track.minTouchHeight = this.controlSize;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderThumbStyles(thumb:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.vSliderThumbUpSkinTexture);
		skin.setTextureForState(ButtonState.HOVER, this.vSliderThumbHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.vSliderThumbDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.vSliderThumbDisabledSkinTexture);
		thumb.defaultSkin = skin;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMinimumTrackStyles(track:Button):Void
	{
		var defaultSkin:Image = new Image(this.vSliderTrackEnabledSkinTexture);
		defaultSkin.scale9Grid = VERTICAL_SLIDER_TRACK_SCALE_9_GRID;
		defaultSkin.height = this.wideControlSize;
		track.defaultSkin = defaultSkin;
		
		track.minTouchWidth = this.controlSize;
		
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
		skin.selectedTexture = this.tabSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.HOVER, this.tabHoverSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.tabDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.tabDisabledSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.tabSelectedDisabledSkinTexture);
		skin.scale9Grid = TAB_SCALE_9_GRID;
		skin.minWidth = this.buttonMinWidth;
		skin.minHeight = this.controlSize;
		tab.defaultSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		tab.focusIndicatorSkin = focusIndicatorSkin;
		
		tab.fontStyles = this.defaultFontStyles.clone();
		tab.disabledFontStyles = this.disabledFontStyles.clone();
		
		tab.paddingTop = this.extraSmallGutterSize;
		tab.paddingBottom = this.extraSmallGutterSize;
		tab.paddingLeft = this.smallGutterSize;
		tab.paddingRight = this.smallGutterSize;
		tab.gap = this.extraSmallGutterSize;
	}
	
	//-------------------------
	// TextArea
	//-------------------------
	
	private function setTextAreaStyles(textArea:TextArea):Void
	{
		this.setScrollerStyles(textArea);
		
		var skin:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledSkinTexture);
		skin.disabledTexture = this.textInputBackgroundDisabledSkinTexture;
		skin.setTextureForState(TextInputState.ERROR, this.textInputBackgroundErrorSkinTexture);
		skin.scale9Grid = TEXT_INPUT_SCALE_9_GRID;
		skin.width = this.wideControlSize * 2;
		skin.height = this.wideControlSize;
		textArea.backgroundSkin = skin;
		
		textArea.fontStyles = this.defaultFontStyles.clone();
		textArea.disabledFontStyles = this.disabledFontStyles.clone();
		
		textArea.promptFontStyles = this.defaultFontStyles.clone();
		textArea.promptDisabledFontStyles = this.disabledFontStyles.clone();
		
		textArea.focusPadding = -2;
		textArea.padding = this.borderSize;
		
		textArea.innerPaddingTop = this.extraSmallGutterSize;
		textArea.innerPaddingRight = this.smallGutterSize;
		textArea.innerPaddingBottom = this.extraSmallGutterSize;
		textArea.innerPaddingLeft = this.smallGutterSize;
	}
	
	private function setTextAreaErrorCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerTextCalloutStyles(callout);
		callout.verticalAlign = VerticalAlign.TOP;
		callout.horizontalAlign = HorizontalAlign.LEFT;
		callout.supportedPositions = [RelativePosition.RIGHT,
			RelativePosition.TOP, RelativePosition.BOTTOM, RelativePosition.LEFT];
	}
	
	//-------------------------
	// TextCallout
	//-------------------------
	
	private function setTextCalloutStyles(callout:TextCallout):Void
	{
		this.setCalloutStyles(callout);
		
		callout.fontStyles = this.defaultFontStyles.clone();
		callout.disabledFontStyles = this.disabledFontStyles.clone();
	}
	
	private function setDangerTextCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerCalloutStyles(callout);
		
		callout.fontStyles = this.invertedFontStyles.clone();
		callout.disabledFontStyles = this.disabledFontStyles.clone();
	}
	
	//-------------------------
	// TextInput
	//-------------------------
	
	private function setBaseTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledSkinTexture);
		skin.disabledTexture = this.textInputBackgroundDisabledSkinTexture;
		skin.setTextureForState(TextInputState.ERROR, this.textInputBackgroundErrorSkinTexture);
		skin.scale9Grid = TEXT_INPUT_SCALE_9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		input.focusIndicatorSkin = focusIndicatorSkin;
		input.focusPadding = -2;
		
		input.gap = this.extraSmallGutterSize;
		input.paddingTop = this.extraSmallGutterSize;
		input.paddingBottom = this.extraSmallGutterSize;
		input.paddingRight = this.smallGutterSize;
		input.paddingLeft = this.smallGutterSize;
	}
	
	private function setTextInputStyles(input:TextInput):Void
	{
		this.setBaseTextInputStyles(input);
		
		input.fontStyles = this.defaultFontStyles.clone();
		input.disabledFontStyles = this.disabledFontStyles.clone();
		
		input.promptFontStyles = this.defaultFontStyles.clone();
		input.promptDisabledFontStyles = this.disabledFontStyles.clone();
	}
	
	private function setSearchTextInputStyles(input:TextInput):Void
	{
		this.setBaseTextInputStyles(input);
		
		var icon:ImageSkin = new ImageSkin(this.textInputSearchIconTexture);
		icon.disabledTexture = this.textInputSearchIconDisabledTexture;
		input.defaultIcon = icon;
		
		input.fontStyles = this.defaultFontStyles.clone();
		input.disabledFontStyles = this.disabledFontStyles.clone();
		
		input.promptFontStyles = this.defaultFontStyles.clone();
		input.promptDisabledFontStyles = this.disabledFontStyles.clone();
	}
	
	private function setTextInputErrorCalloutStyles(callout:TextCallout):Void
	{
		this.setDangerTextCalloutStyles(callout);
		
		callout.verticalAlign = VerticalAlign.TOP;
		callout.horizontalAlign = HorizontalAlign.LEFT;
		callout.supportedPositions = [RelativePosition.RIGHT,
			RelativePosition.TOP, RelativePosition.BOTTOM, RelativePosition.LEFT];
	}
	
	//-------------------------
	// Toast
	//-------------------------
	
	private function setToastStyles(toast:Toast):Void
	{
		var backgroundSkin:Image = new Image(this.toolTipBackgroundSkinTexture);
		backgroundSkin.scale9Grid = TOOL_TIP_SCALE_9_GRID;
		toast.backgroundSkin = backgroundSkin;
		
		toast.fontStyles = this.defaultFontStyles.clone();
		toast.disabledFontStyles = this.disabledFontStyles.clone();
		
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
		button.fontStyles = this.toastActionFontStyles.clone();
		button.setFontStylesForState(ButtonState.DOWN, this.toastActionActiveFontStyles);
	}
	
	//-------------------------
	// ToggleSwitch
	//-------------------------
	
	private function setToggleSwitchStyles(toggle:ToggleSwitch):Void
	{
		toggle.onLabelFontStyles = this.defaultFontStyles.clone();
		toggle.onLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
		toggle.offLabelFontStyles = this.defaultFontStyles.clone();
		toggle.offLabelDisabledFontStyles = this.disabledFontStyles.clone();
		
		toggle.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		toggle.focusIndicatorSkin = focusIndicatorSkin;
		toggle.focusPadding = -1;
	}
	
	private function setToggleSwitchOnTrackStyles(track:Button):Void
	{
		var defaultSkin:Image = new Image(this.toggleButtonSelectedUpSkinTexture);
		defaultSkin.scale9Grid = BUTTON_SCALE_9_GRID;
		defaultSkin.width = 2 * this.controlSize + this.smallControlSize;
		track.defaultSkin = defaultSkin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setToggleSwitchThumbStyles(thumb:Button):Void
	{
		this.setButtonStyles(thumb);
		
		thumb.width = this.controlSize;
		thumb.height = this.controlSize;
		
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Tree
	//-------------------------
	
	private function setTreeStyles(tree:Tree):Void
	{
		this.setScrollerStyles(tree);
		
		tree.verticalScrollPolicy = ScrollPolicy.AUTO;
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.simpleBorderBackgroundSkinTexture);
		backgroundSkin.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		tree.backgroundSkin = backgroundSkin;
		
		tree.padding = this.borderSize;
	}
	
	private function setTreeItemRendererStyles(itemRenderer:DefaultTreeItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.indentation = this.gutterSize;
		
		itemRenderer.disclosureOpenIcon = new ImageSkin(this.treeDisclosureOpenIconTexture);
		itemRenderer.disclosureClosedIcon = new ImageSkin(this.treeDisclosureClosedIconTexture);
		itemRenderer.branchIcon = new ImageSkin(this.treeBranchClosedIconTexture);
		itemRenderer.branchOpenIcon = new ImageSkin(this.treeBranchOpenIconTexture);
		itemRenderer.leafIcon = new ImageSkin(this.treeLeafIconTexture);
	}
	
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
		//otherSkin.setTextureForState(ButtonState.HOVER, this.quietButtonHoverSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.toggleButtonSelectedHoverSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.toggleButtonSelectedDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
		//otherSkin.width = this.controlSize;
		//otherSkin.height = this.controlSize;
		//otherSkin.minWidth = this.controlSize;
		//otherSkin.minHeight = this.controlSize;
		//button.setSkinForState(ButtonState.HOVER, otherSkin);
		//button.setSkinForState(ButtonState.DOWN, otherSkin);
		//button.setSkinForState(ButtonState.HOVER_AND_SELECTED, otherSkin);
		//button.setSkinForState(ButtonState.DOWN_AND_SELECTED, otherSkin);
		//button.setSkinForState(ButtonState.DISABLED_AND_SELECTED, otherSkin);
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		//button.focusIndicatorSkin = focusIndicatorSkin;
		//button.focusPadding = -1;
		//
		//var icon:ImageSkin = new ImageSkin(this.playPauseButtonPlayUpIconTexture);
		//icon.selectedTexture = this.playPauseButtonPauseUpIconTexture;
		//button.defaultIcon = icon;
		//
		//button.hasLabelTextRenderer = false;
		//
		//button.paddingTop = this.extraSmallGutterSize;
		//button.paddingRight = this.smallGutterSize;
		//button.paddingBottom = this.extraSmallGutterSize;
		//button.paddingLeft = this.smallGutterSize;
		//button.gap = this.smallGutterSize;
	//}
	//
	//protected function setOverlayPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):void
	//{
		//var icon:ImageSkin = new ImageSkin(null);
		//icon.setTextureForState(ButtonState.UP, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.HOVER, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.DOWN, this.overlayPlayPauseButtonPlayUpIconTexture);
		//button.defaultIcon = icon;
		//
		//button.isFocusEnabled = false;
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
	
	//protected function setFullScreenToggleButtonStyles(button:FullScreenToggleButton):void
	//{
		//var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		//defaultSkin.alpha = 0;
		//button.defaultSkin = defaultSkin;
		//
		//var otherSkin:ImageSkin = new ImageSkin(null);
		//otherSkin.setTextureForState(ButtonState.HOVER, this.quietButtonHoverSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.toggleButtonSelectedHoverSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.toggleButtonSelectedDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
		//otherSkin.width = this.controlSize;
		//otherSkin.height = this.controlSize;
		//otherSkin.minWidth = this.controlSize;
		//otherSkin.minHeight = this.controlSize;
		//button.setSkinForState(ButtonState.HOVER, otherSkin);
		//button.setSkinForState(ButtonState.DOWN, otherSkin);
		//button.setSkinForState(ButtonState.HOVER_AND_SELECTED, otherSkin);
		//button.setSkinForState(ButtonState.DOWN_AND_SELECTED, otherSkin);
		//button.setSkinForState(ButtonState.DISABLED_AND_SELECTED, otherSkin);
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		//button.focusIndicatorSkin = focusIndicatorSkin;
		//button.focusPadding = -1;
		//
		//var icon:ImageSkin = new ImageSkin(this.fullScreenToggleButtonEnterUpIconTexture);
		//icon.selectedTexture = this.fullScreenToggleButtonExitUpIconTexture;
		//button.defaultIcon = icon;
		//
		//button.hasLabelTextRenderer = false;
		//
		//button.paddingTop = this.extraSmallGutterSize;
		//button.paddingRight = this.smallGutterSize;
		//button.paddingBottom = this.extraSmallGutterSize;
		//button.paddingLeft = this.smallGutterSize;
		//button.gap = this.smallGutterSize;
	//}
	
	//-------------------------
	// VolumeSlider
	//-------------------------
	
	//protected function setVolumeSliderStyles(slider:VolumeSlider):void
	//{
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		//slider.focusIndicatorSkin = focusIndicatorSkin;
		//slider.focusPadding = -1;
		//slider.showThumb = false;
		//if(slider.direction == Direction.VERTICAL)
		//{
			//slider.customMinimumTrackStyleName = THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MINIMUM_TRACK;
			//slider.customMaximumTrackStyleName = THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MAXIMUM_TRACK;
			//slider.width = this.verticalVolumeSliderMinimumTrackSkinTexture.width;
			//slider.height = this.verticalVolumeSliderMinimumTrackSkinTexture.height;
		//}
		//else //horizontal
		//{
			//slider.customMinimumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MINIMUM_TRACK;
			//slider.customMaximumTrackStyleName = THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MAXIMUM_TRACK;
			//slider.width = this.horizontalVolumeSliderMinimumTrackSkinTexture.width;
			//slider.height = this.horizontalVolumeSliderMinimumTrackSkinTexture.height;
		//}
	//}
	//
	//protected function setVolumeSliderThumbStyles(button:Button):void
	//{
		//var thumbSize:Number = 6;
		//button.defaultSkin = new Quad(thumbSize, thumbSize);
		//button.defaultSkin.width = 0;
		//button.defaultSkin.height = 0;
		//button.hasLabelTextRenderer = false;
	//}
	//
	//protected function setHorizontalVolumeSliderMinimumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.source = this.horizontalVolumeSliderMinimumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	//
	//protected function setHorizontalVolumeSliderMaximumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.horizontalAlign = HorizontalAlign.RIGHT;
		//defaultSkin.source = this.horizontalVolumeSliderMaximumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	//
	//protected function setVerticalVolumeSliderMinimumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.verticalAlign = VerticalAlign.BOTTOM;
		//defaultSkin.source = this.verticalVolumeSliderMinimumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	//
	//protected function setVerticalVolumeSliderMaximumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.source = this.verticalVolumeSliderMaximumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	
	//-------------------------
	// MuteToggleButton
	//-------------------------
	
	//private function setMuteToggleButtonStyles(button:MuteToggleButton):void
	//{
		//var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		//defaultSkin.alpha = 0;
		//button.defaultSkin = defaultSkin;
		//
		//var otherSkin:ImageSkin = new ImageSkin(null);
		//otherSkin.setTextureForState(ButtonState.HOVER, this.quietButtonHoverSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.HOVER_AND_SELECTED, this.toggleButtonSelectedHoverSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.toggleButtonSelectedDownSkinTexture);
		//otherSkin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.toggleButtonSelectedDisabledSkinTexture);
		//otherSkin.width = this.controlSize;
		//otherSkin.height = this.controlSize;
		//otherSkin.minWidth = this.controlSize;
		//otherSkin.minHeight = this.controlSize;
		//button.setSkinForState(ButtonState.HOVER, otherSkin);
		//button.setSkinForState(ButtonState.DOWN, otherSkin);
		//button.setSkinForState(ButtonState.HOVER_AND_SELECTED, otherSkin);
		//button.setSkinForState(ButtonState.DOWN_AND_SELECTED, otherSkin);
		//button.setSkinForState(ButtonState.DISABLED_AND_SELECTED, otherSkin);
		//
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		//button.focusIndicatorSkin = focusIndicatorSkin;
		//button.focusPadding = -1;
		//
		//var icon:ImageSkin = new ImageSkin(this.muteToggleButtonLoudUpIconTexture);
		//icon.selectedTexture = this.muteToggleButtonMutedUpIconTexture;
		//button.defaultIcon = icon;
		//
		//button.showVolumeSliderOnHover = true;
		//button.hasLabelTextRenderer = false;
		//
		//button.paddingTop = this.extraSmallGutterSize;
		//button.paddingRight = this.smallGutterSize;
		//button.paddingBottom = this.extraSmallGutterSize;
		//button.paddingLeft = this.smallGutterSize;
		//button.gap = this.smallGutterSize;
	//}
	//
	//protected function setPopUpVolumeSliderStyles(slider:VolumeSlider):void
	//{
		//slider.direction = Direction.VERTICAL;
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		//slider.showThumb = false;
		//var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		//focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		//slider.focusIndicatorSkin = focusIndicatorSkin;
		//slider.focusPadding = 4;
		//slider.width = this.popUpVolumeSliderMinimumTrackSkinTexture.width;
		//slider.height = this.popUpVolumeSliderMinimumTrackSkinTexture.height;
		//slider.minimumPadding = this.popUpVolumeSliderPaddingSize;
		//slider.maximumPadding = this.popUpVolumeSliderPaddingSize;
		//slider.customMinimumTrackStyleName = THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK;
		//slider.customMaximumTrackStyleName = THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MAXIMUM_TRACK;
	//}
	//
	//protected function setPopUpVolumeSliderMinimumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.verticalAlign = VerticalAlign.BOTTOM;
		//defaultSkin.source = this.popUpVolumeSliderMinimumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	//
	//protected function setPopUpVolumeSliderMaximumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageLoader = new ImageLoader();
		//defaultSkin.scaleContent = false;
		//defaultSkin.source = this.popUpVolumeSliderMaximumTrackSkinTexture;
		//track.defaultSkin = defaultSkin;
		//track.hasLabelTextRenderer = false;
	//}
	
	//-------------------------
	// SeekSlider
	//-------------------------
	
	//protected function setSeekSliderStyles(slider:SeekSlider):void
	//{
		//slider.direction = Direction.HORIZONTAL;
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		//
		//slider.minimumPadding = slider.maximumPadding = -this.vSliderThumbUpSkinTexture.height / 2;
		//
		//slider.focusPaddingTop = slider.focusPaddingBottom = -2;
		//slider.focusPaddingLeft = slider.focusPaddingRight = -2 + slider.minimumPadding;
		//
		//var progressSkin:Image = new Image(this.seekSliderProgressSkinTexture);
		//progressSkin.scale9Grid = SEEK_SLIDER_MAXIMUM_TRACK_SCALE_9_GRID;
		//progressSkin.width = this.smallControlSize;
		//slider.progressSkin = progressSkin;
	//}
	//
	//protected function setSeekSliderMinimumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageSkin = new ImageSkin(this.seekSliderMinimumTrackSkinTexture);
		//defaultSkin.scale9Grid = SEEK_SLIDER_MINIMUM_TRACK_SCALE_9_GRID;
		//defaultSkin.width = this.wideControlSize;
		//defaultSkin.minWidth = this.wideControlSize;
		//track.defaultSkin = defaultSkin;
		//
		//track.minTouchHeight = this.controlSize;
		//track.hasLabelTextRenderer = false;
	//}
	//
	//protected function setSeekSliderMaximumTrackStyles(track:Button):void
	//{
		//var defaultSkin:ImageSkin = new ImageSkin(this.seekSliderMaximumTrackSkinTexture);
		//defaultSkin.scale9Grid = SEEK_SLIDER_MAXIMUM_TRACK_SCALE_9_GRID;
		//defaultSkin.width = this.wideControlSize;
		//defaultSkin.minWidth = this.wideControlSize;
		//track.defaultSkin = defaultSkin;
		//
		//track.minTouchHeight = this.controlSize;
		//track.hasLabelTextRenderer = false;
	//}
}