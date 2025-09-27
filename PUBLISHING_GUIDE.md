# AIVELLUM - Android Publishing Guide

## Step 1: Generate Keystore (YOU NEED TO DO THIS)

1. **Run the keystore generation script:**
   ```bash
   generate_keystore.bat
   ```

2. **When prompted, provide:**
   - Keystore password (REMEMBER THIS!)
   - Key password (can be same as keystore password)
   - Your full name
   - Organization: "AIVELLUM" or "Khan Basharat"
   - City: Your city
   - State: Your state/province
   - Country: Your 2-letter country code (e.g., US, IN, UK)

## Step 2: Create key.properties file (YOU NEED TO DO THIS)

1. **Copy the template:**
   ```bash
   copy android\key.properties.template android\key.properties
   ```

2. **Edit android/key.properties and fill in your passwords:**
   ```
   storePassword=YOUR_ACTUAL_KEYSTORE_PASSWORD
   keyPassword=YOUR_ACTUAL_KEY_PASSWORD
   keyAlias=aivellum-key
   storeFile=../keystore/aivellum-keystore.jks
   ```

## Step 3: Build Release APK

```bash
flutter build apk --release
```

## Step 4: Build App Bundle (Recommended for Play Store)

```bash
flutter build appbundle --release
```

## Step 5: Test the Release Build

```bash
flutter install --release
```

## Important Files Created:
- `keystore/aivellum-keystore.jks` - Your signing key (NEVER share this)
- `android/key.properties` - Contains passwords (NEVER commit to git)
- `generate_keystore.bat` - Script to create keystore
- Updated `android/app/build.gradle.kts` - Now configured for release signing

## Security Notes:
- ✅ Keystore files are added to .gitignore
- ✅ key.properties is excluded from git
- ⚠️  NEVER share your keystore file or passwords
- ⚠️  Keep backups of your keystore file safely

## Next Steps for Play Store:
1. Create Google Play Console account
2. Upload the .aab file (app bundle)
3. Fill in store listing details
4. Set up pricing and distribution
5. Submit for review

## Build Outputs:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`