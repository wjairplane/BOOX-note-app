// file: toggle.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var focus: QtObject {
    property var idle: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int borderRadius : 79992
      property int borderWidth : 4
      property int spacing : 8
    }
  }
  property var primary: Type {
    property var container: QtObject {
      property int verticalPadding : 16
    }
    property var item: QtObject {
      property var background: QtObject {
        property var off: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int borderRadius : 79992
          property int borderWidth : 2
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int paddingRight : 40
          property int spacing : 8
        }
        property var on: QtObject {
          property int borderRadius : 79992
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int paddingLeft : 40
          property int spacing : 8
        }
      }
      property var handle: QtObject {
        property var off: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int sizing : 32
        }
        property var on: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int sizing : 32
        }
      }
    }
  }
}