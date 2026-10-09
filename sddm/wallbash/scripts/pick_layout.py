#!/usr/bin/env python3
"""pick_layout.py - deterministic SDDM layout picker for a HyDE theme name.

Same spirit as this dotfiles setup's existing screenshot-gallery layout picker: hash the
theme name and take it modulo the number of layouts, so every HyDE theme gets a stable,
evenly-distributed QML composition without anyone having to curate a mapping by hand.
(The specific file this was asked to mirror,
/tmp/claude-1000/.../scratchpad/pick_layout.py, does not exist on this machine - this is
written directly from the algorithm description instead of ported from that file.)

Bucket order matches the five mockup scenes, for continuity with what was already
approved: 0=1-Bit 1=Bad Blood 2=Rose Pine 3=Synth Wave 4=Catppuccin Mocha, i.e. Template
1-5 in theme.conf vocabulary.

Usage: python3 pick_layout.py "<HyDE theme name>"
Prints a single digit, 1-5, to stdout.
"""
import hashlib
import sys
import unicodedata

LAYOUT_COUNT = 5

# The five themes each composition was actually designed around keep that composition.
# Pure hashing sent Bad Blood to the Catppuccin bottom sheet and Catppuccin Mocha to the
# 1-Bit terminal frame, so the approved previews (and the README screenshots) would not
# have matched what the login screen really showed. Every other theme is still hashed.
PINNED = {
    "1-Bit": 1,
    "Bad Blood": 2,
    "Rosé Pine": 3,
    "Synth Wave": 4,
    "Catppuccin Mocha": 5,
}


def _nfc(s: str) -> str:
    # Theme directory names can arrive NFC or NFD ("é" as one codepoint vs e + accent);
    # normalize both sides so the pin for "Rosé Pine" matches either spelling.
    return unicodedata.normalize("NFC", s)


def pick_template(theme_name: str) -> int:
    """Return 1-5. The same theme name always returns the same number."""
    name = _nfc(theme_name)
    for pinned_name, template in PINNED.items():
        if _nfc(pinned_name) == name:
            return template
    digest = hashlib.md5(theme_name.encode("utf-8")).hexdigest()
    return (int(digest, 16) % LAYOUT_COUNT) + 1


def main() -> int:
    if len(sys.argv) != 2 or not sys.argv[1]:
        # No theme name given - degrade to the safe default (1-Bit) rather than erroring,
        # since this is called from inside a wallbash hook that must never break the
        # wallpaper-set pipeline just because it got called oddly.
        print(1)
        return 0
    print(pick_template(sys.argv[1]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
