# Google Sign-In Fix

## Problem
The `google-services.json` file is missing OAuth client configuration, which is required for Google Sign-In.

## Solution

### Step 1: Get SHA-1 Fingerprint

Run this command:
```bash
cd android
./gradlew signingReport
```

Or on Windows:
```bash
cd android
gradlew.bat signingReport
```

Look for the SHA-1 fingerprint in the output (under "debug" variant).

### Step 2: Add SHA-1 to Firebase Console

1. Go to: https://console.firebase.google.com/project/aivellum-3521b/settings/general
2. Scroll to "Your apps" section
3. Click on your Android app
4. Click "Add fingerprint"
5. Paste the SHA-1 fingerprint
6. Click "Save"

### Step 3: Download New google-services.json

1. In Firebase Console, click "Download google-services.json"
2. Replace the file at: `android/app/google-services.json`

### Step 4: Verify OAuth Client

Open the new `google-services.json` and verify it has `oauth_client` entries like:
```json
"oauth_client": [
  {
    "client_id": "874933875749-xxxxx.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

### Step 5: Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

## Quick Test (Without Full Setup)

For testing purposes, you can use Firebase Auth UI or skip Google Sign-In temporarily.

The app will work without sign-in for:
- Browsing prompts
- Watching ads to unlock
- Viewing content

Sign-in is only required for:
- Making purchases
- Syncing data across devices
