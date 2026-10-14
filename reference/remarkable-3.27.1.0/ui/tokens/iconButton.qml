// file: iconButton.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var large : "IconButtonLarge.primary"
    property var medium : "IconButtonMedium.primary"
    property var small : "IconButtonSmall.primary"
  }
  property var primary_inverted: Type {
    property var large : "IconButtonLarge.primary_inverted"
    property var medium : "IconButtonMedium.primary_inverted"
    property var small : "IconButtonSmall.primary_inverted"
  }
  property var secondary: Type {
    property var large : "IconButtonLarge.secondary"
    property var medium : "IconButtonMedium.secondary"
    property var small : "IconButtonSmall.secondary"
  }
  property var secondary_inverted: Type {
    property var large : "IconButtonLarge.secondary_inverted"
    property var medium : "IconButtonMedium.secondary_inverted"
    property var small : "IconButtonSmall.secondary_inverted"
  }
  property var tertiary: Type {
    property var large : "IconButtonLarge.tertiary"
    property var medium : "IconButtonMedium.tertiary"
    property var small : "IconButtonSmall.tertiary"
  }
  property var tertiary_inverted: Type {
    property var large : "IconButtonLarge.tertiary_inverted"
    property var medium : "IconButtonMedium.tertiary_inverted"
    property var small : "IconButtonSmall.tertiary_inverted"
  }
}