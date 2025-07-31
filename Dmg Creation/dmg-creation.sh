#!/bin/bash

# =============================================================================
# Professional DMG Creator with Notarization
# =============================================================================
# Creates a fully signed and notarized DMG for macOS app distribution
# Author: Faraaz Baig / Arcline Labs Inc.
# =============================================================================

# Configuration
APP_NAME="{Enter your app name here}"
APP_PATH="${APP_NAME}.app"
APPLE_ID="{Enter your ID here}"
TEAM_ID="{Enter your ID here}"
APP_SPECIFIC_PASSWORD="{Enter your app password here}"  # UPDATE THIS!

echo "🚀 Creating professional DMG for $APP_NAME..."

# =============================================================================
# Validation
# =============================================================================

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: $APP_PATH not found in current directory"
    echo "Current directory: $(pwd)"
    ls -la
    exit 1
fi

# Find Developer ID certificate
DEV_ID_CERT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | cut -d'"' -f2)

if [ -z "$DEV_ID_CERT" ]; then
    echo "❌ No Developer ID Application certificate found!"
    echo "Available certificates:"
    security find-identity -v -p codesigning
    echo ""
    echo "Please ensure your Developer ID certificate is installed."
    exit 1
fi

echo "✅ Found Developer ID certificate: $DEV_ID_CERT"

# =============================================================================
# Step 1: Deep Code Signing with Hardened Runtime
# =============================================================================

echo "🔐 Starting comprehensive code signing process..."

# Remove any existing signatures
echo "🧹 Cleaning existing signatures..."
find "$APP_PATH" -type f \( -name "*.dylib" -o -name "*.framework" -o -perm +111 \) -exec codesign --remove-signature {} \; 2>/dev/null || true

# Sign all frameworks and dylibs first (inside-out signing)
echo "📚 Signing frameworks and libraries..."
find "$APP_PATH" -name "*.framework" -type d | sort | while read framework; do
    echo "  → Signing framework: $(basename "$framework")"
    codesign --force --sign "$DEV_ID_CERT" \
        --options runtime \
        --timestamp \
        --verbose \
        "$framework" || echo "    ⚠️ Framework signing failed: $framework"
done

find "$APP_PATH" -name "*.dylib" -type f | while read dylib; do
    echo "  → Signing dylib: $(basename "$dylib")"
    codesign --force --sign "$DEV_ID_CERT" \
        --options runtime \
        --timestamp \
        --verbose \
        "$dylib" || echo "    ⚠️ Dylib signing failed: $dylib"
done

# Sign the main executable
echo "⚙️ Signing main executable..."
MAIN_EXECUTABLE="$APP_PATH/Contents/MacOS/spillitout"
if [ -f "$MAIN_EXECUTABLE" ]; then
    codesign --force --sign "$DEV_ID_CERT" \
        --options runtime \
        --timestamp \
        --verbose \
        "$MAIN_EXECUTABLE"
    
    if [ $? -eq 0 ]; then
        echo "✅ Main executable signed successfully"
    else
        echo "❌ Main executable signing failed"
        exit 1
    fi
else
    echo "⚠️ Main executable not found at expected path"
fi

# Sign the entire app bundle
echo "📱 Signing complete app bundle..."
codesign --force --sign "$DEV_ID_CERT" \
    --options runtime \
    --timestamp \
    --verbose \
    "$APP_PATH"

if [ $? -eq 0 ]; then
    echo "✅ App bundle signed successfully"
else
    echo "❌ App bundle signing failed"
    exit 1
fi

# Verify the signature
echo "🔍 Verifying app signature..."
codesign --verify --verbose=4 "$APP_PATH"
spctl --assess --verbose "$APP_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Signature verification passed"
else
    echo "⚠️ Signature verification had issues, but continuing..."
fi

# =============================================================================
# Step 2: Create Professional DMG
# =============================================================================

echo "🗑️ Cleaning up existing DMG files..."
rm -f *.dmg

echo "🎨 Setting up app icon for DMG..."
APP_ICON="$APP_PATH/Contents/Resources/AppIcon.icns"
VOLUME_ICON="temp-volume-icon.icns"

if [ -f "$APP_ICON" ]; then
    echo "✅ Found app icon, copying for DMG volume icon..."
    cp "$APP_ICON" "$VOLUME_ICON"
    USE_ICON=true
else
    echo "⚠️ No app icon found at $APP_ICON"
    USE_ICON=false
fi

echo "🔨 Creating DMG with professional layout..."
create-dmg \
    --overwrite \
    --dmg-title="$APP_NAME Installer" \
    --identity="$DEV_ID_CERT" \
    "$APP_PATH"

