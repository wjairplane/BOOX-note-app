import QtQuick
import QtQuick.Layouts

import ark.controls as ArkControls

FoldoutOverlay {
    id: root

    property alias showTag: tagFoldoutItem.visible
    property alias showConvert: convertFoldoutItem.visible
    property alias showSendEmail: emailFoldoutItem.visible
    property string sendEmailDescription
    property string convertDescription

    signal tagClicked
    signal convertClicked
    signal sendByEmailClicked
    signal addBeforeClicked
    signal addAfterClicked
    signal foldoutOverlayClicked

    contentItem: ColumnLayout {
        spacing: 0

        ArkControls.FoldoutItem {
            id: tagFoldoutItem
            objectName: "tagFoldoutItem"
            Layout.fillWidth: true
            label: qsTr("Tag")
            iconSource: "qrc:/ark/icons/tag"
            onClicked: root.tagClicked()
        }
        ArkControls.FoldoutItem {
            id: addBeforeItem
            objectName: "addBeforeItem"
            Layout.fillWidth: true
            label: qsTr("Add page before")
            iconSource: "qrc:/ark/icons/place_before"
            onClicked: root.addBeforeClicked()
        }
        ArkControls.FoldoutItem {
            id: addAfterItem
            objectName: "addAfterItem"
            bottomDivider: true
            Layout.fillWidth: true
            label: qsTr("Add page after")
            iconSource: "qrc:/ark/icons/place_after"
            onClicked: root.addAfterClicked()
        }
        ArkControls.FoldoutItem {
            id: convertFoldoutItem
            objectName: "convertFoldoutItem"
            Layout.fillWidth: true
            label: qsTr("Convert")
            description: root.convertDescription
            iconSource: "qrc:/ark/icons/hwc"
            onClicked: root.convertClicked()
        }
        ArkControls.FoldoutItem {
            id: emailFoldoutItem
            objectName: "emailFoldoutItem"
            Layout.fillWidth: true
            label: qsTr("Send by email")
            description: root.sendEmailDescription
            iconSource: "qrc:/ark/icons/send"
            onClicked: root.sendByEmailClicked()
        }
    }

    onOverlayClicked: root.foldoutOverlayClicked()
}
