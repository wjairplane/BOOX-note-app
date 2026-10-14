import QtQuick
import device.ui.text
import com.remarkable
import common
import device.view.experimental
import xofm.libs.epaper as Epaper

MouseArea {
    id: slider

    required property Item documentView
    required property Document document
    required property var tocModel
    required property bool portrait
    required property int pageCount

    property int value: 0
    property int from: 0
    property int to: 0

    property int leftVisibleMargin
    property int rightVisibleMargin

    property int navigationPointThreshold: pageCount / 40
    property int cancelThreshold: 200 // How far you drag for the handle to snap back
    property var navPoints: [] // snap-to points on the slider, i.e tags and last page location
    property var _processedToc: [] // Stores chapter info for each page

    signal activated
    signal accepted

    property bool pageThumbnailVisible
    property bool usageTipVisible

    height: 100
    visible: false

    onDocumentChanged: _processedToc = []

    onVisibleChanged: {
        if (visible) {
            usageTipVisible = true;
            lastPageLocation = currentPage;
        } else {
            lastPageLocation = -1;
        }
    }

    onPageThumbnailVisibleChanged: {
        if (pageThumbnailVisible) {
            usageTipVisible = false;
        }
    }

    onMouseXChanged: (mouse) => {
        if (pageThumbnailVisible) {
            value = pageFromPos(mouse.x);
        }
    }

    onMouseYChanged: (mouse) => {
        pageThumbnailVisible = mouse.y > - cancelThreshold;
    }

    onPressed: (mouse) => {
        pageThumbnailVisible = mouse.y >= 0 && mouse.y <= slider.height;
        value = pageFromPos(mouse.x);
    }

    onReleased: {
        if (pageThumbnailVisible) {
            accepted();
        }
        pageThumbnailVisible = false;
        updateNavigationPoints();
    }

    onActivated: updateNavigationPoints()

    onTocModelChanged: {
        // Creates a mapping from page to chapter.
        let pageTable = [];

        for (let chapter of tocModel) {
            pageTable[chapter.page] = chapter;
        }

        let lastPageWithChapter = -1;
        for (let page = 0; page < pageCount; ++page) {
            if (pageTable[page] !== undefined) {
                lastPageWithChapter = page;
            } else if (lastPageWithChapter >= 0) {
                pageTable[page] = pageTable[lastPageWithChapter];
            } else {
                pageTable[page] = {};
            }
        }

        slider._processedToc = pageTable;
    }

    // Takes a target page and returns the target location with any snapping
    // applied. I.e it could return last pageLocation if it is within navigationPointThreshold
    function snapToPage(page) {
        if (to <= 50) {
            return page;
        }

        if (page === 0 || page === to) { // Never override endpoints
            return page;
        }
        if (navigationPointThreshold > 1) {
            for (const point of navPoints) {
                if (Math.abs(page - point.page) < navigationPointThreshold) {
                    return point.page;
                }
            }
        }
        return page;
    }

    // Gets the page from the current tap position
    function pageFromPos(pos) {
        const visibleItemX = pos - visibleItem.x;
        const targetPage = Math.max(from, Math.min(to, Math.round((visibleItemX / visibleItem.width) * (pageCount - 1))));
        return snapToPage(targetPage);
    }

    function activate() {
        visible = true;
        activated();
    }

    function updateNavigationPoints() {
        navPoints = [];
        let points = [];
        points.push({ name: "previous", page: lastPageLocation, icon: ""});
        const currentPageIndicator = { name: "current", page: currentPage, width: 35 }
        points.push(currentPageIndicator);
        navPoints = points;
    }

    Item {
        id: visibleItem
        anchors.fill: parent
        anchors.leftMargin: slider.leftVisibleMargin
        anchors.rightMargin: slider.rightVisibleMargin

        Rectangle {
            id: thumbnailCover
            anchors.fill: thumbnail
            anchors.margins: -2
            color: Values.colorWhite
            border.width: 2
            border.color: Values.colorBlack
            visible: thumbnail.visible
        }

        Connections {
            target: window
            enabled: slider.pressed
            function onAfterAnimating() {
                thumbnail.page = Math.round(value);
            }
        }

        PageThumbnail {
            id: thumbnail

            document: slider.visible ? slider.document : null
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: 100
            sourceSize: Qt.size(width, height)
            asynchronous: false
            height: Math.min(slider.portrait ? 820 : 615, documentView.height - 400)
            width: height / 4.0 * 3.0
            monochrome: true
            visible: pageThumbnailVisible && slider.visible

            Loading {
                anchors.centerIn: parent
                visible: thumbnail.status !== Image.Ready
                antialiasing: false
            }
        }

        Column {
            id: labelColumn
            anchors.alignWhenCentered: true
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: pageThumbnailVisible && slider.visible

            TextParagraph {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.alignWhenCentered: true
                verticalAlignment: Text.AlignTop
                text: qsTr("Page %1").arg(slider.value + 1)
                font.weight: Font.Medium
                antialiasing: false
                width: 120
            }

            TextParagraph {
                anchors.alignWhenCentered: true
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignHCenter
                antialiasing: false
                width: visibleItem.width
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideRight
                property string currentChapter: slider._processedToc[value]?.name ?? ""
                text: {
                    // If the chapter text is a number, we prefix it, so it's obvious what it is.
                    // If it's text, we display it without any context, to prevent things like:
                    // "Chapter: Part 3: Foo" / "Chapter: Chapter 1: Foo"
                    if (Number(currentChapter) === currentChapter) {
                        return qsTr("Chapter: %1").arg(currentChapter);
                    }

                    return currentChapter;
                }
                font.weight: Font.Medium
                visible: !!currentChapter
                textFormat: Text.PlainText
            }
        }

        Rectangle {
            id: navbar
            height: 8
            width: parent.width + 20
            anchors.alignWhenCentered: true
            anchors.centerIn: parent
            antialiasing: false
            color: Values.colorBlack
            radius: Math.round(height / 2)
        }

        Repeater {
            id: navigationPointsRepeater
            model: navPoints.length

            Item {
                id: navPointItem
                width: 18
                height: width

                property var modelData: navPoints[index] ?? {page:0, width:0}

                y: Math.floor((slider.height - height) / 2)
                x: Math.floor((modelData.page / slider.to) * visibleItem.width) - 9
                visible: width > 0

                Rectangle {
                    readonly property string name: modelData.name
                    anchors.centerIn: parent
                    anchors.alignWhenCentered: true
                    width: (modelData.width && !pageThumbnailVisible) ? modelData.width : 18
                    height: width ?? 0
                    antialiasing: false
                    visible: !(modelData.width && pageThumbnailVisible)
                    color: width < 20 ? Values.colorBlack : Values.colorWhite
                    border.width: width > 20 ? 2 : 0
                    radius: width / 2
                }
            }
        }

        Epaper.ScreenModeItem {
            id: fastUpdateArea
            anchors.top: thumbnailCover.top
            anchors.bottom: labelColumn.bottom
            anchors.bottomMargin: -40
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: -40
            anchors.leftMargin: -40
            visible: thumbnail.visible
            mode: Epaper.ScreenModeItem.Animation
            objectName: "page-slider"
        }
    }
}
