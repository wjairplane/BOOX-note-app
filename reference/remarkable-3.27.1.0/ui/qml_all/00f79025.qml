import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import ark.controls as ArkControls
import ark.tokens as ArkTokens


Rectangle {
    id: root

    required property url imageSource
    required property Action skipReleaseNotes
    required property Action readReleaseNotes

    MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => {
            mouse.accept = true;
        }
    }
    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: root.imageSource
    }
    Container {
        id: buttonFlow

        readonly property real minimumPadding: 64
        readonly property real preferredVerticalWidth: 432
        readonly property real minimumHorizontalWidth: 716
        property real preferredHorizontalWidth: minimumHorizontalWidth

        component SplashScreenButton: ArkControls.Button {
            required property bool stackedVertically
            required property real preferredVerticalWidth
            required property SplashScreenButton otherButton
            required property Action horizontalAction
            required property Action verticalAction

            readonly property real preferredWidth: {
                action; // Force re-eval when action is changed, as it might have a different label
                if (visible) {
                    const extraPadding2x = 48; // Workaround for some Ark-specific button behaviour
                    return otherButton.visible
                            ? Math.ceil(implicitContentWidth) + extraPadding2x
                            : preferredVerticalWidth;
                }
                return -1;
            }

            action: stackedVertically ? verticalAction : horizontalAction
            visible: action.enabled
            type: action === root.readReleaseNotes ? ArkTokens.Button.primary : ArkTokens.Button.secondary
            width: {
                waitForGeometryUpdate.restart();
                const minWidth = stackedVertically ? preferredVerticalWidth : -1;
                return Math.max(minWidth, preferredWidth, otherButton.preferredWidth);
            }
        }

        objectName: "buttonFlow"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: ArkControls.Values.margin.vertical.medium
        }
        background: Rectangle {}
        spacing: 24
        horizontalPadding: Math.max(minimumPadding, (width - implicitContentWidth) / 2)
        contentItem: Flow {
            id: flow

            readonly property bool stackedVertically: width === buttonFlow.preferredVerticalWidth

            spacing: buttonFlow.spacing
            anchors.verticalCenter: buttonFlow.verticalCenter
            width: (root.width === 0) || (buttonFlow.preferredHorizontalWidth + 2 * buttonFlow.minimumPadding <= root.width)
                   ? buttonFlow.preferredHorizontalWidth
                   : buttonFlow.preferredVerticalWidth

            Timer {
                id: waitForGeometryUpdate
                interval: 0
                onTriggered: {
                    const widthOfButtons = Math.max(firstButton.preferredWidth, secondButton.preferredWidth) * 2
                                         + flow.spacing;
                    buttonFlow.preferredHorizontalWidth = Math.ceil(Math.max(buttonFlow.minimumHorizontalWidth, widthOfButtons));
                }
            }
        }

        SplashScreenButton {
            id: firstButton

            stackedVertically: flow.stackedVertically
            preferredVerticalWidth: buttonFlow.preferredVerticalWidth
            otherButton: secondButton
            horizontalAction: root.skipReleaseNotes
            verticalAction: root.readReleaseNotes
        }
        SplashScreenButton {
            id: secondButton

            stackedVertically: flow.stackedVertically
            preferredVerticalWidth: buttonFlow.preferredVerticalWidth
            otherButton: firstButton
            horizontalAction: root.readReleaseNotes
            verticalAction: root.skipReleaseNotes
        }
    }
}
