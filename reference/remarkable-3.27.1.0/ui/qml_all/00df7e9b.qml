import QtQuick
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.ui.headers
import device.view.navigator
import device.view.dialogs
import device.view.experimental
import com.remarkable.devicetelemetry
import com.remarkable.telemetry as Telemetry
import xofm.libs.orientation
import xofm.libs.controls
import xofm.libs.qtgui  // WindowNavigator

import xofm.modules.sendmail

import ark.controls as ArkControls

InputBlocker {
    id: root

    enum ExportFormat {
        PDF,
        PNG,
        SVG,
        HTML
    }

    required property WindowNavigator windowNavigator
    property Item documentView
    property Document document

    property int format: ShareEmailDialog.PDF

    property alias filename: filenameInput.text
    property alias message: messageInput.text

    property var _emails: []
    property var _addedEmails: []
    readonly property var _formats: [ ShareEmailDialog.PDF, ShareEmailDialog.PNG, ShareEmailDialog.SVG, ShareEmailDialog.HTML ]
    property var _expandedSection: null

    property alias pages: _pageSelection.pages
    property bool keepPassword: true
    property bool exportGrayscale: false
    property int preferredOrientation: Qt.Vertical
    property bool lockedByPassword
    property string password
    property Orientation orientation

    property PageSelection pageSelection: PageSelection {
        id: _pageSelection
        document: root.document
    }

    signal close

    anchors.fill: parent

    CloseShortcut {
        objectName: "share-email-close"
        onActivated: root.close()
    }

    Connections {
        target: Settings
        function onShareEmailAddressesChanged() {
            updateAll();
        }
    }

    Binding {
        when: visible
        target: ScreenShare
        property: "allowUpdates"
        value: false
    }

    function clearRecentEmails()
    {
        // Clear reference to listIndex in added emails
        for (var i in root._addedEmails) {
            root._addedEmails[i].listIndex = -1;
        }

        Settings.shareEmailAddresses = [];
    }

    function updateAll()
    {
        root._emails = [];

        for (var i in Settings.shareEmailAddresses) {
            root._emails.push({
                             "text": Settings.shareEmailAddresses[i].trim(),
                             "selected": false
                         });
        }
        updateModels();
    }

    function updateModels() {
        var updated = root._addedEmails;
        root._addedEmails = updated;
        updated = root._emails;
        root._emails = updated;
    }

    function openPagePickerDialog() {
        pagePickerDialog.visible = true;
    }

    function clear() {
        filename = "";
        message = "";
        password = "";
        keepPassword = true;
        format = ShareEmailDialog.PDF;
        root._addedEmails = [];

        updateAll();
    }

    function open() {
        lockedByPassword = document.lockedByPassword;
        root.preferredOrientation = document.orientation;
        selectedPagesItem.text = selectedPagesText();
        pagePanel.document = document;
        updateAll();
    }

    function selectedPagesText() {
        if (!pageSelection.isEmpty && pageSelection.count < document.pageCount) {
            var groupedSelectionString = pageSelection.groupedSelectionString();
            //: Shows which pages are selected for sending, %1 is page number or range like "1-3, 5, 8"
            return qsTr("Page %1").arg(groupedSelectionString);
        }
        return qsTr("All pages");
    }

    function shareTo(email) {
        let formatString
        switch (format) {
        case ShareEmailDialog.PDF:
            formatString = "pdf";
            break;
        case ShareEmailDialog.PNG:
            formatString = "png";
            break;
        case ShareEmailDialog.SVG:
            formatString = "svg";
            break;
        case ShareEmailDialog.HTML:
            formatString = "html";
            break;
        default:
            console.warn("Unrecognised format", format, "using pdf instead");
            formatString = "pdf";
            break;
        }

        var options = {
            "id": document.id,
            "recipients": email,
            "filename": filename,
            "message": message,
            "format": formatString,
            "pages": pageSelection.pages,
            "password": password,
            "keepPassword": keepPassword,
            "grayscale": exportGrayscale,
            "orientation": root.preferredOrientation,
        };

        exportTelemetry.reportExportType(formatString);
        SendMail.enqueue(options);
    }

    ExportTelemetry {
        id: exportTelemetry
        dispatcher: Telemetry.Dispatcher
    }

    Rectangle {
        anchors.fill: parent
        color: Values.colorWhite
    }

    Header {
        id: header
        visible: true
        text: qsTr("Send by email")
        blackOnWhite: false
        width: parent.width
        acceptText: qsTr("Send")
        acceptEnabled: root._addedEmails.length > 0
        rejectText: qsTr("Cancel")
        onRejected: close()
        onAccepted: {
            var emailString = "";
            var email = "";
            for (var i in root._addedEmails) {
                email = root._addedEmails[i].text;
                Settings.addShareEmailAddress(email);
                emailString += email;
                if (i !== root._addedEmails.length - 1) {
                    emailString += ", ";
                }
            }
            shareTo(emailString);
            close();
        }
    }

    ScrollArea {
        id: flickable

        anchors {
            top: header.bottom
            bottom: root.bottom
            left: root.left
            right: root.right
        }

        clip: true
        enableScrollbar: true
        permanentScrollbar: true
        scrollbarTopMargin: ArkControls.Values.margin.vertical.medium
        scrollbarRightMargin: ArkControls.Values.margin.horizontal.small / 3
        contentWidth: width
        contentHeight: topSection.y + topSection.height + (_expandedSection ? 0 : middleAndBottomSection.height)

        Column {
            id: contentColumn
            width: parent.width - 2*Values.navigatorMargin
            padding: Values.navigatorMargin

            Column {
                id: topSection
                width: parent.width
                height: _expandedSection ? flickable.height - contentColumn.padding : implicitHeight

                ExpandableSection {
                    id: sendToSection
                    model: root._addedEmails
                    title: qsTr("Send to")

                    headerItem: AddItemButton {
                        title: qsTr("Add email address")
                        onClicked: {
                            emailInputDialog.open();
                        }
                    }

                    delegate: RemovableItemButton {
                        text: model.text

                        property var onAccepted: function () {
                            root._emails[model.listIndex].text = textInputDialog.text;
                            root._addedEmails[idx].text = textInputDialog.text;
                            root.updateModels();
                        }

                        onEdit: {
                            textInputDialog.title = qsTr("Edit email");
                            textInputDialog.inputMethodHints = Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase;
                            textInputDialog.validatorFunction = parent.SendMail.isValidEmail;
                            textInputDialog.enterKeyText = qsTr("Confirm");
                            textInputDialog.invokeOnAccepted = onAccepted;
                            textInputDialog.open(model.text);
                            textInputDialog.target = label;
                        }

                        onRemove: {
                            // Verify index is valid
                            if (model.listIndex >= 0 && model.listIndex < root._emails.length) {
                                root._emails[model.listIndex].selected = false;
                            }
                            root._addedEmails.splice(idx, 1);
                            root.updateModels();
                        }
                    }
                }

                ExpandableSection {
                    id: recentSection
                    model: root._emails
                    title: qsTr("Recently used")

                    delegate: AddItemButton {
                        title: model.text ? model.text : ""
                        visible: !model.selected
                        width: visible ? implicitWidth : 0
                        onClicked: {
                            var item = root._emails[idx];
                            root._emails[idx].selected = true;
                            root._addedEmails.push({
                                                "text": item.text,
                                                "listIndex": idx
                                            });
                            root.updateModels();
                        }
                    }
                    IconButton {
                        id: clearAll
                        title: qsTr("Clear all")
                        onClicked: {
                            clearRecentEmails();
                        }
                        height: 50
                        padding: 0
                        font.underline: true
                        visible: root._emails.length > 0
                        font.pixelSize: Values.fontSizeBody2
                        anchors {
                            topMargin: 0
                            right: parent.right
                            rightMargin: 0
                            bottom: recentSection.bottom
                            bottomMargin: 30
                        }
                    }
                }

            }

            Column {
                id: middleAndBottomSection
                width: parent.width
                visible: !_expandedSection

                Rectangle {
                    id: middleSeparator
                    visible: middleRow.visible
                    height: Values.outlineSize
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    color: Values.colorBlack
                }

                Row {
                    id: middleRow
                    anchors {
                        left: parent.left
                        right: parent.right

                    }
                    height: implicitHeight + 2*Values.navigatorMargin
                    spacing: Values.navigatorMargin

                    OptionalTextItem {
                        id: messageInput
                        title: qsTr("Message")
                        placeholderText: qsTr("Add message")
                        y: Values.navigatorMargin
                        width: bottomRow.itemWidth
                        height: implicitHeight
                        textItem.maximumLineCount: Values.accessibilityMode ? 4 : 6
                        onClicked: {
                            textInputDialog.enterKeyText = "";
                            textInputDialog.inputMethodHints = Qt.ImhNone;
                            textInputDialog.validatorFunction = null;
                            textInputDialog.multiline = true;
                            textInputDialog.title = title;
                            textInputDialog.open(text);
                            textInputDialog.target = textItem;
                        }
                    }

                    OptionalTextItem {
                        id: selectedPagesItem
                        y: Values.navigatorMargin
                        width: bottomRow.itemWidth
                        height: implicitHeight
                        textItem.maximumLineCount: Values.accessibilityMode ? 4 : 6
                        title: qsTr("Selected")
                        onClicked: openPagePickerDialog()
                    }

                    OptionalTextItem {
                        id: filenameInput
                        title: qsTr("Attachment name")
                        placeholderText: qsTr("Rename")
                        y: Values.navigatorMargin
                        width: bottomRow.itemWidth
                        height: implicitHeight
                        textItem.maximumLineCount: Values.accessibilityMode ? 4 : 6
                        visible: format !== ShareEmailDialog.HTML
                        onClicked: {
                            textInputDialog.inputMethodHints = Qt.ImhNone;
                            textInputDialog.validatorFunction = null;
                            textInputDialog.multiline = false;
                            textInputDialog.maximumLength = 200;
                            textInputDialog.title = title;
                            textInputDialog.open(text);
                            textInputDialog.target = textItem;
                        }
                    }
                }

                Rectangle {
                    id: bottomSeparator
                    height: Values.outlineSize
                    color: Values.colorBlack
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    visible: bottomRow.hasContent
                }

                Row {
                    id: bottomRow

                    readonly property bool hasContent: formatTypeColumn.visible || formatOptionsColumn.hasContent || paperWidthOption.visible
                    readonly property int itemWidth: (parent.width - padding*2 - spacing*2) / 3

                    width: parent.width
                    height: implicitHeight + Values.navigatorMargin
                    spacing: Values.navigatorMargin

                    Column {
                        id: formatTypeColumn
                        width: bottomRow.itemWidth
                        spacing: Values.controlVerticalMargin
                        bottomPadding: Values.navigatorMargin
                        y: Values.navigatorMargin

                        TextHeaderRegular {
                            text: qsTr("Format")
                            height: implicitHeight + Values.controlVerticalMargin - parent.spacing
                        }

                        Repeater {
                            model: {
                                if (!pageSelection.selectionHasText) {
                                    // When no selected page contains any text
                                    // we don't show the 'HTML' option (aka 'Text in email').
                                    return _formats.filter(item => { return item !== ShareEmailDialog.HTML; });
                                }
                                return _formats;
                            }
                            ArkControls.RadioButton {
                                width: parent.width
                                required property var modelData
                                checked: modelData === format
                                text: {
                                    switch (modelData) {
                                    case ShareEmailDialog.PDF:
                                        //: PDF document export format
                                        return qsTr("PDF");
                                    case ShareEmailDialog.PNG:
                                        //: PNG image export format
                                        return qsTr("PNG");
                                    case ShareEmailDialog.SVG:
                                        //: SVG vector graphic export format
                                        return qsTr("SVG");
                                    case ShareEmailDialog.HTML:
                                        //: Option to send converted text directly in email body
                                        return qsTr("Text in email");
                                    default:
                                        return ""
                                    }
                                }

                                onClicked: {
                                    format = modelData;
                                }
                            }
                        }
                    }

                    Column {
                        id: formatOptionsColumn

                        readonly property bool hasContent: passwordCheckbox.visible || grayscalePensCheckbox.visible

                        width: hasContent ? bottomRow.itemWidth : 0
                        spacing: Values.controlVerticalMargin
                        y: Values.navigatorMargin

                        TextHeaderRegular {
                            id: paperWidthOption
                            text: qsTr("Export width")
                            height: implicitHeight + Values.controlVerticalMargin - parent.spacing
                            visible: formatOptionsColumn.hasContent
                        }

                        ArkControls.RadioButton {
                            id: landscapeCheckbox
                            visible: format !== ShareEmailDialog.HTML
                            width: bottomRow.itemWidth
                            text: qsTr("Landscape")
                            checked: root.preferredOrientation === Qt.Horizontal
                            onClicked: root.preferredOrientation = Qt.Horizontal
                        }

                        ArkControls.RadioButton {
                            id: portraitCheckbox
                            visible: format !== ShareEmailDialog.HTML
                            width: bottomRow.itemWidth
                            text: qsTr("Portrait")
                            checked: root.preferredOrientation === Qt.Vertical
                            onClicked: root.preferredOrientation = Qt.Vertical
                        }
                    }

                    Column {
                        width: bottomRow.itemWidth
                        spacing: Values.controlVerticalMargin
                        y: Values.navigatorMargin

                        TextHeaderRegular {
                            id: formatOptionsHeader
                            text: qsTr("Options")
                            height: implicitHeight + Values.controlVerticalMargin - parent.spacing
                            visible: formatOptionsColumn.hasContent
                        }

                        ArkControls.CheckBox {
                            id: passwordCheckbox
                            width: bottomRow.itemWidth
                            visible: format === ShareEmailDialog.PDF && (document && document.lockedByPassword)
                            text: qsTr("Keep password protection")
                            checked:  root.keepPassword
                            onClicked: root.keepPassword = !root.keepPassword
                        }

                        ArkControls.CheckBox {
                            id: grayscalePensCheckbox
                            visible: format !== ShareEmailDialog.HTML
                            width: bottomRow.itemWidth
                            text: qsTr("Grayscale pens")
                            checked: root.exportGrayscale
                            onClicked: root.exportGrayscale = !root.exportGrayscale;
                        }
                    }
                }
            }
        }
    }

    Background {
        id: pagePickerDialog
        visible: false
        anchors.fill: parent

        Header {
            id: pagesHeader
            visible: true
            width: parent.width
            blackOnWhite: false
            text: qsTr("Select pages to send")
            acceptText: qsTr("Confirm")
            rejectText: qsTr("Cancel")
            acceptEnabled: !pageSelection.isEmpty
            onRejected: {
                pagePickerDialog.visible = false;
            }
            onAccepted: {
                pagePickerDialog.visible = false;
                selectedPagesItem.text = selectedPagesText();
            }
        }

        PagePicker {
            id: pagePanel
            documentView: root.documentView
            document: root.document
            anchors {
                top: pagesHeader.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            tags: {}
            selecting: true
            goToPageEnabled: true
            currentPage: root.document?.lastOpenedPage ?? -1
            pageSelection: root.pageSelection
            windowNavigator: root.windowNavigator

        }

        function reject() {
            pagesHeader.reject();
        }
    }

    TextInputDialog {
        id: textInputDialog
        header.acceptText: qsTr("Save")
        anchors.fill: parent
    }

    EmailAddressInputDialog {
        id: emailInputDialog
        title: qsTr("Enter email addresses")
        anchors.fill: parent
        visible: false
        addedEmails: _addedEmails
        emails: _emails
        onUpdateModels: root.updateModels()
        onUpdateEmails: function(value) {
            root._emails = value;
        }
        onUpdateAddedEmails: function(value) {
            root._addedEmails = value;
        }
    }
}
