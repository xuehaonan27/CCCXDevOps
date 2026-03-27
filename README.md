# CCCXDevOps

A framework for Claude Code and Codex to work together on Development, Operations, and Maintenance tasks. Claude Code executes workflows; Codex reviews and advises at critical checkpoints.

## What It Is

- **Pure Skills + Scripts** -- no framework, no daemon, no database
- **`cp -r` to install** -- copy Markdown files to `~/.claude/skills/`
- **Cross-model review** -- Claude Code builds, Codex reviews
- **Composable workflows** -- run the full pipeline or any single skill

## v1 Scope

### Development Workflow (complete)

| Skill | Purpose |
|---|---|
| `cccx-using-devops` | Bootstrap: enforce skill-first behavior |
| `cccx-brainstorm` | Design exploration before code |
| `cccx-plan` | Implementation planning with exact tasks |
| `cccx-tdd` | Test-driven development discipline |
| `cccx-implement` | Subagent-driven implementation with review |
| `cccx-review` | Centralized Codex MCP review gateway |
| `cccx-verify` | Evidence-based completion verification |
| `cccx-debug` | Systematic root-cause debugging |
| `cccx-worktree` | Git worktree isolation |
| `cccx-finish` | Branch completion (merge/PR/keep/discard) |
| `cccx-dev-pipeline` | Full dev workflow: design to merge |

### Operations Pilot (deploy + monitor)

| Skill | Purpose |
|---|---|
| `cccx-deploy` | Configuration-driven deployment with safety review |
| `cccx-monitor` | Health monitoring via SERVICE_PROFILE.md |

## Quick Start

```bash
# Install
git clone <repo-url> /tmp/CCCXDevOps
bash /tmp/CCCXDevOps/scripts/install.sh

# Add this to your project's CLAUDE.md:
#   ## CCCXDevOps
#   When working in this project, check CCCXDevOps skills before taking action.
#   Invoke /cccx-using-devops at session start to activate workflow discipline.

# Optional: enable Codex review
npm install -g @openai/codex && codex setup
claude mcp add codex -s user -- codex mcp-server

# Use -- start Claude Code in your project, then:
#   /cccx-using-devops          -- activate workflow discipline
#   /cccx-dev-pipeline          -- full development workflow
#   /cccx-brainstorm            -- design exploration only
#   /cccx-debug                 -- systematic debugging only
```

See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed setup.

## How It Works

### Development Flow

```
cccx-brainstorm  -->  cccx-plan  -->  cccx-implement  -->  cccx-verify  -->  cccx-finish
     |                    |                 |                                      |
  [Codex review]     [Codex review]    [Codex review]                       [Codex review]
```

### Review Architecture

Only `cccx-review` talks to Codex MCP. Other skills request review by profile:

- `dev-design` -- design document review
- `dev-plan` -- implementation plan review
- `dev-implementation` -- code diff review
- `deploy-safety` -- deployment safety review

### Iron Laws

- **No code without design** -- brainstorm before you build
- **No production code without a failing test** -- TDD always
- **No fix without root cause** -- investigate before patching
- **No completion claim without evidence** -- run it, read it, cite it
- **No deploy without rollback plan** -- safety first

## Project Structure

```
skills/           -- Skill definitions (Markdown)
  cccx-*/         -- Individual skills
  shared-references/  -- Common guidelines and review profiles
scripts/          -- Support scripts (install, health-check, review-context)
templates/        -- Input templates (FEATURE_BRIEF, SERVICE_PROFILE, DEPLOYMENT_PLAN)
tests/            -- Test harnesses (trigger, content, mocked review, fixtures)
docs/             -- Documentation and development plan
```

## Reference
+ https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep
+ https://github.com/obra/superpowers

## License

See [LICENSE](LICENSE) for details.
