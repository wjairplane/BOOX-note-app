import QtQuick
import common
import com.remarkable
import device.ui.headers
import device.ui.controls

import xofm.libs.controls

import ark.controls as ArkControls

Background {
    id: root

    property var target
    property bool hasValidInput: false
    property bool maxEmailsReached: addedEmails.length >= 12
    property bool alreadyAdded: false
    required property var emails
    required property var addedEmails

    property alias title: inputHeader.text
    property alias acceptText: inputHeader.acceptText

    property var _previousAddedEmails
    property var _previousEmails

    signal updateModels
    signal updateEmails(var value)
    signal updateAddedEmails(var value)

    function open() {
        visible = true;
        emailInput.forceActiveFocus();
        _previousEmails = emails;
        _previousAddedEmails = addedEmails;
    }

    function close(accepted) {
        root.visible = false;
        emailInput.focus = false;
        if (accepted) {
            addEmail(emailInput.text);
            root.visible = false;
        } else {
            updateAddedEmails(_previousAddedEmails);
            updateEmails(emails);
        }
    }

    function indexOfEmail(array, email) {
        for (var i in array) {
            if (array[i].text === email) {
                return i;
            }
        }
        return -1;
    }

    function addEmail(address) {
        address = address.trim();
        if (address.length === 0 || maxEmailsReached || !hasValidInput || indexOfEmail(addedEmails, address) > -1) {
            return;
        }
        var currentIndex = indexOfEmail(emails, address);
        if (currentIndex > -1) {
            emails[currentIndex].selected = true; // If email was already in recents
            addedEmails.push({
                                  "text": address,
                                  "listIndex": currentIndex
                              });
            updateAddedEmails(addedEmails);
        } else {
            emails.unshift({
                                "text": address,
                                "selected": true
                            }); // Add to recents
            updateEmails(emails);

            // Increase all listindex with one since we push to front above
            for (var i in addedEmails) {
                addedEmails[i].listIndex++;
            }

            addedEmails.push({
                                  "text": address,
                                  "listIndex": 0
                              });
            updateAddedEmails(addedEmails);
        }
        root.updateModels();
        emailInput.text = "";
    }

    Header {
        id: inputHeader
        width: parent.width
        blackOnWhite: false
        visible: true
        onRejected: root.close(false)
        onAccepted: root.close(true)
        acceptEnabled: addedEmails.length > 0 || (hasValidInput)
    }

    ArkControls.Label {
        id: infoHeader
        type: ArkControls.Label.Medium
        text: maxEmailsReached ? qsTr("You have reached the maxium amount of emails") : alreadyAdded ? qsTr("You have already added this email") : qsTr("Use space bar to add email address")
        visible: false
        anchors {
            margins: Values.navigatorMargin
            topMargin: 60
            top: inputHeader.bottom
            left: parent.left
            right: parent.right
        }
    }

    Flow {
        id: flow
        spacing: 20
        anchors {
            margins: Values.navigatorMargin
            topMargin: 20
            top: infoHeader.bottom
            left: parent.left
            right: parent.right
        }

        Repeater {
            id: repeater
            model: addedEmails
            RemovableItemButton {
                text: modelData ? modelData.text : ""
                onRemove: {
                    emails[modelData.listIndex].selected = false;
                    addedEmails.splice(index, 1);
                    updateAddedEmails(addedEmails);
                    root.updateModels();
                }
            }
        }

        GeneralTextInput {
            id: emailInput
            verticalAlignment: Text.AlignVCenter
            inputMethodHints: Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Values.fontSizeBody1
            height: 60
            cursorHeight: Values.fontSizeBody1

            onAccepted: close(true)
            onTextChanged: {
                hasValidInput = SendMail.isValidEmail(text.trim());
                if (!hasValidInput) {
                    alreadyAdded = false;
                }
                if (text.charAt(text.length - 1) === ' ') {
                    // Pressed space to add email
                    text = text.trim();
                    if (hasValidInput) {
                        alreadyAdded = indexOfEmail(addedEmails, text) > -1;
                        if (!alreadyAdded) {
                            addEmail(text);
                        }
                    }
                }
                infoHeader.visible = alreadyAdded | maxEmailsReached | hasValidInput;
            }
        }
    }
}
