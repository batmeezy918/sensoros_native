#!/bin/bash

echo "[RTAG] Auto-patching Android manifest and Gradle..."

# Patch AndroidManifest.xml
MANIFEST=app/src/main/AndroidManifest.xml

grep -q android:exported "$MANIFEST" || \
sed -i 's/<activity/<activity android:exported="true"/' "$MANIFEST"

# Remove deprecated package attribute
sed -i '/package="/d' "$MANIFEST"

# Force namespace in app/build.gradle
APPGRADLE=app/build.gradle
grep -q "namespace" "$APPGRADLE" || \
sed -i 's/android {/android {\n    namespace "com.sensoros"/' "$APPGRADLE"

echo "[RTAG] Fix complete. Commit + push."
