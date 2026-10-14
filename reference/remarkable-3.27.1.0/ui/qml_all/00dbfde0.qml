pragma Singleton

import QtQuick

Item {
    // Adding translated strings here should be used with caution and is not recommended
    // unless the string is used in multiple places and there is no room for ambiguity
    readonly property string notAvailableInRetailString: qsTr("This feature is not available in retail mode.")

    // Non-visible strings that don't need translation
    // Remember! If changed, to change them in their cpp related classes as well
    readonly property string libraryExplorerId: "myfiles"
    readonly property string defaultTemplateName: "Blank" // See DocumentFiles
    readonly property string invalidId: "INVALID_ID"
}
