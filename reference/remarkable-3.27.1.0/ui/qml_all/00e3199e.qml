import xofm.libs.qtgui // BaseView
import device.view.settings as LegacySettings

BaseView {
    id: root

    contentItem: LegacySettings.Storage {
        windowNavigator: root.windowNavigator
        onClose: root.windowNavigator.close();
    }
}
