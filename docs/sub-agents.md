# Sub-Agents

All sub-agents live in `.claude/agents/` as Markdown files with YAML frontmatter. The frontmatter configures the agent; the Markdown body is its system prompt.

## Agent Index

| Agent | File | Model | Tools | Purpose |
| --- | --- | --- | --- | --- |
| `code-writer` | `.claude/agents/code-writer.md` | sonnet | Read, Write, Edit, Glob, Grep, Bash | Implements code changes and new features |
| `code-reviewer` | `.claude/agents/code-reviewer.md` | sonnet | Read, Glob, Grep, Write | Reviews code for bugs and over-engineering |
| `lessons-collector` | `.claude/agents/lessons-collector.md` | sonnet | Read, Write, Bash | Extracts reusable lessons from review findings |

## File Format

```markdown
---
name: agent-name           # lowercase, hyphens only; matches filename
description: ...           # when Claude should delegate to this agent
tools: Read, Write, Bash   # comma-separated allowlist; omit to inherit all
model: sonnet              # sonnet | opus | haiku | inherit
---

System prompt goes here.
```

## Invocation

**Natural language** — Claude decides automatically:

```text
Use the code-reviewer agent to review my changes
```

**@-mention** — guaranteed invocation:

```text
@"code-reviewer (agent)" review MainFile.cs
```

## Typical Workflow

```text
main agent        →  creates task file:    .claude/tmp/task-<short-description>-<YYYYMMDD>.md
code-writer       →  reads task file, writes or modifies code
                     writes impl lessons to .claude/tmp/lessons-<short-description>-<YYYYMMDD>.md
code-reviewer     →  reviews the output
                     writes review findings to .claude/tmp/review-<mod-name>-<YYYYMMDD>.md
                     appends review lessons to .claude/tmp/lessons-<short-description>-<YYYYMMDD>.md
main agent        →  deletes task file after APPROVED
lessons-collector →  reads lessons + review temp files, appends to docs/dev-lessons.md, deletes temp files
```

## Adding a New Agent

1. Create `.claude/agents/<agent-name>.md` with frontmatter + system prompt
2. Add a row to the Agent Index table above
3. Copy the file to your boilerplate repo if it belongs there
