import QtQuick
import xofm.libs.peninput

FocusScope {
    id: overlay

    // Whether any popups are visible.
    readonly property bool active: _popups.length > 0

    // The active popup if any. This is the last shown but not hidden popup. This item will be
    // visible to the exclusion of any other popups and will be focused item within the overlay.
    readonly property Item activePopup: _popups.length > 0 ? _popups[_popups.length - 1] : null
    property var _popups: []

    // The pen input overlay of the view overlay's pen input blocker for popups. Set this if any
    // popups wish to block pen input to a view item.
    property alias penInputManager: blocker.manager

    // this offset allows to vertically shift the clickable area of this overlay
    property int verticalOffset: 0

    // Adds a popup to the top the overlay's visible popup stack making it the active popup.
    // A popup can not appear multiple times in the stack so If the popup already existed in the
    // stack it will be moved from its previous location.
    function showPopup(popup) {
        const popups = [..._popups];
        const index = popups.indexOf(popup);
        if (index >= 0) {
            if (index == popups.length - 1) {
                // Already active.
                return;
            }
            popups.splice(index, 1);
            popups.push(popup);
            _popups = popups; // It's the same array but modifying it won't notify. Assignment will.
        } else {
            popups.push(popup);
            _popups = popups;
            popup.shown();
        }
    }

    // Removes a popup from the overlay's visible popup stack.
    function hidePopup(popup) {
        const popups = [..._popups];
        const index = popups.indexOf(popup);
        if (index < 0) {
            return;
        }
        popups.splice(index, 1);
        _popups = popups;
        popup.hidden();
    }

    function hideAllPopups() {
        const popups = [..._popups];
        const closed = [];
        while (popups.length > 0) {
            const popup = popups[popups.length - 1];
            if (popup.tapOutsideBehavior === Popup.TapOutside.Ignore) {
                break;
            }
            popups.pop();
            closed.push(popup);
        }
        popups.slice(popups.length - closed.length, closed.length);
        _popups = popups;

        for (const popup of closed) {
            if (popup.tapOutsideBehavior === Popup.TapOutside.AcceptAndHide) {
                popup.accepted();
            } else if (popup.tapOutsideBehavior === Popup.TapOutside.RejectAndHide) {
                popup.rejected();
            }
            popup.hidden();
        }
    }

    MouseArea {
        width: overlay.width
        height: overlay.height - verticalOffset
        y: verticalOffset

        enabled: overlay.activePopup !== null && overlay.activePopup.tapOutsideBehavior !== Popup.TapOutside.Ignore

        onClicked: hideAllPopups()
    }

    PenInputBlocker {
        id: blocker

        width: overlay.width
        height: overlay.height

        visible: overlay.activePopup !== null && overlay.activePopup.outsidePenInputBlocked
    }
}
