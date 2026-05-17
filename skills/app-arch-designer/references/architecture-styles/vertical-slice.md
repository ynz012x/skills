# Vertical Slice Architecture（垂直切片架构）

## 概述

Jimmy Bogard 提倡的架构模式，核心思想是**按功能（Feature）而非技术层次组织代码**。每个功能切片（Slice）包含从请求到响应的完整实现，切片之间最小化耦合。

## 核心概念

### 水平分层 vs 垂直切片

```
水平分层（传统）：           垂直切片：
┌─────────────────────┐      ┌──────┐ ┌──────┐ ┌──────┐
│ Controllers         │      │Create│ │Query │ │Update│
├─────────────────────┤      │Order │ │Order │ │Order │
│ Services            │      │      │ │      │ │      │
├─────────────────────┤      │ API  │ │ API  │ │ API  │
│ Repositories        │      │Logic │ │Logic │ │Logic │
├─────────────────────┤      │ Data │ │ Data │ │ Data │
│ Database            │      │      │ │      │ │      │
└─────────────────────┘      └──────┘ └──────┘ └──────┘
```

**关键区别**：
- 水平分层：修改一个功能需要跨越多个层，改动分散
- 垂直切片：修改一个功能只需要改一个切片，改动内聚

### 切片（Slice）的定义

一个切片 = 一个完整的用户请求处理路径，包含：
- 请求模型（Request/Command/Query）
- 处理逻辑（Handler）
- 响应模型（Response）
- 数据访问（可直接访问 DB，无需 Repository 抽象）
- 验证逻辑（Validator）

## 与 CQRS 结合

垂直切片天然与 CQRS（命令查询职责分离）互补：

| CQRS 侧 | 切片特征 | 典型实现 |
|----------|---------|---------|
| Command（写） | 业务逻辑丰富、可能触发事件 | 包含领域模型、验证、事件发布 |
| Query（读） | 直接查询优化、可绕过领域模型 | 可直接 SQL/视图，无需 Repository |

```
features/
├── orders/
│   ├── commands/
│   │   ├── create_order.py    # Command + Handler + Validator
│   │   └── cancel_order.py
│   └── queries/
│       ├── get_order.py       # Query + Handler（可直接 SQL）
│       └── list_orders.py
```

## 典型目录结构

### Feature Folder 组织

```
src/
├── features/                    # 按功能组织
│   ├── orders/
│   │   ├── create_order/
│   │   │   ├── handler.py      # 业务逻辑
│   │   │   ├── request.py      # 请求模型
│   │   │   ├── response.py     # 响应模型
│   │   │   ├── validator.py    # 验证规则
│   │   │   └── endpoint.py     # API 端点注册
│   │   ├── get_order/
│   │   │   ├── handler.py
│   │   │   ├── request.py
│   │   │   └── endpoint.py
│   │   └── domain/             # 该功能域的共享领域模型
│   │       ├── order.py
│   │       └── order_item.py
│   ├── payments/
│   │   ├── process_payment/
│   │   │   └── ...
│   │   └── domain/
│   │       └── payment.py
│   └── shared/                 # 跨切片共享（尽量少）
│       ├── auth/
│       │   └── current_user.py
│       └── database/
│           └── session.py
├── infrastructure/             # 基础设施配置
│   ├── database.py
│   └── message_bus.py
└── main.py                     # 应用入口
```

### 与 DDD 结合的 Feature Folder

```
src/
├── bounded_contexts/            # 按限界上下文分组
│   ├── ordering/
│   │   ├── features/
│   │   │   ├── place_order/
│   │   │   │   ├── command.py
│   │   │   │   ├── handler.py
│   │   │   │   └── endpoint.py
│   │   │   └── get_order_status/
│   │   │       ├── query.py
│   │   │       ├── handler.py
│   │   │       └── endpoint.py
│   │   ├── domain/
│   │   │   ├── order_aggregate.py
│   │   │   ├── order_events.py
│   │   │   └── order_repository.py  # 接口
│   │   └── infrastructure/
│   │       └── postgres_order_repo.py
│   └── shipping/
│       ├── features/
│       │   └── ...
│       └── domain/
│           └── ...
└── shared_kernel/              # 共享内核
    ├── value_objects.py
    └── domain_event_bus.py
```

## 切片间通信

切片之间**不直接调用**，通过以下方式协作：

| 方式 | 适用场景 | 耦合度 |
|------|---------|--------|
| 领域事件（Domain Event） | 写操作触发后续流程 | 低 |
| 进程内消息总线 | 同步编排多个 Handler | 中 |
| 共享领域模型 | 同一 BC 内的切片 | 中 |
| API 调用 | 跨 BC 通信 | 低 |

## 设计原则

1. **切片独立性**：每个切片可独立修改、测试、部署（在微服务中）
2. **最小共享**：`shared/` 目录只放真正跨切片的内容（认证、DB 连接）
3. **允许重复**：两个切片中相似的代码，宁可重复也不要过早抽象
4. **渐进抽象**：当 3+ 个切片出现相同模式时，再提取为共享组件
5. **测试简单**：每个切片可独立单测，不需要大量 mock

## 适用场景

**推荐使用**：
- 功能模块独立性高、修改频率不同
- 团队按功能（Feature Team）划分
- 需要快速迭代某个功能而不影响其他部分
- 中大型应用中不同功能复杂度差异大
- 未来可能拆分为微服务的单体应用

**谨慎使用**：
- 功能之间共享逻辑非常多
- 需要严格的分层约束（合规要求）
- 团队不熟悉 CQRS/Mediator 模式
- 极小型应用（3-5 个功能，切片开销不划算）

## 与其他架构的对比

| 维度 | Vertical Slice | Clean/Hexagonal | 传统分层 |
|------|---------------|-----------------|---------|
| 组织方式 | 按功能 | 按职责层 | 按技术层 |
| 修改影响范围 | 单个切片内 | 跨多层 | 跨多层 |
| 代码导航 | 找功能名 | 找层名+功能名 | 找层名+功能名 |
| 共享抽象 | 最少 | 较多（Port/Gateway） | 最多（Service/Repo） |
| 新功能添加 | 新建切片目录 | 每层添加对应文件 | 每层添加对应文件 |
| 适合演进为 | 微服务 | 模块化单体 | 不易拆分 |

## 演进策略

垂直切片架构是从单体到微服务的理想中间态：

```
单体（分层） → 模块化单体（垂直切片） → 微服务（切片独立部署）
```

每个切片天然对应一个潜在的微服务边界，当某个切片的负载或变更频率显著高于其他时，可以将其独立部署。
