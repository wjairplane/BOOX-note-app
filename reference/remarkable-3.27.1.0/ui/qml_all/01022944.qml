import QtQuick

import com.remarkable
import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.search.ui

ArkControls.Panel {
    id: root

    required property SearchIndexStatus searchIndexStatus

    visible: searchIndexStatus.status !== SearchIndexStatus.Status.Ineligible
             && !RetailDemo.enabled
             && UserInfo.isSubscribed

    label: qsTr("Handwriting search")
    description: qsTr("Keeps an index of the notes and text you've searched for.")
    action: ArkControls.Button {
        id: resetButton
        type: ArkTokens.Button.secondary
        text: qsTr("Reset")
        onClicked: {
            searchIndexStatus.requestReset();
            searchIndexStatus.requestUpdate();
            showInfoTimer.restart();
        }
    }
    showAttachment: showInfoTimer.running
    attachment: ArkControls.InfoMessage {
        type: ArkTokens.InfoMessage.primary
        message: qsTr("The search index for handwriting has been reset.")
        iconSource: "qrc:/ark/icons/checkmark"
    }

    Timer {
        id: showInfoTimer
        interval: 10000
        triggeredOnStart: true
    }
}
