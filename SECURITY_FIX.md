# Security Fix - Firebase API Keys Exposed

## Issue
Firebase API keys were committed to GitHub and detected by GitHub's secret scanning.

## Actions Taken

1. **Added to .gitignore:**
   - `lib/firebase_options.dart`
   - `google-services.json`
   - `GoogleService-Info.plist`

2. **Created Template:**
   - `lib/firebase_options.dart.template` for reference

3. **Fixed Dependencies:**
   - Downgraded `share_plus` from ^9.0.0 to ^7.2.2 (compatibility fix)

## What You Need to Do

### 1. Rotate Firebase API Keys (IMPORTANT!)
Since the keys were exposed on GitHub, you should rotate them:

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project: `aivellum-3521b`
3. Go to Project Settings > General
4. Under "Your apps", for each platform:
   - Delete the current app
   - Re-add the app with same package name
   - Download new config files

### 2. Remove Exposed Keys from Git History
```bash
# Remove firebase_options.dart from git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/firebase_options.dart" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (WARNING: This rewrites history)
git push origin --force --all
```

### 3. Regenerate firebase_options.dart
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 4. Run flutter pub get
```bash
flutter pub get
```

## Firebase API Keys Security Note

Firebase API keys in `firebase_options.dart` are **not secret** in the traditional sense:
- They identify your Firebase project
- They're meant to be included in client apps
- Security is enforced by Firebase Security Rules, not by hiding keys

However, it's still best practice to:
- Keep them out of public repos
- Use Firebase Security Rules properly
- Monitor usage in Firebase Console
- Rotate keys if compromised

## Current Status
✅ Keys added to .gitignore
✅ Template created
✅ Dependencies fixed
⚠️ Keys still in git history (needs cleanup)
⚠️ Consider rotating keys (optional but recommended)
