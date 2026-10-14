import QtQuick
import QtQuick.Layouts

import com.remarkable

import ark.controls as ArkControls

FoldoutOverlay {
    id: root

    property alias showFavorite: favoriteFoldoutItem.visible
    property alias showTag: tagFoldoutItem.visible
    property alias showSendEmail: emailFoldoutItem.visible
    property alias showArchive: archiveFoldoutItem.visible
    property alias showRetrieve: retrieveFoldoutItem.visible
    property alias showIntegrations: integrationsFoldout.visible
    property string favoriteIcon

    required property var navigationModel
    required property bool connectRequired
    required property bool pairingRequired

    signal favoriteClicked
    signal tagClicked
    signal sendByEmailClicked
    signal archiveClicked
    signal retrieveClicked
    signal showMoreIntegrationsClicked
    signal integrationClicked(string name, string id)
    signal foldoutOverlayClicked

    contentItem: ColumnLayout {
        spacing: 0

        ArkControls.FoldoutItem {
            id: favoriteFoldoutItem
            objectName: "favoriteFoldoutItem"
            Layout.fillWidth: true
            label: qsTr("Favorite")
            iconSource: root.favoriteIcon
            onClicked: root.favoriteClicked()
        }
        ArkControls.FoldoutItem {
            id: tagFoldoutItem
            objectName: "tagFoldoutItem"
            bottomDivider: true
            Layout.fillWidth: true
            label: qsTr("Tag")
            iconSource: "qrc:/ark/icons/tag"
            onClicked: root.tagClicked()
        }
        ArkControls.FoldoutItem {
            id: emailFoldoutItem
            objectName: "emailFoldoutItem"
            Layout.fillWidth: true
            label: qsTr("Send by email")
            description: {
                // pairing takes over Connect subscription
                if (root.pairingRequired) {
                    return qsTr("Pairing required");
                }
                if (root.connectRequired) {
                    return qsTr("Connect required");
                }
                return "";
            }
            iconSource: "qrc:/ark/icons/send"
            onClicked: root.sendByEmailClicked()
        }
        ArkControls.FoldoutItem {
            id: archiveFoldoutItem
            objectName: "archiveFoldoutItem"
            Layout.fillWidth: true
            label: qsTr("Archive to cloud")
            iconSource: "qrc:/ark/icons/archive"
            onClicked: root.archiveClicked()
        }
        ArkControls.FoldoutItem {
            id: retrieveFoldoutItem
            objectName: "retrieveFoldoutItem"
            Layout.fillWidth: true
            label: qsTr("Retrieve from cloud")
            iconSource: "qrc:/ark/icons/retrieve"
            onClicked: root.retrieveClicked()
        }
        IntegrationsFoldoutItem {
            id: integrationsFoldout
            navigationModel: root.navigationModel
            connectRequired: root.connectRequired
            limitShownIntegrations: true
            onShowMoreIntegrationsClicked: root.showMoreIntegrationsClicked()
            onIntegrationClicked: (name, id) => { root.integrationClicked(name, id); }
        }
    }

    onOverlayClicked: root.foldoutOverlayClicked()
}
