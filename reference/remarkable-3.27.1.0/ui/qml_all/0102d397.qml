import QtQuick
import QtQuick.Layouts 1.3

import com.remarkable
import common
import device.ui.controls
import device.ui.text
import device.global

Background {
    id: root
    signal close

    implicitHeight: tabControl.implicitHeight + gridContainer.implicitHeight

    property alias currentIndex: tabControl.currentIndex

    Connections {
        target: KeyboardInfo
        function onKeyboardConnectedChanged(){
            root.close();
        }
    }

    Keys.onTabPressed: (event) => {
        event.accepted =  true;
        if (tabControl.currentIndex === ShortcutCheatSheet.Tab.Editing) {
            tabControl.currentIndex = ShortcutCheatSheet.Tab.Navigation;
        } else {
            tabControl.currentIndex = ShortcutCheatSheet.Tab.Editing;
        }
    }

    enum Tab {
        Editing,
        Navigation
    }

    readonly property var windowsShortcuts: [
        {
            type: ShortcutCheatSheet.Tab.Editing,
            //: Name of keyboard shortcut category
            title: qsTr("Editing"),
            //: Name of formatting type
            shortcuts: [{name: qsTr("Title"),                       keys: ["ctrl", "1"],                                 },
                        //: Name of formatting type
                        {name: qsTr("Subheading"),                  keys: ["ctrl", "2"],                                 },
                        //: Name of formatting type
                        {name: qsTr("Body text"),                   keys: ["ctrl", "3"],                                 },
                        {name: qsTr("Bullet points"),               keys: ["ctrl", "4"],                                 },
                        {name: qsTr("Checkbox"),                    keys: ["ctrl", "5"],                                 },
                        {name: qsTr("Cut"),                         keys: ["ctrl", "X"],                                 },
                        {name: qsTr("Copy"),                        keys: ["ctrl", "C"],                                 },
                        {name: qsTr("Paste"),                       keys: ["ctrl", "V"],                                 },
                        {name: qsTr("Paste without formatting"),    keys: ["ctrl", "qrc:/ark/icons/arrow_up", "V"],      },
                        {name: qsTr("Select all"),                  keys: ["ctrl", "A"],                                 },
                        {name: qsTr("Undo"),                        keys: ["ctrl", "Z"],                                 },
                        {name: qsTr("Redo"),                        keys: ["ctrl", "Y"],                                 },
                        {name: qsTr("Symbol menu"),                 keys: ["ctrl", "alt", "space"],                      }
            ]
        },
        {
            type: ShortcutCheatSheet.Tab.Navigation,
            title: qsTr("Navigation"),
            shortcuts: [
                        {name: qsTr("Next word"),                           keys: ["ctrl", "qrc:/ark/icons/chevron_left", "qrc:/ark/icons/chevron_right"],  extraText: "/"},
                        {name: qsTr("Next paragraph"),                      keys: ["ctrl", "qrc:/ark/icons/chevron_up", "qrc:/ark/icons/chevron_down"],     extraText: "/"},
                        {name: qsTr("Search"),                              keys: ["ctrl", "F"],                                                            },
                        {name: qsTr("Open document or folder"),             keys: ["enter"],                                                                },
                        {name: qsTr("Close document or folder"),            keys: ["ctrl", "W"],                                                            },
                        {name: qsTr("Select or deselect"),                  keys: ["space"],                                                                },
                        {name: qsTr("Move between sections and items"),     keys: ["qrc:/ark/icons/tab"],                                                   },
                        {name: qsTr("Open or close drawer"),                keys: ["ctrl", "qrc:/ark/icons/tab"],                                           },
                        {name: qsTr("Open settings"),                       keys: ["ctrl", ","],                                                            },
                        {name: qsTr("Create a new folder"),                 keys: ["ctrl", "qrc:/ark/icons/arrow_up", "N"],                                 },
                        {name: qsTr("Create a new notebook"),               keys: ["ctrl", "N"],                                                            },
                        {name: qsTr("Add quick sheets"),                    keys: ["ctrl", "O"],                                                            },
            ]
        },
    ]
    readonly property var macShortcuts: [
        {
            type: ShortcutCheatSheet.Tab.Editing,
            //: Name of keyboard shortcut category
            title: qsTr("Editing"),
            //: Name of formatting type
            shortcuts: [{name: qsTr("Title"),                       keys: ["alt", "1"],                                },
                        //: Name of formatting type
                        {name: qsTr("Subheading"),                  keys: ["alt", "2"],                                },
                        //: Name of formatting type
                        {name: qsTr("Body text"),                   keys: ["alt", "3"],                                },
                        {name: qsTr("Bullet points"),               keys: ["alt", "4"],                                },
                        {name: qsTr("Checkbox"),                    keys: ["alt", "5"],                                },
                        {name: qsTr("Cut"),                         keys: ["alt", "X"],                                },
                        {name: qsTr("Copy"),                        keys: ["alt", "C"],                                },
                        {name: qsTr("Paste"),                       keys: ["alt", "V"],                                },
                        {name: qsTr("Paste without formatting"),    keys: ["alt", "qrc:/ark/icons/arrow_up", "V"],     },
                        {name: qsTr("Select all"),                  keys: ["alt", "A"],                                },
                        {name: qsTr("Undo"),                        keys: ["alt", "Z"],                                },
                        {name: qsTr("Redo"),                        keys: ["alt", "qrc:/ark/icons/arrow_up", "Z"],     },
                        {name: qsTr("Symbol menu"),                 keys: ["opt", "alt", "space"],                     }
            ]
        },
        {
            type: ShortcutCheatSheet.Tab.Navigation,
            title: qsTr("Navigation"),
            shortcuts: [{name: qsTr("Next word"),                             keys: ["opt", "qrc:/ark/icons/chevron_left", "qrc:/ark/icons/chevron_right"],   extraText: "/"},
                        {name: qsTr("Next paragraph"),                        keys: ["opt", "qrc:/ark/icons/chevron_up", "qrc:/ark/icons/chevron_down"],      extraText: "/"},
                        {name: qsTr("Start/end of page"),                     keys: ["alt",  "qrc:/ark/icons/chevron_up", "qrc:/ark/icons/chevron_down"],     extraText: "/"},
                        {name: qsTr("Search"),                                keys: ["alt", "F"],                                                             },
                        {name: qsTr("Open document or folder"),               keys: ["enter"],                                                                },
                        {name: qsTr("Close document or folder"),              keys: ["alt", "W"],                                                             },
                        {name: qsTr("Select or deselect"),                    keys: ["space"],                                                                },
                        {name: qsTr("Move between sections and items"),       keys: ["qrc:/ark/icons/tab"],                                                   },
                        {name: qsTr("Open or close drawer"),                  keys: ["alt", "qrc:/ark/icons/tab"],                                            },
                        {name: qsTr("Open settings"),                         keys: ["alt", ","],                                                             },
                        {name: qsTr("Create a new folder"),                   keys: ["alt", "qrc:/ark/icons/arrow_up", "N"],                                  },
                        {name: qsTr("Create a new notebook"),                 keys: ["alt", "N"],                                                             },
                        {name: qsTr("Add quick sheets"),                      keys: ["alt", "O"],                                                             },
            ]
        }
    ]

    property var tabModel: (Settings.inputFlavor === Settings.InputFlavorType.Windows) ? windowsShortcuts : macShortcuts

    TabControl {
        id: tabControl
        valueFunction: (index, model) => model[index].title
        model: tabModel
        showCloseButton: true
        showTopBorderLine: true
        onCloseButtonClicked: root.close()
    }

    Item {
        id: gridContainer

        readonly property int verticalPadding: 64
        readonly property int horizontalPadding: 32

        anchors {
            top: tabControl.bottom
            left: parent.left
            leftMargin: gridContainer.horizontalPadding
            right: parent.right
            rightMargin: gridContainer.horizontalPadding
        }

        implicitHeight: gridContainer.verticalPadding * 2 + grid.implicitHeight

        GridLayout {
            id: grid

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            readonly property int highestShortcutCount:  windowsShortcuts.map(tab => tab.shortcuts.length)
                                                            .concat(macShortcuts.map(tab => tab.shortcuts.length))
                                                            .sort((a, b) => b - a)[0];

            rows: Math.ceil(highestShortcutCount / 2)
            columnSpacing: 240 // What is this magic number? plausibly the tabcontrol height * 2, best we could come up with
            rowSpacing: 32
            flow: GridLayout.TopToBottom

            Repeater {
                model: tabModel[tabControl.currentIndex].shortcuts
                delegate: CheatSheetKeyCombination {
                    required property var modelData
                    shortcut: modelData
                    Layout.preferredWidth: (grid.width / 2) - grid.columnSpacing
                }
            }
        }

        Rectangle {
            anchors.top: grid.top
            anchors.bottom: grid.bottom
            anchors.horizontalCenter: grid.horizontalCenter
            width: 2
            color: Values.colorBlack
        }
    }
}
