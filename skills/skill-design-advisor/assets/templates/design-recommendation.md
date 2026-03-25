# {{ skill_name }} — Skill 设计建议

## 1. 需求摘要

| 维度 | 分析结果 |
|------|---------|
| **目标** | {{ skill_purpose }} |
| **输入特征** | {{ input_type }} |
| **输出特征** | {{ output_type }} |
| **交互复杂度** | {{ interaction_complexity }} |
| **领域知识** | {{ domain_knowledge }} |
| **流程结构** | {{ process_structure }} |
| **类别** | {{ skill_category }} |

## 2. Skill 类别分析

**识别类别**：{{ skill_category }}

**类别特征**：{{ category_characteristics }}

**对设计决策的影响**：{{ category_design_impact }}

## 3. 设计模式推荐

### 主模式：{{ primary_pattern }}

**匹配理由**：{{ primary_reason }}

**在 Claude Code 中的实现方式**：{{ primary_implementation }}

### 辅助模式：{{ secondary_pattern }}

**组合理由**：{{ secondary_reason }}

### 未选模式说明

| 模式 | 不推荐理由 |
|------|-----------|
| {{ unused_pattern_1 }} | {{ unused_reason_1 }} |
| {{ unused_pattern_2 }} | {{ unused_reason_2 }} |
| {{ unused_pattern_3 }} | {{ unused_reason_3 }} |

## 4. 推荐目录结构

```
{{ skill_name }}/
├── SKILL.md                          # {{ skill_md_description }}
{{ directory_tree }}
```

各目录/文件用途：
{{ directory_explanations }}

## 5. SKILL.md 章节结构建议

### Frontmatter

```yaml
---
name: {{ skill_name }}
description: {{ suggested_description }}
---
```

### 章节规划

{{ chapter_plan }}

## 6. 关键设计要点

{{ design_points }}

## 7. 写作最佳实践

基于类别（{{ skill_category }}）和模式（{{ primary_pattern }}）精选的实践建议：

{{ selected_practices }}

> 每条实践的应用说明针对本 skill 的具体场景定制，而非泛泛而谈。

## 8. 与 skill-creator 的衔接

将本设计建议作为上下文传递给 `skill-creator`：

1. 将本文档的"目录结构"和"章节规划"作为 skill-creator 的输入参考
2. 在 skill-creator 的 Interview 阶段，重点关注上述设计要点
3. 编写 SKILL.md 时按照推荐的章节结构组织内容
4. 将第 7 节的写作最佳实践作为写作约束传递给 skill-creator
5. 测试时验证是否遵循了推荐模式的核心特征

---

*本建议由 skill-design-advisor 基于 Google 5大设计模式与 Anthropic Skill 工程实践生成*
