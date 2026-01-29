#!/data/data/com.termux/files/usr/bin/bash

echo "[RTAG] Installing YAML tools (Termux)..."
pkg update -y
pkg install -y python jq

# Install yq via pip (Termux-safe)
pip install --user yq

FILE=".github/workflows/build.yml"

if [ ! -f "$FILE" ]; then
  echo "[ERROR] $FILE not found"
  exit 1
fi

echo "[RTAG] Running YAML syntax validation..."
python -c "import yaml; yaml.safe_load(open('$FILE'))" || {
  echo "[FAIL] YAML SYNTAX INVALID"
  exit 2
}

echo "[RTAG] Structural checks..."
grep -q '^jobs:' "$FILE" || echo "[FAIL] Missing jobs:"
grep -q 'runs-on:' "$FILE" || echo "[FAIL] Missing runs-on"
grep -q 'steps:' "$FILE" || echo "[FAIL] Missing steps"
grep -q 'upload-artifact' "$FILE" || echo "[WARN] No artifact upload step"

echo "[RTAG] YAML CHECK COMPLETE"
