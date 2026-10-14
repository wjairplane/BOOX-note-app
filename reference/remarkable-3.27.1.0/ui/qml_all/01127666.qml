// file: inputField.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var background: QtObject {
      property int height : 96
      property int horizontalPadding : 4
      property int itemSpacing : 16
    }
    property var focus: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int borderWidth : 4
      property int spacing : 8
    }
    property var icon: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int sizing : 48
    }
    property var item: QtObject {
      property var background: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int height : 80
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int height : 80
        }
      }
      property var label: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
        }
      }
    }
    property var underline: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int borderWidth : 2
    }
  }
  property var primary_inverted: Type {
    property var background: QtObject {
      property int height : 96
      property int horizontalPadding : 4
      property int itemSpacing : 16
    }
    property var focus: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int borderWidth : 4
      property int spacing : 8
    }
    property var icon: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int sizing : 48
    }
    property var item: QtObject {
      property var background: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int height : 80
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int height : 80
        }
      }
      property var label: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
        }
      }
    }
    property var underline: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int borderWidth : 2
    }
  }
}