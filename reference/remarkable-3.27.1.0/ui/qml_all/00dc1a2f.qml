import QtQuick

/*
 This class keeps track of registered keyboard handlers to
 facilitate tab cycling between them.
 */
Item {
    id: controller

    // The list of handlers used for navigation.
    property var model: []

    // Register a new keyboard handler.
    function registerHandler(handler) {
        model.push(handler);
    }

    // Unregister a keyboard handler.
    function unregisterHandler(handler) {
        model.splice(model.indexOf(handler), 1);
    }

    // Focus other visible handler than |current|.
    function focusOtherHandler(current) {
        current.focus = false;
        for (let i = 0; i < model.length; i++) {
            if (model[i] !== current && model[i].visible && model[i].canAcceptTabActivation) {
                model[i].forceActiveFocus();
                if (typeof model[i].navigate === "function") {
                    // Just trigger first navigation
                    model[i].navigate(KeyboardNavigationHandler.Direction.None);
                }
                break;
            }
        }
    }
    function _activateItem(item, direction) {
        item.forceActiveFocus();
        if (typeof item.navigate === "function") {
            // Just trigger first navigation
            item.navigate(direction);
        }
    }

    // Focus first visible view
    function focusVisibleView(direction) {
        let i;

        for (i = 0; i < model.length; i++) {
            if (model[i].visible && model[i].canTakeFirstNavigationFocus) {
                _activateItem(model[i], direction);
                return;
            }
        }
        // fallback to any first visible item
        for (i = 0; i < model.length; i++) {
            if (model[i].visible) {
                _activateItem(model[i], direction);
                return;
            }
        }
    }
}
