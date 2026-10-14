import QtQuick
import QtQuick.Controls
import com.remarkable // UpgradeManager
import com.remarkable.devicetelemetry
import xofm.libs.qtgui
import xofm.libs.orientation
import xofm.modules.releasenotes
import xofm.libs.ghostbuster

BaseView {
    id: root

    required property Orientation orientation
    required property ReleaseNotesWindowState windowState
    required property GhostBuster ghostBuster;

    function disableUpdateScreen() {
        // FIXME (SW-20302): Inject Settings, replace Singleton access
        Settings.setValue(Settings.OnboardingUpdateScreen, false);
        root.windowNavigator.close(root.objectName);
        root.windowState.closed();
    }

    contentItem: SplashScreen {
        color: "white" // Values.colorWhite
        imageSource: {
            var image
            if (orientation.isPortraitOrientation) {
                image = "p_releaseupdates";
            }
            else {
                image = "ls_releaseupdates";
            }
            return "qrc:releasenotes/" + image;
        }
        skipReleaseNotes: Action {
            //: Button to skip seeing the release notes. This takes the user to the main UI.
            text: qsTr("Get started")
            onTriggered: {
                SystemTelemetry.releaseNotesRead(false);
                root.disableUpdateScreen();
            }
        }
        readReleaseNotes: Action {
            //: This button takes the user to the release notes
            text: qsTr("Read full release notes")
            enabled: !UpgradeManager.betaProgram.enrolled
            onTriggered: {
                SystemTelemetry.releaseNotesRead(true);
                root.windowNavigator.open("releasenotes/window/releasenotes");
             }
        }
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Home) {
                root.disableUpdateScreen();
            }
        }

        onVisibleChanged: {
            if (!visible) {
                ghostBuster.viewChange(GhostBuster.SplashScreenClosed);
            }
        }
    }
}
