// file: toolbar.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var container: QtObject {
      property int borderRadius : 0
      property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
    }
    property var foldout: QtObject {
      property var container: QtObject {
        property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
        property int borderWidth : 2
        property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
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
      property var grid: QtObject {
        property var item: QtObject {
          property var background: QtObject {
            property var idle: QtObject {
              property int borderRadius : 0
              property int height : 112
              property int horizontalPadding : 32
              property int itemSpacing : 8
            }
            property var disabled: QtObject {
              property int borderRadius : 0
              property int height : 112
              property int horizontalPadding : 32
              property int itemSpacing : 8
            }
            property var selected: QtObject {
              property int borderRadius : 0
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property int height : 112
              property int horizontalPadding : 32
              property int itemSpacing : 8
            }
          }
          property var content: QtObject {
            property var icon: QtObject {
              property var idle: QtObject {
                property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
                property int sizing : 48
              }
              property var disabled: QtObject {
                property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
                property int borderWidth : 4
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
              property var disabled: QtObject {
                property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
                property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
              }
              property var selected: QtObject {
                property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
                property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
              }
            }
            property var spacing: QtObject {
              property int itemSpacing : 0
            }
          }
        }
        property var spacing: QtObject {
          property int horizontalPadding : 32
          property int itemSpacing : 0
          property int paddingBottom : 32
        }
      }
      property var item: QtObject {
        property var background: QtObject {
          property var idle: QtObject {
            property int borderRadius : 0
            property int height : 112
            property int horizontalPadding : 32
          }
          property var disabled: QtObject {
            property int borderRadius : 0
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
          property var description: QtObject {
            property var idle: QtObject {
              property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
              property var typography : Settings.accessibility ? Style.a11y.caption.md : Style.caption.md
            }
            property var disabled: QtObject {
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
              property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
            }
            property var disabled: QtObject {
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
      }
      property var layer: QtObject {
        property var idle: QtObject {
          property var action: QtObject {
            property var background: QtObject {
              property var idle: QtObject {
                property int spacing : 16
              }
              property var disabled: QtObject {
                property int spacing : 16
              }
              property var selected: QtObject {
                property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
                property int spacing : 16
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
          property var container: QtObject {
            property int spacing : 16
          }
          property var focus: QtObject {
            property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int borderRadius : 0
            property int borderWidth : 4
            property int spacing : -4
          }
          property var label: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
          }
        }
        property var selected: QtObject {
          property var action: QtObject {
            property var background: QtObject {
              property var idle: QtObject {
                property int spacing : 16
              }
              property var disabled: QtObject {
                property int spacing : 16
              }
              property var selected: QtObject {
                property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
                property int spacing : 16
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
          property var container: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
            property int spacing : 16
          }
          property var focus: QtObject {
            property color borderColor : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
            property int borderRadius : 0
            property int borderWidth : 4
            property int spacing : -4
          }
          property var label: QtObject {
            property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#ffffff")) : Qt.color("#ffffff")
            property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
          }
        }
      }
      property var section: QtObject {
        property var container: QtObject {
          property int horizontalPadding : 32
          property int itemSpacing : 8
          property int paddingBottom : 16
          property int paddingTop : 24
        }
        property var description: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.caption.md : Style.caption.md
        }
        property var label: QtObject {
          property color fill : Settings.usingDebugColors ? Settings.convertColor(Qt.color("#000000")) : Qt.color("#000000")
          property var typography : Settings.accessibility ? Style.a11y.label.md : Style.label.md
        }
      }
      property var tags: QtObject {
        property var chip_spacing: QtObject {
          property int itemSpacing : 8
        }
        property var container: QtObject {
          property int horizontalPadding : 32
          property int itemSpacing : 16
          property int verticalPadding : 32
        }
      }
      property var toggle: QtObject {
        property var spacing: QtObject {
          property int itemSpacing : 32
        }
      }
    }
  }
}