import QtQuick

import com.remarkable // QrCodeProvider

import xofm.libs.qtgui
import xofm.libs.onboarding

import ark.controls as ArkControls

BaseView {
    id: root

    contentItem: ArkControls.OnboardingDialog {
        anchors.fill: parent
        primaryButtonText: qsTr("Close")
        closeOption: false // we have one Close button, no need in another one

        contentItem: OnboardingPage {
            title: qsTr("Connect required")
            body: [
                { description: qsTr("To make a duplicate, export, and send workbooks from reMarkable Methods, you need Connect. Manage your subscription at my.remarkable.com.") }
            ]
            customImage: Image {
                source: qrProvider.imageUrl
                fillMode: Image.PreserveAspectFit
                height: 250
                width: height
            }
        }

        onPrimaryClicked: windowNavigator.close();

        QRCodeProvider {
            id: qrProvider
            text: "https://remarkable.com/store/connect?rm_utm_source=connect_restriction&rm_utm_campaign=workbook_action"
        }
    }
}
