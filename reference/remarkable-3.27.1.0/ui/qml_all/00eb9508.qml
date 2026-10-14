import QtQuick
import xofm.libs.qtgui
import xofm.modules.releasechannel

BaseView {
    id: root
    required property ReleaseChannelWrapper releaseChannel
    onOpened: {
        if(releaseChannel.channel == ReleaseChannelWrapper.Channels.Beta) {
            windowNavigator.open("releasechannel/window/unenroll");
        }
        else {
            windowNavigator.open("releasechannel/window/enroll");
        }

        windowNavigator.close(root.objectName);
    }

    contentItem: Item {
    }
}
