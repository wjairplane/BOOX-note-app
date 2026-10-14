import QtQuick

import com.remarkable
import common
import device.ui.text
import ark.controls as ArkControls
import ark.tokens as ArkTokens

DeviceKeyboardNavigationHandler {
    id: root

    // Can be used to limit tabs in accessible mode
    property int maximumTabWidth: 1000

    // Model can be any js-array, i.e ["first", "second", "third"]
    property alias model: categoryRepeater.model

    // Optional function (index, model) returning title for a tab
    // If undefined, model[index] will be returned as tab title
    property var valueFunction

    // The current tab index.
    property int currentIndex: 0

    // here so you can change the text on the "Close button"
    property alias closeText: closeButton.text

    // The visible tab count
    readonly property alias count: categoryRepeater.count

    // Optional property for showing a close button in the right corner.
    property bool showCloseButton: false

    // Show the top border line
    property bool showTopBorderLine: false

    // Close button sends a signal if clicked
    signal closeButtonClicked

    // The visible title of a tab at index
    function tabTitle(index) {
        let title = "";
        if (!root.model || index >= root.model.length) {
            console.warn("Invalid model index");
            return title;
        }

        if (!root.valueFunction) {
            return root.model[index];
        }

        return root.valueFunction(index, root.model);
    }

    // Returns the tab Item for a given index.
    function tabForIndex(index) {
        return categoryRepeater.itemAt(index);
    }

    width: parent.width
    height: Values.navigatorSidebarItemHeight

    implicitWidth: flow.width
    implicitHeight: flow.height

    navigationModel: {
        // convert from a qml basic type list (tagFlow.children) to array
        let navModel = [];
        for (let i = 0; i < flow.children.length; i++) {
            navModel.push(flow.children[i]);
        }
        if (showCloseButton) {
            navModel.push(closeButton);
        }
        return navModel;
    }

    onActivated: (element) => {
        element.activate();
    }

    Background {
        anchors.fill: parent
        color: Values.colorWhite
    }

    Rectangle {
        id: topBorderLine
        visible: showTopBorderLine
        width: parent.width
        height: 2
        color: Values.colorBlack
    }

    Flow {
        id: flow
        width: parent.width
        anchors.bottom: parent.bottom

        Repeater {
            id: categoryRepeater

            model: []
            delegate: Item {
                id: tab

                readonly property bool isCurrent: index === root.currentIndex
                readonly property int tabIndex: index
                readonly property alias text: textItem.text
                property bool drawFocus: root.current === tab

                function activate() {
                    root.currentIndex = index;
                }

                height: textItem.height
                width: Math.min(textItem.width, root.maximumTabWidth)

                SubheaderRegular {
                    id: textItem
                    height: Values.navigatorDropdownHeaderHeight
                    padding: Values.navigatorMargin
                    color: Values.colorBlack
                    text: root.tabTitle(index)
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    id: currentTabIndicator
                    width: parent.width
                    height: 6
                    anchors.bottom: parent.bottom
                    color: tab.isCurrent ? Values.colorBlack : Values.colorWhite
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.currentIndex = index
                }

                FocusFrame {
                    id: focusFrame
                    anchors.fill: parent
                    visible: tab.drawFocus
                    borderColor: Values.colorBlack
                }
            }
        }
    }

    ArkControls.Button {
        id: closeButton

        function activate() {
            root.closeButtonClicked();
        }

        visible: root.showCloseButton
        height: Values.navigatorDropdownHeaderHeight
        anchors {
            right: flow.right
            rightMargin: Values.navigatorMargin
            bottom: parent.bottom
        }
        showFocus: root.current === closeButton
        type: ArkTokens.Button.tertiary
        text: qsTr("Close")
        onClicked: closeButton.activate()
    }

    Rectangle {
        id: bottomBorder
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 2
        color: Values.colorBlack
    }
}
