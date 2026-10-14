import QtQuick
import com.remarkable
import common

Item {
    id: root

    property int fontSize: 10
    property var status: Page.None
    property bool runningOnDevice
    property string documentId
    property string pageId
    property string details
    visible: status !== Page.Ready && status !== Page.None

    function findTitleText() {
        switch (root.status) {
        case Page.LowMemoryError:
            return qsTr("Unable to view page. Low on memory.");
        case Page.LoadError:
            return qsTr("Unable to view page");
        case Page.TooLargeError:
            return qsTr("Stroke limit reached");
        case Page.StorageError:
            return qsTr("Unable to save page");
        case Page.Locked:
            return qsTr("Document is being synced");
        case Page.VersionError:
             return qsTr("Update software to view");
        }
        return "";
    }

    function findContentText() {
        switch (root.status) {
        case Page.VersionError:
            return qsTr("This document is not supported by your current software version.\nPlease check for updates");
        case Page.Locked:
            return qsTr("Please close and try again later");
        case Page.TooLargeError:
            return qsTr("Please start a new page or erase something to make further changes");
        case Page.LowMemoryError:
        case Page.LoadError:
        case Page.StorageError:
            return runningOnDevice
                ? qsTr("Try restarting your reMarkable or contact support if the problem persists")
                : qsTr("Try restarting your application or contact support if the problem persists");
        }
        return "";
    }

    Column {
        id: textInfo
        anchors.centerIn: parent
        width: parent.width - 2 * titleText.font.pixelSize

        Text {
            id: titleText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            font.pixelSize: root.fontSize * 1.2
            text: findTitleText()
        }

        Text {
            id: contentText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.bold: false
            font.pixelSize: root.fontSize
            text: findContentText()
            wrapMode: Text.WordWrap
        }
    }

    Column {
        id: debugInfo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: Values.designGridVerticalSpacing * 3

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            font.pixelSize: root.fontSize * 0.8
            text: qsTr("Diagnostic information:")
        }
        Text {
            font.pixelSize: root.fontSize * 0.8
            text: documentId
        }
        Text {
            font.pixelSize: root.fontSize * 0.8
            text: pageId
        }
        Text {
            font.pixelSize: root.fontSize * 0.8;
            text: details
        }

        Text {
            font.pixelSize: root.fontSize * 0.8
            text: UserInfo.id
        }
        Text {
            font.pixelSize: root.fontSize * 0.8
            text: NetworkClient.userAgent
        }
    }
}
