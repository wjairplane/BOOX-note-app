import QtQuick
import QtQuick.Controls
import com.remarkable

StackView {
    id: stackView

    readonly property alias pages: internal.pages
    readonly property alias currentPageIndex: internal.currentPageIndex
    readonly property alias firstPage: internal.firstPage
    readonly property alias lastPage: internal.lastPage

    initialItem: children[0]
    pushEnter: Transition {}
    pushExit: Transition {}
    popEnter: Transition {}
    popExit: Transition {}
    replaceEnter: Transition {}
    replaceExit: Transition {}
    onCurrentItemChanged: internal.currentPageIndex = internal.findIndexByItem(stackView.currentItem)
    Component.onCompleted: internal.currentPageIndex = internal.findIndexByItem(stackView.initialItem)

    function next() {
        if (internal.lastPage) {
            return;
        }

        stackView.push(stackView.children[internal.currentPageIndex + 1]);
    }

    QtObject {
        id: internal

        property int currentPageIndex: 0
        property int pages: stackView.children.length
        property bool firstPage: internal.currentPageIndex === 0
        property bool lastPage: internal.currentPageIndex === internal.pages - 1

        function findIndexByItem(item) {
            for (var i = 0; i < internal.pages; i++) {
                if (stackView.children[i] === item) {
                    return i;
                }
            }

            return -1;
        }
    }
}
