# mobile_app_y4 (rental_room_api)

A Flutter mobile app for rental room listings and management. This README explains how to set up, run, and troubleshoot common problems (including Gradle and Android Gradle Plugin issues).

## Table of contents
- Project overview
- Prerequisites
- Quick start
- Running on Android (emulator/device)
- Common issues & fixes
  - Gradle wrapper version mismatch
  - Android Gradle Plugin (AGP) version mismatch
  - Accepting Android licenses
- Project structure
- Contributing

## Project overview
This repository contains a Flutter application (Dart) implementing a rental room listing app. The app's source is under `lib/`. Platform-specific projects are under `android/`, `ios/`, `web/`, etc.

## Prerequisites
- Flutter SDK (recommended stable channel). See https://docs.flutter.dev/get-started/install
- Android SDK & Android Studio (for Android builds)
- An Android emulator or a physical device for testing
- Java JDK 11+ (as required by recent Android Gradle Plugin versions)

Verify Flutter is installed and working:

```powershell
flutter --version
flutter doctor
```

Fix any issues reported by `flutter doctor` before proceeding.

## Quick start
1. Install dependencies:

```powershell
cd D:\Mobile_App\mobile_app_y4
flutter pub get
```

2. Start an emulator or connect a device, then run:

```powershell
flutter run
```

3. To build an Android APK:

```powershell
flutter build apk --debug
```

If you see Gradle or AGP version errors (like "Minimum supported Gradle version is X" or dependency requires AGP >= Y), see the troubleshooting section below.

## Running on Android (common commands)
- Clean build artifacts:

```powershell
flutter clean
flutter pub get
```

- Run with verbose Gradle output (to debug build failures):

```powershell
flutter run -v
```

## Common issues & fixes
### Gradle wrapper version mismatch
Error example: "Minimum supported Gradle version is 8.11.1. Current version is 8.9. If using the gradle wrapper, try editing the distributionUrl in android/gradle/wrapper/gradle-wrapper.properties to gradle-8.11.1-all.zip"

How to fix (PowerShell):

```powershell
# Replace the distributionUrl in the gradle wrapper properties
(Get-Content android\gradle\wrapper\gradle-wrapper.properties) -replace 'distributionUrl=.*', 'distributionUrl=https\://services.gradle.org/distributions/gradle-8.11.1-all.zip' | Set-Content android\gradle\wrapper\gradle-wrapper.properties
```

After editing, run:

```powershell
cd android; .\gradlew wrapper --recreate; cd ..
flutter clean; flutter pub get; flutter run
```

Note: You can also open `android/gradle/wrapper/gradle-wrapper.properties` in an editor and update the `distributionUrl` line manually.

### Android Gradle Plugin (AGP) version mismatch
Error example: "Dependency 'androidx.activity:activity:1.11.0' requires Android Gradle plugin 8.9.1 or higher. This build currently uses Android Gradle plugin 8.5.0."

How to fix:
- Update the Android Gradle Plugin (AGP) version used by the project. Where to update depends on whether your project uses the Kotlin DSL or Groovy:
  - If your project has `android/build.gradle` (Groovy), update the classpath in the `buildscript` dependencies:

    classpath 'com.android.tools.build:gradle:8.9.1'

  - If your project uses the Kotlin DSL (`android/build.gradle.kts` or `android/settings.gradle.kts` with `plugins` block), update the plugin version in the `plugins` block or the `pluginManagement` resolution strategy to a compatible version, for example `8.9.1`.

Example for `build.gradle` (Groovy):

```groovy
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.9.1'
        // ... other classpath entries
    }
}
```

After updating AGP, make sure the Gradle wrapper distribution is compatible (see the Gradle wrapper section above). Then run:

```powershell
cd android; .\gradlew --version; cd ..
flutter clean; flutter pub get; flutter run
```

If you're unsure which file to edit, check `android/settings.gradle`, `android/settings.gradle.kts`, `android/build.gradle`, or `android/build.gradle.kts` for references to `com.android.tools.build:gradle` or a `plugins` block containing `id("com.android.application")`.

### Accept Android licenses
If the build fails due to missing Android licenses, run:

```powershell
flutter doctor --android-licenses
```

Follow the prompts to accept.

## Project structure (top-level)
- android/ — Android platform project (Gradle files live here)
- ios/ — iOS platform project
- lib/ — Dart source code (app logic, UI)
- assets/, images/ — application assets
- test/ — unit/widget tests

Important Dart entrypoint: `lib/main.dart`.

## Contributing
- Create a feature branch off `main`.
- Write tests for new functionality when appropriate.
- Keep code style consistent with the existing project.

## Where to get help
- Flutter docs: https://docs.flutter.dev
- Flutter GitHub discussions and issues
- If you continue to get Gradle/AGP errors, include the full error log when asking for help.

---

If you'd like, I can also:
- Update the Gradle wrapper and AGP versions in your project files automatically (I can create the changes and run a quick test build). 
- Or create a short script to apply the Gradle distributionUrl replacement for you.

Tell me which of those you'd like me to do next.
