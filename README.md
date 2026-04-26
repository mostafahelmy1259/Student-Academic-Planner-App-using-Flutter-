# Student Academic Planner - Professional V1

A clean Flutter + Firebase academic planner app for students. It includes authentication, subject management, task management, exam scheduling, reminders, statistics, and a modern Material 3 interface.

## Features

- Email/password register and login
- Private data for each Firebase user
- Subjects with custom colors and instructor names
- Tasks with deadline, priority, notes, completion status, and reminders
- Exams with date/time, location, notes, and reminders
- Dashboard with progress, pending tasks, overdue tasks, and upcoming exams
- Statistics page
- Friendly error messages
- Delete confirmation dialogs
- Better empty states and loading states

## Important sign-up fix

If sign-up creates the account but then shows an error, the usual cause is Firestore rules not allowing the app to create this document:

```text
users/{userId}
```

This project includes fixed rules in `firestore.rules`. You must publish them in Firebase Console:

```text
Firebase Console -> Firestore Database -> Rules -> paste firestore.rules -> Publish
```

If an account was already created during the error, do not sign up again with the same email. Either log in with that email/password or delete that user from Firebase Console -> Authentication -> Users.

## Required Firebase setup

1. Create a Firebase project named `Student Academic Planner`.
2. Add an Android app with package name:

```text
com.example.student_academic_planner
```

3. Enable Email/Password Authentication.
4. Create Firestore Database using Standard edition.
5. Publish the included `firestore.rules`.
6. Run FlutterFire configuration from the project folder:

```powershell
firebase login
flutterfire configure
```

Choose Android when asked for platforms.

## First-time setup on Windows

Open PowerShell inside the project folder:

```powershell
flutter create --platforms=android --project-name student_academic_planner .
flutter pub get
dart pub global activate flutterfire_cli
$env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
flutterfire configure
flutter run
```

## Android Gradle requirements

Because this app uses `flutter_local_notifications`, Android needs core library desugaring.

Open:

```text
android/app/build.gradle.kts
```

Inside `android { ... }`, make sure `compileOptions` contains:

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true
}
```

At the bottom of the same file, outside `android { ... }`, make sure this exists:

```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

Also, in `android/app/build.gradle.kts`, the plugins block should contain Google Services without a version:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

Do not put a Google Services version in the app-level file.

## Correct run order

After Firebase and Gradle are configured:

```powershell
flutter clean
flutter pub get
flutterfire configure
flutter run
```

## Troubleshooting

### `flutterfire` is not recognized

Run:

```powershell
dart pub global activate flutterfire_cli
$env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
flutterfire --version
```

### `email-already-in-use`

The account already exists in Firebase Authentication. Use Login, or delete the user from Firebase Console -> Authentication -> Users if you want to sign up again.

### Permission denied after sign-up

Publish `firestore.rules` again. The rules must allow `/users/{userId}` as well as `/tasks`, `/exams`, and `/subjects`.

### Maven/Gradle download timeout

Retry `flutter run`, use a mobile hotspot, or use VPN. The first Android build downloads many Gradle dependencies.
