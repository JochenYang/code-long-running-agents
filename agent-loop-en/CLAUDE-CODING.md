# Coding Agent (Subsequent Sessions)

> **IMPORTANT**: Use this file for ALL sessions AFTER the initial setup. The Initializer Agent uses `agent-loop-en/CLAUDE-INIT.md` for the first session.

---

## Core Principle: Evidence Before Assertions

> **"Evidence before assertions"** — Superpowers verification-before-completion core principle

Before you claim any feature is "complete" or "passed", you **MUST** provide evidence. Assertions without evidence are unacceptable.

---

## Session Startup Checklist (Required)

**You MUST follow this order at the start of every session:**

| Step | Command | Description |
|------|---------|-------------|
| 1 | `pwd` | Confirm working directory |
| 2 | `git log --oneline -20` | Review recent commit history |
| 3 | `cat agent-loop/claude-progress.txt` | Understand current state |
| 4 | `jq '.features[] \| select(.passes == false)' agent-loop/feature_list.json` | Identify next pending task |
| 5 | `./agent-loop/init.sh` | Start development server |
| 6 | `./agent-loop/init.sh test` | Run browser basic functionality verification |

> **Critical Rule**: If basic functionality test fails, report immediately. Do not continue developing new features.

---

## Git Branch Workflow (Must Follow)

### First Session: Initialize Git Repository

If the project doesn't have a Git repository yet:

```bash
# Initialize Git repository
git init

# Create initial commit
git add .
git commit -m "feat: initial project setup"

# Create develop branch
git checkout -b develop
```

### Each Feature: Create Separate Branch

**Each feature must be developed on an independent Git branch:**

```bash
# Create feature branch from develop
git checkout -b feature/feature-id-feature-name

# Example
git checkout -b feature/1-user-login
```

### Development Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Git Branch Development Flow                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. git checkout -b feature/1-feature-name → Create feature branch│
│  2. Implement feature + test until pass                          │
│  3. git add . && git commit -m "feat: complete feature desc"   │
│  4. git checkout develop                 → Switch to develop    │
│  5. git merge feature/1-feature-name   → Merge feature branch │
│  6. git push origin develop             → Push to remote       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Commit Convention

```
feat: complete user login feature

- Create login form component
- Add email/password validation
- Implement JWT authentication
- Verify login redirects to dashboard

Closes: #1
```

### Branch Naming Convention

| Branch Type | Naming Rule | Example |
|------------|-------------|---------|
| Feature | feature/编号-名称 | feature/1-user-login |
| Fix | fix/编号-问题描述 | fix/2-login-validation |
| Develop | develop | develop |
| Main | main | main |

### Important Rules

1. **NEVER develop directly on main/master branch**
2. **One branch per feature**
3. **Ensure tests pass before merging**
4. **Delete feature branch after merging**

---

## Forced Test Loop Mechanism

### Test Loop Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Forced Test Loop Flow                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐               │
│   │Implement │ → │ Run Test │ → │ Test     │               │
│   │ Feature  │    │          │    │ Failed?  │               │
│   └──────────┘    └──────────┘    └─────┬────┘               │
│                                          │                     │
│                    ┌─────────────────────┼─────────────────────┐│
│                    │                     │                     ││
│               ┌────┴────┐          ┌────┴────┐          ┌────┴────┐
│               │   Yes   │          │   No    │          │ Exceeds │
│               └────┬────┘          └────┬────┘          │  Max    │
│                    │                     │             │ Retries?│
│                    ▼                     ▼             └────┬────┘
│               ┌──────────┐    ┌──────────┐          ┌─────┴─────┐
│               │Fix Code  │    │ Mark Pass │          │ Record    │
│               │Retest   │    │Update Prog│          │ Failure   │
│               └──────────┘    └──────────┘          │Ask for Help│
│               └──────────┘          └──────────┘          └───────────┘
│                                                                 │
│   Max retry attempts: 3 (configurable)                          │
│   Test failures must record failureReason                      │
│   Only mark passes: true after test passes                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Forced Rules

#### Rule 1: Maximum Retry Attempts

