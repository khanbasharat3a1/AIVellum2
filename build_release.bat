@echo off
echo Building AIVELLUM for Release...
echo.

echo Cleaning previous builds...
flutter clean
flutter pub get

echo.
echo Building App Bundle (for Play Store)...
flutter build appbundle --release

echo.
echo Building APK (for direct installation)...
flutter build apk --release

echo.
echo Build completed!
echo.
echo Files created:
echo - App Bundle: build\app\outputs\bundle\release\app-release.aab
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo.
pause