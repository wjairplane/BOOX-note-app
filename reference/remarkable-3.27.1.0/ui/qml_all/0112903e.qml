// file: setupPage.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var background: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int paddingBottom : 176
      property int paddingLeft : 176
      property int paddingRight : 176
      property int paddingTop : 176
    }
    property var content: QtObject {
      property var container: QtObject {
        property int itemSpacing : 32
      }
      property var description: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
      }
      property var title: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.title.xl : Style.title.xl
      }
    }
    property var landscape: QtObject {
      property var background: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int paddingBottom : 132
        property int paddingLeft : 351
        property int paddingRight : 351
        property int paddingTop : 132
      }
      property var content: QtObject {
        property var container: QtObject {
          property int itemSpacing : 32
        }
        property var description: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
        }
        property var title: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.title.xl : Style.title.xl
        }
      }
    }
  }
  property var secondary: Type {
    property var background: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int paddingBottom : 176
      property int paddingLeft : 176
      property int paddingRight : 176
      property int paddingTop : 234
    }
    property var content: QtObject {
      property var container: QtObject {
        property int itemSpacing : 32
      }
      property var description: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
      }
      property var title: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.title.xl : Style.title.xl
      }
    }
    property var landscape: QtObject {
      property var background: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int paddingBottom : 132
        property int paddingLeft : 351
        property int paddingRight : 351
        property int paddingTop : 132
      }
      property var content: QtObject {
        property var container: QtObject {
          property int itemSpacing : 32
        }
        property var description: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.body.lg : Style.body.lg
        }
        property var title: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.title.xl : Style.title.xl
        }
      }
    }
  }
}