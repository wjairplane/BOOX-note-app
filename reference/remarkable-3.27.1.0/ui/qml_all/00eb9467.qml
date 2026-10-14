import QtQuick
import xofm.libs.qtgui
import xofm.modules.releasechannel

BaseView {
    id: root

    contentItem: BetaProgramAgreement {
        onClose: {
            root.windowNavigator.close();
        }
    }
}
