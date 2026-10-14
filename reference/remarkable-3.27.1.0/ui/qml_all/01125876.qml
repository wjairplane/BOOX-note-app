// file: keyboard.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property var landscape: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int horizontalPadding : 73
        property int paddingBottom : 40
        property int paddingTop : 24
      }
      property var portrait: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int horizontalPadding : 40
        property int paddingBottom : 40
        property int paddingTop : 24
      }
    }
    property var key: QtObject {
      property var background: QtObject {
        property var idle: QtObject {
          property int height : 120
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int height : 120
        }
      }
      property var glyph: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.xl_strong : Style.label.xl_strong
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.label.xl_strong : Style.label.xl_strong
        }
      }
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
      property var iconWide: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int height : 48
          property int width : 60
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int height : 48
          property int width : 60
        }
      }
      property var popover: QtObject {
        property var container: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int borderWidth : 2
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        }
        property var notch: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        }
      }
    }
    property var keyboardBar: QtObject {
      property var container: QtObject {
        property int verticalPadding : 8
      }
      property var input: QtObject {
        property var background: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int spacing : 4
        }
        property var text: QtObject {
          property var idle: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.body.md : Style.body.md
          }
          property var selected: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.body.md : Style.body.md
          }
        }
      }
    }
    property var keyboardButton: QtObject {
      property var background: QtObject {
        property var idle: QtObject {
          property int height : 120
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int height : 120
        }
      }
      property var border: QtObject {
        property var idle: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int borderWidth : 2
        }
      }
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
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
      }
    }
  }
}