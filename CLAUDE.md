# CCCXDevOps - Claude Code CodeX DevOps

A framework for Claude Code and Codex to work together, providing Development, Operations and Maintenance which is reliable, carefully examined by both Claude Code and Codex, and of high quality.

## General Desire
CCCXDevOps should not involve complicated setup. It should only contain SKILLs and scripts for agent to better execute the SKILLs.

User could lanuch a workflow with a SKILL use, and Claude Code should run the workflow, with Codex monitoring, review and examine what Claude Code is going to do, and provide advices.


## Project to borrow from / refer to
**NOTE: Projects already fetched to current workspace, NO NEED FOR fetching from web again, just explore the local repository**

1. Auto-claude-code-research-in-sleep
    + Original URL: https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep
    + Location: `./Auto-claude-code-research-in-sleep`
    + Pros: This project describes what workflow I want to achieve exactly: full pipeline / single step breakdown; pure SKILL and scripts, simple installation (via `cp -r`); Codex serving as MCP for Claude Code, and Claude Code should request Codex for reviewing action at proper time.
    + Cons: This project is for ML research, not for Development, Operations and Maintenance.
2. superpowers
    + Original URL: https://github.com/obra/superpowers
    + Location: `./superpowers`
    + Pros: This project contains SKILLs and workflows that is useful for CCCXDevOps development, since it is a project designed for software development. And it's test driven development (TDD) style is preferred.
    + Cons: It doesn't cover Operations and Maintenance. And it's installation is complex; instead, pure SKILL and scripts are preferred.

Goal: combine Pros of `Auto-claude-code-research-in-sleep` and `superpowers`, providing pure SKILL and scripts style, workflows of different grains for Development, Operations and Maintenance.

Note: SKILLs should be prefixed with `cccx`, since there will be many skills, co-exist with existing installed SKILLs. That might confuse both Agent and Human user if CCCXDevOps SKILLs are not prefixed.
