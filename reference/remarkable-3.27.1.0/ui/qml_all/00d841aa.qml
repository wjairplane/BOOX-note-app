import QtQuick
import QtQuick.Layouts

import common // import Background
import com.remarkable // import QRCodeProvider

import xofm.libs.explorer // ViewManager

import ark.controls as ArkControls

ScrollArea {
    id: root

    property real topPadding: 0

    implicitWidth: emptyViewLayout.width
    implicitHeight: emptyViewLayout.implicitHeight
    contentWidth: root.width
    contentHeight: emptyViewLayout.childrenRect.height + root.topPadding + (emptyViewLayout.children.length -1) * emptyViewLayout.spacing
    enableScrollbar: true
    permanentScrollbar: true
    scrollbarRightMargin: ArkControls.Values.margin.horizontal.small_static

    clip: true

    /*
        emptyViewKey is the key for the current view which requires an empty state.
        It can be either a ViewManager.View enum value, or a string -
        For example: ViewManager.View.Favorites
                     ViewManager.activeView
                     "noTagsCombination"
        Take a look at the emptyViewMap at the bottom for available empty states keys.
    */
    required property var emptyViewKey

    function getEmptyViewContent(emptyViewKey) {
        return emptyViewMap[emptyViewKey] ?? { icon: "", title: "", subText: "", qrLink: "", qrText: "" };
    }

    readonly property var emptyViewContent: getEmptyViewContent(emptyViewKey)

    ColumnLayout {
        id: emptyViewLayout
        objectName: "emptyViewLayout"
        anchors.horizontalCenter: parent.horizontalCenter
        width: 716
        spacing: ArkControls.Values.platform.spacing.x2large

        Image {
            id: emptyViewIcon
            objectName: "emptyViewIcon"
            source: root.emptyViewContent.icon
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: root.topPadding
            visible: {
                // Derived from looking at the contentHeight when using default values.
                const preferredHeight = 748;
                const isLandscapeMode = root.width > root.height;
                const hasEnoughHeight = root.height >= preferredHeight;
                return isLandscapeMode ? hasEnoughHeight : true;
            }
        }

        ColumnLayout {
            Layout.topMargin: emptyViewIcon.visible ? 0 : root.topPadding
            spacing: ArkControls.Values.platform.spacing.small

            ArkControls.Title {
                id: emptyViewText
                objectName: "emptyViewText"
                type: ArkControls.Title.Large
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.emptyViewContent.title
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
            }

            ArkControls.Body {
                id: emptyViewSubText
                objectName: "emptyViewSubText"
                type: ArkControls.Body.Medium
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.emptyViewContent.subText
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
            }
        }

        Loader {
            id: emptyViewQrLoader
            active: qrProvider.imageReady
            sourceComponent: emptyViewQrCode
            Layout.fillWidth: true
        }

        Component {
            id: emptyViewQrCode

            Column {
                objectName: "emptyViewQrCode"
                height: qrImg.height + qrSubText.implicitHeight
                spacing: ArkControls.Values.spacing.medium

                Image {
                    id: qrImg
                    objectName: "qrImage"
                    source: qrProvider.imageUrl
                    fillMode: Image.PreserveAspectFit
                    height: 250
                    width: height
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ArkControls.Body {
                    id: qrSubText
                    type: ArkControls.Body.Small
                    horizontalAlignment: Text.AlignHCenter
                    text: root.emptyViewContent.qrText ?? ""
                    wrapMode: Text.WordWrap
                }
            }
        }

        QRCodeProvider {
            id: qrProvider
            objectName: "qrProvider"
            text: root.emptyViewContent.qrLink ?? ""
        }
    }

    /* -------------------- empty states data ------------------ */

    readonly property var emptyViewMap: ({
        [ViewManager.View.MyFiles]: {
            icon: "qrc:/qml/images/empty_states/Myfiles.png",
            title:  qsTr("Make your mark"),
            subText:  qsTr("Fill this with notebooks and folders. When you're in a rush, <b>press&#160;and&#160;hold</b> the plus icon to create a new quick sheet."),
        },
        [ViewManager.View.Favorites]: {
            icon: "qrc:/qml/images/empty_states/Favorites.png",
            title:  qsTr("Collect your best content"),
            subText:  qsTr("<b>Press and hold</b> any page, document, or folder, and add it to your favorites. They will appear right here."),
        },
        [ViewManager.View.Notebooks]: {
            icon: "qrc:/qml/images/empty_states/Notebooks.png",
            title: qsTr("Fill this with content", "notebooks"),
            subText: qsTr("You can create notebooks and they will appear here."),
        },
        [ViewManager.View.Pdfs]: {
            icon: "qrc:/qml/images/empty_states/PDF.png",
            title: qsTr("Create a reading list", "pdfs"),
            subText: qsTr("You can import documents as PDF files through the desktop or mobile app, and on my.remarkable.com."),
        },
        [ViewManager.View.Ebooks]: {
            icon: "qrc:/qml/images/empty_states/Ebook.png",
            title:  qsTr("Upload your library"),
            subText: qsTr("You can import books in EPUB format through the desktop or mobile app, and on my.remarkable.com."),
        },
        [ViewManager.View.Trash]: {
            icon: "qrc:/qml/images/empty_states/Trash.png",
            title: qsTr("Clear out the clutter"),
            subText: qsTr("Items you delete from My files will be shown here. You can restore or permanently delete them."),
        },
        [ViewManager.View.Tags]: {
            icon: "qrc:/qml/images/empty_states/Tags.png",
            title: qsTr("Label your work"),
            subText: qsTr("You can add tags to documents and pages to categorize your content. They will appear right here."),
        },
        "emptyFolder": {
            icon: "qrc:/qml/images/empty_states/Folder.png",
            title:  qsTr("Organize in folders"),
            subText:  qsTr("You can create documents and move any type of content or subfolder here."),
        },
        "noTagsCombination": {
            icon: "qrc:/qml/images/empty_states/Tags.png",
            title: qsTr("Try a different combination"),
            subText: qsTr("You can sort your pages with combination of tags. Select one that matches what you're looking for."),
        },
        "noComplianceStatements": {
            icon: "qrc:/qml/images/empty_states/compliance-statements.png",
            title: qsTr("Unable to show compliance statements"),
            subText: qsTr("See lower back of the device and please visit support.remarkable.com for more information."),
        },
        "noIntegrations": {
            icon: "qrc:/qml/images/empty_states/Integrations.png",
            title: qsTr("Add storage integrations"),
            subText: qsTr("To set up cloud storage services and import files, visit <b>my.remarkable.com/integrations</b>"),
            qrLink: "my.remarkable.com/integrations?utm_source=rm_device&utm_medium=qr_code&utm_campaign=integrations_empty_state",
        },
        "noMethodsTemplates": {
            icon: "qrc:/qml/images/empty_states/Imported.png",
            title: qsTr("Import inspiring templates"),
            subText: qsTr("Discover our go-to resource for the latest templates, tools, and tips from <b>methods.remarkable.com</b>"),
            qrLink: "https://methods.remarkable.com?rm_utm_source=empty_state&rm_utm_campaign=methods",
        },
        "noConnectHWS": {
            icon: "qrc:/qml/images/empty_states/Search.png",
            title: qsTr("Search with Connect"),
            subText: qsTr("In order to search for written content, activate your free trial, or subscribe at <b>remarkable.com/store/connect</b>."),
            qrLink: "https://remarkable.com/store/connect?rm_utm_source=empty_state&rm_utm_campaign=connect_hws_filter",
        },
    })
}
