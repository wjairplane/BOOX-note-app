import device.view.dialogs
import xofm.libs.qtgui
import xofm.libs.orientation

BaseView {
    id: root
    property string backText
    required property Orientation orientation

    onOpened: (args) => {
        const { backText } = args;
        root.backText = backText ?? qsTr("Back");
    }

    contentItem: ImageView {
        backText: root.backText
        imageSource: {
            let image;
            if (orientation.isPortraitOrientation) {
                image = "p_releasenotes";
            }
            else {
                image = "ls_releasenotes";
            }

            return "qrc:releasenotes/" + image;
        }
        onClose: {
            root.windowNavigator.close(root.objectName);
        }
    }
}
