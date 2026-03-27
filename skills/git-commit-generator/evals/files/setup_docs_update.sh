#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-docs"

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

cat > README.md << 'MDEOF'
# My Python Project

一个示例 Python 项目。
MDEOF

cat > src/main.py << 'PYEOF'
"""主入口。"""


def main():
    print("Hello, World!")


if __name__ == "__main__":
    main()
PYEOF

git add -A
git commit -m "init: 初始化项目"

# 更新文档：修改 README 并新增 CONTRIBUTING.md
cat > README.md << 'MDEOF'
# My Python Project

一个示例 Python 项目。

## 安装

```bash
pip install -e .
```

## 快速开始

```python
from myproject import main
main()
```

## 贡献

请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解贡献指南。
MDEOF

cat > CONTRIBUTING.md << 'MDEOF'
# 贡献指南

感谢你有兴趣为本项目做出贡献！

## 开发环境

1. Fork 本仓库
2. 克隆到本地：`git clone <your-fork-url>`
3. 安装依赖：`pip install -e ".[dev]"`

## 提交规范

本项目使用 Conventional Commits 规范，提交消息请使用中文。

## Pull Request 流程

1. 创建功能分支
2. 编写代码和测试
3. 确保所有测试通过
4. 提交 Pull Request
MDEOF

# 暂存文档变更
git add README.md CONTRIBUTING.md

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== Staged files ==="
git diff --cached --name-status
echo "=== Diff stat ==="
git diff --cached --stat
