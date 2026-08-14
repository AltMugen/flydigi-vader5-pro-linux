#!/usr/bin/env bash
# Flydigi Vader 5 Pro Linux Full Installer

set -e

echo "Installing Flydigi Vader 5 Pro driver and utilities..."

# Pre-flight build tool check
MISSING_TOOLS=()
for tool in gcc cmake ninja git python3 wget curl; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo "Error: Missing required build tools: ${MISSING_TOOLS[*]}"
    echo ""
    echo "Please install prerequisites for your Linux distribution:"
    echo "  Ubuntu/Debian: sudo apt update && sudo apt install -y git build-essential cmake ninja-build python3 wget curl libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev libxrandr-dev libxrender-dev libxinerama-dev libxss-dev libxtst-dev"
    echo "  Fedora:        sudo dnf install -y git gcc gcc-c++ cmake ninja-build python3 wget curl libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXScrnSaver-devel libXtst-devel"
    echo "  Arch Linux:    sudo pacman -S --needed git base-devel cmake ninja python wget curl libx11 libxext libxcursor libxi libxfixes libxrandr libxrender libxinerama libxss libxtst"
    echo "  openSUSE:      sudo zypper install -y git gcc gcc-c++ cmake ninja python3 wget curl libX11-devel libXext-devel libXcursor-devel libXi-devel libXfixes-devel libXrandr-devel libXrender-devel libXinerama-devel libXss-devel libXtst-devel"
    exit 1
fi

