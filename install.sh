#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVER_DIR="$HOME/.local/share/vader5-driver/sdl"
[[ -f "$DRIVER_DIR/libSDL3-64.so.0" && -x "$HOME/.local/bin/vader5-rumble" ]] || {
    echo 'Run ./build.sh first.' >&2; exit 1;
}
install -Dm 0755 "$ROOT/vader5" "$HOME/.local/bin/vader5"
install -Dm 0644 "$ROOT/systemd/vader5-rumble.service" "$HOME/.config/systemd/user/vader5-rumble.service"
sudo install -m 0644 "$ROOT/60-vader5-sdl.rules" /etc/udev/rules.d/60-vader5-sdl.rules
sudo udevadm control --reload-rules
systemctl --user daemon-reload
"$HOME/.local/bin/vader5" update
"$HOME/.local/bin/vader5" native
