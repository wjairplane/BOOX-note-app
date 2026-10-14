import QtQuick

import com.remarkable
import common

import device.ui.text

import ark.controls as ArkControls

Item {
    id: root

    property var breadcrumbModel
    property var titleList: []
    property int elidedTitles: 0
    readonly property int iconSize: ArkControls.Values.iconSize.medium

    signal open(var id)

    function sizeCrumbs(list, elided) {
        var size = 0;
        for (var i = 0; i < list.length; ++i) {
            if (i > 0 && i < elided) {
                continue;
            }
            if (i === 0) {
                textMetrics.font.pixelSize = largeTitle.font.pixelSize;
                textMetrics.font.family = largeTitle.font.family;
            } else {
                textMetrics.font.pixelSize = mediumTitle.font.pixelSize;
                textMetrics.font.family = mediumTitle.font.family;
            }

            textMetrics.text = list[i];
            if (textMetrics.text.length > 0) {
                var textSize = Math.min(textMetrics.width, Values.navigatorContentGridItemWidth);
                size += (textSize + root.iconSize * 2);
            }
        }
        return size;
    }

    function calculateItemsToHide(title) {
        root.titleList.push(title);
        root.elidedTitles = 0;
        for (var j = breadcrumb.count - 1; j > 1 && sizeCrumbs(root.titleList, root.elidedTitles) > breadcrumb.width; --j) {
            root.elidedTitles++;
        }
        if (root.titleList.length === breadcrumb.count) {
            root.titleList = [];
        }
    }

    function showTitle(idx, name) {
        if ((idx < root.elidedTitles && idx > 0) || name === undefined) {
            return "";
        }
        return qsTranslate("xofm::libs::library::constants", name);
    }

    // We need these to apply the correct tokens
    ArkControls.Title {
        id: largeTitle
        type: ArkControls.Title.Large
    }

    ArkControls.Title {
        id: mediumTitle
        type: ArkControls.Title.Medium
    }

    TextMetrics {
        id: textMetrics
    }

    ListView {
        id: breadcrumb
        anchors {
            left: parent.left
            top: parent.top
            topMargin: 10
            right: parent.right
        }
        height: parent.height
        clip: true
        orientation: Qt.Horizontal
        layoutDirection: Qt.LeftToRight
        interactive: false
        snapMode: ListView.SnapOneItem
        model: root.breadcrumbModel
        delegate: MouseArea {
            id: row

            required property int index
            required property var model
            property int currentIndex: breadcrumb.count - 1
            property bool visibleItem: title.text || (index === 1)

            width: row.visibleItem ? title.width + icon.size : 0
            height: Values.searchHeaderMargin

            Component.onCompleted: root.calculateItemsToHide(model.name)
            onClicked: root.open(model.id);

            ArkControls.Title {
                id: title
                type: ArkControls.Title.Large
                font.family: row.index > 0 ? mediumTitle.font.family : largeTitle.font.family
                font.pixelSize: row.index > 0 ? mediumTitle.font.pixelSize : largeTitle.font.pixelSize
                anchors {
                    left: parent.left
                    verticalCenter: row.verticalCenter
                }
                width: {
                    if (row.index === 0) {
                        return implicitWidth;
                    }
                    if (root.elidedTitles > 1) {
                        return Math.min(implicitWidth, Values.navigatorContentGridItemWidth / 3); // some titles need to be elided: apply this arbitrary ratio to elide the text too
                    }
                    return Math.min(implicitWidth, Values.navigatorContentGridItemWidth);
                }
                text: root.showTitle(row.index, model.name)
                color: Values.colorBlack
                elide: Text.ElideMiddle
                font.bold: row.index === row.currentIndex
            }

            ArkControls.Icon {
                id: icon
                visible: row.index !== row.currentIndex
                anchors {
                    left: title.right
                    verticalCenter: row.verticalCenter
                }
                size: root.iconSize
                source: row.visibleItem ? "qrc:/ark/icons/chevron_small_right" : ""
                color: Values.colorBlack
            }
        }
    }
}
