import xofm.libs.qtgui
import device.view.settings as LegacySettings

import ark.controls as ArkControls
import ark.tokens as ArkTokens

import xofm.libs.user

BaseView {
    id: root
    contentItem: LegacySettings.AccountRetail {
        onClose: {
            root.windowNavigator.close(root.objectName);
        }
    }
}
