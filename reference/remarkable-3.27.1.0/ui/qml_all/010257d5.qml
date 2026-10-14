import QtQuick
import com.remarkable

import xofm.libs.qtgui
import xofm.libs.settings
import xofm.modules.systemclock

CellItemWrapper {
    id: root

    required property SystemClockWrapper clock
    property date _date: clock.datetime // used to reevaluate datetime when it has changed

    function activate() {
        root.windowNavigator.open("systemclock/window/settings-info");
    }

    Component.onCompleted: clock.update()
    on_DateChanged: text = clock.toString();
    onClicked: activate()
}
