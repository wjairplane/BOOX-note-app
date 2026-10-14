import xofm.libs.qtgui // BaseView
import xofm.libs.controls // InputBlocker
import xofm.libs.ghostbuster // GhostBuster

import device.view.settings as LegacySettings

BaseView {
    id: root

    required property var generalPaperTabletCells
    required property var generalPersonalCells
    required property var generalAccountInfo
    required property var paperTabletInfoMessage
    required property var iSettings
    required property var securityPanels
    required property var settingsHelpWidgets
    required property var settingsDisplayWidgets
    required property var ghostBuster
    required property var accessibilityWidgets
    required property var cloudPanels
    required property var internalBuildCells
    required property var wifiWidget

    onVisibleChanged: {
        if (!visible) {
            ghostBuster.viewChange(GhostBuster.SettingsClosed);
        }
    }

    onOpened: (configuration) => { contentItem.onOpened(configuration); }

    background: InputBlocker {}

    contentItem: LegacySettings.Settings {
        windowNavigator: root.windowNavigator
        wifiWidget: root.wifiWidget
        generalPaperTabletCells: root.generalPaperTabletCells
        generalPersonalCells: root.generalPersonalCells
        paperTabletInfoMessage: root.paperTabletInfoMessage
        generalAccountInfo: root.generalAccountInfo
        iSettings: root.iSettings
        securityPanels: root.securityPanels
        settingsHelpWidgets: root.settingsHelpWidgets
        settingsDisplayWidgets: root.settingsDisplayWidgets
        ghostBuster: root.ghostBuster
        accessibilityWidgets: root.accessibilityWidgets
        cloudPanels: root.cloudPanels
        internalBuildCells: root.internalBuildCells
        onClose: root.windowNavigator.close("settings/window/main")
    }
}
