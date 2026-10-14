import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.remarkable
import common
import device.ui.text
import device.ui.controls
import device.ui.headers
import device.view.dialogs
import com.remarkable.devicetelemetry

import ark.tokens as ArkTokens
import ark.controls as ArkControls

DeviceKeyboardNavigationHandler {
    id: helpRoot
    objectName: "helpRoot"
    anchors.fill: parent
    navigationModel: [backButton]
    firstNavigationIndex: 1 // start navigation at the first topic button
    focus: true

    readonly property int gridSpacing: ArkControls.Values.platform.spacing.x2large
    readonly property bool wideScreen: parent.width > 1000

    signal resetTooltips(string lastOpenedDocumentId)
    signal showGestures()
    signal showTutorial()
    signal showCalendarDialog
    signal close()

    onActivated: (element) => {
         element.activate();
    }

    function doTopic(data) {
        if (!data) {
            return;
        }

        switch (data) {
        case "tutorial":
            showTutorial();
            break;
        case "tooltips":
            resetTooltips(lastOpenDocument.entryIds[0]);
            break;
        case "gestures":
            showGestures();
            break;

        case "calendarDialog":
            showCalendarDialog();
            break;
        }
    }

    Background {
        anchors.fill: parent
    }

    ArkControls.NavigationBar {
        id: _navbar
        type: ArkTokens.NavigationBar.secondary
        title: qsTr("Guides")
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        ArkControls.NavigationBar.Button {
            id: backButton
            objectName: "backButton"
            text: qsTr("Back")
            iconSource: "qrc:/ark/icons/chevron_left"
            showFocus: helpRoot.current === backButton
            onClicked: helpRoot.close()
            function activate() {
                helpRoot.close();
            }
        }
        // This item is used in the component to calculate the available space for the title
        Item {
            Layout.fillWidth: true
        }
    }

    ScrollArea {
        id: flick
        anchors {
            top: _navbar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: ArkControls.Values.margin.vertical.small
        }
        contentWidth: parent.width
        contentHeight: helpContent.height + helpRoot.gridSpacing + anchors.bottomMargin // Workaround to ensure some padding at the bottom
        clip: true
        enableScrollbar: true
        permanentScrollbar: true
        scrollbarRightMargin: ArkControls.Values.margin.horizontal.small_static

        Column {
            id: helpContent
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: ArkControls.Values.margin.horizontal.medium
                rightMargin: ArkControls.Values.margin.horizontal.medium
                topMargin: ArkControls.Values.margin.vertical.small
            }

            GridLayout {
                id: grid

                objectName: "helpBrowserGrid"
                width: parent.width
                columns: helpRoot.wideScreen ? 2 : 1
                columnSpacing: gridSpacing
                rowSpacing: gridSpacing

                property int maxCardHeight: maximumImplicitHeight()
                function maximumImplicitHeight() {
                    let maxHeight = 0;
                    for (let i = 0; i < gridRepeater.count; i++) {
                        const item = gridRepeater.itemAt(i);
                        if (item && item.implicitHeight > maxHeight) {
                            maxHeight = item.implicitHeight;
                        }
                    }

                    return maxHeight;
                }

                Repeater {
                    id: gridRepeater
                    model: topics
                    delegate:  GuidesCard {
                        id: topicButton

                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.columnSpan: modelData.fillScreenWidth ? grid.columns : 1
                        Layout.preferredHeight: !modelData.fillScreenWidth && helpRoot.wideScreen ? grid.maxCardHeight : topicButton.implicitHeight

                        design: !modelData.fillScreenWidth && helpRoot.wideScreen ? ArkControls.Card.Design.Vertical : ArkControls.Card.Design.Horizontal
                        imageSource: modelData.image ?? ""
                        title: modelData.topic
                        description: modelData.summary
                        buttonText: modelData.actionText ?? ""
                        buttonAction: modelData.action ? () => helpRoot.doTopic(modelData.action) : () => {}
                        url: modelData.url ?? ""
                    }
                }
            }
        }
    }

    LibrarySearch {
        id: lastOpenDocument
        filter: LibraryView.Documents
        sortOrder: LibraryView.RecentlyOpenedDate
        library: Library
        showRecentsIfTermEmpty: true
        maximumResults: 1
    }

    // -- Content data --

    readonly property var topics: [
        {
            "navigationIndex": 1,
            //: Recommended character limit for translation: 29
            "topic": qsTr("Create meeting note"),
            "summary": qsTr("Start meetings feeling organized and focused."),
            "actionText": qsTr("Learn more"),
            "helpId": "connectCalendar",
            "image": "qrc:/onboarding/illustrations/helpbrowser/meeting_note",
            "action": "calendarDialog",
            "fillScreenWidth": true,
        },
        {
            "navigationIndex": 2,
            //: Recommended character limit for translation: 29
            "topic": qsTr("reMarkable Methods"),
            "summary": qsTr("Discover our go-to resource for the latest templates, tools, and workbooks."),
            "url": "https://methods.remarkable.com?utm_source=rm_device&utm_medium=qr_code&utm_campaign=guides_3_27",
            "fillScreenWidth": true,
        },
        {
            "navigationIndex": 3,
            //: Recommended character limit for translation: 29
            "topic": qsTr("Gestures"),
            "summary": qsTr("Overview of all the gestures that you can use to navigate, edit, and multitask."),
            "actionText": qsTr("View all"),
            "image": "qrc:/onboarding/illustrations/helpbrowser/guides",
            "action": "gestures",
            "helpId": "gestures",
            "fillScreenWidth": true,
        },
        {
            "navigationIndex": 4,
            //: Recommended character limit for translation: 29
            "topic": qsTr("Getting started"),
            "summary": qsTr("Visit our learning and inspiration hub for more helpful tips, guides, and walkthroughs."),
            "url": "https://remarkable.com/guides?utm_source=rm_device&utm_medium=qr_code&utm_campaign=guides_3_27",
            "fillScreenWidth": true,
        },
        {
            "navigationIndex": 5,
            //: Recommended character limit for translation: 29
            "topic": qsTr("Ways of working"),
            "summary": qsTr("A four step guide on how to use your paper tablet and improve your workflow."),
            "actionText": qsTr("Start tutorial"),
            "image": "qrc:/onboarding/illustrations/helpbrowser/helpbrowser_distraction_free_software",
            "helpId": "gettingStarted",
            "action": "tutorial",
            "fillScreenWidth": false,
        },
        {
            "navigationIndex": 6,
            //: Recommended character limit for translation: 29
            "topic": qsTr("Features and functionality"),
            "summary": qsTr("Tips for how the different tools work, and where to find them on your reMarkable."),
            "actionText": qsTr("Show tooltips"),
            "image": "qrc:/onboarding/illustrations/helpbrowser/features_and_functionality",
            "helpId": "tooltips",
            "action": "tooltips",
            "fillScreenWidth": false,
        },

    ]
}
