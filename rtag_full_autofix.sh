#!/bin/bash
set -e

echo "[RTAG] FULL AUTONOMOUS ANDROID PIPELINE FIX"

# ========== CONFIG ==========
APP_PKG="com.sensoros"
APP_NAME="SensorOS"
JAVA_VERSION=17
# ============================

# Ensure git identity
git config user.name "RTAG-Bot"
git config user.email "bot@rta.local"

# ----------------------------
# FIX AndroidManifest.xml
# ----------------------------
mkdir -p app/src/main

cat > app/src/main/AndroidManifest.xml <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:label="$APP_NAME"
        android:allowBackup="true"
        android:supportsRtl="true">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

# ----------------------------
# FIX settings.gradle
# ----------------------------
cat > settings.gradle <<EOF
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "$APP_NAME"
include(":app")
EOF

# ----------------------------
# FIX root build.gradle
# ----------------------------
cat > build.gradle <<EOF
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.2.2"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

# ----------------------------
# FIX app/build.gradle
# ----------------------------
mkdir -p app

cat > app/build.gradle <<EOF
plugins {
    id 'com.android.application'
}

android {
    namespace "$APP_PKG"
    compileSdk 34

    defaultConfig {
        applicationId "$APP_PKG"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            signingConfig signingConfigs.debug
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_$JAVA_VERSION
        targetCompatibility JavaVersion.VERSION_$JAVA_VERSION
    }
}

dependencies {}
EOF

# ----------------------------
# Create MainActivity
# ----------------------------
mkdir -p app/src/main/java/com/sensoros

cat > app/src/main/java/com/sensoros/MainActivity.java <<EOF
package com.sensoros;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        TextView tv = new TextView(this);
        tv.setText("SensorOS RTAG Golden Build");
        setContentView(tv);
    }
}
EOF

# ----------------------------
# FIX GitHub Actions CI
# ----------------------------
mkdir -p .github/workflows

cat > .github/workflows/build.yml <<EOF
name: SensorOS Cloud Build

on:
  push:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: $JAVA_VERSION

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Build APK
        run: |
          chmod +x gradlew || true
          ./gradlew assembleRelease || gradle assembleRelease

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: SensorOS-APK
          path: app/build/outputs/apk/release/*.apk
EOF

# ----------------------------
# Commit & Push
# ----------------------------
git add .
git commit -m "RTAG FULL AUTO FIX Android pipeline" || true
git push

echo "==============================================="
echo "[RTAG] COMPLETE."
echo "GitHub Actions will auto-build APK."
echo "Run: gh run list"
echo "Then: gh run download --name SensorOS-APK"
echo "==============================================="
