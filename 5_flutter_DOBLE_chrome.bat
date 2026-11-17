@echo off
title App Doble – Flutter en Chrome (puerto 8082)
cd /d "%~dp0app_doble"
echo ================================================================
echo  APP DOBLE – Flutter en Google Chrome
echo  Conecta con API 2 en: http://localhost:5238
echo  Recuerda iniciar primero: 2_iniciar_API_DOBLE.bat
echo ================================================================
"C:\f\flutter\bin\flutter.bat" run -d chrome --web-port 8082
pause
