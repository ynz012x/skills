# 聚合设计：{{aggregate_name}}

## 基本信息

| 属性 | 值 |
|------|-----|
| **聚合根** | {{aggregate_root_class}} |
| **所属 BC** | {{bounded_context}} |
| **事务边界** | {{transaction_scope}} |

---

## 聚合结构

```mermaid
classDiagram
  class {{AggregateRoot}} {
    <<Aggregate Root>>
    +{{id_type}} id
    {{fields}}
    +{{method_1}}()
    +{{method_2}}()
  }

  class {{Entity1}} {
    <<Entity>>
    +{{id_type}} id
    {{entity_fields}}
  }

  class {{ValueObject1}} {
    <<Value Object>>
    {{vo_fields}}
    +equals(other): bool
  }

  {{AggregateRoot}} *-- {{Entity1}} : contains
  {{AggregateRoot}} *-- {{ValueObject1}} : contains
```

---

## Vernon 四规则验证

### 规则 1：在事务边界内保护业务不变量

| 不变量 | 描述 | 验证位置 |
|--------|------|---------|
| {{invariant_1}} | {{desc}} | {{method}} |

### 规则 2：聚合尽量小

- 包含实体数量：{{entity_count}}
- 包含值对象数量：{{vo_count}}
- 预估内存大小：{{memory_estimate}}
- 是否可以进一步拆分：{{can_split}} <!-- 说明理由 -->

### 规则 3：通过唯一标识引用其他聚合

| 被引用聚合 | 引用方式 | 说明 |
|-----------|---------|------|
| {{ref_aggregate}} | ID 引用 | {{reason}} |

### 规则 4：使用最终一致性跨聚合边界

| 跨聚合操作 | 一致性方式 | 补偿策略 |
|-----------|-----------|---------|
| {{cross_operation}} | {{consistency_type}} | {{compensation}} |

---

## 领域事件

| 事件名 | 触发时机 | Payload |
|--------|---------|---------|
| {{event_name}} | {{trigger}} | {{payload_fields}} |

---

## Repository 接口

```python
class {{AggregateRoot}}Repository(Protocol):
    """{{aggregate_name}} 仓储接口"""

    def find_by_id(self, id: {{id_type}}) -> Optional[{{AggregateRoot}}]:
        ...

    def save(self, aggregate: {{AggregateRoot}}) -> None:
        ...

    def delete(self, id: {{id_type}}) -> None:
        ...

    # 查询方法（根据业务需要）
    {{custom_queries}}
```

---

## 创建规则

| 条件 | 说明 |
|------|------|
| 前置条件 | {{preconditions}} |
| 创建方式 | {{creation_method}} <!-- 构造函数 / Factory / Builder --> |
| 初始状态 | {{initial_state}} |

---

## 生命周期

```
{{lifecycle_states}}
<!-- 例如：
Created → Active → Suspended → Closed
                ↘ Cancelled
-->
```
