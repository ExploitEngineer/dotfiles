// Layout1Bit.qml - hard-edged terminal/BIOS composition.
// Ports #scene-1-bit from /tmp/sddm_preview/preview.html.
//
// No GraphicalEffects/shader usage anywhere in this file by design: this machine has a
// documented history of GPU instability (Xid 79 off-bus crashes), and a login screen is
// exactly the wrong place to add shader-compilation risk for a cosmetic grayscale filter.
// The wallpaper strip is muted toward monochrome with plain color overlays instead of a
// true desaturation shader - close enough to the mockup's intent, zero extra GPU surface.

import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: scene

    property string bgSource: ""
    property color colBg: "#0a0a0a"
    property color colText: "#e8e8e8"
    property color colA1: "#3a3a3a"
    property color colA2: "#8a8a8a"
    property color colA3: "#636363"
    property bool reducedMotion: false

    // Without this the password field had focus=true but activeFocus=false: its focus
    // chain was broken above it (Loader -> scene), so on a real greeter the first
    // keystrokes went nowhere and the box showed no active state. Measured, not guessed.
    Component.onCompleted: Qt.callLater(function() { passwordField.forceActiveFocus(); })

    property real wpWidth: width * 0.42

    Rectangle {
        anchors.fill: parent
        color: scene.colBg
    }

    // ---- grayscale-leaning wallpaper strip, right 42% --------------------------------
    Item {
        id: wpStrip
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: scene.wpWidth

        Image {
            anchors.fill: parent
            source: scene.bgSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: scene.bgSource.length > 0
        }

        // Desaturate-ish wash instead of a real shader: mid-gray then a dark tint.
        Rectangle { anchors.fill: parent; color: "#808080"; opacity: 0.35 }
        Rectangle { anchors.fill: parent; color: scene.colBg; opacity: 0.2 }

        Canvas {
            id: wpScan
            anchors.fill: parent
            Component.onCompleted: requestPaint()
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "rgba(0,0,0,0.25)";
                ctx.lineWidth = 1;
                for (var y = 0; y < height; y += 3) {
                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: scene.colA1
        }
    }

    // ---- faint full-screen scanline texture -------------------------------------------
    Canvas {
        id: fullScan
        anchors.fill: parent
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = "rgba(0,0,0,0.05)";
            ctx.lineWidth = 1;
            for (var y = 0; y < height; y += 3) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
        }
    }

    // ---- hairline frame with corner brackets -------------------------------------------
    Rectangle {
        id: frame
        anchors.fill: parent
        anchors.margins: 48
        color: "transparent"
        border.color: scene.colA1
        border.width: 1

        Text {
            x: 17
            y: 20
            text: "sddm - tty1 - arch / hyprland"
            color: scene.colA2
            font.family: "monospace"
            font.pixelSize: 10
            font.capitalization: Font.AllUppercase
        }

        // top-left bracket
        Rectangle { x: -1; y: -1; width: 14; height: 2; color: scene.colText }
        Rectangle { x: -1; y: -1; width: 2; height: 14; color: scene.colText }
        // bottom-right bracket
        Rectangle { x: parent.width - 13; y: parent.height - 1; width: 14; height: 2; color: scene.colText }
        Rectangle { x: parent.width - 1; y: parent.height - 13; width: 2; height: 14; color: scene.colText }
    }

    // ---- content -------------------------------------------------------------------
    LastUser { id: lastUser }

    Column {
        id: content
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 64
        width: Math.min(320, scene.width * 0.58 - 128)

        Clock {
            horizontal: true
            textColor: scene.colText
            mutedColor: scene.colA2
            fontFamily: "monospace"
            timeSize: 40
            dateSize: 12
            timeFormat: "hh:mm"
            dateFormat: "ddd / MMM dd"
            dateUppercase: true
        }
        Item { width: 1; height: 18 }
        Rectangle { width: parent.width; height: 1; color: scene.colA1 }
        Item { width: 1; height: 34 }

        Text {
            text: "USER"
            color: scene.colA2
            font.family: "monospace"
            font.pixelSize: 11
            font.letterSpacing: 1
        }
        Item { width: 1; height: 6 }

        TextField {
            id: usernameField
            width: parent.width
            text: lastUser.currentText
            color: scene.colText
            font.family: "monospace"
            font.pixelSize: 14
            selectByMouse: true
            padding: 11
            background: Rectangle {
                color: "transparent"
                border.color: usernameField.activeFocus ? scene.colText : scene.colA1
                border.width: 1
            }
            KeyNavigation.down: passwordField
        }
        Item { width: 1; height: 20 }

        Text {
            // Brightens when the field below has focus, so it is obvious where typing goes.
            text: "PASS"
            color: passwordField.activeFocus ? scene.colText : scene.colA2
            font.family: "monospace"
            font.pixelSize: 11
            font.letterSpacing: 1
        }
        Item { width: 1; height: 6 }

        TextField {
            id: passwordField
            width: parent.width
            echoMode: TextInput.Password
            color: scene.colText
            font.family: "monospace"
            font.pixelSize: 14
            selectByMouse: true
            padding: 11
            background: Rectangle {
                color: "transparent"
                border.color: passwordField.activeFocus ? scene.colText : scene.colA1
                border.width: 1
            }
            // The terminal-style block cursor is the field's own caret, so it sits where
            // typing happens. It used to be a free-floating rectangle beside the "PASS"
            // label that was not connected to the field at all and read as the input point.
            // TextInput shows/hides and blinks this itself, only while the field has focus.
            cursorDelegate: Rectangle {
                width: 10
                height: passwordField.font.pixelSize + 6
                color: scene.colText
            }
            focus: true
            Keys.onReturnPressed: loginButton.clicked()
            Keys.onEnterPressed: loginButton.clicked()
            KeyNavigation.down: loginButton

            Connections {
                target: sddm
                function onLoginFailed() {
                    passwordField.text = "";
                    passwordField.forceActiveFocus();
                }
            }
        }
        Item { width: 1; height: 6 }

        Button {
            id: loginButton
            width: parent.width
            text: "[ authenticate ]"
            font.family: "monospace"
            font.pixelSize: 13
            font.bold: true
            // font.capitalization lives here, not inside contentItem below: QML does not
            // allow assigning the whole "font" group (contentItem's `font: loginButton.font`)
            // and a dotted "font.xxx" sub-property on the same object at once.
            font.capitalization: Font.AllUppercase
            contentItem: Text {
                text: loginButton.text
                color: loginButton.hovered ? scene.colText : scene.colBg
                font: loginButton.font
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                color: loginButton.hovered ? "transparent" : scene.colText
                border.color: scene.colText
                border.width: 1
            }
            onClicked: sddm.login(usernameField.text, passwordField.text, sessionBadge.currentIndex)
        }
    }

    // ---- bottom meta row: left label, right session + power -------------------------
    Item {
        id: metaRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: scene.wpWidth + 64
        anchors.bottom: parent.bottom
        anchors.leftMargin: 64
        anchors.bottomMargin: 64
        height: 24

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: -14
            height: 1
            color: scene.colA1
        }

        SessionBadge {
            id: sessionBadge
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            textColor: scene.colA2
            popupBg: scene.colBg
            popupTextColor: scene.colText
            fontFamily: "monospace"
            fontSize: 11
        }

        PowerRow {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconColor: scene.colA2
            glyphSize: 13
            itemSpacing: 14
        }
    }
}
