pragma Singleton
import QtQuick

QtObject {
    /*!
        Formats sizeInBytes to its correct unit, beeing either Bytes, KB, MB or GB.

        Returns a string on the following format: "<formattedSize> <unit>"
    */
    function formatSizeInBytes(sizeInBytes)
    {
        const formatBytes = (toByteSize, suffix) => {
            return qsTr("%1 %2").arg(Math.round(sizeInBytes / toByteSize)).arg(suffix);
        }

        const kiloBytes = 1024;
        const megaBytes = Math.pow(kiloBytes, 2);
        const gigaBytes = Math.pow(kiloBytes, 3);

        if (sizeInBytes < kiloBytes) {
            return formatBytes(1, qsTr("Bytes"));
        } else if (sizeInBytes < megaBytes) {
            return formatBytes(kiloBytes, qsTr("KB"));
        } else if (sizeInBytes < gigaBytes) {
            return formatBytes(megaBytes, qsTr("MB"));
        } else {
            return formatBytes(gigaBytes, qsTr("GB"));
        }
    }
}
