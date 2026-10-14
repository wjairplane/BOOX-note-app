// file: bottomSheet.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
    }
    property var item: QtObject {
      property var background: QtObject {
        property var idle: QtObject {
          property int horizontalPadding : 40
          property int itemSpacing : 16
          property int verticalPadding : 24
        }
        property var disabled: QtObject {
          property int horizontalPadding : 40
          property int itemSpacing : 16
          property int verticalPadding : 24
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int horizontalPadding : 40
          property int itemSpacing : 16
          property int verticalPadding : 24
        }
      }
      property var focus: QtObject {
        property var idle: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
        property var disabled: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
        property var selected: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
      }
      property var label: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_strong : Style.label.lg_strong
        }
        property var disabled: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_strong : Style.label.lg_strong
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_strong : Style.label.lg_strong
        }
      }
    }
    property var overlay: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
    }
    property var section: QtObject {
      property var container: QtObject {
        property int horizontalPadding : 40
        property int verticalPadding : 24
      }
      property var text: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property var typography : Settings.accessibility ? Style.a11y.caption.md : Style.caption.md
      }
    }
  }
}