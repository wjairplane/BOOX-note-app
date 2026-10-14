import QtQuick
import QtQuick.Layouts

import common

GridView {
    id: root

    property var selectedTemplate
    property bool shouldRestrict: false

    signal addCustomTemplateToShownList(var customTemplate)
    signal applied(var aTemplate, bool isTemplateApplied, bool shouldAddToRecents)
    signal deselectTemplate
    signal restrict

    // The height is based on the TemplateDelegate size
    cellHeight: 340
    cellWidth: root.width / Math.ceil(root.width / cellHeight)
    cacheBuffer: 0
    interactive: false
    clip: true

    delegate: TemplateDelegate {
        width: root.cellWidth
        height: root.cellHeight
        isCurrent: root.currentIndex === index
        isSelected: root.selectedTemplate === modelData

        onClicked: (template) => {
            if (root.shouldRestrict) {
                root.restrict();
                return;
            }

            if (root.selectedTemplate === template) {
                root.deselectTemplate();
            } else if (null === root.selectedTemplate){
                root.applied(template, true, true);
            }
        }

        Component.onCompleted: {
            if (modelData.customTemplate) {
                addCustomTemplateToShownList(modelData);
            }
        }
    }

    function calculatePreferredHeight() {
        const columns = Math.floor(width / (cellWidth));
        const rows = Math.ceil(model.length / Math.max(1, columns));
        return rows * cellHeight;
    }
}
