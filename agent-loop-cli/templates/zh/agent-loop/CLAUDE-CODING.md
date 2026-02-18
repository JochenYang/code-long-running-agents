# 编码代理（Coding Agent）——后续会话专用

> **重要提示**：此文件用于首次设置之后的**所有会话**。初始化代理（Initializer Agent）在首个会话使用 `agent-loop/CLAUDE-INIT.md`。

---

## 核心原则：证据优先于断言

> **"Evidence before assertions"** — Superpowers verification-before-completion 核心理念

在你声称任何功能"完成"或"通过"之前，你**必须**提供证据。没有证据的断言是不可接受的。

---

## 会话启动检查清单（必做）

**每个会话开始时必须按顺序执行：**

| 步骤 | 命令 | 说明 |
|------|------|------|
| 1 | `pwd` | 确认工作目录 |
| 2 | `git log --oneline -20` | 查看最近提交历史 |
| 3 | `cat agent-loop/claude-progress.txt` | 了解当前进度状态 |
| 4 | `jq '.features[] \| select(.passes == false)' agent-loop/feature_list.json` | 识别下一个待完成任务 |
| 5 | `./agent-loop/init.sh` | 启动开发服务器 |
| 6 | `./agent-loop/init.sh test` | 运行浏览器基础功能验证 |

> **关键规则**：如果基础功能测试失败，立即报告，不要继续开发新功能。

---

## Git 分支工作流（必须遵循）

### 首次会话：初始化 Git 仓库

如果项目还没有 Git 仓库：

```bash
# 初始化 Git 仓库
git init

# 创建初始提交
git add .
git commit -m "feat: initial project setup"

# 创建开发分支
git checkout -b develop
```

### 每个功能：创建独立分支

**每个功能必须在独立的 Git 分支上开发：**

```bash
# 基于 develop 创建新功能分支
git checkout -b feature/功能编号-功能名称

# 例如
git checkout -b feature/1-user-login
```

### 开发流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    Git 分支开发流程                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. git checkout -b feature/1-功能名称    → 创建功能分支        │
│  2. 实现功能 + 测试直到通过                                  │
│  3. git add . && git commit -m "feat: 完成功能描述"           │
│  4. git checkout develop                  → 切换到 develop     │
│  5. git merge feature/1-功能名称         → 合并功能分支       │
│  6. git push origin develop              → 推送到远程          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 提交规范

```
feat: complete user login feature

- Create login form component
- Add email/password validation
- Implement JWT authentication
- Verify login redirects to dashboard

Closes: #1
```

### 分支命名规范

| 分支类型 | 命名规则 | 示例 |
|---------|---------|------|
| 功能分支 | feature/编号-名称 | feature/1-user-login |
| 修复分支 | fix/编号-问题描述 | fix/2-login-validation |
| 开发分支 | develop | develop |
| 主分支 | main | main |

### 重要规则

1. **禁止直接在 main/master 分支开发**
2. **每个功能一个独立分支**
3. **合并前确保测试通过**
4. **合并后删除功能分支**

---

## 强制测试循环机制

### 测试循环流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    强制测试循环流程                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐               │
│   │  编写实现  │ → │ 运行测试  │ → │ 测试失败? │               │
│   └──────────┘    └──────────┘    └─────┬────┘               │
│                                          │                     │
│                    ┌─────────────────────┼─────────────────────┐│
│                    │                     │                     ││
│               ┌────┴────┐          ┌────┴────┐          ┌────┴────┐
│               │  是     │          │  否     │          │  超过   │
│               └────┬────┘          └────┬────┘          │  最大   │
│                    │                     │             │  重试?  │
│                    ▼                     ▼             └────┬────┘
│               ┌──────────┐    ┌──────────┐          ┌─────┴─────┐
│               │ 修复代码  │    │ 标记通过  │          │  记录失败  │
│               │ 重新测试  │    │ 更新进度  │          │  寻求帮助  │
│               └──────────┘    └──────────┘          └───────────┘
│                                                                 │
│   最大重试次数：3 次（可配置）                                   │
│   测试失败必须记录 failureReason                                 │
│   只有测试通过才能标记 passes: true                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 强制规则

#### 规则 1：最大重试次数

- **每个功能最多测试 3 次**
- 每次尝试后 `attemptCount` + 1
- 3 次失败后：
  - 记录 `failureReason`（详细说明失败原因）
  - 标记该功能为"需要人工帮助"
  - 继续下一个功能，不要阻塞

#### 规则 2：失败必须记录原因

