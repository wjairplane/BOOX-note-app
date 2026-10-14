import QtQuick
import com.remarkable
import common

/** This component allows a group of ToolTips to cooperate so that at most one is visible at a time */
QtObject {
    id: group

    property Item currentItem
}
