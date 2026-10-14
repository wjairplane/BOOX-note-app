pragma Singleton

import QtQuick
import com.remarkable
import common
import device.global
import ark.tokens as ArkTokens
import ark.controls as ArkControls

Item {
    Connections {
        target: Settings

        function onAccessibilityModeChanged(mode){
            accessibilityMode = mode;
        }

        function onRightHandModeChanged(mode) {
            accessibilityRightHanded = mode;
        }
    }

    KeyboardNavigationController {
        id: keyboardNavigationController
        Component.onCompleted: Global.keyboardNavigationController = keyboardNavigationController
    }

    property bool isPortraitOrientation: true   // binding is set up in MainView

    readonly property bool isDevice: true

    // Geometry definitions
    readonly property int designGridVerticalGutter: 33
    readonly property int designGridVerticalWidth: isPortraitOrientation ? 84 : 123
    readonly property int designGridVerticalSpacing: 30
    readonly property int designGridMargin: 15
    readonly property int designGridHorizontalGutter: 15
    readonly property int designGridHorizontalHeight: 45
    readonly property int designGridHorizontalSpacing: 15
    readonly property int designGridCollectionColumns: isPortraitOrientation ? (accessibilityMode ? 3 : 4) : (accessibilityMode ? 4 : 6)

    function gridColumns(widths, spacings) {
        return widths * designGridVerticalWidth + spacings * designGridVerticalSpacing;
    }

    // Calculate the grid size based on available width and the intended column count
    function gridSize(availableWidth, columns, aspect = 4.0 / 3.0, labelHeight = navigatorContentGridItemLabelHeight) {
      if (columns < 1) { columns = 1; }
      const gridItemWidth = Math.floor(availableWidth / columns);
      const thumbnailHeight = Math.floor((gridItemWidth - designGridHorizontalSpacing * 2) * aspect);
      return Qt.size(gridItemWidth, thumbnailHeight + labelHeight + designGridHorizontalSpacing);
    }

    readonly property size _baseSize: Qt.size(1404, 1872)
    property size _rootSize: _baseSize // Set at runtime to support window scaling
    readonly property bool desktopSimulator: EPFramebuffer.backend === EPFramebuffer.Desktop
    // Some layouts might want to increase the amout of visible items if we have a larger frame buffer
    readonly property real responsiveLayoutScale: Math.min(deviceWidth, deviceHeight) / Math.min(_baseSize.width, _baseSize.height) // view scale relative to base device
    readonly property int deviceHeight: _rootSize.height
    readonly property int deviceWidth: _rootSize.width
    readonly property size gridItemSize: gridSize(deviceWidth  - 2 * viewHorizontalMargin, Math.round(Values.visibleGridColumns * Values.responsiveLayoutScale))

    readonly property int outlineSize: 2
    readonly property int hairlineSize: 1

    readonly property int shadowOffset: 24
    readonly property int onboardingArtworkHeight: accessibilityMode ? 435 : 480
    readonly property int onboardingTitlePadding: accessibilityMode ? 0 : 25

    // View margin is a slightly larger than designGridMargin toto account for the fact that a few border pixels are masked on RM2
    readonly property int viewHorizontalMargin: Values.designGridVerticalGutter - Values.designGridMargin
    readonly property int visibleGridColumns: isPortraitOrientation ? (accessibilityMode ? 3 : 4) : (accessibilityMode ? 4 : 6)
    readonly property int navigatorContentColumnWidth: isPortraitOrientation ? (accessibilityMode ? 4 : 3) : (accessibilityMode ? 3 : 2)

    readonly property real scale: 0.5
    readonly property int navigatorMargin: 40
    readonly property int onboardingIconMargin: 80
    readonly property int navigatorHeaderTitleMargin: 25
    readonly property int navigatorSidebarItemHeight: 120
    readonly property int navigatorSidebarItemMargin: 22
    readonly property int navigatorStatusbarHeight: 72
    readonly property int createMenuHeight: 112
    // The actual required offset for createmenu that is 120px of height is 96 but createmenu height today is 112 and its 4px border is not a part of its height
    readonly property int createMenuBottomMargin: 100
    readonly property int navigatorSidebarWidth: accessibilityMode ? 488 : 414
    readonly property int navigatorSidebarIndentation: 20
    readonly property int navigationEntriesHeaderHeight: 120
    readonly property int navigationEntriesHeaderMargin: 12
    readonly property int navigatorContentGridItemWidth: designGridVerticalWidth * navigatorContentColumnWidth + designGridVerticalSpacing * navigatorContentColumnWidth
    readonly property int navigatorContentGridItemHeight: isPortraitOrientation ?
                                                              accessibilityMode ? 680 : 510 :
                                                              accessibilityMode ? 685 : 457
    readonly property int navigatorContentCollectionHeight: designGridHorizontalHeight + designGridHorizontalSpacing * 2
    property int navigatorContentGridItemLabelHeight: accessibilityMode ? 95 : 80 // see MainWindow::onCompleted
    readonly property int navigatorContentGridItemMargin: 16
    readonly property int navigatorContentGridItemPinnWidth: 42
    readonly property int navigatorContentListItemHeight: 2 * designGridHorizontalHeight + 2 * designGridHorizontalSpacing
    readonly property int navigatorContentListCollectionHeight: designGridHorizontalHeight + 2 * designGridHorizontalSpacing
    readonly property int navigatorContentListItemMargin: 12
    readonly property int navigatorSettingsItemHeight: 200
    readonly property int navigatorSettingsItemTopMargin: 60
    readonly property int navigatorSettingsItemSecondMargin: 200
    readonly property int navigatorSettingsHeaderHeight: 295
    readonly property int navigatorSettingsItemMargin: isPortraitOrientation ? accessibilityMode ? 75 : 145
                                                                             : accessibilityMode ? gridColumns(1, 2) : gridColumns(2, 3)
    readonly property int navigatorSettingsFullscreenItemMargin: isPortraitOrientation ? accessibilityMode ? gridColumns(1, 2) : gridColumns(2, 3)
                                                                                       : accessibilityMode ? gridColumns(2, 3) : gridColumns(3, 4)

    readonly property int navigatorDashboardButtonHeight: 583
    readonly property int navigatorDropdownHeaderHeight: accessibilityMode ? 80 : 72
    readonly property int navigatorDropdownButtonHeight: accessibilityMode ? 98 : 80
    readonly property int buttonHeight: accessibilityMode ? 90 : 80
    readonly property int minimumClickableAreaHeight: 80 // ARK-1119
    readonly property int fixedWidthInputField: 716
    readonly property int minimumButtonWidth: 312
    readonly property int onboardingButtonMargin: 252
    readonly property int toolboxFoldoutMenuWidth: accessibilityMode ? 400 : 339
    readonly property int writingToolFoldoutMenuWidth: 480
    readonly property int eraserToolFoldoutMenuWidth: 376
    readonly property int toolboxFoldoutItemMargin: 27
    readonly property int toolboxGridFoldoutItemMargin: 32
    readonly property int controlVerticalMargin: 18
    readonly property int textInputLineSpacing: 4
    readonly property int thumbnailTagPillCaptionVerticalPadding: 9
    readonly property int thumbnailTagPillCountWidth: accessibilityMode ? 100 : 50
    readonly property int thumbnailRowHeight: accessibilityMode ? 212 : 106
    readonly property real archivedThumbnailOpacity: 0.6

    readonly property int loadingIndicatorSize: 120
    readonly property int onboardingNextPageDelay: 2000
    readonly property int popupTimeout: 4000
    readonly property int pageFooterTimeout: 8000

    readonly property int documentViewToolButtonSize: ArkTokens.Style.variable.controlsHeight.large
    readonly property int documentViewFormatTitleMargin: 30
    readonly property int documentViewFormatGridMargin: 15
    readonly property int documentViewFormatIconSize: 150
    readonly property int documentViewFormatHeight: 550
    readonly property int documentViewTableOfContentsItemHeight: designGridHorizontalHeight + 2 * designGridHorizontalSpacing
    readonly property int documentViewTextEditSideMargin: 200
    readonly property int documentViewTextEditTopMargin: 108

    //Expressed with portrait grid and should ignore grid in landscape
    readonly property int documentViewLayerFoldoutWidth: (30 + 84) * 7
    readonly property int documentViewShareFoldoutWidth: (24 + 80) * 4

    readonly property int searchResultListItemMargin: 80
    readonly property int searchHeaderMargin: 100
    readonly property int searchLeftMargin: 20

    readonly property int scrollBarMinimumWidth: 30
    readonly property int scrollBarMinimumHeight: 30

    readonly property int syncProgressBarWidth: 160
    readonly property int syncProgressBarHeight: 10

    readonly property int inactiveWarningHeight: 55
    readonly property int inactiveWarningWidth: accessibilityMode ? 270 : 217

    readonly property real quickSettingsGestureWidth: 350

    // Keyboard
    property int pinInputCircleDiameter: 58
    readonly property int shortcutSelectionSpacing: 160

    // Icon sizes
    readonly property int iconSizeLarge: ArkControls.Values.iconSize.large
    readonly property int iconSizeMedium: ArkControls.Values.iconSize.medium
    readonly property int iconSizeSmall: ArkControls.Values.iconSize.small

    // Font sizes
    readonly property int fontSizeSetupHeader: 48
    readonly property int fontSizeSetupH1: 34
    readonly property int fontSizeSetupH4: accessibilityMode ? 24 : 18
    readonly property int fontSizeH1: accessibilityMode ? 40 : 36
    readonly property int fontSizeH2: accessibilityMode ? 36 : 28
    readonly property int fontSizeH3: accessibilityMode ? 32 : 25
    readonly property int fontSizeBody1: accessibilityMode ? 36 : 28
    readonly property int fontSizeBody2: accessibilityMode ? 32 : 25

    readonly property real lineHeight: 1.25

    // Color definitions
    readonly property color colorWhite: "white"
    readonly property color colorBlack: "black"

    // Adjustable
    property bool accessibilityRightHanded: true
    property bool accessibilityMode: false
    onAccessibilityModeChanged: {
        ArkTokens.Settings.accessibility = accessibilityMode;
    }

    // Update screen
    property bool updateScreen: false

    property bool pageIndicatorRadius: iconSizeSmall * 0.33 / 2

    readonly property int fontRenderType: Text.QtRendering

    // Empty views positioning
    readonly property real emptyViewTopMarginRatio: isPortraitOrientation ? 0.2 : 0.1

    function entrySubtext(entry) {
        if (!entry) {
            return "";
        }
        switch (entry.type) {
        case Entry.Collection: {
            const size = entry.size;
            return size == 1 ? qsTr("1 item") : qsTr("%1 items").arg(size);
        }
        default:
            return entry.subtext
        }
    }
}
