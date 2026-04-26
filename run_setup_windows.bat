@echo off
echo Student Academic Planner setup
echo.

flutter --version
IF %ERRORLEVEL% NEQ 0 (
  echo Flutter is not installed or not available in PATH.
  pause
  exit /b 1
)

echo.
echo Creating Android platform files if missing...
if not exist android (
  flutter create --platforms=android --project-name student_academic_planner .
)

echo.
echo Installing Flutter packages...
flutter pub get

echo.
echo Installing FlutterFire CLI...
dart pub global activate flutterfire_cli

echo.
echo Now connect Firebase. Follow the terminal questions.
flutterfire configure

echo.
echo Running app...
flutter run

pause
