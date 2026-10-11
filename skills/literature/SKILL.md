---
name: literature
description: Runs a literature review for a confirmed research brief and builds it as an Obsidian-style wiki (source notes, concept notes, gap analysis, wikilinks) plus a folder of open-access PDFs. Orchestrates Claude subagents and independent external models (Hermes, OpenClaw, Gemini), with claim verification against primary sources. Stage 2 of the research pipeline.
---

# Literature review -> wiki

Input: `research/<slug>/brief.md` (read it fully; stop and go back to `interview` if it is missing or the hypothesis is not falsifiable). Output: a vault in `research/<slug>/wiki/` and PDFs in `research/<slug>/papers/`.

## 1. Plan
Write `wiki/plan.md`: the sub-questions (3-6, independent), search seeds from the brief, and the preflight question - **does this already exist?** Novelty is the most important finding of this stage; look for the closest prior work first. Include the brief's *open assumptions* as things to test.

## 2. Fan out
- **Claude subagents**, one per sub-question, parallel, single message, `general-purpose`. Model by job: `haiku` to scan and triage many candidates, `sonnet` to read papers and extract, `opus` only to reason over conflicting evidence. Use `references/subagent-prompt.md`. They write raw findings to `wiki/_raw/<subq>.md` and return a <=10-line summary.
- **Citation chasing**: for the 5-10 most relevant papers found, have a subagent follow their references and their citing papers (backward and forward) one hop.
- **External blind pass** on the 1-2 questions that decide novelty and the main method choice: send the *question only* via `${CLAUDE_PLUGIN_ROOT}/scripts/ask.ps1 -Adapter hermes|openclaw|gemini -Question "..." -Out wiki/_raw/ext-<model>.md`. Run `-List` first; use what is available and record what was not. Never send brief contents beyond the question itself.
- **Fetching papers**: arXiv, publisher open-access, author pages, institutional repositories. Save PDFs to `papers/<citekey>.pdf`. Paywalled: do not bypass; keep metadata + abstract and mark `access: paywalled`.

## 3. Build the wiki
Obsidian-compatible markdown, `[[wikilinks]]`, YAML frontmatter. Layout:

```
wiki/
  index.md        # entry point: scope, how to navigate, links to all concept notes + gaps + log
  plan.md
  log.md          # append-only: date, what was searched, what was added
  gaps.md         # open problems, unanswered questions, where the hypothesis sits relative to the literature
  novelty.md      # closest prior work, how the hypothesis differs, verdict (novel / partly / done already)
  concepts/<topic>.md   # synthesis notes; each claim links to sources
  sources/<citekey>.md  # one per paper
  _raw/                 # unprocessed agent output (kept for audit)
```

Source note (`sources/smith2021-trimmed.md`):
```
---
type: source
citekey: smith2021-trimmed
title: ...
authors: [...]
year: 2021
venue: ...
url: ...
pdf: ../papers/smith2021-trimmed.pdf   # or omit
access: open | paywalled
relevance: high | medium | low
verified: true | false
tags: [...]
---
## Summary            (3-5 sentences, own words)
## Key claims         (each: claim, page/section, short verbatim quote)
## Method / results   (numbers exactly as in the paper)
## Relation to our hypothesis   (supports / contradicts / extends / unrelated, and how)
## Links              [[concepts/...]], [[other-source]]
```

Concept notes synthesize across sources and cite with `[[sources/citekey]]`. Use consistent citekeys: `<firstauthor><year>-<keyword>`.

## 4. Verify (non-negotiable)
Track load-bearing claims in `wiki/ledger.md` (claim | source | how verified | models agreeing | status). Verified means the primary source was opened and the supporting text found. Always re-check numbers, equations, theorem conditions, rates and version numbers (use a verifier subagent with the template in `references/subagent-prompt.md`). On disagreement between agents/models, go to the source; don't average. A source note gets `verified: true` only when its key claims passed. Delete citations you cannot find - never soften them.

## 5. Wrap up
- Read `novelty.md` and `gaps.md` back against the brief; update the brief's *open assumptions* with what the literature says (annotate, don't overwrite the user's wording).
- Add to `state.md`: what was covered, what was not, which models ran/were unavailable.
- Tell the user, in a few lines: verdict on novelty, the 3-5 most important papers, the main gap, anything that challenges the hypothesis, and the path to open the vault. Ask whether to proceed to the proposal or to search deeper somewhere.

## Principles
Primary over secondary; date everything; "not found" is a finding; keep orchestrator context small (agents write files, you read selectively); cheap models scan, strong models judge, independent families cross-check; don't overwrite user edits to notes - read first and merge.
