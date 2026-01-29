#!/data/data/com.termux/files/usr/bin/bash

echo "=== RTAG AUTOFIX AND CLOUD BUILD ==="

# Ensure repo
if [ ! -d .git ]; then
  echo "[ERROR] Run inside your Android repo folder"
  exit 1
fi

# ---------------------------
# FIX ANDROID MANIFEST
# ---------------------------
MANIFEST="app/src/main/AndroidManifest.xml"

echo "[RTAG] Fixing AndroidManifest..."

# Add android:exported if missing
grep -q 'android:exported' "$MANIFEST" || \
sed -i 's/<activity/<activity android:exported="true"/' "$MANIFEST"

# Remove deprecated package attribute
sed -i 's/package="[^"]*"//g' "$MANIFEST"

# ---------------------------
# FIX GRADLE NAMESPACE
# ---------------------------
APP_GRADLE="app/build.gradle"

if ! grep -q "namespace" "$APP_GRADLE"; then
  echo "[RTAG] Adding namespace..."
  sed -i '/android {/a\    namespace "com.sensoros"' "$APP_GRADLE"
fi

# ---------------------------
# YAML CHECK
# ---------------------------
echo "[RTAG] Installing Python YAML parser..."
pkg install -y python >/dev/null 2>&1
pip install --user pyyaml >/dev/null 2>&1

python -c "import yaml; yaml.safe_load(open('.github/workflows/build.yml'))" || {
  echo "[FAIL] YAML broken"
  exit 2
}

# ---------------------------
# GIT COMMIT & PUSH
# ---------------------------
echo "[RTAG] Committing fixes..."
git add .
git commit -m "RTAG auto patch Android pipeline" || true
git push

# ---------------------------
# TRIGGER BUILD STATUS
# ---------------------------
echo "[RTAG] GitHub Actions triggered."
echo "Check build:"
echo "gh run list"

