import QtQuick
import com.remarkable
import device.global
import device.ui.controls

/*!
    \qmltype DocumentViewShortcuts
    \brief Keyboard shortcuts for DocumentView
*/
Item {
    id: root

    required property bool shortcutsEnabled
    required property bool subDialogOpen
    required property bool textMode
    required property bool pageSliderVisible
    required property bool pagesVisible

    signal searchRequested
    signal moveBackwardRequested
    signal moveForwardRequested
    signal openFastScrollRequested
    signal closeFastScrollRequested
    signal pasteRequested
    signal undoRequested
    signal redoRequested
    signal closeRequested(string sequence)
    signal zoomInRequested
    signal zoomOutRequested

    Shortcut {
        enabled: root.shortcutsEnabled && !root.subDialogOpen
        sequence: "Ctrl+F"
        onActivated: root.searchRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled
                 && !root.textMode
                 && (root.pageSliderVisible || DeviceInfo.deviceType === DeviceInfo.RM100)
                 && !root.pagesVisible
        sequence: "Left"
        onActivated: root.moveBackwardRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled
                 && !root.textMode
                 && (root.pageSliderVisible || DeviceInfo.deviceType === DeviceInfo.RM100)
                 && !root.pagesVisible
        sequence: "Right"
        onActivated: root.moveForwardRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled && !DeviceApp.runningOnDevice
        sequence: "Ctrl+F1"
        onActivated: root.openFastScrollRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled && !DeviceApp.runningOnDevice
        sequence: "Ctrl+F2"
        onActivated: root.closeFastScrollRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled && !root.textMode
        sequence: "Ctrl+V"
        onActivated: {
            // If we make the call to paste right away, we'd potentially go
            // into textMode which in turn would deliver the current key
            // press also to DeviceSceneView, which in turn would interpret it as
            // a paste shortcut and we'd paste twice. So rather, call paste
            // () function later to avoid that confusion.
            Qt.callLater(root.pasteRequested);
        }
    }

    Shortcut {
        enabled: root.shortcutsEnabled && !root.textMode
        sequence: "Ctrl+Z"
        onActivated: root.undoRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled && !root.textMode
        sequence: "Ctrl+Y"
        onActivated: root.redoRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled && !DeviceApp.runningOnDevice && !root.textMode
        sequence: "Ctrl+Left"
        onActivated: root.moveBackwardRequested()
    }

    Shortcut {
        enabled: root.shortcutsEnabled && !DeviceApp.runningOnDevice && !root.textMode
        sequence: "Ctrl+Right"
        onActivated: root.moveForwardRequested()
    }

    CloseShortcut {
        objectName: "docview-close"
        enabled: root.shortcutsEnabled && !root.subDialogOpen
        onActivated: (sequence) => root.closeRequested(sequence)
    }
}
