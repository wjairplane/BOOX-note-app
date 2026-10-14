import QtQuick

import xofm.libs.qtgui
import xofm.libs.onboarding

import com.remarkable // QRCodeProvider

BaseView {
    id: root

    onOpened: (config) => {
        if(typeof config.link !== "string") {
            console.error("ShareByUrl QR code dialog opened with invalid config: " + JSON.stringify(config));
            return;
        }
        const url = new URL(config.link);
        url.searchParams.set("rm_utm_source", "shared_webpage");
        url.searchParams.set("rm_utm_campaign", "create_open_link");
        url.searchParams.set("rm_utm_medium", "qr_code");
        qrProvider.text = url.toString();
    }

    QRCodeProvider {
        id: qrProvider
    }

    contentItem: OnboardingDialogue {
        initialModel: [{
            //: title of the onboarding dialogue
            title: qsTr("Sharing your work"),
            body: [{ "description":
                qsTr("Scan the QR-code to access your notes online. You can log in to edit the converted text, change the expiration date, or delete the page. Share your work with others by copying the link.") }],
        }]
        customImage: Image {
            // QRCodeProvider is a QtObject so it's not found by squish,
            // this is a helper property that allows Squish to find the url link
            readonly property string url: qrProvider.text
            objectName: "share-by-url-qr-code-image"

            source: qrProvider.imageUrl
            fillMode: Image.PreserveAspectFit
            height: 250
            width: height
        }

        rightButtonText: qsTr("Close")

        onQuit: root.windowNavigator.close();
        onFinished: root.windowNavigator.close();
    }
}
