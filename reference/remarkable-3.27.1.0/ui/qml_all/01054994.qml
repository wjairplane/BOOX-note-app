import QtQuick

import xofm.libs.dialogs

DialogScreen {
    id: root

    property bool isDiskEncrypted
    readonly property string syncStr: "\n\n" + qsTr("Any recent changes will sync automatically before your reMarkable is reset.")

    signal next()

    gobackButton: false
    iconSource: root.isDiskEncrypted ? "qrc:/ark/icons/padlock" : "qrc:/ark/icons/padlock"
    text: qsTr("Disk encryption")
    description: (root.isDiskEncrypted ? qsTr("Reset your device to factory settings. By doing this all files and settings on your reMarkable will be erased, and your device will be restored to its original state.") :
                                         qsTr("This requires a factory reset of your paper tablet. All files and settings on your reMarkable will be erased.")) + root.syncStr
    buttons: [
        {
            text: qsTr("Cancel"),
            highlight: false,
            action: function() {
                root.goBack();
            }
        },
        {
            text: root.isDiskEncrypted ? qsTr("Factory reset") : qsTr("Continue"),
            highlight: true,
            action: function() {
                root.next()
            }
        }
    ]
}
