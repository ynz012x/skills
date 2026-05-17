# Hexagonal Architecture（六边形架构 / 端口与适配器）

## 概述

Alistair Cockburn 提出的架构模式，核心思想是**应用通过端口（Port）与外部世界交互，适配器（Adapter）负责技术实现**。应用核心与外部技术细节完全解耦。

## 核心概念

```
              ┌────────────────────────────┐
   Driving    │                            │   Driven
   Adapter ──►│ Port ──► Application ──► Port │──► Adapter
  (Primary)   │          Core             │   (Secondary)
              └────────────────────────────┘
```

### 端口（Port）

端口是应用核心定义的**接口**，描述应用需要什么或提供什么。

| 类型 | 方向 | 定义者 | 用途 |
|------|------|--------|------|
| **驱动端口（Primary / Driving）** | 外部 → 应用 | 应用核心 | 定义应用能做什么（Use Case 接口） |
| **被驱动端口（Secondary / Driven）** | 应用 → 外部 | 应用核心 | 定义应用需要什么外部能力（Repository、Gateway） |

### 适配器（Adapter）

适配器是端口的**具体实现**，负责技术协议转换。

| 类型 | 方向 | 实现者 | 示例 |
|------|------|--------|------|
| **驱动适配器（Primary Adapter）** | 调用应用 | 外部层 | REST Controller、CLI Handler、gRPC Service、消息消费者 |
| **被驱动适配器（Secondary Adapter）** | 被应用调用 | 外部层 | PostgreSQL Repository、Redis Cache、HTTP Client、SMTP Sender |

## 与 DDD 结合

六边形架构与 DDD 天然契合：

| DDD 概念 | 在六边形中的位置 |
|----------|-----------------|
| 聚合根 | Application Core 内部 |
| Repository 接口 | 被驱动端口（Secondary Port） |
| Repository 实现 | 被驱动适配器（Secondary Adapter） |
| Application Service | 驱动端口（Primary Port）的实现 |
| Domain Event 发布 | 通过被驱动端口抽象 |

## 依赖规则

```
适配器 ──依赖──► 端口（接口）◄──实现── 应用核心

外层依赖内层，内层不感知外层存在
```

关键点：
- 应用核心**只定义接口（端口）**，不依赖任何具体技术
- 适配器依赖端口接口，实现具体技术细节
- 通过依赖注入（DI）在运行时组装适配器到端口

## 典型目录结构

### Python（FastAPI + SQLAlchemy）

```
src/
├── application/              # 应用核心
│   ├── ports/
│   │   ├── inbound/          # 驱动端口（Use Case 接口）
│   │   │   ├── create_order.py
│   │   │   └── query_order.py
│   │   └── outbound/         # 被驱动端口（Repository/Gateway 接口）
│   │       ├── order_repository.py
│   │       └── payment_gateway.py
│   ├── domain/               # 领域模型
│   │   ├── order.py          # 聚合根
│   │   ├── order_item.py     # 实体
│   │   └── money.py          # 值对象
│   └── services/             # 用例实现
│       ├── create_order_service.py
│       └── query_order_service.py
├── adapters/
│   ├── inbound/              # 驱动适配器
│   │   ├── rest/
│   │   │   └── order_controller.py
│   │   └── grpc/
│   │       └── order_grpc_service.py
│   └── outbound/             # 被驱动适配器
│       ├── persistence/
│       │   └── sqlalchemy_order_repo.py
│       └── external/
│           └── stripe_payment_gateway.py
└── config/                   # 组装层（DI 容器）
    └── container.py
```

### Go

```
internal/
├── application/
│   ├── port/
│   │   ├── input.go          # 驱动端口接口
│   │   └── output.go         # 被驱动端口接口
│   ├── domain/
│   │   ├── order.go
│   │   └── events.go
│   └── service/
│       └── order_service.go
├── adapter/
│   ├── inbound/
│   │   ├── http/
│   │   │   └── handler.go
│   │   └── grpc/
│   │       └── server.go
│   └── outbound/
│       ├── postgres/
│       │   └── order_repo.go
│       └── redis/
│           └── cache.go
└── cmd/
    └── main.go               # 组装入口
```

### Java（Spring Boot）

```
src/main/java/com/example/order/
├── application/
│   ├── port/
│   │   ├── in/               # 驱动端口
│   │   │   ├── CreateOrderUseCase.java
│   │   │   └── GetOrderQuery.java
│   │   └── out/              # 被驱动端口
│   │       ├── LoadOrderPort.java
│   │       └── SaveOrderPort.java
│   ├── domain/
│   │   ├── Order.java
│   │   ├── OrderItem.java
│   │   └── Money.java
│   └── service/
│       └── OrderService.java
├── adapter/
│   ├── in/
│   │   └── web/
│   │       └── OrderController.java
│   └── out/
│       └── persistence/
│           ├── OrderJpaEntity.java
│           ├── OrderMapper.java
│           └── OrderPersistenceAdapter.java
└── config/
    └── BeanConfiguration.java
```

## 适用场景

**推荐使用**：
- 需要支持多种入口（REST + gRPC + CLI + 消息队列）
- 外部依赖频繁变更（更换数据库、切换第三方服务）
- 需要高测试覆盖（可轻松 mock 所有端口）
- 团队关注可替换性和技术中立

**谨慎使用**：
- 简单 CRUD 应用（过度设计）
- 团队对 DI 和接口抽象不熟悉
- 端口/适配器数量极少（只有一种入口和一种存储）

## 与 Clean Architecture 的对比

| 维度 | Hexagonal | Clean Architecture |
|------|-----------|-------------------|
| 层数 | 2层（应用核心 + 适配器） | 4层（实体/用例/适配/框架） |
| 核心抽象 | 端口与适配器 | 依赖规则与同心圆 |
| 方向性 | 强调 In/Out 方向 | 强调内外层级 |
| 命名惯例 | Port、Adapter | UseCase、Gateway、Presenter |
| 实践差异 | 更关注可替换性 | 更关注层次职责划分 |
| 本质关系 | 等价——都遵循依赖倒置原则 | 等价——都遵循依赖倒置原则 |
