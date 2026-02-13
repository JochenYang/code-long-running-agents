<div align="center">

# Long-Running Agent Loop Framework

A framework for executing long-running AI agent tasks with structured feature lists and progress tracking.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](#)

</div>

---

## Problem Solved

Core challenges AI agents face in long-running tasks:

| Challenge | Description |
|-----------|-------------|
| **Context Window Limits** | Each new session has no memory of previous work |
| **Premature Completion** | Agents tend to declare done too early when seeing existing progress |
| **Doing Too Much At Once** | Trying to complete entire project in one go leads to mid-way failures |

---

## Quick Start

### 1. Copy to Target Project

```powershell
# Option 1: Copy entire folder
Copy-Item -Recurse agent-loop target-project/

# Option 2: Copy only required files
cp agent-loop/feature_list.json target-project/
cp agent-loop/CLAUDE.md target-project/
```

### 2. Configure Tasks

Edit `feature_list.json`:

```json
{
  "features": [
    {
      "id": "1",
      "description": "Implement user login feature",
      "steps": ["Create login page", "Add form validation", "Integrate backend API"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

### 3. Start Claude Code

```powershell
cd target-project
claude
```

### 4. Execute Tasks

Tell Claude:

> "Please read feature_list.json and implement all passes:false features in priority order. Update passes to true after each completion and record progress."

---

## File Structure

| File | Description |
|------|-------------|
| `CLAUDE.md` | Agent workflow definition (auto-read by Claude Code) |
| `feature_list.json` | Feature list defining tasks to complete |
| `claude-progress.txt` | Progress tracking |
| `init.sh` | Development server startup script |
| `run-agent-loop.ps1` | Loop execution script (optional) |

---

## feature_list.json Format

```json
{
  "features": [
    {
      "id": "1",
      "description": "Feature description",
      "steps": ["Step 1", "Step 2", "Step 3"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

### Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| id | ✅ | Unique identifier |
| description | ✅ | Feature description |
| steps | ✅ | Implementation steps array |
| passes | ✅ | Completion status, initial false |
| priority | ✅ | Priority: high/medium/low |

---

## Core Rules

1. **All features must start with passes: false**
2. **Agent can only mark passes: true after verification**
3. **Implement only one feature at a time**
4. **Must commit git and update progress after completion**

---

## Workflow

```
1. Read CLAUDE.md (understand rules)
2. Read feature_list.json (select task)
3. Read claude-progress.txt (check progress)
4. Check git log (see history)
5. Start dev server (init.sh)
6. Verify basic functionality
7. Implement current feature
8. Test and verify
9. Update passes: true
10. Update progress record
11. Git commit
12. Loop to next feature
```

---

## Example Project

This repository includes a complete feature list for a comic generation project (15 features total):

| Priority | Feature |
|----------|---------|
| High | Project Infrastructure Setup |
| High | User Authentication System |
| High | AI Image Generation Panel |
| High | Image Editing Tools |
| High | Comic Panel Grid System |
| Medium | Speech Bubble System |
| Medium | Character Management System |
| Medium | Storyboard Management |
| Medium | Project/Workspace Management |
| Medium | Asset Library |
| Medium | Export Functionality |
| Low | History System |
| Low | AI Inpainting |
| Low | AI Image Upscaling |
| Low | Collaboration Features |

---

## Project Structure

```
code-long-running-agents/
├── README.md              # Chinese
├── README-EN.md           # English
├── LICENSE                # MIT License
├── agent-loop/            # Chinese version
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

## License

MIT License - see [LICENSE](LICENSE) for details.

</div>
