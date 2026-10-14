pragma Singleton

import QtQuick
import com.remarkable

QtObject {
    id: developerEnablers

    // New enablers should be implemented as an own property

    property DeveloperState filesystemExplorer: DeveloperState {
        key: "FilesystemExplorer"
    }
}
