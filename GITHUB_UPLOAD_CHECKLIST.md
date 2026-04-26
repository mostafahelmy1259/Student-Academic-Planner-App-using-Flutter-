# GitHub Upload Checklist

This folder is a clean GitHub-ready copy of the Flutter project.

Clean folder path:
C:\Users\m8325\Downloads\student_academic_planner_flutter_app\student_academic_planner_github_ready

Expected important files:
- lib/
- android/
- pubspec.yaml
- README.md
- firestore.rules
- docs/

Generated folders are ignored:
- build/
- .dart_tool/
- android/.gradle/
- android/local.properties

Run locally:
flutter pub get
flutter run

If packages are already downloaded and network is slow:
flutter run --no-pub

Firebase:
Publish Firestore rules from firestore.rules in Firebase Console.

Git upload commands:
git init
git add .
git commit -m Initial-commit-Student-Academic-Planner
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
