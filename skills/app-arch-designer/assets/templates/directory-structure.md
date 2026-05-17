# 项目目录结构：{{project_name}}

> 架构风格: {{architecture_style}} | 生成日期: {{date}}

## 目录总览

```
{{project_name}}/
{{directory_tree}}
```

## 层次/模块职责说明

| 目录 | 层次 | 职责 | 依赖方向 |
|------|------|------|---------|
| {{dir_1}} | {{layer}} | {{responsibility}} | {{depends_on}} |

---

## BC 到目录映射

| 限界上下文 | 对应目录 | 说明 |
|-----------|---------|------|
| {{bc_name}} | {{dir_path}} | {{desc}} |

---

## 关键文件说明

| 文件路径 | 用途 | 所属层 |
|---------|------|--------|
| {{file_path}} | {{purpose}} | {{layer}} |

---

## 依赖规则

### 允许的依赖方向

```
{{dependency_diagram}}
<!-- 例如：
adapters/ ──► application/ ──► domain/
    │                              ▲
    └──────────────────────────────┘
              (via interface)
-->
```

### 禁止的依赖

| 源 | 目标 | 原因 |
|----|------|------|
| domain/ | adapters/ | 领域层不依赖基础设施 |
| domain/ | application/ | 领域层不依赖应用层 |
| {{custom_rule}} | {{target}} | {{reason}} |

---

## 新功能添加指南

当需要添加新功能时，按以下步骤创建文件：

1. **领域层**：`{{domain_path}}/` — 定义实体、值对象、领域事件
2. **应用层**：`{{application_path}}/` — 编写 Use Case / Command Handler
3. **适配层**：`{{adapter_path}}/` — 添加 API 端点、Repository 实现
4. **测试**：`{{test_path}}/` — 对应层级的单测

---

## 模块通信方式

| 通信类型 | 适用场景 | 实现位置 |
|---------|---------|---------|
| 直接调用 | BC 内部、同层 | 方法调用 |
| 领域事件 | 跨聚合、跨 BC | {{event_bus_path}} |
| API 调用 | 跨服务 | {{api_client_path}} |

---

## 初始化脚本参考

```bash
# 创建目录结构
{{mkdir_commands}}
```
