import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ark.controls as ArkControls

ColumnLayout {
    id: root

    required property var navigationModel
    required property bool connectRequired
    property bool limitShownIntegrations: false
    readonly property int _maxItems: 2

    signal showMoreIntegrationsClicked
    signal integrationClicked(string title, string id)

    spacing: 0

    ArkControls.FoldoutItem {
        id: tooManyIntegrations
        objectName: "TooManyIntegrations"
        Layout.fillWidth: true
        label: qsTr("Export to Integration")
        iconSource: "qrc:/ark/icons/puzzle"
        visible: limitShownIntegrations && repeaterModel.count > root._maxItems
        onClicked: root.showMoreIntegrationsClicked()
    }

    Repeater {
        id: repeaterModel
        model: root.navigationModel
        delegate: ArkControls.FoldoutItem {
            required property var model
            required property int index

            objectName: "FoldoutItem%1".arg(index)
            label: repeaterModel.count > root._maxItems ? model.name : qsTr("Export to %1").arg(model.name)
            visible: !tooManyIntegrations.visible
            iconSource: model.iconSource
            description: root.connectRequired ? qsTr("Connect required") : ""
            onClicked: {
                if (root.connectRequired) {
                    // exporting a document with methods concents is not allowed without a Connect subscription
                    return;
                }
                root.integrationClicked(model.name, model.id)
            }
        }
    }
}
