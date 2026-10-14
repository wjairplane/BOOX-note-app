import QtQuick
import com.remarkable
import common

QtObject {
    id: squishUtils

    // Squish cannot get singletons from QML
    // So we create a helper method to get the singletons we need
    function singletonMapper(singletonName) {
        switch (singletonName) {
            case "DeviceInfo":
                return DeviceInfo
            case "Settings":
                return Settings
            case "Library":
                return Library
            // More to be added

            default:
                return undefined;
        }
    }

}
