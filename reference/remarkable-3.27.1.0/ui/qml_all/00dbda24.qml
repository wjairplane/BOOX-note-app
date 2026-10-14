pragma Singleton
import QtQuick

QtObject {
    /*
        Args:
        - SceneController sceneController
        - TextFormatting.TextStyle style

        Returns true if a selection or cursor contains the given style.
    */
    function checkTextStyle(sceneController, style) {
        if (!sceneController) { return false; }

        if (sceneController.hasTextSelection) {
            return sceneController.textSelectionStyles & style;
        }
        return sceneController.textStyles & style;
    }

    function isFormattingButtonSelected(buttonStyleType, currentSelectedStyle) {
        // Display `selected` for indentable types regardless of indent level
        // For list items (checkbox, bulletpoint, numbered list): matches any variant
        // For text styles (title, heading, paragraph): exact match only
        if (!currentSelectedStyle) {
            return false; // No document selected
        }
        return currentSelectedStyle.matchesButtonStyle(buttonStyleType);
    }
}
