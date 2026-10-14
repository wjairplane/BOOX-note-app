import xofm.libs.qtgui // windowNavigator
import device.view.settings as LegacySettings

import xofm.modules.settings // AutosleepDelayDevicePolicy

BaseView {
    id: root

    required property AutosleepDelayDevicePolicy autosleepDelayDevicePolicy

    contentItem: LegacySettings.Battery {
        windowNavigator: root.windowNavigator
        autosleepDelayDevicePolicy: root.autosleepDelayDevicePolicy
        onClose: root.windowNavigator.close();
    }
}
