import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import ark.tokens as ArkTokens

/** \addtogroup controls
 *  @{
 */
/*!  A container with illustration, title and description. 
Primary card can also have a button or a footnote

\image html paperTablet-Card.qml.png paperTablet
\image html paperTablet-CardForGestures.qml.png paperTablet

See \ref example-Card.qml and example-CardForGestures.qml for usage examples
*/

T.Pane {
    id: root
    /*!
        Card type from ArkTokens. Default is primary

        - ArkTokens.Card.primary is a card with a frame and is used for guides
        - ArkTokens.Card.secondary is a smaller frameless card and is used for gestures
    */
    property ArkTokens.Card.Type type: ArkTokens.Card.primary

    /// Switch off antialiasing
    antialiasing: true
    /// Optional title
    property string title
    /// Optional description
    property string description
    /// Optional button text.
    property string buttonText
    /// Path to optional illustration source
    property string illustrationSource
    /// Optional footnote. Either button or footnote can be presence in the card.
    property string footnote
    /// replace illustration with custom image
    property Component customImage: Icon {
        source: illustrationSource
    }

     /*! Position of text/button in relation to the illustration
        - Horizontal - text is on the right (primary type) or left (secondary type) side of the illustration
        - Vertical - text is below the illustration
    */
    enum Design {
        Horizontal,
        Vertical
    }
    property int design: Card.Design.Horizontal

    signal clicked()

    // rest is private and should not be changed
    // secondary card has transparent background
    property bool isPrimary: root.type.container.fill == ArkTokens.Card.primary.container.fill;
    
    leftPadding: root.type.container.horizontalPadding ?? 0
    rightPadding: root.type.container.horizontalPadding ?? 0
    topPadding: root.type.container.verticalPadding ?? 0
    bottomPadding: root.type.container.verticalPadding ?? 0

    contentItem: GridLayout {
        columnSpacing: root.type.container.itemSpacing ?? 0
        rowSpacing: root.type.container.itemSpacing ?? 0
        columns: {
            switch(design) {
                case(Card.Design.Horizontal): return 2;
                case(Card.Design.Vertical): return 1; 
            }
            return 0;
        }
        layoutDirection: (root.isPrimary && root.design ===  Card.Design.Horizontal) ? Qt.RightToLeft : Qt.LeftToRight

        Loader {
            sourceComponent: customImage
            Layout.alignment: {
                if (root.design === Card.Design.Horizontal) {
                    return root.isPrimary ? (Qt.AlignLeft | Qt.AlignVCenter) : (Qt.AlignRight | Qt.AlignVCenter);
                } 
                return Qt.AlignTop | Qt.AlignLeft;
            }
        }
          
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            TextLabel {
                text: title
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                labelStyle: root.type.content.title
                antialiasing: root.antialiasing
            }
            TextLabel {
                text: description
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                labelStyle: root.type.content.description
                antialiasing: root.antialiasing
            }
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: !!buttonText || !!footnote ? root.type.container.itemSpacing : 0
            }
            Button {
                type: ArkTokens.Button.secondary
                text: root.buttonText
                visible: !!text
                onClicked: root.clicked()
            }
            Label {
                type: Label.Type.LargeSubtle
                text: root.footnote
                wrapMode: Text.Wrap
                visible: !!text
                Layout.fillWidth: true
            }
        }
    }

    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    implicitWidth: implicitContentWidth + leftPadding + rightPadding

    background: Rectangle {
        color: root.type.container.fill ?? "transparent"
        radius: root.type.container.borderRadius ?? 0
        border.width: root.type.container.borderWidth ?? 0
        border.color: root.type.container.borderColor ?? "transparent"
    }
}
/** @}*/
