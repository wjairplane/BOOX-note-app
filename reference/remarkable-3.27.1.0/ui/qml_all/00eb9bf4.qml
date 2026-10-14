import QtQuick
import xofm.libs.qtgui
import xofm.libs.user
import xofm.modules.releasechannel

BaseView {
    id: root
    required property ReleaseChannelWrapper releaseChannel
    required property AuthWrapper auth

    contentItem: Unenroll {
        releaseChannel: root.releaseChannel
        auth: root.auth
        onClose: {
            root.windowNavigator.close();
        }
    }
}
