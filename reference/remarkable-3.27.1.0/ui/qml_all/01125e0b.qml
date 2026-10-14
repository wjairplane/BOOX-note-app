// file: pageIndicator.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property int itemSpacing : 24
    }
    property var indicator: QtObject {
      property var active: QtObject {
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int sizing : 16
      }
      property var inactive: QtObject {
        property var border : Style.optionalBorder
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int sizing : 16
      }
      property var selected: QtObject {
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int sizing : 16
      }
    }
  }
  property var primary_inverted: Type {
    property var container: QtObject {
      property int itemSpacing : 24
    }
    property var indicator: QtObject {
      property var active: QtObject {
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int sizing : 16
      }
      property var inactive: QtObject {
        property var border : Style.optionalBorder_inverted
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int sizing : 16
      }
      property var selected: QtObject {
        property int borderRadius : 79992
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int sizing : 16
      }
    }
  }
}