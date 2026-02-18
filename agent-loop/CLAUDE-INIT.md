# 初始化代理（Initializer Agent）——首个会话专用

> **重要提示**：此文件仅用于**首个代理会话**。后续会话必须使用 `agent-loop/CLAUDE-CODING.md`。

## 你的使命

你是初始化代理，负责设置长期运行的代理项目。你的任务是：

1. **评估项目复杂度**并确定合适的功能粒度
2. **生成可测试的完整功能清单**（根据复杂度 50-500 项）
3. **创建初始项目结构**并建立基线
4. **验证设置正确**后再移交给编码代理

---

## 第一阶段：项目复杂度评估

### 步骤 1：收集项目指标

运行以下命令收集项目指标：

```bash
# 统计功能描述数（如果 feature_list.json 存在）
FEATURE_COUNT=$(jq '.features | length' feature_list.json 2>/dev/null || echo "0")

# 统计 npm 依赖数
DEPS_COUNT=$(jq '.dependencies | length' package.json 2>/dev/null || echo "0")

# 统计源文件数
SRC_FILES=$(find src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l)

# 估算集成点数（API 调用、服务）
INTEGRATIONS=$(grep -rE "fetch|axios|WebSocket|connect|endpoint" src --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | wc -l)
```

### 步骤 2：计算复杂度分值

```typescript
interface ProjectMetrics {
  featureCount: number;
  depsCount: number;
  srcFiles: number;
  integrations: number;
}

function calculateComplexityScore(metrics: ProjectMetrics): number {
  return (metrics.featureCount * 3) +
         (metrics.depsCount * 0.5) +
         (metrics.srcFiles * 0.3) +
         (metrics.integrations * 2);
}

// 输出示例解释：
// < 100: 简单工具
// 100-200: 中等应用
// 200-350: 复杂系统
// > 350: 企业级系统
```

### 步骤 3：确定功能粒度

| 复杂度分值 | 项目类型 | 目标功能项数 | 每项步骤数 |
|-----------|---------|-------------|-----------|
| < 100 | 简单工具 | 30-50 | 5-8 |
| 100-200 | 中等应用 | 50-100 | 8-12 |
| 200-350 | 复杂系统 | 100-200 | 12-18 |
| > 350 | 企业级 | 200-500 | 15-25 |

**公式**：`targetItems = max(30, min(500, 50 + complexityScore))`

---

## 第二阶段：生成功能清单

### 关键原则：JSON 格式防止随意修改

使用 JSON 格式是因为它**防止随意修改**。AI 只能修改 `passes` 字段，其他字段必须保持完整。

### 功能模板说明

**每个功能必须包含以下字段：**

| 字段 | 必填 | 说明 |
|-----|-----|------|
| `id` | 是 | 唯一标识符（数字或字符串） |
| `category` | 是 | 分类：core/feature/integration/optimization/safety |
| `description` | 是 | 功能描述 - 简洁说明做什么 |
| `expectedOutcome` | 是 | 期望结果 - 完成后用户能看到什么 |
| `testableSteps` | 是 | 可测试步骤数组（见下文） |
| `passes` | 是 | 初始必须为 `false` |
| `priority` | 是 | must-have / should-have / could-have |
| `complexity` | 是 | simple / medium / complex |

### testableSteps 字段说明

每个测试步骤必须包含：

```json
{
  "step": 1,
  "action": "具体操作（如：点击、输入、导航）",
  "target": "目标元素或URL（如：#login-btn, http://localhost:3000/login）",
  "value": "可选，输入值",
  "verification": "验证条件（如：页面包含'欢迎'）"
}
```

### 功能拆分指导原则

**如何将大功能拆分为可测试的小功能：**

#### 原则 1：一个功能 = 一个用户可验证的结果

| ❌ 错误 | ✅ 正确 |
|--------|---------|
| "实现用户认证系统" | "用户登录功能"、"用户注册功能"、"用户登出功能" |
| "实现购物车" | "添加商品到购物车"、"从购物车删除商品"、"修改商品数量" |

#### 原则 2：每个步骤必须可自动化验证

| ❌ 错误 | ✅ 正确 |
|--------|---------|
| "验证用户体验流畅" | "点击登录按钮后，URL 包含 /dashboard" |
| "检查界面美观" | "页面标题包含 '欢迎'" |

#### 原则 3：按用户流程拆分

```
用户注册流程拆分示例：
├── 注册页面加载
├── 输入邮箱（格式验证）
├── 输入密码（强度验证）
├── 确认密码（一致性验证）
├── 点击注册按钮
├── 验证注册成功提示
└── 验证跳转到登录页
```

### 输出文件：`feature_list.json`

创建包含**可测试步骤**的完整功能清单：

