---
name: plan
description: Turns an accepted proposal, validated literature wiki and target journal into a parallel-maximal roadmap for the manuscript and its code - a task DAG with interfaces, acceptance bars and execution waves. Stage 4 of the research pipeline; run before build.
---

# Planning -> parallel roadmap

Inputs (read all): `brief.md`, `wiki/` (esp. `novelty.md`, `ledger.md`), `proposal/final.md` (or the latest accepted version). If the proposal is not accepted, go back to `proposal`.

Output: `research/<slug>/plan/` containing `journal.md`, `interfaces.md`, `roadmap.md`, `bars.md`.

## 1. Validate the target
Write `plan/journal.md`: scope fit, article type, length/figure limits, template (LaTeX class/Word), reference style, review model, open-access/APC constraints, typical structure, and **3-5 recent exemplar articles** from that journal close to our topic (URL + why). Fetch the author guidelines from the journal site, not from memory. If the hypothesis does not fit the journal's scope or the novelty verdict is "done already", stop and tell the user before planning further.

## 2. Freeze interfaces first
Parallelism fails on unclear seams. Before splitting work, write `plan/interfaces.md`:
- **Manuscript skeleton**: every section/subsection with its one-sentence claim, the wiki sources it cites (citekeys), and the figures/tables/equations it needs, with stable labels (`fig:convergence`, `eq:weak-form`, `tab:benchmark`).
- **Notation sheet**: symbols, units, conventions - one source of truth for all writers.
- **Code contracts**: repo layout, module boundaries, function signatures, data/file formats, numerical conventions, random seeds, how results are written (`results/<id>.json` with the numbers the paper quotes).
- **Result-to-paper bindings**: each number, figure and table in the manuscript is produced by a named code task and read from its result file. Writers never type results by hand.

## 3. Decompose into a DAG
`plan/roadmap.md`: one entry per task, small enough for one agent in one sitting:

```
### T07 - Implement trimmed-cell quadrature        [code]
deps: T03, T04          outputs: src/quadrature.*, tests, results/T07.json
bar: reference solution from <paper/benchmark> (see bars.md#T07)
model: sonnet           isolation: worktree
accept: reproduces benchmark values to <tolerance>; tests pass
```

Task types: `code`, `analysis`, `figure`, `writing`, `review`. Rules for maximal parallelism:
- Split by **interface**, not by phase: a writing task can start from the skeleton and the claim while the code that proves it is still running (it reads results via bindings and marks them `TBD`).
- Write dependencies only where a task truly consumes another's output. If two tasks only share a convention, put it in `interfaces.md` and drop the edge.
- Prefer many small independent tasks over few big ones; tests, baselines, figures, related-work text, methods text and abstract-skeleton can all start early.
- Code tasks that touch different files run in separate git worktrees; writing tasks each own one file (`manuscript/sections/<name>.tex|md`).
- Compute **waves** (topological layers). Each wave is a set of tasks launched simultaneously. Also mark the **critical path** and what is on it; put the strongest model and the earliest start there. Add a final serial tail only for assembly, cross-reference pass and abstract/intro rewrite.
- Assign model per task: `haiku` mechanical/scaffolding, `sonnet` standard implementation and drafting, `opus` core derivations, tricky numerics, and the critics.

## 4. Bars (for the build stage)
`plan/bars.md`: for every task, a **bar** - a specific, real, fetchable reference the work is compared against, blind:
- code: published benchmark values/figures from a source in the wiki, a reference implementation, an analytic solution, convergence rates stated in a paper;
- writing: the matching section of an exemplar article from `journal.md` (e.g. our Methods vs. their Methods);
- figures: a figure of the exemplar type from the journal.
A bar must be **named, fetchable, comparable**. If a task has no honest bar, say so and define the acceptance test explicitly; do not invent a vague one ("professional quality").

## 5. Review and gate
- Sanity-check the DAG yourself: no cycles, every manuscript claim is covered by a task that produces its evidence, every number has a producer, every task has a bar or a test.
- Run one adversarial subagent (`opus`, fresh context): "find missing tasks, hidden dependencies, tasks that cannot actually run in parallel, and claims with no producing task."
- Present to the user: number of tasks and waves, the critical path, estimated cost drivers, risks, and open decisions. Update `state.md` (`stage: plan`, approved: yes/no). Do not start `build` without approval.
