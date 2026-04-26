#!/usr/bin/env bash
set -e

echo "Student Academic Planner setup"
flutter --version
if [ ! -d "android" ]; then
  flutter create --platforms=android --project-name student_academic_planner .
fi
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
flutter run
