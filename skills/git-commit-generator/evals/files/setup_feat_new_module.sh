#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/tmp/test-repo-feat"

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
# My Python Project

一个示例 Python 项目。
MDEOF

git add -A
git commit -m "init: 初始化项目结构"

# 新增认证模块（3 个新文件）
mkdir -p src/auth

cat > src/auth/__init__.py << 'PYEOF'
"""认证模块，提供 JWT 认证和中间件支持。"""

from .jwt_handler import JWTHandler
from .middleware import AuthMiddleware

__all__ = ["JWTHandler", "AuthMiddleware"]
PYEOF

cat > src/auth/jwt_handler.py << 'PYEOF'
"""JWT 令牌处理器。"""

import hashlib
import hmac
import json
import time
from dataclasses import dataclass


@dataclass
class TokenPayload:
    user_id: str
    exp: float
    iat: float


class JWTHandler:
    """JWT 令牌的生成与验证。"""

    def __init__(self, secret: str, expiry_seconds: int = 3600):
        self._secret = secret
        self._expiry = expiry_seconds

    def create_token(self, user_id: str) -> str:
        now = time.time()
        payload = {"user_id": user_id, "exp": now + self._expiry, "iat": now}
        payload_bytes = json.dumps(payload, separators=(",", ":")).encode()
        signature = hmac.new(
            self._secret.encode(), payload_bytes, hashlib.sha256
        ).hexdigest()
        return f"{payload_bytes.hex()}.{signature}"

    def verify_token(self, token: str) -> TokenPayload | None:
        try:
            payload_hex, signature = token.split(".")
            payload_bytes = bytes.fromhex(payload_hex)
            expected_sig = hmac.new(
                self._secret.encode(), payload_bytes, hashlib.sha256
            ).hexdigest()
            if not hmac.compare_digest(signature, expected_sig):
                return None
            data = json.loads(payload_bytes)
            if data["exp"] < time.time():
                return None
            return TokenPayload(**data)
        except (ValueError, KeyError):
            return None
PYEOF

cat > src/auth/middleware.py << 'PYEOF'
"""认证中间件。"""

from typing import Any, Callable

from .jwt_handler import JWTHandler


class AuthMiddleware:
    """HTTP 请求认证中间件。"""

    def __init__(self, jwt_handler: JWTHandler):
        self._jwt = jwt_handler

    def __call__(self, handler: Callable[..., Any]) -> Callable[..., Any]:
        def wrapper(request: Any) -> Any:
            auth_header = getattr(request, "headers", {}).get("Authorization", "")
            if not auth_header.startswith("Bearer "):
                raise PermissionError("缺少认证令牌")
            token = auth_header[7:]
            payload = self._jwt.verify_token(token)
            if payload is None:
                raise PermissionError("令牌无效或已过期")
            request.user_id = payload.user_id
            return handler(request)

        return wrapper
PYEOF

# 暂存新文件
git add src/auth/

echo "=== Setup complete ==="
echo "Repo: $REPO_DIR"
echo "=== Staged files ==="
git diff --cached --name-status
echo "=== Diff stat ==="
git diff --cached --stat
