@echo off
echo ===================================================
echo   Starting ScriptFlow on Chrome...
echo ===================================================

:: Check if .env file exists, if not create a dummy one
if not exist .env (
    echo [INFO] .env file not found. Creating a dummy .env file...
    echo GEMINI_API_KEY=> .env
    echo GEMINI_MODEL=gemini-3.5-flash>> .env
)

:: Run Flutter on Chrome
echo [INFO] Running: flutter run -d chrome
flutter run -d chrome
