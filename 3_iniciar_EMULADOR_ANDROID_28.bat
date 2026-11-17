@echo off
title Emulador Android 9 (API 28)
echo ================================================================
echo  Iniciando Emulador Android 9 Lite – API 28
echo  AVD: android_lite_28
echo ================================================================
"C:\Users\romev\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd android_lite_28 -gpu swiftshader_indirect
pause
