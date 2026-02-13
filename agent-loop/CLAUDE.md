# Long-Running Agent 循环执行工具

## 核心挑战

代理在离散会话中工作，新会话对之前无记忆。两种失败模式：

1. 试图一次性完成太多，耗尽上下文
2. 看到已有进展后，过早宣布完成

## 双代理架构

### 初始化代理 (Initializer)

首个会话创建：

- `init.sh` - 启动开发服务器
- `feature_list.json` - 功能列表（初始 passes: false）
- `claude-progress.txt` - 进度记录
- 初始 git 提交

### 编码代理 (Coding Agent)

后续会话执行：

1. 读取 claude-progress.txt + feature_list.json + git log
2. 执行 init.sh 启动环境，验证基本功能
3. 从 feature_list.json 选 passes=false 的功能
4. 实现功能，运行测试验证
5. 更新 claude-progress.txt，git 提交，标记 passes: true
6. 循环直到所有功能完成

## 文件说明

| 文件                | 用途                                         |
| ------------------- | -------------------------------------------- |
| CLAUDE.md           | 本说明文档                                   |
| feature_list.json   | 功能清单（定义任务，每个功能 passes: false） |
| claude-progress.txt | 进度记录                                     |
| init.sh             | 开发服务器启动脚本（根据项目修改）           |
| run-agent-loop.ps1  | 循环执行脚本                                 |

## feature_list.json 格式

```json
{
  "features": [
    {
      "id": "1",
      "description": "功能描述",
      "steps": ["步骤1", "步骤2"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

**关键规则**:

- 所有功能初始 passes 必须为 false
- 代理只能通过验证后改为 true

## 使用方式

### 1. 复制到目标项目

```powershell
# 复制整个 agent-loop 文件夹到目标项目根目录
Copy-Item -Recurse agent-loop target-project/

# 或手动复制文件
cp agent-loop/* target-project/
```

### 2. 配置任务

编辑 `feature_list.json`，定义你的功能列表：

```json
{
  "features": [
    {
      "id": "1",
      "description": "创建用户登录页面",
      "steps": ["创建 login.html", "添加表单验证", "对接API"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

### 3. 配置启动脚本

根据项目修改 `init.sh`：

```bash
#!/bin/bash
# 根据你的项目修改
npm run dev
# 或其他启动命令
```

### 4. 执行循环任务

```powershell
# 进入目标项目
cd target-project

# 运行循环脚本
.\run-agent-loop.ps1

# 或限制迭代次数
.\run-agent-loop.ps1 -MaxIterations 10
```

## 手动模式（不通过脚本）

如果你想手动控制每个迭代：

```powershell
# 启动 Claude Code
claude

# 告诉它：
# "请读取 feature_list.json，实现第一个 passes:false 的功能"
```

## 会话检查清单

- [ ] pwd 确认工作目录
- [x] 读取 claude-progress.txt (脚本已自动注入上下文)
- [ ] 读取 feature_list.json 选择下一个功能
- [ ] git log --oneline -10 查看最近提交
- [ ] 执行 init.sh 启动开发服务器
- [ ] 验证基本功能正常
- [ ] 实现单个功能并测试
- [ ] 更新 claude-progress.txt + git 提交
- [ ] 标记功能 passes: true（仅验证通过后）
