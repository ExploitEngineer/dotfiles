// LayoutRosePine.qml - organic off-center composition with drifting petals.
// Ports #scene-rose-pine from /tmp/sddm_preview/preview.html.
//
// Petal drift uses plain NumberAnimation loops with a startup PauseAnimation stagger per
// petal (not a literal port of the CSS negative animation-delay values - same scattered,
// already-in-motion look, simpler math). All petals disappear when reducedMotion is set,
// same intent as the mockup's prefers-reduced-motion rule.

import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: scene

    property string bgSource: ""
    property color colBg: "#1a1626"
    property color colText: "#f3edf1"
    property color colA1: "#eb3b85"
    property color colA2: "#d9c8d4"
    property color colA3: "#4a304f"
    property bool reducedMotion: false

    Rectangle { anchors.fill: parent; color: scene.colBg }

    Image {
        anchors.fill: parent
        source: scene.bgSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: scene.bgSource.length > 0
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.72) }
            GradientStop { position: 0.48; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.28) }
            GradientStop { position: 1.0; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.08) }
        }
    }

    Repeater {
        model: [
            { xFrac: 0.18, color: scene.colA1, pause: 0 },
            { xFrac: 0.34, color: scene.colA2, pause: 1600 },
            { xFrac: 0.52, color: scene.colA1, pause: 3200 },
            { xFrac: 0.67, color: scene.colA2, pause: 4800 },
            { xFrac: 0.81, color: scene.colA1, pause: 6400 }
        ]
        delegate: Item {
            id: petal
            visible: !scene.reducedMotion
            x: scene.width * modelData.xFrac
            y: -scene.height * 0.08
            width: 9; height: 12

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: modelData.color
                opacity: 0.55
            }

            SequentialAnimation {
                running: !scene.reducedMotion
                loops: Animation.Infinite
                PauseAnimation { duration: modelData.pause }
                ParallelAnimation {
                    NumberAnimation { target: petal; property: "y"; from: -scene.height * 0.08; to: scene.height * 1.08; duration: 11000 }
                    NumberAnimation { target: petal; property: "rotation"; from: 0; to: 260; duration: 11000 }
                }
            }
        }
    }

    LastUser { id: lastUser }

    Column {
        id: content
        anchors.left: parent.left
        anchors.leftMargin: scene.width * 0.09
        anchors.verticalCenter: parent.verticalCenter
        width: 360
        spacing: 0

        Clock {
            textColor: scene.colText
            mutedColor: scene.colA2
            fontFamily: "serif"
            italic: true
            timeWeight: Font.Medium
            timeSize: 50
            dateSize: 13
            timeFormat: "hh:mm"
            dateFormat: "dddd · d MMMM"
            clockSpacing: 10
        }
        Item { width: 1; height: 26 }

        Text {
            text: "username"
            font.family: "serif"
            font.italic: true
            font.pixelSize: 13
            color: scene.colA2
            opacity: 0.8
        }
        Item { width: 1; height: 7 }

        Item {
            width: parent.width; height: 38
            Rectangle { anchors.fill: parent; color: Qt.rgba(scene.colA3.r, scene.colA3.g, scene.colA3.b, 0.35) }
            Rectangle {
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: 1.5
                color: usernameField.activeFocus ? scene.colA1 : Qt.rgba(scene.colText.r, scene.colText.g, scene.colText.b, 0.3)
            }
            TextField {
                id: usernameField
                anchors.fill: parent
                leftPadding: 4; rightPadding: 4
                text: lastUser.currentText
                color: scene.colText
                font.pixelSize: 14
                selectByMouse: true
                background: Item {}
                KeyNavigation.down: passwordField
            }
        }
        Item { width: 1; height: 18 }

        Text {
            text: "password"
            font.family: "serif"
            font.italic: true
            font.pixelSize: 13
            color: scene.colA2
            opacity: 0.8
        }
        Item { width: 1; height: 7 }

        Item {
            width: parent.width; height: 38
            Rectangle { anchors.fill: parent; color: Qt.rgba(scene.colA3.r, scene.colA3.g, scene.colA3.b, 0.35) }
            Rectangle {
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: 1.5
                color: passwordField.activeFocus ? scene.colA1 : Qt.rgba(scene.colText.r, scene.colText.g, scene.colText.b, 0.3)
            }
            TextField {
                id: passwordField
                anchors.fill: parent
                leftPadding: 4; rightPadding: 4
                echoMode: TextInput.Password
                color: scene.colText
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
        Item { width: 1; height: 20 }

        Button {
            id: loginButton
            text: "Continue"
            font.pixelSize: 13
            padding: 11
            leftPadding: 32; rightPadding: 32
            contentItem: Text {
                text: loginButton.text
                color: loginButton.hovered ? scene.colBg : scene.colText
                font: loginButton.font
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                radius: height / 2
                color: loginButton.hovered ? scene.colA1 : "transparent"
                border.color: scene.colA1
                border.width: 1.5
            }
            onClicked: sddm.login(usernameField.text, passwordField.text, sessionBadge.currentIndex)
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: scene.width * 0.09
        anchors.rightMargin: 40
        anchors.bottomMargin: 30
        height: 20

        SessionBadge {
            id: sessionBadge
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            textColor: scene.colA2
            popupBg: scene.colA3
            popupTextColor: scene.colText
            fontSize: 12
        }
        PowerRow {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconColor: scene.colA2
            glyphSize: 14
            itemSpacing: 16
        }
    }
}
