import QtQuick

import xofm.libs.onboarding
import xofm.libs.controls

import ark.controls as ArkControls
import ark.tokens as ArkTokens


/** Onboarding dialogue - walks the user through one or more pages of
    introduction.
 */
InputBlocker {
    id: intro
    anchors.fill: parent
    color: "transparent"

    // Specify a model that defines pages instead of using child components
    property var initialModel
    // Specify a custom image if you one from from outside the ArkGallery, a QR code for example
    property Component customImage: null

    property string leftButtonText: currentPage > 0 ? qsTr("Back") : ""
    property string rightButtonText: primaryButtonText()

    property alias contentItem: onboardingDialog.contentItem
    property alias closeOption: onboardingDialog.closeOption

    property int pageCount: initialModel?.length ?? (!!contentItem ? 1 : 0)
    property int currentPage: 0

    // Main signals
    signal quit
    signal finished

    // Signals used only for metrics
    signal leftButtonClicked
    signal rightButtonClicked
    signal completeButtonClicked
    signal quitButtonClicked

    function close() {
        if (!onboardingDialog.closeOption) {
            return;
        }

        intro.quitButtonClicked();
        if (intro.currentPage >= (intro.pageCount - 1)) {
            intro.finished();
            return;
        }
        intro.quit();
    }

    function next() {
        rightButtonClicked()
        if (intro.currentPage >= (intro.pageCount - 1)) {
            intro.completeButtonClicked();
            intro.finished();
        } else {
            intro.currentPage = intro.currentPage + 1;
        }
    }

    function back() {
        leftButtonClicked()
        if (intro.currentPage > 0) {
            --intro.currentPage;
        } else {
            intro.quit();
        }
    }

    function primaryButtonText() {
        if (currentPage === (pageCount - 1)) {
            return qsTr("Close");
        } else {
            return qsTr("Next");
        }
    }

    Shortcut {
        enabled: visible
        sequence: "Right"
        onActivated: intro.next()
    }

    Shortcut {
        enabled: visible
        sequence: "Left"
        onActivated: intro.back()
    }

    Rectangle {
        /* Fade out items behind the dialog.
           Since opacity is inherited by children, do not set on the root parent
           but on a sibling item instead. */
        anchors.fill: parent
        opacity: 0.6
    }

    ArkControls.OnboardingDialog {
        id: onboardingDialog

        anchors.fill: parent
        currentPage: intro.currentPage + 1
        totalPages: intro.pageCount
        positionLabel: qsTr("%1 of %2").arg(onboardingDialog.currentPage).arg(onboardingDialog.totalPages)
        closeOption: intro.currentPage !== (intro.pageCount - 1)
        primaryButtonText: intro.rightButtonText
        secondaryButtonText: intro.leftButtonText

        onPrimaryClicked: intro.next();
        onSecondaryClicked: intro.back();
        onCloseClicked: intro.close();

        contentItem: OnboardingPage {
            readonly property var modelData: intro.initialModel[intro.currentPage]

            anchors.fill: parent
            customImage: intro.customImage
            illustrationSource: modelData?.image ?? ""
            title: modelData?.title ?? ""
            body: modelData?.body ?? []
            points: modelData?.points ?? []
            additionalItems: modelData?.additionalItems ?? []
        }
    }
}
