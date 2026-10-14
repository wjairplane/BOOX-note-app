// file: sidebar.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property var foldout: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      }
      property var sidebar: QtObject {
        property var borderRight : Style.divider
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
      }
    }
    property var foldout: QtObject {
      property var item: QtObject {
        property var background: QtObject {
          property var idle: QtObject {
            property int borderRadius : 0
            property int horizontalPadding : 32
            property int itemSpacing : 16
            property int verticalPadding : 32
          }
          property var selected: QtObject {
            property int borderRadius : 0
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int horizontalPadding : 32
            property int itemSpacing : 16
            property int verticalPadding : 32
          }
        }
        property var content: QtObject {
          property var description: QtObject {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property var typography : Settings.accessibility ? Style.a11y.caption.md : Style.caption.md
            }
            property var selected: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
              property var typography : Settings.accessibility ? Style.a11y.caption.md : Style.caption.md
            }
          }
          property var icon: QtObject {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property int sizing : 48
            }
            property var selected: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
              property int sizing : 48
            }
          }
          property var label: QtObject {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
            }
            property var selected: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
              property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
            }
          }
          property var spacing: QtObject {
            property int itemSpacing : 16
          }
        }
        property var focus: QtObject {
          property var idle: QtObject {
            property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int borderRadius : 0
            property int borderWidth : 4
            property int spacing : -4
          }
          property var selected: QtObject {
            property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
            property int borderRadius : 0
            property int borderWidth : 4
            property int spacing : -4
          }
        }
      }
    }
    property var item: QtObject {
      property var background: QtObject {
        property var idle: QtObject {
          property int paddingLeft : 32
          property int paddingRight : 96
          property int verticalPadding : 32
        }
        property var disabled: QtObject {
          property int paddingLeft : 32
          property int paddingRight : 96
          property int verticalPadding : 32
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int paddingLeft : 32
          property int paddingRight : 96
          property int verticalPadding : 32
        }
      }
      property var content: QtObject {
        property var chevron: QtObject {
          property var idle: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int sizing : 48
          }
          property var disabled: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int sizing : 48
          }
          property var selected: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
            property int sizing : 48
          }
        }
        property var icon: QtObject {
          property var idle: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int sizing : 48
          }
          property var disabled: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int sizing : 48
          }
          property var selected: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
            property int sizing : 48
          }
        }
        property var label: QtObject {
          property var idle: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
          }
          property var disabled: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
          }
          property var selected: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
            property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
          }
        }
        property var spacing: QtObject {
          property int itemSpacing : 16
          property int paddingRight : 24
        }
      }
      property var divider: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 2
      }
      property var focus: QtObject {
        property var idle: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
        property var disabled: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
        property var selected: QtObject {
          property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int borderRadius : 0
          property int borderWidth : 4
          property int spacing : -4
        }
      }
    }
    property var sectionHeader: QtObject {
      property var background: QtObject {
        property int horizontalPadding : 16
        property int paddingBottom : 8
        property int paddingTop : 16
      }
      property var label: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property var typography : Settings.accessibility ? Style.a11y.label.sm_subtle : Style.label.sm_subtle
      }
    }
  }
}