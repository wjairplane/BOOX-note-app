pragma Singleton

import QtQuick
import com.remarkable

QtObject {
    id: experimental

    // New enablers should be implemented as an own property

    property ExperimentalState gestures: ExperimentalState {
        group: "Experimental"
        key: "Gestures"
    }
    property ExperimentalState overrideScreenCast: ExperimentalState {
        group: "Experimental"
        key: "OverrideScreenCast"
    }
    property ExperimentalState antialiasing: ExperimentalState {
        group: "Experimental"
        key: "Antialiasing"
    }
    property ExperimentalState pdfPrototype: ExperimentalState {
        group: "Experimental"
        key: "PdfPrototype"
    }
    property ExperimentalState orientation: ExperimentalState {
        group: "Experimental"
        key: "Orientation"
    }
    property ExperimentalState latestSchemaVersion: ExperimentalState {
        group: "Experimental"
        key: "LatestSchemaVersion"
        defaultState: false
    }
    property ExperimentalState writingSettingsMenu: ExperimentalState {
        group: "Experimental"
        key: "WritingSettingsMenu"
    }
    property ExperimentalState oAuthPreview: ExperimentalState {
        group: "Experimental"
        key: "OAuthPreview"
    }
    property ExperimentalState snapToShapes: ExperimentalState {
        group: "Experimental"
        key: "SnapToShapes"
        defaultState: true
    }
    property ExperimentalState delayOrientationChange: ExperimentalState {
        group: "Experimental"
        key: "DelayOrientationChange"
    }
    property ExperimentalState smoothScroll: ExperimentalState {
        group: "Experimental"
        key: "smoothScroll"
        defaultState: false
    }
    property ExperimentalState relevanceSearch: ExperimentalState {
        group: "Experimental"
        key: "RelevanceSearch"
        defaultState: true
    }
    property ExperimentalState annotatePdfs: ExperimentalState {
        group: "Experimental"
        key: "AnnotatePdfs"
        defaultState: false
    }
    property ExperimentalState useCurlHttpBackend: ExperimentalState {
        group: "Experimental"
        key: "UseCurlHttpBackend"
        defaultState: UpgradeManager.isNightlyChannel
    }
    property ExperimentalState glyphSelection: ExperimentalState {
        group: "Experimental"
        key: "GlyphSelection"
        defaultState: UpgradeManager.isNightlyChannel || Values.desktopSimulator
    }
    property ExperimentalState autoReflowTextColumns: ExperimentalState {
        group: "Experimental"
        key: "autoReflowTextColumns"
        defaultState: false
    }
    property ExperimentalState storeCalendarNotesInCurrent: ExperimentalState {
        group: "Experimental"
        key: "storeCalendarNotesInCurrent"
        defaultState: false
    }
    property ExperimentalState networkManagerWifi: ExperimentalState {
        group: "Experimental"
        key: "networkManagerWifi"
        defaultState: false
    }
}
