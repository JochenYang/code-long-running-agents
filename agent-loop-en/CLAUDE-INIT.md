# Initializer Agent (First Session Only)

> **IMPORTANT**: This file is ONLY for the FIRST agent session. Subsequent sessions must use `agent-loop-en/CLAUDE-CODING.md`.

## Your Mission

You are an Initializer Agent responsible for setting up a long-running agent project. Your job is to:

1. **Assess project complexity** and determine appropriate feature granularity
2. **Generate a comprehensive testable feature list** (50-500 items based on complexity)
3. **Create the initial project structure** with proper scaffolding
4. **Verify the setup works** before handing off to the Coding Agent

---

## Phase 1: Project Complexity Assessment

### Step 1: Collect Project Metrics

Run these commands to gather project metrics:

```bash
# Count feature descriptions if feature_list.json exists
FEATURE_COUNT=$(jq '.features | length' feature_list.json 2>/dev/null || echo "0")

# Count npm dependencies
DEPS_COUNT=$(jq '.dependencies | length' package.json 2>/dev/null || echo "0")

# Count source files
SRC_FILES=$(find src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l)

# Estimate integrations (API calls, services)
INTEGRATIONS=$(grep -rE "fetch|axios|WebSocket|connect|endpoint" src --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | wc -l)
```

### Step 2: Calculate Complexity Score

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

