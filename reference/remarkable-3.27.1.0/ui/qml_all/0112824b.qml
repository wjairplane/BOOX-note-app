// file: buttonLarge.qml
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
        property int height : 112
        property int horizontalPadding : 32
      }
      property var disabled: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var selected: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
    }
    property var content: QtObject {
      property var icon: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int sizing : 48
        }
        property var disabled: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int sizing : 48
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int sizing : 48
        }
      }
      property var label: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
        property var disabled: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
      }
      property var spacing: QtObject {
        property int itemSpacing : 16
      }
    }
    property var focus: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
      property var disabled: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
      property var selected: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
    }
  }
  property var primary_inverted: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var disabled: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var selected: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
    }
    property var content: QtObject {
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
      }
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
  property var secondary: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var disabled: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var selected: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
    }
    property var content: QtObject {
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
      }
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
  property var secondary_inverted: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var disabled: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var selected: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
    }
    property var content: QtObject {
      property var icon: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int sizing : 48
        }
        property var disabled: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int sizing : 48
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int sizing : 48
        }
      }
      property var label: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
        property var disabled: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
      }
      property var spacing: QtObject {
        property int itemSpacing : 16
      }
    }
    property var focus: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
      property var disabled: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
      property var selected: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
    }
  }
  property var tertiary: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property int borderRadius : 0
        property int height : 112
        property int horizontalPadding : 32
      }
      property var disabled: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var selected: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
    }
    property var content: QtObject {
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
      }
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
    property var underline: QtObject {
      property var idle: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 2
      }
      property var disabled: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 2
      }
      property var selected: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 2
      }
    }
  }
  property var tertiary_inverted: Type {
    property var background: QtObject {
      property var idle: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var disabled: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 112
        property int horizontalPadding : 32
      }
      property var selected: QtObject {
        property int borderRadius : 0
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 112
        property int horizontalPadding : 32
      }
    }
    property var content: QtObject {
      property var icon: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int sizing : 48
        }
        property var disabled: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property int sizing : 48
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property int sizing : 48
        }
      }
      property var label: QtObject {
        property var idle: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
        property var disabled: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
        property var selected: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.label.lg_subtle : Style.label.lg_subtle
        }
      }
      property var spacing: QtObject {
        property int itemSpacing : 16
      }
    }
    property var focus: QtObject {
      property var idle: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
      property var disabled: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
      property var selected: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderRadius : 0
        property int borderWidth : 4
        property int spacing : -4
      }
    }
    property var underline: QtObject {
      property var idle: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 2
      }
      property var disabled: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
        property int height : 2
      }
      property var selected: QtObject {
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int height : 2
      }
    }
  }
}