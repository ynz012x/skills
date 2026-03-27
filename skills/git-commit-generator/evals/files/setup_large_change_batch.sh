#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-large"

# 清理旧目录
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# 初始化仓库
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 初始提交：基础项目结构
mkdir -p src

cat > src/__init__.py << 'PYEOF'
"""项目根包。"""
PYEOF

cat > README.md << 'MDEOF'
# Component Library

UI 组件库项目。
MDEOF

git add -A
git commit -m "init: 初始化项目"

# 批量新增 25 个组件文件
mkdir -p src/components

for i in $(seq -w 1 25); do
    cat > "src/components/component_${i}.py" << PYEOF
"""组件 ${i}。"""


class Component${i}:
    """UI 组件 ${i} 的实现。"""

    def __init__(self, name: str = "component_${i}"):
        self.name = name
        self._visible = True
        self._enabled = True

    def render(self) -> str:
        """渲染组件。"""
        if not self._visible:
            return ""
        return f"<div class='{self.name}'>Component ${i}</div>"

    def show(self) -> None:
        self._visible = True

    def hide(self) -> None:
        self._visible = False

    def enable(self) -> None:
        self._enabled = True

    def disable(self) -> None:
        self._enabled = False
PYEOF
done

cat > src/components/__init__.py << 'PYEOF'
"""UI 组件集合。"""
PYEOF

# 暂存所有新增文件
git add src/components/

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== Staged files ==="
git diff --cached --name-status
echo "=== File count ==="
git diff --cached --name-only | wc -l
echo "=== Diff stat ==="
git diff --cached --stat
