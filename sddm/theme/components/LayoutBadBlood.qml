// LayoutBadBlood.qml - centered radial composition with angular ("blade") accents.
// Ports #scene-bad-blood from /tmp/sddm_preview/preview.html.
//
// CSS clip-path polygons become QtQuick.Shapes ShapePath polygons here (an inline
// component, Qt 6.5+, so the same slanted-panel shape is only written once). No
// GraphicalEffects/blur/glow shaders - see Layout1Bit.qml's header for why; the glow is
// approximated with plain stacked, semi-transparent circles instead.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 2.15

Item {
    id: scene

    property string bgSource: ""
    property color colBg: "#0d0607"
    property color colText: "#f2eceb"
    property color colA1: "#c12920"
    property color colA2: "#c7b9b7"
    property color colA3: "#7f1a15"
    property bool reducedMotion: false

    component AngularPanel: Shape {
        id: panel
        property color fillColor: "transparent"
        property color strokeColor: "transparent"
        property real skew: 10
        antialiasing: true
        ShapePath {
            // QML color values never compare equal to a string literal via === or == (both
            // are always false, regardless of the actual color) - Qt.colorEqual is the real
            // way to compare a `color` property against a color-literal string.
            strokeWidth: Qt.colorEqual(panel.strokeColor, "transparent") ? 0 : 1
            strokeColor: panel.strokeColor
            fillColor: panel.fillColor
            startX: panel.skew; startY: 0
            PathLine { x: panel.width; y: 0 }
            PathLine { x: panel.width - panel.skew; y: panel.height }
            PathLine { x: 0; y: panel.height }
            PathLine { x: panel.skew; y: 0 }
        }
    }

    Rectangle { anchors.fill: parent; color: scene.colBg }

    Image {
        id: bgImage
        anchors.fill: parent
        source: scene.bgSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: scene.bgSource.length > 0
    }
    Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.45 }

    // vignette: four edge-anchored gradients standing in for a radial gradient (plain
    // QtQuick has no RadialGradient without an extra module; this reads the same way).
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.0) }
            GradientStop { position: 0.75; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.35) }
            GradientStop { position: 1.0; color: scene.colBg }
        }
    }

    // pulsing central glow, approximated with concentric low-opacity circles
    Item {
        id: glow
        anchors.centerIn: parent
        width: 480; height: 480

        Repeater {
            model: 3
            Rectangle {
                anchors.centerIn: parent
                width: glow.width - index * 140
                height: width
                radius: width / 2
                color: scene.colA1
                opacity: 0.18 - index * 0.04
            }
        }

        SequentialAnimation {
            running: !scene.reducedMotion
            loops: Animation.Infinite
            NumberAnimation { target: glow; property: "scale"; to: 1.08; duration: 2250; easing.type: Easing.InOutSine }
            NumberAnimation { target: glow; property: "scale"; to: 1.0; duration: 2250; easing.type: Easing.InOutSine }
        }
    }

    LastUser { id: lastUser }

    Column {
        anchors.centerIn: parent
        spacing: 0

        AngularPanel {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 72; height: 3
            skew: 9
            fillColor: scene.colA1
        }
        Item { width: 1; height: 15 }

        Clock {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            textColor: scene.colText
            mutedColor: scene.colA2
            fontFamily: "sans-serif"
            timeWeight: Font.Bold
            timeSize: 50
            dateSize: 13
            timeFormat: "hh:mm"
            dateFormat: "dddd, MMMM d"
        }
        Item { width: 1; height: 20 }

        Item {
            width: 280; height: 46
            anchors.horizontalCenter: parent.horizontalCenter
            AngularPanel {
                anchors.fill: parent
                skew: 10
                fillColor: Qt.rgba(scene.colText.r, scene.colText.g, scene.colText.b, 0.08)
                strokeColor: usernameField.activeFocus ? scene.colA1 : Qt.rgba(scene.colText.r, scene.colText.g, scene.colText.b, 0.25)
            }
            TextField {
                id: usernameField
                anchors.fill: parent
                text: lastUser.currentText
                color: scene.colText
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                selectByMouse: true
                background: Item {}
                KeyNavigation.down: passwordField
            }
        }
        Item { width: 1; height: 12 }

        Item {
            width: 280; height: 46
            anchors.horizontalCenter: parent.horizontalCenter
            AngularPanel {
                anchors.fill: parent
                skew: 10
                fillColor: passwordField.activeFocus ? Qt.rgba(scene.colA1.r, scene.colA1.g, scene.colA1.b, 0.15) : Qt.rgba(scene.colText.r, scene.colText.g, scene.colText.b, 0.08)
                strokeColor: passwordField.activeFocus ? scene.colA1 : Qt.rgba(scene.colText.r, scene.colText.g, scene.colText.b, 0.25)
            }
            TextField {
                id: passwordField
                anchors.fill: parent
                echoMode: TextInput.Password
                color: scene.colText
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                selectByMouse: true
                background: Item {}
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
        }
        Item { width: 1; height: 18 }

        Item {
            id: loginButton
            width: 280; height: 46
            anchors.horizontalCenter: parent.horizontalCenter

            signal clicked()
            onClicked: sddm.login(usernameField.text, passwordField.text, sessionBadge.currentIndex)

            AngularPanel {
                id: loginPanel
                anchors.fill: parent
                skew: 14
                fillColor: scene.colA1
            }
            Text {
                anchors.centerIn: parent
                text: "Enter"
                color: scene.colText
                font.pixelSize: 13
                font.bold: true
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: loginButton.clicked()
                onEntered: loginPanel.opacity = 0.85
                onExited: loginPanel.opacity = 1.0
                hoverEnabled: true
            }
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        spacing: 22

        SessionBadge {
            id: sessionBadge
            textColor: scene.colA2
            popupBg: scene.colBg
            popupTextColor: scene.colText
            fontSize: 12
        }
        PowerRow {
            iconColor: scene.colA2
            glyphSize: 14
            itemSpacing: 22
        }
    }
}
