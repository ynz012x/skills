---
paths:
  - "**/*.md"
---

# 图像绘制原则

技术绘图优先使用 Mermaid，ASCII 仅用于目录结构。

## 使用 Mermaid 绘制

以下类型的图必须使用 Mermaid：

- 流程图（flowchart）
- 时序图（sequenceDiagram）
- 类图（classDiagram）
- 状态图（stateDiagram）
- ER 图（erDiagram）
- 甘特图（gantt）
- 架构图（architecture）

## 使用 ASCII 绘制

仅以下场景允许使用 ASCII art：

- 文件夹、目录结构展示

# 嵌套代码块规则

嵌套代码块的核心：外层围栏的反引号数量必须多于内层。

- 内层使用 3 个反引号（` ``` `），外层使用 4 个或更多（` ```` `）
- 关闭围栏的反引号数量必须 >= 开启围栏的数量
- 此规则防止 Markdown 解析器将内层结束标记误判为外层代码块的结束
