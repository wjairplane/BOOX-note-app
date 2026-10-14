import QtQuick

import com.remarkable // QRCodeProvider

import xofm.libs.qtgui
import xofm.libs.onboarding

BaseView {
    id: root

    QRCodeProvider {
        id: qrProvider
        text: "https://remarkable.com/shop/connect?rm_utm_source=connect_restriction&rm_utm_campaign=integration_convert_to_notebook"
    }

    contentItem: OnboardingDialogue {
        initialModel: [{
            "title": qsTr("Get access with Connect"),
            "body": [
               { "description": qsTr("Import Word files and Google Docs as free-form, editable notebooks with Convert to Notebook. Available with a Connect subscription.") },
               { "description": qsTr("Learn more and get started at remarkable.com/shop/connect") },
            ]
        }]
        customImage: Image {
            // QRCodeProvider is a QtObject so it's not found by squish,
            // this is a helper property that allows Squish to find the url link
            readonly property string url: qrProvider.text

            objectName: "convert-to-notebook-qr-code-image"
            source: qrProvider.imageUrl
            fillMode: Image.PreserveAspectFit
            height: 250
            width: height
        }
        rightButtonText: qsTr("Close")

        onFinished: {
            root.OnboardingStateProp.completed = true;
            root.windowNavigator.close();
        }
    }
}
