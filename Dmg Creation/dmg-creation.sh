#!/bin/bash

# =============================================================================
# DMG Creator Script for macOS Apps
# =============================================================================
# This script creates a professional DMG installer for macOS applications
# with custom app icon and code signing support.
#
# Author: Faraaz Baig
# Usage: ./create-dmg-script.sh
# Requirements: create-dmg, fileicon (optional)
# =============================================================================

# Configuration
APP_NAME="Your App Name"
APP_PATH="${APP_NAME}.app"

echo "📱 Creating DMG for $APP_NAME..."

# =============================================================================
# Validation
# =============================================================================

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: $APP_PATH not found"
    echo "Make sure your .app bundle is in the same directory as this script"
    exit 1
fi

# =============================================================================
# Cleanup
# =============================================================================

# Remove any existing DMG files
echo "🗑️ Cleaning up existing DMG files..."
rm -f *.dmg

# =============================================================================
# Icon Setup
# =============================================================================

# Extract app icon and create volume icon
echo "🎨 Setting up app icon for DMG..."
APP_ICON="$APP_PATH/Contents/Resources/AppIcon.icns"
VOLUME_ICON="temp-volume-icon.icns"

if [ -f "$APP_ICON" ]; then
    echo "✅ Found app icon, copying for DMG volume icon..."
    cp "$APP_ICON" "$VOLUME_ICON"
    USE_ICON=true
else
    echo "⚠️ No app icon found"
    USE_ICON=false
fi

# =============================================================================
# DMG Creation
# =============================================================================

echo "🔨 Creating DMG..."

# Try with specific certificate to avoid ambiguity
# Note: Update the identity string with your own certificate
create-dmg \
    --overwrite \
    --dmg-title="$APP_NAME Installer" \
    --identity="Apple Development: Your Name (Your Certificate ID)" \
    "$APP_PATH"

# =============================================================================
# Post-Processing
# =============================================================================

# Find the created DMG
DMG_FILE=$(ls *.dmg 2>/dev/null | head -1)

if [ -n "$DMG_FILE" ]; then
    echo "✅ DMG created: $DMG_FILE"
    
    # Apply app icon to the DMG file itself
    if [ "$USE_ICON" = true ]; then
        echo "🎨 Adding app icon to DMG file..."
        
        # Method 1: Use SetFile (part of Xcode Command Line Tools)
        if command -v SetFile &> /dev/null; then
            SetFile -a C "$DMG_FILE" 2>/dev/null || echo "SetFile method failed, DMG still works"
        fi
        
        # Method 2: Use fileicon (recommended)
        if command -v fileicon &> /dev/null; then
            fileicon set "$DMG_FILE" "$VOLUME_ICON"
            echo "✅ Applied app icon to DMG file"
        else
            echo "💡 Install 'fileicon' for better DMG icon support:"
            echo "   brew install fileicon"
        fi
    fi
    
    # Cleanup temporary files
    rm -f "$VOLUME_ICON"
    
    # Display results
    echo "📏 Size: $(ls -lh "$DMG_FILE" | awk '{print $5}')"
    echo "📍 Location: $(pwd)/$DMG_FILE"
    
    # Open in Finder
    open -R "$DMG_FILE"
    
else
    echo "❌ DMG creation failed, trying without code signing..."
    
    # =============================================================================
    # Fallback: Create without code signing
    # =============================================================================
    
    create-dmg --overwrite --dmg-title="$APP_NAME Installer" "$APP_PATH"
    
    DMG_FILE=$(ls *.dmg 2>/dev/null | head -1)
    if [ -n "$DMG_FILE" ]; then
        echo "✅ DMG created without code signing: $DMG_FILE"
        
        # Apply icon to DMG file
        if [ "$USE_ICON" = true ] && command -v fileicon &> /dev/null; then
            fileicon set "$DMG_FILE" "$VOLUME_ICON"
            echo "✅ Applied app icon to DMG file"
        fi
        
        rm -f "$VOLUME_ICON"
        open -R "$DMG_FILE"
    else
        echo "❌ All attempts failed"
        echo "Please check that create-dmg is installed: brew install create-dmg"
    fi
fi

echo "🎉 Done!"