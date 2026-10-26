#!/bin/bash
set -e

CONFIGURATION="${1:-release}"
echo "==> Building FreeIsland ($CONFIGURATION)..."
swift build -c "$CONFIGURATION"

BIN_PATH=$(swift build -c "$CONFIGURATION" --show-bin-path)
APP_BUNDLE="FreeIsland.app"

echo "==> Packaging $APP_BUNDLE..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BIN_PATH/FreeIsland" "$APP_BUNDLE/Contents/MacOS/FreeIsland"
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "==> Successfully created $APP_BUNDLE at $(pwd)/$APP_BUNDLE"
