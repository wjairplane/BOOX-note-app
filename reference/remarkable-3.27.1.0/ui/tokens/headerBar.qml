// file: headerBar.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var breadcrumb: QtObject {
      property var item: QtObject {
        property var background: QtObject {
          property var idle: QtObject {
            property int borderRadius : 0
          }
          property var selected: QtObject {
            property int borderRadius : 0
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          }
        }
        property var label: QtObject {
          property var primary: Type {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            }
          }
          property var secondary: Type {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
            }
            property var selected: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
            }
          }
        }
      }
    }
    property var breadcrumbContainer: QtObject {
      property int itemSpacing : 24
    }
    property var container: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int horizontalPadding : 32
      property int itemSpacing : 24
      property int verticalPadding : 16
    }
    property var icon: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int sizing : 48
    }
  }
}