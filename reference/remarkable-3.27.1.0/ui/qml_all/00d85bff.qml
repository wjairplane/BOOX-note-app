import QtQuick
import QtQuick.Controls as QQC2

import com.remarkable
import common

import device.view.experimental

import ark.controls as ArkControls

ScrollContainer {
    property alias contentX: flickable.contentX
    property alias contentY: flickable.contentY
    property alias contentWidth: flickable.contentWidth
    property alias contentHeight: flickable.contentHeight
    property alias contentItem: flickable.contentItem
    default property alias contentData: flickable.flickableData

    property bool enableScrollbar: false
    property int scrollbarTopMargin: 0
    property bool permanentScrollbar: false

    readonly property bool contentOutsideView: flickable.height < flickable.contentHeight

    property int scrollbarRightMargin: ArkControls.Values.margin.horizontal.small

    // For now only used to override the interactiveness from the related quicktest
    property alias continuousScrollEnabled: flickable.interactive

    view: Flickable {
        id: flickable

        contentWidth: width
        contentHeight: height
        interactive: Experimental.smoothScroll.enabled
        boundsBehavior: Flickable.StopAtBounds

        QQC2.ScrollIndicator.vertical: QQC2.ScrollIndicator {
            id: scrollIndicator
            objectName: "scrollIndicator"
            visible: contentOutsideView && enableScrollbar && (permanentScrollbar || scrollIndicatorTimer.running)
            topPadding: scrollbarTopMargin
            bottomPadding: ArkControls.Values.margin.vertical.medium
            rightPadding: scrollbarRightMargin
            contentItem: Rectangle {
                implicitWidth: scrollbarWidth
                color: Values.colorBlack
            }
        }
    }
    Rectangle {
        id: contentHeightIndicator
        visible: scrollIndicator.visible
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: scrollbarRightMargin
            topMargin: scrollbarTopMargin
            bottomMargin: ArkControls.Values.margin.vertical.medium
        }
        width: 2
        color: Values.colorBlack
    }
    // Wrap in item so it can be a child of ScrollContainer
    Item {
        Connections {
            target: flickable
            enabled: enableScrollbar
            function onContentYChanged() {
                if (!permanentScrollbar) {
                    scrollIndicatorTimer.restart();
                }
            }
        }
        Timer {
            id: scrollIndicatorTimer
            interval: scrollIndicatorTimeout
        }
    }
}
