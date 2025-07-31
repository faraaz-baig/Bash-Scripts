# DMG Creator Scripts for macOS Apps

Professional scripts to create signed and notarized DMG installers for macOS applications.

## 📦 What's Included

- **`create-dmg-simple.sh`** - Quick DMG creation with code signing
- **`create-dmg-professional.sh`** - Full notarization and professional distribution

## 🚀 Quick Start

### Simple DMG (Development/Testing)
```bash
chmod +x create-dmg-simple.sh
./create-dmg-simple.sh
```

### Professional DMG (Production Distribution)
```bash
chmod +x create-dmg-professional.sh
./create-dmg-professional.sh
```

## 📋 Prerequisites

### Required Tools
```bash
# Install create-dmg
brew install create-dmg

# Optional: For better DMG icons
brew install fileicon
```

### Required Certificates

#### For Simple DMG:
- **Apple Development Certificate** (free with Apple ID)

#### For Professional DMG:
- **Developer ID Application Certificate** (requires paid Apple Developer Program)

## ⚙️ Setup Instructions

### 1. Configure Your App
Update the app name in both scripts:
```bash
APP_NAME="YourAppName"  # Change this to your app name
```

### 2. For Professional Notarization

#### Get Developer ID Certificate:
1. Go to [developer.apple.com](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Create a **Developer ID Application** certificate
4. Download and install in Keychain Access

#### Create App-Specific Password:
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in → **App-Specific Passwords**
3. Generate password for "DMG Notarization"
4. Update `APP_SPECIFIC_PASSWORD` in the professional script

#### Update Team ID:
```bash
# Find your Team ID
xcrun altool --list-providers -u "your-apple-id@email.com" -p "your-app-password"

# Update in script
TEAM_ID="YOUR_TEAM_ID"
```

## 📁 File Structure

```
your-project/
├── YourApp.app                    # Your macOS app bundle
├── create-dmg-simple.sh          # Simple DMG creator
├── create-dmg-professional.sh    # Professional DMG creator
└── README.md                     # This file
```

## 🔧 Script Comparison

| Feature | Simple Script | Professional Script |
|---------|---------------|-------------------|
| Code Signing | ✅ Apple Development | ✅ Developer ID |
| Custom DMG Icon | ✅ | ✅ |
| Hardened Runtime | ❌ | ✅ |
| Notarization | ❌ | ✅ |
| Stapling | ❌ | ✅ |
| Distribution Ready | Testing Only | ✅ Production |
| User Experience | Right-click to open | No warnings |

## 🎯 Usage Examples

### Development/Internal Testing
```bash
# Quick DMG for testing
./create-dmg-simple.sh

# Result: Signed DMG, users right-click → Open to install
```

### Production Distribution
```bash
# Professional DMG for public release
./create-dmg-professional.sh

# Result: Fully notarized DMG, installs without warnings
```

## 🔍 Troubleshooting

### "Could not find" Errors
- Ensure your `.app` bundle is in the same directory as the script
- Verify `create-dmg` is installed: `brew install create-dmg`

### Code Signing Issues
```bash
# List available certificates
security find-identity -v -p codesigning

# Verify app signature
codesign --verify --verbose YourApp.app
```

### Notarization Failures
```bash
# Check notarization log (replace SUBMISSION_ID)
xcrun notarytool log SUBMISSION_ID \
    --apple-id "your-email@example.com" \
    --password "your-app-password" \
    --team-id "YOUR_TEAM_ID"
```

### Common Certificate Issues
- **"Apple Development: ambiguous"** → Use certificate hash instead of name
- **"Invalid Team ID"** → Use Team ID from `xcrun altool --list-providers`
- **"Not signed with Developer ID"** → Need Developer ID certificate for notarization

## 📊 Output Examples

### Simple Script Output
```
✅ DMG created: YourApp.dmg
🔐 Code signed with Apple Development certificate
⚠️ Users will need to right-click → Open to install
```

### Professional Script Output
```
🎯 ===== FINAL SUMMARY ===== 🎯
📱 App: YourApp
📦 DMG: YourApp.dmg
📏 Size: 25M
🔐 Code Signed: ✅ (Developer ID)
🍎 Notarized: ✅
📎 Stapled: ✅
🚀 SUCCESS! Your DMG is ready for professional distribution!
```

## 🛡️ Security & Distribution

### Simple DMG Security
- ✅ Code signed with Apple Development certificate
- ⚠️ Shows "unverified developer" warning
- 👥 Good for: Internal testing, beta distribution

### Professional DMG Security
- ✅ Code signed with Developer ID certificate
- ✅ Notarized by Apple
- ✅ Stapled for offline verification
- 👥 Good for: Public distribution, enterprise deployment

## 🔄 Automation

### CI/CD Integration
```bash
# In your build pipeline
./create-dmg-professional.sh

# Upload the resulting DMG to your distribution platform
```

### Batch Processing
```bash
# Process multiple apps
for app in *.app; do
    APP_NAME=$(basename "$app" .app)
    # Update script with app name and run
done
```

## 📝 Customization

### Custom DMG Layout
Modify the `create-dmg` parameters in either script:
```bash
create-dmg \
    --volname "Custom Installer Name" \
    --window-size 600 400 \
    --icon-size 120 \
    # ... other options
```

### Custom Signing Options
```bash
# Add entitlements
codesign --entitlements entitlements.plist \
    --sign "Certificate Name" \
    YourApp.app
```

## 🆘 Support

### Getting Help
1. **Check the script output** - it provides detailed error messages
2. **Verify certificates** - ensure you have the right type installed
3. **Check Apple Developer documentation** for notarization requirements
4. **Test on a clean Mac** to verify the DMG works as expected

### Common Solutions
- **Notarization stuck?** Wait 15 minutes, it can be slow
- **Stapling failed?** DMG still works, just requires internet for verification
- **Certificate expired?** Renew in Apple Developer portal

## 📄 License

MIT License - Feel free to modify and use for your projects.

## 🤝 Contributing

1. Fork the repository
2. Make your improvements
3. Test with your own apps
4. Submit a pull request

---

**Happy DMG creating! 🚀**

*These scripts have been tested with macOS apps and provide a reliable way to create professional installers for distribution.*
