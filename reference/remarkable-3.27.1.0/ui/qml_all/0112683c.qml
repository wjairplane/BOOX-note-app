// file: notificationBar.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var background: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
    }
    property var divider: QtObject {
      property var background: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int width : 2
      }
      property var spacing: QtObject {
        property int verticalPadding : 16
      }
    }
    property var message: QtObject {
      property var background: QtObject {
        property int itemSpacing : 16
        property int paddingLeft : 32
        property int paddingRight : 32
        property int verticalPadding : 16
      }
      property var icon: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int sizing : 48
      }
      property var text: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property var typography : Settings.accessibility ? Style.a11y.body.md_low : Style.body.md_low
      }
    }
  }
  property var secondary: Type {
    property var background: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int borderWidthTop : 2
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
    }
    property var divider: QtObject {
      property var background: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int width : 2
      }
      property var spacing: QtObject {
        property int verticalPadding : 16
      }
    }
    property var message: QtObject {
      property var background: QtObject {
        property int itemSpacing : 16
        property int paddingLeft : 32
        property int paddingRight : 32
        property int verticalPadding : 16
      }
      property var icon: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int sizing : 48
      }
      property var text: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.body.md_low : Style.body.md_low
      }
    }
  }
}