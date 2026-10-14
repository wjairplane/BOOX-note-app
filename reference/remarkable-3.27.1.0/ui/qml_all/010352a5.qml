import QtQuick
import QtQuick.Layouts
import common
import com.remarkable
import device.global
import device.ui.controls
import ark.controls as ArkControls
import xofm.libs.qtgui

Item {
    id: root

    required property PopupOverlay popupOverlay
    required property var createWidgets
    readonly property int sidePadding: primaryLayout.visibleChildren.length === 2 ? 0 : 4 // Since the Repeater counts as a visibl child, we need to check for 2 instead of 1 (off by one)
    readonly property bool popupActive: primaryLayout.visibleChildren.some(widget => widget.item?.popupActive)
    required property string view
    property bool showCreateMenu: true

    visible: showCreateMenu && view !== ""
    width: primaryContainer.width
    height: 112

    Rectangle {
        id: primaryContainer
        width: primaryLayout.implicitWidth + root.sidePadding * 2
        height: parent.height
        radius: height / 2
        border {
            width: 2
            color: "black"
        }

        RowLayout {
            id: primaryLayout
            height: parent.height
            spacing: 0
            anchors {
                left: parent.left
                leftMargin: root.sidePadding
            }

            Repeater {
                model: root.createWidgets
                delegate: WidgetLoader {
                    id: widgetLoader
                    required property int index
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: true
                    Layout.minimumWidth: height
                    visible: !!item?.supportedViews.includes(root.view)
                    injections: {
                        "popupOverlay": root.popupOverlay,
                        "anchorTarget": root,
                        "currentView": root.view
                    }
                }
            }
        }
    }

}
