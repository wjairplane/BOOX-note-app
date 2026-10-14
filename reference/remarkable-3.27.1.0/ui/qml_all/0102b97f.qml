import QtQuick
import QtQuick.Controls
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import ark.tokens as ArkTokens
import ark.controls as ArkControls

Rectangle {
    id: root
    border.width: Values.outlineSize

    property var image
    property alias title: title.text
    property alias description: description.text
    property alias actionText: arrowButton.text
    property var actionData
    property bool actionBorder: true
    property bool showFocus: false
    property bool showButton: true

    signal topicClicked(var data)

    readonly property int artworkHeight: 158

    function activate() {
        topicClicked(root.actionData);
    }

    implicitHeight: textColumn.implicitHeight +
                    arrowButton.height +
                    content.anchors.topMargin +
                    content.anchors.bottomMargin +
                    textColumn.spacing * 2

    Item {
        id: content
        anchors {
            fill: parent
            leftMargin: 40
            rightMargin: 40
            topMargin: 58
            bottomMargin: 48
        }

        Image {
            id: illustration
            height: artworkHeight
            width: height
            source: !!image ? image : ""
            fillMode: Image.PreserveAspectFit
            anchors {
                left: parent.left
                top: parent.top
            }
        }

        Column {
            id: textColumn
            anchors {
                top: parent.top
                bottom: arrowButton.top
                right: parent.right
                left: illustration.right
                rightMargin: 16
                leftMargin: 48
            }

            spacing: 16

            ArkControls.Title {
                id: title
                type: ArkControls.Title.MediumAlt
                width: parent.width
                wrapMode: Text.WordWrap
            }

            ArkControls.Body {
                id: description
                type: ArkControls.Body.Medium
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        ArkControls.Button {
            id: arrowButton
            visible: showButton
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            width: Math.min(parent.width, implicitWidth)
            type: actionBorder ? ArkTokens.Button.secondary
                               : ArkTokens.Button.tertiary
            textPosition: ArkControls.Button.TextPosition.Left
            showFocus: root.showFocus
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: topicClicked(actionData)
    }
}
