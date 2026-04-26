# Android Gradle Fixes

Use this if `flutter run` fails with Google Services conflict or desugaring errors.

## android/app/build.gradle.kts

The plugins block should be:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

Inside `android { ... }`:

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true
}
```

At the bottom of the file:

```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

## android/settings.gradle.kts

If Google Services is declared there, keep only one version:

```kotlin
id("com.google.gms.google-services") version "4.4.4" apply false
```

Do not also use the old classpath method with version 4.3.15.
