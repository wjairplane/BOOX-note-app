import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import common

import ark.tokens as ArkTokens
import ark.controls as ArkControls

ColumnLayout {
    id: root

    property alias currentIndex: pathView.currentIndex // this value is changed when navigating from the spinner, other components are bound with it
    readonly property alias currentItem: pathView.currentItem // expose pathView.currentItem to the outside world (testing purpose)
    property alias model: pathView.model
    readonly property alias elementHeight: pathView.itemHeight

    property int _maxVisible: 5
    property int _step: 1
    property int _scrollDirection: Spinner.ScrollDirection.None

    readonly property int _padding: 24

    enum ScrollDirection {
        None,
        Up,
        Down
    }

    signal newElement(var elt)

    spacing: 0
    implicitWidth: pathView.childrenRect.width // take the highest width among all the patview's children

    function scrollUp(step) {
        currentIndex = (currentIndex - step) % pathView.count;
        newElement(currentItem.modelData);
    }

    function scrollDown(step) {
        currentIndex = (currentIndex + step) % pathView.count;
        newElement(currentItem.modelData);
    }

    ArkControls.Icon {
        objectName: "upArrow"
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        source: "qrc:/ark/icons/chevron_up"
        size: ArkControls.Values.iconSize.large

        MouseArea {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            height: parent.height * 1.5
            width: parent.width * 1.5
            onClicked: scrollUp(root._step)
            onPressAndHold: {
                _scrollDirection = Spinner.ScrollDirection.Up;
                scrollTimer.start();
            }
            onReleased: scrollTimer.stop()
        }

    }

    PathView {
        id: pathView
        objectName: "pathContainer"

        property real itemHeight: height / _maxVisible

        Layout.fillHeight: true
        Layout.fillWidth: true
        pathItemCount: _maxVisible
        interactive: false
        highlightMoveDuration: 0
        preferredHighlightBegin: 0.5 // used to center the selected item
        preferredHighlightEnd: 0.5 // used to center the selected item
        highlightRangeMode: PathView.StrictlyEnforceRange
        delegate: SpinnerItem {}
        path: Path {
            startX: pathView.width / 2
            startY: 0

            PathLine {
                x: pathView.width / 2
                y: pathView.height
            }
        }
    }

    ArkControls.Icon {
        objectName: "downArrow"
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        source: "qrc:/ark/icons/chevron_down"
        size: ArkControls.Values.iconSize.large

        MouseArea {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            height: parent.height * 1.5
            width: parent.width * 1.5
            onClicked: scrollDown(root._step)
            onPressAndHold: {
                _scrollDirection = Spinner.ScrollDirection.Down;
                scrollTimer.start();
            }
            onReleased: {
                _scrollDirection = Spinner.ScrollDirection.None;
                scrollTimer.stop()
            }
        }
    }

    Timer {
        id: scrollTimer
        repeat: true
        interval: 500
        triggeredOnStart: true
        onTriggered: {
            if (_scrollDirection === Spinner.ScrollDirection.Up) {
                scrollUp(5);
            } else if (_scrollDirection === Spinner.ScrollDirection.Down) {
                scrollDown(5);
            }
        }
    }

    component SpinnerItem: Item {
        required property var modelData
        required property int index

        readonly property int normalElementHeight: 80
        readonly property int selectedElementHeight: 112
        readonly property bool selected: pathView.currentIndex === index

        implicitWidth: body.implicitWidth + (2 * _padding)
        height: selected ? selectedElementHeight : normalElementHeight

        ArkControls.Label {
            id: body
            type: selected ? ArkControls.Label.ExtraLargeStrong : ArkControls.Label.LargeSubtle
            anchors.centerIn: parent
            text: modelData.label ?? modelData
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                currentIndex = index;
                root.newElement(currentItem.modelData);
            }
        }
    }
}
