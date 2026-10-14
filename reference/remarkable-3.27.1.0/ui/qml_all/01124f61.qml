// file: selectableChip.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 79992
        property int borderWidth : 2
        property int height : 56
        property int horizontalPadding : 24
      }
      property var longpress: QtObject {
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 56
        property int horizontalPadding : 24
      }
      property var selected: QtObject {
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 56
        property int horizontalPadding : 24
      }
    }
    property var focus: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 79992
        property int borderWidth : 4
        property int spacing : 8
      }
      property var longpress: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 79992
        property int borderWidth : 4
        property int spacing : 8
      }
      property var selected: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 79992
        property int borderWidth : 4
        property int spacing : 8
      }
    }
    property var height: QtObject {
      property int height : 80
    }
    property var label: QtObject {
      property var idle: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.label.sm_subtle : Style.label.sm_subtle
      }
      property var longpress: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property var typography : Settings.accessibility ? Style.a11y.label.sm_subtle : Style.label.sm_subtle
      }
      property var selected: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property var typography : Settings.accessibility ? Style.a11y.label.sm_subtle : Style.label.sm_subtle
      }
    }
    property var longpress: QtObject {
      property var border: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 79992
        property int borderWidth : 2
        property int spacing : -4
      }
    }
  }
}