import QtQuick
import QtQuick.Controls

import com.remarkable // QRCodeProvider

import ark.controls as ArkControls

Control {
    id: root

    required property string title
    required property string description
    required property int design

    property string imageSource: ""
    property string buttonText: ""
    property var buttonAction: () => {}
    property string url: ""

    contentItem: Loader {
        id: cardLoader
        width: parent.width

        sourceComponent: root.url === "" ? cardIllustration : cardQr
    }

    Component {
        id: cardQr

        ArkControls.Card {
            title: root.title
            description: root.description
            design: root.design
            customImage:  Rectangle {
                readonly property int imageFrameSize: 192
                readonly property int qrCodeSide: 144

                height: imageFrameSize
                width: imageFrameSize

                Image {
                    height: qrCodeSide
                    width: qrCodeSide
                    source: qrProvider.imageUrl
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }
            }

            footnote: {
                // trim scheme and query for the pretty url
                const urlObj = new URL(root.url);
                return urlObj.hostname + urlObj.pathname;
            }

            QRCodeProvider {
                id: qrProvider
                text: root.url
            }
        }
    }

    Component {
        id: cardIllustration

        ArkControls.Card {
            title: root.title
            description: root.description
            design: root.design
            illustrationSource: root.imageSource
            buttonText: root.buttonText

            onClicked: root.buttonAction()
        }
    }
}
