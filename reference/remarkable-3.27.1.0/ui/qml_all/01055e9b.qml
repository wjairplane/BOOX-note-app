import QtQuick

import xofm.libs.dialogs

InformationDialog {
    id: root

    property bool isDiskEncrypted

    signal next()

    readonly property var encryptionPoints: [
        qsTr("If you use your reMarkable 2 for work, being able to encrypt data might be a business requirement."),
        qsTr("A factory reset will delete all files stored on your paper tablet."),
        qsTr("Make sure notebooks and documents are synced to the cloud."),
        qsTr("You'll need both a password and a passcode for your device."),
        qsTr("Use the password to power on after being out of battery or factory reset, and a longer passcode means a more secure device.")
    ]

    gobackButton: true
    title: qsTr("Disk encryption")
    subtitle: qsTr("In addition to the passcode, that prevents others from breaking into your physical paper tablet, you can protect your content by encrypting the disk. It will require a factory reset of your device.");
    body: encryptionPoints
    buttons: [
        {
            text: root.isDiskEncrypted ? qsTr("Factory reset") : qsTr("Accept"),
            highlight: true,
            action: function() {
                root.next();
            }
        }
    ]
}
