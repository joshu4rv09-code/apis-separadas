@echo off
title App Doble – Flutter en Emulador Android API 28
cd /d "%~dp0app_doble"
echo ================================================================
echo  APP DOBLE – Flutter en Emulador Android 9 (API 28)
echo  Conecta con API 2 en: http://10.0.2.2:5238
echo  Recuerda iniciar primero:
echo    - 3_iniciar_EMULADOR_ANDROID_28.bat
echo    - 2_iniciar_API_DOBLE.bat
echo ================================================================
"C:\f\flutter\bin\flutter.bat" run -d android_lite_28
pause
