@echo off
title App Saludo – Flutter en Chrome (puerto 8081)
cd /d "%~dp0app_saludo"
echo ================================================================
echo  APP SALUDO – Flutter en Google Chrome
echo  Conecta con API 1 en: http://localhost:5238
echo  Recuerda iniciar primero: 1_iniciar_API_SALUDO.bat
echo ================================================================
"C:\f\flutter\bin\flutter.bat" run -d chrome --web-port 8081
pause
