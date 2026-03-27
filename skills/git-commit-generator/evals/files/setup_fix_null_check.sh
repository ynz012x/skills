#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-fix"

# 清理旧目录
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# 初始化仓库
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 初始提交：包含有 bug 的用户服务
mkdir -p src/services

cat > src/__init__.py << 'PYEOF'
"""项目根包。"""
PYEOF

cat > src/services/__init__.py << 'PYEOF'
"""服务层。"""
PYEOF

cat > src/services/user_service.py << 'PYEOF'
"""用户服务模块。"""

from dataclasses import dataclass


@dataclass
class User:
    id: int
    name: str
    email: str


# 模拟数据库
_users_db: dict[int, User] = {
    1: User(id=1, name="张三", email="zhangsan@example.com"),
    2: User(id=2, name="李四", email="lisi@example.com"),
}


def get_user_by_id(user_id: int) -> User:
    """根据 ID 获取用户信息。"""
    user = _users_db.get(user_id)
    return user


def get_user_display_name(user_id: int) -> str:
    """获取用户的显示名称。"""
    user = get_user_by_id(user_id)
    # BUG: 当 user 为 None 时会抛出 AttributeError
    return f"{user.name} <{user.email}>"


def update_user_email(user_id: int, new_email: str) -> bool:
    """更新用户邮箱。"""
    user = get_user_by_id(user_id)
    # BUG: 同样缺少空值检查
    user.email = new_email
    return True
PYEOF

git add -A
git commit -m "feat(services): 添加用户服务模块"

# 修复 bug：添加空值检查
cat > src/services/user_service.py << 'PYEOF'
"""用户服务模块。"""

from dataclasses import dataclass


@dataclass
class User:
    id: int
    name: str
    email: str


# 模拟数据库
_users_db: dict[int, User] = {
    1: User(id=1, name="张三", email="zhangsan@example.com"),
    2: User(id=2, name="李四", email="lisi@example.com"),
}


def get_user_by_id(user_id: int) -> User | None:
    """根据 ID 获取用户信息。"""
    user = _users_db.get(user_id)
    return user


def get_user_display_name(user_id: int) -> str:
    """获取用户的显示名称。"""
    user = get_user_by_id(user_id)
    if user is None:
        raise ValueError(f"用户 {user_id} 不存在")
    return f"{user.name} <{user.email}>"


def update_user_email(user_id: int, new_email: str) -> bool:
    """更新用户邮箱。"""
    user = get_user_by_id(user_id)
    if user is None:
        raise ValueError(f"用户 {user_id} 不存在")
    user.email = new_email
    return True
PYEOF

# 暂存修复
git add src/services/user_service.py

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== Staged files ==="
git diff --cached --name-status
echo "=== Diff stat ==="
git diff --cached --stat
