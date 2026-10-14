import QtQuick
import QtQuick.Layouts
import com.remarkable
import common
import device.ui.controls
import device.ui.text

import ark.controls as ArkControls
import ark.tokens as ArkTokens

Background {
    id: tableOfContents

    required property Document document
    readonly property alias view: tableOfContentsList
    property int currentPage
    property var model

    signal chapterClicked(var page)
    signal rejected

    // Returns true if currentPage lies within the bounds of the chapter index
    function isCurrentChapter(index) {
        if (index < 0 || index > model.length - 1) {
            return false;
        }
        let chapter = model[index];
        let nextChapter = index < model.length - 1 ? model[index + 1] : null;
        if (currentPage >= chapter.page && (!nextChapter || currentPage < nextChapter.page)) {
            return true;
        }
        return false;
    }

    // Ensures the current chapter is visible within the view
    function ensureCurrentChapterInView() {
        if (!visible || !view.count) {
            return;
        }

        if (currentPage <= 0) {
            view.positionViewAtBeginning();
            return;
        }

        for (let i = 0 ; i < model.length ; ++i) {
            if (isCurrentChapter(i)) {
                view.positionViewAtIndex(i, ListView.Visible);
                break;
            }
        }
    }

    ArkControls.NavigationBar {
        id: navigationBar
        type: ArkTokens.NavigationBar.secondary
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        title: qsTr("Table of contents")
        borderPosition: ArkControls.NavigationBar.Border.Bottom

        ArkControls.NavigationBar.Button {
            text: qsTr("Back")
            iconSource: "qrc:/ark/icons/chevron_left"
            onClicked: tableOfContents.rejected();
        }

        // this Item is needed so that the navigation bar can deal with the back button
        // note: this requires import QtQuick.Layouts
        Item {
            Layout.fillWidth: true
        }
    }

    ScrollContainer {
        anchors {
            fill: parent
            topMargin: navigationBar.height
        }

        topMargin: Values.designGridHorizontalHeight + Values.designGridHorizontalGutter + Values.designGridHorizontalSpacing
        leftMargin: Values.designGridVerticalGutter + Values.designGridVerticalSpacing + Values.designGridVerticalWidth
        rightMargin: Values.designGridVerticalGutter + Values.designGridVerticalSpacing + Values.designGridVerticalWidth
        bottomMargin: Values.designGridHorizontalHeight + Values.designGridHorizontalGutter + Values.designGridHorizontalSpacing

        view: ListView {
            id: tableOfContentsList
            reuseItems: true
            model: tableOfContents.model
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: false
            displayMarginBeginning: Values.designGridHorizontalHeight + Values.designGridHorizontalGutter + Values.designGridHorizontalSpacing
            delegate: Rectangle {
                required property var modelData
                required property int index
                readonly property bool isCurrent: isCurrentChapter(index)
                readonly property string pageString: modelData.page + 1
                readonly property string name: modelData.name
                readonly property int level: modelData.level ?? 0

                width: view.width
                height: Values.documentViewTableOfContentsItemHeight
                color: Values.colorWhite

                MouseArea {
                    id: tableOfContentListMouseArea
                    anchors.fill: parent
                    onClicked: tableOfContents.chapterClicked(modelData.page);
                }

                TextHeaderRegular {
                    id: chapter
                    anchors {
                        left: parent.left
                        right: page.left
                        rightMargin: Values.designGridHorizontalSpacing
                        leftMargin: level * 50
                        verticalCenter: parent.verticalCenter
                    }
                    color: Values.colorBlack
                    elide: Text.ElideMiddle
                    text: name
                    font.bold: isCurrent
                }

                ArkControls.Caption {
                    id: page
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    color: Values.colorBlack
                    text: pageString
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: chapter.left
                        right: parent.right
                    }
                    height: Values.outlineSize
                    color: Values.colorBlack
                }
            }
            onVisibleChanged: ensureCurrentChapterInView()
            Component.onCompleted: ensureCurrentChapterInView()
        }
    }
}
