@echo off
title API 1 - Saludo Personalizado (Puerto 5238)
cd /d "%~dp0api_saludo"

echo [1/3] Liberando puerto 5238 si esta ocupado...
for /f "tokens=5" %%p in ('netstat -aon 2^>nul ^| findstr ":5238.*LISTENING"') do (
    taskkill /PID %%p /F >nul 2>&1
)

echo ================================================================
echo  API 1 – SALUDO PERSONALIZADO (EJECUCION SEPARADA)
echo  Puerto : 5238
echo  Swagger: http://localhost:5238/swagger
echo  Visor  : http://localhost:5238/visor
echo  Android: http://10.0.2.2:5238
echo  BD     : alarmas.db del examen UTH (compartida)
echo ================================================================
timeout /t 2 /nobreak >nul
start "" http://localhost:5238/swagger
start "" http://localhost:5238/visor
dotnet run --urls http://0.0.0.0:5238
pause
