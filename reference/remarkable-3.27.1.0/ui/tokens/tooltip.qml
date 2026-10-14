// file: tooltip.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 185
        property int spacing : 32
        property int width : 730
      }
    }
    property var closeButton: QtObject {
      property var padding: QtObject {
        property int paddingRight : 4
        property int paddingTop : 4
      }
    }
    property var notch: QtObject {
      property var background: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 18
      }
      property var border: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 2
        property real height : 6.75
      }
    }
    property var text: QtObject {
      property var description: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property var typography : Settings.accessibility ? Style.a11y.body.md : Style.body.md
      }
      property var spacing: QtObject {
        property int itemSpacing : 16
      }
      property var title: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property var typography : Settings.accessibility ? Style.a11y.title.md_alt : Style.title.md_alt
      }
    }
  }
  property var secondary: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 185
        property int spacing : 32
        property int width : 730
      }
    }
    property var closeButton: QtObject {
      property var padding: QtObject {
        property int paddingRight : 4
        property int paddingTop : 4
      }
    }
    property var notch: QtObject {
      property var background: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 18
      }
      property var border: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 2
        property int height : 18
      }
    }
    property var text: QtObject {
      property var description: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.body.md : Style.body.md
      }
      property var spacing: QtObject {
        property int itemSpacing : 16
      }
      property var title: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.title.md_alt : Style.title.md_alt
      }
    }
  }
}