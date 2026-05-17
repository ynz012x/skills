---
name: app-arch-designer
description: 基于 DDD 战略/战术设计的应用架构设计工具，融合 Clean Architecture / Hexagonal / Vertical Slice 架构风格推荐和 Arc42 文档模板输出。当你需要做应用架构设计、DDD 建模、划分限界上下文、设计聚合根、选择分层架构、规划模块目录结构、从需求到应用架构落地时，请使用此 skill。也适用于评估现有项目的架构合理性。
---

# 应用架构设计师

融合 **DDD 领域驱动设计**（战略+战术）、**分层架构模式**（Clean / Hexagonal / Vertical Slice 择优推荐）和 **Arc42 文档模板**，帮助用户完成从业务需求到应用内部架构的完整设计。

方法论全景：[references/overview.md](references/overview.md)

## 流程概述

```
Step1: 上下文理解 → Step2: 战略设计 → Step3: 战术设计 → Step4: 分层架构决策 → Step5: 产出整合
```

---

## 前置准备

与用户确认以下参数（缺失项主动询问）：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `project_name` | 项目名称 | 必填 |
| `project_background` | 项目背景和核心业务描述 | 必填 |
| `project_path` | 现有代码库路径（增量设计时使用） | 可选 |
| `design_depth` | 设计深度 | `standard`（可选 quick / standard / comprehensive） |
| `output_dir` | 输出目录 | `./design` |
| `upstream_doc` | requirement-analyzer 输出的需求文档路径 | 可选 |

**设计深度说明**：

| 维度 | quick | standard | comprehensive |
|------|-------|----------|---------------|
| BC 数量 | 2-4 个 | 4-7 个 | 不限 |
| 聚合设计范围 | 仅核心域 | 核心+重要支撑域 | 所有 BC |
| 目录结构深度 | 顶层+2层 | 全模块3层 | 文件级 |
| ADR 数量 | 1-2 个 | 3-5 个 | 所有关键决策 |

---

## 交互原则

**歧义澄清**：遇到以下情况必须暂停询问用户——领域术语存在多义、限界上下文边界不清晰、架构风格取舍难以判断、业务规则不确定是否属于同一聚合。

**阶段门禁**：每个 Step 结束时，必须将该步完整产出展示给用户。用户确认后才能进入下一步。这一机制确保架构决策经过人工审核，避免基于错误假设层层推导。

**深度适配**：根据 `design_depth` 参数调整各步输出粒度。quick 适合小型项目快速原型，comprehensive 适合大型系统长期演进。

**输出规范**：所有图表使用 Mermaid 格式，表格使用 Markdown 格式。

---

## Step 1: 上下文理解

> 参考：[references/overview.md](references/overview.md)

**目标**：建立对目标应用的全面理解，收集架构决策所需的约束信息。

### Step 1.1: 输入材料确认

- 确认前置参数是否齐备
- 如有 `upstream_doc`（requirement-analyzer 输出），读取并提取：主题域 → BC 初始参考、核心实体 → 聚合候选、业务事件 → 领域事件参考、质量需求 → 架构约束
- 如有 `project_path`，扫描现有代码识别当前架构风格

### Step 1.2: 业务能力识别

从用户描述或需求文档中提取：
- 核心业务能力清单（Business Capabilities）
- 关键业务流程和主要参与者
- 领域复杂度评估（简单 CRUD / 中等业务逻辑 / 复杂领域规则）

### Step 1.3: 技术约束与团队上下文

收集以下信息：
- 技术栈约束（语言、框架、基础设施）
- 团队规模与技能分布
- 部署模式（单体 / 模块化单体 / 微服务）
- 项目阶段（绿地新建 / 棕地改造 / 遗留系统重构）

**输出**：项目上下文摘要（业务能力清单 + 复杂度评估 + 约束矩阵）

**检查清单**：[assets/checklists/step1-checklist.md](assets/checklists/step1-checklist.md)

---

## Step 2: 战略设计（DDD Strategic Design）

> 参考：[references/ddd/strategic-design.md](references/ddd/strategic-design.md) | [references/ddd/ubiquitous-language.md](references/ddd/ubiquitous-language.md)

**目标**：完成限界上下文划分、统一语言建立、上下文映射和域分类。

### Step 2.1: 统一语言（Ubiquitous Language）

从 Step 1 的业务能力中提取核心领域术语，为每个术语定义精确含义和使用范围，标识同一概念在不同上下文中的含义差异。

### Step 2.2: 限界上下文划分（Bounded Context）

基于业务能力边界、语言边界、团队边界进行 BC 划分。每个 BC 定义：名称、核心职责、包含的领域概念、团队归属。使用 Event Storming 思维识别关键事件作为天然边界。

### Step 2.3: 上下文映射（Context Map）

确定 BC 之间的关系类型（Partnership / Shared Kernel / Customer-Supplier / Conformist / Anti-Corruption Layer / Open Host Service / Separate Ways），为每对关系说明理由和集成策略。

### Step 2.4: 核心域/支撑域/通用域分类

