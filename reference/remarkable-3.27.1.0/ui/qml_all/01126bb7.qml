// file: infoMessage.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int itemSpacing : 16
      property int spacing : 24
    }
    property var content: QtObject {
      property var container: QtObject {
        property int itemSpacing : 16
      }
      property var description: QtObject {
        property var additionalText: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.caption.md : Style.caption.md
        }
        property var container: QtObject {
          property int itemSpacing : 16
        }
        property var divider: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int height : 2
        }
      }
      property var message: QtObject {
        property var container: QtObject {
          property int itemSpacing : 24
        }
        property var progressBarWidth: QtObject {
          property int sizing : 120
        }
        property var text: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.body.sm : Style.body.sm
        }
      }
      property var title: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
      }
    }
    property var icon: QtObject {
      property var container: QtObject {
        property var idle: QtObject {
          property int paddingTop : 0
        }
        property var default_a11y: QtObject {
          property int paddingTop : 4
        }
        property var none: QtObject {
          property int paddingTop : 0
        }
        property var none_a11y: QtObject {
          property int paddingTop : 4
        }
      }
      property var paperTablet: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int sizing : 48
      }
    }
  }
  property var secondary: Type {
    property var container: QtObject {
      property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
      property int borderWidth : 2
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      property int itemSpacing : 16
      property int spacing : 24
    }
    property var content: QtObject {
      property var container: QtObject {
        property int itemSpacing : 16
      }
      property var description: QtObject {
        property var additionalText: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.caption.md : Style.caption.md
        }
        property var container: QtObject {
          property int itemSpacing : 16
        }
        property var divider: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int height : 2
        }
      }
      property var message: QtObject {
        property var container: QtObject {
          property int itemSpacing : 24
        }
        property var text: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.body.sm : Style.body.sm
        }
      }
      property var title: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
      }
    }
    property var icon: QtObject {
      property var container: QtObject {
        property var idle: QtObject {
          property int paddingTop : 0
        }
        property var default_a11y: QtObject {
          property int paddingTop : 4
        }
        property var none: QtObject {
          property int paddingTop : 0
        }
        property var none_a11y: QtObject {
          property int paddingTop : 4
        }
      }
      property var paperTablet: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int sizing : 48
      }
    }
  }
}