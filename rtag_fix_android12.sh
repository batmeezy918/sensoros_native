#!/data/data/com.termux/files/usr/bin/bash

echo "[RTAG] Android 12 Manifest & Gradle Auto-Patch"

# Go to project
cd ~/RTAG || exit

# ---- PATCH MANIFEST ----
MANIFEST="app/src/main/AndroidManifest.xml"

echo "[RTAG] Patching AndroidManifest.xml"

# Add android:exported if missing
grep -q 'android:exported' "$MANIFEST" || \
sed -i 's/<activity android:name=".MainActivity">/<activity android:name=".MainActivity" android:exported="true">/g' "$MANIFEST"

# Remove legacy package attribute (Google deprecated)
sed -i 's/package="com.sensoros"//g' "$MANIFEST"

# ---- PATCH GRADLE NAMESPACE ----
GRADLE="app/build.gradle"

echo "[RTAG] Patching Gradle namespace"

grep -q 'namespace "com.sensoros"' "$GRADLE" || \
sed -i '/android {/a\    namespace "com.sensoros"' "$GRADLE"

# ---- COMMIT + PUSH ----
echo "[RTAG] Committing and pushing fixes"

git add .
git commit -m "RTAG Android12 compliance auto-patch"
git push

echo "[RTAG] DONE. Cloud build will restart automatically."
