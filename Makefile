# =============================================================================
# cckit-python Makefile
# =============================================================================

SKILLS_DIR := ./skills

# 工具自动检测
SKILLPORT := $(shell command -v skillport 2>/dev/null)
ifndef SKILLPORT
  ifneq ($(shell command -v uvx 2>/dev/null),)
    SKILLPORT := uvx skillport
  endif
endif

# =============================================================================
# 外部 Skill 来源配置
# 每行一条 skillport add 的参数
# 格式: <owner/repo> [path]  或  <url> [path]
# 示例:
#   anthropics/skills skills
#   https://github.com/user/repo path/to/skill
# =============================================================================
define SKILL_SOURCES
anthropics/skills skills/skill-creator
endef
export SKILL_SOURCES

.PHONY: help check-deps sync-skills

.DEFAULT_GOAL := help

## help: 显示所有可用命令
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'

## check-deps: 检查依赖工具是否已安装
check-deps:
	@echo "Checking dependencies..."
	@command -v pre-commit >/dev/null 2>&1 || \
		{ echo "Error: pre-commit not found. Install: uv tool install pre-commit"; exit 1; }
	@echo "  pre-commit: OK"
	@if [ -z "$(SKILLPORT)" ]; then \
		echo "Error: skillport not found. Install: uv tool install skillport"; \
		exit 1; \
	fi
	@echo "  skillport: OK"
	@echo "All dependencies are installed."

## sync-skills: 同步外部 skills（覆盖更新 + validate）
sync-skills: check-deps
	@if [ -z "$$SKILL_SOURCES" ]; then \
		echo "No external skill sources configured. Edit SKILL_SOURCES in Makefile to add sources."; \
	else \
		echo "$$SKILL_SOURCES" | while IFS= read -r line; do \
			[ -z "$$line" ] && continue; \
			echo "Syncing: $$line"; \
			$(SKILLPORT) --skills-dir $(SKILLS_DIR) add $$line --force --yes; \
		done; \
		echo ""; \
		echo "Validating synced skills..."; \
		echo "$$SKILL_SOURCES" | while IFS= read -r line; do \
			[ -z "$$line" ] && continue; \
			skill_name=$$(echo "$$line" | awk '{print $$NF}' | xargs basename); \
			$(SKILLPORT) validate $(SKILLS_DIR)/$$skill_name; \
		done; \
	fi
