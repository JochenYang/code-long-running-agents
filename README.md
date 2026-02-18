<div align="center">

<img src="public/logo.png" alt="Logo" width="720" />

# Long-Running Agent

一个通过结构化功能清单和进度跟踪来执行长时间 AI Agent 任务的框架。

基于 Anthropic 官方论文 [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) 的最佳实践。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](#)

[**English**](README-EN.md) | 中文

</div>

---

## 解决的问题

AI Agent 在长时间任务中面临的核心挑战：

| 挑战               | 描述                                 |
| ------------------ | ------------------------------------ |
| **上下文窗口限制** | 每个新会话对之前没有记忆             |
| **过早完成**       | Agent 看到已有进展后容易过早宣布完成 |
| **一次性做太多**   | 试图一口气完成整个项目导致中途失败   |

---

## 快速开始

### 方式一：使用 CLI 初始化（推荐）

```bash
# 交互式初始化（自动检测系统语言）
npx ai-agent-loop init

# 指定中文
npx ai-agent-loop init --lang zh

# 指定英文
npx ai-agent-loop init --lang en

# 指定目录
npx ai-agent-loop init --lang zh --dir ./my-project
```

CLI 会自动：

- 复制 `CLAUDE.md` 到项目根目录
- 创建 `agent-loop/` 目录及所有必要文件

### 方式二：手动复制

```powershell
# 复制整个文件夹
Copy-Item -Recurse agent-loop target-project/

# 复制 CLAUDE.md 到项目根目录
Copy-Item agent-loop/CLAUDE.md target-project/
```

### 2. 配置任务

编辑 `agent-loop/feature_list.json`：

```json
{
  "project": {
    "name": "your-project-name",
    "description": "项目描述"
  },
  "features": [
    {
      "id": "1",
      "description": "实现用户登录功能",
      "testableSteps": [
        {
          "step": 1,
          "action": "导航到登录页",
          "target": "/login",
          "verification": "页面包含登录"
        }
      ],
      "passes": false,
      "priority": "must-have"
    }
  ]
}
```

### 3. 启动 Claude Code

```powershell
cd target-project
claude
```

### 4. 执行任务

#### 方式一：无 PRD，直接配置任务

告诉 Claude：

> **"请读取 agent-loop/feature_list.json，按优先级顺序实现所有 passes:false 的功能。测试通过后才能标记为完成，每次完成后更新进度并提交 git。"**

#### 方式二：有 PRD，根据 PRD 生成分功能清单

如果项目有 PRD.md，先告诉 Claude：

> **"请读取 PRD.md，根据产品需求文档生成分功能清单。参考 agent-loop/feature_list.json 模板，每个功能需要包含 testableSteps（可验证的测试步骤）。"**

完整指令示例：

```markdown
请读取 PRD.md，然后执行以下任务：

1. 读取并理解 PRD - 分析产品需求文档中的所有功能需求

2. 生成分功能清单 - 根据 PRD 创建 agent-loop/feature_list.json，要求：
   - 每个功能包含：id, category, description, expectedOutcome, testableSteps, passes, priority, complexity
   - 使用 JSON 格式（防止随意修改）
   - testableSteps 必须包含具体的可验证步骤（action, target, verification）
   - 按优先级排序（must-have → should-have → could-have）

3. 初始化项目 - 确保项目可以正常运行：
   - 运行 ./agent-loop/init.sh start 启动开发服务器
   - 验证服务器正常

4. 创建 Git 仓库（如无）：
   - git init
   - git add .
   - git commit -m "feat: initial setup with feature list"
   - git checkout -b develop
```

---

## 核心流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    Agent 开发循环                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. git checkout -b feature/编号-名称   → 创建功能分支        │
│  2. 启动开发服务器 ./init.sh start                             │
│  3. 实现功能                                                   │
│  4. 运行测试 ./init.sh test                                   │
│  5. 测试失败？→ 修复代码 → 重新测试 → 直到通过               │
│  6. 测试通过 → 更新 passes: true                             │
│  7. 更新 claude-progress.txt                                   │
│  8. git add . && git commit                                  │
│  9. git checkout develop && git merge feature/xxx            │
│  10. 循环下一个功能                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 文件说明

| 文件                             | 说明                         |
| -------------------------------- | ---------------------------- |
| `CLAUDE.md`                      | 入口文档（复制到项目根目录） |
| `agent-loop/CLAUDE-INIT.md`      | 初始化代理指南（首个会话）   |
| `agent-loop/CLAUDE-CODING.md`    | 编码代理指南（后续会话）     |
| `agent-loop/feature_list.json`   | 功能清单模板                 |
| `agent-loop/init.sh`             | 启动+测试脚本                |
| `agent-loop/claude-progress.txt` | 进度记录                     |

---

## init.sh 命令

```bash
./agent-loop/init.sh start   # 启动开发服务器
./agent-loop/init.sh test   # 运行测试
./agent-loop/init.sh status # 查看状态
./agent-loop/init.sh stop   # 停止服务器
```

---

## 核心规则

1. **测试驱动开发** - 实现功能 → 测试 → 失败则修复 → 重测 → 直到通过 → 下一功能
2. **证据优先** - 无测试证据不声称完成
3. **每功能独立分支** - 每个功能在单独 Git 分支开发
4. **passes 必须为 false 初始值** - 只能通过验证后改为 true

---

## 基于官方最佳实践

本框架实现自 Anthropic 官方论文的核心原则：

- ✅ 双代理架构（Initializer + Coding）
- ✅ 功能清单管理（JSON 格式防止随意修改）
- ✅ 测试验证机制（Puppeteer 浏览器自动化）
- ✅ 进度追踪（claude-progress.txt + Git 历史）
- ✅ 反过早完成机制（强制测试循环）
- ✅ Git 分支工作流

---

## 项目结构

```
code-long-running-agents/
├── README.md              # 中文说明
├── README-EN.md          # English
├── LICENSE               # MIT License
├── agent-loop/           # 中文版
│   ├── CLAUDE.md
│   ├── CLAUDE-INIT.md
│   ├── CLAUDE-CODING.md
│   ├── feature_list.json
│   ├── claude-progress.txt
│   ├── init.sh
│   └── run-agent-loop.ps1
└── agent-loop-en/        # English version
    ├── CLAUDE.md
    ├── CLAUDE-INIT.md
    ├── CLAUDE-CODING.md
    ├── feature_list.json
    ├── claude-progress.txt
    ├── init.sh
    └── run-agent-loop.ps1
```

---

<div align="center">

## 许可证

MIT License - see [LICENSE](LICENSE) for details.

</div>
