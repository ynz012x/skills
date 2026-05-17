# 限界上下文详情：{{bc_name}}

## 基本信息

| 属性 | 值 |
|------|-----|
| **名称** | {{bc_name}} |
| **域分类** | {{domain_type}} <!-- 核心域 / 支撑域 / 通用域 --> |
| **职责描述** | {{responsibility}} |
| **负责团队** | {{team}} |

---

## 统一语言（本上下文内）

| 术语 | 定义 | 注意事项 |
|------|------|---------|
| {{term_1}} | {{definition_1}} | {{note_1}} |

---

## 上下文边界

### 输入（被调用/接收事件）

| 来源 | 方式 | 数据 |
|------|------|------|
| {{source_bc}} | {{integration_type}} | {{data_desc}} |

### 输出（调用外部/发布事件）

| 目标 | 方式 | 数据 |
|------|------|------|
| {{target_bc}} | {{integration_type}} | {{data_desc}} |

---

## Context Map 关系

| 关联 BC | 关系模式 | 说明 |
|---------|---------|------|
| {{related_bc}} | {{relation_pattern}} | {{relation_desc}} |

<!-- 关系模式参考：
  - Shared Kernel（共享内核）
  - Customer-Supplier（客户-供应商）
  - Conformist（跟随者）
  - Anti-Corruption Layer（防腐层）
  - Open Host Service（开放主机服务）
  - Published Language（已发布语言）
  - Separate Ways（各行其道）
-->

---

## 核心聚合

| 聚合根 | 包含实体 | 包含值对象 | 关键不变量 |
|--------|---------|-----------|-----------|
| {{aggregate_root}} | {{entities}} | {{value_objects}} | {{invariants}} |

---

## 领域事件

| 事件名 | 触发条件 | 携带数据 | 消费者 |
|--------|---------|---------|--------|
| {{event_name}} | {{trigger}} | {{payload}} | {{consumers}} |

---

## 复杂度评估

| 维度 | 评级 | 说明 |
|------|------|------|
| 业务规则复杂度 | {{complexity}} | {{desc}} |
| 数据模型复杂度 | {{complexity}} | {{desc}} |
| 集成复杂度 | {{complexity}} | {{desc}} |
| 变更频率 | {{frequency}} | {{desc}} |
