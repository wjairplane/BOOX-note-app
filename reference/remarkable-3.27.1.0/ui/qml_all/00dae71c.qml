import QtQuick
import QtQuick.Layouts
import device.ui.headers
import device.ui.controls
import com.remarkable
import common

import xofm.libs.epub
import xofm.libs.dialogs

Background {
    id: root

    required property Document document
    required property EpubSettings epubSettings
    property bool _hasConfirmedLayoutChange

    signal formattingApplied

    function show() {
        visible = true;
    }

    function close() {
        visible = false;
    }

    function resetConfirmedLayoutChange() {
        _hasConfirmedLayoutChange = false;
    }

    function confirmLayoutChange(action) {
        const wrappedAction = function() {
            action();
            formattingApplied();
        };

        // This should be changed to property binding so accessing the
        // object is not needed
        if (document.hasContentsOnAnyPage() && !_hasConfirmedLayoutChange) {
            confirmLayoutChangeDialog.visible = true;
            confirmLayoutChangeDialog.acceptedAction = wrappedAction;
        } else {
            wrappedAction();
        }
    }

    height: layout.height
    visible: false

    Component.onCompleted: header.show()

    CloseShortcut {
        onActivated: root.close()
    }

    EpubProperties {
        id: epubProperties
        document: root.document
        documentController: DocumentController
        settings: root.epubSettings
    }

    ColumnLayout {
        id: layout
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        spacing: 0

        Header {
            id: header
            Layout.fillWidth: true
            Layout.bottomMargin: -Values.outlineSize
            text: qsTr("Text settings")
            blackOnWhite: false
            acceptText: qsTr("Save")
            rejectText: qsTr("Reset")
            acceptEnabled: true
            onRejected: {
                var action = function () {
                    epubProperties.reset()
                }
                confirmLayoutChange(action);
            }
            onAccepted: root.close()
        }

        ColumnLayout {
            Layout.maximumHeight: Values.documentViewFormatHeight
            Layout.minimumHeight: Values.documentViewFormatHeight
            spacing: 0

            RowLayout {
                spacing: 0
                Layout.maximumHeight: Math.floor(parent.height / 2)

                FormatTextSize {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    epub: epubProperties
                }

                Rectangle {
                    width: Values.outlineSize
                    Layout.fillHeight: true
                    color: Values.colorBlack
                }

                FormatFont {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    epub: epubProperties
                }
            }

            Rectangle {
                height: Values.outlineSize
                Layout.fillWidth: true
                color: Values.colorBlack
            }

            RowLayout {
                spacing: 0
                Layout.fillWidth: true
                Layout.maximumHeight: Math.floor(parent.height / 2)

                FormatAlignment {
                    Layout.minimumWidth: Math.floor(layout.width * 2 / 8)
                    Layout.fillHeight: true
                    epub: epubProperties
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: Values.outlineSize
                    color: Values.colorBlack
                }

                FormatMargins {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    epub: epubProperties
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: Values.outlineSize
                    color: Values.colorBlack
                }

                FormatLineSpacing {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    epub: epubProperties
                }
            }

            Rectangle {
                height: Values.outlineSize
                Layout.fillWidth: true
                color: Values.colorBlack
            }
        }
    }

    ConfirmChangeDialog {
        id: confirmLayoutChangeDialog

        visible: false
        width: parent.width
        height: implicitHeight
        bottomPadding: 0
        title: qsTr("Misalignment may occur")
        description: qsTr("Your annotations, highlights or doodles may lose its alignment with the changed settings. Please confirm that you want to proceed, as this could be irreversible.")
        confirmButtonText: qsTr("Confirm")
        rejectButtonText: qsTr("Cancel")

        onAccepted: {
            _hasConfirmedLayoutChange = true;
            confirmLayoutChangeDialog.visible = false;
        }
        onRejected: {
            confirmLayoutChangeDialog.visible = false;
            root.close();
        }
    }
}
