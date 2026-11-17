@echo off
title App Saludo – Flutter en Emulador Android API 28
cd /d "%~dp0app_saludo"
echo ================================================================
echo  APP SALUDO – Flutter en Emulador Android 9 (API 28)
echo  Conecta con API 1 en: http://10.0.2.2:5238
echo  Recuerda iniciar primero:
echo    - 3_iniciar_EMULADOR_ANDROID_28.bat
echo    - 1_iniciar_API_SALUDO.bat
echo ================================================================
"C:\f\flutter\bin\flutter.bat" run -d android_lite_28
pause
