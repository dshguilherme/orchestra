---
name: cite-check
description: Audits every citation in a manuscript draft - that each reference exists, its metadata is right, and the cited work actually supports the sentence that cites it. Produces a report and applies safe fixes. Stage 6 of the research pipeline; run before polish.
---

# Citation check

Input: manuscript draft (`manuscript/`), its bibliography, and `wiki/` (sources, ledger). Output: `manuscript/citecheck.md` and fixes to the draft/bib. This is separate from prose polishing: settle the claims first, then fix the style.

## 1. Extract
List every citation instance: file, line, the **citing sentence** (full), the citekeys, and the bibliography entry. Also list bib entries never cited, and citekeys used but missing from the bib.

## 2. Check each reference (existence + metadata)
For each unique entry, via subagents in parallel (`haiku` for lookup, ~10 entries per agent):
- resolve DOI / arXiv ID / URL; confirm title, authors, year, venue, volume/pages match the bib entry;
- check it is the **right** paper (not a similarly titled one) and whether it has been retracted, superseded by a published version of a preprint, or corrected;
- check wiki: does `wiki/sources/<citekey>.md` exist and say `verified: true`? Cross-check its metadata.
Statuses: `OK`, `FIX` (metadata wrong - give corrected entry), `NOT FOUND` (cannot locate - treat as fabricated until proven otherwise), `UPGRADE` (preprint -> published), `RETRACTED`.

## 3. Check each claim (support)
For each citation instance, a verifier subagent (`sonnet`; `opus` for numerical or theorem-level claims) opens the **cited source's actual text** (PDF in `papers/` or fetched open-access copy) and decides:
- `SUPPORTED` - quote the passage + page/section;
- `PARTIAL` - the source says something weaker/narrower/different (state the difference);
- `UNSUPPORTED` - not in the source; `CONTRADICTED` - the source says the opposite;
- `UNVERIFIABLE` - full text inaccessible (paywalled): say so; do not guess from the abstract alone for specific numbers/claims.
Pay particular attention to: numbers, rates, constants, theorem conditions, "first to", "state of the art", and attributions of methods to the wrong authors. Check that a claim attributed to a survey isn't really from a primary paper it summarizes.

## 4. Blind second opinion
For `PARTIAL`/`UNSUPPORTED`/`CONTRADICTED` and a random 10% sample of `SUPPORTED` items, run the same check through a different model family via `${CLAUDE_PLUGIN_ROOT}/scripts/ask.ps1` (only send the citing sentence, the reference's identifiers and the question "does the cited work support this claim?"). Disagreements go to you: open the source yourself.

## 5. Report and fix
`manuscript/citecheck.md`: a summary table (counts per status) then every non-OK item with location, problem, evidence, proposed fix.
Apply **safe** fixes directly: corrected bib metadata, preprint upgrades, removal of uncited entries (list them), citekey typos. For claim problems, **don't silently rewrite scientific content**: propose the minimal edit (weaken the claim, cite the correct source, remove the sentence) and let the user approve, except for plain misattributions where the right source is already verified in the wiki.
Re-run steps 1-3 on everything touched. The stage is done when no `NOT FOUND`, `UNSUPPORTED`, `CONTRADICTED` or `RETRACTED` items remain, and remaining `PARTIAL`/`UNVERIFIABLE` ones are either fixed or explicitly accepted by the user (list them). Update `state.md`.
