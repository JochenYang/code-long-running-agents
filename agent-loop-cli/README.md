# agent-loop CLI

基于 Anthropic 官方论文 [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) 的 AI Agent 脚手架安装工具。

## 安装

```bash
npm install -g agent-loop
```

或直接使用（无需安装）:

```bash
npx agent-loop init
```

## 使用方法

### 交互式初始化

```bash
npx agent-loop init
```

会提示选择语言和目标目录。

### 非交互式初始化

指定语言:

```bash
# 中文
npx agent-loop init --lang zh

# 英文
npx agent-loop init --lang en
```

指定目标目录:

```bash
npx agent-loop init --lang zh --dir ./my-project
```

## 输出

安装后会在目标目录创建以下文件:

```
project/
├── CLAUDE.md                    # 主配置文件（Claude Code 自动读取）
└── agent-loop/
    ├── CLAUDE-INIT.md           # 初始化代理指南（首个会话）
    ├── CLAUDE-CODING.md         # 编码代理指南（后续会话）
    ├── feature_list.json        # 功能清单模板
    ├── claude-progress.txt     # 进度记录
    ├── init.sh                 # 开发服务器启动脚本
    └── run-agent-loop.ps1      # 循环执行脚本
```

## 下一步

1. 进入项目目录: `cd your-project`
2. 启动 Claude Code: `claude`
3. 告诉 Claude: "请读取 CLAUDE.md 和 agent-loop/feature_list.json"
4. 开始实现功能

## 命令行选项

| 选项 | 简写 | 描述 | 默认值 |
|------|------|------|--------|
| --lang | -l | 语言: zh / en | 交互式选择 |
| --dir | -d | 目标目录 | 当前目录 |
| --help | -h | 显示帮助 | - |
| --version | -V | 显示版本 | - |

## 开发

```bash
# 安装依赖
npm install

# 链接本地包
npm link

# 测试
node bin/agent-loop.js init --lang zh --dir ../test-project
```

## License

MIT
