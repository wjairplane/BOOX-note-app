// file: cell.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int borderRadius : 0
      property int borderWidth : 2
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int horizontalPadding : 24
    }
    property var divider: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int height : 2
    }
    property var item: QtObject {
      property var background: QtObject {
        property var idle: QtObject {
          property int itemSpacing : 24
          property int verticalPadding : 24
        }
        property var selected: QtObject {
          property int itemSpacing : 24
          property int verticalPadding : 24
        }
      }
      property var focus: QtObject {
        property var idle: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : 8
        }
        property var selected: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : 8
        }
      }
      property var icon: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int sizing : 48
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int sizing : 48
        }
      }
      property var label: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.body.md : Style.body.md
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.body.md : Style.body.md
        }
      }
      property var status: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var hiddenTypography : Settings.accessibility ? Style.a11y.body.sm_hidden : Style.body.sm_hidden
          property var typography : Settings.accessibility ? Style.a11y.body.sm : Style.body.sm
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var hiddenTypography : Settings.accessibility ? Style.a11y.body.sm_hidden : Style.body.sm_hidden
          property var typography : Settings.accessibility ? Style.a11y.body.sm : Style.body.sm
        }
      }
    }
    property var title: QtObject {
      property var container: QtObject {
        property int paddingBottom : 16
      }
      property var idle: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.label.lg_strong : Style.label.lg_strong
      }
    }
  }
}