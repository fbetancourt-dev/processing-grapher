#!/usr/bin/env bash
# Install Processing Grapher desktop launcher and icons for Linux desktop environments
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/ProcessingGrapher"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor"

mkdir -p "$BIN_DIR" "$DESKTOP_DIR"

# 1. Create launcher in ~/.local/bin/processing-grapher
cat << 'LAUNCHER' > "$BIN_DIR/processing-grapher"
#!/usr/bin/env bash
PROCESSING_BIN="$(which processing-java 2>/dev/null || which processing 2>/dev/null || echo "/usr/local/bin/processing-java")"
SKETCH_PATH="TARGET_SKETCH_PLACEHOLDER"

if [ -x "$PROCESSING_BIN" ]; then
    exec "$PROCESSING_BIN" --sketch="$SKETCH_PATH" --run "$@"
else
    echo "Error: Processing executable (processing-java) not found on PATH." >&2
    exit 1
fi
LAUNCHER
sed -i "s|TARGET_SKETCH_PLACEHOLDER|$APP_DIR|g" "$BIN_DIR/processing-grapher"
chmod +x "$BIN_DIR/processing-grapher"

# 2. Install application icons
for size in 128 256 512; do
    mkdir -p "$ICON_DIR/${size}x${size}/apps"
    if command -v convert >/dev/null 2>&1; then
        convert "$APP_DIR/data/icon-72.png" -filter Mitchell -resize "${size}x${size}" "$ICON_DIR/${size}x${size}/apps/processing-grapher.png"
        convert "$APP_DIR/data/icon-72.png" -filter Mitchell -resize "${size}x${size}" "$ICON_DIR/${size}x${size}/apps/processing-core-PApplet.png"
    else
        cp "$APP_DIR/data/icon-72.png" "$ICON_DIR/${size}x${size}/apps/processing-grapher.png"
        cp "$APP_DIR/data/icon-72.png" "$ICON_DIR/${size}x${size}/apps/processing-core-PApplet.png"
    fi
done

# 3. Install desktop entry
cat << DESKTOP > "$DESKTOP_DIR/processing-grapher.desktop"
[Desktop Entry]
Name=Processing Grapher
Comment=Serial monitor and real-time graphing program
Exec=$BIN_DIR/processing-grapher %u
Icon=processing-grapher
Terminal=false
Type=Application
Categories=Development;Engineering;Electronics;
StartupWMClass=processing-core-PApplet
MimeType=application/x-processing;
DESKTOP

# 4. Refresh databases
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true

echo "Successfully installed Processing Grapher desktop launcher and icons!"
