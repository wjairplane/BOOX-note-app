import QtQuick
import QtQuick.Controls as QtQuickControls
import com.remarkable
import common
import device.ui.controls

// The basic setup page.
// All other pages should use this as their base type.
FocusScope {
    id: root

    required property string stateName

    focus: QtQuickControls.StackView.status === QtQuickControls.StackView.Active

    // This item ensures that any previous remnants from another page are gone.
    Background {
        anchors.fill: parent
        color: Values.colorWhite
    }

    // Advance to the next state
    signal forward()

    // Skip to the end
    signal skipToEnd()

    // Skip to the next ready page
    signal skipToNextPage()

    // Emitted when notification bar becomes visible
    signal notificationShown()

    // Emitted when user confirms notification
    signal notificationConfirmed()

    // Set to true if the page allows going back.
    property bool showBackButton: true

    // Set to true if the page allows skipping.
    property bool showSkipButton: false

    // The text to show in the skip button.
    property string skipText: qsTr("Skip")

    /** Default back behaviour is to go to the previous state in setupState
        @return true if the back behaviour was handled within the page
     */
    function handleBack() {
        return false;
    }

    /** Default skip behaviour is to advance to the next state
        @return true if the skip behaviour was handled within the page
     */
    function handleSkip() {
        return false;
    }

    // The text to use in the notification when it is confirmed. If empty, the notification will
    // not be displayed.
    property string notificationMessage

    // Page which are not ready will be skipped
    property bool pageReady: true

    // Whether to show the page progress indicator.
    property bool showProgressIndicator: true

    // Whether the page is included in the progress indicator.
    property bool includeInProgressCount: true

    // Ensure page is initially hidden, until made visible by Setup.qml.
    QtQuickControls.StackView.visible: false
}
