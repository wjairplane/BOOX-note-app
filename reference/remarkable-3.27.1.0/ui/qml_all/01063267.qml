import QtQuick
import QtQuick.Controls as QtQuickControls
import com.remarkable
import common
import device.ui.text
import device.ui.controls

import QtQuick.Layouts
import ark.tokens as ArkTokens
import ark.controls as ArkControls

Background {
    id: root

    width: parent.width
    height: parent.height
    color: Values.colorWhite

    /// a list of pages passed in at declaration time
    property var initialPages: []

    /// the ordered list of pages used internally
    property var pageSource: []

    property bool showBackButton: !!pageStack.currentItem && pageStack.currentItem.showBackButton && pageStack.depth > 1
    property bool showSkipButton: !!pageStack.currentItem && pageStack.currentItem.showSkipButton && !notificationBar.visible
    property var windowLayout

    required property var insecureSettings

    readonly property string currentPage: pageStack.currentItem.stateName

    signal setupFinished

    // end of internal pages

    function stepBack() {
        if (pageStack.depth === 1) {
            setupFinished();
            return;
        }
        showPage(null);
    }

    function stepForward() {
        for (let i = pageStack.depth - 1; i < pageSource.length; ++i) {
            if (pageStack.currentItem === pageSource[i]) {
                for (++i; i < pageSource.length; ++i) {
                    if (pageSource[i].pageReady) {
                        showPage(pageSource[i]);
                        return;
                    }
                }
            }
        }

        if (pageSource.length > 0
                && pageStack.currentItem === pageSource[pageSource.length - 1]) {
            finishSetup();
            return;
        }

        console.warn("No next state to go forward to in setup");
    }

    function skipToEnd() {
        if (pageSource.length > 0) {
            showPage(pageSource[pageSource.length - 1]);
        }
    }

    // skip to the next "ready" page in the whole list of pages (pageSource)
    function skipToNextPage() {
        // pageStack is the StackView; "depth" is the amount of stacked items so far
        // so, start counting from (depth + 1), since the pageSource starts its index at 0
        for (let i = pageStack.depth + 1; i < pageSource.length; ++i) {
            if (pageSource[i].pageReady) {
                showPage(pageSource[i]);
                return;
            }
        }
        // Can't find a matching hint, so skip to the end
        skipToEnd();
    }

    function showPage(page) {
        if (pageStack.currentItem) {
            pageStack.currentItem.forward.disconnect(root.stepForward);
            pageStack.currentItem.skipToEnd.disconnect(root.skipToEnd);
            pageStack.currentItem.skipToNextPage.disconnect(root.skipToNextPage);
            pageStack.currentItem.QtQuickControls.StackView.visible = false;
        }
        if (page && page !== pageStack.currentItem) {
            pageStack.push(page);
        } else if (!page) {
            while (pageStack.depth > 1) {
                pageStack.pop();
                if (pageStack.currentItem.pageReady) {
                    break;
                }
            }
        }
        if (pageStack.currentItem) {
            pageStack.currentItem.forward.connect(root.stepForward);
            pageStack.currentItem.skipToEnd.connect(root.skipToEnd);
            pageStack.currentItem.skipToNextPage.connect(root.skipToNextPage);
            if (insecureSettings?.setup) {
                // If the user quits the full setup (not the seabird-only setup) mid-way through
                // the process, allow the setup to be restored at the last seen page.
                Settings.setupState = pageStack.currentItem.stateName;
            }
            // SetupBasePage defaults to StackView.visible to hide the page initially, so now make
            // the new page visible.
            pageStack.currentItem.QtQuickControls.StackView.visible = true;
        }
        notificationBar.visible = false;
    }

    function finishSetup() {
        setupFinished();
    }

    /// Resume from the saved setup state or the first page if none saved
    function resumeSetup() {
        let state = Settings.setupState;
        let s = !!state ? pageSource.findIndex(e => e.stateName === state) : 0;

        let i = 0;
        let firstPageIndex = -1;

        // Find the first setup page that can be pushed.
        for (i = 0; i < pageSource.length; ++i) {
            if (pageSource[i].pageReady) {
                pageStack.push(pageSource[i]);
                firstPageIndex = i;
                break;
            }
        }
        // Push the rest of the pages, up to and including the saved setup page.
        for (i = firstPageIndex + 1; i <= s; ++i) {
            if (pageSource[i].pageReady) {
                pageStack.push(pageSource[i]);
            }
        }
        showPage(pageStack.currentItem);
    }

    SetupView {
        id: pageStack
        objectName: "pageStack"
        anchors.fill: parent
        focus: true

        Component.onCompleted: {
            for (const p of initialPages) {
                if (!p) {
                    console.warn("Found invalid setup page! Skipping it...")
                    continue;
                }
                pageSource.push(p);
            }

            if (pageSource.length > 0) {
                resumeSetup();
            } else {
                setupFinished();
            }
        }

        Component.onDestruction: {
            // Protect against cases where the current page may incidentally emit signals to move
            // backwards or forwards on the stack after destruction.
            if (currentItem) {
                currentItem.forward.disconnect(root.stepForward);
                currentItem.skipToEnd.disconnect(root.skipToEnd);
                currentItem.skipToNextPage.disconnect(root.skipToNextPage);
            }
        }
    }

    // When notification is visible, any mouse events on the page cancels the action.
    MouseArea {
        anchors.fill: pageStack
        enabled: notificationBar.visible
        onPressed: function(event) {
            notificationBar.visible = false;
            event.accepted = false;
        }
    }

    ArkControls.Button {
        id: backButton
        objectName: "backButton"
        focusPolicy: Qt.NoFocus
        z: 2
        anchors {
            top: parent.top
            topMargin: ArkControls.Values.spacing.small
            left: parent.left
        }
        enabled: root.showBackButton
        opacity: enabled ? 1 : 0

        type: ArkTokens.Button.tertiary
        textPosition: ArkControls.Button.TextPosition.Right
        iconSource: "qrc:/ark/icons/chevron_left"
        text: qsTr("Back")

        onClicked: {
            if (notificationBar.visible) {
                notificationBar.visible = false;
                return;
            }
            if (!pageStack.currentItem.handleBack()) {
                stepBack();
            }
        }
    }

    ArkControls.NotificationBar {
        id: notificationBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        visible: false

        ArkControls.NotificationBar.Message {
            text: !!pageStack.currentItem ? pageStack.currentItem.notificationMessage : ""
            iconSource: "qrc:/ark/icons/information_circle"
            Layout.fillWidth: true
            Layout.leftMargin: ArkControls.Values.padding.large
            Layout.rightMargin: ArkControls.Values.padding.large
        }

        ArkControls.NotificationBar.Divider {}

        ArkControls.NotificationBar.Button {
            objectName: "confirmNotificationButton"
            focusPolicy: Qt.NoFocus
            text: qsTr("Confirm")
            onClicked: pageStack.currentItem.notificationConfirmed()
        }
    }

    ArkControls.Button {
        id: skipButton
        objectName: "skipButton"
        focusPolicy: Qt.NoFocus
        anchors {
            right: parent.right
            rightMargin: ArkControls.Values.padding.large
            bottom: parent.bottom
            bottomMargin: ArkControls.Values.padding.large
                + (Qt.inputMethod && Qt.inputMethod.visible && !KeyboardInfo.keyboardConnected ? Qt.inputMethod.keyboardRectangle.height : 0)
        }
        visible: root.showSkipButton
        type: ArkTokens.Button.tertiary
        textPosition: ArkControls.Button.TextPosition.Left
        text: !!pageStack.currentItem ? pageStack.currentItem.skipText : qsTr("Skip")

        onClicked: {
            if (pageStack.currentItem.notificationMessage.length) {
                pageStack.currentItem.notificationShown();
                notificationBar.visible = true;
                return;
            }
            if (!pageStack.currentItem.handleSkip()) {
                stepForward();
            }
        }
    }

    Row {
        id: progressIndicatorRow

        readonly property int progressMarkerHeight: 6
        readonly property int currentPageIndex: {
            // Avoid spurious updates before the pagestack state is intialized.
            if (!pageStack.currentItem
                    || Settings.setupState !== pageStack.currentItem.stateName) {
                return -1;
            }
            let pageIndex = 0;
            for (let i = 0; i < pageSource.length; ++i) {
                if (pageSource[i].includeInProgressCount) {
                    pageIndex++;
                }
                if (pageSource[i] === pageStack.currentItem) {
                    return pageIndex;
                }
            }
            return -1;
        }
        readonly property int totalPageCount: {
            // Avoid spurious updates before the pagestack state is intialized.
            if (!pageStack.currentItem
                    || Settings.setupState !== pageStack.currentItem.stateName) {
                return 0;
            }
            let pageCount = 0;
            for (let i = 0; i < pageSource.length; ++i) {
                if (pageSource[i].includeInProgressCount) {
                    pageCount++;
                }
            }
            return pageCount;
        }

        anchors {
            left: backButton.right
            right: parent.right
            rightMargin: progressIndicatorRow.x
            verticalCenter: backButton.verticalCenter
            verticalCenterOffset: - (progressIndicatorRow.progressMarkerHeight / 2)
        }
        height: Values.outlineSize
        visible: !!insecureSettings?.setup // don't show for seabird setup outside of full setup flow
                && totalPageCount > 1
                && pageStack.currentItem && pageStack.currentItem.showProgressIndicator

        Repeater {
            model: progressIndicatorRow.totalPageCount
            delegate: Row {
                width: Math.round(progressIndicatorRow.width / Math.max(1, progressIndicatorRow.totalPageCount))
                height: progressIndicatorRow.progressMarkerHeight

                Rectangle {
                    id: progressSpacing
                    width: 8
                    height: parent.height
                    color: model.index < progressIndicatorRow.currentPageIndex ? Values.colorBlack : "transparent"
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - progressSpacing.width
                    height: model.index < progressIndicatorRow.currentPageIndex ? 6 : 2
                    color: Values.colorBlack
                }
            }
        }
    }
}
