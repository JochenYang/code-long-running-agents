<div align="center">

# Long-Running Agent 循环执行框架

一个通过结构化功能清单和进度跟踪来执行长时间AI Agent任务的框架。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](#)

[**English**](README-EN.md) | 中文

</div>

---

## 解决的问题

AI Agent 在长时间任务中面临的核心挑战：

| 挑战 | 描述 |
|------|------|
| **上下文窗口限制** | 每个新会话对之前没有记忆 |
| **过早完成** | Agent 看到已有进展后容易过早宣布完成 |
| **一次性做太多** | 试图一口气完成整个项目导致中途失败 |

---

## 快速开始

### 1. 复制到目标项目

```powershell
# 方式1：复制整个文件夹
Copy-Item -Recurse agent-loop target-project/

# 方式2：只复制必要文件
cp agent-loop/feature_list.json target-project/
cp agent-loop/CLAUDE.md target-project/
```

### 2. 配置任务

编辑 `feature_list.json`：

```json
{
  "features": [
    {
      "id": "1",
      "description": "实现用户登录功能",
      "steps": ["创建登录页面", "添加表单验证", "对接后端API"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

### 技术栈规范（如有需要）

如果你有特定的技术栈要求，可以在 `steps` 中明确规定：

```json
{
  "id": "1",
  "description": "项目基础架构搭建",
  "steps": [
    "使用 React + TypeScript + Vite 初始化项目",
    "使用 shadcn/ui 作为组件库",
    "使用 Tailwind CSS 作为样式方案",
    "配置 ESLint + Prettier"
  ]
}
```

可以在 steps 中规定的项目：

| 规范项 | 示例 |
|--------|------|
| 前端框架 | React / Vue / Angular |
| UI组件库 | shadcn/ui / Ant Design / Element Plus |
| 样式方案 | Tailwind CSS / CSS Modules |
| 状态管理 | Redux / Zustand / Jotai |
| API方案 | Axios / React Query / SWR |

### 3. 启动 Claude Code

```powershell
cd target-project
claude
```

### 4. 执行任务

告诉 Claude：

> "请读取 feature_list.json，按优先级顺序实现所有 passes:false 的功能。每次完成后更新 passes 为 true 并记录进度。"

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `CLAUDE.md` | Agent 流程定义（Claude Code 会自动读取） |
| `feature_list.json` | 功能清单，定义要完成的任务 |
| `claude-progress.txt` | 进度记录 |
| `init.sh` | 开发服务器启动脚本 |
| `run-agent-loop.ps1` | 循环执行脚本（可选） |

---

## feature_list.json 格式

```json
{
  "features": [
    {
      "id": "1",
      "description": "功能描述",
      "steps": ["步骤1", "步骤2", "步骤3"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

### 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| id | ✅ | 唯一标识符 |
| description | ✅ | 功能描述 |
| steps | ✅ | 实现步骤数组 |
| passes | ✅ | 完成状态，初始为 false |
| priority | ✅ | 优先级：high/medium/low |

---

## 核心规则

1. **所有功能初始 passes 必须为 false**
2. **Agent 只能通过验证后改为 true**
3. **每次只实现一个功能**
4. **完成后必须提交 git 并更新进度**

---

## 会话流程

```
1. 读取 CLAUDE.md (了解规则)
2. 读取 feature_list.json (选择任务)
3. 读取 claude-progress.txt (了解进度)
4. 查看 git log (了解历史)
5. 启动开发服务器 (init.sh)
6. 验证基本功能正常
7. 实现当前功能
8. 测试验证
9. 更新 passes: true
10. 更新进度记录
11. git commit
12. 循环下一个功能
```

---

## 示例项目

本仓库包含一个漫剧生图项目的完整功能清单作为示例（共15个功能）：

| 优先级 | 功能 |
|--------|------|
| High | 项目基础架构搭建 |
| High | 用户认证系统 |
| High | AI图像生成面板 |
| High | 图像编辑工具 |
| High | 漫画分格系统 |
| Medium | 对话气泡系统 |
| Medium | 角色管理系统 |
| Medium | 故事板管理 |
| Medium | 项目/作品管理 |
| Medium | 图像库/素材库 |
| Medium | 导出功能 |
| Low | 历史记录系统 |
| Low | AI局部重绘 |
| Low | AI图像放大 |
| Low | 协作功能 |

---

## 项目结构

```
code-long-running-agents/
├── README.md              # 中文说明
├── README-EN.md           # English
├── LICENSE                # MIT License
├── agent-loop/            # 中文版
│   ├── CLAUDE.md
│   ├── feature_list.json
│   ├── claude-progress.txt
│   ├── init.sh
│   └── run-agent-loop.ps1
└── agent-loop-en/         # English version
    ├── CLAUDE.md
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
