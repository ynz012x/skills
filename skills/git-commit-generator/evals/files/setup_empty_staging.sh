#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-empty"

# 清理旧目录
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# 初始化仓库
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 初始提交
mkdir -p src

cat > src/main.py << 'PYEOF'
"""主入口。"""


def main():
    print("Hello, World!")


if __name__ == "__main__":
    main()
PYEOF

cat > README.md << 'MDEOF'
# Test Project
MDEOF

git add -A
git commit -m "init: 初始化项目"

# 修改文件但不 git add（仅工作区有变更，暂存区为空）
cat > src/main.py << 'PYEOF'
"""主入口。"""

import sys


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else "World"
    print(f"Hello, {name}!")


if __name__ == "__main__":
    main()
PYEOF

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== Git status (should show unstaged changes only) ==="
git status
echo "=== Staged files (should be empty) ==="
git diff --cached --name-status
