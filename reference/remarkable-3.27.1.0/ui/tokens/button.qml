// file: button.qml
pragma Singleton
import QtQuick
QtObject {
  id: root
  component Type : QtObject {}

  property var primary: Type {
    property var large : "ButtonLarge.primary"
    property var medium : "ButtonMedium.primary"
    property var small : "ButtonSmall.primary"
  }
  property var primary_inverted: Type {
    property var large : "ButtonLarge.primary_inverted"
    property var medium : "ButtonMedium.primary_inverted"
    property var small : "ButtonSmall.primary_inverted"
  }
  property var secondary: Type {
    property var large : "ButtonLarge.secondary"
    property var medium : "ButtonMedium.secondary"
    property var small : "ButtonSmall.secondary"
  }
  property var secondary_inverted: Type {
    property var large : "ButtonLarge.secondary_inverted"
    property var medium : "ButtonMedium.secondary_inverted"
    property var small : "ButtonSmall.secondary_inverted"
  }
  property var tertiary: Type {
    property var large : "ButtonLarge.tertiary"
    property var medium : "ButtonMedium.tertiary"
    property var small : "ButtonSmall.tertiary"
    property var xsmall : "ButtonXsmall.tertiary"
  }
  property var tertiary_inverted: Type {
    property var large : "ButtonLarge.tertiary_inverted"
    property var medium : "ButtonMedium.tertiary_inverted"
    property var small : "ButtonSmall.tertiary_inverted"
  }
}