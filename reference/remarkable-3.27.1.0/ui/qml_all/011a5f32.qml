pragma Singleton
import QtQuick
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!
Set of values to use when building layouts and components.
\note
    Values are different for landscape and portrait orientations and on different devices. 
*/
QtObject {
    id: root

    /*!
    Set of icon sizes. The following tokens are available:
    - small
    - medium
    - large
    */
    readonly property var iconSize: QtObject {
        readonly property int small:  ArkTokens.Style.variable.iconSize.small ?? ArkTokens.Style.variable.iconSize
        readonly property int medium: ArkTokens.Style.variable.iconSize.medium ?? ArkTokens.Style.variable.iconSize
        readonly property int large:  ArkTokens.Style.variable.iconSize.large ?? ArkTokens.Style.variable.iconSize
    }
    
    /*! Set of margins. The following tokens are available:
    - horizontal.large
    - horizontal.medium
    - horizontal.medium_static
    - horizontal.none
    - horizontal.small
    - horizontal.small_static
    - horizontal.xlarge
    - horizontal.x2large
    - horizontal.x3large

    - vertical.large
    - vertical.medium
    - vertical.medium_static
    - vertical.none
    - vertical.small
    - vertical.small_static
    - vertical.xlarge
    - vertical.x2large
    - vertical.x3large

    ### Usage example
    \code
    anchors.leftMargin: ArkControls.Values.margin.horizontal.xlarge
    anchors.topMargin: ArkControls.Values.margin.vertical.large
    \endcode
    */
    readonly property var margin: ArkTokens.Settings.landscape ? _margin.landscape : _margin.portrait
    /*!
    Deprecated. Use platform.padding instead
    */
    readonly property var padding: ArkTokens.Style.padding

    /*!
    Set of platform specific values. The following tokens are available:
    - padding
        x3small
        x2small
        xsmall
        small
        medium
        large
        xlarge
        x2large
        x3large
    
    - spacing
        x3small
        x2small
        xsmall
        small
        medium
        large
        xlarge
        x2large
        x3large
        x5large
        x6large
    */
    readonly property var platform: ArkTokens.Style.variable.platform
    
    /*!
    Set of settings. The following tokens are available:
    - leftMargin.firstLevel
    - leftMargin.secondLevel
    - rightMargin.firstLevel
    - rightMargin.secondLevel
    - horizontalMargin.firstLevel (left and right are the same today)
    - horizontalMargin.secondLevel (left and right are the same today)

    \note Use firstLevel margin for settings pages with sidebar and secondLevel for full screen pages.
    */
    readonly property var settings: QtObject {
        readonly property var horizontalMargin: QtObject {
            readonly property real firstLevel: Values.margin.horizontal.large
            readonly property real secondLevel:  {
                if (!ArkTokens.Style.variable.enoughHorizontalSpace && !ArkTokens.Settings.landscape) {
                    return Values.margin.horizontal.large;
                }
                return Values.margin.horizontal.x2large;
            }
        }
        readonly property var leftMargin: horizontalMargin
        readonly property var rightMargin: horizontalMargin
    }

    /*! Deprecated. Use platform.spacing instead
    */
    readonly property var spacing: QtObject {
        readonly property int large: ArkTokens.Style.spacing.large
        readonly property int medium: ArkTokens.Style.spacing.medium
        readonly property int none: ArkTokens.Style.spacing.none
        readonly property int small: ArkTokens.Style.spacing.small
        readonly property int xsmall: ArkTokens.Style.spacing.xsmall
        readonly property int x2small: ArkTokens.Style.spacing.x2small
        readonly property int x3small: ArkTokens.Style.spacing.x3small
        readonly property int x2large: ArkTokens.Style.spacing.x2large * ((!ArkTokens.Style.variable.enoughVerticalSpace && ArkTokens.Settings.landscape) ? 0.5 : 1)
        readonly property int xlarge: ArkTokens.Style.spacing.xlarge * ((!ArkTokens.Style.variable.enoughVerticalSpace && ArkTokens.Settings.landscape) ? 0.5 : 1)
    }
    property var grayscale
    property var neutral

    readonly property var _margin: QtObject {
        readonly property var landscape: QtObject {
            readonly property var horizontal: Margins {
                tokens: ArkTokens.Style.margin.landscape.horizontal
                baseSize: ArkTokens.Style.variable.deviceHeight ?? 0
                debug: "landscape-horizontal"
            }
            readonly property var vertical: Margins {
                tokens: ArkTokens.Style.margin.landscape.vertical
                baseSize: ArkTokens.Style.variable.deviceWidth ?? 0
                debug: "landscape-vertical"
            }
        }
        readonly property var portrait: QtObject {
            readonly property var horizontal: Margins {
                tokens: ArkTokens.Style.margin.portrait.horizontal
                baseSize: ArkTokens.Style.variable.deviceWidth ?? 0
                debug: "portrait-horizontal"
            }
            readonly property var vertical: Margins {
                tokens: ArkTokens.Style.margin.portrait.vertical
                baseSize: ArkTokens.Style.variable.deviceHeight ?? 0
                debug: "portrait-vertical"
            }
        }
    }

    readonly property bool isUsingDebugColors: ArkTokens.Settings.usingDebugColors

    onIsUsingDebugColorsChanged: setDebugColors(isUsingDebugColors)

    /// Sets ark components palete to purple when flag is true
    /// Sets back to original palete otherwise
    /// Do not use this function, set ArkTokens.Settings.usingDebugColors instead
    function setDebugColors(flag) {
        ArkTokens.Settings.usingDebugColors = flag;
    }

    /// Set focus colors, default and inverted at once
    function setFocusColors(defaultColor, invertedColor) {
        ArkTokens.Style.interaction.focus.idle = defaultColor;
        ArkTokens.Style.inverted.interaction.focus.idle = invertedColor;
    }

    Component.onCompleted: {
        setDebugColors(isUsingDebugColors);
    }
}
