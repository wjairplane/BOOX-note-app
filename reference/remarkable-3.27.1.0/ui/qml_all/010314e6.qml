import xofm.libs.qtgui
import xofm.libs.controls

import device.ui.controls // EmptyViewItem
import common // Values

import ark.controls as ArkControls
import ark.tokens as ArkTokens

BaseView {
    id: root

    contentItem: InputBlocker {
        ArkControls.NavigationBar {
            id: integrationsNavigationBar
            type: ArkTokens.NavigationBar.secondary
            anchors.top: parent.top
            ArkControls.NavigationBar.Button {
                id: back
                text: qsTr("Back")
                textPosition: ArkControls.Button.TextPosition.Right
                iconSource: "qrc:/ark/icons/chevron_left"
                onClicked: root.windowNavigator.close()
            }
        }

        ArkControls.Title {
            id: integrationsHeader
            text: qsTr("Integrations")
            type: ArkControls.Title.Large
            anchors {
                left: parent.left
                leftMargin: Values.viewHorizontalMargin + 10
                top: integrationsNavigationBar.bottom
                topMargin: Values.designGridVerticalSpacing
                right: parent.right
            }
        }

        EmptyViewItem {
            id: integrationsEmptyViewItem
            emptyViewKey: "noIntegrations"
            anchors {
                left: parent.left
                top: integrationsHeader.bottom
                right: parent.right
                bottom: parent.bottom
            }
            topPadding: parent.height * Values.emptyViewTopMarginRatio
        }
    }
}
