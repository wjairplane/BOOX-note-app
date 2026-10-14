import xofm.libs.qtgui
import xofm.libs.orientation

BaseView {
    id: root
    required property var virtualKeyboard
    required property var keyboardInfo
    required property Orientation orientation

    z: 10000 // above all other windows, excluding the item inspector

    contentItem: KeyboardPanel {
        id: keyboardPanel
        virtualKeyboard : root.virtualKeyboard
        keyboardConnected: root.keyboardInfo.keyboardConnected
        portrait: orientation.isPortraitOrientation
    }
}
