import QtQuick
import xofm.libs.qtgui

BaseView {
    id: root

    required property var shortcuts
    contentItem: Item {

        Repeater {
            model: root.shortcuts
            delegate: WidgetLoader {
            }
        }

    }
}
