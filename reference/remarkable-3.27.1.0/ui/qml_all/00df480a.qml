import QtQuick
import xofm.libs.onboarding
import xofm.libs.qtgui

BaseView {
    id: root
    required property var metrics
    contentItem: OnboardingDialogue {
        id: tutorial
        rightButtonText: currentPage === 0
                ? qsTr("Learn more")
                : currentPage === (pageCount - 1) ? qsTr("Close") : qsTr("Next")
        initialModel: root.articles
        onFinished: {
            root.metrics.completed();
            windowNavigator.close(root.objectName);
        }
        onQuit: {
            root.metrics.quit();
            windowNavigator.close(root.objectName);
        }
    }

    Connections {
        target: tutorial
        function onQuitButtonClicked() {
            root.metrics.closeButton();
        }

        function onCompleteButtonClicked() {
            root.metrics.completeButton();
        }
    }

    Connections {
        target: tutorial
        enabled: tutorial.currentPage < tutorial.pageCount
        function onLeftButtonClicked() {
            root.metrics.goBackButton();
        }
    }

    Connections {
        target: tutorial
        enabled: tutorial.currentPage < tutorial.pageCount
        function onRightButtonClicked() {
            root.metrics.continueButton();
        }
    }
    onOpened: {
        root.metrics.started();
    }

    readonly property var articles: [
            { "image": "qrc:/onboarding/illustrations/distraction_free_software_big",
                //: Guides, Ways of working, title of page 1
                "title": qsTr("Ways of working"),
                "body": [
                    { "description": qsTr("These next four steps will show you how to use and navigate your paper tablet, introducing you to some important features.") },
                    { "description": qsTr("Find more detailed help in Guides and on Using reMarkable.") }
                ]
            },
            { "image": "qrc:/onboarding/illustrations/document_types",
                //: Guides, Ways of working, title of page 2
                "title": qsTr("Types of documents"),
                "body": [
                    { "description": qsTr("Use the plus icon below to create new items.") },
                ],
                "points": [
                    qsTr("Organize your content into folders"),
                    qsTr("Record ideas, write, and sketch in notebooks"),
                    qsTr("Add quick sheets to jot down your thoughts"),
                ]
            },
            { "image": "qrc:/onboarding/illustrations/touch_gestures",
                //: Guides, Ways of working, title of page 3
                "title": qsTr("Touch gestures"),
                "body": [
                    { "description": qsTr("Navigate your notes, browse pages and switch between files, using your fingers. Find the full overview in Guides.") },
                ],
                "points": [
                    qsTr("To perform actions, <b>press and hold</b> the item for 2 seconds"),
                    qsTr("<b>Swipe upwards</b> for more space inside document"),
                    qsTr("<b>Pinch</b> to zoom in and out, <b>tap</b> the scaling icon to reset"),
                ]
            },
            {
                "image": "qrc:/onboarding/illustrations/create_edit_in_apps",
                //: Guides, Ways of working, title of page 4
                "title": qsTr("Note-taking apps"),
                "body": [
                    { "description": qsTr("Make the most of your content by downloading our mobile and desktop apps.") },
                ],
                "points": [
                    qsTr("Take focused notes anywhere with a Connect subscription"),
                    qsTr("Upload PDFs and EPUBs in the app"),
                    qsTr("Get an overview of your documents and ebooks"),
                ]
            },
            { "image": "qrc:/onboarding/illustrations/writing_and_reading",
                //: Guides, Ways of working, title of page 5
                "title": qsTr("Writing and reading"),
                "body": [
                    { "description": qsTr("Pages of notebooks can be as long or short as you need, allowing you to focus and stay uninterrupted as you work.") },
                    { "description": qsTr("Take notes in different styles with your Marker. Type text in three different sizes, as well as bold and italics. ") }
                ]
            },
    ]
}
