import QtQuick

import com.remarkable
import common
import device.ui.controls

import xofm.libs.navigation // Entity

MouseArea {
    id: baseItem

    signal add
    signal remove
    signal open
    signal abortExport
    signal retrySync

    property bool supported: !(baseItem.type === Entity.Type.File && baseItem.filetype === Entity.FileType.Unsupported)
    property bool selected: false

    property bool moving: false
    property bool isSelectable: true
    property bool passwordProtected: false
    property bool isFavorite: false
    property bool isShared: false
    readonly property color backgroundColor: selected ? Values.colorBlack : Values.colorWhite
    readonly property color itemColor: selected ? Values.colorWhite : Values.colorBlack
    readonly property string notCompatibleText: qsTr("Not compatible")
    property string entityId
    property int filetype
    property int type

    property var syncStatus
    property real progress: 0
    property bool archivedWarningVisible: false
    property bool inactiveWarningVisible: false

    // metadata
    property string author
    property int childIndex: 0
    property int childCount: 0
    property bool hasChildren: childCount > 0
    property string publisher
    property string publicationDate

    property bool isSelecting: false
    property var navigationHandler
    property bool drawFocus: !!navigationHandler && navigationHandler.current === baseItem

    readonly property string folderIcon: {
        if (baseItem.isShared) {
            return "qrc:/ark/icons/placeholder";
        }

        if (baseItem.hasChildren) {
            return "qrc:/ark/icons/folder_inverted";
        }

        return "qrc:/ark/icons/folder";
    }

    enabled: !baseItem.moving
    onClicked: baseItem.handleClick()
    onPressAndHold: baseItem.handleLongPress()

    onIsSelectingChanged: {
        if (!baseItem.isSelecting && baseItem.selected) {
            baseItem.remove();
        }
    }

    // Used to reset the state for recycling
    function reset() {
        isSelecting = false;
        inactiveWarningVisible = false;
        archivedWarningVisible = false;
        type = Entity.Type.File;
        filetype = Entity.FileType.Unsupported;
    }

    function deselect() {
        baseItem.remove();
    }

    function select() {
        if (isSelectable && !moving) {
            baseItem.add();
        }
    }

    function handleClick() {
        if (!baseItem.supported) {
            return;
        }

        if (baseItem.moving && baseItem.selected) {
            return;
        } else if (!baseItem.moving && baseItem.isSelecting) {
            baseItem.handleLongPress();
        } else {
            baseItem.open();
        }
    }

    function handleLongPress() {
        if (!baseItem.supported) {
            return;
        }
        if (baseItem.selected) {
            baseItem.deselect();
        } else {
            baseItem.select();
        }
    }

    function formatDisplayText(childIndex, filetype, entityType, childCount) {
        if (entityType === Entity.Type.Folder) {
            //: Requires plural form
            return qsTr("%n items", "", childCount);
        }

        const pageOf = qsTr("Page %1 of %2").arg(childIndex + 1).arg(childCount);
        if (entityType === Entity.Type.Page) {
            return pageOf;
        }

        switch(filetype) {
        case Entity.FileType.Epub: {
            if (childCount < 2) {
                return qsTr("0% read");
            }
            const readPercent = Math.round(childIndex / (childCount - 1) * 100);
            return qsTr("%1\% read").arg(readPercent);
        }
        case Entity.FileType.Pdf:
        case Entity.FileType.RmDocument:
            return pageOf;
        case Entity.FileType.Unsupported:
        default:
            return "";
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: baseItem.backgroundColor
    }

    FocusFrame {
        anchors.fill: parent
        visible: baseItem.drawFocus
        borderColor: selected ? Values.colorWhite : Values.colorBlack
    }
}