// Example output interpretation:
// < 100: Simple utility
// 100-200: Medium application
// 200-350: Complex system
// > 350: Enterprise system
```

### Step 3: Determine Feature Granularity

| Complexity Score | Project Type | Target Feature Items | Steps Per Feature |
|-----------------|--------------|---------------------|-------------------|
| < 100 | Simple utility | 30-50 | 5-8 |
| 100-200 | Medium app | 50-100 | 8-12 |
| 200-350 | Complex system | 100-200 | 12-18 |
| > 350 | Enterprise | 200-500 | 15-25 |

**Formula**: `targetItems = max(30, min(500, 50 + complexityScore))`

---

## Phase 2: Generate Feature List

### Key Principle: JSON Format Prevents Arbitrary Modification

Using JSON format is chosen because it **prevents arbitrary modification**. The AI can only modify the `passes` field, all other fields must remain intact.

### Feature Template Fields

**Each feature must include these fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (number or string) |
| `category` | Yes | Category: core/feature/integration/optimization/safety |
| `description` | Yes | Feature description - brief explanation |
| `expectedOutcome` | Yes | Expected result - what user sees after completion |
| `testableSteps` | Yes | Array of testable steps (see below) |
| `passes` | Yes | Must be `false` initially |
| `priority` | Yes | must-have / should-have / could-have |
| `complexity` | Yes | simple / medium / complex |

### testableSteps Field Format

Each test step must include:

```json
{
  "step": 1,
  "action": "Specific action (e.g., click, input, navigate)",
  "target": "Target element or URL (e.g., #login-btn, http://localhost:3000/login)",
  "value": "Optional, input value",
  "verification": "Verification condition (e.g., page contains 'Welcome')"
}
```

### Feature Splitting Guidance Principles

**How to split large features into testable smaller ones:**

#### Principle 1: One Feature = One User-Verifiable Result

| ❌ Wrong | ✅ Correct |
|---------|------------|
| "Implement user authentication system" | "User login feature", "User registration feature", "User logout feature" |
| "Implement shopping cart" | "Add item to cart", "Remove item from cart", "Modify item quantity" |

#### Principle 2: Each Step Must Be Automatable

| ❌ Wrong | ✅ Correct |
|---------|------------|
| "Verify smooth user experience" | "After clicking login button, URL contains /dashboard" |
| "Check UI aesthetics" | "Page title contains 'Welcome'" |

#### Principle 3: Split by User Flow

```
User Registration Flow Split Example:
├── Registration page loads
├── Enter email (format validation)
├── Enter password (strength validation)
├── Confirm password (consistency validation)
├── Click registration button
├── Verify registration success message
└── Verify redirect to login page
```

### Output: `feature_list.json`

Create a comprehensive feature list with **testable steps**:

```json
{
  "project": {
    "name": "your-project-name",
    "description": "Project description",
    "complexity": "medium",
    "totalFeatures": 50,
    "createdAt": "2026-02-18T00:00:00Z"
  },
  "features": [
    {
      "id": "1",
      "category": "core",
      "description": "User login feature",
      "expectedOutcome": "User can login with valid credentials and be redirected to dashboard",
      "testableSteps": [
        {
          "step": 1,
          "action": "Navigate to login page",
          "target": "http://localhost:3000/login",
          "verification": "Page contains 'Login' title"
        },
        {
          "step": 2,
          "action": "Enter email",
          "target": "#email",
          "value": "user@test.com",
          "verification": "Input field shows user@test.com"
        },
        {
          "step": 3,
          "action": "Enter password",
          "target": "#password",
          "value": "TestPass123!",
          "verification": "Input field shows password (masked)"
        },
        {
          "step": 4,
          "action": "Click login button",
          "target": "#login-btn",
          "verification": "URL contains /dashboard"
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

### Categories

- `core`: Essential functionality (login, basic navigation)
- `feature`: Main product features
- `integration`: Third-party service connections
- `optimization`: Performance and UX improvements
- `safety`: Security and data protection

### Priority Levels

- `must-have`: Must implement, otherwise feature is unusable
- `should-have`: Important feature but has workaround
- `could-have`: Nice-to-have enhancement

---

## Phase 3: Project Structure Setup

### Required Files to Create

```
project-root/
├── CLAUDE.md              # Main config (copied to root)
└── agent-loop/            # Subdirectory for agent files
    ├── CLAUDE-INIT.md     # This file
    ├── CLAUDE-CODING.md   # For subsequent sessions
    ├── feature_list.json  # Comprehensive feature list
    ├── claude-progress.txt # Progress tracking
    ├── init.sh           # Development server startup
    ├── run-agent-loop.ps1 # Loop execution script
    └── src/              # Your project code
```

### Create Initial Git Commit

```bash
# If project doesn't have Git repo yet, initialize Git
git init

# Add all files and create initial commit
git add .
git commit -m "feat: initialize long-running agent project

- Add CLAUDE.md for main configuration
- Add agent-loop/ directory with agent files
- Add feature_list.json with testable features
- Add init.sh for development server
- Add run-agent-loop.ps1 for continuous execution"

# Create develop branch for ongoing development
git checkout -b develop
```

---

## Phase 4: Verify Setup

### Run Before Handoff

1. **Start development server**: `./agent-loop/init.sh`
2. **Verify server responds**: `curl http://localhost:3000`
3. **Test basic functionality**: Use Puppeteer to verify homepage loads
4. **Check feature list**: Confirm all entries in `agent-loop/feature_list.json` have `passes: false`

### Generate Progress Report

Create `agent-loop/claude-progress.txt`:

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

## Phase 5: Handoff to Coding Agent

### Before Exiting, Verify:

- [ ] `agent-loop/feature_list.json` contains all features with `passes: false`
- [ ] `agent-loop/init.sh` successfully starts development server
- [ ] Homepage loads without errors in browser
- [ ] `agent-loop/claude-progress.txt` created with initialization summary
- [ ] Git commit pushed

### Exit Protocol

1. Tell the user: "Project initialization complete. Use agent-loop/CLAUDE-CODING.md for subsequent sessions."
2. Suggest: "Start with `./agent-loop/run-agent-loop.ps1` or manually run Claude with agent-loop/CLAUDE-CODING.md"
3. **Keep this file** (CLAUDE-INIT.md) for reference

---

## Key Reminders

1. **INITIALIZER ONLY**: This file is for the FIRST session only
2. **TESTABLE STEPS**: Every step must be verifiable through browser automation
3. **PASSES = FALSE**: All features must start with `passes: false`
4. **NO DELETION**: Never delete or modify test steps once created
5. **DOCUMENT EVERYTHING**: The next agent depends on your feature list
6. **JSON FORMAT**: Using JSON prevents arbitrary modification, only passes field can be changed

> When complete, switch to agent-loop/CLAUDE-CODING.md for ongoing development.