```json
{
  "project": {
    "name": "your-project-name",
    "description": "项目描述",
    "complexity": "medium",
    "totalFeatures": 50,
    "createdAt": "2026-02-18T00:00:00Z"
  },
  "features": [
    {
      "id": "1",
      "category": "core",
      "description": "用户登录功能",
      "expectedOutcome": "用户可以使用有效凭据登录并跳转到仪表板",
      "testableSteps": [
        {
          "step": 1,
          "action": "导航到登录页面",
          "target": "http://localhost:3000/login",
          "verification": "页面包含'登录'标题"
        },
        {
          "step": 2,
          "action": "输入邮箱",
          "target": "#email",
          "value": "user@test.com",
          "verification": "输入框显示 user@test.com"
        },
        {
          "step": 3,
          "action": "输入密码",
          "target": "#password",
          "value": "TestPass123!",
          "verification": "输入框显示密码（遮盖）"
        },
        {
          "step": 4,
          "action": "点击登录按钮",
          "target": "#login-btn",
          "verification": "URL 包含 /dashboard"
        }
      ],
      "passes": false,
      "priority": "must-have",
      "complexity": "simple",
      "createdAt": "2026-02-18T00:00:00Z"
    }
  ]
}
```

### 分类体系

- `core`：核心功能（登录、基本导航）
- `feature`：主要产品功能
- `integration`：第三方服务连接
- `optimization`：性能和用户体验优化
- `safety`：安全和数据保护

### 优先级体系

- `must-have`：必须实现，否则功能不可用
- `should-have`：重要功能，但有 workaround
- `could-have`：增强功能锦上添花

---

## 第三阶段：项目结构设置

### 需要创建的文件

```
project-root/
├── CLAUDE.md              # 主配置文件（复制到根目录）
└── agent-loop/            # 子目录存放 Agent 相关文件
    ├── CLAUDE-INIT.md    # 此文件
    ├── CLAUDE-CODING.md  # 用于后续会话
    ├── feature_list.json # 完整功能清单
    ├── claude-progress.txt # 进度跟踪
    ├── init.sh           # 开发服务器启动脚本
    ├── run-agent-loop.ps1 # 循环执行脚本
    └── src/              # 你的项目代码
```

### 创建初始 Git 提交

```bash
# 如果项目还没有 Git 仓库，初始化 Git
git init

# 添加所有文件并创建初始提交
git add .
git commit -m "feat: initialize long-running agent project

- Add CLAUDE.md for main configuration
- Add agent-loop/ directory with agent files
- Add feature_list.json with testable features
- Add init.sh for development server
- Add run-agent-loop.ps1 for continuous execution"

# 创建 develop 分支用于后续开发
git checkout -b develop
```

---

## 第四阶段：验证设置

### 移交前运行

1. **启动开发服务器**：`./agent-loop/init.sh`
2. **验证服务器响应**：`curl http://localhost:3000`
3. **测试基本功能**：使用 Puppeteer 验证首页加载
4. **检查功能清单**：确认 `agent-loop/feature_list.json` 中所有条目 `passes: false`

### 生成进度报告

创建 `agent-loop/claude-progress.txt`：

```
=== PROJECT INITIALIZATION COMPLETE ===

Project: your-project-name
Complexity Score: 156 (Medium Application)
Total Features: 80
Date: 2026-02-18

INITIALIZATION CHECKLIST:
[x] Project structure created
[x] feature_list.json generated with testable steps
[x] init.sh configured and tested
[x] Initial git commit created
[ ] First coding session completed

NEXT STEPS:
1. Use agent-loop/CLAUDE-CODING.md for subsequent sessions
2. Begin implementing feature #1
3. Use Puppeteer to verify each feature after implementation
```

---

## 第五阶段：移交给编码代理

### 退出前验证：

- [ ] `agent-loop/feature_list.json` 包含所有功能且 `passes: false`
- [ ] `agent-loop/init.sh` 成功启动开发服务器
- [ ] 浏览器中首页加载无错误
- [ ] `agent-loop/claude-progress.txt` 已创建初始化摘要
- [ ] Git 提交已推送

### 退出协议

1. 告诉用户："项目初始化完成。后续会话请使用 agent-loop/CLAUDE-CODING.md。"
2. 建议："使用 `./agent-loop/run-agent-loop.ps1` 或手动运行 Claude 并使用 agent-loop/CLAUDE-CODING.md"
3. **保留此文件**（CLAUDE-INIT.md）供参考

---

## 关键提醒

1. **仅限初始化**：此文件仅用于第一个会话
2. **可测试步骤**：每个步骤必须可通过浏览器自动化验证
3. **PASSES = FALSE**：所有功能必须以 `passes: false` 开头
4. **禁止删除**：永远不要删除或修改已创建的测试步骤
5. **记录一切**：下一个代理依赖你的功能清单
6. **JSON 格式**：使用 JSON 是为了防止随意修改，只能修改 passes 字段

> 完成后，切换到 agent-loop/CLAUDE-CODING.md 进行持续开发。
