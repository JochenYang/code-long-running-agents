# Long-Running Agent Loop Framework

## Core Challenge

Agents work in discrete sessions with no memory of previous sessions. Two failure modes:

1. Trying to do too much at once, exhausting context
2. Premature completion after seeing existing progress

## Two-Agent Architecture

### Initializer Agent

First session creates:

- `init.sh` - Start development server
- `feature_list.json` - Feature list (initial passes: false)
- `claude-progress.txt` - Progress tracking
- Initial git commit

### Coding Agent

Subsequent session workflow:

1. Read claude-progress.txt + feature_list.json + git log
2. Run init.sh to start environment, verify basic functionality
3. Select passes=false feature from feature_list.json
4. Implement feature, run tests and verify
5. Update claude-progress.txt, git commit, mark passes: true
6. Loop until all features complete

## File Reference

| File | Description |
|------|-------------|
| CLAUDE.md | This documentation |
| feature_list.json | Feature list (tasks with passes: false) |
| claude-progress.txt | Progress tracking |
| init.sh | Dev server startup script (customize per project) |
| run-agent-loop.ps1 | Loop execution script |

## feature_list.json Format

```json
{
  "features": [
    {
      "id": "1",
      "description": "Feature description",
      "steps": ["Step 1", "Step 2"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

**Key Rules**:

- All features must start with passes: false
- Agent can only change to true after verification

## Usage

### 1. Copy to Target Project

```powershell
# Copy entire agent-loop folder to target project root
Copy-Item -Recurse agent-loop target-project/

# Or copy files manually
cp agent-loop/* target-project/
```

### 2. Configure Tasks

Edit `feature_list.json` to define your feature list:

```json
{
  "features": [
    {
      "id": "1",
      "description": "Create user login page",
      "steps": ["Create login.html", "Add form validation", "Integrate API"],
      "passes": false,
      "priority": "high"
    }
  ]
}
```

### 3. Configure Startup Script

Modify `init.sh` for your project:

```bash
#!/bin/bash
# Customize for your project
npm run dev
# or other startup commands
```

### 4. Execute Loop Tasks

```powershell
# Go to target project
cd target-project

# Run loop script
.\run-agent-loop.ps1

# Or limit iterations
.\run-agent-loop.ps1 -MaxIterations 10
```

## Manual Mode (Without Script)

If you want to manually control each iteration:

```powershell
# Start Claude Code
claude

# Tell it:
# "Please read feature_list.json and implement the first passes:false feature"
```

## Session Checklist

- [ ] pwd - Confirm working directory
- [x] Read claude-progress.txt (script auto-injects context)
- [ ] Read feature_list.json to select next feature
- [ ] git log --oneline -10 to view recent commits
- [ ] Run init.sh to start dev server
- [ ] Verify basic functionality works
- [ ] Implement single feature and test
- [ ] Update claude-progress.txt + git commit
- [ ] Mark feature passes: true (only after verification)
