// file: actionBar.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var actionButtonContainer: QtObject {
      property int paddingRight : 0
    }
    property var container: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
    }
    property var item: QtObject {
      property var actionButton: QtObject {
        property var background: QtObject {
          property var idle: QtObject {
            property int borderRadius : 0
            property int horizontalPadding : 8
          }
          property var selected: QtObject {
            property int borderRadius : 0
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
            property int horizontalPadding : 8
          }
        }
        property var content: QtObject {
          property var icon: QtObject {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
              property int sizing : 48
            }
            property var selected: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property int sizing : 48
            }
          }
          property var label: QtObject {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
              property var typography : Settings.accessibility ? Style.a11y.label.sm_subtle_low : Style.label.sm_subtle_low
            }
            property var selected: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property var typography : Settings.accessibility ? Style.a11y.label.sm_subtle_low : Style.label.sm_subtle_low
            }
          }
          property var spacing: QtObject {
            property int itemSpacing : 4
          }
        }
      }
      property var focus: QtObject {
        property var idle: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
        property var selected: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
      }
    }
    property var title: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property var typography : Settings.accessibility ? Style.a11y.label.lg_strong : Style.label.lg_strong
    }
  }
}