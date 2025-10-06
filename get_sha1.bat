@echo off
echo Getting SHA-1 Fingerprint for Google Sign-In...
echo.
cd android
call gradlew.bat signingReport
echo.
echo.
echo Look for "SHA1:" under "Variant: debug" above
echo Copy that SHA-1 and add it to Firebase Console
echo.
pause
