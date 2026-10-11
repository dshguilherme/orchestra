---
name: proposal
description: Drafts an article proposal from the research brief and literature wiki, then iterates it with the user's feedback and an adversarial LLM review until both are satisfied. Stage 3 of the research pipeline.
---

# Article proposal -> iteration

Inputs: `brief.md`, `wiki/` (especially `novelty.md`, `gaps.md`, `concepts/`, `ledger.md`). Output: `research/<slug>/proposal/v<N>.md` and `proposal/feedback.md`.

## 1. Draft v1
Write `proposal/v1.md`, grounded in the wiki; every substantive claim cites `[[wiki/sources/<citekey>]]` (convert to a bibliography at the end). Do not cite anything not in the wiki; if you need a new source, add it to the wiki through the `literature` skill's verification rules first.

Structure:
1. **Working title** and one-paragraph abstract
2. **Problem and motivation**
3. **State of the art** - what exists, closest prior work, the gap (from `novelty.md`/`gaps.md`)
4. **Contribution** - precise, falsifiable statement of what is new
5. **Approach / methodology**
6. **Evidence plan** - theory, experiments, benchmarks, data; what results confirm or refute
7. **Risks and limitations** - including anything the literature suggests may defeat the idea
8. **Target venue, outline of the paper, timeline**
9. **Bibliography**

State uncertainty honestly: where the novelty verdict is "partly done already", say so in the proposal rather than hiding it.

## 2. Review round (each version)
Before showing the user, run an **adversarial review**:
- Spawn a Claude subagent (`opus`, fresh context, reviewer persona: "a skeptical referee for <venue>; find reasons to reject; check novelty claims against the wiki, citations against sources, and whether the evidence plan can actually support the contribution"). Give it the proposal and wiki path, not your reasoning.
- Optionally for the first and the final version, an independent family via `${CLAUDE_PLUGIN_ROOT}/scripts/ask.ps1` (send the proposal text only if the user has approved sharing it externally; otherwise skip and say so).
- Triage the review: fix what is clearly right; keep disagreements for the user to decide, flagged.

## 3. Iterate with the user
Show the user: the path, a short summary of the proposal (not the whole text), the reviewer's top issues and what you already fixed, and the open decisions only they can make. Then take feedback.

For each round:
1. Append to `proposal/feedback.md`: round number, the user's feedback (their words), the reviewer's points, and your resolution of each (accepted / rejected + reason / needs user decision).
2. Write `proposal/v<N+1>.md` with a short **Changes from v<N>** section at the top. Never edit an earlier version in place.
3. Go to the review round again.

## 4. Done when
- the user says it is satisfactory, **or**
- the reviewer finds no blocking issues and the user has no outstanding feedback, and you have confirmed with the user. 

If three rounds pass with the same issue unresolved, stop iterating and tell the user what the real disagreement is (e.g. "the literature suggests X, you want Y"); possibly return to `interview` or `literature`. On acceptance, set `stage: done` in `state.md`, and copy the final version to `proposal/final.md`.
