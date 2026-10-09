// LastUser.qml - tiny headless helper exposing the last-logged-in username as plain text.
//
// SDDM's userModel is a C++ model with named roles (no JS-friendly `.get(index)`), and
// going through a ComboBox's textRole is the pattern SDDM's own bundled themes use to
// read it. This wraps that so every Layout*.qml can just bind a TextField's initial
// text to `LastUser { id: lastUser }` -> `lastUser.currentText`, exactly as Candy does.

import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    model: userModel
    textRole: "name"
    currentIndex: userModel.lastIndex
    visible: false
}
