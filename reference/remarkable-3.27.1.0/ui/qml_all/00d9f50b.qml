import QtQuick
import com.remarkable
import com.remarkable.devicetelemetry
import common
import device.ui.controls

FocusFrame {
    id: root
    required property Item documentView
    property Document document: null
    property int page: 0
    property var pageTags: !!document ? document.tagsForPage(page) : []
    property bool current: document?.lastOpenedPage === page
    property bool highlighted: false
    property bool selecting:  false
    property bool selected:  false
    property var navigationHandler
    property bool drawFocus: !!navigationHandler && navigationHandler.current === root

    //: This is the page's caption in the pages overview, %1 is the number of the shown page
    readonly property string pageCaption: current ? qsTr("%1 (Current)").arg(page + 1) : (page + 1).toString();

    color: selected ? Values.colorBlack : Values.colorWhite
    borderColor: {
        if (!root.drawFocus) {
            return "transparent";
        }
        return root.selected ? Values.colorWhite : Values.colorBlack;
    }

    property alias mouseArea: _mouseArea

    property bool interactive: true

    Connections {
        target: document
        function onPageTagsChanged() {
            root.pageTags = document.tagsForPage(page);
        }
    }

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        enabled: root.interactive
        onClicked: {
            if (selecting || !movePageSelection.isEmpty) {
                pageSelection.toggle(page);
                return;
            }
            if (!current) {
                pages.documentTelemetry.pageNavigated("Page Overview");
            }
            pages.reportPageAction(current ? "Page clicked Current" : "Page clicked Other");
            documentView.openPage(page, DocumentView.ScrollPosition.Restore);
        }

        onPressAndHold: {
            pageSelection.toggle(page);
        }
    }
}
