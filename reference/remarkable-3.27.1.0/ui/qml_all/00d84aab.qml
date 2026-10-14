import QtQuick
import QtQuick.Controls
import com.remarkable
import common

import ark.controls as ArkControls
import xofm.libs.epaper as Epaper

FocusScope {
    id: scrollContainer

    readonly property bool isFluid: _flickable.interactive

    property color color: Values.colorBlack
    property Item view
    property Flickable _flickable: view && view instanceof Loader ? view.item : view
    property alias overlayItem: overlay
    default property alias overlayItems: overlay.children

    property real leftMargin
    property real rightMargin
    property real topMargin
    property real bottomMargin

    property int orientation: Qt.Vertical

    property real horizontalStepSize: Math.max(0, width - leftMargin - rightMargin) / 2
    property real verticalStepSize: Math.max(0, height - topMargin - bottomMargin) / 2

    property real scrollThreshold: 50

    property bool interactive: true
    property bool keysEnabled: false
    property bool scrollPastMaximum: false
    property bool scrollPastMinimum: false

    readonly property int scrollIndicatorTimeout: 3000
    property bool enableScrollbar: false
    readonly property int scrollbarWidth: 6
    property int scrollbarTopMargin: ArkControls.Values.margin.vertical.medium
    property int scrollbarBottomMargin: ArkControls.Values.margin.vertical.medium
    property int scrollbarRightMargin: 0
    // If true, this will filter drag events from child items even if the flickable cannot scroll
    // any further. This prevents accidental clicks when trying to scroll but it also means if you
    // have a ScrollContainer inside of a ScrollContainer you'll have to drag outside of the inner
    // one to scroll the outer one, instead of the inner one scrolling as far as it can go and then
    // the outer one scrolling.
    property bool filterDrags: true

    readonly property real originX: _flickable && _flickable.originX || 0
    readonly property real originY: _flickable && _flickable.originY || 0

    readonly property real contentX: scrollContainer._flickable?.contentX ?? 0
    readonly property real contentY: scrollContainer._flickable?.contentY ?? 0

    property real minimumContentX: originX
    property real maximumContentX: originX + Math.max(0, _flickable ? _flickable.contentWidth - _flickable.width : 0)
    property real minimumContentY: originY
    property real maximumContentY: originY + Math.max(0, _flickable ? _flickable.contentHeight - _flickable.height : 0)

    readonly property bool contentOutsideView: _flickable.height < _flickable.contentHeight
    property bool _maybeScroll

    signal startedMoving()

    function scrollDown() {
        _maybeScroll = false;
        _flickable.contentY = Math.min(_flickable.contentY + verticalStepSize, maximumContentY);
    }

    function scrollUp() {
        _maybeScroll = false;
        _flickable.contentY = Math.max(_flickable.contentY - verticalStepSize, minimumContentY);
    }

    function scrollRight() {
        _maybeScroll = false;
        if (scrollPastMaximum) {
            if (_flickable.contentX < (_flickable.contentWidth - horizontalStepSize)) {
                _flickable.contentX += horizontalStepSize;
            }
        } else {
            _flickable.contentX = Math.min(_flickable.contentX + horizontalStepSize, maximumContentX);
        }
    }

    function scrollLeft() {
        _maybeScroll = false;
        if (scrollPastMinimum) {
            if (_flickable.contentX > horizontalStepSize) {
                _flickable.contentX -= horizontalStepSize;
            }
        } else {
            _flickable.contentX = Math.max(_flickable.contentX - horizontalStepSize, minimumContentX);
        }
    }

    onViewChanged: {
        if (view) {
            view.anchors.fill = Qt.binding(() => { return view.parent });
            view.anchors.leftMargin = Qt.binding(() => { return scrollContainer.leftMargin });
            view.anchors.rightMargin = Qt.binding(() => { return scrollContainer.rightMargin });
            view.anchors.topMargin = Qt.binding(() => { return scrollContainer.topMargin });
            view.anchors.bottomMargin = Qt.binding(() => { return scrollContainer.bottomMargin });
            view.parent = contentItem;
            // Proxy focus to the view when it is a focus scope.
            view.focus = view instanceof Loader || view instanceof ListView || view instanceof GridView;
        }
    }

    Connections {
        target: _flickable
        enabled: scrollContainer.enableScrollbar
        function onContentYChanged() {
            scrollIndicatorTimer.restart();
        }
    }

    Flickable {
        id: dragArea

        interactive: scrollContainer.interactive && !scrollContainer.isFluid

        anchors.fill: scrollContainer
        contentX: 0
        contentY: 0
        contentWidth: width
        contentHeight: height

        leftMargin: scrollContainer.filterDrags || (scrollContainer.orientation == Qt.Horizontal
                    && scrollContainer.contentX > scrollContainer.minimumContentX)
                ? 10000
                : 0
        rightMargin: scrollContainer.filterDrags || (scrollContainer.orientation == Qt.Horizontal
                    && scrollContainer.contentX < scrollContainer.maximumContentX)
                ? 10000
                : 0
        topMargin: scrollContainer.filterDrags || (scrollContainer.orientation == Qt.Vertical
                    && scrollContainer.contentY > scrollContainer.minimumContentY)
                ? 10000
                : 0
        bottomMargin: scrollContainer.filterDrags || (scrollContainer.orientation == Qt.Vertical
                    && scrollContainer.contentY < scrollContainer.maximumContentY)
                ? 10000
                : 0

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: {
            if (scrollContainer.filterDrags) {
                return Flickable.HorizontalAndVerticalFlick;
            } else if (scrollContainer.orientation == Qt.Vertical) {
                return Flickable.VerticalFlick;
             } else {
                return Flickable.HorizontalFlick;
             }
        }
        pressDelay: 0
        synchronousDrag: true

        // Drag ended emits, then the flickable evaluates if it's flicking and we'd like to abort the flick and reset
        // the content position after the drag ends.
        onDragEnded: {
            scrollContainer._maybeScroll = true;
        }

        onFlickStarted: {
            scrollContainer._maybeScroll = false;
            // If flickable has deemed the gesture worthy of a flick then scroll even if the scroll distance
            // hasn't been exceeded.
            if (scrollContainer.orientation == Qt.Vertical && flickingVertically && verticalVelocity > 0) {
                scrollContainer.scrollDown();
            } else if (scrollContainer.orientation == Qt.Vertical && flickingVertically && verticalVelocity < 0) {
                scrollContainer.scrollUp();
            } else if (scrollContainer.orientation == Qt.Horizontal && flickingHorizontally && horizontalVelocity > 0) {
                scrollContainer.scrollRight();
            } else if (scrollContainer.orientation == Qt.Horizontal && flickingHorizontally && horizontalVelocity < 0) {
                scrollContainer.scrollLeft();
            }

            dragArea.contentX = 0;
            dragArea.contentY = 0;
        }

        onMovementEnded: {
            if (!scrollContainer._maybeScroll) {
                return;
            }

            if (scrollContainer.orientation == Qt.Vertical && dragArea.contentY >= scrollContainer.scrollThreshold) {
                scrollContainer.scrollDown();
            } else if (scrollContainer.orientation == Qt.Vertical && dragArea.contentY <= -scrollContainer.scrollThreshold) {
                scrollContainer.scrollUp();
            } else if (scrollContainer.orientation == Qt.Horizontal && dragArea.contentX >= scrollContainer.scrollThreshold) {
                scrollContainer.scrollRight();
            } else if (scrollContainer.orientation == Qt.Horizontal && dragArea.contentX <= -scrollContainer.scrollThreshold) {
                scrollContainer.scrollLeft();
            }

            dragArea.contentX = 0;
            dragArea.contentY = 0;
        }

        onMovementStarted: scrollContainer.startedMoving()

        Keys.enabled: scrollContainer.keysEnabled && !!scrollContainer._flickable
        Keys.onDownPressed: (event) => {
            if (orientation == Qt.Vertical && scrollContainer.contentY < scrollContainer.maximumContentY) {
                event.accepted = true;
                scrollDown();
            } else {
                event.accepted = false;
            }
        }
        Keys.onUpPressed: (event) => {
            if (orientation == Qt.Vertical && scrollContainer.contentY > scrollContainer.minimumContentY) {
                event.accepted = true;
                scrollUp();
            } else {
                event.accepted = false;
            }
        }
        Keys.onRightPressed: (event) => {
            if (orientation == Qt.Horizontal && scrollContainer.contentX < scrollContainer.maximumContentX) {
                event.accepted = true;
                scrollRight();
            } else {
                event.accepted = false;
            }
        }
        Keys.onLeftPressed: (event) => {
            if (orientation == Qt.Horizontal && scrollContainer.contentX > scrollContainer.minimumContentX) {
                event.accepted = true;
                scrollLeft();
            } else {
                event.accepted = false;
            }
        }

        children: [
            Item {
                id: contentItem

                anchors.fill: dragArea
            },
            Item {
                id: overlay

                anchors.fill: dragArea
            }
        ]
    }
    ScrollIndicator {
        id: scrollIndicator
        visible: enableScrollbar && contentOutsideView && scrollIndicatorTimer.running
        active: enableScrollbar
        topPadding: scrollbarTopMargin
        bottomPadding: scrollbarBottomMargin
        rightPadding: scrollbarRightMargin
        size: scrollContainer.height / _flickable.contentHeight
        position: (_flickable.contentY - originY) / _flickable.contentHeight
        minimumSize: calculateMinimumSize()
        anchors {
            top: parent.top;
            right: parent.right;
            bottom: parent.bottom
        }
        contentItem: Rectangle {
            implicitWidth: scrollbarWidth
            color: Values.colorBlack
        }
        function calculateMinimumSize() {
            // When the indicator becomes smaller, minimum size
            // should be bigger so it's easier to see.
            if (scrollContainer.height < 600) {
                return 0.3;
            } else if (scrollContainer.height < 1000) {
                return 0.25;
            }
            return 0.2;
        }
    }
    Rectangle {
        id: contentHeightIndicator
        visible: scrollIndicator.visible
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            rightMargin: scrollbarRightMargin
            topMargin: scrollbarTopMargin
            bottomMargin: scrollbarBottomMargin
        }
        width: 2
        color: Values.colorBlack
    }

    Timer {
        id: scrollIndicatorTimer
        interval: scrollIndicatorTimeout
    }

    Epaper.ScreenModeItem {
        id: screenMode
        property bool active: false
        objectName: "scroll-container"
        anchors.fill: parent
        visible: active || screenModeTimer.running
        mode: Epaper.ScreenModeItem.Animation

        Timer {
           id: screenModeTimer
           interval: 1000
        }

        Connections {
            target: _flickable
            enabled: isFluid
            function onMovementStarted() {
               screenMode.active = true;
            }
            function onMovementEnded() {
               screenModeTimer.start();
               screenMode.active = false;
            }
        }
    }
}
