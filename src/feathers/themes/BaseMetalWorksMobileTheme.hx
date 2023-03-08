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
import feathers.controls.Drawers;
import feathers.controls.GroupedList;
import feathers.controls.Header;
import feathers.controls.ImageLoader;
import feathers.controls.ItemRendererLayoutOrder;
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
import feathers.controls.popups.BottomDrawerPopUpContentManager;
import feathers.controls.popups.CalloutPopUpContentManager;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.text.ITextEditorViewPort;
import feathers.controls.text.TextFieldTextEditor;
import feathers.controls.text.TextFieldTextEditorViewPort;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.FeathersControl;
import feathers.core.FocusManager;
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
import starling.display.Stage;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * The base class for the "Metal Works" theme for mobile Feathers apps.
 * Handles everything except asset loading, which is left to subclasses.
 *
 * @see MetalWorksMobileTheme
 * @see MetalWorksMobileThemeWithAssetManager
 */
class BaseMetalWorksMobileTheme extends StyleNameFunctionTheme
{
	/**
	 * The name of the embedded font used by controls in this theme. Comes
	 * in normal and bold weights.
	 */
	public static inline var FONT_NAME:String = "SourceSansPro";

	/**
	 * The stack of fonts to use for controls that don't use embedded fonts.
	 */
	public static inline var FONT_NAME_STACK:String = "Source Sans Pro,Helvetica,_sans";
	
	private static inline var PRIMARY_BACKGROUND_COLOR:Int = 0x4a4137;
	private static inline var LIGHT_TEXT_COLOR:Int = 0xe5e5e5;
	private static inline var DARK_TEXT_COLOR:Int = 0x1a1816;
	private static inline var SELECTED_TEXT_COLOR:Int = 0xff9900;
	private static inline var LIGHT_DISABLED_TEXT_COLOR:Int = 0x8a8a8a;
	private static inline var DARK_DISABLED_TEXT_COLOR:Int = 0x383430;
	private static inline var LIST_BACKGROUND_COLOR:Int = 0x383430;
	private static inline var GROUPED_LIST_HEADER_BACKGROUND_COLOR:Int = 0x2e2a26;
	private static inline var GROUPED_LIST_FOOTER_BACKGROUND_COLOR:Int = 0x2e2a26;
	private static inline var MODAL_OVERLAY_COLOR:Int = 0x29241e;
	private static inline var MODAL_OVERLAY_ALPHA:Float = 0.8;
	private static inline var DRAWER_OVERLAY_COLOR:Int = 0x29241e;
	private static inline var DRAWER_OVERLAY_ALPHA:Float = 0.4;
	private static inline var VIDEO_OVERLAY_COLOR:Int = 0x1a1816;
	private static inline var VIDEO_OVERLAY_ALPHA:Float = 0.2;
	private static inline var DATA_GRID_COLUMN_OVERLAY_COLOR:Int = 0x383430;
	private static inline var DATA_GRID_COLUMN_OVERLAY_ALPHA:Float = 0.4;

