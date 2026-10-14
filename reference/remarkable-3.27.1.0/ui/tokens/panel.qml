// file: panel.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property int itemSpacing : 16
    }
    property var content: QtObject {
      property var container: QtObject {
        property int itemSpacing : 8
        property int paddingTop : 20
      }
      property var description: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.body.md : Style.body.md
      }
      property var label: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
      }
    }
    property var icon: QtObject {
      property var container: QtObject {
        property int paddingTop : 20
      }
      property var paperTablet: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int sizing : 48
      }
    }
  }
}