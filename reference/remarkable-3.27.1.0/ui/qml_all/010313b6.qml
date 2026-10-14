import QtQuick
import QtQuick.Layouts

import xofm.libs.qtgui
import xofm.libs.controls   // InputBlocker
import ark.controls as ArkControls

BaseView {
    id: root

    property string thumbnail: ""
    property string title: ""

    onOpened: (args) => {
        const { fileThumbnail = "", fileTitle = "" } = args;
        root.thumbnail = fileThumbnail;
        root.title = fileTitle;
    }

    function close() {
        root.windowNavigator.close();
    }

    contentItem: PreviewFile {
        thumbnailSrc: root.thumbnail
        title: root.title

        onClose: root.close()
    }
}