```json
{
  "id": "1",
  "passes": false,
  "testedAt": "2026-02-18T10:30:00Z",
  "failureReason": "登录按钮点击后未跳转到 /dashboard，控制台报错：'JWT token invalid'",
  "attemptCount": 3
}
```

#### 规则 3：通过必须记录证据

```json
{
  "id": "1",
  "passes": true,
  "testedAt": "2026-02-18T10:30:00Z",
  "testEvidence": "screenshots/login-success-1234567890.png",
  "failureReason": null,
  "attemptCount": 2
}
```

---

## 严格规则：禁止修改测试

### 规则 4：绝对禁止删除或编辑测试

> **禁令**：移除、修改或隐藏测试步骤以使功能看起来已完成是严格禁止的。

**违反此规则的后果：**
- 下个会话的代理将无法验证功能是否真正实现
- 项目会出现隐藏的缺陷
- 这违反了长期运行代理的核心原则

```json
// 错误示例——绝对不要这样做：
{
  "testableSteps": [
    {"step": 1, "action": "检查是否工作", "verification": "无法验证"}
  ],
  "passes": true  // 虚假通过！
}

// 正确做法——保持具体可验证：
{
  "testableSteps": [
    {"step": 1, "action": "导航到登录页面", "target": "http://localhost:3000/login", "verification": "页面标题包含'登录'"},
    {"step": 2, "action": "输入有效邮箱", "target": "#email", "value": "user@test.com", "verification": "邮箱字段显示 'user@test.com'"}
  ],
  "passes": false  // 等待实际测试验证
}
```

### 规则 5：验证通过前禁止标记 passes: true

**每个 `passes: true` 必须满足以下条件：**

| 要求 | 说明 |
|-----|------|
| 测试证据 | 提供测试输出或截图作为证据 |
| 控制台无错误 | 浏览器控制台没有未解决的错误 |
| 功能符合预期 | 功能按照 `expectedOutcome` 描述正常工作 |
| 所有步骤通过 | `testableSteps` 中的每个步骤都已验证 |

**验证清单：**

```bash
# 运行功能验证测试
./agent-loop/init.sh test

# 检查测试结果
cat tests/browser-output/test-results.json

# 只有在测试全部通过后才能标记 passes: true
jq '.features[0].passes = true' agent-loop/feature_list.json > temp.json && mv temp.json agent-loop/feature_list.json
```

---

## 功能实现工作流

### 步骤 1：选择下一个功能

查找优先级最高且 `passes: false` 的功能：

```bash
# 显示待完成功能（按优先级排序）
jq -r '.features[] | select(.passes == false) | "\(.priority): \(.description)"' agent-loop/feature_list.json | sort | head -5

# 显示功能详情（包括尝试次数）
jq '.features[] | select(.passes == false) | {id, description, priority, complexity, attemptCount}' agent-loop/feature_list.json
```

### 步骤 2：理解功能需求

阅读完整的功能详情，特别是 `testableSteps`：

```json
{
  "id": "1",
  "category": "core",
  "description": "用户认证 - 登录功能",
  "expectedOutcome": "用户可以使用有效凭据登录并访问受保护区域",
  "testableSteps": [
    {
      "step": 1,
      "action": "导航到登录页面",
      "target": "http://localhost:3000/login",
      "verification": "页面标题或标题包含'登录'"
    },
    {
      "step": 2,
      "action": "输入有效邮箱地址",
      "target": "#email-input",
      "value": "user@test.com",
      "verification": "邮箱字段显示 'user@test.com'"
    }
  ],
  "passes": false,
  "attemptCount": 0,
  "priority": "must-have",
  "complexity": "simple"
}
```

### 步骤 3：实现功能

1. 编写代码以满足功能需求
2. **不要修改测试步骤来适应你的实现**
3. 如果测试看起来有问题，提出问题但**不要删除测试**

### 步骤 4：使用浏览器自动化验证

**使用 Puppeteer MCP 进行端到端测试：**

```javascript
// 验证登录功能示例
async function verifyLoginFeature() {
  // 1. 导航到登录页面
  await navigate_page({ url: 'http://localhost:3000/login' });

  // 2. 输入凭据
  await fill_form({
    elements: [
      { uid: 'email-input', value: 'user@test.com' },
      { uid: 'password-input', value: 'TestPass123!' }
    ]
  });

  // 3. 点击登录按钮
  await click({ uid: 'login-button' });

  // 4. 验证重定向
  const currentUrl = await evaluate_script({
    function: () => window.location.href
  });
  if (!currentUrl.includes('/dashboard')) {
    throw new Error('登录后未重定向到仪表板');
  }

  // 5. 验证用户头像可见
  const avatarVisible = await evaluate_script({
    function: () => document.querySelector('.user-avatar') !== null
  });
  if (!avatarVisible) {
    throw new Error('登录后用户头像不可见');
  }

  console.log('登录功能验证通过！');
  return true;
}
```

