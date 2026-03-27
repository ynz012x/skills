#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-merge"

# 清理旧目录
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# 初始化仓库
git init -b main
git config user.name "Test User"
git config user.email "test@example.com"

# 初始提交
mkdir -p src

cat > src/config.py << 'PYEOF'
"""配置文件。"""

DATABASE_URL = "sqlite:///db.sqlite3"
DEBUG = False
SECRET_KEY = "initial-secret"
PYEOF

git add -A
git commit -m "init: 初始化项目"

# 创建 feature 分支并修改 config.py
git checkout -b feature/update-config

cat > src/config.py << 'PYEOF'
"""配置文件。"""

DATABASE_URL = "postgresql://localhost/mydb"
DEBUG = False
SECRET_KEY = "feature-branch-secret"
LOG_LEVEL = "INFO"
PYEOF

git add -A
git commit -m "feat: 更新数据库配置为 PostgreSQL"

# 切回 main 并做不同的修改（制造冲突）
git checkout main

cat > src/config.py << 'PYEOF'
"""配置文件。"""

DATABASE_URL = "mysql://localhost/mydb"
DEBUG = True
SECRET_KEY = "main-branch-secret"
CACHE_TTL = 300
PYEOF

git add -A
git commit -m "feat: 更新数据库配置为 MySQL"

# 尝试合并，产生冲突
git merge feature/update-config || true

# 确认处于合并冲突状态
if [ ! -f ".git/MERGE_HEAD" ]; then
    echo "ERROR: MERGE_HEAD not found, conflict setup failed"
    exit 1
fi

# 手动解决冲突并 stage（但不 commit，保持 MERGE_HEAD）
cat > src/config.py << 'PYEOF'
"""配置文件。"""

DATABASE_URL = "postgresql://localhost/mydb"
DEBUG = True
SECRET_KEY = "merged-secret"
LOG_LEVEL = "INFO"
CACHE_TTL = 300
PYEOF

git add src/config.py

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== MERGE_HEAD exists ==="
ls -la .git/MERGE_HEAD
echo "=== Git status ==="
git status
echo "=== Staged files ==="
git diff --cached --name-status
