// SessionBadge.qml - shared session indicator/switcher.
//
// None of the five approved mockup scenes drew a separate session-picker control; each
// one already shows a static "Hyprland" label in its bottom bar. This replaces that
// static text with a live control bound to the real sessionModel, using the same
// flattened-ComboBox trick SDDM's own Candy theme uses (transparent background, no
// indicator, a plain Text contentItem) so it occupies the exact same visual space the
// approved design already reserved for it.

import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: sessionBox

    property color textColor: "#ffffff"
    property color popupBg: "#1a1a1a"
    property color popupTextColor: "#ffffff"
    property int fontSize: 12
    property string fontFamily: "sans-serif"

    model: sessionModel
    textRole: "name"
    currentIndex: sessionModel.lastIndex

    implicitWidth: contentItem.implicitWidth
    implicitHeight: contentItem.implicitHeight

    indicator: Item { implicitWidth: 0; implicitHeight: 0 }
    background: Rectangle { color: "transparent" }

    contentItem: Text {
        text: sessionBox.currentText
        color: sessionBox.textColor
        font.pixelSize: sessionBox.fontSize
        font.family: sessionBox.fontFamily
        verticalAlignment: Text.AlignVCenter
    }

    delegate: ItemDelegate {
        width: sessionBox.width
        contentItem: Text {
            text: model.name
            color: sessionBox.popupTextColor
            font.pixelSize: sessionBox.fontSize
        }
        background: Rectangle {
            color: highlighted ? Qt.lighter(sessionBox.popupBg, 1.3) : sessionBox.popupBg
        }
    }

    popup: Popup {
        implicitWidth: Math.max(140, sessionBox.width)
        contentItem: ListView {
            implicitHeight: contentHeight
            model: sessionBox.popup.visible ? sessionBox.delegateModel : null
            currentIndex: sessionBox.highlightedIndex
        }
        background: Rectangle { color: sessionBox.popupBg }
    }
}
