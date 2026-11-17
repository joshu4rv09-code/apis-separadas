@echo off
cd /d "%~dp0api_saludo"
echo ================================================================
echo  CONSULTA SQLite: Tabla Saludos
echo ================================================================
dotnet run -- query "SELECT id_saludo, nombre, mensaje_saludo, fecha_creacion FROM Saludos ORDER BY id_saludo DESC"
echo.
echo ================================================================
echo  CONSULTA SQLite: Tabla CalculosDoble
echo ================================================================
cd /d "%~dp0api_doble"
dotnet run -- query "SELECT id_calculo, numero_entrada, resultado_doble, fecha_creacion FROM CalculosDoble ORDER BY id_calculo DESC"
echo.
echo ================================================================
echo  CONSULTA SQLite: Tabla Alarma (del Examen)
echo ================================================================
cd /d "%~dp0api_saludo"
dotnet run -- query "SELECT id_alarma, hora, periodicidad, estado, fecha_creacion FROM Alarma ORDER BY id_alarma ASC"
echo.
pause
