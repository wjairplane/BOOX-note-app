import QtQuick
import com.remarkable
import common
import device.ui.text

/**
  Header is a HeaderContainer that is used by various dialogs.
*/
HeaderContainer {
    id: root
    objectName: "Header"

    property alias text: infoText.text
    property alias textItem: infoText

    property alias acceptText: rightButton.title
    property alias acceptIconSource: rightButton.iconSource
    property alias acceptItem: rightButton
    property bool acceptEnabled: false

    signal accepted

    function accept() {
        dismiss();
        accepted();
    }

    FontMetrics {
        id: fontMetrics
        font: infoText.font
    }

    TextHeaderRegular {
        id: infoText
        color: blackOnWhite ? Values.colorBlack : Values.colorWhite
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        anchors {
            left: parent.left
            right: parent.right
            margins: Math.max(rejectItem.width, acceptItem.width)
            verticalCenter: parent.verticalCenter
        }
    }

    // Right button
    HeaderButton {
        id: rightButton
        title: qsTr("Confirm")
        onClicked: accept()
        inverted: !blackOnWhite
        anchors.right: parent.right
        visible: root.acceptEnabled
    }
}
