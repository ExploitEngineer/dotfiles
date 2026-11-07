#!/usr/bin/env bash
#
# Choose which notification daemon owns org.freedesktop.Notifications.
#
# Usage:
#   scripts/notification-daemon.sh swaync    use swaync (the themed design in docs/notifications.md)
#   scripts/notification-daemon.sh dunst     go back to dunst
#   scripts/notification-daemon.sh status    show which one is active
#
# Only one process can own the D-Bus name, and having both installed is
# actively harmful (see docs/hyde-fixes.md), so this masks the one you are not
# using and points D-Bus activation at the one you are. Everything is per-user,
# under ~/.config and ~/.local, so no sudo is needed and the change is undone
# by running the script again with the other name.
set -euo pipefail

DBUS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dbus-1/services"
DBUS_FILE="$DBUS_DIR/org.freedesktop.Notifications.service"

owner() {
  dbus-send --session --print-reply --dest=org.freedesktop.Notifications \
    /org/freedesktop/Notifications org.freedesktop.Notifications.GetServerInformation 2>/dev/null |
    awk -F'"' '/string/ {print $2; exit}' |
    sed 's/^SwayNotificationCenter$/swaync/'
}

use() {
  local want="$1" other="$2"
  command -v "$want" >/dev/null 2>&1 || { echo "error: $want is not installed" >&2; exit 1; }

  systemctl --user unmask "$want.service" 2>/dev/null || true
  systemctl --user mask "$other.service" 2>/dev/null || true
  pkill -x "$other" 2>/dev/null || true

  mkdir -p "$DBUS_DIR"
  printf '[D-BUS Service]\nName=org.freedesktop.Notifications\nExec=/usr/bin/%s\nSystemdService=%s.service\n' \
    "$want" "$want" >"$DBUS_FILE"

  if [ "$(owner)" != "$want" ]; then
    pkill -x "$want" 2>/dev/null || true
    systemctl --user start "$want.service" 2>/dev/null || { setsid -f "$want" >/dev/null 2>&1; }
    for _ in 1 2 3 4 5 6 7 8 9 10; do [ "$(owner)" = "$want" ] && break; sleep 0.3; done
  fi
  echo "notification daemon: $(owner)"
}

case "${1:-status}" in
  swaync) use swaync dunst ;;
  dunst) use dunst swaync ;;
  status) echo "notification daemon: $(owner || echo none)" ;;
  *) sed -n '3,9p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
