// Clock.qml - shared live clock used by every Layout*.qml composition.
//
// Most scenes stack time-over-date (Column); 1-Bit puts them side by side on one
// baseline (Row) - set `horizontal: true` for that case. Each scene supplies its own
// fonts/sizes/colors/format strings so the result matches its mockup, while the actual
// ticking lives in one place.

import QtQuick 2.15

Item {
    id: clockRoot

    property color textColor: "#ffffff"
    property color mutedColor: "#8a8a8a"
    property string fontFamily: "sans-serif"
    property bool italic: false
    property int timeWeight: Font.Normal
    property int timeSize: 46
    property int dateSize: 13
    property string timeFormat: "hh:mm"
    property string dateFormat: "dddd, MMMM d"
    property bool dateUppercase: false
    property bool horizontal: false
    property int clockSpacing: horizontal ? 16 : 6
    property int horizontalAlignment: Text.AlignLeft

    implicitWidth: horizontal ? hRow.implicitWidth : Math.max(timeLabelV.implicitWidth, dateLabelV.implicitWidth)
    implicitHeight: horizontal ? hRow.implicitHeight : (timeLabelV.implicitHeight + clockSpacing + dateLabelV.implicitHeight)

    Row {
        id: hRow
        visible: clockRoot.horizontal
        spacing: clockRoot.clockSpacing

        Text {
            id: timeLabelH
            color: clockRoot.textColor
            font.family: clockRoot.fontFamily
            font.pixelSize: clockRoot.timeSize
            font.weight: clockRoot.timeWeight
            font.italic: clockRoot.italic
        }
        Text {
            id: dateLabelH
            anchors.baseline: timeLabelH.baseline
            color: clockRoot.mutedColor
            font.family: clockRoot.fontFamily
            font.pixelSize: clockRoot.dateSize
        }
    }

    Column {
        id: vCol
        visible: !clockRoot.horizontal
        spacing: clockRoot.clockSpacing
        anchors.horizontalCenter: clockRoot.horizontalAlignment === Text.AlignHCenter ? parent.horizontalCenter : undefined

        Text {
            id: timeLabelV
            anchors.horizontalCenter: clockRoot.horizontalAlignment === Text.AlignHCenter ? parent.horizontalCenter : undefined
            color: clockRoot.textColor
            font.family: clockRoot.fontFamily
            font.pixelSize: clockRoot.timeSize
            font.weight: clockRoot.timeWeight
            font.italic: clockRoot.italic
        }
        Text {
            id: dateLabelV
            anchors.horizontalCenter: clockRoot.horizontalAlignment === Text.AlignHCenter ? parent.horizontalCenter : undefined
            color: clockRoot.mutedColor
            font.family: clockRoot.fontFamily
            font.pixelSize: clockRoot.dateSize
        }
    }

    function updateTime() {
        var now = new Date();
        var t = Qt.formatTime(now, clockRoot.timeFormat);
        var d = Qt.formatDate(now, clockRoot.dateFormat);
        if (clockRoot.dateUppercase) d = d.toUpperCase();
        timeLabelH.text = t;
        dateLabelH.text = d;
        timeLabelV.text = t;
        dateLabelV.text = d;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: clockRoot.updateTime()
    }
}
