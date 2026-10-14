import QtQuick

import xofm.libs.dialogs

DialogScreen {
    id: root

    required property string email
    required property var logoutPolicy

    signal unpairClicked
    signal pairClicked
    signal close

    iconSource: "qrc:/ark/icons/restore"
    text: qsTr("Pair to verify")
    description: qsTr("Pair your reMarkable account%1%2 to your paper tablet, or unpair to connect with with a different account. Visit my.remarkable.com to manage your account and devices.").arg(email !== "" ? " " : "").arg(email)

    buttons: [
        {
            text: qsTr("Unpair"),
            highlight: false,
            visible: !logoutPolicy.value,
            action: function() {
                root.unpairClicked();
            }
        },
        {
            text: qsTr("Pair device"),
            highlight: true,
            action: function() {
                root.pairClicked();
            }
        }
    ]
    onGoBack: root.close();
}
