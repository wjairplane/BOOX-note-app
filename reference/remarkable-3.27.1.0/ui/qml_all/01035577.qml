import QtQuick
import QtQuick.Layouts
import ark.controls as ArkControls
import device.ui.controls
import common

Item {
    id: root

    required property var popupOverlay
    required property var anchorTarget

    // The create menu uses these as criteria to hide the views. Currently the following views are supported:
    // "myfiles", "filter", "notebook-filter"
    required property list<string> supportedViews
    required property string currentView

    property alias caption: caption.text
    property alias iconSource: icon.source
    property Component popup
    readonly property alias popupActive: _popup.active

    readonly property int bottomPadding: 24

    signal actionClicked
    signal longPress

    function hidePopup() {
        _popup.hidePopup()
    }

    // Since we cannot anchor the popup directly to the target, we
    // manually update its position when the target moves. Obviously we should
    // anchor it directly, but since the PopupOverlay has a different coordinate
    // system that would not work.
    readonly property point position: Qt.point(root.anchorTarget.x, root.anchorTarget.y)

    onPositionChanged: {
            const targetPos = root.anchorTarget.mapToItem(_popup.parent, 0, 0)
            _popup.x = targetPos.x + (root.anchorTarget.width / 2) - (_popup.width / 2);
            _popup.y = targetPos.y - _popup.height - bottomPadding;
    }


    MouseArea {
        id: clickArea
        anchors.fill: parent

        Rectangle {
            id: iconActiveBackground
            anchors {
                fill: clickArea
                margins: 20
            }
            radius: width / 2
            color: Values.colorBlack
            visible: root.popupActive
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            ArkControls.Icon {
                id: icon
                Layout.alignment: Qt.AlignHCenter
                size: ArkControls.Values.iconSize.medium
                source: "qrc:/ark/icons/placeholder"
                color: root.popupActive ? Values.colorWhite : Values.colorBlack
            }
            ArkControls.Caption {
                id: caption
                visible: !!text
            }
        }
        onClicked: {
            root.actionClicked()
            if(!root.popup) {
                return;
            }

            if (!root.anchorTarget) {
                return;
            }

            _popup.showPopup()
        }
        onPressAndHold: root.longPress()
    }
    Popup {
        id: _popup
        overlay: root.popupOverlay
        tapOutsideBehavior: Popup.TapOutside.RejectAndHide
        Loader {
                id: popupContent
                active: _popup.active
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                sourceComponent: root.popup
            }
        }
}
