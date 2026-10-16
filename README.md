# orchestra

**English** | [Português (BR)](README.pt-BR.md)

A Claude Code plugin of multi-model orchestration pipelines. Claude subagents do the work; Hermes, OpenClaw and Gemini can act as optional, independent cross-checks.

It has two pipelines (research papers and software) plus two small utility skills.

## Pipelines

### Research (`research` conductor)

From a hypothesis to a citation-checked manuscript. The conductor sequences the stages, keeps a state file in `research/<slug>/`, and resumes where it stopped. Each stage also works on its own.

| Stage | Skill | What it does |
| --- | --- | --- |
| 1 | `interview` | Socratic interview, one question at a time, that turns an idea into a precise brief and finds its weak points |
| 2 | `literature` | Literature review built as an Obsidian-style wiki plus a folder of open-access PDFs, with claims checked against primary sources |
| 3 | `proposal` | Drafts the article proposal and iterates it with you and an adversarial review |
| 4 | `plan` | Parallel-maximal task roadmap for the manuscript and its code, with acceptance bars |
| 5 | `build` | Builder/critic subagent pairs run the roadmap using the gauntlet-loop method |
| 6 | `cite-check` | Verifies every reference exists, its metadata is right, and the cited work supports the sentence |
| 7 | `polish` | Removes AI-writing patterns while protecting equations, citations, numbers and warranted hedging |

### Develop (`develop` conductor)

From a software idea to built code.

| Stage | Skill | What it does |
| --- | --- | --- |
| 1 | `spec-interview` | Socratic requirements extraction into a testable spec with IDs |
| 2 | `design-vault` | Designs the software as an Obsidian vault: modules, functions, types and decisions as linked notes, traced to requirements and tests |
| 3 | `dev-plan` | Parallel-maximal implementation plan from the vault graph, with sealed held-out tests |
| 4 | `build` | Executes the plan; syncs the vault after each wave |

## Utility skills

- **`one-shot`**: interviews you to sharpen a task into a spec, asks which model orchestrates and which model the subagents use, then runs a goal loop until the spec's success criteria are met. For focused tasks that don't need a full pipeline.
- **`your-words`**: prefix a request with `/your-words` and Claude first restates what it understood, what is unclear and what success looks like, then proceeds.

## Install

```
/plugin marketplace add dshguilherme/orchestra
/plugin install orchestra
```

For development: `claude --plugin-dir <path-to-this-repo>`.

## Usage

Type the skill name as a slash command, or just describe what you want:

```
/research        # start from a hypothesis
/develop         # start from a software idea
/interview       # stress-test an idea only
/one-shot <task>
/your-words <request>
```

## Requirements and notes

- `polish` needs the separate [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing) skill. It is calibrated for English; results on other languages are less reliable.
- `scripts/ask.ps1` (Windows PowerShell) sends a question to Hermes, OpenClaw or Gemini if they are installed. `-List` shows which are available. Without them the pipelines still run, minus the external cross-check.
- Only questions are sent to external models, never the vault, memory files or credentials.
- The pipelines run many agents and use a lot of your usage allowance. Use them for projects that merit it.

## Credits

See [NOTICE.md](NOTICE.md).
