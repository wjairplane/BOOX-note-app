import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.remarkable
import common
import device.ui.text
import device.ui.controls

import xofm.libs.controls

import ark.tokens as ArkTokens
import ark.controls as ArkControls

InputBlocker {
    id: gestureCheatRoot
    anchors.fill: parent
    visible: false

    signal back()

    Component {
        id: gestureGroup
        GestureGroup {}
    }

    component GestureGroup: ColumnLayout {
        required property var modelData
        required property var index

        width: parent.width
        spacing: 0

        ArkControls.Title {
            type: ArkControls.Title.Large
            Layout.fillWidth: true
            text: modelData.name
        }

        GridLayout {
            id: grid
            Layout.fillWidth: true
            Layout.topMargin: ArkControls.Values.platform.spacing.large
            columnSpacing: ArkControls.Values.platform.spacing.x2large
            rowSpacing: ArkControls.Values.platform.spacing.x2large
            columns: parent.width > 1000 ? 3 : 1

            property double maxCellWidth: grid.width / groupRepeater.count

            Repeater {
                id: groupRepeater
                model: modelData.gestures
                delegate: ArkControls.Card {
                    required property int index
                    readonly property var item: groupRepeater.model[index]

                    Layout.fillWidth: true
                    Layout.preferredWidth: grid.maxCellWidth
                    Layout.alignment: Qt.AlignTop
                    type: ArkTokens.Card.secondary
                    design: parent.width > 1000 ? ArkControls.Card.Design.Vertical : ArkControls.Card.Design.Horizontal
                    illustrationSource: gestureInfo[item].image
                    title: gestureInfo[item].title
                    description: gestureInfo[item].description
                }
            }
        }

        Rectangle {
            visible: index < (gestures.groups.length - 1)
            color: Values.colorBlack
            height: 2
            Layout.fillWidth: true
            Layout.topMargin: ArkControls.Values.platform.spacing.x2large
            Layout.bottomMargin: ArkControls.Values.platform.spacing.x2large
        }
    }

    ArkControls.NavigationBar {
        id: _navbar
        type: ArkTokens.NavigationBar.secondary
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: qsTr("Gestures")

        ArkControls.NavigationBar.Button {
            objectName: "backButton"
            text: qsTr("Back")
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: back()
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
        contentHeight: helpContent.height + anchors.bottomMargin + ArkControls.Values.platform.spacing.x2large // Workaround to ensure some padding at the bottom
        scrollbarRightMargin: ArkControls.Values.margin.horizontal.small_static
        clip: true
        enableScrollbar: true
        permanentScrollbar: true

        Column {
            id: helpContent
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: ArkControls.Values.margin.horizontal.medium
                rightMargin: ArkControls.Values.margin.horizontal.medium
                topMargin: ArkControls.Values.margin.vertical.small
            }

            Repeater {
                id: columnRepeater
                model: gestures.groups
                delegate: gestureGroup
            }
        }
    }

    // -- Content data --
 readonly property var gestureInfo: [
        { "image": "qrc:/onboarding/illustrations/gestures/undo",
            "title": qsTr("Undo"),
            "description": qsTr("Tap once with two fingers to take back your last change")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/redo",
            "title": qsTr("Redo"),
            "description": qsTr("Tap once with three fingers to make undone actions reappear")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/select_item",
            "title": qsTr("Select item"),
            "description": qsTr("Press and hold with one finger to perform actions when selected")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/scroll",
            "title": qsTr("Scroll"),
            "description": qsTr("Navigate pages and overviews with one finger, up, down, and to the sides")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/pan",
            "title": qsTr("Pan"),
            "description": qsTr("Slowly navigate inside documents with two fingers, dragging the page")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/zoom",
            "title": qsTr("Zoom"),
            "description": qsTr("Pinch/spread two fingers to change the zoom level of pages")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/jump",
            "title": qsTr("Jump"),
            "description": qsTr("Swipe one finger vertically to quickly scroll in longer pages")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/flip_page",
            "title": qsTr("Flip page"),
            "description": qsTr("Swipe one finger horizontally to move between pages")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/close_document",
            "title": qsTr("Close document"),
            "description": qsTr("Swipe down from the top edge to Return to My files")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/open_drawer",
            "title": qsTr("Open drawer"),
            "description": qsTr("Swipe two fingers from the top edge to view recent and favorited files")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/quick_settings",
            "title": qsTr("Open quick settings"),
            "description": qsTr("Swipe down from the top-right corner to see battery level, Wi-Fi, and more")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/quick_browse",
            "title": qsTr("Quick browse"),
            "description": qsTr("Swipe up from the bottom edge to get a scrollable preview of your pages")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/select_word",
            "title": qsTr("Select word"),
            "description": qsTr("Double-tap with one finger to edit or format typed text")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/select_paragraph",
            "title": qsTr("Select paragraph"),
            "description": qsTr("Triple-tap with one finger to edit or format typed sections")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/select_all",
            "title": qsTr("Select all"),
            "description": qsTr("Tap four times to edit or format the whole text")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/draw_shapes",
            "title": qsTr("Draw shapes"),
            "description": qsTr("Hold at end of stroke to fix the shape. Drag and rotate it to adjust")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/select_typed_text",
            "title": qsTr("Select typed text"),
            "description": qsTr("Hold and drag on typed text to edit and format it")
        },
        { "image": "qrc:/onboarding/illustrations/gestures/select_below",
            "title": qsTr("Select below"),
            "description": qsTr("Draw a horizontal line and hold to select handwriting beneath the line")
        },
    ]

    readonly property var gestures: {
        "groups": [
            { "name": qsTr("Editing"),
                "gestures": [ 0, 1, 2 ]
            },
            { "name": qsTr("Navigation"),
                "gestures": [ 3, 4, 5, 6, 7, 8 ]
            },
            { "name": qsTr("Shortcuts"),
                "gestures": [ 9, 10, 11 ]
            },
            { "name": qsTr("Typed text"),
                "gestures": [ 12, 13, 14 ]
            },
            { "name": qsTr("Marker"),
                "gestures": [ 15, 16, 17 ]
            }
        ]
    }
}
