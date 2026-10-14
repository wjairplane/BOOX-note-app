import QtQuick
import QtQuick.Templates as T
import ark.tokens as ArkTokens

/*! \defgroup ark ark */
/*! \ingroup ark
    \defgroup controls controls
*/
/*! \ingroup controls
    \defgroup details details
*/
/*! \ingroup ark
    \defgroup models models
*/

/** \addtogroup details
 *  @{
 */
/*! QtQuick <a href="https://doc.qt.io/qt-6/qml-qtquick-controls-button.html">Button</a> styled with Ark tokens

\note
This is a base for all buttons and should not be used directly
*/
T.Button {
    id: root

    /// All implementations are required to set either type or tokens
    property var type

    /// Switch off antialiasing of all children
    antialiasing: true

    /// Set button \ref Size for paperTablet. Default is Small
    property int buttonSize: ButtonBase.Size.Small

    /// change content position with Qt.AlignLeft or Qt.AlignRight. Default is Qt.AlignHCenter
    property int horizontalAlignment: Qt.AlignHCenter

    /// path to icon source
    property string iconSource

    /// set selected state
    property bool selected: checked

    /// set transparent background
    property bool transparent: false


    /*! Get control over focusFrame visibility
    By default focus frame is controlled by visualFocus read-only property
    */
    property alias showFocus: focusFrame.visible

    /*! A bitmask of states the button may take

    - Default for paperTablet is Idle
    - Default for client is Active Disabled, Idle", Hover, Selected

    \note Idle state must always be included
    */
    enum ButtonState {
        Active = 0x1,
        Disabled = 0x2,
        Selected = 0x4,
        Hover = 0x8,
        Idle = 0x10
    }

    property int states: {
        if (ArkTokens.Style.variable.isPaper)
            return ButtonBase.ButtonState.Idle;
        return ButtonBase.ButtonState.Active | ButtonBase.ButtonState.Disabled | ButtonBase.ButtonState.Selected | ButtonBase.ButtonState.Hover | ButtonBase.ButtonState.Idle;
    }

    /// Set \ref textPosition. Default is Right (text to the right of the icon)
    property int textPosition : !!iconSource && !!text ? ButtonBase.TextPosition.Right : ButtonBase.TextPosition.None

    /*! Selection of button 2.0 heights for paperTablet
        - Small (80px)
        - Medium (96px)
        - Large (112px)
    */
    enum Size {
        XSmall,
        Small, //< Values for button size
        Medium,
        Large
    }

    /*! Position of text in relation to the icon
        - None
        - Left
        - Right
    */
    enum TextPosition {
        None,
        Left, //< Values for button size
        Right
    }

    // The rest of the attributes are protected and should not be changed

    // ark components may overwrite this with own tokens
    property var tokens: {
       
        if (!ArkTokens.Style.variable.isPaper || !root.type.small) {
            return root.type;
        }

        let path=""
        switch (root.buttonSize) {
            case ButtonBase.Size.Large: path = root.type.large; break;
            case ButtonBase.Size.Medium: path = root.type.medium; break;
            case ButtonBase.Size.Small: path = root.type.small; break;
            default: console.error("ButtonBase: invalid buttonSize", root.buttonSize);
        }

        let t = path.split('.').reduce((acc, c) => acc && acc[c], ArkTokens);
        return t;
    }

    property color ditherBackgroundColor: root.tokens.background?.disabled?.fill ?? "white"

    // ark components may set this to false to implement own focus frame
    property bool defaultFocus: true

    background: Rectangle {
        color: root.transparent ? "transparent" : (root.tokens.background[root.state].fill ?? "transparent")
        radius: root.tokens.background[root.state].borderRadius ?? 0
        border.width: root.tokens.background[root.state].borderWidth ?? 0
        border.color: root.tokens.background[root.state].borderColor ?? "transparent"
        anchors {
            fill: parent
            topMargin: root.topInset
            leftMargin: root.leftInset
            rightMargin: root.rightInset
            bottomMargin: root.bottomInset
        }

        FocusFrame {
            id: focusFrame
            tokens: root.tokens.focus
            state: root.state
            visible: root.visualFocus && root.defaultFocus
        }
    }

    contentItem: IconLabel {
        text: root.text
        iconSource: root.iconSource
        iconSize: root.tokens.content?.icon?.idle.sizing ?? -1
        iconColor: root.tokens.content?.icon ? (root.tokens.content.icon[root.state].fill ?? "red") : "red"
        spacing: root.tokens.content?.spacing?.itemSpacing ?? 0
        textColor: root.tokens.content?.label ? (root.tokens.content.label[root.state].fill ?? "red") : "red"
      
        typography: root.tokens.content?.label?.idle.typography ?? ArkTokens.Style.label.md
        layoutDirection: root.textPosition === ButtonBase.TextPosition.Left ? Qt.RightToLeft : Qt.LeftToRight
        antialiasing: root.antialiasing

        Loader {
            anchors.fill: parent
            active: root.state === "disabled" && ArkTokens.Style.variable.isPaper
            sourceComponent: Image {
                anchors.fill: parent
                source: Details.overlaySource(ditherBackgroundColor)
                fillMode: Image.Tile
            }
        }
    }

    hoverEnabled: root.states & ButtonBase.ButtonState.Hover

    property real _minLeftPadding: root.tokens.background.idle.paddingLeft || root.tokens.background.idle.horizontalPadding || root.tokens.background.idle.spacing || 0
    property real _minRightPadding:root.tokens.background.idle.paddingRight || root.tokens.background.idle.horizontalPadding || root.tokens.background.idle.spacing || 0

    property real _maxTopPadding: root.tokens.background.idle.paddingTop || root.tokens.background.idle.verticalPadding || root.tokens.background.idle.spacing || 0
    property real _maxBottomPadding: root.tokens.background.idle.paddingBottom || root.tokens.background.idle.verticalPadding || root.tokens.background.idle.spacing || 0

    implicitWidth:  Math.max(implicitHeight, tokens.background.idle.height ?? 0, tokens.background.idle.width ?? 0, implicitContentWidth + _minLeftPadding + _minRightPadding) + leftInset + rightInset;
    implicitHeight: Math.max(tokens.background.idle.height ?? 0, implicitContentHeight + _maxTopPadding + _maxBottomPadding) + topInset + bottomInset;
    
    property string state: {
        if (!root.enabled && !!root.tokens.background.disabled && (states & ButtonBase.ButtonState.Disabled)) {
            return "disabled";
        }
        if (root.selected && !!root.tokens.background.selected && (states & ButtonBase.ButtonState.Selected)) {
            return "selected";
        }
        if (!root.down && (root.hovered || root.highlighted) && !!root.tokens.background.hover && (states & ButtonBase.ButtonState.Hover)) {
            return "hover";
        }
        if (root.down && !!root.tokens.background.active && (states & ButtonBase.ButtonState.Active)) {
            return "active";
        }
        return "idle";
    }

    property real _verticalInset: {
        if (!!root.tokens.height && !!root.tokens.background.idle.height) {
            return (root.tokens.height.height - root.tokens.background.idle.height) / 2;
        }
        return 0;
    }

    topInset: _verticalInset;
    bottomInset: _verticalInset;


    topPadding: {
        if (!!tokens.background.idle.height) {
            return  topInset + (tokens.background.idle.height - implicitContentHeight) / 2;
        }
        return topInset + _maxTopPadding;
    }

    bottomPadding: {
        if (!!tokens.background.idle.height) {
            return  bottomInset + (tokens.background.idle.height - implicitContentHeight) / 2;
        }
        return bottomInset + _maxBottomPadding;
    }

    leftPadding:  {
        switch (root.horizontalAlignment) {
            case Qt.AlignHCenter:
                return leftInset + (background.width - implicitContentWidth) / 2;
            case Qt.AlignLeft:
                return leftInset + _minLeftPadding;
            case Qt.AlignRight:
                return leftInset + Math.max(_minLeftPadding, background.width - implicitContentWidth - _minRightPadding);
            default:
                return leftInset;
        }
    }
    rightPadding:  {
        switch (root.horizontalAlignment) {
        case Qt.AlignHCenter:
            return rightInset + background.width - implicitContentWidth - leftPadding + leftInset;
        case Qt.AlignLeft:
            return rightInset + Math.max(_minRightPadding, background.width - implicitContentWidth - _minLeftPadding);
        case Qt.AlignRight:
            return rightInset + _minRightPadding;
        default:
            return rightInset;
        }
    }
}
/** @}*/
