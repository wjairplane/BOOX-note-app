import QtQuick
import ark.tokens as ArkTokens

QtObject {
    id: root
    required property QtObject tokens
    required property int baseSize
    readonly property int none: tokens.none
    readonly property int small_static: tokens.small_static ?? small
    readonly property int medium_static: tokens.medium_static ?? medium
    readonly property int small: Math.round(tokens.small * (tokens.small > 1 ? 1 : baseSize))
    readonly property int medium: Math.round(tokens.medium * (tokens.medium > 1 ? 1 : baseSize))
    readonly property int large: Math.round(tokens.large * (tokens.large > 1 ? 1 : baseSize))
    readonly property int xlarge: Math.round(tokens.xlarge * (tokens.xlarge > 1 ? 1 : baseSize))
    readonly property int x2large: Math.round(tokens.x2large * (tokens.x2large > 1 ? 1 : baseSize))
    readonly property int x3large: Math.round(tokens.x3large * (tokens.x3large > 1 ? 1 : baseSize))
    property string debug
}