// LayoutSynthWave.qml - horizon-grid composition with a striped retro sun.
// Ports #scene-synth-wave from /tmp/sddm_preview/preview.html.
//
// The grid is a flat repeating pattern in the mockup too (background-size: 56px 56px,
// no real 3D perspective) so a Canvas redraw reproduces it exactly, just animated by
// shifting a y-offset instead of CSS background-position. Deviation: the mockup's date
// line uses an em dash ("FRIDAY — 10.09"); this project's house style forbids the em
// dash, so it renders as "FRIDAY - 10.09" instead. Addition: the approved mockup's
// bottom-bar for this scene has no power icons, but the brief requires working power
// icons in every composition, so a small PowerRow is added bottom-right - functional
// requirement over pixel-exact mockup fidelity for this one element.

import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: scene

    property string bgSource: ""
    property color colBg: "#0a0930"
    property color colText: "#f3e9ff"
    property color colA1: "#c11f34"
    property color colA2: "#ae2d9a"
    property color colA3: "#511c65"
    property bool reducedMotion: false

    // Without this the password field had focus=true but activeFocus=false: its focus
    // chain was broken above it (Loader -> scene), so on a real greeter the first
    // keystrokes went nowhere and the box showed no active state. Measured, not guessed.
    Component.onCompleted: Qt.callLater(function() { passwordField.forceActiveFocus(); })

    property real horizonY: height * 0.60

    Rectangle { anchors.fill: parent; color: scene.colBg }

    Image {
        anchors.fill: parent
        source: scene.bgSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: scene.bgSource.length > 0
    }
    Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.25 }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.55) }
            GradientStop { position: 0.16; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.08) }
            GradientStop { position: 0.52; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.04) }
            GradientStop { position: 0.76; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.65) }
            GradientStop { position: 1.0; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.92) }
        }
    }

    // ---- retro sun: vertical gradient circle + bottom-half stripes -------------------
    // sunGlow is declared BEFORE sun on purpose: QtQuick paints same-z siblings in
    // declaration order, so this alone puts the glow ring behind the sun circle. The
    // previous version used `z: sun.z - 1`, which actually went negative relative to the
    // WHOLE scene (sun.z defaults to 0), hiding the glow behind the opaque background
    // too, not just behind the sun.
    Rectangle {
        id: sunGlow
        anchors.centerIn: sun
        width: sun.width + 40; height: sun.height + 40
        radius: width / 2
        color: "transparent"
        border.color: scene.colA1
        border.width: 18
        opacity: 0.4
    }
    Item {
        id: sun
        anchors.horizontalCenter: parent.horizontalCenter
        y: scene.height * 0.22
        width: 150; height: 150
        clip: true

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffd166" }
                GradientStop { position: 0.65; color: scene.colA1 }
                GradientStop { position: 1.0; color: scene.colA3 }
            }
        }
        Column {
            y: parent.height * 0.46
            width: parent.width
            spacing: 4
            Repeater {
                model: 8
                Rectangle { width: sun.width; height: 5; color: scene.colBg }
            }
        }

        SequentialAnimation {
            running: !scene.reducedMotion
            loops: Animation.Infinite
            NumberAnimation { target: sunGlow; property: "opacity"; to: 0.7; duration: 2500; easing.type: Easing.InOutSine }
            NumberAnimation { target: sunGlow; property: "opacity"; to: 0.4; duration: 2500; easing.type: Easing.InOutSine }
        }
    }

    // ---- horizon line ------------------------------------------------------------------
    Rectangle {
        id: horizonLine
        anchors.left: parent.left
        anchors.right: parent.right
        y: scene.horizonY
        height: 2
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: scene.colA1 }
            GradientStop { position: 1.0; color: "transparent" }
        }

        SequentialAnimation {
            running: !scene.reducedMotion
            loops: Animation.Infinite
            NumberAnimation { target: horizonLine; property: "opacity"; to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
            NumberAnimation { target: horizonLine; property: "opacity"; to: 0.75; duration: 2000; easing.type: Easing.InOutSine }
        }
    }

    // ---- perspective grid (flat repeating pattern, same as the CSS) ------------------
    Canvas {
        id: grid
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: horizonLine.bottom
        anchors.bottom: parent.bottom
        property real offset: 0

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = Qt.rgba(scene.colA2.r, scene.colA2.g, scene.colA2.b, 0.35);
            ctx.lineWidth = 1;
            var step = 56;
            var y0 = offset % step;
            for (var y = y0; y < height; y += step) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
            }
            for (var x = 0; x < width; x += step) {
                ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke();
            }
        }
        onOffsetChanged: requestPaint()
        Component.onCompleted: requestPaint()

        NumberAnimation {
            target: grid
            property: "offset"
            from: 0; to: 56
            duration: 6000
            loops: Animation.Infinite
            running: !scene.reducedMotion
        }
    }

    LastUser { id: lastUser }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: scene.height * 0.10
        width: 320
        spacing: 0

        Clock {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            textColor: scene.colText
            mutedColor: scene.colA2
            fontFamily: "monospace"
            timeWeight: Font.Bold
            timeSize: 36
            dateSize: 12
            timeFormat: "h:mm AP"
            dateFormat: "dddd - MM.dd"
            dateUppercase: true
            clockSpacing: 4
        }
        Item { width: 1; height: 20 }

        TextField {
            id: usernameField
            width: parent.width
            text: lastUser.currentText
            color: scene.colText
            horizontalAlignment: Text.AlignHCenter
            font.family: "monospace"
            font.pixelSize: 13
            selectByMouse: true
            padding: 10
            background: Rectangle {
                color: Qt.rgba(scene.colA3.r, scene.colA3.g, scene.colA3.b, 0.3)
                border.color: scene.colA2
                border.width: 1
                radius: 2
            }
            KeyNavigation.down: passwordField
        }
        Item { width: 1; height: 12 }

        TextField {
            id: passwordField
            width: parent.width
            echoMode: TextInput.Password
            color: scene.colText
            horizontalAlignment: Text.AlignHCenter
            font.family: "monospace"
            font.pixelSize: 13
            selectByMouse: true
            padding: 10
            background: Rectangle {
                color: Qt.rgba(scene.colA3.r, scene.colA3.g, scene.colA3.b, 0.3)
                border.color: scene.colA2
                border.width: 1
                radius: 2
            }
            focus: true
            Keys.onReturnPressed: loginButton.clicked()
            Keys.onEnterPressed: loginButton.clicked()

            Connections {
                target: sddm
                function onLoginFailed() {
                    passwordField.text = "";
                    passwordField.forceActiveFocus();
                }
            }
        }
        Item { width: 1; height: 4 }

        Button {
            id: loginButton
            width: parent.width
            text: "Jack In"
            font.family: "monospace"
            font.pixelSize: 13
            font.bold: true
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.5
            contentItem: Text {
                text: loginButton.text
                color: scene.colText
                font: loginButton.font
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                color: loginButton.hovered ? Qt.rgba(scene.colA1.r, scene.colA1.g, scene.colA1.b, 0.25) : "transparent"
                border.color: scene.colA1
                border.width: 1
                radius: 2
            }
            onClicked: sddm.login(usernameField.text, passwordField.text, sessionBadge.currentIndex)
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        height: 18

        Text {
            anchors.left: parent.left
            text: "◉ " + lastUser.currentText
            color: scene.colA2
            font.family: "monospace"
            font.pixelSize: 11
            font.letterSpacing: 1
        }
        SessionBadge {
            id: sessionBadge
            anchors.right: parent.right
            textColor: scene.colA2
            popupBg: scene.colA3
            popupTextColor: scene.colText
            fontFamily: "monospace"
            fontSize: 11
        }
    }

    PowerRow {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        iconColor: scene.colA2
        glyphSize: 13
        itemSpacing: 12
    }
}
