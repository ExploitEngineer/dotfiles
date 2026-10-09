// PowerRow.qml - shared suspend/hibernate/reboot/shutdown row.
//
// Wired directly to the real sddm context property. Each glyph is gated on the matching
// sddm.canX property, so a button simply does not appear - no layout gap, Row skips
// invisible children - when the action is not available (e.g. no hibernate without swap).

import QtQuick 2.15

Row {
    id: powerRow

    property color iconColor: "#ffffff"
    property int glyphSize: 16
    property real itemSpacing: 22

    spacing: itemSpacing

    Repeater {
        model: [
            { glyph: "⏾", action: "suspend", available: sddm.canSuspend },
            { glyph: "⏼", action: "hibernate", available: sddm.canHibernate },
            { glyph: "⟲", action: "reboot", available: sddm.canReboot },
            { glyph: "⏻", action: "shutdown", available: sddm.canPowerOff }
        ]

        delegate: Text {
            visible: modelData.available
            text: modelData.glyph
            color: powerRow.iconColor
            font.pixelSize: powerRow.glyphSize

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.action === "suspend") sddm.suspend();
                    else if (modelData.action === "hibernate") sddm.hibernate();
                    else if (modelData.action === "reboot") sddm.reboot();
                    else if (modelData.action === "shutdown") sddm.powerOff();
                }
            }
        }
    }
}