# Find the created DMG
DMG_FILE=$(ls -t *.dmg 2>/dev/null | head -1)

if [ -z "$DMG_FILE" ]; then
    echo "❌ DMG creation failed"
    exit 1
fi

echo "✅ DMG created: $DMG_FILE"

# Apply app icon to the DMG file itself
if [ "$USE_ICON" = true ]; then
    if command -v fileicon &> /dev/null; then
        echo "🎨 Applying app icon to DMG file..."
        fileicon set "$DMG_FILE" "$VOLUME_ICON"
        echo "✅ App icon applied to DMG file"
    else
        echo "💡 Install 'fileicon' for DMG icon support: brew install fileicon"
    fi
fi

# Cleanup temporary files
rm -f "$VOLUME_ICON"

# =============================================================================
# Step 3: Notarization Process
# =============================================================================

echo "📋 Starting notarization process..."

# Check if app-specific password is set
if [ -z "$APP_SPECIFIC_PASSWORD" ] || [ "$APP_SPECIFIC_PASSWORD" = "your-app-specific-password-here" ]; then
    echo "⚠️ App-specific password not set!"
    echo ""
    echo "To enable notarization:"
    echo "1. Go to https://appleid.apple.com"
    echo "2. Sign in and go to 'App-Specific Passwords'"
    echo "3. Generate a new password for 'DMG Notarization'"
    echo "4. Update APP_SPECIFIC_PASSWORD in this script"
    echo ""
    echo "Your DMG is created and signed, but not notarized."
    echo "Users will need to right-click → Open to install."
    open -R "$DMG_FILE"
    exit 0
fi

echo "📤 Submitting DMG for notarization..."
echo "This may take 5-15 minutes..."

NOTARIZATION_OUTPUT=$(xcrun notarytool submit "$DMG_FILE" \
    --apple-id "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait 2>&1)

echo "$NOTARIZATION_OUTPUT"

# Check if notarization succeeded
if echo "$NOTARIZATION_OUTPUT" | grep -q "status: Accepted"; then
    echo "🎉 Notarization successful!"
    
    # Wait a moment before stapling
    echo "⏳ Waiting 30 seconds before stapling..."
    sleep 30
    
    # Staple the notarization ticket
    echo "📎 Stapling notarization ticket to DMG..."
    STAPLE_OUTPUT=$(xcrun stapler staple "$DMG_FILE" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ DMG successfully stapled!"
        echo "🏆 Your DMG is now fully notarized and ready for distribution!"
        STAPLED="✅"
    else
        echo "⚠️ Stapling failed, but notarization succeeded"
        echo "DMG will work with internet connection for verification"
        echo "Staple error: $STAPLE_OUTPUT"
        STAPLED="⚠️ Online verification required"
    fi
    
    NOTARIZED="✅"
else
    echo "❌ Notarization failed"
    echo "Your DMG is signed but will show 'not verified' warning"
    
    # Try to get the submission ID for logs
    SUBMISSION_ID=$(echo "$NOTARIZATION_OUTPUT" | grep -o 'id: [a-f0-9-]*' | cut -d' ' -f2 | head -1)
    if [ -n "$SUBMISSION_ID" ]; then
        echo "📋 To see detailed error log, run:"
        echo "xcrun notarytool log $SUBMISSION_ID --apple-id \"$APPLE_ID\" --password \"$APP_SPECIFIC_PASSWORD\" --team-id \"$TEAM_ID\""
    fi
    
    NOTARIZED="❌"
    STAPLED="❌"
fi

# =============================================================================
# Final Summary
# =============================================================================

echo ""
echo "🎯 ===== FINAL SUMMARY ===== 🎯"
echo "📱 App: $APP_NAME"
echo "📦 DMG: $DMG_FILE"
echo "📏 Size: $(ls -lh "$DMG_FILE" | awk '{print $5}')"
echo "📍 Location: $(pwd)/$DMG_FILE"
echo ""
echo "🔐 Code Signed: ✅ (Developer ID)"
echo "🍎 Notarized: $NOTARIZED"
echo "📎 Stapled: $STAPLED"
echo ""

if [ "$NOTARIZED" = "✅" ]; then
    echo "🚀 SUCCESS! Your DMG is ready for professional distribution!"
    echo "   Users can install without any security warnings."
else
    echo "✅ Your DMG is code-signed and functional!"
    echo "   Users can install by right-clicking → Open."
fi

echo ""
echo "📂 Opening DMG location in Finder..."
open -R "$DMG_FILE"

echo "🎉 Done! Happy distributing! 🚀"

