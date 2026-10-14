import QtQuick

import device.ui.text

TextParagraph {
    width: parent.width
    wrapMode: Text.WordWrap
    font.family: "Noto Serif"

    text: qsTr("<p>To do so, this device acts as an USB ethernet device, and you can connect using the SSH protocol. \
Because this device is enrolled with your enterprise, SSH connectivity has been disabled for security purposes.</p>")
}
