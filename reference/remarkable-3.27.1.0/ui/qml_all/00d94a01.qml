import QtQuick
import QtQuick.Layouts

import com.remarkable
import common

import xofm.libs.qtgui // BaseView

import device.ui.text
import device.ui.controls

import ark.controls as ArkControls

/**
  Accessibility settings page

  This allows the user to configure left/right hand mode and large/regular font sizes.
*/
DeviceKeyboardNavigationHandler {
    id: root
    objectName: "Accessibility"

    property var accessibilityWidgets
    property bool showheader: true
    property bool fullscreen: false

    function overrideNavigation(event) {
        // Handle going to the sidebar
        if (event.key === Qt.Key_Left && navigationModel[0] === root.current) {
            root.resetFocusIndex();
            root.focus = false;
            // settings.focus = true;
            settings.navigate();
            return true;
        }
        return false;
    }

    navigationModel: []
    canAcceptTabActivation: true
    keyOverrideHandler: overrideNavigation.bind(this)

    onActivated: (element) => {
        if (element) {
            element.parent.activate(element);
        }
    }

    ScrollArea {
        id: flickable

        anchors.fill: parent
        contentWidth: width
        contentHeight: itemWrapper.childrenRect.height + (itemWrapper.children.length - 1) * ArkControls.Values.spacing.xlarge

        enableScrollbar: true
        permanentScrollbar: true
        scrollbarTopMargin: header.y

        Item {
            id: itemWrapper
            implicitWidth: flickable.width

            ArkControls.PlaceholderBar {
                id: placeholder
                width: parent.width
            }

            ArkControls.Title {
                id: header
                type: ArkControls.Title.Large
                anchors {
                    top: placeholder.bottom
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                }
                visible: root.showheader
                //: Title of Accessibility settings page
                text: qsTr("Accessibility settings")
            }

            ColumnLayout {
                id: column
                anchors {
                    left: parent.left
                    leftMargin: ArkControls.Values.margin.horizontal.large
                    right: parent.right
                    rightMargin: ArkControls.Values.margin.horizontal.large
                    top: header.bottom
                    topMargin: ArkControls.Values.platform.spacing.x2large
                }
                spacing: ArkControls.Values.platform.spacing.x2large

                Repeater {
                    id: widgetRepeater
                    Layout.fillWidth: true
                    model: root.accessibilityWidgets;
                    delegate: WidgetLoader {
                        id: widgetLoader
                        Layout.fillWidth: true
                        z: parent.z + 2
                        height: widgetLoader.height
                    }
                }

                ArkControls.Panel {
                    Layout.fillWidth: true
                    //: Name of selection between default or large
                    label: qsTr("Readability")
                    description: qsTr("Choose the size you prefer for system font and layout.")
                    showAttachment: true
                    attachment: RowLayout {
                        // Used by keyboard navigation to change Settings.accessibilityMode
                        function activate(selector) {
                            selector.click();
                        }

                        Layout.fillWidth: true
                        spacing: ArkControls.Values.spacing.large

                        // We want the user to immediately see which selector is now checked,
                        // without having to wait for the changed Settings.accessibilityMode
                        // to finish updating all UI elements, as that tends to take some time
                        // on the device.
                        Timer {
                            id: delayedSelectionProcessor
                            interval: 20
                            repeat: false
                            onTriggered: Settings.accessibilityMode = largeFontSizeSelector.checked
                        }

                        ArkControls.Selector {
                            id: standardFontSizeSelector
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Standard")
                            objectName: "StandardTextSizeSelector"
                            illustration: "qrc:/settings/illustrations/readability_standard"
                            checked: !Values.accessibilityMode
                            autoExclusive: true
                            checkable: true
                            onClicked: delayedSelectionProcessor.restart()
                            Component.onCompleted: root.navigationModel[0] = standardFontSizeSelector;

                            FocusFrame {
                                anchors.fill: parent
                                visible: root.current === standardFontSizeSelector
                            }
                        }

                        ArkControls.Selector {
                            id: largeFontSizeSelector
                            Layout.alignment: Qt.AlignHCenter
                            //: Secondary button with accessibility font size
                            text: qsTr("Large")
                            objectName: "LargeTextSizeSelector"
                            illustration: "qrc:/settings/illustrations/readability_large"
                            checked: Values.accessibilityMode
                            autoExclusive: true
                            checkable: true
                            onClicked: delayedSelectionProcessor.restart()
                            Component.onCompleted: root.navigationModel[3] = largeFontSizeSelector;

                            FocusFrame {
                                anchors.fill: parent
                                visible: root.current === largeFontSizeSelector
                            }
                        }
                    }
                }

                ArkControls.Panel {
                    Layout.fillWidth: true
                    //: Name of radio button selection between left and right
                    label: qsTr("Handedness")
                    description: qsTr("Choose the hand you prefer to write and draw with.")
                    showAttachment: true
                    attachment: HandednessChooser {
                        navigationModel: root.navigationModel
                        navigationHandler: root
                        navigationIndex: 4
                        Layout.fillWidth: true
                        spacing: ArkControls.Values.spacing.large
                    }
                }
            }
        }
    }
}
