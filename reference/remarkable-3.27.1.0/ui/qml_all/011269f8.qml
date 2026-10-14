// file: selector.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var item: QtObject {
      property var background: QtObject {
        property var active: QtObject {
          property int borderRadius : 0
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int spacing : 24
        }
        property var idle: QtObject {
          property int borderRadius : 0
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int spacing : 24
        }
        property var selected: QtObject {
          property int borderRadius : 0
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int spacing : 24
        }
      }
      property var content: QtObject {
        property var icon: QtObject {
          property var active: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          }
          property var idle: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          }
          property var selected: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          }
        }
        property var label: QtObject {
          property var active: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
          }
          property var idle: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
          }
          property var selected: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
          }
        }
        property var spacing: QtObject {
          property int itemSpacing : 16
        }
      }
      property var focus: QtObject {
        property var active: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
        property var idle: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
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
  }
}