# 1. Fetch and install padctl
echo "Installing padctl daemon..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
URL=$(curl -s https://api.github.com/repos/BANANASJIM/padctl/releases/latest | grep "browser_download_url.*x86_64-linux-musl.tar.gz" | cut -d '"' -f 4)

if [ -z "$URL" ]; then
    echo "Error: Could not retrieve padctl release URL from GitHub API."
    exit 1
fi

wget -q --show-progress -O padctl.tar.gz "$URL"
tar -xf padctl.tar.gz

PADCTL_BIN=$(find . -name "padctl" -type f | head -n 1)
if [ -n "$PADCTL_BIN" ]; then
    sudo cp "$PADCTL_BIN" /usr/bin/padctl
    sudo chmod +x /usr/bin/padctl
else
    echo "Error: Could not find padctl binary in extracted archive!"
    exit 1
fi

cd - >/dev/null
rm -rf "$TMP_DIR"

# 2. Prepare and build patched SDL3
echo "Building patched SDL3 library..."
SDL_SRC="$HOME/sdl-build/SDL-3.4.4"

if [ ! -d "$SDL_SRC" ]; then
    mkdir -p "$HOME/sdl-build"
    git clone --quiet --branch release-3.4.4 --depth 1 https://github.com/libsdl-org/SDL.git "$SDL_SRC"
fi

# Apply C patches directly
python3 -c '
import os, re

file_path = os.path.expanduser("~/sdl-build/SDL-3.4.4/src/joystick/hidapi/SDL_hidapi_flydigi.c")

with open(file_path, "r") as f:
    code = f.read()

# 1. Define RAW_PACKET_SIZE
if "FLYDIGI_V2_RAW_PACKET_SIZE" not in code:
    code = code.replace(
        "#define FLYDIGI_V2_ACQUIRE_CONTROLLER_COMMAND 0x1C",
        "#define FLYDIGI_V2_ACQUIRE_CONTROLLER_COMMAND 0x1C\n#define FLYDIGI_V2_RAW_PACKET_SIZE 32"
    )

# 2. Define helper functions
if "SDL_HIDAPI_Flydigi_UsesUnnumbered32ByteReports" not in code:
    helpers = """static bool SDL_HIDAPI_Flydigi_UsesUnnumbered32ByteReports(SDL_HIDAPI_Device *device)
{
    return device->vendor_id == USB_VENDOR_FLYDIGI_V2 && device->interface_number == 1;
}

static int SDL_HIDAPI_Flydigi_WritePacket(SDL_HIDAPI_Device *device, const Uint8 *packet, size_t size)
{
    if (SDL_HIDAPI_Flydigi_UsesUnnumbered32ByteReports(device)) {
        Uint8 raw_packet[FLYDIGI_V2_RAW_PACKET_SIZE + 1];
        size_t payload_size;

        SDL_zeroa(raw_packet);

        if (size > 0 && packet[0] == FLYDIGI_V2_CMD_REPORT_ID) {
            ++packet;
            --size;
        }

        payload_size = SDL_min(size, (size_t)FLYDIGI_V2_RAW_PACKET_SIZE);
        SDL_memcpy(&raw_packet[1], packet, payload_size);
        return SDL_hid_write(device->dev, raw_packet, sizeof(raw_packet));
    }

    return SDL_hid_write(device->dev, packet, size);
}

static bool GetReply"""
    code = code.replace("static bool GetReply", helpers)

# 3. Inject rumble handler (2x Burst + 22ms rate limiter)
new_rumble = """static bool HIDAPI_DriverFlydigi_RumbleJoystick(SDL_HIDAPI_Device *device, SDL_Joystick *joystick, Uint16 low_frequency_rumble, Uint16 high_frequency_rumble)
{
    Uint8 rumble_packet[] = { FLYDIGI_V2_CMD_REPORT_ID, FLYDIGI_V2_MAGIC1, FLYDIGI_V2_MAGIC2, FLYDIGI_V2_HAPTIC_COMMAND, 6, 0, 0, 0, 0, 0 };
    Uint8 req_low = low_frequency_rumble >> 8;
    Uint8 req_high = high_frequency_rumble >> 8;
    rumble_packet[5] = req_low;
    rumble_packet[6] = req_high;

    static Uint64 last_write_time = 0;
    static Uint8 last_sent_low = 0, last_sent_high = 0;

    bool is_stop = (req_low == 0 && req_high == 0);

    if (!is_stop && req_low == last_sent_low && req_high == last_sent_high) {
        return true;
    }

    if (is_stop && last_sent_low == 0 && last_sent_high == 0) {
        return true;
    }

    Uint64 now = SDL_GetTicks();
    Uint64 elapsed = now - last_write_time;

    if (is_stop) {
        if (elapsed < 22) {
            SDL_Delay((Uint32)(22 - elapsed));
        }

        for (int i = 0; i < 2; i++) {
            if (SDL_HIDAPI_Flydigi_UsesUnnumbered32ByteReports(device)) {
                Uint8 raw_packet[FLYDIGI_V2_RAW_PACKET_SIZE + 1];
                SDL_zeroa(raw_packet);
                SDL_memcpy(&raw_packet[1], &rumble_packet[1], sizeof(rumble_packet) - 1);
                SDL_HIDAPI_SendRumble(device, raw_packet, sizeof(raw_packet));
            } else {
                SDL_HIDAPI_SendRumble(device, rumble_packet, sizeof(rumble_packet));
            }
            if (i < 1) SDL_Delay(22);
        }

        last_sent_low = 0;
        last_sent_high = 0;
        last_write_time = SDL_GetTicks();
        return true;
    }

    if (elapsed < 22) {
        SDL_Delay((Uint32)(22 - elapsed));
        now = SDL_GetTicks();
    }

    last_sent_low = req_low;
    last_sent_high = req_high;
    last_write_time = now;

    if (SDL_HIDAPI_Flydigi_UsesUnnumbered32ByteReports(device)) {
        Uint8 raw_packet[FLYDIGI_V2_RAW_PACKET_SIZE + 1];
        SDL_zeroa(raw_packet);
        SDL_memcpy(&raw_packet[1], &rumble_packet[1], sizeof(rumble_packet) - 1);
        if (SDL_HIDAPI_SendRumble(device, raw_packet, sizeof(raw_packet)) != sizeof(raw_packet)) {
            return SDL_SetError("Could not send rumble packet");
        }
    } else if (SDL_HIDAPI_SendRumble(device, rumble_packet, sizeof(rumble_packet)) != sizeof(rumble_packet)) {
        return SDL_SetError("Could not send rumble packet");
    }

    return true;
}"""

pattern = r"static bool HIDAPI_DriverFlydigi_RumbleJoystick\(.*?\n\}"
code = re.sub(pattern, new_rumble, code, flags=re.DOTALL)

with open(file_path, "w") as f:
    f.write(code)
'

# Build 64-bit SDL3
SDL_BUILD64="$SDL_SRC/build-steam64"
cmake -S "$SDL_SRC" -B "$SDL_BUILD64" -GNinja -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=ON -DSDL_TESTS=OFF
cmake --build "$SDL_BUILD64" -j"$(nproc)"

mkdir -p "$HOME/.local/share/vader5-driver/sdl"
cp "$SDL_BUILD64/libSDL3.so.0" "$HOME/.local/share/vader5-driver/sdl/libSDL3-64.so.0"

# 3. Install udev rules and vader5 script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo cp "$SCRIPT_DIR/vader5" /usr/local/bin/vader5
sudo chmod +x /usr/local/bin/vader5

sudo cp "$SCRIPT_DIR/60-vader5-sdl.rules" /etc/udev/rules.d/
sudo cp "$SCRIPT_DIR/60-padctl.rules" /etc/udev/rules.d/60-padctl.rules.disabled

sudo udevadm control --reload-rules && sudo udevadm trigger

# 4. Patch Steam
vader5 update

echo "Installation complete! Use 'vader5' command to switch modes."