	private static var DEFAULT_BACKGROUND_SCALE9_GRID:Rectangle = new Rectangle(4, 4, 1, 1);
	private static var BUTTON_SCALE9_GRID:Rectangle = new Rectangle(4, 4, 1, 20);
	private static var SMALL_BACKGROUND_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 1, 1);
	private static var BACK_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(13, 0, 1, 28);
	private static var FORWARD_BUTTON_SCALE9_GRID:Rectangle = new Rectangle(3, 0, 1, 28);
	private static var ITEM_RENDERER_SCALE9_GRID:Rectangle = new Rectangle(1, 1, 1, 42);
	private static var INSET_ITEM_RENDERER_MIDDLE_SCALE9_GRID:Rectangle = new Rectangle(2, 2, 1, 40);
	private static var INSET_ITEM_RENDERER_FIRST_SCALE9_GRID:Rectangle = new Rectangle(7, 7, 1, 35);
	private static var INSET_ITEM_RENDERER_LAST_SCALE9_GRID:Rectangle = new Rectangle(7, 2, 1, 35);
	private static var INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID:Rectangle = new Rectangle(7, 7, 1, 30);
	private static var TAB_SCALE9_GRID:Rectangle = new Rectangle(11, 11, 1, 22);
	private static var SPINNER_LIST_SELECTION_OVERLAY_SCALE9_GRID:Rectangle = new Rectangle(2, 6, 1, 32);
	private static var HORIZONTAL_SCROLL_BAR_THUMB_SCALE9_GRID:Rectangle = new Rectangle(4, 0, 4, 5);
	private static var VERTICAL_SCROLL_BAR_THUMB_SCALE9_GRID:Rectangle = new Rectangle(0, 4, 5, 4);
	private static var FOCUS_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(5, 5, 1, 1);
	private static var DATA_GRID_HEADER_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 2, 4);
	private static var DATA_GRID_VERTICAL_DIVIDER_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 1, 4);
	private static var DATA_GRID_COLUMN_RESIZE_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 3, 28);
	private static var DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(0, 1, 3, 28);

	private static var HEADER_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1, 1, 128, 64);
	private static var TAB_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1, 0, 22, 44);
	
	/**
	 * @private
	 * The theme's custom style name for item renderers in a SpinnerList.
	 */
	private static inline var THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER:String = "metal-works-mobile-spinner-list-item-renderer";

	/**
	 * @private
	 * The theme's custom style name for item renderers in a PickerList.
	 */
	private static inline var THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER:String = "metal-works-mobile-tablet-picker-list-item-renderer";

	/**
	 * @private
	 * The theme's custom style name for buttons in an Alert's button group.
	 */
	private static inline var THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON:String = "metal-works-mobile-alert-button-group-button";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a horizontal SimpleScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB:String = "metal-works-mobile-horizontal-simple-scroll-bar-thumb";

	/**
	 * @private
	 * The theme's custom style name for the thumb of a vertical SimpleScrollBar.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB:String = "metal-works-mobile-vertical-simple-scroll-bar-thumb";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a horizontal slider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK:String = "metal-works-mobile-horizontal-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the maximum track of a horizontal slider.
	 */
	private static inline var THEME_STYLE_NAME_HORIZONTAL_SLIDER_MAXIMUM_TRACK:String = "metal-works-mobile-horizontal-slider-maximum-track";

	/**
	 * @private
	 * The theme's custom style name for the minimum track of a vertical slider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK:String = "metal-works-mobile-vertical-slider-minimum-track";

	/**
	 * @private
	 * The theme's custom style name for the maximum track of a vertical slider.
	 */
	private static inline var THEME_STYLE_NAME_VERTICAL_SLIDER_MAXIMUM_TRACK:String = "metal-works-mobile-vertical-slider-maximum-track";

	/**
	 * @private
	 * The theme's custom style name for the item renderer of the DateTimeSpinner's SpinnerLists.
	 */
	private static inline var THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER:String = "metal-works-mobile-date-time-spinner-list-item-renderer";

	/**
	 * @private
	 * The theme's custom style name for the action buttons of a toast.
	 */
	private static inline var THEME_STYLE_NAME_TOAST_ACTIONS_BUTTON:String = "metal-works-mobile-toast-actions-button";
	
	/**
	 * The default global text renderer factory for this theme creates a
	 * TextBlockTextRenderer.
	 */
	private static function textRendererFactory():ITextRenderer
	{
		return new TextFieldTextRenderer();
	}
	
	/**
	 * The default global text editor factory for this theme creates a
	 * StageTextTextEditor.
	 */
	private static function textEditorFactory():ITextEditor
	{
		return new TextFieldTextEditor();
	}

	/**
	 * The text editor factory for a TextArea creates a
	 * TextFieldTextEditorViewPort.
	 */
	private static function textAreaTextEditorFactory():ITextEditorViewPort
	{
		return new TextFieldTextEditorViewPort();
	}
	
	/**
	 * The text editor factory for a NumericStepper creates a
	 * TextBlockTextEditor.
	 */
	private static function stepperTextEditorFactory():TextFieldTextEditor
	{
		//we're only using this text editor in the NumericStepper because
		//isEditable is false on the TextInput. this text editor is not
		//suitable for mobile use if the TextInput needs to be editable
		//because it can't use the soft keyboard or other mobile-friendly UI
		return new TextFieldTextEditor();
	}
	
	/**
	 * The pop-up factory for a PickerList creates a SpinnerList.
	 */
	private static function pickerListSpinnerListFactory():SpinnerList
	{
		return new SpinnerList();
	}
	
	/**
	 * This theme's scroll bar type is SimpleScrollBar.
	 */
	private static function scrollBarFactory():SimpleScrollBar
	{
		return new SimpleScrollBar();
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
	private var regularFontSize:Int = 12;

	/**
	 * A larger font size for headers.
	 */
	private var largeFontSize:Int = 14;

	/**
	 * An extra large font size.
	 */
	private var extraLargeFontSize:Int = 18;

	/**
	 * The size, in pixels, of major regions in the grid. Used for sizing
	 * containers and larger UI controls.
	 */
	private var gridSize:Int = 44;

	/**
	 * The size, in pixels, of minor regions in the grid. Used for larger
	 * padding and gaps.
	 */
	private var gutterSize:Int = 12;

	/**
	 * The size, in pixels, of smaller padding and gaps within the major
	 * regions in the grid.
	 */
	private var smallGutterSize:Int = 8;

	/**
	 * The size, in pixels, of smaller padding and gaps within controls.
	 */
	private var smallControlGutterSize:Int = 6;

	/**
	 * The width, in pixels, of UI controls that span across multiple grid regions.
	 */
	private var wideControlSize:Int = 156;

	/**
	 * The size, in pixels, of a typical UI control.
	 */
	private var controlSize:Int = 28;

	/**
	 * The size, in pixels, of smaller UI controls.
	 */
	private var smallControlSize:Int = 12;

	/**
	 * The size, in pixels, of borders;
	 */
	private var borderSize:Int = 1;

	private var popUpFillSize:Int = 276;
	private var calloutBackgroundMinSize:Int = 12;
	private var calloutArrowOverlapGap:Int = -2;
	private var scrollBarGutterSize:Int = 2;
	private var focusPaddingSize:Int = -1;
	private var tabFocusPaddingSize:Int = 4;
	
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
	 * The font styles for light, centered UI text.
	 */
	private var lightCenteredUIFontStyles:TextFormat;

	/**
	 * The font styles for light, centered, disabled UI text.
	 */
	private var lightCenteredDisabledUIFontStyles:TextFormat;

	/**
	 * The font styles for light disabled UI text.
	 */
	private var lightDisabledUIFontStyles:TextFormat;

	/**
	 * The font styles for dark, disabled UI text.
	 */
	private var darkDisabledUIFontStyles:TextFormat;

	/**
	 * The font styles for large, light UI text.
	 */
	private var largeLightUIFontStyles:TextFormat;

	/**
	 * The font styles for large, dark UI text.
	 */
	private var largeDarkUIFontStyles:TextFormat;

	/**
	 * The font styles for large, selected UI text.
	 */
	private var largeSelectedUIFontStyles:TextFormat;

	/**
	 * The font styles for large, light, disabled UI text.
	 */
	private var largeLightUIDisabledFontStyles:TextFormat;

	/**
	 * The font styles for large, dark, disabled UI text.
	 */
	private var largeDarkUIDisabledFontStyles:TextFormat;

	/**
	 * The font styles for extra-large, light UI text.
	 */
	private var xlargeLightUIFontStyles:TextFormat;

	/**
	 * The font styles for extra-large, light, disabled UI text.
	 */
	private var xlargeLightUIDisabledFontStyles:TextFormat;

	/**
	 * The font styles for standard-sized, light text for a text input.
	 */
	private var lightInputFontStyles:TextFormat;

	/**
	 * The font styles for standard-sized, light, disabled text for a text input.
	 */
	private var lightDisabledInputFontStyles:TextFormat;

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
	private var popUpHeaderBackgroundSkinTexture:Texture;
	private var backgroundSkinTexture:Texture;
	private var backgroundDisabledSkinTexture:Texture;
	private var backgroundInsetSkinTexture:Texture;
	private var backgroundInsetDisabledSkinTexture:Texture;
	private var backgroundInsetFocusedSkinTexture:Texture;
	private var backgroundInsetDangerSkinTexture:Texture;
	private var backgroundLightBorderSkinTexture:Texture;
	private var backgroundDarkBorderSkinTexture:Texture;
	private var backgroundDangerBorderSkinTexture:Texture;
	private var buttonUpSkinTexture:Texture;
	private var buttonDownSkinTexture:Texture;
	private var buttonDisabledSkinTexture:Texture;
	private var buttonSelectedUpSkinTexture:Texture;
	private var buttonSelectedDisabledSkinTexture:Texture;
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
	private var pickerListButtonSelectedIconTexture:Texture;
	private var pickerListButtonIconDisabledTexture:Texture;
	private var tabUpSkinTexture:Texture;
	private var tabDownSkinTexture:Texture;
	private var tabDisabledSkinTexture:Texture;
	private var tabSelectedUpSkinTexture:Texture;
	private var tabSelectedDisabledSkinTexture:Texture;
	private var pickerListItemSelectedIconTexture:Texture;
	private var spinnerListSelectionOverlaySkinTexture:Texture;
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
	private var itemRendererSelectedSkinTexture:Texture;
	private var insetItemRendererUpSkinTexture:Texture;
	private var insetItemRendererSelectedSkinTexture:Texture;
	private var insetItemRendererFirstUpSkinTexture:Texture;
	private var insetItemRendererFirstSelectedSkinTexture:Texture;
	private var insetItemRendererLastUpSkinTexture:Texture;
	private var insetItemRendererLastSelectedSkinTexture:Texture;
	private var insetItemRendererSingleUpSkinTexture:Texture;
	private var insetItemRendererSingleSelectedSkinTexture:Texture;
	private var calloutTopArrowSkinTexture:Texture;
	private var calloutRightArrowSkinTexture:Texture;
	private var calloutBottomArrowSkinTexture:Texture;
	private var calloutLeftArrowSkinTexture:Texture;
	private var dangerCalloutTopArrowSkinTexture:Texture;
	private var dangerCalloutRightArrowSkinTexture:Texture;
	private var dangerCalloutBottomArrowSkinTexture:Texture;
	private var dangerCalloutLeftArrowSkinTexture:Texture;
	private var verticalScrollBarThumbSkinTexture:Texture;
	private var horizontalScrollBarThumbSkinTexture:Texture;
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
	private var dragHandleIcon:Texture;
	
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
	private var seekSliderProgressSkinTexture:Texture;
	
	/**
	 * Disposes the atlas before calling super.dispose()
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
	}
	
	/**
	 * Initializes font sizes and formats.
	 */
	private function initializeFonts():Void
	{
		this.lightFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.darkFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightDisabledFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.selectedFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, SELECTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		
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
		this.lightCenteredDisabledUIFontStyles = new TextFormat(FONT_NAME, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.CENTER, VerticalAlign.TOP);
		this.lightCenteredDisabledUIFontStyles.bold = true;
		
		this.largeLightUIFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeLightUIFontStyles.bold = true;
		this.largeDarkUIFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DARK_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeDarkUIFontStyles.bold = true;
		this.largeSelectedUIFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, SELECTED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeSelectedUIFontStyles.bold = true;
		this.largeLightUIDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeLightUIDisabledFontStyles.bold = true;
		this.largeDarkUIDisabledFontStyles = new TextFormat(FONT_NAME, this.largeFontSize, DARK_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.largeDarkUIDisabledFontStyles.bold = true;
		
		this.xlargeLightUIFontStyles = new TextFormat(FONT_NAME, this.extraLargeFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.xlargeLightUIFontStyles.bold = true;
		this.xlargeLightUIDisabledFontStyles = new TextFormat(FONT_NAME, this.extraLargeFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.xlargeLightUIDisabledFontStyles.bold = true;
		
		this.lightInputFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightDisabledInputFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		
		this.lightScrollTextFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
		this.lightDisabledScrollTextFontStyles = new TextFormat(FONT_NAME_STACK, this.regularFontSize, LIGHT_DISABLED_TEXT_COLOR, HorizontalAlign.LEFT, VerticalAlign.TOP);
	}
	
	/**
	 * Initializes the textures by extracting them from the atlas and
	 * setting up any scaling grids that are needed.
	 */
	private function initializeTextures():Void
	{
		this.focusIndicatorSkinTexture = this.atlas.getTexture("focus-indicator-skin0000");
		
		this.backgroundSkinTexture = this.atlas.getTexture("background-skin0000");
		this.backgroundDisabledSkinTexture = this.atlas.getTexture("background-disabled-skin0000");
		this.backgroundInsetSkinTexture = this.atlas.getTexture("background-inset-skin0000");
		this.backgroundInsetDisabledSkinTexture = this.atlas.getTexture("background-inset-disabled-skin0000");
		this.backgroundInsetFocusedSkinTexture = this.atlas.getTexture("background-focused-skin0000");
		this.backgroundInsetDangerSkinTexture = this.atlas.getTexture("background-inset-danger-skin0000");
		this.backgroundLightBorderSkinTexture = this.atlas.getTexture("background-light-border-skin0000");
		this.backgroundDarkBorderSkinTexture = this.atlas.getTexture("background-dark-border-skin0000");
		this.backgroundDangerBorderSkinTexture = this.atlas.getTexture("background-danger-border-skin0000");
		
		this.buttonUpSkinTexture = this.atlas.getTexture("button-up-skin0000");
		this.buttonDownSkinTexture = this.atlas.getTexture("button-down-skin0000");
		this.buttonDisabledSkinTexture = this.atlas.getTexture("button-disabled-skin0000");
		this.buttonSelectedUpSkinTexture = this.atlas.getTexture("toggle-button-selected-up-skin0000");
		this.buttonSelectedDisabledSkinTexture = this.atlas.getTexture("toggle-button-selected-disabled-skin0000");
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
		
		this.tabUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("tab-up-skin0000"), TAB_SKIN_TEXTURE_REGION);
		this.tabDownSkinTexture = Texture.fromTexture(this.atlas.getTexture("tab-down-skin0000"), TAB_SKIN_TEXTURE_REGION);
		this.tabDisabledSkinTexture = Texture.fromTexture(this.atlas.getTexture("tab-disabled-skin0000"), TAB_SKIN_TEXTURE_REGION);
		this.tabSelectedUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("tab-selected-up-skin0000"), TAB_SKIN_TEXTURE_REGION);
		this.tabSelectedDisabledSkinTexture = Texture.fromTexture(this.atlas.getTexture("tab-selected-disabled-skin0000"), TAB_SKIN_TEXTURE_REGION);
		
		this.pickerListButtonIconTexture = this.atlas.getTexture("picker-list-button-icon0000");
		this.pickerListButtonSelectedIconTexture = this.atlas.getTexture("picker-list-button-selected-icon0000");
		this.pickerListButtonIconDisabledTexture = this.atlas.getTexture("picker-list-button-disabled-icon0000");
		this.pickerListItemSelectedIconTexture = this.atlas.getTexture("picker-list-item-renderer-selected-icon0000");
		
		this.spinnerListSelectionOverlaySkinTexture = this.atlas.getTexture("spinner-list-selection-overlay-skin0000");
		
		this.checkUpIconTexture = this.atlas.getTexture("check-up-icon0000");
		this.checkDownIconTexture = this.atlas.getTexture("check-down-icon0000");
		this.checkDisabledIconTexture = this.atlas.getTexture("check-disabled-icon0000");
		this.checkSelectedUpIconTexture = this.atlas.getTexture("check-selected-up-icon0000");
		this.checkSelectedDownIconTexture = this.atlas.getTexture("check-selected-down-icon0000");
		this.checkSelectedDisabledIconTexture = this.atlas.getTexture("check-selected-disabled-icon0000");
		
		this.radioUpIconTexture = this.checkUpIconTexture;
		this.radioDownIconTexture = this.checkDownIconTexture;
		this.radioDisabledIconTexture = this.checkDisabledIconTexture;
		this.radioSelectedUpIconTexture = this.atlas.getTexture("radio-selected-up-icon0000");
		this.radioSelectedDownIconTexture = this.atlas.getTexture("radio-selected-down-icon0000");
		this.radioSelectedDisabledIconTexture = this.atlas.getTexture("radio-selected-disabled-icon0000");
		
		this.pageIndicatorSelectedSkinTexture = this.atlas.getTexture("page-indicator-selected-symbol0000");
		this.pageIndicatorNormalSkinTexture = this.atlas.getTexture("page-indicator-symbol0000");
		
		this.searchIconTexture = this.atlas.getTexture("search-icon0000");
		this.searchIconDisabledTexture = this.atlas.getTexture("search-disabled-icon0000");
		
		this.itemRendererUpSkinTexture = this.atlas.getTexture("item-renderer-up-skin0000");
		this.itemRendererSelectedSkinTexture = this.atlas.getTexture("item-renderer-selected-up-skin0000");
		this.insetItemRendererUpSkinTexture = this.atlas.getTexture("inset-item-renderer-up-skin0000");
		this.insetItemRendererSelectedSkinTexture = this.atlas.getTexture("inset-item-renderer-selected-up-skin0000");
		this.insetItemRendererFirstUpSkinTexture = this.atlas.getTexture("first-inset-item-renderer-up-skin0000");
		this.insetItemRendererFirstSelectedSkinTexture = this.atlas.getTexture("first-inset-item-renderer-selected-up-skin0000");
		this.insetItemRendererLastUpSkinTexture = this.atlas.getTexture("last-inset-item-renderer-up-skin0000");
		this.insetItemRendererLastSelectedSkinTexture = this.atlas.getTexture("last-inset-item-renderer-selected-up-skin0000");
		this.insetItemRendererSingleUpSkinTexture = this.atlas.getTexture("single-inset-item-renderer-up-skin0000");
		this.insetItemRendererSingleSelectedSkinTexture = this.atlas.getTexture("single-inset-item-renderer-selected-up-skin0000");
		
		this.dragHandleIcon = this.atlas.getTexture("drag-handle-icon0000");
		
		var headerBackgroundSkinTexture:Texture = this.atlas.getTexture("header-background-skin0000");
		var popUpHeaderBackgroundSkinTexture:Texture = this.atlas.getTexture("header-popup-background-skin0000");
		this.headerBackgroundSkinTexture = Texture.fromTexture(headerBackgroundSkinTexture, HEADER_SKIN_TEXTURE_REGION);
		this.popUpHeaderBackgroundSkinTexture = Texture.fromTexture(popUpHeaderBackgroundSkinTexture, HEADER_SKIN_TEXTURE_REGION);
		
		this.calloutTopArrowSkinTexture = this.atlas.getTexture("callout-arrow-top-skin0000");
		this.calloutRightArrowSkinTexture = this.atlas.getTexture("callout-arrow-right-skin0000");
		this.calloutBottomArrowSkinTexture = this.atlas.getTexture("callout-arrow-bottom-skin0000");
		this.calloutLeftArrowSkinTexture = this.atlas.getTexture("callout-arrow-left-skin0000");
		this.dangerCalloutTopArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-top-skin0000");
		this.dangerCalloutRightArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-right-skin0000");
		this.dangerCalloutBottomArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-bottom-skin0000");
		this.dangerCalloutLeftArrowSkinTexture = this.atlas.getTexture("danger-callout-arrow-left-skin0000");
		
		this.horizontalScrollBarThumbSkinTexture = this.atlas.getTexture("horizontal-simple-scroll-bar-thumb-skin0000");
		this.verticalScrollBarThumbSkinTexture = this.atlas.getTexture("vertical-simple-scroll-bar-thumb-skin0000");
		
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
		this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_BUTTON_GROUP, this.setAlertButtonGroupStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON, this.setAlertButtonGroupButtonStyles);
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Alert.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPopUpHeaderStyles);
		
		//auto-complete
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
		//this.getStyleProviderForClass(DataGrid).defaultStyleFunction = this.setDataGridStyles;
		//this.getStyleProviderForClass(DefaultDataGridCellRenderer).defaultStyleFunction = this.setDataGridCellRendererStyles;
		//this.getStyleProviderForClass(DefaultDataGridHeaderRenderer).defaultStyleFunction = this.setDataGridHeaderStyles;
		
		//date time spinner
		//this.getStyleProviderForClass(DateTimeSpinner).defaultStyleFunction = this.setDateTimeSpinnerStyles;
		//this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER, this.setDateTimeSpinnerListItemRendererStyles);
		
		//drawers
		this.getStyleProviderForClass(Drawers).defaultStyleFunction = this.setDrawersStyles;
		
		//grouped list
		this.getStyleProviderForClass(GroupedList).defaultStyleFunction = this.setGroupedListStyles;
		this.getStyleProviderForClass(GroupedList).setFunctionForStyleName(GroupedList.ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST, this.setInsetGroupedListStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER, this.setInsetGroupedListMiddleItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FIRST_ITEM_RENDERER, this.setInsetGroupedListFirstItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_LAST_ITEM_RENDERER, this.setInsetGroupedListLastItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_SINGLE_ITEM_RENDERER, this.setInsetGroupedListSingleItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName(DefaultGroupedListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);
		
		//header
		this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;
		
		//header and footer renderers for grouped list
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).defaultStyleFunction = this.setGroupedListHeaderRendererStyles;
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.DEFAULT_CHILD_STYLE_NAME_FOOTER_RENDERER, this.setGroupedListFooterRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER, this.setInsetGroupedListHeaderRendererStyles);
		this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName(GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER, this.setInsetGroupedListFooterRendererStyles);
		
		//labels
		this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_HEADING, this.setHeadingLabelStyles);
		this.getStyleProviderForClass(Label).setFunctionForStyleName(Label.ALTERNATE_STYLE_NAME_DETAIL, this.setDetailLabelStyles);
		
		//layout group
		this.getStyleProviderForClass(LayoutGroup).setFunctionForStyleName(LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR, setToolbarLayoutGroupStyles);
		
		//list
		this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setListItemRendererStyles;
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_DRILL_DOWN, this.setDrillDownItemRendererStyles);
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(DefaultListItemRenderer.ALTERNATE_STYLE_NAME_CHECK, this.setCheckItemRendererStyles);
		
		//numeric stepper
		this.getStyleProviderForClass(NumericStepper).defaultStyleFunction = this.setNumericStepperStyles;
		this.getStyleProviderForClass(TextInput).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT, this.setNumericStepperTextInputStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON, this.setNumericStepperButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(NumericStepper.DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON, this.setNumericStepperButtonStyles);
		
		//page indicator
		this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;
		
		//panel
		this.getStyleProviderForClass(Panel).defaultStyleFunction = this.setPanelStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(Panel.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPopUpHeaderStyles);
		
		//panel screen
		this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
		this.getStyleProviderForClass(Header).setFunctionForStyleName(PanelScreen.DEFAULT_CHILD_STYLE_NAME_HEADER, this.setPanelScreenHeaderStyles);
		
		//picker list (see also: list and item renderers)
		this.getStyleProviderForClass(PickerList).defaultStyleFunction = this.setPickerListStyles;
		this.getStyleProviderForClass(List).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_LIST, this.setPickerListPopUpListStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(PickerList.DEFAULT_CHILD_STYLE_NAME_BUTTON, this.setPickerListButtonStyles);
		this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName(THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER, this.setPickerListItemRendererStyles);
		
		//progress bar
		this.getStyleProviderForClass(ProgressBar).defaultStyleFunction = this.setProgressBarStyles;
		
		//radio
		this.getStyleProviderForClass(Radio).defaultStyleFunction = this.setRadioStyles;
		
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
		this.getStyleProviderForClass(Button).setFunctionForStyleName(Slider.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
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
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
		this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_THUMB, this.setSimpleButtonStyles);
		this.getStyleProviderForClass(Button).setFunctionForStyleName(ToggleSwitch.DEFAULT_CHILD_STYLE_NAME_ON_TRACK, this.setToggleSwitchTrackStyles);
		//we don't need a style function for the off track in this theme
		//the toggle switch layout uses a single track
		
		//tree
		//this.getStyleProviderForClass(Tree).defaultStyleFunction = this.setTreeStyles;
		//this.getStyleProviderForClass(DefaultTreeItemRenderer).defaultStyleFunction = this.setTreeItemRendererStyles;
		
		//media controls
		
		//play/pause toggle button
		//this.getStyleProviderForClass(PlayPauseToggleButton).defaultStyleFunction = this.setPlayPauseToggleButtonStyles;
		//this.getStyleProviderForClass(PlayPauseToggleButton).setFunctionForStyleName(PlayPauseToggleButton.ALTERNATE_STYLE_NAME_OVERLAY_PLAY_PAUSE_TOGGLE_BUTTON, this.setOverlayPlayPauseToggleButtonStyles);
		
		//full screen toggle button
		//this.getStyleProviderForClass(FullScreenToggleButton).defaultStyleFunction = this.setFullScreenToggleButtonStyles;
		
		//mute toggle button
		//this.getStyleProviderForClass(MuteToggleButton).defaultStyleFunction = this.setMuteToggleButtonStyles;
		
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
		skin.minTouchWidth = this.controlSize;
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
		if (DeviceCapabilities.isPhone())
		{
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
			layout.padding = this.smallGutterSize;
			layout.gap = this.smallGutterSize;
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
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		scroller.focusIndicatorSkin = focusIndicatorSkin;
		scroller.focusPadding = 0;
		
		scroller.horizontalScrollBarFactory = scrollBarFactory;
		scroller.verticalScrollBarFactory = scrollBarFactory;
	}

	private function setSimpleButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		button.hasLabelTextRenderer = false;
		
		button.minTouchWidth = this.gridSize;
		button.minTouchHeight = this.gridSize;
	}
	
	private function setDropDownListStyles(list:List):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		backgroundSkin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
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
		
		var backgroundSkin:Image = new Image(this.backgroundLightBorderSkinTexture);
		backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
		alert.backgroundSkin = backgroundSkin;
		
		alert.fontStyles = this.lightFontStyles.clone();
		
		alert.paddingTop = this.gutterSize;
		alert.paddingRight = this.gutterSize;
		alert.paddingBottom = this.smallGutterSize;
		alert.paddingLeft = this.gutterSize;
		alert.outerPadding = this.borderSize;
		alert.gap = this.smallGutterSize;
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
		group.gap = this.smallGutterSize;
		group.padding = this.smallGutterSize;
		group.customButtonStyleName = THEME_STYLE_NAME_ALERT_BUTTON_GROUP_BUTTON;
	}
	
	private function setAlertButtonGroupButtonStyles(button:Button):Void
	{
		this.setButtonStyles(button);
		
		var skin:ImageSkin = cast button.defaultSkin;
		skin.minWidth = 2 * this.controlSize;
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
		
		button.paddingTop = this.smallControlGutterSize;
		button.paddingBottom = this.smallControlGutterSize;
		button.paddingLeft = this.gutterSize;
		button.paddingRight = this.gutterSize;
		button.gap = this.smallControlGutterSize;
		button.minGap = this.smallControlGutterSize;
		button.minTouchWidth = this.gridSize;
		button.minTouchHeight = this.gridSize;
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
			skin.selectedTexture = this.buttonSelectedUpSkinTexture;
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.buttonSelectedDisabledSkinTexture);
		}
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		button.defaultSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		button.focusIndicatorSkin = focusIndicatorSkin;
		button.focusPadding = this.focusPaddingSize;
		
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
		skin.minWidth = this.controlSize;
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
		otherSkin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		otherSkin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		button.downSkin = otherSkin;
		button.disabledSkin = otherSkin;
		var toggleButton:ToggleButton = null;
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			toggleButton = cast button;
			otherSkin.selectedTexture = this.buttonSelectedUpSkinTexture;
			toggleButton.defaultSelectedSkin = otherSkin;
		}
		otherSkin.scale9Grid = BUTTON_SCALE9_GRID;
		otherSkin.width = this.controlSize;
		otherSkin.height = this.controlSize;
		otherSkin.minWidth = this.controlSize;
		otherSkin.minHeight = this.controlSize;
		
		button.fontStyles = this.lightUIFontStyles.clone();
		button.setFontStylesForState(ButtonState.DOWN, this.darkUIFontStyles.clone());
		button.setFontStylesForState(ButtonState.DISABLED, this.lightDisabledUIFontStyles.clone());
		if (toggleButton != null)
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			toggleButton.selectedFontStyles = this.darkUIFontStyles.clone();
			toggleButton.setFontStylesForState(ButtonState.DISABLED_AND_SELECTED, this.darkDisabledUIFontStyles.clone());
		}
		
		button.paddingTop = this.smallControlGutterSize;
		button.paddingBottom = this.smallControlGutterSize;
		button.paddingLeft = this.smallGutterSize;
		button.paddingRight = this.smallGutterSize;
		button.gap = this.smallControlGutterSize;
		button.minGap = this.smallControlGutterSize;
		button.minTouchWidth = this.gridSize;
		button.minTouchHeight = this.gridSize;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		button.focusIndicatorSkin = focusIndicatorSkin;
		button.focusPadding = this.focusPaddingSize;
	}

	private function setDangerButtonStyles(button:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.buttonDangerUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDangerDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
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
		
		button.paddingLeft = this.gutterSize + this.smallGutterSize;
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
		var skin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.buttonDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.buttonDisabledSkinTexture);
		if (Std.isOfType(button, ToggleButton))
		{
			//for convenience, this function can style both a regular button
			//and a toggle button
			skin.selectedTexture = this.buttonSelectedUpSkinTexture;
			skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.buttonSelectedDisabledSkinTexture);
		}
		skin.scale9Grid = BUTTON_SCALE9_GRID;
		skin.width = this.popUpFillSize;
		skin.height = this.gridSize;
		skin.minWidth = this.gridSize;
		skin.minHeight = this.gridSize;
		button.defaultSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		button.focusIndicatorSkin = focusIndicatorSkin;
		button.focusPadding = this.focusPaddingSize;
		
		button.fontStyles = this.largeDarkUIFontStyles.clone();
		button.disabledFontStyles = this.largeDarkUIDisabledFontStyles.clone();
		
		button.paddingTop = this.smallGutterSize;
		button.paddingBottom = this.smallGutterSize;
		button.paddingLeft = this.gutterSize;
		button.paddingRight = this.gutterSize;
		button.gap = this.smallGutterSize;
		button.minGap = this.smallGutterSize;
		button.horizontalAlign = HorizontalAlign.CENTER;
		button.minTouchWidth = this.gridSize;
		button.minTouchHeight = this.gridSize;
	}
	
	//-------------------------
	// Callout
	//-------------------------
	
	private function setCalloutStyles(callout:Callout):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundLightBorderSkinTexture);
		backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
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
		
		callout.padding = this.smallGutterSize;
	}

	private function setDangerCalloutStyles(callout:Callout):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundDangerBorderSkinTexture);
		backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
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
		
		callout.padding = this.smallGutterSize;
	}
	
	//-------------------------
	// Check
	//-------------------------
	
	private function setCheckStyles(check:Check):Void
	{
		var skin:Quad = new Quad(this.controlSize, this.controlSize);
		skin.alpha = 0;
		check.defaultSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		check.focusIndicatorSkin = focusIndicatorSkin;
		check.focusPadding = this.focusPaddingSize;
		
		var icon:ImageSkin = new ImageSkin(this.checkUpIconTexture);
		icon.selectedTexture = this.checkSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.DOWN, this.checkDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.checkDisabledIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.checkSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.checkSelectedDisabledIconTexture);
		check.defaultIcon = icon;
		
		check.fontStyles = this.lightUIFontStyles.clone();
		check.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		check.horizontalAlign = HorizontalAlign.LEFT;
		check.gap = this.smallControlGutterSize;
		check.minGap = this.smallControlGutterSize;
		check.minTouchWidth = this.gridSize;
		check.minTouchHeight = this.gridSize;
	}
	
	//-------------------------
	// DataGrid
	//-------------------------
	
	//private function setDataGridStyles(grid:DataGrid):Void
	//{
		//this.setScrollerStyles(grid);
		//var backgroundSkin:Quad = new Quad(this.gridSize, this.gridSize, LIST_BACKGROUND_COLOR);
		//grid.backgroundSkin = backgroundSkin;
		//
		//var columnResizeSkin:ImageSkin = new ImageSkin(this.dataGridColumnResizeSkinTexture);
		//columnResizeSkin.scale9Grid = DATA_GRID_COLUMN_RESIZE_SCALE_9_GRID;
		//grid.columnResizeSkin = columnResizeSkin;
		//
		//var columnDropIndicatorSkin:ImageSkin = new ImageSkin(this.dataGridColumnDropIndicatorSkinTexture);
		//columnDropIndicatorSkin.scale9Grid = DATA_GRID_COLUMN_DROP_INDICATOR_SCALE_9_GRID;
		//grid.columnDropIndicatorSkin = columnDropIndicatorSkin;
		//grid.extendedColumnDropIndicator = true;
		//
		//var columnDragOverlaySkin:Quad = new Quad(1, 1, DATA_GRID_COLUMN_OVERLAY_COLOR);
		//columnDragOverlaySkin.alpha = DATA_GRID_COLUMN_OVERLAY_ALPHA;
		//grid.columnDragOverlaySkin = columnDragOverlaySkin;
		//
		//grid.headerDividerFactory = this.dataGridHeaderDividerFactory;
		//grid.verticalDividerFactory = this.dataGridVerticalDividerFactory;
	//}
	
	//private function setDataGridHeaderStyles(headerRenderer:DefaultDataGridHeaderRenderer):Void
	//{
		//headerRenderer.backgroundSkin = new Quad(1, 1, GROUPED_LIST_HEADER_BACKGROUND_COLOR);
		//
		//headerRenderer.sortAscendingIcon = new ImageSkin(this.dataGridHeaderSortAscendingIconTexture);
		//headerRenderer.sortDescendingIcon = new ImageSkin(this.dataGridHeaderSortDescendingIconTexture);
		//
		//headerRenderer.fontStyles = this.lightUIFontStyles;
		//headerRenderer.disabledFontStyles = this.lightDisabledUIFontStyles;
		//headerRenderer.padding = this.smallGutterSize;
	//}

	//private function setDataGridCellRendererStyles(cellRenderer:DefaultDataGridCellRenderer):Void
	//{
		//var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		//skin.selectedTexture = this.itemRendererSelectedSkinTexture;
		//skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
		//skin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
		//skin.width = this.gridSize;
		//skin.height = this.gridSize;
		//skin.minWidth = this.gridSize;
		//skin.minHeight = this.gridSize;
		//cellRenderer.defaultSkin = skin;
		//
		//cellRenderer.fontStyles = this.largeLightFontStyles.clone();
		//cellRenderer.disabledFontStyles = this.largeLightDisabledFontStyles.clone();
		//cellRenderer.selectedFontStyles = this.largeDarkFontStyles.clone();
		//cellRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles.clone());
		//
		//cellRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		//cellRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		//cellRenderer.iconLabelSelectedFontStyles = this.darkFontStyles.clone();
		//cellRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		//
		//cellRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		//cellRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		//cellRenderer.accessoryLabelSelectedFontStyles = this.darkFontStyles.clone();
		//cellRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		//
		//cellRenderer.horizontalAlign = HorizontalAlign.LEFT;
		//cellRenderer.paddingTop = this.smallGutterSize;
		//cellRenderer.paddingBottom = this.smallGutterSize;
		//cellRenderer.paddingLeft = this.gutterSize;
		//cellRenderer.paddingRight = this.gutterSize;
		//cellRenderer.gap = this.gutterSize;
		//cellRenderer.minGap = this.gutterSize;
		//cellRenderer.iconPosition = RelativePosition.LEFT;
		//cellRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		//cellRenderer.minAccessoryGap = this.gutterSize;
		//cellRenderer.accessoryPosition = RelativePosition.RIGHT;
		//cellRenderer.minTouchWidth = this.gridSize;
		//cellRenderer.minTouchHeight = this.gridSize;
	//}
	
	//-------------------------
	// DateTimeSpinner
	//-------------------------
	
	//private function setDateTimeSpinnerStyles(spinner:DateTimeSpinner):Void
	//{
		//spinner.customItemRendererStyleName = THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER;
	//}
	
	private function setDateTimeSpinnerListItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		this.setSpinnerListItemRendererStyles(itemRenderer);
		
		itemRenderer.accessoryPosition = RelativePosition.LEFT;
		itemRenderer.gap = this.smallGutterSize;
		itemRenderer.minGap = this.smallGutterSize;
		itemRenderer.accessoryGap = this.smallGutterSize;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
	}
	
	//-------------------------
	// Drawers
	//-------------------------
	
	private function setDrawersStyles(drawers:Drawers):Void
	{
		var overlaySkin:Quad = new Quad(10, 10, DRAWER_OVERLAY_COLOR);
		overlaySkin.alpha = DRAWER_OVERLAY_ALPHA;
		drawers.overlaySkin = overlaySkin;
		
		var topDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
		drawers.topDrawerDivider = topDrawerDivider;
		
		var rightDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
		drawers.rightDrawerDivider = rightDrawerDivider;
		
		var bottomDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
		drawers.bottomDrawerDivider = bottomDrawerDivider;
		
		var leftDrawerDivider:Quad = new Quad(this.borderSize, this.borderSize, DRAWER_OVERLAY_COLOR);
		drawers.leftDrawerDivider = leftDrawerDivider;
	}
	
	//-------------------------
	// GroupedList
	//-------------------------
	
	private function setGroupedListStyles(list:GroupedList):Void
	{
		this.setScrollerStyles(list);
		var backgroundSkin:Quad = new Quad(this.gridSize, this.gridSize, LIST_BACKGROUND_COLOR);
		list.backgroundSkin = backgroundSkin;
	}
	
	//see List section for item renderer styles
	
	private function setGroupedListHeaderRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		renderer.backgroundSkin = new Quad(1, 1, GROUPED_LIST_HEADER_BACKGROUND_COLOR);
		
		renderer.fontStyles = this.lightUIFontStyles.clone();
		renderer.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		renderer.horizontalAlign = HorizontalAlign.LEFT;
		renderer.paddingTop = this.smallGutterSize;
		renderer.paddingBottom = this.smallGutterSize;
		renderer.paddingLeft = this.smallGutterSize + this.gutterSize;
		renderer.paddingRight = this.gutterSize;
	}
	
	private function setGroupedListFooterRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		renderer.backgroundSkin = new Quad(1, 1, GROUPED_LIST_FOOTER_BACKGROUND_COLOR);
		
		renderer.fontStyles = this.lightFontStyles.clone();
		renderer.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		renderer.horizontalAlign = HorizontalAlign.CENTER;
		renderer.paddingTop = renderer.paddingBottom = this.smallGutterSize;
		renderer.paddingLeft = this.smallGutterSize + this.gutterSize;
		renderer.paddingRight = this.gutterSize;
	}
	
	private function setInsetGroupedListStyles(list:GroupedList):Void
	{
		list.customItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER;
		list.customFirstItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FIRST_ITEM_RENDERER;
		list.customLastItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_LAST_ITEM_RENDERER;
		list.customSingleItemRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_SINGLE_ITEM_RENDERER;
		list.customHeaderRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER;
		list.customFooterRendererStyleName = GroupedList.ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER;
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.useVirtualLayout = true;
		layout.padding = this.smallGutterSize;
		layout.gap = 0;
		layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		layout.verticalAlign = VerticalAlign.TOP;
		list.layout = layout;
	}
	
	private function setInsetGroupedListItemRendererStyles(itemRenderer:DefaultGroupedListItemRenderer, defaultSkinTexture:Texture, selectedAndDownSkinTexture:Texture, scale9Grid:Rectangle):Void
	{
		var skin:ImageSkin = new ImageSkin(defaultSkinTexture);
		skin.selectedTexture = selectedAndDownSkinTexture;
		skin.setTextureForState(ButtonState.DOWN, selectedAndDownSkinTexture);
		skin.scale9Grid = scale9Grid;
		skin.width = this.gridSize;
		skin.height = this.gridSize;
		skin.minWidth = this.gridSize;
		skin.minHeight = this.gridSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.largeLightFontStyles.clone();
		itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles.clone();
		itemRenderer.selectedFontStyles = this.largeDarkFontStyles.clone();
		itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles.clone());
		
		itemRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.iconLabelSelectedFontStyles = this.darkFontStyles.clone();
		itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.accessoryLabelSelectedFontStyles = this.darkFontStyles.clone();
		itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize + this.smallGutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.gap = this.gutterSize;
		itemRenderer.minGap = this.gutterSize;
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.gutterSize;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		itemRenderer.minTouchWidth = this.gridSize;
		itemRenderer.minTouchHeight = this.gridSize;
	}
	
	private function setInsetGroupedListMiddleItemRendererStyles(renderer:DefaultGroupedListItemRenderer):Void
	{
		this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererUpSkinTexture, this.insetItemRendererSelectedSkinTexture, INSET_ITEM_RENDERER_MIDDLE_SCALE9_GRID);
	}
	
	private function setInsetGroupedListFirstItemRendererStyles(renderer:DefaultGroupedListItemRenderer):Void
	{
		this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererFirstUpSkinTexture, this.insetItemRendererFirstSelectedSkinTexture, INSET_ITEM_RENDERER_FIRST_SCALE9_GRID);
	}
	
	private function setInsetGroupedListLastItemRendererStyles(renderer:DefaultGroupedListItemRenderer):Void
	{
		this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererLastUpSkinTexture, this.insetItemRendererLastSelectedSkinTexture, INSET_ITEM_RENDERER_LAST_SCALE9_GRID);
	}
	
	private function setInsetGroupedListSingleItemRendererStyles(renderer:DefaultGroupedListItemRenderer):Void
	{
		this.setInsetGroupedListItemRendererStyles(renderer, this.insetItemRendererSingleUpSkinTexture, this.insetItemRendererSingleSelectedSkinTexture, INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID);
	}
	
	private function setInsetGroupedListHeaderRendererStyles(headerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		defaultSkin.alpha = 0;
		headerRenderer.backgroundSkin = defaultSkin;
		
		headerRenderer.fontStyles = this.lightUIFontStyles.clone();
		headerRenderer.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		headerRenderer.horizontalAlign = HorizontalAlign.LEFT;
		headerRenderer.paddingTop = this.smallGutterSize;
		headerRenderer.paddingBottom = this.smallGutterSize;
		headerRenderer.paddingLeft = this.gutterSize + this.smallGutterSize;
		headerRenderer.paddingRight = this.gutterSize;
	}
	
	private function setInsetGroupedListFooterRendererStyles(footerRenderer:DefaultGroupedListHeaderOrFooterRenderer):Void
	{
		var defaultSkin:Quad = new Quad(this.controlSize, this.controlSize, 0xff00ff);
		defaultSkin.alpha = 0;
		footerRenderer.backgroundSkin = defaultSkin;
		
		footerRenderer.fontStyles = this.lightFontStyles.clone();
		footerRenderer.disabledFontStyles = this.lightDisabledFontStyles.clone();
		
		footerRenderer.horizontalAlign = HorizontalAlign.CENTER;
		footerRenderer.paddingTop = this.smallGutterSize;
		footerRenderer.paddingBottom = this.smallGutterSize;
		footerRenderer.paddingLeft = this.gutterSize + this.smallGutterSize;
		footerRenderer.paddingRight = this.gutterSize;
	}
	
	//-------------------------
	// Header
	//-------------------------
	
	private function setHeaderStyles(header:Header):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.headerBackgroundSkinTexture);
		backgroundSkin.tileGrid = new Rectangle();
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		header.backgroundSkin = backgroundSkin;
		
		header.fontStyles = this.xlargeLightUIFontStyles.clone();
		header.disabledFontStyles = this.xlargeLightUIDisabledFontStyles.clone();
		
		header.padding = this.smallGutterSize;
		header.gap = this.smallGutterSize;
		header.titleGap = this.smallGutterSize;
	}
	
	//-------------------------
	// Label
	//-------------------------
	
	private function setLabelStyles(label:Label):Void
	{
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
	
	//-------------------------
	// LayoutGroup
	//-------------------------
	
	private function setToolbarLayoutGroupStyles(group:LayoutGroup):Void
	{
		if (group.layout == null)
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.padding = this.smallGutterSize;
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
		
		var backgroundSkin:Quad = new Quad(this.gridSize, this.gridSize, LIST_BACKGROUND_COLOR);
		list.backgroundSkin = backgroundSkin;
		
		var dropIndicatorSkin:Quad = new Quad(this.borderSize, this.borderSize, LIGHT_TEXT_COLOR);
		list.dropIndicatorSkin = dropIndicatorSkin;
	}
	
	private function setListItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		var dragIcon:ImageSkin = new ImageSkin(this.dragHandleIcon);
		dragIcon.minTouchWidth = this.gridSize;
		dragIcon.minTouchHeight = this.gridSize;
		itemRenderer.dragIcon = dragIcon;
	}
	
	private function setItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.selectedTexture = this.itemRendererSelectedSkinTexture;
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
		skin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
		skin.width = this.gridSize;
		skin.height = this.gridSize;
		skin.minWidth = this.gridSize;
		skin.minHeight = this.gridSize;
		itemRenderer.defaultSkin = skin;
		
		itemRenderer.fontStyles = this.largeLightFontStyles.clone();
		itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles.clone();
		itemRenderer.selectedFontStyles = this.largeDarkFontStyles.clone();
		itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles.clone());
		
		itemRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.iconLabelSelectedFontStyles = this.darkFontStyles.clone();
		itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.accessoryLabelSelectedFontStyles = this.darkFontStyles.clone();
		itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.gap = this.gutterSize;
		itemRenderer.minGap = this.gutterSize;
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.gutterSize;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		itemRenderer.minTouchWidth = this.gridSize;
		itemRenderer.minTouchHeight = this.gridSize;
	}
	
	private function setDrillDownItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		this.setItemRendererStyles(itemRenderer);
		
		itemRenderer.itemHasAccessory = false;
		
		var accessorySkin:ImageSkin = new ImageSkin(this.listDrillDownAccessoryTexture);
		accessorySkin.selectedTexture = this.listDrillDownAccessorySelectedTexture;
		accessorySkin.setTextureForState(ButtonState.DOWN, this.listDrillDownAccessorySelectedTexture);
		itemRenderer.defaultAccessory = accessorySkin;
	}
	
	private function setCheckItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
		skin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
		skin.width = this.gridSize;
		skin.height = this.gridSize;
		skin.minWidth = this.gridSize;
		skin.minHeight = this.gridSize;
		itemRenderer.defaultSkin = skin;
		
		var defaultSelectedIcon:ImageLoader = new ImageLoader();
		defaultSelectedIcon.source = this.pickerListItemSelectedIconTexture;
		itemRenderer.defaultSelectedIcon = defaultSelectedIcon;
		defaultSelectedIcon.validate();
		
		var defaultIcon:Quad = new Quad(defaultSelectedIcon.width, defaultSelectedIcon.height, 0xff00ff);
		defaultIcon.alpha = 0;
		itemRenderer.defaultIcon = defaultIcon;
		
		itemRenderer.fontStyles = this.largeLightFontStyles.clone();
		itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles.clone();
		itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles.clone());
		
		itemRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.itemHasIcon = false;
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.gap = Math.POSITIVE_INFINITY;
		itemRenderer.minGap = this.gutterSize;
		itemRenderer.iconPosition = RelativePosition.RIGHT;
		itemRenderer.accessoryGap = this.smallGutterSize;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
		itemRenderer.accessoryPosition = RelativePosition.BOTTOM;
		itemRenderer.layoutOrder = ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON;
		itemRenderer.minTouchWidth = this.gridSize;
		itemRenderer.minTouchHeight = this.gridSize;
	}
	
	//-------------------------
	// NumericStepper
	//-------------------------
	
	private function setNumericStepperStyles(stepper:NumericStepper):Void
	{
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		stepper.focusIndicatorSkin = focusIndicatorSkin;
		stepper.focusPadding = this.focusPaddingSize;
		
		stepper.useLeftAndRightKeys = true;
		
		stepper.buttonLayoutMode = StepperButtonLayoutMode.SPLIT_HORIZONTAL;
		stepper.incrementButtonLabel = "+";
		stepper.decrementButtonLabel = "-";
	}
	
	private function setNumericStepperTextInputStyles(input:TextInput):Void
	{
		var backgroundSkin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		backgroundSkin.setTextureForState(TextInputState.DISABLED, this.backgroundDisabledSkinTexture);
		backgroundSkin.setTextureForState(TextInputState.FOCUSED, this.backgroundInsetFocusedSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		backgroundSkin.width = this.controlSize;
		backgroundSkin.height = this.controlSize;
		backgroundSkin.minWidth = this.controlSize;
		backgroundSkin.minHeight = this.controlSize;
		input.backgroundSkin = backgroundSkin;
		
		input.textEditorFactory = stepperTextEditorFactory;
		input.fontStyles = this.lightCenteredUIFontStyles.clone();
		input.disabledFontStyles = this.lightCenteredDisabledUIFontStyles.clone();
		
		input.minTouchWidth = this.gridSize;
		input.minTouchHeight = this.gridSize;
		input.gap = this.smallControlGutterSize;
		input.paddingTop = this.smallControlGutterSize;
		input.paddingRight = this.smallGutterSize;
		input.paddingBottom = this.smallControlGutterSize;
		input.paddingLeft = this.smallGutterSize;
		input.isEditable = false;
		input.isSelectable = false;
	}
	
	private function setNumericStepperButtonStyles(button:Button):Void
	{
		this.setButtonStyles(button);
		button.keepDownStateOnRollOut = true;
	}
	
	//-------------------------
	// PageIndicator
	//-------------------------
	
	private function setPageIndicatorStyles(pageIndicator:PageIndicator):Void
	{
		pageIndicator.normalSymbolFactory = this.pageIndicatorNormalSymbolFactory;
		pageIndicator.selectedSymbolFactory = this.pageIndicatorSelectedSymbolFactory;
		pageIndicator.gap = this.smallGutterSize;
		pageIndicator.padding = this.smallGutterSize;
		pageIndicator.minTouchWidth = this.smallControlSize * 2;
		pageIndicator.minTouchHeight = this.smallControlSize * 2;
	}
	
	//-------------------------
	// Panel
	//-------------------------

	private function setPanelStyles(panel:Panel):Void
	{
		this.setScrollerStyles(panel);
		
		var backgroundSkin:Image = new Image(this.backgroundLightBorderSkinTexture);
		backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
		panel.backgroundSkin = backgroundSkin;
		panel.padding = this.smallGutterSize;
		panel.outerPadding = this.borderSize;
	}
	
	private function setPopUpHeaderStyles(header:Header):Void
	{
		header.padding = this.smallGutterSize;
		header.gap = this.smallGutterSize;
		header.titleGap = this.smallGutterSize;
		
		header.fontStyles = this.xlargeLightUIFontStyles.clone();
		header.disabledFontStyles = this.xlargeLightUIDisabledFontStyles.clone();
		
		var backgroundSkin:ImageSkin = new ImageSkin(this.popUpHeaderBackgroundSkinTexture);
		backgroundSkin.tileGrid = new Rectangle();
		backgroundSkin.width = this.gridSize;
		backgroundSkin.height = this.gridSize;
		backgroundSkin.minWidth = this.gridSize;
		backgroundSkin.minHeight = this.gridSize;
		header.backgroundSkin = backgroundSkin;
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
			list.popUpContentManager = new BottomDrawerPopUpContentManager();
		}
		else //tablet or desktop
		{
			list.popUpContentManager = new CalloutPopUpContentManager();
			list.customItemRendererStyleName = THEME_STYLE_NAME_TABLET_PICKER_LIST_ITEM_RENDERER;
		}
	}
	
	private function setPickerListPopUpListStyles(list:List):Void
	{
		this.setDropDownListStyles(list);
	}
	
	private function setPickerListItemRendererStyles(itemRenderer:BaseDefaultItemRenderer):Void
	{
		var skin:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
		skin.setTextureForState(ButtonState.DOWN, this.itemRendererSelectedSkinTexture);
		skin.scale9Grid = ITEM_RENDERER_SCALE9_GRID;
		skin.width = this.popUpFillSize;
		skin.height = this.gridSize;
		skin.minWidth = this.popUpFillSize;
		skin.minHeight = this.gridSize;
		itemRenderer.defaultSkin = skin;
		
		var defaultSelectedIcon:ImageLoader = new ImageLoader();
		defaultSelectedIcon.source = this.pickerListItemSelectedIconTexture;
		itemRenderer.defaultSelectedIcon = defaultSelectedIcon;
		defaultSelectedIcon.validate();
		
		var defaultIcon:Quad = new Quad(defaultSelectedIcon.width, defaultSelectedIcon.height, 0xff00ff);
		defaultIcon.alpha = 0;
		itemRenderer.defaultIcon = defaultIcon;
		
		itemRenderer.fontStyles = this.largeLightFontStyles.clone();
		itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles.clone();
		itemRenderer.setFontStylesForState(ButtonState.DOWN, this.largeDarkFontStyles.clone());
		
		itemRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.setIconLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		itemRenderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, this.darkFontStyles.clone());
		
		itemRenderer.itemHasIcon = false;
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.gap = Math.POSITIVE_INFINITY;
		itemRenderer.minGap = this.gutterSize;
		itemRenderer.iconPosition = RelativePosition.RIGHT;
		itemRenderer.accessoryGap = this.smallGutterSize;
		itemRenderer.minAccessoryGap = this.smallGutterSize;
		itemRenderer.accessoryPosition = RelativePosition.BOTTOM;
		itemRenderer.layoutOrder = ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON;
		itemRenderer.minTouchWidth = this.gridSize;
		itemRenderer.minTouchHeight = this.gridSize;
	}
	
	private function setPickerListButtonStyles(button:Button):Void
	{
		this.setButtonStyles(button);
		
		var icon:ImageSkin = new ImageSkin(this.pickerListButtonIconTexture);
		icon.selectedTexture = this.pickerListButtonSelectedIconTexture;
		icon.setTextureForState(ButtonState.DISABLED, this.pickerListButtonIconDisabledTexture);
		button.defaultIcon = icon;
		
		button.gap = Math.POSITIVE_INFINITY;
		button.minGap = this.gutterSize;
		button.iconPosition = RelativePosition.RIGHT;
	}
	
	//-------------------------
	// ProgressBar
	//-------------------------
	
	private function setProgressBarStyles(progress:ProgressBar):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundSkinTexture);
		backgroundSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
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
		backgroundDisabledSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
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
		fillSkin.width = this.smallControlSize;
		fillSkin.height = this.smallControlSize;
		progress.fillSkin = fillSkin;
		
		var fillDisabledSkin:Image = new Image(this.buttonDisabledSkinTexture);
		fillDisabledSkin.scale9Grid = BUTTON_SCALE9_GRID;
		fillDisabledSkin.width = this.smallControlSize;
		fillDisabledSkin.height = this.smallControlSize;
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
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		radio.focusIndicatorSkin = focusIndicatorSkin;
		radio.focusPadding = this.focusPaddingSize;
		
		var icon:ImageSkin = new ImageSkin(this.radioUpIconTexture);
		icon.selectedTexture = this.radioSelectedUpIconTexture;
		icon.setTextureForState(ButtonState.DOWN, this.radioDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED, this.radioDisabledIconTexture);
		icon.setTextureForState(ButtonState.DOWN_AND_SELECTED, this.radioSelectedDownIconTexture);
		icon.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.radioSelectedDisabledIconTexture);
		radio.defaultIcon = icon;
		
		radio.fontStyles = this.lightUIFontStyles.clone();
		radio.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		
		radio.horizontalAlign = HorizontalAlign.LEFT;
		radio.gap = this.smallControlGutterSize;
		radio.minGap = this.smallControlGutterSize;
		radio.minTouchWidth = this.gridSize;
		radio.minTouchHeight = this.gridSize;
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
			layout.padding = this.smallGutterSize;
			layout.gap = this.smallGutterSize;
			layout.verticalAlign = VerticalAlign.MIDDLE;
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
		text.paddingRight = this.gutterSize + this.smallGutterSize;
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
		var defaultSkin:Image = new Image(this.horizontalScrollBarThumbSkinTexture);
		defaultSkin.scale9Grid = HORIZONTAL_SCROLL_BAR_THUMB_SCALE9_GRID;
		defaultSkin.width = this.gutterSize;
		thumb.defaultSkin = defaultSkin;
		thumb.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSimpleScrollBarThumbStyles(thumb:Button):Void
	{
		var defaultSkin:Image = new Image(this.verticalScrollBarThumbSkinTexture);
		defaultSkin.scale9Grid = VERTICAL_SCROLL_BAR_THUMB_SCALE9_GRID;
		defaultSkin.height = this.gutterSize;
		thumb.defaultSkin = defaultSkin;
		thumb.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Slider
	//-------------------------
	
	private function setSliderStyles(slider:Slider):Void
	{
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		slider.focusIndicatorSkin = focusIndicatorSkin;
		slider.focusPadding = this.focusPaddingSize;
		
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
	}
	
	private function setHorizontalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.wideControlSize;
		skin.minHeight = this.controlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}

	private function setHorizontalSliderMaximumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.minWidth = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minHeight = this.controlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMinimumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.wideControlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.wideControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	private function setVerticalSliderMaximumTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		skin.width = this.controlSize;
		skin.height = this.wideControlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.wideControlSize;
		track.defaultSkin = skin;
		
		track.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// SpinnerList
	//-------------------------
	
	private function setSpinnerListStyles(list:SpinnerList):Void
	{
		this.setScrollerStyles(list);
		
		var backgroundSkin:Image = new Image(this.backgroundDarkBorderSkinTexture);
		backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
		list.backgroundSkin = backgroundSkin;
		
		var selectionOverlaySkin:Image = new Image(this.spinnerListSelectionOverlaySkinTexture);
		selectionOverlaySkin.scale9Grid = SPINNER_LIST_SELECTION_OVERLAY_SCALE9_GRID;
		list.selectionOverlaySkin = selectionOverlaySkin;
		
		list.customItemRendererStyleName = THEME_STYLE_NAME_SPINNER_LIST_ITEM_RENDERER;
		
		list.paddingTop = this.borderSize;
		list.paddingBottom = this.borderSize;
	}

	private function setSpinnerListItemRendererStyles(itemRenderer:DefaultListItemRenderer):Void
	{
		var defaultSkin:Quad = new Quad(this.gridSize, this.gridSize, 0xff00ff);
		defaultSkin.alpha = 0;
		itemRenderer.defaultSkin = defaultSkin;
		
		itemRenderer.fontStyles = this.largeLightFontStyles.clone();
		itemRenderer.disabledFontStyles = this.largeLightDisabledFontStyles.clone();
		
		itemRenderer.iconLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.iconLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		itemRenderer.accessoryLabelFontStyles = this.lightFontStyles.clone();
		itemRenderer.accessoryLabelDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
		itemRenderer.paddingTop = this.smallGutterSize;
		itemRenderer.paddingBottom = this.smallGutterSize;
		itemRenderer.paddingLeft = this.gutterSize;
		itemRenderer.paddingRight = this.gutterSize;
		itemRenderer.gap = this.gutterSize;
		itemRenderer.minGap = this.gutterSize;
		itemRenderer.iconPosition = RelativePosition.LEFT;
		itemRenderer.accessoryGap = Math.POSITIVE_INFINITY;
		itemRenderer.minAccessoryGap = this.gutterSize;
		itemRenderer.accessoryPosition = RelativePosition.RIGHT;
		itemRenderer.minTouchWidth = this.gridSize;
		itemRenderer.minTouchHeight = this.gridSize;
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
		var skin:ImageSkin = new ImageSkin(this.tabUpSkinTexture);
		skin.selectedTexture = this.tabSelectedUpSkinTexture;
		skin.setTextureForState(ButtonState.DOWN, this.tabDownSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED, this.tabDisabledSkinTexture);
		skin.setTextureForState(ButtonState.DISABLED_AND_SELECTED, this.tabSelectedDisabledSkinTexture);
		skin.scale9Grid = TAB_SCALE9_GRID;
		skin.width = this.gridSize;
		skin.height = this.gridSize;
		skin.minWidth = this.gridSize;
		skin.minHeight = this.gridSize;
		tab.defaultSkin = skin;
		
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		tab.focusIndicatorSkin = focusIndicatorSkin;
		tab.focusPadding = this.tabFocusPaddingSize;
		
		tab.fontStyles = this.lightUIFontStyles.clone();
		tab.disabledFontStyles = this.lightDisabledUIFontStyles.clone();
		tab.selectedFontStyles = this.darkUIFontStyles.clone();
		
		tab.paddingTop = this.smallGutterSize;
		tab.paddingBottom = this.smallGutterSize;
		tab.paddingLeft = this.gutterSize;
		tab.paddingRight = this.gutterSize;
		tab.gap = this.smallGutterSize;
		tab.minGap = this.smallGutterSize;
		tab.minTouchWidth = this.gridSize;
		tab.minTouchHeight = this.gridSize;
	}
	
	//-------------------------
	// TextArea
	//-------------------------
	
	private function setTextAreaStyles(textArea:TextArea):Void
	{
		this.setScrollerStyles(textArea);
		
		var skin:ImageSkin = new ImageSkin(this.backgroundInsetSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.backgroundDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.backgroundInsetFocusedSkinTexture);
		skin.setTextureForState(TextInputState.ERROR, this.backgroundInsetDangerSkinTexture);
		skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.wideControlSize;
		textArea.backgroundSkin = skin;
		
		textArea.fontStyles = this.lightInputFontStyles.clone();
		textArea.disabledFontStyles = this.lightDisabledInputFontStyles.clone();
		
		textArea.promptFontStyles = this.lightFontStyles.clone();
		textArea.promptDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		textArea.textEditorFactory = textAreaTextEditorFactory;
		
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
	// Toast
	//-------------------------
	
	private function setToastStyles(toast:Toast):Void
	{
		var backgroundSkin:Image = new Image(this.backgroundLightBorderSkinTexture);
		backgroundSkin.scale9Grid = SMALL_BACKGROUND_SCALE9_GRID;
		toast.backgroundSkin = backgroundSkin;
		
		toast.fontStyles = this.lightFontStyles.clone();
		
		toast.width = this.popUpFillSize;
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
	// TextInput
	//-------------------------
	
	private function setBaseTextInputStyles(input:TextInput):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundInsetSkinTexture);
		skin.setTextureForState(TextInputState.DISABLED, this.backgroundInsetDisabledSkinTexture);
		skin.setTextureForState(TextInputState.FOCUSED, this.backgroundInsetFocusedSkinTexture);
		skin.setTextureForState(TextInputState.ERROR, this.backgroundInsetDangerSkinTexture);
		skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		skin.width = this.wideControlSize;
		skin.height = this.controlSize;
		skin.minWidth = this.controlSize;
		skin.minHeight = this.controlSize;
		input.backgroundSkin = skin;
		
		input.fontStyles = this.lightInputFontStyles.clone();
		input.disabledFontStyles = this.lightDisabledInputFontStyles.clone();
		
		input.promptFontStyles = this.lightFontStyles.clone();
		input.promptDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		input.minTouchWidth = this.gridSize;
		input.minTouchHeight = this.gridSize;
		input.gap = this.smallControlGutterSize;
		input.paddingTop = this.smallControlGutterSize;
		input.paddingRight = this.smallGutterSize;
		input.paddingBottom = this.smallControlGutterSize;
		input.paddingLeft = this.smallGutterSize;
		input.verticalAlign = VerticalAlign.MIDDLE;
	}
	
	private function setTextInputStyles(input:TextInput):Void
	{
		this.setBaseTextInputStyles(input);
	}
	
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
		
		input.fontStyles = this.lightInputFontStyles.clone();
		input.disabledFontStyles = this.lightDisabledInputFontStyles.clone();
		
		input.promptFontStyles = this.lightFontStyles.clone();
		input.promptDisabledFontStyles = this.lightDisabledFontStyles.clone();
		
		var icon:ImageSkin = new ImageSkin(this.searchIconTexture);
		icon.setTextureForState(TextInputState.DISABLED, this.searchIconDisabledTexture);
		input.defaultIcon = icon;
	}
	
	//-------------------------
	// ToggleSwitch
	//-------------------------

	private function setToggleSwitchStyles(toggle:ToggleSwitch):Void
	{
		var focusIndicatorSkin:Image = new Image(this.focusIndicatorSkinTexture);
		focusIndicatorSkin.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
		toggle.focusIndicatorSkin = focusIndicatorSkin;
		toggle.focusPadding = this.focusPaddingSize;
		
		toggle.trackLayoutMode = TrackLayoutMode.SINGLE;
		
		toggle.offLabelFontStyles = this.lightUIFontStyles.clone();
		toggle.offLabelDisabledFontStyles = this.lightDisabledUIFontStyles.clone();
		toggle.onLabelFontStyles = this.selectedUIFontStyles.clone();
		toggle.onLabelDisabledFontStyles = this.lightDisabledUIFontStyles.clone();
	}
	
	//see Shared section for thumb styles
	
	private function setToggleSwitchTrackStyles(track:Button):Void
	{
		var skin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		skin.disabledTexture = this.backgroundDisabledSkinTexture;
		skin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		skin.width = Math.fround(this.controlSize * 2.5);
		skin.height = this.controlSize;
		track.defaultSkin = skin;
		track.hasLabelTextRenderer = false;
	}
	
	//-------------------------
	// Tree
	//-------------------------
	
	//private function setTreeStyles(tree:Tree):Void
	//{
		//this.setScrollerStyles(tree);
		//var backgroundSkin:Quad = new Quad(this.gridSize, this.gridSize, LIST_BACKGROUND_COLOR);
		//tree.backgroundSkin = backgroundSkin;
	//}
	
	//private function setTreeItemRendererStyles(itemRenderer:DefaultTreeItemRenderer):Void
	//{
		//this.setItemRendererStyles(itemRenderer);
		//
		//itemRenderer.indentation = this.treeDisclosureOpenIconTexture.width;
		//
		//var disclosureOpenIcon:ImageSkin = new ImageSkin(this.treeDisclosureOpenIconTexture);
		//disclosureOpenIcon.selectedTexture = this.treeDisclosureOpenSelectedIconTexture;
		////make sure the hit area is large enough for touch screens
		//disclosureOpenIcon.minTouchWidth = this.gridSize;
		//disclosureOpenIcon.minTouchHeight = this.gridSize;
		//itemRenderer.disclosureOpenIcon = disclosureOpenIcon;
		//
		//var disclosureClosedIcon:ImageSkin = new ImageSkin(this.treeDisclosureClosedIconTexture);
		//disclosureClosedIcon.selectedTexture = this.treeDisclosureClosedSelectedIconTexture;
		//disclosureClosedIcon.minTouchWidth = this.gridSize;
		//disclosureClosedIcon.minTouchHeight = this.gridSize;
		//itemRenderer.disclosureClosedIcon = disclosureClosedIcon;
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
		//
		//button.minTouchWidth = this.gridSize;
		//button.minTouchHeight = this.gridSize;
	//}
	
	//private function setOverlayPlayPauseToggleButtonStyles(button:PlayPauseToggleButton):Void
	//{
		//var icon:ImageSkin = new ImageSkin(null);
		//icon.setTextureForState(ButtonState.UP, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.HOVER, this.overlayPlayPauseButtonPlayUpIconTexture);
		//icon.setTextureForState(ButtonState.DOWN, this.overlayPlayPauseButtonPlayDownIconTexture);
		//button.defaultIcon = icon;
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
		//
		//button.minTouchWidth = this.gridSize;
		//button.minTouchHeight = this.gridSize;
	//}
	
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
		//button.hasLabelTextRenderer = false;
		//button.showVolumeSliderOnHover = false;
		//
		//button.minTouchWidth = this.gridSize;
		//button.minTouchHeight = this.gridSize;
	//}
	
	//-------------------------
	// SeekSlider
	//-------------------------
	
	//private function setSeekSliderStyles(slider:SeekSlider):Void
	//{
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
		//slider.showThumb = false;
		//var progressSkin:Image = new Image(this.seekSliderProgressSkinTexture);
		//progressSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		//progressSkin.width = this.smallControlSize;
		//progressSkin.height = this.smallControlSize;
		//slider.progressSkin = progressSkin;
	//}
	
	private function setSeekSliderThumbStyles(thumb:Button):Void
	{
		var thumbSize:Float = 6;
		thumb.defaultSkin = new Quad(thumbSize, thumbSize);
		thumb.hasLabelTextRenderer = false;
		thumb.minTouchWidth = this.gridSize;
		thumb.minTouchHeight = this.gridSize;
	}
	
	private function setSeekSliderMinimumTrackStyles(track:Button):Void
	{
		var defaultSkin:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
		defaultSkin.scale9Grid = BUTTON_SCALE9_GRID;
		defaultSkin.width = this.wideControlSize;
		defaultSkin.height = this.smallControlSize;
		defaultSkin.minWidth = this.wideControlSize;
		defaultSkin.minHeight = this.smallControlSize;
		track.defaultSkin = defaultSkin;
		track.hasLabelTextRenderer = false;
		track.minTouchHeight = this.gridSize;
	}

	private function setSeekSliderMaximumTrackStyles(track:Button):Void
	{
		var defaultSkin:ImageSkin = new ImageSkin(this.backgroundSkinTexture);
		defaultSkin.scale9Grid = DEFAULT_BACKGROUND_SCALE9_GRID;
		defaultSkin.width = this.wideControlSize;
		defaultSkin.height = this.smallControlSize;
		defaultSkin.minHeight = this.smallControlSize;
		track.defaultSkin = defaultSkin;
		track.hasLabelTextRenderer = false;
		track.minTouchHeight = this.gridSize;
	}
	
	//-------------------------
	// VolumeSlider
	//-------------------------
	
	//private function setVolumeSliderStyles(slider:VolumeSlider):Void
	//{
		//slider.direction = Direction.HORIZONTAL;
		//slider.trackLayoutMode = TrackLayoutMode.SPLIT;
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
		track.minTouchHeight = this.gridSize;
	}

	private function setVolumeSliderMaximumTrackStyles(track:Button):Void
	{
		var defaultSkin:ImageLoader = new ImageLoader();
		defaultSkin.scaleContent = false;
		defaultSkin.horizontalAlign = HorizontalAlign.RIGHT;
		defaultSkin.source = this.volumeSliderMaximumTrackSkinTexture;
		track.defaultSkin = defaultSkin;
		track.hasLabelTextRenderer = false;
		track.minTouchHeight = this.gridSize;
	}
	
}