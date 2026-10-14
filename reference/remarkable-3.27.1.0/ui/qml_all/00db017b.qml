import QtQuick
import com.remarkable
import common

import device.ui.controls
import device.ui.text
import device.ui.headers

import xofm.libs.controls

import ark.controls as ArkControls
import ark.tokens as ArkTokens

HeaderActions {
    id: root

    required property Item documentView
    required property bool isSceneViewActive

    property alias searchController: searchController
    property alias text: searchField.text
    property alias running: searchController.running
    property alias totalResults: searchController.totalResults
    property alias filteredResults: searchController.filteredResults
    property alias filteredResultIndex: searchController.filteredResultIndex
    property string placeholder: ""
    property string committedSearchInput: ""
    property Document document
    property bool pageOnly: false;
    property int currentPage
    readonly property string searchProgressionText: {
        return qsTr("Searching page %1 of %2").arg(searchController.lastSearchedPage + 1).arg(documentView.pageCount);
    }
    readonly property real progress: searchController.lastSearchedPage / documentView.pageCount

    signal openPage(int pageNumber)
    signal updateViewFromSearchResult(rect location)

    // Move to the next page with results.
    function nextResult() {
        searchController.incrementCurrentResultIndex();
    }

    // Move to the previous page with results.
    function previousResult() {
        searchController.decrementCurrentResultIndex();
    }

    function dismiss() {
        committedSearchInput = "";
        searchController.cancel();
        root.visible = false;
        root.focus = false;
    }

    function unfocus() {
        root.focus = false;
    }

    function executeSearch() {
        if (!document) {
            return;
        }
        if (searchField.text.trim().length > 0) {
            committedSearchInput = searchField.text;
            if (!KeyboardInfo.keyboardConnected) {
                searchField.focus = false;
            }
            searchController.search(committedSearchInput, documentView.currentPage, root.pageOnly);
        } else {
            searchController.cancel();
        }
    }

    blackOnWhite: false
    hideOnDismiss: true
    rejectText: qsTr("Cancel")
    actions: [
        HeaderActions.Action {
            iconSource: "qrc:/ark/icons/chevron_up"
            onClicked: root.previousResult()
            visible: searchController.hasPreviousResult || (!searchController.running && searchController.totalResults > 0)
        },
        HeaderActions.Action {
            iconSource: "qrc:/ark/icons/chevron_down"
            onClicked: root.nextResult()
            visible: searchController.hasNextResult || (!searchController.running && searchController.totalResults > 0)
        }]

    onRejected: dismiss()
    onVisibleChanged: {
        if (visible) {
            searchField.forceActiveFocus();
        } else {
            dismiss();
        }
    }
    onCurrentPageChanged: {
        if (pageOnly && visible) {
            searchController.cancel();
            executeSearch();
        }
    }
    onPageOnlyChanged: {
        committedSearchInput = "";
        searchController.cancel();
    }

    Connections {
        target: searchController
        enabled: root.isSceneViewActive
        function onResultLocationChanged(resultLocation) {
            root.updateViewFromSearchResult(resultLocation);
        }
    }

    Shortcut {
        sequence: "Shift+Return"
        onActivated: previousResult()
        enabled: root.visible
                 && searchController.totalResults > 0
                 && committedSearchInput === searchField.text
    }

    Shortcut {
        sequence: "Return"
        onActivated: nextResult()
        enabled: root.visible
                 && searchController.totalResults > 0
                 && committedSearchInput === searchField.text
    }

    ArkControls.Icon {
        id: inputIcon
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: root.rejectItem.width + 24
        }
        size: ArkControls.Values.iconSize.medium
        color: searchField.color
        source: "qrc:/ark/icons/lens"
    }

    DocumentSearchController {
        id: searchController
        document: root.document
        currentPageNumber: currentPage

        onOpenPage: (pageNumber) => {
            root.openPage(pageNumber);
        }
    }

    GeneralTextInput {
        id: searchField
        focus: true

        anchors {
            verticalCenter: parent.verticalCenter
            left: inputIcon.right
            leftMargin: 8
            right: pageOnlyCheckBox.left
            rightMargin: 8
        }

        height: parent.height
        horizontalAlignment: TextInput.AlignLeft
        verticalAlignment: TextInput.AlignVCenter
        font.pixelSize: Values.fontSizeH2
        font.bold: false
        color: Values.colorWhite
        selectedTextColor: Values.colorBlack
        selectionColor: Values.colorWhite
        opacity: text === "" || activeFocus ? 1.0 : 0.0
        KeyboardSettings.actionPanelEnabled: true

        onActiveFocusChanged: {
            if (activeFocus) {
                //To wipe or not to wipe, thats the question
                searchController.cancel();
                committedSearchInput = "";
                searchField.selectAll();
            }
        }

        onTextChanged: {
            searchController.cancel();
            committedSearchInput = "";
        }

        CloseShortcut {
            objectName: "search-results-close"
            onActivated: {
                root.visible = false;
            }
        }

        onAccepted: {
            root.executeSearch();
        }

        Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            height: searchField.font.pixelSize + 10
            color: Values.colorWhite
            width: placeholderText.implicitWidth + 20
            visible: placeholderText.visible
        }

        Text {
            id: placeholderText
            text: qsTr("Search here")
            anchors {
                fill: parent
                leftMargin: 10
            }
            horizontalAlignment: parent.horizontalAlignment
            verticalAlignment: parent.verticalAlignment
            font: parent.font
            color: Values.colorBlack
            visible: !parent.text && !parent.activeFocus
        }
    }

    // TextInput doesn't support eliding.
    // We want to not have resultsLabel overlap the input,
    // so we display this when not in edit mode.
    Text {
        id: searchFieldLabel
        text: searchField.text
        anchors {
            left: searchField.left
            top: searchField.top
            bottom: searchField.bottom
            right: actions.left
            rightMargin: 16
        }
        horizontalAlignment: searchField.horizontalAlignment
        verticalAlignment: searchField.verticalAlignment
        elide: Text.ElideMiddle
        font: searchField.font
        color: Values.colorWhite
        visible: searchField.opacity === 0
    }

    ArkControls.CheckBox {
        id: pageOnlyCheckBox
        anchors {
            right: confirmButton.left
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        width: {
            // These values have been empirically determined whilst using translations.
            // Below a certain width the label is expected to line-wrap to keep the
            // search bar useable.
            const {width, a11yWidth} = root.width < 1000
                                     ? { width: 210, a11yWidth: 230 }
                                     : { width: 270, a11yWidth: 320 };
            return Math.min(Values.accessibilityMode ? a11yWidth : width, implicitWidth)
        }
        type: ArkTokens.Checkbox.primary_inverted
        //: Checkbox for searching only in this page; recommended character limit for translation: 12 (max. 15)
        //: Shares horizontal space with two CTAs, "Cancel" and "Search", and also the search input field.
        text: qsTr("Page only")
        focusPolicy: Qt.TabFocus // We expect the focus to be kept on the input field
        visible: searchController.totalResults === 0 && searchField.activeFocus
        checked:  root.pageOnly
        onClicked: root.pageOnly = !root.pageOnly
    }

    TextParagraph {
        id: resultsLabel
        anchors {
            right: root.row.left
            rightMargin: 36
        }
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: Values.colorWhite
        visible: searchController.totalResults > 0 && committedSearchInput !== ""
        text: qsTr("%1/%2").arg(searchController.currentResultIndex + 1).arg(searchController.totalResults)
    }

    // Right button
    HeaderButton {
        id: confirmButton
        property bool canClear: searchField.text.trim().length > 0 && !searchField.focus && searchController.totalResults === 0
        inverted: !blackOnWhite
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        disabled: searchField.text.trim().length < 1
        title: confirmButton.canClear ? qsTr("Clear") : qsTr("Search")
        visible: !searchController.running && searchController.totalResults < 1
        onClicked: {
            if (confirmButton.canClear) {
                searchField.clear();
            } else {
                searchField.accepted();
            }
        }
    }
}
