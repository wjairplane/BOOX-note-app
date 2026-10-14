import QtQuick
import com.remarkable
import common
import device.ui.text

/**
    HeaderActions is a HeaderContainer that contains a Row of actions.
*/
HeaderContainer {
    id: root
    objectName: "HeaderActions"

    property alias text: infoText.text
    property alias textItem: infoText
    property alias align: infoText.horizontalAlignment
    property alias actions: _row.children
    readonly property alias row: _row

    signal hideFoldouts

    function findAction(title) {
        const buttons = _row.children;
        for (let i in buttons) {
            let button = buttons[i];
            if (button.title === title) {
                return button;
            }
        }
        return null;
    }

    function findActionIndex(title) {
        const buttons = _row.children;
        for (let i in buttons) {
            const button = buttons[i];
            if (button.title === title) {
                return i;
            }
        }
        return 0;
    }

    height: Values.navigatorSidebarItemHeight
    rejectText: qsTr("Close")

    onVisibleChanged: {
        if (!visible) {
            root.hideFoldouts();
        }
    }
    onActivated: (element) => {
        if (element) {
            element.clicked(null);
        }
    }

    component Action: HeaderButton {
        readonly property HeaderActions headerActions: parent?._headerActions

        required iconSource

        baselineOffset: parent.baselineOffset
        inverted: !headerActions?.blackOnWhite
        navigationHandler: headerActions
    }

    FontMetrics {
        id: fontMetrics
        font: infoText.font
    }

    TextHeaderRegular {
        id: infoText

        color: blackOnWhite ? Values.colorBlack : Values.colorWhite
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideMiddle
        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: fontMetrics.descent / 2
            left: parent.left
            right: parent.right
            leftMargin: horizontalAlignment === Text.AlignHCenter ? 0 : rejectItem.width + Values.navigatorHeaderTitleMargin
            rightMargin: horizontalAlignment === Text.AlignHCenter ? 0 : _row.width + Values.navigatorHeaderTitleMargin
            margins: horizontalAlignment === Text.AlignHCenter ? Math.max(_row.width, rejectItem.width) + Values.navigatorHeaderTitleMargin : 0
        }
    }

    Row {
        id: _row

        property alias _headerActions: root

        height: parent.height
        anchors.right: parent.right
        baselineOffset: root.rejectItem.baselineOffset
    }
}
