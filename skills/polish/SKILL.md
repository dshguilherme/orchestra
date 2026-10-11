---
name: polish
description: Removes AI-writing patterns from a citation-checked scientific manuscript using the avoid-ai-writing skill, while protecting equations, citations, numbers and scientifically warranted hedging. Final stage of the research pipeline.
---

# Anti-AI-slop polish

Runs after `cite-check`. The prose is edited **without changing the science**: claims, numbers, math, references and their placement stay exactly as verified.

Uses the `avoid-ai-writing` skill (github.com/conorbronsdon/avoid-ai-writing, MIT; Detect / Rewrite / Edit modes, pattern catalog in `references/patterns.md`). 

## Setup check
If `avoid-ai-writing` is not among the available skills, tell the user to install it - `/plugin marketplace add conorbronsdon/avoid-ai-writing` then install, or `git clone https://github.com/conorbronsdon/avoid-ai-writing ~/.claude/skills/avoid-ai-writing` - and stop. Do not substitute your own idea of AI patterns. Its README states it is calibrated for English; if the manuscript is in another language, say the result will be less reliable.

## Procedure
1. **Snapshot.** Commit or copy the cite-checked manuscript (`manuscript/pre-polish/`). Record a **preservation manifest**: every citekey with count per section, every `\ref`/`\label`/equation, every number with its unit, every defined term/acronym. 
2. **Detect first.** Run `avoid-ai-writing` in Detect mode, one section at a time (technical voice profile if offered), on the prose only. Triage flags into: *real problem*, *judgment call*, *scientifically legitimate* (e.g. a hedge backed by uncertainty in the data, standard phrasing the journal expects, defined terminology). Keep that triage in `manuscript/polish.md`.
3. **Rewrite per section, with guards.** Run Rewrite/Edit on one section at a time as plain prose. Never pass LaTeX preambles, math environments, bib files, tables of results, or code; protect inline math and `\cite`, `\ref`, `\label`. Instruct it: keep every claim, number, citation and equation unchanged; do not add content, adjectives of significance or new claims; keep hedges that reflect real uncertainty; keep field terminology; keep the journal's voice and tense conventions from `plan/journal.md` (e.g. passive vs. active in Methods). Section edits can run in parallel (one agent per section file).
4. **Verify preservation.** Diff against the snapshot and recompute the manifest: citekeys, refs, labels, equations, numbers, terms must match exactly. Any difference is reverted or justified. Use the skill's own validator if present. A fresh critic subagent reads old vs. new and answers: *was any claim strengthened, weakened, added or lost?* Fix those.
5. **Second detect pass** on the final text; leave judgment calls the user can see. Don't iterate more than twice - over-polishing flattens a writer's voice and introduces new tells.
6. **Compile** the manuscript, check that the PDF builds, and fix reference/label breakage.
7. **Report**: sections touched, patterns most often removed, any flags deliberately left, any content changes you reverted. Set `stage: done`, with the final manuscript path. Recommend the user read it through in their own voice; this tool reduces tells, it doesn't replace authorship.

Note for honesty: removing stylistic patterns doesn't make text "undetectable", and the user should follow the target journal's policy on AI-assisted writing disclosure. Mention it once in the report.
