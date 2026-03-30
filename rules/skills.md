---
paths:
  - "**/SKILL.md"
---

# SKILL.md 编写规范

## 描述长度限制
- Skill 的触发描述（description 字段）不超过 250 字符，加载到上下文时超出部分会被截断以减少 context 用量
- 描述必须在此限制内清晰表达触发场景和用途

## 文件长度限制
- SKILL.md 正文不超过 500 行
- 超出时将核心内容拆分至 `references/` 子目录，在 SKILL.md 中通过路径引用