### 步骤 5：更新 passes 字段

**只有测试通过后才能更新：**

```bash
# 更新 feature_list.json（包含完整的测试证据）
jq '
  (.features[] | select(.id == "1")) |= {
    .passes: true,
    .testedAt: "2026-02-18T10:30:00Z",
    .testEvidence: "screenshots/login-success-1234567890.png",
    .attemptCount: 2,
    .failureReason: null,
    .updatedAt: "2026-02-18T10:30:00Z"
  }
' agent-loop/feature_list.json > temp.json && mv temp.json agent-loop/feature_list.json
```

### 步骤 6：更新进度

验证成功后：

1. 更新 `agent-loop/feature_list.json` 中的 passes 和相关字段
2. 更新 `agent-loop/claude-progress.txt` 记录完成的工作
3. 创建 Git 提交
4. 截图保存到 screenshots/ 目录

---

## 进度跟踪

### 查看进度

```bash
# 查看进度文件
cat agent-loop/claude-progress.txt

# 查看已完成功能
jq '.features[] | select(.passes == true) | {id, description, testedAt}' agent-loop/feature_list.json

# 查看待完成功能（包括失败原因）
jq '.features[] | select(.passes == false) | {id, description, priority, attemptCount, failureReason}' agent-loop/feature_list.json

# 计算完成百分比
jq -r '.features | (map(select(.passes == true)) | length) as $completed | .features | length as $total | "\($completed)/\($total) = \($completed * 100 / $total)%"' agent-loop/feature_list.json
```

### 写入进度（增强版）

更新 `agent-loop/claude-progress.txt`：

```
=== SESSION UPDATE ===

Date: 2026-02-18 10:30:00
Session: #3

COMPLETED THIS SESSION:
- Feature #1: 用户认证 - 登录功能
  - Status: PASSED (verified)
  - Tested At: 2026-02-18T10:25:00Z
  - Test Evidence: screenshots/login-success-1234567890.png
  - Attempt Count: 2

REMAINING WORK:
- Feature #2: 用户注册 (passes: false, attemptCount: 1)
  - 失败原因: 表单验证错误 - 邮箱格式校验未通过
- Feature #3: 密码重置 (passes: false, attemptCount: 0)

PROGRESS: 1 of 80 features complete (1.25%)

BLOCKERS:
- Feature #2 需要修复邮箱格式校验逻辑

VERIFICATION:
- Browser tests passed for all completed features
- No console errors detected
- Git commit: abc1234
```

---

## 常见陷阱及避免方法

| 陷阱 | 解决方案 |
|-----|---------|
| "测试全部通过"（但从未运行测试） | 始终运行实际的浏览器测试 |
| "看起来不错" | 使用 Puppeteer 进行客观验证 |
| "以后再修复" | 永远不要用已知问题标记 passes: true |
| "测试是错的" | 记录问题，不要删除测试 |
| "在我机器上能工作" | 在浏览器自动化中验证，而不仅仅在本地开发 |
| 跳过失败继续下一个 | 测试失败必须重试直到 3 次，然后记录失败原因 |

---

## 记住

1. **证据优先于断言** — 没有证据的"完成"声明是不可接受的
2. 你是一个长期运行过程中的一个代理
3. 下一个代理必须理解你做了什么
4. 你的变更必须可验证
5. 测试失败是正常的，记录原因并继续
6. 3 次重试后仍然失败，记录原因，继续下一个功能

> 当有疑问时，运行测试。测试通过后提交。完成后更新进度。

---

## 启动流程速查卡

```
╔════════════════════════════════════════════════════════════════╗
║                    会话启动流程 (6 步)                       ║
╠════════════════════════════════════════════════════════════════╣
║  1. pwd                    → 确认工作目录                    ║
║  2. git log --oneline -20  → 查看最近进度                   ║
║  3. cat agent-loop/claude-progress.txt → 了解当前状态                   ║
║  4. jq agent-loop/feature_list.json → 识别下一个任务         ║
║  5. ./agent-loop/init.sh             → 启动开发服务器         ║
║  6. ./agent-loop/init.sh test        → 基础功能验证         ║
╚════════════════════════════════════════════════════════════════╝
```

**如果在任何步骤发现问题，继续修复并重测，直到测试通过。不要跳过或放弃。**
