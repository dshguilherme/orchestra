# orchestra

A Claude Code plugin of multi-model orchestration pipelines. Claude subagents do the work; Hermes, OpenClaw and Gemini act as independent cross-checks.

## Pipelines

**Research** (`research` conductor): `interview` -> `literature` (Obsidian wiki) -> `proposal` -> `plan` -> `build` -> `cite-check` -> `polish`

**Develop** (`develop` conductor): `spec-interview` -> `design-vault` (Obsidian node graph / function docs) -> `dev-plan` (with sealed held-out tests) -> `build`

## Install

```
/plugin marketplace add dshguilherme/orchestra
/plugin install orchestra
```
or for development: `claude --plugin-dir <path-to-this-repo>`

`polish` needs the separate [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing) plugin. `scripts/ask.ps1` (Windows PowerShell) calls external models if installed; `-List` shows which.

See `NOTICE.md` for credits.
