# Clean Architecture（整洁架构）

## 概述

Robert C. Martin（Uncle Bob）提出的架构模式，核心思想是**依赖规则**：源代码依赖只能指向内层，内层绝不依赖外层。

## 四层结构

```
┌───────────────────────────────────────────────┐
│ 框架层 Frameworks & Drivers                    │ ← 最外层
│ ┌───────────────────────────────────────────┐ │
│ │ 接口适配层 Interface Adapters             │ │
│ │ ┌───────────────────────────────────────┐ │ │
│ │ │ 用例层 Use Cases / Application        │ │ │
│ │ │ ┌───────────────────────────────────┐ │ │ │
│ │ │ │ 实体层 Entities / Domain          │ │ │ │ ← 最内层
│ │ │ └───────────────────────────────────┘ │ │ │
│ │ └───────────────────────────────────────┘ │ │
│ └───────────────────────────────────────────┘ │
└───────────────────────────────────────────────┘
```

| 层 | 职责 | 包含 |
|----|------|------|
| **实体层（Domain）** | 企业级核心业务规则 | Entity、Value Object、Domain Service、Domain Event |
| **用例层（Application）** | 应用级业务流程编排 | Use Case Interactor、Input/Output Port（接口定义） |
| **接口适配层（Adapters）** | 外部格式与内部格式的转换 | Controller、Presenter、Gateway、Repository 实现 |
| **框架层（Frameworks）** | 具体技术实现 | Web 框架、ORM、第三方 SDK、数据库驱动 |

## 依赖规则

**唯一规则**：外层可以依赖内层，内层**绝不**依赖外层。

通过**依赖倒置原则（DIP）**实现跨层通信：
- 内层定义接口（Port）
- 外层实现接口（Adapter）
- 运行时通过依赖注入组装

## 典型目录结构

### Python

```
src/
├── domain/                    # 实体层
│   ├── entities/
│   ├── value_objects/
│   ├── events/
│   └── services/
├── application/               # 用例层
│   ├── use_cases/
│   ├── ports/                 # 接口定义（Input/Output Port）
│   └── dtos/
├── adapters/                  # 接口适配层
│   ├── controllers/           # 入站适配（HTTP/CLI）
│   ├── repositories/          # 出站适配（数据库实现）
│   └── gateways/              # 出站适配（外部服务）
└── frameworks/                # 框架层
    ├── web/                   # Flask/FastAPI 配置
    ├── database/              # SQLAlchemy/数据库配置
    └── config/                # 应用配置
```

### Go

```
cmd/server/main.go             # 入口 + 依赖注入
internal/
├── domain/                    # 实体层
│   ├── entity/
│   ├── valueobject/
│   └── event/
├── application/               # 用例层
│   ├── usecase/
│   └── port/
├── adapter/                   # 适配层
│   ├── handler/               # HTTP Handler
│   ├── repository/            # 数据库实现
│   └── gateway/               # 外部服务客户端
└── infrastructure/            # 框架层
    ├── server/
    ├── database/
    └── config/
```

### Java/Kotlin

```
src/main/java/com/example/
├── domain/                    # 实体层
│   ├── model/
│   ├── event/
│   └── service/
├── application/               # 用例层
│   ├── usecase/
│   ├── port/in/               # 入站端口
│   └── port/out/              # 出站端口
├── adapter/                   # 适配层
│   ├── in/web/                # REST Controller
│   ├── out/persistence/       # JPA Repository
│   └── out/external/          # 外部服务客户端
└── infrastructure/            # 框架层
    └── config/                # Spring 配置
```

## 适用场景

- 复杂领域逻辑，需要长期维护和演进
- 核心业务规则需要独立于技术框架
- 团队较大，需要清晰的分层约定
- 需要高可测试性（内层可以完全脱离外部依赖测试）

## 注意事项

- 小项目可能过度工程化——如果业务逻辑简单，分 4 层反而增加复杂度
- 依赖注入是关键——没有 DI，依赖规则难以真正执行
- 不要教条化——层的命名和数量可以根据项目调整
