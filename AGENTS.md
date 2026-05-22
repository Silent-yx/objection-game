# AGENTS.md

## 交互规范

当需要与用户讨论多个问题时，每次只提出一个问题，等待用户回答后再提出下一个。禁止一次性抛出多个问题。提供选项时必须使用 AskUserQuestion 工具，确保用户可以自由编辑回答。

### 代码修改审批制

当用户报告问题或要求分析问题时，**只展示分析结果和解决方案，不得直接修改代码**。必须等用户明确同意后才能动手改代码。具体流程：

1. **分析阶段**：定位问题根因，展示涉及的文件和代码位置
2. **方案阶段**：提出修改方案（可提供多个选项），说明每个方案的影响范围
3. **等待确认**：用户确认采用某个方案后，再执行代码修改

**例外**：用户明确说"帮我改"、"直接修"、"fix it"等指令时，可直接修改。

## Memory Bank

重大修改前先阅读 `memory-bank/` 目录：
- `ARCHITECTURE.md` - 架构设计
- `progress.md` - 改造进度
- `implementation-plan.md` - 实施计划

## 常用命令

```bash
python -m src.main                 # 一键启动服务
uv run python -m src.main          # UV 环境运行（推荐）
uv run pytest src/tests/           # 运行测试
```

## 开发规范（必须严格遵守）

### 一、代码风格规范

| 规范项 | 要求 | 示例 |
|--------|------|------|
| **显式关键字参数** | 自定义方法和第三方库方法调用必须使用命名参数 | `foo(name=name)` ✓ / `foo(name)` ✗ |
| **方法单行注释** | 每个方法定义上方必须添加 `# 功能描述`（5-15字） | `# 异步调用 LLM` |
| **命名风格** | Python 内部 snake_case，外部 JSON camelCase | Pydantic alias_generator |

### 二、类型规范

| 规范项 | 要求 |
|--------|------|
| **强类型** | 所有函数参数和返回值必须有类型注解 |
| **数据类** | 使用 Pydantic BaseModel 或 dataclass |
| **类型目录** | 类型定义统一放在 `src/schemas/` 目录 |

### 三、错误处理规范

| 规范项 | 要求 |
|--------|------|
| **异常捕获** | 使用 try-except 捕获异常 |
| **失败处理** | 失败时返回默认值或抛出自定义异常，不静默忽略 |

### 四、日志规范

| 规范项 | 要求 |
|--------|------|
| **日志工具** | 使用 `loguru` 的 `logger` |
| **日志级别** | `logger.info` 普通信息 / `logger.error` 错误 / `logger.success` 成功 |
| **关键节点** | 方法开始、结束、异常处必须记录日志 |

### 五、导入顺序规范

```python
# 1. 标准库
import os
import sys

# 2. 第三方库
from loguru import logger
from pydantic import BaseModel

# 3. 本地模块
from src.schemas import ProjectInfo
from src.services import TenderExtractor
```

### 六、文件头注释规范

```python
# -*- coding: utf-8 -*-
"""
模块名 - 模块简述

包含：
- ClassA: 类A说明
- ClassB: 类B说明
"""
```

### 七、测试规范

| 规范项 | 要求 |
|--------|------|
| **方法注释** | 测试方法上方必须有单行注释 |
| **耗时统计** | 每个测试方法必须打印耗时 |
| **日志输出** | 使用 `logger.info` 打印测试结果 |

### 八、通用原则

| 规范项 | 要求 |
|--------|------|
| **简洁原则** | 避免多余功能，代码保持简洁、易懂、高效 |
| **复用优先** | 优先使用已有封装方法，避免重复代码 |