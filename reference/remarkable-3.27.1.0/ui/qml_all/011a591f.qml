import QtQuick
import QtQuick.Layouts
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!  Black (primary) or white (secondary) rectangles that relate to panels in Settings\n

There are two variants: Primary (black) and Secondary (white). 
They can have an icon, a title, and/or message and an optional description/addition beneath the line
Message may be followed by progress bar

### Usage example
\code
ArkControls.InfoMessage {
    type: ArkTokens.InfoMessage.secondary
    width: 400
    title: "Title"
    iconSource: "qrc:/ark/icons/placeholder"
    message: "Info message"
    showProgress: true
    progress: 0.5
    description: "Description"
}
\endcode

\todo replace icon's Qt.AlignVCenter with topMargin when available in tokens

See \ref example-InfoMessage.qml for usage examples
*/
Rectangle {
    id: root

    /*!
       InfoMessage type available from ArkTokens. Default is primary

        - ArkTokens.InfoMessage.primary
        - ArkTokens.InfoMessage.secondary
    */
    property var type: ArkTokens.InfoMessage.primary

    /// title text
    property string title

    /// Path to an icon to the left from the title
    required property string iconSource

    /// info message text
    property string message

    /// description text
    property string description

    /// show progressBar
    property alias showProgress: progressBar.visible

    /// ProgressBar value
    property alias progress: progressBar.value

    /*! Mandatory for control to function properly
    */
    width: 0

    /// Switch off antialiasing of all children
    antialiasing: true

    /// info message might handle clicks
    signal clicked()

    /// link in message or description text has been activated
    signal linkActivated(string link)

    // rest is private and should not be touched
    color: root.type.container.fill
    border.color: root.type.container.borderColor ?? "transparent"
    border.width: root.type.container.borderWidth ?? 0

    /*! Do not touch
    */
    implicitHeight: content.implicitHeight + 2 * root.type.container.spacing


    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }

    GridLayout {
        id: content
        width: parent.width - 2 * root.type.container.spacing
        anchors.centerIn: parent
        columns: 2
        columnSpacing: root.type.container.itemSpacing
        rowSpacing: root.type.container.itemSpacing

        Icon {
            Layout.row: 0
            Layout.column: 0
            source: root.iconSource
            style: ArkTokens.Style.variable.isPaper ? root.type.icon.paperTablet : root.type.icon.client
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.topMargin: ArkTokens.Settings.accessibility ? root.type.icon.container.default_a11y.paddingTop : root.type.icon.container.idle.paddingTop
        }

        TextLabel {
            Layout.row: 0
            Layout.column: 1
            text: root.title
            labelStyle: root.type.content.title
            antialiasing: root.antialiasing
            Layout.alignment: Qt.AlignVCenter
            visible: !!root.title
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.row: !!root.title ? 1 : 0
            Layout.column: 1
            Layout.fillWidth: true
            spacing: root.type.content.message.container.itemSpacing

            TextLabel {
                text: root.message
                labelStyle: root.type.content.message.text
                antialiasing: root.antialiasing
                wrapMode: Text.WordWrap
                Layout.preferredWidth: textPreferredWidth()
                Layout.fillWidth: true
                linkColor: color
                onLinkActivated: (link)=> root.linkActivated(link)
            }

            ProgressBar {
                id: progressBar
                type: ArkTokens.ProgressBar.primary_inverted
                width: root.type.content.message.progressBarWidth ? root.type.content.message.progressBarWidth.sizing : 0
                visible: false
                Layout.alignment: Qt.AlignVCenter
            }
            visible: !!root.message
        }

        Rectangle {
            Layout.row: !!root.title ? 2 : 1
            Layout.column: 1
            color: root.type.content.description.divider.fill
            height: root.type.content.description.divider.height
            Layout.fillWidth: true
            visible: !!root.description
        }

        TextLabel {
            Layout.row: !!root.title ? 3 : 2
            Layout.column: 1
            text: root.description
            labelStyle: root.type.content.description.additionalText
            antialiasing: root.antialiasing
            visible: !!root.description
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            linkColor: color
            onLinkActivated: (link) => root.linkActivated(link)
        }
    }


    function textPreferredWidth() {
        return root.width - 2 * root.type.container.spacing - root.type.icon[ArkTokens.Style.variable.tokens].sizing - root.type.container.itemSpacing - (progressBar.visible ? progressBar.width + parent.spacing : 0);
    }
}
/** @}*/