- **Maximum 3 test attempts per feature**
- Increment `attemptCount` by 1 after each attempt
- After 3 failures:
  - Record `failureReason` (detailed explanation)
  - Mark feature as "needs human help"
  - Continue to next feature, don't block

#### Rule 2: Failures Must Record Reason

```json
{
  "id": "1",
  "passes": false,
  "testedAt": "2026-02-18T10:30:00Z",
  "failureReason": "After clicking login button, did not redirect to /dashboard. Console error: 'JWT token invalid'",
  "attemptCount": 3
}
```

#### Rule 3: Passing Must Record Evidence

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

## Strict Rules: NO Modifying Tests

### Rule 4: NEVER Delete or Edit Tests

> **FORBIDDEN**: Removing, modifying, or hiding test steps to make features appear complete is strictly prohibited.

**Consequences of violating this rule:**
- The next session's agent won't be able to verify if features are truly implemented
- The project will have hidden defects
- This violates the core principles of long-running agents

```json
// WRONG - Never do this:
{
  "testableSteps": [
    {"step": 1, "action": "Check if it works", "verification": "Cannot verify"}
  ],
  "passes": true  // Fake pass!
}

// CORRECT - Keep it specific and verifiable:
{
  "testableSteps": [
    {"step": 1, "action": "Navigate to login page", "target": "http://localhost:3000/login", "verification": "Page title contains 'Login'"},
    {"step": 2, "action": "Enter valid email", "target": "#email", "value": "user@test.com", "verification": "Email field shows 'user@test.com'"}
  ],
  "passes": false  // Waiting for actual test verification
}
```

### Rule 5: NEVER Mark passes: true Without Testing

**Each `passes: true` MUST satisfy:**

| Requirement | Description |
|------------|-------------|
| Test evidence | Provide test output or screenshot as evidence |
| No console errors | Browser console has no unresolved errors |
| Feature works as expected | Feature works as described in `expectedOutcome` |
| All steps pass | Every step in `testableSteps` has been verified |

**Verification checklist:**

```bash
# Run feature verification tests
./agent-loop/init.sh test

# Check test results
cat tests/browser-output/test-results.json

# Only mark passes: true after all tests pass
jq '.features[0].passes = true' agent-loop/feature_list.json > temp.json && mv temp.json agent-loop/feature_list.json
```

---

## Feature Implementation Workflow

### Step 1: Select Next Feature

Find the highest priority feature with `passes: false`:

```bash
# Show pending features (sorted by priority)
jq -r '.features[] | select(.passes == false) | "\(.priority): \(.description)"' agent-loop/feature_list.json | sort | head -5

# Show feature details (including attempt count)
jq '.features[] | select(.passes == false) | {id, description, priority, complexity, attemptCount}' agent-loop/feature_list.json
```

### Step 2: Understand Feature Requirements

Read the complete feature details, especially `testableSteps`:

```json
{
  "id": "1",
  "category": "core",
  "description": "User Authentication - Login Feature",
  "expectedOutcome": "User can login with valid credentials and access protected area",
  "testableSteps": [
    {
      "step": 1,
      "action": "Navigate to login page",
      "target": "http://localhost:3000/login",
      "verification": "Page title contains 'Login'"
    },
    {
      "step": 2,
      "action": "Enter valid email address",
      "target": "#email-input",
      "value": "user@test.com",
      "verification": "Email field shows 'user@test.com'"
    }
  ],
  "passes": false,
  "attemptCount": 0,
  "priority": "must-have",
  "complexity": "simple"
}
```

### Step 3: Implement Feature

1. Write code to satisfy the feature requirements
2. **Don't modify test steps to fit your implementation**
3. If tests seem problematic, raise the issue but **don't delete tests**

### Step 4: Verify with Browser Automation

**Use Puppeteer MCP for end-to-end testing:**

