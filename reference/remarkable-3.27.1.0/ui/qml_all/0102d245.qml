import QtQuick
import QtQuick.Layouts

import common
import device.ui.text

import ark.controls as ArkControls

RowLayout {
    id: rowLayout
    spacing: 0
    required property var shortcut

    ArkControls.Label {
        type: ArkControls.Label.Medium
        text: shortcut.name
    }

    Item {
        Layout.fillWidth: true
    }

    CheatSheetKey {
        key: shortcut.keys[0] ?? ""
    }

    CheatSheetKey {
        key: shortcut.keys[1] ?? ""
        visible: shortcut.keys.length > 1
        Layout.leftMargin: 20
    }

    ArkControls.Body {
        accessibility: false
        type: ArkControls.Body.Medium
        text: shortcut?.extraText ?? ""
        visible: !!text
        Layout.leftMargin: 20
    }

    CheatSheetKey {
        key: shortcut.keys[2] ?? ""
        visible: modelData.keys.length > 2
        Layout.leftMargin: 20
    }
}
