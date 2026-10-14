// file: progressBar.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property int borderRadius : 79992
    }
    property var fill: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
    }
    property var track: QtObject {
      property var large: QtObject {
        property var border : Style.optionalBorder
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 40
      }
      property var small: QtObject {
        property var border : Style.optionalBorder
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 16
      }
    }
  }
  property var primary_inverted: Type {
    property var container: QtObject {
      property int borderRadius : 79992
    }
    property var fill: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
    }
    property var track: QtObject {
      property var large: QtObject {
        property var border : Style.optionalBorder_inverted
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 40
      }
      property var small: QtObject {
        property var border : Style.optionalBorder_inverted
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 16
      }
    }
  }
}