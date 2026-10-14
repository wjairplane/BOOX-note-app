import QtQuick
import QtQuick.Layouts

import com.remarkable // QrCodeProvider
import xofm.libs.qtgui
import xofm.libs.onboarding

import ark.controls as ArkControls

BaseView {
    id: root

    OnboardingStateProp.group: OnboardingManager.Group.Dialogs
    OnboardingStateProp.domain: ""
    OnboardingStateProp.key: "HWS_In_Doc_No_Connect_Onboarding"

    function complete() {
        windowNavigator.close();
    }

    onOpened: {
        if (OnboardingStateProp.completed) {
            root.complete();
        }
    }

    contentItem: OnboardingDialogue {
        initialModel: [
            {
                "title": qsTr("Not subscribed"),
                "body": [
                    { "description": qsTr("To search for keywords in your handwritten notes inside documents you need Connect. Subscribe at remarkable.com/store/connect.") },
                ],
            }
        ]
        customImage: Image {
            source: qrProvider.imageUrl
            fillMode: Image.PreserveAspectFit
            height: 250
            width: height
        }

        onFinished: {
            root.OnboardingStateProp.completed = true;
            root.complete();
        }

        QRCodeProvider {
            id: qrProvider
            text: "https://remarkable.com/store/connect?rm_utm_source=connect_restriction&rm_utm_campaign=hws_in_doc"
        }
    }
}
