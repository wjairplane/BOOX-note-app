import QtQuick
import common

FocusScope {
    id: handler
    // Index within the model of grids.
    property int index: -1
    // If set, this is used as the initial index during first navigation in a handler.
    property int firstNavigationIndex: -1
    // The model of grids or items to navigate inside.
    // You cannot mix grids/listviews with regular Items in this model.
    // If you need navigation in both, create 2 handlers and chain them with
    // nextNavigationHandler/previousNavigationHandler to accomplish the same effect.
    required property var navigationModel
    // When true, position the navigation rect at the first item.
    property bool firstNavigation: true
    // Can this handler accept being activated with the tab key.
    property bool canAcceptTabActivation: false
    // Can this handler take first navigation focus
    property bool canTakeFirstNavigationFocus: false
    // navigation can wrap around to the beginning of the model. Does not work if
    // there is a relevant previous or next navigation handler set.
    property bool wrapAroundNavigation: false
    // The current grid item.
    readonly property var current: {
        if (!firstNavigation && handler.index > -1 && handler.activeFocus) {
            if (navigationModel[handler.index] && navigationModel[handler.index].currentItem) {
                return navigationModel[handler.index].currentItem;
            } else {
                // Assume it's a regular button or similar.
                return navigationModel[handler.index];
            }
        }
        return null;
    }
    // adds increment and decrement for left/right
    // since those are the keys we have available on rm1 and also
    // for some listviews that have horizontal orientation
    property bool horizontalListViewNavigation: false

    // Allows for chaining together multiple handlers so, when
    // reaching the start or end of one, it can navigate to the previous
    // or next handler.
    property var nextNavigationHandler
    property var previousNavigationHandler

    // The positionMode to use for the ListView or GridView, if navigation
    // is used in any of these controls.
    property var positionMode: ListView.Center

    // Callback called for every key. The handler must return true if it
    // handled the event, in which case no default navigation will occur.
    property var keyOverrideHandler

    // Signals fired on certain keys
    signal activated(var element)
    signal selected(var element)
    signal toggleSelected(var element)
    signal tabCycle(var handler)
    // Fired before navigation
    signal willNavigate(var direction)

    function resetFocusIndex() {
        // unselect it
        handler.index = -1;
        handler.firstNavigation = true;
    }

    function activate() {
        if (typeof(current) !== 'undefined') {
            activated(current);
        }
    }

    function select(item) {
        if (!item) {
            item = current;
        }
        if (typeof(item) !== 'undefined') {
            selected(item);
        }
    }
    function toggleSelect(item) {
        if (!item) {
            item = current;
        }
        if (typeof(item) !== 'undefined') {
            toggleSelected(item);
        }
    }

    enum Direction { None, Up, Down, Left, Right }

    // Normalize navigation array, removing gaps
    function normalizeArray() {
        handler.navigationModel = handler.navigationModel.filter(x => typeof x !== 'undefined');
    }

    // Return the current model item if visible,
    // otherwise look for the next visible one.
    function getVisibleModelIndex() {
        let idx = handler.index > -1 ? handler.index : 0;
        do {
            if (idx > navigationModel.length) {
                break;
            } else if (navigationModel[idx]) {
                const count = (typeof navigationModel[idx].count === "number") ? navigationModel[idx].count : 1;
                if (navigationModel[idx].visible && count > 0 && !isBannedFromNavigation(navigationModel[idx])) {
                    return idx;
                }
            }
            idx++;

        } while(true)

        return -1;
    }

    // By ignoring some widgets in the chain, we can pass in all children
    // some places where it makes sense
    function isBannedFromNavigation(widget) {
        return widget instanceof Repeater;
    }

    // Can we initiate a navigation to the next element in the model?
    function canNavigate(direction) {
        if (direction === KeyboardNavigationHandler.Direction.Down ||
            direction === KeyboardNavigationHandler.Direction.Right) {

            for (let idx = handler.index + 1; navigationModel[idx] !== null; idx++) {
                if (!navigationModel[idx]) {
                    break;
                }
                if (isBannedFromNavigation(navigationModel[idx])) {
                    continue;
                }
                const count = (typeof navigationModel[idx].count === "number") ? navigationModel[idx].count : 1;
                if (navigationModel[idx].visible && count > 0 && !navigationModel[idx].hidden) {
                    return [true, idx];
                }
            }
        } else {
            for (let idx = handler.index - 1; idx >= 0 && navigationModel[idx] !== null; idx--) {
                if (!navigationModel[idx]) {
                    break;
                }
                if (isBannedFromNavigation(navigationModel[idx])) {
                    continue;
                }
                const count = (typeof navigationModel[idx].count === "number") ? navigationModel[idx].count : 1;
                if (navigationModel[idx].visible && count > 0 && !navigationModel[idx].hidden) {
                    return [true, idx];
                }
            }
        }
        return [false, -1];
    }

    function selectRange(idxStart, idxEnd) {
        // Check if range is reversed.
        if (idxStart > idxEnd) {
            let tmp = idxStart;
            idxStart = idxEnd;
            idxEnd = tmp;
        }
        for (let idx = idxStart; idx <= idxEnd; idx++) {
            let item = navigationModel[handler.index].itemAtIndex(idx);
            select(item);
        }
    }

    function nextSection() {
        tabCycle(handler);
    }

    function switchHandler(newHandler, direction) {
        // yield focus and activate the next handler
        handler.focus = false;
        handler.resetFocusIndex();
        newHandler.forceActiveFocus();

        const index = newHandler.index > 0 ? newHandler.index : 0;
        let count = 0;

        if (direction === KeyboardNavigationHandler.Direction.Up ||
            direction === KeyboardNavigationHandler.Direction.Left) {

            // If we navigate up, we want to have the last item in the new handler selected
            // TODO: once were at qt6: count = (typeof newHandler.navigationModel[index]?.count === "number") ? newHandler.navigationModel[index].count - 1 : 0;
            count = (newHandler.navigationModel[index] && typeof newHandler.navigationModel[index].count === "number") ? newHandler.navigationModel[index].count - 1 : 0;
        }
        if (count === 0) {
            count = index;
        }
        newHandler.navigate(direction, false, count);
    }

    // Sets the first navigation initial index
    function setFirstNavigationStartIndexToEnd() {
        handler.firstNavigation = true;
        handler.index = navigationModel.length > 0 ? navigationModel.length - 1 : 0;
        while (handler.index > -1) {
            // skip banned items, typically Repeater
            if (!isBannedFromNavigation(navigationModel[handler.index]))
                break;

            handler.index--;
        }
    }

    function navigate(direction = KeyboardNavigationHandler.Direction.None, multiselect = false, newIndex = 0) {
        handler.index = getVisibleModelIndex();
        if (handler.index > -1) {
            if (firstNavigation) {
                handler.normalizeArray();
                willNavigate(direction);
                if (firstNavigationIndex > -1) {
                    handler.index = firstNavigationIndex;
                }
                const widget = navigationModel[handler.index];
                firstNavigation = false;
                if (typeof widget.currentIndex === "number" && typeof widget.positionViewAtIndex === "function") {
                    widget.currentIndex = newIndex;
                    if (multiselect) {
                        selectRange(grid.currentIndex, grid.currentIndex);
                    }
                    widget.positionViewAtIndex(newIndex, handler.positionMode)
                } else {
                    // The widget is likely something else than a grid, handle
                    // the index as if each model entry is a button or similar.
                    if (firstNavigationIndex === -1) {
                        handler.index = newIndex;
                    }
                }
            } else {
                if (direction === KeyboardNavigationHandler.Direction.None) {
                    if (firstNavigationIndex > -1) {
                        handler.index = firstNavigationIndex;
                    } else {
                        handler.index = newIndex;
                    }
                }
                const currentWidget = navigationModel[handler.index];
                const currentIndex = (typeof currentWidget.currentIndex === "number") ? currentWidget.currentIndex : handler.index;
                switch (direction) {
                    case KeyboardNavigationHandler.Direction.None:
                        break;
                    case KeyboardNavigationHandler.Direction.Up:
                        willNavigate(direction);
                        if (typeof currentWidget.moveCurrentIndexUp === "function") {
                            currentWidget.moveCurrentIndexUp();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode)
                        } else if (typeof currentWidget.decrementCurrentIndex === "function") {
                            currentWidget.decrementCurrentIndex();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode);
                        } else {
                            const [canNav, newIdx] = handler.canNavigate(direction);
                            if (canNav) {
                                handler.index = newIdx;
                            } else if (handler.previousNavigationHandler) {
                                handler.previousNavigationHandler.setFirstNavigationStartIndexToEnd();
                                handler.switchHandler(handler.previousNavigationHandler, direction);
                            }
                        }
                        break;
                    case KeyboardNavigationHandler.Direction.Down:
                        willNavigate(direction);

                        if (typeof currentWidget.moveCurrentIndexDown === "function") {
                            currentWidget.moveCurrentIndexDown();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode)
                        } else if (typeof currentWidget.incrementCurrentIndex === "function") {
                            currentWidget.incrementCurrentIndex();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode);
                        } else {
                            const [canNav, newIdx] = handler.canNavigate(direction);
                            if (canNav) {
                                handler.index = newIdx;
                            } else if (handler.nextNavigationHandler) {
                                handler.switchHandler(handler.nextNavigationHandler, direction);
                            }
                        }
                        break;
                    case KeyboardNavigationHandler.Direction.Left:
                        willNavigate(direction);

                        if (typeof currentWidget.moveCurrentIndexLeft === "function") {
                            currentWidget.moveCurrentIndexLeft();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode);
                        } else if (typeof currentWidget.decrementCurrentIndex === "function" && horizontalListViewNavigation) {
                            currentWidget.decrementCurrentIndex();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode);
                        } else {
                            const [canNav, newIdx] = handler.canNavigate(direction);
                            if (canNav) {
                                handler.index = newIdx;
                            } else if (handler.previousNavigationHandler) {
                                handler.previousNavigationHandler.setFirstNavigationStartIndexToEnd();
                                handler.switchHandler(handler.previousNavigationHandler, direction);
                            }
                        }
                        break;
                    case KeyboardNavigationHandler.Direction.Right:
                        willNavigate(direction);

                        if (typeof currentWidget.moveCurrentIndexRight === "function") {
                            currentWidget.moveCurrentIndexRight();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode);
                        } else if (typeof currentWidget.incrementCurrentIndex === "function" && horizontalListViewNavigation) {
                            currentWidget.incrementCurrentIndex();
                            currentWidget.positionViewAtIndex(currentWidget.currentIndex, handler.positionMode);
                        } else {
                            const [canNav, newIdx] = handler.canNavigate(direction);
                            if (canNav) {
                                handler.index = newIdx;
                            } else if (handler.nextNavigationHandler) {
                                handler.switchHandler(handler.nextNavigationHandler, direction);
                            }
                        }
                        break;
                }
                const newCurrentIndex = typeof currentWidget.currentIndex === "number" ? currentWidget.currentIndex : handler.index;
                if (multiselect) {
                    selectRange(currentIndex, newCurrentIndex);
                }
                if (currentIndex === newCurrentIndex) {
                    if (direction === KeyboardNavigationHandler.Direction.Down ||
                        direction === KeyboardNavigationHandler.Direction.Right) {

                        // End of the grid reached, skip to the next Grid
                        // if possible.
                        if (handler.index <= navigationModel.length - 1) {
                            const [canNav, newIdx] = handler.canNavigate(direction);
                            if (canNav) {
                                handler.index++;
                                firstNavigation = true;
                                handler.navigate(direction, multiselect);
                            } else if (handler.nextNavigationHandler) {
                                handler.switchHandler(handler.nextNavigationHandler, direction);
                            } else if (handler.wrapAroundNavigation) {
                                handler.index = 0;
                                firstNavigation = true;
                                handler.navigate(direction, multiselect);
                            }
                        }
                    } else {
                        // Beginning of the grid reached, skip to the previous Grid
                        // if possible.
                        if (handler.index >= 0) {
                            const [canNav, newIdx] = handler.canNavigate(direction);
                            if (canNav) {
                                handler.index--;
                                firstNavigation = true;
                                handler.navigate(direction, multiselect, navigationModel[handler.index].count > 0 ? navigationModel[handler.index].count - 1 : 0);
                            } else if (handler.previousNavigationHandler) {
                                handler.previousNavigationHandler.setFirstNavigationStartIndexToEnd();
                                handler.switchHandler(handler.previousNavigationHandler, direction);
                            } else if (handler.wrapAroundNavigation) {
                                // A little trick, switch handler to ourself and it will
                                // magically wrap around
                                handler.switchHandler(handler, direction);
                            }
                        }
                    }
                }
            }
        }
    }
    function callCustomKeyHandler(event) {
        if (typeof keyOverrideHandler === "function") {
            if (keyOverrideHandler(event)) {
                event.accepted = true;
                return true;
            }
        }
        return false;
    }

    function callDefaultHandler(event, direction) {
        handler.navigate(direction);
        event.accepted = true;
    }

    Keys.onTabPressed: (event) => {
        if (handler.activeFocus) {
            handler.nextSection();
            event.accepted =  true;
        }
    }
    Keys.onDownPressed: (event) => {
        if (handler.activeFocus) {
            if (!callCustomKeyHandler(event)) {
                callDefaultHandler(event, KeyboardNavigationHandler.Direction.Down);
            }
        }
    }
    Keys.onUpPressed: (event) => {
        if (handler.activeFocus) {
            if (!callCustomKeyHandler(event)) {
                callDefaultHandler(event, KeyboardNavigationHandler.Direction.Up);
            }
        }
    }
    Keys.onRightPressed: (event) => {
        if (handler.activeFocus) {
            if (!callCustomKeyHandler(event)) {
               callDefaultHandler(event, KeyboardNavigationHandler.Direction.Right);
            }
        }
    }
    Keys.onLeftPressed: (event) => {
        if (handler.activeFocus) {
            if (!callCustomKeyHandler(event)) {
                callDefaultHandler(event, KeyboardNavigationHandler.Direction.Left);
            }
        }
    }
    Keys.onReturnPressed: (event) => {
        if (handler.activeFocus) {
            handler.activate()
            event.accepted = true;
        }
    }
    Keys.onEnterPressed: (event) => {
        if (handler.activeFocus) {
            handler.activate()
            event.accepted = true;
        }
    }
    Keys.onSpacePressed: (event) => {
        if (handler.activeFocus) {
            handler.toggleSelect()
            event.accepted = true;
        }
    }
}
