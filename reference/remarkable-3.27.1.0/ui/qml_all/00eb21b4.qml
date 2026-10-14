import device.ui.text // TextParagraph

TextParagraph {
    width: parent.width
    wrapMode: Text.WordWrap
    font.family: "Noto Serif"
    text: qsTr("<p>To do so, this device acts as an USB ethernet device, and you can connect using the SSH protocol. \
On a non-demo device the username, password and IP addresses can be found here.</p>")
}
