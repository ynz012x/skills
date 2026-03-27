#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-breaking"

# 清理旧目录
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# 初始化仓库
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 初始提交：包含公共 API 函数
mkdir -p src/api/v1

cat > src/__init__.py << 'PYEOF'
"""项目根包。"""
PYEOF

cat > src/api/__init__.py << 'PYEOF'
"""API 包。"""
PYEOF

cat > src/api/v1/__init__.py << 'PYEOF'
"""API v1。"""
PYEOF

cat > src/api/v1/users.py << 'PYEOF'
"""用户 API 接口。"""

from dataclasses import dataclass


@dataclass
class User:
    id: int
    name: str
    email: str
    profile: str = ""


# 模拟数据库
_db: dict[int, User] = {}


def get_user(user_id: int) -> User | None:
    """获取用户信息。

    Args:
        user_id: 用户 ID

    Returns:
        用户对象，不存在时返回 None
    """
    return _db.get(user_id)


def create_user(name: str, email: str) -> User:
    """创建新用户。

    Args:
        name: 用户名
        email: 邮箱

    Returns:
        新创建的用户对象
    """
    user_id = max(_db.keys(), default=0) + 1
    user = User(id=user_id, name=name, email=email)
    _db[user_id] = user
    return user


def delete_user(user_id: int) -> bool:
    """删除用户。

    Args:
        user_id: 用户 ID

    Returns:
        是否成功删除
    """
    if user_id in _db:
        del _db[user_id]
        return True
    return False
PYEOF

git add -A
git commit -m "feat(api): 添加用户 API v1 接口"

# 破坏性变更：删除 delete_user，修改 get_user 签名
cat > src/api/v1/users.py << 'PYEOF'
"""用户 API 接口（v2 重构）。"""

from dataclasses import dataclass, field


@dataclass
class UserProfile:
    bio: str = ""
    avatar_url: str = ""
    settings: dict = field(default_factory=dict)


@dataclass
class User:
    id: str
    name: str
    email: str
    profile: UserProfile = field(default_factory=UserProfile)


# 模拟数据库
_db: dict[str, User] = {}


def get_user(user_id: str, include_profile: bool = False) -> User | None:
    """获取用户信息。

    Args:
        user_id: 用户 ID（改为字符串类型）
        include_profile: 是否包含用户详情

    Returns:
        用户对象，不存在时返回 None
    """
    user = _db.get(user_id)
    if user and not include_profile:
        # 返回不含 profile 的浅拷贝
        return User(id=user.id, name=user.name, email=user.email)
    return user


def create_user(name: str, email: str) -> User:
    """创建新用户。

    Args:
        name: 用户名
        email: 邮箱

    Returns:
        新创建的用户对象
    """
    user_id = str(max((int(k) for k in _db.keys()), default=0) + 1)
    user = User(id=user_id, name=name, email=email)
    _db[user_id] = user
    return user


# delete_user 已移除 — 用户删除改为软删除，通过 update_user 设置 status
PYEOF

# 暂存破坏性变更
git add src/api/v1/users.py

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== Staged files ==="
git diff --cached --name-status
echo "=== Diff stat ==="
git diff --cached --stat
