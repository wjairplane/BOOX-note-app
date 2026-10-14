import device.view.documentview
import xofm.libs.devicescreen
import xofm.libs.qtgui
import xofm.libs.orientation


BaseView {
    id: root
    required property Orientation orientation
    property var onApplied: null
    property var onRejected: null
    property size paperSize

    contentItem: TemplateSelector {
        id: templateSelector
        rejectText: qsTr("Back", "Template selector")
        orientation: root.orientation
        paperSize: root.paperSize
        onApplied: (template, templateApplied, addToRecent) => {
            root.onApplied?.(template, templateApplied, addToRecent);
            root.windowNavigator.close();
        }
        onRejected: () => {
            root.onRejected?.()
            root.windowNavigator.close();
        }
    }


    onOpened: (args) => {
        const { currentTemplate, onApplied, onRejected, paperSize } = args || {};
        root.onApplied = onApplied || null;
        root.onRejected = onRejected || null;
        root.paperSize = paperSize ?? DeviceScreenInfo.paperSize;
        templateSelector.open(currentTemplate);
    }
}
