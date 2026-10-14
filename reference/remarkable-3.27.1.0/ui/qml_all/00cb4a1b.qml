import QtQuick

import device.ui.text
import com.remarkable

Column {
    id: root
    required property var settings

    TextParagraph {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: "Noto Serif"
        text: qsTr("<p>To do so, this device acts as an USB ethernet device, "
                   + "and you can connect using the SSH protocol "
                   + "using the username 'root' and the password <b>'%1'</b>.</p> "
                   + "<p>SSH over WLAN is disabled by default, but can be enabled "
                   + "by connecting to the device over USB using the SSH protocol "
                   + "with the credentials mentioned above and running the command "
                   + "<br><br><b>rm-ssh-over-wlan on</b>.</p><br>")
        .arg(root.settings.developerPassword)
    }
    TextParagraph {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: "Noto Serif"
        text: qsTr("<p>The IP addresses available to connect to are listed below:</p>")
    }
    Repeater {
        model: networkAddresses.ipAddresses
        delegate: TextParagraph {
            width: parent.width
            wrapMode: Text.WrapAnywhere
            text: modelData
        }
    }

    LinkDetails {
        id: networkAddresses
    }
}
