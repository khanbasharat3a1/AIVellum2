@echo off
echo Creating Android Keystore for AIVELLUM...
echo.
echo This will create a keystore file for signing your Android app.
echo You will need to provide:
echo 1. Keystore password (remember this!)
echo 2. Key password (can be same as keystore password)
echo 3. Your name
echo 4. Organization name
echo 5. City/Location
echo 6. State/Province
echo 7. Country code (2 letters, e.g., US, IN, UK)
echo.
pause

keytool -genkey -v -keystore keystore\aivellum-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias aivellum-key

echo.
echo Keystore created successfully!
echo.
echo Now you need to create the key.properties file:
echo 1. Copy key.properties.template to key.properties in android folder
echo 2. Fill in your passwords in the key.properties file
echo.
pause