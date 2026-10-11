---
name: dev-plan
description: Creates a parallel-maximal implementation plan for the code only, derived from the design vault's node graph - tasks, dependencies, waves, critical path, tests and acceptance bars, ready for the build skill to execute. Stage 3 of the develop pipeline.
---

# Implementation plan (code only)

Inputs: `spec.md`, `vault/` (confirmed design), the stack decision. Output: `dev/<slug>/plan/roadmap.md`. Scope is writing the code that realizes the vision; no research, papers, or documentation prose beyond keeping the vault in sync.

The vault already froze the interfaces (module APIs, function signatures, types, contracts), which is exactly what makes parallelism safe. The plan is mostly a graph transformation of the vault.

## 1. Derive tasks from the graph
- A task implements a **set of function/type nodes** that are cohesive (same module, tightly related) and sized for one agent in one sitting; list them as wikilinks. Split big modules; merge trivial helpers.
- **Dependencies** come from the vault, but only real ones: a task depends on another only if it needs that code *at run time or compile time to test itself*. Callers can be developed against **stubs/fakes** of callees thanks to the frozen signatures, so a call edge does not by itself force an order. Write the edge only where a real implementation is required for meaningful tests.
- Standard tasks to add: **T00 scaffold** (repo layout, build, lint, CI, test runner, stubs for every node from the vault signatures - one serial task that unblocks everyone); **types** (data structures with invariants); **test tasks** written from vault contracts and spec acceptance examples (can run in parallel with implementation); **integration** per flow (UC-n end to end); **non-functional** tasks (performance benchmarks, security checks) tied to quality requirements; final **docs/sync** task (design-vault sync mode).
- **Risk spikes first**: anything with high uncertainty (novel algorithm, unfamiliar API, performance target) gets its own early task on the critical path; if it fails, the plan changes before anything depends on it.

## 2. Waves and critical path
Topologically layer the tasks into **waves**; every task in a wave can start simultaneously. Mark the **critical path**; give it the strongest model and the earliest start. Check for avoidable serialization: shared files (assign ownership or split), a convention that belongs in the scaffold, or a dependency that stubs could remove. Report the speedup: tasks / waves, and the longest chain.

## 3. Task format

```
### T07 - Implement build_rule and Rule type         [code]
nodes: [[functions/quadrature.build_rule]], [[types/Rule]]
requirements: R-004
deps: T00, T03          # real deps only
files: src/quadrature.py, tests/test_quadrature.py
model: sonnet           isolation: worktree
accept: contract tests pass (preconditions, postconditions, examples from the note); property tests on invariants; no new dependency cycles
held-out: HT-014..HT-022    # sealed; run only by the critic
bar: <named, fetchable, comparable reference - see below>
```

Models: `haiku` for scaffolding/boilerplate, `sonnet` for standard implementation and tests, `opus` for core algorithms, concurrency, security-sensitive and spike tasks, and for all critics.

## 4. Bars
Each task needs a bar the `build` critic can compare against blind: the acceptance examples and contract tests from the vault; a reference implementation or existing tool's output on the same inputs; a published algorithm's known results; a performance target measured on a stated machine; an existing high-quality project's equivalent module for code quality. If no honest bar exists, state the acceptance test explicitly instead of a vague "good quality".

## 4b. Held-out tests (sealed from the coder)
The planner also decides **the tests the software must pass**. There are two kinds, and the difference matters:
- **Public tests**: contract and example tests from the vault, written by test tasks. The builder sees and runs these while working.
- **Held-out tests**: written now, during planning, stored in `dev/<slug>/plan/held-out/` **outside the code repo and outside every builder worktree**. The builder never sees them. Only the critic runs them.

How to write them:
- Derive from `spec.md` acceptance examples, requirement acceptance criteria, vault contracts and invariants, not from any implementation. Write them against the scaffold's stub signatures (T00) so they can run unchanged later.
- Make them **harsh**: boundary and degenerate inputs, malformed input and error paths, property-based tests for invariants, round-trip/metamorphic checks, randomized seeds fixed in the file, performance and scale targets from the quality requirements, regression traps for the likely wrong-but-plausible implementations, and cases that defeat hard-coding (many varied inputs, not the examples shown in public tests).
- Every test has an ID, the requirement(s) it covers, and a category. Keep an index `plan/held-out/INDEX.md` (ID, requirement, category, one-line intent; **no inputs or expected values**). Coverage rule: each Must requirement has at least two held-out tests, one beyond the happy path.
- Deterministic and runnable with one command (`plan/held-out/run.*`), which takes the repo path as an argument and copies/mounts the tests into a scratch location at run time.
- **Validate the tests before sealing**: they must fail on the T00 stubs, and a fresh agent that did not write them must confirm each is derivable from the spec (no hidden assumptions). A test that fails for a correct implementation is worse than none. When the first real implementation passes the public tests but fails a held-out test, a critic decides whether the code or the test is wrong, and the planner fixes the test if needed (log it in `plan/held-out/CHANGELOG.md` without revealing contents to builders).
- Author them with an agent that is **separate from every builder** and does not see the builders' output. Use `opus`, and for the most important ones consider a second model family via `ask.ps1` (question and spec only) to write adversarial cases.
- The **user may read** the held-out tests and is encouraged to review `INDEX.md` and the tests at the gate. The seal is against the coder, not the owner.

Each task lists the held-out IDs that gate it (`held-out: HT-014..HT-022`); tasks with no testable behavior (scaffolding) have none.

Limits to state honestly to the user: the seal is a convention plus file placement, not a sandbox. A builder with shell access could in principle find files elsewhere on disk, so the builder prompts forbid reading `plan/held-out/`, the critic checks the diff for references to it and for special-casing, and any breach invalidates that round.

## 5. Review and gate
- Self-check: acyclic; every vault node is covered by exactly one task; every requirement is reached by a task, a public test and (for Must) held-out tests; held-out tests validated against the stubs; tasks are small; critical path identified.
- Fresh adversarial `opus` subagent: "find missing tasks, hidden dependencies, tasks that cannot truly run in parallel, nodes with no task, tasks with no testable acceptance."
- Present to the user: number of tasks/waves, critical path, spikes, what is stubbed/deferred, risks, and decisions needing them. Set `state.md` (`stage: dev-plan`, approved: yes/no). **Do not start `build` without approval.**

## Hand-off
Execution is the `build` skill: it takes this roadmap wave by wave, one builder + one fresh-context critic per task in the gauntlet loop, merges winners, and runs the tests. After each wave, run design-vault sync mode to keep node `status` current.
