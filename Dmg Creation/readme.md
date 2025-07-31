# DMG Creator Script

A bash script to create professional DMG installers for macOS applications with custom app icons and code signing support.

## Features

- ✅ Creates professional DMG installers
- 🎨 Uses your app's icon for the DMG file
- 🔐 Code signing support (with fallback)
- 🧹 Automatic cleanup
- 📱 Works with any macOS app bundle

## Prerequisites

### Required
```bash
brew install create-dmg
```

### Optional (for better DMG icon support)
```bash
brew install fileicon
```

## Usage

1. Place your `.app` bundle in the same directory as the script
2. Update the configuration variables in the script:
   ```bash
   APP_NAME="YourApp"  # Change this to your app name
   ```
3. Update the code signing identity (or remove for unsigned DMGs):
   ```bash
   --identity="Apple Development: Your Name (TEAMID)"
   ```
4. Make the script executable:
   ```bash
   chmod +x create-dmg-script.sh
   ```
5. Run the script:
   ```bash
   ./create-dmg-script.sh
   ```

## Configuration

Edit these variables at the top of the script:

- `APP_NAME`: Your application name
- `APP_PATH`: Path to your .app bundle (usually `${APP_NAME}.app`)

## Code Signing

To use code signing, update the `--identity` parameter with your certificate:

```bash
# Find your certificates
security find-identity -v -p codesigning

# Use the full name or hash in the script
--identity="Apple Development: Your Name (TEAMID)"
```

To disable code signing, remove the `--identity` parameter entirely.

## Troubleshooting

### "Could not find" errors
- Make sure your `.app` bundle is in the same directory as the script
- Verify `create-dmg` is installed: `brew install create-dmg`

### Code signing ambiguity
- Use the full certificate name including team ID
- Or use the certificate hash instead of the name

### DMG icon not applied
- Install `fileicon`: `brew install fileicon`
- Ensure your app has an `AppIcon.icns` file in `Contents/Resources/`

## Output

The script creates:
- A DMG file with your app name
- Professional installer layout
- Custom DMG icon matching your app
- Automatic Finder reveal when complete

## License

MIT License - feel free to modify and use for your projects.