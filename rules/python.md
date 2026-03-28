---
paths:
  - "**/*.py"
---

# Python 编码规范

## 强制使用绝对导入，禁止相对导入

错误：`from .utils import helper`
正确：`from mypackage.utils import helper`

所有导入必须从包根路径开始，禁止使用 `.` 或 `..` 相对路径。

## `__init__.py` 仅保留文档字符串

错误：
```python
from .foo import Foo
__all__ = ["Foo"]
```

正确：
```python
"""模块说明文档"""
```

`__init__.py` 不包含任何 import 语句或 `__all__` 定义。例外：根模块可保留 `__version__` 等元信息。

## 禁止硬编码绝对路径

错误：`data_file = "/home/user/project/data.csv"`

正确：
```python
from pathlib import Path
data_file = Path(__file__).parent / "data" / "data.csv"
# 或使用环境变量
data_dir = Path(os.getenv("PROJECT_DATA_DIR", "./data"))
```

## 可枚举常量使用 Enum，禁止魔法值

错误：`if status == "pending":`

正确：
```python
from enum import Enum

class OrderStatus(str, Enum):
    PENDING = "pending"
    COMPLETED = "completed"

if status == OrderStatus.PENDING:
```

固定选项集合（状态、类型、模式）必须定义为 Enum，成员使用 `UPPER_CASE` 命名。