```javascript
// Example: Verify login feature
async function verifyLoginFeature() {
  // 1. Navigate to login page
  await navigate_page({ url: 'http://localhost:3000/login' });

  // 2. Enter credentials
  await fill_form({
    elements: [
      { uid: 'email-input', value: 'user@test.com' },
      { uid: 'password-input', value: 'TestPass123!' }
    ]
  });

  // 3. Click login button
  await click({ uid: 'login-button' });

  // 4. Verify redirect
  const currentUrl = await evaluate_script({
    function: () => window.location.href
  });
  if (!currentUrl.includes('/dashboard')) {
    throw new Error('Did not redirect to dashboard after login');
  }

  // 5. Verify user avatar visible
  const avatarVisible = await evaluate_script({
    function: () => document.querySelector('.user-avatar') !== null
  });
  if (!avatarVisible) {
    throw new Error('User avatar not visible after login');
  }

  console.log('Login feature verified!');
  return true;
}
```

### Step 5: Update passes Field

**Only update after tests pass:**

```bash
# Update feature_list.json (with complete test evidence)
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

### Step 6: Update Progress

After successful verification:

1. Update passes and related fields in `agent-loop/feature_list.json`
2. Update `agent-loop/claude-progress.txt` with completed work
3. Create Git commit
4. Save screenshot to screenshots/ directory

---

## Progress Tracking

### View Progress

```bash
# View progress file
cat agent-loop/claude-progress.txt

# View completed features
jq '.features[] | select(.passes == true) | {id, description, testedAt}' agent-loop/feature_list.json

# View pending features (including failure reasons)
jq '.features[] | select(.passes == false) | {id, description, priority, attemptCount, failureReason}' agent-loop/feature_list.json

# Calculate completion percentage
jq -r '.features | (map(select(.passes == true)) | length) as $completed | .features | length as $total | "\($completed)/\($total) = \($completed * 100 / $total)%"' agent-loop/feature_list.json
```

### Write Progress (Enhanced)

Update `agent-loop/claude-progress.txt`:

```
=== SESSION UPDATE ===

Date: 2026-02-18 10:30:00
Session: #3

COMPLETED THIS SESSION:
- Feature #1: User Authentication - Login Feature
  - Status: PASSED (verified)
  - Tested At: 2026-02-18T10:25:00Z
  - Test Evidence: screenshots/login-success-1234567890.png
  - Attempt Count: 2

REMAINING WORK:
- Feature #2: User Registration (passes: false, attemptCount: 1)
  - Failure reason: Form validation error - email format validation failed
- Feature #3: Password Reset (passes: false, attemptCount: 0)

PROGRESS: 1 of 80 features complete (1.25%)

BLOCKERS:
- Feature #2 needs email format validation logic fix

VERIFICATION:
- Browser tests passed for all completed features
- No console errors detected
- Git commit: abc1234
```

---

## Common Pitfalls and Solutions

| Pitfall | Solution |
|---------|----------|
| "All tests pass" (but never ran tests) | Always run actual browser tests |
| "Looks good" | Use Puppeteer for objective verification |
| "Fix later" | Never mark passes: true with known issues |
| "Tests are wrong" | Document issues, don't delete tests |
| "Works on my machine" | Verify in browser automation, not just local dev |
| Skip failures and continue | Test failures must retry until 3 attempts, then record failure |

---

## Remember

1. **Evidence before assertions** — "Complete" claims without evidence are unacceptable
2. You are one agent in a long-running process
3. The next agent must understand what you did
4. Your changes must be verifiable
5. Test failures are normal, record the reason and continue
6. After 3 retries still fails, record reason and continue to next feature

> When in doubt, run tests. After tests pass, commit. After complete, update progress.

---

## Startup Quick Reference

```
╔════════════════════════════════════════════════════════════════╗
║               Session Startup Flow (6 Steps)          ║
╠════════════════════════════════════════════════════════════════╣
║  1. pwd                    → Confirm working directory    ║
║  2. git log --oneline -20  → View recent progress        ║
║  3. cat agent-loop/claude-progress.txt → Understand current state     ║
║  4. jq agent-loop/feature_list.json → Identify next task   ║
║  5. ./agent-loop/init.sh             → Start dev server  ║
║  6. ./agent-loop/init.sh test        → Basic verification ║
╚════════════════════════════════════════════════════════════════╝
```

**If any step发现问题，停止并报告。不要继续。**
