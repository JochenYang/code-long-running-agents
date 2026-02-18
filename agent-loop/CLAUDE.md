# Long-Running Agent 循环执行工具

> **重要提示**：将此文件复制到**你的项目根目录**，其他文件保留在 `agent-loop/` 子目录中。

## 核心挑战

代理在离散会话中工作，新会话对之前无记忆。两种失败模式：

1. 试图一次性完成太多，耗尽上下文
2. 看到已有进展后，过早宣布完成

## 双代理架构

### 初始化代理 (Initializer)

首个会话创建：

- `init.sh` - 启动开发服务器 + 测试脚本
- `feature_list.json` - 功能列表（初始 passes: false）
- `claude-progress.txt` - 进度记录
- 初始 git 提交

### 编码代理 (Coding Agent)

后续会话执行：

1. 读取 claude-progress.txt + feature_list.json + git log
2. 执行 init.sh 启动环境
3. 执行 init.sh test 运行基础测试验证
4. 从 feature_list.json 选 passes=false 的功能
5. **实现功能 → 运行测试 → 测试失败则修复 → 重新测试 → 直到测试通过**
6. 更新 claude-progress.txt，git 提交，标记 passes: true
7. 循环直到所有功能完成

---

## 核心理念：测试驱动开发

> **"测试直到通过才进行下一步"** — 这是强制要求，不是可选建议

```
实现功能 → 运行测试 → 测试失败？ → 修复代码 → 重新测试 → 直到通过 → 标记 passes: true → 下一功能
```

---

## 文件说明

| 文件 | 用途 |
|------|------|
| CLAUDE.md | 本说明文档（复制到项目根目录） |
| agent-loop/feature_list.json | 功能清单（定义任务，每个功能 passes: false） |
| agent-loop/claude-progress.txt | 进度记录 |
| agent-loop/init.sh | 开发服务器启动 + 测试脚本 |
| agent-loop/run-agent-loop.ps1 | 循环执行脚本 |

---

## feature_list.json 格式

```json
{
  "project": {
    "name": "your-project-name",
    "description": "项目描述",
    "complexity": "medium"
  },
  "features": [
    {
      "id": "1",
      "category": "core",
      "description": "功能描述",
      "expectedOutcome": "期望结果",
      "testableSteps": [
        {
          "step": 1,
          "action": "具体操作",
          "target": "目标元素或URL",
          "verification": "验证条件"
        }
      ],
      "passes": false,
      "testedAt": null,
      "failureReason": null,
      "attemptCount": 0,
      "priority": "must-have"
    }
  ]
}
```

**关键规则**：

- 所有功能初始 passes 必须为 false
- 代理只能通过验证后改为 true
- **测试失败必须修复并重试，直到测试通过才能标记 passes: true**

---

## 使用方式

### 1. 复制到目标项目

```powershell
# 复制整个 agent-loop 文件夹到目标项目根目录
Copy-Item -Recurse agent-loop target-project/

# 复制 CLAUDE.md 到根目录
Copy-Item agent-loop/CLAUDE.md target-project/
```

### 2. 配置任务

编辑 `agent-loop/feature_list.json`，定义你的功能列表（参考 CLAUDE-INIT.md 中的拆分原则）

### 3. 配置启动和测试脚本

根据项目修改 `agent-loop/init.sh`：

```bash
#!/bin/bash
# 开发服务器启动
npm run dev
```

### 4. 测试脚本

测试使用 Puppeteer MCP，在功能实现后运行：

```bash
# 运行功能测试
./agent-loop/init.sh test
```

---

## 手动模式（不通过脚本）

```powershell
# 启动 Claude Code
claude

# 告诉它：
# "请读取 agent-loop/CLAUDE-CODING.md 和 feature_list.json"
# "实现第一个 passes:false 的功能，测试通过后才能标记为完成"
```

---

## 会话检查清单

- [ ] pwd 确认工作目录
- [ ] git log --oneline -10 查看最近提交
- [ ] cat agent-loop/claude-progress.txt 了解当前状态
- [ ] 读取 agent-loop/feature_list.json 选择下一个功能
- [ ] ./agent-loop/init.sh 启动开发服务器
- [ ] ./agent-loop/init.sh test 验证基础功能
- [ ] 实现功能 → 运行测试 → 失败则修复 → 重测 → 直到通过
- [ ] 更新 claude-progress.txt + git 提交
- [ ] 标记功能 passes: true（仅在测试通过后）

---

## 文档说明

- [agent-loop/CLAUDE-INIT.md](./agent-loop/CLAUDE-INIT.md) - 初始化代理专用指南
- [agent-loop/CLAUDE-CODING.md](./agent-loop/CLAUDE-CODING.md) - 编码代理专用指南
