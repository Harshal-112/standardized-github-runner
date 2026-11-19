
#!/usr/bin/env bash

set -euo pipefail

EXPECTED_NODE_MAJOR="${EXPECTED_NODE_MAJOR:-22}"
EXPECTED_PYTHON_MINOR="${EXPECTED_PYTHON_MINOR:-3.12}"
EXPECTED_VAULT_VERSION="${EXPECTED_VAULT_VERSION:-2.2.2}"

echo "=================================="
echo " Runner Environment Validation"
echo "=================================="

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 1. Git functional test
echo ""
echo "[TEST] Git"

git --version

cd "$TEMP_DIR"
git init -q
git config user.name "Runner Test"
git config user.email "runner-test@example.com"

echo "Test file" > test.txt
git add test.txt
git commit -qm "Test commit"

git log -1 --oneline
echo "[PASS] Git functional test"

# 2. jq functional test
echo ""
echo "[TEST] jq"

jq --version

JSON='{"runner":"standardized","status":"ok"}'
STATUS=$(echo "$JSON" | jq -r '.status')

test "$STATUS" = "ok"
echo "[PASS] jq functional test"

# 3. Node.js version + functional test
echo ""
echo "[TEST] Node.js"

node --version

NODE_VERSION=$(node -p "process.versions.node")
NODE_MAJOR="${NODE_VERSION%%.*}"

test "$NODE_MAJOR" = "$EXPECTED_NODE_MAJOR"

node -e "const data = {status: 'ok'}; if(data.status !== 'ok') process.exit(1); console.log('Node functional test passed')"

echo "[PASS] Node.js $EXPECTED_NODE_MAJOR"

# 4. Python version + functional test
echo ""
echo "[TEST] Python"

PYTHON_CMD="python3.12"

$PYTHON_CMD --version

PYTHON_VERSION=$($PYTHON_CMD -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

test "$PYTHON_VERSION" = "$EXPECTED_PYTHON_MINOR"

$PYTHON_CMD -c "import json; data=json.loads('{\"status\":\"ok\"}'); assert data['status']=='ok'; print('Python functional test passed')"

echo "[PASS] Python $EXPECTED_PYTHON_MINOR"

# 5. Vault version + functional test
echo ""
echo "[TEST] Vault"

vault version

VAULT_VERSION=$(vault version | awk '{print $2}' | sed 's/^v//')

test "$VAULT_VERSION" = "$EXPECTED_VAULT_VERSION"

echo "[PASS] Vault $VAULT_VERSION"

echo ""
echo "=================================="
echo " All tool tests passed"
echo "=================================="
