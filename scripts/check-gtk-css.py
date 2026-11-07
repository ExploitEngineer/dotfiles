#!/usr/bin/env python3
"""Parse GTK 3 CSS files with GTK's own parser and fail on any error.

Needs a display, so run it under xvfb-run:
    xvfb-run -a python3 scripts/check-gtk-css.py file.css [file.css ...]
"""
import sys
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk  # noqa: E402

failed = 0
for path in sys.argv[1:]:
    errors = []
    provider = Gtk.CssProvider()
    provider.connect("parsing-error", lambda _p, sec, err: errors.append((sec.get_start_line() + 1, err.message)))
    try:
        provider.load_from_path(path)
    except Exception as exc:  # noqa: BLE001
        errors.append((0, str(exc)))
    print(f"{path}: {len(errors)} error(s)")
    for line, msg in errors[:10]:
        print(f"  line {line}: {msg}")
    failed += bool(errors)
sys.exit(1 if failed else 0)
