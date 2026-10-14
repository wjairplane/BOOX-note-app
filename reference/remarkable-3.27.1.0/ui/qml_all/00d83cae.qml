import QtQuick

// An item which can be displayed in a PopupOverlay.
FocusScope {
    id: popup

    enum TapOutside {
        Ignore,
        AcceptAndHide,
        RejectAndHide
    }

    // The PopupOver the popup belongs to. When shown the Popup will appear exclusively in an overlay.
    property PopupOverlay overlay

    // What action is performed when the user taps outside of the popup.
    property int tapOutsideBehavior: Popup.TapOutside.Ignore
    // Whether pen input is blocked outside the popup while it is visible.
    property bool outsidePenInputBlocked: false
    // Whether the popup is the active popup in the overlay. If true the popup will
    // both be visible and have focus in the overlay.
    readonly property bool active: overlay && overlay.activePopup === popup

    parent: overlay
    visible: active
    focus: active

    // Emitted when the popup is added to the overlay's visible popup stack.
    signal shown()
    // Emitted when the popup is removed from the overlay's visible popup stack. If another popup is
    // added above this then the item will be temporarily obscured, but this signal will not be
    // emitted while its possible to return to it by hiding the popup above.
    signal hidden()

    signal accepted()
    signal rejected()

    // Adds the popup to the top of its overlay's visible popup stack making it the active popup.
    // A popup can not appear multiple times in the stack so If the popup already existed in the
    // stack it will be moved from its previous location.
    function showPopup() {
        const owner = overlay || parent
        if (owner) {
            owner.showPopup(popup);
        }
    }

    // Removes the popup from its overlay's visible popup stack.
    function hidePopup() {
        const owner = overlay || parent
        if (owner) {
            owner.hidePopup(popup);
        }
    }
}
