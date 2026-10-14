import xofm.libs.qtgui
import xofm.libs.factoryreset // ResetDeviceDialog

BaseView {
    id: root

    contentItem: ResetDeviceDialog {
        onClose: {
            root.windowNavigator.close();
        }
    }
}
