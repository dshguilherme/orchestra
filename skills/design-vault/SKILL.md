---
name: design-vault
description: Designs software as an Obsidian vault that is both the node-graph and the function documentation - modules, functions, types, flows and decisions as linked notes, traced to requirements and tests. Includes an existing-solutions preflight and a sync mode that checks vault against code. Stage 2 of the develop pipeline.
---

# Design vault (node graph + function docs)

Input: `dev/<slug>/spec.md` (confirmed). Output: `dev/<slug>/vault/`, an Obsidian vault where **the graph view is the architecture**: each note is a node, each `[[wikilink]]` an edge. It is written **before the code** as the design, then kept in sync as the code lands.

## 0. Existing-solutions preflight
Briefly search for maintained libraries, OSS projects and free platforms that already cover each major capability. Write `vault/decisions/D-001-build-vs-reuse.md`: per capability, candidates, verdict (reuse / wrap / build), reason. Choose the **stack** here too (language, key dependencies, test framework, packaging). Show the user the verdicts that surprise them before designing around them.

## 1. Vault structure
```
vault/
  index.md            # start here: vision, how to read the graph, links to everything
  graph.md            # Mermaid overview: modules and data flow (rendered by Obsidian)
  requirements/R-001.md ...     # one note per requirement, mirrors spec.md
  modules/<module>.md           # responsibility, public API, dependencies, owned types
  functions/<module>.<fn>.md    # one per function/method that matters
  types/<Type>.md               # data structures, invariants, serialization
  flows/<UC-n>.md               # use case as sequence: which functions in what order, error paths
  interfaces/<name>.md          # external systems, CLI/API surface, file formats
  decisions/D-00n-*.md          # design decisions with options and rationale
  tests/<module>.md             # test plan, and acceptance examples from spec
```
Granularity: a function note for every public function and every function with non-trivial logic, invariants or side effects. Trivial private helpers are listed in their module note. Prefer small, cohesive modules with a clear direction of dependency (no cycles: if you find one, fix the design).

## 2. Note formats
Frontmatter is machine-readable (the plan and sync checks parse it); tags make graph colors usable (`#type/function`, `#type/module`, ...).

Function note, e.g. `functions/quadrature.build_rule.md`:
```
---
type: function
module: "[[modules/quadrature]]"
signature: "build_rule(cell: Cell, degree: int) -> Rule"
status: designed            # designed | stubbed | implemented | verified | stale
requirements: ["[[requirements/R-004]]"]
calls: ["[[functions/geometry.clip_cell]]", "[[types/Rule]]"]
reads: []
writes: []
tags: [type/function]
---
## Purpose
## Inputs        (name, type, units, valid range)
## Outputs
## Behavior      (algorithm in steps; complexity)
## Preconditions / Postconditions / Invariants
## Errors        (which, when, how surfaced)
## Side effects  (I/O, global state, randomness/seeds)
## Examples      (input -> output, usable as tests)
## Tests         [[tests/quadrature]]  (property tests, edge cases)
## Notes / alternatives rejected
```
Module notes list responsibility, public API (links to function notes), `depends_on:` (module links), and the owned types. Flow notes link every function they call in order, so a use case reads as a path through the graph. `called_by` is not written by hand (Obsidian backlinks show it).

## 3. Design procedure
1. **Skeleton**: from the spec, derive modules and the dependency direction; write `graph.md` (Mermaid) and the module notes. Check modules against requirements: every requirement maps to at least one module.
2. **Types first**: data notes with invariants and example values; most bugs live in the data model.
3. **Functions, in parallel**: one subagent per module (`sonnet`; `opus` for the core algorithms) writes its function notes against the frozen module APIs and types. They must link requirements and write examples with real values.
4. **Flows**: one note per use case, walking the graph, including error flows. A flow that cannot be walked exposes a missing function; add it.
5. **Tests**: derive tests from requirement acceptance criteria, function examples, pre/postconditions and invariants.
6. **Adversarial review** (`opus`, fresh context, "find holes"): missing requirements coverage, orphan nodes, dependency cycles, functions whose contracts don't compose, unhandled error paths, vague contracts (can't be tested), over-engineering relative to the spec.
7. **Automated checks** (script or subagent, run against frontmatter and links): every requirement has >=1 function and >=1 test; every function links >=1 requirement (or is marked `support`); every wikilink resolves; no module cycles; every `calls` target exists. Fix, then report counts.
8. Present to the user: the Mermaid overview, module list, key decisions, surprises, and the vault path to open in Obsidian. They may edit notes; merge, don't overwrite. Update `state.md`.

## Sync mode (after build tasks, and at the end)
Compare vault and code: signatures, existence of functions, `calls` vs. real call graph, error behavior. Differences become one of: **code is wrong** (task to fix), **design changed on purpose** (update note, add decision, set `status`), or **undocumented function** (add a note or mark private helper). Update `status:` (`stubbed` -> `implemented` -> `verified` once its tests pass in a critic run). Never let the vault silently drift: report drift counts to the user.
