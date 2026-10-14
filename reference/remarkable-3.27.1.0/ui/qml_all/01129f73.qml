// file: onboardingDialog.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var background: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
    }
    property var border: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int borderWidth : 2
    }
    property var bottomBar: QtObject {
      property var background: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property real borderWidthTop : 0.5
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      }
      property var spacing: QtObject {
        property var landscape: QtObject {
          property int itemSpacing : 40
          property int paddingBottom : 100
          property int paddingTop : 32
        }
        property var portrait: QtObject {
          property int itemSpacing : 40
          property int paddingBottom : 84
          property int paddingTop : 32
        }
      }
    }
    property var content: QtObject {
      property var container: QtObject {
        property int itemSpacing : 16
      }
      property var description: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      }
      property var title: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.title.lg : Style.title.lg
      }
    }
    property var elevation: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
    }
  }
}