#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-refactor"

# 清理旧目录
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# 初始化仓库
git init
git config user.name "Test User"
git config user.email "test@example.com"

# 初始提交：4 个模块中包含重复的验证逻辑
mkdir -p src/models src/services src/api src/utils

cat > src/__init__.py << 'PYEOF'
"""项目根包。"""
PYEOF

cat > src/models/__init__.py << 'PYEOF'
"""数据模型。"""
PYEOF

cat > src/models/user.py << 'PYEOF'
"""用户模型。"""

import re


def validate_email(email: str) -> bool:
    """验证邮箱格式。"""
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(pattern, email))


def validate_phone(phone: str) -> bool:
    """验证手机号格式。"""
    pattern = r"^1[3-9]\d{9}$"
    return bool(re.match(pattern, phone))


class User:
    def __init__(self, name: str, email: str, phone: str):
        if not validate_email(email):
            raise ValueError(f"无效的邮箱: {email}")
        if not validate_phone(phone):
            raise ValueError(f"无效的手机号: {phone}")
        self.name = name
        self.email = email
        self.phone = phone
PYEOF

cat > src/services/__init__.py << 'PYEOF'
"""服务层。"""
PYEOF

cat > src/services/auth.py << 'PYEOF'
"""认证服务。"""

import re


def validate_email(email: str) -> bool:
    """验证邮箱格式。"""
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(pattern, email))


def validate_password(password: str) -> bool:
    """验证密码强度。"""
    return len(password) >= 8 and bool(re.search(r"[A-Z]", password))


class AuthService:
    def register(self, email: str, password: str) -> dict:
        if not validate_email(email):
            raise ValueError(f"无效的邮箱: {email}")
        if not validate_password(password):
            raise ValueError("密码强度不足")
        return {"email": email, "status": "registered"}

    def login(self, email: str, password: str) -> dict:
        if not validate_email(email):
            raise ValueError(f"无效的邮箱: {email}")
        return {"email": email, "token": "mock-token"}
PYEOF

cat > src/api/__init__.py << 'PYEOF'
"""API 层。"""
PYEOF

cat > src/api/routes.py << 'PYEOF'
"""API 路由。"""

import re


def validate_email(email: str) -> bool:
    """验证邮箱格式。"""
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(pattern, email))


def validate_phone(phone: str) -> bool:
    """验证手机号格式。"""
    pattern = r"^1[3-9]\d{9}$"
    return bool(re.match(pattern, phone))


def handle_create_user(request: dict) -> dict:
    email = request.get("email", "")
    phone = request.get("phone", "")
    if not validate_email(email):
        return {"error": "无效的邮箱"}
    if not validate_phone(phone):
        return {"error": "无效的手机号"}
    return {"status": "created"}
PYEOF

cat > src/utils/__init__.py << 'PYEOF'
"""工具函数。"""
PYEOF

cat > src/utils/helpers.py << 'PYEOF'
"""通用工具函数。"""

import re


def validate_email(email: str) -> bool:
    """验证邮箱格式。"""
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(pattern, email))


def validate_phone(phone: str) -> bool:
    """验证手机号格式。"""
    pattern = r"^1[3-9]\d{9}$"
    return bool(re.match(pattern, phone))


def format_display_name(name: str, email: str) -> str:
    """格式化显示名称。"""
    if not validate_email(email):
        return name
    return f"{name} <{email}>"
PYEOF

git add -A
git commit -m "feat: 添加用户管理基础模块"

# 重构：消除重复的验证逻辑，统一使用 utils/validators.py

cat > src/utils/validators.py << 'PYEOF'
"""统一的数据验证工具。"""

import re

EMAIL_PATTERN = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
PHONE_PATTERN = re.compile(r"^1[3-9]\d{9}$")


def validate_email(email: str) -> bool:
    """验证邮箱格式。"""
    return bool(EMAIL_PATTERN.match(email))


def validate_phone(phone: str) -> bool:
    """验证手机号格式。"""
    return bool(PHONE_PATTERN.match(phone))


def validate_password(password: str) -> bool:
    """验证密码强度：至少 8 位且包含大写字母。"""
    return len(password) >= 8 and bool(re.search(r"[A-Z]", password))
PYEOF

cat > src/models/user.py << 'PYEOF'
"""用户模型。"""

from src.utils.validators import validate_email, validate_phone


class User:
    def __init__(self, name: str, email: str, phone: str):
        if not validate_email(email):
            raise ValueError(f"无效的邮箱: {email}")
        if not validate_phone(phone):
            raise ValueError(f"无效的手机号: {phone}")
        self.name = name
        self.email = email
        self.phone = phone
PYEOF

cat > src/services/auth.py << 'PYEOF'
"""认证服务。"""

from src.utils.validators import validate_email, validate_password


class AuthService:
    def register(self, email: str, password: str) -> dict:
        if not validate_email(email):
            raise ValueError(f"无效的邮箱: {email}")
        if not validate_password(password):
            raise ValueError("密码强度不足")
        return {"email": email, "status": "registered"}

    def login(self, email: str, password: str) -> dict:
        if not validate_email(email):
            raise ValueError(f"无效的邮箱: {email}")
        return {"email": email, "token": "mock-token"}
PYEOF

cat > src/api/routes.py << 'PYEOF'
"""API 路由。"""

from src.utils.validators import validate_email, validate_phone


def handle_create_user(request: dict) -> dict:
    email = request.get("email", "")
    phone = request.get("phone", "")
    if not validate_email(email):
        return {"error": "无效的邮箱"}
    if not validate_phone(phone):
        return {"error": "无效的手机号"}
    return {"status": "created"}
PYEOF

cat > src/utils/helpers.py << 'PYEOF'
"""通用工具函数。"""

from src.utils.validators import validate_email


def format_display_name(name: str, email: str) -> str:
    """格式化显示名称。"""
    if not validate_email(email):
        return name
    return f"{name} <{email}>"
PYEOF

# 暂存所有重构变更
git add -A

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== Staged files ==="
git diff --cached --name-status
echo "=== Diff stat ==="
git diff --cached --stat
