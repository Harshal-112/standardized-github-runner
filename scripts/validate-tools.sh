
#!/usr/bin/env bash

set -Eeuo pipefail

# Exact versions for the Ubuntu 24.04 x86_64 runner baseline.
EXPECTED_NODE="${EXPECTED_NODE:-22.23.5}"
EXPECTED_NPM="${EXPECTED_NPM:-10.9.9}"
EXPECTED_PYTHON="${EXPECTED_PYTHON:-3.12.3}"
EXPECTED_PIP="${EXPECTED_PIP:-24.0}"
EXPECTED_VAULT="${EXPECTED_VAULT:-2.2.2}"

declare -A EXPECTED_PACKAGES=(
  [git]="1:2.43.0-1ubuntu7.4"
  [curl]="8.5.0-2ubuntu10.16"
  [jq]="1.7.1-3ubuntu0.24.04.2"
  [tar]="1.35+dfsg-3ubuntu0.4"
  [zip]="3.0-13ubuntu0.2"
  [unzip]="6.0-28ubuntu4.1"
  [make]="4.3-4.1build2"
  [python3.12]="3.12.3-1ubuntu0.17"
  [python3.12-venv]="3.12.3-1ubuntu0.17"
  [python3-pip]="24.0+dfsg-1ubuntu1.3"
  [gh]="2.45.0-1ubuntu0.3"
)

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo "[PASS] $1"
  ((PASS_COUNT+=1))
}

fail() {
  echo "[FAIL] $1" >&2
  ((FAIL_COUNT+=1))
}

check_command() {
  local tool="$1"

  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool is installed"
  else
    fail "$tool is missing"
  fi
}

check_package_version() {
  local package="$1"
  local expected="$2"
  local actual

  if ! dpkg-query -W -f='${Version}' "$package" >/dev/null 2>&1; then
    fail "$package is not installed"
    return
  fi

  actual=$(dpkg-query -W -f='${Version}' "$package")

  if [[ "$actual" == "$expected" ]]; then
    pass "$package version $actual"
  else
    fail "$package expected $expected, found $actual"
  fi
}

check_exact_version() {
  local tool="$1"
  local expected="$2"
  shift 2
  local actual

  if ! command -v "$tool" >/dev/null 2>&1; then
    fail "$tool is missing"
    return
  fi

  if ! actual=$("$@" 2>&1); then
    fail "$tool could not report its version: $actual"
    return
  fi

  if [[ "$actual" == "$expected" ]]; then
    pass "$tool version $actual"
  else
    fail "$tool expected $expected, found $actual"
  fi
}

echo "=========================================="
echo " Standardized Runner Environment Check"
echo "=========================================="

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo ""
echo "===== APT PACKAGE VERSION CHECKS ====="

for package in "${!EXPECTED_PACKAGES[@]}"; do
  check_package_version "$package" "${EXPECTED_PACKAGES[$package]}"
done

echo ""
echo "===== NODE.JS AND NPM ====="

check_exact_version node "$EXPECTED_NODE" node -p "process.versions.node"
check_exact_version npm "$EXPECTED_NPM" npm --version

if node -e "const x = {status: 'ok'}; if (x.status !== 'ok') process.exit(1)"; then
  pass "Node.js functional test"
else
  fail "Node.js functional test"
fi

echo ""
echo "===== PYTHON, PIP AND VENV ====="

check_exact_version python3.12 "$EXPECTED_PYTHON" python3.12 -c \
  "import platform; print(platform.python_version())"

if python3.12 -m pip --version >/dev/null 2>&1; then
  ACTUAL_PIP=$(python3.12 -m pip --version | awk '{print $2}')
  if [[ "$ACTUAL_PIP" == "$EXPECTED_PIP" ]]; then
    pass "pip version $ACTUAL_PIP"
  else
    fail "pip expected $EXPECTED_PIP, found $ACTUAL_PIP"
  fi
else
  fail "Python pip is unavailable"
fi

if python3.12 -m venv "$TEMP_DIR/test-venv"; then
  pass "Python venv creation"
else
  fail "Python venv creation"
fi

if python3.12 -c "import json; assert json.loads('{\"status\":\"ok\"}')['status'] == 'ok'"; then
  pass "Python JSON functional test"
else
  fail "Python JSON functional test"
fi

echo ""
echo "===== GIT ====="

if git init -q "$TEMP_DIR/git-test" &&
   cd "$TEMP_DIR/git-test" &&
   git config user.name "Runner Test" &&
   git config user.email "runner-test@example.com" &&
   echo "test" > test.txt &&
   git add test.txt &&
   git commit -qm "Test commit" &&
   git log -1 --oneline >/dev/null; then
  pass "Git repository and commit test"
else
  fail "Git functional test"
fi

echo ""
echo "===== CURL ====="

if curl --version >/dev/null 2>&1; then
  pass "curl executable test"
else
  fail "curl executable test"
fi

echo ""
echo "===== JQ ====="

if printf '{"status":"ok"}' | jq -e '.status == "ok"' >/dev/null; then
  pass "jq JSON parsing test"
else
  fail "jq JSON parsing test"
fi

echo ""
echo "===== ARCHIVE TOOLS ====="

if tar -czf "$TEMP_DIR/test.tar.gz" -C "$TEMP_DIR" git-test &&
   tar -tzf "$TEMP_DIR/test.tar.gz" >/dev/null; then
  pass "tar archive test"
else
  fail "tar archive test"
fi

if zip -qr "$TEMP_DIR/test.zip" "$TEMP_DIR/git-test" &&
   unzip -t "$TEMP_DIR/test.zip" >/dev/null; then
  pass "zip and unzip archive test"
else
  fail "zip/unzip archive test"
fi

echo ""
echo "===== GNU MAKE ====="

printf 'check:\n\t@echo make-ok\n' > "$TEMP_DIR/Makefile"

if make -s -C "$TEMP_DIR" check | grep -qx "make-ok"; then
  pass "make execution test"
else
  fail "make execution test"
fi

echo ""
echo "===== HASHICORP VAULT ====="

if command -v vault >/dev/null 2>&1; then
  ACTUAL_VAULT=$(vault version 2>&1 | awk 'NR==1 {print $2}' | sed 's/^v//')

  if [[ "$ACTUAL_VAULT" == "$EXPECTED_VAULT" ]]; then
    pass "Vault version $ACTUAL_VAULT"
  else
    fail "Vault expected $EXPECTED_VAULT, found $ACTUAL_VAULT"
  fi
else
  fail "Vault is missing"
fi

echo ""
echo "===== GITHUB CLI ====="

if gh --version >/dev/null 2>&1; then
  ACTUAL_GH=$(gh --version | awk 'NR==1 {print $3}')

  if [[ "$ACTUAL_GH" == "2.45.0" ]]; then
    pass "GitHub CLI version $ACTUAL_GH"
  else
    fail "GitHub CLI expected 2.45.0, found $ACTUAL_GH"
  fi
else
  fail "GitHub CLI is missing"
fi

echo ""
echo "=========================================="
echo " Validation Summary"
echo "=========================================="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"

if (( FAIL_COUNT > 0 )); then
  echo "RESULT: FAILED"
  exit 1
fi

echo "RESULT: ALL CHECKS PASSED"