将每个 BC 分类为核心域（核心竞争力，自研精打）、支撑域（辅助功能，适度投入）、通用域（通用方案，复用/采购）。

**输出**：BC 清单 + Context Map 图（Mermaid）+ 域分类表 + 术语表

**检查清单**：[assets/checklists/step2-checklist.md](assets/checklists/step2-checklist.md)

---

## Step 3: 战术设计（DDD Tactical Design）

> 参考：[references/ddd/tactical-design.md](references/ddd/tactical-design.md)

**目标**：为核心 BC 完成内部领域建模——聚合、实体、值对象、领域事件等。

### Step 3.1: 聚合设计（Aggregate）

遵循 Vaughn Vernon 聚合四规则：在一致性边界内建模真正的不变量、设计小聚合、通过 ID 引用其他聚合、边界外使用最终一致性。为每个聚合确定聚合根、内部实体和值对象。

### Step 3.2: 实体与值对象

区分实体（有唯一标识、有生命周期、状态可变）和值对象（无标识、不可变、以值相等）。定义核心属性和业务方法。

### Step 3.3: 领域服务（Domain Service）

识别不属于任何单一实体的领域逻辑，定义领域服务的职责和接口。区分领域服务（纯业务逻辑）和应用服务（用例编排）。

### Step 3.4: 领域事件（Domain Event）

从业务流程中识别关键状态变更，定义事件名、触发者、携带数据和订阅者。确定事件发布策略（进程内 / 消息队列）。

### Step 3.5: 仓储与工厂（Repository & Factory）

为每个聚合根定义 Repository 接口和核心查询方法。识别需要 Factory 的复杂创建逻辑。

**输出**：聚合清单 + 聚合结构图（Mermaid classDiagram）+ 领域事件清单 + 事件流图（Mermaid sequenceDiagram）

**检查清单**：[assets/checklists/step3-checklist.md](assets/checklists/step3-checklist.md)

---

## Step 4: 分层架构决策

> 参考：[references/architecture-styles/decision-guide.md](references/architecture-styles/decision-guide.md)

**目标**：为项目选择最适合的分层架构风格，生成推荐的项目目录结构。

### Step 4.1: 架构风格评估

基于 Step 1 的约束（领域复杂度、团队规模、技术栈、部署模式），评估三种候选架构的适用性：

- **Clean Architecture**：复杂领域逻辑、长期演进 → [references/architecture-styles/clean-architecture.md](references/architecture-styles/clean-architecture.md)
- **Hexagonal (Ports & Adapters)**：多端口集成、可替换基础设施 → [references/architecture-styles/hexagonal.md](references/architecture-styles/hexagonal.md)
- **Vertical Slice**：功能独立性高、团队并行开发 → [references/architecture-styles/vertical-slice.md](references/architecture-styles/vertical-slice.md)

给出推荐并记录为 ADR（使用模板 [assets/templates/architecture-decision.md](assets/templates/architecture-decision.md)）。

### Step 4.2: 分层结构设计

基于选定架构风格，定义具体分层结构、每层职责、允许的依赖方向和层间通信契约。

### Step 4.3: 项目目录结构推荐

结合架构风格 + DDD 设计结果，生成完整的项目目录结构（使用模板 [assets/templates/directory-structure.md](assets/templates/directory-structure.md)），包含每个目录/文件的用途说明和模块间引用规则。

### Step 4.4: 跨切面关注点

定义跨切面逻辑的处理策略：日志、认证授权、错误处理、事务管理、缓存。确定放置位置（中间件 / 装饰器 / AOP / 基础设施层）。

**输出**：架构风格 ADR + 分层依赖图（Mermaid）+ 项目目录结构 + 跨切面策略表

**检查清单**：[assets/checklists/step4-checklist.md](assets/checklists/step4-checklist.md)

---

## Step 5: 产出整合

> 参考：[references/arc42/template-guide.md](references/arc42/template-guide.md)

**目标**：生成最终的应用架构设计文档。

### Step 5.1: 完整性检查

使用 [assets/checklists/completeness-checklist.md](assets/checklists/completeness-checklist.md) 逐项验证所有步骤产出的完整性和一致性。

### Step 5.2: 文档生成

读取模板 [assets/templates/app-arch-doc.md](assets/templates/app-arch-doc.md)，将 Step 1-4 的产出整合为完整的应用架构设计文档，输出到 `{{output_dir}}/app-architecture.md`。

### Step 5.3: 总结报告

展示设计完成摘要：

```
应用架构设计完成
===============
项目：{{project_name}} | 深度：{{design_depth}} | 架构风格：{{architecture_style}}

统计：BC {{bc_count}} 个 | 聚合 {{aggregate_count}} 个 | 领域事件 {{event_count}} 个 | ADR {{adr_count}} 条

输出：{{output_dir}}/app-architecture.md

建议后续：
1. 与团队评审架构设计
2. 创建技术原型验证关键假设
3. 可选：使用 ccpy:system-design 完成系统级设计
```
