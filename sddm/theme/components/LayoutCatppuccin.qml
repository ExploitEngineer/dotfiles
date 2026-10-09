// LayoutCatppuccin.qml - warm bottom-sheet composition that slides up on load.
// Ports #scene-catppuccin-mocha from /tmp/sddm_preview/preview.html.
//
// Uses Qt 6.7+'s per-corner Rectangle radius (topLeftRadius/topRightRadius) instead of a
// masking-rectangle trick, since this machine's Qt runtime (6.11.2) supports it directly -
// confirmed against the installed qt6-declarative package before using it; if qmllint on
// an older runtime ever complains, fall back to a square mask Rectangle over a fully
// rounded one. No backdrop blur (the mockup's backdrop-filter: blur) - that needs a
// ShaderEffectSource/GraphicalEffects pass this project deliberately avoids; a slightly
// more opaque flat fill stands in for it.

import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: scene

    property string bgSource: ""
    property color colBg: "#0f1a2a"
    property color colText: "#f2e9e4"
    property color colA1: "#d1768b"
    property color colA2: "#c9b8c3"
    property color colA3: "#1a1415"
    property bool reducedMotion: false

    Rectangle { anchors.fill: parent; color: scene.colBg }

    Image {
        anchors.fill: parent
        source: scene.bgSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: scene.bgSource.length > 0
    }
    Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.28 }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.62; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.92) }
        }
    }

    LastUser { id: lastUser }

    Rectangle {
        id: sheet
        // Anchored to the bottom (its correct resting position) rather than animating an
        // absolute y computed from "scene.height - sheet.height": sheet.height depends on
        // sheetContent.implicitHeight, which is not guaranteed to have settled to its
        // final value yet when Component.onCompleted first fires, so that absolute target
        // could be snapshotted wrong and leave the sheet's bottom off-screen. Anchoring
        // means the resting position is always correct regardless of that timing; only
        // the slide's *starting* offset (slideOffset, below) depends on the same
        // not-yet-settled height, and getting that slightly wrong just makes the slide
        // start a little short/long, never ends up wrong.
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: Math.min(420, scene.width - 32)
        height: sheetContent.implicitHeight + 70
        color: Qt.rgba(scene.colA3.r, scene.colA3.g, scene.colA3.b, 0.72)
        border.color: Qt.rgba(scene.colA1.r, scene.colA1.g, scene.colA1.b, 0.25)
        border.width: 1
        radius: 0
        topLeftRadius: 28
        topRightRadius: 28

        property real slideOffset: height
        transform: Translate { y: sheet.slideOffset }
        Behavior on slideOffset {
            enabled: !scene.reducedMotion
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }
        Component.onCompleted: sheet.slideOffset = 0

        Column {
            id: sheetContent
            anchors.horizontalCenter: parent.horizontalCenter
            y: 34
            width: parent.width - 80
            spacing: 0

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 36; height: 4; radius: 4
                color: Qt.rgba(scene.colText.r, scene.colText.g, scene.colText.b, 0.25)
            }
            Item { width: 1; height: 28 }

            Clock {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                textColor: scene.colText
                mutedColor: scene.colA2
                timeWeight: Font.DemiBold
                timeSize: 32
                dateSize: 13
                timeFormat: "hh:mm"
                dateFormat: "dddd, MMMM d"
                clockSpacing: 4
            }
            Item { width: 1; height: 18 }

            TextField {
                id: usernameField
                width: parent.width
                text: lastUser.currentText
                color: scene.colText
                font.pixelSize: 14
                selectByMouse: true
                padding: 11
                background: Rectangle {
                    color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.4)
                    radius: 13
                    border.color: usernameField.activeFocus ? scene.colA1 : "transparent"
                    border.width: 1
                }
                KeyNavigation.down: passwordField
            }
            Item { width: 1; height: 10 }

            TextField {
                id: passwordField
                width: parent.width
                echoMode: TextInput.Password
                color: scene.colText
                font.pixelSize: 14
                selectByMouse: true
                padding: 11
                background: Rectangle {
                    color: Qt.rgba(scene.colBg.r, scene.colBg.g, scene.colBg.b, 0.4)
                    radius: 13
                    border.color: passwordField.activeFocus ? scene.colA1 : "transparent"
                    border.width: 1
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
                text: "Welcome back"
                font.pixelSize: 14
                font.bold: true
                contentItem: Text {
                    text: loginButton.text
                    color: scene.colA3
                    font: loginButton.font
                    horizontalAlignment: Text.AlignHCenter
                }
                background: Rectangle {
                    color: loginButton.hovered ? Qt.lighter(scene.colA1, 1.08) : scene.colA1
                    radius: 13
                }
                onClicked: sddm.login(usernameField.text, passwordField.text, sessionBadge.currentIndex)
            }
            Item { width: 1; height: 20 }

            Item {
                width: parent.width
                height: 18

                SessionBadge {
                    id: sessionBadge
                    anchors.left: parent.left
                    textColor: scene.colA2
                    popupBg: scene.colA3
                    popupTextColor: scene.colText
                    fontSize: 12
                }
                PowerRow {
                    anchors.right: parent.right
                    iconColor: scene.colA2
                    glyphSize: 13
                    itemSpacing: 14
                }
            }
        }
    }
}
