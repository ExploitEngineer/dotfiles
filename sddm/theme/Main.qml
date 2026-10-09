// Main.qml - hyde-wallbash SDDM greeter
//
// Deliberately thin: it only resolves *which* colors/background/template to use and
// hands them to one of the five components/Layout*.qml compositions. All real UI lives
// in those files so each can faithfully match its mockup scene without fighting a shared
// layout skeleton.
//
// Two sources of truth, in priority order:
//   1. /etc/sddm-wallbash/current.conf - written by wallbash on every theme/wallpaper
//      switch (see ../wallbash/). May not exist yet, may be stale, may be malformed -
//      never trust it blindly.
//   2. theme.conf's [General] section (exposed here as config.*) - baked in at install
//      time, always valid. This is the safe fallback for a machine that has never run
//      the wallbash hook, or whose hook failed.
//
// Reading (1) uses XMLHttpRequest against a file:// URL, synchronously. That is a real,
// long-supported part of the QML JS environment - no C++ plugin, no extra QML module -
// and the file is a few hundred bytes, so the synchronous read is not a startup-latency
// concern on a login screen.

import QtQuick 2.15

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height
    color: "#000000"

    // ---- baked-in defaults from theme.conf -------------------------------------------
    property string defaultBackground: config.Background || ""
    property string defaultPry1: config.ColorPry1 || "1D1D1D"
    property string defaultTxt1: config.ColorTxt1 || "FFFFFF"
    property string defaultPry2: config.ColorPry2 || "3A3A3A"
    property string defaultPry3: config.ColorPry3 || "7F7F7F"
    property string defaultPry4: config.ColorPry4 || "B3B3B3"
    property int defaultTemplate: parseInt(config.Template || "1") || 1
    property bool defaultReducedMotion: (config.ReducedMotion || "false") === "true"

    // ---- live override, filled in by loadOverride() below -----------------------------
    property var override: ({})

    property string bgPath: override.Background !== undefined ? override.Background : defaultBackground
    property color colBg: "#" + (override.ColorPry1 !== undefined ? override.ColorPry1 : defaultPry1)
    property color colText: "#" + (override.ColorTxt1 !== undefined ? override.ColorTxt1 : defaultTxt1)
    property color colA1: "#" + (override.ColorPry2 !== undefined ? override.ColorPry2 : defaultPry2)
    property color colA2: "#" + (override.ColorPry3 !== undefined ? override.ColorPry3 : defaultPry3)
    property color colA3: "#" + (override.ColorPry4 !== undefined ? override.ColorPry4 : defaultPry4)
    property int templateIndex: {
        var t = override.Template !== undefined ? parseInt(override.Template) : defaultTemplate;
        if (isNaN(t) || t < 1 || t > 5) t = 1;
        return t;
    }
    property bool reducedMotion: override.ReducedMotion !== undefined ? (override.ReducedMotion === "true") : defaultReducedMotion

    readonly property var layoutSources: [
        "components/Layout1Bit.qml",
        "components/LayoutBadBlood.qml",
        "components/LayoutRosePine.qml",
        "components/LayoutSynthWave.qml",
        "components/LayoutCatppuccin.qml"
    ]

    // Parses the flat "Key=Value" override file written by sddm-wallbash.sh. Never
    // throws past this function: any problem at all just leaves the result empty, and
    // the baked-in theme.conf defaults above stand unchanged.
    function loadOverride() {
        var result = {};
        try {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///etc/sddm-wallbash/current.conf", false);
            xhr.send();
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.responseText) {
                var lines = xhr.responseText.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.length === 0 || line.charAt(0) === "#") continue;
                    var idx = line.indexOf("=");
                    if (idx === -1) continue;
                    var key = line.substring(0, idx).trim();
                    var value = line.substring(idx + 1).trim();
                    if (key.length > 0) result[key] = value;
                }
            }
        } catch (e) {
            result = {};
        }
        return result;
    }

    function applyLayout() {
        var idx = root.templateIndex - 1;
        if (idx < 0 || idx > 4) idx = 0;
        // Qt.resolvedUrl handles both cases correctly: theme.conf's baked-in default is a
        // path relative to this file (e.g. "backgrounds/default.png", Candy's own
        // convention), while the live override from /etc/sddm-wallbash/current.conf is
        // always an absolute filesystem path. Resolving an absolute path against any base
        // URL yields that same absolute path with a file:// scheme either way.
        var url = root.bgPath.length > 0 ? Qt.resolvedUrl(root.bgPath).toString() : "";
        stage.setSource(root.layoutSources[idx], {
            "bgSource": url,
            "colBg": root.colBg,
            "colText": root.colText,
            "colA1": root.colA1,
            "colA2": root.colA2,
            "colA3": root.colA3,
            "reducedMotion": root.reducedMotion
        });
    }

    Component.onCompleted: {
        root.override = loadOverride();
        applyLayout();
    }

    Loader {
        id: stage
        anchors.fill: parent
        focus: true
    }
}
